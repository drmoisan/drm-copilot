# AC-29 agent frontmatter registrations (plan [P11-T20], issue #905)

Timestamp: 2026-10-11T23-34
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-scoped.ps1 tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 tests/scripts/claude-runtime/claude-settings.Tests.ps1
EXIT_CODE: 0
Output Summary: `git diff --stat origin/epic/subagentstop-envelope-integration...HEAD -- .claude/agents extensions/drm-copilot/resources/claude-customizations/.claude/agents` printed nothing and `git status --porcelain -- <same paths>` printed nothing. `Select-String -SimpleMatch` found exactly one match per file: `-File .claude/hooks/validate-pr-author-output.ps1` at line 27 of `.claude/agents/pr-author.md` and of its bundled copy; `-File .claude/hooks/validate-task-researcher-output.ps1` at line 19 of `.claude/agents/task-researcher.md` and of its bundled copy (the expected lines, so no deviation entry). R-SCOPED: SUMMARY: passed=47 failed=0 skipped=0 notrun=0; CONTAINER-ERRORS: 0; the success branch was met, so no ExpectedExitCode field is carried. RS-3 is recorded in `evidence/other/deviations.md` ([P11-T16] entry).

```text
AGENT-REG: .claude/agents/pr-author.md | '-File .claude/hooks/validate-pr-author-output.ps1' | matches=1 | lines=27
AGENT-REG: extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md | '-File .claude/hooks/validate-pr-author-output.ps1' | matches=1 | lines=27
AGENT-REG: .claude/agents/task-researcher.md | '-File .claude/hooks/validate-task-researcher-output.ps1' | matches=1 | lines=19
AGENT-REG: extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md | '-File .claude/hooks/validate-task-researcher-output.ps1' | matches=1 | lines=19
```

```text
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-01 exposes the decision function with a CommandText parameter and an ordered result
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-02 allows git log -1 --format=%H
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-03 allows git log --oneline -5
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-04 allows git rev-parse HEAD
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-05 allows gh pr create --head bug/x-5 --base main --body-file artifacts/pr_body_5.md
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-06 allows gh pr edit 5 --body-file artifacts/pr_body_5.md
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-07 allows sha256sum artifacts/pr_body_5.md
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-08 allows date -u +%Y-%m-%dT%H:%M:%SZ
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-09 allows date -u
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-10 allows git rev-parse HEAD && git log -1 --format=%H
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-11 denies git log -1 --format=%H && sha256sum artifacts/pr_body_5.md && date -u +%Y-%m-%dT%H:%M:%SZ
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-12 denies git -C /repo log
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-13 denies git --no-pager log
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-14 denies sha256sum artifacts/other.md
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-15 denies sha256sum -b artifacts/pr_body_5.md
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-16 denies sha256sum artifacts/pr_body_5.md artifacts/pr_body_6.md
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-17 denies date
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-18 denies date +%s
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-19 denies date -u -d yesterday
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-20 denies date -u +%s extra
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-21 denies git log > out.txt
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-22 denies bash -c "git log"
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-23 denies git log $(whoami)
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-24 denies echo "$(git log)"
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-25 denies git log "unterminated
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-26 denies git log -1; rm -rf x
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-27 denies cat artifacts/pr_body_5.md
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-28 denies git log -1 & git rev-parse HEAD
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-29 denies FOO=1 git log
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-30 denies git log $X
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-31 denies sha256sum artifacts/pr_body_5.md; date -u +%Y-%m-%dT%H:%M:%SZ
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-32 allows an empty command
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-33 registers the hook in the pr-author frontmatter and keeps the SubagentStop entry
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-34 allows every command form the receipt procedure names
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-35 names both receipt commands in the agent and the skill
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-36 returns 0 from the entry point and denies a payload anomaly
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-37 writes a deny decision and exits 0 when the script runs in process
PASSED-TEST: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | AL-38 matches no allowed form for a record with no tokens
PASSED-TEST: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | requires .claude/settings.json to omit a default agent and declare canonical worker hook coverage
PASSED-TEST: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | requires .claude/settings.json to use the active PowerShell MCP contract
PASSED-TEST: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | requires the Bash PreToolUse hook chain to include validate-bash and enforce-promotion-mcp-only
PASSED-TEST: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | requires one dedicated prd-feature stop-hook registration in byte-identical settings files
PASSED-TEST: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | rejects complete omission, broad-only, duplicate, extra-command, wrong-command, wrong-type, wrong-matcher, and divergent prd-feature registration fixtures
PASSED-TEST: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | removes every SubagentStop command that reads CLAUDE_HOOK_INPUT from both settings copies
PASSED-TEST: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | keeps no SubagentStop command that ends with exit 1 in either settings copy
PASSED-TEST: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | retains the fifteen-agent SubagentStop group with only the discovery-artifact gate in both settings copies
PASSED-TEST: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | registers no hook command that references subagentstop-envelope.ps1 in either settings copy
BLOCK-ERRORS: 0
CONTAINER-ERRORS: 0
SUMMARY: passed=47 failed=0 skipped=0 notrun=0
```
