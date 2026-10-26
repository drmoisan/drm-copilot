# Completion report: legacy discovery and parity (issue #980)

- Issue: #980
- Branch: `feature/legacy-discovery-and-parity-980` (merge base with `origin/main` derived at reconciliation time; 140 commits on the branch)
- Plan: `plan.2026-10-17T22-38.md` (82 tasks; P11-T9 not accepted, see below)
- Reconciled: 2026-10-26T02-54 by the executor (this report records executor-verified evidence only; independent review and exact-head CI are pending and are not claimed)

## Status in one paragraph

Every implementation task of the plan (P0 through P10 and P11-T1 through P11-T8) is accepted with canonical evidence, and the final sources pass every language loop (Python 15504 tests at 96.68% lines / 93.61% branches; TypeScript extension 4997 tests at 97.15% / 93.53% and root 5013 tests at 98.2% / 93.23%; PowerShell 12138 tests at 93.13% lines), the isolation runs, the repository and publication contracts, and the independent installed-runtime smoke on Claude Code, Codex and GitHub Copilot. The feature is **not complete**: the complete checklist self-review (P11-T9) reports one Blocker and one Major finding that lie outside this plan's correction scope, so P11-T9 remains unchecked, the acceptance criteria that depend on the installed completion-receipt path remain unchecked, and the independent feature review (AC-64) and exact-head CI have not run.

## Acceptance criteria

Source files: `spec.md` and `user-story.md` (`## Acceptance Criteria`, 66 criteria each, identical text). Per-criterion mapping to tasks, artifacts and tests: `evidence/qa-gates/acceptance-criteria-status.2026-10-26T02-57.md`; the criterion counts after reconciliation are 64 checked and 2 unchecked in each file.

Unchecked criteria and why:

| Criterion | Reason |
| --- | --- |
| Every new agent has a SubagentStop output validator. | The validators exist for all four roles on all three hosts and block fail-closed (observed in P11-T7), but their receipt-accepting branch cannot be exercised on an installed host because the runtime cannot mint a receipt (blocker below); proven in process only. |
| Feature review reports no blocking defects. | The executor self-review reports one Blocker; the independent feature review has not run. |

Retained checklists in `spec.md`: Definition of Done 5 of 7 checked (unchecked: "Behavior matches acceptance criteria in all documented environments" because of the blocker; "Telemetry/logging added or updated (if applicable)" not applicable, the feature adds no telemetry surface and the item is left unchecked rather than claimed); Seeded Test Conditions 11 of 12 checked (unchecked: the final full feature review).

## Quality gates (final sources)

| Gate | Result | Evidence |
| --- | --- | --- |
| Python format, lint, types | Black 946 files unchanged; Ruff clean; Pyright 0 errors | `evidence/qa-gates/discovery-installed-runtime.2026-10-23T14-13.md` |
| Python tests with coverage | 15504 passed, 6 skipped; 96.68% lines, 93.61% branches; threshold check 85/75 passed | `evidence/qa-gates/p11t7-python-tests.2026-10-26T02-32.md` |
| TypeScript (root and extension) | Prettier, ESLint, tsc clean; root 315 suites / 5013 tests 98.2% / 93.23%; extension 312 suites / 4997 tests 97.15% / 93.53%, per-file thresholds met | `evidence/qa-gates/typescript-*.2026-10-23T02-25.md`, `discovery-installed-runtime.2026-10-23T14-13.md` |
| PowerShell | PoshQC format no change; PSScriptAnalyzer no findings; Pester 12138 passed / 0 failed / 10 pre-existing skips; 93.13% lines (no branch metric) | `evidence/qa-gates/powershell-*.2026-10-23T03-*.md`, `p11t7-powershell-loop.2026-10-23T08-31.md`, `discovery-installed-runtime.2026-10-23T14-13.md` |
| Coverage deltas and T2 rigor | 254 changed production files at the floors, added files >= 90%, changed lines covered; property and mutation inventories recorded | `evidence/qa-gates/coverage-comparison.2026-10-23T08-18.md`, `tier-properties-mutation.2026-10-23T04-16.md` |
| Isolation | seeded Jest, reversed Python, three Pester seeds, CI-shaped single process | `evidence/regression-testing/discovery-isolation.2026-10-23T10-09.md` |
| Repository and publication contracts | zero drift, 9523 + 1024 contract tests, tiers 27/27, packaging closures DEFECTS=0 | `evidence/qa-gates/discovery-repository-contracts.2026-10-26T02-42.md` |
| Installed runtime and native controls | 31 console entries, 42 MCP tools, probes and start/tool/stop hooks on three hosts; six installed-host defects repaired | `evidence/qa-gates/discovery-installed-runtime.2026-10-23T14-13.md`, `discovery-native-capabilities.2026-10-23T13-49.md` |
| Self-review | 118 rows: 108 PASS, 8 N/A, 2 FAIL | `evidence/qa-gates/self-review.2026-10-26T02-48.md` |

## Open blockers (escalated, outside this plan)

1. **Installed completion-receipt path.** The Python runtime has no host-principal service composition (`service._local`, `gateway_local.installed_local_io`), so `finalize-agent` and agent-scoped `read-source` are refused for both principals and no `validation-receipt` can be minted on an installed host. Required plan delta: a host-principal `ServiceIO` that reads the protected invocation, start attestation and tool-authorization records and supplies `ServiceAuthority(principal="host", invocation=...)` to the existing finalize flow, plus the installed smoke cases for finalize, agent read, receipt-accepting stop and stale-receipt block.
2. **Pre-existing over-limit files extended.** `scripts/dev_tools/agentic_sync.py` (820 lines) and `tests/scripts/dev_tools/test_agentic_sync.py` (598) were above 500 lines at the merge base and grew by one and twelve lines in P8-T9; a follow-up splits the publisher's folder tables and their tests.

