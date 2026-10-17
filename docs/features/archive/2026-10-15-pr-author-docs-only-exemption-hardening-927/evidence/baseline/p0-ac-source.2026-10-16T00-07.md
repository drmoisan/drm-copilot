# P0-T1 Requirements-Source Check (issue #927)

Timestamp: 2026-10-16T00-07
Command: grep -c '^## Acceptance Criteria' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md
EXIT_CODE: 0
Output Summary: AC heading count 1; create-side AC count 22; merge-side AC count 25; Work Mode full-bug marker count 1; spec.md present, user-story.md absent. Requirements source is valid.

## Commands and results

- `grep -c '^## Acceptance Criteria' .../spec.md` -> `1` (EXIT_CODE: 0)
- `grep -c -E '^- \[ \] AC-[0-9]+ ' .../spec.md` -> `22` (EXIT_CODE: 0)
- `grep -c -E '^- \[ \] AC-M[0-9]+ ' .../spec.md` -> `25` (EXIT_CODE: 0)
- `grep -c -F -e '- Work Mode: full-bug' .../issue.md` -> `1` (EXIT_CODE: 0)
- `ls docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927` -> `issue.md`, `plan.2026-10-15T07-41.md`, `research/`, `spec.md` (EXIT_CODE: 0)

AC_SOURCE: spec.md `## Acceptance Criteria`
USER_STORY_PRESENT: no
