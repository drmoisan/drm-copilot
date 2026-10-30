# Completion report: legacy discovery and parity (issue #980)

- Issue: #980
- Branch: `feature/legacy-discovery-and-parity-980` (scope comparisons use the merge base of `origin/main` and `HEAD`)
- Plan: `plan.2026-10-17T22-38.md` (Phases 0 to 16; Phases 15 and 16 are remediation cycle 1 of the review set `{policy-audit,code-review,feature-audit,remediation-inputs}.2026-10-29T13-16.md`)
- Reconciled: 2026-10-30 by the executor (this report records executor-verified evidence only; the independent re-review and exact-head CI are pending and are not claimed)

## Status in one paragraph

Every implementation task of the plan is accepted with canonical evidence. Phase 12 added the host-principal completion path and split the over-limit publisher. Its installed-host proof (P12-T12) exercised the full receipt chain through harness-simulated host events, with the identity exported by `SCRATCH` launchers under the retired `DRM_DISCOVERY_*` contract, which closed both blockers the first self-review escalated against the installed packages; it did not observe a real Claude Code, Codex or Copilot host payload. Remediation cycle 1 (Phases 15 and 16) takes identity from the host hook payload only, binds a specialist's controlled calls by `invocation_ref`, admits root calls only through one-use root grants, refuses every unbound controlled call, derives the capability probe's status from recorded host observations, adds a Python dispatch latch and expiry check, re-checks resolved read targets, caches the verified schema registry by content, gates the ten unthresholded TypeScript files and retains the coverage reports; it records what each host was observed to deliver in the P16-T7 table (`evidence/qa-gates/discovery-host-observations.2026-10-30T01-47.md`: no host was driven in this cycle, every row names its source). Phase 14 had corrected the schema-registry rebuild (the full Python run fell from 17965.16 s to 929.37 s); the Phase 15 cache brings the `tests/discovery_runtime` tree from 304.69 s to 156.30 s. Phase 16 re-ran every final gate on the remediated tree. Python: 15728 tests, 96.69% lines, 93.62% branches in 661.48 s. TypeScript extension: 5177 tests, 97.04% / 93.63% with every per-file threshold. TypeScript root: 5194 tests. PowerShell: 12744 tests, 93.34% lines. The isolation runs, the per-file coverage comparison over 274 branch files, the repository and publication contracts under the tiered file-size policy, the evidence-location validator and the installed runtime of the rebuilt wheel also pass. The feature is **not complete**: the independent re-review (AC-64) and exact-head CI have not run.

## Acceptance criteria

Source files: `spec.md` and `user-story.md` (`## Acceptance Criteria`, 66 criteria each, identical text). Per-criterion mapping: `evidence/qa-gates/acceptance-criteria-status.2026-10-26T02-57.md` for the full table, `evidence/qa-gates/acceptance-criteria-status.2026-10-29T12-51.md` for the Phase 14 changes, and `evidence/qa-gates/acceptance-criteria-status.2026-10-30T01-58.md` for the remediation-cycle re-evaluation of AC-07, AC-60, AC-65 and AC-66 (each re-proven from Phase 15 or 16 evidence), the Phase 16 quality citations and the closing task of every review finding. Counts: 65 checked and 1 unchecked in each file.

| Unchecked criterion | Reason |
| --- | --- |
| Feature review reports no blocking defects. | The independent re-review of remediation cycle 1 has not run. The executor self-review (`evidence/qa-gates/self-review.*.md`, lexicographically greatest) is not a substitute for it. |

Retained checklists in `spec.md`: Definition of Done 6 of 7 checked (unchecked: "Telemetry/logging added or updated (if applicable)". The feature adds no telemetry surface, so the item is not applicable and is left unchecked rather than claimed). Seeded Test Conditions 11 of 12 checked (unchecked: the final full feature review).

## Quality gates (remediated tree, Phase 16)

