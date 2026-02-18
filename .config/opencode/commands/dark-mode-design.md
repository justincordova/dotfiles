---
description: Quick guidance on dark mode design for OLED-optimized interfaces
argument-hint: [optional: specific-question]
allowed-tools: [Skill]
---

# /dark-mode-design

Get quick guidance on dark mode design - user preference, eye comfort, and OLED optimization.

## When to Use
- Implementing dark themes or OLED-optimized interfaces
- Building media platforms, developer tools, or any user-facing application
- Need to respect system preferences for appearance
- Creating low-light or professional development environments

## Quick Overview

**Core Principle:** User choice and comfort - respect system preferences for eye comfort, battery efficiency, and consistent experience.

**Key Characteristics:**
- Dark backgrounds (#121212, #1E1E1E, #2D2D2D)
- Light gray text (#E0E0E0) not pure white
- Slightly desaturated colors for reduced eye strain
- Subtle light glows instead of shadows
- Same structural components as light mode

## Quick Implementation Tips
1. Use `@media (prefers-color-scheme: dark)` for automatic switching
2. CSS custom properties: `--color-bg-primary: #121212`
3. Avoid pure white (#FFFFFF) on pure black (#000000) - causes halation
4. Use lighter gray (#E0E0E0) on dark backgrounds
5. Ensure WCAG AA contrast ratio (4.5:1 minimum)
6. Test images: `filter: brightness(0.8) contrast(1.2)`
7. Smooth theme transitions: `transition: background-color 0.3s, color 0.3s`
8. Pure black (#000000) for OLED power savings when appropriate

## Framework-Agnostic Approach
Works with: React, Vue, Angular, Svelte, vanilla CSS/HTML, any framework with theming support

## Common Pitfalls to Avoid
- ❌ Pure white on pure black (halation causes eye strain)
- ❌ Inconsistent themes (different colors between modes breaks mental model)
- ❌ No OLED optimization (wastes battery on OLED screens)

## Learn More
- Load full `dark-mode-design` skill for detailed guidelines
- Search online: "dark mode design guidelines", "OLED dark mode best practices"
- Study: VS Code, Twitter Dark, GitHub Dark, iOS Dark Mode

## Aliases
This command can also be invoked as:
- `/dark`
- `/dark-mode`
