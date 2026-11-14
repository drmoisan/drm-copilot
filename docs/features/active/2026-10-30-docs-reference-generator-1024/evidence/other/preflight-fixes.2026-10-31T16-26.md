# Preflight Fixes - docs-reference-generator (1024)

Timestamp: 2026-10-31T16-26
Plan: docs/features/active/2026-10-30-docs-reference-generator-1024/plan.2026-10-30T16-54.md
Cycle: plan version 3.0 (reconciliation revision under owner decision P2), single-pass preflight

## Fixes

1. Task: [P6-T4]
   - Defect class: literal omission against the covered criterion (AC-10 states that a `ReadText` exception other than absence exits 3 with one stderr line; the task listed the exit code, finding and `result` only).
   - Change: the `ReadText` exception case now also lists `one stderr line`, matching the AC-10 text and the parallel `WriteText` exception case of the same task. The assertion meaning of AC-10 is unchanged.

2. Task: [P9-T8]
   - Defect class: literal-formatting ambiguity in a search assertion.
   - Change: the CON-1 patterns `r[g]f` and `fore[c]ast` are stated to be applied as regular expressions, not fixed strings. A fixed-string search would match the bracketed spellings that this plan and its evidence carry, and the zero-match acceptance condition would then be unsatisfiable. The asserted outcome (zero matches of the forbidden tokens) is unchanged.

3. Heading: `### Phase 9 — Final QA Loop and Closure` (QA loop rule)
   - Defect class: validator-blind ordering gap that keeps the assertion meaning.
   - Change: the loop rule now states that when a loop pass changes a NEW-MODULES file or `LIB/Invoke-DocsCommand.ps1` (for example a formatter change in [P9-T1] after the [P8-T1] copy), the `BUNDLE` copy is refreshed and the [P8-T1] and [P8-T3] evidence is rewritten before the restart. Without this, the AC-19 evidence could describe bytes that no longer match the final source. No task is added, removed or reordered.
