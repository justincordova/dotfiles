---
name: flat-design
description: Use when building SaaS applications, mobile apps, or need bold simple interfaces without depth effects
---

# Flat Design

## Core Principle
Digital authenticity - embrace screen-native rendering without skeuomorphism, removing unnecessary visual noise.

## When to Apply
- Symptom: SaaS applications, mobile apps, clean interfaces needed
- Use case: Enterprise software, documentation sites, developer tools
- Context: Performance and clarity prioritized over decorative effects

## Visual Characteristics
**Typography:** Clean sans-serif (Helvetica Neue, Roboto, Open Sans), large bold headlines (32-64px), high contrast ratios (4.5:1), clear visual hierarchy through size, system fonts for performance

**Color:** Vibrant saturated colors (primary, secondary palettes), limited 3-6 core colors, flat backgrounds without gradients, high contrast for accessibility, bold accent colors for CTAs

**Shapes:** Geometric shapes (circles, squares, rectangles), sharp edges or minimal border-radius (2-4px), simple icons, consistent stroke weights (1-2px), scalable vector graphics

**Shadows and Depth:** Minimal or no shadows (flat layering), subtle separation through color differences, avoid 3D effects, no gradients or textures, clean solid borders when needed

**Motion:** Simple transitions, subtle hover states, functional animations only

## Implementation Guidelines
### Technical Considerations
- Flat button: solid color background, no shadows, `border-radius: 4px`
- Hover state: slight color darkening, no lift effect
- Active state: darker color, minimal scale `scale(0.98)`
- Card component: solid border `1px solid #E5E7EB`, no shadow
- Border radius: 2-4px for buttons, 8px for cards, 4px for inputs
- Color variables: `--primary: #007AFF`, `--secondary: #5AC8FA`
- Performance: minimal assets, fast loading, no complex effects
- Focus states: solid outline `2px solid #007AFF`, visible keyboard navigation
- Accessibility: WCAG AA compliance for color contrast, screen reader semantic HTML
- Touch targets: 44x44px minimum for mobile

### Quick Reference
| Element | Guideline |
|---------|----------|
| Color palette | 3-6 colors maximum |
| Border radius | 2-4px (buttons), 8px (cards) |
| Shadows | None or minimal |
| Gradients | Avoid, use solid colors |
| Stroke weight | 1-2px for icons/borders |
| Contrast ratio | 4.5:1 minimum (WCAG AA) |
| Hover effect | Color darkening only |
| Touch targets | 44x44px minimum |

## Common Mistakes
- ❌ Too flat: No visual hierarchy, hard to scan
- ✅ Clear hierarchy: Use size, color, weight for organization

- ❌ Poor accessibility: Low contrast colors fail WCAG
- ✅ High contrast: 4.5:1 ratio minimum for readability

- ❌ Boring interface: Lacks character and engagement
- ✅ Strategic personality: Bold colors and intentional choices

## Research More
For examples and additional resources, this skill can search online for "flat design examples", "flat UI patterns", and "flat design best practices"
