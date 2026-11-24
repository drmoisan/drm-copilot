# Preflight Fixes - docs-review-cadence (#1220), round three

Timestamp: 2026-11-23T06-52
Plan: .dev/active/1220-docs-review-cadence/plan.2026-11-23T00-39.md
Command: in-place task-text edits during single-pass preflight (no task added, removed, or reordered)
EXIT_CODE: 0
Output Summary: 1 trivial fix applied; no substantive defect. The round-two defect is resolved.

## Fixes

1. [P3-T2] | missing test row for behavior the task already owns | The `Tests` line now states that the six-field template test also asserts that the front-matter line directly after the `last_reviewed` line has key `review_due`. Reason: the spec acceptance criterion requires `review_due` "on the line directly after `last_reviewed`", P3-T2 already implements that insertion and already edits that test, and the current test parses keys into a hashtable, so no existing or planned assertion fails if the line position is wrong. Classified trivial on the precedent that a missing test row for behavior owned by the same task, in the same test file, for the same cited spec criterion is fixed in place; the orchestrator may review the classification.

## Round-Two Defect Re-Checked

- [P3-T2, P4-T5] resolved. Verified against the tree: `Get-HarnessSkillMirrorFileMap` (`scripts/harness-generation/HarnessSkillMirror.psm1`) writes one rendered text to `.claude/skills/<name>/` and its `claude-customizations` bundle path only; the three `find` entries of `scripts/harness-generation/sources/skills/docs-author-page.substitutions.json` all target `SKILL.md` (sections `## When to Use This Skill`, `## Prerequisites`, and step 2), so templates are rendered only through `ConvertTo-HarnessGeneratedText` (LF, leading BOM removed). `config/harness-parity-matrix.json` entry `codex:skill:docs-author-page` is `shared`. Current SHA-256 values: `.claude` and `claude-customizations` `SKILL.md` are equal, `.agents` and `codex-and-agents-customizations` `SKILL.md` are equal, the two pairs differ, and each of the eight templates has one hash across the four roots. `docs-authoring-roles.Mirrors.Tests.ps1` compares `ClaudeBundle` with `Claude` and `CodexBundle` with `Codex` for `SKILL.md`, and one distinct hash across four roots for each template. The revised P3-T2 and P4-T5 assertions match this behavior.
- Observation: the working-tree copies of the `.agents` templates and `SKILL.md` currently carry CRLF line endings; P3-T2 already requires each edited `.agents` file to have LF endings and no BOM, which keeps the generator output, the source, and the byte-copied Codex bundle equal.
