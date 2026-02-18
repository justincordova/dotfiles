---
name: glassmorphism-design
description: Use when building floating panels, overlays, or need transparent layered glass effects
---

# Glassmorphism Design

## Core Principle
Transparency and depth - layered interfaces with glass-like qualities creating modern, screen-native aesthetics.

## When to Apply
- Symptom: Floating panels, overlays, modern UI effects needed
- Use case: Dashboard widgets, modal dialogs, navigation elements, feature cards
- Context: Modern, premium, or tech-focused design language

## Visual Characteristics
**Visual Effects:** Background blur (10-20px Gaussian blur), transparency/opacity (70-90%), subtle borders (1px, 10-30% opacity), inner shadows for depth, color overlay tints

**Colors:** Light backgrounds with white glass (`rgba(255, 255, 255, 0.7)`), dark backgrounds with dark glass (`rgba(0, 0, 0, 0.6)`), gradient overlays for richness, subtle accent colors, high contrast text

**Shapes:** Rounded corners (16-32px radius), smooth edges, floating layers, overlapping elements, soft shadows for elevation

**Lighting:** Specular highlights, ambient light effects, inner glow for glass thickness, reflection simulation, soft drop shadows

**Motion:** Smooth fade-ins, subtle hover elevations, backdrop blur transitions

## Implementation Guidelines
### Technical Considerations
- Glass card: `background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(16px);`
- Webkit fallback: `-webkit-backdrop-filter: blur(16px);`
- Border: `border: 1px solid rgba(255, 255, 255, 0.2);`
- Border radius: `border-radius: 20px;`
- Shadow: `box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);`
- Dark mode glass: `background: rgba(0, 0, 0, 0.6); border: rgba(255, 255, 255, 0.1);`
- Browser support: Chrome/Safari/Edge good, Firefox requires flag or fallback
- Fallback for no backdrop-filter: Semi-opaque solid background `rgba(255, 255, 255, 0.95)`
- Performance: GPU-accelerated with `transform: translateZ(0)` if needed
- Limit glass layers: Max 2-3 per view for performance
- Don't animate blur properties (expensive)
- Accessibility: Text contrast must meet WCAG AA (4.5:1) on glass backgrounds
- Test with various background patterns and images
- Keyboard focus states: Visible on glass (solid outline or ring)

### Quick Reference
| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | rgba(255, 255, 255, 0.7) | rgba(0, 0, 0, 0.6) |
| Border | rgba(255, 255, 255, 0.2) | rgba(255, 255, 255, 0.1) |
| Blur | 16px | 16px |
| Border radius | 20px | 20px |
| Shadow | 0 8px 32px rgba(0, 0, 0, 0.1) | 0 8px 32px rgba(0, 0, 0, 0.3) |
| Opacity | 70-90% | 70-90% |

## Common Mistakes
- ❌ Poor readability: Text lost against glass background
- ✅ High contrast: Ensure 4.5:1 WCAG AA ratio for accessibility

- ❌ Overusing glass: Too many layers create performance issues
- ✅ Strategic layers: Max 2-3 glass elements per view

- ❌ No fallbacks: Breaks in browsers without backdrop-filter support
- ✅ Progressive enhancement: Semi-opaque solid background as fallback

## Research More
For examples and additional resources, this skill can search online for "glassmorphism examples", "backdrop-filter patterns", and "glassmorphism best practices"
