# Preflight Fixes — Issue #1221 (round 2)

Timestamp: 2026-11-23T06-34
Plan: .dev/active/1221-docs-family-gate-and-ia/plan.2026-11-23T00-39.md
Signal: PREFLIGHT: ALL CLEAR
Validators after the fixes: installed MCP `validate_orchestration_artifacts` (plan) ok; branch-current `scripts.dev_tools.validate_orchestration_artifacts plan` exit 0.

## Fixes applied in place (task text only; no task added, removed, or reordered)

1. [P0-T1] | stale anchor (scope base ref) | The merge-base derivation now uses `origin/epic/documentation-estate-families-integration` and `HEAD`. The epic manifest names that branch as `integration_branch`, and this child merges into it. A merge base with `origin/main` would include the sibling #1218 changes in every scope diff. The recorded check is otherwise unchanged.
2. [P0-T4] | validator-blind class (success-case output source) | The `jest-extension` suite runs `node run-jest.cjs` with `collectCoverage: false` and the reporters `lcov` and `text-summary`, so per-file figures appear only in `extensions/drm-copilot/coverage/lcov.info` of a `--coverage` run. The task now names that run mode and file. The asserted values are unchanged.
3. [P1-T2] | unsatisfiable literal wording | "The resulting set must contain at least" conflicted with the task's own drop rule: `DocsCompleteIntegration.Tests.ps1` and `DocsHashLineEnding.Tests.ps1` take their profile only from `New-DocsLedgerTestProfile`, and `docs-estate-workflow.EndToEnd.Tests.ps1` runs no docs-complete validation (it uses a literal receipt text). The text now requires the inventory to list those four files, each with its disposition, and a dropped file to be listed as unchanged with the reason. AC-17 requires this listing ("The plan lists each fixture found with its disposition").
4. [P1-T3] | anchor clarification | The AC-7 non-`.md` case now names `.png`, `.txt`, and `.MD`. This is the same spec `### Edge cases` bullet that AC-7 is drawn from ("The suffix comparison is ordinal, so `.MD` does not match"). Without the clarification, no named case would fail under a case-insensitive suffix comparison.
5. [P2-T1] | anchor clarification (call route) | The existing summary-line case for a profile without families now names its route: the output of `ConvertTo-DocsCoverageReportLine` over a report that carries the `families` section. The asserted literal `families: required=0 present=0 missing=0 not_applicable=0 legacy_exclusions=0` is unchanged. Without this route, no named case would fail if the delegating line required by spec Decision 9 and AC-14 were missing.
6. [P2-T2] | placeholder in asserted token | "heading `Result` with a family token" left the asserted token to the executor. It now names `` `required_families` ``.
7. [P2-T2] | scope clarification | "the new text contains no `.claude/` or `.agents/` path" is now scoped to the normalized `Steps` and `Result` section text. The Claude copies keep `.claude/` paths in `## When to Use This Skill` and `## Prerequisites` (`../../../.claude/agents/docs-architect.md`, `.claude/lib/docs/`), so a whole-file reading could not pass.
8. [P3-T3] | validator-blind class (success-case output source) | Same as fix 2, for the final Jest gate.
9. [P3-T5] | stale anchor (scope base ref) | Same base-ref correction as fix 1. Without it, the "no file outside the plan's file set" check would also list the #1218 files.
10. [P3-T5] | scope clarification | "the plan's file set" now names its members: the files named in the plan's tasks, the fixtures listed in `r1-fixture-inventory`, the feature folder, and the promoted record `.dev/potential/promoted/2026-11-23-docs-family-gate-and-ia.md`. Evidence files and AC check-offs written under the feature folder would otherwise fail the check.
11. [P3-T6] | stale anchor (scope base ref) | The self-review diff now names the same integration-branch merge base as fix 1.

## Self-check

Each fix was checked against the tonality rule and the design-level plan contract. No line-number or commit citation was introduced, and no task identifier moved. In fixes 4 and 5, each assertion still checks the value it checked before; the fix only fixes the case or route that the spec already names.
