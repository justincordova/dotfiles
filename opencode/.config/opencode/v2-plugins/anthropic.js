import { appendFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { Plugin } from "@opencode/plugin";
import { authorize, exchange } from "./node_modules/@ex-machina/opencode-anthropic-auth/dist/auth.js";
import { CLIENT_ID, TOKEN_URL } from "./node_modules/@ex-machina/opencode-anthropic-auth/dist/constants.js";
import { resolveClaudeCodeVersion } from "./node_modules/@ex-machina/opencode-anthropic-auth/dist/config.js";
import { setOAuthHeaders, rewriteRequestBody, rewriteUrl, createStrippedStream } from "./node_modules/@ex-machina/opencode-anthropic-auth/dist/transform.js";
import { refreshAccountsList, loadPersistedAccountSource, setActiveAccountSource, getCachedCredentials } from "./node_modules/opencode-claude-auth/dist/credentials.js";
import { buildRequestHeaders } from "./node_modules/opencode-claude-auth/dist/index.js";
import { transformBody, transformResponseStream } from "./node_modules/opencode-claude-auth/dist/transforms.js";

const integrationID = "anthropic";
const cliMethodID = "claude-code";

// Claude Code 2.1.310 sends token requests through axios 1.15.2. Anthropic's
// token endpoint fingerprints the request shape and answers mismatches with
// 429 rate_limit_error — even on the first request of the day — so mirror
// Claude Code exactly instead of using the runtime's default headers.
const CLAUDE_CODE_TOKEN_USER_AGENT = "axios/1.15.2";
const CLAUDE_CODE_TOKEN_ACCEPT = "application/json, text/plain, */*";
const TOKEN_URLS = [TOKEN_URL, "https://claude.ai/v1/oauth/token"];
const REFRESH_ATTEMPT_DELAYS_MS = [500, 1000];
const REFRESH_MAX_DELAY_MS = 10_000;
const REFRESH_TIMEOUT_MS = 10_000;
const REFRESH_BUDGET_MS = 12_000;
const REFRESH_COOLDOWN_MS = 30_000;

// A refresh token that Anthropic calls invalid is gone for good; everything
// else (429, 5xx, network, unknown) is transient and worth retrying.
const TERMINAL_OAUTH_ERRORS = new Set([
  "invalid_grant",
  "invalid_client",
  "unauthorized_client",
  "unsupported_grant_type",
]);

// A refresh rotates the refresh token, so two concurrent refreshes leave one
// caller holding a dead token. Share one attempt per token inside this process,
// and back off after a failed one so a transient 429 cannot become a storm.
const inflightRefreshes = new Map();
const refreshCooldowns = new Map();

// Non-secret refresh diagnostics: hosts and status codes only, never tokens.
function logRefresh(entry) {
  if (process.env.NODE_ENV === "test") return;
  try {
    appendFileSync(
      join(homedir(), ".local", "share", "opencode", "anthropic-refresh.log"),
      `${JSON.stringify({ ts: new Date().toISOString(), ...entry })}\n`,
    );
  } catch {
    // Diagnostics must never break a refresh.
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function retryAfterMs(response) {
  const raw = response.headers.get("retry-after");
  if (!raw) return undefined;
  const seconds = Number.parseInt(raw, 10);
  if (Number.isFinite(seconds) && seconds > 0) return seconds * 1000;
  const date = Date.parse(raw);
  return Number.isFinite(date) ? Math.max(0, date - Date.now()) : undefined;
}

async function oauthErrorCode(response) {
  let raw = "";
  try {
    raw = await response.text();
  } catch {
    return undefined;
  }
  try {
    const body = JSON.parse(raw);
    if (typeof body?.error === "string") return body.error;
    if (typeof body?.error?.type === "string") return body.error.type;
  } catch {
    // Non-JSON error body: treat as transient.
  }
  return undefined;
}

function cooldownRemaining(key) {
  const state = refreshCooldowns.get(key);
  return state && state.until > Date.now() ? state.until - Date.now() : 0;
}

async function performOAuthRefresh(credential, key) {
  // Omit `scope`: the endpoint rejects a scope list that differs from the one
  // the refresh token was granted with (`invalid_scope`). Leaving it out keeps
  // the token's existing grants.
  const body = JSON.stringify({
    grant_type: "refresh_token",
    refresh_token: credential.refresh,
    client_id: CLIENT_ID,
  });
  let lastStatus = "no attempt";
  let lastHost = "none";
  let delay = 0;
  const deadline = Date.now() + REFRESH_BUDGET_MS;

  for (let attempt = 0; attempt < TOKEN_URLS.length + 1; attempt++) {
    if (attempt > 0 && delay > 0) {
      await sleep(Math.min(delay, Math.max(0, deadline - Date.now())));
    }
    if (Date.now() >= deadline) break;
    const url = TOKEN_URLS[attempt % TOKEN_URLS.length];
    lastHost = new URL(url).host;
    logRefresh({ event: "attempt", attempt, host: lastHost });

    let response;
    try {
      response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: CLAUDE_CODE_TOKEN_ACCEPT,
          "User-Agent": CLAUDE_CODE_TOKEN_USER_AGENT,
        },
        body,
        signal: AbortSignal.timeout(
          Math.min(REFRESH_TIMEOUT_MS, Math.max(1000, deadline - Date.now())),
        ),
      });
    } catch (error) {
      lastStatus = `network error: ${error instanceof Error ? error.message : String(error)}`;
      delay = Math.min(
        REFRESH_ATTEMPT_DELAYS_MS[attempt] ?? REFRESH_ATTEMPT_DELAYS_MS.at(-1),
        Math.max(0, deadline - Date.now()),
      );
      logRefresh({ event: "network_error", attempt, host: lastHost, message: lastStatus, delay });
      console.warn(`[anthropic-auth] token refresh ${lastStatus} (${lastHost}); retrying in ${delay}ms`);
      continue;
    }

    lastStatus = `HTTP ${response.status}`;
    if (response.ok) {
      const result = await response.json().catch(() => null);
      if (!result?.access_token || !result?.refresh_token || !Number.isFinite(result?.expires_in)) {
        logRefresh({ event: "invalid_response", attempt, host: lastHost });
        throw new Error("Invalid Claude token refresh response.");
      }
      logRefresh({ event: "success", attempt, host: lastHost });
      refreshCooldowns.delete(key);
      return {
        ...credential,
        access: result.access_token,
        refresh: result.refresh_token,
        expires: Date.now() + result.expires_in * 1000,
      };
    }

    const code = await oauthErrorCode(response);
    if (code && TERMINAL_OAUTH_ERRORS.has(code)) {
      logRefresh({ event: "terminal", attempt, host: lastHost, status: response.status, code });
      throw new Error(`Claude session expired (${code}). Re-authenticate with Ctrl+A → Anthropic.`);
    }

    const hinted = retryAfterMs(response);
    const fallback = REFRESH_ATTEMPT_DELAYS_MS[attempt] ?? REFRESH_ATTEMPT_DELAYS_MS.at(-1);
    delay = Math.min(
      hinted !== undefined ? hinted : fallback,
      REFRESH_MAX_DELAY_MS,
      Math.max(0, deadline - Date.now()),
    );
    logRefresh({ event: "http_error", attempt, host: lastHost, status: response.status, code, delay });
    console.warn(
      `[anthropic-auth] token refresh ${lastStatus} from ${lastHost}${code ? ` (${code})` : ""}; retrying in ${delay}ms`,
    );
  }

  refreshCooldowns.set(key, { until: Date.now() + REFRESH_COOLDOWN_MS });
  logRefresh({ event: "exhausted", lastStatus, lastHost });
  console.error(
    `[anthropic-auth] token refresh failed after ${TOKEN_URLS.length + 1} attempts ` +
      `(last: ${lastStatus} from ${lastHost}). Keeping the current credential and cooling down ` +
      `for ${REFRESH_COOLDOWN_MS / 1000}s.`,
  );
  return credential;
}

