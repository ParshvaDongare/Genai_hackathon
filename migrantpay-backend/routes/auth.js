const express = require('express');
const router = express.Router();
const twilio = require('twilio');
const { v4: uuidv4 } = require('uuid');
const store = require('../store');

// Twilio client — gracefully falls back to demo mode if not configured
const isTwilioConfigured =
  process.env.TWILIO_ACCOUNT_SID &&
  process.env.TWILIO_ACCOUNT_SID !== 'your_account_sid_here' &&
  process.env.TWILIO_AUTH_TOKEN &&
  process.env.TWILIO_AUTH_TOKEN !== 'your_auth_token_here' &&
  process.env.TWILIO_PHONE_NUMBER &&
  process.env.TWILIO_PHONE_NUMBER !== 'REPLACE_WITH_TWILIO_NUMBER' &&
  !process.env.TWILIO_PHONE_NUMBER.includes('REPLACE');

const twilioClient = isTwilioConfigured
  ? twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN)
  : null;

// Helper: generate 6-digit OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// ─── POST /api/auth/send-otp ─────────────────────────────────────────────────
// Body: { phone: "9876543210", name?: "Ramesh Kumar" }
router.post('/send-otp', async (req, res) => {
  try {
    const { phone, name } = req.body;

    if (!phone || phone.length < 10) {
      return res.status(400).json({ error: 'Valid 10-digit phone number required' });
    }

    const otp = generateOTP();
    const otpExpiry = Date.now() + 5 * 60 * 1000; // 5 minutes

    // Store OTP
    store.users[phone] = {
      ...store.users[phone],
      phone,
      name: name || '',
      otp,
      otpExpiry,
      verified: false,
    };

    // Initialize wallet if new user
    if (!store.wallets[phone]) {
      store.wallets[phone] = {
        balance: 12500.00, // Demo starting balance
        transactions: [],
      };
    }

    // Send via Twilio or demo mode
    if (twilioClient) {
      await twilioClient.messages.create({
        body: `Your MigrantPay OTP is: ${otp}. Valid for 5 minutes. DO NOT share it with anyone.`,
        from: process.env.TWILIO_PHONE_NUMBER,
        to: `+91${phone}`,
      });
      console.log(`📱 OTP sent to +91${phone} via Twilio`);
    } else {
      // Demo mode — log OTP to console
      console.log(`\n🔑 DEMO MODE — OTP for ${phone}: ${otp}\n`);
    }

    res.json({
      success: true,
      message: isTwilioConfigured
          ? `OTP sent to +91${phone}`
          : 'Demo mode: check server console for OTP',
      demoMode: !isTwilioConfigured,
      // In demo mode, return OTP to Flutter so user can see it
      ...(isTwilioConfigured ? {} : { demoOtp: otp }),
    });
  } catch (err) {
    console.error('Send OTP error:', err.message);
    res.status(500).json({ error: 'Failed to send OTP: ' + err.message });
  }
});

// ─── POST /api/auth/verify-otp ───────────────────────────────────────────────
// Body: { phone: "9876543210", otp: "123456" }
router.post('/verify-otp', (req, res) => {
  const { phone, otp } = req.body;

  if (!phone || !otp) {
    return res.status(400).json({ error: 'Phone and OTP required' });
  }

  const user = store.users[phone];

  if (!user) {
    return res.status(404).json({ error: 'User not found. Please request OTP first.' });
  }

  if (Date.now() > user.otpExpiry) {
    return res.status(410).json({ error: 'OTP expired. Please request a new one.' });
  }

  if (user.otp !== otp) {
    return res.status(401).json({ error: 'Invalid OTP. Please try again.' });
  }

  // Mark verified
  store.users[phone].verified = true;
  store.users[phone].otp = null; // invalidate OTP after use

  const token = `${uuidv4()}-${phone}`; // simple session token
  store.users[phone].token = token;

  res.json({
    success: true,
    message: 'OTP verified successfully',
    token,
    user: {
      phone,
      name: user.name,
      kycStatus: user.kycStatus || 'pending',
      hasPin: !!user.pin,
    },
  });
});

// ─── POST /api/auth/set-pin ───────────────────────────────────────────────────
// Body: { phone, token, pin: "123456" }
router.post('/set-pin', (req, res) => {
  const { phone, token, pin } = req.body;

  const user = store.users[phone];
  if (!user || user.token !== token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  if (!pin || pin.length !== 6 || !/^\d+$/.test(pin)) {
    return res.status(400).json({ error: 'PIN must be exactly 6 digits' });
  }

  store.users[phone].pin = pin;

  res.json({ success: true, message: 'PIN set successfully' });
});

// ─── POST /api/auth/verify-pin ────────────────────────────────────────────────
// Body: { phone, token, pin }
router.post('/verify-pin', (req, res) => {
  const { phone, token, pin } = req.body;

  const user = store.users[phone];
  if (!user || user.token !== token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  if (user.pin !== pin) {
    return res.status(401).json({ error: 'Incorrect PIN' });
  }

  res.json({ success: true, message: 'PIN verified' });
});

// ─── POST /api/auth/submit-kyc ────────────────────────────────────────────────
// Body: { phone, token, docType }
router.post('/submit-kyc', (req, res) => {
  const { phone, token, docType } = req.body;

  const user = store.users[phone];
  if (!user || user.token !== token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  // Simulate KYC processing (auto-approve after 2s delay in demo)
  store.users[phone].kycStatus = 'verified';
  store.users[phone].kycDocType = docType;

  res.json({
    success: true,
    message: 'KYC submitted and verified',
    kycStatus: 'verified',
  });
});

module.exports = router;
