# P11-T10 Acceptance-criteria status (AC-01–AC-66, D01–D22, Definition of Done, seeded conditions)

Timestamp: 2026-10-26T02-57
Task: [P11-T10] Reconcile acceptance evidence and the publication handoff.
Command: `poetry run python SCRATCH/issue-980-p11t10-checkoff.py SCRATCH/issue-980-p11t10-verified-criteria.txt spec.md user-story.md` (38 criteria flipped from `- [ ]` to `- [x]` in each file by exact text, no criterion text changed); `poetry run python SCRATCH/issue-980-p11t10-checkoff.py SCRATCH/issue-980-p11t10-retained-checklists.txt spec.md` (5 Definition of Done and 11 seeded-condition items); `grep -c "^- \[x\]"` and `grep -n "^- \[ \]"` on both files
EXIT_CODE: 0 (every check-off reported `checked=38` and `checked=16`, no `MISSING` line)
Output Summary: After reconciliation `spec.md` and `user-story.md` each carry 64 of 66 acceptance criteria checked; the two unchecked criteria in each file are "Every new agent has a SubagentStop output validator." (receipt-accepting branch proven in process only, installed receipt path blocked) and "Feature review reports no blocking defects." (independent review pending; the executor self-review reports one Blocker). The retained `spec.md` checklists stand at Definition of Done 5 of 7 (unchecked: behavior in all documented environments, telemetry not applicable) and Seeded Test Conditions 11 of 12 (unchecked: the final full feature review). C# applicability is conditional and no C# was added. Package versions and digests are those of the final P11-T7 build. No criterion text was changed and no completion is claimed.
Result: PASS (reconciliation complete; two criteria and two retained items remain pending on the escalated blocker and the independent review)

AC identifiers follow the order of the `## Acceptance Criteria` section of `spec.md` (identical in `user-story.md`); task identifiers refer to `plan.2026-10-17T22-38.md`; evidence paths are relative to `evidence/`.

## AC-01–AC-66

