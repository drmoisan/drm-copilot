# Pass-After Audit — Repository Root (#414, [P1-T3])

Timestamp: 2026-07-25T21-42

Command: `npm audit --audit-level=moderate` (working directory: repository root, AFTER the [P1-T1] manifest edit and [P1-T2] lockfile regeneration)
EXIT_CODE: 0

## Verbatim Output

```text
found 0 vulnerabilities
```

## Fail-Before / Pass-After Comparison

| Run | Artifact | EXIT_CODE | Findings |
|---|---|---|---|
| Fail-before ([P0-T7]) | `evidence/baseline/npm-audit-fail-before-root.2026-07-25T17-01.md` | 1 | 22 high, all GHSA-mh99-v99m-4gvg |
| Pass-after ([P1-T3]) | this artifact | 0 | 0 |

Output Summary: `npm audit --audit-level=moderate` now exits 0 in the repository root with `found 0 vulnerabilities`, down from 22 high-severity GHSA-mh99-v99m-4gvg findings at the pre-edit baseline. This satisfies the `spec.md` acceptance criterion "`npm audit --audit-level=moderate` exits 0 in the repository root (`.`)".
