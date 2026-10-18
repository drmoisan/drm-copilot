# P3-T1 corrected provider verification

Timestamp: 2026-10-18T12-12
Command: poetry run python SCRATCH/issue-980-p3t1-resume-binding.py
EXIT_CODE: 0
Output Summary: The native correction is exactly 0x80 to 0x81 plus one comment; reversing it restores the pre-pause raw SHA. Mutation plan, I/O and report helper hashes remain unchanged. The 42-case memory proof is retained without a broad rerun.

Exact proof and hashes: [p3t1-executor-resume-binding.2026-10-18T12-12.json](p3t1-executor-resume-binding.2026-10-18T12-12.json). The early six-case native smoke is diagnostic; the final ordered integration result and complete task gates remain required. P3-T1 is unchecked.

```text
AFFECTED_CORRECTION_VERIFIED; retained mutation cases: 42; corrected provider cases: 3; findings: [].
```
