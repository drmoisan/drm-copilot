# Facade Header Edit (Remediation Cycle 1, P1-T3)

Timestamp: 2026-09-27T19-54
Command: sh SCRATCH/run-ps.sh SCRATCH/function-body-equal.ps1 -Path .claude/lib/blast-radius/BlastRadius.psm1 -Name Test-BlastRadiusConflict -BaseSha <R_HEAD, then R_MAIN_BASE>; git diff --name-only f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d -- .claude/lib/blast-radius/BlastRadius.psm1; git status --porcelain -- .claude/lib/blast-radius/BlastRadius.psm1
EXIT_CODE: 0

## Edit applied (Appendix S, S6)

Header lines 21-23 now read:

```text
    It also re-exports two scheduling functions of BlastRadiusScheduling.psm1
    (issue #722); each takes the relation as -Relation, so a caller passes
    ${function:Test-BlastRadiusConflict} from this facade:
```

Nothing else in the file changed (git diff --stat against R_HEAD: 1 file changed, 2 insertions(+), 2 deletions(-)).

## Outputs (verbatim)

A9 with -BaseSha f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d (R_HEAD), exit 0:

```text
BODY-EQUAL=True
```

A9 with -BaseSha beae3f021674e64fa6662097fe48a332d8da62b8 (R_MAIN_BASE), exit 0:

```text
BODY-EQUAL=True
```

git diff --name-only f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d -- .claude/lib/blast-radius/BlastRadius.psm1, exit 0:

```text
.claude/lib/blast-radius/BlastRadius.psm1
```

git status --porcelain -- .claude/lib/blast-radius/BlastRadius.psm1, exit 0:

```text
 M .claude/lib/blast-radius/BlastRadius.psm1
```

Output Summary: PASS. Both A9 runs print BODY-EQUAL=True (Test-BlastRadiusConflict unchanged against R_HEAD and R_MAIN_BASE); the anchored diff lists the one path and the porcelain status prints one line for it.