| ID | Criterion | Status | Implementing tasks | Evidence and tests |
| --- | --- | --- | --- | --- |
| AC-01 | Reusable framework exists | checked | P1-T1, P2, P3, P6-T1–T3, P11-T1 | `regression-testing/discovery-public-workflows.2026-10-22T22-01.md`; `tests/discovery_runtime/test_public_*` |
| AC-02 | No TaskMaster/TMW core behavior | checked | P1-T1, P4-T9, P10-T4 | `qa-gates/p11t8-source-neutrality.2026-10-26T02-42.md`; `analyzer/test_domain_neutrality.py`, `test_stack_neutrality.py` |
| AC-03 | Local domain profile | checked (P1) | P1-T2–T10, P6-T1 | `other/p1t10-profile-boundary.2026-10-18T07-11.md`; `test_profile_v2.py`, `test_configuration.py` |
| AC-04 | Nonparticipants unaffected | checked | P9-T2–T5, P11-T7 | disabled-case smoke in `qa-gates/discovery-native-capabilities.2026-10-23T13-49.md`; inactive-workspace allow paths in the hook suites |
| AC-05 | Generic agents | checked | P7-T1, P7-T3, P10-T1 | `regression-testing/p10t1-native-bundle-publication-contract.2026-10-22T18-28.md`; `legacy-discovery-agent-roles.Tests.ps1`, `test_discovery_publication_contracts.py` |
| AC-06 | Generic skills | checked | P7-T2, P7-T3, P10-T1 | same; `test_legacy_discovery_skills_contracts.py` |
| AC-07 | Authorized writes only | checked | P8-T3, P9-T2, P11-T7 | tool-gate denials (Bash, Write) and grants in `discovery-native-capabilities.2026-10-23T13-49.md`; `DiscoveryAuthorization.Tests.ps1`, `discovery-authorization*.test.ts` |
| AC-08 | Stop validator per agent | unchecked | P8-T5, P9-T4, P11-T7 | validators block fail-closed on three hosts (observed); receipt-accepting branch in `DiscoveryStop.Tests.ps1`, `discovery-finalization*.test.ts` only; installed receipt path blocked (`completion-report.md`) |
| AC-09 | Ecosystem availability | checked | P7-T3, P8-T9, P10-T1 | `qa-gates/p11t8-mirror-and-publication-contracts.2026-10-26T02-42.md` |
| AC-10–AC-14 | Schemas, examples, failures, references, extensions | checked (P2) | P2-T1–T9 | `tests/schemas`, `regression-testing/p2t*-contract*.md` |
| AC-15–AC-19 | Initialization | checked (P3) | P3-T1–T4, P6-T2 | `regression-testing/p3t*-contracts*.md`; installed `init` dry-run, write, repeat in `qa-gates/discovery-installed-runtime.2026-10-23T14-13.md` |
| AC-20–AC-21 | Individual and complete validators | checked (P2/P3) | P2-T5–T8, P3-T5 | console sweep and smoke steps |
| AC-22 | Nonzero blocking exits | checked | P6-T1–T3, P11-T7 | exits 1/2/3 observed in `discovery-installed-runtime.2026-10-23T14-13.md`; `test_cli_errors.py`, `test_gateway.py` |
| AC-23–AC-24 | Reports; completion checks | checked (P5) | P5-T1–T5 | `regression-testing/p5t*-contracts*.md` |
| AC-25–AC-30 | Evidence for verified claims; unknown records; runtime evidence; disposition gate; required dimensions; planning prerequisite | checked | P2-T7–T9, P5-T1–T3, P9-T5 | `test_claim_rules.py`, `test_evidence_rules.py`, `test_completion_rules.py`, `test_dimension_rules.py`; `regression-testing/p9t5-native-planning-gate-contract.2026-10-22T16-56.md`; installed discovery-complete exit 1 |
| AC-31–AC-36 | Analyzers | checked (P4) | P4-T1–T9 | `regression-testing/p4t*-final-contracts*.md` |
| AC-37 | Python authority | checked | P6-T1, P8-T1, P8-T6 | `regression-testing/p8t1-runtime-transport-contract.2026-10-22T10-48.md`; no hook invokes Python (`enforcement-hooks-no-python-invocation.Tests.ps1`) |
| AC-38 | Documented and tested CLI | checked | P6-T3, P10-T4, P11-T7 | 31 entries in the console sweep; `test_cli_*.py`; documentation contracts |
| AC-39 | MCP functions | checked | P8-T6, P8-T7, P11-T7 | 42 tools over stdio in `discovery-installed-runtime.2026-10-23T14-13.md`; `mcp-*discovery*.test.ts` |
| AC-40 | VS Code wrappers | checked | P8-T7 | `regression-testing/p8t7-discovery-command-contract.2026-10-22T12-53.md`; `extension.discovery-commands.test.ts` |
| AC-41 | Thin wrappers | checked | P8-T1, P8-T6 | gateway client transport suites; `discovery-public-workflow.test.ts` |
| AC-42 | Workspace path safety | checked | P1-T11, P3-T4, P9-T1 | `other/p1t11-path-policy.2026-10-18T07-30.md`; `test_path_policy.py`, `test_path_resolution.py`, `DiscoveryAuthority.Tests.ps1` |
| AC-43–AC-45 | Claude, Codex, Copilot publication | checked | P7-T3, P8-T9, P10-T1, P11-T7 | probes supported and hooks attested on each host (`discovery-native-capabilities.2026-10-23T13-49.md`); generator check zero drift |
| AC-46 | Publication validation | checked | P10-T1–T3, P11-T8 | `qa-gates/discovery-repository-contracts.2026-10-26T02-42.md`, `p11t8-packaging-closure.2026-10-26T02-42.md` |
| AC-47 | No unsupported references | checked | P10-T1, P11-T8 | packaging inspector `DEFECTS=0`, no unresolved resource reference; documentation contracts |
| AC-48–AC-52 | Acceptance scenarios | checked (P5) | P5-T4–T5 | `test_acceptance_*.py` |
| AC-53–AC-58 | Documentation | checked | P10-T4, P10-T5 | `qa-gates/p10t4-documentation-contract.2026-10-22T19-11.md`, `p10t5-publication-handoff-contract.2026-10-22T19-17.md`; `test_discovery_documentation_contracts.py` |
| AC-59 | Python gates | checked | P11-T2, P11-T5, P11-T7 | `qa-gates/p11t7-python-tests.2026-10-26T02-32.md` (15504 passed, 96.68% / 93.61%) |
| AC-60 | TypeScript gates | checked | P11-T3, P11-T7 | `qa-gates/typescript-*.2026-10-23T02-25.md`; final extension rerun 4997 passed |
| AC-61 | PowerShell gates | checked | P11-T4, P11-T6, P11-T7 | `qa-gates/powershell-*.2026-10-23T03-*.md`; 12138 passed, 93.13% lines; three seeded orders |
| AC-62 | Conditional C# gates | checked (conditional) | none | no C# file is added or changed on the branch (`SCRATCH/issue-980-branch-files.txt` holds no `.cs` path); no waiver is claimed for any future addition |
| AC-63 | All tests pass | checked | P11-T2–T8 | final populations above |
| AC-64 | No blocking review defects | unchecked | P11-T9 (not accepted) | `qa-gates/self-review.2026-10-26T02-48.md` reports one Blocker; independent review pending |
| AC-65 | Canonical evidence | checked | P0, every task | every artifact under `evidence/<kind>/` with the required fields |
| AC-66 | Current docs and generated assets | checked | P10-T1, P10-T4, P11-T8 | generator check zero drift; documentation contracts pass |

