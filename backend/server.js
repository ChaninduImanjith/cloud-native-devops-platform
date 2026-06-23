"use strict";

const express = require("express");
const cors = require("cors");
const client = require("prom-client");

const app = express();

// ─── Prometheus Registry & Default Metrics ───────────────────────────────────
const register = new client.Registry();

// Attach default Node.js metrics (event loop lag, GC, heap, etc.)
client.collectDefaultMetrics({
  register,
  prefix: "nodejs_",
  gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5],
});

// ─── Custom HTTP Metrics ──────────────────────────────────────────────────────

// Total HTTP requests counter, labelled by method, route, and status code
const httpRequestsTotal = new client.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"],
  registers: [register],
});

// HTTP request duration histogram (latency buckets in seconds)
const httpRequestDuration = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "HTTP request duration in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
  registers: [register],
});

// Active in-flight requests gauge
const httpRequestsInFlight = new client.Gauge({
  name: "http_requests_in_flight",
  help: "Number of HTTP requests currently being processed",
  labelNames: ["method"],
  registers: [register],
});

// ─── Middleware ───────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// Prometheus instrumentation middleware — must be registered BEFORE routes
app.use((req, res, next) => {
  // Skip metrics scrape requests from being counted as app traffic
  if (req.path === "/metrics") return next();

  const end = httpRequestDuration.startTimer();
  httpRequestsInFlight.inc({ method: req.method });

  res.on("finish", () => {
    const route = req.route ? req.route.path : req.path;
    const labels = {
      method: req.method,
      route,
      status_code: res.statusCode,
    };
    httpRequestsTotal.inc(labels);
    end(labels);
    httpRequestsInFlight.dec({ method: req.method });
  });

  next();
});

// ─── Health Check Endpoints ───────────────────────────────────────────────────

// Liveness probe — is the process alive?
app.get("/health/live", (req, res) => {
  res.status(200).json({ status: "alive", timestamp: new Date().toISOString() });
});

// Readiness probe — is the app ready to serve traffic?
app.get("/health/ready", (req, res) => {
  // In a real app, check DB connectivity here
  res.status(200).json({ status: "ready", timestamp: new Date().toISOString() });
});

// Startup probe — has the app finished initialising?
app.get("/health/startup", (req, res) => {
  res.status(200).json({ status: "started", timestamp: new Date().toISOString() });
});

// ─── Prometheus Metrics Endpoint ──────────────────────────────────────────────
app.get("/metrics", async (req, res) => {
  try {
    res.set("Content-Type", register.contentType);
    res.end(await register.metrics());
  } catch (err) {
    res.status(500).end(err.message);
  }
});

// ─── Application Routes ───────────────────────────────────────────────────────
app.get("/api/message", (req, res) => {
  res.json({
    message: "DevOps Platform Backend Running 🚀",
    timestamp: new Date().toISOString(),
    version: "2.0.0",
  });
});

app.get("/api/status", (req, res) => {
  res.json({
    status: "healthy",
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString(),
  });
});

// ─── Server Bootstrap ────────────────────────────────────────────────────────
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`📊 Metrics available at http://localhost:${PORT}/metrics`);
  console.log(`❤️  Liveness  probe at  http://localhost:${PORT}/health/live`);
  console.log(`✔️  Readiness probe at  http://localhost:${PORT}/health/ready`);
});