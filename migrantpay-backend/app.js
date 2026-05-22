require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const walletRoutes = require('./routes/wallet');

const app = express();

// Middleware
app.use(cors({ origin: '*' }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', app: 'MigrantPay API', version: '1.0.0' });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/wallet', walletRoutes);

// 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: err.message || 'Internal server error' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`\n🚀 MigrantPay Backend running on http://localhost:${PORT}`);
  console.log(`📱 Twilio SMS: ${process.env.TWILIO_ACCOUNT_SID ? '✅ Connected' : '⚠️  Not configured (demo mode)'}`);
  console.log(`\nEndpoints:`);
  console.log(`  POST /api/auth/send-otp`);
  console.log(`  POST /api/auth/verify-otp`);
  console.log(`  POST /api/auth/set-pin`);
  console.log(`  GET  /api/wallet/balance`);
  console.log(`  POST /api/wallet/send`);
  console.log(`  POST /api/wallet/add`);
  console.log(`  GET  /api/wallet/transactions`);
});

module.exports = app;
