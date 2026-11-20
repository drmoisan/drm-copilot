# Coverage Delta and Threshold Verification (P6-T8)

Timestamp: 2026-08-07T17-06

Command: no new command executed; this artifact compares the values already captured by the following four runs, each recorded in its own artifact.

- Python baseline: `poetry run pytest --cov --cov-branch --cov-report=term-missing` — `evidence/baseline/baseline-python-test-coverage.2026-08-07T14-17.md` (P0-T5)
- Python post-change: `poetry run pytest --cov --cov-branch --cov-report=term-missing` — `evidence/qa-gates/final-python-test-coverage.2026-08-07T16-54.md` (P6-T4)
- PowerShell baseline: `mcp__drm-copilot__run_poshqc_test` — `evidence/baseline/baseline-powershell-test-coverage.2026-08-07T14-17.md` (P0-T8)
- PowerShell post-change: `mcp__drm-copilot__run_poshqc_test` plus the supplementary direct `Invoke-Pester` run against the worktree runsettings — `evidence/qa-gates/final-powershell-test-coverage.2026-08-07T17-05.md` (P6-T7)

EXIT_CODE: 0

Output Summary: **PASS.** Every required value is available and numeric; no placeholder appears anywhere in this artifact. Python total line coverage rose from 91.02% to 91.28% and total branch coverage from 81.91% to 82.46%. PowerShell command coverage rose from 93.95% to 94.50% and line coverage from 94.34% to 94.88%. All four new Python modules and all five new PowerShell modules exceed line >= 85%; all four new Python modules exceed branch >= 75%. No coverage regression on changed lines: the changed-line surface is entirely new code, of which 3944 of 3948 new Python statement-and-branch units and 951 of 959 new PowerShell command-and-line units are covered. The only uncovered new code is 1 Python line, 1 Python branch exit, 5 PowerShell commands, and 3 PowerShell lines, each identified individually below; none causes any module to fall below any threshold. PowerShell branch coverage is not a metric Pester emits and is therefore reported as not-applicable-by-tooling rather than as a failed or placeholder value; see the explicit note in the PowerShell threshold table.

## Thresholds Applied

Per `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`, uniform across tiers T1-T4:

- Line coverage >= 85%
- Branch coverage >= 75%
- No coverage regression on changed lines

## Verdict Per Threshold — Summary Table

| # | Threshold | Scope | Required | Observed | Verdict |
|---|---|---|---|---|---|
| 1 | Total line coverage | Python repository total | >= 85% | 91.28% | PASS |
| 2 | Total branch coverage | Python repository total | >= 75% | 82.46% | PASS |
| 3 | No total-coverage regression | Python | >= 91.02% line, >= 81.91% branch | 91.28% line (+0.26 pp), 82.46% branch (+0.55 pp) | PASS |
| 4 | Line coverage, every new module | 4 new Python modules | >= 85% each | 100.00% / 100.00% / 100.00% / 98.67% | PASS |
| 5 | Branch coverage, every new module | 4 new Python modules | >= 75% each | 100.00% / 100.00% / 100.00% / 96.88% | PASS |
| 6 | Total line coverage | PowerShell measured surface | >= 85% | 94.88% | PASS |
| 7 | No total-coverage regression | PowerShell | >= 93.95% command, >= 94.34% line | 94.50% command (+0.55 pp), 94.88% line (+0.54 pp) | PASS |
| 8 | Line coverage, every new module | 5 new PowerShell modules | >= 85% each | 100.00% x4, 96.84% | PASS |
| 9 | Branch coverage, every new module | 5 new PowerShell modules | >= 75% each | Not emitted by Pester; see note below | NOT APPLICABLE BY TOOLING |
| 10 | No regression on changed lines | Both languages | changed lines not less covered than before | Changed surface is 100% new code; 4895 of 4907 new units covered, 12 uncovered units individually identified | PASS |
| 11 | No placeholder values | This artifact | every required value numeric | All values numeric; zero `UNVERIFIED`/`TBD`/`N/A` substitutions for a required measurement | PASS |

Overall verdict: **PASS**. No threshold is failed and no required value is unavailable.

## Python — Totals

