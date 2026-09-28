# Remediation Inputs — Cycle 1 (Issue #722, PR #748)

- Timestamp: 2026-09-27T18-49
- Source: CI failure relayed by the parallel coordinator
- PR: #748, head f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d
- Failing check: poshqc / PowerShell QC (workflow run 36356018317; https://github.com/drmoisan/drm-copilot/actions/runs/36356018317)
- Result: Pester 5514 passed, 35 failed. The 18 other checks pass.
- Blocking findings: 2 (both FAIL)

## Finding R1 — Order-dependent conflict-relation lookup (34 tests)

- Affected tests: every case in tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 and
  tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1.
- Error: `RuntimeException: Test-BlastRadiusConflict is not available; import the facade module BlastRadius.psm1 before scheduling.`
  at Get-ConflictRelationCommand, .claude/lib/blast-radius/BlastRadiusScheduling.psm1:328.
- Cause (coordinator root cause, confirmed by reading the code): Get-ConflictRelationCommand
  (BlastRadiusScheduling.psm1 lines 320-331) resolves Test-BlastRadiusConflict with Get-Command at run
  time, from the scheduling module's own scope. The suites import the facade into the test scope
  (`Import-Module $facadePath -Force`), which is not visible from inside another module's scope unless
  imported with -Global. It passed locally only because an earlier import in the same session had
  loaded the facade globally. CI runs all suites in one process with coverage and a different order.
- Also a latent production defect: any caller that imports only BlastRadiusScheduling.psm1 hits the
  same error.

## Finding R2 — Dynamic invocation rejected by the no-Python-invocation guard (1 test)

- Affected test: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1.
- Error: `.claude/lib/blast-radius/BlastRadiusScheduling.psm1:384 [DynamicInvocation] in Get-BlastRadiusPairDecision:
  ampersand-invoked variable $relation is not a [scriptblock] parameter, so its target cannot be
  verified statically (fail-closed).`
- Cause: `$relation = Get-ConflictRelationCommand; & $relation ...` (lines 383-384).

## Design constraints the fix must respect

1. Test-BlastRadiusConflict is defined in the facade .claude/lib/blast-radius/BlastRadius.psm1
   (line 371), and the facade imports BlastRadiusScheduling.psm1 (line 74). Importing the facade from
   the scheduling module creates an import cycle.
2. The detection relation must not be edited or moved: spec AC-06, plan tasks P7-T3 and P14-T4
   (body-equality check against FINAL_BASE), and the merge-order independence with sibling #452
   depend on Test-BlastRadiusConflict staying byte-identical in BlastRadius.psm1.
3. The coordinator's recommended alternative applies: remove the runtime lookup helper and its error
   path, and supply the relation through a [scriptblock]-typed parameter, which the guard accepts.
   The seam must work for a caller that imports only the facade and for a caller that imports only the
   scheduling module, and it must not depend on import order or -Global imports. Parity with the Python
   scheduling module (which calls `conflicts` directly) is unchanged in behavior.
4. Keep the bundled mirror under extensions/drm-copilot/resources/claude-customizations/ byte-identical
   (copy, not edit) and every file at or under 500 lines (BlastRadiusScheduling.psm1 is 490 lines).
5. Do not weaken or delete any test. Existing tests that relied on the lookup helper may be updated
   only to pass the relation explicitly.

## Required verification (as CI runs it)

- Fail-before: run BlastRadiusScheduling.Tests.ps1 and BlastRadius.HistoricalRuns.Tests.ps1 alone in a
  fresh pwsh process before the fix and record the failure (expected to reproduce R1).
- Pass-after: a single Pester invocation over the whole tests/scripts tree with coverage enabled, in a
  fresh pwsh process, using the repository runsettings; FailedCount must be 0 (apart from any failure
  that is proven pre-existing on origin/main and unrelated), and the guard test must pass.
- Also re-run the two suites alone in a fresh process after the fix.
- PoshQC format and analyze clean; mirror hashes equal; line counts at or under 500.
- Do not check off AC-38; CI is re-run by the coordinator.
