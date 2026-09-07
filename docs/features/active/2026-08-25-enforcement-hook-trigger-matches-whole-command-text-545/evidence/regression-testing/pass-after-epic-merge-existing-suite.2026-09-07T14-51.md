# Pass-after — existing suite `enforce-epic-merge-gate.Tests.ps1` (issue #545)

Timestamp: 2026-09-07T14-51

Task: [P9-T4]

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session because
`pwsh`, `powershell`, and `cmd` cannot be invoked from any context here. Per-suite results were read
from `artifacts/pester/pester-junit.xml`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count; the suite this task measures contributes 0 of it)

## Result

| Measure | Value |
| --- | --- |
| Suite | `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` |
| Tests | 56 |
| Failures | **0** |
| Errors | 0 |
| Skipped | 0 |
| Derived passed count | **56** |
| [P0-T10] baseline passed count | **56** |
| Equal to baseline? | **yes** |

The baseline figure is row 5 of `evidence/baseline/baseline-targeted-pester.2026-09-07T11-14.md`,
which recorded 56 tests, 56 passed, 0 failed for this suite.

## Assertions specifically checked against the [P9-T1] edit

Every command string this suite drives was surveyed before the edit, so no existing assertion was
left to chance. All of them still resolve as they did at baseline:

| Command string driven by the suite | Post-change behaviour |
| --- | --- |
| `git status` | out of scope, allow — no `gh pr merge` invocation |
| `gh pr merge 10 --squash` | out of scope, allow — `Test-CommandLineFlag` finds no `--merge` |
| `gh pr merge 410 --merge` | in scope; `Get-CommandLineOperand` yields `410` |
| `gh pr merge 999 --merge` | in scope; `Get-CommandLineOperand` yields `999` |
| `gh pr merge --merge 501` | in scope; `Get-CommandLineFlagValue` yields `501` |
| `gh pr merge --merge 777` | in scope; `Get-CommandLineFlagValue` yields `777` |
| `gh pr merge --merge` | in scope; both resolvers yield `$null`, the fail-closed value |

The suite's own extractor context at line 218,
`Get-EpicMergeGateCommandPrNumber extractor (flag-order forms)`, holds three direct assertions —
`410` for `gh pr merge 410 --merge`, `410` for `gh pr merge --merge 410`, and null for the bare
`gh pr merge --merge` — and all three pass unmodified.

Output Summary: the existing merge-gate suite reports **56 tests / 0 failures**, a derived passed
count of **56**, equal to the [P0-T10] baseline passed count of 56. No pre-existing assertion in this
suite was modified, weakened, or newly failing after the [P9-T1] rewrite of the scope filter and the
PR-number extractor.
