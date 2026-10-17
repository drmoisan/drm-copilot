# ci.yml gating and A2, rule 17 RI-3 re-run of P4-T7

Timestamp: 2026-10-17T00-12
Command: git diff --numstat HEAD -- tests/scripts/workflows/CiWorkflow.Tests.ps1
EXIT_CODE: 0
Output Summary: After the merge, ci.yml keeps every G7 line (the auto-merge added only the #952 `merge_group:` / `types: [checks_requested]` lines to the on: block, which this plan does not edit; verified by the RI-4 re-run of P4-T14). The latest edit-points artifact records A2-APPLICABLE: yes, so A2 of section 7 was applied to the #952 row `reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph`: line 232 was replaced by the fifteen A2 lines and the `$allowedHits.Count` assertion was inserted after the `$eventFieldLines.Count` line (pre-edit line 236). Both pre-edit lines matched the A2 quotations exactly (CR-INVENTORY count=1 at lines 232 and 236). numstat prints `16	1` as required. The row's pass is observed by the RI-4 re-run of P4-T12.

## A2 record

- Old line 232: `            $eventFieldLines = @($graphLines | Where-Object { $_ -match 'github\.event\.pull_request|github\.head_ref|github\.base_ref|github\.event_name' })`
- New lines: the section 7 A2 block (the three comment lines, `$allowedEventFieldLines` with the five allowed G7 lines for ci.yml only, `$allowedHits`, and the filtered `$eventFieldLines`).
- Inserted after the existing line `            $eventFieldLines.Count | Should -Be 0 -Because "$graphFile must not read a pull-request event field, which a merge_group run does not carry"`: `            $allowedHits.Count | Should -Be $allowedEventFieldLines.Count -Because "$graphFile must carry each issue #962 change-scope event-field line exactly once"`

## numstat output

```
16	1	tests/scripts/workflows/CiWorkflow.Tests.ps1
```