function refreshOAuthCredential(credential) {
  const key = credential.refresh;
  const remaining = cooldownRemaining(key);
  if (remaining > 0) {
    logRefresh({ event: "cooldown_skip", remainingMs: remaining });
    console.warn(
      `[anthropic-auth] token refresh cooling down for ${Math.ceil(remaining / 1000)}s; ` +
        `using the current credential`,
    );
    return Promise.resolve(credential);
  }

  const existing = inflightRefreshes.get(key);
  if (existing) return existing;

  const pending = performOAuthRefresh(credential, key).finally(() => {
    inflightRefreshes.delete(key);
  });
  inflightRefreshes.set(key, pending);
  return pending;
}

function cliCredential(creds) {
  if (!creds) throw new Error("No valid Claude Code credentials. Sign in with the Claude CLI first.");
  return { type: "oauth", methodID: cliMethodID, access: creds.accessToken, refresh: creds.refreshToken, expires: creds.expiresAt };
}

async function readCliCredentials() {
  const accounts = refreshAccountsList();
  const selected = loadPersistedAccountSource();
  const account = accounts.find((a) => a.source === selected) ?? accounts[0];
  if (!account) throw new Error("No Claude Code account found. Sign in with the Claude CLI first.");
  setActiveAccountSource(account.source);
  return cliCredential(await getCachedCredentials());
}

