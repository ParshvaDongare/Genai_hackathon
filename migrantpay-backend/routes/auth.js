const express = require('express');
const {
  ApiError,
  checkAccount,
  sendOtp,
  verifyOtp,
  loginWithPin,
  setPin,
  verifyPin,
  submitKyc,
} = require('../services/auth-service');

const router = express.Router();

function asyncHandler(handler) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (error) {
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({ error: error.message });
      }
      console.error('Auth route error:', error);
      return res.status(500).json({ error: error.message || 'Internal server error' });
    }
  };
}

router.post(
  '/check-account',
  asyncHandler(async (req, res) => {
    const { phone, name } = req.body;
    if (!phone || !name) {
      throw new ApiError(400, 'Phone and name are required');
    }
    res.json(await checkAccount(phone, name));
  }),
);

router.post(
  '/login',
  asyncHandler(async (req, res) => {
    const { phone, name, pin } = req.body;
    if (!phone || !name || !pin) {
      throw new ApiError(400, 'Phone, name and PIN are required');
    }
    res.json(await loginWithPin(phone, name, pin));
  }),
);

router.post(
  '/send-otp',
  asyncHandler(async (req, res) => {
    const { phone, name } = req.body;
    if (!phone || phone.length < 10) {
      throw new ApiError(400, 'Valid 10-digit phone number required');
    }
    if (!name || !name.trim()) {
      throw new ApiError(400, 'Full name is required');
    }

    const result = await sendOtp(phone, name.trim());
    console.log(`DEMO MODE OTP for ${phone}: ${result.demoOtp}`);
    res.json(result);
  }),
);

router.post(
  '/verify-otp',
  asyncHandler(async (req, res) => {
    const { phone, otp } = req.body;
    if (!phone || !otp) {
      throw new ApiError(400, 'Phone and OTP required');
    }
    res.json(await verifyOtp(phone, otp));
  }),
);

router.post(
  '/set-pin',
  asyncHandler(async (req, res) => {
    const { phone, token, pin } = req.body;
    if (!phone || !token) {
      throw new ApiError(401, 'Unauthorized');
    }
    res.json(await setPin(phone, token, pin));
  }),
);

router.post(
  '/verify-pin',
  asyncHandler(async (req, res) => {
    const { phone, token, pin } = req.body;
    if (!phone || !token || !pin) {
      throw new ApiError(401, 'Unauthorized');
    }
    res.json(await verifyPin(phone, token, pin));
  }),
);

router.post(
  '/submit-kyc',
  asyncHandler(async (req, res) => {
    const { phone, token, docType } = req.body;
    if (!phone || !token) {
      throw new ApiError(401, 'Unauthorized');
    }
    res.json(await submitKyc(phone, token, docType || 'aadhaar'));
  }),
);

module.exports = router;
