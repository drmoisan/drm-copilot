"""Replay the shared activation-authority fixture against the Python runtime.

The fixture under ``tests/fixtures/discovery_authority`` pins registry locations
and protected record encodings for both runtimes. The TypeScript extension
replays the same file, so a drift in either implementation fails here or there.
"""

from __future__ import annotations

import json
from hashlib import sha256
from pathlib import Path
from typing import Literal, cast

import pytest
from drm_copilot_discovery.activation_filesystem import RegistryLocation
from drm_copilot_discovery.configuration import (
    ActivationRecord,
    ConfigurationError,
    locator_bytes,
)

FIXTURE = (
    Path(__file__).resolve().parents[1]
    / "fixtures"
    / "discovery_authority"
    / "authority-vectors.json"
)
VECTORS = json.loads(FIXTURE.read_text(encoding="utf-8"))
WORKSPACE_SHA256 = cast("str", VECTORS["locations"][0]["workspace_sha256"])


def _platform(value: object) -> Literal["windows", "macos", "linux"]:
    """Narrow a fixture platform string for the typed resolver signature."""
    return cast('Literal["windows", "macos", "linux"]', value)


@pytest.mark.parametrize(
    "row", VECTORS["locations"], ids=[r["directory"][-8:] for r in VECTORS["locations"]]
)
def test_location_rows_match_the_resolver(row: dict[str, object]) -> None:
    """Every recorded location resolves identically from its trusted inputs."""
    location = RegistryLocation.for_host(
        workspace_root=cast("str", row["workspace_root"]),
        platform=_platform(row["platform"]),
        user_home=cast("str", row["user_home"]),
        local_app_data=cast("str | None", row["local_app_data"]),
        xdg_state_home=cast("str | None", row["xdg_state_home"]),
    )
    assert location.workspace == row["workspace"]
    assert location.workspace_sha256 == row["workspace_sha256"]
    assert location.directory == row["directory"]


@pytest.mark.parametrize("row", VECTORS["invalid_locations"])
def test_invalid_location_rows_are_rejected(row: dict[str, object]) -> None:
    """Rejected vectors keep failing before any I/O."""
    with pytest.raises(ValueError):
        RegistryLocation.for_host(
            workspace_root=cast("str", row["workspace_root"]),
            platform=_platform(row["platform"]),
            user_home=cast("str", row["user_home"]),
            local_app_data=cast("str | None", row["local_app_data"]),
            xdg_state_home=cast("str | None", row["xdg_state_home"]),
        )


@pytest.mark.parametrize(
    "row", VECTORS["records"], ids=[r["name"] for r in VECTORS["records"]]
)
def test_record_rows_round_trip_exact_bytes(row: dict[str, object]) -> None:
    """Decoding and re-encoding a recorded record reproduces the fixture bytes."""
    encoded = cast("str", row["encoded"]).encode("utf-8")
    record = ActivationRecord.decode(encoded, workspace_sha256=WORKSPACE_SHA256)
    assert json.loads(record.encode()) == row["record"]
    assert record.encode() == encoded
    assert sha256(encoded).hexdigest() == row["encoded_sha256"]
    # Bound rows also pin the locator rendering and the profile digest.
    if row["locator_text"] is not None:
        assert record.profile_path is not None
        assert locator_bytes(record.profile_path).decode("utf-8") == row["locator_text"]
        profile = cast("str", row["profile_bytes"]).encode("utf-8")
        assert sha256(profile).hexdigest() == record.profile_sha256


@pytest.mark.parametrize(
    "row",
    VECTORS["invalid_records"],
    ids=[r["name"] for r in VECTORS["invalid_records"]],
)
def test_invalid_record_rows_report_the_recorded_code(row: dict[str, object]) -> None:
    """Malformed and foreign records fail with the code the fixture records."""
    with pytest.raises(ConfigurationError) as caught:
        ActivationRecord.decode(
            cast("str", row["text"]).encode("utf-8"), workspace_sha256=WORKSPACE_SHA256
        )
    assert caught.value.findings[0].code == row["code"]
