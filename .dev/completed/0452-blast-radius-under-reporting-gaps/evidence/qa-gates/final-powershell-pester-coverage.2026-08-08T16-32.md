# [P11-T7] Final QA — PowerShell tests with coverage

Timestamp: 2026-08-08T16-32
Task: [P11-T7]
Loop iteration: 1

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5c761b8f1a691079`
and no `scan_folders` override, so the run resolves
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` over the `config/poshqc-scan.json`
scan set (`scripts`, `tests/powershell`, `tests/scripts`).

EXIT_CODE: 2

Results parsed from `artifacts/pester/pester-junit.xml` and
`artifacts/pester/powershell-coverage.xml`.

## Test counts

| Metric | Baseline [P0-T9] | This run | Delta |
| --- | --- | --- | --- |
| Total | 1995 | 2031 | +36 |
| Passed | 1984 | 2020 | +36 |
| Failed | 2 | 2 | 0 |
| Errors | 0 | 0 | 0 |
| Skipped (`disabled`) | 9 | 9 | 0 |
| Wall time | 99.849 s | 98.874 s | — |

The +36 is the tests added across Phases 3 through 9: the [P4-T1] extraction matrix, the [P4-T5]
config assertions, the [P5-T3] parity config-shape assertion, the ten [P7-T2] cases, the four
[P9-T2] monotonicity cases, and the ten parity cases produced by the five new fixtures.

## The two failures are the documented pre-existing baseline failures

Byte-for-byte the same two tests recorded at [P0-T9], [P5-T6], and [P7-T7]:

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ::
   `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` ::
   `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

Both read the real, gitignored `artifacts/orchestration/orchestrator-state.json` (`epic_mode: true`)
instead of a mocked seam. `artifacts/` is gitignored, so on a clean checkout neither file exists
and both tests pass. This is a test-isolation defect in two hook suites, outside the scope of issue
#452. Neither suite is modified by this plan, and the failure count is unchanged from the baseline
of 2. Zero blast-radius tests fail.

## Numeric post-change coverage

Repository-wide, over the `CodeCoverage.Path` list in the runsettings:

| Counter | Covered | Missed | Total | Percent | Baseline [P0-T9] |
| --- | --- | --- | --- | --- | --- |
| LINE | 3148 | 189 | 3337 | **94.34%** | 94.34% |
| INSTRUCTION | 4316 | 278 | 4594 | **93.95%** | 93.95% |
| METHOD | 240 | 26 | 266 | **90.23%** | 90.23% |
| CLASS | 39 | 2 | 41 | **95.12%** | 95.12% |

Line coverage 94.34% >= 85%. No regression against baseline: every counter is identical to the
[P0-T9] value.

## Per-module coverage for the five `.claude/lib/blast-radius/*.psm1` modules

| Module | Post-change measured coverage | Baseline [P0-T9] |
| --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | UNMEASURED — no `sourcefile` entry emitted | UNMEASURED |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | UNMEASURED — no `sourcefile` entry emitted | UNMEASURED |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | UNMEASURED — no `sourcefile` entry emitted | UNMEASURED |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | UNMEASURED — no `sourcefile` entry emitted | UNMEASURED |
| `.claude/lib/blast-radius/BlastRadius.psm1` | UNMEASURED — no `sourcefile` entry emitted | UNMEASURED |

A query for `//sourcefile` entries whose name matches `*BlastRadius*` in
`artifacts/pester/powershell-coverage.xml` returns nothing, exactly as at baseline. All five
modules ARE declared in the runsettings `CodeCoverage.Path` list (added by issue #447), but Pester
emits no `sourcefile` element for any of them because the suites consume the modules through
`Import-Module`, which loads each into its own module scope where the coverage breakpoints do not
bind. This is a pre-existing measurement condition of the F1 delivery, present before any edit in
this plan and unchanged by it. No coverage exclusion was added for these modules; the condition is
instrumentation binding, not exclusion.

The modules are nonetheless behaviourally exercised. The scoped run at [P8-T9]
(`scan_folders: ["tests/scripts/claude-lib/blast-radius"]`) reported 316 tests with zero failures,
up from 284 at baseline, which isolates the cause to coverage instrumentation rather than test
absence.

Output Summary: 2020 passed, 2 failed, 0 errors, 9 skipped of 2031 total; EXIT_CODE 2. The failure
count is unchanged from the [P0-T9] baseline of 2 and both failing tests are the identical
documented pre-existing hook-suite isolation defects, outside this issue's scope. Post-change
repository-wide PowerShell coverage is 94.34% line (3148/3337) and 93.95% instruction, both
identical to baseline with no regression. The five `.claude/lib/blast-radius/*.psm1` modules remain
UNMEASURED for per-module coverage for the same pre-existing instrumentation reason recorded at
baseline; the blast-radius suites themselves are green at 316 tests with zero failures.
