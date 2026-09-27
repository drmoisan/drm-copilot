# P0-T2 Requirements Read

Timestamp: 2026-09-27T09-58
Work Mode: full-bug

Files read:

1. docs/features/active/gate-suites-read-unmocked-local-epic-state-709/issue.md
2. docs/features/active/gate-suites-read-unmocked-local-epic-state-709/spec.md
3. docs/features/active/gate-suites-read-unmocked-local-epic-state-709/research/research.2026-09-26T23-00.md

## AC inventory (spec.md "Acceptance Criteria", document order)

- AC1: the seven suites import EpicScopeResolution.psm1 without -Force and declare the Get-EpicScopeCheckpointText $null mock in the outermost BeforeAll after the hook load; verified by the structural-guard Describe passing.
- AC2: the new file exists and its structural guard failed before the suite edits with one failing row per unprotected suite (fail-before record under evidence/regression-testing/).
- AC3: seam-sufficiency control and treatment rows for the gate-1, gate-3, and gate-4 call shapes pass.
- AC4: the new file is hermetic (no temporary file, no gitignored read, no origin/main or git history, no drive-letter path) and passes in the CI windows-latest PoshQC job.
- AC5: Passed/Failed/Skipped totals of the seven edited suites are identical before and after.
- AC6: the three *.EpicScope.Tests.ps1 suites are unmodified and their totals are identical before and after.
- AC7: no production file and no push-down mirror changed (diff lists only the eight test files plus feature-folder files).
- AC8: format no changes, PSScriptAnalyzer zero findings, Pester zero failures for the eight changed files, and the full configured Pester run zero failures.
- AC9: line coverage of .claude/lib/worktree-resolution/EpicScopeResolution.psm1 does not decrease from baseline to final.

## Decisions

- D1: isolation seam is a per-suite module-scoped Mock of Get-EpicScopeCheckpointText.
- D2: mock placement in the existing top-level BeforeAll, after the hook dot-source or module import.
- D3: mock return value is $null.
- D4: regression check is a new standalone file with a structural guard and a resolver-level proof.
- D5: Codex suites are out of scope.
- D6: merge-order independence with siblings #707, #708, #710, #713 (content-anchor insertion, no reflow).
- D7: work mode full-bug; spec.md is the sole AC source.
- D8: the four relative-path epic-reading hooks are a follow-up.
- D9: explicit seven-path list in the structural guard.
- D10: no mock of Find-WorktreeResolutionRoot in the edited suites.

## Evidence override

EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baselines/ replaced with docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/
