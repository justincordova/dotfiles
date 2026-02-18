---
description: Run verification commands before claiming completion
argument-hint: [verification-context]
allowed-tools: [Skill]
---

# /verification-before-completion

Use when about to claim work is complete, fixed, or passing. Requires running verification commands and confirming output before making success claims.

## When to Use
- About to claim work is complete
- About to claim a bug is fixed
- About to claim tests pass
- Before committing or creating PRs

## Quick Overview

**Core Principle:** Evidence before assertions. Verify, then claim.

**Process:**
1. Identify verification commands (build, test, lint, typecheck)
2. Run verification commands
3. Confirm output is successful
4. THEN claim completion

## Key Principles
- Evidence before assertions always
- Don't assume, verify
- Run all relevant checks
- See the output, don't guess

## Anti-Pattern
- "Tests should pass" (don't assume)
- "Build should work" (run it)
- "I fixed it" (verify first)

## Common Verification Commands
- Build: `npm run build`, `go build ./...`
- Test: `npm test`, `go test ./...`
- Lint: `npm run lint`, `ruff`
- Typecheck: `npm run typecheck`, `tsc --noEmit`

## Learn More
- Load full `verification-before-completion` skill for detailed guidelines

## Aliases
This command can also be invoked as:
- `/verify`
- `/check`
- `/verification`
