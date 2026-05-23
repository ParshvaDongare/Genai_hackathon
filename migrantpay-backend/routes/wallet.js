const express = require('express');
const { ApiError } = require('../services/auth-service');
const {
  getBalance,
  getTransactions,
  addMoney,
  sendMoney,
} = require('../services/wallet-service');

const router = express.Router();

function asyncHandler(handler) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (error) {
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({ error: error.message });
      }
      console.error('Wallet route error:', error);
      return res.status(500).json({ error: error.message || 'Internal server error' });
    }
  };
}

router.get(
  '/balance',
  asyncHandler(async (req, res) => {
    const phone = req.headers['x-phone'];
    const token = req.headers['x-token'];
    if (!phone || !token) {
      throw new ApiError(401, 'Unauthorized. Please login again.');
    }
    res.json(await getBalance(phone, token));
  }),
);

router.get(
  '/transactions',
  asyncHandler(async (req, res) => {
    const phone = req.headers['x-phone'];
    const token = req.headers['x-token'];
    if (!phone || !token) {
      throw new ApiError(401, 'Unauthorized. Please login again.');
    }
    res.json(await getTransactions(phone, token));
  }),
);

router.post(
  '/send',
  asyncHandler(async (req, res) => {
    const { phone, token, receiverPhone, receiverName, amount, pin, note } = req.body;
    if (!phone || !token) {
      throw new ApiError(401, 'Unauthorized. Please login again.');
    }

    res.json(
      await sendMoney({
        phone,
        token,
        receiverPhone,
        receiverName,
        amount,
        pin,
        note,
      }),
    );
  }),
);

router.post(
  '/add',
  asyncHandler(async (req, res) => {
    const { phone, token, amount, method } = req.body;
    if (!phone || !token) {
      throw new ApiError(401, 'Unauthorized. Please login again.');
    }
    res.json(await addMoney(phone, token, amount, method || 'UPI'));
  }),
);

module.exports = router;
