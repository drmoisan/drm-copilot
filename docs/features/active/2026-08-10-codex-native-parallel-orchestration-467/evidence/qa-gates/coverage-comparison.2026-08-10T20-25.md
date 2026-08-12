# Final Coverage Comparison

Timestamp: `2026-08-11` (result-only recovery `S5_atomic_execution_recovery_103`)

Command: `read-only deterministic aggregation of the canonical P0-T21 baseline reports and the refreshed P6-T5, P6-T9, P6-T12, and P6-T15 final reports`

EXIT_CODE: `0`

Output Summary: P6-T19 passed. The comparison used the refreshed TypeScript LCOV and Bash Cobertura artifacts plus the unchanged Python coverage JSON and PowerShell JaCoCo artifacts. No suite was rerun during this result-only recovery.

## Canonical artifacts

| Language | Baseline artifact | Final artifact | Final SHA-256 |
| --- | --- | --- | --- |
| TypeScript | `evidence/baseline/typescript-coverage.2026-08-10T20-25/lcov.info` | `evidence/qa-gates/typescript-coverage.2026-08-10T20-25/lcov.info` | `BDD8387FC460B474F71E66C4B1AAF73C9D5BAE311BAEBD73403DD77C8899D4F9` |
| Python | `evidence/baseline/python-coverage.2026-08-10T20-25.json` | `evidence/qa-gates/python-coverage.2026-08-10T20-25.json` | `DDF0234DFD541DD889F38A27CF6214C1113DA6E10AC41ECBC50F6F40650B603E` |
| PowerShell | `evidence/baseline/powershell-pester-coverage.2026-08-10T20-25.md` | `artifacts/pester/powershell-coverage.xml` as recorded by `evidence/qa-gates/powershell-pester-coverage.2026-08-10T20-25.md` | `29795FE57630315E31D0AFA334009EA4C825D87F385EE779A29D8BCC4DE4A21E` |
| Bash | `evidence/baseline/bash-bats-coverage.2026-08-10T20-25.md` | `evidence/qa-gates/bash-kcov.2026-08-10T20-25/kcov-merged/cobertura.xml` | `DCD87B7BC6CD9CB30B09FB62229536969C6E7A7D72EB80FBEB105F6C9E8F4167` |

## Baseline, final, and delta

| Language | Metric | Baseline | Final | Delta | Gate |
| --- | --- | ---: | ---: | ---: | --- |
| TypeScript | Lines | `40,958 / 42,412` (`96.57%`) | `44,075 / 45,739` (`96.36%`) | `-0.21 pp` | `PASS >=85%` |
| TypeScript | Branches | `5,822 / 6,476` (`89.90%`) | `6,552 / 7,316` (`89.55%`) | `-0.35 pp` | `PASS >=75%` |
| TypeScript | Functions | `1,191 / 1,321` (`90.15%`) | `1,304 / 1,434` (`90.93%`) | `+0.78 pp` | `PASS >=90%` |
| Python | Lines | `13,288 / 14,396` (`92.30%`) | `14,289 / 15,505` (`92.16%`) | `-0.14 pp` | `PASS >=85%` |
| Python | Branches | `4,475 / 5,286` (`84.66%`) | `4,865 / 5,776` (`84.23%`) | `-0.43 pp` | `PASS >=75%` |
| PowerShell | Lines | `4,019 / 4,237` (`94.85%`) | `4,040 / 4,260` (`94.84%`) | `-0.01 pp` | `PASS >=85%` |
| PowerShell | Methods | `335 / 362` (`92.54%`) | `336 / 363` (`92.56%`) | `+0.02 pp` | `PASS >=90%` |
| PowerShell | Classes | `50 / 52` (`96.15%`) | `50 / 52` (`96.15%`) | `0.00 pp` | `PASS >=90%` |
| Bash | Lines | `92.30%` | `1,364 / 1,461` (`93.36%`) | `+1.06 pp` | `PASS >=85%` |

The directly comparable TypeScript, Python, and PowerShell line aggregate is `58,265 / 61,045` (`95.45%`) at baseline and `62,404 / 65,504` (`95.27%`) final. Including the newly countable Bash final report yields `63,768 / 66,965` (`95.22%`) final. The measurable TypeScript and Python branch aggregate is `10,297 / 11,762` (`87.54%`) at baseline and `11,417 / 13,092` (`87.20%`) final. Every measurable aggregate remains above its required line or branch floor.

## Unsupported metric treatment

- The configured PowerShell JaCoCo report does not emit branch counters. PowerShell branch coverage is `UNSUPPORTED_BY_REPORT`, is excluded from the branch denominator, and is not recorded as a pass.
- The configured Bash kcov Cobertura report does not emit a stable repository branch, function, method, or class metric. Those values are `UNSUPPORTED_BY_REPORT`, are excluded from the corresponding denominators, and are not recorded as passes.
- TypeScript and Python line and branch values are present and enforced. PowerShell line/method/class values and Bash line values are present and enforced. No required available value is treated as missing or silently passed.
- External-process PowerShell entrypoints that do not produce parent-process JaCoCo source nodes remain explicitly classified as externally exercised rather than assigned fabricated numeric owner values. The instrumented changed PowerShell scope is reported separately below.

