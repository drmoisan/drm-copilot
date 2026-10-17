# 2026-09-29-blast-radius-overlap-perf (Remediation Plan, cycle 1)

- **Issue:** #776
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T20-15
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** minor-audit
- **Language in scope:** PowerShell only
- **Requirements source (sole AC source):** `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md`, section `## Acceptance Criteria` (AC-1 through AC-5 in document order)
- **Remediation input:** `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/remediation-inputs.2026-09-29T20-15.md` (finding F-1: P2-T6 recorded RATIO=2.60 against the 4.00 threshold)
- **Plan of record being remediated:** `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/plan.2026-09-29T18-10.md` (Phases 0 and 1 complete and uncommitted; Phase 2 stopped at P2-T6)

**Mode note (minor-audit):** `spec.md`, `user-story.md`, and `research.md` are not required. Execution fails closed if `spec.md` or `user-story.md` appears in the feature folder, if `## Acceptance Criteria` is missing from `issue.md`, if a required Phase 0 artifact is missing or incomplete, or if checklist state contradicts evidence on disk.

**Fail-closed evidence rule:** PowerShell policy requires line coverage >= 85%. If any required baseline artifact, final-QC artifact, or coverage value is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; an artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`.

## Terms used in every task

The terms of the original plan (`plan.2026-09-29T18-10.md`, section "Terms used in every task") apply unchanged: FEATURE, TS, SCRATCH, REPO, GLOB, CONFLICT, GLOB-MIRROR, CONFLICT-MIRROR, TEST-CACHE, TEST-OVERLAP, HISTORICAL, and MCP-TEST. The following are added or restated:

- BASE_SHA is the commit recorded by the original P0-T3, whose abbreviated form is `43c9e95e`. Every scope diff and every changed-line computation in this plan is anchored to it.
- ORIGINAL-BASELINE means the Phase 0 artifacts of the original plan under FEATURE/evidence/baseline/. Four values from it are reused as the comparison reference: the 64-line export surface (hash prefix `B7EB8334`), the full suite of 5676 test cases with 0 failures, the HISTORICAL median of 213.12 s, and the P0-T11 blast-radius TotalCount.
- SCHEDULING means `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`; SCHEDULING-MIRROR means `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1`.
- TEST-PAIRS means `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1` (new, 10 tests). TEST-COST means `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1` (new, 7 tests).
- NEW-EXPORT means the one function this plan adds to the export list of CONFLICT: `Get-OverlappingPathPair`.
- Scripts A1 through A12 are the scratch scripts in the Appendix of the original plan, rewritten verbatim into this session's SCRATCH. Scripts A13 and A14 are in this plan's Appendix. The invocation form is unchanged: `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <arguments>` from the repository root, or the equivalent `pwsh -NoProfile -NonInteractive -File` call through a PowerShell tool. The `Command:` field records the form actually used.
- Remediation evidence goes to FEATURE/evidence/remediation-baseline/ (Phase 0), FEATURE/evidence/other/ (Phase 1, file prefix `r1-`), and FEATURE/evidence/qa-gates/ (Phase 2, file prefix `r1-`). No other evidence location is used.

## Scope and recorded design decisions

Production files edited in this cycle: CONFLICT and SCHEDULING. GLOB is not edited. Mirrors are produced by A10 (`Copy-Item` through pwsh), never by Write or Edit. New test files: TEST-PAIRS and TEST-COST. No existing test file, test assertion, or fixture is edited; TEST-CACHE and TEST-OVERLAP from the original Phase 1 stay unchanged. `.claude/lib/blast-radius/BlastRadius.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and the Python port (`scripts/dev_tools/_blast_radius_glob.py`, `scripts/dev_tools/compute_blast_radius.py`) are not edited.

- R1 — The overlap enumeration must be indexed, not a nested loop. The remediation input's own profile rules out reusing the Phase 1 inline nested loop for the cost path. Detection alone takes 8.1 s for 55 radius pairs of the largest fixture, which is about 0.15 s per pair; almost all of that is the roughly 25,000 interpreted loop iterations per pair. Reusing that loop for `Get-BlastRadiusPairCost` would bring a scheduling pass to about 8.1 + 46 x 0.15 = 15 s, down from 19.5 s. HISTORICAL would then land near 65 s against the 53.28 s ceiling, a ratio of about 3.3.
  `Get-OverlappingPathPair` therefore finds concrete-versus-concrete overlaps through dictionary lookups, since those pairs are almost all of the pairs. Glob-involving pairs are evaluated by iteration. Details:
  - Equality: a dictionary maps each concrete entry of the other collection to the list of indexes of every occurrence of that entry, so a repeated entry yields one pair per occurrence.
  - Anchored-directory containment: `X.StartsWith(Y.TrimEnd('/') + '/')` holds exactly when `X[k]` is `/` and `X.Substring(0, k)` equals `Y.TrimEnd('/')` for some k, where k runs over the positions of `/` in X. So a dictionary keyed by the trimmed form of each concrete entry, mapping each key to the list of indexes of every concrete entry with that trimmed form, answers containment in both directions with one probe per `/` position in X. Position k = 0 is probed only when `X[0]` is `/`.
  - Glob pairs: every pair with a glob on either side is decided by iterating that glob against the whole other collection, using the four-case decision.
  - Ordering: each overlapping pair is recorded once, as the key `i * |B| + j`, in a hash set. The sorted keys give exactly the nested-loop order: outer over PathA in input order, inner over PathB in input order.
  Estimated cost per radius pair is about 20 ms, against 150 ms.
