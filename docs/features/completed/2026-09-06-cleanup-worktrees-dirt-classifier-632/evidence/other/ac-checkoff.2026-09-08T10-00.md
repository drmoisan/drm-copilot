# AC check-off — AC-46 and AC-47 (P5-T10)

Timestamp: 2026-09-08T10-00
WorkingDirectory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ac72d35e7980bc69d`
AC source (work mode `full-bug`): `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`,
`## Acceptance Criteria` section only.

## What was checked off

`spec.md:850` AC-46 and `spec.md:856` AC-47 were changed from `- [ ]` to `- [x]`. Only the checkbox
characters changed; neither criterion's text was modified.

## Evidence supporting each criterion

**AC-46** — rung 4's tracked half resolves `CONTENT_ON_MAIN` only when the path is present in
`main`, so an `AD` entry whose content exists only as a staged blob is `UNIQUE` and its worktree is
`HAS_UNIQUE`, with both directions pinned by one checked-in fixture.

- Fail-before: `evidence/regression-testing/fail-before-rung4-path-in-main.2026-09-08T08-00.md`
- Pass-after: `evidence/regression-testing/pass-after-rung4-path-in-main.2026-09-08T08-00.md`
- Both directions in one fixture: `tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_staged_only_blob/`,
  carrying the `AD staged_only.md` entry and the `M  docs/tracked.md` entry, pinned by the two
  tests recorded in `evidence/qa-gates/shell-qc-test.2026-09-08T10-00.md` as `ok 306` and `ok 307`.

**AC-47** — the guard enumeration, the registry under (`id`, `mutation`) row identity, the
semantic-mutation constraint, the six gate obligations, the three row kinds asserting both the
difference and the identity they name, the scenario-scoping of `EXEMPT`, and the eighteen pinned
rows over seventeen ids.

- Fail-before: `evidence/regression-testing/fail-before-guard-separation.2026-09-08T08-30.md`
- Pass-after: `evidence/regression-testing/pass-after-guard-separation.2026-09-08T09-00.md`
- Registry design and derivation: `evidence/other/guard-registry-design.2026-09-08T08-30.md`
- Row classification: `evidence/qa-gates/guard-registry-classification.2026-09-08T08-30.md`
- Marker-addition neutrality: `evidence/regression-testing/marker-pass-neutral.2026-09-08T08-30.md`
- Gate green in the full local stage: `evidence/qa-gates/shell-qc-test.2026-09-08T10-00.md`,
  `ok 310`, `ok 311` and `ok 312`.

## Counts, section-scoped

Both counts use the derivation P4-T4 fixes. An unscoped count is not the criterion count, because
eight checkboxes sit outside the section.

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \['`
EXIT_CODE: 0
SectionScopedTotal: 47

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \[x\]'`
EXIT_CODE: 0
SectionScopedChecked: 47

Command: `grep -c '^- \[ \] AC-4' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
EXIT_CODE: 1
Result: 0

`grep -c` exits 1 when it reports a count of zero, which is the expected shape for an assertion that
demands `0`; the reported count is the value the acceptance names.

## Output Summary

Section-scoped total 47, section-scoped checked 47, unchecked 0. No `AC-4x` box remains unchecked.
Acceptance met.
