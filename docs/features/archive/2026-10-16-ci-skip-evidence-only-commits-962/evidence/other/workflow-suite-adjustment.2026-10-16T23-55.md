# D6 adjustments of existing contract tests (P4-T13, AC-22)

Timestamp: 2026-10-16T23-55
Command: git diff --numstat HEAD -- tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests/scripts/workflows/CiWorkflow.Tests.ps1
EXIT_CODE: 0
Output Summary: Two adjustments were made (A1 always; A4 with A4C because POSHQC-SHAPE: sharded). A2 is not applicable (A2-APPLICABLE: no) and A3 is withdrawn by PD-15. Fail-before: p4-py-contract-fail-before.2026-10-16T23-53.md. Pass-after: p4-py-contract-pass-after.2026-10-16T23-53.md (P4-T10) and p4-existing-suites.2026-10-16T23-55.md (P4-T12).

D6-ADJUSTMENT: tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py | test_threshold_step_runs_on_every_matrix_leg

- Old text: `    assert "if" not in step` (with the docstring lines "condition key, per decision D3 of the spec. Expected outcome: the step" / "mapping carries no ``if`` key.")
- New text: the module constant `RUN_HEAVY_GATE = "${{ inputs.run-heavy }}"` after `CODECOV_ACTION`, and `assert step.get("if") == RUN_HEAVY_GATE, (...)` with the docstring of section 7 A1
- Cause: G1 gives the `Enforce Python coverage thresholds` step `        if: ${{ inputs.run-heavy }}` in `.github/workflows/_quality-checks.yml`.

D6-ADJUSTMENT: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | $script:GetResultGateViolation (used by rows WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE and WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS)

- Helper comment line, old (line 51): `        # -or, exits 1, carries no step-level if condition, and precedes the completeness and merge steps.`
- Helper comment line, new (line 51): `        # -or, exits 1, carries no step-level if condition other than the issue #962 run-heavy gate, and precedes the completeness and merge steps.`
- Helper condition line, old (line 85): `            if ($gate -match '(?m)^ {8}if:') {`
- Helper condition line, new (line 85): `            if ($gate -match '(?m)^ {8}if:' -and $gate -notmatch '(?m)^ {8}if:[ \t]*\$\{\{ inputs\.run-heavy \}\}[ \t]*$') {`
- Cause: G6-sharded gives the aggregator gate step `Require the static and shard jobs to succeed` the line `        if: ${{ inputs.run-heavy }}` in `.github/workflows/_poshqc.yml`.

D6-NOT-APPLICABLE: A2 | A2-APPLICABLE: no on this HEAD (#952 is not on origin/main; the CiWorkflow.Tests.ps1 event-field row is absent)
D6-NOT-APPLICABLE: A3 | withdrawn by PD-15 (the poshqc-shard upload step keeps if: always() inside its job-gated job)

## numstat output

```
10	4	tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
2	2	tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
```

(tests/scripts/workflows/CiWorkflow.Tests.ps1 is unchanged and prints no line.)

## Pass conditions of the referenced artifacts

- P4-T10 (p4-py-contract-pass-after.2026-10-16T23-53.md): 80 passed, no FAILED or ERROR line, equal to the P0-T17 baseline count.
- P4-T12 (p4-existing-suites.2026-10-16T23-55.md): every container Result=Passed, TOTAL Failed=0, WF02 and WF03 Passed=1 Total=1, A2 row Total=0, PATTERNS-PARSER rows Passed=1 Total=1, EXIT_CODE_COMPUTED: 0.
