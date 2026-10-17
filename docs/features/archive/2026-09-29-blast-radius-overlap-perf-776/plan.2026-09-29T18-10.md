# 2026-09-29-blast-radius-overlap-perf (Plan)

- **Issue:** #776
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T18-10
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** minor-audit
- **Language in scope:** PowerShell only
- **Requirements source (sole AC source):** `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md`, section `## Acceptance Criteria` (five checklist entries, identified in this plan as AC-1 through AC-5 in document order)

**Mode note (minor-audit):** `spec.md`, `user-story.md`, and `research.md` are intentionally absent and are not required. Only the `## Acceptance Criteria` section of `issue.md` is the acceptance-criteria source. Execution fails closed if `spec.md` or `user-story.md` appears in the feature folder, if the `## Acceptance Criteria` section is missing from `issue.md`, if a required Phase 0 artifact is missing or incomplete, or if checklist state contradicts evidence on disk.

**Fail-closed evidence rule:** PowerShell policy requires line coverage >= 85%. Baseline and final-QC test tasks therefore record numeric coverage. If any required baseline artifact, final-QC artifact, or coverage value is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Every evidence-producing task names its artifact path. A task is not checked off until its artifact exists and carries every required field. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; an artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`.

## Terms used in every task

- FEATURE means `docs/features/active/2026-09-29-blast-radius-overlap-perf-776`. Evidence is written only under FEATURE/evidence/baseline/, FEATURE/evidence/other/, and FEATURE/evidence/qa-gates/. No `artifacts/` path is an evidence location; `artifacts/pester/` is read only as tool output. No non-canonical evidence path was supplied by the caller, so no override was recorded.
- TS means the execution time of the task in yyyy-MM-ddTHH-mm form.
- SCRATCH means the executor's session scratchpad directory, outside the repository. Artifacts record it as the literal token SCRATCH, never as a host path. The repository root is recorded as the literal token REPO.
- BASE_SHA means the commit recorded by P0-T3 before any edit. Every scope diff and every changed-line computation is anchored to it.
- GLOB means `.claude/lib/blast-radius/BlastRadiusGlob.psm1`; CONFLICT means `.claude/lib/blast-radius/BlastRadiusConflict.psm1`.
- GLOB-MIRROR and CONFLICT-MIRROR mean the byte-identical bundle copies of those two files under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`.
- TEST-CACHE means `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1` (new); TEST-OVERLAP means `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1` (new).
- HISTORICAL means `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` (unchanged; 3 fixtures x 3 generated tests = 9 tests).
- Script names A1 through A12 refer to the scratch scripts in the Appendix. Every PowerShell scratch script runs as `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <arguments>` from the repository root (script A1). An executor that has a PowerShell tool may instead run `pwsh -NoProfile -NonInteractive -File SCRATCH/<script>.ps1 <arguments>` through that tool; the `Command:` field records the invocation actually used.
- MCP-TEST means `mcp__drm-copilot__run_poshqc_test` called with `workspace_root` set to REPO and no `scan_folders`, which runs the full Pester suite under `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` semantics and writes `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`. The MCP result text is a fixed template and carries no counts; no acceptance condition reads a number from it. Test totals come only from A11 over the JUnit file, coverage only from A12 over the coverage file, analyzer findings only from A7.

## Scope and recorded design decisions

