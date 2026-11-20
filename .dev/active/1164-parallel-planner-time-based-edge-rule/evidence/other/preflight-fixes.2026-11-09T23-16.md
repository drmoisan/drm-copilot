# Preflight Fixes — Issue #1164 (round 2)

Timestamp: 2026-11-09T23-16
Plan: docs/features/active/parallel-planner-time-based-edge-rule-1164/plan.2026-11-09T16-56.md
Directive: PREFLIGHT VALIDATION ONLY (second and final round; single pass; task text only; no task added, removed, reordered, or checked)
Prior record: docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/other/preflight-fixes.2026-11-09T22-57.md (unchanged)
Validator (branch Python CLI, plan subcommand, module form, VIRTUAL_ENV unset): passed before and after the fixes, EXIT_CODE 0.
Validator (installed MCP): ok after the fixes.

## Round-one defects re-checked

- [P5-T4] B8.3 elements: resolved. Nine element tokens are quoted in P5-T1, each is a substring of the verbatim B8.3 paragraph after backtick removal, none occurs in any B8.2 file today, and each case asserts the token's index is after the pinned sentence in all twelve files.
- [P5-T1, P5-T2, P4-T2] B5.3, B6.1, B6.2, B6.3, B6.5, B10.4: resolved. Each rule has a quoted token in the editing task and a P5-T4 case (surface, paragraph, or `.DESCRIPTION` case) for the source and its mirror. The `.DESCRIPTION` route matches the existing `GetHelpContent().Description` pattern in `Invoke-ParallelAdmission.Tests.ps1`.

## Fixes

1. [P5-T1] | literal formatting (element token omitted the tolerance qualifier) | The element token "the rule is exactly merge time greater than gain" became "At tolerance_percent 100 the rule is exactly merge time greater than gain". The token is taken from the same verbatim paragraph, so removing the B8.3 qualifier "at tolerance_percent 100" now fails a case. The count of nine element tokens is unchanged.
2. [P5-T2] | validator-blind class: absence assertion against text the task did not name | `parallel-plan` `### Seeding procedure` step 4 contains "the tolerated extra fields `hard`, `cost`, and `benefit`", which matches the P5-T4 absence literal "tolerated extra fields hard, cost, and benefit" once backticks are removed. The task now states that step 4 also drops that wording.
3. [P5-T3] | stale statement in an edited paragraph | The `parallel-orchestrate` `**Precedence.**` paragraph says the Python orchestrator-state validator "reads `conflict_edges[]` only". After P3-T1 that is inaccurate. The task now rewrites that sentence to say the validator checks the shape of `precedence[]` entries when present but not their ordering.
4. [P5-T1] | stale statement in an edited section | The rule's `**Known gap (Layer 2).**` paragraph in `## Prepared-Item Admission (issue #1047)` says the Python validator "does not check precedence". The task now applies the same shape-but-not-ordering wording there. No test pins either sentence.
