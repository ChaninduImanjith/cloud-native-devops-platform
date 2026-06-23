import React, { useEffect, useState } from "react";
import "./App.css";

function App() {
  const [messageData, setMessageData] = useState(null);
  const [statusData, setStatusData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const apiUrl = process.env.REACT_APP_API_URL || "";
        
        // Fetch custom message
        const msgRes = await fetch(`${apiUrl}/api/message`);
        const msgData = await msgRes.json();
        setMessageData(msgData);

        // Fetch server status
        const statusRes = await fetch(`${apiUrl}/api/status`);
        const stData = await statusRes.json();
        setStatusData(stData);

      } catch (error) {
        console.error("Error fetching data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
    // Auto-refresh status every 10 seconds
    const interval = setInterval(fetchData, 10000);
    return () => clearInterval(interval);
  }, []);

  const formatUptime = (seconds) => {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = Math.floor(seconds % 60);
    return `${h}h ${m}m ${s}s`;
  };

  const formatMemory = (bytes) => {
    return (bytes / 1024 / 1024).toFixed(2) + " MB";
  };

  return (
    <div className="dashboard-container">
      <div className="background-shapes">
        <div className="shape shape-1"></div>
        <div className="shape shape-2"></div>
        <div className="shape shape-3"></div>
      </div>

      <header className="dashboard-header">
        <h1>Cloud Native DevOps Platform</h1>
        <p className="subtitle">Enterprise-Grade Infrastructure Demonstration</p>
      </header>

      {loading ? (
        <div className="loader">Initializing System...</div>
      ) : (
        <main className="dashboard-content">
          
          {/* Main Status Banner */}
          <div className="card glass-card hero-card">
            <div className="status-indicator">
              <span className={`pulse ${statusData?.status === "healthy" ? "healthy" : "down"}`}></span>
              <h2>{statusData?.status === "healthy" ? "System Healthy" : "System Unavailable"}</h2>
            </div>
            <p className="main-message">
              {messageData?.message || "Waiting for backend response..."}
            </p>
            <div className="version-badge">API Version: {messageData?.version || "Unknown"}</div>
          </div>

          {/* Metrics Grid */}
          <div className="metrics-grid">
            
            <div className="card glass-card metric-card">
              <div className="metric-icon">⏱️</div>
              <div className="metric-info">
                <h3>Backend Uptime</h3>
                <p className="metric-value">
                  {statusData ? formatUptime(statusData.uptime) : "0h 0m 0s"}
                </p>
              </div>
            </div>

            <div className="card glass-card metric-card">
              <div className="metric-icon">💾</div>
              <div className="metric-info">
                <h3>Memory Usage (Heap)</h3>
                <p className="metric-value">
                  {statusData ? formatMemory(statusData.memory.heapUsed) : "0 MB"}
                </p>
              </div>
            </div>

            <div className="card glass-card metric-card">
              <div className="metric-icon">📡</div>
              <div className="metric-info">
                <h3>Last Synced</h3>
                <p className="metric-value time-value">
                  {statusData ? new Date(statusData.timestamp).toLocaleTimeString() : "--:--:--"}
                </p>
              </div>
            </div>

          </div>

          {/* Architecture Info */}
          <div className="card glass-card info-card">
            <h3>🛠️ Architecture Overview</h3>
            <ul className="feature-list">
              <li>✅ React.js Frontend (Containerized)</li>
              <li>✅ Node.js Express API Backend</li>
              <li>✅ Kubernetes Deployment & Service</li>
              <li>✅ NGINX Ingress Routing</li>
              <li>✅ Prometheus Metrics & Grafana Monitoring</li>
            </ul>
          </div>

        </main>
      )}

      <footer className="dashboard-footer">
        <p>Deployed via GitHub Actions & Minikube</p>
      </footer>
    </div>
  );
}

export default App;