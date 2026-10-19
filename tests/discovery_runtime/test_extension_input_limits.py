"""Verify finite projection resources and exact canonical serialization boundaries."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import extension_inputs as subject
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
from drm_copilot_discovery.models import (
    JsonObject,
    JsonValue,
    ParseLimits,
    canonical_json,
)
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import inventory_profile
from tests.discovery_runtime.test_extension_inputs import capture_case

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


@pytest.mark.parametrize(
    "failure",
    ["source-bytes", "pin-bytes", "file-bytes", "count", "records", "depth", "work"],
)
def test_projection_reserves_resources_before_complete_result_allocation(
    analyzer_catalog: SchemaCatalog, failure: str
) -> None:
    """Reject deterministic overflows in separate byte/count/traversal domains.

    analyzer_catalog (SchemaCatalog), failure (str) choose a bounded synthetic
    overflow. Returns None; assertions enforce whole-operation failure. No I/O.
    """
    capture = capture_case(analyzer_catalog, limits={"document_bytes": 16384})
    # Each branch exhausts one independent reservation without large stress inputs.
    if failure in ("source-bytes", "file-bytes"):
        size = 16385 if failure == "source-bytes" else 2
        source = SnapshotFile(
            path="src/large.cs", category="source", content=b"x" * size
        )
        capture = replace(
            capture,
            inputs=(InventoryInput(path=source.path, status="inspected", file=source),),
        )
        if failure == "file-bytes":
            capture = replace(
                capture,
                profile=inventory_profile(
                    analyzer_catalog,
                    analyzers={
                        "enabled": ["repository"],
                        "options": {"max_file_bytes": 1},
                        "ignored_paths": [],
                        "extension_result_manifests": [],
                    },
                ),
            )
    elif failure == "pin-bytes":
        capture = replace(
            capture,
            repository_files=(
                replace(capture.repository_files[0], content=b"x" * 16385),
            ),
        )
    elif failure == "count":
        capture = replace(
            capture,
            profile=inventory_profile(
                analyzer_catalog, test_roots=["tests"], limits={"source_files": 3}
            ),
            repository_files=capture.repository_files * 2,
        )
    else:
        limits = (
            {"artifact_records": 1}
            if failure == "records"
            else (
                {"nesting_depth": 2}
                if failure == "depth"
                else {"artifact_records": 100}
            )
        )
        capture = replace(
            capture,
            profile=inventory_profile(
                analyzer_catalog, test_roots=["tests"], limits=limits
            ),
        )
        if failure == "work":
            name = "src/" + "a" * 1000
            capture = replace(
                capture,
                inputs=(
                    InventoryInput(
                        path=name, status="unreadable", rationale="Unavailable."
                    ),
                ),
            )
    with pytest.raises(ValueError, match="limit|count"):
        subject.extension_input_projection(capture)


@pytest.mark.parametrize("text", ["ASCII", "é", "中", "😀", "\x00", "\n\t", '"\\/~'])
def test_manifest_serialization_accounts_for_exact_utf8_and_json_escapes(
    text: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Accept exact encoded boundaries and reject one byte below before serialization.

    text (str) selects Unicode/escape cases; monkeypatch (MonkeyPatch) installs
    isolated small parser limits. Returns None; assertions expose wrong budgets.
    """
    value = row(value=text)
    size = len(canonical_json(value))
    actual = ParseLimits

    def limits(**overrides: int) -> ParseLimits:
        """Return finite test policy; overrides (int keywords) preserve capacities.

        Returns ParseLimits using the selected exact byte size; no I/O occurs.
        """
        return actual(**(overrides | {"document_bytes": size}))

    monkeypatch.setattr(subject, "ParseLimits", limits)
    assert (
        subject.extension_manifest_digest(value)
        == hashlib.sha256(canonical_json(value)).hexdigest()
    )
    size -= 1
    with pytest.raises(ValueError, match="byte limit"):
        subject.extension_manifest_digest(value)


@pytest.mark.parametrize("invalid", [None, {}, ()])
def test_public_hash_inputs_require_validated_immutable_carriers(
    invalid: object,
) -> None:
    """Reject arbitrary caller objects without executing them or coercing their data.

    invalid (object) selects a malformed boundary value. Returns None; assertions
    enforce fixed ValueError diagnostics. No external state is accessed.
    """
    with pytest.raises(ValueError, match="InventoryCapture"):
        subject.extension_input_projection(cast("InventoryCapture", invalid))
    with pytest.raises(ValueError, match="JsonObject"):
        subject.extension_manifest_digest(cast("JsonObject", invalid))


@pytest.mark.parametrize("value", [None, True, False, 123, -7, 1.25, (), (1, "x")])
def test_manifest_hash_preserves_supported_json_scalars(value: JsonValue) -> None:
    """Canonicalize supported scalar/array values without lossy string conversion.

    value (JsonValue) selects the immutable input. Returns None; assertions fail
    if canonical identity differs. No I/O or mutable global state is used.
    """
    document = row(value=value)
    assert (
        subject.extension_manifest_digest(document)
        == hashlib.sha256(canonical_json(document)).hexdigest()
    )


