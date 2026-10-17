# Phase 10 PowerShell Test (P10-T7)

Timestamp: 2026-10-13T12-45
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks"]
EXIT_CODE: 7
Output Summary: Call disposition `"ok":false` with `Command exited with code 7.` This is recorded as the call disposition only, per the task text. Because the disposition was non-zero where the Phase 10 target rows were expected to pass, the executor read the JUnit file that the local run wrote to `artifacts/pester/pester-junit.xml` (git-ignored) as a supplementary observation for the P12-T27 withhold decision. CI remains authoritative (P12-T23, P12-T27).

## MCP result (verbatim, worktree path redacted)

```
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "<worktree>",
  "summary": "Command exited with code 7."
}
```

## Supplementary local observation (not an acceptance input)

- Local JUnit summary: `tests="4519" failures="7"`.
- The four Phase 10 target rows now pass locally: the three `F-1 non-compliant` rows and `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` all have `status="Passed"`. The two `F-1 compliant` rows, the three `AC-13 compliant` rows, `AC-9 compliant direct statements`, and `AC-10 compliant every top-level Describe isolates` also pass, so the P10-T3 bindings keep the in-memory compliant fixtures compliant.
- All seven failures are rows of `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (`discovery guard (both hook surfaces).AC-4 <suite> complies with the baseline isolation form for every closure seam`). Every finding in their failure messages (121 findings in total) is `no dot-source loads the hook`, the F-2 change; no F-1 finding appears. Flagged real suites:
  - `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`
  - `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`
  - `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`
  - `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`
  - `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`
  - `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
  - `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`
- These suites load their hooks through a dot-source that names no `hooks/<name>.ps1` literal and no variable bound to one; before F-2 the first-dot-source fallback identified a dot-source for them. Three of the seven are in the `hook-dependency-failure*` family that `issue.md` (Concurrency Constraints) names as likely owned by the concurrent epic `subagentstop-envelope` (ownership not verified). The plan routes this to P12-T27: if the CI Discovery suite reports any finding, the four Phase 10 files are restored to their PHASE0 content and the withhold is recorded. The executor made no edit to any flagged suite.
