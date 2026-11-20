# P18-T6 Acceptance-criteria status after remediation cycle 2

Timestamp: 2026-10-30T12-46
Task: [P18-T6] Re-reconcile AC-64 and the QA criteria from Phase 18 evidence.
Command: re-evaluation of AC-59, AC-60, AC-61, AC-63 and AC-66 against the Phase 18 evidence named below and of AC-64 against the cycle-2 closing evidence and the deferral record, with AC-64 held unchecked; `grep -c "^- \[x\]"` and `grep -n "^- \[ \]"` on `spec.md` and `user-story.md` (no criterion text changed, no criterion created, no checkbox flipped in this task because each re-cited criterion re-establishes its proof)
EXIT_CODE: 0
Output Summary: `spec.md` and `user-story.md` each keep 65 of 66 acceptance criteria checked; the one unchecked criterion in each file is "Feature review reports no blocking defects." (AC-64: the independent re-review of remediation cycle 2 has not run). The five re-cited criteria each cite Phase 18 evidence and stay checked; no criterion is checked from executor prose alone. The retained `spec.md` checklists stand at Definition of Done 6 of 7 (telemetry not applicable, left unchecked) and Seeded Test Conditions 11 of 12 (the final full feature review pending), so `spec.md` carries 82 checked boxes and `user-story.md` 65. The deliverable set D01 to D22 is unchanged.

AC identifiers follow the order of the `## Acceptance Criteria` section of `spec.md` (identical in `user-story.md`); task identifiers refer to `plan.2026-10-17T22-38.md`; evidence paths are relative to `evidence/`. Rows not listed below keep the status, tasks and evidence of `acceptance-criteria-status.2026-10-30T01-58.md` and its predecessors.

## AC-64 after remediation cycle 2

