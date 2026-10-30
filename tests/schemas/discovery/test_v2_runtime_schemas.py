"""Keep runtime characterization plans, observations and comparisons distinct."""

from __future__ import annotations

from copy import deepcopy
from typing import cast

import pytest

from tests.schemas.discovery.v2_schema_test_support import (
    as_object,
    load_fixture,
    schema_errors,
)

KIND = "runtime-characterization-scenario"
REQUIRED_FIELDS = (
    "scenario_id feature_refs environment fixture preconditions action "
    "observation_plan "
    "pre_state_capture post_state_capture expected_result expected_result_basis "
    "result_status deviations evidence_refs repeatability confidence "
    "unresolved_findings "
    "runs extensions"
).split()


def _run(scenario: dict[str, object]) -> dict[str, object]:
    """Select the first execution from a freshly loaded scenario fixture."""
    return as_object(cast("list[object]", scenario["runs"])[0])


def _comparison(result: str) -> dict[str, object]:
    """Supply known expectations separately from captured outcomes."""
    scenario = load_fixture(KIND)
    scenario.update(
        expected_result="The processor is active.",
        expected_result_basis="prior-runtime-observation",
        result_status=result,
        unresolved_findings=[],
    )
    _run(scenario).update(
        expected_result="The processor is active.", result_status=result
    )
    return scenario


@pytest.mark.parametrize("field", REQUIRED_FIELDS)
def test_runtime_scenario_requires_every_plan_and_result_category(field: str) -> None:
    """Characterization cannot omit its fixture, observation plan or result axes."""
    scenario = load_fixture(KIND)
    del scenario[field]

    assert schema_errors(KIND, scenario)


def test_unexecuted_plan_has_no_fabricated_observation_or_expected_result() -> None:
    """A valid not-run scenario records plans and unknown results explicitly."""
    scenario = load_fixture(KIND)
    scenario.update(
        result_status="not-run", runs=[], evidence_refs=[], confidence="unknown"
    )
    for field in ("pre_state_capture", "post_state_capture"):
        as_object(scenario[field]).update(observed_state=None, evidence_refs=[])

    assert schema_errors(KIND, scenario) == []
    assert scenario["expected_result"] is None
    assert scenario["expected_result_basis"] == "unknown"


def test_first_observation_is_not_a_pass_without_a_known_expectation() -> None:
    """Observing state changes does not establish correctness against an expectation."""
    scenario = load_fixture(KIND)
    assert schema_errors(KIND, scenario) == []
    scenario["result_status"] = "passed"

    assert schema_errors(KIND, scenario)


@pytest.mark.parametrize("result", ("passed", "failed"))
def test_comparison_requires_known_expectation_and_recorded_evidence(
    result: str,
) -> None:
    """Comparison results retain expected/observed separation and capture evidence."""
    scenario = _comparison(result)
    assert schema_errors(KIND, scenario) == []
    scenario["evidence_refs"] = []
    assert schema_errors(KIND, scenario)
    scenario = _comparison(result)
    _run(scenario)["expected_result"] = None

    assert schema_errors(KIND, scenario)


@pytest.mark.parametrize("result", ("observed", "passed", "failed"))
@pytest.mark.parametrize("field", ("pre_state_capture", "post_state_capture"))
def test_recorded_result_needs_both_observed_state_and_evidence(
    result: str, field: str
) -> None:
    """Neither capture plans nor unbacked prose can substitute for recorded state."""
    scenario = load_fixture(KIND) if result == "observed" else _comparison(result)
    as_object(scenario[field])["evidence_refs"] = []
    assert schema_errors(KIND, scenario)
    as_object(scenario[field])["observed_state"] = None

    assert schema_errors(KIND, scenario)


@pytest.mark.parametrize(
    "field",
    (
        "timestamp",
        "environment",
        "pre_state_capture",
        "post_state_capture",
        "observed_result",
        "evidence_refs",
    ),
)
def test_each_execution_keeps_its_own_environment_and_state_captures(
    field: str,
) -> None:
    """Run-level provenance cannot be supplied only by a scenario-wide summary."""
    scenario = load_fixture(KIND)
    del _run(scenario)[field]

    assert schema_errors(KIND, scenario)


@pytest.mark.parametrize(
    "repeatability", ("repeatable", "variable", "environment-dependent")
)
def test_repeatability_claims_require_multiple_recorded_runs(
    repeatability: str,
) -> None:
    """A single observation does not prove repeatability or environmental variation."""
    scenario = load_fixture(KIND)
    scenario["repeatability"] = repeatability
    assert schema_errors(KIND, scenario)
    second = deepcopy(_run(scenario))
    second.update(id="run-beta", timestamp="2026-01-02T00:00:00Z")
    if repeatability == "environment-dependent":
        as_object(second["environment"])["id"] = "environment-beta"
    scenario["runs"] = [_run(scenario), second]

    assert schema_errors(KIND, scenario) == []


@pytest.mark.parametrize(
    "field,value",
    [
        ("expected_result", "Invented outcome"),
        ("expected_result_basis", "product-decision"),
        ("result_status", "verified"),
        ("repeatability", "passed"),
        ("confidence", "observed"),
        ("observation_plan", []),
        ("feature_refs", ["feature-alpha"]),
        ("action", {"command": "run-anything"}),
        ("environment", {"id": "environment-alpha"}),
    ],
)
def test_runtime_statuses_plans_and_link_kinds_fail_closed(
    field: str, value: object
) -> None:
    """Target approval, shell commands and incompatible axes cannot assert facts."""
    scenario = load_fixture(KIND)
    scenario[field] = value

    assert schema_errors(KIND, scenario)


@pytest.mark.parametrize("status", ("blocked", "not-applicable"))
def test_nonexecution_dispositions_require_an_explicit_reason(status: str) -> None:
    """Blocked and inapplicable observations retain a concrete deviation reason."""
    scenario = load_fixture(KIND)
    scenario.update(result_status=status, runs=[])
    assert schema_errors(KIND, scenario)
    scenario["deviations"] = [
        "The configured environment cannot execute this scenario."
    ]

    assert schema_errors(KIND, scenario) == []


def test_passed_scenario_cannot_keep_unresolved_findings() -> None:
    """An unresolved comparison cannot be converted into a passing summary."""
    scenario = _comparison("passed")
    scenario["unresolved_findings"] = [
        {"artifact_kind": "unspecified-behavior", "id": "behavior-alpha"}
    ]

    assert schema_errors(KIND, scenario)


@pytest.mark.parametrize("status", ("passed", "failed", "not-run"))
def test_scenario_summary_cannot_contradict_its_recorded_execution(status: str) -> None:
    """A summary needs a corresponding comparison, and not-run cannot retain a run."""
    scenario = _comparison(status)
    _run(scenario)["result_status"] = "observed"

    assert schema_errors(KIND, scenario)
