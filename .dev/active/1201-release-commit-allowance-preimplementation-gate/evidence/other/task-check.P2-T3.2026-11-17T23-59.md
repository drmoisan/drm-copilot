# Task check - P2-T3

Timestamp: 2026-11-17T23-59
Changed files:
- .agents/skills/orchestrate/SKILL.md and extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md: paragraph "Release-commit allowance (issue #1201)" in `## Pre-Implementation Gate` after the issue #1160 paragraph (source and bundle share SHA256 prefix 387a7b9c9332601f).
- .claude/rules/orchestrator-state.md and extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md: new `## Release-Commit Allowance Scope` before `## Enforcement` (destination-owned file, never bundled, published, or shipped with a default; command-only and allow-side only; the eight codes) (source and bundle share SHA256 prefix c04321e6a8fa0d04).
- extensions/drm-copilot/CHANGELOG.md: `### Added` entry under `## [Unreleased]` naming `.claude/release-commit-allowance.json`, the push-down refresh after the extension release, and the opt-in by committing the file.
Selection rule: the tests named in the task acceptance plus every test file that names `rules/orchestrator-state.md`, `agents/skills/orchestrate`, or the CHANGELOG (text search of tests/), and the Codex generator check, because the .agents skills feed the Codex bundle.

Commands:
1. Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check (via SCRATCH/issue-1201-py-select.sh)
   EXIT_CODE: 0
   Output Summary: no output, no drift; tracked changes are only this change's 15 files.
2. Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py <17 further Python files that name the edited documents>
   EXIT_CODE: 0
   Output Summary: 451 passed, 0 failed (all unmodified).
3. Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/concurrent-review-skill-contract.Tests.ps1 tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1 tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1 tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1 tests/scripts/claude-runtime/review-verdict-skill-contract.Tests.ps1 tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 tests/scripts/dev-tools/StageTimingDocumentation.Tests.ps1 tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1
   EXIT_CODE: 0
   Output Summary: 535 tests, 535 passed, 0 failed (all unmodified).
