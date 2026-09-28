# Pester Part A (P5-T10)

Timestamp: 2026-09-27T15-52
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <file> -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath <xml> (one run per file of P5-T2, P5-T3, P5-T4)
EXIT_CODE: 0
Output Summary: All three runs printed FailedCount=0. The P5-T2 run (BlastRadiusScheduling.Tests.ps1) printed TotalCount=50, PassedCount=50, one It per B23 entry, and COVERAGE for the scheduling module AnalyzedLines=122 CoveredLines=122 LinePercent=100. The P5-T3 run (historical runs) printed 6/6 passed, scheduling-module LinePercent=90.98. The P5-T4 run (key partition, including conflict_tolerance in Class 1) printed 5/5 passed; it does not exercise the scheduling module (LinePercent=0 is expected for that file). The P5-T9 pack-manifest edit parses as JSON (poetry run python -m json.tool exit 0).

## Run 1: P5-T2 file

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath SCRATCH/pester-p5.xml
EXIT_CODE: 0

```text
Describing BlastRadiusScheduling
 Context Edge rule terms
   [+] keeps a shared-surface overlap hard at every tolerance
   [+] treats a contract dependency as hard
   [+] costs equal concrete entries the same_file weight
   [+] evaluates append_only before same_file
   [+] costs a directory-prefix overlap the possible_overlap weight
   [+] adds the module weight per shared module
   [+] costs mergeable paths nothing
   [+] uses the minimum band duration as the benefit
   [+] uses default_band for a missing band
   [+] applies the integer inequality strictly at its boundary
   [+] records the first canonical reason kind
   [+] reads an absent key as strict
 Context conflict_tolerance reader
   [+] rejects non-object
   [+] rejects percent-negative
   [+] rejects percent-float
   [+] rejects percent-string
   [+] rejects percent-bool
   [+] rejects weight-zero
   [+] rejects weight-bool
   [+] rejects weight-float
   [+] rejects weight-unknown-name
   [+] rejects weight-missing-name
   [+] rejects band-duration-zero
   [+] rejects band-missing-name
   [+] rejects default-band-out-of-range
   [+] rejects append-only-not-list
 Context Scheduling fixtures
   [+] reproduces the expected decisions for scheduling-452-shared-surface-hard
   [+] reproduces the expected decisions for scheduling-452-directory-prefix-weighted
   [+] reproduces the expected decisions for scheduling-452-negative-controls
   [+] reproduces the expected decisions for scheduling-soft-pair-tolerated
   [+] reproduces the expected decisions for scheduling-absent-key-strict
   [+] embeds the radii in every #452 scheduling fixture
 Context Strict identity
   [+] matches detection at tolerance 0 for conflict-contract
   [+] matches detection at tolerance 0 for conflict-directory-vs-file
   [+] matches detection at tolerance 0 for conflict-directory-vs-glob
   [+] matches detection at tolerance 0 for conflict-empty-vs-empty
   [+] matches detection at tolerance 0 for conflict-empty-vs-nonempty
   [+] matches detection at tolerance 0 for conflict-glob-concrete
   [+] matches detection at tolerance 0 for conflict-glob-undecidable
   [+] matches detection at tolerance 0 for conflict-mergeable-csproj-no-edge
   [+] matches detection at tolerance 0 for conflict-mergeable-glob-still-contends
   [+] matches detection at tolerance 0 for conflict-module-overlap
   [+] matches detection at tolerance 0 for conflict-multi-reason
   [+] matches detection at tolerance 0 for conflict-none-disjoint
   [+] matches detection at tolerance 0 for conflict-path-overlap
   [+] matches detection at tolerance 0 for conflict-shared-surface
   [+] matches detection at tolerance 0 for conflict-sibling-prefix-disjoint
 Context Ordering and symmetry
   [+] sorts edges and tolerated overlaps by pair
   [+] decides (b, a) the same as (a, b)
   [+] fails fast naming the facade when Test-BlastRadiusConflict is unavailable
TotalCount=50
PassedCount=50
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=122 CoveredLines=122 LinePercent=100
```

B23 mapping: the twelve Edge rule terms It blocks correspond one-to-one to the twelve non-parametrized
B10 tests from test_shared_surface_overlap_is_hard_at_every_tolerance through
test_absent_key_reads_as_strict; the fourteen 'rejects <Case>' It blocks to the fourteen reader
cases; the five 'reproduces the expected decisions for <FixtureName>' It blocks to the five fixtures;
'embeds the radii in every #452 scheduling fixture' to test_452_scheduling_fixtures_embed_radii; the
fifteen 'matches detection at tolerance 0 for <FixtureName>' It blocks cover every top-level conflict
fixture (test_strict_identity_over_existing_conflict_fixtures); 'sorts edges and tolerated overlaps
by pair' to test_edges_and_tolerated_overlaps_are_sorted_by_pair; and 'decides (b, a) the same as
(a, b)' is the B23 symmetry block. One additional It, 'fails fast naming the facade when
Test-BlastRadiusConflict is unavailable', covers the fail-fast branch that P5-T5 specifies for the
call-time resolution of the relation (Get-Command is mocked inside the scheduling module).

The per-fixture and per-case It names are interpolated at discovery time by a loop, so the fixture
name is part of the unexpanded test name and a Pester FullName filter on a fixture name selects the
matching test (see P7-T2).

## Run 2: P5-T3 file

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath SCRATCH/pester-p5-historical.xml
EXIT_CODE: 0

```text
  [+] reproduces the pinned BEFORE edges for epic-655-followups 1.88s
  [+] matches detection at tolerance 0 for epic-655-followups 4.88s
  [+] reproduces the pinned BEFORE edges for backlog-2026-09-26 7.97s
  [+] matches detection at tolerance 0 for backlog-2026-09-26 26.32s
  [+] reproduces the pinned BEFORE edges for followups-2026-09-27 23.64s
  [+] matches detection at tolerance 0 for followups-2026-09-27 96.2s
TotalCount=6
PassedCount=6
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=122 CoveredLines=111 LinePercent=90.98
```

Recorded deviation: this run was executed in the background with -CoverageOutputPath
SCRATCH/pester-p5-historical.xml instead of SCRATCH/pester-p5.xml so that it could not overwrite the
XML of the run executing at the same time. The output path is a scratch file outside the
repository; the printed counts and the COVERAGE line are unaffected.

## Run 3: P5-T4 file

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath SCRATCH/pester-p5.xml
EXIT_CODE: 0

```text
   [+] declares equal values for the runtime-describing keys in both copies
   [+] requires every separator-free self-hosted shared surface to reach the bundled copy
   [+] requires every top-level key in both copies to be classified and shared
   [+] requires a populated shared-surface list and module map in both copies
   [+] requires every Class 2 and Class 3 key to be indexed by name in its registered consumer file
TotalCount=5
PassedCount=5
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=122 CoveredLines=0 LinePercent=0
```

The key-partition file reads the two committed config copies only and never calls the scheduling
module, so 0 percent is the expected value for this file; the scheduling module's coverage headline
is the Run 1 value (100 percent).

SCRATCH denotes the executor session scratchpad directory (outside the repository).
