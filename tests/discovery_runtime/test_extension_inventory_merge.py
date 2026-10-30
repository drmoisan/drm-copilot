"""Verify reconstruction, complete accounting and independent merge resource bounds."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.findings import diagnostic, row
from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
from drm_copilot_discovery.analyzer.models import InventoryInput
from drm_copilot_discovery.analyzer.pipeline import run_inventory
from drm_copilot_discovery.extension_inputs import extension_input_digest
from drm_copilot_discovery.extension_results import (
    ExtensionResultError,
    merge_extension_inventory,
    validate_extension_results,
)
from drm_copilot_discovery.extension_validation import (
    ExtensionValidation,
    object_rows,
)
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import (
    JsonObject,
    canonical_json,
    to_plain_value,
)
from drm_copilot_discovery.profile_models import ProfileLimits
from drm_copilot_discovery.schema_validation import validate_document

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.test_extension_results import (
    ADAPTER,
    AUTHOR,
    MEMBER,
    STAMP,
    documents,
    edit_bundle,
    set_field,
)
from tests.discovery_runtime.test_extension_results import (
    bundle as bundle,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.extension_validation import ValidatedExtension
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def test_merge_reconstructs_complete_core_and_external_rows(
    bundle: DiscoverySnapshot,
) -> None:
    """Preserve core and external rows from bundle (DiscoverySnapshot); return None.

    Assertions detect schema, identity, accounting or confidence changes. Pure
    reconstruction returns unassigned proposals without I/O or publication.
    """
    core = run_inventory(
        capture_snapshot(bundle),
        timestamp=STAMP,
        author_or_agent=AUTHOR,
        catalog=bundle.catalog,
    )
    merged = merge_extension_inventory(bundle, timestamp=STAMP, author_or_agent=AUTHOR)
    assert merged == merge_extension_inventory(
        bundle, timestamp=STAMP, author_or_agent=AUTHOR
    )
    assert merged.document["files"] == core.document["files"]
    assert merged.document["exclusions"] == core.document["exclusions"]
    # Built-in rows and diagnostics remain present without replacement or confidence
    # promotion.
    for family in ("components", "findings", "relationships", "diagnostics"):
        assert set(object_rows(core.document, family)) <= set(
            object_rows(merged.document, family)
        )
    assert ADAPTER in cast("tuple[JsonObject, ...]", merged.document["analyzers"])
    assert all(item["disposition"] == "unassigned" for item in merged.ledger_components)
    assert all(
        item["inspection_status"] == "uninspected" for item in merged.ledger_components
    )
    assert validate_document(
        canonical_json(merged.document),
        expected_kind="inventory-snapshot",
        expected_version="2.0.0",
        format="json",
        catalog=bundle.catalog,
    ).ok
    later = merge_extension_inventory(
        bundle, timestamp="2026-01-02T00:00:00Z", author_or_agent=AUTHOR
    )
    assert later.semantic_sha256 == merged.semantic_sha256
    assert later.document["id"] == merged.document["id"]
    assert later.document["capture"] != merged.document["capture"]


def test_empty_selection_retains_exact_builtin_output(
    bundle: DiscoverySnapshot,
) -> None:
    """Compare empty selection for bundle (DiscoverySnapshot); return None.

    Assertions require exact built-in output; immutable inputs and external state
    are unchanged.
    """
    core = run_inventory(
        capture_snapshot(bundle),
        timestamp=STAMP,
        author_or_agent=AUTHOR,
        catalog=bundle.catalog,
    )
    assert (
        merge_extension_inventory(
            bundle, timestamp=STAMP, author_or_agent=AUTHOR, manifest_paths=()
        )
        == core
    )


@pytest.mark.parametrize("manifest_only", [False, True])
@pytest.mark.parametrize("blocking", [False, True])
def test_incomplete_external_diagnostics_remain_blocking_data(
    bundle: DiscoverySnapshot, manifest_only: bool, blocking: bool
) -> None:
    """Retain diagnostic state from bundle (DiscoverySnapshot); return None.

    manifest_only/blocking (bool) choose location/severity. Only detached test
    dictionaries change; assertions detect lost blockers or links. No I/O occurs.
    """
    manifest, member = documents(bundle)
    problem = diagnostic(
        "external-incomplete",
        "src/main.cs",
        "Static analysis is incomplete.",
        analyzer="local-example",
        blocking=blocking,
    )
    # A manifest-only failure is valid transport; member failures retain exact file
    # links.
    if manifest_only:
        # A warning alone cannot replace the schema's required result or blocker.
        manifest["result_files"] = [] if blocking else manifest["result_files"]
        manifest["diagnostics"] = [to_plain_value(problem)]
    else:
        member["diagnostics"] = [to_plain_value(problem)]
        set_field(member, ("files", 1, "diagnostic_ids"), [problem["id"]])
    changed = edit_bundle(bundle, manifest, member)
    checked = validate_extension_results(changed)
    assert checked[0].analysis.diagnostics == (problem,)
    merged = merge_extension_inventory(changed, timestamp=STAMP, author_or_agent=AUTHOR)
    assert problem in object_rows(merged.document, "diagnostics")
    assert any(
        item["id"] == problem["id"] and item["blocking"] is blocking
        for item in object_rows(merged.document, "diagnostics")
    )
    assert object_rows(merged.document, "files")[1]["diagnostic_ids"] == (
        problem["id"],
    )


@pytest.mark.parametrize(
    ("field", "value", "code"),
    [
        ("analyzer_id", "repository", "IDENTITY"),
        ("path", "other/source.cs", "SOURCE"),
        ("blocking", False, "ACCOUNTING"),
    ],
)
def test_invalid_diagnostic_ownership_cannot_weaken_core(
    bundle: DiscoverySnapshot,
    field: str,
    value: object,
    code: str,
) -> None:
    """Reject malformed diagnostics in bundle (DiscoverySnapshot); return None.

    field (str), value (object), code (str) select a local mutation and expected
    ExtensionResultError. Assertions detect wrong rejection; no I/O occurs.
    """
    manifest, member = documents(bundle)
    problem = as_object(
        to_plain_value(
            diagnostic("incomplete", None, "Incomplete.", analyzer="local-example")
        )
    )
    problem[field] = value
    manifest["diagnostics"] = [problem]
    with pytest.raises(ExtensionResultError, match="EXTENSION_" + code):
        merge_extension_inventory(
            edit_bundle(bundle, manifest, member),
            timestamp=STAMP,
            author_or_agent=AUTHOR,
        )


def test_core_pin_failure_is_preserved_without_falsely_validating_documentation(
    bundle: DiscoverySnapshot,
) -> None:
    """Retain the missing-docs-pin blocker for bundle (DiscoverySnapshot).

    Returns None; local immutable replacements leave input unchanged. Assertions
    detect lost core diagnostics; no source claim or external effect is created.
    """
    # Documentation still participates in input digest and full file accounting.
    changed = replace(
        bundle,
        repository_files=tuple(
            pin for pin in bundle.repository_files if pin.path != "docs/guide.md"
        ),
    )
    manifest, member = documents(changed)
    manifest["input_manifest_sha256"] = extension_input_digest(
        capture_snapshot(changed)
    )
    changed = edit_bundle(changed, manifest, member)
    result = merge_extension_inventory(changed, timestamp=STAMP, author_or_agent=AUTHOR)
    assert any(
        item["path"] == "docs/guide.md" and item["blocking"] is True
        for item in object_rows(result.document, "diagnostics")
    )


def test_core_component_collision_fails_without_overwriting(
    bundle: DiscoverySnapshot,
) -> None:
    """Reject external/core ID collision for bundle (DiscoverySnapshot).

    Returns None; only detached rows mutate. Expects EXTENSION_COLLISION; assertion
    failure detects replacement of authoritative rows. No I/O occurs.
    """
    core = run_inventory(
        capture_snapshot(bundle),
        timestamp=STAMP,
        author_or_agent=AUTHOR,
        catalog=bundle.catalog,
    )
    identifier = object_rows(core.document, "components")[0]["component_id"]
    manifest, member = documents(bundle)
    set_field(member, ("components", 0, "component_id"), identifier)
    set_field(member, ("findings", 0, "component_id"), identifier)
    set_field(member, ("relationships", 0, "from_component_id"), identifier)
    with pytest.raises(ExtensionResultError, match="EXTENSION_COLLISION"):
        merge_extension_inventory(
            edit_bundle(bundle, manifest, member),
            timestamp=STAMP,
            author_or_agent=AUTHOR,
        )


def test_merge_does_not_trust_public_validation_carriers(
    bundle: DiscoverySnapshot, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject forged proof for bundle (DiscoverySnapshot); return None.

    monkeypatch (pytest.MonkeyPatch) temporarily replaces one public seam. Expects
    EXTENSION_DIGEST from raw reconstruction; assertions detect bypass. No I/O.
    """
    import drm_copilot_discovery.extension_results as module

    proof = validate_extension_results(bundle)

    def forged(*args: object, **kwargs: object) -> tuple[ValidatedExtension, ...]:
        """Return retained tuple[ValidatedExtension, ...] for ignored arguments.

        args/kwargs (object) do not affect the deliberately untrusted proof.
        No input mutation, failure or I/O occurs.
        """
        return proof

    monkeypatch.setattr(module, "validate_extension_results", forged)
    manifest, member = documents(bundle)
    manifest["input_manifest_sha256"] = "f" * 64
    with pytest.raises(ExtensionResultError, match="EXTENSION_DIGEST"):
        module.merge_extension_inventory(
            edit_bundle(bundle, manifest, member),
            timestamp=STAMP,
            author_or_agent=AUTHOR,
        )