## Review, CI and orchestration

- Independent feature review (policy audit, code review, feature audit): pending; the orchestrator continues the mandatory lifecycle after this executor handoff.
- Exact-head CI: pending; the branch is pushed and current with `origin/main` at the time of the last acceptance.
- Orchestrator checkpoint: `artifacts/orchestration/orchestrator-state.json` records 81 verified tasks through P11-T8; P11-T9 is recorded as not accepted in `requirements-traceability.md`.

## Backward compatibility and known limits

- v1 artifacts remain readable through the frozen v1 catalog and the `migrate` operation; the retired validators keep their compatibility aliases (`evidence/regression-testing/p9t7-retired-validator-compatibility-contract.2026-10-22T18-11.md`).
- Analyzer limits: the generic repository analyzer and the .NET/C# analyzer classify facts versus inference; the VSTO adapter is optional and isolated; no analyzer executes consumer code.
- Host limits: Codex ordinary-agent starts replayed with a reused agent id collide on the exclusive routing attestation (pre-existing ordinary hook behavior, observed in P11-T7); the Python doctor under the `local-user` principal reports native capability as unavailable by contract, the host doctor projects the session attestation.
- Package versions: wheel 2.0.0, extension and npm package 1.1.22; digests in `handoff.md`.

## Executor handoff (P11-T11)

- Plan state: 83 of 84 tasks of `plan.2026-10-17T22-38.md` are checked (P0-T1 through P11-T8, P11-T10 and P11-T11); P11-T9 is unchecked because its acceptance requires no FAIL row and two rows are escalated. The plan validates through the installed MCP validator and the branch-current Python CLI; the orchestrator checkpoint `artifacts/orchestration/orchestrator-state.json` validates through both and records every accepted task with its commit; a proof check over the checkpoint and `requirements-traceability.md` confirms that each checked task names at least one existing canonical artifact (`evidence/qa-gates/p11t11-handoff-validation.<timestamp>.md`).
- Baseline references: `evidence/baseline/python-tests.2026-10-18T03-51.md`, `typescript-root-tests.2026-10-18T03-55.md`, `typescript-extension-tests.2026-10-18T03-58.md`, `powershell-tests.2026-10-18T04-21.md`, `initial-file-inventory.2026-10-18T03-48.json`, `evidence/other/phase0-instructions-read.2026-10-18T03-48.md`.
- Final references: `evidence/qa-gates/p11t7-python-tests.2026-10-26T02-32.md`, `typescript-{root,extension}-{format,lint,types,architecture,tests,build}.2026-10-23T02-25.md`, `powershell-{format,analyze}.2026-10-23T03-17.md`, `powershell-{tests,single-process,shards,coverage-files}.2026-10-23T03-27.md`, `p11t5-{python,powershell}-loop.*.md`, `discovery-installed-runtime.2026-10-23T14-13.md`, `discovery-native-capabilities.2026-10-23T13-49.md`, `discovery-repository-contracts.2026-10-26T02-42.md` with its seven command-step records.
- Coverage references: `evidence/qa-gates/coverage-comparison.2026-10-23T08-18.md`, `python-coverage-metrics.2026-10-23T07-57.json`, `tier-properties-mutation.2026-10-23T04-16.md`, `evidence/other/t2-property-inventory.2026-10-23T04-16.md`, `mutation-trend.2026-10-23T04-16.json`.
- Isolation and regression references: `evidence/regression-testing/discovery-isolation.2026-10-23T10-09.md` with its five per-run records, `discovery-public-workflows.2026-10-22T22-01.md`, the P2–P10 contract records.
- Self-review: `evidence/qa-gates/self-review.2026-10-26T02-48.md` (118 rows, 2 FAIL escalated).
- Package and handoff: `handoff.md` (final digests, publication prerequisites, per-repository work, installed-host limit), `evidence/qa-gates/acceptance-criteria-status.2026-10-26T02-57.md`, `docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md`.
- Remaining review- and CI-dependent acceptance items: AC-64 "Feature review reports no blocking defects." and the seeded condition "final full feature review" (independent review); Definition of Done "Behavior matches acceptance criteria in all documented environments" and AC-08 (receipt path, escalated); exact-head CI on the pull request the orchestrator opens (no pull request was opened by the executor).
- Required plan delta for the next cycle: (1) a host-principal service composition in the Python runtime (`gateway_local` or a sibling module) that reads the protected invocation, start attestation and tool-authorization records and supplies `ServiceAuthority(principal="host", invocation=...)` so `service._local`'s refusal of `prepare-agent`, `finalize-agent`, agent-output mode and references is replaced by a verified host path, with the installed smoke cases finalize, agent read, receipt-accepting stop and stale-receipt block; (2) a split of `scripts/dev_tools/agentic_sync.py` and `tests/scripts/dev_tools/test_agentic_sync.py` below 500 lines.

## Remaining local consumer work

Unchanged from `handoff.md` (interpreter and wheel, host package, push-down, probe, initialize and activate, source discovery, target work), with the installed-host limit above: agent-driven finalize and receipt-gated planning are unavailable until the next plan ships the host-principal composition.
