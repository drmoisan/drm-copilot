# Part 3.2 Verification — validate-feature-review-coverage.ps1 (multi-language coverage floors)

- Timestamp: 2026-06-28T00-00
- Issue: #259
- File: `.claude/hooks/validate-feature-review-coverage.ps1`
- Outcome: NO-OP (all required elements present; no code change required)

## Verified Elements

### Per-language LCOV parsing (line + branch)

- `Get-LcovRepoCoverage` (lines 140–159): sums `LF:` (lines found) and `LH:` (lines hit), returns percent.
- `Get-LcovBranchCoverage` (lines 161–184): sums `BRF:` (branches found) and `BRH:` (branches hit), returns percent.
- Routing:
  - TypeScript line/branch -> `coverage/lcov.info` (lines 250, 213)
  - Python line/branch -> `artifacts/python/lcov.info` (lines 251, 214)

### Per-language JaCoCo parsing (line + branch)

- `Get-JacocoRepoCoverage` (lines 221–241): sums `counter[@type="LINE"]` missed/covered, returns percent.
- `Get-JacocoBranchCoverage` (lines 186–206): sums `counter[@type="BRANCH"]` missed/covered, returns percent.
- Routing:
  - PowerShell line/branch -> `artifacts/pester/powershell-coverage.xml` (lines 252, 215)
  - CSharp line/branch -> `artifacts/csharp/coverage.xml` (lines 253, 216)

### Both floors enforced in `Test-LanguageCoverageRow` (lines 258–332)

- Line floor: when `$RepoWidePct -lt 85.0` and no FAIL verdict on a coverage row -> FAIL (lines 313–321).
- Branch floor: when `$BranchPct -lt 75.0` (`$BranchFloor = 75.0`) -> FAIL (lines 323–329).

### Scope-narrowing as failure

- `$narrowingPattern` (line 295): `(?i)(informational only|context only|out of plan scope|out of scope|not applicable|\bN/A\b|\bUNVERIFIED\b)`.
- A coverage row matching that pattern for a changed-file language yields FAIL (lines 296–303).

### Changed-language enumeration

- `Get-ChangedLanguageSet` (lines 121–138) maps changed paths in `artifacts/pr_context.summary.txt` to TypeScript/.tsx, Python/.py, PowerShell/.ps1/.psm1, CSharp/.cs.

## SubagentStop Block Form (Unchanged)

Entrypoint (lines 449–459) retains `Write-Error` + `exit 1` to block, `exit 0` to allow. No top-level `decision` envelope introduced. Correct for SubagentStop; not changed.
