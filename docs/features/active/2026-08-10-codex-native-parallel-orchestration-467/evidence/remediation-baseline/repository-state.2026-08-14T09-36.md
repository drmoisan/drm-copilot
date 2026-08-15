# Repository State Baseline

Timestamp: 2026-08-14T23-23
Command: `git status --short --branch`; `git diff --cached --name-only`; `git rev-parse HEAD`; `git merge-base HEAD main`; `git diff --no-ext-diff --binary -- tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` with direct-stream SHA-256 hashing.
EXIT_CODE: 0
Output Summary: HEAD and merge base match the approved review baseline. The index is empty. One tracked file has a preserved unstaged user-owned edit, and seven grouped review/remediation or Phase 0 evidence files are untracked at capture time.

- HEAD: `7f63b7323fc88fee0aadb83fa2e603b4480a8039`
- Merge Base: `768e485ddf3b48b16aa7588a72709e17568ee5f5`
- Branch: `feature/codex-native-parallel-orchestration-467`
- Upstream: `origin/feature/codex-native-parallel-orchestration-467`
- Index Status: empty; `git diff --cached --name-only` returned no paths.

## Exact Worktree and Untracked Inventory

```text
 M tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
?? docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-14T09-36/code-review.2026-08-14T09-36.md
?? docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-14T09-36/feature-audit.2026-08-14T09-36.md
?? docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-14T09-36/policy-audit.2026-08-14T09-36.md
?? docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/remediation-baseline/cycle-context.2026-08-14T09-36.md
?? docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/remediation-baseline/phase0-instructions-read.2026-08-14T09-36.md
?? docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-2026-08-14T09-36/remediation-inputs.2026-08-14T09-36.md
?? docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-2026-08-14T09-36/remediation-plan.2026-08-14T09-36.md
```

## Preserved User-Owned In-Scope Edit

- Path: `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`
- Working-file SHA-256: `9C2DF03E5C5EE965A89BC12EF78349DB75FC2EC184B8FE315A3621FC47FF2115`
- Unstaged binary-diff SHA-256: `78A9A3C7695BC75DB378EF54EC667C06DD30AED3DDF1B4B5027E9BCC678200FE`
- Ownership and preservation status: user-owned, in-scope, retained without modification by the executor at baseline capture.
- Semantic delta: replace the assertion that the entire `.codex/state` directory is absent with exact absence checks for `powershell-batch-budget.native-hook-contract.json` and `python-batch-budget.native-hook-contract.json`, while permitting unrelated active-session state.
