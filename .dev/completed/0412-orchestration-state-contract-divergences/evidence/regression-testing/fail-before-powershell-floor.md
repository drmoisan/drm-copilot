# Fail-Before — Divergence 2 (PowerShell), Pre-Fix Reproduction (Issue #412)

Task: [P0-T15] `[expect-fail]`

Timestamp: 2026-07-25T17-39

Command:

```
pwsh -NoProfile -Command "Import-Module ./.claude/lib/model-routing/ModelRouting.psm1; Get-ComplexityFloor -SignalsPresent @('docs_or_comment_only')"
```

Run from the repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`.

EXIT_CODE: 0

Output Summary:

Observed output, verbatim, a single token:

```
C3
```

This matches the documented pre-fix expectation `C3` and demonstrates the defect.

`docs_or_comment_only` is flagged `"floor": false` in `config/orchestration-routing.json`, so
`Get-ComplexityFloor` must return `C1` for it. The working-tree module returns `C3` instead,
mirroring the Python defect reproduced in [P0-T14]: any non-empty `-SignalsPresent` list
forces the floor to `C3` regardless of whether the named signals are floor-forcing.

The command targets the root module `.claude/lib/model-routing/ModelRouting.psm1` directly via
`Import-Module`, so the observed behavior is that of the working-tree module rather than the
published MCP bundle (see plan Hard Constraint 9).

The exit code is 0 because the defect is an incorrect return value, not a thrown error. The
`[expect-fail]` outcome for this task is the buggy output above, which is what was observed.

Phase 4 ([P4-T11]) verifies the post-fix behavior; the expected post-fix output there is `C1`
for `docs_or_comment_only` followed by `C3` for `cross_module_contract_change`.
