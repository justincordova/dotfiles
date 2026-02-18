---
description: Create isolated git worktrees for feature work
argument-hint: <branch-name>
allowed-tools: [Skill]
---

# /using-git-worktrees

When starting feature work that needs isolation from current workspace or before executing implementation plans. Creates isolated git worktrees.

## When to Use
- Starting feature work that needs isolation
- Need to work on multiple branches simultaneously
- Before executing implementation plans
- Need to switch between contexts without stashing

## Quick Overview

**Core Principle:** Use worktrees for isolated development environments.

**Process:**
1. Determine worktree location (smart directory selection)
2. Verify safety (don't create conflicts)
3. Create worktree with git worktree add
4. Work in isolated environment
5. Clean up when done

## Key Principles
- Isolate feature work from main workspace
- Work on multiple branches simultaneously
- No need to stash/commit when switching
- Safe directory selection and verification

## Benefits
- Switch contexts without stashing
- Work on multiple features at once
- Keep main workspace clean
- Isolate changes until ready

## Learn More
- Load full `using-git-worktrees` skill for detailed guidelines

## Aliases
This command can also be invoked as:
- `/worktree`
- `/git-worktree`
- `/isolate`
