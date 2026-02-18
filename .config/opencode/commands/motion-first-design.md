---
description: Quick guidance on motion-first design and microinteractions
argument-hint: [optional: specific-question]
allowed-tools: [Skill]
---

# /motion-first-design

Get quick guidance on motion-first design - microinteraction feedback for engaging interfaces.

## When to Use
- Building interactive UIs, animation-heavy interfaces, or engagement-focused applications
- Creating button interactions, form validation, or navigation transitions
- Need visual confirmation and user feedback for all actions
- Designing data visualization or media-rich experiences

## Quick Overview

**Core Principle:** Feedback-driven design - every action deserves a visual response that enhances understanding and creates delight.

**Key Characteristics:**
- Fast microinteractions (100-300ms for feedback)
- Smooth transitions (200-500ms for state changes)
- Cubic-bezier easing for organic feel
- Subtle movements (2-8px translations)
- Scale changes (0.95-1.05 for hover states)

## Quick Implementation Tips
1. CSS transitions: `transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1)`
2. Use `transform` and `opacity` for GPU acceleration (60fps target)
3. Avoid animating `width`, `height`, `top`, `left` (causes reflow)
4. `@media (prefers-reduced-motion: reduce)` - respect user preference
5. Button hover: `translateY(-2px)` or `scale(1.02)` (150-200ms)
6. Button click: `scale(0.98)` or `translateY(1px)` (100ms)
7. Page transitions: 300-500ms with cubic-bezier easing
8. Loading states: skeleton screens, spinners, progress bars

## Framework-Agnostic Approach
Works with: React (Framer Motion), Vue (Transition), Angular, GSAP, Motion One, any framework with CSS/JS animation support

## Common Pitfalls to Avoid
- ❌ Over-animating (too many effects distract and confuse)
- ❌ Ignoring reduced motion (accessibility violation)
- ❌ Poor performance (animating layout properties causes jank)

## Learn More
- Load full `motion-first-design` skill for detailed guidelines
- Search online: "microinteraction examples", "UI animation best practices"
- Study: Stripe forms, Linear transitions, Google ripple effects

## Aliases
This command can also be invoked as:
- `/motion`
- `/microinteraction`
- `/animation`
