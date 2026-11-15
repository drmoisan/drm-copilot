# Task check P3-T5

Timestamp: 2026-11-15T20-06
Command: `git grep -n -F -e "- [ ] AC-" -- docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192/spec.md`; `git diff --numstat` on `spec.md`.
EXIT_CODE: 1 for the search with no output (no unchecked AC, as required); 0 for the diff.
Output Summary:
- Changed file: `spec.md` (ten AC boxes set, each with an evidence reference appended on the same line).
- Diff numstat 10 added and 10 removed: no line shifted other than the ten box lines.
- The hyphen-leading pattern is passed through `-e`.
