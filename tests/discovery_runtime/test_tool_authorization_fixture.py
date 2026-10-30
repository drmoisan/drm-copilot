"""Replay the native tool/input digest fixture against the Python runtime.

``tests/fixtures/discovery_host/tool-authorizations.json`` pins the digests the
TypeScript consumer must reproduce, the tool/operation table, the root-only
operation set and schema-checked authorization records. This module proves the
fixture remains a faithful capture of the Python ``canonical_json`` rendering
and of the committed v2 schemas.
"""

from __future__ import annotations

import json
from hashlib import sha256
from pathlib import Path
from typing import cast

import pytest
from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json

from tests.schemas.discovery.v2_schema_test_support import load_schema, schema_errors

FIXTURE = (
    Path(__file__).resolve().parents[1]
    / "fixtures"
    / "discovery_host"
    / "tool-authorizations.json"
)
VECTORS = json.loads(FIXTURE.read_text(encoding="utf-8"))


def _freeze(value: object) -> JsonValue:
    """Convert plain JSON containers into the runtime's immutable JSON values."""
    if isinstance(value, dict):
        members = cast("dict[str, object]", value)
        return JsonObject(
            tuple((key, _freeze(child)) for key, child in members.items())
        )
    if isinstance(value, list):
        return tuple(_freeze(item) for item in cast("list[object]", value))
    return cast("JsonValue", value)


def _enum(kind: str, pointer: tuple[str, ...]) -> list[str]:
    """Read one enum list from a committed schema by key path."""
    node: dict[str, object] = load_schema(kind)
    # Walk the key path; every step is a mapping in the committed schemas.
    for key in pointer:
        node = cast("dict[str, object]", node[key])
    return cast("list[str]", node["enum"])


@pytest.mark.parametrize(
    "row", VECTORS["digest_vectors"], ids=[r["name"] for r in VECTORS["digest_vectors"]]
)
def test_digest_vectors_match_canonical_json(row: dict[str, object]) -> None:
    """Every recorded digest is sha256(canonical_json({inputs, operation, tool}))."""
    payload = _freeze(
        {"inputs": row["inputs"], "operation": row["operation"], "tool": row["tool"]}
    )
    assert sha256(canonical_json(payload)).hexdigest() == row["input_sha256"]


def test_tool_table_covers_the_controlled_operation_enum_exactly() -> None:
    """The tool table, controlled set and root-only set derive from the schemas."""
    controlled = _enum("tool-authorization", ("properties", "operation"))
    tools = _enum("tool-authorization", ("properties", "tool"))
    request_operations = _enum("service-request", ("$defs", "operation"))
    table = cast("dict[str, list[str]]", VECTORS["tool_operations"])
    covered = sorted({op for ops in table.values() for op in ops})
    assert covered == sorted(controlled)
    assert sorted(table) == sorted(tools)
    assert VECTORS["controlled_operations"] == controlled
    assert VECTORS["root_only_operations"] == [
        op for op in request_operations if op not in controlled
    ]


@pytest.mark.parametrize("name", sorted(VECTORS["records"]))
def test_records_are_schema_valid(name: str) -> None:
    """Retained records are valid envelopes; refusal reasons live outside the schema."""
    assert not schema_errors("tool-authorization", VECTORS["records"][name])


@pytest.mark.parametrize("name", sorted(VECTORS["invalid_records"]))
def test_invalid_records_fail_schema_validation(name: str) -> None:
    """Every malformed variant is rejected by the committed schema."""
    assert schema_errors("tool-authorization", VECTORS["invalid_records"][name])
