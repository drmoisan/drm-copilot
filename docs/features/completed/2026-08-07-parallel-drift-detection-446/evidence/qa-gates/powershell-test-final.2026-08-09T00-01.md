# PowerShell Test and Coverage — Final QC, Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P8-T7]

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`

EXIT_CODE: 1

Supplementary Command (authoritative per-file coverage against the repository's declared 48-file
denominator; the MCP invocation resolves its runsettings from the installed extension bundle and
measures a smaller denominator — see the [P0-T8] artifact's
`## Coverage-Denominator Divergence` section):
`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

Supplementary EXIT_CODE: 1

The non-zero exit is recorded truthfully. It is **not** `SKIPPED` and the failure count below is **not**
reported as zero.

## Output Summary

### Every observed failure, named by file and test name

Exactly **one** test failed. It is the only `[-]` line in the entire run output:

- File: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Test: `enforce-pr-author-skill.ps1` / `allowed commands` /
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Assertion site: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142`, at
  `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'`
- Observed: `deny`. Expected: `allow`.

No other test failed in any file. No drift-gate test failed:
`tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` and
`tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` both report `[+]`.

### The non-zero exit is attributed to the named pre-existing failure

The failure is exactly the one this plan records by name in its
`## Pre-Existing PowerShell Failure` section, at exactly the assertion site that section names
(`enforce-pr-author-skill.Tests.ps1:142`, expected `'allow'`, observed `'deny'`).

Root cause, as recorded: the suite exercises `.claude/hooks/enforce-pr-author-skill.ps1`, which reads
the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam, so it
fails whenever an orchestrated run is live — which it is, since this remediation cycle is itself an
orchestrated run.

Its [P0-T8] counterpart: the same test failed identically in this cycle's entry baseline
(`evidence/remediation-baseline/powershell-test-baseline.2026-08-09T00-01.md`, 1 failed), and before
that in the original Phase 0 baseline
(`evidence/baseline/powershell-test-baseline.2026-08-08T20-59.md`) and the original post-implementation
final QC (`evidence/qa-gates/powershell-test-final.2026-08-08T23-24.md`).

This cycle's `## Scope Contract` prohibits editing that file, and the plan explicitly prohibits editing
the hook to force a green gate. Neither was done: `git status --porcelain` reports no change to
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` or to
`.claude/hooks/enforce-pr-author-skill.ps1`.

### Failed-count delta against [P0-T8]

| Reference | Total | Passed | Failed | Skipped |
| --- | --- | --- | --- | --- |
| Plan `## Non-Regression Benchmarks` floor | — | 2080 | 1 | 9 |
| [P0-T8] cycle-entry re-capture | 2090 | 2080 | 1 | 9 |
| **This run** | **2099** | **2089** | **1** | **9** |

**Failed-count delta against [P0-T8]: 0.** One failure at cycle entry, one failure now, and it is the
same named test. No new failure was introduced and no previously passing test regressed.

The passed count rose by **9** (2080 to 2089) and the total by 9, from the tests this cycle added:
one `It` in [P4-T6] (the canonical-timestamp row assertion), two in [P5-T1] (`LatestAt` surfacing and
its malformed-log case), one in [P5-T2] (non-canonical `EventAt` fails closed), and five in [P5-T4]
(four parametrized narrowing cases plus the deny-reason assertion). Skipped is unchanged at 9.

### Numeric coverage

Report-level, over the repository's declared 48-file denominator:

| Counter | Covered / Total | Percent |
| --- | --- | --- |
| LINE | 3735 / 3932 | **94.99%** |
| INSTRUCTION | 5111 / 5401 | **94.63%** |
| METHOD | 300 / 326 | 92.02% |
| CLASS | 46 / 48 | 95.83% |

**No `BRANCH` counter is emitted** by Pester v5 or the PoshQC conversion step. The counter types
present in the report are exactly `CLASS`, `INSTRUCTION`, `LINE`, and `METHOD`. This is the condition
recorded as F8-I2 at the original baseline; INSTRUCTION coverage is the recorded analogue and **no
branch figure is invented**.

Per-file LINE coverage for the two drift-gate PowerShell files:

| File | LINE | INSTRUCTION |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | **94.95% (94/99)** | **94.53% (121/128)** |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | **100.00% (66/66)** | **100.00% (106/106)** |

Both clear the uniform 85% line-coverage floor. The hook's five uncovered lines are the same
dot-source-guarded entrypoint block as at cycle entry, which cannot execute while the suite
dot-sources the file; the count of uncovered lines is unchanged at five even though the file gained
twelve measured lines across [P5-T2] and [P5-T3], so every line this cycle added to it is covered.

Measurement-path statement, per the acknowledged divergence: the **report-level and per-file figures
above come from the repo-root `Invoke-PoshQCTest` invocation**, which resolves
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` from this worktree and measures the full
48-file denominator. The `mcp__drm-copilot__run_poshqc_test` invocation resolves its runsettings from
the installed extension bundle instead and measures a 41-file denominator that omits both drift-gate
hooks, so its coverage numbers cannot be used for the per-file comparison. Test outcomes are identical
between the two invocations: both exit 1 with the same single failure.
