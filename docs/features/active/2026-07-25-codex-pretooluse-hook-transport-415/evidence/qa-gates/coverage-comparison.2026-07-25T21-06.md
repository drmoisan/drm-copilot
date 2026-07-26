# Coverage Comparison — Baseline versus Post-Change (Issue #415)

Timestamp: 2026-07-25T21-06

Sources:

- Baseline: `FEATURE/evidence/baseline/phase0-poshqc-test.2026-07-25T19-16.md` (`mcp__drm-copilot__run_poshqc_test`, full workspace, at commit `25d0b39c` on `00980851`)
- Post-change: `FEATURE/evidence/qa-gates/final-poshqc-test.2026-07-25T21-02.md` (same command, same workspace root)

Both figures come from the JaCoCo `<counter type="LINE">` totals in `artifacts/pester/powershell-coverage.xml`. No value below is a placeholder.

## Numeric comparison

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Lines covered | 2150 | 2151 | +1 |
| Lines missed | 233 | 235 | +2 |
| Total measured lines | 2383 | 2386 | +3 |
| **Line coverage** | **90.22%** | **90.15%** | **−0.07 pp** |
| Instructions covered / missed | 2928 / 337 | 2930 / 338 | +2 / +1 |
| Methods covered / missed | 167 / 28 | 167 / 28 | 0 / 0 |
| Classes covered / missed | 29 / 2 | 29 / 2 | 0 / 0 |
| Tests | 1356 | 1391 | +35 |
| Failures | 0 | 0 | 0 |

## Threshold verdict

**Post-change line coverage 90.15% >= 85% required. PASS.** Headroom is 5.15 percentage points.

**Branch coverage: not separately measurable in this toolchain — documented limitation (`spec.md:248`).** Pester 5's JaCoCo output through PoshQC emits per-line `mb`/`cb` attributes that are uniformly `0` and no aggregate `BRANCH` counter, so no branch percentage exists to compare. No branch threshold was waived; the metric is unavailable rather than failing. This limitation predates issue #415 and is unchanged by it.

## Changed-module coverage

### What is measured, and why the total moved

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` scopes `CodeCoverage.Path` to an explicit allow-list. Only **two** `.codex/hooks` files are in it:

| File | Baseline missed / covered | Post-change missed / covered | Post-change line % |
|---|---|---|---|
| `enforce-completion-consistency.ps1` | (package total 77 / 99 across both files) | 69 / 67 | 49.26 |
| `enforce-completion-helpers.ps1` | — | 10 / 33 | 76.74 |
| `.codex/hooks` package total | 77 / 99 | 79 / 100 | 55.87 |

The entire −0.07 pp movement is attributable to this one package. `enforce-completion-consistency.ps1` is simultaneously (a) one of the eight rewired hooks and (b) one of only two `.codex/hooks` files in the measured set. Its rewire replaced a two-line entrypoint call with an eight-line block (shared-parser call, governed-path mapping, comments), which added measurable lines. Those added lines sit **after** the `if ($MyInvocation.InvocationName -eq '.') { return }` dot-source guard, so in-process Pester coverage can never reach them; they execute only in spawned hook processes, whose coverage Pester does not attribute back to the file.

Every other package is byte-identical to baseline:

| Package | Baseline missed / covered | Post-change missed / covered |
|---|---|---|
| `.claude/hooks` | 91 / 1148 | 91 / 1148 |
| `.claude/lib/model-routing` | 0 / 43 | 0 / 43 |
| `.claude/lib/orchestrator-state` | 3 / 147 | 3 / 147 |
| `scripts/dev-tools` | 53 / 358 | 53 / 358 |
| `scripts/powershell` | 7 / 109 | 7 / 109 |
| `scripts/powershell/PoshQC` | 2 / 246 | 2 / 246 |

### No regression on changed lines

The requirement is that changed lines must not lose coverage relative to their prior state. Assessed per changed file:

1. **Seven of the eight rewired hooks are outside the measured set entirely** (`check-python-test-purity`, `check-powershell-test-purity`, `enforce-python-batch-budget`, `enforce-powershell-batch-budget`, `enforce-evidence-locations`, `enforce-orchestration-preimplementation-gate`, `enforce-checkpoint-monotonic`). Their lines contributed 0 to both the baseline and the post-change denominator, so no line of theirs can have regressed in the metric.

2. **`enforce-completion-consistency.ps1` is measured.** Its changed lines are: one comment line above an existing dot-source, six lines adding the shared-module dot-source with its explanatory comment, and the eight-line entrypoint block. None of these lines was covered at baseline either — the baseline entrypoint lines were equally unreachable behind the same dot-source guard. **No previously-covered line became uncovered.** The delta is entirely new uncovered lines, not lost coverage.

3. **The new shared module `codex-pretooluse-file-mapping.ps1` is not in the measured set**, so its 474 lines are in neither denominator. Coverage did not change on its account.

Verdict: **no regression on changed lines.** The −0.07 pp movement is denominator growth from three newly-added unreachable entrypoint lines in one measured file, not a loss of coverage on any previously-covered line.

### Behavioural coverage of the changed modules

Although the shared module and seven rewired entrypoints are outside the line-coverage instrument, they are exercised heavily by the new cases, and that exercise is the substantive verification:

- `codex-pretooluse-transport.Tests.ps1` (27 tests) drives roughly 75 real hook-process spawns across all eight rewired hooks.
- `codex-pretooluse-integration.Tests.ps1` (6 tests) drives 59 more spawns derived from `.codex/config.toml`, covering every registered handler against every tool name its own matcher admits, plus 34 malformed-input spawns.
- The shared module's public functions are additionally exercised in-process by the mapping-unit assertions in `legacy-codex-hook-contracts.Tests.ps1` updated by `[P5-T4]` and `[P6-T4]`, and by the preimplementation-gate deny cases in the transport suite.
- Pass-after evidence: all 32 fail-before rows now exit 0, and all 59 integration invocations exit 0 (`FEATURE/evidence/regression-testing/pass-after.2026-07-25T20-46.md`).

### Recorded observation — coverage allow-list not modified

`.claude/rules/general-unit-test.md` states that no production file may be excluded from coverage measurement. The `CodeCoverage.Path` allow-list in `pester.runsettings.psd1` leaves most `.codex/hooks` and `.claude/hooks` files outside measurement. This is a **pre-existing repository-wide configuration choice that predates issue #415**; the file is not named in this plan's files-to-change list and no plan task authorizes editing it, so it was deliberately left unmodified rather than expanded as an unplanned side change.

Adding `codex-pretooluse-file-mapping.ps1` and the seven other rewired hooks to the measured set would be a legitimate follow-up, but it would also materially move the repository-wide coverage number for reasons unrelated to this bug fix, and it is outside this plan's scope. Flagging it here rather than acting on it.

## Outcome

**PASS.** Post-change line coverage is 90.15%, above the 85% threshold; numeric baseline and post-change values are both recorded; no changed line lost coverage; branch coverage is unavailable by documented toolchain limitation rather than by omission.
