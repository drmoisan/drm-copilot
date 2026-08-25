# Scope and Size Verification — issue #535

Timestamp: 2026-08-23T22-16

Command: `wc -l` over the six in-scope files, plus
`git diff --name-only e96e32e01662035faacec460a12441b253b6f3b2 HEAD`,
`git diff --numstat e96e32e01662035faacec460a12441b253b6f3b2 HEAD`, and a grep of the hook
diff for `Test-OrchestrationReady`, `Test-ImplementationCommand`, `git add|commit`,
`GetFullPath`, `Resolve-Path`, and `IsPathRooted`.
`e96e32e01662035faacec460a12441b253b6f3b2` is the branch state before this feature's first
commit.

EXIT_CODE: 0

## File Sizes (limit: 500 lines)

| File | Lines | Under 500 |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 339 | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 339 | yes |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 336 | yes |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 336 | yes |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 461 | yes |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 494 | yes |

All six counts are under 500.

## Scope Confirmations

- **Diff surface is exactly the six in-scope files.**
  `git diff --name-only` between the pre-feature commit and `HEAD` lists the four hook
  copies and the two test files, and nothing else. `git diff --numstat` shows the four hook
  copies each at +71/-1 or +72/-1 (the one deleted line per file is the replaced
  single-literal equality `if ($NormalizedPath -eq $script:CheckpointPath)`), the Claude
  test file at +156/-0, and the codex contract test file at +16/-0. No deletions in either
  test file, so no existing assertion was removed or weakened.

- **Issue #516 absolute-path normalization is NOT implemented.** The exempt entries are
  seven repo-relative string literals in `$script:CheckpointPaths`, evaluated by one
  `-contains` membership check against the path the caller already normalized with the
  pre-existing `-replace '\\', '/'`. The diff contains no occurrence of `GetFullPath`,
  `Resolve-Path`, or `IsPathRooted`, and no per-path normalization logic was added.

- **`Test-ImplementationCommand` is unmodified.** The command-pattern array, including the
  `(^|\s)git\s+(add|commit)\b` pattern, appears nowhere in the added or removed diff lines.
  The `git add|commit` housekeeping gap is untouched.

- **`Test-OrchestrationReady` is unmodified.** It appears nowhere in the added or removed
  diff lines.

- **`enforce-promotion-mcp-only.ps1` is untouched.**
  `git diff --name-only ... -- .claude/hooks/enforce-promotion-mcp-only.ps1` returns zero
  lines.

- **Unchanged behavior surfaces.** The anomaly path, the file-extension regex, the
  whole-payload delegation regex, and the decision-JSON shape are unchanged; the deny reason
  keeps the `PREIMPLEMENTATION_GATE_BLOCKED` prefix and the phrases `route metadata` and
  `lifecycle readiness`. The `.codex` copy's exit-code contract and Codex transport are
  unchanged, and no cross-runtime import of `.claude/lib/hook-payload/HookPayload.psm1` was
  added to it.

Output Summary: All six files are under the 500-line limit (339, 339, 336, 336, 461, 494).
The diff surface is exactly those six files. Issue #516 absolute-path normalization is not
implemented, `Test-ImplementationCommand` and `Test-OrchestrationReady` are unmodified, and
`enforce-promotion-mcp-only.ps1` is untouched. No out-of-scope change is present.
