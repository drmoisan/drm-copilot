# Preflight Fixes: remediation plan cycle 1

Timestamp: 2026-11-18T12-04
Plan: docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/remediation-plan.2026-11-18T11-45.md
Command: single-pass preflight review; branch-current validation with `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`
EXIT_CODE: 0
Output Summary: three trivial defects fixed in task and preamble text; no task added, removed, or reordered; no substantive defect. Plan validation passed before and after the fixes.

## Fixes

1. `## Decisions` D1 | citation correction | The reason stated that the Codex target keeps "only" the remediation-cycle, review-outcome, concurrent-review key, and human-interaction invariants. The Codex target's `sections` array in `scripts/harness-generation/sources/rules/orchestrator-state.json` also lists `head-2`, `foreign-schema-warning-do-not-copy-verbatim`, `portable-handoff-projection-invariants`, `scope-and-backward-compatibility`, and `enforcement-2`. The sentence now names those sections. The decision and its conclusion are unchanged.
2. `[P1-T4]` | literal-formatting correction | The N/A citation read the changed-file set from `git status --porcelain` alone, which lists nothing once the earlier tasks are committed (commit after each completed step). The citation now reads `git diff --name-status REM_BASE HEAD` together with `git status --porcelain`, the same union `[P1-T6]` uses. The asserted file set is unchanged.
3. `[P1-T3]` | citation addition | Named the existing test `tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1`, which asserts the `## Release-Commit Allowance Scope` heading in `.claude/rules/orchestrator-state.md` and its bundle copy, with disposition unchanged because both files stay byte-identical. No assertion changed.

## Read-only verification performed during preflight (no source edited)

- Generator check mode, `-Surface rules` and `-Surface all`, on the unchanged tree: exit 1, two findings, `DRIFT .claude/rules/orchestrator-state.md (content differs)` and `DRIFT extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md (content differs)`; no other path.
- In-memory render through `Get-HarnessRuleSection` and `ConvertTo-HarnessRuleTargetText` with the section spliced before the `enforcement` marker of the source body and the key inserted before `enforcement` in the Claude `sections` array: the Claude render equals the committed `.claude/rules/orchestrator-state.md` byte for byte, and the Codex render equals the committed `.agents/skills/orchestrator-state/SKILL.md` byte for byte. Helper scripts were stored under SCRATCH.
