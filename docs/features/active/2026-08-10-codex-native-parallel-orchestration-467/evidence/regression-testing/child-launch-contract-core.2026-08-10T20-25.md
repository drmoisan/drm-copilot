# Surface-neutral child-launch contract extraction

## Scope

- Created `.codex/scripts/codex-child-launch-contract-core.ps1` as the pure surface-neutral constructor and validator.
- Converted `.codex/scripts/epic-child-launch-contract.ps1` to a thin epic policy and error-compatibility adapter over that core.
- No parallel adapter or Phase 3 runtime implementation was added in this task.

## Structural verification

- Physical lines: core 351; epic adapter 312. Both are at or below 500 lines.
- The core version-validates surface, canonical repository, base/head and live branch, worktree, exact agent/model/reasoning/permission profile, guarded authority/delegation/topology/model-routing/child-status paths, isolated `CODEX_HOME`, and lowercase SHA-256 bindings.
- The core-plus-adapter function-signature union retains all 17 signatures from the pre-extraction epic contract; missing signatures: 0.
- Epic launcher parameters match `HEAD`: `LaunchSpecPath,MaxParallel,Supervisor,Wait,RepositoryRoot`.
- Epic resume parameters match `HEAD`: `ReceiptPath,Prompt,LastMessagePath`.
- Epic parsing failures retain the `EPIC_CHILD_LAUNCH_BLOCKED` prefix.

## Quality gates

- Initial scoped PoshQC analysis reported two findings: `PSAvoidAssignmentToAutomaticVariable` for `$home`, and `PSUseShouldProcessForStateChangingFunctions` for the pure `New-` constructor.
- Corrected the variable to `$codexHome`, renamed the pure constructor to `ConvertTo-CodexChildLaunchIdentity`, and restarted the required loop.
- Final scoped `mcp__drm-copilot__run_poshqc_format`: PASS.
- Final scoped `mcp__drm-copilot__run_poshqc_analyze`: PASS with zero findings.
- Focused PoshQC Pester scan of epic worktree-launcher and hardening/resume owners: 41 passed, 0 failed, 0 errors in 1.699 seconds; 22 worktree-launcher and 19 hardening/resume cases.
- Neutral identity proof: valid record produced 0 errors; traversal receipt path, invalid SHA-256, and non-isolated `CODEX_HOME` each produced one rejection.
- Focused parallel contract remains the planned pre-adapter state: 6 failures, 0 errors, with one unique message naming only the three absent adapters assigned to P3-T6.
- `.claude/` changed files: 0; diff lines: 0.
- `git diff --check`: PASS, exit 0.
