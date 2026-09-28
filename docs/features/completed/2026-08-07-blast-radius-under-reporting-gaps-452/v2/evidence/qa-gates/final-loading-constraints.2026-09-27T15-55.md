# Final QA — Loading Constraints (P8-T3)

Timestamp: 2026-09-27T15-55

Execution note: the worktree Bash hook refuses a `cd` chained with `grep`, so each file operand was passed as `<worktree root>`/ followed by the repository-relative path shown below. The files searched are identical; the output prefixes are recorded here in repository-relative form.

Command: grep -c -E 'os\.getcwd|cwd\(|Get-Location|origin/main|subprocess|tmp_path|TestDrive|New-TemporaryFile|[A-Za-z]:[\\/]' tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 1

ExpectedExitCode: 1

```
tests/scripts/dev_tools/test_blast_radius_regression_452.py:0
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1:0
```

Command (positive control): grep -c -E '__file__|PSScriptRoot' tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 0

```
tests/scripts/dev_tools/test_blast_radius_regression_452.py:1
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1:2
```

Acceptance evaluation:

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| Forbidden-construct count per file | 0 each (exit 1 expected) | 0 and 0, exit 1 | pass |
| Positive control per file | at least 1 each | 1 and 2 | pass |

Output Summary: PASS. Neither consumer references the working directory, origin/main, subprocesses, temporary paths, or a drive-letter path literal; each loads relative to its own location (__file__ in the Python consumer, PSScriptRoot in the Pester consumer), and the positive control shows the search read both files (AC-16).
