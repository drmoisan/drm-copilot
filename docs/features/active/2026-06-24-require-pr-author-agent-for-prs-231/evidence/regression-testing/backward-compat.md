# Backward Compatibility — Cases A/B/C and Allowed Paths (FR-4, AC5)

- Timestamp: 2026-06-24T16-39
- Issue: #231

All pre-existing test cases in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` retain their original expectations and pass. Cases A and B are evaluated before any sentinel check; Case C is evaluated before the sentinel check; the previously-allowed `--body-file` + context path was extended (a valid sentinel is now additionally required), so the pre-existing allow tests now also mock a valid in-TTL `pr-author` sentinel to keep their original `allow` expectation valid. This is a mock addition, not an expectation change.

## Pre-existing test cases and outcomes

| Test case | Original expectation | Post-change result |
|---|---|---|
| CLAUDE_TOOL_INPUT empty | allow | allow (pass) |
| JSON has no command field | allow | allow (pass) |
| malformed JSON throws | throw / exit 1 | throw / exit 1 (pass) |
| Case A: `gh pr create --body "inline"` | block PR_AUTHOR_SKILL_BLOCKED | block (pass) |
| Case A: `gh pr create --body='inline'` (equals form) | block PR_AUTHOR_SKILL_BLOCKED | block (pass) |
| Case B: `gh pr create` no body flags | block PR_AUTHOR_SKILL_BLOCKED | block (pass) |
| Case B: `gh pr create --title foo` no body | block PR_AUTHOR_SKILL_BLOCKED | block (pass) |
| Case C: `gh pr create --body-file` context absent | block PR_CONTEXT_MISSING | block (pass) |
| Case C: `gh pr edit --body-file` context absent | block PR_CONTEXT_MISSING | block (pass) |
| allowed: `gh pr create --body-file` context present | allow | allow (pass, with valid sentinel mock) |
| allowed: `gh pr edit --body-file` context present | allow | allow (pass, with valid sentinel mock) |
| allowed: `gh pr edit --title` (no body flag) | allow | allow (pass) |
| allowed: `gh pr edit --add-label` (no body flag) | allow | allow (pass) |
| allowed: `gh pr view` / `list` / `merge` / `checkout` | allow | allow (pass) |
| allowed: `gh issue create` (not guarded) | allow | allow (pass) |
| end-to-end: empty input | exit 0 allow | exit 0 allow (pass) |
| end-to-end: Case A inline body | exit 0 block | exit 0 block (pass) |
| end-to-end: malformed JSON | exit 1 | exit 1 (pass) |

## Verification

- Command: `Invoke-Pester` over `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`.
- Result: 41 tests, 0 failures, 0 errors. All pre-existing expectations preserved.
- `gh pr edit --title` (no body flag) continues to short-circuit to allow without requiring a sentinel.
