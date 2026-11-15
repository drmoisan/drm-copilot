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
PYTEST_STEP_NAME = "Run tests with Pytest and coverage"
PYTEST_COMPAT_STEP_NAME = "Run tests with Pytest (compatibility, no coverage)"
COVERAGE_PYTHON_VERSION = "3.13"
EQUALS_COVERAGE_FORM = "--cov="
JSON_COVERAGE_REPORT_PATH = "artifacts/python/coverage.json"
THRESHOLD_CHECKER_MODULE = "check_python_coverage_thresholds"
MIN_LINE_FLOOR = "85"
MIN_BRANCH_FLOOR = "75"
CODECOV_ACTION = "codecov/codecov-action"
RUN_HEAVY_GATE = "${{ inputs.run-heavy }}"
# Issue #1190: the 3.13 leg is carried by job identity, so its steps carry the
# plain run-heavy gate.
COVERAGE_LEG_GATE = RUN_HEAVY_GATE
COMPAT_LEG_GATE = "${{ inputs.run-heavy && matrix.python-version != '3.13' }}"
COMPAT_JOB_ID = "quality-checks7"
STATIC_JOB_ID = "python-static-313"
SHARD_JOB_ID = "python-coverage-shard"
COMBINE_JOB_ID = "python-coverage-combine"
SHARD_HELPER_NAME = "Select-PythonTestShard.ps1"
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


def load_job(job_id: str) -> dict[str, object]:
    """Return the job mapping with id ``job_id`` of the safe-loaded workflow.

    Args:
        job_id: Key of the job under the top-level ``jobs`` mapping.

    Returns:
        The job mapping; the lookup fails the test when the id is absent.
    """
    parsed = yaml.safe_load(read_repo_text(WORKFLOW_PATH))
    jobs = cast("dict[str, object]", cast("dict[str, object]", parsed)["jobs"])
    assert job_id in jobs, f"workflow carries no job {job_id}"
    return cast("dict[str, object]", jobs[job_id])


def job_steps(job_id: str) -> tuple[dict[str, object], ...]:
    """Return the step mappings of one job, in workflow order."""
    steps = cast("list[object]", load_job(job_id).get("steps", []))
    return tuple(cast("dict[str, object]", step) for step in steps)


def job_step_named(job_id: str, name: str) -> dict[str, object]:
    """Return the single step of ``job_id`` whose ``name`` equals ``name``."""
    matches = [step for step in job_steps(job_id) if step.get("name") == name]
    assert len(matches) == 1, f"expected one step {name} in {job_id}"
    return matches[0]


def step_index_running(job_id: str, token: str) -> int:
    """Return the index of the one step of ``job_id`` running ``token``."""
    matches = [
        index
        for index, step in enumerate(job_steps(job_id))
        if token in str(step.get("run", ""))
    ]
    assert len(matches) == 1, f"expected one step running {token} in {job_id}"
    return matches[0]


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
    to keep the helper independent of the TOML parser. Only a single-line
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


def test_combine_job_emits_the_json_coverage_report_the_threshold_gate_reads() -> None:
    """The combine job must emit the JSON report the threshold gate reads.

    Scenario: the combined-coverage step and the threshold step are
    shell-split (issue #1190 moved report generation from the pytest step to
    the combine job). Expected outcome: ``coverage json -o`` names the report
    path and the threshold step reads the same path through ``--report``.
    """
    json_tokens = run_tokens(step_running("coverage json"))
    threshold_tokens = run_tokens(step_running(THRESHOLD_CHECKER_MODULE))

    json_index = json_tokens.index("json")
    assert json_tokens[json_index + 1] == "-o"
    assert json_tokens[json_index + 2] == JSON_COVERAGE_REPORT_PATH
    report_index = threshold_tokens.index("--report")
    assert threshold_tokens[report_index + 1] == JSON_COVERAGE_REPORT_PATH


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


