# Preflight Fixes (confirming preflight, plan version 1.2)

Timestamp: 2026-11-04T14-54
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/plan.2026-10-30T18-40.md
Command: mcp__drm-copilot__validate_orchestration_artifacts (artifact_type plan) and poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>
EXIT_CODE: 0
Output Summary: two trivial in-place fixes to evidence-source text; both validators pass after the fixes; no task added, removed, or reordered, and no asserted value changed.

## Fix 1 - Definitions, Pester count source

- Defect class: validator-blind unobtainable evidence source (assertion meaning unchanged).
- Finding: the definition named the JUnit file, or "the Pester result object of the same run" when that file is truncated or absent. On this host the single-process `tests/scripts` run truncates `artifacts/pester/pester-junit.xml` (Pester 5.9.1 JUnit export fails on a 0x1B character in a `tests/scripts/dev-tools/activate.Tests.ps1` failure message; recorded in the 1022 baseline evidence). The `TestResult` plugin runs in Pester's End step, so the export failure enters the catch path of `Invoke-Pester`, which emits no result object and exits -1 (255). `Invoke-PoshQCTest` (`PoshQC.Testing.psm1`) also never returns the result object to its caller. With the default route, neither named source exists, so the P0-T9 per-file failure profile and counts had no permitted source.
- Change: the definition now states that a run reading the result object passes an `-InvokePester` seam that sets `Run.PassThru` to `$true`, `Run.Exit` to `$false` and `TestResult.Enabled` to `$false` and keeps the returned object, and that P0-T9 and run (2) of P7-T8 use that seam. A P7-T8 concurrent shard (which has no seam) whose JUnit file does not load as XML is counted from the `Tests Passed:` summary line of its `shard.log`, with failed names from that log's failure lines. The counts, names, and profile columns asserted by P0-T9, P7-T3, and P7-T8 are unchanged.

## Fix 2 - P7-T8 run (3) acceptance

- Defect class: validator-blind unobtainable evidence source (assertion meaning unchanged).
- Finding: run (3) read counts only from each `artifacts/pester/parallel/shard-<i>/pester-junit.xml`. `Invoke-PoshQCParallelMerge` (`PoshQC.Parallel.psm1`) skips the merge when any shard exits non-zero, which is expected on this host, and the shard that runs `activate.Tests.ps1` leaves a JUnit file that does not load as XML (observed in the 1066 parallel baseline: shard exit 255, counted from its summary line).
- Change: run (3) now reads such a shard's counts from its `shard.log` under the Pester count source definition before summing.

## Checks performed without a fix

- `Invoke-PoshQCParallelTest` takes no scan-folder parameter; each shard runs `Invoke-PoshQCTest -ShardIndex -ShardCount` over `config/poshqc-scan.json` (`scripts`, `tests/powershell`, `tests/scripts`); `git ls-files` lists no `*.Tests.ps1` under `scripts`, and `tests/powershell` does not exist, so run (3) and run (2) cover the same file population, as the plan states.
- `Get-PoshQCShardSlice` returns each shard's files in enumeration order, so an order-dependent failure that appears in a shard also has its leaker ahead of it in the single-process order; every file with failures in the 1066 shard baseline also appears in the 1022 single-process failing list. The baseline-relative rule for runs (2) and (3) is satisfiable, and it can fail: any failure in a `TOUCHED_SUITES` file, or any failure outside the P0-T9 list, fails the task.
- P7-T3 scan folders (`claude-lib`, `claude-hooks`, `claude-runtime`) exclude `tests/scripts/dev-tools`, so its JUnit file is expected to load.
- Citations re-checked against the tree: both 1034 anchors, the `check`, `inventory`, and `validate` rows, the absence of `ResolveRevision` and `ReadRevisionText` at the merge base, the eight members of the `New-DocsCommandContext` literal, the final `core.json` element `.claude/lib/docs/DocsInventory.psm1`, every cited test name and helper function, the hook helper files, the four `## File Size Advisory` headings, the bundle paths, and the three policy-audit templates.
