# Repository-Wide PowerShell Coverage (F1, P2-T3)

Timestamp: 2026-10-16T07-38
Command: sh SCRATCH/929/RC1-P2-T2-1.sh
EXIT_CODE: 0

Output Summary:
- Full self-hosted PoshQC run without `-ScanFolders` (the command of `.github/workflows/_poshqc.yml` line 42) on RUN_HEAD bb386ed6bb6813aa2ae94465fda2611f86acd928, which equals PRE_RUN_HEAD in `rc1-full-run-prestate.2026-10-16T07-17.md`. PWSH_EXIT=0; the 180-minute bound did not fire (no `LOG | timeout: ` line; `LOG | Tests completed in 1022.9s` present).
- Tests: `Tests Passed: 10405, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`; JUnit TESTS=10415 FAILURES=0 ERRORS=0; no FAILED_CASE line.
- Report-level counter: `<counter type="LINE" missed="1731" covered="16384" />`
- REPO_WIDE_LINE_PCT=90.44
- REPO-WIDE-THRESHOLD: MET
- Per-file counter for `.claude/hooks/validate-task-researcher-output.ps1` (package ending `/.claude/hooks`, SOURCEFILE_MATCHES=1): `<counter type="LINE" missed="2" covered="100" />` (missed 2, total 102; equal to the scoped run in `coverage-counters-final.2026-10-16T05-12.md`).
- JUNIT_FRESH=True and COVERAGE_XML_FRESH=True (both result files were written after RUN_START_UTC).
- The log also contains four `Code coverage population: source=settings; files=1` lines after the `source=config; files=203` line; they are recorded verbatim below. The report-level counter is read from `artifacts/pester/powershell-coverage.xml` written by this run.

Script: SCRATCH/929/RC1-P2-T2-1.ps1, verbatim:

```powershell
'RUN_START_UTC=' + [DateTime]::UtcNow.ToString('o'); 'RUN_HEAD=' + (git rev-parse HEAD); Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path
```

Wrapper: SCRATCH/929/RC1-P2-T2-1.sh (background wrapper form), verbatim:

```sh
cd "$(dirname "$0")/../.." || exit 97
printf 'RUNNING\n' > SCRATCH/929/RC1-P2-T2-1.exit
timeout --verbose --kill-after=60 180m pwsh -NoProfile -NonInteractive -File SCRATCH/929/RC1-P2-T2-1.ps1 > SCRATCH/929/RC1-P2-T2-1.log 2>&1
echo "PWSH_EXIT=$?" > SCRATCH/929/RC1-P2-T2-1.exit
```

## Read script

Command: sh SCRATCH/929/RC1-P2-T3-1.sh
EXIT_CODE: 0

Script: SCRATCH/929/RC1-P2-T3-1.ps1 (full-run read body from the plan's Fixed names), verbatim:

```powershell
$ErrorActionPreference = 'Stop'; $R = '.'; $L = 'SCRATCH/929/RC1-P2-T2-1.log'; $E = 'SCRATCH/929/RC1-P2-T2-1.exit'; $esc = [char]27; $root = [regex]::Escape(((Resolve-Path -LiteralPath $R).Path -replace '\\', '/')); (Get-Content -LiteralPath $E | Select-Object -First 1); $log = @(Get-Content -LiteralPath $L | ForEach-Object { ($_ -replace ($esc + '\[[0-9;]*m'), '').Trim() }); $log | Where-Object { $_ -match '^(RUN_START_UTC=|RUN_HEAD=|Code coverage population:|Discovery found|Tests completed in|Tests Passed:|Covered |timeout: )' } | ForEach-Object { 'LOG | ' + ($_ -replace $root, 'WORKTREE_ROOT') }; $rs = [DateTime]::Parse((@($log | Where-Object { $_.StartsWith('RUN_START_UTC=') })[0]).Substring(14), [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime(); $jp = Join-Path $R 'artifacts/pester/pester-junit.xml'; $cp = Join-Path $R 'artifacts/pester/powershell-coverage.xml'; 'JUNIT_FRESH=' + ((Get-Item -LiteralPath $jp).LastWriteTimeUtc -gt $rs); 'COVERAGE_XML_FRESH=' + ((Get-Item -LiteralPath $cp).LastWriteTimeUtc -gt $rs); [xml]$j = Get-Content -LiteralPath $jp -Raw; $t = $j.SelectSingleNode('/testsuites'); 'TESTS=' + $t.GetAttribute('tests') + ' FAILURES=' + $t.GetAttribute('failures') + ' ERRORS=' + $t.GetAttribute('errors'); $j.SelectNodes('//testcase[failure or error]') | ForEach-Object { 'FAILED_CASE | ' + (($_.GetAttribute('classname') -replace '\\', '/') -replace $root, 'WORKTREE_ROOT') + ' | ' + $_.GetAttribute('name') }; [xml]$x = Get-Content -LiteralPath $cp -Raw; $c = $x.SelectSingleNode("/report/counter[@type='LINE']"); 'REPORT_LINE_COUNTER=' + $c.OuterXml; $mi = [double]$c.GetAttribute('missed'); $co = [double]$c.GetAttribute('covered'); 'REPO_WIDE_LINE_PCT=' + (100 * $co / ($co + $mi)).ToString('0.00', [Globalization.CultureInfo]::InvariantCulture); 'THRESHOLD_85_MET=' + (($co / ($co + $mi)) -ge 0.85); $m = @($x.SelectNodes('/report/package') | Where-Object { ($_.GetAttribute('name') -replace '\\', '/') -like '*/.claude/hooks' } | ForEach-Object { $_.SelectNodes('sourcefile') } | Where-Object { $_.GetAttribute('name') -eq 'validate-task-researcher-output.ps1' }); 'SOURCEFILE_MATCHES=' + $m.Count; $m | ForEach-Object { $_.SelectNodes('counter') } | Where-Object { $_.GetAttribute('type') -eq 'LINE' } | ForEach-Object { 'FILE_LINE_COUNTER=' + $_.OuterXml }
```

Output (verbatim):

```
PWSH_EXIT=0
LOG | RUN_START_UTC=2026-10-16T07:17:41.9511333Z
LOG | RUN_HEAD=bb386ed6bb6813aa2ae94465fda2611f86acd928
LOG | Code coverage population: source=config; files=203
LOG | Discovery found 10415 tests in 78.52s.
LOG | Code coverage population: source=settings; files=1
LOG | Code coverage population: source=settings; files=1
LOG | Code coverage population: source=settings; files=1
LOG | Code coverage population: source=settings; files=1
LOG | Tests completed in 1022.9s
LOG | Tests Passed: 10405, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
LOG | Covered 89.63% / 0%. 26,455 analyzed Commands in 203 Files.
JUNIT_FRESH=True
COVERAGE_XML_FRESH=True
TESTS=10415 FAILURES=0 ERRORS=0
REPORT_LINE_COUNTER=<counter type="LINE" missed="1731" covered="16384" />
REPO_WIDE_LINE_PCT=90.44
THRESHOLD_85_MET=True
SOURCEFILE_MATCHES=1
FILE_LINE_COUNTER=<counter type="LINE" missed="2" covered="100" />
```
