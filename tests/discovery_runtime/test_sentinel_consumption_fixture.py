"""Replay the sentinel consumption fixture against the Python runtime and schemas.

``tests/fixtures/discovery_host/sentinel-consumption.json`` pins the contract the
PowerShell gate (producer), the TypeScript sentinel tool (consumer) and the
PowerShell capability probe (reader) share: the two ``host-observation`` records the
gate writes for the sentinel agent, their protected-store paths, the input digest
of the sentinel tool call and the exact ``.consumed`` latch text the consumer leaves
beside the tool record. This module proves the fixture remains a faithful capture
of the committed v2 schemas and of the Python ``canonical_json`` rendering.
"""

from __future__ import annotations

import json
from hashlib import sha256
from pathlib import Path
from typing import cast

import pytest
from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json

from tests.schemas.discovery.v2_schema_test_support import (
    is_rfc3339_timestamp,
    schema_errors,
)

FIXTURE = (
    Path(__file__).resolve().parents[1]
    / "fixtures"
    / "discovery_host"
    / "sentinel-consumption.json"
)
CONTRACT = json.loads(FIXTURE.read_text(encoding="utf-8"))
RECORDS = cast("dict[str, dict[str, object]]", CONTRACT["records"])
RELATIVE_PATHS = cast("dict[str, str]", CONTRACT["relative_paths"])


def _freeze(value: object) -> JsonValue:
    """Convert plain JSON containers into the runtime's immutable JSON values."""
    # Objects become JsonObject, arrays become tuples, scalars pass through, so the
    # digest is computed over the same value shape the runtime canonicalizes.
    if isinstance(value, dict):
        members = cast("dict[str, object]", value)
        return JsonObject(
            tuple((key, _freeze(child)) for key, child in members.items())
        )
    if isinstance(value, list):
        return tuple(_freeze(item) for item in cast("list[object]", value))
    return cast("JsonValue", value)


@pytest.mark.parametrize("name", sorted(RECORDS))
def test_records_are_schema_valid_host_observations(name: str) -> None:
    """Both gate-built records validate against the host-observation schema."""
    assert not schema_errors("host-observation", RECORDS[name])


def test_input_digest_matches_canonical_json_of_the_tool_call() -> None:
    """The grant digest is sha256(canonical_json({inputs, operation, tool}))."""
    envelopes = cast("dict[str, object]", CONTRACT["envelopes"])
    envelope = cast("dict[str, object]", envelopes["tool"])
    payload = _freeze(
        {
            "inputs": envelope["tool_input"],
            "operation": "sentinel",
            "tool": "discovery_capability_sentinel",
        }
    )
    assert sha256(canonical_json(payload)).hexdigest() == CONTRACT["input_sha256"]
    assert RECORDS["tool"]["input_sha256"] == CONTRACT["input_sha256"]


@pytest.mark.parametrize("name", sorted(RELATIVE_PATHS))
def test_relative_paths_partition_by_the_session_digest(name: str) -> None:
    """Each record lives under sessions/<sha256(session_id)>/observations/<ref>.json."""
    session_id = cast("str", CONTRACT["session_id"])
    segments = RELATIVE_PATHS[name].split("/")
    assert segments[0] == "sessions"
    assert segments[1] == sha256(session_id.encode("utf-8")).hexdigest()
    assert segments[2] == "observations"
    assert segments[3] == f"{RECORDS[name]['observation_ref']}.json"


def test_latch_names_the_tool_record_with_a_schema_timestamp() -> None:
    """The consumer latch is a JSON object naming the tool record's reference."""
    latch = cast("dict[str, str]", CONTRACT["latch"])
    assert latch["relative_path"] == f"{RELATIVE_PATHS['tool']}.consumed"
    parsed = cast("dict[str, object]", json.loads(latch["text"]))
    assert sorted(parsed) == ["consumed_at", "observation_ref"]
    assert parsed["observation_ref"] == RECORDS["tool"]["observation_ref"]
    assert is_rfc3339_timestamp(parsed["consumed_at"])
    assert latch["text"].endswith("\n")


def test_tool_record_is_issued_and_never_rewritten_as_consumed() -> None:
    """The producer writes state issued; consumption is the latch, not a rewrite."""
    assert RECORDS["tool"]["state"] == "issued"
    assert RECORDS["tool"]["tool"] == "discovery_capability_sentinel"
    assert "state" not in RECORDS["shell"]
