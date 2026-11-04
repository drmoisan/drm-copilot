---
name: registry-row-additions-break-id-filtered-suites
description: Adding native rows that share an Id with scanner rows breaks sibling suites that filter the committed docs analyzer registry by Id; check every Get-DocsAnalyzerRegistration caller, not just the registry suite
metadata:
  type: project
---

Observed 2026-11-04 on issue 1031 [P0-T4] (fail-closed existing-test disposition task). The plan named only `DocsAnalyzerRegistry.Tests.ps1` for the four native rows, but two 1022 suites also read the committed registry: `DocsAnalyzerConfigFiles.Tests.ps1` (registration case asserts one row per `Id`) and `DocsInventorySnapshot.Tests.ps1` (builds a snapshot from all rows and asserts the exact five-entry `analyzers` list). The run stopped with `BLOCKED: unplanned existing-test change` before any code.

**Why:** preflight of the plan cleared without this search; the stop cost a planner round.

**How to apply:** in preflight or Phase 0 of any plan that adds registry or dispatch rows, grep the whole test tree for the registry getter (`Get-DocsAnalyzerRegistration`, `Get-DocsCommandTable`) and evaluate each caller's filter against the post-change table with a SCRATCH probe (rows built in memory with `-NativeRow`). Related: [[probe-expect-fail-claims-in-preflight]].
