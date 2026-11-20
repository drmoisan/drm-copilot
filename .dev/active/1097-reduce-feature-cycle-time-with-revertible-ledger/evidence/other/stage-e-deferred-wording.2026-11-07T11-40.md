# Stage E Deferred Wording (Stage D and Review Item N4, Entry 0003)

Timestamp: 2026-11-07T11-40
Command: sh SCRATCH/issue-1097-e-run.sh issue-1097-e-replay.ps1 -Entry 0003-light-remediation.md; sh SCRATCH/issue-1097-e-run.sh issue-1097-e-inventory.ps1 -Mode check -Reference SCRATCH/issue-1097-e-inventory-ref.p0.json
EXIT_CODE: 0
Output Summary:
  Ledger replay over 0003: EXIT_CODE 0
    ledger-valid=True rows=5
    entry=0003-light-remediation.md entry-at-HEAD=True blocks=46 new-blocks=9
    REPLAY .claude/skills/atomic-plan-contract/SKILL.md blocks=1 equals-HEAD=True
    REPLAY .agents/skills/atomic-plan-contract/SKILL.md blocks=1 equals-HEAD=True
    REPLAY .github/skills/atomic-plan-contract/SKILL.md blocks=1 equals-HEAD=True
    REPLAY .claude/skills/execution-environment/SKILL.md blocks=2 equals-HEAD=True
    REPLAY .claude/skills/remediation-handoff-atomic-planner/SKILL.md blocks=1 equals-HEAD=True
    REPLAY .agents/skills/remediation-handoff-atomic-planner/SKILL.md blocks=1 equals-HEAD=True
    REPLAY .github/skills/remediation-handoff-atomic-planner/SKILL.md blocks=1 equals-HEAD=True
    REPLAY .github/agents/orchestrator.agent.md blocks=1 equals-HEAD=True
    current-once-checked=126
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

This artifact supersedes `stage-e-deferred-wording` of [P3-T2] for the rows below; W1 to W6 stand as that artifact records them.

| # | Source | Deferred item | Disposition |
| --- | --- | --- | --- |
| W7 | `plan.2026-11-07T00-22.md` (`Deferred wording (K3, K6)`) and entry `0003` | `atomic-plan-contract` `### Single-Pass Preflight`: a light cycle has no remediation plan and no preflight, and an executor stop before the first task converts it to the design chain | Landed as its own paragraph after the `At most one return.` paragraph of each of the three sources, copied to the three bundles; the `.claude` sentence naming proportionate cycles is unchanged; entry `0003` gains one block per source |
| W8 | `plan.2026-11-07T00-22.md` and entry `0003` | Brief `## MCP Surfaces Run the Installed Extension`: invariant 8 reaches installed MCP only after its release; a Claude run validates through the CLI `orchestrator-state` subcommand; on Codex the light path is unavailable | Landed as one bullet in all six brief copies; entry `0003` |
| W9 | `plan.2026-11-07T00-22.md` and entry `0003` | Brief `## Contract Tests That Pin Mirrored Files`: `light-remediation-skill-contract.Tests.ps1` | Landed as one bullet in all six brief copies; entry `0003` |
| W10 | Stage D review item N4 (`code-review.2026-11-07T10-50.md`) | The `Exactly one mode line` bullet of the three `remediation-handoff-atomic-planner` sources and the mode-line sentence of `.github/agents/orchestrator.agent.md` named two `Remediation-Mode` values | Each gains one closing sentence naming `Remediation-Mode: light`; the existing sentences are byte-identical; the four bundles are re-copied; entry `0003` gains one block per file with `Prior` the line before this task |

Not edited: `.codex/prompts/feature-review-remediate.md` (unchanged from `HEAD`), which stays at two modes because the light path is unavailable on Codex.

Wording note: the W10 handoff sentence states that a light cycle that falls back to R1 has its line rewritten to `Remediation-Mode: proportionate` or `Remediation-Mode: design`, because the orchestrate skill rewrites to either value when the route lacks invariant 8 and to design when the executor stops before its first task.

Reverse-patch result (recorded only): no file moved to failing in this commit, so `## Revert Steps` step 1 of `0003` gains no ordering statement.
