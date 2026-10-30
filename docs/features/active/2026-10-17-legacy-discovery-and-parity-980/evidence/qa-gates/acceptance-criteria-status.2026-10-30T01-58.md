# P16-T9 Acceptance-criteria status after remediation cycle 1

Timestamp: 2026-10-30T01-58
Task: [P16-T9] Re-reconcile the acceptance criteria from Phase 16 evidence.
Command: re-evaluation of AC-07, AC-60, AC-65 and AC-66 against the Phase 15 and 16 evidence named below, with AC-64 held unchecked; `grep -c "^- \[x\]"` and `grep -n "^- \[ \]"` on `spec.md` and `user-story.md` (no criterion text changed, no criterion created, no checkbox flipped in this task because each re-evaluated criterion re-establishes its proof)
EXIT_CODE: 0
Output Summary: `spec.md` and `user-story.md` each keep 65 of 66 acceptance criteria checked; the one unchecked criterion in each file is "Feature review reports no blocking defects." (AC-64: the independent re-review of remediation cycle 1 has not run). The four re-evaluated criteria each cite Phase 15 or 16 evidence and stay checked; no criterion is checked from executor prose alone. The retained `spec.md` checklists stand at Definition of Done 6 of 7 (telemetry not applicable, left unchecked) and Seeded Test Conditions 11 of 12 (the final full feature review pending). The deliverable set D01 to D22 is unchanged.

AC identifiers follow the order of the `## Acceptance Criteria` section of `spec.md` (identical in `user-story.md`); task identifiers refer to `plan.2026-10-17T22-38.md`; evidence paths are relative to `evidence/`. Rows not listed below keep the status, tasks and evidence of `acceptance-criteria-status.2026-10-29T12-51.md` and `acceptance-criteria-status.2026-10-26T02-57.md`.

## Re-evaluated criteria (remediation cycle 1)

| ID | Text | Status | Phase 15 or 16 proof |
| --- | --- | --- | --- |
| AC-07 | Agents cannot write outside authorized paths. | checked | The payload-attributed tool gate: identity from the hook payload only, a specialist's controlled call bound by `invocation_ref` to its one started invocation, root calls admitted only through a one-use root grant, every controlled call without a binding refused (P15-T6, the payload-attributed gate in `DiscoveryAuthorization.psm1`, proven by `DiscoveryAuthorization.Tests.ps1`, `enforce-discovery-artifact-gate.Tests.ps1`, `discovery-pre-tool.Tests.ps1` for Codex and Copilot, which run in `qa-gates/p16-powershell-tests.2026-10-30T01-29.md` and in the three seeded orders of `regression-testing/p16-isolation-pester-seeds.2026-10-30T01-45.md`; P15-T14 and P15-T16 in `qa-gates/p15t12-t15-verification.2026-10-29T23-17.md` and `qa-gates/p15t16-verification.2026-10-29T23-45.md`: `DISCOVERY_HOST_BINDING_REQUIRED`, the Python `.used` dispatch latch and the replay refusal). The per-host observation table `qa-gates/discovery-host-observations.2026-10-30T01-47.md` records that no host was driven in this cycle and cites the per-host Pester suites (`enforce-discovery-artifact-gate`, `discovery-pre-tool`, `DiscoveryAuthorization`) that prove the denials by fixture; the P16-T3 run of those suites is `qa-gates/p16-powershell-tests.2026-10-30T01-29.md`. |
| AC-60 | Applicable TypeScript quality gates pass. | checked | `qa-gates/p16-typescript-{root,extension}-{format,lint,types,tests,architecture,build}.2026-10-30T01-40.md` (extension 321 suites / 5177 tests, 97.04% lines / 93.63% branches with every per-file threshold including the ten P15-T20 entries; root 324 suites / 5194 tests), the retained reports `qa-gates/p16-typescript-{root,extension}-lcov.2026-10-30T01-40.info` and `-coverage-summary.2026-10-30T01-40.json`, and the per-file comparison `qa-gates/p16-coverage-comparison.2026-10-30T01-41.md` (50 TypeScript files, 0 failures; R1 closed). |
| AC-65 | Evidence is stored in canonical feature evidence locations. | checked | P15-T1 recorded the cycle entry (`remediation-baseline/phase15-instructions-read.2026-10-29T17-53.md`) and P15-T2 removed the two stray files under `artifacts/coverage/` (`qa-gates/p15-evidence-locations.2026-10-29T17-54.md`); P16-T8 runs `validate_evidence_locations.py --root .` with exit 0 (`qa-gates/p16-evidence-locations.2026-10-30T01-55.md`; R2 closed). Every Phase 15 and 16 artifact is under `evidence/<kind>/` with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`. |
| AC-66 | Documentation and generated customization outputs are current. | checked | P15-T22 mirror parity (46 source-to-mirror pairs byte-identical, the three new helper modules registered, the stray shared-library copy removed: `other/p15-mirror-parity.2026-10-30T00-23.md`); P15-T23 documentation (`## Identity source` and `## Capability probe` in `enforcement.md`, requalified handoff and completion report, cycle-1 status lines: `other/p15-execution-environment-check.2026-10-30T00-28.md`); P16-T8 zero generated drift, six identical brief copies and current build manifest (`qa-gates/p16-generator-check.2026-10-30T01-55.md`, `p16-mirror-and-publication-contracts.2026-10-30T01-55.md`, `p16-packaging-closure.2026-10-30T01-55.md`); `handoff.md` digests updated in P16-T6. |
| AC-64 | Feature review reports no blocking defects. | unchecked | The independent re-review of remediation cycle 1 has not run. The executor self-review of P16-T10 is not a substitute for it. |

