# Completion report: legacy discovery and parity (issue #980)

- Issue: #980
- Branch: `feature/legacy-discovery-and-parity-980` (scope comparisons use the merge base of `origin/main` and `HEAD`)
- Plan: `plan.2026-10-17T22-38.md` (Phases 0 to 14)
- Reconciled: 2026-10-29 by the executor (this report records executor-verified evidence only; independent review and exact-head CI are pending and are not claimed)

## Status in one paragraph

Every implementation task of the plan is accepted with canonical evidence. Phase 12 added the host-principal completion path and split the over-limit publisher. Its installed-host proof (P12-T12) exercised the full receipt chain through harness-simulated host events, with the identity exported by `SCRATCH` launchers under the retired `DRM_DISCOVERY_*` contract, which closed both blockers the first self-review escalated against the installed packages; it did not observe a real Claude Code, Codex or Copilot host payload. Remediation cycle 1 (Phases 15 and 16) takes identity from the host hook payload only and records what each host was observed to deliver in the P16-T7 table (`evidence/qa-gates/discovery-host-observations.*.md`). Phase 14 corrected a schema-registry defect: `SchemaCatalog` rebuilt and re-verified its registry on every validation, and now builds it once per catalog. The full Python run fell from 17965.16 s to 929.37 s. Phase 14 then re-ran every final gate on the corrected tree, which is rebased onto main. Python: 15668 tests, 96.70% lines, 93.62% branches. TypeScript extension: 5109 tests, 97.13% / 93.58%. TypeScript root: 5126 tests, 98.22% / 93.3%. PowerShell: 12615 tests, 93.28% lines. The isolation runs, the repository and publication contracts under the tiered file-size policy, and the installed runtime of the rebuilt wheel also pass. The feature is **not complete**: the independent feature review (AC-64) and exact-head CI have not run.

## Acceptance criteria

Source files: `spec.md` and `user-story.md` (`## Acceptance Criteria`, 66 criteria each, identical text). Per-criterion mapping: `evidence/qa-gates/acceptance-criteria-status.2026-10-26T02-57.md` for the full table and `evidence/qa-gates/acceptance-criteria-status.2026-10-29T12-51.md` for the final changes and the Phase 14 quality citations. Counts: 65 checked and 1 unchecked in each file.

| Unchecked criterion | Reason |
| --- | --- |
| Feature review reports no blocking defects. | The independent feature review has not run. The executor self-review (`evidence/qa-gates/self-review.*.md`, lexicographically greatest) is not a substitute for it. |

Retained checklists in `spec.md`: Definition of Done 6 of 7 checked (unchecked: "Telemetry/logging added or updated (if applicable)". The feature adds no telemetry surface, so the item is not applicable and is left unchecked rather than claimed). Seeded Test Conditions 11 of 12 checked (unchecked: the final full feature review).

## Quality gates (final tree)

| Gate | Result | Evidence |
| --- | --- | --- |
| Python format, lint, types | Black 972 files unchanged; Ruff clean; Pyright 0 errors | `evidence/qa-gates/p14-python-{format,lint,types}.2026-10-29T12-45.md` |
| Python tests with coverage | 15668 passed, 6 skipped in 929.37 s; 96.70% lines, 93.62% branches; threshold check 85/75 passed | `evidence/qa-gates/p14-python-tests.2026-10-29T12-45.md` |
| TypeScript (root and extension) | Prettier, ESLint, tsc clean; root 319 suites / 5126 tests 98.22% / 93.3%; extension 316 suites / 5109 tests 97.13% / 93.58%, per-file thresholds met; both builds pass | `evidence/qa-gates/p14-typescript-*.2026-10-29T10-50.md` |
| PowerShell | PoshQC format no change; PSScriptAnalyzer no findings; Pester 12615 tests / 0 failed / 10 pre-existing skips; 93.28% lines (no branch metric); three shards complete; Linux hook-suite shape 7358 passed | `evidence/qa-gates/p14-powershell-*.2026-10-29T12-14.md` |
| Coverage deltas | 35 Phase 12 and catalog production files meet the floors; added files at least 90% lines; every changed line of pre-existing files covered | `evidence/qa-gates/p14-coverage-comparison.2026-10-29T12-45.md` |
| Isolation | seeded Jest 1414, reversed Python over 25 modules, Pester seeds 141, 242, 343 | `evidence/regression-testing/p14-isolation.2026-10-29T12-23.md` |
| Repository and publication contracts | zero drift, 9547 + 1053 contract tests, tiers 28/28, packaging closures DEFECTS=0, no branch file above 500 logical lines, six identical brief copies | `evidence/qa-gates/p14-repository-contracts.2026-10-29T12-49.md` |
| Installed runtime | rebuilt wheel installs in isolation, doctor verifies build `dc7bff83…`, 31 console entries answer | `evidence/qa-gates/discovery-installed-runtime.2026-10-29T12-26.md` |
| Native host controls | receipt chain, stale-receipt block, replay denial and refusals on three hosts (host-side code unchanged since) | `evidence/qa-gates/discovery-native-capabilities.2026-10-28T15-06.md` |
| Registry correction | 327 registry builds and 348.58 s in the profiled test before; 1 build and 0.93 s after | `evidence/other/p14-registry-timing.2026-10-29T12-45.md`, `p14-registry-sharing-verification.2026-10-29T10-23.md` |