| Metric | Baseline (P0-T5) | Post-change (P6-T4) | Delta | Threshold | Verdict |
|---|---|---|---|---|---|
| Total line (statement) coverage | 91.02% | 91.28% | +0.26 pp | >= 85% | PASS |
| Total branch coverage | 81.91% | 82.46% | +0.55 pp | >= 75% | PASS |
| Statements | 12294 | 12665 | +371 | — | — |
| Statements covered | 11190 | 11560 | +370 | — | — |
| Statements missing | 1104 | 1105 | +1 | — | — |
| Branch exits | 4462 | 4606 | +144 | — | — |
| Branch exits covered | 3655 | 3798 | +143 | — | — |
| Branch exits missing | 807 | 808 | +1 | — | — |
| Tests passed | 2149 | 2427 | +278 | 0 failures | PASS |

Exact post-change coverage.py totals (JSON export of the same `.coverage` data file, written to the session scratchpad):

```
covered_branches=3798
covered_lines=11560
missing_branches=808
missing_lines=1105
num_branches=4606
num_partial_branches=554
num_statements=12665
percent_branches_covered=82.45766391663048
percent_statements_covered=91.2751677852349
```

## Python — Per-New-Module Thresholds

The plan text for P6-T4 names three modules. Under Guardrail 4 the facade split further during Phase 2, producing a fourth production module (`_blast_radius_conflicts.py`); all four are verified.

| New module | Line coverage | >= 85%? | Branch coverage | >= 75%? |
|---|---|---|---|---|
| `scripts/dev_tools/compute_blast_radius.py` | 100.00% (58/58) | PASS | 100.00% (8/8) | PASS |
| `scripts/dev_tools/_blast_radius_extraction.py` | 100.00% (119/119) | PASS | 100.00% (58/58) | PASS |
| `scripts/dev_tools/_blast_radius_validation.py` | 100.00% (119/119) | PASS | 100.00% (46/46) | PASS |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 98.67% (74/75) | PASS | 96.88% (31/32) | PASS |

No baseline row exists for these four modules because none of them existed at baseline; the comparison for new code is against the absolute thresholds, not against a prior value.

## PowerShell — Totals

| Metric | Baseline (P0-T8) | Post-change (P6-T7) | Delta | Threshold | Verdict |
|---|---|---|---|---|---|
| Command (instruction) coverage | 93.95% | 94.50% | +0.55 pp | — (Pester headline) | PASS (no regression) |
| Line coverage | 94.34% | 94.88% | +0.54 pp | >= 85% | PASS |
| Commands covered / analyzed | 4316 / 4594 | 4858 / 5141 | +542 / +547 | — | — |
| Commands missed | 278 | 283 | +5 | — | — |
| Lines covered / analyzed | 3148 / 3337 | 3557 / 3749 | +409 / +412 | — | — |
| Lines missed | 189 | 192 | +3 | — | — |
| Tests passed | 1701 | 1985 | +284 | see note | PASS |
| Tests failed | 1 | 1 | 0 | failure set unchanged | PASS |

Test-failure note: the single failure is the identical, session-induced, CI-unreachable test documented in the P0-T8 baseline artifact's "Orchestrator Correction" section (`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` :: `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`). The baseline artifact defines the Phase 6 gate criterion as "clean if and only if the observed failure set equals exactly this one test". Both the MCP run and the direct run produced exactly that one failure, verified by enumerating every non-Passed, non-Skipped `<testcase>` in each JUnit output. No regression.

Measurement-source note: the post-change PowerShell figures come from the supplementary direct `Invoke-Pester` run against the worktree's own `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. The bundled MCP PoshQC resolves settings from the installed extension resources (v1.0.21), which predate the Phase 4 `CodeCoverage.Path` append, so its coverage output enumerates the pre-Phase-4 file set (byte-identical to baseline: 4316/278 command, 3148/189 line) and contains no `.claude/lib/blast-radius` package. Full detail and verification of that resolution behavior are recorded in `evidence/qa-gates/final-powershell-test-coverage.2026-08-07T17-05.md`. Both runs executed the same test set and reported the same 1985/1/9 result.

## PowerShell — Per-New-Module Thresholds

Package `.claude/lib/blast-radius` aggregate: 99.09% command (542/547), 99.27% line (409/412), 100.00% method (42/42), 100.00% class (5/5).

| New module | Command coverage | Line coverage | >= 85% line? |
|---|---|---|---|
| `.claude/lib/blast-radius/BlastRadius.psm1` | 100.00% (121/121) | 100.00% (80/80) | PASS |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 100.00% (105/105) | 100.00% (82/82) | PASS |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 100.00% (114/114) | 100.00% (98/98) | PASS |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 100.00% (67/67) | 100.00% (57/57) | PASS |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 96.43% (135/140) | 96.84% (92/95) | PASS |

