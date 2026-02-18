---
description: Quick guidance on flat design for bold simple interfaces
argument-hint: [optional: specific-question]
allowed-tools: [Skill]
---

# /flat-design

Get quick guidance on flat design - digital authenticity without depth effects for clean interfaces.

## When to Use
- Building SaaS applications, mobile apps, or clean interfaces
- Creating developer tools, documentation sites, or enterprise software
- Need bold, simple interfaces without decorative depth
- Prioritizing performance and clarity over visual effects

## Quick Overview

**Core Principle:** Digital authenticity - embrace screen-native rendering without skeuomorphism, removing unnecessary visual noise.

**Key Characteristics:**
- Vibrant saturated colors (3-6 core colors)
- No shadows or depth effects
- Geometric shapes with minimal border-radius (2-4px)
- Clean borders (1-2px stroke weight)
- High contrast ratios (4.5:1 minimum)

## Quick Implementation Tips
1. Flat button: solid color background, no shadows, `border-radius: 4px`
2. Hover state: slight color darkening, no lift effect
3. Active state: darker color, minimal scale `scale(0.98)`
4. Card component: solid border `1px solid #E5E7EB`, no shadow
5. Border radius: 2-4px for buttons, 8px for cards, 4px for inputs
6. Color variables: `--primary: #007AFF`, `--secondary: #5AC8FA`
7. Touch targets: 44x44px minimum for mobile
8. Focus states: solid outline `2px solid #007AFF` for keyboard navigation

## Framework-Agnostic Approach
Works with: React, Vue, Angular, Svelte, vanilla CSS/HTML, Bootstrap, Tailwind, any framework

## Common Pitfalls to Avoid
- ❌ Too flat (no visual hierarchy, hard to scan)
- ❌ Poor accessibility (low contrast colors fail WCAG)
- ❌ Boring interface (lacks character and engagement)

## Learn More
- Load full `flat-design` skill for detailed guidelines
- Search online: "flat design examples", "flat UI patterns"
- Study: Microsoft Fluent, Bootstrap, Jira, Confluence

## Aliases
This command can also be invoked as:
- `/flat`
- `/flat-design`
