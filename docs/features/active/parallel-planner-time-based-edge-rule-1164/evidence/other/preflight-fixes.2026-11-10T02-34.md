# Preflight Fixes (correction plan)

Timestamp: 2026-11-10T02-34
Plan: docs/features/active/parallel-planner-time-based-edge-rule-1164/remediation-plan.2026-11-10T02-18.md
Validator: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan> - exit 0, "plan validation passed".

## Fixes

1. [P2-T11] | task-ordering clarification (validator-blind) | The `[P2-T11]` check-off of the plan file is necessarily made after the task's own commit, so it would leave a change under `<FEATURE>/` and contradict the porcelain acceptance once recorded. Added one sentence: the check-off is committed and pushed in one follow-up commit with a plain `git push`, and the acceptance is read again after that push. The asserted conditions (porcelain clean under the four paths; `HEAD` equals `@{u}`) are unchanged.

## Observations (no change made)

- The item checkpoint already selects route `large`, not terminal, so the batch-budget exemption the Execution Terms bullet requires holds before Phase 1.
- A SCRATCH probe of the P0-T2 population on the unmodified tree reported 64 Python/bash/TypeScript findings and 26 PowerShell findings, all inside the files named in P1-T1 to P1-T7, and covering the 13 Python functions; the expect-fail claim of P0-T2 holds.
- Line-count headroom: parallel_manifest_contract.py 580 of 600, Invoke-ParallelAdmission.ps1 678 of 700, _parallel_state_records.py 500 of 700 (DEC-1164-7), _blast_radius_scheduling.py 641 of 700.
- tests/scripts/claude-runtime/parallel-scheduling-rule-wording.Tests.ps1 reads the script-level help through GetHelpContent(), so in-function help does not affect it.
