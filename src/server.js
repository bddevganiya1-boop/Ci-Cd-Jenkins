const express = require('express');
const path = require('path');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;
const APP_VERSION = process.env.APP_VERSION || '1.0.0';

// Serve static assets
app.use(express.static(path.join(__dirname, '../public')));
app.use(express.json());

// API: System Info & Pipeline Metadata
app.get('/api/info', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'DevOps CI/CD Demo Service',
        version: APP_VERSION,
        hostname: os.hostname(),
        platform: os.platform(),
        uptime: `${Math.floor(process.uptime())}s`,
        timestamp: new Date().toISOString()
    });
});

// API: Health Check (Used by Jenkins Pipeline Smoke Test)
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'UP',
        timestamp: new Date().toISOString()
    });
});

// Start server
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`[CI/CD Demo App] Server running on port ${PORT}`);
        console.log(`[CI/CD Demo App] Version: ${APP_VERSION}`);
        console.log(`[CI/CD Demo App] Health check available at http://localhost:${PORT}/health`);
    });
}

module.exports = app;
