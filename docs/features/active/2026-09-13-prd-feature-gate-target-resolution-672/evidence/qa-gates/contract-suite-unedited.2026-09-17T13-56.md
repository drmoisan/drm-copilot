# Remediation gate 3, first half — the PreToolUse schema contract suite passes unedited

Timestamp: 2026-09-17T13-56

Task: `[P4-T6]` of `remediation-plan.2026-09-17T12-29.md`
Criterion this protects: criterion 23 (`spec.md` line 642), which requires
`tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` to pass **unedited**.

Command:

- **C4** against the contract suite:
  `Import-Module Pester -MinimumVersion 5.0.0 -Force; $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1' -PassThru; $r.TotalCount; $r.PassedCount; $r.FailedCount`
- `git merge-base --is-ancestor 1b150689c2d6bbda848ae10ec92e4ccc018a5560 HEAD`
- `git diff --name-only 1b150689c2d6bbda848ae10ec92e4ccc018a5560`
- `git status --porcelain --untracked-files=all`

EXIT_CODE: 0

- `Invoke-Pester` host exit code: **0**
- `git merge-base --is-ancestor` exit code: **0**
- `git diff --name-only` exit code: **0**
- `git status --porcelain --untracked-files=all` exit code: **0**

Anchor precondition: `<baselineHead>` is bound to `1b150689c2d6bbda848ae10ec92e4ccc018a5560`, the commit
`[P0-T2]` recorded. The ancestry check exits 0, so the halt branch stated in `[P1-T5]` is not taken.

Output Summary:

## Suite result

| metric | value | required |
| --- | --- | --- |
| `TotalCount` | **15** | 15 |
| `PassedCount` | **15** | 15 |
| `FailedCount` | **0** | 0 |

The suite needed no edit, as the plan's consequence 3 predicted: its prd-feature case uses the prompt
`plan something generic`, which carries no feature-folder token, no absolute path, and no branch, so
`Resolve-WorktreeCallTarget` returns `NoTarget` and the decision is the same deny shape as before the
pre-filter was removed.

## Both enumerations — required, and neither substitutes for the other

The two mechanisms are complementary and each alone is wrong in one state: the anchored diff enumerates
tracked changes only and cannot report a file this remediation creates, and porcelain status goes empty once a
change is committed. Both are recorded.

### Anchored name-listing diff — 31 paths

`git diff --name-only 1b150689c2d6bbda848ae10ec92e4ccc018a5560` reported **31** paths. Grouped:

**7 source files — the complete intended change set:**

1. `.claude/hooks/enforce-prd-feature-before-planner.ps1`
2. `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`
5. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
6. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
7. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`

**24 documentation and evidence paths**, all under
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/`: the plan file with its checkbox
transitions, `spec.md` with the two acceptance-criterion checkbox changes, and 22 evidence artifacts.

No other source path appears. The change set contains no file outside the 7 the plan's batch table declares.

### Porcelain status — 5 paths, all untracked evidence

```
?? docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/failure-set-equality.2026-09-17T13-56.md
?? docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-analyze.2026-09-17T13-56.md
?? docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-delivery-tests.2026-09-17T13-56.md
?? docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-format.2026-09-17T13-56.md
?? docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-test.2026-09-17T13-56.md
```

All five are Phase 4 evidence artifacts written after the Phase 3 work-preservation commit. No tracked source
file is listed as modified, which independently confirms the `[P4-T1]` finding that the formatter changed
nothing and that no Phase 4 step altered a tracked file.

## Guarded-name checks over both enumerations

Each name was searched in the anchored diff list and in the porcelain list:

| guarded name | occurrences in the anchored diff | occurrences in porcelain status |
| --- | --- | --- |
| `PreToolUseSchema.Contract.Tests.ps1` | **0** | **0** |
| `enforce-orchestration-preimplementation-gate` | **0** | **0** |
| `enforce-epic-merge-gate` | **0** | **0** |
| `enforce-pr-author-skill` | **0** | **0** |
| `enforce-epic-wave-barrier` | **0** | **0** |
| `.codex/` | **0** | **0** |

The first row is this task's acceptance: neither the anchored name-listing diff nor the porcelain status names
`tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, so the suite passed unedited rather than
passing because it was adjusted.

The remaining five rows discharge the plan's deviation-protocol prohibition, which forbids this remediation
from editing `.claude/hooks/enforce-pr-author-skill.ps1`,
`.claude/hooks/enforce-epic-wave-barrier.ps1`, their suites, any `.codex/` path, or any file matching
`enforce-orchestration-preimplementation-gate` or `enforce-epic-merge-gate`. All are absent. Rows 4 and 5 are
also what establish that the two baseline failures recorded by `[P4-T5]` are inherited rather than caused:
neither of their suites, and neither hook, is in the change set.

`[P4-T7]` reads the `enforce-orchestration-preimplementation-gate` and `enforce-epic-merge-gate` rows from
this enumeration.

Acceptance: the suite reports 15 total, 15 passed, 0 failed, and neither enumeration names
`tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`. Both enumerations and the ancestry check
are recorded with all three exit codes. Satisfied.
