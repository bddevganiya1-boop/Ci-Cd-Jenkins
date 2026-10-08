const http = require('http');
const app = require('../src/server');

const TEST_PORT = 3099;
let server;

console.log('>>> [TEST SUITE] Starting Automated Pipeline Tests...');

server = app.listen(TEST_PORT, async () => {
    try {
        // Test 1: Health check endpoint test
        await testEndpoint('/health', (data, statusCode) => {
            if (statusCode !== 200) {
                throw new Error(`Expected HTTP 200 on /health, got ${statusCode}`);
            }
            const parsed = JSON.parse(data);
            if (parsed.status !== 'UP') {
                throw new Error(`Expected status 'UP', got ${parsed.status}`);
            }
            console.log('✔ [PASS] Health check endpoint (/health) returned 200 OK');
        });

        // Test 2: Info API endpoint test
        await testEndpoint('/api/info', (data, statusCode) => {
            if (statusCode !== 200) {
                throw new Error(`Expected HTTP 200 on /api/info, got ${statusCode}`);
            }
            const parsed = JSON.parse(data);
            if (!parsed.version || !parsed.hostname) {
                throw new Error('API Info response missing required fields');
            }
            console.log('✔ [PASS] Metadata API endpoint (/api/info) returned valid schema');
        });

        console.log('>>> [TEST SUITE] All Pipeline Tests Passed Successfully!');
        server.close(() => process.exit(0));
    } catch (err) {
        console.error('❌ [FAIL] Test execution failed:', err.message);
        if (server) server.close();
        process.exit(1);
    }
});

function testEndpoint(path, callback) {
    return new Promise((resolve, reject) => {
        http.get(`http://localhost:${TEST_PORT}${path}`, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    callback(data, res.statusCode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            });
        }).on('error', (err) => {
            reject(err);
        });
    });
}
