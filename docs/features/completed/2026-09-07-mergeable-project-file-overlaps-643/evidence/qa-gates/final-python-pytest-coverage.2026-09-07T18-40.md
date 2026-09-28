# Final QA — Python tests with coverage (loop iteration 2)

Timestamp: 2026-09-07T18-40

Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`

EXIT_CODE: 1

## Output Summary

Verbatim pytest summary line:

```text
1 failed, 4273 passed, 5 skipped in 21.89s
```

Verbatim `TOTAL` row:

```text
TOTAL                                                               15241   1110   5592    567    91%
```

Verbatim rows for the two modules the task names:

```text
scripts\dev_tools\_blast_radius_mergeable.py                           28      1     14      1    95%   122
scripts\dev_tools\_blast_radius_conflicts.py                           62      0     22      0   100%
```

Both named rows show `Cover` at or above 90 (95% and 100%).

### Numeric coverage percentages computed from `artifacts/python/coverage.json` `totals`

Extraction command, identical to [P0-T7]:
`poetry run python -c "import json; t=json.load(open('artifacts/python/coverage.json'))['totals']; print(t['covered_lines'], t['num_statements'], t['covered_branches'], t['num_branches'])"`

Printed integers: `14131 15241 4771 5592`

- Statement coverage: `covered_lines / num_statements * 100` = `14131 / 15241 * 100` = **92.72%**
- Branch coverage: `covered_branches / num_branches * 100` = `4771 / 5592 * 100` = **85.32%**

Statement coverage is at or above 85 and branch coverage is at or above 75, meeting the uniform
thresholds of `.claude/rules/quality-tiers.md`. The `91%` in the terminal `TOTAL` row is the single
combined `Cover` column pytest-cov prints; the two separate percentages above are the values this
plan requires.

### Passed-count check

The [P0-T7] baseline recorded `4244 passed`. The required floor is that count plus 25, that is 4269.
The observed count is 4273, which clears the floor by 4.

### Failing node list — the constraint C4 anchor

Exactly one test failed:

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
E           AssertionError: Repo file missing from bundle: .claude\state\current-session-id
```

`EXIT_CODE: 1` is accepted under the constraint C4 bounded exemption. All three conditions hold
against the [P0-T7] record `evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md`: the
failing node ID set is exactly the set P0-T7 recorded; the run reports exactly that many failures
(one); and the sole assertion message names a path under `.claude/state/`. No other failure is
exempt and none occurred.

## Loop iteration and restart cause

This is iteration 2 of the Python loop. Iteration 1 (recorded in the sibling artifacts stamped
18-25, 18-27, 18-29) passed format, lint, and type-check, and its pytest run reported **two**
failures: the C4-exempt node above and
`tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources`.

The second failure was a genuine regression of this plan and was not exempt. Cause: the plan appends
every new PowerShell production file to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
(constraint C3, because `CodeCoverage.Path` is an explicit per-file allow-list), and that settings
file has a byte-parity mirror at
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` which the plan
does not name. The repo-root edit therefore left the pair out of parity.

Fix applied at source, using the constraint C9 mirror form so no batch-budget slot is consumed:

```text
pwsh -NoProfile -Command "Copy-Item -LiteralPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 -Force"
```

`poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` then reported `1 passed`.
Because a tracked file changed, the Python loop restarted from its first step; iteration 2 re-ran
Black (`463 files left unchanged.`, porcelain listings identical), Ruff (`All checks passed!`), and
Pyright (`0 errors, 0 warnings, 0 informations`) before this run.

## Post-final-change re-verification

The PowerShell loop restarted after this artifact was first written, and its iteration-3 fix changed
tracked source under `.claude/lib/` and `tests/`. To keep the [P8-T13] statement true — that every
recorded pass observed the tree after the last source change — this step was re-run at
2026-09-07T19-30 against the final tree. Observed result: `1 failed, 4273 passed, 5 skipped in 22.82s` with the same single C4-exempt node; JSON totals `14131 15241 4771 5592`, so statement 92.72% and branch 85.32% are unchanged; `_blast_radius_mergeable.py` 95% and `_blast_radius_conflicts.py` 100% unchanged.

The re-run required no source change, so no further restart followed it.