## D01–D22

| Deliverable | Status | Evidence |
| --- | --- | --- |
| D01 Active feature documentation | delivered | `issue.md`, `spec.md`, `user-story.md`, `requirements-traceability.md`, `completion-report.md` |
| D02 Research | delivered | `research/2026-10-18T02-40-*.md` |
| D03 Specification | delivered | `spec.md` with normative decisions |
| D04 Atomic plan | delivered | `plan.2026-10-17T22-38.md` (81 tasks accepted, P11-T9 not accepted) |
| D05 Agents | delivered | four canonical roles, Codex families (P7-T1, P7-T3, P10-T1) |
| D06 Skills | delivered | nine workflows, seven aliases (P7-T2) |
| D07 Schemas | delivered | v1 frozen and v2 catalogs (P2) |
| D08 Validators | delivered | rule modules and adapters (P2, P3, P5) |
| D09 Hooks | delivered with one limit | native start/tool/stop/planning adapters (P9); receipt path blocked on installed hosts |
| D10 Templates | delivered | `docs/discovery/templates/v2` (P3-T1) |
| D11 CLI | delivered | 31 `dev.discovery.*` entries (P6-T3) |
| D12 Analyzers | delivered | generic set plus isolated optional adapter (P4) |
| D13 MCP | delivered with one limit | 42 tools; `finalize_discovery_agent` and agent-scoped reads refused by the installed runtime |
| D14 VS Code | delivered | justified commands (P8-T7) |
| D15 Publication | delivered | bundles, manifests, VSIX, npm, wheel (P10-T1–T3, P11-T7, P11-T8) |
| D16 Tests | delivered | populations and categories above |
| D17 User and maintainer docs | delivered | `docs/engineering/legacy-discovery-and-parity/` (P10-T4) |
| D18 Architecture diagram | delivered | Mermaid in `spec.md` and the architecture page |
| D19 Consumer structure | delivered | default root table and trees (P10-T4, P10-T5) |
| D20 Final feature audit | pending | independent review not yet run |
| D21 Completion report | delivered | `completion-report.md` (no unverified completion claim) |
| D22 Follow-on handoff | delivered | `handoff.md` with final digests and the known installed-host limit |

## Definition of Done (7) and seeded conditions (12)

- Definition of Done: checked "Acceptance criteria documented and mapped", "Tests updated/added", "Edge cases and error handling covered", "Docs updated", "Toolchain pass completed"; unchecked "Behavior matches acceptance criteria in all documented environments" (installed receipt path) and "Telemetry/logging added or updated (if applicable)" (not applicable: the feature adds no telemetry; left unchecked rather than claimed).
- Seeded conditions: all eleven implementation conditions checked with their suites (schema, cross-artifact, completion gates, initialization, analyzers, reports, scenario generation, agent and hook validation, CLI examples, integration, publishing); "Applicable complete language/repository quality loops, coverage and isolation checks, and final full feature review" unchecked pending the independent review.

## Package versions, limits and compatibility

- Wheel 2.0.0 `19e7dd456d854f02503cbfe36cc1b175b1582ee25ce0506beff4c2977121ccdd`; VSIX 1.1.22 `a3bf8eedd136b8fe23911e259d232d4eccd1a4db3b3aa58f829f0f132acbd52a`; npm 1.1.22 `1e1709064ff100e3972738397f8ea1ea6e1690932bf91535b099aa42166eae2a` (`handoff.md`, superseding the P10-T2/P10-T3 digests).
- Known limits: installed receipt path (above); Codex ordinary-agent start replays collide on the exclusive routing attestation (pre-existing); the local-user doctor reports native capability unavailable by contract.
- Backward compatibility: v1 artifacts readable and migratable; retired validators keep their compatibility aliases (`regression-testing/p9t7-retired-validator-compatibility-contract.2026-10-22T18-11.md`).
- Remaining local consumer work: `handoff.md` "Per-repository local work" and "Open items", plus the installed-host limit.
