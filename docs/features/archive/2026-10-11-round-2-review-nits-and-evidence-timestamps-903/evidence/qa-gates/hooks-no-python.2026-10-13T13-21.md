# AC-45 Hooks Introduce No Python Invocation (P12-T19)

Timestamp: 2026-10-13T13-21
Command: git diff -U0 origin/main...HEAD -- .claude/hooks .codex/hooks > artifacts/scratch-903/hooks-diff-903.txt; grep -E '^\+' artifacts/scratch-903/hooks-diff-903.txt | grep -vE '^\+\+\+' | sed 's/^+//' | grep -cE '(^|[[:space:];|&(])(python3?|poetry|py)[[:space:]]'
EXIT_CODE: 0
HEAD: 92e85dd747c6cbabda41de18c0637c3139cb0414

The diff exited 0 and was written to `artifacts/scratch-903/hooks-diff-903.txt` (not committed). The plan regex `(^|[\s;|&(])(python3?|poetry|py)\s` is applied in its POSIX-class form (`[[:space:]]` for `\s`) to the text of each added line after its leading `+`, excluding `+++` file-header lines.

- Added lines scanned (excluding `+++` headers): 285
- Regex matches: 0
- Matching lines: none

Regex sanity check (shows the pattern can match): over the three sample lines `poetry run x`, `& python3 -c`, and `nopython here`, the same `grep -cE` printed `2` (the first two match, the third does not).

Match count: 0

Output Summary: PASS. 0 of 285 added lines in `.claude/hooks` and `.codex/hooks` match the Python-invocation regex.
