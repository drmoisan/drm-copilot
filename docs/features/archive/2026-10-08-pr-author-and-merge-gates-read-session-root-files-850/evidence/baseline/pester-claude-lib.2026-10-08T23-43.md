# P0-T22 Pester baseline folder tests/scripts/claude-lib

Timestamp: 2026-10-08T23-43
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib
EXIT_CODE: 0
Output Summary:
  Failed: 38, 
  TotalCount=2329
  PassedCount=2290
  FailedCount=38
  BASE_CLIB: 2329
  A18 (copied verbatim from evidence/baseline/pester-set-pra.2026-10-08T23-39.md; not re-run):
  DECISION=deny
  REASON=EPIC_BASE_BRANCH_MISMATCH: `gh pr create` must pass `--base epic/enforcement-hook-precision-integration` (`epic_context.integration_branch`) under `epic_mode`; the command does not carry a matching `--base` argument.
  DECISION-WITHOUT-CHECKPOINT=allow
  Rule EE: applied; the folder contains no EE-ROWS suite, so nothing is exempt (no ENV-EPIC-FAILED line).
  Baseline failure set (P0-T22): the 38 FAILED lines listed below, all in tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 (not a BASELINE-GREEN suite; P0-T22 carries no stop on failures). Failure message for each: CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program. Pre-existing on this tree; not caused by this plan (no production edit has been made).
  Baseline container set (P0-T22): empty
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

Starting discovery in 84 files.
Discovery found 2329 tests in 3.91s.
Running tests.

