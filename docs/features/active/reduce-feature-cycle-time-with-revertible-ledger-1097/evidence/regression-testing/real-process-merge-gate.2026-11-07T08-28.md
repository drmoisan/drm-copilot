# Real-Process Merge Gate Run

Timestamp: 2026-11-07T08-28
Command: `sh` launcher under SCRATCH that clones the pushed branch head into SCRATCH/gate-clone (sparse: `.claude`, `.codex`, `tests/scripts/claude-hooks`) and, for each fixture written to the clone's `artifacts/orchestration/orchestrator-state.json`, pipes a PreToolUse envelope to `.claude/hooks/enforce-epic-merge-gate.ps1` and `.codex/hooks/enforce-epic-merge-gate.ps1` in a fresh PowerShell 7 process, with no mocked seam. The command text is data; it is never executed, and no `gh` merge ran.
EXIT_CODE: 0
Output Summary: 218 rows at the pushed head; 0 rows differ from the plan's table. Fixture A (key, no review outcome) and fixture B (key, passing outcome): each of the 32 merge forms, on both gates, returned a deny carrying `REVIEW_GATE_HEAD_UNRESOLVED`; each of the 5 legitimate forms returned allow from Claude and no output from Codex. Fixture C (no key) kept the decision without the key on every form. Exit status 0 on every row.

- Merge forms: every `wrapper-*` form, `chain-second-bare`, `chain-and`, `flag-auto`, `api-rest-merge`, `api-graphql-merge`, and `selector-branch` (27 forms), plus the five commands of finding F1, on pull requests 1101 and 1100, under fixtures A and B (`reviewer-*`). Those five name a pull request the fixture does not bind, so they show the session read.
- Fixture C: all 27 merge forms and the 5 legitimate forms returned allow from Claude and no output from Codex.
- Fixture `C-no-worktree`: the 6 out-of-scope merge forms, with the Claude process started from a directory outside any worktree, where the item target resolves `NoTarget` for real; each returned allow.

