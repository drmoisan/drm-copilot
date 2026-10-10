# Regression: #510 spec status, line citations, and rc-file path ([P7-T28], AC-29)

Timestamp: 2026-10-09T21-42
Command: git grep -n -e "line 68" -e "line 67" -e "line 21" -e "evidence/coverage/" -e "Status:\*\* Draft" -- docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: no output; none of the stale citations, the old rc-file path, or the Draft status remain.

## Block 2

Command: git grep -n -e "line 23" -e "line 69" -e "line 70" -e "evidence/other/coveragerc-helper.ini" -- docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md
EXIT_CODE: 0
Output Summary: three lines, at 45, 61, and 174 (line text truncated here; line 45 cites `.gitignore` line 70, line 61 cites lines 23, 69, 70, and 23, line 174 names `evidence/other/coveragerc-helper.ini` and begins `- [x] `).

Edits recorded: line 6 `- **Last Updated:** 2026-10-09T21-41` (host clock at [P7-T24]); line 7 `- **Status:** Implemented (all 13 acceptance criteria checked; reviewed in code-review.2026-10-07T15-30.md; status corrected under #846, previously Draft)`. The 13 checked criteria were confirmed by listing the checkboxes under `## Acceptance Criteria` (lines 164-176, all `- [x]`). The .gitignore values were re-read on 2026-10-09: line 23 `.claude/worktrees`, line 69 `.claude/agent-memory`, line 70 `.claude/state/`.

Acceptance (AC-29): first block exits 1 and prints nothing; second block prints lines 45, 61, and 174. PASS.
