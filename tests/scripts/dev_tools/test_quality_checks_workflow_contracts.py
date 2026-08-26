"""Contract regression tests for the reusable quality-checks workflow.

These tests assert against the committed workflow document, following the
precedent of ``test_orchestrator_direct_command_contracts.py``: the repository
root is computed from this file's own resolved path and the workflow is read as
UTF-8 text.
"""

from __future__ import annotations

import shlex
from pathlib import Path
from typing import cast

import yaml

REPO_ROOT = Path(__file__).resolve().parents[3]
WORKFLOW_PATH = ".github/workflows/_quality-checks.yml"
FOREIGN_COVERAGE_TARGET = "lexile_corpus_tuner"
PYTEST_STEP_NAME = "Run tests with Pytest"
EQUALS_COVERAGE_FORM = "--cov="
JSON_COVERAGE_REPORT_ARGUMENT = "--cov-report=json:artifacts/python/coverage.json"
THRESHOLD_CHECKER_MODULE = "check_python_coverage_thresholds"
MIN_LINE_FLOOR = "85"
MIN_BRANCH_FLOOR = "75"
CODECOV_ACTION = "codecov/codecov-action"


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 content for a checked-in repository text file."""
    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def load_workflow_steps() -> tuple[dict[str, object], ...]:
    """Return every step mapping of the safe-loaded quality-checks workflow.

    Isolates the untyped ``yaml.safe_load`` boundary so callers work against
    narrowed mappings.
    """
    parsed = yaml.safe_load(read_repo_text(WORKFLOW_PATH))
    document = cast("dict[str, object]", parsed)
    jobs = cast("dict[str, object]", document["jobs"])
    steps: list[dict[str, object]] = []
    for job in jobs.values():
        job_mapping = cast("dict[str, object]", job)
        for step in cast("list[object]", job_mapping.get("steps", [])):
            steps.append(cast("dict[str, object]", step))
    return tuple(steps)


def step_named(name: str) -> dict[str, object]:
    """Return the single workflow step whose ``name`` value equals ``name``."""
    matches = [step for step in load_workflow_steps() if step.get("name") == name]
    assert len(matches) == 1, f"expected one step named {name}, found {len(matches)}"
    return matches[0]


def step_running(token: str) -> dict[str, object]:
    """Return the single workflow step whose ``run`` value contains ``token``."""
    matches = [
        step for step in load_workflow_steps() if token in str(step.get("run", ""))
    ]
    assert len(matches) == 1, f"expected one step running {token}, found {len(matches)}"
    return matches[0]


def step_using(action: str) -> dict[str, object]:
    """Return the single workflow step whose ``uses`` value names ``action``."""
    matches = [
        step for step in load_workflow_steps() if action in str(step.get("uses", ""))
    ]
    assert len(matches) == 1, f"expected one step using {action}, found {len(matches)}"
    return matches[0]


def run_tokens(step: dict[str, object]) -> tuple[str, ...]:
    """Shell-split a step's ``run`` value, dropping line-continuation tokens."""
    run_value = step.get("run")
    assert isinstance(run_value, str), "step carries no string run value"
    return tuple(token for token in shlex.split(run_value) if token.strip())


def test_workflow_names_no_foreign_coverage_target() -> None:
    """The workflow must not name a coverage target package the repo lacks.

    Scenario: the committed workflow text is lowercased and searched for the
    foreign package token. Expected outcome: the token is absent.
    """
    workflow_text = read_repo_text(WORKFLOW_PATH).lower()

    assert FOREIGN_COVERAGE_TARGET not in workflow_text


def test_pytest_step_uses_bare_cov_with_branch() -> None:
    """The pytest step must measure branches over the configured source list.

    Scenario: the pytest step's ``run`` value is shell-split. Expected outcome:
    ``--cov-branch`` is present and no token pins coverage to an explicit
    target with the equals form.
    """
    tokens = run_tokens(step_named(PYTEST_STEP_NAME))

    assert "--cov-branch" in tokens
    pinned = [token for token in tokens if token.startswith(EQUALS_COVERAGE_FORM)]
    assert pinned == []


def test_pytest_step_emits_json_coverage_report() -> None:
    """The pytest step must emit the JSON report the threshold gate reads.

    Scenario: the pytest step's ``run`` value is shell-split. Expected outcome:
    the JSON coverage-report token is present.
    """
    tokens = run_tokens(step_named(PYTEST_STEP_NAME))

    assert JSON_COVERAGE_REPORT_ARGUMENT in tokens


def test_threshold_step_invokes_the_checker_with_both_floors() -> None:
    """The enforcement step must pass both policy floors to the checker.

    Scenario: the step running the threshold checker is shell-split. Expected
    outcome: ``--min-line`` is immediately followed by 85 and ``--min-branch``
    is immediately followed by 75.
    """
    tokens = run_tokens(step_running(THRESHOLD_CHECKER_MODULE))

    assert "--min-line" in tokens
    assert tokens[tokens.index("--min-line") + 1] == MIN_LINE_FLOOR
    assert "--min-branch" in tokens
    assert tokens[tokens.index("--min-branch") + 1] == MIN_BRANCH_FLOOR


def test_threshold_step_runs_on_every_matrix_leg() -> None:
    """The enforcement step must not be conditioned onto one matrix leg.

    Scenario: the step running the threshold checker is inspected for a
    condition key, per decision D3 of the spec. Expected outcome: the step
    mapping carries no ``if`` key.
    """
    step = step_running(THRESHOLD_CHECKER_MODULE)

    assert "if" not in step


def test_codecov_step_uses_the_declared_files_input() -> None:
    """The Codecov upload must use the action's declared report input.

    Scenario: the Codecov step's ``with`` mapping is inspected. Expected
    outcome: it carries the declared ``files`` key and not the undeclared
    ``file`` key.
    """
    step = step_using(CODECOV_ACTION)
    with_mapping = cast("dict[str, object]", step["with"])

    assert "files" in with_mapping
    assert "file" not in with_mapping
