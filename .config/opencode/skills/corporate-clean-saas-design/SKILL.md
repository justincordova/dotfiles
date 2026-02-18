---
name: corporate-clean-saas-design
description: Use when building enterprise applications, SaaS dashboards, data-heavy interfaces, or need professional/trustworthy aesthetics
---

# Corporate Clean / SaaS Design

## Core Principle
Trust through consistency - uniform elements create reliability and scalability across complex interfaces.

## When to Apply
- Symptom: Enterprise applications, data dashboards, admin panels
- Use case: SaaS products, project management tools, developer platforms
- Context: Professional audiences, business users, data-first experiences

## Visual Characteristics
**Typography:** Professional sans-serifs (Inter, system-ui, IBM Plex), clear 6-7 heading levels, condensed fonts for data tables, monospace for code/technical content

**Color:** Neutral bases (#000000, #FFFFFF, #F5F5F5), trust colors (blue #007AFF, green #28A745), semantic status colors, gray scale for non-interactive elements, dark text (#1A1A1A)

**Spacing:** 8px grid system (multiples of 8), dense but readable information density, 4-6px padding in data tables, 16-24px between sections, sidebar width 240-280px

**Layout:** Dashboard grids (3-4 columns), left or top navigation, breadcrumb trails, tabbed interfaces, modal overlays for secondary actions, data tables with sorting/filtering

**Motion:** Purposeful and functional, loading states, micro-interactions for feedback, smooth transitions (200-400ms), no decorative animations

## Implementation Guidelines
### Technical Considerations
- Documented component library (Storybook for visual docs)
- Token-based design system for consistency
- Accessibility-first approach with clear focus states
- 12-column grid with 24px gutters
- Responsive breakpoints: mobile (320px), tablet (768px), desktop (1024px)
- 16px minimum touch targets for interactive elements
- Form validation with inline messages

### Quick Reference
| Element | Guideline |
|---------|----------|
| Grid system | 8px baseline, multiples of 8 |
| Spacing scale | 4px, 8px, 16px, 24px, 32px, 48px |
| Sidebar width | 240-280px |
| Table padding | 4-6px (dense) |
| Touch targets | 16px minimum |
| Focus states | 2px ring on focus |

## Common Mistakes
- ❌ Too sterile: Lacks personality and becomes boring
- ✅ Subtle personality: Add strategic accent colors and thoughtful details

- ❌ Inconsistent components: Similar elements look different
- ✅ Component library: Documented and reusable components

- ❌ Poor data density: Too much whitespace reduces efficiency
- ✅ Balanced density: Dense but readable information hierarchy

## Research More
For examples and additional resources, this skill can search online for "corporate SaaS design", "enterprise UI patterns", and "SaaS dashboard examples"
