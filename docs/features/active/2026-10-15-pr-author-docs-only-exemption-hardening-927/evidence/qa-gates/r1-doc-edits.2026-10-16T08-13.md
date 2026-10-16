# R1 Documentation Edits (Issue #927, CR-6, CR-10; checkbox state unchanged)

Timestamp: 2026-10-16T08-13
Command: grep -c -E '^- \[x\] AC-M?[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md
EXIT_CODE: 0
Output Summary: spec.md revision 1.3 keeps 41 checked and 6 pending criteria (47 total). The only research-folder change since R1_START_HEAD is the superseded-duplicate line in research-addendum-merge-gate.2026-10-15T19-46.md (M, no rename, no deletion).

CHECKED_COUNT: 41

Command 2: grep -c -E '^- \[ \] AC-(9|18|19|21|M23|M24) ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md
EXIT_CODE_2: 0
PENDING_COUNT: 6

Command 3: grep -c -E '^- \[[ x]\] AC-M?[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md
EXIT_CODE_3: 0
TOTAL_COUNT: 47

Command 4: git diff --name-status 8ee8f25311f6bbc3777b0068100cf497bd6a7a03 -- docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research
EXIT_CODE_4: 0
DIFF_LINE: M	docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research/research-addendum-merge-gate.2026-10-15T19-46.md

Command 5: git status --porcelain -- docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research
EXIT_CODE_5: 0
STATUS_LINE:  M docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/research/research-addendum-merge-gate.2026-10-15T19-46.md
