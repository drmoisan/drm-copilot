# Coverage Delta (P2-T12, AC-17)

Timestamp: 2026-10-12T15-19
Command: comparison of evidence/baseline/ci-coverage-main.2026-10-12T14-33.md (P0-T13) and evidence/qa-gates/ci-coverage-perfile.2026-10-12T15-18.md (P2-T11)
EXIT_CODE: 0

Baseline source: main push CI run 38286041896 (headSha 88946d10a47911a426abec906b2b2163814f5950).
Post-change source: PR #919 CI run 38294481892 (headSha 59fa06a04f8b75dcf9dc43466f8758f2345bd2c8).

| File | Baseline pct (P0-T13) | Post-change pct (P2-T11) | Difference | Changed-line pct | Changed-line uncovered |
|---|---|---|---|---|---|
| HostTooling.psm1 | 94.74 (36/38) | 95.24 (40/42) | +0.50 | 100.00 (5/5) | none |
| HostBootstrapWorkspace.psm1 | 100.00 (70/70) | 100.00 (64/64) | +0.00 | 100.00 (6/6) | none |
| HostBootstrap.psm1 | 100.00 (155/155) | 100.00 (154/154) | +0.00 | 100.00 (3/3) | none |
| publish-sideloaded-extension.ps1 | 100.00 (24/24) | 100.00 (32/32) | +0.00 | 100.00 (16/16) | none |

Verdict: PASS

## Output Summary:

Every post-change pct and every changed-line pct is >= 85.00. No file regressed: HostTooling.psm1 rose from 94.74 to 95.24; the other three files remain at 100.00. Instrumented-line counts changed with the edits (HostBootstrapWorkspace.psm1 70 to 64, HostBootstrap.psm1 155 to 154, publish-sideloaded-extension.ps1 24 to 32, HostTooling.psm1 38 to 42). Changed-line coverage is 100.00 with no uncovered changed line in any file.