## New and changed production coverage

| Language | Covered / total | Percent | Result |
| --- | ---: | ---: | --- |
| TypeScript, current complete issue-owned source-diff recomputation | `3,178 / 3,392` | `93.69%` | `PASS >=90%` |
| TypeScript, like-for-like P6-T5 scope after the test-only remediation | `2,797 / 2,961` | `94.46%` | `PASS`; `71` additional covered lines and no production write |
| Python | `1,021 / 1,129` | `90.43%` | `PASS >=90%`; unchanged from P6-T9 |
| PowerShell, instrumented changed/new root hook and script lines | `25 / 27` | `92.59%` | `PASS >=90%`; unchanged from P6-T12 |
| Bash, nine approved portable owners | `743 / 780` | `95.26%` | `PASS >=90%`; `16` additional covered lines and no production write |

Only tests changed during P6-T19. TypeScript and Bash covered-line counts increased, while the Python and PowerShell artifacts remained unchanged. Therefore the accepted changed/new scopes have no coverage regression.

## Exact seven remediated owners

| Production owner | Lines | Branches where supported | Result |
| --- | ---: | ---: | --- |
| `extensions/drm-copilot/src/lib/validate/parallel-codex-readiness-filesystem.ts` | `274 / 302` (`90.73%`) | `59 / 75` (`78.67%`) | `PASS` |
| `extensions/drm-copilot/src/lib/validate/parallel-codex-readiness.ts` | `454 / 477` (`95.18%`) | `84 / 96` (`87.50%`) | `PASS` |
| `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-completion-receipts.ts` | `234 / 258` (`90.70%`) | `42 / 50` (`84.00%`) | `PASS` |
| `.claude/lib/bash/compute-concurrency-batches.sh` | `40 / 44` (`90.91%`) | `UNSUPPORTED_BY_REPORT` | `PASS` on available line metric |
| `.claude/lib/bash/parallel-yaml-emit.sh` | `138 / 153` (`90.20%`) | `UNSUPPORTED_BY_REPORT` | `PASS` on available line metric |
| `.claude/lib/bash/parallel-yaml-scan.sh` | `109 / 117` (`93.16%`) | `UNSUPPORTED_BY_REPORT` | `PASS` on available line metric |
| `.claude/lib/bash/validate-parallel-manifest.sh` | `43 / 46` (`93.48%`) | `UNSUPPORTED_BY_REPORT` | `PASS` on available line metric |

The three TypeScript owners report `29 / 29` covered functions. The other issue #467 owners retained the applicable green owner results established by P6-T5, P6-T9, P6-T12, and P6-T15; the seven rows above were the complete previously sub-threshold remediation set.

## Refreshed loop results

- TypeScript: format exit `0` with `0` writes; ESLint exit `0`; TSC exit `0`; coverage exit `0`; `193 / 193` suites and `2,674 / 2,674` tests passed.
- Bash: format exit `0` with `0` writes; check exit `0` with `0` findings; focused owners `79 / 79` passed; full coverage `255 / 255` passed with `0` failed and `0` skipped.
- Python artifact: `3,926` passed, `0` failed, `5` skipped; unchanged from P6-T9.
- PowerShell artifact: `2,285` passed, `0` failed, `9` skipped/disabled; unchanged from P6-T12.

## Size, immutability, and diff gates

The six P6-T19 test owners remain within the `500`-line limit:

| Test owner | Lines |
| --- | ---: |
| `extensions/drm-copilot/test/lib/validate/parallel-codex-readiness-filesystem.test.ts` | `357` |
| `extensions/drm-copilot/test/lib/validate/parallel-codex-readiness.test.ts` | `399` |
| `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-completion-receipts.test.ts` | `220` |
| `tests/shell/parallel_cohorts.bats` | `232` |
| `tests/shell/parallel_yaml_subset.bats` | `205` |
| `tests/shell/parallel_manifest_validate.bats` | `172` |

- P6-T19 production-file writes: `0`.
- Issue-owned code files above `500` lines: `0`; maximum remains `500` lines.
- `.claude` baseline/current files: `150 / 150`.
- `.claude` baseline/current manifest SHA-256: `34FE91AA14F9622BF4B9BF10E87BE787B95E992FFD69DFE09728937A779AA07C`.
- `.claude` missing, added, mismatched, or status paths: `0 / 0 / 0 / 0`.
- `.codex/state`: absent.
- `git diff --check`: exit `0`, no output.

## Result

`P6_T19_STATUS: COMPLETE`
