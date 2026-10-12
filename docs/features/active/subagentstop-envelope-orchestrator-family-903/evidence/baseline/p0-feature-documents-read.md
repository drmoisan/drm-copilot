# Feature Documents Read ([P0-T4])

Timestamp: 2026-10-11T23-45

Files Read:
- docs/features/active/subagentstop-envelope-orchestrator-family-903/spec.md
- docs/features/active/subagentstop-envelope-orchestrator-family-903/issue.md
- docs/features/active/subagentstop-envelope-orchestrator-family-903/research/research.2026-10-11T15-15.md
- docs/features/epics/subagentstop-envelope/epic.md
- docs/features/active/subagentstop-envelope-core-897/spec.md (E1_SPEC_PATH on HEAD)
- docs/features/active/subagentstop-envelope-orchestrator-family-903/plan.2026-10-11T07-59.md

AC Inventory (unchecked checkbox lines under `## Acceptance Criteria` in spec.md, source order; identifier, line, first twelve words):
1. AC-1: line 349 - "Upstream gate passed before any production or test edit: after `git fetch origin`, `git"
2. AC-2: line 350 - "`validate-orchestrator-output.ps1`, with `stop_hook_active` absent from the stdin envelope, blocks with exit 2"
3. AC-3: line 351 - "`validate-executor-output.ps1`, with `stop_hook_active` absent from the stdin envelope, blocks with exit 2"
4. AC-4: line 352 - "`validate-planner-output.ps1`, with `stop_hook_active` absent from the stdin envelope, blocks with exit 2"
5. AC-5: line 353 - "`validate-required-artifact-output.ps1`, with `stop_hook_active` absent from the stdin envelope, blocks with exit 2"
6. AC-6: line 354 - "For each converted validator, with `stop_hook_active` absent: (a) a Pester row supplies `-InputText`"
7. AC-7: line 355 - "`rg -n \"CLAUDE_HOOK_INPUT\"` over the six E2 production files returns no match."
8. AC-8: line 356 - "`rg -n \"\$payload\.output|Properties\.Name -contains 'output'|...\"` over the same production file list returns"
9. AC-9: line 357 - "`rg -n \"\bexit 1\b|Write-Error\"` over the same production file list returns no match."
10. AC-10: line 358 - "A failed load of the E1 helper is recorded through `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1'` and"
11. AC-11: line 359 - "#787 CR-1 fixed: `validate-orchestrator-output-resolution.ps1` uses `-contains` for both property-name checks in `Find-OrchestratorOutputRunSignalValue`,"
12. AC-12: line 360 - "#787 CR-3 fixed: a new row in `validate-orchestrator-output-resolution.Tests.ps1` mocks `Resolve-OrchestratorOutputCheckpointPath` to throw"
13. AC-13: line 361 - "#787 CR-7 fixed: `rg -n \"One subprocess call\"` over the orchestrator main file and routing sibling returns"
14. AC-14: line 362 - "#786 double import fixed: `rg -n \"OrchestratorState\.psm1'\)\" .claude/hooks/validate-orchestrator-output.ps1` matches only the import"
15. AC-15: line 363 - "#786 FailClosed nit fixed: `rg -n \"OrchestratorOutputResolverImportFailure|OrchestratorOutputWaveBarrierImportFailure\"` over the FailClosed suite returns no match,"
16. AC-16: line 364 - "Split done: `.claude/hooks/validate-orchestrator-output-routing.ps1` defines `Test-OrchestratorCheckpointStructure` and `Invoke-RoutingContractValidation`, `.claude/hooks/validate-orchestrator-output.ps1` no"
17. AC-17: line 365 - "Every production and test file added or changed by E2 is at or under 500"
18. AC-18: line 366 - "Line coverage is >= 85% for each changed or added PowerShell production file (including"
19. AC-19: line 367 - "Each changed or added production file under `.claude/hooks/` has a byte-identical mirror under"
20. AC-20: line 368 - "Frontmatter registrations are consistent: `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` passes, and `git diff --name-only"
21. AC-21: line 369 - "No Python invocation in E2 files: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes, the AST no-Python row"
22. AC-22: line 370 - "Re-entry behavior matches the re-entry table. For every non-S1 row (O-1 to O-15,"
23. AC-23: line 371 - "Out-of-scope files are untouched: `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD` lists no E3-owned or E4-owned"
24. AC-24: line 372 - "Full PowerShell toolchain is clean in a single pass over the changed PowerShell files:"
25. AC-25: line 373 - "Pure-entry seam and exit placement conform to E1 consumer policies 3 and 5: an"

Entry count: 25 (AC-1 to AC-25 in source order).
