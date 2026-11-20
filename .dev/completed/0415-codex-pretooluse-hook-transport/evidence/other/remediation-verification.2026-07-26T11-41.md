# Remediation Closeout (Cycle 1)

- **Issue:** #415
- **Task:** [P6-T10]
- **Plan of record:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-25T21-03.md` (Version 1.3)
- **Remediation inputs:** `remediation-inputs.2026-07-25T21-03.md`

Timestamp: 2026-07-26T11-41

## Finding R1 — changed PowerShell production surface absent from `CodeCoverage.Path`

**Verdict: PASS**

| Deliverable | Artifact | Result |
|---|---|---|
| [P1-T1] diff summary (both runsettings copies) | see below | PASS |
| Final per-file verification | `evidence/qa-gates/per-file-coverage-final.2026-07-26T11-41.md` | PASS |
| Final test + coverage gate | `evidence/qa-gates/remediation-final-poshqc-test.2026-07-26T11-41.md` | PASS |
| Refreshed coverage comparison | `evidence/qa-gates/coverage-comparison.2026-07-26T11-41.md` | PASS |

### [P1-T1] diff summary

Both copies received the identical 13-line addition — a five-line comment attributing the change to issue #415 remediation cycle 1 (R1), followed by the 8 C5 paths appended to `CodeCoverage.Path`:

```
scripts/powershell/PoshQC/settings/pester.runsettings.psd1               | 13 +++++++++++++
extensions/drm-copilot/resources/powershell/PoshQC/settings/…psd1        | 13 +++++++++++++
2 files changed, 26 insertions(+)
```

- Only added lines; no line removed or altered; every pre-existing entry retained.
- `CoveragePercentTarget` unchanged at `0`; no other key touched.
- Byte parity re-verified after the final gate: `git diff --no-index scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` exits **0** — the condition `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` asserts, and that suite is green.

### R1 measured outcome

The changed production surface is now inside the coverage denominator and above threshold. All 8 C5 paths appear under the `.codex/hooks` package in `artifacts/pester/powershell-coverage.xml` (the package held 2 sourcefiles at baseline and holds 10 now). All 9 files in the C7 verdict set meet the 85% per-file threshold on the RAW number:

| File | Baseline ([P1-T3]) | Final | Verdict |
|---|---:|---:|---|
| `codex-pretooluse-file-mapping.ps1` | 78.22% | **100.00%** | PASS |
| `check-python-test-purity.ps1` | 0.00% | **100.00%** | PASS |
| `check-powershell-test-purity.ps1` | 0.00% | **100.00%** | PASS |
| `enforce-python-batch-budget.ps1` | 29.89% | **96.55%** | PASS |
| `enforce-powershell-batch-budget.ps1` | 29.89% | **96.55%** | PASS |
| `enforce-evidence-locations.ps1` | 0.00% | **100.00%** | PASS |
| `enforce-checkpoint-monotonic.ps1` | 4.81% | **99.04%** | PASS |
| `enforce-orchestration-preimplementation-gate.ps1` | 38.78% | **100.00%** | PASS |
| `enforce-completion-consistency.ps1` | 49.26% | **100.00%** | PASS |
| **C7 set total** | **30.78%** | **99.11%** | PASS |

Repo-wide PowerShell line coverage: **2869 / 3042 = 94.31% >= 85% — PASS** (baseline anchor [P0-T5] was 2160 / 2395 = 90.19% over a smaller, incomplete measured set).

No RI-1 residual computation was required for any file: every raw number clears the threshold without adjustment.

## Finding R2 — no Python per-language coverage evidence

**Verdict: PASS**

| Deliverable | Artifact | Result |
|---|---|---|
| Python full-suite coverage evidence | `evidence/qa-gates/python-coverage.2026-07-26T11-41.md` | PASS |
| Baseline counterpart | `evidence/remediation-baseline/phase0-pytest-cov.2026-07-26T11-41.md` | PASS |

- Line coverage **91.00%** (11175 / 12280, derived as `(Stmts − Miss) / Stmts`; confirmed by summed `LH`/`LF`) — **>= 85% PASS**.
- Branch coverage **81.84%** (3642 / 4450, summed `BRH`/`BRF`) — **>= 75% PASS**.
- `artifacts/python/lcov.info` present (344174 bytes) — the artifact whose absence the finding flagged.
- 2123 passed, 0 failed. Numbers identical to the [P0-T9] baseline, as expected: no production Python changed on the branch and no `.py` file changed in this cycle.

## Non-blocking items

| Item | Task | Artifact | Result |
|---|---|---|---|
| `.codex/state/` gitignore entry (Info) | [P5-T1] | `.gitignore` diff, one added line | **PASS** — `git check-ignore .codex/state/probe` exits 0; `git diff .gitignore` shows exactly one added line |
| Shared-parser `hook_event_name` hardening (Minor) | [P5-T2] | `evidence/other/remediation-followups.2026-07-26T11-41.md` | **RECORDED as deferred follow-up** with rationale and binding constraints |

The follow-up dossier additionally records two items discovered during execution: an unreachable operator-precedence branch at `enforce-checkpoint-monotonic.ps1:260-261` (benign today, out of scope under Hard Constraints 3 and 4), and the bundled-MCP PoshQC release lag documented at [P1-T2].

## Final toolchain state

| Gate | Command | Exit | Result |
|---|---|---:|---|
| PowerShell format | `mcp__drm-copilot__run_poshqc_format` | 0 | 0 files changed |
| PowerShell analyze | `mcp__drm-copilot__run_poshqc_analyze` | 0 | 0 errors, 0 warnings, 0 information |
| PowerShell test | `mcp__drm-copilot__run_poshqc_test` | 0 | 1668 tests, 0 failures, 0 errors |
| PowerShell coverage (CI-equivalent) | `Invoke-PoshQCTest -Root <repo>` | 0 | 1659 passed, 0 failed; 94.31% line |
| Python format | `poetry run black --check tests/scripts/dev_tools` | 0 | 183 files unchanged |
| Python lint | `poetry run ruff check tests/scripts/dev_tools` | 0 | All checks passed |
| Python type-check | `poetry run pyright` | 0 | 0 errors |
| Python test + coverage | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 0 | 2123 passed; 91.00% line / 81.84% branch |

All PowerShell gates passed in one uninterrupted pass ([P6-T1]..[P6-T3]); all Python gates passed in one uninterrupted pass ([P6-T4]..[P6-T7]).

## Scope and hygiene

`evidence/other/remediation-scope-verification.2026-07-26T11-41.md` — all four assertions hold: no `.claude/` path in the delta; the delta contains only the two runsettings copies, `.gitignore`, seven `tests/scripts/codex-hooks/` test files, and feature-folder evidence; nothing under `.codex/` changed; no `.codex/state/*` file is staged, committed, or present on disk.

## Cycle-1 exit-gate status

- **R1: evidenced and PASS.**
- **R2: evidenced and PASS.**
- **PoshQC loop: green** — format, analyze, and test all exit 0 in a single uninterrupted pass with all suites passing, including the root/bundle parity suites.
- Both findings are resolved with named artifacts and numeric evidence. No verdict in this closeout is non-PASS, so the plan outcome is **complete**, not remediation-required.
- The `blocking_count == 0` re-audit is performed by `feature-review`, outside this plan.

## Constraint compliance summary

- No file under `.claude/` created, modified, or deleted; no agent memory written.
- No batch budget reset, no runtime state file deleted or created, no cap overridden.
- No Codex hook registration disabled, removed, bypassed, or weakened; `.codex/config.toml` unchanged with its three `PreToolUse` matcher groups intact.
- No handler allow/deny policy function changed.
- Root `.codex/` and the bundled Codex copy remain byte-identical; the two `pester.runsettings.psd1` copies are byte-identical.
- No production file removed from `CodeCoverage.Path`; no threshold lowered; no denominator shrunk; no assertion weakened; no analyzer suppression added.
- No temporary files in tests: process-level cases use `ProcessStartInfo` with `RedirectStandardInput`; in-process entrypoint cases use `[System.Console]::SetIn([System.IO.StringReader]::new(...))` with readers restored in `finally`.
- No production, test, or reusable script file exceeds 500 lines (largest: 489).
- The `spec.md` acceptance-criteria text was not edited and no criterion was unchecked.
- No git hook or quality gate was bypassed; the two analyzer failures encountered were fixed at the root cause with a full loop restart each time.
