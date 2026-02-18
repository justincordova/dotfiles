---
name: dark-mode-design
description: Use when implementing dark themes, OLED-optimized interfaces, or need user preference-based color schemes
---

# Dark Mode Design

## Core Principle
User choice and comfort - respect system preferences for eye comfort, battery efficiency, and consistent experience.

## When to Apply
- Symptom: Low-light environments, OLED displays, user preference
- Use case: All application types, media platforms, developer tools
- Context: Users demand dark mode as standard feature

## Visual Characteristics
**Typography:** Slightly reduced font weight for dark backgrounds, increased letter-spacing for readability, lighter gray text (#E0E0E0) not pure white, careful font stack selection

**Color:** Dark backgrounds (#121212, #1E1E1E, #2D2D2D), text colors (#E0E0E0, #B0B0B0, #909090), accent colors with increased luminance, slightly desaturated colors, transparent overlays (0.7-0.9 opacity)

**Spacing:** Identical to light mode for consistency, may reduce visual weight with more negative space, dark borders replaced by subtle light borders (0.12 opacity)

**Layout:** Same structural components as light mode, cards with dark backgrounds and lighter surface colors, reduced shadows (subtle light glows instead), elevated elements: #1E1E1E, #2C2C2C, #373737

**Motion:** Same timing as light mode, but glow effects instead of shadows for feedback, subtle light highlights on interactions

## Implementation Guidelines
### Technical Considerations
- Use `@media (prefers-color-scheme: dark)` for automatic switching
- CSS custom properties for theme tokens: `--color-bg-primary: #121212`
- Manual toggle with localStorage persistence
- Pure black (#000000) for OLED power savings when appropriate
- Avoid pure white (#FFFFFF) on pure black - causes halation (use #E0E0E0)
- Ensure WCAG AA contrast ratio (4.5:1 minimum)
- Test images with `filter: brightness(0.8) contrast(1.2)`
- Support reduced motion and high contrast preferences
- Smooth theme transitions: `transition: background-color 0.3s, color 0.3s`

### Quick Reference
| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Primary background | #FFFFFF | #121212 |
| Secondary background | #F5F5F5 | #1E1E1E |
| Text primary | #1A1A1A | #E0E0E0 |
| Text secondary | #6B7280 | #B0B0B0 |
| Accent color | #007AFF | #BB86FC (or luminance-adjusted) |
| Border opacity | 0.12 | 0.12 (lighter value) |

## Common Mistakes
- ❌ Pure white on pure black: Halation causes eye strain
- ✅ Balanced luminance: #E0E0E0 on #121212 for comfortable reading

- ❌ Inconsistent themes: Different colors between modes breaks mental model
- ✅ Semantic tokens: Same semantic meaning, adjusted luminance values

- ❌ No OLED optimization: Wastes battery on OLED screens
- ✅ Pure black backgrounds: #000000 for power savings where appropriate

## Research More
For examples and additional resources, this skill can search online for "dark mode design guidelines", "OLED dark mode best practices", and "dark mode color contrast"
