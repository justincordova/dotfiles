import { test, expect } from "bun:test";
import auth from "./anthropic.js";
import quotas from "./quotas.js";
import rtk from "./rtk.ts";

async function authHarness(credential) {
  const hooks = new Map();
  const methods = new Map();
  await auth.setup({
    integration: {
      transform: async (edit) => edit({ method: { update: (m) => methods.set(m.method.id, m) } }),
      connection: { active: async () => ({}), resolve: async () => credential },
    },
    session: { hook: async (name, fn) => hooks.set(name, fn) },
  });
  return { hooks, methods };
}

test("auth registers both V2 sign-in methods", async () => {
  const { methods } = await authHarness();
  expect([...methods.keys()]).toEqual(["oauth", "claude-code"]);
});

test("API-key requests are untouched", async () => {
  const { hooks } = await authHarness({ type: "key", key: "test" });
  const event = { request: new Request("https://api.anthropic.com/v1/messages"), model: { id: "claude-sonnet-4-6" } };
  const original = event.request;
  await hooks.get("http.request")(event);
  expect(event.request).toBe(original);
});

test("OAuth requests transform body and strip prefixed response tools", async () => {
  const { hooks } = await authHarness({ type: "oauth", methodID: "oauth", access: "test-access" });
  const event = {
    model: { id: "claude-sonnet-4-6" },
    request: new Request("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-api-key": "old" },
      body: JSON.stringify({ model: "claude-sonnet-4-6", system: "Test", messages: [{ role: "user", content: "Hi" }], tools: [{ name: "read", input_schema: { type: "object" } }] }),
    }),
  };
  await hooks.get("http.request")(event);
  expect(event.request.headers.get("authorization")).toBe("Bearer test-access");
  expect(event.request.headers.has("x-api-key")).toBe(false);
  const body = await event.request.clone().json();
  expect(body.tools[0].name).not.toBe("read");
  const responseEvent = { request: event.request, response: new Response(`data: ${JSON.stringify({ type: "content_block_start", content_block: { type: "tool_use", name: body.tools[0].name } })}\n\n`, { headers: { "Content-Type": "text/event-stream" } }) };
  await hooks.get("http.response")(responseEvent);
  const data = (await responseEvent.response.text()).split("data: ")[1].trim();
  expect(JSON.parse(data).content_block.name).toBe("read");
});

test("OAuth refresh rejects invalid server responses", async () => {
  const { methods } = await authHarness();
  const original = globalThis.fetch;
  globalThis.fetch = async () => Response.json({ access_token: "test" });
  try {
    await expect(methods.get("oauth").refresh({ type: "oauth", refresh: "test" })).rejects.toThrow("Invalid Claude token refresh response");
  } finally { globalThis.fetch = original; }
});

test("OAuth refresh mirrors Claude Code's token request shape", async () => {
  const { methods } = await authHarness();
  const original = globalThis.fetch;
  const calls = [];
  globalThis.fetch = async (url, init) => {
    calls.push({ url, init });
    return Response.json({ access_token: "new-access", refresh_token: "new-refresh", expires_in: 3600 });
  };
  try {
    const result = await methods.get("oauth").refresh({ type: "oauth", refresh: "shape-token" });
    expect(result.access).toBe("new-access");
    expect(result.refresh).toBe("new-refresh");
    expect(result.expires).toBeGreaterThan(Date.now());
    expect(calls).toHaveLength(1);
    const { url, init } = calls[0];
    expect(url).toBe("https://platform.claude.com/v1/oauth/token");
    const headers = new Headers(init.headers);
    expect(headers.get("user-agent")).toBe("axios/1.15.2");
    expect(headers.get("accept")).toBe("application/json, text/plain, */*");
    expect(headers.get("content-type")).toBe("application/json");
    const body = JSON.parse(init.body);
    expect(body.grant_type).toBe("refresh_token");
    expect(body.refresh_token).toBe("shape-token");
    expect(body.client_id).toBe("9d1c250a-e61b-44d9-88ed-5944d1962f5e");
    expect(body.scope).toBeUndefined();
  } finally { globalThis.fetch = original; }
});

test("OAuth refresh treats 429 as transient and keeps the credential", async () => {
  const { methods } = await authHarness();
  const original = globalThis.fetch;
  let calls = 0;
  globalThis.fetch = async () => {
    calls++;
    return new Response(JSON.stringify({ error: { type: "rate_limit_error", message: "Rate limited." } }), {
      status: 429,
      headers: { "Content-Type": "application/json" },
    });
  };
  try {
    const credential = { type: "oauth", refresh: "rate-limited-token", access: "old", expires: Date.now() - 1000 };
    const result = await methods.get("oauth").refresh(credential);
    expect(result).toBe(credential);
    expect(calls).toBe(3);
  } finally { globalThis.fetch = original; }
});

test("OAuth refresh treats invalid_grant as terminal", async () => {
  const { methods } = await authHarness();
  const original = globalThis.fetch;
  globalThis.fetch = async () => new Response(JSON.stringify({ error: "invalid_grant" }), { status: 400 });
  try {
    await expect(methods.get("oauth").refresh({ type: "oauth", refresh: "dead-token" })).rejects.toThrow("Re-authenticate");
  } finally { globalThis.fetch = original; }
});

test("OAuth refresh coalesces concurrent refreshes for the same token", async () => {
  const { methods } = await authHarness();
  const original = globalThis.fetch;
  let calls = 0;
  globalThis.fetch = async () => {
    calls++;
    await new Promise((resolve) => setTimeout(resolve, 20));
    return Response.json({ access_token: "shared-access", refresh_token: "shared-refresh", expires_in: 3600 });
  };
  try {
    const credential = { type: "oauth", refresh: "concurrent-token" };
    const [first, second] = await Promise.all([
      methods.get("oauth").refresh(credential),
      methods.get("oauth").refresh(credential),
    ]);
    expect(calls).toBe(1);
    expect(first.access).toBe("shared-access");
    expect(second).toBe(first);
  } finally { globalThis.fetch = original; }
});

test("quota tools register valid no-argument V2 schemas", async () => {
  const tools = [];
  await quotas.setup({ tool: { transform: async (edit) => edit({ add: (tool) => tools.push(tool) }) } });
  expect(tools.map((t) => t.name)).toEqual(["mystatus"]);
  expect(tools.every((t) => t.input.type === "object")).toBe(true);
});

test("RTK rewrites supported shell commands and ignores other tools", async () => {
  let before;
  await rtk.setup({ tool: { hook: async (_, fn) => { before = fn; } } });
  expect(typeof before).toBe("function");
  const shell = { tool: "shell", input: { command: "git status" } };
  await before(shell);
  expect(shell.input.command).toContain("rtk");
  const read = { tool: "read", input: { command: "git status" } };
  await before(read);
  expect(read.input.command).toBe("git status");
  const alreadyRewritten = { tool: "shell", input: { command: shell.input.command } };
  await before(alreadyRewritten);
  expect(alreadyRewritten.input.command).toBe(shell.input.command);
});
