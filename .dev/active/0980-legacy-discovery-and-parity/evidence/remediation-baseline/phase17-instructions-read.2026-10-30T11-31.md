# Phase 17 instructions read and remediation baseline (remediation cycle 2)

Timestamp: 2026-10-30T11-31
Command: git status --porcelain; git branch --show-current; git merge-base origin/main HEAD
EXIT_CODE: 0
Output Summary: working tree clean (zero porcelain lines) on `feature/legacy-discovery-and-parity-980`; the scope anchor is the merge base of origin/main and HEAD; every policy file, the three review artifacts, the remediation inputs and the cycle-2 revision of the plan were read in full before any implementation task; no implementation has preceded this record (the only change since the review set is the preflight fix record `evidence/other/preflight-fixes.2026-10-30T11-29.md` with two in-place task-text anchor fixes in [P17-T2]).

## Policy Order (policy-compliance-order)

1. .github/copilot-instructions.md
2. .github/instructions/general-code-change.instructions.md
3. .github/instructions/general-unit-test.instructions.md
4. Language-specific, for the three languages Phase 17 and 18 touch:
   - .github/instructions/python-code-change.instructions.md
   - .github/instructions/python-unit-test.instructions.md
   - .github/instructions/powershell-code-change.instructions.md
   - .github/instructions/powershell-unit-test.instructions.md
   - .github/instructions/typescript-code-change.instructions.md
   - .github/instructions/typescript-unit-test.instructions.md

The runtime also loaded the mirrored rule files CLAUDE.md, .claude/rules/general-code-change.md, .claude/rules/general-unit-test.md, .claude/rules/quality-tiers.md, .claude/rules/tonality.md, .claude/rules/plan-acceptance-gates.md, .claude/rules/powershell.md, .claude/rules/typescript.md, .claude/rules/typescript-suppressions.md and .claude/rules/architecture-boundaries.md.

## Files read

Policy (in the order above): the nine files listed under Policy Order.

Review set (stamp 2026-10-30T10-19):
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/policy-audit.2026-10-30T10-19.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/code-review.2026-10-30T10-19.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/feature-audit.2026-10-30T10-19.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/remediation-inputs.2026-10-30T10-19.md

Plan of record: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md (preamble, `## Revision: remediation cycle 2 (sentinel consumption contract)` with its `### Real-host pre-mortem`, Phases 17 and 18, and the Set S dispositions).

Design sources re-derived for the cycle: .claude/lib/discovery-validation/{DiscoveryCapability,DiscoveryObservation,DiscoveryPayload,DiscoveryToolRouting,DiscoveryAuthorization,DiscoveryAuthority}.psm1; extensions/drm-copilot/src/{discovery-sentinel,discovery-authorization-record,discovery-authorization,discovery-authority-paths}.ts; tests/scripts/claude-lib/discovery-validation/{DiscoveryGate.TestSupport.ps1,DiscoveryCapability.Tests.ps1}; the three host probe suites; tests/fixtures/discovery_host/tool-authorizations.json with tests/discovery_runtime/test_tool_authorization_fixture.py and extensions/drm-copilot/test/{discovery-authorization-test-support,discovery-grant-test-support,discovery-invocation-test-support,discovery-store-test-helpers}.ts; schemas/discovery/v2/{host-observation,common,service-request}.schema.json; examples/discovery/v2/host-observation.example.yaml; docs/engineering/legacy-discovery-and-parity/enforcement.md; tests/scripts/dev_tools/test_discovery_documentation_contracts.py.

## Head state

- Branch: `feature/legacy-discovery-and-parity-980`
- `git status --porcelain`: empty
- Scope anchor: the merge base of origin/main and HEAD (derived with `git merge-base origin/main HEAD` at write time; the branch was rebased onto origin/main before the cycle-2 revision, so the root package manifest and lockfile changed through that rebase and the Phase 18 TypeScript gate begins with a clean root dependency install)

## The three findings of the 2026-10-30T10-19 review and their dispositions