| ID | Text | Status | Cycle-2 closing evidence and deferrals |
| --- | --- | --- | --- |
| AC-64 | Feature review reports no blocking defects. | unchecked | The 2026-10-30T10-19 re-review (`code-review.2026-10-30T10-19.md`, `policy-audit.2026-10-30T10-19.md`, `feature-audit.2026-10-30T10-19.md`, `remediation-inputs.2026-10-30T10-19.md`) reported Blocker R5 (the sentinel tool consumes its grant by writing only the `.consumed` latch while the probe required the record's `state` to read `consumed`), one Minor and one Nit. R5 is closed in this cycle: P17-T2 pins the contract in `tests/fixtures/discovery_host/sentinel-consumption.json` with `tests/discovery_runtime/test_sentinel_consumption_fixture.py` and `extensions/drm-copilot/test/discovery-sentinel.contract.test.ts` (run in `qa-gates/p18-python-tests.2026-10-30T12-32.md` and `qa-gates/p18-typescript-extension-tests.2026-10-30T12-25.md`); P17-T3 records the fail-before run of the PowerShell contract suite (`regression-testing/p17-sentinel-contract-fail-before.2026-10-30T11-42.md`, `ExpectedExitCode: 1`); P17-T4 corrects `Get-DiscoverySessionObservation` and `Get-DiscoveryObservationEvidence` to prove consumption from the latch and rebuilds the test pair from the gate (the suite now passes in `qa-gates/p18-powershell-tests.2026-10-30T12-41.md`); P17-T5 runs the gate, the emitted TypeScript consumer and the probe over one real filesystem store (`regression-testing/p17-cross-runtime-smoke.2026-10-30T12-09.md`); P17-T6 mirrors the module (`other/p17-mirror-parity.2026-10-30T12-11.md`, re-verified in `qa-gates/p18-mirror-and-publication-contracts.2026-10-30T12-43.md`). The Minor (`consumeRootGrant` decodes every `root-grants/` entry strictly and nothing prunes) and the Nit (the `SHELL` deny observation is matched by `agent_id` only) are deferred to follow-up issues #1007 and #1008 by user decision (`other/p17-deferred-findings.2026-10-30T12-13.md`); no Phase 17 task changes the corresponding code. The criterion stays unchecked until the independent re-review of cycle 2 reports no blocking defect; the executor self-review of P18-T7 is not a substitute for it. |

## Quality criteria re-cited from Phase 18 evidence

| ID | Status | Phase 18 proof |
| --- | --- | --- |
| AC-59 Python gates | checked | `qa-gates/p18-python-{format,lint,types,tests}.2026-10-30T12-32.md` (Black 979 unchanged, Ruff clean, Pyright 0 errors, 15795 passed, 96.69% lines, 93.62% branches, threshold gate exit 0; `p18-python-coverage.2026-10-30T12-32.json` retained); totals beside the baseline in `qa-gates/p18-coverage-comparison.2026-10-30T12-43.md` (P18-T1) |
| AC-60 TypeScript gates | checked | `qa-gates/p18-typescript-root-install.2026-10-30T12-25.md` (clean root `npm ci`, empty porcelain status) and `qa-gates/p18-typescript-extension-{format,lint,types,tests}.2026-10-30T12-25.md` (323 suites / 5239 tests, 97.04% lines / 93.65% branches with every per-file threshold), the retained `p18-typescript-extension-lcov.2026-10-30T12-25.info` and `p18-typescript-extension-coverage-summary.2026-10-30T12-25.json` (P18-T2); the root package is not re-run in this cycle by plan decision, and its P16-T2 evidence stands |
| AC-61 PowerShell gates | checked | `qa-gates/p18-powershell-{format,analyze,tests}.2026-10-30T12-41.md` (1241 files already formatted, analyzer no findings, 13091 tests / 0 failed / 10 pre-existing skips, 93.41% lines, canonical coverage file equal to the evidence copy) with `p18-powershell-junit.2026-10-30T12-41.xml` and `p18-powershell-coverage.2026-10-30T12-41.xml` (P18-T3); the changed module at 99.46% with every cycle-changed line covered in `qa-gates/p18-coverage-comparison.2026-10-30T12-43.md` (P18-T4); the shard matrix and the dedicated shuffled-order runs are not repeated in this cycle by plan decision, and the P16-T3 and P16-T5 evidence stands |
| AC-63 All tests pass | checked | the three Phase 18 language loops above (P18-T1 to P18-T3), the P18-T3 single process as the CI-shaped order check of this cycle, and the contract suites in `qa-gates/p18-mirror-and-publication-contracts.2026-10-30T12-43.md` (77 passed) |
| AC-66 Current docs and generated assets | checked | P17-T6 mirror parity (`other/p17-mirror-parity.2026-10-30T12-11.md`); P17-T7 documentation (`## Protected records` and `## Capability probe` in `enforcement.md` state the latch contract, documentation suite 32 passed, `never rewritten` present; `other/p17-execution-environment-check.2026-10-30T12-13.md`: no brief fact changed; cycle-2 status lines in `spec.md` and `user-story.md`; `completion-report.md` and `handoff.md` requalified); P18-T5 zero mirror differences, zero generator drift and passing publication contracts (`qa-gates/p18-mirror-and-publication-contracts.2026-10-30T12-43.md`), file size (`qa-gates/p18-file-size.2026-10-30T12-43.md`) and evidence locations (`qa-gates/p18-evidence-locations.2026-10-30T12-44.md`) |

AC-62 (conditional C# gates) and AC-65 (canonical evidence) keep their P16-T9 citations; AC-65 additionally has `qa-gates/p18-evidence-locations.2026-10-30T12-44.md` (exit 0 on the final cycle-2 tree). No criterion was restored to unchecked: each of the five re-cited criteria has its Phase 18 proof above.

## Review findings of 2026-10-30T10-19 and their closing tasks

| Finding | Closing task | Evidence |
| --- | --- | --- |
| R5 (Blocker): sentinel consumption contract differs between the TypeScript consumer and the PowerShell probe | P17-T2, P17-T3, P17-T4, P17-T5; mirrored by P17-T6 | `tests/fixtures/discovery_host/sentinel-consumption.json`; `regression-testing/p17-sentinel-contract-fail-before.2026-10-30T11-42.md`; `qa-gates/p18-powershell-tests.2026-10-30T12-41.md` (the contract suite passes); `regression-testing/p17-cross-runtime-smoke.2026-10-30T12-09.md`; `other/p17-mirror-parity.2026-10-30T12-11.md` |
| Minor: strict decode of every `root-grants/` entry and no pruning | deferred to #1007 by user decision | `other/p17-deferred-findings.2026-10-30T12-13.md` |
| Nit: `SHELL` deny observation matched by `agent_id` only | deferred to #1008 by user decision | `other/p17-deferred-findings.2026-10-30T12-13.md` |
| `## Capability probe` sentence of `enforcement.md` | P17-T7 | `docs/engineering/legacy-discovery-and-parity/enforcement.md` (`never rewritten`), documentation contracts 32 passed |

## Deliverables

Unchanged set D01 to D22. D15 Publication keeps the P16-T6 digests (no distributable was rebuilt in this cycle, as the plan states; a rebuild after the merge produces new digests per `handoff.md`). D20 Final feature audit: pending (independent re-review of cycle 2). D22 Follow-on handoff: `handoff.md` with the cycle-2 delivery status and the two deferred follow-ups.

## Remaining review- and CI-dependent items

AC-64 "Feature review reports no blocking defects.", the seeded condition "Applicable complete language/repository quality loops, coverage and isolation checks, and final full feature review.", deliverable D20, and exact-head CI on the pull request the orchestrator opens. The two deferred follow-ups #1007 and #1008 are not preconditions of the cycle-2 exit gate.
