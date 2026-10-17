# SubagentStop Exit-1 Paths and Registrations ([P9-T8])

Timestamp: 2026-10-10T00-42
Command: R-EXIT1 of `git show 86e457a003be0c60b65e01156e4cccd6495dfd1a:<path>` and of the working file for each of the six Claude SubagentStop W-HOOKS files; `git diff --stat 86e457a003be0c60b65e01156e4cccd6495dfd1a -- .claude/settings.json .codex/config.toml`
EXIT_CODE: 0
Output Summary: every count pair is equal (1 = 1 for all six hooks); the stat output is empty (no registration change).

```text
EXIT1: .claude/hooks/validate-discovery-artifact-gate.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-feature-review-coverage.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-orchestrator-output.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-planner-output.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-pr-author-output.ps1 | base=1 | post=1 | equal
EXIT1: .claude/hooks/validate-prd-feature-output.ps1 | base=1 | post=1 | equal
git diff --stat 86e457a003be0c60b65e01156e4cccd6495dfd1a -- .claude/settings.json .codex/config.toml: (empty)
```