@pytest.mark.parametrize(
    "failure", ["nodes", "records", "depth", "integer", "unicode", "scalar"]
)
def test_manifest_limits_reject_before_canonical_serialization(
    failure: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject bounded structural/scalar errors before canonical conversion is called.

    failure (str) chooses the isolated defect; monkeypatch (MonkeyPatch) supplies
    test-local policy/serialization seams. Returns None; assertions expose late
    rejection. Forged immutable carriers exercise defensive public boundaries.
    """
    value = row(value=tuple(range(64)))
    policy = ParseLimits(artifact_records=1)
    # Small inputs distinguish traversal, nesting, numeric and Unicode failures.
    if failure == "records":
        value = row(value=row(nested=1))
    elif failure == "depth":
        value = row(value=(((1,),),))
        policy = ParseLimits(nesting_depth=2)
    elif failure == "integer":
        value = row(value=10**40)
        policy = ParseLimits(document_bytes=20)
    elif failure in ("unicode", "scalar"):
        value = row(value="valid")
        object.__setattr__(
            value,
            "members",
            (("value", "\ud800" if failure == "unicode" else float("nan")),),
        )

    def limits(**overrides: int) -> ParseLimits:
        """Return policy (ParseLimits) through the isolated constructor seam.

        overrides (int keywords) are already validated by the real policy object.
        Returns ParseLimits; no I/O or state mutation occurs.
        """
        del overrides
        return policy

    def forbidden(value: JsonValue) -> bytes:
        """Reject premature serialization of value (JsonValue) in this test.

        Returns no bytes; always raises AssertionError. No I/O occurs.
        """
        raise AssertionError("Canonical serialization happened before rejection")

    monkeypatch.setattr(subject, "ParseLimits", limits)
    monkeypatch.setattr(subject, "canonical_json", forbidden)
    with pytest.raises(ValueError, match="Extension"):
        subject.extension_manifest_digest(value)


def test_pin_budget_is_checked_before_any_content_hash(
    analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject an over-limit retained object before its digest property executes.

    analyzer_catalog (SchemaCatalog), monkeypatch (MonkeyPatch) supply isolated
    capture and property seam. Returns None; assertions enforce prospective work.
    """
    from drm_copilot_discovery.repository_reader import RepositoryFile

    capture = capture_case(analyzer_catalog, limits={"document_bytes": 16384})
    capture = replace(
        capture,
        repository_files=(replace(capture.repository_files[0], content=b"x" * 16385),),
    )

    def forbidden(source: RepositoryFile) -> str:
        """Reject hashing source (RepositoryFile) before its byte reservation.

        Returns no digest; always raises AssertionError. No I/O occurs.
        """
        raise AssertionError("Pinned bytes were hashed before reservation")

    monkeypatch.setattr(RepositoryFile, "sha256", property(forbidden))
    with pytest.raises(ValueError, match="retained pin bytes"):
        subject.extension_input_projection(capture)


def test_projected_mappings_reserve_records_before_row_construction(
    analyzer_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Stop when profile plus two rows exhaust a three-input projection's capacity.

    analyzer_catalog (SchemaCatalog) supplies an immutable profile; monkeypatch
    (MonkeyPatch) counts actual row construction. Returns None; assertions enforce
    prospective record limits independently of the path-comparison budget.
    """
    initial = capture_case(analyzer_catalog)

    def mappings(value: JsonValue) -> int:
        """Count existing mapping nodes in value (JsonValue) for a fixture capacity.

        Returns int; recursive traversal touches only this tiny immutable fixture.
        No I/O occurs and no exceptions are expected for validated JSON.
        """
        if isinstance(value, JsonObject):
            # Include each existing nested object exactly once in the fixture cap.
            return 1 + sum(mappings(child) for _, child in value.members)
        if isinstance(value, tuple):
            # Array elements can independently contain mapping records.
            return sum(mappings(child) for child in value)
        return 0

    # Short valid paths leave traversal capacity for the independent record gate.
    artifacts = {
        name: "o" if name == "root" else f"o/{index:x}"
        for index, name in enumerate(initial.profile.artifacts.data)
    }
    # An explicit limits policy itself adds a mapping to profiles that omit it.
    final_shape = row(
        **(dict(initial.profile.document) | {"limits": row(artifact_records=1)})
    )
    capture = capture_case(
        analyzer_catalog,
        limits={"artifact_records": mappings(final_shape) + 2},
        artifacts=artifacts,
        evidence_roots=["o/9"],
    )
    # Preserve all three input roles while avoiding unrelated long-root costs.
    files = tuple(
        SnapshotFile(path=path, category=source.file.category, content=b"x")
        for path, source in zip(
            ("docs/c", "src/a", "tests/b"), capture.inputs, strict=True
        )
        if source.file is not None
    )
    # Exactly two successful rows may be retained before the third reservation.
    capture = replace(
        capture,
        inputs=tuple(
            InventoryInput(path=file.path, status="inspected", file=file)
            for file in files
        ),
    )
    created: list[JsonObject] = []

    def counted_row(**values: JsonValue) -> JsonObject:
        """Record each bounded projection allocation in values (JsonValue keywords).

        Returns JsonObject via the real constructor; its validation errors propagate.
        Only this test-local list changes, without filesystem or network access.
        """
        result = row(**values)
        created.append(result)
        return result

    monkeypatch.setattr(subject, "row", counted_row)
    with pytest.raises(ValueError, match="record limit"):
        subject.extension_input_projection(capture)
    assert len(created) == 2