| Form | Fixture | Runtime | Decision | Code | Exit | Matches table |
| --- | --- | --- | --- | --- | --- | --- |
| api-graphql-merge | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| api-rest-merge | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| chain-and | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| chain-second-bare | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| confirmation-query | A | claude | allow |  | 0 | True |
| flag-auto | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| pr-checks | A | claude | allow |  | 0 | True |
| pr-create | A | claude | allow |  | 0 | True |
| pr-edit | A | claude | allow |  | 0 | True |
| pr-view | A | claude | allow |  | 0 | True |
| reviewer-bang | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-chain | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-exec | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-if-then | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-second-bare | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| selector-branch | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-backtick-substitution | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-bang | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-bash-c | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-brace-group | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-builtin | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-case | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-cd-prefix | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-command | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-dollar-substitution | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-env | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-eval | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-exec | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-for | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-if-then | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-leading-backslash | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-pwsh-c | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-sh-c | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-subshell | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-time | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-while | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-xargs | A | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| api-graphql-merge | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| api-rest-merge | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| chain-and | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| chain-second-bare | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| confirmation-query | A | codex | none |  | 0 | True |
| flag-auto | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| pr-checks | A | codex | none |  | 0 | True |
| pr-create | A | codex | none |  | 0 | True |
| pr-edit | A | codex | none |  | 0 | True |
| pr-view | A | codex | none |  | 0 | True |
| reviewer-bang | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-chain | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-exec | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-if-then | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-second-bare | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| selector-branch | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-backtick-substitution | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-bang | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-bash-c | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-brace-group | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-builtin | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-case | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-cd-prefix | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-command | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-dollar-substitution | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-env | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-eval | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-exec | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-for | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-if-then | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-leading-backslash | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-pwsh-c | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-sh-c | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-subshell | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-time | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-while | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-xargs | A | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| api-graphql-merge | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| api-rest-merge | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| chain-and | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| chain-second-bare | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| confirmation-query | B | claude | allow |  | 0 | True |
| flag-auto | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| pr-checks | B | claude | allow |  | 0 | True |
| pr-create | B | claude | allow |  | 0 | True |
| pr-edit | B | claude | allow |  | 0 | True |
| pr-view | B | claude | allow |  | 0 | True |
| reviewer-bang | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-chain | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-exec | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-if-then | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-second-bare | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| selector-branch | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-backtick-substitution | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-bang | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-bash-c | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-brace-group | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-builtin | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-case | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-cd-prefix | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-command | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-dollar-substitution | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-env | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-eval | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-exec | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-for | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-if-then | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-leading-backslash | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-pwsh-c | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-sh-c | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-subshell | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-time | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-while | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-xargs | B | claude | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| api-graphql-merge | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| api-rest-merge | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| chain-and | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| chain-second-bare | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| confirmation-query | B | codex | none |  | 0 | True |
| flag-auto | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| pr-checks | B | codex | none |  | 0 | True |
| pr-create | B | codex | none |  | 0 | True |
| pr-edit | B | codex | none |  | 0 | True |
| pr-view | B | codex | none |  | 0 | True |
| reviewer-bang | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-chain | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-exec | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-if-then | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| reviewer-second-bare | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| selector-branch | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-backtick-substitution | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-bang | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-bash-c | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-brace-group | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-builtin | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-case | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-cd-prefix | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-command | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-dollar-substitution | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-env | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-eval | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-exec | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-for | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-if-then | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-leading-backslash | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-pwsh-c | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-sh-c | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-subshell | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-time | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-while | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| wrapper-xargs | B | codex | deny | REVIEW_GATE_HEAD_UNRESOLVED | 0 | True |
| api-graphql-merge | C | claude | allow |  | 0 | True |
| api-rest-merge | C | claude | allow |  | 0 | True |
| chain-and | C | claude | allow |  | 0 | True |
| chain-second-bare | C | claude | allow |  | 0 | True |
| confirmation-query | C | claude | allow |  | 0 | True |
| flag-auto | C | claude | allow |  | 0 | True |
| pr-checks | C | claude | allow |  | 0 | True |
| pr-create | C | claude | allow |  | 0 | True |
| pr-edit | C | claude | allow |  | 0 | True |
| pr-view | C | claude | allow |  | 0 | True |
| selector-branch | C | claude | allow |  | 0 | True |
| wrapper-backtick-substitution | C | claude | allow |  | 0 | True |
| wrapper-bang | C | claude | allow |  | 0 | True |
| wrapper-bash-c | C | claude | allow |  | 0 | True |
| wrapper-brace-group | C | claude | allow |  | 0 | True |
| wrapper-builtin | C | claude | allow |  | 0 | True |
| wrapper-case | C | claude | allow |  | 0 | True |
| wrapper-cd-prefix | C | claude | allow |  | 0 | True |
| wrapper-command | C | claude | allow |  | 0 | True |
| wrapper-dollar-substitution | C | claude | allow |  | 0 | True |
| wrapper-env | C | claude | allow |  | 0 | True |
| wrapper-eval | C | claude | allow |  | 0 | True |
| wrapper-exec | C | claude | allow |  | 0 | True |
| wrapper-for | C | claude | allow |  | 0 | True |
| wrapper-if-then | C | claude | allow |  | 0 | True |
| wrapper-leading-backslash | C | claude | allow |  | 0 | True |
| wrapper-pwsh-c | C | claude | allow |  | 0 | True |
| wrapper-sh-c | C | claude | allow |  | 0 | True |
| wrapper-subshell | C | claude | allow |  | 0 | True |
| wrapper-time | C | claude | allow |  | 0 | True |
| wrapper-while | C | claude | allow |  | 0 | True |
| wrapper-xargs | C | claude | allow |  | 0 | True |
| api-graphql-merge | C | codex | none |  | 0 | True |
| api-rest-merge | C | codex | none |  | 0 | True |
| chain-and | C | codex | none |  | 0 | True |
| chain-second-bare | C | codex | none |  | 0 | True |
| confirmation-query | C | codex | none |  | 0 | True |
| flag-auto | C | codex | none |  | 0 | True |
| pr-checks | C | codex | none |  | 0 | True |
| pr-create | C | codex | none |  | 0 | True |
| pr-edit | C | codex | none |  | 0 | True |
| pr-view | C | codex | none |  | 0 | True |
| selector-branch | C | codex | none |  | 0 | True |
| wrapper-backtick-substitution | C | codex | none |  | 0 | True |
| wrapper-bang | C | codex | none |  | 0 | True |
| wrapper-bash-c | C | codex | none |  | 0 | True |
| wrapper-brace-group | C | codex | none |  | 0 | True |
| wrapper-builtin | C | codex | none |  | 0 | True |
| wrapper-case | C | codex | none |  | 0 | True |
| wrapper-cd-prefix | C | codex | none |  | 0 | True |
| wrapper-command | C | codex | none |  | 0 | True |
| wrapper-dollar-substitution | C | codex | none |  | 0 | True |
| wrapper-env | C | codex | none |  | 0 | True |
| wrapper-eval | C | codex | none |  | 0 | True |
| wrapper-exec | C | codex | none |  | 0 | True |
| wrapper-for | C | codex | none |  | 0 | True |
| wrapper-if-then | C | codex | none |  | 0 | True |
| wrapper-leading-backslash | C | codex | none |  | 0 | True |
| wrapper-pwsh-c | C | codex | none |  | 0 | True |
| wrapper-sh-c | C | codex | none |  | 0 | True |
| wrapper-subshell | C | codex | none |  | 0 | True |
| wrapper-time | C | codex | none |  | 0 | True |
| wrapper-while | C | codex | none |  | 0 | True |
| wrapper-xargs | C | codex | none |  | 0 | True |
| wrapper-bang | C-no-worktree | claude | allow |  | 0 | True |
| wrapper-builtin | C-no-worktree | claude | allow |  | 0 | True |
| wrapper-exec | C-no-worktree | claude | allow |  | 0 | True |
| wrapper-for | C-no-worktree | claude | allow |  | 0 | True |
| wrapper-if-then | C-no-worktree | claude | allow |  | 0 | True |
| wrapper-while | C-no-worktree | claude | allow |  | 0 | True |