def test_coverage_steps_run_only_on_the_coverage_leg() -> None:
    """Coverage measurement and its threshold gate must run on Python 3.13 only.

    Scenario: the coverage pytest step, the threshold step, and the Codecov
    step are inspected for their jobs and conditions (issue #1190 moved the
    3.13 leg into dedicated jobs). Expected outcome: they live in the shard
    and combine jobs under the run-heavy gate, the compatibility pytest step
    keeps its complementary condition in a matrix that excludes 3.13, so every
    version runs the tests exactly once.
    """
    coverage_step = job_step_named(SHARD_JOB_ID, PYTEST_STEP_NAME)
    threshold_step = step_running(THRESHOLD_CHECKER_MODULE)
    compat_step = job_step_named(COMPAT_JOB_ID, PYTEST_COMPAT_STEP_NAME)
    matrix = cast(
        "dict[str, object]",
        cast("dict[str, object]", load_job(COMPAT_JOB_ID)["strategy"])["matrix"],
    )

    assert coverage_step.get("if") == COVERAGE_LEG_GATE
    assert threshold_step.get("if") == COVERAGE_LEG_GATE
    assert step_using(CODECOV_ACTION).get("if") == COVERAGE_LEG_GATE
    assert compat_step.get("if") == COMPAT_LEG_GATE
    assert "--cov" not in run_tokens(compat_step)
    assert COVERAGE_PYTHON_VERSION not in cast("list[object]", matrix["python-version"])


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
    for step_name in (PYTEST_STEP_NAME, PYTEST_COMPAT_STEP_NAME):
        tokens = run_tokens(step_named(step_name))

        # Act
        flag_count = tokens.count(XDIST_WORKER_FLAG)

        # Assert
        assert (
            flag_count == 1
        ), f"{step_name}: expected one -n token, found {flag_count}"
        worker_value = tokens[tokens.index(XDIST_WORKER_FLAG) + 1]
        assert worker_value in XDIST_WORKER_VALUES, (
            f"{step_name}: expected a worker count in {XDIST_WORKER_VALUES}, "
            f"found {worker_value!r}"
        )


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


def test_compat_matrix_is_311_and_312_without_coverage_steps() -> None:
    """The compatibility job must cover 3.11 and 3.12 and measure no coverage.

    Scenario: the ``quality-checks7`` job is loaded by id. Expected outcome:
    its matrix equals ``["3.11", "3.12"]`` and no step of the job measures
    coverage, enforces the threshold, or uploads to Codecov.
    """
    # Arrange
    job = load_job(COMPAT_JOB_ID)
    matrix = cast(
        "dict[str, object]", cast("dict[str, object]", job["strategy"])["matrix"]
    )

    # Act
    coverage_steps = [
        step.get("name")
        for step in job_steps(COMPAT_JOB_ID)
        if "--cov" in str(step.get("run", ""))
        or THRESHOLD_CHECKER_MODULE in str(step.get("run", ""))
        or CODECOV_ACTION in str(step.get("uses", ""))
    ]

    # Assert
    assert matrix["python-version"] == ["3.11", "3.12"]
    assert coverage_steps == []


def test_shard_job_matrix_and_shard_count_wiring() -> None:
    """The shard job must run shards 1 and 2 and derive the count from the matrix.

    Scenario: the ``python-coverage-shard`` job is loaded by id. Expected
    outcome: its matrix is ``[1, 2]`` and the selection step passes the shard
    index from the matrix and the shard count from ``strategy.job-total``, so
    the matrix literal is the only place the count is written.
    """
    # Arrange
    job = load_job(SHARD_JOB_ID)
    matrix = cast(
        "dict[str, object]", cast("dict[str, object]", job["strategy"])["matrix"]
    )
    select_step = job_step_named(SHARD_JOB_ID, "Select the test files of this shard")

    # Act
    run_text = str(select_step["run"])

    # Assert
    assert matrix["shard"] == [1, 2]
    assert SHARD_HELPER_NAME in run_text
    assert "-ShardCount ${{ strategy.job-total }}" in run_text
    assert "-ShardIndex ${{ matrix.shard }}" in run_text


def test_shard_coverage_file_is_not_a_dot_name() -> None:
    """The shard coverage data file must not be a hidden file.

    Scenario: the ``COVERAGE_FILE`` value of the shard pytest step is read.
    Expected outcome: its basename does not start with a dot and names the
    shard, because ``upload-artifact`` skips hidden files and two shards must
    not share a data file name.
    """
    # Arrange
    env = cast("dict[str, str]", job_step_named(SHARD_JOB_ID, PYTEST_STEP_NAME)["env"])

    # Act
    basename = env["COVERAGE_FILE"].rsplit("/", maxsplit=1)[-1]

    # Assert
    assert not basename.startswith(".")
    assert "${{ matrix.shard }}" in basename


