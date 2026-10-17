# R4 Perf Status (P4-T13, issue #935)

Timestamp: 2026-10-17T01-10

PERF-1: FIXED (P4-T3, P4-T4, P4-T5, P4-T10; artifacts qa-gates/r4-perf-ps-test.2026-10-17T01-07.md, qa-gates/r4-perf-timing-after.2026-10-17T01-09.md): the census memo keyed by path and text (Get-EpicStateFileSeamCensus, $script:EpicStateCensusCache), the closure-node memo per reader instance and path (Get-EpicStateMemoSourceText, Get-EpicStateClosureSuccessor, $script:EpicStateClosureNodeCache), and the reader memo per repository root (Get-EpicStateSourceReader, $script:EpicStateReaderCache).
DESIGN-NOTE: closure memoized per file node with the breadth-first order kept; see Established Facts
PERF-2: FIXED (P4-T6, P4-T7, P4-T10; artifact qa-gates/r4-perf-ps-test.2026-10-17T01-07.md): BeforeDiscovery computes suite discovery and the probe seams once; the probe rows carry `Seam`, and Get-EpicStateProbeFinding takes -Seam; the AC-5 rows read the discovered suites from the Describe -ForEach data.
PERF-3: FIXED (P4-T2, P4-T7, P4-T10; artifacts other/r4-perf-cr-n4-supersession.2026-10-17T00-55.md, qa-gates/r4-perf-ps-test.2026-10-17T01-07.md): the AC-5b and F-3 non-vacuity rows read one report built in the Describe-level BeforeAll.
PERF-4: FIXED (P4-T8, P4-T10; artifact qa-gates/r4-perf-ps-test.2026-10-17T01-07.md): rows `PERF census memo returns the cached records for a repeated file`, `PERF census memo recomputes for changed text`, `PERF census memo keys by path as well as text`, `PERF closure memo reads each file once for a repeated closure`, `PERF closure memo recomputes for a reader with changed text`, `PERF memo starts empty when the helper is dot-sourced`.
PERF-5: MEASURED-JUNIT-ONLY (P4-T1, P4-T11, P4-T12; artifacts qa-gates/r4-perf-timing-before.2026-10-17T00-54.md, qa-gates/r4-perf-timing-after.2026-10-17T01-09.md, qa-gates/r4-perf-shuffled-run.2026-10-17T01-10.md): PERF-JUNIT-DELTA: before JUNIT_SUITE_TIME_S=222.758 after JUNIT_SUITE_TIME_S=78.931 (relative; coverage enabled; no target applies); PERF-JUNIT-ROW-SET: UNCHANGED; direct timing PENDING-ORCHESTRATOR (PERF-TIMING-REFUSED)
SHUFFLE: PERF-TIMING-REFUSED

D-LC: tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 373; tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1 227; tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 458 (each at or below 500).

OBSERVATION: $script:EpicStateParseCache uses a case-insensitive @{} key; unchanged by this cycle (Established Facts)
