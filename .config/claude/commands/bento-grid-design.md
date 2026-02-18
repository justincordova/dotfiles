---
description: Quick guidance on bento grid layout design for compartmentalized content
argument-hint: [optional: specific-question]
allowed-tools: [Skill]
---

# /bento-grid-design

Get quick guidance on bento grid layout design - modular compartmentalization for dashboards and portfolios.

## When to Use
- Building dashboard layouts, analytics interfaces, or admin panels
- Creating portfolio websites, app store interfaces, or feature showcases
- Organizing diverse content types with clear information hierarchy
- Designing mixed-media layouts with varied content sizes

## Quick Overview

**Core Principle:** Modular compartmentalization - organized information hierarchy through grid-based containers inspired by Japanese bento boxes.

**Key Characteristics:**
- Rectangular grid cells in rows/columns
- Cells span multiple rows/columns for emphasis
- Consistent gaps between grid items (4-24px)
- Rounded corners (8-16px)
- Clean sans-serif typography

## Quick Implementation Tips
1. Use CSS Grid: `grid-template-columns: repeat(4, 1fr)`
2. 12-column grid with 24px gutters for flexibility
3. Responsive breakpoints: mobile (1 col), tablet (2-3 cols), desktop (3-4 cols)
4. Cell span classes: `grid-column: span 2`, `grid-row: span 2`
5. Gap consistency: `gap: 24px` desktop, `16px` tablet, `8px` mobile
6. Border radius: 8px-16px for softer edges
7. Generous cell padding: 16-32px within cells
8. Performance: `content-visibility: auto` for off-screen cells

## Framework-Agnostic Approach
Works with: React, Vue, Angular, Svelte, vanilla CSS Grid, any framework with CSS support

## Common Pitfalls to Avoid
- ❌ Inconsistent cell sizes (breaks visual rhythm)
- ❌ Poor mobile stacking (complex grids become unusable)
- ❌ No whitespace (cramped, overwhelming interface)

## Learn More
- Load full `bento-grid-design` skill for detailed guidelines
- Search online: "bento grid layouts", "CSS grid dashboard examples"
- Study: Apple product pages, Notion dashboards, Linear

## Aliases
This command can also be invoked as:
- `/bento`
- `/bento-grid`
- `/grid`