- R2 — One overlap decision. The four-case glob-involving decision moves out of `Get-SmallestPathOverlap` into one non-exported simple function in CONFLICT, `Test-PathOverlapRecordPair` (parameters `$Left` and `$Right`, each a record from `ConvertTo-PathOverlapRecord`). It keeps the D3 order of the original plan: both literal nest tests first, then `Test-GlobMatch`. Both `Get-OverlappingPathPair` and, through it, `Get-SmallestPathOverlap` use it. `Get-SmallestPathOverlap` keeps its signature and output: it takes the ordinal minimum of the ordered joined details over `Get-OverlappingPathPair`'s pairs. That minimum does not depend on enumeration order.
- R3 — One new export. `Get-OverlappingPathPair` is exported from CONFLICT and from no other module; the facade's 14-name surface is unchanged. SCHEDULING already imports CONFLICT (line 39), so this export is what lets the cost loop share the fast enumeration. The original plan's decision D1 avoided a new export, and F-1 shows that decision cost the threshold. The AC-4 assertion becomes a subset check (A13): all 64 baseline signature lines are present verbatim, and the only added line is NEW-EXPORT's.
- R4 — Output contract of NEW-EXPORT. Parameters: `PathA` and `PathB`, both `[string[]]`, mandatory, with `[AllowEmptyCollection()]` and `[AllowEmptyString()]`; `[CmdletBinding()]`; `[OutputType([System.Object[]])]`. It returns one hashtable per overlapping pair, with keys `EntryA` (from PathA) and `EntryB` (from PathB), in nested-loop order, with no reordering by value. When nothing overlaps it returns an empty array.
- R5 — Cost path. In `Get-BlastRadiusPairCost` (SCHEDULING, lines 264-273), the nested loop is replaced by one loop over `@(Get-OverlappingPathPair -PathA $pathsA -PathB $pathsB)`. That loop adds `Get-PathPairWeight -EntryA $pair['EntryA'] -EntryB $pair['EntryB'] -Tolerance $Tolerance` for each pair. `Get-PathPairWeight`, the mergeable exclusion, the module term, and the signature are unchanged. SCHEDULING must not grow: at most 486 lines, and a net reduction is expected.
- R6 — Timing threshold unchanged: the P0-T10 median of the original plan (213.12 s) divided by the new post-change median must be at least 4.00, which means a median of at most 53.28 s.
- R7 — Line budget. CONFLICT is 365 lines and gains NEW-EXPORT (about 90 lines including help) plus `Test-PathOverlapRecordPair` (about 30 lines). It loses about 35 lines from `Get-SmallestPathOverlap`. Target: at most 470; hard limit 500. If the executor measures CONFLICT above 500 after P1-T3, it stops and reports rather than splitting the module.

## Execution constraints

- Batch budget. This is a new atomic-executor session, so its budget counts from zero. Write or Edit touches two production PowerShell files (CONFLICT and SCHEDULING); GLOB is not edited. Test files are never counted by `.claude/hooks/enforce-powershell-batch-budget.ps1`, and the three mirrors are produced by A10, which does not pass through the hook. The count cannot exceed 2 of the cap of 3, so no reset is scheduled. If the hook still denies a CONFLICT or SCHEDULING write with `POWERSHELL_LARGE_PATH_REQUIRED`:
  - List `.claude/state/powershell-batch-budget.*.json`.
  - Delete the one file whose `prodFiles` equals the denial's "already counted" list.
  - Write FEATURE/evidence/other/r1-batch-budget-reset.TS.md with the file name, its prior `prodFiles`, and the denial text.
  - Retry once. A second denial stops the plan.
- Shell route. Every git command is one plain command with literal arguments. Scratch scripts are written with the Write tool into SCRATCH. Grep patterns beginning with `-` are passed with `-e`. No `git grep` runs against an untracked file; the four new test files are untracked, so they are searched with plain `grep`.
- Long-running commands. P0-T8, P0-T10, P2-T3, P2-T5, P2-T6, and any run of the full suite outside MCP run in the background. The executor waits for the completion notification before reading output. While an A8 timing run (P2-T6) is in progress, the executor starts no other test, analyzer, formatter, or benchmark command, and the next task begins only after that run's completion notification. A timed-out foreground run is not a result.
- Hooks. If a hook denies a command, stop and report the denial text. Do not bypass it.
- Stop conditions. When a stop condition is reached, write the task's artifact with the stop reason and report to the caller. Do not improvise a substitute design.

### Phase 0 — Remediation Baseline and Context

- [x] [P0-T1] Verify the minor-audit preconditions and the remediation input for FEATURE (`docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md`), and write FEATURE/evidence/remediation-baseline/r1-mode-check.TS.md.
      Commands: `ls docs/features/active/2026-09-29-blast-radius-overlap-perf-776`; `grep -c -x -F "## Acceptance Criteria" docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md`; `grep -c -x -F -e "- Work Mode: minor-audit" docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md`; `grep -c -F "RATIO=2.60" docs/features/active/2026-09-29-blast-radius-overlap-perf-776/remediation-inputs.2026-09-29T20-15.md`.
      Acceptance: the listing contains neither spec.md nor user-story.md; each of the three greps prints 1.
- [x] [P0-T2] Read the policy files in the required order, plus the remediation input and the original plan, and write FEATURE/evidence/remediation-baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the files read, in this order:
      (1) `.github/copilot-instructions.md`, `CLAUDE.md`, `.claude/rules/tonality.md`;
      (2) `.github/instructions/general-code-change.instructions.md`, `.claude/rules/general-code-change.md`;
      (3) `.github/instructions/general-unit-test.instructions.md`, `.claude/rules/general-unit-test.md`;
      (4) `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`;
      (5) `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`;
      (6) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`;
      (7) `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/remediation-inputs.2026-09-29T20-15.md`, `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/plan.2026-09-29T18-10.md`.
      Acceptance: the artifact has the three required headers and lists all 15 files in that order.
- [x] [P0-T3] Record the pre-remediation tree state for `.claude/lib/blast-radius` and write FEATURE/evidence/remediation-baseline/r1-tree-state.TS.md.
      Commands: `git rev-parse HEAD`; `git status --porcelain -- .claude/lib extensions/drm-copilot/resources/claude-customizations/.claude/lib tests/scripts/claude-lib/blast-radius tests/fixtures/blast_radius`.
      Acceptance: rev-parse prints a SHA beginning `43c9e95e` (equal to BASE_SHA). The status output lists exactly GLOB, CONFLICT, GLOB-MIRROR, and CONFLICT-MIRROR as modified and TEST-CACHE and TEST-OVERLAP as untracked, and no other path. Any other state stops the plan.
- [x] [P0-T4] Write scratch scripts A1 through A12 (verbatim from the Appendix of `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/plan.2026-09-29T18-10.md`) and A13 and A14 (from this plan's Appendix) into SCRATCH. Hash them and write FEATURE/evidence/remediation-baseline/r1-scratch-scripts.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 SCRATCH/pester-coverage.ps1 SCRATCH/line-counts.ps1 SCRATCH/file-hashes.ps1 SCRATCH/format-check.ps1 SCRATCH/pssa.ps1 SCRATCH/timing.ps1 SCRATCH/export-surface.ps1 SCRATCH/copy-file.ps1 SCRATCH/junit-summary.ps1 SCRATCH/coverage-xml.ps1 SCRATCH/export-subset.ps1 SCRATCH/pin-cost-and-pairs.ps1`.
      Acceptance: exit 0 and 14 hash lines printed, recorded with the SCRATCH token.
