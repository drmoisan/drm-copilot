# Final QC — TypeScript coverage (Jest)

Timestamp: 2026-08-20T09-53

Task: [P8-T9]

Command: (from `extensions/drm-copilot`) npm run test:coverage -- --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov
EXIT_CODE: 0

The added `text` reporter is load-bearing: the script's configured reporters are `lcov` and
`text-summary` only, and `text-summary` prints no per-file rows.

## Overall coverage (text-summary block)

```
Statements   : 96.62% ( 41810/43272 )
Branches     : 89.98% ( 5912/6570 )
Functions    : 90.11% ( 1222/1356 )
Lines        : 96.62% ( 41810/43272 )
```

| Metric | Baseline ([P0-T15]) | Post-change | Delta |
| --- | --- | --- | --- |
| Overall LINE | 96.61% (41750/43212) | **96.62% (41810/43272)** | +0.01 pp |
| Overall BRANCH | 89.96% (5902/6560) | **89.98% (5912/6570)** | +0.02 pp |

Both are above the policy thresholds (line >= 85%, branch >= 75%) and neither regressed.

## Per-file coverage of the two changed TypeScript files

Read from the `text` table of this run:

```
File                       | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
 src/lib/pr-context        |   93.93 |    87.73 |   85.41 |   93.93 |
  collector-output.ts      |   97.57 |    81.01 |     100 |   97.57 | 112,253-256,300-303,374-375
  verification-evidence.ts |   96.36 |    83.72 |     100 |   96.36 | 130-131,270-271,281-282,292-293,298,300-301
```

| File | Baseline line | Post line | Baseline branch | Post branch |
| --- | --- | --- | --- | --- |
| `src/lib/pr-context/verification-evidence.ts` | 95.56% | **96.36%** | 80.00% | **83.72%** |
| `src/lib/pr-context/collector-output.ts` | 97.55% | **97.57%** | 80.51% | **81.01%** |

Both files improved on both metrics.

## `Uncovered Line #s` for `verification-evidence.ts` — no added or changed line (AC22)

`130-131, 270-271, 281-282, 292-293, 298, 300-301`. Each region is pre-existing code this change does
not touch:

- **130-131** — the `continue` for a colon-free line inside the parse loop. The baseline reported this
  same region as `106-107`; the additions shifted the numbering.
- **270-271** — the non-`root`-prefixed fallback in `relativeToPosix` (baseline `215-216`).
- **281-282, 292-293** — the `left > right` and `return 0` arms of `compareCodePoint` (baseline
  `226-227`, `237-238`).
- **298, 300-301** — the empty-string early return and the trailing-terminator `pop` in `splitLines`
  (baseline `243`, `245-246`).

Mapping baseline to post-change shows the SAME five uncovered regions in both runs, shifted by the 55
added lines. Every line the change added — the optional-field constant, the record member, the
exported `normalizeResult` helper, the separate accept `if`, the expectation read, the third
unparseable branch with its three `expectedExitCode: 0` assignments, the normalization call, and the
success-path expectation — is covered.

`collector-output.ts` uncovered regions (`112, 253-256, 300-303, 374-375`) are likewise the same
pre-existing regions the baseline reported as `112, 248-251, 295-298, 369-370`, shifted by the 5 added
lines; its added lines are covered by the three new renderer cases.

## Test outcome in the same run

```
Tests:       2580 passed, 2580 total
```

Output Summary: Jest coverage passes with exit code 0. Overall line coverage 96.62% (41810/43272) and
overall branch coverage 89.98% (5912/6570), both above threshold and both improved against the 96.61%
/ 89.96% baseline. Per file, `verification-evidence.ts` rose to line 96.36% / branch 83.72% from
95.56% / 80.00%, and `collector-output.ts` to line 97.57% / branch 81.01% from 97.55% / 80.51%. The
`Uncovered Line #s` set for `verification-evidence.ts` is `130-131, 270-271, 281-282, 292-293, 298,
300-301`, which maps region-for-region onto the baseline's uncovered set shifted by the added lines;
no line added or changed by this change is uncovered.
