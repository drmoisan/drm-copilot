# Final QA — Receipt Coverage Map (AC1 / AC5)

Timestamp: 2026-06-28T00-12

Source: artifacts/pester/pester-junit.xml (single green run, enforce-pr-author-skill.Tests.ps1, 46/46 passed).

## Five ordered receipt deny reasons -> passing It

| Deny reason | Context :: It | Status |
|---|---|---|
| PR_BODY_PATH_NONCANONICAL | receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL) :: blocks a --body-file artifacts/pr_body.md (no number) with PR_BODY_PATH_NONCANONICAL | PASS |
| PR_AUTHOR_RECEIPT_MISSING | receipt - missing (PR_AUTHOR_RECEIPT_MISSING) :: blocks with PR_AUTHOR_RECEIPT_MISSING when the receipt read seam returns null | PASS |
| PR_AUTHOR_RECEIPT_NUMBER_MISMATCH | receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH) :: blocks with PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when receipt.number does not match the path number | PASS |
| PR_AUTHOR_RECEIPT_HASH_MISMATCH | receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH) :: blocks with PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body SHA-256 does not match receipt.sha256 | PASS |
| PR_AUTHOR_RECEIPT_STALE | receipt - stale (PR_AUTHOR_RECEIPT_STALE) :: blocks with PR_AUTHOR_RECEIPT_STALE when created_at is not strictly newer than the context last-write | PASS |

## Allow path -> passing It

| Path | Context :: It | Status |
|---|---|---|
| Allow (all five checks pass) | receipt - all checks pass (allow) :: allows when all five receipt checks pass | PASS |

## Retained shape blocks -> passing It

| Shape block | Context :: It | Status |
|---|---|---|
| Case A (inline --body, create) | gh pr create - inline body (Case A) :: blocks gh pr create --body "inline string" | PASS |
| Case A (inline --body, edit) | gh pr edit - inline body (Case A) :: blocks gh pr edit --body "inline text" (no --body-file) | PASS |
| Case B (create, no body flag) | gh pr create - missing body (Case B) :: blocks gh pr create with no body flags | PASS |
| Case C (--body-file, no context, create) | gh pr create/edit - missing context artifact (Case C) :: blocks gh pr create --body-file artifacts/pr_body_12.md when context is absent | PASS |
| Case C (--body-file, no context, edit) | gh pr create/edit - missing context artifact (Case C) :: blocks gh pr edit --body-file artifacts/pr_body_12.md when context is absent | PASS |
| edit-no-body allow | gh pr edit - inline body (Case A) :: allows gh pr edit --title "x" (no body flag remains allowed) | PASS |

## Decision-shape coverage

- Get-PrAuthorSkillBlockDecision yields hookEventName=PreToolUse and permissionDecision=deny (serialize-then-parse): PASS.
- Get-PrAuthorSkillAllowDecision yields permissionDecision=allow: PASS.

## Result

All five receipt deny reasons, the three retained shape blocks (Case A/B/C plus edit-no-body allow), and the allow path map to a passing It within a single green run. AC1 (five ordered deny reasons + deny shape) and the AC5 Pester-coverage condition are satisfied.
