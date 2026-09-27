# Detection Relation Unchanged, Final (P14-T4)

Timestamp: 2026-09-27T17-59
Command: git diff --name-only beae3f021674e64fa6662097fe48a332d8da62b8 -- scripts/dev_tools/_blast_radius_conflicts.py scripts/dev_tools/_blast_radius_glob.py scripts/dev_tools/_blast_radius_mergeable.py .claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 ; git status --porcelain -- <same pathspec> ; sh SCRATCH/run-ps.sh SCRATCH/function-body-equal.ps1 -Path .claude/lib/blast-radius/BlastRadius.psm1 -Name Test-BlastRadiusConflict -BaseSha beae3f021674e64fa6662097fe48a332d8da62b8
EXIT_CODE: 0
Output Summary: PASS. Repeat of P7-T3 on the merged tree with FINAL_BASE (beae3f021674e64fa6662097fe48a332d8da62b8) in place of BASE_SHA, both as the name-diff base and as the -BaseSha argument of script A9. The FINAL_BASE-anchored name diff over the block B30 detection-module pathspec printed nothing (exit 0) and the porcelain status over the same pathspec printed nothing (exit 0). All five pathspec entries are tracked (git ls-files lists all five), so the empty output is not a pathspec that matches nothing. Script A9 printed BODY-EQUAL=True for Test-BlastRadiusConflict in the facade against FINAL_BASE.

## Command outputs

```text
$ git diff --name-only beae3f021674e64fa6662097fe48a332d8da62b8 -- <B30 pathspec>
(no output; exit 0)

$ git status --porcelain -- <B30 pathspec>
(no output; exit 0)

$ git ls-files -- <B30 pathspec>
.claude/lib/blast-radius/BlastRadiusConflict.psm1
.claude/lib/blast-radius/BlastRadiusGlob.psm1
scripts/dev_tools/_blast_radius_conflicts.py
scripts/dev_tools/_blast_radius_glob.py
scripts/dev_tools/_blast_radius_mergeable.py

$ sh SCRATCH/run-ps.sh SCRATCH/function-body-equal.ps1 -Path .claude/lib/blast-radius/BlastRadius.psm1 -Name Test-BlastRadiusConflict -BaseSha beae3f021674e64fa6662097fe48a332d8da62b8
BODY-EQUAL=True
(exit 0)
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
