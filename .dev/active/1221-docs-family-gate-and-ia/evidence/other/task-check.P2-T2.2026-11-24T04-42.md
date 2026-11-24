# Task Check - P2-T2 (Issue #1221)

Timestamp: 2026-11-24T04-42
Command: sh SCRATCH/issue-1221-gen-check.sh (Invoke-HarnessGeneration.ps1, write mode, then -Check); cp .agents source to its bundle copy; sh SCRATCH/issue-1221-static-ps.sh check <test>; sh SCRATCH/issue-1221-pssa-one.sh <test>; sh <worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <5 files>
EXIT_CODE: 0
Output Summary: Generator `-Check` reports `harness-generation: no drift`; format 0 files needing format and analyzer 0 findings on the edited test file; Pester selection 193 passed, 0 failed (5 shards, exit 0).

## Changed Files

- `.agents/skills/docs-plan-ia/SKILL.md` (source): new step 7 in `## Steps`, after the element-assignment steps, naming `required_families`, the coverage `families` section, `SECURITY.md`, `CODEOWNERS`, `exclusion`, and `legacy_exclusions`; a family paragraph in `## Result`. Existing steps 1 to 6 and the existing Result paragraph are unchanged.
- `.claude/skills/docs-plan-ia/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-plan-ia/SKILL.md`: written by `Invoke-HarnessGeneration.ps1` (not hand-edited); byte-identical to each other.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-plan-ia/SKILL.md`: the generator write did not refresh this copy, so it was copied from the `.agents` source (spec Decision 18 leaves the writer open); generator `-Check` then reports no drift.
- `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1`: new `Describe 'docs-plan-ia family-planning step (issue 1221)'` over the four roots of `Get-DocsAuthoringSkillRoot` with the Steps token row, the Result token row, `It 'places the family step after the element-assignment step in the Steps of <Path>'`, and a row asserting that the Steps and Result sections name no `.claude/` or `.agents/` path.

## Selection and Rule

- Plan P2-T2 acceptance: `docs-authoring-roles.WorkflowText.Tests.ps1`, `docs-authoring-roles.Skills.Tests.ps1`, `docs-authoring-roles.Registration.Tests.ps1`, `DocumentationEstateOnboarding.Tests.ps1`, `HarnessGeneration.RepoGate.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE | Result |
|---|---|---|---|
| Generator write | Invoke-HarnessGeneration.ps1 | 0 | wrote the `.claude` copy and its bundle copy |
| Generator check | Invoke-HarnessGeneration.ps1 -Check | 0 | `harness-generation: no drift` |
| Format | static-ps check (test file) | 0 | FILES_NEEDING_FORMAT=0 |
| Analyze | pssa-one (test file) | 0 | FINDINGS=0 |
| Pester | launcher pester -TestPath (5 files) | 0 | TESTS=193 FAILURES=0 |
