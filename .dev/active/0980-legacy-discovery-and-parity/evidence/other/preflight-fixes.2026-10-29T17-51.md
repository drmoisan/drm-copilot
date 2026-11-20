# Preflight fixes — remediation cycle 1 (Phases 15 and 16)

Timestamp: 2026-10-29T17-51
Plan: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md
EXIT_CODE: 0
Output Summary: plan validation passed before and after the fixes below; single-pass review of every Phase 15 and Phase 16 task against the tree found four trivial defects and no substantive defect.

Scope of the pass: every file, symbol, heading, test name and parameter name cited by [P15-T1] through [P16-T11], the Set P, Set Q and Set R dispositions, the revision section `## Revision: remediation cycle 1 (host identity from hook payloads)`, and the Pre-Mortem bullets that name Phase 15 and 16 tasks.

## Fixes (task text only; no task added, removed or reordered)

1. [P15-T3] | stale anchor | `$script:CorrelationIdPattern` is defined in CL/DiscoveryStart.psm1, CL/DiscoveryStop.psm1, CL/DiscoveryAuthorization.psm1 and CL/DiscoveryAuthority.psm1 but not in CL/DiscoveryPayload.psm1, where the task applies it. The task text now states that the pattern is added to CL/DiscoveryPayload.psm1 with the same value CL/DiscoveryStart.psm1 defines. The assertion (agent id must match the correlation pattern) is unchanged.
2. [P15-T4] | stale anchor list | The parenthetical list of entry scripts that import DiscoveryAuthorization.psm1 named three scripts that do not import it (XH/discovery-capability-probe.ps1 dot-sources XH/enforce-discovery-artifact-gate.ps1; .github/hooks/discovery-capability-probe.ps1 imports only DiscoveryCapability.psm1; scripts/dev-tools/Test-DiscoveryHostCapability.ps1 imports no module) and omitted the three planning-gate scripts that do import it (CH/enforce-discovery-planning-gate.ps1, XH/enforce-discovery-planning-gate.ps1, .github/hooks/discovery-planning.ps1), whose module CL/DiscoveryPlanning.psm1 calls the moved `Resolve-DiscoveryToolName`. The list now matches the task's own rule ("every entry script that imports DiscoveryAuthorization.psm1"), and the three planning-gate suites are added to the run list so the move is proven on those entry points.
3. [P15-T5] | evidence filename spelling | `E2/{root-grant,host-observation}.example.json` is corrected to `.example.yaml`, the existing convention of examples/discovery/v2 (for example start-attestation.example.yaml). The fixture set and the assertions are unchanged.
4. [P15-T9] | stale assumption about the matcher shape | The `enforce-discovery-artifact-gate.ps1` PreToolUse matcher in .claude/settings.json (`Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|WebFetch|WebSearch|mcp__.*`) and the Codex matcher in .codex/config.toml (`^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$`) already admit the sentinel tool name through `mcp__.*`. The task now confirms admission instead of editing the matchers. The claude-settings.Tests.ps1 assertion that the matcher admits the sentinel tool (Set P) and the acceptance that the four role matchers are unchanged are both unchanged.

## Checked and found consistent (no change)

- Every PowerShell function and `$script:` variable named by P15-T3 through P15-T11 exists in the module the task names, with the parameter names the task removes or keeps (`-Environment`, `-HostEnvironment`, `-HandlerSha256`, `-Store`, `-Now`, `-Nonce`, `-TtlSeconds`, `-SentinelDecision`, `-AgentType`).
- Every TypeScript export named by P15-T12 through P15-T15 exists; `DISCOVERY_ENVIRONMENT_KEYS` carries six identity keys plus `localAppData` and `xdgStateHome`; the refusal codes `AUTHORIZATION_MISSING`, `AUTHORIZATION_AMBIGUOUS`, `AUTHORIZATION_CONSUMED` and `AUTHORIZATION_IDENTITY` exist; every ET test file of Set Q exists.
- Every Python symbol and test named by P15-T16 through P15-T19 and Set R exists; `Clock` is the TypeAlias in R/service_contracts.py; `HostServiceIO.__init__` and `installed_host_io` carry no clock today; `PathStamp` has `kind` with `symlink` and `reparse` members and `resolved_path`.
- The ten P15-T20 files exist and have no `coverageThreshold` entry; extensions/drm-copilot/jest.config.cjs has 487 physical lines; ET/discovery-coverage-contracts.test.ts mentions the 500-line limit only in its header comment and pins no line count.
- The fourth `## Test Runtime` bullet of the brief is the shared-fixture bullet and carries the token `its own copy`; P14-T5 names the six copies.
- The two artifacts/coverage residue files of P15-T2 exist and are untracked.
- DOC/enforcement.md carries the `Start attestation` row and the `## Supported native controls`, `## Protected records` and `## Host-principal path` headings; FEATURE/handoff.md and FEATURE/completion-report.md carry the real-host observation sentence P15-T23 replaces; spec.md and user-story.md carry `Status` and `Last Updated` lines.
- The revision section lists eight decisions, matching P15-T1.

## Execution-level decision recorded for P15-T15

`discovery_capability_sentinel` is added to the controlled-operation tables on both sides, and the gate routes it to the sentinel decision before the controlled-tool path; the TypeScript admission in `admitControlledToolCall` likewise routes the sentinel tool to `consumeSentinelGrant` before the root-grant branch, so no root grant and no tool authorization is required or consumed for it. This follows the task text ("the gate routes the sentinel tool to `Get-DiscoverySentinelDecision` before the controlled-tool path, so no tool authorization is written for it") and is not a plan change.
