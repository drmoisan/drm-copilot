# Routing-pair byte compare (Issue #500)

Timestamp: 2026-08-22T00:14:00Z
Issue: #500
Task: [P7-T5]

Command:

```powershell
Get-FileHash -Algorithm SHA256 'config/orchestration-routing.json'
Get-FileHash -Algorithm SHA256 'extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json'
```

(working directory: worktree root, under PowerShell 7.6.5)

EXIT_CODE: 0

Output Summary: the two SHA256 digests are **equal**.

| Path | SHA256 |
| --- | --- |
| `config/orchestration-routing.json` | `D9C6657CBDBE15413E0FB9BC1BE700CE1A8F892D0DB413C3BBC253EA24EA7BDA` |
| `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` | `D9C6657CBDBE15413E0FB9BC1BE700CE1A8F892D0DB413C3BBC253EA24EA7BDA` |

The pair is confirmed byte-identical **independently of its TypeScript test**. `Get-FileHash` reads
the two files directly, so this confirmation does not depend on the Jest suite that also asserts the
relation, and it does not depend on the Python parity suite either.

This discharges the second half of spec AC17. The first half — the `git log --follow` divergence
walk over both copies of `config/blast-radius.json` — is discharged by
`evidence/other/divergence-commit-walk.2026-08-21T21-47.md` and cited by
`evidence/other/divergence-walk-citation.2026-08-21T23-04.md` under [P0-T16].

`.claude/rules/parallel-orchestration.md` records that the `parallel` route entry in
`config/orchestration-routing.json` is "mirrored byte-for-byte" in the bundled copy. This measurement
confirms that statement holds for the whole file, not only for that entry.
