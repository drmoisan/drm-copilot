# Uncovered-Line Classification — `scripts/dev-tools/Invoke-ReleaseVerification.ps1`

Timestamp: 2026-08-26T04-08

> Filename-stamp substitution note: the filename carries the fixed cycle stamp `2026-08-26T02-36`
> required by the plan, whose acceptance conditions assert exact filenames. The `Timestamp:` field
> records the actual execution stamp, `2026-08-26T04-08`. Same convention as Phases 0 through 3.

Command: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path'`

EXIT_CODE: 0

## Output Summary

The uncovered line numbers were read from `artifacts/pester/powershell-coverage.xml`, selecting the
`sourcefile` named `Invoke-ReleaseVerification.ps1` inside the `package` element whose name resolves
to `scripts/dev-tools`, and taking every `line` element whose covered-instruction count is 0. Each
number was then resolved against the working-tree source to name its enclosing region.

The file measures **65 lines**, of which **56 are covered** and **9 are uncovered**
(86.1538 percent). The complete uncovered set is:

`69, 70, 86, 87, 104, 403, 418, 419, 420`

### Line-by-line classification

| Uncovered line | Source text | Enclosing function or block | Region |
|---|---|---|---|
| 69 | `$output = & gh @GhArgs 2>&1` | `Invoke-GhExe` | `Invoke-GhExe` |
| 70 | `return @{ Output = @($output); ExitCode = $LASTEXITCODE }` | `Invoke-GhExe` | `Invoke-GhExe` |
| 86 | `$output = & npm @NpmArgs 2>&1` | `Invoke-NpmExe` | `Invoke-NpmExe` |
| 87 | `return @{ Output = @($output); ExitCode = $LASTEXITCODE }` | `Invoke-NpmExe` | `Invoke-NpmExe` |
| 104 | `Start-Sleep -Seconds $Seconds` | `Invoke-Sleep` | `Invoke-Sleep` |
| 403 | `$verification = Invoke-TagPublishVerification ...` | **entry-point block** | entry-point block |
| 418 | `Write-Output "State: ...; RunExistence: ...; StepConclusion: ..."` | **entry-point block** | entry-point block |
| 419 | `Write-Output "Instruction: $($verification.Instruction)"` | **entry-point block** | entry-point block |
| 420 | `exit $verification.ExitCode` | **entry-point block** | entry-point block |

### Region boundaries

- `Invoke-GhExe` is declared at line 56 and closes at line 71. Its two body statements are 69 and 70.
- `Invoke-NpmExe` is declared at line 73 and closes at line 88. Its two body statements are 86 and 87.
- `Invoke-Sleep` is declared at line 90 and closes at line 105. Its single body statement is 104.
- The entry-point block is the dot-source-guarded `if ($MyInvocation.InvocationName -ne '.') { ... }`
  opening at line 401 and closing at line 421 (the file is 421 lines long). Lines 403, 418, 419, and
  420 all fall inside it. The guard condition on line 401 is itself covered, because it is evaluated
  every time the file is dot-sourced by a test.

### Out-of-region count

**The count of uncovered lines falling outside the `Invoke-GhExe`, `Invoke-NpmExe`, `Invoke-Sleep`,
and entry-point regions is 0.**

All 9 uncovered lines classify into exactly one of the four declared regions: 5 into the three
wrapper-seam bodies and 4 into the entry-point block. No uncovered line is unaccounted for.

### Why each region is uncoverable under this cycle's constraints

- **The three wrapper-seam bodies.** Covering line 69 or 70 requires executing the real `gh`
  executable; covering 86 or 87 requires executing the real `npm` executable. AC21 prohibits any test
  added or modified by this change from invoking `npm`, `gh`, or `git` as a real external process.
  Covering line 104 requires a real `Start-Sleep`, which AC22 prohibits outright and which
  `.claude/rules/general-unit-test.md` bans as a real wall-clock wait in test code. These are the
  seams whose entire purpose is to be mocked; a test that covered them would be the defect, not the
  fix.

- **The entry-point block.** It executes only when the script is invoked rather than dot-sourced,
  which is precisely the condition the guard on line 401 excludes for every test. Line 420 is
  additionally an `exit` statement, which would terminate the Pester host. Under the Coverage
  Exclusion Policy in `.claude/rules/general-unit-test.md` the correct treatment is to keep this
  block as thin wiring and leave its cost visible in the metric rather than to exclude the file, and
  that is what this cycle did: every decision the block used to make is a pure function measured
  elsewhere.

### Assertion form

This record asserts the uncovered set **as a set**, not as a percentage. The falsifiable condition is
that every uncovered line classifies into one of the four declared regions with an out-of-region
count of 0. That condition is unaffected by the coverage-denominator re-partitioning caused by the
Phase 1 module split, and it catches a newly uncovered line of real logic — a regression that a
percentage threshold alone could hide.
