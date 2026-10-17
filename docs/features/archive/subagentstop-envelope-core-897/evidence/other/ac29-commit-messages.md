# AC-29 Commit-Message Verification (issue #897, epic child E1)

Timestamp: 2026-10-11T13-15
Task: [P5-T15]
Command: `git log --format=%H origin/epic/subagentstop-envelope-integration..HEAD`, then `git log -1 --format=%B <sha>` per commit; `REFS_897` tests the literal `Refs #897`; `CLOSING_KEYWORD_897` tests the case-insensitive regex `\b(close[sd]?|fix(e[sd])?|resolve[sd]?)\b:?\s+#897\b`.
EXIT_CODE: 0
Output Summary: 6 commits ahead of the anchor at the time of the check; every row reads `REFS_897: yes` and `CLOSING_KEYWORD_897: no`; no `AC29_RISK:` row.

## Per-commit rows

```text
COMMIT: 60027886e6c129a9c3f1743925e721018c866bb7 | REFS_897: yes | CLOSING_KEYWORD_897: no | test(897): record final QA and coverage evidence for the SubagentStop envelope helper
COMMIT: 9c69282ded151142dea16155b3c0eed557cf7b7a | REFS_897: yes | CLOSING_KEYWORD_897: no | chore(897): remove the inline SubagentStop command from both settings copies
COMMIT: 82a4e52482436d32a71556e27a967107ec936b9f | REFS_897: yes | CLOSING_KEYWORD_897: no | feat(897): implement Read-SubagentStopEnvelope and anomaly reasons with bundled mirror and core manifest entry
COMMIT: b4f24a098a2e2e8b8fd6f4956df7363bba06b5ad | REFS_897: yes | CLOSING_KEYWORD_897: no | test(897): add SubagentStop envelope helper and settings regression tests
COMMIT: 7bb19a8bc87850367190e263bea6ec3716b28aa4 | REFS_897: yes | CLOSING_KEYWORD_897: no | feat(897): add Exit-SubagentStopBlock and its exit-route test entry script
COMMIT: 466f212c8b1231d1887306e3d0851819862d5512 | REFS_897: yes | CLOSING_KEYWORD_897: no | docs(897): record Phase 0 baseline evidence for SubagentStop envelope helper
```

AC29_RISK rows: none.

PR_BODY_PORTION: DEFERRED to the PR-authoring step (gh pr view <pr> --json body is verified when the PR exists; outside this plan)

AC-29 stays unchecked in `spec.md` because its PR-body portion cannot be verified inside this plan. The row `AC-29: DEFERRED | P5-T15 | evidence/other/ac29-commit-messages.md` is appended to `evidence/other/ac-status.md`. The one commit made after this task ([P5-T17], subject `docs(897): record scope, commit-message, and acceptance status evidence`) uses the prescribed subject and `Refs #897` and is re-checked at PR authoring.
