# Acceptance-Criteria Check-Off Log ([P9-T1] to [P9-T25])

Timestamp: 2026-09-25T20-17
Command: sed line-addressed `- [ ] ` to `- [x] ` substitution on spec.md lines 232, 237, 243, 250, 260, 264, 269, 270, 274, 275, 276, 277 (the other 13 lines were already checked in Phases 1 to 6); verification by sh <SCRATCHPAD>/i663/run.sh p9-identity
EXIT_CODE: 0
Output Summary: 25 rows. Every named line of `spec.md` begins `- [x] ` and its remaining text is identical to the [P0-T2] AC inventory (p9-identity: 25 rows, Problems 0; section counts 25 checked, 0 unchecked). No evidence condition is unmet.

Evidence paths are relative to `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/`. `FPC` = `qa-gates/final-pester-coverage.md` (pass 2).

| AC | Line | Task | Evidence | Condition confirmed | State |
| --- | --- | --- | --- | --- | --- |
| AC-1 | 226 | [P9-T1] | `qa-gates/b2-scoped-pester.md`, FPC | b2 records the EpicScopeResolution testsuite at 21 passed; FPC shows all 21 names Passed | checked (Phase 2), confirmed |
| AC-2 | 230 | [P9-T2] | FPC, `regression-testing/fail-before-b3.md` | G1-1 Passed in FPC; fail-before-b3 lists G1-1 on a FAILED line (EXIT_CODE 1) | checked (Phase 3), confirmed |
| AC-3 | 231 | [P9-T3] | FPC | G1-2, G1-3, G1-4 Passed | checked (Phase 3), confirmed |
| AC-4 | 232 | [P9-T4] | FPC, `qa-gates/p7-existing-suites.md` | G1-5 Passed; the seven unextended pr-author suites are absent from numstat; the nine `enforce-pr-author-skill*.Tests.ps1` testsuite rows have failures 0 and errors 0 | checked now |
| AC-5 | 236 | [P9-T5] | FPC | the five expanded `issue #663 epic scope` names Passed, including `issue #663 epic scope reads the epic checkpoint once per gh pr create call` | checked (Phase 3), confirmed |
| AC-6 | 237 | [P9-T6] | `qa-gates/p7-existing-suites.md`, FPC | epic-base-branch.Tests.ps1 numstat 82/0 (deletions 0); TriggerScoping absent from numstat; both testsuite rows (14 and 2 tests) have failures 0 and errors 0 | checked now |
| AC-7 | 241 | [P9-T7] | FPC | G3-1 Passed | checked (Phase 4), confirmed |
| AC-8 | 242 | [P9-T8] | FPC | G3-2 Passed | checked (Phase 4), confirmed |
| AC-9 | 243 | [P9-T9] | FPC, `qa-gates/p7-existing-suites.md` | G3-3 and G3-4 Passed; both existing model-routing suites absent from numstat; their testsuite rows (15 and 20 tests) have failures 0 and errors 0 | checked now |
| AC-10 | 247 | [P9-T10] | FPC | G4-1 Passed | checked (Phase 5), confirmed |
| AC-11 | 248 | [P9-T11] | FPC | G4-2, the three G4-3 names, the two G4-4 names, and the six `command-leg readiness names <Conjunct> for <Label>` rows for route_id, epic_feature_folder, epic_manifest_path, integration_branch, features, merge-in-progress Passed (RS-2) | checked (Phase 5), confirmed |
| AC-12 | 249 | [P9-T12] | FPC | G4-6 and G4-7 Passed | checked (Phase 5), confirmed |
| AC-13 | 250 | [P9-T13] | FPC, `qa-gates/p7-existing-suites.md` | G4-8, G4-9, G4-10 Passed; the six unextended preimplementation suites absent from numstat and CommandExemption.Tests.ps1 at 35/0; the seven testsuite rows (including mode-resolution, 87 tests) have failures 0 and errors 0 | checked now |
| AC-14 | 254 | [P9-T14] | FPC | the eight `issue #663` rows of the Claude CommandExemption testsuite Passed; `denies D4 row 12c - an output redirection in the segment` and `denies D4 row 12d - an input redirection in the segment` Passed (RS-1) | checked (Phase 1), confirmed |
| AC-15 | 255 | [P9-T15] | FPC | the eight `issue #663` rows of the Codex command-exemption testsuite Passed | checked (Phase 1), confirmed |
| AC-16 | 256 | [P9-T16] | FPC, `qa-gates/p7-mirror-parity.md` | Parity testsuite passed 2, failures 0, errors 0; legacy-codex-hook-contracts passed 43 of 43, failures 0, errors 0; four-copy helpers set equal | checked (Phase 1), confirmed |
| AC-17 | 260 | [P9-T17] | FPC, `qa-gates/p7-gate5-untouched.md` | both D3 names Passed; the gate-5 diff is empty | checked now |
| AC-18 | 264 | [P9-T18] | FPC, `qa-gates/p7-existing-suites.md`, `qa-gates/p7-gate6-untouched.md` | the three parallel-worktree-removal testsuite rows (11, 49, 3 tests) have failures 0 and errors 0; all three absent from numstat; the gate-6 diff is empty | checked now |
| AC-19 | 268 | [P9-T19] | FPC | the `epic-plan` and `epic-planner` contract rows Passed | checked (Phase 6), confirmed |
| AC-20 | 269 | [P9-T20] | FPC, `qa-gates/p7-existing-suites.md` | the `epic-orchestrate` and `epic-orchestrator` contract rows and the seven pre-existing hygiene rows Passed; checkpoint-hygiene-skill-contract.Tests.ps1 numstat 53/0 (deletions 0) | checked now |
| AC-21 | 270 | [P9-T21] | `qa-gates/b6-validator-additive-test.md`, `qa-gates/final-pytest-contracts.md`, `qa-gates/p7-existing-suites.md` | `1 passed` for the additive test; contract suites 119 passed with no failure (covers test_parallel_planner_surface_contracts.py); that file absent from numstat | checked now |
| AC-22 | 274 | [P9-T22] | `qa-gates/final-pytest-contracts.md`, `qa-gates/final-jest-manifest-completeness.md`, FPC, `qa-gates/p7-mirror-parity.md` | contract suites pass with the RS-8 cleanup recorded (`.claude/state` porcelain empty); Jest 16 passed; WorktreeResolution.Manifest testsuite passed 16, failures 0, errors 0; every mirror pair equal | checked now |
| AC-23 | 275 | [P9-T23] | FPC, `qa-gates/p7-d5-no-python.md` | the no-python testsuite row has failures 0 and errors 0 (27 passed); p7-d5-no-python meets its acceptance (1 authority line per module, EXIT_CODE 0, FailedCount 0, guarded-tree name on a PASSED line) | checked now |
| AC-24 | 276 | [P9-T24] | `qa-gates/p7-line-limits.md`, `qa-gates/p7-untouched-modules.md` | 23 counts at most 500 (max 496; post-remediation addendum keeps this); the two shared modules show an empty diff and empty porcelain | checked now |
| AC-25 | 277 | [P9-T25] | `qa-gates/final-poshqc-format.md`, `qa-gates/final-poshqc-analyze.md`, FPC, `qa-gates/final-coverage-delta.md`, `qa-gates/final-seven-stage-loop.md` | all four meet their acceptance in pass 2 per the Single-Pass Statement; every new or changed PowerShell production file at least 85% line coverage (lowest 90.38%). `EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/coverage/ replaced with docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/qa-gates/` (RS-4). Per RS-10 the module functions `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCTest` with the repository `pester.runsettings.psd1` stand in for the MCP tools `run_poshqc_format`, `run_poshqc_analyze`, and `run_poshqc_test`, which read the installed extension's settings and return no test output. | checked now |

