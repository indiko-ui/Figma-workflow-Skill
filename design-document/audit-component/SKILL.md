---
name: audit-component
description: Audit selected Figma components, component sets, patterns, or bounded UI sections for design-system readiness before documentation or engineering handoff. Use for evidence-based review, not redesign or automatic cleanup.
---

# Audit Component

Audit the selected Figma scope to surface the decisions that could cause incorrect use, fragile implementation, inconsistent scaling, or misleading documentation. The result is a concise, evidence-led review that helps the owner decide what to fix, define, or intentionally leave alone.

This is a review skill. Do not edit, rename, detach, delete, re-tokenize, or redesign the source unless the user explicitly asks for a follow-up change.

## Operating principles

- Audit the selected component or UI scope, not the entire file. Inspect nearby components only to establish an actual convention or identify a concrete dependency.
- Treat the existing design system as the reference point. Do not use generic industry patterns as a hidden standard.
- Separate what is observed from what is inferred. A missing state or token is not automatically a defect.
- Report only findings that affect use, implementation, consistency, maintenance, accessibility readiness, or trustworthy documentation.
- Cite the exact node, property, variant axis/value, variable/style, or visual scenario that supports each finding.
- Preserve uncertainty. Use **Needs definition** when evidence is insufficient; do not replace it with a recommendation disguised as a fact.

## 1. Establish the audit scope

Before evaluating, confirm:

- the selected node, its type, and whether it is a main component, component set, instance, pattern, or ordinary UI frame;
- the property owner for a variant or instance; do not mistake an instance override for a component capability;
- the parent component set, relevant variants, nested components, and exposed properties;
- bound variables, styles, layout mode, sizing rules, constraints, and effects;
- one or two comparable components or existing documentation examples, when they exist.

Record the scope in one sentence. If the selection is only a fragment of a larger component, state which conclusions are out of scope rather than auditing absent information.

## 2. Build an evidence map before finding issues

Inspect the relevant evidence efficiently instead of walking every possible checklist item:

| Evidence area | Inspect when relevant | What it can establish |
| --- | --- | --- |
| Component API | Variants, booleans, text, instance swaps, nested properties | Meaningful configuration, naming, defaults, duplicate dimensions |
| Structure and layout | Hierarchy, Auto Layout, absolute layers, Hug/Fill/Fixed, padding, wrapping | Maintainability and resilience under content or container changes |
| Visual comparison | Representative variants, states, and comparable components | Unintended drift in alignment, typography, icon size, color, or dimensions |
| Tokens and styles | Bound variables/styles plus nearby system equivalents | Tokenized, intentional raw value, or unresolved value |
| Interaction evidence | Defined state variants, prototypes, annotations, or existing docs | What is actually specified versus still undefined |
| Content stress | Long/short copy, optional children, localization, values, narrow containers | Fragility that follows from the observed layout |
| Accessibility signals | Visible focus, contrast, labels, target affordance, non-color cues | Design-level risks and items requiring implementation verification |

Do not claim a test occurred when it did not. For example, call a long-label result a **layout inference** unless it was inspected in a real or deliberately duplicated stress case.

## 3. Evaluate only the applicable audit dimensions

Use the following dimensions as a decision guide, not as mandatory sections. Omit dimensions that do not apply.

### Component API and variants

Check whether property names, values, defaults, and variant axes are understandable, conceptually distinct, and consistent with the local system. Flag a variant matrix only when there is evidence of duplication, contradictory axes, missing meaningful combinations, or variant explosion.

Recommend a property-versus-variant change only as an option, and explain the implementation or maintenance consequence. Never rename or restructure automatically.

### Structure and layout resilience

Look for wrappers, hidden layers, absolute positioning, and sizing choices that could break a real content scenario. Pay particular attention to nested Auto Layout, optional children, text wrapping, and a component placed in both narrow and wide parents.

State the exact scenario and mechanism: for example, “the label is Fixed-width inside a horizontal Auto Layout row, so a localized label can overlap the trailing action.” Avoid ungrounded statements such as “layout could improve.”

