# Scheduling Module Edit (Remediation Cycle 1, P1-T2)

Timestamp: 2026-09-27T19-54
Command: sh SCRATCH/run-ps.sh SCRATCH/relation-audit.ps1 -Root "." (LOOKUP-AUDIT line); git grep -c -F -e '& $Relation -RadiusA' -- .claude/lib/blast-radius/BlastRadiusScheduling.psm1; sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1
EXIT_CODE: 0

## Edits applied (Appendix S, S1 through S5)

- S1: header note now states the caller supplies the relation as the [scriptblock] -Relation.
- S2: the comment and the constants RelationCommand and FacadeModule replaced by the RelationRequired message constant (single-quoted).
- S3: Get-ConflictRelationCommand, its two comment lines, and the following blank line deleted.
- S4: Get-BlastRadiusPairDecision gains the .PARAMETER Relation help block, the [scriptblock] $Relation parameter, the fail-fast guard, and the invocation "& $Relation -RadiusA ...".
- S5: Get-BlastRadiusConflictEdge gains the .PARAMETER Relation help block, the [scriptblock] $Relation parameter, the fail-fast guard as the first body line, and forwards -Relation $Relation to every pair decision.

## Outputs (verbatim)

R3 (exit 0):

```text
LOOKUP-AUDIT RelationHelperLines=0 GetCommandLines=0
```

git grep (exit 0):

```text
.claude/lib/blast-radius/BlastRadiusScheduling.psm1:1
```

A4 (exit 0):

```text
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 LineCount=486
```

Output Summary: PASS. LOOKUP-AUDIT RelationHelperLines=0 GetCommandLines=0; the new literal "& $Relation -RadiusA" occurs once (absent at R_HEAD); LineCount=486 (at most 500, and equal to the expected size stated in Appendix S).
