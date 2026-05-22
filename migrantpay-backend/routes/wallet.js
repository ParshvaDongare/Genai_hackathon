const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const store = require('../store');

// Middleware: verify token
function auth(req, res, next) {
  const phone = req.headers['x-phone'] || req.body.phone;
  const token = req.headers['x-token'] || req.body.token;

  const user = store.users[phone];
  if (!user || user.token !== token) {
    return res.status(401).json({ error: 'Unauthorized. Please login again.' });
  }
  req.phone = phone;
  req.user = user;
  next();
}

// ─── GET /api/wallet/balance ─────────────────────────────────────────────────
router.get('/balance', auth, (req, res) => {
  const wallet = store.wallets[req.phone] || { balance: 0, transactions: [] };
  res.json({
    balance: wallet.balance,
    currency: 'INR',
    kycStatus: req.user.kycStatus || 'pending',
  });
});

// ─── GET /api/wallet/transactions ────────────────────────────────────────────
router.get('/transactions', auth, (req, res) => {
  const wallet = store.wallets[req.phone] || { balance: 0, transactions: [] };
  res.json({
    transactions: wallet.transactions.slice().reverse(), // newest first
    total: wallet.transactions.length,
  });
});

// ─── POST /api/wallet/send ───────────────────────────────────────────────────
// Body: { phone, token, receiverPhone, receiverName, amount, pin }
router.post('/send', auth, (req, res) => {
  const { receiverPhone, receiverName, amount, pin } = req.body;

  const user = req.user;
  const wallet = store.wallets[req.phone];

  // Verify PIN
  if (user.pin && user.pin !== pin) {
    return res.status(401).json({ error: 'Incorrect PIN. Transaction rejected.' });
  }

  const amountNum = parseFloat(amount);
  if (isNaN(amountNum) || amountNum <= 0) {
    return res.status(400).json({ error: 'Invalid amount' });
  }

  if (wallet.balance < amountNum) {
    return res.status(402).json({ error: 'Insufficient balance' });
  }

  // Deduct from sender
  wallet.balance -= amountNum;

  // Generate transaction record
  const txn = {
    id: `TXN${Date.now()}${Math.random().toString(36).substring(2, 6).toUpperCase()}`,
    type: 'sent',
    name: receiverName || 'Unknown',
    phoneOrUpi: receiverPhone,
    amount: amountNum,
    fee: 0,
    status: 'success',
    timestamp: new Date().toISOString(),
    note: req.body.note || '',
    blockchainHash: `0x${uuidv4().replace(/-/g, '')}${uuidv4().replace(/-/g, '').substring(0, 16)}`,
  };

  wallet.transactions.push(txn);

  // Credit receiver if they have a wallet
  if (store.wallets[receiverPhone]) {
    store.wallets[receiverPhone].balance += amountNum;
    store.wallets[receiverPhone].transactions.push({
      ...txn,
      id: `TXN${Date.now()}R`,
      type: 'received',
      name: user.name || req.phone,
      phoneOrUpi: req.phone,
    });
  }

  console.log(`💸 ₹${amountNum} sent from ${req.phone} → ${receiverPhone} (Fee: ₹0)`);

  res.json({
    success: true,
    transaction: txn,
    newBalance: wallet.balance,
    message: `₹${amountNum} sent successfully! Zero fee charged.`,
  });
});

// ─── POST /api/wallet/add ────────────────────────────────────────────────────
// Body: { phone, token, amount, method }
router.post('/add', auth, (req, res) => {
  const { amount, method } = req.body;
  const wallet = store.wallets[req.phone];

  const amountNum = parseFloat(amount);
  if (isNaN(amountNum) || amountNum <= 0) {
    return res.status(400).json({ error: 'Invalid amount' });
  }

  wallet.balance += amountNum;

  const txn = {
    id: `TXN${Date.now()}${Math.random().toString(36).substring(2, 6).toUpperCase()}`,
    type: 'addedMoney',
    name: `Added via ${method || 'UPI'}`,
    phoneOrUpi: method || 'UPI',
    amount: amountNum,
    fee: 0,
    status: 'success',
    timestamp: new Date().toISOString(),
    note: '',
    blockchainHash: `0x${uuidv4().replace(/-/g, '')}${uuidv4().replace(/-/g, '').substring(0, 16)}`,
  };

  wallet.transactions.push(txn);

  console.log(`💰 ₹${amountNum} added to ${req.phone}'s wallet via ${method}`);

  res.json({
    success: true,
    transaction: txn,
    newBalance: wallet.balance,
    message: `₹${amountNum} added to wallet successfully!`,
  });
});

module.exports = router;