## Quality criteria AC-59 to AC-66 (Phase 16 evidence)

| ID | Status | Evidence |
| --- | --- | --- |
| AC-59 Python gates | checked | `qa-gates/p16-python-{format,lint,types,tests}.2026-10-30T00-42.md` (Black 976 unchanged, Ruff clean, Pyright 0 errors, 15728 passed, 96.69% lines, 93.62% branches, threshold gate exit 0; `p16-python-coverage.2026-10-30T00-42.json` retained); coverage deltas `qa-gates/p16-coverage-comparison.2026-10-30T01-41.md` (185 Python files, 0 failures); installed wheel `qa-gates/discovery-installed-runtime.2026-10-30T01-47.md` |
| AC-60 TypeScript gates | checked | see the re-evaluation row above; seeded Jest `regression-testing/p16-isolation-jest-seed-1616.2026-10-30T01-45.md` |
| AC-61 PowerShell gates | checked | `qa-gates/p16-powershell-{format,analyze,tests,single-process,shards}.2026-10-30T01-29.md` (12744 tests, 0 failed, 93.34% lines, shard completeness verified, canonical coverage file regenerated from the full run); Pester seeds `regression-testing/p16-isolation-pester-seeds.2026-10-30T01-45.md`; 39 PowerShell files in `qa-gates/p16-coverage-comparison.2026-10-30T01-41.md`, 0 failures |
| AC-62 Conditional C# gates | checked (conditional) | no `.cs` file among the branch's added or modified paths (`qa-gates/p16-file-size.2026-10-30T01-55.md` counts 724 branch code files; the counted set holds no `.cs` path); no waiver is claimed for any future addition |
| AC-63 All tests pass | checked | the three Phase 16 language loops above, isolation `regression-testing/p16-isolation.2026-10-30T01-45.md`, and the contract suites in `qa-gates/p16-mirror-and-publication-contracts.2026-10-30T01-55.md` (9581 + 1053 passed) |
| AC-64 No blocking review defects | unchecked | see above |
| AC-65 Canonical evidence | checked | see the re-evaluation row above; `qa-gates/p16-repository-contracts.2026-10-30T01-55.md` |
| AC-66 Current docs and generated assets | checked | see the re-evaluation row above |

## Criteria whose cited proof changed character (no checkbox change)

- AC-08 "Every new agent has a SubagentStop output validator." stays checked. The P12-T12 record it cited (`qa-gates/discovery-native-capabilities.2026-10-28T15-06.md`) is now qualified as harness-simulated host events with launcher-exported identity (P15-T23). The criterion's proof rests on the validators themselves and their suites, which run on the remediated tree: `DiscoveryStop.Tests.ps1`, the three host `discovery-output.Tests.ps1` suites, `discovery-finalization*.test.ts` and `tests/discovery_runtime/test_service_finalization.py` (P16-T3 and P16-T2 populations), with the four registered stop validators listed in `qa-gates/p16-mirror-and-publication-contracts.2026-10-30T01-55.md` (claude-settings and codex-bundle contracts).
- The Definition of Done item "Behavior matches acceptance criteria in all documented environments" stays checked on the same basis: every documented environment's hooks and gates pass their suites on the remediated tree and the installed runtime is re-verified (`qa-gates/discovery-installed-runtime.2026-10-30T01-47.md`); a live-host observation is recorded only when the orchestrator drives a host (`qa-gates/discovery-host-observations.2026-10-30T01-47.md`).

