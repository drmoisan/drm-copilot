# Baseline: generator output hash before the fix

Timestamp: 2026-10-28T22-45
Command: scripts/ci/New-FileSizeBaseline.ps1 -Ref a7a928d59fd52610c1a627448c8fffac106b23c5 -OutputPath SCRATCH/issue-990-baseline-before.json (ref = git merge-base of origin/main and HEAD), then Get-FileHash -Algorithm SHA256 and a byte comparison with config/file-size-baseline.json
EXIT_CODE: 0
Output Summary:
- SHA256 of the pre-fix output: 8ed473b7fda2623b51c3b5fa41a5e134398d4e49f1b93ad6649cd5f1ddc6f4ea
- Equals the reference value 8ed473b7fda2623b51c3b5fa41a5e134398d4e49f1b93ad6649cd5f1ddc6f4ea: yes.
- Byte comparison with config/file-size-baseline.json: identical.
- This is the pre-fix reference for [P2-T3].
