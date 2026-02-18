---
description: Quick guidance on Apple-style minimalism for premium interfaces
argument-hint: [optional: specific-question]
allowed-tools: [Skill]
---

# /apple-style-minimalism

Get quick guidance on Apple-style minimalism - intuitive design for Apple ecosystem and premium apps.

## When to Use
- Building iOS, macOS, or Apple ecosystem applications
- Creating premium mobile apps or Apple-optimized web experiences
- Need polished, refined minimalism with intuitive interactions
- Designing for users familiar with Apple interface patterns

## Quick Overview

**Core Principle:** Intuitive by design - interfaces should explain themselves through seamless integration of form, function, and motion.

**Key Characteristics:**
- San Francisco (SF Pro) custom typeface
- System colors adapting to appearance mode
- Large comfortable touch targets (44x44pt minimum)
- Smooth physics-based animations with spring effects
- Bottom navigation on mobile, tab bars for primary navigation

## Quick Implementation Tips
1. Use safe area insets: `padding-top: env(safe-area-inset-top)`
2. Implement glassmorphism: `backdrop-filter: blur(20px)` with `rgba(255, 255, 255, 0.8)`
3. Smooth transitions: `transition: all 0.3s cubic-bezier(0.25, 0.1, 0.25, 1)`
4. Subtle shadows: `box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04)`
5. Spacing scale: 12pt, 16pt, 20pt, 24pt, 32pt, 40pt, 48pt
6. Support Dynamic Type and both light/dark appearance modes

## Framework-Agnostic Approach
Works with: SwiftUI, UIKit, React Native, Flutter, web (CSS), cross-platform frameworks

## Common Pitfalls to Avoid
- ❌ Missing motion (interfaces feel lifeless)
- ❌ Violating HIG patterns (users can't predict behavior)
- ❌ No dark mode support (incomplete experience)

## Learn More
- Load full `apple-style-minimalism` skill for detailed guidelines
- Search online: "Apple Human Interface Guidelines", "iOS design patterns"
- Study: iOS apps, Apple Music, macOS Big Sur, Apple.com

## Aliases
This command can also be invoked as:
- `/apple`
- `/ios`
- `/macos`
