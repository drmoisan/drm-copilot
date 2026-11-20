# Preflight Result — Issue #1030, plan version 2.1

Timestamp: 2026-11-18T07-53
Plan: `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md`
Command: `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan-path>`; `sh SCRATCH/issue-1030-p0exist2.sh <worktree root>`
EXIT_CODE: 0
Output Summary: branch-current plan validator passed before and after the in-place fix; existence check `MISSING-COUNT=0` (every plan-named file and test-row text present, every plan-created file and the deferred Codex feature-folder-order file absent).

PREFLIGHT: ALL CLEAR
CONVERGENCE: NO FURTHER ROUNDS EXPECTED
PREFLIGHT-FIX: [P1-T3] | literal correction | matrix entry for the new Codex SubagentStop registration sets `consumers` `["codex"]` as its sibling `.codex/config.toml` entries instead of the skeleton's empty array
preflight-fix-record: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/evidence/other/preflight-fixes.2026-11-18T07-53.md

## Design Check (spec.md 0.4)

| Spec item | Implementing task | Test that fails when the rule is broken |
| --- | --- | --- |
| Phase 0 checks (a) to (d), (c) record-only | [P0-T1] | `PHASE0-GATE:` line of the phase0-gate artifact |
| Every registration has one native entry with `decision_ref` | [P1-T3], [P2-T1] | `HarnessParityMatrix.RepoGate.Tests.ps1` (`committed matrix has no violation against the live inventory`); H3 of `HarnessHookParity.RepoGate.Tests.ps1` |
| Claude group without Codex member carries a gap; Codex-only group carries `CODEX-NATIVE` | [P2-T1], [P2-T3] | H1, H2 and the two in-memory negative rows of [P2-T3] |
| Codex `validate-pr-author-output.ps1` root, bundle, manifest, behavior suite, malformed payload exit 2 | [P1-T1], [P1-T2] | `codex-validate-pr-author-output.Tests.ps1`; `legacy-codex-hook-contracts.Tests.ps1` (`fails closed with exit 2 and stderr for malformed stdin on every hook`, byte-identity, manifest rows) |
| One `[[hooks.SubagentStop]]` table, matcher admits `pr-author`, one continuation | [P1-T2], [P1-T3] | `Describe 'pr-author SubagentStop registration'` and the child-process `stop_hook_active` rows |
| AD-8 deferral: no Codex FFO file, registry entry or timeout change; Claude-only group with `GAP:DEFER:` naming `DevelopmentDocsRoot.psm1` and child 4 | [P2-T1], [P3-T4] | `records the feature-folder-order port as deferred`, H5; `PreToolUseDispatch.Parity.Tests.ps1` (`sets the Codex dispatcher timeout to the registry timeout sum`); [P3-T4] scope assertions |
| Envelope twin text identity; identical-helper set pinned | [P1-T1] | `cross-tree-helper-identity.Tests.ps1` |
| C1 `NOT-EXPRESSIBLE` (#555), C2 `DEFER` (`agent_type`) | [P2-T1], [P2-T3] | `records C1 as NOT-EXPRESSIBLE naming issue 555`, `records C2 as DEFER naming agent_type` |
| DEFER stem set with dependency reasons | [P2-T1], [P2-T3] | H5; `names the claude lib module and child 4 in each non-C2 DEFER reason` |
| Copilot entries native, `owner_child` 6 | [P2-T1], [P2-T3] | H4 and the Copilot row of [P2-T3] |
| No-Python scan covers `.github/hooks` | [P2-T4] | `AC-15 scans exactly the four hook roots`, `AC-15 copilot hooks path is under a scan root` |
| Mirrors and manifests green | [P1-T1] to [P1-T3], [P3-T3] | listed Pester and Python contract suites |
| Scope: no capped Codex file, no generator-owned edit; generator check | [P3-T1], [P3-T4] | [P3-T4] assertions; `GENERATOR-CHECK` exit code |
| No new Python or TypeScript; `pwsh` commands | [P3-T4] | [P3-T4] assertions; registration rows |
| New Codex files at 85% line coverage | [P3-T2] | `pester-coverage` per-file figures |
| Linux hook-suite job | [P3-T5] (orchestrator-owned) | CI conclusion |

Every rule, parameter and boundary has an implementing task and a failing test; no substantive defect was found.
