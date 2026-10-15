# TypeScript Coverage Delta (#623)

Timestamp: 2026-09-30T08-55
Command: grep -n -F -e "<literal>" extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts (four literals); NODE-LCOV against "extensions/drm-copilot/coverage/lcov.info" (produced by P7-T5) with trailing arguments 443 444 445 447
EXIT_CODE: 0
Output Summary: Post-change coverage is not lower than baseline for either file on either metric. All four changed promotion.ts lines were executed (DA443=53, DA444=2, DA445=2, DA447=37).

## Changed-line greps (each printed exactly one line)

```
443:  if (!filesystem.exists(destPath)) {
444:    emitLine(`Promoted file missing after move: ${destPath}`);
445:    return { exitCode: 1, messages };
447:  emitLine(`Moved potential file to promoted folder: ${destPath}`);
```

## Baseline (P0-T13) vs post-change (P7-T5)

| File | Metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- | --- |
| promotion.ts | line | 438/443 = 98.87% | 445/450 = 98.89% | +0.02 |
| promotion.ts | branch | 54/65 = 83.08% | 57/68 = 83.82% | +0.74 |
| potential-to-issue-service-call.ts | line | 238/238 = 100.00% | 238/238 = 100.00% | 0.00 |
| potential-to-issue-service-call.ts | branch | 17/20 = 85.00% | 17/20 = 85.00% | 0.00 |
| text-summary total | Lines | 97.02% (49780/51304) | 97.02% (49787/51311) | 0.00 |
| text-summary total | Branches | 91.17% (7211/7909) | 91.17% (7214/7912) | 0.00 |

New/changed-code coverage (promotion.ts lines 443-447): 4 of 4 executable changed lines hit (100%); both outcomes of the line 443 branch are exercised (the move-verification suite covers the true branch and the success paths cover the false branch).

## NODE-LCOV output (verbatim; paths under extensions/drm-copilot/)

```
src/lib/potential-to-issue/potential-to-issue-service-call.ts LH/LF=238/238 BRH/BRF=17/20 DA223=2 DA443=none DA444=none DA445=none DA447=none
src/lib/potential-to-issue/promotion.ts LH/LF=445/450 BRH/BRF=57/68 DA223=36 DA443=53 DA444=2 DA445=2 DA447=37
```
