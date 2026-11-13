# Local OpenCode V2 plugin ports

These plugins restore the V1 functionality on OpenCode 2.2.0:

- `quotas/`: `mystatus`, using the upstream query code with V2 credential lookup and tool registration.
- `anthropic/`: Claude Pro/Max OAuth and optional credentials from a signed-in Claude Code account, using V2 integrations and HTTP hooks. Token refresh mirrors Claude Code 2.1.310's request shape (`axios/1.15.2` user agent and `Accept: application/json, text/plain, */*`), omits `scope` because the endpoint rejects a mismatched list with `invalid_scope`, tries both token hosts, retries 429/5xx with backoff and `Retry-After`, coalesces concurrent refreshes, and treats transient failures as non-fatal with a 30s cooldown. Anthropic's token endpoint filters requests by shape and answers mismatches with 429, so do not remove those headers. Refresh outcomes are written to `~/.local/share/opencode/anthropic-refresh.log` (hosts and status codes only, never tokens).
- `rtk.ts`: V2 shell hook, symlinked to `~/.opencode/plugins/rtk.ts` so it applies under all of $HOME; RTK exit code 3 means a successful rewrite.

Gemini remains on its upstream V2-compatible release. Package dependencies here are pinned. Installation scripts were disabled so quota package installers cannot rewrite your configuration.

Run checks with `bun test plugins.test.js` from this directory, then `opencode plugin list` and `opencode mcp list`.

Original configuration and RTK files are saved in `backup/`. They contain the original settings, potentially including credentials; `backup/` is gitignored -- keep it that way.

`vendor/` holds only opencode-mystatus 1.2.4's `mystatus.js`, patched to read credentials through V2 (MIT, upstream LICENSE kept beside it). The per-provider query code is imported straight from the pinned package in `node_modules` rather than copied: its `google.js` embeds Antigravity's public OAuth client, which GitHub push protection rejects as a secret. API account/subscription errors require valid account access and are not plugin compatibility failures.
