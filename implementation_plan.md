# MigrantPay / ZeroFee Wallet — Hackathon MVP Implementation Plan

## Overview

Build a **stunning, mobile-first FinTech web demo** of MigrantPay — a zero-fee remittance and digital wallet platform targeting migrant workers. This will be a single HTML/CSS/JS application that demonstrates the full hackathon demo flow with realistic UI, simulated data, and interactive features.

The app will be built as a polished, production-looking demo in `d:\Genai\migrantpay\` — a single-page app with multiple "screens" navigated via JS state.

---

## User Review Required

> [!IMPORTANT]
> This is a **frontend-only demo** — no real backend, OTP, or bank integration. All transactions are simulated. This is ideal for a hackathon presentation where you demo the full flow live.

> [!NOTE]
> I'll build this as a **web app** (HTML + CSS + JS) in `d:\Genai\migrantpay\` rather than a native mobile app, since it runs in any browser instantly and can be presented on screen at the hackathon.

---

## Open Questions

> [!IMPORTANT]
> **Should I also build the Admin Dashboard as a separate page (`admin.html`)?** The PRD specifies an admin panel. I'll include it by default.

> [!NOTE]
> **Language**: I'll implement English + Hindi (full translation layer) as the two languages, with a switcher in the app header — satisfying the multilingual acceptance criteria.

---

## Proposed Changes

### Project Structure — `d:\Genai\migrantpay\`

#### [NEW] index.html
Main mobile-first app shell. Single-page app with JS-powered screen routing. Contains all screens: Splash, Language Select, Register, OTP, PIN Setup, KYC, Home/Wallet, Send Money, Transaction History, AI Savings, Micro-Investment, Notifications.

#### [NEW] admin.html
Admin dashboard: user table, transaction monitor, KYC approval queue, fraud alerts, analytics charts.

#### [NEW] style.css
Full design system:
- Dark premium theme with violet/indigo/emerald accent palette
- Glassmorphism cards
- Smooth screen transitions (slide, fade)
- Mobile viewport (375px max-width centered)
- Micro-animations on buttons, cards, modals
- Google Fonts: Inter + Noto Sans Devanagari (Hindi support)

#### [NEW] app.js
Core application logic:
- Screen router
- Simulated wallet state (balance, transactions)
- OTP simulation
- PIN entry
- Language switching (en/hi dictionaries)
- AI savings engine (rule-based suggestions)
- Blockchain hash generator (SHA-like mock)
- Notification toast system
- Chart rendering for savings goal

#### [NEW] admin.js
Admin dashboard logic:
- User data table with KYC status badges
- Transaction monitoring table
- Approve/reject KYC actions
- Fraud flag toggling
- Analytics: Chart.js bar/pie charts for transaction volume, user registrations

#### [NEW] assets/
Generated images: app logo, persona avatars, feature icons

---

## Screens to Build

### User App (`index.html`)
| # | Screen | Key Elements |
|---|--------|-------------|
| 1 | Splash | Logo, tagline animation, loading bar |
| 2 | Language Select | Hindi / English cards with flags |
| 3 | Register | Mobile number input, T&C |
| 4 | OTP Verify | 6-digit OTP boxes, resend timer |
| 5 | PIN Setup | 6-dot PIN keypad |
| 6 | KYC | Document type select, upload area, selfie mock, status |
| 7 | Home / Wallet | Balance card, quick actions, recent transactions |
| 8 | Send Money | Receiver input, amount, fee = ₹0 confirmation, PIN verify |
| 9 | Transaction History | Filterable list with status badges |
| 10 | AI Savings | Insights card, savings goal creator, weekly tip |
| 11 | Micro-Investment | Risk profile quiz, fund cards, SIP setup |
| 12 | Notifications | Bell with badges, notification list |

### Admin Dashboard (`admin.html`)
| # | Panel | Key Elements |
|---|-------|-------------|
| 1 | Overview | KPI cards: users, txn volume, KYC pending, fraud alerts |
| 2 | Users | Searchable table with KYC status, wallet balance, actions |
| 3 | Transactions | Live table, filter by status/date, blockchain hash display |
| 4 | KYC Queue | Pending approvals with approve/reject buttons |
| 5 | Fraud Alerts | Flagged accounts, freeze/unfreeze wallet |
| 6 | Analytics | Bar chart (daily txn volume), Pie chart (user KYC split) |

---

## Design System

| Token | Value |
|-------|-------|
| Primary | `#7C3AED` (violet-600) |
| Secondary | `#10B981` (emerald-500) |
| Accent | `#F59E0B` (amber) |
| Background | `#0F0F1A` (deep navy-black) |
| Surface | `rgba(255,255,255,0.06)` glassmorphism |
| Error | `#EF4444` |
| Font | Inter + Noto Sans Devanagari |
| Border Radius | `16px` cards, `12px` inputs, `50%` avatars |
| Shadow | Violet glow on primary elements |

---

## Demo Flow Implemented

Following PRD Section 18 exactly:
1. ✅ Opens app → Language select (Hindi / English)
2. ✅ Register with mobile → OTP verify → PIN setup
3. ✅ Basic KYC → document type → upload → status "Pending → Verified"
4. ✅ Home wallet → Add money flow
5. ✅ Send ₹1,000 → fee = ₹0 → PIN confirm → success
6. ✅ Receiver notification toast
7. ✅ Transaction history with blockchain hash
8. ✅ AI tip: "Save ₹100 weekly for emergency fund"
9. ✅ Admin sees the transaction in dashboard
10. ✅ Blockchain audit ID displayed on transaction detail

---

## Verification Plan

### Manual Verification
- Open `index.html` in Chrome — full demo flow works end to end
- Language toggle switches to Hindi instantly
- PIN entry and OTP screens are interactive
- Send money deducts from wallet balance in real-time
- Admin dashboard at `admin.html` shows populated data
- All animations and transitions are smooth
- Mobile viewport (375px) looks great; responsive on desktop too
