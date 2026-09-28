---
name: update-doc
description: Synchronize existing Figma design-system documentation with its current source component while preserving authored guidance and reporting only meaningful documentation changes. Use for targeted documentation maintenance, not redesign or full regeneration.
---

# Update Documentation

Synchronize an existing Figma documentation scope with the current source component or component set. The aim is a trustworthy, minimal update: source-derived facts stay current, useful human knowledge stays intact, and ambiguity is visible rather than silently resolved.

Do not rebuild the documentation page, restyle it, or change the source component unless the user explicitly asks. Synchronization is a content-and-reference maintenance task, not a redesign task.

## Operating principles

- Treat the current source component as authoritative for observable structural facts: component/variant/property names, bound variables and styles, anatomy that affects use, and defined layout/state evidence.
- Treat documentation as potentially authoritative for product rationale, usage guidance, content rules, accessibility/engineering notes, decisions, and migration history.
- Update only facts that are proven stale or facts newly supported by the source. Preserve wording and layout that remain valid.
- Never translate uncertainty into a definitive change. Use **Review required** or **Needs definition** with a concise reason.
- Keep every update traceable to both the source evidence and the documentation location it changes.

## 1. Resolve the source–documentation relationship

Before editing, identify the source and the exact documentation scope using explicit links, component references, metadata, names, instances, or nearby established page conventions.

Confirm all of the following:

- source node and type (main component, component set, instance, or pattern);
- documentation root and its intended source relationship;
- whether the selected documentation is a complete page or a bounded section;
- comparable documentation convention only when it helps preserve the existing pattern.

If the relationship is ambiguous, do not modify the documentation. Report **Blocked — source relationship needs confirmation** and state the candidates or missing link.

## 2. Inspect both sides before planning a change

Capture the current source facts that can materially affect documentation:

- component hierarchy, exposed properties, variant axes/values/defaults, nested instances, and meaningful states;
- layout mode, sizing, padding, gap, wrapping, constraints, and content limits;
- bound variables, styles, typography, colors, borders, radius, effects, and icons;
- existing interaction/prototype evidence only when present.

Read the existing documentation in context. Classify each relevant claim or block as:

- **Source fact** — directly derived from the component;
- **Authored guidance** — intentionally written product, content, accessibility, engineering, or migration knowledge;
- **Mixed** — combines a source fact with authored interpretation;
- **Unknown provenance** — origin cannot be determined from the scope.

Do not infer responsive behavior, runtime behavior, accessibility implementation, or business rules from visual structure alone.

## 3. Build a change manifest

Compare the source facts with their associated documentation claims. A manifest entry is required before a canvas change.

| Change type | Use only when | Documentation action |
| --- | --- | --- |
| Added | A new source fact has a clear place in the existing documentation | Add the smallest matching fact/example |
| Removed | A documented source fact is no longer present | Remove or mark obsolete generated content; protect authored interpretation |
| Modified | The same observable fact has a changed value or behavior | Update the specific claim/table/example |
| Renamed | Identity is confirmed by a stable reference or clear one-to-one continuity of type, role, and context | Update the name and cross-references without needless reordering |
| Unchanged | No meaningful reader-facing difference | Do not touch it |
| Uncertain | Relationship, identity, provenance, or consequence is unclear | Do not silently change it; add a review marker only when useful |

Do not call something a rename because the label happens to be similar. Without continuity evidence, record separate Added and Removed facts or mark it Uncertain.

For each proposed change, record:

1. source evidence (node/property/variant/token/style);
2. documentation location and claim affected;
3. whether the block is source fact, authored guidance, mixed, or unknown;
4. the smallest safe action; and
5. whether the change can invalidate usage, engineering, accessibility, or migration guidance.

Ignore layer-order moves, selection changes, and other implementation-only Figma edits that do not change a reader-facing fact.

## 4. Decide what is safe to update

Apply source-driven updates directly when the documentation block is a source fact and the mapping is unambiguous. Typical examples are property names/values, variant names, visible anatomy, bound token references, sizing facts, and component instances used as examples.

Protect authored guidance by default. If a source change could make it misleading, retain the guidance and add a local **Review required** note that names the conflicting source change. Do not delete or rewrite product rationale, usage rules, writing guidance, accessibility notes, engineering notes, limitations, decisions, or migration history simply because the component does not contain that information.

For mixed blocks, update only the factual portion. Keep the authored interpretation unless it is clearly invalidated, in which case flag it for review.

When a needed new rule cannot be determined, use **Needs definition**. Do not fill the page with a guessed state, breakpoint, API, token replacement, or accessibility claim.

## 5. Update with minimal visual disturbance

Make only the manifest-approved changes. Preserve page structure, section order, documentation components, grid, spacing, typography, and working examples unless one is directly affected by the source change.

Apply the appropriate narrow update:

- **Property/variant change:** update the row, label, default, comparison cell, and direct cross-references only.
- **Anatomy change:** amend relevant callouts; preserve numbering where possible and avoid exposing internal-only layers.
- **Token/style change:** replace the actual reference; if the source became a raw value, report the token gap rather than inventing a replacement.
- **Layout change:** update only observable user- or implementation-relevant rules, such as Fixed/Hug/Fill, direction, wrapping, spacing, or min/max constraints.
- **State change:** update source-derived state examples; retain authored guidance and mark it for review if it refers to a removed state.
- **Example instance change:** preserve purposeful content, but ensure the instance/variant/property still represents the documented rule.

Return the affected documentation node IDs and the corresponding manifest entries after each meaningful update. Do not touch unrelated sections for visual consistency alone.

## 6. Verify the synchronization

After updating:

1. Re-read the changed claims, examples, and cross-references against the current source.
2. Capture a screenshot of the changed documentation scope at a readable scale.
3. Check for stale names, invalid references, clipped or overlapping content, outdated component instances, and disrupted local layout.
4. Make a targeted correction only if the verification exposes a defect. Do not iterate on cosmetic alternatives.

Verify explicitly that human guidance remains present unless it was knowingly changed with user authorization.

## 7. Report only meaningful results

Finish with a **Documentation update summary**:

- **Updated** — modified facts, with old → new wording where useful.
- **Added** — newly documented source facts.
- **Removed** — obsolete source-derived documentation that was removed.
- **Review required** — authored or uncertain material potentially affected by a source change.
- **No change** — state this plainly when source and documentation are already aligned.

Attach a documentation impact level to each reported change when it helps prioritization:

- **Breaking** — existing usage or implementation guidance may now be invalid.
- **Significant** — a reader-facing rule or configuration meaningfully changed.
- **Minor** — a contained factual update with no expected downstream behavior change.

Then set exactly one completion status:

- **Synced** — all mapped source facts are current and no documentation-impacting conflicts remain.
- **Synced — review required** — source facts are current, but authored or ambiguous material needs an owner decision.
- **Blocked** — a source/documentation relationship or required evidence could not be determined safely.

Never report **Synced** when a material review item remains.

## Final check

Before finishing, confirm that the change manifest supports every edit, the selected source relationship is still valid, no unsupported behavior was introduced, and no unrelated documentation was overwritten. The best sync is often a small diff with a clear reason for every line changed.
