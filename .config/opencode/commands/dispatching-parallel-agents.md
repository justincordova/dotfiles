---
description: Dispatch independent parallel agents for 2+ unrelated tasks
argument-hint: <tasks>
allowed-tools: [Skill]
---

# /dispatching-parallel-agents

Handle 2+ independent tasks that can be worked on without shared state or sequential dependencies.

## When to Use
- Multiple independent tasks that can run in parallel
- Tasks don't depend on each other's output or state
- Can speed up by running multiple agents simultaneously

## Quick Overview

**Core Principle:** Parallelize independent work to save time.

**Process:**
1. Identify independent tasks
2. Ensure no shared state or dependencies
3. Launch multiple agents in parallel
4. Collect results

## Key Principles
- Tasks must be truly independent (no shared state, no sequential dependencies)
- Use when tasks can work simultaneously without interference
- Better performance for unrelated work
- NOT for tasks that need coordination

## Anti-Pattern
Using for dependent tasks - if tasks need each other's output, they should run sequentially.

## Learn More
- Load full `dispatching-parallel-agents` skill for detailed guidelines

## Aliases
This command can also be invoked as:
- `/parallel`
- `/dispatch`
