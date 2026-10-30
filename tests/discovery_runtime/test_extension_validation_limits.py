"""Verify extension transport and prospective resource boundaries in memory."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
from drm_copilot_discovery.extension_inputs import extension_input_digest
from drm_copilot_discovery.extension_results import (
    ExtensionResultError,
    validate_extension_results,
)
from drm_copilot_discovery.extension_validation import (
    ExtensionBudget,
    ExtensionValidation,
)
from drm_copilot_discovery.models import JsonValue, canonical_json
from drm_copilot_discovery.profile_models import ProfileLimits
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import inventory_profile
from tests.discovery_runtime.test_extension_results import (
    MANIFEST,
    MEMBER,
    documents,
    edit_bundle,
)
from tests.discovery_runtime.test_extension_results import bundle as bundle
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


@pytest.mark.parametrize(
    "fault",
    [
        "manifest-hash",
        "member-hash",
        "missing-member",
        "category",
        "missing-pin",
        "changed-pin",
        "malformed-json",
    ],
)
def test_transport_and_independent_pin_failures(
    bundle: DiscoverySnapshot, fault: str
) -> None:
    """Reject fault (str) in bundle (DiscoverySnapshot); return None.

    Creates isolated capture variants and expects the matching ExtensionResultError;
    assertions reject incorrect integrity/provenance outcomes. No I/O occurs.
    """
    manifest, member = documents(bundle)
    changed, code = bundle, "EXTENSION_MEMBER"
    # Each branch models a distinct capture failure instead of manufacturing proof.
    if fault == "manifest-hash":
        manifest["manifest_sha256"] = "f" * 64
        changed, code = (
            edit_bundle(bundle, manifest, member, seal=False),
            "EXTENSION_DIGEST",
        )
    elif fault == "member-hash":
        as_object(cast("list[object]", manifest["result_files"])[0])["sha256"] = (
            "f" * 64
        )
        changed = edit_bundle(bundle, manifest, member, bind=False)
    elif fault in {"missing-pin", "changed-pin"}:
        pins = (
            ()
            if fault == "missing-pin"
            else tuple(
                replace(pin, content=b"different") for pin in bundle.repository_files
            )
        )
        changed = replace(bundle, repository_files=pins)
        manifest["input_manifest_sha256"] = extension_input_digest(
            capture_snapshot(changed)
        )
        changed, code = edit_bundle(changed, manifest, member), "EXTENSION_SOURCE"
    else:
        # Faults alter only the member stream/category; other captured bytes remain
        # exact.
        files = tuple(file for file in bundle.manifest.files if file.path != MEMBER)
        if fault == "category":
            original = bundle.file(MEMBER)
            assert original is not None
            files += (replace(original, category="source-snapshot"),)
        elif fault == "malformed-json":
            files += (SnapshotFile(path=MEMBER, content=b"{", category="artifact"),)
            code = "EXTENSION_SCHEMA"
        changed = replace(bundle, manifest=replace(bundle.manifest, files=files))
    with pytest.raises(ExtensionResultError) as failure:
        validate_extension_results(changed)
    assert failure.value.code == code


@pytest.mark.parametrize(
    ("inputs", "diagnostics", "allowed"),
    [
        (100, 0, True),
        (0, 100, True),
        (100, 63, True),
        (100, 64, True),
        (100, 65, False),
    ],
)
def test_diagnostic_link_work_has_an_independent_operation_ceiling(
    inputs: int, diagnostics: int, allowed: bool
) -> None:
    """Check inputs/diagnostics (int) against allowed (bool); return None.

    Expects EXTENSION_LIMIT only above the operation ceiling; assertions detect
    incorrect equality/empty handling. No mutation or external effects occur.
    """
    from drm_copilot_discovery.extension_validation import check_link_work

    # The prospective operation budget includes empty and exact-boundary populations.
    if allowed:
        assert check_link_work(inputs, diagnostics, 6400) is None
    else:
        with pytest.raises(ExtensionResultError, match="EXTENSION_LIMIT"):
            check_link_work(inputs, diagnostics, 6400)


@pytest.mark.parametrize("invalid", [0, -1, True, 1.5, "1", None])
@pytest.mark.parametrize(
    "field", ["max_bytes", "max_records", "max_nodes", "max_depth"]
)
def test_resource_limits_require_positive_exact_integers(
    field: str, invalid: object
) -> None:
    """Reject invalid (object) capacity at field (str); return None.

    Expects EXTENSION_LIMIT before traversal; assertions reject ambiguous types.
    Only an isolated argument mapping is allocated; no I/O occurs.
    """
    values = {"max_bytes": 100, "max_records": 10, "max_nodes": 100, "max_depth": 10}
    with pytest.raises(ExtensionResultError, match="EXTENSION_LIMIT"):
        ExtensionBudget(**(values | {field: cast("int", invalid)}))


@pytest.mark.parametrize(
    "value",
    [None, True, False, 3, -42, 1.25, 'é𐍈"\n\x01', ("x", "y"), row(**{'é"': ("𐍈", 1)})],
)
def test_utf8_json_reservation_matches_canonical_boundary(value: JsonValue) -> None:
    """Reserve canonical bytes of value (JsonValue); return None.

    Expects EXTENSION_LIMIT one byte short; assertions require exact allowed cost.
    Mutates local budgets only, with no input changes or I/O.
    """
    size = len(canonical_json(value))
    allowed = ExtensionBudget(
        max_bytes=size, max_records=10, max_nodes=100, max_depth=10
    )
    allowed.reserve(value)
    assert allowed.bytes == size
    denied = ExtensionBudget(
        max_bytes=size - 1, max_records=10, max_nodes=100, max_depth=10
    )
    with pytest.raises(ExtensionResultError, match="EXTENSION_LIMIT"):
        denied.reserve(value)


@pytest.mark.parametrize(
    "mode",
    ["record", "depth", "node", "invalid-record", "nonfinite", "non-json", "integer"],
)
def test_independent_traversal_record_and_numeric_limits(mode: str) -> None:
    """Exhaust the independent resource selected by mode (str); return None.

    Expects EXTENSION_LIMIT and no partial projection; assertion failure detects
    an unchecked bound. Changes only isolated reservation state, without I/O.
    """
    reservation = ExtensionBudget(
        max_bytes=100,
        max_records=1,
        max_nodes=1 if mode == "node" else 100,
        max_depth=1 if mode == "depth" else 10,
    )
    # Each branch exercises one distinct prospective boundary with a small fixed
    # payload.
    value: JsonValue = ("child",) if mode in {"depth", "node"} else "value"
    records = (
        2 if mode == "record" else cast("int", True) if mode == "invalid-record" else 0
    )
    if mode == "nonfinite":
        value = float("inf")
    elif mode == "non-json":
        value = cast("JsonValue", [])
    elif mode == "integer":
        value = 10**5000
    with pytest.raises(ExtensionResultError, match="EXTENSION_LIMIT"):
        reservation.reserve(value, records=records)


def test_raw_member_aggregate_is_independent_of_each_document_limit(
    bundle: DiscoverySnapshot,
) -> None:
    """Bound combined retained bytes for bundle (DiscoverySnapshot); return None.

    Alters an isolated context limit; expects EXTENSION_LIMIT on the second read.
    Assertions detect unbounded aggregate input; no filesystem access occurs.
    """
    context = ExtensionValidation(bundle)
    manifest, member = bundle.file(MANIFEST), bundle.file(MEMBER)
    assert manifest is not None and member is not None
    context.limits = ProfileLimits(
        document_bytes=len(manifest.content) + len(member.content) - 1
    )
    context.read(MANIFEST, "extension-result-manifest")
    with pytest.raises(ExtensionResultError, match="EXTENSION_LIMIT"):
        context.read(MEMBER, "inventory-snapshot")


def test_capture_index_count_is_bounded_before_projection(
    bundle: DiscoverySnapshot,
) -> None:
    """Bound capture indexes from bundle (DiscoverySnapshot); return None.

    Supplies explicit low profile limits; expects EXTENSION_LIMIT before indexing.
    Assertions detect missed bounds; immutable local replacement causes no I/O.
    """
    profile = inventory_profile(
        bundle.catalog, limits={"source_files": 1, "artifact_records": 1}
    )
    with pytest.raises(ExtensionResultError, match="EXTENSION_LIMIT"):
        ExtensionValidation(replace(bundle, profile=profile))


@pytest.mark.parametrize(
    ("value", "capacity", "preload", "allowed"),
    [
        pytest.param(0, 2, False, True, id="zero-exact"),
        pytest.param(0, 1, False, False, id="zero-short"),
        pytest.param(9, 2, False, True, id="single-exact"),
        pytest.param(10, 3, False, True, id="power-exact"),
        pytest.param(10, 2, False, False, id="power-short"),
        pytest.param(-9, 3, False, True, id="negative-exact"),
        pytest.param(-9, 2, False, False, id="negative-short"),
        pytest.param(-10, 4, False, True, id="negative-power-exact"),
        pytest.param(-10, 3, False, False, id="negative-power-short"),
        pytest.param(123, 2, False, False, id="review-small-overflow"),
        pytest.param(999, 4, False, True, id="below-power-exact"),
        pytest.param(1000, 4, False, False, id="power-width-overflow"),
        pytest.param(10**1000, 10, False, False, id="review-large-overflow"),
        pytest.param(-(10**1000), 10, False, False, id="negative-large-overflow"),
        pytest.param(10**1000, 1002, False, True, id="review-large-exact"),
        pytest.param(-(10**1000), 1003, False, True, id="negative-large-exact"),
        pytest.param(10**5000, 5002, False, True, id="beyond-rendering-ceiling"),
        pytest.param(123, 9, True, True, id="remaining-exact"),
        pytest.param(123, 8, True, False, id="remaining-short"),
    ],
)
def test_integer_budget_never_renders_before_reservation(
    value: int,
    capacity: int,
    preload: bool,
    allowed: bool,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Measure value (int) within capacity (int), without decimal allocation.

    preload/allowed (bool) select prior usage and expected success. monkeypatch
    (pytest.MonkeyPatch) installs a counted local str seam. Returns None; assertions
    detect rendering or wrong byte costs, with EXTENSION_LIMIT expected on denial.
    Mutates only local counters and a temporary module attribute; no I/O occurs.
    """
    import drm_copilot_discovery.extension_validation as module

    conversions: list[object] = []

    class CountedText(str):
        """Count attempted decimal rendering through one temporary local seam.

        Installed only by this test's monkeypatch; each construction records its
        input, then preserves normal str behavior. No I/O or production state is
        retained after fixture cleanup. Integer reservations must never invoke it.
        """

        def __new__(cls, item: object = "") -> CountedText:
            """Return CountedText for item (object), counting this allocation attempt.

            cls is the test string subclass. Normal str conversion failures
            propagate; only the isolated conversions list changes. No I/O occurs.
            """
            conversions.append(item)
            return super().__new__(cls, item)

    monkeypatch.setattr(module, "str", CountedText, raising=False)
    reservation = ExtensionBudget(
        max_bytes=capacity, max_records=1, max_nodes=10, max_depth=1
    )
    # Prior usage verifies the guard applies to remaining, not original, capacity.
    if preload:
        reservation.reserve(None)
    before = reservation.bytes
    # Exact boundaries succeed; overflow is rejected before any decimal conversion.
    if allowed:
        reservation.reserve(value)
        assert reservation.bytes == capacity
    else:
        with pytest.raises(ExtensionResultError, match="EXTENSION_LIMIT"):
            reservation.reserve(value)
        assert reservation.bytes == before
    assert conversions == []
