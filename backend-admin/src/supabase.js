import { createClient } from '@supabase/supabase-js';
import { config } from './config.js';

// This client is server-only. Never expose its key to the Flutter app/browser.
export const adminDb = createClient(config.supabaseUrl, config.secretKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

// Public-key client is used only for password sign-in and token validation.
export const authClient = createClient(config.supabaseUrl, config.publishableKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});