| Finding | Severity | Disposition in this cycle |
| --- | --- | --- |
| R5: the sentinel tool consumes its grant by writing only the `.consumed` latch beside the observation record, while the probe (`Get-DiscoveryObservationEvidence`) requires the record's own `state` to read `consumed`; on every real host the probe reports `unsupported` and no root grant for `prepare_discovery_agent` can be written | Blocker (autonomous) | Closed in this cycle by P17-T2 (shared fixture pinned on the Python and TypeScript sides), P17-T3 (fail-before consumer contract run), P17-T4 (probe reads the latch; test pair built from the gate), P17-T5 (cross-runtime smoke over one real filesystem store); mirrored by P17-T6 |
| Minor: every root call decodes every entry under `root-grants/` strictly and nothing prunes consumed or expired grants (`consumeRootGrant` in extensions/drm-copilot/src/discovery-root-grant.ts) | Minor | Deferred to follow-up issue #1007 by user decision; no task in this plan changes ES/discovery-root-grant.ts; recorded by P17-T7 and the P18-T7 self-review |
| Nit: the `SHELL` deny observation is matched by `agent_id` only, without the handler-hash and TTL checks the sentinel tool observation receives | Nit | Deferred to follow-up issue #1008 by user decision; no task in this plan changes the `SHELL` match of `Get-DiscoveryObservationEvidence`; recorded by P17-T7 and the P18-T7 self-review |

The remediation inputs also ask that the `## Capability probe` sentence of docs/engineering/legacy-discovery-and-parity/enforcement.md stay accurate for the chosen contract; P17-T7 replaces it.

## Canonical consumption representation (cycle-2 revision, final)

A one-use record the gate writes (`tool-authorization`, `root-grant`, the sentinel `host-observation`) is immutable once published; its `state` is `issued` as written, or `revoked`. Consumption by the MCP server is the exclusive sibling latch `<record>.json.consumed`, a JSON object naming the record's reference (`request_id`, `grant_ref` or `observation_ref`) and `consumed_at`; dispatch by the Python runtime is the exclusive sibling latch `<record>.json.used`. The producer never rewrites the record and every reader decides from the latch: a record is live only when its `state` is `issued` and no `.consumed` latch exists, and consumed when the latch exists. The probe additionally requires the latch's `observation_ref` to equal the record's, so a latch beside the wrong record proves nothing, and it does not parse `consumed_at` (the TypeScript consumer writes millisecond precision; the shared fixture pins the exact latch text). The consumer side (`consumeSentinelGrant`) does not change; the probe is corrected to read the latch. The tool-authorization `consume()` keeps its record rewrite because `decode_authorization` in the Python runtime reads `consumed_at` from that record; no task changes tool authorizations. The `state` enum of the host-observation schema is unchanged; `consumed` stays admissible for a decoder but is never written by this repository.

Option (b) of the review's two acceptable remedies is the chosen one: it changes fewer files and keeps the record immutable.

## Remediation baseline: gate figures the review verified

| Language | Figure | Source artifact |
| --- | --- | --- |
| Python | 96.69% lines (32061/33160), 93.59% branches (11613/12408); 15728 passed, 6 skipped | evidence/qa-gates/p16-python-tests.2026-10-30T00-42.md and evidence/qa-gates/p16-python-coverage.2026-10-30T00-42.json; the review parsed artifacts/python/lcov.info (the executor's JSON report reads 93.62% branches, 11659/12454) |
| TypeScript, extension | 97.04% lines (61352/63223), 93.64% branches (9333/9967); 5177 passed | evidence/qa-gates/p16-typescript-extension-tests.2026-10-30T01-40.md with the retained p16-typescript-extension-lcov.2026-10-30T01-40.info and p16-typescript-extension-coverage-summary.2026-10-30T01-40.json (the summary reads 93.63% branches) |
| TypeScript, root | 98.20% lines (67200/68434), 93.37% branches (9973/10681); 5194 passed | evidence/qa-gates/p16-typescript-root-tests.2026-10-30T01-40.md with the retained p16-typescript-root-lcov.2026-10-30T01-40.info and p16-typescript-root-coverage-summary.2026-10-30T01-40.json |
| PowerShell | 93.34% lines (20188/21629); 12744 tests, 12734 passed, 0 failed, 10 pre-existing skips | evidence/qa-gates/p16-powershell-tests.2026-10-30T01-29.md and evidence/qa-gates/p16-powershell-coverage.2026-10-30T01-29.xml |

Review verdict: REMEDIATION_REQUIRED, proportionate mode; one blocking finding (R5), one Minor and one Nit as tabled above; every finding of the 2026-10-29T13-16 review verified resolved in code.

## Scratch location

SCRATCH resolves to the session scratchpad under `issue-980/`; scratch file names of this cycle start with `issue-980-p17-` or `issue-980-p18-`. No scratch path is recorded in evidence.
