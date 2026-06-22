import React, { useEffect, useState } from "react";

function App() {

  const [message, setMessage] = useState("");

  useEffect(() => {
    fetch(`${process.env.REACT_APP_API_URL || "http://localhost:5000"}/api/message`)
      .then((res) => res.json())
      .then((data) => setMessage(data.message));
  }, []);

  return (
    <div style={{ textAlign: "center", marginTop: "100px" }}>
      <h1>Cloud Native DevOps Platform</h1>
      <h2>{message}</h2>
    </div>
  );
}

export default App;