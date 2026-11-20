# D6 adjustments of existing contract tests, rule 17 RI-4 re-run of P4-T13 (AC-22)

Timestamp: 2026-10-17T00-12
Command: git diff --numstat origin/main -- tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests/scripts/workflows/CiWorkflow.Tests.ps1
EXIT_CODE: 0
Output Summary: After the re-integration of origin/main b8fcd7790 (#952), three adjustments are in place: A1 (always), A2 (A2-APPLICABLE: yes), and A4 with A4C (POSHQC-SHAPE: sharded). A3 is withdrawn by PD-15. Fail-before: p4-py-contract-fail-before.2026-10-16T23-53.md. Pass-after: p4-py-contract-pass-after.2026-10-16T23-53.md (P4-T10; the Python files are unchanged by the merge, and P6-T17 re-observes them) and p4-existing-suites.2026-10-17T00-12.md (P4-T12 re-run). This artifact supersedes workflow-suite-adjustment.2026-10-16T23-55.md.

D6-ADJUSTMENT: tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py | test_threshold_step_runs_on_every_matrix_leg

- Old text: `    assert "if" not in step` (with the docstring lines "condition key, per decision D3 of the spec. Expected outcome: the step" / "mapping carries no ``if`` key.")
- New text: the module constant `RUN_HEAVY_GATE = "${{ inputs.run-heavy }}"` after `CODECOV_ACTION`, and `assert step.get("if") == RUN_HEAVY_GATE, (...)` with the docstring of section 7 A1
- Cause: G1 gives the `Enforce Python coverage thresholds` step `        if: ${{ inputs.run-heavy }}` in `.github/workflows/_quality-checks.yml`.

D6-ADJUSTMENT: tests/scripts/workflows/CiWorkflow.Tests.ps1 | reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph

- Old text (line 232): `            $eventFieldLines = @($graphLines | Where-Object { $_ -match 'github\.event\.pull_request|github\.head_ref|github\.base_ref|github\.event_name' })`
- New text: the fifteen A2 lines of section 7 (comment, `$allowedEventFieldLines` holding the five G7 event-field lines for ci.yml only, `$allowedHits`, and the filtered `$eventFieldLines`), plus the inserted line `            $allowedHits.Count | Should -Be $allowedEventFieldLines.Count -Because "$graphFile must carry each issue #962 change-scope event-field line exactly once"` after the existing `$eventFieldLines.Count` assertion
- Cause: G7 adds to ci.yml the checkout `ref: ${{ github.event.pull_request.head.sha || github.sha }}` line and the `EVENT_NAME`, `HEAD_SHA`, `HEAD_REF`, `HEAD_REPO` env lines of the `changes` job, which the unmodified row reports as pull-request event fields.

D6-ADJUSTMENT: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | $script:GetResultGateViolation (used by rows WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE and WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS)

- Helper comment line, old (line 51): `        # -or, exits 1, carries no step-level if condition, and precedes the completeness and merge steps.`
- Helper comment line, new (line 51): `        # -or, exits 1, carries no step-level if condition other than the issue #962 run-heavy gate, and precedes the completeness and merge steps.`
- Helper condition line, old (line 85): `            if ($gate -match '(?m)^ {8}if:') {`
- Helper condition line, new (line 85): `            if ($gate -match '(?m)^ {8}if:' -and $gate -notmatch '(?m)^ {8}if:[ \t]*\$\{\{ inputs\.run-heavy \}\}[ \t]*$') {`
- Cause: G6-sharded gives the aggregator gate step `Require the static and shard jobs to succeed` the line `        if: ${{ inputs.run-heavy }}` in `.github/workflows/_poshqc.yml`.

D6-NOT-APPLICABLE: A3 | withdrawn by PD-15 (the poshqc-shard upload step keeps if: always() inside its job-gated job)

## numstat output (against origin/main, which the branch now contains)

```
10	4	tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
16	1	tests/scripts/workflows/CiWorkflow.Tests.ps1
2	2	tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
```

## Pass conditions of the referenced artifacts

- P4-T10 (p4-py-contract-pass-after.2026-10-16T23-53.md): 80 passed, no FAILED or ERROR line.
- P4-T12 re-run (p4-existing-suites.2026-10-17T00-12.md): every container Result=Passed, TOTAL Failed=0, A2 row Passed=1 Total=1, WF02 and WF03 Passed=1 Total=1, PATTERNS-PARSER rows Passed=1 Total=1, EXIT_CODE_COMPUTED: 0.
