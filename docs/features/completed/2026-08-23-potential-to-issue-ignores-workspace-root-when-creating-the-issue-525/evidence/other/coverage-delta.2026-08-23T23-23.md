# Coverage Delta — Baseline vs Post-Change ([P6-T5])

Timestamp: 2026-08-25T10-14

Command: awk '/^SF:/{f=$0} /^SF:/{keep=(f ~ /gh-client\.ts$/ || f ~ /repo-slug\.ts$/ || f ~ /potential-to-issue-service-call\.ts$/ || f ~ /mcp-tools\.ts$/ || f ~ /repo-automation-service-contract\.ts$/)} keep && /^(SF:|LF:|LH:|BRF:|BRH:|FNF:|FNH:)/{print}' coverage/lcov.info

EXIT_CODE: 0

Baseline source: `evidence/baseline/ts-changed-file-coverage.2026-08-23T23-23.md` ([P0-T9]), read from
the lcov report of the [P0-T8] run.
Post-change source: `extensions/drm-copilot/coverage/lcov.info`, produced by the [P6-T4] run of
`npm --prefix extensions/drm-copilot run test:coverage` (EXIT_CODE 0).
Working directory for the command above: `extensions/drm-copilot`.

## Output Summary

Five rows: the four files carried in the [P0-T9] baseline plus the new resolver module. **No changed
file regressed on line coverage, no changed file regressed on branch coverage, and every gated file
meets the 85% line and 75% branch thresholds.**

| # | File | Baseline line | Post line | Line delta | Baseline branch | Post branch | Branch delta | Gated | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `src/lib/potential-to-issue/gh-client.ts` | 100.00% | 100.00% | 0.00 | 79.31% | 81.82% | **+2.51** | yes | no regression; meets 85/75 |
| 2 | `src/lib/potential-to-issue/repo-slug.ts` (new) | n/a — file did not exist | 100.00% | n/a | n/a — file did not exist | 100.00% | n/a | yes | new file; meets 85/75 |
| 3 | `src/lib/potential-to-issue/potential-to-issue-service-call.ts` | 100.00% | 100.00% | 0.00 | 83.33% | 85.00% | **+1.67** | yes | no regression; meets 85/75 |
| 4 | `src/mcp-tools.ts` | 92.50% | 94.14% | **+1.64** | 82.76% | 86.67% | **+3.91** | no | no regression |
| 5 | `src/repo-automation-service-contract.ts` | 0.00% | 0.00% | 0.00 | 0.00% | 0.00% | 0.00 | no | no regression; see note |

Every changed file's line delta and branch delta is greater than or equal to zero. Three of the five
files improved on branch coverage and one improved on line coverage; the remaining movements are
exactly zero. There is no negative delta in the table.

### Gated files against the thresholds

The three gated files are the entries [P4-T6] added to the threshold map in
`extensions/drm-copilot/jest.config.cjs`, each at 85 lines and 75 branches:

| File | Line | Threshold | Margin | Branch | Threshold | Margin |
| --- | --- | --- | --- | --- | --- | --- |
| `./src/lib/potential-to-issue/gh-client.ts` | 100.00% | 85% | +15.00 | 81.82% | 75% | +6.82 |
| `./src/lib/potential-to-issue/repo-slug.ts` | 100.00% | 85% | +15.00 | 100.00% | 75% | +25.00 |
| `./src/lib/potential-to-issue/potential-to-issue-service-call.ts` | 100.00% | 85% | +15.00 | 85.00% | 75% | +10.00 |

All three clear both thresholds. This is corroborated independently by the [P6-T4] exit code: Jest
fails the run when any configured per-path threshold is unmet, so `EXIT_CODE: 0` on that gate is a
second, mechanical confirmation of the same three results.

The narrowest margin in the change is `gh-client.ts` at 81.82% branch, +6.82 over the floor. [P0-T9]
flagged this file as the narrowest baseline margin at 79.31%; the added selector branches are covered
by the [P1-T2], [P4-T1], and [P4-T2] tests, so the margin widened rather than narrowed.

## Raw Counters

Post-change, read verbatim from `extensions/drm-copilot/coverage/lcov.info`:

```
SF:src\mcp-tools.ts
LF:324
LH:305
BRF:60
BRH:52
SF:src\repo-automation-service-contract.ts
LF:182
LH:0
BRF:1
BRH:0
SF:src\lib\potential-to-issue\gh-client.ts
LF:358
LH:358
BRF:33
BRH:27
SF:src\lib\potential-to-issue\potential-to-issue-service-call.ts
LF:238
LH:238
BRF:20
BRH:17
SF:src\lib\potential-to-issue\repo-slug.ts
LF:193
LH:193
BRF:19
BRH:19
```

Percentages are computed as `LH / LF` and `BRH / BRF`, rounded to two decimal places, which is the
same method [P0-T9] used for the baseline figures. Jest's own text reporter truncates rather than
rounds, so it renders row 1's branch figure as `81.81%` where the rounded computation above gives
`81.82%`; both denote the identical counter pair 27/33 and neither affects the threshold verdict.

## Notes on Individual Rows

- **Row 2 has no baseline and therefore no delta.** `repo-slug.ts` was created by [P2-T1]; it did not
  exist at [P0-T9] time, so "no regression" is vacuously true for it and the meaningful check is the
  threshold check, which it passes at 100.00% on both metrics. Its 19 of 19 branches include all
  seven enumerated unresolvable conditions from spec E3 that are reachable; the sixth E3 bullet is
  annotated unreachable by [P5-T1] and has no branch to cover.
- **Row 4 grew in both metrics despite being a smaller edit.** [P3-T7] added the conditional spread to
  the projection helper, and [P4-T4] and [P4-T5] cover both arms of it, which is why the new branch
  did not dilute the ratio.
- **Row 5 is unchanged at 0.00% on both metrics, which is correct and is not a regression.**
  `repo-automation-service-contract.ts` is an interface-only contract file whose type declarations are
  erased at transpile time, so it is never executed and legitimately reports zero executable coverage.
  [P3-T6] added an optional interface property, which emits no executable statement. It carries no
  threshold entry, for the reason already documented in that file and recorded by [P4-T6]. The line
  and branch counts moved (176 to 182 found lines) because the interface gained a declaration, but
  both hit counts remain 0 and both ratios remain 0.00%, so the delta is exactly zero.

## Whole-Project Figures for Context

| Metric | Baseline ([P0-T8]) | Post-change ([P6-T4]) | Delta |
| --- | --- | --- | --- |
| Overall line | 96.66% (43084 / 44571) | 96.69% (43349 / 44831) | +0.03 |
| Overall branch | 90.05% (6128 / 6805) | 90.12% (6158 / 6833) | +0.07 |

Both whole-project metrics moved upward. The configuration has no global threshold key, so these
figures are context rather than a gate.

## Method Note

Both the baseline and the post-change figures are read from the `lcov` reporter output of the two
coverage runs the plan already required ([P0-T8] and [P6-T4]). No additional test run was performed
for this comparison. The `text-summary` reporter emits whole-project totals only and no per-file rows,
which is why the per-file figures come from `lcov.info`.