## Resolved escalations

The two blockers the first self-review escalated (`evidence/qa-gates/self-review.2026-10-26T02-48.md`) are closed. The installed completion-receipt path was implemented in P12-T1 to P12-T9 and observed in P12-T12. The over-limit publisher files were split in P12-T10 (`scripts/dev_tools/agentic_sync.py` is now 454 lines), and the stale baseline entry for that file was removed from `config/file-size-baseline.json` in P14-T8.

## Review, CI and orchestration

- Independent feature review (policy audit, code review, feature audit): pending; the orchestrator continues the mandatory lifecycle after the executor handoff.
- Exact-head CI: pending; the branch is pushed.
- Orchestrator checkpoint: `artifacts/orchestration/orchestrator-state.json` is owned by the orchestrator.

## Backward compatibility and known limits

- v1 artifacts remain readable through the frozen v1 catalog and the `migrate` operation; the retired validators keep their compatibility aliases (`evidence/regression-testing/p9t7-retired-validator-compatibility-contract.2026-10-22T18-11.md`).
- Analyzer limits: the generic repository analyzer and the .NET/C# analyzer classify facts versus inference; the VSTO adapter is optional and isolated; no analyzer executes consumer code.
- Host limits: Codex ordinary-agent starts replayed with a reused agent id collide on the exclusive routing attestation (pre-existing ordinary hook behavior); the Python doctor under the `local-user` principal reports native capability as unavailable by contract, and the host doctor projects the session attestation.
- Package versions: wheel 2.0.0, extension and npm package 1.1.22; digests in `handoff.md` (`## Built artifacts`).

## Executor handoff (P14-T16)

- Plan state: all 122 tasks of `plan.2026-10-17T22-38.md` are checked. P13-T4 to P13-T9 and P11-T9 are checked together with their Phase 14 discharging tasks (P14-T10, P14-T11, P14-T13, P14-T14, P14-T15, P14-T16), as the plan's revision section prescribes. The plan validates through the installed MCP validator and the branch-current Python CLI. The orchestrator checkpoint validates through both; it records tasks through P11-T11, and recording Phases 12 to 14 is the orchestrator's step. A proof check confirms that every checked task names at least one existing canonical artifact, and that each discharged task is checked only with its discharging task (`evidence/qa-gates/p14-handoff-validation.*.md`).
- Baseline references: `evidence/baseline/python-tests.2026-10-18T03-51.md`, `typescript-root-tests.2026-10-18T03-55.md`, `typescript-extension-tests.2026-10-18T03-58.md`, `powershell-tests.2026-10-18T04-21.md`, `p14-registry-timing-before.2026-10-29T10-18.md`.
- Final references: `evidence/qa-gates/p14-python-{format,lint,types,tests}.2026-10-29T12-45.md`; `p14-typescript-{root,extension}-{format,lint,types,tests,architecture,build}.2026-10-29T10-50.md`; `p14-powershell-{format,analyze,tests,single-process,shards}.2026-10-29T12-14.md`; `p14-coverage-comparison.2026-10-29T12-45.md`; `p14-repository-contracts.2026-10-29T12-49.md` with its eight command-step records; `discovery-installed-runtime.2026-10-29T12-26.md`; `evidence/regression-testing/p14-isolation.2026-10-29T12-23.md`; `evidence/other/p14-registry-timing.2026-10-29T12-45.md`.
- Self-review: `evidence/qa-gates/self-review.2026-10-29T12-53.md` (121 rows, 0 FAIL).
- Acceptance: `evidence/qa-gates/acceptance-criteria-status.2026-10-29T12-51.md` (65 of 66 per source).
- Remaining review- and CI-dependent items: AC-64 "Feature review reports no blocking defects.", the seeded condition for the final full feature review, deliverable D20, and exact-head CI on the pull request the orchestrator opens (no pull request was opened by the executor).
- Observation for the orchestrator: the checkpoint's evidence entries for P1-T4, P1-T5 and P1-T6 name paths that are not on disk. Those tasks are proven by their `requirements-traceability.md` links, which resolve (`evidence/regression-testing/p1t{4,5,6}-executor-verification.*.md`).

## Remaining local consumer work

Unchanged from `handoff.md` (interpreter and wheel, host package, push-down, probe, initialize and activate, source discovery, target work). The installed host now supports agent-driven finalize and receipt-gated stops.