@pytest.mark.parametrize("invalid", [None, True, "snapshot"])
def test_untyped_snapshot_is_rejected_before_analysis(invalid: object) -> None:
    """Reject invalid (object) before analysis; return None.

    Expects EXTENSION_SNAPSHOT; assertion failure detects accepted malformed input.
    No source capture, input mutation or I/O occurs.
    """
    with pytest.raises(ExtensionResultError, match="EXTENSION_SNAPSHOT"):
        validate_extension_results(cast("DiscoverySnapshot", invalid))


def test_load_blockers_precede_valid_extension_claims(
    bundle: DiscoverySnapshot,
) -> None:
    """Keep capture failures blocking for bundle (DiscoverySnapshot); return None.

    Expects EXTENSION_SNAPSHOT from a local immutable variant; assertion failure
    detects false success. No input mutation or external effects occur.
    """
    changed = replace(
        bundle,
        findings=(
            Finding(
                code="SNAPSHOT_INPUT",
                message="Missing input.",
                next_action="Recapture.",
            ),
        ),
    )
    with pytest.raises(ExtensionResultError, match="EXTENSION_SNAPSHOT"):
        merge_extension_inventory(changed, timestamp=STAMP, author_or_agent=AUTHOR)


@pytest.mark.parametrize(
    ("field", "value"),
    [
        ("manifest_sha256", "x"),
        ("input_manifest_sha256", "G" * 64),
        ("adapter", None),
        ("result_files", []),
        ("result_files", (None,)),
        ("analysis", None),
    ],
)
def test_carriers_are_immutable_descriptions_with_checked_field_types(
    bundle: DiscoverySnapshot, field: str, value: object
) -> None:
    """Reject malformed carrier fields for bundle (DiscoverySnapshot); return None.

    field (str)/value (object) select a local replacement. Expects EXTENSION_CARRIER;
    assertion failure detects unchecked fields. No input mutation or I/O occurs.
    """
    carrier = validate_extension_results(bundle)[0]
    with pytest.raises(ExtensionResultError, match="EXTENSION_CARRIER"):
        replace(carrier, **{field: value})


