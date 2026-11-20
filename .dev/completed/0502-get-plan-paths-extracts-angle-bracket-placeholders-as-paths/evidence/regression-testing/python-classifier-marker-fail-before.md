# Fail-Before — Python Classifier Marker Rejection — [P1-T2]

Timestamp: 2026-08-23T01-28

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P1-T2] [expect-fail]
State captured: PRE-FIX, after the tests were added and before the guard exists

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction_rules.py`

EXIT_CODE: 1

ExpectedExitCode: 1

A failing run is the expected outcome for this task. The guard that satisfies the five rejection
cases is not added until [P2-T4]; a passing run here would mean the tests assert something the
pre-change classifier already does, which would make them non-discriminating.

## Result

```text
5 failed, 20 passed in 0.10s
```

## The five rejection cases, failing, by node ID

| Node ID | Observed |
| --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[angle-open]` | FAILED — expected rejection, observed `'concrete'` |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[angle-close]` | FAILED — expected rejection, observed `'concrete'` |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[dollar-brace]` | FAILED — expected rejection, observed `'concrete'` |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[dollar-paren]` | FAILED — expected rejection, observed `'concrete'` |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[percent]` | FAILED — expected rejection, observed `'concrete'` |

Failure messages, verbatim:

```text
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[angle-open] - AssertionError: Expected 'docs/features/active/<feature/plan.md' to be rejected; observed 'concrete'.
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[angle-close] - AssertionError: Expected 'docs/features/active/feature>/plan.md' to be rejected; observed 'concrete'.
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[dollar-brace] - AssertionError: Expected '.claude/state/${session_id}.json' to be rejected; observed 'concrete'.
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[dollar-paren] - AssertionError: Expected '.claude/state/$(session).json' to be rejected; observed 'concrete'.
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker[percent] - AssertionError: Expected '.claude/state/%SESSION%.json' to be rejected; observed 'concrete'.
```

Exactly five parametrized cases fail, one per marker. The failure count matches the marker count,
which is the fail-before condition [P2-T3] later asserts as a deselected count of exactly 5.

## The companion real-path case, passing, by node ID

Command: `poetry run pytest "tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_real_path_on_same_task_line_survives_placeholder_rejection"`

EXIT_CODE: 0

```text
.                                                                        [100%]
1 passed in 0.04s
```

| Node ID | Observed |
| --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_real_path_on_same_task_line_survives_placeholder_rejection` | PASSED |

This case asserts survival only and makes no claim about the placeholder token, which is what lets
it hold both before and after the guard exists. Its value is that it holds across the change: if
[P2-T4]'s guard were to drop the whole task line rather than the single marker-bearing token, this
case would start failing and the over-broad rejection would be caught.

A first draft of this control additionally asserted that the placeholder token was absent from the
harvest. That assertion cannot hold pre-fix, so the control failed alongside the five rejection
cases and could not serve as a cross-change invariant. It was removed, leaving the survival
assertion the plan's task text specifies.

## Toolchain stages for this task

The `[expect-fail]` tag applies to the test stage only. The other stages remain normal pass/fail
gates and all passed on the file as committed:

| Stage | Command | Result |
| --- | --- | --- |
| format | `poetry run black --check tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` | 1 file would be left unchanged |
| lint | `poetry run ruff check --no-fix tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` | All checks passed! |
| type-check | `poetry run pyright tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` | 0 errors, 0 warnings, 0 informations |

Black reformatted the file on its first invocation, so the loop was restarted from the formatting
stage and every stage above was re-run to a clean pass, per the cross-language toolchain rule.

## Output Summary

Fail-before evidence established. Exit code 1 against an expected 1. The five parametrized
placeholder-marker rejection cases fail, each observing `'concrete'` where `None` is required, one
per marker. The companion real-path control passes. Format, lint, and type-check are clean.
