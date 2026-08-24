# Coverage Delta and Threshold Verification (Issue #479, [P7-T13], AC41 coverage half)

Timestamp: 2026-08-17T03-08

Command: comparison of the Phase 0 baseline artifacts against the Phase 7 final-QC artifacts.

- Baselines: `evidence/baseline/python-test-baseline.2026-08-16T23-55.md` (P0-T6),
  `ts-test-baseline.2026-08-16T23-58.md` (P0-T10), `shell-baseline.2026-08-17T00-05.md`
  (P0-T11), `powershell-test-baseline.2026-08-17T00-08.md` (P0-T12).
- Post-change: `evidence/qa-gates/final-python-test.2026-08-17T02-47.md` (P7-T4),
  `final-ts-test.2026-08-17T02-52.md` (P7-T8), `final-shell-qc.2026-08-17T03-05.md` (P7-T12),
  `final-powershell-test.2026-08-17T02-57.md` (P7-T11).

EXIT_CODE: 0

## Per-language totals

| Language | Metric | Baseline | Post-change | Delta | Threshold | Result |
|---|---|---|---|---|---|---|
| Python | Line | 92.30% (13288/14396) | **92.40%** (13479/14587) | +0.10 | >= 85% | PASS |
| Python | Branch | 84.66% (4475/5286) | **84.88%** (4548/5358) | +0.22 | >= 75% | PASS |
| TypeScript | Line | 96.61% (41738/43200) | **96.61%** (41738/43200) | 0.00 | >= 85% | PASS |
| TypeScript | Branch | 89.96% (5901/6559) | **89.96%** (5901/6559) | 0.00 | >= 75% | PASS |
| bash | Line | 92.3% | **92.6%** | +0.3 | >= 85% | PASS |
| bash | Branch | `N/A — kcov does not measure branch coverage; bash is exempt from the branch threshold only` | same | n/a | n/a | n/a |
| PowerShell | Line | 95.14% (4090/4299) | **95.14%** (4090/4299) | 0.00 | >= 85% | PASS |
| PowerShell | Branch | `N/A — Pester does not measure branch coverage` | same | n/a | n/a | n/a |

No language regressed on either measured metric. Python and bash improved; TypeScript and
PowerShell are unchanged.

## New and changed code

### Python — new module

| Module | Line | Branch | Threshold | Result |
|---|---|---|---|---|
| `scripts/dev_tools/parallel_lane_assertion.py` | **100.00%** (143/143 stmts) | **100.00%** (44/44 branch exits) | line >= 85%, branch >= 75% | PASS |

### Python — changed modules, required to be at or above baseline

| Module | Baseline line | Post line | Post branch | Result |
|---|---|---|---|---|
| `scripts/dev_tools/parallel_mutation_protocol.py` | 100% | **100.00%** | **100.00%** | at baseline |
| `scripts/dev_tools/parallel_manifest_contract.py` | 100% | **100.00%** | **100.00%** | at baseline |

`parallel_manifest_contract.py` transiently fell to 97% when the M8 check landed. That was
caught by the `[P7-T4]` coverage run, three tests covering the M8 resolution-target degradation
path were added, and the Python loop was restarted from formatting. The values above are from
the final clean pass.

Other Python files touched (docstring-only or single-constant changes), for completeness:
`_parallel_mutation_models.py` 100.00%/100.00%, `_parallel_state_common.py` 100.00%/100.00%,
`validate_parallel_planner_state.py` 100.00%/100.00%,
`validate_parallel_orchestrator_state.py` 97.73%/94.12% (identical to baseline; its only change
is the covered module-level `MAX_CONCURRENCY` constant).

### TypeScript — changed files

| File | Line | Branch | Threshold | Result |
|---|---|---|---|---|
| `src/lib/validate/parallel-orchestrator-state-core.ts` | **99.38%** (320/322) | **92.11%** (35/38) | line >= 85%, branch >= 75% | PASS |
| `src/lib/validate/parallel-planner-state-core.ts` | **100.00%** (453/453) | **97.96%** (48/49) | line >= 85%, branch >= 75% | PASS |

Both are byte-identical to their baseline values. No new TypeScript module was created, so no
`jest.config.cjs` per-file threshold changed.

### bash — changed file

`.claude/lib/bash/parallel-manifest-validate.sh` is the only bash file edited
(`parallel-items-validate.sh` was NOT edited, so the plan's conditional does not apply). The
kcov include pattern covers `.claude/lib/bash/`, so the edited file is measured inside the
**92.6%** line headline, which is above the 85% threshold and above the 92.3% baseline.
Branch: `N/A — kcov exemption`.

### PowerShell — new/changed code

`N/A — no PowerShell production or test file changed in this feature; regression gate only`.

This literal `N/A` is the plan's explicitly authorized value for this row and does not trigger
the fail-closed clause. It is corroborated by `[P5-T1]`: `git diff --name-only` against the
merge base contains no `.ps1`, `.psm1`, or `.psd1` file at all.

## Fail-closed check

Every required value above is numeric or an authorized literal `N/A — <reason>`. No placeholder
(`UNVERIFIED`, `TBD`) appears. No threshold is unmet. The outcome is **PASS**, not
remediation-required.
