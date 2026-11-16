# Sibling Reconciliation (P0-T1)

Timestamp: 2026-11-10T03-14
Command: git fetch origin; git merge --no-edit origin/main; git grep anchor checks; sha256sum; awk logical line counts
EXIT_CODE: 0
Output Summary: plain merge of origin/main completed with no conflicts (incoming: PR #1166, issue #1165); no sibling of #1156-#1163 is in the merge base; registration branch A applies.

## Merge Result

- `git merge --no-edit origin/main` produced merge commit `Merge remote-tracking branch 'origin/main' into feature/test-execution-policy-machine-lock-1158` with no conflicts.
- Incoming change: PR #1166 (issue #1165, cd-chained Bash deny guidance): `.claude/hooks/bash-command-shape-guidance.ps1`, `.claude/rules/bash-command-shape.md`, the execution-environment brief `## Command-Text Restrictions` section in six copies, and their tests. No file this item edits conflicted.

## Sibling Status (merge base of origin/main and HEAD)

| Sibling | In merge base | Remote branch |
|---|---|---|
| #1156 | no | origin/feature/regenerate-after-integration-merge-1156 |
| #1157 | no | origin/feature/owner-directive-pass-down-1157 |
| #1159 | no | origin/feature/hook-dispatcher-process-cost-1159 |
| #1160 | no | origin/bug/preimplementation-gate-false-positives-1160 |
| #1161 | no | origin/feature/planner-worktree-removal-authorization-1161 |
| #1162 | no | origin/feature/cross-epic-dependencies-1162 |
| #1163 | no | origin/bug/hook-session-root-resolution-1163 |

Registration branch: **A** (#1159 not in the merge base). `.claude/hooks/pretooluse-dispatch.json` and `.codex/hooks/pretooluse-dispatch.json` do not exist on the merged tree, so the branch B registry fields (member shape, dispatched names, dispatcher timeout, sum rule, #1159 test names) are not applicable and are re-checked in P6-T9.

## Files Re-read (merged-sibling status: none changed by a sibling)

`.claude/settings.json`, `.codex/config.toml`, both `core.json` pack manifests, the six `execution-environment` and six `atomic-plan-contract` SKILL.md copies (execution-environment changed by #1165 in `## Command-Text Restrictions` only), `.claude/agents/atomic-executor.md`, `.claude/agents/atomic-planner.md`, `.codex/agents/atomic-executor.toml`, `.codex/agents/atomic-planner.toml`, `.claude/hooks/hook-command-payload.ps1`, `.claude/hooks/hook-command-invocation.ps1`, their `.codex/hooks/` twins, `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`.

## Anchors

| Anchor | Status | Location |
|---|---|---|
| `Bash` PreToolUse group | present | `.claude/settings.json` (`"matcher": "Bash"`) |
| `^Bash$` group | present | `.codex/config.toml` |
| `## Phase 0 Requirements`, `## Final QA Loop` | present | six atomic-plan-contract copies |
| `## Tool Routes by Agent` | present | six execution-environment copies |
| `Read-CommandLineInvocationSegment`, `Get-CommandLineWrapperPayload`, `Skip-CommandLineTransparentWrapper` | present | `.claude/hooks/hook-command-payload.ps1` and twin |
| `Skip-CommandLineTransparentWrapper` stops at a non-dash `env` operand (D25 premise) | holds | the `env` case skips dash and `VAR=value` tokens only |
| `$script:CommandLineGlobalOptions` | present | `.claude/hooks/hook-command-invocation.ps1` and twin |
| `PreflightQCResult`, `run_preflight_qc_with_capture` | present | `scripts/dev_tools/atomic_executor/cli_preflight.py` |
| `Invoke-PoshQCTest`, `Invoke-PoshQCSuite` | present | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` |
| `Get-PoshQCParallelShardArgument` (still builds a `-Command` text) | present | `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` |
| `Invoke-PoshQCPwshExe` | present | `PoshQC.Parallel.psm1` |
| `Invoke-PoshQCParallelTest` (declares `Root` and `WorkerCount`) | present | `PoshQC.Parallel.psm1` |
| `run_simple_step` | present | `scripts/dev_tools/fix_all.py` (alias of `_run_simple_step`) |
| `runNodeTool` | present | `run-node-tool.cjs` |
| `run_fix_all` | present | `scripts/dev_tools/fix_all.py`, `scripts/dev_tools/fix_all_runtime.py` |
| `run_pytest_with_expectations`, `run_jest_with_expectations` | present | `scripts/dev_tools/atomic_executor/qc_runner_expectations.py` |
| `run_preflight_qc_fix_loop`, `execute_auto_qc_phase` | present | `scripts/dev_tools/atomic_executor/cli_task_runtime.py` |
| `## Caller Dispositions` entries | present | each named symbol and file resolved above |

## Suite Script Hash

`scripts/dev-tools/run-poshqc-suite.ps1` and `extensions/drm-copilot/resources/templates/run-poshqc-suite.ps1`: equal SHA-256.

## Sizes (logical lines) against config/file-size-baseline.json

- `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: 493 (no baseline entry)
- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`: 257 (no baseline entry)

## Probe Counts (tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1, merged tree)

- unique registered hooks: 26
- PreToolUse hooks: 21 (also in the `It` title)
- invocations: 48

## Addendum: files changed by the merged origin/main (#1165, not a listed sibling)

Derived from `git diff --name-only` between the merge commit's first parent and the merge commit. Of the re-read files and the files this item later edits, the merge changed: both `core.json` pack manifests (new `bash-command-shape` entries), the six `execution-environment` copies (`## Command-Text Restrictions`), `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, and `.claude/hooks/worktree-poetry-venv-policy.ps1` with its `.codex/hooks/` twin. These are adopted as merged; later tasks edit the merged text.
