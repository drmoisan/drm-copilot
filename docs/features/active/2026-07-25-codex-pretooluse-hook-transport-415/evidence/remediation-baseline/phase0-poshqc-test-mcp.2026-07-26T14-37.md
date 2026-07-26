# Phase 0 — Baseline PoshQC Test, MCP Path (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P0-T5]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`

Timestamp: 2026-07-26T14-37

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`

EXIT_CODE: 0

## Raw Result

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53'."}
```

## Counts (parsed from `artifacts/pester/pester-junit.xml` produced by this run)

Command: `pwsh -NoProfile -Command "$x = [xml](Get-Content -LiteralPath 'artifacts/pester/pester-junit.xml' -Raw); $x.testsuites"`
EXIT_CODE: 0

| Metric | Value |
|---|---|
| Tests | 1668 |
| Failures | 0 |
| Errors | 0 |
| Skipped | 0 |
| Elapsed | 117.610 s |

## Output Summary

All suites green: **1668 tests, 0 failures, 0 errors** in 117.6 s.

### RD-5 stale-runsettings caveat (mandatory record)

`mcp__drm-copilot__run_poshqc_test` executes the PoshQC module bundled inside the npx-cached
`@danmoisan/drm-copilot-mcp` package (v1.0.19). That bundled copy carries its own
`pester.runsettings.psd1`, which predates this branch. Its `CodeCoverage.Path` measured set is therefore
**stale** relative to the repo-resident settings file at
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Coverage numbers produced by the MCP
stage are not authoritative for this plan and are not cited here. The authoritative coverage source is
the local `Invoke-PoshQCTest -Root <REPO>` run recorded at [P0-T6], which mirrors the CI invocation at
`.github/workflows/_poshqc.yml:38-42`. The MCP stage remains a mandated loop stage (convention C2) and
is executed at every loop task regardless.

### Why the CI failure does not reproduce locally (mandatory record)

`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` reports **6 tests, 0 failures** in this
run. It PASSES on this checkout because the working tree is on a named local branch
(`bug/codex-pretooluse-hook-transport-415`), so `git branch --show-current` returns a non-empty branch name
and `[string](<non-empty pipeline>)` yields a real `System.String` on which `.Trim()` succeeds.

The C1 defect at `.codex/hooks/enforce-epic-child-worktree-binding.ps1:311-316` is reachable only when
`git branch --show-current` succeeds (exit 0) and emits **nothing** — that is, on a **detached HEAD**.
GitHub Actions checks out `refs/pull/N/merge` in a detached state, which is why CI run 30213678367 caught
the failure (`enforce-epic-child-worktree-binding.ps1 x Bash: exit=2 ... You cannot call a method on a
null-valued expression.`) and why every local run on a named branch is green. The detached-HEAD state is
reproduced deliberately by the [P0-T7] fail-before probe in a detached worktree at the C4 probe root.
