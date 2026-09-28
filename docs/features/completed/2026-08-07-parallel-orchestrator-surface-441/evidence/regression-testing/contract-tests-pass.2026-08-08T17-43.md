# Contract Tests Pass — P4-T8

Timestamp: 2026-08-08T17-43

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -v`

EXIT_CODE: 0

Output Summary:

- Collected 36 test items; 36 passed, 0 failed, 0 errored, 0 skipped, 0 xfailed.
- Runtime 0.09s. Platform win32, Python 3.13.12, pytest 9.0.2.
- Test file: `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
  (457 lines). Helper modules:
  `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py` (465 lines)
  and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
  (253 lines). Every file is within the 500-line limit (P4-T7).

## Coverage of Phase 4 Task Groups

| Task | Test items | Result |
| --- | --- | --- |
| P4-T1 existence and frontmatter | 8 | pass |
| P4-T2 ordered headings and reserved sections | 5 | pass |
| P4-T3 kickoff section (section-scoped) | 5 | pass |
| P4-T4 behavioral text plus 3 producer/consumer seam checks | 13 | pass |
| P4-T5 prescriptive-literal negatives | 3 | pass |
| P4-T6 frozen epic-surface hash pinning | 2 | pass |

## Frozen-Surface Hash Re-Verification (P4-T6 pin source)

Both pinned digests still equal the current file content:

- `.claude/agents/epic-orchestrator.md` =
  `f4e3589ab53e6a61791f2d31e7506e7e6003ec63fe651f3cec323023d923f250` (matches
  the P0-T6 baseline).
- `.claude/skills/epic-orchestrate/SKILL.md` =
  `3c2e38bd5bdc5e2b7312437d47dc27aa282f2ff24fbaf01590b51e853e788d68` (matches
  the P0-T6 baseline).
- `.claude/skills/orchestrate/SKILL.md` =
  `b4e4c26fc5597af9499e43497ea013cf4780faaac14009e2bcf44946cde3402c` (matches
  the P0-T6 baseline; not pinned in-test per the P4-T6 task text, verified by
  P5-T1).

## Producer/Consumer Seam Coverage

Three seam tests bind the producer prescription in
`.claude/skills/parallel-orchestrate/SKILL.md`
`## Documentation Maintenance Boundaries` to the consumer template
`docs/features/templates/parallel/parallel-status.md`. Each parses the
prescribed names out of the producer section at run time rather than restating
them, so a one-sided rename fails:

- `test_seam_status_template_realises_header_fields_prescribed_by_skill` —
  parsed `('parallel_slug', 'mode', 'max_concurrency', 'current_cohort',
  'recolor_generation', 'last_updated')`.
- `test_seam_status_template_realises_cohort_columns_prescribed_by_skill` —
  parsed `('index', 'generation', 'item_keys')` and required one template table
  header row to carry all three.
- `test_seam_status_template_realises_projections_prescribed_by_skill` —
  parsed `('## Conflict Edges', '## Mutations', '## Drift Events')`.

Divergence sensitivity was verified in memory (no repository file modified) by
feeding the parsers a mutated copy of the producer section: renaming
`recolor_generation`, `item_keys[]`, and `## Drift Events` on the producer side
left each name unbound in the consumer template, which is the failing condition
each seam test asserts against.

## Supporting Toolchain Results (scoped to the new files)

- `poetry run black <3 new files>` — 3 files left unchanged.
- `poetry run ruff check tests/scripts/dev_tools/` — All checks passed.
- `poetry run pyright <3 new files>` — 0 errors, 0 warnings, 0 informations.

The unconditional repository-wide QC loop remains Phase 6 (P6-T1 through P6-T5).
