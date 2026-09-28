# Scratch Script Setup and Smoke Runs (P0-T12)

Timestamp: 2026-09-27T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusGlob.psm1 -CoverageOutputPath SCRATCH/pester-smoke.xml ; poetry run python SCRATCH/changed-lines-cov.py jacoco SCRATCH/pester-smoke.xml HEAD .claude/lib/blast-radius/BlastRadiusGlob.psm1
EXIT_CODE: 0
Output Summary: Fourteen scratch scripts were written verbatim from Appendix A into SCRATCH. The A3 smoke run printed FailedCount=0 and exactly one COVERAGE line with LinePercent=91.43. The B42 smoke run printed one CHANGED line with Found=True and ExecutableLines=70. Stop condition not reached.

SCRATCH denotes the executor's session scratchpad directory (outside the repository; never committed).

## Scripts created (fourteen)

| ID | File name in SCRATCH |
| --- | --- |
| A1 | run-ps.sh |
| A2 | pester-counts.ps1 |
| A3 | pester-coverage.ps1 |
| A4 | line-counts.ps1 |
| A5 | file-hashes.ps1 |
| A6 | ps-format-check.ps1 |
| A7 | py-cov-files.py |
| A8 | reset-batch-budget.ps1 |
| A9 | function-body-equal.ps1 |
| A10 | copy-file.ps1 |
| A11 | psd1-parse.ps1 |
| A12 | ci-wait.sh |
| B39 | changed-lines.py |
| B42 | changed-lines-cov.py |

## A3 smoke output (tail; exit 0)

```text
Tests Passed: 49, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Covered 91.67% / 75%. 84 analyzed Commands in 1 File.
TotalCount=49
PassedCount=49
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusGlob.psm1 AnalyzedLines=70 CoveredLines=64 LinePercent=91.43
```

Exactly one line begins "COVERAGE file=" and it carries the numeric value LinePercent=91.43.

## B42 smoke output (exit 0)

```text
CHANGED file=.claude/lib/blast-radius/BlastRadiusGlob.psm1 Found=True ExecutableLines=70 ChangedExecutable=0 Covered=0 ChangedLinePercent=100.00
```

The JaCoCo matcher joined the package name blast-radius to the sourcefile name
BlastRadiusGlob.psm1 and matched the repository-relative target by suffix.

## First 40 lines of SCRATCH/pester-smoke.xml (observed JaCoCo shape)

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE report PUBLIC "-//JACOCO//DTD Report 1.1//EN" "report.dtd"[]>
<report name="Pester (09/27/2026 14:38:55)">
  <sessioninfo id="this" start="1790519934309" dump="1790519935288" />
  <package name="blast-radius">
    <class name="blast-radius/BlastRadiusGlob" sourcefilename="BlastRadiusGlob.psm1">
      <method name="&lt;script&gt;" desc="()" line="37">
        <counter type="INSTRUCTION" missed="0" covered="5" />
        <counter type="LINE" missed="0" covered="4" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <method name="Test-GlobEntry" desc="()" line="69">
        <counter type="INSTRUCTION" missed="0" covered="4" />
        <counter type="LINE" missed="0" covered="4" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <method name="Get-ConcreteEntry" desc="()" line="104">
        <counter type="INSTRUCTION" missed="0" covered="7" />
        <counter type="LINE" missed="0" covered="5" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <method name="ConvertTo-GlobRegexText" desc="()" line="127">
        <counter type="INSTRUCTION" missed="0" covered="14" />
        <counter type="LINE" missed="0" covered="14" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <method name="Test-GlobMatch" desc="()" line="179">
        <counter type="INSTRUCTION" missed="0" covered="3" />
        <counter type="LINE" missed="0" covered="2" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <method name="Test-PathSubsumed" desc="()" line="216">
        <counter type="INSTRUCTION" missed="0" covered="9" />
        <counter type="LINE" missed="0" covered="9" />
        <counter type="METHOD" missed="0" covered="1" />
      </method>
      <method name="Get-LiteralPrefix" desc="()" line="264">
        <counter type="INSTRUCTION" missed="0" covered="7" />
        <counter type="LINE" missed="0" covered="4" />
        <counter type="METHOD" missed="0" covered="1" />
```
