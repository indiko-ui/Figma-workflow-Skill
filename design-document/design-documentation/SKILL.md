---
name: design-documentation
description: Create polished, evidence-based Figma documentation pages for selected components, patterns, and UI sections. Use when documenting how an existing design works; do not use to invent a design system or product behavior.
---

# Design Documentation

Create a documentation page that makes an existing Figma design easier to understand, review, and implement. The page is an interface in its own right: it should lead with the component, make important decisions easy to scan, and use visual evidence instead of verbose notes.

Document only what can be observed in the selected scope, its linked components and variables, nearby design-system examples, or supplied product requirements. Mark gaps as **Needs definition**. Do not turn an absence of evidence into a proposed API, state, breakpoint, accessibility claim, or token.

## Scope and outcome

Use this skill for a selected component, component set, pattern, or bounded UI section. Preserve the component and its existing behavior; build or update the surrounding documentation only.

The output should let a designer or engineer answer these questions quickly:

- What is this and when should I use it?
- What can I configure or swap?
- What visual or layout rules must remain true?
- Which decisions are confirmed, and which still need definition?

Do not create a long, generic checklist page. A strong small page with real evidence is better than a complete-looking page made of empty tables and placeholder cards.

## 1. Inspect before composing

Before writing or changing the canvas, inspect the exact selected node and its nearby documentation. Capture the evidence needed to make decisions:

- component hierarchy and nested instances;
- component properties, variants, text overrides, and instance swaps;
- variables, styles, typography, fills, borders, effects, and spacing;
- Auto Layout, Hug/Fill/Fixed sizing, constraints, wrapping, clipping, and overflow;
- existing interaction/state evidence and prototype links, if any;
- existing documentation page conventions, components, and grid.

Use exact Figma property and variable names. If the selected node is an instance, distinguish the instance override from the main component capability. Do not infer responsive behavior or interactive states merely because they are common patterns.

Write a compact content plan before building. For every planned section, record the question it answers and the source evidence that supports it. Omit a section when it cannot answer a real question.

## 2. Choose the documentation modules deliberately

Start with a short overview and a prominent component showcase. Then select only the modules warranted by the audit.

| Module | Include when there is evidence | Best visual form |
| --- | --- | --- |
| Anatomy | Structural parts change implementation or use | Numbered callouts attached to a readable component example |
| Properties | The Figma component exposes meaningful configuration | Compact table with exact property names and defaults |
| Variants or states | Actual variants or state designs exist | Comparison matrix with only meaningful differences |
| Layout and sizing | Layout rules affect composition or resilience | Short spec beside short/long/content-stress examples |
| Content guidance | Copy length or formatting materially affects the component | Good/bad examples using realistic copy |
| Usage | The component has a clear product decision boundary | Concise “Use when / Avoid when” guidance with a visual example when helpful |
| Accessibility | Contrast, focus, target size, labels, or semantics are visible or specified | Verified facts plus an explicit implementation-verification note where needed |
| Tokens | Actual variables or styles are bound or documented | Grouped, scannable token list; retain exact names |
| Open decisions | A missing definition blocks consistent use | One compact callout listing the decision and consequence |

Rules for sparse evidence:

- No exposed properties: say so in one line; do not make a mostly empty table.
- No defined states or variants: omit the matrix and list the gap only if it matters.
- No token bindings: do not manufacture a token register from raw colors.
- Several open questions: group them in one “Needs definition” callout, not a full section of speculative cards.

## 3. Compose a documentation page, not a stack of templates

Use the file’s existing documentation components, tokens, styles, and grid when available. Reuse published components or existing page patterns before drawing replacements. If the file has no documentation system, create simple Auto Layout containers and establish a small, consistent structure only within the requested documentation scope.

Make the component the visual focus:

- Lead with a showcase large enough to read at normal desktop zoom. Show the component in a plausible context when relationship matters. For example, a tooltip must visibly relate to its trigger, not float alone in a blank card.
- Use a different composition for different information types: comparison for alternatives, callouts for anatomy, a table for configuration, and an applied example for usage. Do not repeat a fixed “text on the left, grey rectangle on the right” formula for every section.
- Size examples from their contents. Do not give a small specimen a large empty canvas merely to keep sections visually uniform.
- Use cards only to group a concrete example, comparison, or decision. A card must earn its border or background.
- Keep the reading order obvious: overview and showcase first; configuration and behavior next; guidance, tokens, and unresolved decisions last.

Use Auto Layout for related content. Prefer content-driven heights and correct Hug/Fill behavior. Use a consistent outer grid and alignment, but allow a section to be compact when its information is compact.

## 4. Visual direction

Aim for the confidence of a mature product design system: calm, precise, and intentionally edited.

- Establish three clear text levels: page title, section title, and readable body/spec text. Labels may be smaller, but must remain legible at the page’s intended viewing size.
- Use restrained contrast to separate structural labels, body copy, data, and interactive examples. Avoid low-contrast microcopy.
- Keep white space purposeful: space should clarify grouping, not compensate for missing content.
- Use one coherent surface, border, radius, and elevation treatment. Do not mix several unrelated card styles.
- Keep decoration subordinate to information. Avoid gradients, hero-style marketing treatments, oversized shadows, decorative illustrations, and arbitrary accent colors.
- Use real component instances, variables, styles, and icons where the design system provides them. Do not redraw an existing component as approximate primitives.

The result should feel edited by a product designer: compact where it can be compact, visually explicit where words would be ambiguous, and quiet everywhere else.

## 5. Write useful documentation copy

Use direct, specific language. Prefer a verified rule over a broad explanation.

Good:

> The label grows with its content while preserving horizontal padding.

Weak:

> This versatile component can be used in many contexts.

For each claim, make the evidence clear in the visual or nearby copy. Use realistic product text for examples, including a long-content or localization example only when it tests a real constraint. Keep Do/Don't examples focused on one rule; the contrast between the two examples should be visible without reading a paragraph.

For developer handoff, state design requirements and observed constraints. Do not prescribe a framework, DOM structure, or API unless supplied by the source.

## 6. Build and verify

1. Build the page or the requested documentation section using the selected plan.
2. Return or record the affected node IDs and key structural evidence after each meaningful mutation.
3. Capture a screenshot of the complete documentation scope.
4. Review it at a readable scale for hierarchy, balance, alignment, component prominence, clipping, overlapping content, and empty/overbuilt sections.
5. Apply targeted fixes only to the defects found, then capture one updated screenshot. Stop after the page passes; do not churn through decorative alternatives.

Before finishing, confirm:

- all property, variant, token, and style names are exact;
- claims about states, behavior, responsiveness, and accessibility are evidenced or explicitly qualified;
- the main specimen is legible and contextually meaningful;
- sections vary by information need rather than repeating one visual template;
- no placeholder text, empty table, oversized demonstration area, clipping, or overlapping content remains;
- the documentation works without requiring the reader to inspect the source component.

## Final standard

Optimize in this order:

1. Actual system behavior
2. Clear visual explanation
3. Readable hierarchy and density
4. Consistency with the existing design system
5. Decoration

When information is missing, preserve the uncertainty. A concise **Needs definition** note is more professional than a polished fiction.
