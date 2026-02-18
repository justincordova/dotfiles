---
name: bento-grid-design
description: Use when building dashboards, portfolio showcases, or compartmentalized content layouts with varied cell sizes
---

# Bento Grid Layout Design

## Core Principle
Modular compartmentalization - organized information hierarchy through grid-based containers inspired by Japanese bento boxes.

## When to Apply
- Symptom: Dashboard layouts, mixed content types, feature showcases
- Use case: Analytics dashboards, portfolio websites, app store interfaces
- Context: Diverse content needing organized presentation

## Visual Characteristics
**Typography:** Clean sans-serif (Inter, SF Pro, Roboto), clear hierarchy (12-48px), left-aligned text, balanced line lengths, varied sizes for emphasis

**Color:** Neutral backgrounds (white, light gray, dark mode), subtle shadows or borders for depth, accent colors sparingly, consistent color coding for content types

**Spacing:** Generous padding within cells (16-32px), consistent gaps between grid items (4-24px), proper whitespace for breathing room, optical alignment

**Layout:** Rectangular grid cells in rows/columns, 2-4 column layouts on desktop, single column on mobile, cells span multiple rows/columns for emphasis, consistent gaps, rounded corners (8-16px)

**Motion:** Smooth hover transitions, staggered cell reveals, subtle elevation on hover, responsive layout transitions

## Implementation Guidelines
### Technical Considerations
- Use CSS Grid: `grid-template-columns: repeat(4, 1fr)`
- 12-column grid for flexibility with 24px gutters
- Responsive breakpoints: mobile (1 col), tablet (2-3 cols), desktop (3-4 cols)
- Cell span classes: `grid-column: span 2`, `grid-row: span 2`
- Gap consistency: `gap: 24px` for desktop, `16px` tablet, `8px` mobile
- Border radius: 8px-16px for softer edges
- Performance: `content-visibility: auto` for off-screen cells, lazy load images
- Test accessibility: keyboard navigation, screen reader support

### Quick Reference
| Element | Guideline |
|---------|----------|
| Grid columns | 4 columns desktop, 2-3 tablet, 1 mobile |
| Cell padding | 16-32px within cells |
| Grid gaps | 24px desktop, 16px tablet, 8px mobile |
| Border radius | 8px-16px |
| Cell span | Use `span-2`, `span-2x2` for emphasis |
| Hover effect | Subtle elevation: `transform: translateY(-2px)` |

## Common Mistakes
- ❌ Inconsistent cell sizes: Breaks visual rhythm
- ✅ Span system: Use consistent span classes for variety

- ❌ Poor mobile stacking: Complex grids become unusable
- ✅ Single column: Stack all cells on mobile with clear separation

- ❌ No whitespace: Cramped, overwhelming interface
- ✅ Generous gaps: 24px+ between cells creates breathing room

## Research More
For examples and additional resources, this skill can search online for "bento grid layouts", "CSS grid dashboard examples", and "bento design patterns"
