# Preflight Fixes — Remediation Plan Cycle 1 (Issue #1066)

Timestamp: 2026-11-04T01-14
Plan: docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/remediation-plan.2026-11-04T01-03.md

## Fixes

1. [P4-T6] | literal-formatting defect that does not change what is asserted | The acceptance sentence "no suite named under `## Existing Test Dispositions` is listed" also covered `TARGET` and `GUARD`, which that section names and which the preceding sentence requires to be listed. Changed to "no suite named under `## Existing Test Dispositions` other than `TARGET` and `GUARD` is listed". The asserted path set is unchanged.

## Probes Run During Preflight (no tree edit)

- SCRATCH/issue-1066-probe-rd.ps1 (RD2 form p mechanism, nested Invoke-Pester with the DD2 configuration): control (sentinel, probe) probe value 41; synthetic leak container (one It assigning 0) between sentinel and probe gives probe value 0; current TARGET (DD1 applied) between sentinel and probe gives probe value 41 with 35 passed TARGET tests. The form p assertion can fail and the precondition holds on this host.
- SCRATCH/issue-1066-probe-rd.ps1 -Rd1Only (fresh process, RD1 mechanism): a Describe AfterAll that removes `Function:\Import-ScriptFunction` through `$ExecutionContext.SessionState.InvokeProvider.Item` and calls `Remove-Module -Name Microsoft.PowerShell.Archive` leaves neither the function, the module, nor `Function:\Expand-Archive` after the nested run.
- Victim search preview (`git grep -l` over `tests/` for the five P0-T3 patterns): matches are TARGET, TestHelpers.ps1, and the four suites named under `## Existing Test Dispositions`; no other suite matches.

## Validator

- mcp__drm-copilot__validate_orchestration_artifacts (plan): ok.
- poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>: plan validation passed, exit 0.
