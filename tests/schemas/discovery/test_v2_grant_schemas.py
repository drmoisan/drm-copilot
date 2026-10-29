"""Verify the one-use root-grant and host-observation protected record schemas."""

from __future__ import annotations

import pytest

from tests.schemas.discovery.v2_control_test_support import control_fixture
from tests.schemas.discovery.v2_schema_test_support import (
    load_fixture,
    schema_errors,
)


@pytest.mark.parametrize(
    "kind,tokens",
    [
        ("root-grant", ("Bash", "handler_sha256")),
        ("host-observation", ("maybe", "state")),
    ],
)
def test_examples_validate_and_invalid_fixtures_are_rejected(
    kind: str, tokens: tuple[str, ...]
) -> None:
    """Each committed example validates; each invalid fixture names its defects."""
    assert schema_errors(kind, load_fixture(kind)) == []

    errors = schema_errors(kind, load_fixture(kind, invalid=True))

    assert errors
    messages = " ".join(error.message for error in errors)
    for token in tokens:
        assert token in messages


@pytest.mark.parametrize(
    "field,value",
    [
        ("tool", "discovery_capability_sentinel"),
        ("operation", "sentinel"),
        ("parent_agent_id", None),
        ("state", "pending"),
        ("tool_use_id", "bad id"),
        ("workspace", {}),
    ],
)
def test_root_grant_binds_tool_operation_parent_and_state(
    field: str, value: object
) -> None:
    """A root grant names a grantable tool, an operation, a parent and a state."""
    document = control_fixture("root-grant")
    document[field] = value

    assert schema_errors("root-grant", document)


def test_root_grant_tool_use_id_may_be_null() -> None:
    """Hosts whose PreToolUse carries no tool-call identifier record null."""
    document = control_fixture("root-grant")
    document["tool_use_id"] = None

    assert schema_errors("root-grant", document) == []


@pytest.mark.parametrize(
    "field,value",
    [
        ("decision", "maybe"),
        ("code", "sentinel"),
        ("tool_use_id_present", "yes"),
        ("tool", "read_discovery_source"),
        ("agent_id", "bad id"),
        ("extra", True),
    ],
)
def test_host_observation_binds_decision_code_and_sentinel_tool(
    field: str, value: object
) -> None:
    """An observation records a typed decision and only the sentinel tool as a grant."""
    document = control_fixture("host-observation")
    document[field] = value

    assert schema_errors("host-observation", document)


def test_host_observation_grant_fields_are_optional_but_travel_together() -> None:
    """A plain observation carries no grant; a partial grant is rejected."""
    document = control_fixture("host-observation")
    for field in ("tool", "input_sha256", "expires_at", "state"):
        del document[field]
    document["agent_id"] = None
    document["agent_type"] = None
    assert schema_errors("host-observation", document) == []
    document["tool"] = "discovery_capability_sentinel"

    assert schema_errors("host-observation", document)
