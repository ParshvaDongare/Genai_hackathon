# 💸 MigrantPay — ZeroFee Wallet

> A mobile-first financial inclusion platform for migrant workers to send **zero-fee remittances**, store money securely, and access simple investment tools.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-Express-green?logo=node.js)](https://nodejs.org)
[![Twilio](https://img.shields.io/badge/SMS-Twilio-red?logo=twilio)](https://twilio.com)

---

## 🚀 Features

- ✅ **Zero-Fee Remittances** — Send money home with ₹0 platform fee
- 📱 **Mobile OTP Auth** — Real SMS via Twilio
- 🔐 **KYC Verification** — Aadhaar / PAN / Passport flow
- 🤖 **AI Financial Insights** — Savings tips & micro-investment cards
- ⛓️ **Blockchain Audit Trail** — Immutable hash per transaction
- 🌐 **Bilingual** — English & Hindi
- 💰 **Savings Goals** — Track progress toward financial goals

---

## 📁 Project Structure

```
Genai_hackathon/
├── migrantpay/          # Flutter mobile app
│   └── lib/
│       ├── screens/     # 14 screens
│       ├── providers/   # State management
│       ├── services/    # API service layer
│       ├── theme/       # Design system
│       └── widgets/     # Reusable widgets
└── migrantpay-backend/  # Node.js + Express API
    ├── routes/
    │   ├── auth.js      # OTP, PIN, KYC
    │   └── wallet.js    # Balance, send, add money
    ├── app.js
    └── .env.example
```

---

## ⚙️ Setup & Run

### 1. Backend (Node.js)

```bash
cd migrantpay-backend
npm install
cp .env.example .env
# Fill in your Twilio credentials in .env
node app.js
# → Running at http://localhost:3000
```

### 2. Flutter App

```bash
cd migrantpay
flutter pub get
flutter run -d chrome     # Web
flutter run -d windows    # Desktop
flutter run               # Android/iOS (needs device)
```

---

## 🔑 Environment Variables

Create `migrantpay-backend/.env` from `.env.example`:

| Variable | Description |
|----------|-------------|
| `TWILIO_ACCOUNT_SID` | From [Twilio Console](https://console.twilio.com) |
| `TWILIO_AUTH_TOKEN` | From Twilio Console |
| `TWILIO_PHONE_NUMBER` | A Twilio-purchased number (e.g. `+1XXXXXXXXXX`) |
| `PORT` | Server port (default: 3000) |
| `JWT_SECRET` | Any random secret string |

---

## 📱 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/send-otp` | Send OTP via SMS |
| POST | `/api/auth/verify-otp` | Verify OTP → get token |
| POST | `/api/auth/set-pin` | Set 6-digit PIN |
| POST | `/api/auth/submit-kyc` | Submit KYC docs |
| GET | `/api/wallet/balance` | Get wallet balance |
| GET | `/api/wallet/transactions` | Get transaction history |
| POST | `/api/wallet/send` | Send money (zero fee) |
| POST | `/api/wallet/add` | Add money to wallet |

---

## 🎨 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x (Dart) |
| State | Provider pattern |
| Backend | Node.js + Express |
| SMS OTP | Twilio |
| Animations | flutter_animate |
| Fonts | Google Fonts (Inter) |
| Charts | percent_indicator |

---

## 👥 Team

Built for **GenAI Hackathon 2024** 🚀
