# Phase 0 — Per-File Coverage Baseline ([P0-T7])

Timestamp: 2026-09-07T19-37
Task: [P0-T7]
Command: transcription of the two figures supplied with the remediation plan, cross-checked against `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/coverage-delta.2026-09-07T17-00.md` rows 16 and 17
EXIT_CODE: 0

Workflow path: `.github/workflows/_poshqc.yml`
CI run id: **34145103168**
Measured commit recorded by that artifact: `5903d0c7`

TOOLCHAIN_SUBSTITUTION: The MCP test runner (`mcp__drm-copilot__run_poshqc_test`) was deliberately
NOT used for any coverage figure in this or any later task of this plan. It resolves its runsettings
from the installed VS Code extension and therefore cannot see this branch's `CodeCoverage.Path`
entries; the locally produced `artifacts/pester/powershell-coverage.xml` was independently confirmed
during the prior cycle to contain zero `hook-command-scanner` occurrences for that reason. Coverage
figures come from a `workflow_dispatch` of `.github/workflows/_poshqc.yml` only. The executor has no
`gh` in its tool allowlist, so dispatching that workflow and reading its counters is orchestrator
work; this task transcribes supplied figures and runs no coverage command.

## Baseline per-file line coverage

| # | Canonical copy | Baseline line coverage (percent) |
|---|---|---|
| 1 | `.claude/hooks/validate-bash.ps1` | **94.3182** |
| 2 | `.codex/hooks/validate-bash.ps1` | **100.0000** |

Both cells carry a numeric percentage. No placeholder value such as `UNVERIFIED` appears in either.

## Cross-check performed

`grep -n "94.3182\|100.0000\|34145103168" evidence/qa-gates/coverage-delta.2026-09-07T17-00.md`
returned, among other rows:

```
| 16 | `.claude/hooks/validate-bash.ps1` | 90.3846 | 94.3182 | +3.9336 |
| 17 | `.codex/hooks/validate-bash.ps1` | absent from CodeCoverage.Path at baseline | 100.0000 | n/a (no numeric baseline) |
```

and the run-id row naming `34145103168` at commit `5903d0c7`. The two supplied figures therefore
agree byte-for-byte with the prior cycle's recorded post-change figures, which are this remediation
cycle's baseline.

## How these figures are used later

`[P4-T7]` compares the orchestrator-supplied post-change figures from `[P4-T6]` against these two
values. Both post-change values must be at or above 85.0000 and neither may fall below its baseline
here. The Codex baseline is 100.0000, so on that side any single uncovered new statement fails the
no-regression condition while still clearing the absolute threshold; the plan's `[P4-T7]` remedy
governs that case. `[P4-T6]` and `[P4-T7]` are out of scope for this delegation and remain unchecked.

Output Summary: Baseline per-file line coverage transcribed and cross-checked — `.claude/hooks/validate-bash.ps1`
94.3182 percent, `.codex/hooks/validate-bash.ps1` 100.0000 percent, both from run `34145103168` of
`.github/workflows/_poshqc.yml`. EXIT_CODE 0 for the transcription. No coverage command was run by
the executor and no MCP-produced coverage figure was used.
