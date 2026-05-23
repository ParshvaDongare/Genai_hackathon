const { v4: uuidv4 } = require('uuid');
const { supabase } = require('./supabase');
const { ApiError, getSession } = require('./auth-service');

function requireSuccess(response, fallbackMessage) {
  if (response.error) {
    throw new ApiError(500, `${fallbackMessage}: ${response.error.message}`);
  }
  return response.data;
}

function mapTransactionRow(row, currentPhone) {
  const isSent = row.type === 'sent';

  return {
    id: row.public_id,
    type: row.type,
    amount: Number(row.amount),
    fee: Number(row.fee || 0),
    status: row.status,
    timestamp: row.created_at,
    note: row.note || '',
    blockchainHash: row.blockchain_hash || '',
    receiverName: isSent ? row.counterparty_name : undefined,
    receiverPhone: isSent ? row.counterparty_phone : undefined,
    senderName: !isSent ? row.counterparty_name : undefined,
    senderPhone: !isSent ? row.counterparty_phone : undefined,
    phone: currentPhone,
  };
}

async function getWalletState(phone, token) {
  const { user } = await getSession(phone, token);

  const walletResponse = await supabase
    .from('wallets')
    .select('*')
    .eq('user_id', user.id)
    .maybeSingle();
  const wallet = requireSuccess(walletResponse, 'Failed to load wallet');

  if (!wallet) {
    throw new ApiError(404, 'Wallet not found');
  }

  return { user, wallet };
}

async function getBalance(phone, token) {
  const { user, wallet } = await getWalletState(phone, token);
  return {
    balance: Number(wallet.balance),
    currency: 'INR',
    kycStatus: user.kyc_status || 'pending',
  };
}

async function getTransactions(phone, token) {
  const { user } = await getWalletState(phone, token);

  const response = await supabase
    .from('transactions')
    .select('*')
    .eq('user_id', user.id)
    .order('created_at', { ascending: false });

  const rows = requireSuccess(response, 'Failed to load transactions') || [];

  return {
    transactions: rows.map((row) => mapTransactionRow(row, phone)),
    total: rows.length,
  };
}

async function addMoney(phone, token, amount, method = 'UPI') {
  const { user, wallet } = await getWalletState(phone, token);
  const amountNum = parseFloat(amount);

  if (Number.isNaN(amountNum) || amountNum <= 0) {
    throw new ApiError(400, 'Invalid amount');
  }

  const newBalance = Number(wallet.balance) + amountNum;

  const walletUpdate = await supabase
    .from('wallets')
    .update({ balance: newBalance })
    .eq('user_id', user.id)
    .select('*')
    .single();
  requireSuccess(walletUpdate, 'Failed to update wallet');

  const publicId = `TXN${Date.now()}${Math.random()
    .toString(36)
    .substring(2, 6)
    .toUpperCase()}`;

  const transactionResponse = await supabase
    .from('transactions')
    .insert({
      user_id: user.id,
      public_id: publicId,
      type: 'addedMoney',
      amount: amountNum,
      fee: 0,
      status: 'success',
      note: '',
      blockchain_hash: `0x${uuidv4().replace(/-/g, '')}${uuidv4()
        .replace(/-/g, '')
        .substring(0, 16)}`,
      counterparty_name: `Added via ${method}`,
      counterparty_phone: method,
    })
    .select('*')
    .single();

  const transaction = requireSuccess(
    transactionResponse,
    'Failed to save transaction',
  );

  return {
    success: true,
    transaction: mapTransactionRow(transaction, phone),
    newBalance,
    message: `Rs ${amountNum} added to wallet successfully.`,
  };
}

async function sendMoney({
  phone,
  token,
  receiverPhone,
  receiverName,
  amount,
  pin,
  note = '',
}) {
  const { user, wallet } = await getWalletState(phone, token);
  const amountNum = parseFloat(amount);

  if (user.pin && !receiverPhone.startsWith('savings_goal_') && user.pin !== pin) {
    throw new ApiError(401, 'Incorrect PIN. Transaction rejected.');
  }

  if (Number.isNaN(amountNum) || amountNum <= 0) {
    throw new ApiError(400, 'Invalid amount');
  }

  if (Number(wallet.balance) < amountNum) {
    throw new ApiError(402, 'Insufficient balance');
  }

  const newSenderBalance = Number(wallet.balance) - amountNum;
  const senderWalletUpdate = await supabase
    .from('wallets')
    .update({ balance: newSenderBalance })
    .eq('user_id', user.id)
    .select('*')
    .single();
  requireSuccess(senderWalletUpdate, 'Failed to update sender wallet');

  const publicId = `TXN${Date.now()}${Math.random()
    .toString(36)
    .substring(2, 6)
    .toUpperCase()}`;
  const blockchainHash = `0x${uuidv4().replace(/-/g, '')}${uuidv4()
    .replace(/-/g, '')
    .substring(0, 16)}`;

  const senderTxnResponse = await supabase
    .from('transactions')
    .insert({
      user_id: user.id,
      public_id: publicId,
      type: 'sent',
      amount: amountNum,
      fee: 0,
      status: 'success',
      note,
      blockchain_hash: blockchainHash,
      counterparty_name: receiverName || 'Unknown',
      counterparty_phone: receiverPhone,
    })
    .select('*')
    .single();

  const senderTxn = requireSuccess(
    senderTxnResponse,
    'Failed to save sender transaction',
  );

  const receiverUserResponse = await supabase
    .from('users')
    .select('*')
    .eq('phone', receiverPhone)
    .maybeSingle();
  const receiverUser = requireSuccess(
    receiverUserResponse,
    'Failed to load receiver account',
  );

  if (receiverUser) {
    const receiverWalletResponse = await supabase
      .from('wallets')
      .select('*')
      .eq('user_id', receiverUser.id)
      .maybeSingle();
    const receiverWallet = requireSuccess(
      receiverWalletResponse,
      'Failed to load receiver wallet',
    );

    if (receiverWallet) {
      const receiverBalance = Number(receiverWallet.balance) + amountNum;
      const receiverWalletUpdate = await supabase
        .from('wallets')
        .update({ balance: receiverBalance })
        .eq('user_id', receiverUser.id);
      requireSuccess(receiverWalletUpdate, 'Failed to update receiver wallet');

      const receiverTxnInsert = await supabase.from('transactions').insert({
        user_id: receiverUser.id,
        public_id: `TXN${Date.now()}R`,
        type: 'received',
        amount: amountNum,
        fee: 0,
        status: 'success',
        note,
        blockchain_hash: blockchainHash,
        counterparty_name: user.name || phone,
        counterparty_phone: phone,
      });
      requireSuccess(receiverTxnInsert, 'Failed to save receiver transaction');
    }
  }

  return {
    success: true,
    transaction: mapTransactionRow(senderTxn, phone),
    newBalance: newSenderBalance,
    message: `Rs ${amountNum} sent successfully with zero fee.`,
  };
}

module.exports = {
  getBalance,
  getTransactions,
  addMoney,
  sendMoney,
};
