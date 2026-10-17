# P8-T11 Regression over tests/scripts/claude-lib

Timestamp: 2026-10-09T00-56
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib
EXIT_CODE: 0
Output Summary:
  Failed: 38, 
  TotalCount=2341
  PassedCount=2302
  FailedCount=38
  FAILED: Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving potential_to_issue alone
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving the feature entry tool with a record
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption accepts valid records (AC-6).accepts a bug checkpoint waiving the bug entry tool with a record
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption accepts valid records (AC-6).accepts the same record on the preparation route
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption accepts valid records (AC-6).accepts the documented origin value transferred
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption accepts valid records (AC-6).accepts the documented origin value filed_before_orchestration
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption accepts valid records (AC-6).accepts the documented origin value epic_decomposition
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_issue_view
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_api_get
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption accepts valid records (AC-6).accepts the documented verification source github_mcp_issue_read
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind string
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind integer
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind list
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a null adoption value
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects an integer issue number
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a leading-zero issue number
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects an issue number that differs from the checkpoint issue-num
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects an issue URL that does not end with the issue number
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects an unknown origin
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects an unknown verification source
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects an absent verification time
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a null verification time
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a whitespace-only verification time
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects empty evidence
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects an empty waived list
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind string
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind blank-entry
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind integer-entry
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects a waived list that omits the issue-creation tool
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption rejects malformed records (AC-7).rejects an invalid potential record when waiving the entry tool
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature-folder tool
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the artifact-validation tool
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature entry tool on a bug checkpoint
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects any waiver on the remediation route
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving a tool that holds a successful receipt
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects a tool listed twice
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption fails closed and is presence gated (AC-9, AC-11).empties the waived set whenever any error is reported across a fixed grid
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
  FAILED: Issue adoption fails closed and is presence gated (AC-9, AC-11).yields no errors and no waivers for a checkpoint without the adoption key
  FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1

## Full output

