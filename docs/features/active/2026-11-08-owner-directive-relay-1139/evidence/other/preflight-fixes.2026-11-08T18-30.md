# Preflight Fixes (revision 0.4 preflight pass)

Timestamp: 2026-11-08T18-30
Plan: docs/features/active/2026-11-08-owner-directive-relay-1139/plan.2026-11-08T12-32.md
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-11-08-owner-directive-relay-1139/plan.2026-11-08T12-32.md
EXIT_CODE: 0
Output Summary: The branch-current Python CLI and the installed MCP validator both passed the plan before the fix below; the Python CLI was re-run after it. One trivial fix was made in task text. One substantive defect (design check, outside the backward-compatibility area) is reported in the preflight return and is not fixed here.

## Fix 1

- Task: [P1-T1]
- Defect class: task-ordering ambiguity in an acceptance condition (the asserted value is unchanged)
- Before: "the task commit changes exactly one line of `FEATURE/spec.md` (`git show --numstat HEAD -- FEATURE/spec.md` reports 1 added and 1 deleted; ..."
- After: "the task commit changes exactly one line of `FEATURE/spec.md` (read after the task commit, while it is `HEAD` and before the push: `git show --numstat HEAD -- FEATURE/spec.md` reports 1 added and 1 deleted; ..."
- Basis: the `-State <psobject>` signature is still present in the spec `## API / Validator Surface` paragraph, so the P1-T1 commit carries a one-line spec edit of its own. The condition is satisfiable only when read with that commit at `HEAD`. Read before the commit, `HEAD` is the P0-T3 evidence commit, which does not touch `spec.md`, and the command prints no row. The current `HEAD` (the revision 0.4 plan commit) reports 1 added and 1 deleted for `spec.md`, which confirms the command form.

## Backward-compatibility observations (no change made)

- No tracked file outside the feature folder and its promoted lifecycle record contains `owner_directive`, so no existing checkpoint, fixture, or test carries either key.
- SCRATCH probe (PowerShell 7): `ConvertFrom-Json` decodes an escaped `owner_directives` key to `owner_directives` in `PSObject.Properties.Name`, and it rejects a checkpoint that holds both `Owner_Directives` and `owner_directives` (keys that differ only by case). That checkpoint is already blocked today as invalid JSON, so the ordinal eligibility check adds no new outcome for it.
- No validator in `.claude/lib/orchestrator-state/` or `scripts/dev_tools/validate_orchestrator_state*.py` rejects unknown top-level keys.
- The hook test files that enumerate this hook (`subagentstop-uncaught-error`, `hook-dependency-failure.Claude`, `hook-dependency-failure.SpecialCases`, `subagentstop-envelope-orchestrator-family.Registration`, `parallel_orchestrator_surface_expectations.py` `HOOK_COMMAND_FRAGMENTS`) assert prefixes, registrations, and command fragments that P2-T1 does not change.
