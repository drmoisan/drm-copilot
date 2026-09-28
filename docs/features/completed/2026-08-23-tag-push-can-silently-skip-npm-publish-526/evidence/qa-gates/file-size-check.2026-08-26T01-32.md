# File-Size Check — Phase 3 (P3-T11)

Timestamp: 2026-08-26T01-32

Filename-stamp substitution: the plan fixes every evidence filename at
`.2026-08-24T13-10.md`. This execution ran on a different date, so the stamp
`2026-08-26T01-32` was substituted into that position per the plan's "Evidence
filename timestamps" rule. The path prefix and base name are unchanged.

Command: `wc -l scripts/dev-tools/Invoke-ReleaseTagPush.ps1 scripts/dev-tools/Invoke-ReleaseVerification.ps1`

EXIT_CODE: 0

Output Summary:

| File | Lines | Cap | Verdict |
|---|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | 278 | 500 | PASS |
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 499 | 500 | PASS |

Both recorded counts are at most 500, so the acceptance condition of P3-T11 is
satisfied.

Notes:

- `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` grew from 213 lines to 278 lines
  in Phase 3 (dot-source of the verification module, the pre-push inverted
  registry check, the dependency-ordered tag loop, the inter-push gate, the
  extension post-push verification, and the Codex pin guard). It retains 222
  lines of headroom against the cap.
- `scripts/dev-tools/Invoke-ReleaseVerification.ps1` is unchanged by Phase 3 and
  remains at 499 lines, exactly as the plan's "Known constraint — file-size
  headroom on the verification module" section requires. Phase 3 added no code
  to that file.
- The formatter (`mcp__drm-copilot__run_poshqc_format`) was run before these
  counts were taken and changed zero files, so the counts above are post-format
  figures.

Related file (not in this task's acceptance clause, recorded for continuity with
P7-T8, which does enumerate it): `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1`
stands at 491 lines against the same 500-line cap.
