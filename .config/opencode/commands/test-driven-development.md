---
description: Write tests before implementation code
argument-hint: <feature-or-bug>
allowed-tools: [Skill]
---

# /test-driven-development

When implementing any feature or bugfix, before writing implementation code. Write test, watch it fail, write minimal code to pass.

## When to Use
- New features
- Bug fixes
- Refactoring
- Behavior changes

## Quick Overview

**Iron Law:** NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

**Red-Green-Refactor:**
1. **RED** - Write failing test
2. **Verify RED** - Watch it fail correctly
3. **GREEN** - Write minimal code to pass
4. **Verify GREEN** - Watch it pass
5. **REFACTOR** - Clean up while green

## Key Principles
- If you didn't watch it fail, you don't know if it tests the right thing
- Write test BEFORE code, delete if you wrote code first
- Tests-first = "what should this do?"
- Tests-after = "what does this do?" (biased by implementation)

## Red Flags
- Code before test
- Test after implementation
- Test passes immediately
- "I'll test after to verify it works"
- "Keep as reference, write tests first"

## Why TDD?
- Finds bugs before commit (faster than debugging after)
- Prevents regressions
- Documents behavior
- Enables refactoring

## Learn More
- Load full `test-driven-development` skill for detailed guidelines

## Aliases
This command can also be invoked as:
- `/tdd`
- `/test-first`
