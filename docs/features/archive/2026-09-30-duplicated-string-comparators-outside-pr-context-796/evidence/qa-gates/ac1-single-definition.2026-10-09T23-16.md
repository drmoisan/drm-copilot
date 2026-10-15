# QA gate: AC-1 single definition (P4-T7, pass 2)

Timestamp: 2026-10-09T23-16
Command: git grep --untracked -n -E "function compareCodePoint|const compareCodePoint" -- extensions/drm-copilot/src; git grep --untracked -n -w -E "compareStrings|compareOrdinal" -- extensions/drm-copilot/src; git grep --untracked -n -E "^[[:space:]]*import([^[:alnum:]_]|$)" -- extensions/drm-copilot/src/lib/string-ordering.ts; git grep --untracked -n -F "require(" -- extensions/drm-copilot/src/lib/string-ordering.ts
EXIT_CODE: 0
Output Summary:
- (1) exit 0, exactly one line: `extensions/drm-copilot/src/lib/string-ordering.ts:53:export function compareCodePoint(left: string, right: string): number {` (baseline P0-T17: one line in pr-context/models.ts:355).
- (2) exit 1, no match (baseline: 27 lines).
- (3) exit 1, no match (baseline: the same pattern matched models.ts:26, proving it can match).
- (4) exit 1, no match.
- These are the D7 portable forms of the spec AC-1 commands (`-w` replaces `\b`, `[[:space:]]` replaces `\s`).
- Result: PASS.
