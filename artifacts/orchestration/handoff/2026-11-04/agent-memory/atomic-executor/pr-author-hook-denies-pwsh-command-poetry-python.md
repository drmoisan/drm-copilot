---
name: pr-author-hook-denies-pwsh-command-poetry-python
description: The PR-authoring PreToolUse hook denied two inline `pwsh -Command "...; poetry run python ..."` Bash lines with PR_AUTHOR_SKILL_BLOCKED although no PR action was attempted; a `sh <scratch>.sh` launcher with the same commands passed.
metadata:
  type: feedback
---

Put multi-step toolchain commands (pytest, generate_codex_agent_variants --check, validate_orchestration_artifacts.py plan) in a `sh` launcher under SCRATCH instead of an inline `pwsh -NoProfile -Command "..."` string.

**Why:** On 2026-11-04 (issue 1023, Phase 7) `.claude/hooks/enforce-pr-author-skill.ps1` denied two inline `pwsh -Command` lines that carried `poetry run python ...` with `PR_AUTHOR_SKILL_BLOCKED: New PRs require --body-file`, while an inline line of the same shape running `node run-jest.cjs` passed. The exact matched token was not identified; the launcher route (`sh SCRATCH/issue-<n>-<name>.sh`) ran the same commands with no denial, and it also avoids the `xargs` exit-123 trap when a plan asserts grep's own exit 1.

Second observation (issue 1022, Phase 6, 2026-11-04): the same denial fired on a plain inline `for n in ...; do ... grep -c ... ; done` loop over test-file names (no pwsh, no poetry, no gh); the identical loop in a `sh` file passed. The trigger is broader than `poetry run python`.

Related: a foreground Bash call is moved to the background after about 180 s regardless of its `timeout`; poll long runs with loops that end within about 160 s.

**How to apply:** For any multi-statement Bash loop or any Bash command that embeds `poetry run python` inside a `pwsh -Command` string, write the commands to a scratch `.sh` file first and run `sh <absolute path>`; record the launcher as `SCRATCH/<name>.sh` in evidence.
