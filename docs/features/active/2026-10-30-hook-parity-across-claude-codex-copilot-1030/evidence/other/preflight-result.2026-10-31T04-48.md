# Preflight Result (round two, confirming)

Timestamp: 2026-10-31T04-48
Plan: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md
Branch: issue-1030-prep-r2 (plan revision commit "revise issue 1030 plan for preflight round one defects")
Work Mode: full-feature (AC sources spec.md, user-story.md)

PREFLIGHT: ALL CLEAR
CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Validator Runs

- Command: poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md
- EXIT_CODE: 0 (run before and after the in-place fixes; both runs printed "plan validation passed")
- MCP validate_orchestration_artifacts (artifact_type plan): ok true, before and after the fixes
- Output Summary: no Blocking finding and no Warning from either validator.

## Round-One Defects: Resolution Verified Against the Tree

1. Wrong reference branch: resolved. `## Terms` defines `INTEGRATION` from the `integration_branch` frontmatter of `docs/features/epics/shared-agent-harness-layer/epic.md`, which reads `epic/shared-agent-harness-layer-integration` at `INTEGRATION`. `BASE` is the merge base of `INTEGRATION` and `HEAD`, and that merge base resolves on this branch. Check (a) stays at `origin/main` and adds an `IN-INTEGRATION` containment column. Checks (b) to (e), the [P2-T10] frontmatter equality, [P6-T8], [P6-T10] and [P6-T12] all read `INTEGRATION` or `BASE`. The only remaining `origin/main` references are check (a) and the run-manifest read, and both are correct. The spec.md wording is routed to the coordinator under `## Owner Questions` and is not counted here, as directed.
2. codex-bundle-hook-probe.Tests.ps1: resolved. The counts were re-derived from the bundled `.codex/config.toml` and the `Get-CodexHookRegistration` regex, which matches only single-quoted `'pwsh ... /.codex/hooks/<name>.ps1"'` commands. Current state: 25 unique hooks, 20 PreToolUse, 5 excluded. Invocations: `^Bash$` 5x1, the broad group 6x4, `^(apply_patch|Edit|Write)$` 9x2, and the delegation group 0, for 47. [P2-T10] adds five single-quoted SubagentStop hooks, giving 30/20/47. The four basic-string `validate-required-artifact-output.ps1` handlers are not matched, as the task states. [P3-T2] adds one hook to the patch group (apply_patch and Edit admitted), giving 31/21/49. [P4-T3] adds one Bash-only hook, giving 32/22/50. [P4-T1] is unchanged because the gate is already counted and the delegation matcher admits no candidate. All values match the plan.
3. C1 spawn_agent: resolved. In `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, the process entry tail passes `tool_input` only for `Bash` and `apply_patch` and maps every other tool through `ConvertTo-CodexFileEditInput`, as [P0-T6] states. [P0-T6] records `C1-ENTRY-TAIL` and `C1-PROCESS`, and DELIVER requires F1, ROUTED and DENY-IMPL-ALLOW-OTHER. Otherwise the result is DEFER with `NOT-EXPRESSIBLE` (issue #555) or `DEFER`. [P4-T1] drives the gate through its process entry point. It names the mode-resolution row `registers no PreToolUse matcher admitting an Agent or Task tool name` and the D5 header as updated under DELIVER. [P4-T4] and [P5-T5] carry the new gap class.

## Sibling and Whole-Plan Checks (no substantive defect)

- [P2-T13] reason prefixes match the `-ReasonPrefix` literals in the six Claude validators. `Get-HookRegistration` (`HookDependencyGraph.Helpers.ps1`) discovers registrations in any quoting form, so B4 needs all six entries, including `validate-required-artifact-output:`. Dependency checks precede the argument check in that hook, so B1 to B3 hold without arguments.
- The other suites that read `config.toml` are unaffected: `discovery-capability.Tests.ps1` (the new matchers do not contain `epic-planner|epic-orchestrator`), `codex-pretooluse-integration.Tests.ps1` (no delegation candidate), the release and worktree-session suites (mocked paths), and the Python closure and push-down tests (any-quote regex; covered by the [P2-T11] core.json entries).
- [P2-T10] matchers: the `.codex/agents` variant stems exist for atomic-planner, atomic-executor, task-researcher, prd-feature and pr-author. epic-review, status-updater and staged-review have no variants. The Claude frontmatter registers the handler set that the task states.
- The [P2-T12] `legacy-codex-hook-contracts.Tests.ps1` names, rows and stdin-read pattern are confirmed.
- [P5-T1]/[P5-T2]: `$script:ScanRoot`, `Get-GuardedPowerShellFile`, `Test-GuardedPathUnderScanRoot` and the cited rows exist. `.github/hooks` holds no Python invocation (one comment mention only).
- Language rule: no new Python or TypeScript. Pushed-down artifacts are PowerShell. E2 is not applicable.
- The Phase 0 E3 re-check gate is retained. Execution waits for parallel run bugs-1001-1002-1003-1006 to merge, and [P0-T8] stops on any (a) to (d) or (f) mismatch.

## In-Place Fixes

PREFLIGHT-FIX: [P3-T3] | incomplete anchor and unnamed existing test (validator-blind) | the H1 codex row now states its variable, deny condition, deny code and both guarded leaves (feature-folder-resolution.ps1, DevelopmentDocsRoot.psm1); hook-import-failure-exemptions.Guard.Tests.ps1 is named as unchanged and added to acceptance
PREFLIGHT-FIX: [P2-T9] | ambiguous literal, assertion unchanged | the missing-argument block is stated to go through Exit-CodexSubagentStopDecision, matching the [P2-T12] repeated-stop row

preflight-fix-record: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/evidence/other/preflight-fixes.2026-10-31T04-48.md

## Substantive Defects

None.