Running tests from 'tests\scripts\claude-lib\ClaudeLibModuleConvention.Tests.ps1'
Describing Claude library module conventions
 59ms (35ms|24ms)
 211ms (210ms|1ms)
 126ms (125ms|1ms)
 197ms (196ms|1ms)
 830ms (830ms|1ms)
 83ms (82ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Conflict.Tests.ps1'
Describing Test-BlastRadiusConflict result shape
 Context The documented return contract
 118ms (112ms|6ms)
 22ms (21ms|1ms)
 38ms (37ms|1ms)
 13ms (12ms|1ms)
 84ms (83ms|1ms)

Describing Test-BlastRadiusConflict disjuncts in isolation
 Context path_overlap
 16ms (13ms|3ms)
 20ms (19ms|1ms)
 10ms (9ms|1ms)
 Context module_overlap, shared_surface_overlap, and contract_dependency
 13ms (11ms|2ms)
 11ms (10ms|1ms)
 11ms (10ms|1ms)
 11ms (10ms|1ms)
 Context Mechanically-mergeable paths (issue #643)
 46ms (44ms|2ms)
 13ms (12ms|1ms)
 17ms (16ms|1ms)

Describing Test-BlastRadiusConflict fail-closed behavior
 Context Undecidable glob pairs
 13ms (11ms|3ms)
 10ms (9ms|1ms)
 Context Empty radii
 11ms (10ms|2ms)
 31ms (12ms|20ms)

Describing Test-BlastRadiusConflict reason ordering
 Context The fixed kind order
 14ms (12ms|2ms)
 10ms (9ms|1ms)
 11ms (10ms|1ms)

Describing Contention relation invariants
 Context Symmetry
 19ms (17ms|2ms)
 11ms (11ms|1ms)
 Context Monotonicity
 16ms (14ms|2ms)
 13ms (12ms|1ms)
 Context Self-conflict and determinism
 14ms (12ms|2ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 6ms (6ms|1ms)
 29ms (28ms|1ms)
 12ms (11ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.HistoricalRuns.Tests.ps1'
Describing Blast-radius historical runs
 599ms (596ms|3ms)
 1.96s (1.96s|1ms)
 1.21s (1.21s|1ms)
 1.87s (1.87s|1ms)
 5.85s (5.85s|1ms)
 2.2s (2.2s|1ms)
 7.6s (7.6s|1ms)
 25.49s (25.49s|1ms)
 8.74s (8.74s|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.KeyPartition.Tests.ps1'
Describing Committed blast-radius truth table cross-copy key partition
 Context Cross-copy key partition
 10ms (9ms|1ms)
 6ms (6ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 10ms (10ms|0ms)
 17ms (17ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Manifest.Tests.ps1'
Describing Blast-radius core.json manifest membership
 Context Library coverage
 3ms (2ms|1ms)
 4ms (3ms|0ms)
 6ms (5ms|0ms)
 Context Bundled payload parity
 6ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Parity.Tests.ps1'
Describing Blast-radius fixture corpus discovery
 Context Non-vacuous iteration
 7ms (5ms|2ms)
 6ms (5ms|0ms)
 2ms (2ms|0ms)

Describing Blast-radius derivation and validation parity
 Context Derived radius
 36ms (34ms|3ms)
 9ms (8ms|0ms)
 6ms (6ms|0ms)
 5ms (4ms|0ms)
 6ms (5ms|0ms)
 7ms (6ms|0ms)
 10ms (6ms|4ms)
 4ms (4ms|0ms)
 5ms (5ms|1ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 8ms (8ms|0ms)
 8ms (7ms|0ms)
 7ms (7ms|0ms)
 6ms (5ms|0ms)
 7ms (7ms|0ms)
 6ms (5ms|0ms)
 6ms (6ms|0ms)
 10ms (7ms|4ms)
 7ms (6ms|0ms)
 Context Validation findings
 34ms (34ms|1ms)
 17ms (17ms|1ms)
 12ms (12ms|1ms)
 11ms (10ms|0ms)
 9ms (9ms|0ms)
 10ms (10ms|0ms)
 19ms (19ms|0ms)
 8ms (7ms|0ms)
 9ms (9ms|0ms)
 12ms (12ms|0ms)
 8ms (7ms|0ms)
 11ms (11ms|0ms)
 10ms (9ms|1ms)
 10ms (10ms|0ms)
 12ms (11ms|0ms)
 11ms (11ms|0ms)
 14ms (13ms|1ms)
 6ms (5ms|0ms)
 6ms (6ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)

Describing Blast-radius contention parity
 Context Conflict verdict
 9ms (8ms|1ms)
 9ms (8ms|1ms)
 5ms (4ms|1ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 8ms (8ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 7ms (4ms|2ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 5ms (5ms|1ms)
 Context Conflict reasons
 10ms (9ms|1ms)
 6ms (5ms|1ms)
 5ms (5ms|1ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 7ms (7ms|1ms)
 6ms (5ms|1ms)
 6ms (6ms|1ms)
 7ms (7ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)
 7ms (5ms|2ms)

Describing Verification-integrity regression (issue #489)
 Context Before state
 524ms (523ms|1ms)
 Context After state
 508ms (507ms|1ms)
 271ms (271ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Regression452.Tests.ps1'
Describing BlastRadius regression corpus for issue 452
 Context Corpus contract
 13ms (11ms|2ms)
 155ms (155ms|0ms)
 7ms (7ms|0ms)
 14ms (14ms|1ms)
 23ms (23ms|1ms)
 4ms (4ms|0ms)
 7ms (7ms|0ms)
 Context Detection-level verdicts
 38ms (37ms|1ms)
 25ms (25ms|0ms)
 20ms (19ms|0ms)
 16ms (15ms|0ms)
 15ms (15ms|0ms)
 4ms (4ms|1ms)
 3ms (3ms|0ms)
 4ms (4ms|1ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 11ms (3ms|8ms)
 4ms (3ms|0ms)
 4ms (3ms|1ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 Context Bundled configuration parity
 4ms (3ms|1ms)
 Context Tolerance branch
   [!] keeps a scheduling edge for every must-conflict case at the strictest tolerance is skipped, because  because Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.,
 13ms (11ms|2ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Tests.ps1'
Describing Get-BlastRadius record shape
 Context Key set and source vocabulary
 9ms (8ms|1ms)
 7ms (6ms|0ms)
 6ms (6ms|0ms)
 7ms (6ms|0ms)
 9ms (8ms|1ms)
 8ms (8ms|1ms)
 10ms (9ms|0ms)
 4ms (4ms|0ms)

Describing Get-BlastRadius path derivation
 Context The feature-folder append
 7ms (6ms|1ms)
 7ms (6ms|0ms)
 7ms (7ms|0ms)
 Context Plan and spec contributions
 9ms (8ms|1ms)
 8ms (7ms|1ms)
 9ms (8ms|1ms)
 14ms (14ms|1ms)

Describing Get-BlastRadius module and surface resolution
 Context Modules
 10ms (8ms|2ms)
 7ms (6ms|1ms)
 Context Shared surfaces
 9ms (8ms|1ms)
 9ms (9ms|1ms)
 9ms (8ms|1ms)
 9ms (8ms|1ms)
 Context Contracts
 10ms (9ms|2ms)
 8ms (7ms|1ms)

Describing Get-BlastRadiusFromObservedPaths
 Context Observed-source radii
 10ms (8ms|2ms)
 7ms (6ms|1ms)
 8ms (7ms|2ms)
 6ms (6ms|1ms)
 8ms (7ms|1ms)
 6ms (6ms|1ms)

Describing Get-NormalizedDeclaredRadius
 Context Re-filtering a recorded radius (issue #489)
 15ms (13ms|2ms)
 14ms (13ms|1ms)
 18ms (17ms|1ms)

Describing Exported facade surface
 Context Spec PowerShell surface
 10ms (8ms|2ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 3ms (1ms|1ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 4ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.TruthTable.Tests.ps1'
Describing Committed blast-radius truth table shape
 Context Schema version
 3ms (2ms|1ms)
 Context Module map
 3ms (3ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 Context Over-breadth fraction
 5ms (4ms|1ms)
 Context Shared surfaces
 3ms (2ms|1ms)
 4ms (3ms|0ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 Context Read-by-mandate exclusions
 4ms (3ms|1ms)
 6ms (6ms|0ms)
 3ms (2ms|0ms)
 Context Non-vacuity floor helper
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Location-bucket modules
 3ms (2ms|1ms)
 Context Disjoint work items
 27ms (26ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.Validation.Tests.ps1'
Describing ConvertTo-NormalizedBlastRadius
 Context Construction invariants
 6ms (5ms|1ms)
 5ms (5ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 5ms (4ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)

Describing Test-BlastRadius rule V1
 Context Coverage of plan paths
 7ms (6ms|1ms)
 7ms (7ms|0ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 6ms (5ms|0ms)
 14ms (14ms|0ms)

Describing Test-BlastRadius rule V2
 Context Shared-surface enumeration
 6ms (5ms|1ms)
 4ms (4ms|0ms)
 6ms (6ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)

Describing Test-BlastRadius rule V3
 Context The over-breadth boundary
 6ms (4ms|1ms)
 6ms (6ms|0ms)
 9ms (9ms|0ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)
 6ms (6ms|1ms)

Describing Test-BlastRadius finding ordering and determinism
 Context Cross-rule ordering
 10ms (8ms|1ms)
 12ms (12ms|0ms)
 9ms (8ms|0ms)
 8ms (7ms|0ms)
 5ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusConfig.Tests.ps1'
Describing Get-RequiredText
 Context Accepted values
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 Context Rejected values
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)

Describing Get-RequiredStringList
 Context Accepted collections
 13ms (11ms|1ms)
 2ms (2ms|0ms)
 Context Rejected collections
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)

Describing Get-RequiredMapping
 Context Accepted shapes
 3ms (2ms|1ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 Context Rejected shapes
 4ms (4ms|1ms)
 4ms (3ms|0ms)

Describing Get-ConfigStringList
 Context Reading optional list entries
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Get-ConfigRootSurface
 Context Reading the separator-free subset
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)

Describing Get-ConfigModuleEntry
 Context Reading the module map
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 2ms (2ms|0ms)
 5ms (4ms|0ms)

Describing Get-ConfigOverBreadthFraction
 Context Accepted thresholds
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 Context Rejected thresholds
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 5ms (4ms|1ms)
 7ms (5ms|2ms)
 4ms (2ms|2ms)
 2ms (1ms|1ms)

Describing Get-ConfigMandateRead
 Context Optional read-by-mandate list
 9ms (7ms|2ms)
 3ms (2ms|0ms)
 6ms (5ms|1ms)
 6ms (6ms|1ms)

Describing Resolve-BlastRadiusModule
 Context Module resolution
 6ms (4ms|2ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (5ms|1ms)
 4ms (4ms|1ms)

Describing Resolve-BlastRadiusSharedSurface
 Context Surface membership
 6ms (4ms|2ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)

Describing Committed truth table
 Context config/blast-radius.json shape
 7ms (6ms|2ms)
 4ms (4ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.OverlappingPairs.Tests.ps1'
Describing Get-OverlappingPathPair (issue #776)
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 5ms (5ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 41ms (41ms|0ms)
 38ms (37ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.PathOverlap.Tests.ps1'
Describing Get-SmallestPathOverlap record-form parity (issue #776)
 33ms (32ms|1ms)
 30ms (29ms|1ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 5ms (5ms|0ms)
 3ms (3ms|0ms)

Describing Get-SmallestPathOverlap minimum tracking (issue #776)
 4ms (4ms|1ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 5ms (4ms|0ms)
 2ms (2ms|0ms)

Describing ConvertTo-PathOverlapRecord (issue #776)
 13ms (12ms|1ms)
 5ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.Tests.ps1'
Describing Get-ConfigMergeablePath
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)

Describing Test-MergeablePath
 3ms (2ms|1ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)

Describing Get-NonMergeablePathEntry
 5ms (4ms|1ms)
 2ms (2ms|0ms)

Describing Relocated overlap helpers
 3ms (3ms|1ms)
 2ms (2ms|0ms)

Describing Test-BlastRadiusConflict equivalence
 13ms (13ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Path.Tests.ps1'
Describing Get-PathTokenKind
 Context Known top-level segments
 7ms (5ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|1ms)
 2ms (1ms|1ms)
 7ms (6ms|0ms)
 2ms (1ms|0ms)
 Context Directory-shaped token rejection (issue #489)
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 Context Cross-corpus documentation-glob rejection (issue #489)
 6ms (5ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 3ms (2ms|0ms)
 3ms (3ms|1ms)
 Context Extension fallback rule
 8ms (3ms|5ms)
 3ms (3ms|1ms)
 4ms (4ms|1ms)
 Context Glob classification
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 Context Rejected tokens
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 Context Configured separator-free root surfaces
 6ms (5ms|2ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 6ms (5ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)

Describing Get-PathFromLine and Get-PlanPaths
 Context Aggregation across lines
 6ms (4ms|2ms)
 4ms (3ms|1ms)
 Context Whole-plan extraction
 8ms (6ms|2ms)
 4ms (3ms|1ms)

Describing Get-ContractIdentifier letterless rejection (issue #489)
 9ms (6ms|2ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 5ms (4ms|1ms)

Describing Get-ContractIdentifier
 Context Qualifying sections
 12ms (10ms|2ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 Context Exclusions
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)

Describing Get-OrdinalSortedEntry
 Context Normalization
 5ms (3ms|2ms)
 4ms (4ms|1ms)
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Tests.ps1'
Describing ConvertTo-NormalizedLine
 Context Line-ending styles
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 9ms (8ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 Context Degenerate input
 4ms (3ms|1ms)
 3ms (2ms|0ms)

Describing Get-PlanLineScan
 Context Task and phase line parsing
 5ms (3ms|2ms)
 3ms (3ms|0ms)
 1ms (1ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)

Describing Get-InlineCodeToken
 Context Span extraction
 4ms (2ms|1ms)
 3ms (3ms|0ms)
 3ms (2ms|1ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.RegexCache.Tests.ps1'
Describing Glob regex cache (issue #776)
 6ms (5ms|1ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 5ms (4ms|0ms)

Describing Test-GlobMatch cached and uncached agreement (issue #776)
 9ms (8ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Get-LiteralPrefix single-scan fast path (issue #776)
 5ms (3ms|1ms)
 1ms (1ms|0ms)
 12ms (2ms|10ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.Tests.ps1'
Describing Test-GlobEntry
 Context Wildcard detection
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)

Describing Get-ConcreteEntry
 Context Filtering
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Test-GlobMatch
 Context The supported fnmatch subset
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Test-PathSubsumed
 Context The three coverage rules
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Get-LiteralPrefix
 Context Prefix extraction
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Test-EntryOverlap
 Context Concrete against concrete
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 Context Glob against concrete
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Glob against glob, decided conservatively
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Directory containment, added by issue #452
 5ms (4ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 4ms (4ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 Context Monotonicity, the fail-closed invariant
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)

Describing Get-OrdinalSmallestEntry
 Context Ordinal minimum
 3ms (2ms|1ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusNormalization.Tests.ps1'
Describing Test-MandateRead
 Context Exclusion rules
 4ms (2ms|1ms)
 4ms (4ms|0ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|0ms)

Describing Get-NonMandateReadEntry
 Context Collection filtering
 5ms (4ms|2ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)

Describing Read-by-mandate exclusion through the facade (issue #489)
 Context Derivation harvest
 12ms (10ms|1ms)
 10ms (10ms|1ms)
 Context Symmetric exclusion
 15ms (14ms|1ms)

Describing Get-NormalizedDeclaredRadius placeholder stripping (issue #502)
 Context Retrospective cleaning of an already-recorded radius
 13ms (12ms|1ms)
 10ms (9ms|1ms)

Describing Placeholder-only overlap after normalization (issue #502)
 Context Pair-level regression for the placeholder guard
 33ms (31ms|2ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.PairCost.Tests.ps1'
Describing Get-BlastRadiusPairCost equivalence (issue #776)
 15ms (12ms|3ms)
 6ms (5ms|1ms)
 5ms (5ms|1ms)
 5ms (5ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 7ms (6ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.Tests.ps1'
Describing BlastRadiusScheduling
 Context Edge rule terms
 33ms (32ms|1ms)
 12ms (12ms|1ms)
 8ms (8ms|0ms)
 11ms (11ms|0ms)
 25ms (25ms|0ms)
 8ms (7ms|1ms)
 12ms (12ms|1ms)
 7ms (7ms|0ms)
 4ms (4ms|0ms)
 22ms (21ms|0ms)
 20ms (19ms|0ms)
 7ms (6ms|0ms)
 Context conflict_tolerance reader
 9ms (8ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 2ms (2ms|1ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 6ms (5ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 Context Scheduling fixtures
 39ms (38ms|1ms)
 68ms (67ms|1ms)
 74ms (74ms|1ms)
 80ms (80ms|0ms)
 30ms (29ms|1ms)
 45ms (45ms|0ms)
 Context Strict identity
 31ms (30ms|1ms)
 15ms (15ms|1ms)
 17ms (17ms|0ms)
 11ms (10ms|0ms)
 10ms (9ms|1ms)
 18ms (17ms|0ms)
 14ms (13ms|0ms)
 20ms (19ms|0ms)
 15ms (14ms|0ms)
 20ms (19ms|0ms)
 19ms (19ms|0ms)
 10ms (9ms|0ms)
 20ms (19ms|0ms)
 15ms (14ms|0ms)
 12ms (11ms|0ms)
 Context Ordering and symmetry
 51ms (51ms|1ms)
 157ms (157ms|0ms)
 7ms (7ms|0ms)
 5ms (5ms|0ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusTokenShape.Tests.ps1'
Describing Placeholder-marker token-shape rejection (issue #502)
 Context Paired predicate and classifier assertions, one case per marker
 5ms (4ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 Context Marker position and discrimination
 4ms (3ms|1ms)
 2ms (2ms|0ms)
 Context Degenerate tokens must not throw
 4ms (3ms|1ms)
 4ms (1ms|3ms)
 1ms (1ms|0ms)

Describing Test-MultipleFeatureFolderSpan after relocation (issue #489 behavior preserved)
 Context Cross-corpus documentation globs
 4ms (3ms|1ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 Context Module export surface after relocation
 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadiusWriteIntent.Tests.ps1'
Describing BlastRadiusWriteIntent
 Context Rules W1 through W6
 6ms (5ms|1ms)
 15ms (15ms|0ms)
 4ms (3ms|0ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 3ms (2ms|0ms)
 7ms (7ms|0ms)
 8ms (7ms|0ms)
 3ms (3ms|0ms)
 Context Flag behavior and selector
 25ms (25ms|1ms)
 16ms (15ms|0ms)
 22ms (22ms|0ms)
 88ms (88ms|0ms)
 13ms (13ms|0ms)
 341ms (341ms|0ms)
 Context Committed fixtures and readers
 11ms (10ms|1ms)
 7ms (7ms|0ms)
 5ms (5ms|0ms)
 10ms (10ms|0ms)
 5ms (5ms|0ms)
 6ms (6ms|0ms)
 50ms (50ms|0ms)
 28ms (27ms|0ms)
 5ms (5ms|0ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)
 7ms (6ms|0ms)

Running tests from 'tests\scripts\claude-lib\ci-gate\CiGate.Manifest.Tests.ps1'
Describing CiGate core.json manifest membership
 5ms (4ms|1ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\ci-gate\Invoke-CiGateParser.Tests.ps1'
Describing Invoke-CiGateParser.ps1
 Context conclusion derivation across bucket combinations
 7ms (6ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 Context fail-fast error handling
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 Context deterministic verified_at via injected clock
 2ms (2ms|1ms)
 Context field passthrough
 4ms (3ms|1ms)
 2ms (2ms|0ms)
 Context JSON emission
 8ms (7ms|1ms)
 Context Get-CiGateConclusion pure helper
 2ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\cleanup-manifest\CleanupWorktreeManifest.Tests.ps1'
Describing CleanupWorktreeManifest
 Context vocabulary constants
 9ms (7ms|2ms)
 4ms (4ms|0ms)
 Context path normalization
 3ms (3ms|1ms)
 Context removal record lookup
 17ms (8ms|10ms)
 3ms (2ms|0ms)
 Context allow predicate
 60ms (60ms|1ms)
 Context checkpoint exclusion
 4ms (4ms|1ms)

Running tests from 'tests\scripts\claude-lib\codex-routing\CodexDeployment.Parity.Tests.ps1'
Describing Resolve-CodexDeployment base profile table
 6ms (5ms|1ms)
 14ms (14ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Resolve-CodexDeployment agent family resolution
 3ms (2ms|1ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)

Describing Resolve-CodexDeployment C3 overlay rule
 4ms (3ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)

Describing Resolve-CodexDeployment forced personas
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)

Describing Resolve-CodexDeployment invalid-input throw surface
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 7ms (7ms|0ms)

Describing Resolve-CodexDeployment model availability
 4ms (3ms|1ms)
 4ms (4ms|0ms)
 7ms (7ms|0ms)

Running tests from 'tests\scripts\claude-lib\codex-routing\CodexRouting.Manifest.Tests.ps1'
Describing CodexRouting core.json manifest membership
 5ms (5ms|1ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)

Describing CodexRouting bundle mirror byte identity
 8ms (8ms|1ms)

Running tests from 'tests\scripts\claude-lib\codex-routing\CodexTopology.Parity.Tests.ps1'
Describing Resolve-CodexTopology small route
 13ms (12ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)

Describing Resolve-CodexTopology language normalization
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 5ms (5ms|0ms)

Describing Resolve-CodexTopology escalation precedence
 5ms (4ms|1ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 8ms (8ms|0ms)
 4ms (3ms|1ms)

Describing Resolve-CodexTopology forced root persona
 6ms (4ms|1ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 5ms (4ms|0ms)
 5ms (4ms|1ms)
 3ms (3ms|1ms)

Describing Get-CodexForcedRootPersona
 5ms (4ms|2ms)

Describing Resolve-CodexTopology invalid-input throw surface
 7ms (5ms|2ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)
 5ms (5ms|1ms)
 5ms (5ms|1ms)
 5ms (5ms|1ms)
 5ms (4ms|1ms)
 10ms (9ms|1ms)
 6ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Manifest.Tests.ps1'
Describing DiscoveryValidation core.json manifest membership
 20ms (19ms|1ms)
 6ms (5ms|1ms)
 11ms (10ms|1ms)

Describing DiscoveryValidation bundle mirror byte identity
 7ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Tests.ps1'
Describing DiscoveryValidation
 Context artifact-type table
 8ms (4ms|4ms)
 26ms (25ms|1ms)
 4ms (3ms|1ms)
 10ms (9ms|1ms)
 Context profile placeholder contract
 19ms (18ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 4ms (3ms|1ms)
 10ms (9ms|1ms)
 7ms (6ms|1ms)
 8ms (7ms|1ms)
 5ms (5ms|1ms)
 4ms (3ms|1ms)
 Context schema resolution
 12ms (8ms|5ms)
 3ms (3ms|1ms)
 6ms (5ms|1ms)
 8ms (7ms|1ms)
 5ms (5ms|1ms)
 8ms (7ms|1ms)
 6ms (5ms|1ms)
 Context schema-governed artifact validation
 9ms (8ms|2ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 72ms (71ms|1ms)
 20ms (20ms|1ms)
 Context dispatch by artifact type
 6ms (5ms|1ms)
 4ms (3ms|1ms)
 5ms (5ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 Context seam result contract (defect D-2 avoidance)
 9ms (7ms|1ms)
 5ms (5ms|1ms)
 8ms (8ms|1ms)
 7ms (6ms|1ms)
 9ms (8ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.VersionFloor.Tests.ps1'
Describing DiscoveryValidation destination version floor
 Context floor boundary
 10ms (3ms|7ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 Context message content (all three required elements)
 5ms (3ms|1ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 Context fail-closed at every entry point
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 4ms (4ms|1ms)
 10ms (9ms|1ms)
 Context no silent degradation
 7ms (6ms|1ms)
 5ms (4ms|1ms)

Running tests from 'tests\scripts\claude-lib\hook-payload\HookPayload.Tests.ps1'
Describing Read-ClaudeHookRawPayload transport
 Context precedence when several sources carry text
 8ms (7ms|1ms)
 5ms (5ms|1ms)
 Context fallback order when stdin is whitespace-only
 6ms (5ms|1ms)
 5ms (5ms|0ms)
 5ms (4ms|0ms)
 Context a throwing stdin read
 6ms (5ms|1ms)
 4ms (3ms|0ms)
 Context redirect-guard polarity
 5ms (5ms|1ms)
 10ms (3ms|6ms)
 7ms (7ms|0ms)
 Context environment-variable defaults
 8ms (8ms|1ms)
 6ms (6ms|0ms)

Describing ConvertFrom-ClaudeHookEnvelope
 Context well-formed payloads
 18ms (16ms|1ms)
 5ms (5ms|1ms)
 4ms (4ms|0ms)
 Context anomalous payloads
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)

Describing Get-ClaudeHookToolInput strict nested extraction
 Context well-formed envelopes
 7ms (6ms|2ms)
 Context envelope-level anomalies
 4ms (3ms|1ms)
 7ms (7ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)

Describing Resolve-ClaudeHookToolInput end-to-end extraction
 Context nested property extraction per matcher family
 6ms (4ms|2ms)
 5ms (4ms|0ms)
 4ms (3ms|0ms)
 6ms (5ms|0ms)
 Context property-level tolerance inside a well-formed tool_input
 4ms (3ms|1ms)
 5ms (5ms|0ms)
 Context anomaly propagation
 4ms (3ms|1ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)

Describing Anomaly reason mapping
 6ms (5ms|1ms)
 8ms (7ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)

Describing Shape helper predicates
 Context Test-ClaudeHookEnvelopeHasKey
 5ms (3ms|2ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 3ms (2ms|0ms)
 3ms (2ms|1ms)
 Context Test-ClaudeHookObjectValue
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 Context Get-ClaudeHookEnvelopeValue
 4ms (3ms|1ms)
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidGrammar.Tests.ps1'
Describing MermaidGrammar reference data
 Context pinned documentation metadata
 4ms (2ms|1ms)
 3ms (2ms|0ms)
 5ms (5ms|0ms)
 Context first-line keyword allowlist
 15ms (14ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 9ms (9ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 5ms (4ms|0ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|1ms)
 23ms (23ms|0ms)
 5ms (4ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 5ms (5ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|1ms)
 Context verified versus keyword-accept rows
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 Context deep-checked diagram type set
 5ms (5ms|1ms)
 4ms (3ms|1ms)
 1ms (1ms|1ms)
 1ms (1ms|1ms)
 1ms (1ms|1ms)
 1ms (1ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 Context per-type arrow token sets
 12ms (7ms|5ms)
 6ms (5ms|0ms)
 7ms (6ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|1ms)
 9ms (8ms|1ms)
 4ms (4ms|1ms)
 5ms (5ms|1ms)
 2ms (1ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|0ms)
 6ms (5ms|0ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 Context statement-keyword exemption list
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 1ms (1ms|1ms)
 2ms (1ms|1ms)
 1ms (1ms|1ms)
 1ms (1ms|1ms)
 2ms (1ms|1ms)
 1ms (1ms|1ms)
 1ms (1ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 Context bracket-structural and post-colon classification
 8ms (6ms|2ms)
 11ms (10ms|1ms)
 7ms (5ms|1ms)
 Context keyword shape rule
 5ms (3ms|1ms)
 6ms (6ms|1ms)
 Context type table accessors
 27ms (21ms|7ms)
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidLineScanner.Tests.ps1'
Describing MermaidLineScanner quote-aware scanning
 Context quoted spans excluded from bracket balance
 43ms (40ms|3ms)
 8ms (7ms|1ms)
 6ms (6ms|1ms)
 Context backslash is an ordinary character
 21ms (20ms|1ms)
 6ms (5ms|1ms)
 Context comment stripping outside quoted spans only
 9ms (7ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 4ms (3ms|1ms)
 Context directive recognition before comment stripping
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 Context bracket imbalance detection on a structural line
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 5ms (5ms|1ms)
 Context unterminated quote detection
 5ms (3ms|1ms)
 5ms (4ms|1ms)
 Context angle brackets are never structural
 7ms (6ms|1ms)
 4ms (4ms|1ms)
 Context Unicode content is scanned without error
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 Context statement-keyword classification
 9ms (7ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 Context arrow candidate tokenization
 6ms (5ms|1ms)
 16ms (16ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 4ms (4ms|1ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)
 7ms (6ms|1ms)
 8ms (7ms|1ms)
 3ms (3ms|1ms)
 Context pre-colon segmentation for statement labels
 11ms (10ms|1ms)
 4ms (4ms|1ms)
 6ms (6ms|1ms)
 5ms (4ms|1ms)
 Context masking helpers used by the validator
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 5ms (5ms|1ms)
 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidMarkdownFences.Tests.ps1'
Describing MermaidMarkdownFences extraction
 Context plain fence recognition
 52ms (44ms|8ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 6ms (5ms|1ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 5ms (5ms|1ms)
 Context nested fence classification
 6ms (4ms|1ms)
 6ms (4ms|2ms)
 4ms (3ms|1ms)
 Context unclosed fence tolerance
 7ms (4ms|2ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 Context opt-out marker contract
 15ms (14ms|1ms)
 4ms (4ms|1ms)
 7ms (6ms|1ms)
 6ms (6ms|1ms)
 5ms (3ms|2ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 5ms (4ms|2ms)
 Context fence line parsing helpers
 12ms (10ms|1ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (4ms|1ms)
 4ms (4ms|1ms)
 Context line splitting and quote-prefix helpers
 5ms (4ms|1ms)
 4ms (4ms|1ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidValidation.Tests.ps1'
Describing Test-MermaidDiagram structural verdicts
 Context accepted diagrams of each checked type
 46ms (41ms|5ms)
 15ms (14ms|1ms)
 13ms (12ms|1ms)
 33ms (32ms|1ms)
 14ms (13ms|1ms)
 5ms (5ms|1ms)
 6ms (5ms|1ms)
 Context first-line keyword defects
 10ms (8ms|1ms)
 12ms (12ms|1ms)
 5ms (5ms|1ms)
 9ms (9ms|1ms)
 5ms (4ms|1ms)
 Context per-type invalid arrow tokens
 10ms (8ms|1ms)
 11ms (10ms|1ms)
 15ms (14ms|1ms)
 10ms (9ms|1ms)
 11ms (10ms|1ms)
 Context bracket balance and quote termination
 12ms (11ms|1ms)
 7ms (7ms|1ms)
 8ms (7ms|1ms)
 8ms (7ms|1ms)
 Context subgraph pairing
 10ms (9ms|1ms)
 18ms (17ms|1ms)
 Context empty and whitespace-only content
 5ms (3ms|1ms)
 4ms (4ms|1ms)
 5ms (5ms|1ms)
 Context line endings and frontmatter
 10ms (9ms|1ms)
 15ms (14ms|1ms)
 10ms (9ms|1ms)
 7ms (6ms|1ms)
 9ms (9ms|1ms)
 11ms (11ms|1ms)
 6ms (6ms|1ms)
 Context fail-open policy
 10ms (8ms|1ms)
 5ms (5ms|1ms)
 5ms (4ms|1ms)
 8ms (8ms|1ms)
 5ms (4ms|1ms)

Describing Test-MermaidManagedDiagram detector
 6ms (5ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\mermaid\MermaidValidationAcceptMatrix.Tests.ps1'
Describing MermaidValidation accept matrix
 Context quoted-label constructs
 11ms (9ms|2ms)
 10ms (10ms|1ms)
 9ms (9ms|1ms)
 9ms (8ms|1ms)
 9ms (8ms|1ms)
 9ms (8ms|1ms)
 8ms (7ms|1ms)
 9ms (9ms|1ms)
 Context block and statement constructs
 15ms (14ms|1ms)
 8ms (7ms|1ms)
 9ms (8ms|1ms)
 9ms (9ms|1ms)
 8ms (8ms|1ms)
 8ms (7ms|1ms)
 8ms (8ms|1ms)
 9ms (8ms|1ms)
 12ms (11ms|1ms)
 Context free-text constructs
 10ms (9ms|1ms)
 6ms (5ms|1ms)
 Context documented grammar variants
 11ms (9ms|1ms)
 8ms (7ms|1ms)
 11ms (10ms|1ms)

Running tests from 'tests\scripts\claude-lib\model-routing\Get-ComplexityFloor.Tests.ps1'
Describing Get-ComplexityFloor
 Context No floor signals present
 5ms (3ms|1ms)
 Context A single present floor signal
 8ms (7ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 Context Multiple present floor signals
 4ms (3ms|1ms)
 6ms (5ms|1ms)
 Context Non-floor and unknown signals
 6ms (5ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 Context Mixed floor and non-floor signals
 6ms (4ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 9ms (9ms|1ms)
 Context Determinism
 7ms (7ms|1ms)
 5ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\model-routing\ModelRouting.Manifest.Tests.ps1'
Describing ModelRouting core.json manifest membership
 7ms (6ms|1ms)
 5ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\model-routing\ModelRouting.Parity.Tests.ps1'
Describing ModelRouting config parity
 Context Base complexity-to-model table
 9ms (8ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 Context Preferred overlay
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 8ms (7ms|1ms)
 Context Floor candidate and ceiling bands
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 Context Floor-signal name set
 12ms (11ms|1ms)
 10ms (9ms|0ms)
 Context Disabled policy literal
 6ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\model-routing\Resolve-DelegationModel.Tests.ps1'
Describing Resolve-DelegationModel
 Context Base table under the available policy
 12ms (10ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 Context Disabled policy clamp
 6ms (6ms|1ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|1ms)
 3ms (3ms|0ms)
 Context Preferred overlay
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (2ms|1ms)
 5ms (5ms|1ms)
 2ms (1ms|1ms)
 Context Determinism
 17ms (16ms|1ms)
 Context Out-of-table band (negative case)
 6ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Manifest.Tests.ps1'
Describing OrchestratorState core.json manifest membership
 7ms (6ms|1ms)
 6ms (6ms|0ms)
 64ms (63ms|1ms)
 26ms (25ms|1ms)
 25ms (25ms|1ms)

Describing OrchestratorState bundle mirror byte identity
 22ms (21ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1'
Describing Test-OrchestratorStatePrCreationReadiness
 Context PR-creation-ready checkpoint
 109ms (108ms|1ms)
 Context rejection conditions
 20ms (19ms|1ms)
 32ms (31ms|0ms)
 16ms (16ms|1ms)
 14ms (13ms|1ms)
 19ms (18ms|0ms)
 27ms (27ms|1ms)
 19ms (18ms|0ms)
 Context fail-closed conditions
 16ms (15ms|1ms)
 17ms (16ms|1ms)
 35ms (35ms|0ms)
 18ms (18ms|0ms)

Describing Invoke-OrchestratorStatePreflight
 Context Invoke-OrchestratorStatePreflight (direct seam tests)
 13ms (11ms|2ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 5ms (4ms|0ms)
 Context default invoker (portable path is the only path)
 473ms (472ms|1ms)
 177ms (177ms|1ms)
 40ms (40ms|1ms)
 34ms (33ms|1ms)
 55ms (54ms|1ms)

Describing Get-OrchestratorStateBasePresenceError per-step-key status vocabulary
 Context per-key extra statuses accepted on their owning key
 10ms (7ms|2ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 5ms (4ms|1ms)
 Context per-key extra statuses rejected on every non-owning key
 7ms (6ms|2ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 9ms (8ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 Context epic-merge-gate regression scenario
 11ms (10ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.ValueContract.Tests.ps1'
Describing Get-OrchestratorStateCheckpoint value contract
 30ms (29ms|1ms)
 35ms (34ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Backcompat.Tests.ps1'
Describing Orchestrator-state blocked_reason back-compat capture
 8ms (6ms|1ms)
 16ms (16ms|1ms)
 111ms (110ms|1ms)
 23ms (7ms|16ms)
 7ms (6ms|1ms)
 24ms (23ms|1ms)
 10ms (9ms|1ms)
 7ms (7ms|1ms)
 21ms (20ms|1ms)
 11ms (10ms|1ms)
 32ms (31ms|1ms)
 45ms (44ms|2ms)
 6ms (5ms|1ms)
 9ms (6ms|3ms)
 23ms (22ms|1ms)
 6ms (5ms|1ms)
 10ms (9ms|1ms)
 22ms (20ms|1ms)
 6ms (6ms|1ms)
 12ms (11ms|1ms)
 20ms (19ms|1ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)
 19ms (18ms|1ms)
 10ms (7ms|3ms)
 12ms (12ms|1ms)
 40ms (40ms|1ms)
 7ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Parity.Tests.ps1'
Describing OrchestratorState blocked_reason corpus parity
 8ms (6ms|2ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 8ms (2ms|5ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 14ms (13ms|1ms)
 6ms (5ms|1ms)
 6ms (6ms|1ms)
 7ms (6ms|1ms)
 25ms (24ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 8ms (8ms|1ms)
 6ms (5ms|1ms)
 6ms (6ms|1ms)
 8ms (8ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 5ms (5ms|1ms)
 9ms (8ms|2ms)
 6ms (5ms|1ms)
 16ms (14ms|1ms)
 16ms (15ms|1ms)
 16ms (15ms|1ms)
 12ms (11ms|1ms)
 9ms (8ms|1ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Tests.ps1'
Describing OrchestratorState blocked_reason base membership
 9ms (7ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 12ms (10ms|2ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)

Describing OrchestratorState blocked_reason PR-creation readiness
 10ms (8ms|2ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)

Describing OrchestratorState blocked_reason grouped vocabulary
 15ms (13ms|2ms)
 8ms (8ms|1ms)

Describing OrchestratorState blocked_reason completion gate
 18ms (6ms|13ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCheckpointValue.Tests.ps1'
Describing Checkpoint shape predicates
 5ms (3ms|2ms)
 4ms (4ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)

Describing Checkpoint member-name enumeration
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 9ms (8ms|1ms)

Describing Checkpoint member accessor
 8ms (7ms|2ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)

Describing Ordinal key sorting
 5ms (3ms|2ms)
 3ms (3ms|1ms)

Describing Python zero equivalence
 10ms (8ms|2ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)

Describing Python value equality
 5ms (3ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 5ms (3ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 5ms (5ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 7ms (6ms|1ms)
 5ms (4ms|1ms)
 4ms (4ms|1ms)

Describing Python str() rendering
 6ms (4ms|2ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 5ms (3ms|1ms)
 4ms (3ms|1ms)

Describing Python repr() rendering
 6ms (4ms|2ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexModelReceipts.Tests.ps1'
Describing OrchestratorStateCodexModelReceipts shape and key checks
 28ms (27ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 7ms (6ms|1ms)
 6ms (6ms|1ms)
 6ms (5ms|1ms)

Describing OrchestratorStateCodexModelReceipts resolver-input and resolved-key checks
 6ms (4ms|1ms)
 6ms (5ms|1ms)
 5ms (5ms|1ms)
 6ms (5ms|1ms)
 5ms (5ms|1ms)
 6ms (5ms|0ms)
 6ms (6ms|1ms)

Describing OrchestratorStateCodexModelReceipts ceiling monotonicity and transition checks
 9ms (7ms|1ms)
 10ms (10ms|0ms)
 9ms (9ms|1ms)
 6ms (6ms|1ms)
 6ms (6ms|1ms)
 6ms (6ms|0ms)
 6ms (6ms|0ms)
 15ms (14ms|0ms)
 7ms (6ms|1ms)
 7ms (7ms|0ms)
 7ms (6ms|0ms)
 7ms (7ms|0ms)

Describing Single-implementation rule for the Codex deployment resolver
 31ms (30ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexTopologyReceipts.Tests.ps1'
Describing OrchestratorStateCodexTopologyReceipts shape and key checks
 30ms (29ms|1ms)
 8ms (7ms|1ms)
 16ms (15ms|1ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 6ms (5ms|0ms)
 6ms (6ms|0ms)

Describing OrchestratorStateCodexTopologyReceipts resolver-input type checks
 5ms (4ms|1ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 8ms (7ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 6ms (6ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 6ms (5ms|0ms)
 6ms (6ms|0ms)

Describing OrchestratorStateCodexTopologyReceipts resolver and resolved-key checks
 16ms (15ms|1ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 7ms (6ms|0ms)
 6ms (6ms|0ms)
 9ms (8ms|0ms)

Describing Single-implementation rule for the Codex topology resolver
 27ms (25ms|1ms)
 16ms (15ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletion.Tests.ps1'
Describing Test-OrchestratorStateCompletionReadiness
 Context model-routing existence gate
 106ms (105ms|1ms)
 29ms (29ms|0ms)
 30ms (29ms|1ms)
 32ms (31ms|0ms)
 Context fail-closed conditions
 12ms (12ms|1ms)
 14ms (13ms|1ms)
 38ms (38ms|0ms)
 Context M2 complexity-assessment pairing
 35ms (34ms|1ms)
 31ms (30ms|0ms)
 33ms (33ms|0ms)
 31ms (29ms|2ms)
 Context PD-2 single emission
 39ms (39ms|1ms)
 35ms (35ms|0ms)
 39ms (38ms|0ms)
 Context M3 reuse of the per-entry validators
 52ms (51ms|1ms)
 48ms (48ms|0ms)
 Context complete-parity composition
 36ms (35ms|1ms)
 34ms (34ms|0ms)
 39ms (39ms|0ms)
 34ms (33ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletionChecks.Tests.ps1'
Describing C1 completion-blocking step statuses
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 15ms (15ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|1ms)

Describing C2 completion blocked_reason
 5ms (2ms|2ms)
 3ms (3ms|1ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)

Describing C3 completion pr_gate
 9ms (8ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)

Describing C4 completion ci_gate
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 8ms (7ms|0ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 3ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)

Describing C5 mandatory route phases
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)

Describing C7 preparation terminal contract
 6ms (5ms|1ms)
 9ms (8ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Parity.Tests.ps1'
Describing Issue-adoption fixture corpus discovery
 Context Non-vacuous iteration
 4ms (2ms|1ms)
 7ms (6ms|1ms)
 3ms (3ms|1ms)

Describing Issue-adoption routing-contract parity
 18ms (17ms|1ms)
 29ms (29ms|1ms)
 10ms (9ms|1ms)
 14ms (14ms|1ms)
 13ms (12ms|1ms)
 10ms (10ms|1ms)
 27ms (26ms|1ms)
 12ms (11ms|1ms)
 10ms (10ms|1ms)
 14ms (13ms|1ms)
 10ms (10ms|1ms)
 11ms (10ms|1ms)
 13ms (13ms|1ms)
 11ms (10ms|1ms)
 10ms (10ms|1ms)
 12ms (12ms|1ms)
 9ms (9ms|1ms)
 9ms (8ms|1ms)
 8ms (7ms|1ms)
 14ms (13ms|1ms)
 11ms (11ms|1ms)
 11ms (10ms|1ms)
 15ms (14ms|1ms)
 10ms (9ms|1ms)
 9ms (8ms|1ms)
 15ms (14ms|1ms)
 10ms (9ms|1ms)
 10ms (9ms|1ms)
 9ms (9ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1'
Describing Issue adoption accepts valid records (AC-6)
  [-] accepts a feature checkpoint waiving potential_to_issue alone
 41ms (40ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:120
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts a feature checkpoint waiving the feature entry tool with a record
 37ms (37ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:127
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts a bug checkpoint waiving the bug entry tool with a record
 39ms (39ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:134
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the same record on the preparation route
 41ms (40ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:140
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented origin value transferred
 28ms (28ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented origin value filed_before_orchestration
 39ms (38ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented origin value epic_decomposition
 40ms (39ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:148
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented verification source gh_issue_view
 44ms (44ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented verification source gh_api_get
 50ms (44ms|6ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] accepts the documented verification source github_mcp_issue_read
 48ms (47ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:156
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

Describing Issue adoption rejects malformed records (AC-7)
  [-] rejects a non-object adoption value of kind string
 46ms (43ms|3ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a non-object adoption value of kind integer
 42ms (42ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a non-object adoption value of kind list
 38ms (37ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:167
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a null adoption value
 40ms (40ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:173
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an integer issue number
 61ms (60ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:179
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a leading-zero issue number
 43ms (42ms|2ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:186
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an issue number that differs from the checkpoint issue-num
 46ms (45ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:193
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an issue URL that does not end with the issue number
 48ms (46ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:200
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an unknown origin
 47ms (46ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:206
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an unknown verification source
 46ms (45ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:211
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an absent verification time
 46ms (46ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:216
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a null verification time
 54ms (53ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:221
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a whitespace-only verification time
 48ms (48ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:226
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects empty evidence
 38ms (37ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:231
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an empty waived list
 41ms (40ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:236
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a malformed waived list of kind string
 47ms (46ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a malformed waived list of kind blank-entry
 53ms (52ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a malformed waived list of kind integer-entry
 46ms (45ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:246
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a waived list that omits the issue-creation tool
 38ms (38ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:253
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects an invalid potential record when waiving the entry tool
 41ms (40ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:260
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

Describing Issue adoption enforces the closed waivable set (AC-8)
  [-] rejects waiving the feature-folder tool
 57ms (56ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:270
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects waiving the artifact-validation tool
 45ms (45ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:277
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects waiving the feature entry tool on a bug checkpoint
 47ms (46ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:283
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects any waiver on the remediation route
 45ms (44ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:288
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects waiving a tool that holds a successful receipt
 41ms (40ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:293
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] rejects a tool listed twice
 43ms (42ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:299
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

Describing Issue adoption fails closed and is presence gated (AC-9, AC-11)
  [-] empties the waived set whenever any error is reported across a fixed grid
 44ms (43ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:329
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] yields no errors and no waivers for a checkpoint without the adoption key
 40ms (39ms|1ms)
   at script:Invoke-Adoption, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:92
   at <ScriptBlock>, tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1:349
   CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

Describing Routing contract wiring for issue adoption
 13ms (11ms|1ms)
 19ms (18ms|1ms)
 11ms (10ms|1ms)
 12ms (11ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateModelReceipts.Tests.ps1'
Describing OrchestratorStateModelReceipts complexity_assessments checks (U6.C)
 5ms (4ms|1ms)
 4ms (3ms|0ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|0ms)
 4ms (3ms|1ms)
 4ms (3ms|0ms)
 4ms (4ms|1ms)
 4ms (4ms|1ms)
 3ms (3ms|0ms)
 6ms (5ms|0ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)

Describing OrchestratorStateModelReceipts model_routing_receipts checks (U6.M)
 8ms (6ms|2ms)
 4ms (4ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)

Describing Single-implementation rule for the shared reference formulas
 20ms (18ms|1ms)
 26ms (26ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStatePromotionType.Parity.Tests.ps1'
Describing Promotion-type fixture corpus discovery
 Context Non-vacuous iteration
 4ms (2ms|2ms)
 7ms (7ms|1ms)
 4ms (3ms|1ms)

Describing Promotion-type routing-contract parity
 Context Corpus cases
 13ms (11ms|2ms)
 33ms (32ms|1ms)
 18ms (16ms|1ms)
 9ms (8ms|1ms)
 10ms (10ms|1ms)
 6ms (5ms|1ms)
 8ms (7ms|1ms)
 9ms (8ms|1ms)
 17ms (16ms|1ms)
 9ms (8ms|1ms)
 8ms (8ms|1ms)
 9ms (9ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateReceipts.Tests.ps1'
Describing OrchestratorStateReceipts delegation_receipts checks (U5)
 3ms (2ms|1ms)
 4ms (3ms|0ms)
 7ms (7ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|0ms)
 5ms (4ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)

Describing OrchestratorStateReceipts remediation_loop checks (U6.R)
 26ms (24ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 5ms (4ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (5ms|0ms)

Describing OrchestratorStateReceipts human_interaction checks (U6.H)
 12ms (11ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationAccounting.Tests.ps1'
Describing Get-RemediationReviewVerdict
 7ms (6ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 4ms (4ms|0ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|1ms)
 2ms (1ms|1ms)
 8ms (7ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)

Describing Get-OrchestratorStateRemediationAccountingError
 11ms (9ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 14ms (13ms|1ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 2ms (2ms|1ms)
 4ms (4ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 7ms (7ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 8ms (7ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 6ms (6ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 5ms (5ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 2ms (2ms|1ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 6ms (6ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)

Describing Remediation accounting vocabulary
 10ms (8ms|1ms)
 13ms (12ms|1ms)

Describing Remediation accounting through the unconditional block
 11ms (9ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Backcompat.Tests.ps1'
Describing Remediation-loop back-compat corpus discovery
 5ms (3ms|1ms)

Describing Remediation-loop back-compat replay
 18ms (17ms|1ms)
 16ms (16ms|1ms)
 4ms (3ms|1ms)
 5ms (5ms|1ms)
 13ms (13ms|0ms)
 3ms (3ms|0ms)
 14ms (13ms|1ms)
 12ms (12ms|0ms)
 4ms (3ms|0ms)
 8ms (7ms|0ms)
 14ms (14ms|1ms)
 4ms (4ms|1ms)
 10ms (10ms|1ms)
 17ms (17ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 15ms (15ms|1ms)
 5ms (4ms|1ms)
 9ms (8ms|1ms)
 17ms (16ms|1ms)
 5ms (5ms|1ms)
 10ms (10ms|1ms)
 17ms (16ms|1ms)
 5ms (4ms|1ms)
 9ms (8ms|0ms)
 14ms (13ms|0ms)
 4ms (3ms|1ms)
 10ms (9ms|1ms)
 15ms (15ms|1ms)
 4ms (3ms|1ms)
 9ms (8ms|0ms)
 17ms (17ms|1ms)
 7ms (6ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Parity.Tests.ps1'
Describing Remediation-loop corpus discovery
 11ms (5ms|6ms)
 8ms (7ms|1ms)

Describing Remediation-loop corpus parity
 6ms (4ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (1ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 5ms (5ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
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
 2ms (1ms|0ms)
 7ms (6ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 12ms (11ms|0ms)
 6ms (6ms|1ms)
 6ms (6ms|1ms)
 7ms (5ms|2ms)
 5ms (5ms|1ms)
 5ms (5ms|1ms)
 6ms (5ms|1ms)
 7ms (7ms|0ms)
 6ms (5ms|0ms)
 6ms (6ms|1ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 9ms (9ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 5ms (5ms|0ms)
 8ms (7ms|0ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 6ms (5ms|0ms)
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 5ms (4ms|0ms)
 6ms (6ms|0ms)
 5ms (4ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 8ms (8ms|1ms)
 6ms (5ms|1ms)
 6ms (6ms|1ms)
 8ms (7ms|1ms)
 6ms (5ms|1ms)
 7ms (6ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 5ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingContract.Tests.ps1'
Describing C6 terminal rows (matrix, route selection, route membership)
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)

Describing C6 declared-list equality rows
 6ms (5ms|1ms)
 6ms (5ms|0ms)
 9ms (9ms|0ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)
 6ms (5ms|0ms)

Describing C6 receipt-presence rows
 10ms (9ms|1ms)
 7ms (7ms|0ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 9ms (9ms|0ms)
 6ms (6ms|0ms)

Describing C6 empty-list rows, both message variants
 7ms (6ms|1ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 9ms (8ms|0ms)
 6ms (5ms|0ms)

Describing C6 lifecycle-operation rows
 6ms (5ms|1ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 9ms (8ms|0ms)
 6ms (6ms|0ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)

Describing C6 bug-promotion tool substitution
 7ms (6ms|1ms)
 6ms (6ms|1ms)
 7ms (7ms|0ms)
 7ms (6ms|1ms)
 8ms (7ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingMatrix.Tests.ps1'
Describing Pinned routing-matrix constants match config/orchestration-routing.json
 5ms (4ms|1ms)
 6ms (6ms|0ms)
 5ms (5ms|0ms)
 16ms (16ms|0ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)

Describing Routing-matrix route lookup
 6ms (5ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Route gate predicates
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 5ms (5ms|0ms)
 2ms (2ms|0ms)

Describing Route required-name list accessor
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Describing Checkpoint route-value resolution
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorStateUnconditional.Tests.ps1'
Describing Unconditional aggregation: fully valid checkpoint
 5ms (4ms|1ms)

Describing Unconditional aggregation: base-presence family (U2-U4)
 4ms (3ms|1ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)

Describing Unconditional aggregation: delegation-receipt family (U5)
 4ms (3ms|1ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)

Describing Unconditional aggregation: each optional family surfaces
 12ms (11ms|1ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 6ms (5ms|0ms)
 5ms (4ms|0ms)

Describing Unconditional aggregation: key-gated semantics
 5ms (4ms|1ms)
 4ms (3ms|0ms)
 9ms (8ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\Invoke-ParallelDriftDetection.Tests.ps1'
Describing Invoke-ParallelDriftDetection.ps1
 Context Parameter surface
 16ms (15ms|1ms)
 18ms (17ms|0ms)
 Context With mocked file and clock seams
 19ms (18ms|1ms)
 9ms (9ms|1ms)
 27ms (26ms|0ms)
 25ms (24ms|0ms)
 24ms (24ms|0ms)
 120ms (120ms|0ms)
 30ms (29ms|0ms)
 36ms (36ms|0ms)
 27ms (26ms|0ms)
 22ms (22ms|0ms)
 45ms (44ms|1ms)
 32ms (31ms|1ms)
 Context JSON conversion
 25ms (24ms|1ms)
 23ms (23ms|1ms)
 4ms (4ms|0ms)
 8ms (7ms|0ms)
 6ms (5ms|0ms)
 Context With the real file seam
 27ms (26ms|1ms)
 33ms (33ms|0ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\ParallelDrift.Manifest.Tests.ps1'
Describing Parallel-drift core.json manifest membership
 3ms (2ms|1ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 9ms (9ms|0ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\ParallelDrift.Parity.Tests.ps1'
Describing Parallel drift parity corpus
 6ms (5ms|1ms)
 9ms (8ms|0ms)
 28ms (28ms|1ms)
 8ms (8ms|1ms)
 7ms (7ms|0ms)
 27ms (27ms|1ms)
 25ms (25ms|1ms)
 26ms (26ms|1ms)
 30ms (30ms|1ms)
 25ms (25ms|1ms)
 24ms (23ms|1ms)
 26ms (26ms|0ms)
 20ms (20ms|1ms)
 11ms (11ms|1ms)
 8ms (7ms|0ms)
 26ms (26ms|0ms)
 15ms (15ms|1ms)
 17ms (17ms|0ms)
 20ms (19ms|0ms)
 21ms (21ms|0ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\ParallelDrift.Tests.ps1'
Describing ParallelDrift.psm1
 16ms (15ms|1ms)
 34ms (34ms|1ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)
 4ms (3ms|1ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)
 5ms (5ms|1ms)
 12ms (12ms|1ms)
 4ms (3ms|1ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 5ms (4ms|0ms)
 6ms (6ms|0ms)
 5ms (5ms|0ms)
 11ms (10ms|0ms)
 7ms (7ms|1ms)
 8ms (7ms|1ms)
 21ms (20ms|1ms)
 5ms (4ms|0ms)
 14ms (13ms|0ms)
 18ms (18ms|0ms)

Running tests from 'tests\scripts\claude-lib\parallel-drift\ParallelDriftHalt.Tests.ps1'
Describing ParallelDriftHalt.psm1
 3ms (3ms|1ms)
 5ms (5ms|0ms)
 2ms (1ms|0ms)
 3ms (2ms|0ms)
 2ms (1ms|0ms)
 4ms (3ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|1ms)
 5ms (5ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 4ms (3ms|0ms)
 5ms (5ms|0ms)
 7ms (7ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Manifest.Tests.ps1'
Describing Project-file merge core.json manifest membership
 Context Library coverage
 3ms (2ms|1ms)
 10ms (9ms|0ms)
 Context Bundled payload parity
 6ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Tests.ps1'
Describing Get-ConflictHunk
 12ms (11ms|1ms)
 5ms (4ms|0ms)
 2ms (2ms|0ms)

Describing Merge-ConflictedText keyed union
 25ms (24ms|1ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 6ms (5ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 4ms (3ms|0ms)
 5ms (5ms|0ms)
 4ms (3ms|1ms)
 6ms (5ms|0ms)
 4ms (4ms|0ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 14ms (13ms|0ms)
 10ms (10ms|0ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 8ms (8ms|0ms)
 8ms (7ms|0ms)

Describing Test-NeverDropPostCondition
 24ms (23ms|1ms)
 9ms (8ms|0ms)
 5ms (5ms|0ms)

Running tests from 'tests\scripts\claude-lib\project-file-merge\ProjectFileMergeGrammar.Tests.ps1'
Describing Get-ProjectFileKind
 5ms (4ms|1ms)
 3ms (2ms|0ms)
 5ms (5ms|0ms)
 3ms (2ms|1ms)

Describing Get-MergeableUnit
 12ms (10ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|1ms)
 3ms (2ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)

Describing Compare-UnitVersion
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\project-file-merge\Resolve-MergeableConflict.Tests.ps1'
Describing Invoke-MergeableConflictResolution
 101ms (99ms|2ms)
 17ms (17ms|1ms)
 22ms (22ms|1ms)
 20ms (20ms|1ms)
 35ms (34ms|1ms)
 25ms (25ms|1ms)

Describing Byte-level seams
 9ms (6ms|3ms)
 6ms (5ms|1ms)
 4ms (4ms|1ms)
 12ms (11ms|1ms)

Running tests from 'tests\scripts\claude-lib\requirements\GeneratedDocumentCounters.Tests.ps1'
Describing Get-NamedSectionCheckboxCount
 7ms (6ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1'
Describing Get-EpicPrCreationReadinessFailure
 7ms (6ms|1ms)
 6ms (5ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|0ms)
 4ms (4ms|1ms)

Describing Get-EpicCommandLegReadinessFailure
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 3ms (3ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|1ms)
 3ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint run-target location
 87ms (87ms|1ms)
 19ms (19ms|0ms)
 25ms (25ms|0ms)
 36ms (35ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint epic-scope matches
 25ms (24ms|1ms)
 16ms (16ms|0ms)
 24ms (23ms|0ms)
 17ms (16ms|0ms)
 22ms (22ms|0ms)

Describing Resolve-EpicScopeCheckpoint fail-closed non-matches
 13ms (13ms|1ms)
 14ms (14ms|0ms)
 15ms (15ms|0ms)
 28ms (28ms|1ms)
 13ms (12ms|0ms)
 13ms (13ms|0ms)
 17ms (17ms|0ms)
 13ms (13ms|0ms)
 14ms (14ms|0ms)

Describing Resolve-EpicScopeCheckpoint checkpoint path composition
 16ms (16ms|1ms)
 20ms (20ms|0ms)
 19ms (18ms|0ms)

Describing EpicScopeResolution read seams
 14ms (13ms|1ms)
 16ms (16ms|0ms)
 11ms (10ms|0ms)
 11ms (11ms|1ms)
 15ms (14ms|0ms)

Describing Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2)
 22ms (22ms|1ms)
 21ms (21ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1'
Describing WorktreeItemResolution checkpoint path
 3ms (2ms|1ms)
 10ms (10ms|0ms)
 2ms (2ms|0ms)

Describing WorktreeItemResolution issue signals
 8ms (7ms|1ms)
 2ms (2ms|0ms)
 7ms (7ms|0ms)
 4ms (3ms|0ms)

Describing WorktreeItemResolution checkpoint reader
 11ms (10ms|1ms)
 13ms (13ms|0ms)

Describing WorktreeItemResolution liveness seam
 23ms (22ms|1ms)
 18ms (17ms|0ms)

Describing WorktreeItemResolution target resolution
 14ms (13ms|1ms)
 24ms (23ms|0ms)
 11ms (11ms|0ms)
 20ms (20ms|0ms)
 14ms (14ms|0ms)
 9ms (9ms|0ms)
 11ms (10ms|0ms)
 10ms (10ms|0ms)
 7ms (7ms|0ms)
 9ms (9ms|0ms)
 8ms (7ms|0ms)
 6ms (6ms|0ms)
 11ms (11ms|0ms)
 10ms (10ms|0ms)
 6ms (6ms|0ms)
 32ms (32ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1'
Describing WorktreeResolution core.json manifest membership
 6ms (5ms|1ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (2ms|0ms)
 4ms (3ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 8ms (7ms|0ms)

Describing WorktreeResolution bundle mirror byte identity
 5ms (4ms|1ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1'
Describing WorktreeResolution seam default bodies
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 8ms (7ms|0ms)

Describing WorktreeResolution
 Context path normalisation
 5ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 1ms (0ms|0ms)
 Context root marker
 5ms (5ms|1ms)
 6ms (6ms|0ms)
 6ms (6ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)
 Context upward ascent
 8ms (7ms|1ms)
 9ms (9ms|0ms)
 14ms (14ms|0ms)
 6ms (6ms|0ms)
 7ms (7ms|0ms)
 3ms (2ms|0ms)
 Context worktree enumeration
 15ms (15ms|1ms)
 8ms (7ms|0ms)
 16ms (16ms|0ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 3ms (2ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
 19ms (19ms|0ms)
 7ms (6ms|0ms)
 11ms (10ms|0ms)
 7ms (6ms|0ms)
 7ms (6ms|0ms)
 12ms (12ms|0ms)
 Context repo-relative normalisation
 14ms (13ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 7ms (7ms|0ms)
 2ms (1ms|0ms)
 4ms (4ms|0ms)
 Context reason code
 6ms (5ms|1ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 22ms (21ms|1ms)
 18ms (17ms|0ms)
 12ms (11ms|0ms)
 12ms (11ms|0ms)
 10ms (10ms|0ms)
 9ms (9ms|0ms)
 15ms (14ms|0ms)
 9ms (8ms|0ms)
 8ms (8ms|0ms)
 9ms (8ms|0ms)
 9ms (9ms|0ms)
 8ms (8ms|0ms)
 8ms (8ms|0ms)

Describing Resolve-WorktreeOperandTarget
 21ms (11ms|11ms)
 6ms (5ms|0ms)
 6ms (5ms|0ms)
 5ms (5ms|0ms)
 9ms (8ms|0ms)

Describing Run resolver result contract
 15ms (14ms|1ms)
 15ms (14ms|0ms)
 15ms (14ms|1ms)
 12ms (11ms|0ms)
 26ms (25ms|0ms)

Describing Run resolver purity (parse-tree scan)
 22ms (21ms|1ms)
 20ms (19ms|1ms)
 24ms (24ms|0ms)

Describing Resolver module exports
 3ms (2ms|1ms)
 2ms (2ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1'
Describing Find-WorktreeRunIdentitySignal
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 4ms (3ms|0ms)

Describing Get-WorktreeRunCheckpointText
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 16ms (15ms|0ms)

Describing Get-WorktreeRunCheckpointPath
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1'
Describing Resolve-WorktreeEpicTarget
 17ms (16ms|1ms)
 12ms (11ms|0ms)
 10ms (10ms|0ms)
 9ms (9ms|0ms)
 12ms (11ms|0ms)
 10ms (10ms|0ms)
 15ms (14ms|0ms)
 11ms (10ms|0ms)
 10ms (10ms|0ms)
 11ms (10ms|0ms)
 7ms (6ms|0ms)
 17ms (17ms|0ms)
 9ms (9ms|1ms)
 9ms (9ms|1ms)
 7ms (7ms|1ms)

Describing Resolve-WorktreeParallelTarget
 10ms (9ms|1ms)
 10ms (10ms|0ms)
 13ms (13ms|0ms)
 10ms (10ms|0ms)
 7ms (7ms|0ms)
 7ms (7ms|0ms)
 7ms (6ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1'
Describing WorktreeTargetResolution
 Context result factory and field invariants
 22ms (21ms|1ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 8ms (7ms|0ms)
 8ms (8ms|0ms)
 26ms (26ms|0ms)
 9ms (9ms|0ms)
 Context signal extraction
 2ms (2ms|1ms)
 3ms (2ms|0ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 1ms (0ms|0ms)
 1ms (1ms|0ms)
 1ms (0ms|0ms)
 Context required matrix
 23ms (22ms|1ms)
 11ms (11ms|0ms)
 10ms (9ms|0ms)
 16ms (15ms|0ms)
 10ms (10ms|0ms)
 6ms (6ms|0ms)
 14ms (14ms|0ms)
 7ms (7ms|0ms)
 10ms (10ms|0ms)
 10ms (10ms|0ms)
 9ms (8ms|0ms)
 7ms (6ms|0ms)
 Context ambiguity, no target, and Ruling B
 19ms (18ms|1ms)
 11ms (11ms|1ms)
 8ms (8ms|1ms)
 11ms (10ms|0ms)
 15ms (14ms|0ms)
 14ms (14ms|0ms)
 6ms (5ms|0ms)
 6ms (6ms|0ms)
 23ms (23ms|0ms)
 12ms (12ms|0ms)
 21ms (20ms|0ms)
 4ms (4ms|0ms)
 35ms (35ms|0ms)
 Context path composition
 4ms (3ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 3ms (3ms|0ms)
Tests completed in 111.99s
Tests Passed: 2290, 
Failed: 38, 
Skipped: 1, 
Inconclusive: 0, 

NotRun: 0
TotalCount=2329
PassedCount=2290
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