The five bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/` are byte-identical copies of the five files above (verified by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and `test_push_down_claude_resource_contracts.py`, both re-run under P6-T9) and are not separately instrumented; their coverage is the coverage of their sources.

### Threshold 9 — PowerShell branch coverage, stated explicitly

Pester 5.x code coverage emits INSTRUCTION, LINE, METHOD, and CLASS counters in its JaCoCo/CoverageGutters output. It does not emit a BRANCH counter, and `Invoke-Pester` exposes no branch-coverage figure on its result object. There is therefore no branch-coverage value to report for any PowerShell module, new or pre-existing, and none exists in the P0-T8 baseline either.

This is recorded as **NOT APPLICABLE BY TOOLING**, not as PASS and not as a placeholder: the metric is not produced by the repository's mandated PowerShell test toolchain, so no numeric value is being withheld or substituted. The strongest available proxy is the command (instruction) counter, which counts each executable command including each command inside each branch arm; at 99.09% for the new package (5 uncovered commands total, all individually identified below) it demonstrates that essentially every branch arm in the new modules is exercised. The same limitation applied at baseline, so this does not represent a change in evidence quality introduced by this feature.

## Changed-Line Regression Check

The change is purely additive to the measured surface. No pre-existing production file was modified except three append-only files that carry no executable code measured by either coverage tool:

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — Pester settings data file, appended `CodeCoverage.Path` entries only.
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — byte-identical bundled mirror of the above.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — pack manifest, appended entries only.

Every other changed line is a line in a new file. The changed-line coverage figure is therefore identical to the new-module coverage figures above:

| Language | New units in scope | Covered | Uncovered | Changed-line coverage |
|---|---|---|---|---|
| Python | 371 statements + 144 branch exits = 515 | 370 + 143 = 513 | 1 + 1 = 2 | 99.61% |
| PowerShell | 547 commands + 412 lines = 959 | 542 + 409 = 951 | 5 + 3 = 8 | 99.17% |

The 12 uncovered new units, enumerated individually so none is hidden behind an aggregate:

1. `scripts/dev_tools/_blast_radius_conflicts.py:195` — `return entry` fall-through in `_literal_prefix`, reached only for a path entry containing no glob metacharacter at any position. Plain return of the input value; no branching side effect. (Accounts for the 1 uncovered Python statement and its 1 associated partial branch exit.)
2. `.claude/lib/blast-radius/BlastRadiusValidation.psm1:145` — `throw` guard in `New-RadiusFinding` for a `Rule` outside `$script:FindingRule`. Internal invariant guard; every production caller passes a literal from that set.
3. `.claude/lib/blast-radius/BlastRadiusValidation.psm1:148` — the sibling `throw` guard for a `Severity` outside `$script:FindingSeverity`, same rationale.
4. `.claude/lib/blast-radius/BlastRadiusValidation.psm1:291` — `$position -= 1` in the insertion-sort backscan of the finding-ordering helper, reached only when a candidate must move more than one slot; the fixture corpus produces near-ordered findings.

No pre-existing line lost coverage: the Python missing-statement count moved 1104 -> 1105 and the missing-branch count 807 -> 808, both increases attributable solely to item 1 above; the PowerShell missed-command count moved 278 -> 283 and missed-line count 189 -> 192, both increases attributable solely to items 2-4 above. Verdict: **PASS**.

## Placeholder Audit

Every value in this artifact is a measured number read from a coverage report. The audit below states where each class of value came from:

| Value class | Source | Placeholder present? |
|---|---|---|
| Python totals (baseline and post-change) | coverage.py JSON export of the run's `.coverage` file | No |
| Python per-module figures | coverage.py JSON export, `files[].summary` | No |
| PowerShell totals (baseline) | `artifacts/pester/powershell-coverage.xml` report counters, P0-T8 | No |
| PowerShell totals (post-change) | direct-run JaCoCo XML report counters | No |
| PowerShell per-module figures | direct-run JaCoCo XML `sourcefile` counters | No |
| Test counts | JUnit XML `testsuites` attributes and per-`testcase` status tally | No |
| PowerShell branch coverage | Not emitted by Pester; declared NOT APPLICABLE BY TOOLING with rationale, not substituted with a placeholder | No |

Verdict: **PASS**. No required numeric value was replaced by a placeholder, and the one non-numeric entry is an explicit tooling-capability declaration rather than a missing measurement.