### Tokens, styles, and visual consistency

Classify each relevant observation carefully:

- **Tokenized** — an appropriate existing variable or style is bound.
- **Intentional raw value** — a literal value is present, but no applicable system token was found or the component context justifies it.
- **Potential token gap** — a raw value conflicts with a known applicable local token or lacks a documented rationale.
- **Unresolved** — the available scope does not establish whether a suitable token exists.

Compare only states or variants that should remain visually aligned. Do not report stateful differences as drift when they clearly signal hierarchy or status.

### Behavior, content, and accessibility readiness

Review states, interaction behavior, content resilience, and accessibility only when the component's purpose makes them relevant. Separate visible design evidence from code-dependent behavior.

Use **Requires implementation verification** for keyboard handling, ARIA/semantics, screen-reader announcements, actual focus order, and dynamic runtime behavior. Do not claim WCAG compliance from a Figma inspection alone.

## 4. Classify findings by decision urgency

Use one of these classes for each finding. Do not manufacture findings to fill a class.

| Class | Use when | Expected next action |
| --- | --- | --- |
| Critical | Likely to cause broken behavior, incorrect usage, material accessibility risk, or misleading engineering handoff | Resolve before publishing or relying on the component |
| Important | Creates a real consistency, resilience, or maintenance cost without an immediate break | Plan a targeted correction or confirm the exception |
| Improvement | A non-blocking enhancement with a clear benefit | Consider when the component is next touched |
| Needs definition | A rule, state, ownership boundary, or usage decision cannot be inferred reliably | Assign an owner to define it; do not guess a solution |

If a concern is only a preference, omit it. A compact audit with three meaningful findings is stronger than a long list of weak observations.

## 5. Write each finding for action

Every finding must include the following, in this order:

1. **Issue** — one precise sentence.
2. **Evidence** — the exact Figma reference and observed condition.
3. **Impact** — the user, implementation, or maintenance consequence.
4. **Recommendation** — a proportionate next action; state when confirmation is needed first.

Example:

> **Important — Label can collide with the trailing action**  
> **Evidence:** `Button / Primary`, variant `Size=Small`, uses a Fixed-width label in a horizontal Auto Layout row; the trailing icon has no shrink strategy.  
> **Impact:** Longer localized labels can obscure the action hierarchy.  
> **Recommendation:** Validate the intended long-label behavior. If wrapping is allowed, make the label occupy the remaining row width; otherwise define truncation and the maximum content length.

Never present a speculative solution as a verified requirement.

## 6. Produce a decision-ready report

Return the report in this order:

1. **Scope** — selected node and audit boundary.
2. **Summary** — one short paragraph: the main strengths, the highest-risk issue, and whether the component can proceed.
3. **Findings** — grouped by class, Critical first. Omit empty groups.
4. **Verified strengths** — at most three concrete, relevant observations; omit this section when it adds no decision value.
5. **Documentation readiness** — one status plus the reason:
   - **Ready**: purpose, configuration, layout behavior, and relevant system references are sufficiently evidenced.
   - **Ready with notes**: documentation can proceed if identified gaps are visibly marked.
   - **Not ready**: unresolved items would cause documentation to state or imply unreliable rules.
6. **Suggested next actions** — the smallest ordered set of decisions or fixes that unblocks the owner.

When the user asks to place the audit in Figma, add it only in the nominated documentation area or immediately beside the selected scope. Do not alter the audited component itself.

## 7. Finish with a quality check

Before returning the audit, verify:

- every finding names observable evidence rather than a general preference;
- severity reflects consequence, not the number of issues found;
- token claims distinguish a confirmed mismatch from an unknown library search result;
- accessibility language distinguishes design evidence from implementation verification;
- the report states what was not inspected when that limits a conclusion;
- no automatic changes were made.

The audit is complete when it gives the component owner a defensible next decision. It does not need to diagnose every theoretical edge case.