- [x] [P0-T5] Pre-remediation line counts: run A4 over GLOB, CONFLICT, SCHEDULING, and `.claude/lib/blast-radius/BlastRadius.psm1`, and write FEATURE/evidence/remediation-baseline/r1-line-counts.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1 .claude/lib/blast-radius/BlastRadius.psm1`.
      Acceptance: exit 0 and LineCount values 454, 365, 486, 475 in that order. Any difference stops the plan, because R5 and R7 were derived from those counts.
- [x] [P0-T6] Pre-remediation mirror identity: run A5 over the three primary-and-mirror pairs (GLOB, CONFLICT, SCHEDULING under `.claude/lib/blast-radius/` and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`), and write FEATURE/evidence/remediation-baseline/r1-mirror-hashes.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1`.
      Acceptance: exit 0 and each primary hash equals its mirror hash. An unequal pair stops the plan.
- [x] [P0-T7] Pre-remediation export surface against ORIGINAL-BASELINE: locate the single original export-surface artifact under `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/baseline/`, run A13 against it with no expected addition, and write FEATURE/evidence/remediation-baseline/r1-export-subset.TS.md.
      Commands: `ls docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/baseline`; `sh SCRATCH/run-ps.sh SCRATCH/export-subset.ps1 -BaselineArtifact BASELINE_EXPORT_ARTIFACT -ExpectedAddition NONE`, substituting the one listed file whose name starts `export-surface.` for BASELINE_EXPORT_ARTIFACT.
      Acceptance: the listing holds exactly one such file; A13 exits 0 and prints `BASELINE-COUNT=64`, `MISSING-COUNT=0`, `ADDED-COUNT=0`, and `SUBSET-RESULT=PASS`. Anything else stops the plan, because the subset baseline would then be wrong.
- [x] [P0-T8] Pin cost values and overlapping-pair lists on the pre-remediation tree, before any edit: run A14 over `tests/fixtures/blast_radius/historical-runs` (background) and write FEATURE/evidence/remediation-baseline/r1-cost-and-pairs-pin.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pin-cost-and-pairs.ps1 -FixtureDirectory tests/fixtures/blast_radius/historical-runs`.
      Acceptance: exit 0; `PAIRS-CANDIDATE=ABSENT` (NEW-EXPORT does not exist yet); every `COST` and `PAIRS` line recorded verbatim; `COST-LINES=`, `COST-SHA256=`, `PAIRS-LINES=`, and `PAIRS-REFERENCE-SHA256=` recorded. `COST-LINES` equals `PAIRS-LINES` and is greater than 0. These two hashes are the expected values for P2-T5.
- [x] [P0-T9] Pre-remediation analyzer findings: run A7 over CONFLICT and SCHEDULING (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`, `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`), and write FEATURE/evidence/remediation-baseline/r1-pssa.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pssa.ps1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1`.
      Acceptance: exit 0 and the numeric `PSSA-TOTAL=` value and every `PSSA-FINDING` line recorded.
- [x] [P0-T10] Pre-remediation blast-radius Pester run with coverage on GLOB, CONFLICT, and SCHEDULING (`tests/scripts/claude-lib/blast-radius`, background), and write FEATURE/evidence/remediation-baseline/r1-blast-radius-pester-coverage.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius -CoveragePath .claude/lib/blast-radius/BlastRadiusGlob.psm1,.claude/lib/blast-radius/BlastRadiusConflict.psm1,.claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath SCRATCH/r1-baseline-blast-coverage.xml`.
      Acceptance: exit 0; `FailedCount=0`; `TotalCount` equals the ORIGINAL-BASELINE P0-T11 TotalCount plus 33 (the two Phase 1 test files); one numeric `COVERAGE ... LinePercent=` per module recorded. The TotalCount is recorded as R1-BLAST-TOTAL.

### Phase 1 — Constrained Small-Path Implementation

This phase is one delegated handoff. The small-path implementation engineer performs P1-T2 through P1-T9 in order. Each task writes FEATURE/evidence/other/r1-p1-tN.TS.md (N is the task number) recording its commands, exit codes, and output summary. Each r1-p1-tN artifact for P1-T2 through P1-T9 carries exactly one top-level `EXIT_CODE:`, equal to the exit code of the task's last non-grep command (A2, A5, A10, or A14), and no `ExpectedExitCode:`. Each grep's printed count and exit code are recorded inside `Output Summary:` as `GREP count=<n> exit=<n>`, one line per grep, in command order. The P1-T1 artifact records the engineer's completion report and carries no `EXIT_CODE:` line, because P1-T1 runs no command.

- [x] [P1-T1] Delegated implementation handoff: apply P1-T2 through P1-T9 to CONFLICT (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`), SCHEDULING (`.claude/lib/blast-radius/BlastRadiusScheduling.psm1`), TEST-PAIRS, TEST-COST, and the three mirrors only.
      Constraints:
      - no edit to GLOB, the facade, or any existing test file or fixture;
      - no change to any existing exported function's name, parameters, parameter attributes, `[OutputType()]`, or return values;
      - the only export-list change is appending `Get-OverlappingPathPair` to the `Export-ModuleMember` block of CONFLICT;
      - no `Mock` in the new test files.
      Acceptance: every acceptance condition of P1-T2 through P1-T9 holds, and FEATURE/evidence/other/r1-p1-t1.TS.md records the completion report.
