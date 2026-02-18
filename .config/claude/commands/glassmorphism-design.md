---
description: Quick guidance on glassmorphism design for transparent layered interfaces
argument-hint: [optional: specific-question]
allowed-tools: [Skill]
---

# /glassmorphism-design

Get quick guidance on glassmorphism design - transparency and depth effects for modern interfaces.

## When to Use
- Building floating panels, dashboard widgets, or modal dialogs
- Creating modern, premium, or tech-focused design languages
- Need transparent layered glass effects
- Designing overlays, navigation elements, or feature cards

## Quick Overview

**Core Principle:** Transparency and depth - layered interfaces with glass-like qualities creating modern, screen-native aesthetics.

**Key Characteristics:**
- Background blur (10-20px Gaussian blur)
- Transparency/opacity (70-90%)
- Subtle borders (1px, 10-30% opacity)
- Rounded corners (16-32px radius)
- Inner shadows and subtle lighting effects

## Quick Implementation Tips
1. Glass card: `background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(16px);`
2. Webkit fallback: `-webkit-backdrop-filter: blur(16px);`
3. Border: `border: 1px solid rgba(255, 255, 255, 0.2);`
4. Border radius: `border-radius: 20px;`
5. Shadow: `box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);`
6. Dark mode glass: `background: rgba(0, 0, 0, 0.6); border: rgba(255, 255, 255, 0.1);`
7. Fallback for no backdrop-filter: Semi-opaque solid `rgba(255, 255, 255, 0.95)`
8. Limit glass layers: Max 2-3 per view for performance
9. Don't animate blur properties (expensive)

## Framework-Agnostic Approach
Works with: React, Vue, Angular, Svelte, vanilla CSS, any framework with CSS support (Chrome/Safari/Edge best, Firefox limited)

## Common Pitfalls to Avoid
- ❌ Poor readability (text lost against glass background)
- ❌ Overusing glass (too many layers create performance issues)
- ❌ No fallbacks (breaks in browsers without backdrop-filter support)

## Learn More
- Load full `glassmorphism-design` skill for detailed guidelines
- Search online: "glassmorphism examples", "backdrop-filter patterns"
- Study: macOS Big Sur, Windows 11, iOS widgets

## Aliases
This command can also be invoked as:
- `/glass`
- `/glassmorphism`
- `/glass-effect`
