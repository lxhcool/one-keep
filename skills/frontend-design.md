---
name: frontend-design
description: Design and implement distinctive, production-grade frontend interfaces with strong visual direction, real usability, and high implementation quality. Use when the user asks to build or refine pages, components, dashboards, landing pages, application shells, or any frontend UI that must feel intentionally designed rather than generic.
license: Complete terms in LICENSE.txt
---

# frontend-design

This skill is for designing and implementing frontend UI that feels authored, specific, and production-ready.

It is not a "make it prettier" prompt.
It is a disciplined workflow for turning product requirements into a clear visual direction, then into polished code.

Use this skill when the task involves:
- building a page, component, screen, app shell, or full frontend
- redesigning or beautifying an existing frontend
- translating rough requirements into a concrete visual system
- improving layout, hierarchy, motion, color, typography, or interaction quality

Do not use this skill for:
- backend-only work
- purely textual copywriting tasks
- minor one-line CSS tweaks unless the user explicitly wants design judgment

## Core Principle

Every output must have a strong point of view.

The goal is not "nice enough".
The goal is a frontend that feels intentional, memorable, and coherent while still being usable, accessible, and shippable.

## Operating Rules

Always:
- implement real working code, not mockups unless the user explicitly asks for mockups
- choose a clear aesthetic direction before editing
- match the design to product context and user intent
- preserve an existing design system when working inside one
- optimize for hierarchy, spacing, readability, and interaction quality
- respect responsive behavior and accessibility

Never:
- default to generic AI aesthetics
- use interchangeable layouts with no visual identity
- rely on overused choices by reflex
- add decoration that hurts clarity or usability
- introduce complexity that the implementation cannot support cleanly

## Anti-Patterns

Avoid these unless the product context truly calls for them:
- default white page + purple gradient + centered card
- Inter/Roboto/Arial/system as the automatic choice
- every section using the same card/grid pattern
- vague "modern SaaS" without a distinct visual direction
- random motion everywhere instead of one coordinated motion system
- glassmorphism used by habit rather than intent
- ornamental shadows, glows, and gradients with no structural purpose

## Design Workflow

Before coding, decide these explicitly:

### 1. Product Context
- What is this interface for?
- Who uses it?
- What action or understanding matters most on this screen?

### 2. Visual Direction
Pick a deliberate aesthetic direction, for example:
- refined editorial
- calm premium minimal
- playful utility
- brutalist/raw
- organic/natural
- technical/control-room
- retro-futurist
- luxury geometric

The direction must affect typography, color, spacing, motion, and composition.

### 3. Differentiator
Define one memorable visual or interaction idea.

Examples:
- a dramatic asymmetrical hero
- layered card planes with controlled motion
- a strong numeric dashboard language
- tactile pill-based navigation
- expressive type-led composition

### 4. Constraints
Confirm:
- framework and stack
- responsive requirements
- accessibility expectations
- performance constraints
- whether this is a fresh design or must fit an existing system

## Execution Standards

### Typography
- Use a characterful display face paired with a readable body face when appropriate.
- Build clear hierarchy with size, weight, rhythm, and spacing.
- Do not choose fonts lazily.
- If the existing product already has a font system, stay consistent unless the user asked for redesign.

### Color
- Build around a deliberate palette with a dominant base and controlled accents.
- Use CSS/custom properties or theme tokens for consistency.
- Prefer confidence over timid neutrality.
- Ensure contrast remains usable in both primary and secondary text.

### Layout
- Compose with intent.
- Use rhythm, negative space, scale contrast, and grouping to guide attention.
- Break grid predictability when it improves memorability, but not at the cost of clarity.
- Design for mobile and desktop unless the user narrows scope.

### Motion
- Use motion to reinforce hierarchy and state changes.
- Prefer a few high-quality moments over many weak ones.
- Typical good uses:
  - page entry
  - staggered reveal
  - press feedback
  - tab/nav transitions
  - loading state shimmer
- Respect reduced-motion where practical.

### Surfaces and Depth
- Use gradients, borders, textures, overlays, or shadows intentionally.
- Depth should clarify importance, not just decorate.
- If a flatter style is chosen, commit to flatness and remove accidental glow/shadow noise.

### Interaction
- Buttons, cards, nav items, and toggles must feel tactile.
- Hover, focus, pressed, active, disabled, and loading states should be deliberate.
- Inputs should have strong focus affordances and clean validation presentation.

## Existing-System Rule

If working in an existing product:
- preserve its component language
- keep spacing and interaction patterns compatible
- improve quality without making the page look imported from another app

If working from scratch:
- create a consistent visual system before building multiple components

## Output Requirements

When using this skill, the implementation should aim to produce:
- working frontend code
- a clear visual direction
- polished states and transitions
- responsive behavior
- accessible hierarchy and interaction states

Unless the user asked for something else, prefer output that is:
- production-oriented
- componentized
- easy to extend
- visually complete enough to review immediately

## Recommended Response Pattern

When performing the task, structure the work internally like this:

1. State the chosen visual direction in one sentence.
2. Summarize the main UI decisions that follow from that direction.
3. Implement directly.
4. Verify layout, responsiveness, and interaction quality.
5. Explain what changed in high-signal terms.

Do not spend long paragraphs romanticizing the design.
Spend the effort in the implementation.

## Quality Bar

Before considering the task complete, check:
- Does this feel specific to the product rather than generic?
- Is the hierarchy obvious within 3 seconds?
- Are spacing and type choices consistent?
- Do buttons and inputs feel intentional?
- Is there at least one memorable visual idea?
- Does it still feel usable and not overdesigned?
- Would this survive a design review without needing excuses?

## Frontend Implementation Guidance

### For React / modern web
- prefer component boundaries that reflect actual UI structure
- avoid unnecessary memoization unless the codebase already uses it or performance requires it
- keep styling tokens centralized
- use animation libraries only if already present or clearly justified

### For plain HTML/CSS/JS
- prioritize CSS variables, semantic structure, and resilient layout
- favor CSS animation/transitions before adding JS-driven motion

### For Flutter
- use shared theme tokens and reusable widgets
- keep animation durations coherent
- ensure pressed/selected/loading states feel consistent across screens
- avoid decorating every widget independently; prefer shared primitives

## Verification Checklist

Before finalizing:
- responsive layout checked
- empty/loading/error states reviewed
- focus/pressed/disabled states reviewed
- color contrast sanity-checked
- no accidental overflow or clipping
- no visual effect used without purpose
- no part of the UI feels like filler

## Short Reminder

Make it feel designed.
Make it work.
Make it specific.
Do not make it generic.
