# AC-20 and AC-23 Scope Boundary, Static Re-run ([P7-T8] re-run of [P6-T10])

Timestamp: 2026-10-12T04-21
Command: git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD ; git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .claude/agents ; git status --porcelain
EXIT_CODE: 0
Output Summary: OUT_OF_ALLOWLIST_COUNT: 0; FORBIDDEN_PATHS_FOUND: none; AGENTS_DIFF_COUNT: 1 (.claude/agents/prd-feature.md) with AGENT_EDIT_OUTCOME: LANDED; porcelain lists only feature-folder paths.

.claude/agents diff output:
.claude/agents/prd-feature.md

The full listing is the same set classified in evidence/qa-gates/scope-boundary.2026-10-12T04-10.md (all S-ALLOW).

OUT_OF_ALLOWLIST_COUNT: 0
AGENTS_DIFF_COUNT: 1
AGENT_EDIT_OUTCOME: LANDED (from evidence/other/prd-feature-registration.2026-10-12T04-06.md)
FORBIDDEN_PATHS_FOUND: none
