# Pre-Gate Sync, Registration Branch B (P6-T9 rule re-applied under OD-7)

Timestamp: 2026-11-14T10-11
Command: `git fetch origin main`; `git merge --no-edit origin/main`; conflict resolution below; Pester `Run.Path` = the debugging selection below, `Run.Exit` = `$true`; `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <contract selection>`; `git status --porcelain` after the merge commit
EXIT_CODE: 0
Output Summary: `origin/main` advanced during the Phase 7 loop with PR #1177 (issue #1159, the single PreToolUse hook dispatcher). The merge conflicted in seven files. This record applies the P6-T9 rule: #1159 arrived after the earlier syncs, so this commit switches from registration branch A to branch B. Ledger entry in force: `0012`. #1159 changed the stored patch of entry `0010` and recorded regions of no other entry, and the ledger tests pass on the merged tree with no re-application. Debugging runs: Pester selection 857 passed, 0 failed, 8 skipped. pytest contract selection: 112 passed, 0 failed. The Phase 7 final QA loop restarts at P7-T1 on the merged tree.

## Registration Branch B in Force

- Registry paths: `.claude/hooks/pretooluse-dispatch.json`, `.codex/hooks/pretooluse-dispatch.json`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/pretooluse-dispatch.json`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/pretooluse-dispatch.json`. None was moved.
- Dispatched tool names: the Claude dispatcher matcher `Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|WebFetch|WebSearch|mcp__.*` and the Codex dispatcher matcher `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*|Agent|Task|spawn_agent|run_subagent|delegate)$` admit `Bash`, `mcp__drm-copilot__run_poshqc_test`, and `mcp__drm-copilot__run_poshqc_suite`. All three names are dispatched, so no branch A direct group remains.
- Member entry: one group per registry copy, placed directly after the Bash group. The Claude copies use matcher `Bash|mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite` in the settings shape `{type, command}` with no member `timeout`. The Codex copies use matcher `^(Bash|mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite)$` with `command`, `command_windows`, and `timeout` 30. Under branch A the hook ran last in the Bash group, and the PoshQC MCP group followed directly. One group directly after the Bash group gives the same run order for all three tool names, and it keeps the Codex sum at one member, so the dispatcher `timeout` rises by exactly 30, as the plan states.
- Dispatcher timeouts: `.codex/config.toml` and its bundle copy go from `timeout = 690` to `timeout = 720`, the sum of the 24 member timeouts. The Claude dispatcher entry in both `settings.json` copies has no `timeout` key (`claude-settings.Tests.ps1`: `registers a single PreToolUse dispatcher entry without a timeout key`), so the sum rule does not apply there.
- Direct entries removed: this item's `Bash` group entry and PoshQC MCP group in both `settings.json` copies and both `config.toml` copies. Those files now take the `origin/main` text, apart from the Codex timeout.
- #1159 registry and timeout-sum tests: `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1`, with the rows `sets the Codex dispatcher timeout to the registry timeout sum`, `resolves every <Runtime> registry hook to an existing file in the settings shape`, `has parity envelopes for <Leaf>`, and `loads each stateless shared module once per call`.

## Re-applied Changes

| File | Change |
|---|---|
| the four registry copies | the member group above |
| `.codex/config.toml` and bundle copy | dispatcher `timeout` 690 to 720 |
| `.claude/settings.json`, `.codex/config.toml`, and bundle copies | conflict resolved to the `origin/main` text: the direct entries of this item are removed |
| `.claude/hooks/enforce-test-execution-policy.ps1` and bundle copy | `HookPayload.psm1` import without `-Force`, as #1159 did for every registry member, so the in-process dispatcher loads the stateless module once per call |
| `tests/scripts/claude-hooks/test-execution-policy.Registration.Tests.ps1` | rewritten for branch B: registry membership (four copies), group position, Codex member shape, no direct registration (four copies), and one timeout-sum row per `config.toml` copy (18 rows) |
| `tests/scripts/claude-hooks/PreToolUseDispatch.ParityCorpus.Claude.ps1`, `...Codex.ps1` | envelope `bash-direct-test-runner` (`pytest -q tests/parity-probe`, denied by `enforce-test-execution-policy.ps1`), so the hook has an allow and a deny parity envelope |
| `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` | conflict resolved to the `origin/main` text, whose counts are derived from the bundle registry |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` | both token rows kept: this item's hook and the dispatcher |

## Debugging Runs

| Suite | Result |
|---|---|
| Pester: `test-execution-policy.Registration.Tests.ps1` (18), `PreToolUseDispatch.Parity.Tests.ps1`, `codex-bundle-hook-probe.Tests.ps1`, both `hook-dependency-failure` suites, `claude-settings.Tests.ps1`, `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, both `enforce-test-execution-policy.Tests.ps1` suites (152 and 157), `ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionLedger.Index.Tests.ps1`, `owner-directive-pass-down.Registration.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1` | 857 passed, 0 failed, 8 skipped |
| pytest: brief contracts, both resource contracts, both pack-manifest completeness tests, dependency closure, Codex core-manifest closure, discovery publication contracts | 112 passed, 0 failed |

## Sibling Status

#1156, #1157, #1159, #1160, #1161, and #1163 are merged into `origin/main`; #1162 is not.