def test_shard_uploads_python_coverage_shard_artifact() -> None:
    """Each shard must upload its data, JUnit report, and manifest.

    Scenario: the upload step of the shard job is read. Expected outcome: the
    artifact name is ``python-coverage-shard-${{ matrix.shard }}`` and its
    path lists the shard coverage data file, the shard JUnit file, and the
    shard manifest.
    """
    # Arrange
    upload = next(
        step
        for step in job_steps(SHARD_JOB_ID)
        if "actions/upload-artifact" in str(step.get("uses", ""))
    )
    with_mapping = cast("dict[str, str]", upload["with"])
    coverage_file = cast(
        "dict[str, str]", job_step_named(SHARD_JOB_ID, PYTEST_STEP_NAME)["env"]
    )["COVERAGE_FILE"]

    # Act
    paths = [line.strip() for line in with_mapping["path"].splitlines()]

    # Assert
    assert with_mapping["name"] == "python-coverage-shard-${{ matrix.shard }}"
    assert coverage_file in paths
    assert "artifacts/python/junit-shard-${{ matrix.shard }}.xml" in paths
    assert "artifacts/python/shard-files.json" in paths


def test_combine_job_name_needs_and_always() -> None:
    """The combine job must keep the required context name and always start.

    Scenario: the ``python-coverage-combine`` job is loaded by id. Expected
    outcome: its name is ``Code Quality & Tests (3.13)``, it needs the static
    and shard jobs, and its job condition contains ``always()`` so the context
    reports even when a needed job fails or is skipped.
    """
    # Arrange
    job = load_job(COMBINE_JOB_ID)

    # Act
    needs = cast("list[str]", job["needs"])

    # Assert
    assert job["name"] == "Code Quality & Tests (3.13)"
    assert sorted(needs) == [SHARD_JOB_ID, STATIC_JOB_ID]
    assert "always()" in str(job["if"])


def test_combine_first_step_requires_both_results_success() -> None:
    """The first combine step must fail unless both needed jobs succeeded.

    Scenario: the first step of the combine job is read. Expected outcome: its
    run text reads the results of both needed jobs and exits non-zero, so an
    always-running job cannot report success after a failed shard.
    """
    # Arrange
    first = job_steps(COMBINE_JOB_ID)[0]

    # Act
    run_text = str(first["run"])

    # Assert
    assert "needs.python-static-313.result" in run_text
    assert "needs.python-coverage-shard.result" in run_text
    assert "exit 1" in run_text
    assert RUN_HEAVY_GATE in str(first["if"])


def test_combine_orders_combine_before_threshold_and_codecov() -> None:
    """The combine job must merge coverage before the threshold and upload steps.

    Scenario: the step indices of the combine, completeness, threshold, and
    Codecov steps are compared. Expected outcome: completeness is verified
    first, then coverage is combined, and both precede the threshold check and
    the Codecov upload.
    """
    # Arrange
    steps = job_steps(COMBINE_JOB_ID)
    combine = step_index_running(COMBINE_JOB_ID, "coverage combine")
    verify = step_index_running(COMBINE_JOB_ID, SHARD_HELPER_NAME)
    threshold = step_index_running(COMBINE_JOB_ID, THRESHOLD_CHECKER_MODULE)
    codecov = next(
        index
        for index, step in enumerate(steps)
        if CODECOV_ACTION in str(step.get("uses", ""))
    )

    # Act and Assert
    assert verify < combine < threshold < codecov


def test_combine_runs_completeness_verify_step() -> None:
    """The combine job must run the helper in verify mode.

    Scenario: the combine step that names the helper script is read.
    Expected outcome: it selects Verify mode, reads the shard manifests from
    the download folder, and passes the collected-count text, so a missing or
    duplicated test file and a JUnit sum mismatch fail the job.
    """
    # Arrange
    verify_index = step_index_running(COMBINE_JOB_ID, SHARD_HELPER_NAME)
    verify_step = str(job_steps(COMBINE_JOB_ID)[verify_index]["run"])

    # Act and Assert
    assert "-Mode Verify" in verify_step
    assert "-ShardRoot artifacts/shards" in verify_step
    assert "-CollectCountText" in verify_step
    assert "pytest --collect-only -q" in verify_step