## p9-identity output

```
AC-1 line 226: checked=True textIdentical=True
AC-2 line 230: checked=True textIdentical=True
AC-3 line 231: checked=True textIdentical=True
AC-4 line 232: checked=True textIdentical=True
AC-5 line 236: checked=True textIdentical=True
AC-6 line 237: checked=True textIdentical=True
AC-7 line 241: checked=True textIdentical=True
AC-8 line 242: checked=True textIdentical=True
AC-9 line 243: checked=True textIdentical=True
AC-10 line 247: checked=True textIdentical=True
AC-11 line 248: checked=True textIdentical=True
AC-12 line 249: checked=True textIdentical=True
AC-13 line 250: checked=True textIdentical=True
AC-14 line 254: checked=True textIdentical=True
AC-15 line 255: checked=True textIdentical=True
AC-16 line 256: checked=True textIdentical=True
AC-17 line 260: checked=True textIdentical=True
AC-18 line 264: checked=True textIdentical=True
AC-19 line 268: checked=True textIdentical=True
AC-20 line 269: checked=True textIdentical=True
AC-21 line 270: checked=True textIdentical=True
AC-22 line 274: checked=True textIdentical=True
AC-23 line 275: checked=True textIdentical=True
AC-24 line 276: checked=True textIdentical=True
AC-25 line 277: checked=True textIdentical=True
InventoryRows: 25
SectionChecked: 25
SectionUnchecked: 0
Problems: 0
PROCESS_EXIT_CODE: 0
```