```text
Pester v5.6.1

Starting discovery in 85 files.
Discovery found 2341 tests in 2.57s.
Running tests.

Running tests from 'tests\scripts\claude-lib\ClaudeLibModuleConvention.Tests.ps1'
Describing Claude library module conventions
 55ms (34ms|21ms)
 177ms (177ms|1ms)
 108ms (106ms|2ms)
 149ms (148ms|1ms)
 644ms (643ms|1ms)
 71ms (70ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Conflict.Tests.ps1'
Describing Test-BlastRadiusConflict result shape
 Context The documented return contract
 63ms (59ms|4ms)
 14ms (14ms|1ms)
 29ms (28ms|1ms)
 9ms (9ms|1ms)
 67ms (67ms|1ms)

Describing Test-BlastRadiusConflict disjuncts in isolation
 Context path_overlap
 13ms (11ms|3ms)
 16ms (15ms|1ms)
 9ms (9ms|1ms)
 Context module_overlap, shared_surface_overlap, and contract_dependency
 11ms (9ms|1ms)
 9ms (8ms|1ms)
 10ms (9ms|1ms)
 30ms (13ms|17ms)
 Context Mechanically-mergeable paths (issue #643)
 55ms (53ms|3ms)
 14ms (13ms|1ms)
 20ms (19ms|1ms)

Describing Test-BlastRadiusConflict fail-closed behavior
 Context Undecidable glob pairs
 18ms (13ms|5ms)
 20ms (18ms|2ms)
 Context Empty radii
 13ms (10ms|3ms)
 12ms (10ms|1ms)

Describing Test-BlastRadiusConflict reason ordering
 Context The fixed kind order
 18ms (13ms|5ms)
 16ms (15ms|1ms)
 15ms (14ms|1ms)

Describing Contention relation invariants
 Context Symmetry
 28ms (25ms|3ms)
 24ms (23ms|1ms)
 Context Monotonicity
 18ms (16ms|2ms)
 20ms (18ms|1ms)
 Context Self-conflict and determinism
 21ms (18ms|3ms)
 10ms (9ms|1ms)
 8ms (7ms|1ms)
 22ms (21ms|1ms)
 24ms (23ms|1ms)
 15ms (14ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.HistoricalRuns.Tests.ps1'
Describing Blast-radius historical runs
 349ms (347ms|2ms)
 1.16s (1.16s|1ms)
 907ms (907ms|1ms)
 1.39s (1.39s|1ms)
 4.61s (4.6s|1ms)
 1.93s (1.93s|0ms)
 4.55s (4.55s|0ms)
 19.94s (19.94s|0ms)
 7.2s (7.2s|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.KeyPartition.Tests.ps1'
Describing Committed blast-radius truth table cross-copy key partition
 Context Cross-copy key partition
 8ms (7ms|1ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 13ms (13ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Manifest.Tests.ps1'
Describing Blast-radius core.json manifest membership
 Context Library coverage
 2ms (1ms|1ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 Context Bundled payload parity
 4ms (4ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Parity.Tests.ps1'
Describing Blast-radius fixture corpus discovery
 Context Non-vacuous iteration
 6ms (4ms|1ms)
 4ms (4ms|0ms)
 2ms (2ms|0ms)

Describing Blast-radius derivation and validation parity
 Context Derived radius
 25ms (23ms|2ms)
 8ms (8ms|0ms)
 7ms (6ms|0ms)
 9ms (9ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 5ms (4ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 12ms (11ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 6ms (6ms|0ms)
 4ms (4ms|0ms)
 7ms (6ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 Context Validation findings
 27ms (26ms|1ms)
 10ms (10ms|0ms)
 8ms (7ms|0ms)
 7ms (7ms|0ms)
 8ms (8ms|0ms)
 10ms (10ms|0ms)
 7ms (7ms|1ms)
 7ms (7ms|0ms)
 9ms (9ms|0ms)
 14ms (13ms|0ms)
 8ms (8ms|0ms)
 8ms (8ms|0ms)
 7ms (7ms|0ms)
 9ms (9ms|0ms)
 13ms (12ms|0ms)
 9ms (8ms|0ms)
 7ms (7ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 7ms (6ms|0ms)

Describing Blast-radius contention parity
 Context Conflict verdict
 6ms (6ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 7ms (7ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 Context Conflict reasons
 6ms (5ms|1ms)
 7ms (6ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 10ms (9ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)

Describing Verification-integrity regression (issue #489)
 Context Before state
 437ms (436ms|1ms)
 Context After state
 423ms (423ms|1ms)
 218ms (217ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Regression452.Tests.ps1'
Describing BlastRadius regression corpus for issue 452
 Context Corpus contract
 10ms (8ms|2ms)
 121ms (121ms|0ms)
 7ms (7ms|0ms)
 10ms (10ms|0ms)
 18ms (17ms|0ms)
 4ms (3ms|0ms)
 7ms (6ms|0ms)
 Context Detection-level verdicts
 40ms (39ms|1ms)
 20ms (20ms|0ms)
 19ms (19ms|0ms)
 15ms (15ms|0ms)
 12ms (11ms|0ms)
 3ms (3ms|0ms)
 7ms (7ms|1ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 6ms (5ms|0ms)
 Context Bundled configuration parity
 4ms (4ms|1ms)
 Context Tolerance branch
   [!] keeps a scheduling edge for every must-conflict case at the strictest tolerance is skipped, because  because Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.,
 11ms (9ms|2ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Tests.ps1'
Describing Get-BlastRadius record shape
 Context Key set and source vocabulary
 8ms (7ms|1ms)
 5ms (5ms|0ms)
 6ms (5ms|0ms)
 16ms (15ms|0ms)
 8ms (8ms|0ms)
 8ms (7ms|0ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)

Describing Get-BlastRadius path derivation
 Context The feature-folder append
 7ms (6ms|1ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 Context Plan and spec contributions
 7ms (6ms|1ms)
 8ms (7ms|0ms)
 5ms (5ms|0ms)
 7ms (7ms|0ms)

Describing Get-BlastRadius module and surface resolution
 Context Modules
 7ms (6ms|1ms)
 5ms (5ms|0ms)
 Context Shared surfaces
 6ms (5ms|1ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 8ms (5ms|3ms)
 Context Contracts
 6ms (5ms|1ms)
 5ms (5ms|0ms)

Describing Get-BlastRadiusFromObservedPaths
 Context Observed-source radii
 6ms (5ms|1ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)

Describing Get-NormalizedDeclaredRadius
 Context Re-filtering a recorded radius (issue #489)
 9ms (8ms|1ms)
 7ms (6ms|0ms)
 4ms (4ms|0ms)

Describing Exported facade surface
 Context Spec PowerShell surface
 6ms (5ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (0ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (0ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.TruthTable.Tests.ps1'
Describing Committed blast-radius truth table shape
 Context Schema version
 3ms (2ms|1ms)
 Context Module map
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 Context Over-breadth fraction
 3ms (3ms|0ms)
 Context Shared surfaces
 2ms (1ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 13ms (13ms|0ms)
 Context Read-by-mandate exclusions
 4ms (3ms|1ms)
 6ms (5ms|0ms)
 2ms (2ms|0ms)
 Context Non-vacuity floor helper
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context Location-bucket modules
 2ms (1ms|0ms)
 Context Disjoint work items
 31ms (31ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Validation.Tests.ps1'
Describing ConvertTo-NormalizedBlastRadius
 Context Construction invariants
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)

Describing Test-BlastRadius rule V1
 Context Coverage of plan paths
 6ms (5ms|1ms)
 5ms (5ms|0ms)
 6ms (6ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 8ms (7ms|0ms)

Describing Test-BlastRadius rule V2
 Context Shared-surface enumeration
 5ms (5ms|1ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 3ms (3ms|0ms)
 7ms (7ms|0ms)

Describing Test-BlastRadius rule V3
 Context The over-breadth boundary
 6ms (5ms|1ms)
 6ms (5ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)

Describing Test-BlastRadius finding ordering and determinism
 Context Cross-rule ordering
 7ms (6ms|1ms)
 9ms (9ms|0ms)
 8ms (7ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusConfig.Tests.ps1'
Describing Get-RequiredText
 Context Accepted values
 6ms (5ms|1ms)
 2ms (1ms|0ms)
 Context Rejected values
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)

Describing Get-RequiredStringList
 Context Accepted collections
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 Context Rejected collections
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)

Describing Get-RequiredMapping
 Context Accepted shapes
 2ms (1ms|1ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 Context Rejected shapes
 3ms (2ms|0ms)
 5ms (5ms|0ms)

Describing Get-ConfigStringList
 Context Reading optional list entries
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Get-ConfigRootSurface
 Context Reading the separator-free subset
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)

Describing Get-ConfigModuleEntry
 Context Reading the module map
 3ms (3ms|1ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)

Describing Get-ConfigOverBreadthFraction
 Context Accepted thresholds
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 Context Rejected thresholds
 4ms (3ms|1ms)
 6ms (6ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|1ms)
 2ms (1ms|1ms)
 1ms (1ms|0ms)

Describing Get-ConfigMandateRead
 Context Optional read-by-mandate list
 4ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)

Describing Resolve-BlastRadiusModule
 Context Module resolution
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Resolve-BlastRadiusSharedSurface
 Context Surface membership
 7ms (6ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Committed truth table
 Context config/blast-radius.json shape
 4ms (3ms|1ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.OverlappingPairs.Tests.ps1'
Describing Get-OverlappingPathPair (issue #776)
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 31ms (30ms|0ms)
 20ms (19ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.PathOverlap.Tests.ps1'
Describing Get-SmallestPathOverlap record-form parity (issue #776)
 6ms (5ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 4ms (4ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Get-SmallestPathOverlap minimum tracking (issue #776)
 4ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 4ms (4ms|0ms)
 2ms (2ms|0ms)

Describing ConvertTo-PathOverlapRecord (issue #776)
 11ms (11ms|1ms)
 4ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.Tests.ps1'
Describing Get-ConfigMergeablePath
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)

Describing Test-MergeablePath
 2ms (1ms|1ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 4ms (1ms|3ms)

Describing Get-NonMergeablePathEntry
 4ms (4ms|1ms)
 2ms (1ms|0ms)

Describing Relocated overlap helpers
 3ms (2ms|1ms)
 2ms (1ms|0ms)

Describing Test-BlastRadiusConflict equivalence
 10ms (9ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Path.Tests.ps1'
Describing Get-PathTokenKind
 Context Known top-level segments
 7ms (6ms|1ms)
 1ms (1ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 Context Directory-shaped token rejection (issue #489)
 4ms (3ms|1ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 Context Cross-corpus documentation-glob rejection (issue #489)
 3ms (3ms|1ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 Context Extension fallback rule
 4ms (4ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 Context Glob classification
 2ms (2ms|1ms)
 2ms (1ms|0ms)
 Context Rejected tokens
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context Configured separator-free root surfaces
 3ms (2ms|1ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 2ms (2ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)

Describing Get-PathFromLine and Get-PlanPaths
 Context Aggregation across lines
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 Context Whole-plan extraction
 3ms (3ms|1ms)
 5ms (4ms|0ms)

Describing Get-ContractIdentifier letterless rejection (issue #489)
 4ms (4ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)

Describing Get-ContractIdentifier
 Context Qualifying sections
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Exclusions
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Get-OrdinalSortedEntry
 Context Normalization
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Tests.ps1'
Describing ConvertTo-NormalizedLine
 Context Line-ending styles
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Degenerate input
 2ms (1ms|1ms)
 2ms (2ms|0ms)

Describing Get-PlanLineScan
 Context Task and phase line parsing
 3ms (2ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Get-InlineCodeToken
 Context Span extraction
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.RegexCache.Tests.ps1'
Describing Glob regex cache (issue #776)
 5ms (5ms|1ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)

Describing Test-GlobMatch cached and uncached agreement (issue #776)
 6ms (6ms|1ms)
 11ms (11ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Get-LiteralPrefix single-scan fast path (issue #776)
 4ms (3ms|1ms)
 1ms (0ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.Tests.ps1'
Describing Test-GlobEntry
 Context Wildcard detection
 4ms (3ms|1ms)
 1ms (0ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Get-ConcreteEntry
 Context Filtering
 2ms (2ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Test-GlobMatch
 Context The supported fnmatch subset
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Test-PathSubsumed
 Context The three coverage rules
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Get-LiteralPrefix
 Context Prefix extraction
 2ms (2ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Test-EntryOverlap
 Context Concrete against concrete
 2ms (1ms|1ms)
 5ms (1ms|3ms)
 Context Glob against concrete
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context Glob against glob, decided conservatively
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 Context Directory containment, added by issue #452
 3ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (0ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context Monotonicity, the fail-closed invariant
 3ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)

Describing Get-OrdinalSmallestEntry
 Context Ordinal minimum
 3ms (2ms|1ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusNormalization.Tests.ps1'
Describing Test-MandateRead
 Context Exclusion rules
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Get-NonMandateReadEntry
 Context Collection filtering
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Read-by-mandate exclusion through the facade (issue #489)
 Context Derivation harvest
 8ms (7ms|1ms)
 6ms (6ms|0ms)
 Context Symmetric exclusion
 8ms (8ms|0ms)

Describing Get-NormalizedDeclaredRadius placeholder stripping (issue #502)
 Context Retrospective cleaning of an already-recorded radius
 9ms (8ms|1ms)
 5ms (5ms|0ms)

Describing Placeholder-only overlap after normalization (issue #502)
 Context Pair-level regression for the placeholder guard
 14ms (14ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.PairCost.Tests.ps1'
Describing Get-BlastRadiusPairCost equivalence (issue #776)
 15ms (12ms|3ms)
 12ms (11ms|1ms)
 6ms (6ms|1ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 7ms (6ms|1ms)
 9ms (8ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.Tests.ps1'
Describing BlastRadiusScheduling
 Context Edge rule terms
 21ms (20ms|1ms)
 7ms (7ms|0ms)
 5ms (5ms|0ms)
 14ms (14ms|0ms)
 9ms (9ms|0ms)
 5ms (5ms|0ms)
 7ms (6ms|0ms)
 4ms (4ms|0ms)
 2ms (2ms|0ms)
 13ms (12ms|0ms)
 10ms (10ms|0ms)
 5ms (4ms|0ms)
 Context conflict_tolerance reader
 6ms (5ms|1ms)
 4ms (4ms|0ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context Scheduling fixtures
 23ms (23ms|1ms)
 43ms (43ms|0ms)
 43ms (43ms|0ms)
 63ms (62ms|1ms)
 32ms (32ms|0ms)
 37ms (37ms|0ms)
 Context Strict identity
 17ms (16ms|1ms)
 14ms (13ms|0ms)
 11ms (10ms|0ms)
 7ms (6ms|0ms)
 9ms (9ms|0ms)
 11ms (11ms|0ms)
 11ms (11ms|0ms)
 12ms (11ms|0ms)
 11ms (11ms|0ms)
 14ms (13ms|0ms)
 12ms (12ms|0ms)
 11ms (10ms|0ms)
 12ms (12ms|0ms)
 14ms (14ms|0ms)
 10ms (10ms|0ms)
 Context Ordering and symmetry
 43ms (42ms|1ms)
 150ms (150ms|0ms)
 7ms (7ms|0ms)
 7ms (7ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusTokenShape.Tests.ps1'
Describing Placeholder-marker token-shape rejection (issue #502)
 Context Paired predicate and classifier assertions, one case per marker
 6ms (5ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 9ms (9ms|1ms)
 3ms (2ms|1ms)
 Context Marker position and discrimination
 5ms (4ms|1ms)
 3ms (3ms|0ms)
 Context Degenerate tokens must not throw
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 1ms (1ms|1ms)

Describing Test-MultipleFeatureFolderSpan after relocation (issue #489 behavior preserved)
 Context Cross-corpus documentation globs
 5ms (4ms|1ms)
 1ms (1ms|1ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 Context Module export surface after relocation
 4ms (4ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusWriteIntent.Tests.ps1'
Describing BlastRadiusWriteIntent
 Context Rules W1 through W6
 6ms (5ms|1ms)
 9ms (8ms|0ms)
 4ms (3ms|0ms)
 6ms (6ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 7ms (7ms|0ms)
 10ms (10ms|0ms)
 4ms (3ms|0ms)
 Context Flag behavior and selector
 26ms (25ms|1ms)
 28ms (28ms|0ms)
 15ms (15ms|0ms)
 80ms (80ms|0ms)
 13ms (13ms|0ms)
 301ms (301ms|0ms)
 Context Committed fixtures and readers
 12ms (11ms|1ms)
 6ms (6ms|0ms)
 7ms (7ms|0ms)
 13ms (12ms|0ms)
 11ms (11ms|0ms)
 7ms (6ms|0ms)
 46ms (46ms|0ms)
 28ms (27ms|0ms)
 5ms (4ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 6ms (6ms|0ms)

Running tests from 'tests\scripts\claude-lib\ci-gate\CiGate.Manifest.Tests.ps1'
Describing CiGate core.json manifest membership
 4ms (4ms|1ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\ci-gate\Invoke-CiGateParser.Tests.ps1'
Describing Invoke-CiGateParser.ps1
 Context conclusion derivation across bucket combinations
 7ms (6ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context fail-fast error handling
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 Context deterministic verified_at via injected clock
 4ms (3ms|1ms)
 Context field passthrough
 5ms (4ms|1ms)
 3ms (3ms|0ms)
 Context JSON emission
 3ms (3ms|0ms)
 Context Get-CiGateConclusion pure helper
 2ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\cleanup-manifest\CleanupWorktreeManifest.Tests.ps1'
Describing CleanupWorktreeManifest
 Context vocabulary constants
 8ms (6ms|2ms)
 3ms (3ms|0ms)
 Context path normalization
 3ms (2ms|1ms)
 Context removal record lookup
 6ms (5ms|0ms)
 2ms (2ms|0ms)
 Context allow predicate
 49ms (48ms|1ms)
 Context checkpoint exclusion
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\codex-routing\CodexDeployment.Parity.Tests.ps1'
Describing Resolve-CodexDeployment base profile table
 4ms (4ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)

Describing Resolve-CodexDeployment agent family resolution
 2ms (2ms|1ms)
 4ms (4ms|0ms)
 17ms (17ms|0ms)
 4ms (4ms|0ms)

Describing Resolve-CodexDeployment C3 overlay rule
 3ms (3ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)

Describing Resolve-CodexDeployment forced personas
 3ms (2ms|1ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)

Describing Resolve-CodexDeployment invalid-input throw surface
 3ms (2ms|1ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)

Describing Resolve-CodexDeployment model availability
 3ms (2ms|1ms)
 4ms (3ms|0ms)
 5ms (5ms|0ms)

Running tests from 'tests\scripts\claude-lib\codex-routing\CodexRouting.Manifest.Tests.ps1'
Describing CodexRouting core.json manifest membership
 4ms (4ms|1ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)

Describing CodexRouting bundle mirror byte identity
 7ms (7ms|1ms)

Running tests from 'tests\scripts\claude-lib\codex-routing\CodexTopology.Parity.Tests.ps1'
Describing Resolve-CodexTopology small route
 8ms (7ms|1ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Resolve-CodexTopology language normalization
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 4ms (4ms|0ms)

Describing Resolve-CodexTopology escalation precedence
 4ms (3ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Resolve-CodexTopology forced root persona
 4ms (3ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)

Describing Get-CodexForcedRootPersona
 2ms (2ms|1ms)

Describing Resolve-CodexTopology invalid-input throw surface
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Manifest.Tests.ps1'
Describing DiscoveryValidation core.json manifest membership
 4ms (3ms|1ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)

Describing DiscoveryValidation bundle mirror byte identity
 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Tests.ps1'
Describing DiscoveryValidation
 Context artifact-type table
 4ms (2ms|1ms)
 3ms (2ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
 Context profile placeholder contract
 4ms (3ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 Context schema resolution
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 Context schema-governed artifact validation
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 33ms (33ms|0ms)
 10ms (10ms|0ms)
 Context dispatch by artifact type
 3ms (3ms|0ms)
 2ms (1ms|0ms)
 10ms (9ms|0ms)
 2ms (1ms|0ms)
 3ms (2ms|0ms)
 Context seam result contract (defect D-2 avoidance)
 5ms (4ms|1ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.VersionFloor.Tests.ps1'
Describing DiscoveryValidation destination version floor
 Context floor boundary
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 Context message content (all three required elements)
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context fail-closed at every entry point
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 Context no silent degradation
 3ms (2ms|0ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\hook-payload\HookPayload.Tests.ps1'
Describing Read-ClaudeHookRawPayload transport
 Context precedence when several sources carry text
 5ms (4ms|1ms)
 3ms (3ms|0ms)
 Context fallback order when stdin is whitespace-only
 7ms (7ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 Context a throwing stdin read
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 Context redirect-guard polarity
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 4ms (4ms|0ms)
 Context environment-variable defaults
 4ms (3ms|1ms)
 3ms (3ms|0ms)

Describing ConvertFrom-ClaudeHookEnvelope
 Context well-formed payloads
 8ms (7ms|1ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 Context anomalous payloads
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 5ms (5ms|0ms)

Describing Get-ClaudeHookToolInput strict nested extraction
 Context well-formed envelopes
 4ms (3ms|1ms)
 Context envelope-level anomalies
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Resolve-ClaudeHookToolInput end-to-end extraction
 Context nested property extraction per matcher family
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 Context property-level tolerance inside a well-formed tool_input
 2ms (1ms|0ms)
 14ms (13ms|0ms)
 Context anomaly propagation
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Anomaly reason mapping
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Shape helper predicates
 Context Test-ClaudeHookEnvelopeHasKey
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context Test-ClaudeHookObjectValue
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 Context Get-ClaudeHookEnvelopeValue
 2ms (1ms|1ms)
 1ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidGrammar.Tests.ps1'
Describing MermaidGrammar reference data
 Context pinned documentation metadata
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 Context first-line keyword allowlist
 8ms (7ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 8ms (1ms|7ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 7ms (7ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 Context verified versus keyword-accept rows
 2ms (2ms|1ms)
 2ms (1ms|0ms)
 Context deep-checked diagram type set
 3ms (2ms|1ms)
 4ms (2ms|2ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 Context per-type arrow token sets
 5ms (5ms|1ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 4ms (4ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context statement-keyword exemption list
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 Context bracket-structural and post-colon classification
 5ms (4ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context keyword shape rule
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 Context type table accessors
 8ms (8ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidLineScanner.Tests.ps1'
Describing MermaidLineScanner quote-aware scanning
 Context quoted spans excluded from bracket balance
 20ms (19ms|1ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 Context backslash is an ordinary character
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 Context comment stripping outside quoted spans only
 4ms (4ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 Context directive recognition before comment stripping
 2ms (2ms|1ms)
 1ms (1ms|0ms)
 Context bracket imbalance detection on a structural line
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 10ms (10ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context unterminated quote detection
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 Context angle brackets are never structural
 3ms (3ms|1ms)
 2ms (2ms|0ms)
 Context Unicode content is scanned without error
 3ms (3ms|1ms)
 2ms (2ms|0ms)
 Context statement-keyword classification
 4ms (4ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 4ms (4ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context arrow candidate tokenization
 3ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 10ms (9ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 Context pre-colon segmentation for statement labels
 6ms (6ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context masking helpers used by the validator
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidMarkdownFences.Tests.ps1'
Describing MermaidMarkdownFences extraction
 Context plain fence recognition
 18ms (17ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context nested fence classification
 2ms (2ms|0ms)
 5ms (5ms|0ms)
 2ms (1ms|0ms)
 Context unclosed fence tolerance
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context opt-out marker contract
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context fence line parsing helpers
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 4ms (3ms|0ms)
 2ms (1ms|0ms)
 Context line splitting and quote-prefix helpers
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidValidation.Tests.ps1'
Describing Test-MermaidDiagram structural verdicts
 Context accepted diagrams of each checked type
 18ms (17ms|1ms)
 14ms (13ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context first-line keyword defects
 4ms (3ms|0ms)
 5ms (4ms|0ms)
 2ms (2ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 Context per-type invalid arrow tokens
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 6ms (6ms|0ms)
 5ms (5ms|0ms)
 Context bracket balance and quote termination
 7ms (6ms|1ms)
 5ms (4ms|0ms)
 5ms (5ms|0ms)
 5ms (5ms|1ms)
 Context subgraph pairing
 6ms (5ms|1ms)
 7ms (7ms|0ms)
 Context empty and whitespace-only content
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 Context line endings and frontmatter
 7ms (6ms|1ms)
 9ms (8ms|0ms)
 12ms (11ms|0ms)
 5ms (5ms|0ms)
 6ms (6ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 Context fail-open policy
 7ms (6ms|1ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 6ms (6ms|0ms)
 4ms (3ms|0ms)

Describing Test-MermaidManagedDiagram detector
 6ms (4ms|2ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|1ms)
 3ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidValidationAcceptMatrix.Tests.ps1'
Describing MermaidValidation accept matrix
 Context quoted-label constructs
 6ms (5ms|1ms)
 7ms (6ms|0ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 Context block and statement constructs
 9ms (8ms|1ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 16ms (15ms|0ms)
 5ms (5ms|0ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)
 Context free-text constructs
 7ms (6ms|1ms)
 3ms (3ms|0ms)
 Context documented grammar variants
 8ms (7ms|1ms)
 6ms (5ms|0ms)
 10ms (10ms|0ms)

Running tests from 'tests\scripts\claude-lib\model-routing\Get-ComplexityFloor.Tests.ps1'
Describing Get-ComplexityFloor
 Context No floor signals present
 3ms (2ms|1ms)
 Context A single present floor signal
 6ms (5ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context Multiple present floor signals
 3ms (2ms|1ms)
 4ms (3ms|0ms)
 Context Non-floor and unknown signals
 4ms (4ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Mixed floor and non-floor signals
 5ms (4ms|1ms)
 5ms (5ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 7ms (7ms|0ms)
 Context Determinism
 5ms (4ms|1ms)
 4ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\model-routing\ModelRouting.Manifest.Tests.ps1'
Describing ModelRouting core.json manifest membership
 6ms (5ms|1ms)
 4ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\model-routing\ModelRouting.Parity.Tests.ps1'
Describing ModelRouting config parity
 Context Base complexity-to-model table
 10ms (9ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 Context Preferred overlay
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 Context Floor candidate and ceiling bands
 3ms (3ms|1ms)
 3ms (2ms|0ms)
 Context Floor-signal name set
 7ms (6ms|1ms)
 6ms (6ms|0ms)
 Context Disabled policy literal
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\model-routing\Resolve-DelegationModel.Tests.ps1'
Describing Resolve-DelegationModel
 Context Base table under the available policy
 7ms (6ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 Context Disabled policy clamp
 3ms (3ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 3ms (2ms|0ms)
 Context Preferred overlay
 3ms (3ms|1ms)
 5ms (5ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 Context Determinism
 8ms (7ms|1ms)
 Context Out-of-table band (negative case)
 4ms (4ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Manifest.Tests.ps1'
Describing OrchestratorState core.json manifest membership
 5ms (5ms|1ms)
 5ms (4ms|0ms)
 35ms (34ms|0ms)
 21ms (21ms|0ms)
 9ms (9ms|0ms)

Describing OrchestratorState bundle mirror byte identity
 14ms (13ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1'
Describing Test-OrchestratorStatePrCreationReadiness
 Context PR-creation-ready checkpoint
 63ms (62ms|1ms)
 Context rejection conditions
 22ms (21ms|1ms)
 12ms (11ms|0ms)
 11ms (10ms|0ms)
 12ms (12ms|0ms)
 12ms (12ms|0ms)
 10ms (9ms|0ms)
 9ms (9ms|0ms)
 Context fail-closed conditions
 19ms (18ms|1ms)
 12ms (12ms|0ms)
 8ms (8ms|0ms)
 11ms (11ms|0ms)

Describing Invoke-OrchestratorStatePreflight
 Context Invoke-OrchestratorStatePreflight (direct seam tests)
 8ms (7ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 Context default invoker (portable path is the only path)
 254ms (253ms|1ms)
 57ms (57ms|0ms)
 15ms (15ms|0ms)
 28ms (27ms|0ms)
 19ms (19ms|0ms)

Describing Get-OrchestratorStateBasePresenceError per-step-key status vocabulary
 Context per-key extra statuses accepted on their owning key
 5ms (4ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 Context per-key extra statuses rejected on every non-owning key
 3ms (3ms|1ms)
 19ms (18ms|0ms)
 12ms (11ms|0ms)
 15ms (14ms|0ms)
 29ms (29ms|0ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 3ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context epic-merge-gate regression scenario
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.ValueContract.Tests.ps1'
Describing Get-OrchestratorStateCheckpoint value contract
 16ms (16ms|1ms)
 22ms (21ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Backcompat.Tests.ps1'
Describing Orchestrator-state blocked_reason back-compat capture
 5ms (4ms|1ms)
 8ms (8ms|0ms)
 62ms (62ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 13ms (12ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 15ms (15ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 11ms (10ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 19ms (19ms|0ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)
 10ms (10ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 11ms (10ms|0ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)
 12ms (11ms|0ms)
 5ms (4ms|0ms)
 4ms (3ms|0ms)
 9ms (8ms|0ms)
 4ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Parity.Tests.ps1'
Describing OrchestratorState blocked_reason corpus parity
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 4ms (4ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 10ms (9ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 6ms (5ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 5ms (5ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 2ms (2ms|0ms)
 6ms (6ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Tests.ps1'
Describing OrchestratorState blocked_reason base membership
 5ms (4ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 4ms (4ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Describing OrchestratorState blocked_reason PR-creation readiness
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Describing OrchestratorState blocked_reason grouped vocabulary
 6ms (5ms|1ms)
 3ms (3ms|0ms)

Describing OrchestratorState blocked_reason completion gate
 3ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCheckpointValue.Tests.ps1'
Describing Checkpoint shape predicates
 2ms (1ms|1ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Checkpoint member-name enumeration
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Checkpoint member accessor
 3ms (2ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Ordinal key sorting
 2ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Python zero equivalence
 4ms (4ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Python value equality
 2ms (2ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)

Describing Python str() rendering
 2ms (2ms|1ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Python repr() rendering
 2ms (1ms|1ms)
 10ms (10ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexModelReceipts.Tests.ps1'
Describing OrchestratorStateCodexModelReceipts shape and key checks
 14ms (13ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 6ms (5ms|0ms)
 3ms (2ms|0ms)

Describing OrchestratorStateCodexModelReceipts resolver-input and resolved-key checks
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing OrchestratorStateCodexModelReceipts ceiling monotonicity and transition checks
 5ms (4ms|1ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 4ms (3ms|0ms)
 6ms (6ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 10ms (10ms|0ms)
 5ms (5ms|0ms)

Describing Single-implementation rule for the Codex deployment resolver
 18ms (17ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexTopologyReceipts.Tests.ps1'
Describing OrchestratorStateCodexTopologyReceipts shape and key checks
 18ms (18ms|1ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)

Describing OrchestratorStateCodexTopologyReceipts resolver-input type checks
 3ms (3ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 4ms (4ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 6ms (6ms|0ms)
 4ms (4ms|0ms)

Describing OrchestratorStateCodexTopologyReceipts resolver and resolved-key checks
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 6ms (6ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)

Describing Single-implementation rule for the Codex topology resolver
 18ms (17ms|1ms)
 15ms (14ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletion.Tests.ps1'
Describing Test-OrchestratorStateCompletionReadiness
 Context model-routing existence gate
 99ms (99ms|1ms)
 48ms (48ms|1ms)
 38ms (38ms|0ms)
 40ms (39ms|1ms)
 Context fail-closed conditions
 15ms (14ms|1ms)
 14ms (13ms|1ms)
 42ms (41ms|0ms)
 Context M2 complexity-assessment pairing
 40ms (39ms|1ms)
 30ms (30ms|0ms)
 33ms (32ms|0ms)
 30ms (30ms|0ms)
 Context PD-2 single emission
 36ms (36ms|1ms)
 25ms (24ms|0ms)
 23ms (23ms|0ms)
 Context M3 reuse of the per-entry validators
 29ms (29ms|0ms)
 25ms (25ms|0ms)
 Context complete-parity composition
 20ms (19ms|0ms)
 17ms (17ms|0ms)
 22ms (22ms|0ms)
 21ms (20ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletionChecks.Tests.ps1'
Describing C1 completion-blocking step statuses
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 4ms (4ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing C2 completion blocked_reason
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)

Describing C3 completion pr_gate
 6ms (6ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 6ms (5ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing C4 completion ci_gate
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)

Describing C5 mandatory route phases
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 5ms (4ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)

Describing C7 preparation terminal contract
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Parity.Tests.ps1'
Describing Issue-adoption fixture corpus discovery
 Context Non-vacuous iteration
 3ms (2ms|1ms)
 6ms (6ms|0ms)
 3ms (2ms|0ms)

Describing Issue-adoption routing-contract parity
 11ms (9ms|1ms)
 24ms (23ms|0ms)
 13ms (12ms|1ms)
 9ms (8ms|1ms)
 10ms (9ms|1ms)
 13ms (12ms|1ms)
 9ms (9ms|1ms)
 9ms (8ms|1ms)
 14ms (13ms|1ms)
 9ms (9ms|1ms)
 9ms (8ms|1ms)
 11ms (10ms|1ms)
 8ms (7ms|1ms)
 8ms (7ms|1ms)
 10ms (10ms|0ms)
 7ms (7ms|0ms)
 6ms (5ms|1ms)
 6ms (6ms|0ms)
 9ms (8ms|1ms)
 8ms (7ms|1ms)
 8ms (7ms|0ms)
 11ms (10ms|1ms)
 8ms (7ms|1ms)
 8ms (8ms|1ms)
 9ms (8ms|0ms)
 7ms (7ms|1ms)
 9ms (8ms|1ms)
 7ms (7ms|0ms)
 10ms (8ms|2ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1'
Describing Issue adoption accepts valid records (AC-6)
  [-] accepts a feature checkpoint waiving potential_to_issue alone
 32ms (32ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:120
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts a feature checkpoint waiving the feature entry tool with a record
 31ms (30ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:127
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts a bug checkpoint waiving the bug entry tool with a record
 32ms (31ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:134
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the same record on the preparation route
 33ms (33ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:140
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented origin value transferred
 34ms (33ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented origin value filed_before_orchestration
 30ms (29ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented origin value epic_decomposition
 30ms (29ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented verification source gh_issue_view
 31ms (31ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented verification source gh_api_get
 19ms (18ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented verification source github_mcp_issue_read
 26ms (26ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

Describing Issue adoption rejects malformed records (AC-7)
  [-] rejects a non-object adoption value of kind string
 25ms (24ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a non-object adoption value of kind integer
 34ms (33ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a non-object adoption value of kind list
 33ms (33ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a null adoption value
 32ms (32ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:173
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an integer issue number
 30ms (30ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:179
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a leading-zero issue number
 20ms (19ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:186
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an issue number that differs from the checkpoint issue-num
 19ms (19ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:193
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an issue URL that does not end with the issue number
 30ms (29ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:200
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an unknown origin
 20ms (19ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:206
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an unknown verification source
 33ms (33ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:211
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an absent verification time
 38ms (38ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:216
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a null verification time
 40ms (40ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:221
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a whitespace-only verification time
 41ms (41ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:226
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects empty evidence
 87ms (86ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:231
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an empty waived list
 42ms (41ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:236
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a malformed waived list of kind string
 46ms (45ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a malformed waived list of kind blank-entry
 41ms (40ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a malformed waived list of kind integer-entry
 41ms (40ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a waived list that omits the issue-creation tool
 45ms (44ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:253
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an invalid potential record when waiving the entry tool
 38ms (37ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:260
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

Describing Issue adoption enforces the closed waivable set (AC-8)
  [-] rejects waiving the feature-folder tool
 40ms (39ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:270
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects waiving the artifact-validation tool
 36ms (36ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:277
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects waiving the feature entry tool on a bug checkpoint
 37ms (36ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:283
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects any waiver on the remediation route
 25ms (25ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:288
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects waiving a tool that holds a successful receipt
 26ms (26ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:293
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a tool listed twice
 24ms (23ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:299
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

Describing Issue adoption fails closed and is presence gated (AC-9, AC-11)
  [-] empties the waived set whenever any error is reported across a fixed grid
 29ms (29ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:329
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] yields no errors and no waivers for a checkpoint without the adoption key
 21ms (21ms|0ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:349
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

Describing Routing contract wiring for issue adoption
 17ms (16ms|1ms)
 7ms (7ms|0ms)
 7ms (7ms|0ms)
 12ms (11ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateModelReceipts.Tests.ps1'
Describing OrchestratorStateModelReceipts complexity_assessments checks (U6.C)
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)

Describing OrchestratorStateModelReceipts model_routing_receipts checks (U6.M)
 6ms (5ms|1ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 8ms (7ms|0ms)
 4ms (4ms|0ms)

Describing Single-implementation rule for the shared reference formulas
 14ms (13ms|1ms)
 17ms (16ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStatePromotionType.Parity.Tests.ps1'
Describing Promotion-type fixture corpus discovery
 Context Non-vacuous iteration
 3ms (2ms|1ms)
 6ms (6ms|0ms)
 3ms (2ms|0ms)

Describing Promotion-type routing-contract parity
 Context Corpus cases
 12ms (10ms|2ms)
 7ms (6ms|1ms)
 8ms (8ms|1ms)
 14ms (13ms|1ms)
 7ms (6ms|1ms)
 6ms (6ms|1ms)
 7ms (7ms|1ms)
 20ms (20ms|1ms)
 16ms (15ms|1ms)
 14ms (12ms|2ms)
 9ms (8ms|1ms)
 15ms (14ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateReceipts.Tests.ps1'
Describing OrchestratorStateReceipts delegation_receipts checks (U5)
 5ms (2ms|2ms)
 7ms (6ms|1ms)
 14ms (14ms|1ms)
 4ms (3ms|1ms)
 5ms (5ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 10ms (9ms|1ms)
 25ms (25ms|1ms)
 6ms (5ms|1ms)
 4ms (4ms|1ms)
 8ms (7ms|1ms)
 10ms (9ms|1ms)

Describing OrchestratorStateReceipts remediation_loop checks (U6.R)
 35ms (29ms|5ms)
 5ms (3ms|2ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 5ms (5ms|1ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 5ms (5ms|1ms)
 7ms (6ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)

Describing OrchestratorStateReceipts human_interaction checks (U6.H)
 11ms (5ms|6ms)
 5ms (4ms|1ms)
 3ms (3ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationAccounting.Tests.ps1'
Describing Get-RemediationReviewVerdict
 26ms (25ms|1ms)
 7ms (7ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 9ms (2ms|8ms)
 2ms (2ms|1ms)
 2ms (1ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (2ms|1ms)
 2ms (1ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 8ms (7ms|1ms)
 3ms (2ms|1ms)
 5ms (5ms|1ms)

Describing Get-OrchestratorStateRemediationAccountingError
 9ms (8ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 5ms (5ms|0ms)
 11ms (2ms|10ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 4ms (4ms|0ms)
 2ms (2ms|0ms)
 5ms (2ms|3ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 4ms (4ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 4ms (4ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Remediation accounting vocabulary
 8ms (7ms|1ms)
 8ms (8ms|0ms)

Describing Remediation accounting through the unconditional block
 12ms (11ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Backcompat.Tests.ps1'
Describing Remediation-loop back-compat corpus discovery
 5ms (4ms|1ms)

Describing Remediation-loop back-compat replay
 12ms (11ms|1ms)
 20ms (19ms|1ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 19ms (18ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 17ms (16ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|0ms)
 15ms (15ms|0ms)
 5ms (4ms|1ms)
 7ms (6ms|0ms)
 17ms (16ms|0ms)
 5ms (4ms|1ms)
 7ms (6ms|1ms)
 24ms (24ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 14ms (13ms|0ms)
 4ms (3ms|0ms)
 5ms (5ms|0ms)
 20ms (19ms|1ms)
 4ms (3ms|1ms)
 5ms (5ms|0ms)
 21ms (21ms|1ms)
 3ms (3ms|0ms)
 5ms (5ms|0ms)
 22ms (22ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|0ms)
 16ms (16ms|0ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Parity.Tests.ps1'
Describing Remediation-loop corpus discovery
 4ms (3ms|1ms)
 4ms (4ms|0ms)

Describing Remediation-loop corpus parity
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 8ms (8ms|0ms)
 5ms (5ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 5ms (4ms|0ms)
 9ms (8ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 5ms (4ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 6ms (4ms|1ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingContract.Tests.ps1'
Describing C6 terminal rows (matrix, route selection, route membership)
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing C6 declared-list equality rows
 5ms (4ms|1ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 6ms (6ms|0ms)

Describing C6 receipt-presence rows
 5ms (4ms|1ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 6ms (3ms|3ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)

Describing C6 empty-list rows, both message variants
 4ms (4ms|1ms)
 6ms (6ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)

Describing C6 lifecycle-operation rows
 5ms (4ms|1ms)
 6ms (6ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 6ms (6ms|0ms)

Describing C6 bug-promotion tool substitution
 5ms (5ms|1ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingMatrix.Tests.ps1'
Describing Pinned routing-matrix constants match config/orchestration-routing.json
 6ms (5ms|1ms)
 5ms (4ms|0ms)
 3ms (3ms|0ms)
 11ms (10ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)

Describing Routing-matrix route lookup
 4ms (3ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Route gate predicates
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)

Describing Route required-name list accessor
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Describing Checkpoint route-value resolution
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateUnconditional.Tests.ps1'
Describing Unconditional aggregation: fully valid checkpoint
 4ms (3ms|1ms)

Describing Unconditional aggregation: base-presence family (U2-U4)
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)

Describing Unconditional aggregation: delegation-receipt family (U5)
 3ms (3ms|1ms)
 7ms (7ms|0ms)
 3ms (3ms|0ms)

Describing Unconditional aggregation: each optional family surfaces
 5ms (4ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)

Describing Unconditional aggregation: key-gated semantics
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\Invoke-ParallelDriftDetection.Tests.ps1'
Describing Invoke-ParallelDriftDetection.ps1
 Context Parameter surface
 11ms (10ms|1ms)
 12ms (11ms|0ms)
 Context With mocked file and clock seams
 10ms (10ms|0ms)
 6ms (6ms|0ms)
 11ms (11ms|0ms)
 16ms (16ms|0ms)
 15ms (15ms|0ms)
 104ms (103ms|0ms)
 40ms (39ms|0ms)
 29ms (28ms|0ms)
 25ms (24ms|0ms)
 22ms (21ms|0ms)
 27ms (27ms|0ms)
 39ms (39ms|0ms)
 Context JSON conversion
 7ms (6ms|1ms)
 20ms (19ms|0ms)
 3ms (3ms|0ms)
 7ms (7ms|0ms)
 5ms (4ms|0ms)
 Context With the real file seam
 30ms (30ms|1ms)
 28ms (27ms|0ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\ParallelDrift.Manifest.Tests.ps1'
Describing Parallel-drift core.json manifest membership
 3ms (2ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\ParallelDrift.Parity.Tests.ps1'
Describing Parallel drift parity corpus
 4ms (4ms|1ms)
 6ms (6ms|0ms)
 16ms (15ms|0ms)
 6ms (6ms|0ms)
 6ms (6ms|0ms)
 33ms (33ms|0ms)
 23ms (23ms|0ms)
 33ms (32ms|1ms)
 29ms (29ms|1ms)
 33ms (32ms|1ms)
 26ms (26ms|1ms)
 43ms (42ms|1ms)
 22ms (21ms|1ms)
 11ms (10ms|1ms)
 12ms (11ms|1ms)
 36ms (35ms|1ms)
 21ms (20ms|1ms)
 27ms (27ms|1ms)
 26ms (25ms|1ms)
 30ms (29ms|1ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\ParallelDrift.Tests.ps1'
Describing ParallelDrift.psm1
 15ms (14ms|1ms)
 17ms (17ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 5ms (5ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 8ms (8ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 12ms (12ms|0ms)
 4ms (3ms|0ms)
 9ms (9ms|0ms)
 13ms (13ms|0ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\ParallelDriftHalt.Tests.ps1'
Describing ParallelDriftHalt.psm1
 3ms (2ms|1ms)
 4ms (4ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 11ms (10ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 4ms (4ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 5ms (5ms|0ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Manifest.Tests.ps1'
Describing Project-file merge core.json manifest membership
 Context Library coverage
 2ms (1ms|1ms)
 5ms (5ms|0ms)
 Context Bundled payload parity
 4ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Tests.ps1'
Describing Get-ConflictHunk
 12ms (11ms|1ms)
 4ms (3ms|0ms)
 1ms (1ms|0ms)

Describing Merge-ConflictedText keyed union
 11ms (11ms|1ms)
 4ms (4ms|0ms)
 2ms (2ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 11ms (11ms|0ms)
 5ms (4ms|0ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 10ms (10ms|0ms)
 8ms (7ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 6ms (6ms|0ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)

Describing Test-NeverDropPostCondition
 12ms (12ms|1ms)
 7ms (7ms|0ms)
 4ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\project-file-merge\ProjectFileMergeGrammar.Tests.ps1'
Describing Get-ProjectFileKind
 3ms (3ms|1ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)

Describing Get-MergeableUnit
 3ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)

Describing Compare-UnitVersion
 2ms (2ms|1ms)
 2ms (1ms|0ms)
 5ms (2ms|3ms)

Running tests from 'tests\scripts\claude-lib\project-file-merge\Resolve-MergeableConflict.Tests.ps1'
Describing Invoke-MergeableConflictResolution
 52ms (51ms|1ms)
 9ms (8ms|0ms)
 10ms (10ms|0ms)
 11ms (11ms|0ms)
 13ms (13ms|0ms)
 11ms (11ms|0ms)

Describing Byte-level seams
 7ms (6ms|1ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 8ms (7ms|0ms)

Running tests from 'tests\scripts\claude-lib\requirements\GeneratedDocumentCounters.Tests.ps1'
Describing Get-NamedSectionCheckboxCount
 5ms (4ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1'
Describing Get-EpicPrCreationReadinessFailure
 5ms (5ms|1ms)
 5ms (4ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)

Describing Get-EpicCommandLegReadinessFailure
 5ms (4ms|1ms)
 4ms (3ms|0ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint run-target location
 61ms (60ms|1ms)
 13ms (13ms|0ms)
 29ms (28ms|0ms)
 17ms (17ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint epic-scope matches
 23ms (23ms|1ms)
 10ms (10ms|0ms)
 15ms (15ms|0ms)
 15ms (15ms|0ms)
 16ms (16ms|0ms)

Describing Resolve-EpicScopeCheckpoint fail-closed non-matches
 10ms (10ms|1ms)
 13ms (13ms|0ms)
 12ms (12ms|0ms)
 9ms (9ms|0ms)
 9ms (9ms|0ms)
 19ms (18ms|0ms)
 13ms (13ms|0ms)
 8ms (8ms|0ms)
 10ms (10ms|0ms)

Describing Resolve-EpicScopeCheckpoint checkpoint path composition
 13ms (12ms|1ms)
 11ms (11ms|0ms)
 12ms (12ms|0ms)

Describing EpicScopeResolution read seams
 8ms (8ms|1ms)
 13ms (13ms|0ms)
 7ms (7ms|0ms)
 7ms (7ms|0ms)
 11ms (10ms|0ms)

Describing Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2)
 25ms (24ms|1ms)
 17ms (17ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1'
Describing Resolve-WorktreeItemTargetByPrNumber
 25ms (25ms|1ms)
 10ms (9ms|0ms)
 9ms (8ms|0ms)
 8ms (8ms|0ms)
 23ms (22ms|0ms)
 2ms (2ms|0ms)
 8ms (8ms|0ms)
 7ms (7ms|0ms)
 5ms (5ms|0ms)
 5ms (4ms|0ms)
 18ms (18ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1'
Describing WorktreeItemResolution checkpoint path
 2ms (1ms|1ms)
 7ms (7ms|0ms)
 1ms (1ms|0ms)

Describing WorktreeItemResolution issue signals
 5ms (5ms|0ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 5ms (2ms|3ms)

Describing WorktreeItemResolution checkpoint reader
 5ms (5ms|0ms)
 9ms (9ms|0ms)

Describing WorktreeItemResolution liveness seam
 18ms (17ms|1ms)
 15ms (14ms|0ms)

Describing WorktreeItemResolution target resolution
 8ms (7ms|1ms)
 11ms (11ms|0ms)
 6ms (6ms|0ms)
 7ms (7ms|0ms)
 13ms (13ms|0ms)
 9ms (9ms|0ms)
 9ms (9ms|0ms)
 10ms (10ms|0ms)
 7ms (6ms|0ms)
 8ms (8ms|0ms)
 11ms (10ms|0ms)
 5ms (5ms|0ms)
 8ms (8ms|0ms)
 6ms (6ms|0ms)
 4ms (4ms|0ms)
 15ms (15ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1'
Describing WorktreeResolution core.json manifest membership
 5ms (5ms|1ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 4ms (4ms|0ms)
 2ms (1ms|0ms)
 4ms (3ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 5ms (5ms|0ms)

Describing WorktreeResolution bundle mirror byte identity
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1'
Describing WorktreeResolution seam default bodies
 4ms (3ms|1ms)
 4ms (3ms|0ms)
 5ms (5ms|0ms)

Describing WorktreeResolution
 Context path normalisation
 3ms (2ms|1ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (1ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 3ms (2ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 Context root marker
 11ms (11ms|1ms)
 11ms (10ms|0ms)
 7ms (6ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context upward ascent
 6ms (5ms|1ms)
 9ms (9ms|0ms)
 6ms (5ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 2ms (2ms|0ms)
 Context worktree enumeration
 14ms (13ms|0ms)
 7ms (7ms|0ms)
 11ms (11ms|0ms)
 6ms (6ms|0ms)
 6ms (5ms|0ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 6ms (6ms|0ms)
 7ms (7ms|0ms)
 7ms (7ms|0ms)
 4ms (4ms|0ms)
 6ms (6ms|0ms)
 8ms (8ms|0ms)
 Context repo-relative normalisation
 19ms (10ms|9ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 5ms (5ms|0ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)
 Context reason code
 2ms (1ms|0ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 15ms (15ms|1ms)
 7ms (7ms|0ms)
 12ms (12ms|0ms)
 8ms (7ms|0ms)
 6ms (6ms|0ms)
 6ms (5ms|0ms)
 6ms (6ms|0ms)
 7ms (7ms|0ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 7ms (7ms|0ms)
 5ms (5ms|0ms)
 6ms (6ms|0ms)
 8ms (8ms|0ms)

Describing Resolve-WorktreeOperandTarget
 11ms (10ms|1ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 7ms (7ms|0ms)

Describing Run resolver result contract
 14ms (13ms|1ms)
 13ms (12ms|0ms)
 12ms (12ms|0ms)
 9ms (9ms|0ms)
 22ms (22ms|0ms)

Describing Run resolver purity (parse-tree scan)
 20ms (19ms|1ms)
 17ms (17ms|0ms)
 23ms (23ms|0ms)

Describing Resolver module exports
 3ms (2ms|1ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1'
Describing Find-WorktreeRunIdentitySignal
 4ms (3ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 6ms (5ms|0ms)
 3ms (2ms|0ms)

Describing Get-WorktreeRunCheckpointText
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 15ms (15ms|0ms)

Describing Get-WorktreeRunCheckpointPath
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1'
Describing Resolve-WorktreeEpicTarget
 15ms (14ms|1ms)
 9ms (9ms|0ms)
 7ms (7ms|0ms)
 6ms (6ms|0ms)
 7ms (7ms|0ms)
 7ms (7ms|0ms)
 11ms (10ms|0ms)
 8ms (8ms|0ms)
 7ms (6ms|0ms)
 7ms (7ms|0ms)
 4ms (4ms|0ms)
 6ms (5ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)

Describing Resolve-WorktreeParallelTarget
 6ms (5ms|1ms)
 6ms (6ms|0ms)
 9ms (7ms|2ms)
 8ms (7ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1'
Describing WorktreeTargetResolution
 Context result factory and field invariants
 5ms (4ms|1ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 5ms (5ms|0ms)
 6ms (6ms|0ms)
 18ms (17ms|0ms)
 6ms (6ms|0ms)
 Context signal extraction
 2ms (1ms|1ms)
 2ms (2ms|0ms)
 1ms (0ms|0ms)
 2ms (2ms|0ms)
 1ms (0ms|0ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 Context required matrix
 20ms (19ms|1ms)
 9ms (8ms|0ms)
 8ms (8ms|0ms)
 12ms (12ms|0ms)
 8ms (8ms|0ms)
 5ms (5ms|0ms)
 10ms (10ms|0ms)
 5ms (5ms|0ms)
 10ms (10ms|0ms)
 8ms (8ms|0ms)
 8ms (8ms|0ms)
 5ms (5ms|0ms)
 Context ambiguity, no target, and Ruling B
 14ms (13ms|1ms)
 8ms (8ms|0ms)
 5ms (5ms|0ms)
 8ms (7ms|0ms)
 10ms (10ms|0ms)
 10ms (10ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 15ms (15ms|0ms)
 9ms (9ms|0ms)
 16ms (16ms|0ms)
 4ms (4ms|0ms)
 21ms (20ms|0ms)
 Context path composition
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
Tests completed in 82.32s
Tests Passed: 2302, 
Failed: 38, 
Skipped: 1, 
Inconclusive: 0, 

NotRun: 0
TotalCount=2341
PassedCount=2302
FailedCount=38
FAILED: Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving potential_to_issue alone
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption accepts valid records (AC-6).accepts a feature checkpoint waiving the feature entry tool with a record
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption accepts valid records (AC-6).accepts a bug checkpoint waiving the bug entry tool with a record
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption accepts valid records (AC-6).accepts the same record on the preparation route
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented origin value transferred
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented origin value filed_before_orchestration
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented origin value epic_decomposition
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_issue_view
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented verification source gh_api_get
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption accepts valid records (AC-6).accepts the documented verification source github_mcp_issue_read
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind string
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind integer
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a non-object adoption value of kind list
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a null adoption value
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects an integer issue number
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a leading-zero issue number
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects an issue number that differs from the checkpoint issue-num
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects an issue URL that does not end with the issue number
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects an unknown origin
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects an unknown verification source
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects an absent verification time
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a null verification time
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a whitespace-only verification time
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects empty evidence
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects an empty waived list
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind string
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind blank-entry
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a malformed waived list of kind integer-entry
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects a waived list that omits the issue-creation tool
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption rejects malformed records (AC-7).rejects an invalid potential record when waiving the entry tool
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature-folder tool
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the artifact-validation tool
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving the feature entry tool on a bug checkpoint
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects any waiver on the remediation route
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects waiving a tool that holds a successful receipt
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption enforces the closed waivable set (AC-8).rejects a tool listed twice
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption fails closed and is presence gated (AC-9, AC-11).empties the waived set whenever any error is reported across a fixed grid
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
FAILED: Issue adoption fails closed and is presence gated (AC-9, AC-11).yields no errors and no waivers for a checkpoint without the adoption key
FAILED-FILE: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
```

Baseline comparison: the 38 FAILED lines are identical to the P0-T22 baseline failure set (sorted diff against evidence/baseline/pester-claude-lib.2026-10-08T23-43.md exits 0); TotalCount 2341 = BASE_CLIB 2329 + 12. No FAILED-CONTAINER line. WorktreeResolution.Manifest.Tests.ps1 passes (AC-41).
