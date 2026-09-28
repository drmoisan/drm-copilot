# Baseline — scenario, record and criterion counts

Timestamp: 2026-09-09T00-00

Task: [P0-T9]

Every command below was run with an absolute path to its target rather than a
repository-relative path, because this session's Bash permission layer refuses a `cd`-chained
file-reading command. The commands, their flags and their targets are otherwise unchanged.

Command: `find tests/fixtures/cleanup_worktrees/scenarios -maxdepth 1 -type d -name 'dirt_*' | wc -l`
EXIT_CODE: 0

Command: `sed -n '253p' tests/shell/test_cleanup_worktrees_dirt_classify.bats`
EXIT_CODE: 0

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \['`
EXIT_CODE: 0

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \[x\]'`
EXIT_CODE: 0

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \[ \]'`
EXIT_CODE: 1 (`grep -c` returns 1 when its count is zero; the printed count is `0`)

Command: `grep -c '^- \[' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
EXIT_CODE: 0

## Measured values

OnDiskScenarioCount: 28

AssertedRecordTotal: 34

Read from `tests/shell/test_cleanup_worktrees_dirt_classify.bats:253`, which reads verbatim:

```
    [ "$seen" -eq 34 ]
```

SectionScopedCriterionTotal: 47

SectionScopedChecked: 47

SectionScopedUnchecked: 0

UnscopedCheckboxTotal: 55

## Why the unscoped figure is not the criterion count

`grep -c '^- \['` over the whole of `spec.md` reports **55**. That figure is **not** the
acceptance-criterion count and must not be used as one. Eight checkboxes in the file sit
outside the `## Acceptance Criteria` section, so the unscoped count over-reports by exactly
eight: 55 - 47 = 8. The authoritative derivation is the section-scoped one, which begins after
the line `## Acceptance Criteria` and stops at the next line beginning `## `, and it reports
47.

The same distinction applies to the end state this cycle produces. Two criteria are added
(AC-48 and AC-49), so the section-scoped total becomes 49 and the unscoped figure becomes 57.
Neither unscoped figure is a criterion count.

Output Summary: 28 `dirt_*` scenario directories on disk; the classify suite asserts a record
total of 34; `spec.md` carries 47 acceptance criteria in its `## Acceptance Criteria` section,
all 47 checked and 0 unchecked; the unscoped whole-file checkbox count is 55 and is recorded
here only to state that it is not the criterion count.