Production files edited: GLOB and CONFLICT only. Their mirrors are produced by copy (A10), never by Write or Edit. New test files: TEST-CACHE and TEST-OVERLAP. No existing test file, test assertion, or fixture is edited. `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`, `.claude/lib/blast-radius/BlastRadius.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `scripts/dev_tools/_blast_radius_glob.py`, and `scripts/dev_tools/compute_blast_radius.py` are not edited.

- D1 — No new exported function. The export list of every blast-radius module stays byte-for-byte the same (AC-4). A non-exported function of one PowerShell module is not callable from another module, so the record-form overlap evaluation lives inside CONFLICT, and the scheduling cost loop in `BlastRadiusScheduling.psm1` (line 269) keeps calling the exported `Test-EntryOverlap`. That loop speeds up only through the cheaper `Test-EntryOverlap` of P1-T4.
- D2 — Timing threshold. Pass condition for AC-2: baseline median divided by post-change median is at least 4.00, with coverage disabled, on the same host and Pester version. Rationale: in the slowest test ("matches detection at tolerance 0 for followups-2026-09-27") about 110 of about 200 full pairwise passes go through `Get-SmallestPathOverlap`, which this plan rewrites to evaluate each pair inline, and about 90 go through the unchanged scheduling cost loop, whose per-pair cost falls from roughly five advanced-function invocations to one or two. The estimated speedup for the file is 5x to 7x. A 4.00 threshold leaves margin for timing variance and for the part of the gain D1 leaves out of reach, and still requires a material reduction (190 s to at most about 48 s on the baseline host).
- D3 — Mixed glob-and-concrete pairs. The record-form decision evaluates the two literal nest tests before `Test-GlobMatch`. All three terms are pure, so reordering an OR of them does not change the result. A full glob match implies the candidate starts with the glob's literal prefix, which implies one of the two nest tests holds, so the regex term never changes the verdict. It is kept for structural parity with the Python `_entries_overlap`, and in practice it is evaluated only for non-overlapping mixed pairs.
- D4 — Regex cache. `$script:GlobRegexCache` is a script-scoped `Dictionary[string, regex]` with an ordinal key comparer, memoizing a pure translation. It lives per module instance (reset by `Import-Module -Force`) and is bounded by the number of distinct patterns seen. This is the one sanctioned mutable script-scoped variable in this change.
- D5 — Simple functions in hot paths. `Get-GlobRegex` (GLOB) is declared without `[CmdletBinding()]` because it runs once per `Test-GlobMatch` call and advanced-function parameter binding is the per-call cost this issue removes. A comment above it states that reason. All exported functions keep `[CmdletBinding()]` and their parameter attributes.
- D6 — 500-line limit. Measured at planning time: GLOB 431, CONFLICT 290, `BlastRadius.psm1` 475, `BlastRadiusScheduling.psm1` 486. New code goes only into GLOB and CONFLICT. Target: GLOB at most 480 and CONFLICT at most 400; hard limit 500 (P2-T9).

## Execution constraints

- Batch budget. This plan writes two production PowerShell files through Write or Edit (GLOB and CONFLICT). Test files are not counted, and mirrors are produced by A10, which does not pass through the hook. No scheduled reset is needed. If `.claude/hooks/enforce-powershell-batch-budget.ps1` still denies a GLOB or CONFLICT write with `POWERSHELL_LARGE_PATH_REQUIRED` (stale counts earlier in the session), take these steps. List `.claude/state/powershell-batch-budget.*.json`. Delete the one file whose `prodFiles` equals the "already counted" list in the denial text. Write FEATURE/evidence/other/batch-budget-reset.TS.md with the deleted file name, its prior `prodFiles`, and the denial text. Retry the write once. A second denial stops the plan.
- Shell route. Every git command is one plain command with literal arguments. Scratch scripts are written with the Write tool into SCRATCH (outside the repository, so no hook slot is used). No multi-line `-c` argument is used.
- Long-running commands. P0-T10, P0-T11, P2-T3, P2-T5, and any run of the full suite outside MCP run in the background. The executor waits for the completion notification before reading output. While an A8 timing run (P0-T10 or P2-T5) is in progress, the executor starts no other test, analyzer, formatter, or benchmark command, and the next task begins only after that run's completion notification. A timed-out foreground run is not a result.
- Hooks. If a hook denies a command in this plan, stop and report the denial text. Do not bypass it.
- Stop conditions. When a stop condition in a task is reached, write the task's artifact with the stop reason and report to the caller. Do not improvise a substitute design.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Verify the minor-audit preconditions for FEATURE (`docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md`) and write FEATURE/evidence/baseline/phase0-mode-check.TS.md.
      Commands: `ls docs/features/active/2026-09-29-blast-radius-overlap-perf-776`; `grep -c -x -F "## Acceptance Criteria" docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md`; `grep -c -x -F -e "- Work Mode: minor-audit" docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md`.
      Acceptance: the listing contains neither spec.md nor user-story.md; each grep prints 1. Any other result stops the plan.
- [x] [P0-T2] Read the policy files in the required order and write FEATURE/evidence/baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `.github/copilot-instructions.md`, `CLAUDE.md`, `.claude/rules/tonality.md`; (2) `.github/instructions/general-code-change.instructions.md`, `.claude/rules/general-code-change.md`; (3) `.github/instructions/general-unit-test.instructions.md`, `.claude/rules/general-unit-test.md`; (4) `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`; (5) `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`; (6) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
      Acceptance: the artifact has the three required headers and lists all 13 files in that order.
- [x] [P0-T3] Record BASE_SHA and the clean pre-edit state of `.claude/lib/blast-radius` and write FEATURE/evidence/baseline/base-sha.TS.md.
      Commands: `git rev-parse HEAD`; `git status --porcelain -- .claude/lib/blast-radius extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius tests/scripts/claude-lib/blast-radius tests/fixtures/blast_radius`.
      Acceptance: rev-parse prints one 40-character hexadecimal SHA, which is recorded as BASE_SHA, and the status command prints nothing. Any status output stops the plan, because the baseline would not measure the committed code.
- [x] [P0-T4] Write scratch scripts A1 through A12 from the Appendix verbatim into SCRATCH, hash them, and write FEATURE/evidence/baseline/scratch-scripts.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 SCRATCH/pester-coverage.ps1 SCRATCH/line-counts.ps1 SCRATCH/file-hashes.ps1 SCRATCH/format-check.ps1 SCRATCH/pssa.ps1 SCRATCH/timing.ps1 SCRATCH/export-surface.ps1 SCRATCH/copy-file.ps1 SCRATCH/junit-summary.ps1 SCRATCH/coverage-xml.ps1`.
      Acceptance: exit 0 and 12 hash lines are printed. Paths are recorded with the SCRATCH token.
- [x] [P0-T5] Baseline line counts: run A4 over `.claude/lib/blast-radius/BlastRadiusGlob.psm1`, `.claude/lib/blast-radius/BlastRadiusConflict.psm1`, `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`, and `.claude/lib/blast-radius/BlastRadius.psm1`, and write FEATURE/evidence/baseline/line-counts.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1 .claude/lib/blast-radius/BlastRadius.psm1`.
      Acceptance: exit 0 and LineCount values 431, 290, 486, 475 in that order. If GLOB or CONFLICT differs, stop, because D6 headroom was derived from those counts.
- [x] [P0-T6] Baseline mirror identity: run A5 over GLOB, GLOB-MIRROR (`extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusGlob.psm1`), CONFLICT, and CONFLICT-MIRROR, and write FEATURE/evidence/baseline/mirror-hashes.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusConflict.psm1`.
      Acceptance: exit 0, and each primary hash equals its mirror hash. An unequal pair stops the plan, because copying would then not be a pure sync.
