# Expect-Fail Record: docs-init Documentation Families (Issue #1218, P3-T1)

Timestamp: 2026-11-23T10-47
Command: sh SCRATCH/issue-1218-check.sh check-p3t1 tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1 tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1 tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1 (launcher pester suite with -TestPath; attempt 1 exit 75 queue timeout, attempt 2 ran)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- 145 tests: 142 passed, 3 failed.
- Expected failures (by design until P3-T2 regenerates and copies the mirrors), each at `$families.Success | Should -BeTrue` because the copy has no `## Documentation Families` heading yet:
  - `docs-init Documentation Families section (issue 1218).places the Documentation Families section between Steps and Linter Configuration in .claude/skills/docs-init/SKILL.md` (row `Claude`)
  - `...in extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-init/SKILL.md` (row `ClaudeBundle`)
  - `...in extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-init/SKILL.md` (row `CodexBundle`)
- The same It passes for the `Codex` row (.agents/skills/docs-init/SKILL.md): the section lies between `## Steps` and `## Linter Configuration` and contains every backticked family id, template id, `exclusion`, `reason`, `recorded_at`, and `legacy_exclusions`.
- Every existing It of docs-authoring-roles.WorkflowText.Tests.ps1, docs-authoring-roles.Skills.Tests.ps1 (including `keeps <Path> free of .claude/ text and states the push-down prerequisite`), and HarnessParityMatrix.RepoGate.Tests.ps1 (standard contract) passes.
