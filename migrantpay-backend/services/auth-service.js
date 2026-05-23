const { v4: uuidv4 } = require('uuid');
const { supabase } = require('./supabase');

const DEFAULT_BALANCE = 12500.0;

class ApiError extends Error {
  constructor(statusCode, message) {
    super(message);
    this.statusCode = statusCode;
  }
}

function normalizeName(name) {
  return (name || '').trim().toLowerCase();
}

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function asPublicUser(user) {
  return {
    phone: user.phone,
    name: user.name,
    kycStatus: user.kyc_status || 'pending',
    hasPin: !!user.pin,
  };
}

function requireSuccess(response, fallbackMessage) {
  if (response.error) {
    throw new ApiError(500, `${fallbackMessage}: ${response.error.message}`);
  }
  return response.data;
}

async function getUserByPhone(phone) {
  const response = await supabase
    .from('users')
    .select('*')
    .eq('phone', phone)
    .maybeSingle();

  if (response.error) {
    throw new ApiError(500, `Failed to load user: ${response.error.message}`);
  }

  return response.data;
}

async function ensureUserAndWallet(phone, name) {
  let user = await getUserByPhone(phone);

  if (!user) {
    const inserted = await supabase
      .from('users')
      .insert({
        phone,
        name,
        verified: false,
        kyc_status: 'pending',
      })
      .select('*')
      .single();

    user = requireSuccess(inserted, 'Failed to create user');

    const wallet = await supabase.from('wallets').insert({
      user_id: user.id,
      phone,
      balance: DEFAULT_BALANCE,
    });
    requireSuccess(wallet, 'Failed to create wallet');
  } else if (name && user.name !== name) {
    const updated = await supabase
      .from('users')
      .update({ name })
      .eq('id', user.id)
      .select('*')
      .single();
    user = requireSuccess(updated, 'Failed to update user');
  }

  return user;
}

async function createSession(user) {
  const token = `${uuidv4()}-${user.phone}`;
  const response = await supabase
    .from('auth_sessions')
    .insert({
      user_id: user.id,
      phone: user.phone,
      token,
    })
    .select('token')
    .single();

  requireSuccess(response, 'Failed to create session');
  return token;
}

async function checkAccount(phone, name) {
  const user = await getUserByPhone(phone);
  const exists =
    !!user &&
    user.verified === true &&
    !!user.pin &&
    normalizeName(user.name) === normalizeName(name);

  return {
    exists,
    user: exists ? asPublicUser(user) : null,
  };
}

async function sendOtp(phone, name) {
  const user = await ensureUserAndWallet(phone, name);
  const otp = generateOtp();
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString();

  const response = await supabase.from('otp_requests').insert({
    user_id: user.id,
    phone,
    otp,
    expires_at: expiresAt,
    used: false,
  });
  requireSuccess(response, 'Failed to store OTP');

  return {
    success: true,
    message: 'Demo mode: check server console for OTP',
    demoMode: true,
    demoOtp: otp,
  };
}

async function verifyOtp(phone, otp) {
  const user = await getUserByPhone(phone);
  if (!user) {
    throw new ApiError(404, 'User not found. Please request OTP first.');
  }

  const otpResponse = await supabase
    .from('otp_requests')
    .select('*')
    .eq('phone', phone)
    .eq('used', false)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (otpResponse.error) {
    throw new ApiError(500, `Failed to verify OTP: ${otpResponse.error.message}`);
  }

  const otpRecord = otpResponse.data;
  if (!otpRecord) {
    throw new ApiError(404, 'OTP not found. Please request a new one.');
  }

  if (new Date(otpRecord.expires_at).getTime() < Date.now()) {
    throw new ApiError(410, 'OTP expired. Please request a new one.');
  }

  if (otpRecord.otp !== otp) {
    throw new ApiError(401, 'Invalid OTP. Please try again.');
  }

  const markUsed = await supabase
    .from('otp_requests')
    .update({ used: true })
    .eq('id', otpRecord.id);
  requireSuccess(markUsed, 'Failed to update OTP');

  const updatedUserResponse = await supabase
    .from('users')
    .update({ verified: true })
    .eq('id', user.id)
    .select('*')
    .single();

  const updatedUser = requireSuccess(
    updatedUserResponse,
    'Failed to update user verification',
  );
  const token = await createSession(updatedUser);

  return {
    success: true,
    message: 'OTP verified successfully',
    token,
    user: asPublicUser(updatedUser),
  };
}

async function loginWithPin(phone, name, pin) {
  const user = await getUserByPhone(phone);
  if (!user || !user.verified) {
    throw new ApiError(404, 'Account not found. Please sign up first.');
  }
  if (normalizeName(user.name) !== normalizeName(name)) {
    throw new ApiError(401, 'Name does not match this account.');
  }
  if (!user.pin || user.pin !== pin) {
    throw new ApiError(401, 'Incorrect PIN');
  }

  const token = await createSession(user);
  return {
    success: true,
    token,
    user: asPublicUser(user),
  };
}

async function setPin(phone, token, pin) {
  const session = await getSession(phone, token);
  if (!pin || pin.length !== 6 || !/^\d+$/.test(pin)) {
    throw new ApiError(400, 'PIN must be exactly 6 digits');
  }

  const response = await supabase
    .from('users')
    .update({ pin })
    .eq('id', session.user.id)
    .select('*')
    .single();

  requireSuccess(response, 'Failed to save PIN');
  return { success: true, message: 'PIN set successfully' };
}

async function verifyPin(phone, token, pin) {
  const session = await getSession(phone, token);
  if (session.user.pin !== pin) {
    throw new ApiError(401, 'Incorrect PIN');
  }
  return { success: true, message: 'PIN verified' };
}

async function submitKyc(phone, token, docType) {
  const session = await getSession(phone, token);

  const userUpdate = await supabase
    .from('users')
    .update({
      kyc_status: 'verified',
      kyc_doc_type: docType,
    })
    .eq('id', session.user.id)
    .select('*')
    .single();

  requireSuccess(userUpdate, 'Failed to update KYC status');

  const kycRecord = await supabase.from('kyc_records').upsert({
    user_id: session.user.id,
    phone,
    document_type: docType,
    status: 'verified',
  });
  requireSuccess(kycRecord, 'Failed to save KYC record');

  return {
    success: true,
    message: 'KYC submitted and verified',
    kycStatus: 'verified',
  };
}

async function getSession(phone, token) {
  const sessionResponse = await supabase
    .from('auth_sessions')
    .select('*')
    .eq('phone', phone)
    .eq('token', token)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (sessionResponse.error) {
    throw new ApiError(
      500,
      `Failed to validate session: ${sessionResponse.error.message}`,
    );
  }

  const session = sessionResponse.data;
  if (!session) {
    throw new ApiError(401, 'Unauthorized');
  }

  const user = await getUserByPhone(phone);
  if (!user || user.id !== session.user_id) {
    throw new ApiError(401, 'Unauthorized');
  }

  return { session, user };
}

module.exports = {
  ApiError,
  checkAccount,
  sendOtp,
  verifyOtp,
  loginWithPin,
  setPin,
  verifyPin,
  submitKyc,
  getSession,
};
