# Acceptance Scenario Matrix (spec 7.1 / 7.2) -> Passing Tests

- Timestamp: 2026-06-24T16-41
- Issue: #231

## 7.1 — enforce-pr-author-skill.Tests.ps1 (41 tests, 0 failures)

| Spec 7.1 scenario | Expected | Asserting `It` (Context > It) |
|---|---|---|
| Case D — missing (null) | block PR_AGENT_AUTHORIZATION_MISSING | authorization sentinel - missing (Case D) > blocks ... when the sentinel read seam returns null |
| Case D — missing (empty/whitespace) | block PR_AGENT_AUTHORIZATION_MISSING | authorization sentinel - missing (Case D) > blocks ... empty/whitespace |
| Case E — invalid issuer (orchestrator) | block PR_AGENT_AUTHORIZATION_INVALID | authorization sentinel - invalid issuer (Case E) > blocks ... issued_by is orchestrator within TTL |
| Case F — expired (300 s) | block PR_AGENT_AUTHORIZATION_EXPIRED | authorization sentinel - expired (Case F) > blocks ... issued 300 s before the injected clock |
| Malformed JSON | block PR_AGENT_AUTHORIZATION_MALFORMED | authorization sentinel - malformed > blocks ... not valid JSON |
| Malformed — missing issued_at | block PR_AGENT_AUTHORIZATION_MALFORMED | authorization sentinel - malformed > blocks ... issued_at is missing |
| Malformed — unparseable issued_at | block PR_AGENT_AUTHORIZATION_MALFORMED | Test-PrAuthorAuthorization unparseable issued_at (malformed) > returns ... unparseable |
| Valid authorization (5 s, in TTL) | allow | authorization sentinel - valid authorization (allow) > allows ... issued_at is 5 s before the injected clock |
| Valid authorization — gh pr edit | allow | authorization sentinel - valid authorization (allow) > allows gh pr edit --body-file with a valid in-TTL pr-author sentinel |
| Backward compat — Case A | block (unchanged) | gh pr create - inline body (Case A) > blocks ... (two forms) |
| Backward compat — Case B | block (unchanged) | gh pr create - missing body (Case B) > blocks ... (two forms) |
| Backward compat — Case C | block (unchanged) | gh pr create/edit - missing context artifact (Case C) > blocks ... (create + edit) |
| Backward compat — gh pr edit --title | allow (unchanged) | allowed commands > allows gh pr edit --title "new title" (no body flag) |

## 7.2 — validate-pr-author-output.Tests.ps1 (15 tests, 0 failures)

| Spec 7.2 scenario | Expected | Asserting `It` |
|---|---|---|
| Output contains PR URL | allow (exit 0) | allow scenarios > allows when output contains a GitHub PR URL; entrypoint exits 0 when ... reports a PR URL |
| gh pr create/edit confirmation with PR number | allow (exit 0) | allow scenarios > allows ... gh pr create confirmation with a PR number; ... gh pr edit confirmation with a PR number |
| Output empty | block (exit 1) | block scenarios > blocks when output is empty |
| Output without PR URL/number | block (exit 1) | block scenarios > blocks when output has no PR URL or number |
| CLAUDE_HOOK_INPUT empty | block (exit 1) | block scenarios > blocks when CLAUDE_HOOK_INPUT content is empty; entrypoint exits 1 when ... empty |
| CLAUDE_HOOK_INPUT malformed JSON | block (exit 1) | block scenarios > blocks when CLAUDE_HOOK_INPUT is malformed JSON; entrypoint exits 1 when ... malformed JSON |

## Conclusion

Every spec 7.1 and 7.2 scenario maps to at least one passing `It`. Allowed (valid `pr-author` sentinel) and all blocked variants (missing, expired, wrong-issuer, malformed, Case A, Case B, Case C) are asserted (AC5), and the six validator scenarios are asserted (AC7).