- [x] [P1-T2] Create TEST-COST (`tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`) as a characterization test and run it against the unchanged SCHEDULING.
      Imports and helpers: the file imports SCHEDULING with `Import-Module (Resolve-Path ...) -Force`. Each case builds two radius records (keys `paths`, `modules`, `shared_surfaces` = empty, `contracts` = empty, `source` = `declared`, `computed_at` = `2026-09-29T20-15`). Every case uses one config: `version` 1, `over_breadth_fraction` 0.25, `mergeable_paths` `**/*.csproj`, and a `conflict_tolerance` member with `tolerance_percent` 0, weights same_file 8, possible_overlap 2, append_only 1, module 2, band durations C1 1, C2 2, C3 4, C4 8, `default_band` C1, and `append_only_paths` `**/CHANGELOG.md`.
      It passes `Get-ConfigConflictTolerance -Config` of that config as `-Tolerance` to `Get-BlastRadiusPairCost`. It holds one Describe 'Get-BlastRadiusPairCost equivalence (issue #776)' with one It 'returns <Expected> for <Name>' and these seven -ForEach rows (Name; PathsA; PathsB; ModulesA; ModulesB; Expected):
      - 'one shared concrete file'; `src/a.py`, `src/b.py`; `src/a.py`; none; none; 8
      - 'a glob over a concrete file'; `src/**`; `docs/x.md`, `src/a.py`; none; none; 2
      - 'a root append-only file named by both'; `CHANGELOG.md`; `CHANGELOG.md`; none; none; 1
      - 'shared modules only'; `a/x.py`; `b/y.py`; `m1`, `m2`; `m2`; 2
      - 'a mergeable project file named by both'; `p/x.csproj`; `p/x.csproj`; none; none; 0
      - 'a listed directory over a file beneath it'; `scripts/dev_tools`; `scripts/dev_tools/a.py`; none; none; 2
      - 'mixed pairs summed'; `a/1.py`, `a/**`; `a/1.py`, `a/2.py`; none; none; 12
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`; `grep -c -w -F Mock tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`.
      Acceptance: the grep prints 0 (exit 1 is the pass condition). A2 exits 0 with `TotalCount=7` and `FailedCount=0` against the unchanged SCHEDULING, so the pinned values match the pre-remediation code. A failing row stops the plan and is reported with its observed value; the expected value is not edited to match.
- [x] [P1-T3] In CONFLICT (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`), add the non-exported simple function `Test-PathOverlapRecordPair` (R2) and the exported advanced function `Get-OverlappingPathPair` (R1, R4), and append `Get-OverlappingPathPair` to the `Export-ModuleMember` block.
      `Test-PathOverlapRecordPair` holds the four-case decision now inline in `Get-SmallestPathOverlap` (lines 279-297), with its comments. `Get-OverlappingPathPair` builds both record lists once with `ConvertTo-PathOverlapRecord`, finds concrete-versus-concrete overlaps through the equality and trimmed-form dictionaries of R1, evaluates every glob-involving pair with `Test-PathOverlapRecordPair`, and emits pairs sorted by the key `i * |B| + j`. Its help block states the R1 equivalence argument and the ordering contract.
      The task creates the literals "function Get-OverlappingPathPair" and "function Test-PathOverlapRecordPair".
      Commands: `grep -c -F "function Get-OverlappingPathPair" .claude/lib/blast-radius/BlastRadiusConflict.psm1`; `grep -c -F "function Test-PathOverlapRecordPair" .claude/lib/blast-radius/BlastRadiusConflict.psm1`; `grep -c -F "Get-OverlappingPathPair" .claude/lib/blast-radius/BlastRadiusConflict.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/blast-radius/BlastRadiusConflict.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1`.
      Acceptance: the first two greps print 1 each; the third prints 2 or more (definition and export entry); LineCount is at most 500; A2 exits 0 with `FailedCount=0`.