@pytest.mark.parametrize(
    "path",
    [
        "../escape",
        "CON",
        "C:/outside",
        "docs/migration/discovery/inventory-other/member.json",
    ],
)
def test_manifest_member_paths_use_portable_containment(
    bundle: DiscoverySnapshot, path: str
) -> None:
    """Reject path (str) against bundle (DiscoverySnapshot); return None.

    Expects EXTENSION_PATH; assertions detect alias/sibling access. Uses immutable
    capture bytes without filesystem access or input mutation.
    """
    with pytest.raises(ExtensionResultError, match="EXTENSION_PATH"):
        ExtensionValidation(bundle).read(path, "inventory-snapshot")


def test_reused_member_paths_and_result_ids_are_rejected(
    bundle: DiscoverySnapshot,
) -> None:
    """Reject reuse in a local context for bundle (DiscoverySnapshot); return None.

    Expects EXTENSION_COLLISION for paths and IDs; assertions detect ambiguous
    retention. Only operation-local counters/sets change; no I/O occurs.
    """
    context = ExtensionValidation(bundle)
    context.read(MEMBER, "inventory-snapshot")
    with pytest.raises(ExtensionResultError, match="EXTENSION_COLLISION"):
        context.read(MEMBER, "inventory-snapshot")
    context.unique("inventory", "same")
    with pytest.raises(ExtensionResultError, match="EXTENSION_COLLISION"):
        context.unique("inventory", "same")


