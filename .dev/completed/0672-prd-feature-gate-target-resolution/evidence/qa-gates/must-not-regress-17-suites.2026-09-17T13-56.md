# Remediation gate 3, second half — the 17-suite must-not-regress batch

Timestamp: 2026-09-17T13-56

Task: `[P4-T7]` of `remediation-plan.2026-09-17T12-29.md`
Criteria this protects: criterion 17 (`spec.md` line 636), the pre-implementation gate's restrictions, and
criterion 18 (line 637), the epic merge gate's matcher.

Command, **C5**:
`Import-Module Pester -MinimumVersion 5.0.0 -Force; $files = @(Get-ChildItem -Path tests -Recurse -File -Filter '*.Tests.ps1' | Where-Object { $_.Name -like 'enforce-orchestration-preimplementation-gate*' -or $_.Name -like 'enforce-epic-merge-gate*' } | ForEach-Object { $_.FullName }); $files.Count; $r = Invoke-Pester -Path $files -PassThru; $r.TotalCount; $r.PassedCount; $r.FailedCount`

EXIT_CODE: 0

Output Summary:

## Enumerated file count

**17**, as the plan's C5 derivation states. The glob is mechanical, so a third party re-running it obtains the
same set. The 17 files, grouped as the plan's derivation groups them:

**`tests/scripts/claude-hooks/` — 10 files**

`enforce-epic-merge-gate*` family, 4:

1. `enforce-epic-merge-gate.Authorization.Tests.ps1`
2. `enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`
3. `enforce-epic-merge-gate.Tests.ps1`
4. `enforce-epic-merge-gate.TriggerScoping.Tests.ps1`

`enforce-orchestration-preimplementation-gate*`, 6:

5. `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`
6. `enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`
7. `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
8. `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
9. `enforce-orchestration-preimplementation-gate.Tests.ps1`
10. `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`

**`tests/scripts/codex-hooks/` — 7 files**

`enforce-epic-merge-gate*` family, 3:

11. `enforce-epic-merge-gate-authorization.Tests.ps1`
12. `enforce-epic-merge-gate-decision-surface.Tests.ps1`
13. `enforce-epic-merge-gate-trigger-scoping.Tests.ps1`

`enforce-orchestration-preimplementation-gate*`, 4:

14. `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
15. `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
16. `enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1`
17. `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`

The measured grouping is 6 preimplementation-gate and 4 epic-merge-gate suites under `claude-hooks/`, plus 4
and 3 respectively under `codex-hooks/`, which reproduces the plan's C5 derivation exactly.

## Results

| metric | value | expected |
| --- | --- | --- |
| enumerated file count | **17** | 17 |
| `TotalCount` | **556** | 556, as the feature audit recorded |
| `PassedCount` | **556** | equal to `TotalCount` |
| `FailedCount` | **0** | 0 |

`TotalCount` equals `PassedCount` at 556, and `FailedCount` is 0. No failing test was reported, so no failure
name is recorded.

The observed `TotalCount` of **556 matches the feature audit's recorded figure exactly**, so no difference has
to be stated: the suite set itself has not changed since the audit.

Note on the Codex suites in this set. The plan forbids editing any `.codex/` path, and `[P4-T6]` confirms none
was edited. The seven suites under `tests/scripts/codex-hooks/` in this batch are test files, not `.codex/`
paths, and they are read here rather than modified; they are in the batch because their names match the glob
that defines the must-not-regress set. Their passing is evidence, not a change.

## Changed-file enumeration check

Recorded per this task's requirement, read from the enumerations `[P4-T6]` captured:

| needle | occurrences in the anchored `git diff --name-only 1b150689c2d6bbda848ae10ec92e4ccc018a5560` | occurrences in `git status --porcelain --untracked-files=all` |
| --- | --- | --- |
| `enforce-orchestration-preimplementation-gate` | **0** | **0** |
| `enforce-epic-merge-gate` | **0** | **0** |

**No file matching `enforce-orchestration-preimplementation-gate` or `enforce-epic-merge-gate` appears in the
changed-file enumeration.** The 556 passes are therefore passes of unmodified suites against unmodified
hooks, which is what criteria 17 and 18 require: the gate restrictions were not weakened and the epic merge
gate's matcher was not widened, because neither was touched.

Acceptance: the enumerated file count is 17, `FailedCount` is 0, and `TotalCount` equals `PassedCount`.
Satisfied.
