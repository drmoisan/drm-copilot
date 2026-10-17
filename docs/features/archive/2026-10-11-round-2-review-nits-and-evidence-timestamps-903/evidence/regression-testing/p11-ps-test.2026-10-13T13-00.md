# Phase 11 PowerShell Test (P11-T16)

Timestamp: 2026-10-13T13-00
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]
EXIT_CODE: 7
Output Summary: Call disposition `"ok":false` with `Command exited with code 7.` This is recorded as the call disposition only, per the task text. CI remains authoritative (P12-T23).

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

- Local JUnit (`artifacts/pester/pester-junit.xml`, git-ignored) summary: `tests="9414" errors="0" failures="7"`.
- The seven failures are the same seven `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` rows recorded in `p10-ps-test.2026-10-13T12-45.md` (F-2 `no dot-source loads the hook` findings in seven real suites). They are routed to the P12-T27 withhold decision. Phase 11 introduced no new failure.
- Phase 11 rows observed passing locally: the `DEV-2` row (`DEV-2 wave barrier allows a benign payload for every admitted tool name when no local checkpoint text is supplied`); all nine `AC-19` rows of `GENERATED_AGENT_FAMILIES parity`; and the four edited `publish-mcp-npm.yml workflow invariants` rows (`asserts tag and manifest version equality in a ref-guarded step ordered before the publish step`, `polls the exact published version after publishing and fails the job on budget expiry`, `keeps the exit-code reset, explicit exits, and exact-version operand in the poll step`, `runs the registry poll step only after a successful publish step`).
