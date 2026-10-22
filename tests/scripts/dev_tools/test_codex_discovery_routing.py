"""Tests for fixed discovery routing through the Codex topology resolver.

The discovery route selects one of four specialist roles from an exact
canonical ``skill_id`` and refuses every code-scope, root-override, alias, or
coerced-selector input. Receipts are compared against the committed
``discovery_operations`` block of ``config/orchestration-routing.json`` so the
Python helper, the configuration, and the PowerShell/TypeScript mirrors share
one source of truth.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

from scripts.dev_tools._codex_discovery_routing import (
    DISCOVERY_GENERATED_AGENT_FAMILIES,
    DISCOVERY_OPERATIONS,
    resolve_codex_discovery_topology,
    validate_invocation_kind,
)
from scripts.dev_tools.resolve_codex_deployment import (
    GENERATED_AGENT_FAMILIES,
    ModelUnavailableError,
    resolve_codex_deployment,
)
from scripts.dev_tools.resolve_codex_topology import main, resolve_codex_topology

REPO_ROOT = Path(__file__).resolve().parents[3]
CONFIG_PATH = REPO_ROOT / "config" / "orchestration-routing.json"
SKILL_IDS: tuple[str, ...] = tuple(DISCOVERY_OPERATIONS)
CONTEXTS: tuple[str, ...] = (
    "standalone",
    "epic_preparation_child",
    "epic_execution_child",
)
PROFILE_ROWS: tuple[tuple[str, str, str], ...] = (
    ("C1", "gpt-6-luna", "low"),
    ("C2", "gpt-6.1-sol", "medium"),
    ("C3", "gpt-6.1-sol", "high"),
    ("C4", "gpt-6-astra", "max"),
)


def _configured_operations() -> dict[str, Any]:
    """Load the canonical ``discovery_operations`` block.

    Returns:
        dict[str, Any]: Skill id to its configured operation row.
    """

    document = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    return cast("dict[str, Any]", document["discovery_operations"])


def _discovery(skill_id: str, context: str = "standalone") -> dict[str, object]:
    """Resolve one well-formed discovery request.

    Args:
        skill_id: Exact canonical skill.
        context: Execution context for the request.

    Returns:
        dict[str, object]: The discovery receipt as a plain mapping.
    """

    return cast(
        "dict[str, object]",
        resolve_codex_topology(
            [], 0, 0, context, invocation_kind="discovery", skill_id=skill_id
        ),
    )


@pytest.mark.parametrize("skill_id", SKILL_IDS)
def test_discovery_receipt_matches_configured_operation(skill_id: str) -> None:
    """Each canonical skill yields the configured role, kinds, version, and gate."""

    operation = _configured_operations()[skill_id]

    receipt = _discovery(skill_id)

    assert len(receipt) == 17
    assert receipt["logical_agent"] == operation["logical_agent"]
    assert receipt["permissible_artifact_kinds"] == list(
        operation["permissible_artifact_kinds"]
    )
    assert receipt["output_contract_version"] == operation["output_contract_version"]
    assert receipt["gate_mode"] == operation["gate_mode"]
    assert receipt["route"] == "discovery"
    assert receipt["topology"] == "discovery_specialist"
    assert receipt["routing_reason"] == "fixed_discovery_operation"
    assert receipt["invocation_kind"] == "discovery"
    assert receipt["skill_id"] == skill_id
    assert receipt["production_file_count"] == 0
    assert receipt["max_production_files"] == 0
    assert receipt["languages"] == []
    assert receipt["root_persona"] is None


def test_configured_operations_match_python_table() -> None:
    """Keep the helper table and the central config synchronized."""

    configured = _configured_operations()

    assert set(configured) == set(DISCOVERY_OPERATIONS)
    # Compare each row with list-normalized kinds so tuple storage is immaterial.
    for skill_id, operation in DISCOVERY_OPERATIONS.items():
        assert configured[skill_id] == {
            **operation,
            "permissible_artifact_kinds": list(operation["permissible_artifact_kinds"]),
        }


def test_discovery_families_are_the_added_generated_families() -> None:
    """The four discovery roles are generated families and route every skill."""

    routed_roles = {row["logical_agent"] for row in DISCOVERY_OPERATIONS.values()}

    assert set(DISCOVERY_GENERATED_AGENT_FAMILIES) == routed_roles
    assert set(DISCOVERY_GENERATED_AGENT_FAMILIES) <= GENERATED_AGENT_FAMILIES


@pytest.mark.parametrize("context", CONTEXTS)
def test_discovery_routes_before_epic_child_and_zero_count_escalation(
    context: str,
) -> None:
    """Discovery is selected in every context without ordinary escalation."""

    receipt = _discovery("review-discovery-coverage", context)

    assert receipt["route"] == "discovery"
    assert receipt["execution_context"] == context
    assert receipt["logical_agent"] == "migration-coverage-reviewer"


def test_receipts_own_fresh_kind_lists() -> None:
    """Mutating one receipt cannot change the canonical table or later receipts."""

    first = _discovery("inventory-legacy-system")
    cast("list[str]", first["permissible_artifact_kinds"]).append("forbidden-write")

    second = _discovery("inventory-legacy-system")

    assert "forbidden-write" not in cast(
        "list[str]", second["permissible_artifact_kinds"]
    )
    assert (
        "forbidden-write"
        not in DISCOVERY_OPERATIONS["inventory-legacy-system"][
            "permissible_artifact_kinds"
        ]
    )


def test_explicit_ordinary_receipt_keeps_twelve_keys() -> None:
    """An explicit ordinary selector produces the unchanged ordinary receipt."""

    receipt = resolve_codex_topology(
        ["python"], 2, 3, "standalone", invocation_kind="ordinary"
    )

    assert len(receipt) == 12
    assert "invocation_kind" not in receipt
    assert receipt["logical_agent"] == "python-typed-engineer"


@pytest.mark.parametrize(
    "value", [None, 7, True, ["discovery"], "Discovery", "", "agent", " discovery"]
)
def test_invalid_invocation_kind_is_rejected_without_coercion(value: object) -> None:
    """Only the exact lowercase selectors are accepted."""

    with pytest.raises(
        ValueError, match="invocation_kind must be ordinary or discovery"
    ):
        validate_invocation_kind(value)
    with pytest.raises(
        ValueError, match="invocation_kind must be ordinary or discovery"
    ):
        resolve_codex_topology(
            [], 0, 0, "standalone", invocation_kind=cast("str", value)
        )


@pytest.mark.parametrize(
    "value",
    [
        None,
        7,
        False,
        ["inventory-legacy-system"],
        "Inventory-legacy-system",
        "",
        "discovery-repo-inventory",
        "inventory-legacy-system ",
    ],
)
def test_noncanonical_skill_is_rejected(value: object) -> None:
    """Aliases, case variants, padding, blanks, and non-strings are refused."""

    with pytest.raises(ValueError, match="require a supported skill_id"):
        resolve_codex_topology(
            [],
            0,
            0,
            "standalone",
            invocation_kind="discovery",
            skill_id=cast("str | None", value),
        )


@pytest.mark.parametrize("value", ["inventory-legacy-system", "", False])
def test_ordinary_invocation_rejects_a_supplied_skill(value: object) -> None:
    """A skill is only meaningful for discovery invocations."""

    with pytest.raises(ValueError, match="only valid for discovery invocations"):
        resolve_codex_topology(
            ["python"], 1, 1, "standalone", skill_id=cast("str | None", value)
        )


@pytest.mark.parametrize(
    ("field", "value", "message"),
    [
        ("root_persona", "epic-planner", "do not accept root_persona"),
        ("root_persona", "", "do not accept root_persona"),
        ("production_file_count", 1, "require production_file_count=0"),
        ("production_file_count", -1, "require production_file_count=0"),
        ("test_file_count", 1, "require test_file_count=0"),
        ("test_file_count", -1, "require test_file_count=0"),
        ("languages", ["python"], "do not accept languages"),
        ("cross_cutting", True, "do not accept cross_cutting"),
    ],
)
def test_discovery_refuses_forbidden_fields(
    field: str, value: object, message: str
) -> None:
    """Every code-scope or root-override field blocks a discovery request."""

    request: dict[str, Any] = {
        "languages": [],
        "production_file_count": 0,
        "test_file_count": 0,
        "execution_context": "standalone",
        "cross_cutting": False,
        "root_persona": None,
        "invocation_kind": "discovery",
        "skill_id": "inventory-legacy-system",
    }
    request[field] = value

    with pytest.raises(ValueError, match=message):
        resolve_codex_topology(**request)


def test_guards_fire_in_the_shared_precedence_order() -> None:
    """Fixing each field in order reveals the next guard until the request passes."""

    request: dict[str, Any] = {
        "invocation_kind": "discovery",
        "skill_id": "unknown",
        "execution_context": "standalone",
        "languages": ["python"],
        "production_file_count": 1,
        "test_file_count": 1,
        "cross_cutting": True,
        "root_persona": "epic-planner",
    }
    empty_languages: list[str] = []
    ordered: tuple[tuple[str, object, str], ...] = (
        ("root_persona", None, "do not accept root_persona"),
        ("production_file_count", 0, "require production_file_count=0"),
        ("test_file_count", 0, "require test_file_count=0"),
        ("languages", empty_languages, "do not accept languages"),
        ("cross_cutting", False, "do not accept cross_cutting"),
        ("skill_id", "inventory-legacy-system", "require a supported skill_id"),
    )
    # Each iteration asserts the current first failure, then repairs that field.
    for field, valid, message in ordered:
        with pytest.raises(ValueError, match=message):
            resolve_codex_discovery_topology(**request)
        request[field] = valid

    receipt = resolve_codex_discovery_topology(**request)

    assert receipt is not None
    assert receipt["route"] == "discovery"


def test_existing_type_validation_precedes_selector_validation() -> None:
    """Context, language, count, and boolean guards still fire first."""

    with pytest.raises(ValueError, match="execution_context must be one of"):
        resolve_codex_topology([], 0, 0, "unknown", invocation_kind="unknown")
    with pytest.raises(ValueError, match="cross_cutting must be a boolean"):
        resolve_codex_topology(
            [],
            0,
            0,
            "standalone",
            cross_cutting=cast("bool", "true"),
            invocation_kind="unknown",
        )


@pytest.mark.parametrize("family", DISCOVERY_GENERATED_AGENT_FAMILIES)
@pytest.mark.parametrize(("band", "model", "effort"), PROFILE_ROWS)
def test_discovery_families_use_the_unchanged_deployment_policy(
    family: str, band: str, model: str, effort: str
) -> None:
    """Each discovery role resolves the exact base profile with no fallback."""

    receipt = resolve_codex_deployment(
        family, band, "standalone", band, available_models={model}
    )

    assert receipt["deployment_agent"] == f"{family}-{band.lower()}"
    assert receipt["model"] == model
    assert receipt["model_reasoning_effort"] == effort
    assert receipt["c3_overlay_applied"] is False


@pytest.mark.parametrize("family", DISCOVERY_GENERATED_AGENT_FAMILIES)
def test_discovery_families_fail_without_model_fallback(family: str) -> None:
    """An unavailable exact model is reported, never substituted."""

    with pytest.raises(ModelUnavailableError, match="model_unavailable"):
        resolve_codex_deployment(
            family, "C1", "standalone", "C1", available_models={"gpt-6-astra"}
        )
    with pytest.raises(ValueError, match="C2 below C3"):
        resolve_codex_deployment(family, "C3", "standalone", "C2")


def test_cli_emits_the_discovery_receipt(capsys: pytest.CaptureFixture[str]) -> None:
    """The CLI accepts the selector and skill flags and prints sorted JSON."""

    exit_code = main(
        [
            "--execution-context",
            "standalone",
            "--invocation-kind",
            "discovery",
            "--skill-id",
            "generate-acceptance-scenarios",
        ]
    )

    output = json.loads(capsys.readouterr().out)
    assert exit_code == 0
    assert output["logical_agent"] == "requirements-reconciler"
    assert output["skill_id"] == "generate-acceptance-scenarios"
    assert list(output) == sorted(output)


def test_cli_rejects_an_unsupported_invocation_kind_as_usage_error() -> None:
    """An out-of-choice selector is a parser rejection, not a resolver receipt."""

    with pytest.raises(SystemExit) as raised:
        main(["--execution-context", "standalone", "--invocation-kind", "unsupported"])

    assert raised.value.code == 2