export default Plugin.define({
  id: "local.anthropic-auth",
  async setup(ctx) {
    const version = resolveClaudeCodeVersion();
    const cliVersion = version.type === "invalid" ? undefined : version.version;
    await ctx.integration.transform((editor) => {
      editor.method.update({
        integrationID,
        method: { id: "oauth", type: "oauth", label: "Claude Pro/Max" },
        async authorize() {
          const attempt = await authorize("max");
          return {
            url: attempt.url,
            instructions: "Paste the authorization code or callback URL here:",
            mode: "code",
            async callback(code) {
              const result = await exchange(code, attempt.verifier, attempt.redirectUri, attempt.state);
              if (result.type !== "success") throw new Error("Claude authorization failed.");
              return { type: "oauth", methodID: "oauth", access: result.access, refresh: result.refresh, expires: result.expires };
            },
          };
        },
        async refresh(credential) {
          return refreshOAuthCredential(credential);
        },
      });
      editor.method.update({
        integrationID,
        method: { id: cliMethodID, type: "oauth", label: "Use Claude Code account" },
        async authorize() {
          const credential = await readCliCredentials();
          return { url: "", instructions: "Using your selected Claude Code account.", mode: "auto", callback: Promise.resolve(credential) };
        },
        async refresh() {
          // Claude Code owns its token rotation; reuse its credential manager.
          return await readCliCredentials();
        },
      });
    });

    const scope = { providerID: integrationID };
    const requests = new WeakMap();
    await ctx.session.hook("http.request", async (event) => {
      const connection = await ctx.integration.connection.active(integrationID);
      if (!connection) return;
      const credential = await ctx.integration.connection.resolve(connection);
      if (credential?.type !== "oauth") return; // Preserve API-key authentication.
      const cli = credential.methodID === cliMethodID;
      const auth = cli ? await readCliCredentials() : credential;
      const request = event.request;
      const body = request.body ? await request.clone().text() : undefined;
      const headers = cli
        ? buildRequestHeaders(request, {}, auth.access, event.model.id)
        : setOAuthHeaders(new Headers(request.headers), auth.access, cliVersion);
      const url = rewriteUrl(request.url).input;
      event.request = new Request(url, {
        method: request.method,
        headers,
        body: body === undefined ? undefined : cli ? transformBody(body) : rewriteRequestBody(body, cliVersion),
        signal: request.signal,
      });
      requests.set(event.request, cli);
    }, scope);
    await ctx.session.hook("http.response", (event) => {
      const cli = requests.get(event.request);
      if (cli === undefined) return;
      event.response = cli ? transformResponseStream(event.response) : createStrippedStream(event.response);
      requests.delete(event.request);
    }, scope);
  },
});
