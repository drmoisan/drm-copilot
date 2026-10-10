# Evidence filename stamps versus recorded timestamps (superseding note; written under #846)

Timestamp: 2026-10-09T21-37
Command: git grep -n -e "^Timestamp:" -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/
EXIT_CODE: 0
Output Summary: 12 lines printed, 11 of them in files stamped 2026-09-30T05-20; the twelfth is evidence/baseline/phase0-instructions-read.md (Timestamp 2026-09-30T09-47), which carries no filename stamp. The command was run before this note was created.
Supersedes: none (clarifies the filename stamps)

| File | Filename stamp | Recorded Timestamp |
| --- | --- | --- |
| evidence/baseline/baseline-citation-grep.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-50 |
| evidence/baseline/baseline-code-source-diff.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-50 |
| evidence/baseline/baseline-pytest.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-49 |
| evidence/baseline/baseline-rootfolders-diff.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-50 |
| evidence/baseline/minor-audit-preconditions.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-48 |
| evidence/qa-gates/final-citation-grep.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-58 |
| evidence/qa-gates/final-pytest.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-58 |
| evidence/qa-gates/final-rootfolders-diff.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-58 |
| evidence/qa-gates/final-toolchain-applicability.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-58 |
| evidence/regression-testing/edit-diff.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-55 |
| evidence/regression-testing/targeted-parity-test.2026-09-30T05-20.md | 2026-09-30T05-20 | 2026-09-30T09-55 |

The filename stamp 2026-09-30T05-20 was the plan-assigned stamp; the Timestamp field is the authoritative run time. No file is renamed (written under #846).
