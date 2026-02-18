---
name: material-design
description: Use when building Android apps, Google products, or need metaphorical component-rich design system
---

# Material Design

## Core Principle
Material is the metaphor - UI elements behave like physical materials with elevation, depth, and meaningful motion.

## When to Apply
- Symptom: Android native applications, Google product ecosystems
- Use case: Mobile apps, web applications, cross-platform with Flutter
- Context: Component-rich interfaces needing comprehensive system

## Visual Characteristics
**Typography:** Roboto (historical) and Product Sans/Google Sans (current), scale 12px-112px, Roboto Medium for body, Google Sans with tighter spacing

**Color:** Primary/secondary/tertiary systems, 500-level colors (indigo, purple, teal), surface colors with elevation-based lightness, semantic tokens (primary, on-primary, error), dynamic color extraction (Material You)

**Spacing:** 4px baseline grid, 8dp as base unit, padding 8dp/16dp/24dp/32dp/48dp, margins follow 4dp increments, card elevation shadows create perceived spacing

**Layout:** Grid-based layouts (4, 8, 12 columns), card-based components with subtle shadows, FAB for primary actions, bottom navigation or bottom app bar, drawer/sheet for secondary navigation

**Motion:** Purposeful animations guide and educate, ripple effects on click, elevation transitions, staggered reveals, spring physics, 200-500ms duration

## Implementation Guidelines
### Technical Considerations
- Use Material Design tokens for consistency: colors, typography, elevation
- Elevation system: 0-24dp shadows with progressive depth
- FAB position: bottom-right or bottom-center, elevated above content
- Ripple effect: `transform: scale(10, 10)` on active
- Bottom navigation: 3-5 destinations maximum
- Card elevation: 2dp standard, 8dp on hover
- Border radius: 4dp small, 8dp medium, 16dp large, 28dp extra large
- Support dynamic color for Android 12+

### Quick Reference
| Element | Guideline |
|---------|----------|
| Grid baseline | 4px |
| Spacing unit | 8dp multiples |
| Card radius | 8dp (standard), 16dp (large) |
| FAB size | 56dp standard, 40dp mini |
| Touch targets | 48dp minimum |
| Animation duration | 200-500ms |
| Elevation | 0-24dp scale |

## Common Mistakes
- ❌ Overusing elevation: Too many layers create visual noise
- ✅ Strategic elevation: Use sparingly for meaningful hierarchy

- ❌ Inconsistent spacing: Random breaks in rhythm
- ✅ 4dp grid: All spacing follows 4dp multiples

- ❌ Missing ripple feedback: Interactions feel unresponsive
- ✅ Ripple effects: Visual feedback on every interactive element

## Research More
For examples and additional resources, this skill can search online for "Material Design components", "Material UI examples", and "Material Design 3"