def test_merge_metadata_errors_remain_fixed_and_nonpublishing(
    bundle: DiscoverySnapshot,
) -> None:
    """Reject malformed metadata for bundle (DiscoverySnapshot); return None.

    Expects EXTENSION_MERGE and asserts value redaction; no input mutation or I/O.
    """
    with pytest.raises(ExtensionResultError, match="EXTENSION_MERGE") as failure:
        merge_extension_inventory(
            bundle, timestamp="secret-invalid-time", author_or_agent=AUTHOR
        )
    assert "secret" not in str(failure.value)


def test_unreadable_accounting_requires_a_blocking_diagnostic(
    bundle: DiscoverySnapshot,
) -> None:
    """Require unavailable-input blockers for bundle (DiscoverySnapshot); return None.

    Expects EXTENSION_ACCOUNTING after isolated context changes; assertions detect
    unreported unreadability. No source bytes or external state change.
    """
    context = ExtensionValidation(bundle)
    unavailable = InventoryInput(
        path="src/main.cs", status="unreadable", rationale="Unavailable."
    )
    context.capture = replace(context.capture, inputs=(unavailable,))
    context.input_index = {unavailable.path: unavailable}
    file = row(
        path=unavailable.path,
        status="unreadable",
        sha256=None,
        size=None,
        rationale=unavailable.rationale,
        diagnostic_ids=(),
    )
    document = row(files=(file,), exclusions=context.capture.exclusions)
    with pytest.raises(ExtensionResultError, match="EXTENSION_ACCOUNTING"):
        context.accounting(document, ())


@pytest.mark.parametrize("field", ["timestamp", "author"])
def test_metadata_budget_precedes_builtin_emission(
    bundle: DiscoverySnapshot, field: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject oversized field (str) for bundle (DiscoverySnapshot); return None.

    monkeypatch (pytest.MonkeyPatch) temporarily installs bounded local seams.
    Expects EXTENSION_LIMIT before core calls; assertions detect ordering failure.
    Only local state changes; no I/O occurs.
    """
    import drm_copilot_discovery.extension_results as module

    context = ExtensionValidation(bundle)
    context.limits = ProfileLimits(document_bytes=64)

    def bounded_context(snapshot: DiscoverySnapshot) -> ExtensionValidation:
        """Return ExtensionValidation for snapshot (DiscoverySnapshot), without I/O.

        Asserts the expected immutable input; returns prepared local state unchanged.
        """
        assert snapshot is bundle
        return context

    def forbidden(*args: object, **kwargs: object) -> None:
        """Reject ignored object args/kwargs with AssertionError; never return None.

        Detects forbidden core emission in this isolated test; no I/O or mutation.
        """
        raise AssertionError("metadata must fail before core emission")

    monkeypatch.setattr(module, "ExtensionValidation", bounded_context)
    monkeypatch.setattr(module, "run_inventory", forbidden)
    # Independently exercise a large timestamp and a large structured author value.
    timestamp = "é" * 40 if field == "timestamp" else STAMP
    author = row(kind="agent", id="é" * 40) if field == "author" else AUTHOR
    with pytest.raises(ExtensionResultError, match="EXTENSION_LIMIT"):
        module.merge_extension_inventory(
            bundle, timestamp=timestamp, author_or_agent=author
        )
