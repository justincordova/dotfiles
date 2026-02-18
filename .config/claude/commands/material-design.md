---
description: Quick guidance on Material Design for Android and Google products
argument-hint: [optional: specific-question]
allowed-tools: [Skill]
---

# /material-design

Get quick guidance on Material Design - metaphorical component-rich design system for Android and Google ecosystem.

## When to Use
- Building Android native applications or Google product interfaces
- Creating web applications with Material components
- Using Flutter, React, or cross-platform frameworks
- Need comprehensive design system with rich components

## Quick Overview

**Core Principle:** Material is the metaphor - UI elements behave like physical materials with elevation, depth, and meaningful motion.

**Key Characteristics:**
- Elevation system with shadows (0-24dp)
- Roboto/Google Sans typography (12px-112px scale)
- Primary/secondary/tertiary color systems
- 4px baseline grid, 8dp base unit
- Ripple effects on all interactive elements
- FABs (Floating Action Buttons) for primary actions

## Quick Implementation Tips
1. Use 4dp grid for all spacing (4dp, 8dp, 16dp, 24dp, 32dp, 48dp)
2. Elevation shadows: 2dp standard, 8dp on hover
3. Card border radius: 4dp small, 8dp medium, 16dp large
4. FAB size: 56dp standard, 40dp mini (bottom-right or bottom-center)
5. Bottom navigation: 3-5 destinations maximum
6. Ripple effect: `transform: scale(10, 10)` on active
7. Support dynamic color for Android 12+

## Framework-Agnostic Approach
Works with: Android native (Kotlin/Java), Flutter, React Native, React (Material-UI), web (MDC Web)

## Common Pitfalls to Avoid
- ❌ Overusing elevation (too many layers create visual noise)
- ❌ Inconsistent spacing (random breaks in rhythm)
- ❌ Missing ripple feedback (interactions feel unresponsive)

## Learn More
- Load full `material-design` skill for detailed guidelines
- Search online: "Material Design components", "Material UI examples"
- Study: Google apps, Material.io, Material Design 3

## Aliases
This command can also be invoked as:
- `/material`
- `/android`
