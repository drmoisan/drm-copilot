# Preflight Fixes (Issue #1028)

Timestamp: 2026-10-31T04-29
Plan: docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/plan.2026-10-30T18-30.md

Validator after fixes: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exited 0. No task was added, removed or reordered.

1. [P0-T9] | literal-formatting / tool route | `Invoke-PoshQCFormat` in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` has no check switch; the task now states that check mode replaces its `-WriteFile` script block with one that records each path and writes nothing.
2. [P1-T3] | validator-blind class (tracked-file listing of a file the plan creates) | `scripts/dev_tools/check_quality_tiers.py` discovers projects from `git ls-files`, which does not list the untracked module created in [P1-T1], so the new entry would report QT007. The acceptance now stages `scripts/harness-generation/HarnessGeneration.psm1` with `git add` before the checker runs. The asserted outcome (exit 0, no QT007 or QT008) is unchanged.
3. [P1-T6] | evidence filename | "appended to the phase1-pester evidence" replaced by a new `<FEATURE>/evidence/qa-gates/phase1-pester.<timestamp>.md`, per the write-time filename rule.
4. [P1-T9] | literal-formatting (pathspec) | the task text asserts both bundle copies are unchanged, but the `git diff` pathspec named only the two root files; the two bundle paths (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`, `extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json`) were added.
5. [P3-T1] | stale anchor (frontmatter key list) | every current `.github/instructions/*.instructions.md` carries `description:`, and the spec `## Inputs / Outputs` compatibility rule keeps the frontmatter keys consumers read; the Copilot frontmatter list now reads optional `name:` and `description:`.
6. [P3-T3], [P3-T5] | stale anchor (task placement) | `DELIBERATE_UNCONDITIONAL_RULES` in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` is `general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`, `tonality.md`. Three of those sources are created in [P3-T3], not [P3-T5]. [P3-T3] now declares `claudeUnconditional: true` for its three members and [P3-T5] for `quality-tiers` only.
7. [P3-T9] | citation completion | child 1's schema (`### Parity Matrix: Feature Entry`) requires `target_paths` when `disposition` is `generated`; the rule-skill entry update now sets `target_paths` to `.agents/skills/<name>/SKILL.md` and `owner_child` 3. The acceptance (child 1 repository gate passes) is unchanged.
8. [P4-T3], [P4-T5] | stale anchor (task placement) | alphabetically, `epic-orchestrator` falls in the first third and `pr-author` in the second third of the 21 agents present in both trees at `HEAD`; the protected-agent names moved from [P4-T5] to [P4-T3] ("in whichever third they fall"), which [P4-T4] and [P4-T5] inherit.
9. [P6-T5] | evidence path spelling | the second and third artifact names now carry the full `<FEATURE>/evidence/qa-gates/` prefix.
10. [P6-T13] | wording (AC tracking rule) | "every checked item cites its evidence file" could be read as editing criterion text, which the acceptance-criteria-tracking skill forbids; the citation now goes in the executor's AC status summary and only `- [ ]` changes to `- [x]`.
