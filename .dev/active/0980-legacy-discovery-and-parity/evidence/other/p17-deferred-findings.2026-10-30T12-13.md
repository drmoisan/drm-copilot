# P17-T7 Deferred findings of the 2026-10-30T10-19 review (user decision)

Timestamp: 2026-10-30T12-13
Task: [P17-T7] Document the consumption contract, record the deferred findings and requalify the status lines.
Command: none (this record states a user decision and the scope of Phase 17; it runs no tool)
EXIT_CODE: 0
Output Summary: By user decision, recorded as final in the plan's `## Revision: remediation cycle 2 (sentinel consumption contract)`, remediation cycle 2 fixes only the Blocker R5 of the review set `{policy-audit,code-review,feature-audit,remediation-inputs}.2026-10-30T10-19.md`. The review's Minor and Nit are deferred to follow-up issues #1007 and #1008; no Phase 17 task changes the corresponding code.

## Deferred findings

| Review citation | Finding | Follow-up issue | Scope statement |
| --- | --- | --- | --- |
| `code-review.2026-10-30T10-19.md`, Findings Table, severity Minor, file `extensions/drm-copilot/src/discovery-root-grant.ts` (`consumeRootGrant` candidate scan); restated in `policy-audit.2026-10-30T10-19.md` `### Identified Gaps` ("Root-grant partition growth and strict decode") and in `remediation-inputs.2026-10-30T10-19.md` `## Non-blocking items` | Every root call lists `root-grants/` and decodes every `.json` entry strictly, and nothing prunes consumed or expired grants; one malformed or partially written file refuses every subsequent root call for the workspace, including doctor, and the per-call cost grows with the session history | #1007 | No task in Phases 17 or 18 changes `extensions/drm-copilot/src/discovery-root-grant.ts`, the gate writers or the root-grant partition layout |
| `code-review.2026-10-30T10-19.md`, Findings Table, severity Nit, file `.claude/lib/discovery-validation/DiscoveryCapability.psm1` (the `SHELL` candidate selection in `Get-DiscoveryObservationEvidence`); restated in `policy-audit.2026-10-30T10-19.md` `### Identified Gaps` ("Shell observation not bounded") and in `remediation-inputs.2026-10-30T10-19.md` `## Non-blocking items` | The `SHELL` deny observation is matched by `agent_id` only and is not checked against the registered handler hash or the TTL window the sentinel tool observation receives | #1008 | P17-T4 changes the sentinel-tool acceptance of `Get-DiscoveryObservationEvidence` (consumption from the latch) and leaves the `SHELL` match unchanged, as the task text states |

## Closed in this cycle, for contrast

R5 (Blocker): closed by P17-T2 (shared fixture `tests/fixtures/discovery_host/sentinel-consumption.json` with the Python and TypeScript replays), P17-T3 (fail-before contract run, `evidence/regression-testing/p17-sentinel-contract-fail-before.2026-10-30T11-42.md`), P17-T4 (probe reads the `.consumed` latch; test pair built from the gate), P17-T5 (cross-runtime smoke, `evidence/regression-testing/p17-cross-runtime-smoke.2026-10-30T12-09.md`) and P17-T6 (mirrors, `evidence/other/p17-mirror-parity.2026-10-30T12-11.md`). The `## Capability probe` sentence of `docs/engineering/legacy-discovery-and-parity/enforcement.md` named by the remediation inputs is replaced by this task.

The orchestrator carries both issue numbers in the pull request description per the plan's `## Orchestrator continuation after executor handoff`; neither is a precondition of the cycle-2 exit gate.
