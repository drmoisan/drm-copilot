# r3 Final CR-18 and CR-19 Documentation (P5-T15)

Timestamp: 2026-10-16T22-39
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; Select-String -SimpleMatch counts in scripts/powershell/PoshQC/README.md of "a negative weight is rejected", "CRLF line endings counted as LF", "Sharded runs (issue #953)", "every runner that checks out the same tree"; and in scripts/powershell/PoshQC/PoshQC.Shard.psm1 of "or a weight is negative (CR-18)." and "weighs the UTF-8 size of its text with CRLF counted as LF"' (SCRATCH/issue-953-r3-p5-t15.sh)
EXIT_CODE: 0
Output Summary:
- README: `a negative weight is rejected` 1; `CRLF line endings counted as LF` 1; `Sharded runs (issue #953)` 1; `every runner that checks out the same tree` 0
- PoshQC.Shard.psm1: `or a weight is negative (CR-18).` 1; `weighs the UTF-8 size of its text with CRLF counted as LF` 1
- README pair identical: PAIR_EQUAL README.md YES in r3-final-bundle-identity.2026-10-16T22-38.md
- Result: PASS.
