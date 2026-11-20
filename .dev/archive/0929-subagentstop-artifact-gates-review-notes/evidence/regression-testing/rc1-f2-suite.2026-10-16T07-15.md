# Remediation Cycle 1 F2 Suite Run (P1-T7)

Timestamp: 2026-10-16T07-15
Command: sh SCRATCH/929/RC1-P1-T7-1.sh
EXIT_CODE: 0

Output Summary: suite `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` after the F2 edit: FAILED=0, FAILED_BLOCKS=0, FAILED_CONTAINERS=0, PASSED=66 (equal to PASSED=66 in the greatest `rc1-suite-coverage-baseline.*.md`, `rc1-suite-coverage-baseline.2026-10-16T07-05.md`); the NB-11 test passed. HOOK_LINE_COUNTER=<counter type="LINE" missed="18" covered="84" /> (unchanged from the baseline).

Script: SCRATCH/929/RC1-P1-T7-1.ps1 (suite coverage body from the plan's Fixed names with `$X = 'SCRATCH/929/RC1-P1-T7-coverage.xml'`), verbatim:

```powershell
Import-Module Pester -MinimumVersion 5.0.0; $X = 'SCRATCH/929/RC1-P1-T7-coverage.xml'; $c = New-PesterConfiguration; $c.Run.Path = @('tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1'); $c.Run.PassThru = $true; $c.Output.Verbosity = 'None'; $c.CodeCoverage.Enabled = $true; $c.CodeCoverage.Path = @('.claude/hooks/validate-task-researcher-output.ps1'); $c.CodeCoverage.OutputFormat = 'JaCoCo'; $c.CodeCoverage.OutputPath = $X; $r = Invoke-Pester -Configuration $c; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'FAILED_BLOCKS=' + $r.FailedBlocksCount; 'FAILED_CONTAINERS=' + $r.FailedContainersCount; 'PASSED=' + $r.PassedCount; [xml]$x = Get-Content -LiteralPath $X -Raw; $lc = $x.SelectSingleNode("/report/counter[@type='LINE']"); 'HOOK_LINE_COUNTER=' + $lc.OuterXml; $mi = [double]$lc.GetAttribute('missed'); $co = [double]$lc.GetAttribute('covered'); 'HOOK_LINE_PCT=' + (100 * $co / ($co + $mi)).ToString('0.00', [Globalization.CultureInfo]::InvariantCulture); exit [int]($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount)
```

Output (verbatim):

```
Passed | exits 2 with a stderr reason when last_assistant_message lacks a research-path
Passed | exits 0 when last_assistant_message carries a valid research-path
Passed | blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
Passed | exits 2 with the existing empty-output reason when last_assistant_message is an empty string
Passed | exits 2 with a payload anomaly reason for empty stdin
Passed | exits 2 with a payload anomaly reason for malformed stdin
Passed | exits 2 with a payload anomaly reason when last_assistant_message is absent
Passed | keeps validating when stop_hook_active is true
Passed | exits 2 with a stderr reason when the research-path file cannot be read
Passed | exits 2 with the validate-task-researcher-output: prefix when subagentstop-envelope.ps1 fails to load
Passed | has no S1, S2, S3 or S6 guard-shape finding
Passed | exits 2 in a separate process when the stdin envelope lacks a research-path
Passed | exits 0 when the research-path uses the research.yyyy-MM-ddTHH-mm.md form
Passed | R1 accepts 2026-10-11T10-26-subagentstop-envelope-artifact-gates-addendum-research.md
Passed | R1 accepts 2026-10-11-short-name-research.md
Passed | R1 accepts 20261011-short-name-research.md
Passed | R1 accepts 2026-10-11T1026-short-name-research.md
Passed | R1 accepts 2026-10-11T10-26-short-name.research.md
Passed | R1 accepts 2026-10-11-short-name.research.md
Passed | R1 accepts 20261011-short-name.research.md
Passed | R1 accepts 2026-10-11T1026-short-name.research.md
Passed | R1 accepts research.2026-10-11T10-26.md
Passed | R1 accepts research.2026-10-11.md
Passed | R1 accepts research-addendum.2026-10-11T10-26.md
Passed | R1 accepts research-addendum.2026-10-11.md
Passed | R1 accepts backslash path 2026-10-11T10-26-short-name-research.md
Passed | R1 rejects foo.md (no date stamp)
Passed | R1 rejects bad-name.md (no date stamp)
Passed | R1 rejects research-input.md (no date stamp)
Passed | R1 rejects research-findings.md (no date stamp)
Passed | R1 rejects orchestration-mechanics.research.md (no date stamp)
Passed | R1 rejects claude-ecosystem.md (no date stamp)
Passed | R1 rejects hook-surface-inventory.2026-06-27.md (stamp only as a suffix)
Passed | R1 rejects parallel-planner-surface.2026-08-07T12-30.md (stamp only as a suffix)
Passed | R1 rejects 2026-07-22-npm-audit-fix-strategy.md (leading stamp without research ending)
Passed | R1 rejects 2026-10-09T05-40-root-prettier-fixture-exclusion.md (leading stamp without research ending)
Passed | R1 rejects 2026-10-11T10-26-research.md (empty short name)
Passed | R1 rejects 2026-10-11T10-26--short-name-research.md (short name starts with a hyphen)
Passed | R1 rejects 2026-10-11T10-26-short_name-research.md (underscore in short name)
Passed | R1 rejects 2026-10-11T10-26-short name-research.md (space in short name)
Passed | R1 rejects 2026-10-11T10-26-short.name-research.md (extra dot in short name)
Passed | R1 rejects 2026-10-11T10-26-short-name-research.MD (upper-case extension)
Passed | R1 rejects 2026-10-11T10-26-short-name-research.markdown (other extension)
Passed | R1 rejects 2026-10-11T10-26-short-name-research.txt (other extension)
Passed | R1 rejects 2026-10-11T12:05-short-name-research.md (stamp in another shape)
Passed | R1 rejects 2026-1-11-short-name-research.md (stamp in another shape)
Passed | R1 rejects research.2026-10-11T1205.md (compact time after research.)
Passed | R1 rejects research.2026-10-11T10-26-short-name.md (stamp after research. with a short name)
Passed | R3 accepts the exhaustive scope entire worktree
Passed | R3 accepts the exhaustive scope whole worktree with all directories
Passed | R3 accepts the exhaustive scope entire repository accepted before R3
Passed | R3 accepts the exhaustive scope complete source tree
Passed | R3 accepts the exhaustive scope whole repo
Passed | R3 accepts the exhaustive scope upper-case entire worktree
Passed | R3 accepts the exhaustive scope entire worktree root
Passed | R3 accepts the exhaustive scope whole repository excluding docs
Passed | R3 accepts the exhaustive scope NB-2 whole worktree restricted to code
Passed | R3 accepts the exhaustive scope NB-2 entire repository excluding docs
Passed | R3 rejects the exhaustive scope the hooks folder
Passed | R3 rejects the exhaustive scope noun without a quantifier
Passed | R3 rejects the exhaustive scope quantifier without a noun
Passed | R3 rejects the exhaustive scope path-shaped value
Passed | R3 rejects the exhaustive scope all inside allocated
Passed | R3 rejects the exhaustive scope tree inside subtree
Passed | R3 rejects the exhaustive scope worktree inside worktrees
Passed | returns the guard ExitCode and Reason object in process when a dependency failure is recorded (S6 by design)
FAILED=0
FAILED_BLOCKS=0
FAILED_CONTAINERS=0
PASSED=66
HOOK_LINE_COUNTER=<counter type="LINE" missed="18" covered="84" />
HOOK_LINE_PCT=82.35
```