| Gate | Result | Evidence |
| --- | --- | --- |
| Python format, lint, types | Black 976 files unchanged; Ruff clean; Pyright 0 errors | `evidence/qa-gates/p16-python-{format,lint,types}.2026-10-30T00-42.md` |
| Python tests with coverage | 15728 passed, 6 skipped in 661.48 s; 96.69% lines, 93.62% branches; threshold check 85/75 passed; coverage JSON retained | `evidence/qa-gates/p16-python-tests.2026-10-30T00-42.md`, `p16-python-coverage.2026-10-30T00-42.json` |
| TypeScript (root and extension) | Prettier, ESLint, tsc clean; root 324 suites / 5194 tests; extension 321 suites / 5177 tests 97.04% / 93.63%, every per-file threshold including the ten P15-T20 entries met; both builds pass; lcov and coverage-summary reports retained | `evidence/qa-gates/p16-typescript-*.2026-10-30T01-40.md` (supersedes the `2026-10-30T00-48` set after the P16-T4 test addition) |
| PowerShell | PoshQC format no change; PSScriptAnalyzer no findings; Pester 12744 tests / 0 failed / 10 pre-existing skips; 93.34% lines (no branch metric); three shards complete; Linux hook-suite shape 7394 passed; canonical coverage file equals the full-run copy | `evidence/qa-gates/p16-powershell-*.2026-10-30T01-29.md` |
| Coverage deltas | 274 branch production files (185 Python, 50 TypeScript, 39 PowerShell), 0 failures; new files at least 90% lines; every changed line of pre-existing files covered after two focused sentinel-dispatch tests were added | `evidence/qa-gates/p16-coverage-comparison.2026-10-30T01-41.md` |
| Isolation | seeded Jest 1616 in both projects, reversed Python over the 12 Phase 15 modules, Pester seeds 161, 262, 363 over 25 suites | `evidence/regression-testing/p16-isolation.2026-10-30T01-45.md` |
| Repository and publication contracts | zero drift, 9581 + 1053 contract tests, tiers 28/28, packaging closures DEFECTS=0, no branch file at or above 700 logical lines (`jest.config.cjs` at 531), six identical brief copies, evidence-location validator exit 0 | `evidence/qa-gates/p16-repository-contracts.2026-10-30T01-55.md` |
| Installed runtime | rebuilt wheel installs in isolation, doctor verifies build `3396ea3b…`, 31 console entries answer, 36 schemas including the two new kinds | `evidence/qa-gates/discovery-installed-runtime.2026-10-30T01-47.md` |
| Host observations | no host driven by the executor in this cycle; per-host rows cite the fixture suites; VS Code legacy Local harness `unsupported` | `evidence/qa-gates/discovery-host-observations.2026-10-30T01-47.md` |
| Registry cache | `tests/discovery_runtime` 304.69 s before, 156.30 s after; content-keyed cache shared across identical catalogs | `evidence/other/p15-registry-cache-timing.2026-10-30T00-11.md` |

## Resolved escalations

The two blockers the first self-review escalated (`evidence/qa-gates/self-review.2026-10-26T02-48.md`) are closed. The installed completion-receipt path was implemented in P12-T1 to P12-T9 and exercised through harness-simulated host events in P12-T12. The over-limit publisher files were split in P12-T10 (`scripts/dev_tools/agentic_sync.py` is now 454 lines), and the stale baseline entry for that file was removed from `config/file-size-baseline.json` in P14-T8.

## Review findings of 2026-10-29T13-16 and their closure

R1 (TypeScript coverage artifact absent): P15-T20, P16-T2, P16-T4. R2 (evidence-location validator): P15-T2, P16-T8. R3 (probe attests from its own synthetic environment): P15-T10, P15-T11, P16-T7. R4 (no production supplier of the trusted identity; user decision: the host hook payload): P15-T3 to P15-T9, P15-T12 to P15-T16, P15-T23. The Major (Python re-admits a consumed grant): P15-T16. The Minors: P15-T19 (deep-copied `before`), P15-T16 (identity-refusal finding per row), P16-T3 (full-run coverage file), P15-T17 (read-target re-check), P15-T23 and P16-T9 (status lines), P15-T21 (brief wording). The user-directed catalog cache: P15-T18. The per-finding evidence is tabulated in `evidence/qa-gates/acceptance-criteria-status.2026-10-30T01-58.md`.

## Review, CI and orchestration

- Independent feature review (policy audit, code review, feature audit): pending; the orchestrator continues the mandatory lifecycle after the executor handoff.
- Exact-head CI: pending; the branch is pushed.
- Orchestrator checkpoint: `artifacts/orchestration/orchestrator-state.json` is owned by the orchestrator.

## Backward compatibility and known limits

