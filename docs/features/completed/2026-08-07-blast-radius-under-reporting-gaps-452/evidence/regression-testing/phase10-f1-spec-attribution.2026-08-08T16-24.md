# [P10-T5] F1 specification amendment is traceable to issue #452

Timestamp: 2026-08-08T16-24
Task: [P10-T5]

Command: `rg -n "issue #452" docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md`

EXIT_CODE: 0

## Output Summary

Total hits: **5**, against the required minimum of 2.

| Line | Region | Task | What it attributes |
| ---: | --- | --- | --- |
| 42 | `### Derivation heuristic details`, **Path extraction** bullet | [P10-T1] | separator-free tokens that are exact members of the configured `shared_surfaces` list are now accepted; that list is the sole source of separator-free acceptance |
| 53 | `### Behavior semantics` list | [P10-T3] | listed-directory semantics are honoured symmetrically by V1 and by `conflicts`; the over-report when a concrete entry is a file is the accepted fail-closed direction |
| 95 | `## Public API Contract`, Python surface block | [P10-T4] | the keyword-only `root_surfaces` parameter on `extract_plan_paths` |
| 121 | `conflicts` semantics list, `path_overlap` bullet | [P10-T2] | the concrete×concrete listed-directory prefix clause and the glob×concrete literal-prefix nest clause |
| 133 | `### PowerShell surface` list | [P10-T4] | the `-RootSurface` parameter on `Get-PlanPaths` |

The two required regions are both present:

- **Line 42 region** — hit at line 42, the amended Path extraction bullet. The line number is
  unchanged from the pre-amendment document because the amendment is an in-place edit of that
  single bullet.
- **Line 118 region** — hit at line 121, the amended `path_overlap` bullet. It sits at 121 rather
  than 118 because the [P10-T3] behaviour-semantics bullet added one line above it and the
  [P10-T4] Python signature block added two.

## Preserved text

- The pre-existing separator-bearing acceptance rule at line 42 is preserved verbatim: the
  known-top-level-segment list and the `<segment>/.../<name>.<ext>` clause are unchanged, and the
  `Tokens containing *` sentence still closes the bullet. The amendment is additive.
- The glob×glob sentence at line 121 is byte-identical to its pre-change form:
  "Glob×glob: **any pair not provably disjoint counts as overlapping** — the implementation may
  use a conservative shared-literal-prefix test, and when it cannot decide, it returns overlap.
  This is the fail-closed clause made concrete."
- Exactly one bullet was added to the `### Behavior semantics` list. The five pre-existing bullets
  at lines 48-52 are unmodified.

Output Summary: 5 hits for the literal string `issue #452`, covering both required regions — one
at the amended line 42 and one at the amended line-118 region (now line 121) — plus three further
attributions on the behaviour-semantics bullet and the two surface blocks.
