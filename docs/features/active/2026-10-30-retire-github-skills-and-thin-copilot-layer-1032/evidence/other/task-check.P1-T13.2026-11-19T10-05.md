# Task Check P1-T13

Timestamp: 2026-11-19T10-05
Plan: plan.2026-10-30T18-39.md
Changed files: `.github/copilot-instructions.md` reduced to Copilot-only text under `# Copilot-only instructions` (shared instructions and the tone policy from `AGENTS.md`, shared skills from `.agents/skills`, path-scoped instructions in `.github/instructions`, prompts and handoff-bearing agents native in `.github/prompts` and `.github/agents`, hooks native in `.github/hooks`); copied to `extensions/drm-copilot/resources/customizations/.github/copilot-instructions.md` (`cmp` identical). `CLAUDE.md` unchanged: P0-T4 recorded `ClaudeMdPointer: agents-md`, so the OQ5 pointer edit does not apply.
Selection rule: the contract tests that read these files: the test-cadence and parallel-gate sweeps (both unchanged). No unit test asserts the file's former tone text (search of `tests/` for the two tone tokens returned no file).

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| Fixed-string search of `.github/copilot-instructions.md` for `strictly professional` and `Do not use jokes` | 0 | 0 matches each |
| Fixed-string search of `CLAUDE.md` for `copilot-instructions.md` | 0 | 0 matches |
| `cmp` of the file and its bundle copy | 0 | identical |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` | 0 | Invoke-PoshQCParallelTest exit code 0 (workers 2, 101s) |
