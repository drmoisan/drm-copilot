# PowerShell Changed-Line Coverage (Remediation Cycle 1, P2-T4)

Timestamp: 2026-09-27T20-06
Command: poetry run python SCRATCH/changed-lines-cov.py jacoco SCRATCH/rem-p2-directory.xml f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d .claude/lib/blast-radius/BlastRadiusScheduling.psm1 .claude/lib/blast-radius/BlastRadius.psm1
EXIT_CODE: 0

Base: R_HEAD (f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d). Report: the JaCoCo file written by the P2-T3 directory run.

## Output (verbatim)

```text
CHANGED file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Found=True ExecutableLines=118 ChangedExecutable=5 Covered=5 ChangedLinePercent=100.00
CHANGED file=.claude/lib/blast-radius/BlastRadius.psm1 Found=True ExecutableLines=107 ChangedExecutable=0 Covered=0 ChangedLinePercent=100.00
```

Output Summary: PASS. Exit 0; two CHANGED lines with Found=True; the scheduling module prints ChangedLinePercent=100.00 (5 of 5 changed executable lines covered, at least 85); the facade (comment-only change) prints ChangedExecutable=0 and ChangedLinePercent=100.00.
