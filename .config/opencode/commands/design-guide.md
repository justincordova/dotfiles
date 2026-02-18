---
description: Get detailed guidance on a specific design pattern
argument-hint: <pattern-name>
allowed-tools: [Skill]
---

# /design-guide

Quick reference for specific design patterns without interactive selection.

## Workflow

When this command is invoked with a pattern name:

1. **Normalize and validate pattern name**:
   - Convert to lowercase and hyphenated format
   - Map aliases to skill names
   - If invalid pattern, list available patterns and suggest similar matches

2. **Load corresponding skill** for detailed guidance

3. **Provide condensed summary**:
   - Core principle (1-2 sentences)
   - Best for [use cases]
   - Key characteristics (bullet points)
   - Quick implementation tips (3-5 tips)

4. **Offer additional help**:
   - Open full skill documentation for detailed guidance
   - Search online for examples, tutorials, and best practices
   - Answer specific questions about implementation

5. **Framework-agnostic approach**:
   - Patterns apply to any frontend framework (React, Vue, Angular, etc.)
   - Work for web, mobile, and desktop applications
   - Focus on design principles, not implementation specifics

## Pattern Aliases

| User Input | Skill Name |
|------------|------------|
| minimalism, minimal | minimalism-design |
| corporate, saas, clean | corporate-clean-saas-design |
| apple, ios, macos | apple-style-minimalism |
| material, android | material-design |
| dark, dark-mode | dark-mode-design |
| bento, bento-grid, grid | bento-grid-design |
| motion, microinteraction, animation | motion-first-design |
| flat, flat-design | flat-design |
| glass, glassmorphism, glass-effect | glassmorphism-design |
| swiss, swiss-style, international | swiss-style-design |

## Available Patterns

1. **minimalism-design** - Essentialism, "less is more" philosophy
2. **corporate-clean-saas-design** - Trust through consistency for enterprise
3. **apple-style-minimalism** - Intuitive design for Apple ecosystem
4. **material-design** - Metaphorical design for Android/Google
5. **dark-mode-design** - User preference and comfort
6. **bento-grid-design** - Modular compartmentalization
7. **motion-first-design** - Microinteraction feedback design
8. **flat-design** - Digital authenticity without depth
9. **glassmorphism-design** - Transparency and depth effects
10. **swiss-style-design** - Mathematical precision and typography

## Example Usage

```
/design-guide minimalism
/design-guide material
/design-guide dark-mode
/design-guide bento-grid
```

## Aliases

This command can also be invoked as:
- `/pattern-guide`
- `/design-help`

## Sample Output Format

```
## [Pattern Name]

**Core Principle:** [One-sentence philosophical foundation]

**Best for:** [List of use cases]

**Key characteristics:**
- [Characteristic 1]
- [Characteristic 2]
- [Characteristic 3]

**Quick tips:**
- [Tip 1]
- [Tip 2]
- [Tip 3]

[Would you like detailed implementation guidance?]
[Search for [Pattern Name] examples and tutorials]
```

## Notes

- All patterns are framework-agnostic and can be applied to any tech stack
- Patterns apply to web, mobile, and desktop applications
- Skills include research capability for additional resources
- Multiple patterns can be combined for hybrid approaches
- Always consider accessibility, performance, and target audience
