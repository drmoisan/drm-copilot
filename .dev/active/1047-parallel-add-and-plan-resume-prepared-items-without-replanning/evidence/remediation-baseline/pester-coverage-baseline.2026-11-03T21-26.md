# PowerShell Coverage Baseline (remediation cycle 2)

Timestamp: 2026-11-03T21-26
Task: [P0-T3]
Command: sha256sum .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 (worktree and `git show HEAD:` blob at branch head 17193681c), compared with the canonical hash in <FEATURE>/evidence/other/mirror-hashes.2026-11-03T20-31.md; figures carried from <FEATURE>/evidence/qa-gates/pester-coverage.2026-11-03T20-57.md
EXIT_CODE: 0
Output Summary: hash comparison equal (7f0a6920239db6b623a641f075d4ceb7d0776f686caa9af6aa87cacb7a21090a in both), so the cycle 1 final coverage run describes the same script. Baseline: Invoke-ParallelAdmission.ps1 217 covered, 8 missed, 96.44%; repo-wide report-level LINE 21594 covered, 1724 missed, 92.61%.

## Source artifacts

- Hash source: `<FEATURE>/evidence/other/mirror-hashes.2026-11-03T20-31.md` (lexicographically greatest `mirror-hashes.*.md`)
- Coverage source: `<FEATURE>/evidence/qa-gates/pester-coverage.2026-11-03T20-57.md` (lexicographically greatest `pester-coverage.*.md`)

## Hash comparison

| Item | SHA256 |
| --- | --- |
| Canonical hash in mirror-hashes.2026-11-03T20-31.md | 7f0a6920239db6b623a641f075d4ceb7d0776f686caa9af6aa87cacb7a21090a |
| Branch head blob (17193681c) | 7f0a6920239db6b623a641f075d4ceb7d0776f686caa9af6aa87cacb7a21090a |
| Result | equal |

## Baseline figures

| File | Covered | Missed | Line % |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 217 | 8 | 96.44 |
| Repo-wide (report-level LINE counter) | 21594 | 1724 | 92.61 |
