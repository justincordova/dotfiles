# CLAUDE.md

## Git Conventions

Commits are task-scoped and written by the developer. Claude does NOT author
or suggest commit messages unless explicitly asked.

Format: `type(scope): description`

Common types:
- `feat` — new feature
- `fix` — bug fix
- `refactor` — code restructure with no behavior change
- `chore` — maintenance, deps, config
- `docs` — documentation only
- `test` — test additions or changes
- `style` — formatting only

Rules:
- **Never** append "Generated with Claude Code", "Co-authored by Claude", or any
  AI attribution footer to commit messages
- **Never** suggest or auto-generate commit messages unless explicitly asked
- One commit per logical task or subtask — not per file, not per session
- Description is lowercase, no trailing period
- Keep the subject line under 72 characters

### Pre-Commit Gate

Before any commit, the project must build and pass. Run in order:
1. Build the project (e.g. `go build ./...`, `npm run build`, etc.)
2. Run tests (e.g. `go test ./...`, `npm test`, etc.)
3. Run type checking / linting if applicable

If anything fails, fix it. Do not commit broken code.

---

## Code Style

- Prefer small, focused diffs. Never refactor unrelated code in the same change.
- Match the existing style of the file you are editing — do not impose conventions.
- If a file has no precedent for something, follow the nearest pattern in the repo.
- No commented-out code. Remove it or don't write it.
- Explicit is better than clever. Readability first.

---

## General Rules

- During brainstorming, ask clarifying questions if the task is ambiguous.
- During brainstorming, share best practice recommendations relevant to the question being asked.
- Never touch files outside the scope of the current task.
- If context is getting large, say so — don't silently degrade.
- Treat every task as if a senior engineer will review it tomorrow.