- v1 artifacts remain readable through the frozen v1 catalog and the `migrate` operation; the retired validators keep their compatibility aliases (`evidence/regression-testing/p9t7-retired-validator-compatibility-contract.2026-10-22T18-11.md`).
- Analyzer limits: the generic repository analyzer and the .NET/C# analyzer classify facts versus inference; the VSTO adapter is optional and isolated; no analyzer executes consumer code.
- Host limits: Codex ordinary-agent starts replayed with a reused agent id collide on the exclusive routing attestation (pre-existing ordinary hook behavior); the Python doctor under the `local-user` principal reports native capability as unavailable by contract, and the host doctor projects the session attestation; a host whose PreToolUse carries no `agent_id` for subagent calls is `unsupported` by the probe, and the VS Code legacy Local harness is `unsupported` (`docs/engineering/legacy-discovery-and-parity/enforcement.md`, `## Identity source`, `## Capability probe`).
- Package versions: wheel 2.0.0, extension and npm package 1.1.23; digests in `handoff.md` (`## Built artifacts`).

## Executor handoff (P16-T11, remediation cycle 1)

- Plan state: all 156 tasks of `plan.2026-10-17T22-38.md` are checked (122 of Phases 0 to 14 and the 34 of Phases 15 and 16). The plan validates through the installed MCP validator and the branch-current Python CLI. The orchestrator checkpoint validates through both; it records tasks through P11-T11, and recording Phases 12 to 16 is the orchestrator's step. A proof check confirms that every checked task names at least one existing canonical artifact and that each discharged task is checked only with its discharging task (`evidence/qa-gates/p16-handoff-validation.*.md`); P15-T3 to P15-T6 wrote no dedicated record and are proven by the Pester and schema suites the plan names, which ran in the P16-T3 and P16-T1 populations.
- Baseline references: `evidence/baseline/python-tests.2026-10-18T03-51.md`, `typescript-root-tests.2026-10-18T03-55.md`, `typescript-extension-tests.2026-10-18T03-58.md`, `powershell-tests.2026-10-18T04-21.md`; the cycle entry `evidence/remediation-baseline/phase15-instructions-read.2026-10-29T17-53.md`.
- Final references: `evidence/qa-gates/p16-python-{format,lint,types,tests}.2026-10-30T00-42.md` with `p16-python-coverage.2026-10-30T00-42.json`; `p16-typescript-{root,extension}-{format,lint,types,tests,architecture,build}.2026-10-30T01-40.md` with the retained lcov and coverage-summary reports; `p16-powershell-{format,analyze,tests,single-process,shards}.2026-10-30T01-29.md` with the JUnit, coverage and shard files; `p16-coverage-comparison.2026-10-30T01-41.md`; `p16-repository-contracts.2026-10-30T01-55.md` with its nine command-step records; `discovery-installed-runtime.2026-10-30T01-47.md`; `discovery-host-observations.2026-10-30T01-47.md`; `evidence/regression-testing/p16-isolation.2026-10-30T01-45.md`; `evidence/other/p15-registry-cache-timing.2026-10-30T00-11.md`.
- Self-review: `evidence/qa-gates/self-review.2026-10-30T02-04.md` (123 checklist rows, 0 FAIL; 13 review-finding rows, each closed).
- Acceptance: `evidence/qa-gates/acceptance-criteria-status.2026-10-30T01-58.md` (65 of 66 per source; AC-07, AC-60, AC-65 and AC-66 re-proven from Phase 15 and 16 evidence).
- Remaining review- and CI-dependent items: AC-64 "Feature review reports no blocking defects.", the seeded condition for the final full feature review, deliverable D20, a live per-host observation that only a non-isolated orchestrator delegation can produce (instructions in `discovery-host-observations.2026-10-30T01-47.md`), and exact-head CI on the pull request the orchestrator opens (no pull request was opened by the executor).
- Observation for the orchestrator: the checkpoint's evidence entries for P1-T4, P1-T5 and P1-T6 name paths that are not on disk. Those tasks are proven by their `requirements-traceability.md` links, which resolve (`evidence/regression-testing/p1t{4,5,6}-executor-verification.*.md`).

## Remaining local consumer work

Unchanged from `handoff.md` (interpreter and wheel, host package, push-down, probe, initialize and activate, source discovery, target work). The installed host now supports agent-driven finalize and receipt-gated stops.
