// In-memory store — replace with MongoDB/PostgreSQL for production
const store = {
  // phone -> { otp, otpExpiry, verified, name, pin, kycStatus, createdAt }
  users: {},
  // phone -> { balance, transactions[] }
  wallets: {},
};

module.exports = store;
