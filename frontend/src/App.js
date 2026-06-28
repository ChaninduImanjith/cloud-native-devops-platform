import React, { useEffect, useState } from "react";
import "./App.css";

function App() {
  const [messageData, setMessageData] = useState(null);
  const [statusData, setStatusData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [cpuUsage, setCpuUsage] = useState(32);
  const [activeUsers, setActiveUsers] = useState(1240);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const apiUrl = ""; // Uses relative path for Ingress
        
        const [msgRes, statusRes] = await Promise.all([
          fetch(`${apiUrl}/api/message`).catch(() => null),
          fetch(`${apiUrl}/api/status`).catch(() => null)
        ]);

        if (msgRes) setMessageData(await msgRes.json());
        if (statusRes) setStatusData(await statusRes.json());

      } catch (error) {
        console.error("Error fetching data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
    const interval = setInterval(() => {
      fetchData();
      // Simulate dynamic metrics
      setCpuUsage(Math.floor(Math.random() * (75 - 20 + 1) + 20));
      setActiveUsers(prev => prev + Math.floor(Math.random() * 10 - 3));
    }, 5000);
    
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
    <div className="dashboard-layout">
      {/* Sidebar Navigation */}
      <nav className="sidebar">
        <div className="sidebar-logo">
          <div className="logo-icon">☁️</div>
          <h2>DevOpsPro</h2>
        </div>
        <ul className="nav-links">
          <li className="active">📊 Overview</li>
          <li>📦 Pods</li>
          <li>🌐 Network</li>
          <li>⚙️ Settings</li>
        </ul>
        <div className="sidebar-footer">
          <p>Logged in as <b>Admin</b></p>
        </div>
      </nav>

      {/* Main Content */}
      <div className="main-content">
        <header className="topbar">
          <div className="topbar-search">
            <input type="text" placeholder="Search resources..." />
          </div>
          <div className="topbar-actions">
            <button className="deploy-btn">🚀 Trigger Pipeline</button>
            <div className="avatar">A</div>
          </div>
        </header>

        {loading ? (
          <div className="loader-container">
            <div className="spinner"></div>
            <p>Connecting to Cluster API...</p>
          </div>
        ) : (
          <div className="dashboard-container">
            
            {/* API Status Hero Card */}
            <div className="card hero-card">
              <div className="hero-header">
                <h2>Platform Status</h2>
                <span className={`status-badge ${statusData?.status === "healthy" ? "healthy" : "down"}`}>
                  <span className="pulse"></span>
                  {statusData?.status === "healthy" ? "All Systems Operational" : "Degraded State"}
                </span>
              </div>
              <p className="main-message">
                {messageData?.message || "Awaiting API response..."}
              </p>
              <div className="hero-footer">
                <span>API Version: {messageData?.version || "Unknown"}</span>
                <span>Last Synced: {statusData ? new Date(statusData.timestamp).toLocaleTimeString() : "--:--:--"}</span>
              </div>
            </div>

            {/* Metrics Grid */}
            <div className="metrics-grid">
              <div className="card metric-card">
                <div className="metric-header">
                  <h3>Active Users</h3>
                  <span className="icon">👥</span>
                </div>
                <div className="metric-value">{activeUsers.toLocaleString()}</div>
                <div className="metric-trend up">↑ 12% vs last hour</div>
              </div>

              <div className="card metric-card">
                <div className="metric-header">
                  <h3>Backend Uptime</h3>
                  <span className="icon">⏱️</span>
                </div>
                <div className="metric-value">{statusData ? formatUptime(statusData.uptime) : "0h 0m 0s"}</div>
                <div className="metric-trend neutral">Stable</div>
              </div>

              <div className="card metric-card">
                <div className="metric-header">
                  <h3>Heap Memory</h3>
                  <span className="icon">💾</span>
                </div>
                <div className="metric-value">{statusData ? formatMemory(statusData.memory.heapUsed) : "0 MB"}</div>
                <div className="metric-trend down">Optimized</div>
              </div>

              <div className="card metric-card">
                <div className="metric-header">
                  <h3>CPU Load</h3>
                  <span className="icon">⚡</span>
                </div>
                <div className="metric-value">{cpuUsage}%</div>
                <div className="progress-bar">
                  <div className="progress-fill" style={{ width: `${cpuUsage}%`, backgroundColor: cpuUsage > 70 ? '#ef4444' : '#10b981' }}></div>
                </div>
              </div>
            </div>

            <div className="bottom-grid">
              {/* Cluster Health Table */}
              <div className="card table-card">
                <div className="card-header">
                  <h3>Cluster Health (Pods)</h3>
                </div>
                <div className="data-table-wrapper">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Service</th>
                      <th>Replicas</th>
                      <th>Status</th>
                      <th>Restarts</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>frontend-deployment</td>
                      <td>2 / 2</td>
                      <td><span className="badge success">Running</span></td>
                      <td>0</td>
                    </tr>
                    <tr>
                      <td>backend-api</td>
                      <td>2 / 2</td>
                      <td><span className="badge success">Running</span></td>
                      <td>0</td>
                    </tr>
                    <tr>
                      <td>postgresql-db</td>
                      <td>1 / 1</td>
                      <td><span className="badge success">Running</span></td>
                      <td>0</td>
                    </tr>
                    <tr>
                      <td>ingress-nginx</td>
                      <td>1 / 1</td>
                      <td><span className="badge success">Running</span></td>
                      <td>0</td>
                    </tr>
                  </tbody>
                </table>
                </div>
              </div>

              {/* Recent Deployments */}
              <div className="card list-card">
                <div className="card-header">
                  <h3>Recent Deployments</h3>
                </div>
                <div className="list-group">
                  <div className="list-item">
                    <div className="item-icon success">✓</div>
                    <div className="item-details">
                      <h4>Update UI components</h4>
                      <p>Commit <code>a1b2c3d</code> • 5 mins ago</p>
                    </div>
                  </div>
                  <div className="list-item">
                    <div className="item-icon success">✓</div>
                    <div className="item-details">
                      <h4>Fix PostgreSQL connection pool</h4>
                      <p>Commit <code>9f8e7d6</code> • 2 hours ago</p>
                    </div>
                  </div>
                  <div className="list-item">
                    <div className="item-icon error">✗</div>
                    <div className="item-details">
                      <h4>Update Node.js version</h4>
                      <p>Commit <code>4a5b6c7</code> • Failed (Rollback)</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
          </div>
        )}
      </div>
    </div>
  );
}

export default App;