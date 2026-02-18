---
description: Interactive design pattern selection assistant for frontend projects
argument-hint: [optional: project-type audience constraints]
allowed-tools: [Question, Skill]
---

# /design-pattern

Interactive assistant to help you choose the right design pattern for your frontend project.

## Workflow

When this command is invoked:

1. **Parse optional arguments** or ask clarifying questions:
   - What type of project? (web app, mobile app, dashboard, portfolio, marketing site, etc.)
   - Who is the target audience? (enterprise, consumers, developers, general public, etc.)
   - Any constraints or preferences? (framework, performance, accessibility, platform, etc.)
   - What's the primary goal? (trust, innovation, speed, simplicity, engagement, etc.)

2. **Recommend 2-3 patterns** based on answers with brief justifications:
   - Explain why each pattern fits the requirements
   - Highlight key characteristics relevant to the project
   - Mention potential considerations or trade-offs

3. **Use Question tool** for user to select pattern:
   - Present options with pattern names
   - Allow user to ask questions about patterns
   - Offer to see examples or more details

4. **Load selected skill** for detailed guidance:
   - Invoke corresponding design pattern skill
   - Provide summary of key implementation points
   - Answer specific questions about applying the pattern

5. **Offer additional help**:
   - Show examples and references
   - Search online for more information about the pattern
   - Provide implementation tips specific to user's framework/stack

## Pattern Recommendations Logic

| Project Type | Recommended Patterns |
|--------------|---------------------|
| Enterprise SaaS/Dashboard | Corporate Clean, Material Design, Dark Mode |
| Mobile App | Apple-Style Minimalism (iOS), Material Design (Android), Flat Design |
| Portfolio/Showcase | Minimalism, Bento Grid, Swiss Style |
| Marketing Site | Minimalism, Swiss Style, Motion-First |
| Media/Content | Dark Mode, Apple-Style, Motion-First |
| Developer Tools | Corporate Clean, Dark Mode, Flat Design |

## Example Usage

```
/design-pattern
/design-pattern dashboard enterprise performance
/design-pattern mobile app iOS consumers
```

## Available Patterns

All 10 design patterns are available:
- minimalism-design
- corporate-clean-saas-design
- apple-style-minimalism
- material-design
- dark-mode-design
- bento-grid-design
- motion-first-design
- flat-design
- glassmorphism-design
- swiss-style-design

## Aliases

This command can also be invoked as:
- `/design`
- `/pattern`

## Notes

- Recommendations are based on best practices and common use cases
- User preferences and specific constraints may override recommendations
- Multiple patterns can be combined for hybrid approaches
- Always consider accessibility, performance, and target audience
