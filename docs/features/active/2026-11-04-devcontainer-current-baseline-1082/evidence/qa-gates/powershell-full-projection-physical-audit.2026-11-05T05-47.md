Timestamp: 2026-11-05T05-47
Command: python SCRATCH/issue-1082-verify-projection.py
EXIT_CODE: 1
Output Summary:

Physical byte audit checked all 35576 tracked paths at HEAD 726184cc65c685d17876be32de2f776441e914f5 with the exact current binary diff applied. 35540 files were byte-identical; 36 differed by line endings and required explicit classification. No tracked file was missing. Host physical tree digest: 018c5daa5c5a585198d3b6dedb2944e4ee95601c3a764ff1901a0fd741b71d3a. Raw details: SCRATCH/issue-1082-current-source-manifest.json. This physical-byte result alone is not a passing parity claim; the subsequent normalized audit classifies every mismatch.
