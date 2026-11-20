# Cycle-2 Coverage Note ([P1-T8])

Timestamp: 2026-11-20T04-56
Plan: remediation-plan.2026-11-19T19-58.md
Command: git diff --name-status between INTEGRATION-TIP (second parent of the cycle-2 merge commit) and the merge commit, over the resolution paths and the P1-T3 tests; git diff --name-status --diff-filter=A from the pre-merge branch head to HEAD filtered for `.py`; read of `evidence/baseline/c2-baseline-ref.2026-11-19T20-40.md` and the three P1-T7 gate records
EXIT_CODE: 0
Output Summary: no production code file changed in this cycle beyond the incoming side; repository-wide figures show no drop against BASELINE-REF in any gate; no `*.py` file added (0 added `.py` paths from the pre-merge branch head to HEAD, and 0 in the merge relative to INTEGRATION-TIP).

## Baseline sources

- Phase 0 record: `evidence/baseline/c2-baseline-ref.2026-11-19T20-40.md`.
- Its BASELINE-REF sources: `evidence/regression-testing/branch-b-pytest-final.2026-11-19T19-20.md`, `evidence/regression-testing/branch-b-pester-final.2026-11-19T19-32.md`, `evidence/regression-testing/h3-jest-final.2026-11-19T16-55.md`.
- Final records: `evidence/regression-testing/c2-pytest-final.2026-11-20T04-43.md`, `c2-jest-final.2026-11-20T04-43.md`, `c2-pester-final.2026-11-20T04-55.md`.

## Files this cycle changed beyond the incoming side

| Path | Change | Class |
| --- | --- | --- |
| `.github/skills/execution-environment/SKILL.md` | kept deleted (modify/delete resolution, P1-T1) | document |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | kept deleted (modify/delete resolution, P1-T1) | document |
| `.github/skills/push-down-integration/SKILL.md` | deleted IncomingRetiredAdds path (P1-T1) | document |
| `extensions/drm-copilot/resources/customizations/.github/skills/push-down-integration/SKILL.md` | deleted IncomingRetiredAdds path (P1-T1) | document |
| `extensions/drm-copilot/resources/customizations/pack-manifests/core.json` | incoming entries kept minus 1 retired (P1-T2) | data |
| `extensions/drm-copilot/test/packaging/push-down-integration-skill.test.ts` | copy set reduced to four (P1-T3) | test |
| `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts` | brief copy list reduced to four (P1-T3) | test |
| `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1` | `$script:BriefCopies` reduced to four (P1-T3) | test |

No `.claude/skills/execution-environment/SKILL.md` edit was made (`BriefEdits: none` in `task-check.P1-T1.2026-11-19T20-45.md`).

Result: no production code file changed.

## Repository-wide comparison

| Gate | BASELINE-REF | Final (P1-T7) | Change |
| --- | --- | --- | --- |
| pytest line | 98.00% (35359/36079) | 98.00% (35359/36079) | none |
| pytest branch | 95.46% (13091/13714) | 95.46% (13091/13714) | none |
| Jest lines | 97.42% (68402/70212) | 97.51% (71883/73715) | +0.09 points; denominator growth from INCOMING-DELTA |
| Jest branches | 94.63% (10595/11196) | 94.83% (11414/12036) | +0.20 points; denominator growth from INCOMING-DELTA |
| Pester line | 96.84% (47091 covered, 1539 missed) | 96.84% (47273 covered, 1541 missed) | none at two decimals; 182 covered and 2 missed lines added by INCOMING-DELTA |

Every difference lies in files this cycle did not change and is attributed to INCOMING-DELTA (#1049, #1050, #1051). Pass counts: pytest 17101 passed at both points; Jest 6115 to 6450 and Pester 28994 to 29123 passed, the increases being the incoming suites; 0 failures in every gate.

## Per-file figures

No changed production file, so no per-file threshold applies (85% line and 75% branch; line only for PowerShell).
