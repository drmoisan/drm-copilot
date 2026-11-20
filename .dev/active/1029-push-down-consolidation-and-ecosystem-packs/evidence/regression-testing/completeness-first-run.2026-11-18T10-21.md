# P4-T1 Completeness Test: First Run ([expect-fail])

Timestamp: 2026-11-18T10-21
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down/push-down-bundle-manifest-completeness
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The new full-bundle completeness test fails by design on its first run: 6 cases, 4 passed, 2 failed. `lists every Claude bundle file` reports 14 unlisted paths; `lists every Codex bundle file` reports 40. `lists every Copilot bundle file`, `lists no path outside the shared set in shared.json`, `keeps every ecosystem-layer exception in a Codex manifest and out of shared.json`, and `enumerates a non-empty bundle tree` pass. P4-T2 (Claude) and P4-T3 (Codex) add the missing entries.

## Missing paths per bundle

```text
## claude (14)
.claude/agent-memory/epic-orchestrator/MEMORY.md
.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md
.claude/agent-memory/epic-orchestrator/feedback_no_sendmessage_tool.md
.claude/agent-memory/epic-orchestrator/feedback_worktree_isolation_branches_from_main.md
.claude/agent-memory/orchestrator/MEMORY.md
.claude/agent-memory/orchestrator/feedback_branch_base_check_unmerged_pr_deps.md
.claude/agent-memory/orchestrator/feedback_commit_push_memory_before_pr.md
.claude/agent-memory/orchestrator/feedback_every_change_through_lifecycle.md
.claude/agent-memory/orchestrator/feedback_policy_compliance_not_optional.md
.claude/agent-memory/orchestrator/feedback_potential_to_issue_creates_github_issue.md
.claude/agent-memory/orchestrator/feedback_remediation_plan_em_dash_required.md
.claude/agent-memory/orchestrator/feedback_small_bug_uses_minor_audit.md
.claude/agent-memory/orchestrator/feedback_test_files_count_against_500_cap.md
.mcp.json
## codex (40)
.agents/skills/architecture-boundaries/SKILL.md
.agents/skills/benchmark-baselines/SKILL.md
.agents/skills/commit-message-conventions/SKILL.md
.agents/skills/feature-review/SKILL.md
.agents/skills/general-code-change/SKILL.md
.agents/skills/general-unit-test/SKILL.md
.agents/skills/pr-authoring/SKILL.md
.agents/skills/quality-tiers/SKILL.md
.agents/skills/self-explanatory-code-commenting/SKILL.md
.agents/skills/tonality/SKILL.md
.agents/skills/translate-claude-to-codex/SKILL.md
.codex/agents/5.1-beast-adjusted.toml
.codex/agents/5.1-thinking-beast-mode-adjusted.toml
.codex/agents/api-architect.toml
.codex/agents/atomic-planning.toml
.codex/agents/commentary-remediation.toml
.codex/agents/csharp-atomic-executor.toml
.codex/agents/csharp-atomic-planning.toml
.codex/agents/csharp-orchestrator.toml
.codex/agents/epic-review.toml
.codex/agents/expert-nextjs-developer.toml
.codex/agents/expert-react-frontend-engineer.toml
.codex/agents/feature-review.toml
.codex/agents/gpt-5-beast-mode.toml
.codex/agents/hlbpa.toml
.codex/agents/mentor.toml
.codex/agents/powershell-di-unit-test-engineer.toml
.codex/agents/prd.toml
.codex/agents/pytest-unit-test-coding.toml
.codex/agents/python-execution-only-typed.toml
.codex/agents/staged-review.toml
.codex/agents/status-updater.toml
.codex/agents/tdd-green.toml
.codex/agents/tdd-red.toml
.codex/agents/tdd-refactor.toml
.codex/agents/voidbeast-gpt41enhanced.toml
.codex/codex-web-setup.plan.md
.codex/codex-web-setup.sh
.codex/prompts/feature-review-remediate.md
.codex/prompts/generate-commit-message-repo.md
```

The P0-T1 child 3 list (`evidence/qa-gates/phase0-upstream-recheck.2026-11-18T07-50.md`) is a subset: its Claude entry `.mcp.json` and its Codex entries (the seven skills and four agents it names) are all above; its `AGENTS.md` entry is now listed by `shared.json`.