## Review findings of 2026-10-29T13-16 and their closing tasks

| Finding | Closing task | Evidence |
| --- | --- | --- |
| R1 TypeScript coverage artifact absent | P15-T20, P16-T2, P16-T4 | `other/p15-jest-thresholds.2026-10-30T00-17.md`; retained lcov and summaries stamped `2026-10-30T01-40`; `qa-gates/p16-coverage-comparison.2026-10-30T01-41.md` |
| R2 Evidence-location validator exits nonzero | P15-T2, P16-T8 | `qa-gates/p16-evidence-locations.2026-10-30T01-55.md` (exit 0) |
| R3 Capability probe attests from its own synthetic environment | P15-T10, P15-T11, P16-T7 | `qa-gates/p15t10-verification.2026-10-29T22-18.md`, `qa-gates/p15t11-verification.2026-10-29T22-23.md`; probe status derived from recorded observations only (`enforcement.md` `## Capability probe`) |
| R4 No production supplier of the trusted agent identity | P15-T3 to P15-T9, P15-T12 to P15-T16, P15-T23 (user decision: identity from the host hook payload) | P15-T3 to P15-T6 are proven by the Set P Pester suites (`DiscoveryPayload`, `DiscoveryToolRouting`, `DiscoveryRootGrant`, `DiscoveryObservation`, `DiscoveryAuthorization`) in `qa-gates/p16-powershell-tests.2026-10-30T01-29.md`; `qa-gates/p15t7-verification.2026-10-29T21-50.md`; `qa-gates/p15t8-verification.2026-10-29T21-52.md`; `other/p15-sentinel-agent.2026-10-29T21-57.md`; `qa-gates/p15t12-t15-verification.2026-10-29T23-17.md`; `qa-gates/p15t16-verification.2026-10-29T23-45.md`; `enforcement.md` `## Identity source`; requalified `handoff.md` and `completion-report.md`; `qa-gates/discovery-host-observations.2026-10-30T01-47.md` |
| Major: Python re-admits a consumed grant and ignores `expires_at` | P15-T16 | `qa-gates/p15t16-verification.2026-10-29T23-45.md` (`.used` latch, "expired before dispatch" and "already dispatched" refusals, replay test) |
| Minor: `after == before` compares one object with itself | P15-T19 | `regression-testing/p15-isolation-assertion.2026-10-30T00-14.md` |
| Minor: identity-refusal finding not asserted per row | P15-T16 (`test_gateway_host_main.py` rows) | `qa-gates/p15t16-verification.2026-10-29T23-45.md` |
| Minor: partial `powershell-coverage.xml` | P16-T3 | `qa-gates/p16-powershell-tests.2026-10-30T01-29.md` (canonical file equals the full-run copy, 93.34%) |
| Minor: resolved read target not re-checked against `selected_paths` | P15-T17 | `qa-gates/p15t17-verification.2026-10-29T23-56.md` |
| Minor: stale status lines | P15-T23, P16-T9 | `spec.md` and `user-story.md` status and `Last Updated` lines |
| Minor: shared-fixture bullet wording | P15-T21 | `other/p15-brief-wording.2026-10-30T00-19.md` |
| Catalog cache (user-directed) | P15-T18 | `other/p15-registry-cache-timing.2026-10-30T00-11.md` (304.69 s to 156.30 s on `tests/discovery_runtime`) |

## Deliverables

Unchanged set D01 to D22. D15 Publication is rebuilt in P16-T6 (wheel `8993309f…`, VSIX `c9eda59d…` 1.1.23, npm `6c04864e…` 1.1.23). D20 Final feature audit: pending (independent re-review). D22 Follow-on handoff: `handoff.md` with the P16-T6 digests, the requalified host claims and the P16-T7 table.

## Remaining review- and CI-dependent items

AC-64 "Feature review reports no blocking defects.", the seeded condition "Applicable complete language/repository quality loops, coverage and isolation checks, and final full feature review.", deliverable D20, and exact-head CI on the pull request the orchestrator opens.
