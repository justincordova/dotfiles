---
name: apple-style-minimalism
description: Use when building Apple ecosystem apps, iOS/macOS interfaces, or need premium/polished minimalism with intuitive design
---

# Apple-Style Minimalism

## Core Principle
Intuitive by design - interfaces should explain themselves through seamless integration of form, function, and motion.

## When to Apply
- Symptom: iOS/macOS native applications, Apple product showcases
- Use case: Premium apps, media consumption, creative tools, health/fitness
- Context: Users familiar with Apple interface patterns, expect polish

## Visual Characteristics
**Typography:** San Francisco (SF Pro) custom typeface, system font stack `-apple-system, BlinkMacSystemFont`, dynamic type sizing, carefully tuned letter-spacing and line-height, bold headlines with relaxed body text

**Color:** System colors adapting to appearance mode, vibrant accents (Apple Blue #007AFF, Green, Orange, Red), gradients used sparingly and subtly, translucent materials in moderation, dark mode with reduced saturation

**Spacing:** Large comfortable touch targets (44x44pt minimum), generous padding between sections, 12pt/16pt/20pt/24pt/32pt/40pt/48pt scale, safe areas for notches and home indicators, dynamic type adjusts based on content

**Layout:** Bottom navigation on mobile, tab bar for primary navigation, centered content with max-width constraints, smooth scrolling with bounce effect, full-screen gestures (swipe, pinch), modal sheets (half-screen on mobile)

**Motion:** Smooth physics-based animations, spring physics for natural feel (40-80Hz), purposeful micro-interactions, staggered reveals, smooth page transitions, gestures provide feedback

## Implementation Guidelines
### Technical Considerations
- Follow Human Interface Guidelines (HIG) for clarity, deference, depth, feedback
- Use safe area insets: `padding-top: env(safe-area-inset-top)`
- Touch target minimum: 44x44pt
- Glassmorphism: `backdrop-filter: blur(20px)` with `rgba(255, 255, 255, 0.8)`
- Smooth transitions: `transition: all 0.3s cubic-bezier(0.25, 0.1, 0.25, 1)`
- Subtle shadows for elevation: `box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04)`
- Test in both light and dark appearance modes
- Support Dynamic Type for accessibility

### Quick Reference
| Element | Guideline |
|---------|----------|
| Touch targets | 44x44pt minimum |
| Font stack | -apple-system, BlinkMacSystemFont |
| Transitions | 0.3s cubic-bezier(0.25, 0.1, 0.25, 1) |
| Spacing scale | 12pt, 16pt, 20pt, 24pt, 32pt, 40pt, 48pt |
| Blur effect | backdrop-filter: blur(20px) |
| Shadow elevation | 0 2px 8px rgba(0, 0, 0, 0.04) |

## Common Mistakes
- ❌ Missing motion: Interfaces feel lifeless and less intuitive
- ✅ Purposeful animation: Every motion enhances understanding

- ❌ Violating HIG patterns: Users can't predict behavior
- ✅ Follow Apple conventions: Familiar interactions work as expected

- ❌ No dark mode support: Incomplete experience
- ✅ Appearance-aware: Design for both light and dark modes

## Research More
For examples and additional resources, this skill can search online for "Apple Human Interface Guidelines", "iOS design patterns", and "macOS UI examples"
