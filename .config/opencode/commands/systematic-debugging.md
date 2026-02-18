---
description: Find root cause before proposing fixes for bugs
argument-hint: <issue-description>
allowed-tools: [Skill]
---

# /systematic-debugging

When encountering any bug, test failure, or unexpected behavior, before proposing fixes. ALWAYS find root cause first.

## When to Use
- ANY bug, test failure, or unexpected behavior
- Performance problems
- Build failures
- Integration issues
- ESPECIALLY under time pressure or when "just one quick fix" seems obvious

## Quick Overview

**Iron Law:** NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST

**Four Phases:**
1. **Root Cause Investigation** - Read errors, reproduce, check changes, gather evidence
2. **Pattern Analysis** - Find working examples, compare, identify differences
3. **Hypothesis and Testing** - Form theory, test minimally, verify
4. **Implementation** - Create test, fix root cause, verify

## Key Principles
- Find root cause before ANY fix
- Symptom fixes are failure
- 3+ failed fixes = question architecture
- Systematic approach is faster than guess-and-check

## Red Flags
- "Quick fix for now"
- "Just try changing X"
- "Add multiple changes, run tests"
- "One more fix attempt" (after 2+ failures)

## Real-World Impact
- Systematic: 15-30 minutes
- Random fixes: 2-3 hours of thrashing
- First-time fix rate: 95% vs 40%

## Learn More
- Load full `systematic-debugging` skill for detailed guidelines

## Aliases
This command can also be invoked as:
- `/debug`
- `/troubleshoot`
