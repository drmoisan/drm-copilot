# Coverage Delta - issue #1021, remediation cycle 1

Timestamp: 2026-11-04T00-55
Task: [P3-T5]
Command: comparison of `evidence/remediation-baseline/baseline-pester-coverage.2026-11-04T00-45.md` ([P0-T4]) with `evidence/qa-gates/qa-pester-coverage.2026-11-04T00-55.md` ([P3-T4]); changed lines read from the JaCoCo `line` elements of `artifacts/pester/powershell-coverage.xml` (no line of either edited module has `ci="0"`)
EXIT_CODE: 0
Output Summary: no module decreases; every `DocsPage*.psm1` is at 100.00% before and after; the 3 new executable lines of `DocsPageFrontMatter.psm1` and the 2 new executable lines of `DocsPageCheck.psm1` are all covered.

| Module | Baseline ([P0-T4]) | Post-change ([P3-T4]) | Delta |
|---|---|---|---|
| `DocsPageCheck.psm1` | 100.00% (157 of 157) | 100.00% (159 of 159) | 0.00 |
| `DocsPageDiataxis.psm1` | 100.00% (54 of 54) | 100.00% (54 of 54) | 0.00 |
| `DocsPageFrontMatter.psm1` | 100.00% (180 of 180) | 100.00% (183 of 183) | 0.00 |
| `DocsPageLinks.psm1` | 100.00% (114 of 114) | 100.00% (114 of 114) | 0.00 |
| `DocsPageMarkdown.psm1` | 100.00% (102 of 102) | 100.00% (102 of 102) | 0.00 |
| `DocsPageMetadata.psm1` | 100.00% (109 of 109) | 100.00% (109 of 109) | 0.00 |
| `DocsPageOrphans.psm1` | 100.00% (28 of 28) | 100.00% (28 of 28) | 0.00 |

## Changed-line coverage

- [P1-T2] `ConvertFrom-DocsPageFlowSequence`: the `$escaped` initialisation, the escaped-character branch, the backslash branch, the close-on-quote branch and the opening statement that resets the flag are covered (the module has no missed line; the escaped-backslash cases drive both escape branches). Changed-line coverage 100%.
- [P2-T2] `Get-DocsPageCheckFinding`: `$map = $LinkMap` and the null fallback line are covered by `Get-DocsPageCheckFinding rules` (no map passed) and by the `Invoke-DocsCheckCommand` tests (map passed). `Invoke-DocsCheckCommand`: the single `Get-DocsPageLinkMap` assignment, the external-target line and the `-LinkMap` pass-through line are covered. Changed-line coverage 100%.
