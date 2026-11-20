# Preflight Fixes: Plan B (Issue #1025), Round 2

Timestamp: 2026-10-31T15-54
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/owner-decision-plan.md
Preflight signal: PREFLIGHT: REVISIONS REQUIRED

Validators after the fixes: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exit 0 (`plan validation passed`); MCP `validate_orchestration_artifacts` (`plan`) `ok: true`.

## Round-1 Defects Re-Checked

1. `[P2-T8]` / `Y3` (`ExcludedTouched`): resolved. Y1 requires `git status --porcelain` to list no excluded path, Y3 records `PlanBStart` from `git rev-parse HEAD`, and P2-T8 counts excluded matches only among `git diff --name-only PlanBStart` plus porcelain paths, so plan A outputs committed before `PlanBStart` are not counted. `SpecExcludedTouched` against `MB` is satisfiable: every path in spec `### Excluded paths (must not be edited by this child)` is also in plan A `## Excluded Paths`, and neither plan writes any of them. The anchored diff has its porcelain companion (G8b).
2. Rules 1 to 3 / `[P1-T2]` (override to `shared` or `generated` without a derivation rule): resolved for those two dispositions. Rule 3a counts every such row in `OverridesWithoutRule` before any write, and P1-T2 asserts `OverridesWithoutRule: 0`. Two related gaps remain for overrides to other values; see the substantive defects below.

## Language Classification Check

Owner rule (no new Python; existing Python run or call only; pushed-down code PowerShell or bash; TypeScript only for MCP tools and extension commands; E2 analyzer exception): compliant. Plan B creates no `.py` file (P2-T6), runs existing Python only, pushes down Markdown contracts only (no executable code), uses session-only PowerShell helpers and `sh` launchers that are never committed, adds no TypeScript and does not use E2.

## Fixes Applied (task text and preamble only; no task added, removed or reordered)

1. `## Citations Re-Checked at Phase 0`, template entry | citation path | The second and third template file names lacked the `docs/features/templates/policy_audit/` prefix, so a literal `git ls-files --error-unmatch` from the repository root at Y2 would not match them. Expanded both to full repository-relative paths. The cited files are unchanged.
2. `## Execution Preconditions (Orchestrator-Checked)` | precondition consistency | Y1 and the `PlanBStart` design require the owner's `Approval` edits to be committed before plan B starts, but the orchestrator precondition list did not state it. Added a precondition line that restates the existing Y1 condition. No assertion changed.

## Substantive Defects Returned (not fixed)

1. `## Decision Application Rules`, rules 1, 3, 3a and 9 / `[P1-T2]`, `[P1-T3]`: an `## Owner Overrides` row that sets `native` on an entry plan A wrote `generated` or `shared` keeps that entry's `target_paths` and `generated_from` (rule 1 leaves unnamed values as plan A wrote them, rule 3 removes them only for `dropped`, and rule 3a counts only `shared` and `generated`). For an entry bootstrapped with `pending-source:<kind>` (agents, path-scoped rules, MCP servers), rule 9 then never settles it: the entry stays `provisional` with a placeholder that no child replaces, because a `native` entry has no generated source. The acceptance conditions still pass, so the committed matrix records an owner-approved `native` decision as permanently unsettled and carries mirror or generator targets that contradict spec `### Disposition Semantics`.
2. `## Decision Application Rules`, rule 6 versus rules 1, 3 and 3a / `[P1-T3]`: rule 6 sets every `copilot:agent:*` entry to `dropped` when both E3 observations are `yes`, and otherwise says it "stays `generated`". Rule 6 runs after the owner's overrides (rules 1 and 3), so it either overwrites an owner override on a `copilot:agent` entry, or ("stays `generated`") is undefined when the owner set `native` or `dropped`. The plan does not state whether the owner decision or the E3 result takes precedence.
