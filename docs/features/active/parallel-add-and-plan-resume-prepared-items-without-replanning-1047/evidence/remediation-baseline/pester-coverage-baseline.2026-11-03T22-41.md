# PowerShell Coverage Baseline (remediation cycle 3)

Timestamp: 2026-11-03T22-41
Task: [P0-T3]
Command: sha256sum .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 at branch head b433ccc86; compared with the canonical hash in evidence/other/mirror-hashes.2026-11-03T21-27.md (lexicographically greatest mirror-hashes.*.md); figures carried from evidence/qa-gates/pester-coverage.2026-11-03T21-51.md (lexicographically greatest pester-coverage.*.md)
EXIT_CODE: 0
Output Summary: hash comparison equal (fee660825d4c800b935130cf8aee861c373259460f6c7a380a29a64f619bf69c in both), so the cycle 2 final-head coverage figures describe the current script. Baseline: Invoke-ParallelAdmission.ps1 219 covered, 8 missed, 96.48%; repo-wide report-level LINE 21596 covered, 1724 missed, 92.61%.

| Item | Value |
| --- | --- |
| Source artifact (hash) | evidence/other/mirror-hashes.2026-11-03T21-27.md |
| Source artifact (figures) | evidence/qa-gates/pester-coverage.2026-11-03T21-51.md |
| Head SHA256 of Invoke-ParallelAdmission.ps1 | fee660825d4c800b935130cf8aee861c373259460f6c7a380a29a64f619bf69c |
| Canonical SHA256 in mirror-hashes | fee660825d4c800b935130cf8aee861c373259460f6c7a380a29a64f619bf69c |
| Hash comparison | equal |
| Invoke-ParallelAdmission.ps1 covered / missed / % | 219 / 8 / 96.48 |
| Repo-wide report-level LINE covered / missed / % | 21596 / 1724 / 92.61 |
