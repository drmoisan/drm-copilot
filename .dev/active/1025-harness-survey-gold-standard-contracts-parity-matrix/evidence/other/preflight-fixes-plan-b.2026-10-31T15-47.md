# Preflight Fixes: Plan B (Issue #1025), Round 1

Timestamp: 2026-10-31T15-47
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/owner-decision-plan.md
Preflight signal: PREFLIGHT: REVISIONS REQUIRED

Validators after the fixes: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exit 0 (`plan validation passed`); MCP `validate_orchestration_artifacts` (`plan`) `ok: true`.

## Fixes Applied (task text and preamble only; no task added, removed or reordered)

1. `## Decision Application Rules`, rule 0 | wording consistency | Rule 0 listed only two selection methods (exact `id`, or `ecosystem`/`kind`/`name`), but rules 4, 7 and 9 select entries by the runbook path in `decision_ref`. Added "or by the runbook path in its `decision_ref` (rules 4, 7 and 9)". The id-matching constraint is unchanged.
2. `## Language Classification` | classification completeness | The scratch row named four scripts only. Extended it to cover any other `SCRATCH/issue-1025-*.ps1` helper (for example the P1-T4 contract check), and added a row for the session-only `sh` launchers that the `execution-environment` skill route uses for PowerShell runs. No permitting clause changed; E2 is still unused.
3. `[P2-T1]` | evidence hygiene literal | Added "each file recorded by its repository-relative path (the formatter prints absolute paths, which evidence never records)", matching plan A P9-T1. The asserted `Already formatted:` / `Formatted:` values are unchanged.
4. `## Pre-Mortem`, `Evidence` bullet | inaccurate claim | The bullet stated that every plan B artifact name differs from plan A's, but `self-review` is shared because the plan contract fixes that name. Added a sentence stating the exception and why the latest-file rule still selects plan B's file.

## Substantive Defects Returned (not fixed)

1. `[P2-T8]` and entry check `Y3`: `ExcludedTouched: 0` cannot be met. `git diff --name-only MB` lists every plan A output that plan B places under `## Excluded Paths` (`quality-tiers.yml`, `scripts/harness/**`, `tests/scripts/harness/**`, `config/harness-parity-matrix.schema.json`, `<FEATURE>/runbooks/**`, `<FEATURE>/survey/difference-approval.md`, `plan.2026-10-30T17-06.md`). Path lists alone cannot show whether plan B edited a path that was already changed on the branch.
2. `## Decision Application Rules`, rules 1 to 3 / `[P1-T2]`: an `## Owner Overrides` row that sets `shared` or `generated` on an entry that rule 2 does not cover (any non-skill entry, or a `copilot:skill` entry) gets no `target_paths` or `generated_from`, so `Violations: 0` fails. No stop rule covers this case.
