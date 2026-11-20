# Escape round-trip probe (P2-T7)

Timestamp: 2026-11-04T15-50
Command: sh SCRATCH/issue-1067-escape-probe.sh (pwsh -NoProfile -File SCRATCH/issue-1067-escape-probe.ps1)
EXIT_CODE: 0

```
INPUT=quote'root
ESCAPED=quote''root
ESCAPE-ROUNDTRIP=True
UNESCAPED-ERROR At line:1 char:12
UNESCAPED-PARSE=error
```

Output Summary: ESCAPE-ROUNDTRIP=True (the script block built from the `EscapeSingleQuotedStringContent` output evaluates to the original `quote'root`) and UNESCAPED-PARSE=error (the same input interpolated without the helper is not valid script-block source). This is the defect R1-F2 and R1-F4 describe, and the escape applied in P2-T1 to P2-T3 closes it.
