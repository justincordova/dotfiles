---
name: motion-first-design
description: Use when building interactive UIs, animation-heavy interfaces, or need microinteraction feedback for user actions
---

# Motion-First / Microinteraction Design

## Core Principle
Feedback-driven design - every action deserves a visual response that enhances understanding and creates delight.

## When to Apply
- Symptom: Interactive interfaces, user feedback needs, engagement goals
- Use case: Button interactions, form validation, navigation transitions, data visualization
- Context: User experience benefits from visual confirmation and guidance

## Visual Characteristics
**Typography:** Standard typography from parent design system, motion applied to text states (loading, success, error)

**Color:** Motion states use semantic colors (success green, error red, warning orange), hover states with slight color shifts, active states with reduced brightness

**Spacing:** Motion doesn't change spacing, but elements may expand/contract during transitions

**Layout:** Layout stable during motion, elements transform in place, staggered reveals for content loading

**Motion:** Fast microinteractions (100-300ms for feedback), smooth transitions (200-500ms for state changes), cubic-bezier easing for organic feel, subtle movements (2-8px translations), scale changes (0.95-1.05 for hover), rotation (2-15°), opacity shifts (0.6-1.0)

## Implementation Guidelines
### Technical Considerations
- CSS transitions: `transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1)`
- Use `transform` and `opacity` for GPU acceleration (60fps target)
- Avoid animating `width`, `height`, `top`, `left` (causes reflow)
- `@media (prefers-reduced-motion: reduce)` - disable/respect user preference
- Microinteraction timing: button hover 100-200ms, click 100ms, loading 500-1000ms
- Hover states: slight lift `translateY(-2px)` or scale `scale(1.02)`
- Active states: press down `scale(0.98)` or `translateY(1px)`
- Loading states: skeleton screens, spinners, progress bars with animation
- Success/error states: color transitions, icon animations, checkmark draws
- Web Animations API for complex sequences
- Libraries: Framer Motion (React), GSAP, Motion One for advanced effects

### Quick Reference
| Interaction Type | Duration | Easing | Effect |
|----------------|----------|--------|--------|
| Button hover | 150-200ms | ease-out | Scale 1.02, slight lift |
| Button click | 100ms | ease-in | Scale 0.98, press down |
| Page transition | 300-500ms | cubic-bezier | Slide, fade, or zoom |
| Form validation | 200-300ms | ease-out | Color shift, icon animation |
| Loading state | 500-2000ms | linear/ease-in-out | Spinner, skeleton, progress |
| Success confirmation | 300-500ms | cubic-bezier | Checkmark draw, color pulse |
| Error shake | 300-400ms | ease-in-out | 6px horizontal shake |

## Common Mistakes
- ❌ Over-animating: Too many effects distract and confuse
- ✅ Purposeful motion: Every animation serves a clear purpose

- ❌ Ignoring reduced motion: Accessibility violation for motion-sensitive users
- ✅ Respect preferences: `@media (prefers-reduced-motion: reduce)`

- ❌ Poor performance: Animating layout properties causes jank
- ✅ GPU acceleration: Use `transform` and `opacity` for smooth 60fps

## Research More
For examples and additional resources, this skill can search online for "microinteraction examples", "UI animation best practices", and "Framer Motion tutorials"
