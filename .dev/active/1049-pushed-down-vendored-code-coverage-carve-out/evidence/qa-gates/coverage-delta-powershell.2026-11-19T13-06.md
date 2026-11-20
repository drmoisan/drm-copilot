# Coverage Delta - PowerShell - [P4-T5]

Timestamp: 2026-11-19T13-06
Command: sh SCRATCH/issue-1049-delta.sh (PowerShell 7: reads the [P0-T6] merged coverage copy and the [P4-T4] merged artifacts/pester/powershell-coverage.xml copy, both kept under SCRATCH; changed lines are the `git diff --unified=0 BASE -- <file>` hunks, BASE = merge base of origin/epic/shared-agent-harness-layer-integration and HEAD, intersected with the XML executable lines of the current report)
EXIT_CODE: 0
Output Summary: PASS. Coverage source MERGED (the [P4-T4] run had ExitCode 0). Every changed PowerShell production file is at or above 85% line coverage with no drop against the Phase 0 baseline; changed-line coverage is 100% for each modified file and 99.09% for the new file; zero changed executable lines that were covered in the baseline are uncovered now. Repo-wide line coverage 96.77% to 96.78%.

## Per-file line coverage

| File | Phase 0 baseline | Post-change | Change | Changed executable lines covered | Uncovered changed lines | Result |
| --- | --- | --- | --- | --- | --- | --- |
| scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1 (new) | n/a - no pre-change run | 99.09% (109/110) | n/a | 109/110 (99.09%) | 107 (the throw for a manifest document that parses to a non-object JSON value) | PASS (threshold 85%) |
| scripts/powershell/PoshQC/PoshQC.Coverage.psm1 | 94.55% (104/110) | 94.92% (112/118) | +0.37 | 12/12 (100%) | none | PASS |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 94.17% (210/223) | 94.30% (215/228) | +0.13 | 5/5 (100%) | none | PASS |
| scripts/powershell/PoshQC/PoshQC.psm1 | 88.52% (54/61) | 88.52% (54/61) | 0.00 | 0/0 (the change adds list entries with no executable line of their own) | none | PASS |
| scripts/powershell/PoshQC/PoshQC.psd1 | n/a | n/a | n/a | no executable lines | n/a | N/A |

The bundle copies under extensions/drm-copilot/resources/powershell/PoshQC/ are byte-identical mirrors outside the coverage roots and are not measured separately.

## Repo-wide

| Measure | Phase 0 baseline | Post-change |
| --- | --- | --- |
| Line coverage | 96.77% (47184/48759) | 96.78% (47306/48882) |

## Baseline-covered lines now uncovered

For each modified file, every changed executable line is covered in the post-change report, so no changed line that was covered in the baseline is uncovered now (count 0). The uncovered line sets outside the changed hunks are the same lines as at baseline, shifted by the inserted lines: PoshQC.Coverage.psm1 75, 96, 163, 256, 257, 258 at baseline and 76, 97, 165, 263, 264, 265 now; PoshQC.Testing.psm1 94, 95, 98, 99, 103, 104, 105, 275, 284, 322, 323, 324, 326 at baseline and 94, 95, 98, 99, 103, 104, 105, 278, 287, 325, 326, 327, 329 now; PoshQC.psm1 20 to 25 and 136 at baseline and 20 to 25 and 137 now.