- [x] [P1-T4] In CONFLICT (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`), rewrite the body of `Get-SmallestPathOverlap` (R2) to take the ordinal minimum of the ordered joined details over `@(Get-OverlappingPathPair -PathA $PathA -PathB $PathB)`. Its signature, help, and return contract are unchanged. The four-case decision then exists only in `Test-PathOverlapRecordPair`.
      The task creates the literal "Get-OverlappingPathPair -PathA $PathA -PathB $PathB".
      Commands: `grep -c -F 'Get-OverlappingPathPair -PathA $PathA -PathB $PathB' .claude/lib/blast-radius/BlastRadiusConflict.psm1`; `grep -c -F "Test-GlobMatch -Pattern" .claude/lib/blast-radius/BlastRadiusConflict.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`.
      Acceptance: the first grep prints 1 (it prints 0 before this task); the second prints 3 (the existing call in `Test-MergeablePath` at line 137 and the two mixed cases in `Test-PathOverlapRecordPair`); a value of 5 would mean a duplicate decision was left behind; the TEST-OVERLAP run exits 0 with `TotalCount=21` and `FailedCount=0`; the other A2 run exits 0 with `FailedCount=0`.
- [x] [P1-T5] Create TEST-PAIRS (`tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1`). It imports the facade `.claude/lib/blast-radius/BlastRadius.psm1` first, CONFLICT second, and GLOB third, each with `-Force` (GLOB last so `Test-EntryOverlap` resolves). It formats each returned pair as `EntryA|EntryB` and uses no Mock.
      It holds exactly these 10 tests in one Describe 'Get-OverlappingPathPair (issue #776)':
      - (1) 'returns no pair when the first collection is empty';
      - (2) 'returns no pair when the second collection is empty';
      - (3) 'emits pairs outer over PathA and inner over PathB in input order': PathA `z/1.py`, `a/1.py`; PathB `z/1.py`, `a/**`, `a/1.py`; expected exactly `z/1.py|z/1.py`, `a/1.py|a/**`, `a/1.py|a/1.py` in that order;
      - (4) 'keeps the PathA entry first in each pair': `src/**` against `src/a.py` gives `src/**|src/a.py`, and the swapped call gives `src/a.py|src/**`;
      - (5)-(8) 'returns exactly one pair for the <Case> case', -ForEach rows: concrete-concrete `a/1.py` against `a/1.py`; glob-concrete `scripts/**` against `scripts/a.py`; concrete-glob `scripts/a.py` against `scripts/**`; glob-glob `scripts/*/a.py` against `scripts/dev_tools/*.py`;
      - (9)-(10) 'matches a nested Test-EntryOverlap loop exactly with <Orientation> input'. The -ForEach rows are `forward` (PathA = MATRIX, PathB = MATRIX reversed) and `reversed` (PathA = MATRIX reversed, PathB = MATRIX). The expected list is built in the It by a nested loop over PathA then PathB calling `Test-EntryOverlap`. MATRIX is, in this order: empty string, `/`, `a`, `a/`, `a/1.py`, `a/1.py/`, `a//`, `a//*`, `x/y`, `x/y/z.md`, `x/**`, `x/*/z.md`, `scripts/dev_tools`, `scripts/dev_toolsX/a.py`, `docs/features/active/alpha`, `docs/features/active/beta/**`, `a/1.py`. The final `a/1.py` repeats an earlier entry, so each orientation contains a duplicate and the expected list contains one pair per occurrence. MATRIX therefore has 17 entries. Each test also asserts that the pair `a/1.py|a/1.py` appears exactly 4 times in the returned list (2 occurrences in PathA x 2 in PathB).
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1`; `grep -c -w -F Mock tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1`.
      Acceptance: A2 exits 0 with `TotalCount=10` and `FailedCount=0`; the grep prints 0 (exit 1 is the pass condition).
- [x] [P1-T6] In SCHEDULING (`.claude/lib/blast-radius/BlastRadiusScheduling.psm1`), apply R5 to `Get-BlastRadiusPairCost`: replace the nested loop at lines 264-273 with one loop over `@(Get-OverlappingPathPair -PathA $pathsA -PathB $pathsB)`, updating the loop's intent comment.
      The task creates the literal "Get-OverlappingPathPair -PathA $pathsA -PathB $pathsB" and removes the literal "Test-EntryOverlap -EntryA $entryA".
      Commands: `grep -c -F 'Get-OverlappingPathPair -PathA $pathsA -PathB $pathsB' .claude/lib/blast-radius/BlastRadiusScheduling.psm1`; `grep -c -F 'Test-EntryOverlap -EntryA $entryA' .claude/lib/blast-radius/BlastRadiusScheduling.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1`.
      Acceptance: the first grep prints 1; the second prints 0 (it prints 1 before this task; exit 1 is the pass condition); LineCount is at most 486; TEST-COST exits 0 with `TotalCount=7` and `FailedCount=0`; the other A2 run exits 0 with `FailedCount=0`.
- [x] [P1-T7] Sync the mirrors by copy: run A10 for CONFLICT to CONFLICT-MIRROR and SCHEDULING to SCHEDULING-MIRROR (under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`), then A5 over all three pairs.
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/copy-file.ps1 -Source .claude/lib/blast-radius/BlastRadiusConflict.psm1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusConflict.psm1`; the same for BlastRadiusScheduling.psm1; the A5 command of P0-T6.
      Acceptance: each A10 run exits 0 with its `COPIED` line; each primary hash equals its mirror hash; the CONFLICT and SCHEDULING hashes differ from their P0-T6 values; the GLOB hash equals its P0-T6 value.
- [x] [P1-T8] Fast gate: run A2 over `tests/scripts/claude-lib/blast-radius`.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius`.
      Acceptance: exit 0, `FailedCount=0`, and `TotalCount` equals R1-BLAST-TOTAL plus 17.
- [x] [P1-T9] Equivalence probe on real data: run A14 over `tests/fixtures/blast_radius/historical-runs` (background).
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pin-cost-and-pairs.ps1 -FixtureDirectory tests/fixtures/blast_radius/historical-runs`.
      Acceptance: exit 0; `COST-SHA256` and `PAIRS-REFERENCE-SHA256` equal the P0-T8 values; `PAIRS-CANDIDATE-MATCHES-REFERENCE=True`. Any mismatch stops the plan before Phase 2.

### Phase 2 — Final QC Loop

Run the PowerShell toolchain in order on the final tree: format (P2-T1), lint (P2-T2), and tests (P2-T3, P2-T4, P2-T8). Type checking does not apply to PowerShell. If any Phase 2 task fails or changes a file, the small-path engineer remediates. After remediation, re-run P1-T7 when CONFLICT or SCHEDULING changed, then restart from P2-T1. Every task is unconditional; none has a SKIPPED outcome.

IN-SCOPE-7 means these seven files, in this order: GLOB, CONFLICT, SCHEDULING, TEST-CACHE, TEST-OVERLAP, TEST-PAIRS, TEST-COST, that is `.claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1 tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`.

- [x] [P2-T1] Format with `mcp__drm-copilot__run_poshqc_format` (`workspace_root` REPO, `scan_folders` [".claude/lib/blast-radius", "tests/scripts/claude-lib/blast-radius"]), observing the tree before and after, and write FEATURE/evidence/qa-gates/r1-format.TS.md.
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1` over IN-SCOPE-7 before the call; the MCP call; the same A5 command after; `git status --porcelain -- .claude/lib/blast-radius tests/scripts/claude-lib/blast-radius`.
      Acceptance: all seven hashes are unchanged across the call, and the status output lists no path outside IN-SCOPE-7. If a hash changed, re-run P1-T7 and restart at P2-T1. If any other path appears, stop and report it.
- [x] [P2-T2] Lint: call `mcp__drm-copilot__run_poshqc_analyze` (`workspace_root` REPO, same `scan_folders`) for toolchain compliance, then run A7 over IN-SCOPE-7 (`.claude/lib/blast-radius/BlastRadiusConflict.psm1` and the other six), and write FEATURE/evidence/qa-gates/r1-lint.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pssa.ps1` followed by the IN-SCOPE-7 paths.
      Acceptance: A7 exits 0 and prints `PSSA-TOTAL=0`. The MCP result text is recorded but not used as a finding count.
- [x] [P2-T3] Blast-radius fast gate with coverage: run A3 over `tests/scripts/claude-lib/blast-radius` with coverage on GLOB, CONFLICT, and SCHEDULING (background), and write FEATURE/evidence/qa-gates/r1-blast-radius-pester-coverage.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius -CoveragePath .claude/lib/blast-radius/BlastRadiusGlob.psm1,.claude/lib/blast-radius/BlastRadiusConflict.psm1,.claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath SCRATCH/r1-final-blast-coverage.xml`.
      Acceptance: exit 0, `FailedCount=0`, `TotalCount` equals R1-BLAST-TOTAL plus 17, and each of the three `COVERAGE ... LinePercent=` values is at least 85.
- [x] [P2-T4] Convention and name-uniqueness guards: run A2 over `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` and `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`, and write FEATURE/evidence/qa-gates/r1-convention-and-uniqueness.TS.md.
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`; `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`.
      Acceptance: both exit 0 with `FailedCount=0`.
- [x] [P2-T5] Cost and pair-list equivalence on the final tree: run A14 over `tests/fixtures/blast_radius/historical-runs` (background) and write FEATURE/evidence/qa-gates/r1-cost-and-pairs-equivalence.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/pin-cost-and-pairs.ps1 -FixtureDirectory tests/fixtures/blast_radius/historical-runs`.
      Acceptance: exit 0. `COST-LINES` and `COST-SHA256` equal the P0-T8 values, so every pinned `Get-BlastRadiusPairCost` value is unchanged. `PAIRS-REFERENCE-SHA256` equals the P0-T8 value. `PAIRS-CANDIDATE-MATCHES-REFERENCE=True`. Any mismatch quotes the first differing `COST` or `PAIRS` line against P0-T8.
- [x] [P2-T6] Post-remediation timing of HISTORICAL (`tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`), coverage disabled, three runs (background, exclusive per Execution constraints), and write FEATURE/evidence/qa-gates/r1-historical-runs-timing.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/timing.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -Runs 3`.
      Acceptance: exit 0; `CODE-COVERAGE-ENABLED=False`; the `PESTER-VERSION=` value equals the ORIGINAL-BASELINE P0-T10 value; three `RUN` lines each with `Total=9 Passed=9 Failed=0`; one `MEDIAN-SECONDS=` line recorded.
- [x] [P2-T7] Timing comparison for AC-2 against the ORIGINAL-BASELINE median of 213.12 s: compute the ratio and write FEATURE/evidence/qa-gates/r1-timing-comparison.TS.md (`tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`).
      Command: `awk 'BEGIN { printf "RATIO=%.2f\n", 213.12 / POST_MEDIAN }'`, with the P2-T6 median substituted as a literal number for POST_MEDIAN.
      Acceptance: exit 0 and RATIO is at least 4.00 (R6). The artifact states both medians, the ratio, the threshold, and PASS or FAIL. FAIL stops the plan as remediation-required.
- [x] [P2-T8] Full Pester suite through MCP-TEST, with JUnit and coverage parsing, and write FEATURE/evidence/qa-gates/r1-full-suite-pester.TS.md (`artifacts/pester/pester-junit.xml` read as tool output).
      Commands: `date -u +%Y-%m-%dT%H:%M:%SZ` (record as START); MCP-TEST; `sh SCRATCH/run-ps.sh SCRATCH/junit-summary.ps1 -Path artifacts/pester/pester-junit.xml`; `sh SCRATCH/run-ps.sh SCRATCH/coverage-xml.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -BaseRef BASE_SHA .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1` (substitute the full BASE_SHA).
      Acceptance:
      - both scripts exit 0, and both last-write values are later than START;
      - `JUNIT-TESTCASES` equals 5726 (5676 + 33 + 17);
      - there is no `JUNIT-FAILED-CASE` line, except one whose `file=` is `enforce-pr-author-skill.Tests.ps1` or `codex-pretooluse-integration.Tests.ps1`. Those two suites read the gitignored `artifacts/orchestration/orchestrator-state.json`, which changes during the run. Each excepted line is quoted in the artifact under `PRE-EXISTING-STATE-DEPENDENT:`. Any other failing case fails the task;
      - every `JUNIT-BLAST-SUITE` line shows `failures=0 errors=0`, including the four new files;
      - the `COVERAGE` and `CHANGED` lines for the three modules are recorded as numbers.
- [x] [P2-T9] Coverage threshold and delta for AC-5: from the ORIGINAL-BASELINE P0-T12, this plan's P0-T10, P2-T3, and P2-T8 artifacts, write FEATURE/evidence/qa-gates/r1-coverage-delta.TS.md for GLOB, CONFLICT, and SCHEDULING (`.claude/lib/blast-radius/BlastRadiusScheduling.psm1` and the two others).
      For each file, record: the baseline LinePercent (ORIGINAL-BASELINE P0-T12 for GLOB and CONFLICT; this plan's P0-T10 for SCHEDULING); the P2-T8 LinePercent; the P2-T3 LinePercent; and the P2-T8 changed-line values against BASE_SHA.
      Acceptance: PASS only if, for all three files, the P2-T8 LinePercent is at least 85, `AnalyzedChangedLines` is greater than 0, and `ChangedLinePercent` is at least 85. Otherwise the artifact states remediation-required and the task fails.
- [x] [P2-T10] Line limits for AC-5: run A4 over IN-SCOPE-7 (`.claude/lib/blast-radius/BlastRadiusScheduling.psm1` and the other six), and write FEATURE/evidence/qa-gates/r1-line-counts.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1` followed by the IN-SCOPE-7 paths.
      Acceptance: exit 0, every LineCount is at most 500, and SCHEDULING is at most 486 (R5). The R7 target for CONFLICT (at most 470) is reported as informational.
- [x] [P2-T11] Final mirror identity: run the P0-T6 A5 command over the three primary-and-mirror pairs (`extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`), and write FEATURE/evidence/qa-gates/r1-mirror-hashes.TS.md.
      Acceptance: exit 0 and each primary hash equals its mirror hash.
- [x] [P2-T12] Export surface subset for AC-4: run A13 against the ORIGINAL-BASELINE export-surface artifact located in P0-T7 (under `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/baseline/`), and write FEATURE/evidence/qa-gates/r1-export-subset.TS.md.
      Command: `sh SCRATCH/run-ps.sh SCRATCH/export-subset.ps1 -BaselineArtifact BASELINE_EXPORT_ARTIFACT -ExpectedAddition "BlastRadiusConflict.psm1 function=Get-OverlappingPathPair"`, substituting the P0-T7 path.
      Acceptance: exit 0; `BASELINE-COUNT=64`; `MISSING-COUNT=0`; `ADDED-COUNT=1`; the one `ADDED` line names module BlastRadiusConflict.psm1 and function Get-OverlappingPathPair; `SUBSET-RESULT=PASS`.
- [x] [P2-T13] Scope and fixture immutability for AC-1: write FEATURE/evidence/qa-gates/r1-scope-and-fixture-immutability.TS.md (`tests/fixtures/blast_radius`, `tests/scripts/claude-lib/blast-radius`).
      Commands: `git diff --name-only BASE_SHA -- .claude/lib extensions/drm-copilot/resources/claude-customizations/.claude/lib scripts tests config` (substitute the full SHA); `git status --porcelain -- .claude/lib extensions/drm-copilot/resources/claude-customizations/.claude/lib scripts tests config`.
      Acceptance: the union of the listed paths is a subset of these ten: GLOB, CONFLICT, SCHEDULING, GLOB-MIRROR, CONFLICT-MIRROR, SCHEDULING-MIRROR, TEST-CACHE, TEST-OVERLAP, TEST-PAIRS, TEST-COST. Each of the ten appears in at least one output. No existing file under `tests/fixtures/blast_radius` or `tests/scripts/claude-lib/blast-radius` appears, and neither `.claude/lib/blast-radius/BlastRadius.psm1` nor `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` appears.
- [x] [P2-T14] Bundle byte-identity test: run the pytest node that guards `.claude` bundle parity and write FEATURE/evidence/qa-gates/r1-bundle-parity-pytest.TS.md.
      Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`.
      Acceptance, case (a): the node prints PASSED and the artifact records `KL-510: PASSED`.
      Acceptance, case (b), the known local issue #510: the node fails; its assertion message is the literal "Repo file missing from bundle:" followed by one path for which `git check-ignore -q` exits 0; and no output line contains the literal "Bundle content differs from repo for:". The artifact records `KL-510: STATE-ONLY`, quotes the message verbatim, and carries `ExpectedExitCode: 1`.
      Any other outcome fails the task. P2-T11 remains the direct identity proof for the three mirrors.
- [x] [P2-T15] Reduced-audit handoff: write FEATURE/evidence/other/r1-small-audit-handoff.TS.md (under `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/other/`) listing AC-1 through AC-5, each with the artifact paths that evidence it per the traceability table below. Name the F-1 closure evidence (P2-T7). List AC-3 as orchestrator-verified post-PR per the original plan's "Post-PR verification" section, which is unchanged: `poshqc / PowerShell QC` of at most 700 s.
      Command: `ls docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/remediation-baseline docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/qa-gates docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/other docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/baseline`.
      Acceptance: every artifact path named in the handoff file appears in the listing.

## Acceptance-criteria traceability

| AC | issue.md criterion (abridged) | Implementation | Verification | Evidence |
| --- | --- | --- | --- | --- |
| AC-1 | blast-radius suites pass; no fixture or assertion edits | P1-T3, P1-T4, P1-T6 | P1-T8, P2-T3, P2-T5, P2-T8, P2-T13 | qa-gates/r1-blast-radius-pester-coverage, qa-gates/r1-cost-and-pairs-equivalence, qa-gates/r1-full-suite-pester, qa-gates/r1-scope-and-fixture-immutability |
| AC-2 | before/after local timing, coverage disabled, material reduction | P1-T3, P1-T4, P1-T6 | P2-T6, P2-T7 (against original P0-T10) | qa-gates/r1-historical-runs-timing, qa-gates/r1-timing-comparison |
| AC-3 | CI PowerShell QC job lower than 838 s | P1-T3, P1-T4, P1-T6 | orchestrator post-PR check (original plan section) | qa-gates/ci-powershell-qc-duration |
| AC-4 | exported signatures and return values unchanged | P1-T1 constraints, P1-T3 | P0-T7, P0-T8, P2-T5, P2-T12 | remediation-baseline/r1-export-subset, qa-gates/r1-export-subset, qa-gates/r1-cost-and-pairs-equivalence |
| AC-5 | line coverage >= 85% per touched file; no file over 500 lines | P1-T2, P1-T5 | P2-T3, P2-T8, P2-T9, P2-T10 | qa-gates/r1-coverage-delta, qa-gates/r1-full-suite-pester, qa-gates/r1-line-counts |

## Appendix — scratch scripts

A1 through A12 are written verbatim from the Appendix of `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/plan.2026-09-29T18-10.md`. A13 and A14 follow.

A13 export-subset.ps1 (runs A9 in-process; `-ExpectedAddition NONE` requires no addition):

```powershell
param(
    [Parameter(Mandatory)][string] $BaselineArtifact,
    [Parameter(Mandatory)][string] $ExpectedAddition
)
$ErrorActionPreference = 'Stop'
$marker = 'SURFACE module='
$baseline = @(Get-Content -LiteralPath $BaselineArtifact | ForEach-Object {
        $index = $_.IndexOf($marker, [System.StringComparison]::Ordinal)
        if ($index -ge 0) { $_.Substring($index).Trim() }
    })
$current = @(& (Join-Path -Path $PSScriptRoot -ChildPath 'export-surface.ps1') | Where-Object { $_.StartsWith($marker, [System.StringComparison]::Ordinal) })
$baselineSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$baseline, [StringComparer]::Ordinal)
# A SURFACE line quoted twice in the baseline artifact counts once.
$baseline = @($baselineSet)
$currentSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$current, [StringComparer]::Ordinal)
$missing = @($baseline | Where-Object { -not $currentSet.Contains($_) })
$added = @($current | Where-Object { -not $baselineSet.Contains($_) })
Write-Output "BASELINE-COUNT=$($baseline.Count)"
Write-Output "CURRENT-COUNT=$($current.Count)"
Write-Output "MISSING-COUNT=$($missing.Count)"
foreach ($line in $missing) { Write-Output "MISSING $line" }
Write-Output "ADDED-COUNT=$($added.Count)"
foreach ($line in $added) { Write-Output "ADDED $line" }
$expectedPrefix = "$marker$ExpectedAddition "
$additionOk = if ($ExpectedAddition -ceq 'NONE') { $added.Count -eq 0 } else { $added.Count -eq 1 -and $added[0].StartsWith($expectedPrefix, [System.StringComparison]::Ordinal) }
$pass = $missing.Count -eq 0 -and $additionOk
Write-Output ('SUBSET-RESULT={0}' -f $(if ($pass) { 'PASS' } else { 'FAIL' }))
if (-not $pass) { exit 1 }
```

A14 pin-cost-and-pairs.ps1 (run from the repository root; the reference pair list is always the brute-force `Test-EntryOverlap` nested loop over the same non-mergeable path lists `Get-BlastRadiusPairCost` builds):

```powershell
param([Parameter(Mandatory)][string] $FixtureDirectory)
$ErrorActionPreference = 'Stop'
$library = (Resolve-Path -LiteralPath '.claude/lib/blast-radius').Path
foreach ($name in @('BlastRadius.psm1', 'BlastRadiusScheduling.psm1', 'BlastRadiusValidation.psm1', 'BlastRadiusConflict.psm1', 'BlastRadiusGlob.psm1')) {
    Import-Module (Join-Path -Path $library -ChildPath $name) -Force
}
$hasCandidate = $null -ne (Get-Command -Name 'Get-OverlappingPathPair' -ErrorAction SilentlyContinue)
function Get-TextHash {
    param([AllowEmptyCollection()][string[]] $Line = @())
    $bytes = [System.Text.Encoding]::UTF8.GetBytes(($Line -join "`n"))
    return [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes))
}
$strictMember = @{
    tolerance_percent = 0
    weights           = @{ same_file = 8; possible_overlap = 2; append_only = 1; module = 2 }
    band_durations    = @{ C1 = 1; C2 = 2; C3 = 4; C4 = 8 }
    default_band      = 'C1'
    append_only_paths = @('**/CHANGELOG.md')
}
$costLine = [System.Collections.Generic.List[string]]::new()
$referenceLine = [System.Collections.Generic.List[string]]::new()
$candidateLine = [System.Collections.Generic.List[string]]::new()
foreach ($file in @(Get-ChildItem -LiteralPath $FixtureDirectory -Filter '*.json' -File | Sort-Object -Property Name)) {
    $fixture = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json -AsHashtable -DateKind String
    $beforeConfig = $fixture['before']['config'].Clone()
    $beforeConfig['conflict_tolerance'] = $strictMember
    $variants = @(
        @{ Name = 'before'; Config = $beforeConfig; Normalize = $false },
        @{ Name = 'after'; Config = $fixture['after']['config']; Normalize = $true }
    )
    foreach ($variant in $variants) {
        $tolerance = Get-ConfigConflictTolerance -Config $variant['Config']
        $mergeable = [string[]]@(Get-ConfigMergeablePath -Config $variant['Config'])
        $radius = @{}
        foreach ($item in $fixture['items']) {
            $radius[[int]$item['issue_num']] = if ($variant['Normalize']) { Get-NormalizedDeclaredRadius -Radius $item['radius'] -Config $variant['Config'] } else { $item['radius'] }
        }
        $key = @($radius.Keys | Sort-Object)
        for ($i = 0; $i -lt $key.Count; $i++) {
            for ($j = $i + 1; $j -lt $key.Count; $j++) {
                $label = 'fixture={0} config={1} a={2} b={3}' -f $file.BaseName, $variant['Name'], $key[$i], $key[$j]
                $cost = Get-BlastRadiusPairCost -RadiusA $radius[$key[$i]] -RadiusB $radius[$key[$j]] -Config $variant['Config'] -Tolerance $tolerance
                $costLine.Add("COST $label cost=$cost")
                $left = ConvertTo-NormalizedBlastRadius -Radius $radius[$key[$i]]
                $right = ConvertTo-NormalizedBlastRadius -Radius $radius[$key[$j]]
                $pathsA = [string[]]@(Get-NonMergeablePathEntry -Entry ([string[]]@($left['paths'])) -MergeablePath $mergeable)
                $pathsB = [string[]]@(Get-NonMergeablePathEntry -Entry ([string[]]@($right['paths'])) -MergeablePath $mergeable)
                $reference = [System.Collections.Generic.List[string]]::new()
                foreach ($entryA in $pathsA) {
                    foreach ($entryB in $pathsB) {
                        if (Test-EntryOverlap -EntryA $entryA -EntryB $entryB) { $reference.Add("$entryA`t$entryB") }
                    }
                }
                $referenceLine.Add("PAIRS $label count=$($reference.Count) sha=$(Get-TextHash -Line $reference.ToArray())")
                if ($hasCandidate) {
                    $candidate = @(Get-OverlappingPathPair -PathA $pathsA -PathB $pathsB | ForEach-Object { "$($_['EntryA'])`t$($_['EntryB'])" })
                    $candidateLine.Add("PAIRS $label count=$($candidate.Count) sha=$(Get-TextHash -Line $candidate)")
                }
            }
        }
    }
}
foreach ($line in $costLine) { Write-Output $line }
foreach ($line in $referenceLine) { Write-Output $line }
Write-Output "COST-LINES=$($costLine.Count)"
Write-Output "COST-SHA256=$(Get-TextHash -Line $costLine.ToArray())"
Write-Output "PAIRS-LINES=$($referenceLine.Count)"
Write-Output "PAIRS-REFERENCE-SHA256=$(Get-TextHash -Line $referenceLine.ToArray())"
if ($hasCandidate) {
    $candidateHash = Get-TextHash -Line $candidateLine.ToArray()
    Write-Output "PAIRS-CANDIDATE-SHA256=$candidateHash"
    Write-Output "PAIRS-CANDIDATE-MATCHES-REFERENCE=$($candidateHash -ceq (Get-TextHash -Line $referenceLine.ToArray()))"
} else {
    Write-Output 'PAIRS-CANDIDATE=ABSENT'
}
```
