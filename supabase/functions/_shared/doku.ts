const enc = new TextEncoder();
const b64 = (b: ArrayBuffer) => btoa(String.fromCharCode(...new Uint8Array(b)));

export async function dokuSign(
  clientId: string, secret: string, requestId: string,
  timestamp: string, target: string, body: string,
) {
  const digest = b64(await crypto.subtle.digest("SHA-256", enc.encode(body)));
  const component =
    `Client-Id:${clientId}\nRequest-Id:${requestId}\nRequest-Timestamp:${timestamp}\n` +
    `Request-Target:${target}\nDigest:${digest}`;
  const key = await crypto.subtle.importKey(
    "raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"],
  );
  return "HMACSHA256=" + b64(await crypto.subtle.sign("HMAC", key, enc.encode(component)));
}