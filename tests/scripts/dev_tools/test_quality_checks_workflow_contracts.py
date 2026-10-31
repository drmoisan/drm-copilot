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
RUN_HEAVY_GATE = "${{ inputs.run-heavy }}"
XDIST_WORKER_FLAG = "-n"
XDIST_WORKER_VALUES = ("auto", "4")
XDIST_LONG_FLAG_PREFIXES = ("--numprocesses", "--dist")
PYPROJECT_PATH = "pyproject.toml"
PYTEST_INI_SECTION = "[tool.pytest.ini_options]"


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


def extract_pytest_addopts(pyproject_text: str) -> str:
    """Return the ``addopts`` value of the pytest section of a pyproject text.

    The text is scanned line by line instead of parsed with ``tomllib``,
    because the Python 3.10 matrix leg has no ``tomllib``. Only a single-line
    quoted ``addopts`` string is recognized, which is the form the project
    uses.

    Args:
        pyproject_text: Full text of a ``pyproject.toml`` document.

    Returns:
        The unquoted ``addopts`` string, or an empty string when the pytest
        section carries no ``addopts`` key.
    """
    in_pytest_section = False
    # Walk the lines, tracking whether the current table is the pytest section.
    for line in pyproject_text.splitlines():
        stripped = line.strip()
        # A table header switches sections; only keys of the pytest table count.
        if stripped.startswith("["):
            in_pytest_section = stripped == PYTEST_INI_SECTION
            continue
        key, separator, value = stripped.partition("=")
        if in_pytest_section and separator and key.strip() == "addopts":
            return value.strip().strip("\"'")
    return ""


def xdist_flags_in(addopts: str) -> list[str]:
    """Return every xdist worker or distribution token in an ``addopts`` value.

    Args:
        addopts: The ``addopts`` string to shell-split.

    Returns:
        The tokens equal to ``-n`` or starting with ``--numprocesses`` or
        ``--dist``, in their original order; an empty list when there are none.
    """
    # Keep each token that would make every pytest invocation start xdist workers.
    return [
        token
        for token in shlex.split(addopts)
        if token == XDIST_WORKER_FLAG or token.startswith(XDIST_LONG_FLAG_PREFIXES)
    ]


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

    Scenario: the step running the threshold checker is inspected for its
    condition, per decision D3 of the spec. The only permitted condition is the
    issue #962 run-heavy gate, whose value is the same on every matrix leg.
    Expected outcome: the step's ``if`` value equals the run-heavy gate exactly;
    an absent key or any other condition fails.
    """
    step = step_running(THRESHOLD_CHECKER_MODULE)

    assert step.get("if") == RUN_HEAVY_GATE, (
        "the threshold step must carry exactly the run-heavy gate, found "
        f"{step.get('if')!r}"
    )


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


def test_pytest_step_runs_xdist_workers() -> None:
    """The CI pytest step must start xdist workers with a measured worker count.

    Scenario: the pytest step's ``run`` value is shell-split. Expected outcome:
    ``-n`` occurs exactly once and the token after it is ``auto`` or ``4``,
    the two worker settings that issue #1048 measures on the CI runner.
    """
    # Arrange
    tokens = run_tokens(step_named(PYTEST_STEP_NAME))

    # Act
    flag_count = tokens.count(XDIST_WORKER_FLAG)

    # Assert
    assert flag_count == 1, f"expected one -n token, found {flag_count}"
    worker_value = tokens[tokens.index(XDIST_WORKER_FLAG) + 1]
    assert (
        worker_value in XDIST_WORKER_VALUES
    ), f"expected a worker count in {XDIST_WORKER_VALUES}, found {worker_value!r}"


def test_pyproject_addopts_carries_no_xdist_flag() -> None:
    """The project ``addopts`` must not start xdist workers on every run.

    Scenario: the committed ``pyproject.toml`` is read as text and its pytest
    ``addopts`` value is shell-split. Expected outcome: no ``-n``,
    ``--numprocesses``, or ``--dist`` token is present, because the VS Code
    Test Explorer keys results to the wrong file when ``addopts`` carries
    ``-n``.
    """
    # Arrange
    addopts = extract_pytest_addopts(read_repo_text(PYPROJECT_PATH))

    # Act
    flags = xdist_flags_in(addopts)

    # Assert
    assert addopts != "", "the pytest section carries no addopts value"
    assert flags == [], f"addopts must not carry xdist flags, found {flags}"


def test_addopts_xdist_check_rejects_injected_flag() -> None:
    """The ``addopts`` check must report an injected xdist flag.

    Scenario: an in-memory pyproject text whose pytest ``addopts`` carries
    ``-n auto`` and a ``--dist`` option, preceded by another table that has
    its own ``addopts`` key, is fed to the same extraction helper. Expected
    outcome: only the pytest table is read and both xdist tokens are
    reported, so the check can fail.
    """
    # Arrange
    pyproject_text = (
        "[tool.other]\n"
        'addopts = "-q"\n'
        f"{PYTEST_INI_SECTION}\n"
        'addopts = "-ra -n auto --dist=loadfile"\n'
    )

    # Act
    flags = xdist_flags_in(extract_pytest_addopts(pyproject_text))

    # Assert
    assert flags == ["-n", "--dist=loadfile"]
