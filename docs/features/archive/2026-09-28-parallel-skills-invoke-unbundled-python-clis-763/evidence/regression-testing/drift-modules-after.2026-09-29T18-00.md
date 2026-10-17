# Drift Module Suites With the Modules Present (P3-T14)

Timestamp: 2026-09-29T18-00
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-selfhosted.ps1 tests/scripts/claude-lib/parallel-drift ; poetry run python SCRATCH/junit-cases.py artifacts/pester/pester-junit.xml parallel-drift/ParallelDriftHalt.Tests.ps1 parallel-drift/ParallelDrift.Tests.ps1 parallel-drift/ParallelDrift.Manifest.Tests.ps1
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary:
- `JUNIT file=parallel-drift/ParallelDriftHalt.Tests.ps1 Total=28 Passed=28 Failed=0 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Tests.ps1 Total=26 Passed=26 Failed=0 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Manifest.Tests.ps1 Total=5 Passed=1 Failed=4 Other=0`
- `JUNIT-ALL Total=59 Failed=4`; the four failures are the Manifest cases that need the core.json
  entries and bundle copies of Phase 5:
  - lists every discovered library file in core.json paths
  - lists the entry script exactly once
  - ships a bundled counterpart for every library file
  - ships byte-identical bundled counterparts
- The Pester process EXIT_CODE 4 equals the four expected Manifest failures.

Every B14 and B15 It name appears on a `JUNIT-CASE status=Passed` line (the templated B14 name
'Assert-ParallelDriftItemKey rejects <case>' appears as its four expansions: zero, negative,
boolean, string). Additional tests added by the executor (permitted by Appendix B) also passed:
Halt: 'Assert-ParallelDriftText returns a non-blank value unchanged', 'Assert-ParallelDriftPathList
rejects a non-collection value', '... rejects an empty collection when not allowed', '...
deduplicates and sorts ordinally', 'Assert-ParallelDriftEnumMember rejects a value outside the
vocabulary', '... returns a member unchanged', 'Get-ParallelDriftStartRank ranks an unknown start
above a timestamped start', '... rejects a non-string start timestamp'; Drift:
'Get-ParallelDriftCheckpointItem returns every object entry in order',
'Test-ParallelDriftObservedPairEdge reports no edge for a disjoint peer radius',
'Get-ParallelDriftNewConflictPair returns canonical pairs in ascending order'.

Passed cases (JUNIT-CASE status=Passed):
Halt (28): Assert-ParallelDriftItemKey accepts a positive integer; rejects zero; rejects negative;
rejects boolean; rejects string; Assert-ParallelDriftText rejects a blank value; returns a
non-blank value unchanged; Assert-ParallelDriftPathList rejects a bare string; rejects a
non-collection value; rejects a blank entry; rejects an empty collection when not allowed; accepts
an empty collection when allowed; deduplicates and sorts ordinally; Assert-ParallelDriftEnumMember
rejects a value outside the vocabulary; returns a member unchanged; ConvertTo-ParallelDriftItemKey
returns null for an unreadable value; Get-ParallelDriftCanonicalPair orders the lower key first;
Get-ParallelDriftStartRank ranks an unknown start above a timestamped start; rejects a non-string
start timestamp; Select-ParallelDriftHaltedItem halts the later timestamp; halts the larger key on
equal timestamps; halts the item whose start is unknown; halts the larger key when both starts are
unknown; rejects a pair that names one item twice; Get-ParallelDriftHaltedItemKey never returns the
drifting key; returns deduplicated ascending keys; returns an empty array for no pairs; applies the
comparator when the drifting key is in neither member.
Drift (26): imports the blast-radius library and defines none of its functions; calls the
subsumption, observed-radius, conflict, and pair-decision functions;
Get-ParallelDriftCheckpointItem rejects a non-list items collection; rejects a non-object items
entry; returns every object entry in order; Get-ParallelDriftCheckpointEdge rejects a non-list
conflict_edges collection; omits a non-object edge; Get-ParallelDriftItemRecord rejects an item key
absent from the checkpoint; Get-ParallelDriftDeclaredPath rejects a non-object blast_radius;
rejects a non-list paths value; Get-ParallelDriftEscapedPath returns an empty array when every path
is subsumed; returns the paths no declared entry covers; Get-ParallelDriftEvent carries exactly the
six drift-event keys; rejects an empty escaped-path list; Get-ParallelDriftExistingEdgePair
canonicalizes a reversed edge; omits an edge with identical endpoints; Get-ParallelDriftItemBand
returns null for an unreadable band; Test-ParallelDriftObservedPairEdge fails closed for a
non-object peer radius; fails closed for an unparseable peer radius; reports no edge for a disjoint
peer radius; Get-ParallelDriftNewConflictPair skips a peer that is not in flight; skips a pair
already recorded as an edge; returns canonical pairs in ascending order; Get-ParallelDriftResult
returns no_escape with null drift_event and observed_radius; returns no_new_conflict with a
raised_blocking_finding event; returns halt_required with a halted_later_started_item event.
Manifest (1): discovers the parallel-drift library files on disk.
