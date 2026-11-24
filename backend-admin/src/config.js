import 'dotenv/config';

function required(name) {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`Environment variable ${name} is required`);
  return value;
}

export const config = {
  port: Number(process.env.PORT ?? 4100),
  nodeEnv: process.env.NODE_ENV ?? 'development',
  supabaseUrl: required('SUPABASE_URL'),
  publishableKey: process.env.SUPABASE_PUBLISHABLE_KEY?.trim()
    || process.env.SUPABASE_ANON_KEY?.trim()
    || required('SUPABASE_PUBLISHABLE_KEY'),
  secretKey: process.env.SUPABASE_SECRET_KEY?.trim()
    || process.env.SUPABASE_SERVICE_ROLE_KEY?.trim()
    || required('SUPABASE_SECRET_KEY'),
  corsOrigins: (process.env.CORS_ORIGINS ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
  pendingApproval: process.env.STATUS_APPROVE_PENDING ?? 'N',
  approvedApproval: process.env.STATUS_APPROVE_APPROVED ?? 'Y',
  rejectedApproval: process.env.STATUS_APPROVE_REJECTED?.trim() || null,
};
