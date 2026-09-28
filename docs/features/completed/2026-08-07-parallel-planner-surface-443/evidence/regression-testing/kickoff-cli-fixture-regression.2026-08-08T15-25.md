# Committed-Fixture Regression Through the CLI

Timestamp: 2026-08-08T15-25

Task: [P5-T3]
Working directory: repository root

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-kickoff tests/fixtures/parallel_kickoff/valid-kickoff.md`

EXIT_CODE: 0

Output Summary: PASS with zero error lines emitted. The pre-existing committed fixture still validates cleanly after the [P1-T1] widening of `RESUME_RE`. The fixture's resume sentence uses the `items resume` spelling (`items resume at atomic execution from their committed plan-path on their own pushed feature branch`), which was already admitted by the pre-widening alternation and remains admitted by the widened one. Adding `Each item` as a third alternant is purely additive and did not break the fixture.

## Raw Output

```
parallel-kickoff validation passed: tests/fixtures/parallel_kickoff/valid-kickoff.md
```

Error lines emitted: 0.

## Cross-Reference

The same agreement is asserted as a unit test by the Python seam module's `test_committed_fixture_and_template_agree_on_the_resume_clause` ([P3-T8]), which additionally checks that `RESUME_RE` matches both the fixture text and the rendered template text. This CLI run is the end-to-end counterpart of that unit assertion.
