# Stage E Deferred Wording (Stage C, Entry 0002)

Timestamp: 2026-11-07T11-36
Command: sh SCRATCH/issue-1097-e-run.sh issue-1097-e-replay.ps1 -Entry 0002-concurrent-review.md; sh SCRATCH/issue-1097-e-run.sh issue-1097-e-inventory.ps1 -Mode check -Reference SCRATCH/issue-1097-e-inventory-ref.p0.json
EXIT_CODE: 0
Output Summary:
  Ledger replay over 0002: EXIT_CODE 0
    ledger-valid=True rows=5
    entry=0002-concurrent-review.md entry-at-HEAD=True blocks=30 new-blocks=5
    REPLAY .claude/skills/execution-environment/SKILL.md blocks=5 equals-HEAD=True
    current-once-checked=117
    0001-patch-reverse-check-exit=1 (recorded only; reference at [P0-T3] is exit 1 on the two .github feature-review-workflow copies)
    0001-patch-moved-to-failing-by-this-commit=none
    failures=0
    exit=0
  Hold check: EXIT_CODE 0
    STRING EQUAL :: Plan must include Phase 0 with at least one baseline task.
    STRING EQUAL :: Phase 0 must include a baseline task.
    STRING EQUAL :: Phase 0 must also capture static baselines
    STRING EQUAL :: one baseline artifact per baseline command step
    STRING EQUAL :: each baseline step artifact MUST include:
    STRING EQUAL :: baseline command-step artifacts with at least:
    STRING EQUAL :: ### Baseline Evidence Output Summary (Required)
    STRING EQUAL :: If any required QA artifact or post-change coverage metric is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.
    STRING EQUAL :: Do not mark the audit PASS, fully compliant, or ready for merge when any required QA artifact or post-change coverage metric is missing.
    STRING EQUAL :: static baseline capture (format, lint, type check, and analyzer findings)
    STRING EQUAL :: No earlier figure is compared.
    STRING EQUAL :: N/A - no pre-change run
    STRING EQUAL :: Include explicit static baseline tasks
    STRING EQUAL :: canonical baseline location
    BASELINE-WORD ROSE :: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 26->31
    BASELINE-WORD files=57 fell=0 rose=1
    REPO-WIDE N/A EQUAL files=43
    failures=0
    exit=0

| # | Source plan | Deferred item | Disposition |
| --- | --- | --- | --- |
| W1 | `plan.2026-11-06T21-23.md`, `plan.2026-11-06T23-08.md`, `plan.2026-11-06T23-29.md` (`Mirror parity`) | Brief `## Test Isolation Checks` listing serial runs | Satisfied by #1094 (PR #1102): the section states the parallel gates and keeps serial tasks for debugging only. `## Test Isolation Checks` is not edited. |
| W2 | `plan.2026-11-06T23-29.md` | Brief `## Hook Execution Context`: the merge guard, its twin, both gates, the inert default, the three deny codes after `EPIC_MERGE_GATE_BLOCKED`, the checkpoints it reads, and D10 | Landed in this commit as one bullet in all six brief copies; entry `0002` gains its block |
| W3 | `plan.2026-11-06T23-29.md`, with stage D's R2 and R3 | Brief `## Command-Text Restrictions`: unbound merge text is denied with `REVIEW_GATE_HEAD_UNRESOLVED`; one plain `gh pr merge`; `git commit -F` | Landed in this commit; entry `0002` |
| W4 | `plan.2026-11-06T23-29.md` | Brief `## CI Shape and Required Checks`: the concurrent-review join and the withheld `merge_status: ci_green` | Landed in this commit; entry `0002` |
| W5 | `plan.2026-11-06T23-29.md` | Brief `## MCP Surfaces Run the Installed Extension`: installed MCP accepts a concurrent checkpoint the stop hook and CLI reject; the CLI `orchestrator-state` subcommand with `--require-complete` | Landed in this commit; entry `0002` |
| W6 | `plan.2026-11-06T23-29.md` | Brief `## Contract Tests That Pin Mirrored Files`: `concurrent-review-skill-contract.Tests.ps1` | Landed in this commit; entry `0002` |
| W7 | `plan.2026-11-07T00-22.md` (`Deferred wording (K3, K6)`) and entry `0003` | `atomic-plan-contract` `### Single-Pass Preflight`: the light-cycle paragraph | Pending: [P3-T3], entry `0003` |
| W8 | `plan.2026-11-07T00-22.md` and entry `0003` | Brief `## MCP Surfaces Run the Installed Extension`: invariant 8 and the light route | Pending: [P3-T3], entry `0003` |
| W9 | `plan.2026-11-07T00-22.md` and entry `0003` | Brief `## Contract Tests That Pin Mirrored Files`: `light-remediation-skill-contract.Tests.ps1` | Pending: [P3-T3], entry `0003` |

Each brief bullet is written once in `.claude/skills/execution-environment/SKILL.md` and copied byte for byte to its five copies; the six copies hash equal. The bullets carry no line number, no commit identifier, no removed-run token of `test_brief_copies_carry_no_removed_run_tokens`, and no `PGW-SWEEP-SURFACES` token.