- [x] [P0-T7] Baseline read-only format check with A6 over every module in `.claude/lib/blast-radius` and every test file in `tests/scripts/claude-lib/blast-radius`, and write FEATURE/evidence/baseline/format-check.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/format-check.ps1 .claude/lib/blast-radius/*.psm1 tests/scripts/claude-lib/blast-radius/*.ps1` (sh expands the globs).
      Acceptance: exit 0 and a `FORMAT-SUMMARY ChangedCount=` line recorded with its value and every `Changed=True` file name. A non-zero count is recorded as pre-existing drift; it predicts which files the P2-T1 formatter will rewrite.
- [x] [P0-T8] Baseline analyzer findings: run A7 over GLOB and CONFLICT (`.claude/lib/blast-radius/BlastRadiusGlob.psm1`, `.claude/lib/blast-radius/BlastRadiusConflict.psm1`), and write FEATURE/evidence/baseline/pssa.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pssa.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1`.
      Acceptance: exit 0 and a `PSSA-TOTAL=` line recorded with its numeric value and every `PSSA-FINDING` line.
- [x] [P0-T9] Baseline export surface of every module under `.claude/lib/blast-radius`: run A9 and write FEATURE/evidence/baseline/export-surface.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/export-surface.ps1`.
      Acceptance: exit 0, every `SURFACE` line recorded verbatim, and `SURFACE-COUNT=` and `SURFACE-SHA256=` recorded. P2-T11 compares against this SHA.
- [x] [P0-T10] Baseline timing of HISTORICAL (`tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`) with coverage disabled, before any production edit: run A8 with three runs in the background and write FEATURE/evidence/baseline/historical-runs-timing.TS.md.
      Commands: `git status --porcelain -- .claude/lib/blast-radius`; `sh SCRATCH/run-ps.sh SCRATCH/timing.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -Runs 3`.
      Acceptance: the status command prints nothing; A8 exits 0 and prints `CODE-COVERAGE-ENABLED=False`, one `PESTER-VERSION=` line, three `RUN` lines each with `Total=9 Passed=9 Failed=0`, and one `MEDIAN-SECONDS=` line. The artifact records every line; its `Output Summary:` states the three elapsed values and the median.
- [x] [P0-T11] Baseline blast-radius Pester run with coverage on GLOB and CONFLICT (`tests/scripts/claude-lib/blast-radius`): run A3 in the background and write FEATURE/evidence/baseline/blast-radius-pester-coverage.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius -CoveragePath .claude/lib/blast-radius/BlastRadiusGlob.psm1,.claude/lib/blast-radius/BlastRadiusConflict.psm1 -CoverageOutputPath SCRATCH/baseline-blast-coverage.xml`.
      Acceptance: exit 0, `FailedCount=0`, and `TotalCount=`, `PassedCount=`, and one `COVERAGE ... LinePercent=` line per module, all recorded as numbers in `Output Summary:`. A non-zero FailedCount stops the plan, because AC-1 presumes a green baseline.
- [x] [P0-T12] Baseline full Pester suite through MCP-TEST, with JUnit and coverage parsing, and write FEATURE/evidence/baseline/full-suite-pester.TS.md.
      Commands: `date -u +%Y-%m-%dT%H:%M:%SZ` (record as START); MCP-TEST; `sh SCRATCH/run-ps.sh SCRATCH/junit-summary.ps1 -Path artifacts/pester/pester-junit.xml`; `sh SCRATCH/run-ps.sh SCRATCH/coverage-xml.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -BaseRef BASE_SHA .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1` (substitute the recorded SHA for BASE_SHA).
      Acceptance: both scripts exit 0; `JUNIT-LAST-WRITE-UTC` and `COVERAGE-LAST-WRITE-UTC` are both later than START (an earlier value means the MCP run wrote nothing and stops the plan); `JUNIT-TESTCASES`, `JUNIT-FAILED`, every `JUNIT-FAILED-CASE` line (this is the baseline failure set), every `JUNIT-BLAST-SUITE` line, and both `COVERAGE ... LinePercent=` values are recorded as numbers.

### Phase 1 — Constrained Small-Path Implementation

This phase is one delegated handoff. The small-path implementation engineer performs P1-T2 through P1-T10 in order. No implementation is performed during planning. Each task writes FEATURE/evidence/other/p1-tN.TS.md (N is the task number) recording its commands, exit codes, and output summary. Each p1-tN artifact for P1-T2 through P1-T10 carries exactly one top-level `EXIT_CODE:`, equal to the exit code of the task's last non-grep command (A2, A5, or A10), and no `ExpectedExitCode:`. Each grep's printed count and exit code are recorded inside `Output Summary:` as `GREP count=<n> exit=<n>`, one line per grep, in command order. The P1-T1 artifact records the engineer's completion report and carries no `EXIT_CODE:` line, because P1-T1 runs no command.

- [x] [P1-T1] Delegated implementation handoff: apply P1-T2 through P1-T10 to GLOB (`.claude/lib/blast-radius/BlastRadiusGlob.psm1`), CONFLICT (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`), TEST-CACHE, TEST-OVERLAP, and the two mirrors only.
      Constraints: no edit to any `Export-ModuleMember` block, exported function name, parameter, parameter attribute, or `[OutputType()]`; no edit to any existing test file or fixture; no `Mock` in the new test files; the Python port is untouched.
      Acceptance: every acceptance condition of P1-T2 through P1-T10 holds, and FEATURE/evidence/other/p1-t1.TS.md records the engineer's completion report.
- [x] [P1-T2] In GLOB (`.claude/lib/blast-radius/BlastRadiusGlob.psm1`), replace `$script:GlobWildcard = @('*', '?')` with the script-scoped wildcard character array `$script:GlobWildcardCharacter = [char[]]@('*', '?')`, keeping the comment above it. Make `Test-GlobEntry` return `$Entry.IndexOfAny($script:GlobWildcardCharacter) -ge 0`. Make `Get-LiteralPrefix` compute one `IndexOfAny` over the same array, returning `$Entry.Substring(0, $index)` when the index is non-negative and `$Entry` otherwise.
      This removes the per-character `Test-GlobEntry` call and the `foreach` over `$script:GlobWildcard`. The task creates the literal "IndexOfAny" in GLOB and removes the literals "Test-GlobEntry -Entry ([string]$Entry", "foreach ($wildcard in", and "$script:GlobWildcard =".
      Commands: `grep -c -F "IndexOfAny" .claude/lib/blast-radius/BlastRadiusGlob.psm1`; `grep -c -F -e 'Test-GlobEntry -Entry ([string]$Entry' -e 'foreach ($wildcard in' .claude/lib/blast-radius/BlastRadiusGlob.psm1`; `grep -c -F '$script:GlobWildcard =' .claude/lib/blast-radius/BlastRadiusGlob.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1`.
      Acceptance: the first grep prints 2 or more; the second grep prints 0 (it exits 1, which is the pass condition here); the third grep prints 0 (exit 1 is the pass condition); A2 exits 0 with `FailedCount=0`.
- [x] [P1-T3] In GLOB (`.claude/lib/blast-radius/BlastRadiusGlob.psm1`), add the regex cache and route `Test-GlobMatch` through it.
      Add `$script:GlobRegexCache = [System.Collections.Generic.Dictionary[string, regex]]::new([StringComparer]::Ordinal)`. Add the non-exported simple function `Get-GlobRegex` (param `[string] $Pattern`; no `[CmdletBinding()]`, per D5). On a miss it builds `[regex]::new('\A(?:' + (ConvertTo-GlobRegexText -Pattern $Pattern) + ')\z')`, stores it under `$Pattern`, and returns it; on a hit it returns the stored instance. `Test-GlobMatch` returns `(Get-GlobRegex -Pattern $Pattern).IsMatch($Candidate)`. Add a module-header parity note on the cache (D4).
      The task creates the literals "GlobRegexCache" and "function Get-GlobRegex" and removes the literal "[regex]::IsMatch($Candidate".
      Commands: `grep -c -F "GlobRegexCache" .claude/lib/blast-radius/BlastRadiusGlob.psm1`; `grep -c -F "function Get-GlobRegex" .claude/lib/blast-radius/BlastRadiusGlob.psm1`; `grep -c -F '[regex]::IsMatch($Candidate' .claude/lib/blast-radius/BlastRadiusGlob.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1`.
      Acceptance: the first grep prints 2 or more; the second prints 1; the third prints 0 (exit 1 is the pass condition); A2 exits 0 with `FailedCount=0`.
- [x] [P1-T4] In GLOB (`.claude/lib/blast-radius/BlastRadiusGlob.psm1`), rewrite the body of `Test-EntryOverlap` so it makes no call to `Test-GlobEntry` or `Get-LiteralPrefix`. It computes `$indexA = $EntryA.IndexOfAny($script:GlobWildcardCharacter)` and `$indexB` once, derives each entry's glob flag (`-ge 0`) and literal prefix (`Substring(0, index)`) from those indexes, and keeps the four existing cases, their conditions, and their comments.
      The mixed cases evaluate the two nest tests before `Test-GlobMatch`, per D3. The task removes the literals "Test-GlobEntry -Entry $EntryA", "Test-GlobEntry -Entry $EntryB", "Get-LiteralPrefix -Entry $EntryA", and "Get-LiteralPrefix -Entry $EntryB".
      Commands: `grep -c -F -e 'Test-GlobEntry -Entry $EntryA' -e 'Test-GlobEntry -Entry $EntryB' -e 'Get-LiteralPrefix -Entry $EntryA' -e 'Get-LiteralPrefix -Entry $EntryB' .claude/lib/blast-radius/BlastRadiusGlob.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`.
      Acceptance: the grep prints 0 (it currently prints 6; exit 1 is the pass condition); both A2 runs exit 0 with `FailedCount=0`.
- [x] [P1-T5] In CONFLICT (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`), add the non-exported advanced function `ConvertTo-PathOverlapRecord`.
      It takes `[string[]] $Entry` (empty collection and empty strings allowed) and returns one hashtable per entry, in input order, with keys `Entry`, `IsGlob` (from the exported `Test-GlobEntry`), `Prefix` (from the exported `Get-LiteralPrefix` for a glob entry, `$null` otherwise), and `Directory` (`$Entry.TrimEnd('/') + '/'`). It is called once per collection, so its per-entry advanced calls are O(n). The task creates the literal "function ConvertTo-PathOverlapRecord".
      Commands: `grep -c -F "function ConvertTo-PathOverlapRecord" .claude/lib/blast-radius/BlastRadiusConflict.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1`.
      Acceptance: the grep prints 1; A2 exits 0 with `FailedCount=0`.
- [x] [P1-T6] In CONFLICT (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`), rewrite the body of `Get-SmallestPathOverlap` with an unchanged signature, help, and return contract.
      Build the records of `$PathA` and `$PathB` once with `ConvertTo-PathOverlapRecord`. In the nested loop, decide each pair inline over the records with exactly the four cases of `Test-EntryOverlap`:
      - two concrete entries: ordinal equality or either anchored directory prefix;
      - glob and concrete, either order: prefix-nests-directory, directory-nests-prefix, then `Test-GlobMatch` (D3);
      - two globs: either prefix nests the other.
      For each overlapping pair, form the ordinally ordered joined detail with `$script:PairDetailSeparator` and keep it only when it is the first or `[string]::CompareOrdinal` places it below the current minimum. Return that minimum, or `$null` when nothing overlaps. Add a comment naming `Test-EntryOverlap` as the relation this inline decision reproduces and TEST-OVERLAP as the parity guard.
      The task removes the literals "Test-EntryOverlap -EntryA" and "$detail.Add(".
      Commands: `grep -c -F -e 'Test-EntryOverlap -EntryA' -e '$detail.Add(' .claude/lib/blast-radius/BlastRadiusConflict.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`.
      Acceptance: the grep prints 0 (it currently prints 2; exit 1 is the pass condition); both A2 runs exit 0 with `FailedCount=0`.
- [x] [P1-T7] Create TEST-CACHE (`tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1`). It imports GLOB with `Import-Module (Resolve-Path ...) -Force`, uses `InModuleScope BlastRadiusGlob` for the non-exported helper and the cache, uses Arrange-Act-Assert comments, and uses no Mock.
      It holds exactly these 12 tests:
      - Describe 'Glob regex cache (issue #776)':
        - (1) 'returns the same compiled regex instance for a repeated pattern' (`[object]::ReferenceEquals` is true);
        - (2) 'adds one cache entry for a new pattern and none for a repeat' (the pattern is removed from the cache first, so the test is order-independent);
        - (3) 'keys the cache ordinally so patterns differing by case stay distinct' (`A/*.py` and `a/*.py` are two keys, and `Test-GlobMatch -Pattern 'A/*.py' -Candidate 'a/x.py'` is false);
        - (4) 'anchors the cached regex as a whole-string match' (`(Get-GlobRegex -Pattern 'scripts/*').ToString()` equals `\A(?:scripts/[^/]*)\z`).
      - Describe 'Test-GlobMatch cached and uncached agreement (issue #776)': one It 'returns <Expected> for <Pattern> against <Candidate> on the first and the repeated call' with -ForEach rows `scripts/**`|`scripts/dev_tools/a.py`|True, `scripts/*`|`scripts/dev_tools/a.py`|False, `a/?.py`|`a/x.py`|True, `a/[ab].py`|`a/a.py`|False, and `a//*`|`a//`|True. Each row removes its pattern from the cache, asserts it is absent, then calls twice (5 tests).
      - Describe 'Get-LiteralPrefix single-scan fast path (issue #776)': 'returns an empty prefix when the entry starts with <_>' -ForEach `*`, `?` (2 tests), and 'returns an empty prefix for an empty entry' (1 test).
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1`; `grep -c -w -F Mock tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1`.
      Acceptance: A2 exits 0 with `TotalCount=12` and `FailedCount=0`; the grep prints 0 (exit 1 is the pass condition).
- [x] [P1-T8] Create TEST-OVERLAP (`tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1`). It imports the facade `.claude/lib/blast-radius/BlastRadius.psm1` first, CONFLICT second, and GLOB (`.claude/lib/blast-radius/BlastRadiusGlob.psm1`) third, each with `-Force`. The facade-before-CONFLICT order follows the order comment in `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1`. GLOB is imported last because neither earlier module re-exports `Test-EntryOverlap`, and importing it last means no later `-Force` sibling import replaces it. It uses `InModuleScope BlastRadiusConflict` only for `ConvertTo-PathOverlapRecord` and uses no Mock.
      It holds exactly these 21 tests:
      - Describe 'Get-SmallestPathOverlap record-form parity (issue #776)': one It 'returns <Expected> for <EntryA> against <EntryB> in both argument orders' with -ForEach rows (13 tests). For each row it asserts that `$null -ne (Get-SmallestPathOverlap -PathA @($EntryA) -PathB @($EntryB))`, the swapped call, `Test-EntryOverlap -EntryA $EntryA -EntryB $EntryB`, and the swapped call all equal Expected. The rows (EntryA, EntryB, Expected) are:
        - `a/1.py`, `a/1.py`, True
        - `a/1.py`, `a/2.py`, False
        - `scripts/dev_tools`, `scripts/dev_tools/a.py`, True
        - `scripts/**`, `scripts/dev_tools/a.py`, True
        - `tests/**`, `scripts/a.py`, False
        - `scripts/*/a.py`, `scripts/dev_tools/*.py`, True
        - `scripts/*.py`, `tests/*.py`, False
        - `scripts/dev_tools`, `scripts/dev_toolsX/a.py`, False
        - `docs/features/active/alpha`, `docs/features/active/beta/**`, False
        - `scripts/dev_tools/`, `scripts/dev_tools/a.py`, True
        - `a//*`, `a//`, True
        - `scripts/dev_tools`, `scripts/*/a.py`, True
        - empty string, `a/b.py`, False
      - Describe 'Get-SmallestPathOverlap minimum tracking (issue #776)' (6 tests):
        - 'returns null when the first collection is empty';
        - 'returns null when the second collection is empty';
        - 'returns null when no pair overlaps' (`scripts/a.py` against `tests/**`);
        - 'returns the ordinally smallest detail rather than the culture smallest' (both collections `B/x.py`, `a/x.py`; expected `B/x.py ~ B/x.py`);
        - 'returns the same detail in both argument orders for a mixed glob and concrete collection' (PathA `tests/b.ps1`, `scripts/**`; PathB `scripts/dev_tools/a.py`, `tests/b.ps1`; expected `scripts/** ~ scripts/dev_tools/a.py`);
        - 'orders a glob and its trailing-slash concrete match inside the detail' (`a//*` against `a//`; expected `a// ~ a//*`).
      - Describe 'ConvertTo-PathOverlapRecord (issue #776)' (2 tests):
        - 'classifies a glob entry and records its literal prefix' (`scripts/**` gives IsGlob True and Prefix `scripts/`);
        - 'records the anchored directory form of a concrete entry with a trailing separator' (`scripts/dev_tools/` gives IsGlob False and Directory `scripts/dev_tools/`).
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1`; `grep -c -w -F Mock tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1`.
      Acceptance: A2 exits 0 with `TotalCount=21` and `FailedCount=0`; the grep prints 0 (exit 1 is the pass condition).
- [x] [P1-T9] Sync the mirrors by copy: run A10 for GLOB to GLOB-MIRROR and for CONFLICT to CONFLICT-MIRROR (`extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`), then A5 over the four files.
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/copy-file.ps1 -Source .claude/lib/blast-radius/BlastRadiusGlob.psm1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusGlob.psm1`; the same for BlastRadiusConflict.psm1; `sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusConflict.psm1`.
      Acceptance: each A10 run exits 0 and prints its `COPIED` line; each primary hash equals its mirror hash; each primary hash differs from its P0-T6 value.
- [x] [P1-T10] Fast gate: run A2 over the whole blast-radius Pester directory `tests/scripts/claude-lib/blast-radius`.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius`.
      Acceptance: exit 0, `FailedCount=0`, and `TotalCount` equals the P0-T11 TotalCount plus 33.

### Phase 2 — Final QC Loop

Run the PowerShell toolchain in order: format (P2-T1), lint (P2-T2), and tests (P2-T3, P2-T4, P2-T7). Type checking does not apply to PowerShell. If any Phase 2 task fails or changes a file, the small-path engineer remediates. After remediation, re-run P1-T9 when GLOB or CONFLICT changed, then restart from P2-T1. Every Phase 2 task is unconditional; none has a SKIPPED outcome. Artifacts go to FEATURE/evidence/qa-gates/ unless stated.

- [x] [P2-T1] Format with `mcp__drm-copilot__run_poshqc_format` (`workspace_root` REPO, `scan_folders` [".claude/lib/blast-radius", "tests/scripts/claude-lib/blast-radius"]), observing the tree before and after, and write FEATURE/evidence/qa-gates/format.TS.md.
      Commands: A5 over GLOB, CONFLICT, TEST-CACHE, and TEST-OVERLAP before the call (`sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1`); the MCP call; the same A5 command after; `git status --porcelain -- .claude/lib/blast-radius tests/scripts/claude-lib/blast-radius`.
      Acceptance: all four hashes are unchanged across the call, and the status output lists no path other than the four in-scope files. A listing of none of them is also acceptable when they are already committed. If a hash changed, re-run P1-T9 and restart at P2-T1. If any other path appears, stop and report it.
- [x] [P2-T2] Lint: call `mcp__drm-copilot__run_poshqc_analyze` (`workspace_root` REPO, same `scan_folders`) for toolchain compliance, then run A7 over GLOB, CONFLICT, TEST-CACHE, and TEST-OVERLAP, and write FEATURE/evidence/qa-gates/lint.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pssa.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1`.
      Acceptance: A7 exits 0 and prints `PSSA-TOTAL=0`. The MCP result text is recorded but not used as evidence of the finding count.
- [x] [P2-T3] Blast-radius fast gate with coverage: run A3 over `tests/scripts/claude-lib/blast-radius` with coverage on GLOB and CONFLICT (background run), and write FEATURE/evidence/qa-gates/blast-radius-pester-coverage.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius -CoveragePath .claude/lib/blast-radius/BlastRadiusGlob.psm1,.claude/lib/blast-radius/BlastRadiusConflict.psm1 -CoverageOutputPath SCRATCH/final-blast-coverage.xml`.
      Acceptance: exit 0, `FailedCount=0`, `TotalCount` equals the P0-T11 TotalCount plus 33, and each `COVERAGE ... LinePercent=` value is at least 85.
- [x] [P2-T4] Convention and name-uniqueness guards: run A2 over `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` and over `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`, and write FEATURE/evidence/qa-gates/convention-and-uniqueness.TS.md.
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`.
      Acceptance: both runs exit 0 with `FailedCount=0`.
- [x] [P2-T5] Post-change timing of HISTORICAL (`tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`) with coverage disabled: run A8 with three runs and write FEATURE/evidence/qa-gates/historical-runs-timing.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/timing.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -Runs 3`.
      Acceptance: exit 0; `CODE-COVERAGE-ENABLED=False`; the `PESTER-VERSION=` value equals the P0-T10 value; three `RUN` lines each with `Total=9 Passed=9 Failed=0`; one `MEDIAN-SECONDS=` line recorded.
- [ ] [P2-T6] Timing comparison for AC-2: compute the ratio of the P0-T10 median to the P2-T5 median and write FEATURE/evidence/qa-gates/timing-comparison.TS.md (`tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`).
      Command: `awk 'BEGIN { printf "RATIO=%.2f\n", BASELINE_MEDIAN / POST_MEDIAN }'`, with the two recorded medians substituted as literal numbers.
      Acceptance: exit 0 and the printed RATIO is at least 4.00 (D2). The artifact states both medians, the ratio, the threshold, and PASS or FAIL. FAIL stops the plan as remediation-required; the remediation is not improvised here.
- [ ] [P2-T7] Full Pester suite through MCP-TEST, with JUnit and coverage parsing, and write FEATURE/evidence/qa-gates/full-suite-pester.TS.md (`artifacts/pester/pester-junit.xml` read as tool output).
      Commands: `date -u +%Y-%m-%dT%H:%M:%SZ` (record as START); MCP-TEST; `sh SCRATCH/run-ps.sh SCRATCH/junit-summary.ps1 -Path artifacts/pester/pester-junit.xml`; `sh SCRATCH/run-ps.sh SCRATCH/coverage-xml.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -BaseRef BASE_SHA .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1` (substitute the recorded SHA for BASE_SHA).
      Acceptance: both scripts exit 0; both last-write values are later than START. `JUNIT-TESTCASES` equals the P0-T12 value plus 33. Every `JUNIT-FAILED-CASE` line also appears in the P0-T12 baseline failure set, except a line whose `file=` is `enforce-pr-author-skill.Tests.ps1` or `codex-pretooluse-integration.Tests.ps1`. Those two suites read the gitignored `artifacts/orchestration/orchestrator-state.json`, which changes during the run. Each excepted line is quoted in the artifact under `PRE-EXISTING-STATE-DEPENDENT:`. Any other new failing case fails the task. Every `JUNIT-BLAST-SUITE` line shows `failures=0 errors=0`, including the lines for BlastRadiusGlob.RegexCache.Tests.ps1 and BlastRadiusConflict.PathOverlap.Tests.ps1. The `COVERAGE` and `CHANGED` lines for both modules are recorded as numbers.
- [ ] [P2-T8] Coverage threshold and delta for AC-5: from the P0-T11, P0-T12, P2-T3, and P2-T7 artifacts, write FEATURE/evidence/qa-gates/coverage-delta.TS.md for GLOB (`.claude/lib/blast-radius/BlastRadiusGlob.psm1`) and CONFLICT (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`).
      For each file, record the baseline LinePercent (P0-T12), the post-change LinePercent (P2-T7), the fast-gate LinePercent (P2-T3), and the changed-line values (P2-T7 `AnalyzedChangedLines`, `CoveredChangedLines`, `ChangedLinePercent`).
      Acceptance: PASS only if, for both files, the P2-T7 LinePercent is at least 85, `AnalyzedChangedLines` is greater than 0, and `ChangedLinePercent` is at least 85. Otherwise the artifact states remediation-required and the task fails.
- [ ] [P2-T9] Line limits for AC-5: run A4 over GLOB, CONFLICT, TEST-CACHE, and TEST-OVERLAP, and write FEATURE/evidence/qa-gates/line-counts.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1`.
      Acceptance: exit 0 and every LineCount is at most 500. The artifact also reports the D6 targets (GLOB at most 480, CONFLICT at most 400) as informational.
- [ ] [P2-T10] Final mirror identity: run A5 over GLOB, GLOB-MIRROR, CONFLICT, and CONFLICT-MIRROR (`extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`), and write FEATURE/evidence/qa-gates/mirror-hashes.TS.md.
      Command: the A5 command of P1-T9.
      Acceptance: exit 0 and each primary hash equals its mirror hash.
- [ ] [P2-T11] Export surface for AC-4: run A9 and write FEATURE/evidence/qa-gates/export-surface.TS.md (modules under `.claude/lib/blast-radius`).
      Command: `sh SCRATCH/run-ps.sh SCRATCH/export-surface.ps1`.
      Acceptance: exit 0, and `SURFACE-COUNT` and `SURFACE-SHA256` equal the P0-T9 values. Any difference is quoted line by line against P0-T9 and fails the task.
- [ ] [P2-T12] Scope and fixture immutability for AC-1: write FEATURE/evidence/qa-gates/scope-and-fixture-immutability.TS.md (`tests/fixtures/blast_radius`, `tests/scripts/claude-lib/blast-radius`).
      Commands: `git diff --name-only BASE_SHA -- .claude/lib extensions/drm-copilot/resources/claude-customizations/.claude/lib scripts tests config` (substitute the recorded SHA); `git status --porcelain -- .claude/lib extensions/drm-copilot/resources/claude-customizations/.claude/lib scripts tests config`. The pathspec leaves out tracked agent-memory files, which other agents may write during the run.
      Acceptance: the union of the paths listed by the two commands is a subset of GLOB, CONFLICT, GLOB-MIRROR, CONFLICT-MIRROR, TEST-CACHE, and TEST-OVERLAP, and each of those six paths appears in at least one of the two outputs. No existing file under `tests/fixtures/blast_radius` or `tests/scripts/claude-lib/blast-radius` appears, and `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` does not appear.
- [ ] [P2-T13] Bundle byte-identity test: run the pytest node that guards `.claude` bundle parity and write FEATURE/evidence/qa-gates/bundle-parity-pytest.TS.md.
      Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`.
      Acceptance, case (a): the node prints PASSED and the artifact records `KL-510: PASSED`.
      Acceptance, case (b), the known local issue #510: the node fails and its assertion message is the literal "Repo file missing from bundle:" followed by one path. `git check-ignore -q` on that path exits 0, meaning it is gitignored local state. No output line contains the literal "Bundle content differs from repo for:". The artifact records `KL-510: STATE-ONLY`, quotes the message verbatim, and carries `ExpectedExitCode: 1`.
      Any other outcome fails the task. P2-T10 remains the direct identity proof for the two mirrors.
- [ ] [P2-T14] Reduced-audit handoff: write FEATURE/evidence/other/small-audit-handoff.TS.md (under `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/other/`) listing AC-1 through AC-5, each with the artifact paths that evidence it per the traceability table below. AC-3 is listed as orchestrator-verified post-PR. The orchestrator then delegates the minor-audit review with that file as its evidence index.
      Command: `ls docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/baseline docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/qa-gates docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/other`.
      Acceptance: every artifact path named in the handoff file appears in the listing.

## Post-PR verification (orchestrator-owned, not an executor task)

AC-3 is verified by the orchestrator after the pull request exists and CI on the PR head has completed. The executor does not perform or check off this step.

- Command shape: `gh run view RUN_ID --json jobs --jq '.jobs[] | select(.name == "poshqc / PowerShell QC") | [.startedAt, .completedAt] | @tsv'`, where RUN_ID is the CI workflow run on the PR head. The job name comes from `.github/workflows/_poshqc.yml` (job `poshqc`, name "PowerShell QC") called as job `poshqc` in `.github/workflows/ci.yml`.
- Pass condition: completedAt minus startedAt is at most 700 seconds, against the 838 seconds of run 1043. Rationale: HISTORICAL took 369 s of that job; a reduction of at least 4x (D2) removes at least about 277 s, and 700 s leaves about 139 s for runner variance.
- Evidence: FEATURE/evidence/qa-gates/ci-powershell-qc-duration.TS.md with the command, the two timestamps, the computed duration, and PASS or FAIL.

## Acceptance-criteria traceability

| AC | issue.md criterion (abridged) | Implementation | Verification | Evidence |
| --- | --- | --- | --- | --- |
| AC-1 | blast-radius suites pass; no fixture or assertion edits | P1-T2..P1-T6 | P1-T10, P2-T3, P2-T7, P2-T12 | qa-gates/blast-radius-pester-coverage, qa-gates/full-suite-pester, qa-gates/scope-and-fixture-immutability |
| AC-2 | before/after local timing, coverage disabled, material reduction | P1-T2..P1-T6 | P0-T10, P2-T5, P2-T6 | baseline/historical-runs-timing, qa-gates/historical-runs-timing, qa-gates/timing-comparison |
| AC-3 | CI PowerShell QC job lower than 838 s | P1-T2..P1-T6 | Post-PR verification (orchestrator) | qa-gates/ci-powershell-qc-duration |
| AC-4 | exported signatures and return values unchanged | P1-T1 constraints, P1-T2..P1-T6 | P0-T9, P2-T11, P1-T10 | baseline/export-surface, qa-gates/export-surface |
| AC-5 | line coverage >= 85% per touched file; no file over 500 lines | P1-T7, P1-T8 | P2-T3, P2-T7, P2-T8, P2-T9 | qa-gates/coverage-delta, qa-gates/full-suite-pester, qa-gates/line-counts |

## Appendix — scratch scripts (written verbatim by P0-T4)

A1 run-ps.sh:

```sh
#!/bin/sh
set -eu
pwsh -NoProfile -NonInteractive -File "$@"
```

A2 pester-counts.ps1:

```powershell
param(
    [Parameter(Mandatory)][string] $Path
)
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Path
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) { Write-Output "FAILED: $($failedTest.ExpandedPath)" }
if ($result.FailedCount -gt 0) { exit 1 }
```

A3 pester-coverage.ps1:

```powershell
param(
    [Parameter(Mandatory)][string] $TestPath,
    [Parameter(Mandatory)][string[]] $CoveragePath,
    [Parameter(Mandatory)][string] $CoverageOutputPath
)
$CoveragePath = @($CoveragePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = $CoveragePath
$configuration.CodeCoverage.OutputPath = $CoverageOutputPath
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) { Write-Output "FAILED: $($failedTest.ExpandedPath)" }
$executed = @($result.CodeCoverage.CommandsExecuted)
$missed = @($result.CodeCoverage.CommandsMissed)
foreach ($file in $CoveragePath) {
    $fullPath = (Resolve-Path -LiteralPath $file).Path
    $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
    $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
    Write-Output "COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent"
}
if ($result.FailedCount -gt 0) { exit 1 }
```

A4 line-counts.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file LineCount=$((Get-Content -LiteralPath $file).Count)" }
```

A5 file-hashes.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file Hash=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)" }
```

A6 format-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$changedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    $changed = $formatted -cne $original
    if ($changed) { $changedCount++ }
    Write-Output "FORMAT file=$file Changed=$changed"
}
Write-Output "FORMAT-SUMMARY ChangedCount=$changedCount"
```

A7 pssa.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$ErrorActionPreference = 'Stop'
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$total = 0
foreach ($file in $Path) {
    $finding = @(Invoke-ScriptAnalyzer -Path $file -Settings $settings)
    $total += $finding.Count
    Write-Output "PSSA file=$file Findings=$($finding.Count)"
    foreach ($item in $finding) { Write-Output "PSSA-FINDING file=$file line=$($item.Line) rule=$($item.RuleName) severity=$($item.Severity)" }
}
Write-Output "PSSA-TOTAL=$total"
```

A8 timing.ps1 (coverage and result files disabled; one process, sequential runs):

```powershell
param(
    [Parameter(Mandatory)][string] $Path,
    [int] $Runs = 3
)
$ErrorActionPreference = 'Stop'
$pester = Import-Module Pester -MinimumVersion 5.0.0 -PassThru
Write-Output "PESTER-VERSION=$($pester.Version)"
$elapsed = [System.Collections.Generic.List[double]]::new()
$badRun = 0
for ($run = 1; $run -le $Runs; $run++) {
    $configuration = New-PesterConfiguration
    $configuration.Run.Path = $Path
    $configuration.Run.PassThru = $true
    $configuration.CodeCoverage.Enabled = $false
    $configuration.TestResult.Enabled = $false
    $configuration.Output.Verbosity = 'None'
    if ($run -eq 1) { Write-Output "CODE-COVERAGE-ENABLED=$($configuration.CodeCoverage.Enabled.Value)" }
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $result = Invoke-Pester -Configuration $configuration
    $stopwatch.Stop()
    $seconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)
    $elapsed.Add($seconds)
    if ($result.FailedCount -gt 0 -or $result.PassedCount -ne $result.TotalCount) { $badRun++ }
    Write-Output "RUN index=$run ElapsedSeconds=$seconds Total=$($result.TotalCount) Passed=$($result.PassedCount) Failed=$($result.FailedCount)"
}
$sorted = @($elapsed | Sort-Object)
Write-Output "MEDIAN-SECONDS=$($sorted[[int][math]::Floor(($sorted.Count - 1) / 2)])"
if ($badRun -gt 0) { exit 1 }
```

A9 export-surface.ps1 (run from the repository root):

```powershell
$ErrorActionPreference = 'Stop'
$commonName = @('Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ProgressAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'WhatIf', 'Confirm')
$common = [System.Collections.Generic.HashSet[string]]::new([string[]]$commonName)
$line = [System.Collections.Generic.List[string]]::new()
foreach ($file in @(Get-ChildItem -LiteralPath '.claude/lib/blast-radius' -Filter '*.psm1' -File | Sort-Object -Property Name)) {
    $module = Import-Module -Name $file.FullName -Force -PassThru
    foreach ($name in @($module.ExportedFunctions.Keys | Sort-Object)) {
        $command = $module.ExportedFunctions[$name]
        $parameter = @($command.Parameters.Values | Where-Object { -not $common.Contains($_.Name) } | Sort-Object -Property Name | ForEach-Object {
                $mandatory = @($_.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }).Count -gt 0
                '{0}:{1}:{2}' -f $_.Name, $_.ParameterType.FullName, $mandatory
            })
        $output = @($command.OutputType | ForEach-Object { $_.Name }) -join ','
        $line.Add(('SURFACE module={0} function={1} cmdletbinding={2} output={3} params={4}' -f $file.Name, $name, $command.CmdletBinding, $output, ($parameter -join ';')))
    }
}
foreach ($entry in $line) { Write-Output $entry }
Write-Output "SURFACE-COUNT=$($line.Count)"
$bytes = [System.Text.Encoding]::UTF8.GetBytes(($line -join "`n"))
Write-Output "SURFACE-SHA256=$([System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes)))"
```

A10 copy-file.ps1 (mirror production):

```powershell
param(
    [Parameter(Mandatory)][string] $Source,
    [Parameter(Mandatory)][string] $Destination
)
Copy-Item -LiteralPath $Source -Destination $Destination -Force
Write-Output "COPIED $Source"
```

A11 junit-summary.ps1 (prints file leaf names only, never host paths):

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
$item = Get-Item -LiteralPath $Path
$doc = [System.Xml.XmlDocument]::new()
$doc.Load($item.FullName)
$suite = @($doc.SelectNodes('//testsuite'))
$case = @($doc.SelectNodes('//testcase'))
$failed = @($case | Where-Object { $null -ne $_.SelectSingleNode('failure') -or $null -ne $_.SelectSingleNode('error') })
$skipped = @($case | Where-Object { $null -ne $_.SelectSingleNode('skipped') })
Write-Output "JUNIT-LAST-WRITE-UTC=$($item.LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
Write-Output "JUNIT-TESTCASES=$($case.Count)"
Write-Output "JUNIT-FAILED=$($failed.Count)"
Write-Output "JUNIT-SKIPPED=$($skipped.Count)"
foreach ($entry in $failed) { Write-Output ('JUNIT-FAILED-CASE file={0} name={1}' -f (Split-Path -Leaf $entry.GetAttribute('classname')), $entry.GetAttribute('name')) }
foreach ($entry in @($suite | Where-Object { $_.GetAttribute('name') -match 'blast-radius' })) {
    Write-Output ('JUNIT-BLAST-SUITE file={0} tests={1} failures={2} errors={3} time={4}' -f (Split-Path -Leaf $entry.GetAttribute('name')), $entry.GetAttribute('tests'), $entry.GetAttribute('failures'), $entry.GetAttribute('errors'), $entry.GetAttribute('time'))
}
```

A12 coverage-xml.ps1 (reads the CoverageGutters/JaCoCo file; changed lines come from an anchored diff):

```powershell
param(
    [Parameter(Mandatory)][string] $CoverageXml,
    [Parameter(Mandatory)][string] $BaseRef,
    [Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path
)
$ErrorActionPreference = 'Stop'
$item = Get-Item -LiteralPath $CoverageXml
Write-Output "COVERAGE-LAST-WRITE-UTC=$($item.LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
$settings = [System.Xml.XmlReaderSettings]::new()
$settings.DtdProcessing = [System.Xml.DtdProcessing]::Ignore
$reader = [System.Xml.XmlReader]::Create($item.FullName, $settings)
$doc = [System.Xml.XmlDocument]::new()
try { $doc.Load($reader) } finally { $reader.Dispose() }
$missing = 0
foreach ($file in $Path) {
    $directory = ((Split-Path -Parent $file) -replace '\\', '/').TrimEnd('/')
    $leaf = Split-Path -Leaf $file
    $source = @($doc.SelectNodes('/report/package') |
            Where-Object { ($_.GetAttribute('name') -replace '\\', '/').EndsWith('/' + $directory) } |
            ForEach-Object { $_.SelectNodes('sourcefile') } |
            Where-Object { $_.GetAttribute('name') -eq $leaf })
    if ($source.Count -ne 1) { Write-Output "COVERAGE file=$file MISSING matches=$($source.Count)"; $missing++; continue }
    $line = @($source[0].SelectNodes('line'))
    $covered = @($line | Where-Object { [int]$_.GetAttribute('ci') -gt 0 })
    $percent = if ($line.Count -eq 0) { 'NA' } else { [math]::Round(100 * $covered.Count / $line.Count, 2) }
    Write-Output "COVERAGE file=$file AnalyzedLines=$($line.Count) CoveredLines=$($covered.Count) LinePercent=$percent"
    $changed = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($row in @(git diff --unified=0 $BaseRef -- $file)) {
        if ($row -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@') {
            $start = [int]$Matches[1]
            $count = if ($Matches[2]) { [int]$Matches[2] } else { 1 }
            for ($number = $start; $number -lt $start + $count; $number++) { [void]$changed.Add($number) }
        }
    }
    $changedLine = @($line | Where-Object { $changed.Contains([int]$_.GetAttribute('nr')) })
    $changedCovered = @($changedLine | Where-Object { [int]$_.GetAttribute('ci') -gt 0 })
    $changedPercent = if ($changedLine.Count -eq 0) { 'NA' } else { [math]::Round(100 * $changedCovered.Count / $changedLine.Count, 2) }
    Write-Output "CHANGED file=$file ChangedLines=$($changed.Count) AnalyzedChangedLines=$($changedLine.Count) CoveredChangedLines=$($changedCovered.Count) ChangedLinePercent=$changedPercent"
}
if ($missing -gt 0) { exit 1 }
```
