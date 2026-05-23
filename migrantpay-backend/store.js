const fs = require('fs');
const path = require('path');

const storePath = path.join(__dirname, 'store-data.json');
const defaultStore = {
  // phone -> { otp, otpExpiry, verified, name, pin, kycStatus, createdAt, token }
  users: {},
  // phone -> { balance, transactions[] }
  wallets: {},
};

function loadStore() {
  try {
    if (!fs.existsSync(storePath)) {
      return { ...defaultStore };
    }

    const raw = fs.readFileSync(storePath, 'utf8');
    if (!raw.trim()) {
      return { ...defaultStore };
    }

    const parsed = JSON.parse(raw);
    return {
      users: parsed.users || {},
      wallets: parsed.wallets || {},
    };
  } catch (error) {
    console.error('Failed to load persisted store:', error.message);
    return { ...defaultStore };
  }
}

const persisted = loadStore();

const store = {
  users: persisted.users,
  wallets: persisted.wallets,
  save() {
    fs.writeFileSync(
      storePath,
      JSON.stringify(
        {
          users: store.users,
          wallets: store.wallets,
        },
        null,
        2,
      ),
      'utf8',
    );
  },
};

module.exports = store;
