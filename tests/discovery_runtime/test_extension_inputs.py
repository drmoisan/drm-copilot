"""Verify exact analyzer projection identity and bounded, output-independent hashing."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING, Literal, cast

import pytest
from drm_copilot_discovery import extension_inputs as subject
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import inventory_profile
from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import InputCategory


def capture_case(catalog: SchemaCatalog, **changes: object) -> InventoryCapture:
    """Create three immutable role inputs with exact independent local pin bytes.

    catalog (SchemaCatalog) supplies trusted schemas; changes (object keywords)
    override profile fields. Returns InventoryCapture; validation errors propagate.
    Reads only installed test resources and changes no source or external state.
    """
    profile = inventory_profile(catalog, test_roots=["tests"], **changes)
    # Distinct categories demonstrate that documentation remains a digest input.
    files = (
        SnapshotFile(
            path="src/main.cs", category="source", content=b"class Main {}\r\n"
        ),
        SnapshotFile(path="tests/main.cs", category="test", content=b"new Main();"),
        SnapshotFile(path="docs/guide.md", category="documentation", content=b"Guide."),
    )
    identity = RepositoryIdentity(
        id=profile.repository.id, revision=profile.repository.revision
    )
    return InventoryCapture(
        profile=profile,
        # Retain each immutable source once, with its original role and content.
        inputs=tuple(
            InventoryInput(path=file.path, status="inspected", file=file)
            for file in files
        ),
        # Model independent exact Git objects without accessing a repository.
        repository_files=tuple(
            RepositoryFile(repository=identity, path=file.path, content=file.content)
            for file in files
        ),
    )


def test_projection_retains_exact_roles_statuses_and_pins(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Return truthful selected metadata with no fabricated checkout or raw bytes.

    analyzer_catalog (SchemaCatalog) supplies schemas. Returns None; assertion
    failures expose contract deviations. Only synthetic immutable memory is used.
    """
    capture = capture_case(analyzer_catalog)
    value = subject.extension_input_projection(capture)
    inputs = cast("tuple[JsonObject, ...]", value["inputs"])
    pins = cast("tuple[JsonObject, ...]", value["repository_files"])
    # All three configured roles remain observable in canonical path order.
    assert tuple(item["category"] for item in inputs) == (
        "documentation",
        "source",
        "test",
    )
    # Retained local objects align exactly with the selected input path set.
    assert tuple(item["path"] for item in pins) == tuple(
        item["path"] for item in inputs
    )
    assert inputs[1]["sha256"] == hashlib.sha256(b"class Main {}\r\n").hexdigest()
    assert inputs[1]["size"] == 15 and inputs[1]["entry_point"] is False
    assert value["profile"] is capture.profile.document
    assert value["target_repositories"] == ()
    assert "checkout" not in value and "missing_paths" not in value
    assert b"class Main" not in canonical_json(value)
    assert (
        subject.extension_input_digest(capture)
        == hashlib.sha256(canonical_json(value)).hexdigest()
    )
    assert (
        subject.extension_input_projection(
            replace(capture, repository_files=capture.repository_files[::-1])
        )
        == value
    )


@pytest.mark.parametrize("status", ["excluded", "unreadable"])
def test_unavailable_inputs_retain_rationale_without_fabricated_bytes(
    analyzer_catalog: SchemaCatalog, status: str
) -> None:
    """Keep unavailable inputs visible while ignoring their unselected Git objects.

    analyzer_catalog (SchemaCatalog) and status (str) select the case. Returns None;
    raises AssertionError on a contract failure. No filesystem activity occurs.
    """
    capture = capture_case(analyzer_catalog)
    unavailable = InventoryInput(
        path="src/main.cs",
        status=cast("Literal['excluded', 'unreadable']", status),
        rationale="Explicit unavailable input.",
    )
    # Replace only the selected input, preserving the other captured evidence.
    changed = replace(
        capture,
        inputs=tuple(
            unavailable if item.path == unavailable.path else item
            for item in capture.inputs
        ),
    )
    value = subject.extension_input_projection(changed)
    item = cast("tuple[JsonObject, ...]", value["inputs"])[1]
    assert item["status"] == status and item["sha256"] is None and item["size"] is None
    assert item["rationale"] == "Explicit unavailable input."
    assert len(cast("tuple[JsonObject, ...]", value["repository_files"])) == 2


@pytest.mark.parametrize("kind", ["reports", "inventory", "acceptance", "evidence"])
def test_generated_output_insertion_does_not_change_input_identity(
    analyzer_catalog: SchemaCatalog, kind: str
) -> None:
    """Filter configured outputs before row retention and any additional hashing.

    analyzer_catalog (SchemaCatalog) and kind (str) select an output directory.
    Returns None; assertions fail on changed identity. Uses only memory values.
    """
    capture = capture_case(analyzer_catalog)
    root = cast("str", capture.profile.artifacts.data[kind])
    output = InventoryInput(
        path=root + "/generated.json",
        status="inspected",
        file=SnapshotFile(
            path=root + "/generated.json",
            category="documentation",
            content=b"generated",
        ),
    )
    modified = replace(capture, inputs=capture.inputs + (output,))
    assert subject.extension_input_digest(modified) == subject.extension_input_digest(
        capture
    )


def test_manifest_filter_requires_the_configured_inventory_root(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Reject source-hiding manifest configuration before exclusion can occur.

    analyzer_catalog (SchemaCatalog) supplies schemas. Returns None; raises
    AssertionError if an out-of-root declaration is accepted. No I/O occurs.
    """
    analyzers: dict[str, object] = {
        "enabled": ["repository"],
        "options": {},
        "ignored_paths": [],
        "extension_result_manifests": ["src/main.cs"],
    }
    capture = capture_case(analyzer_catalog, analyzers=analyzers)
    with pytest.raises(ValueError, match="inside artifacts.inventory"):
        subject.extension_input_projection(capture)
    analyzers["extension_result_manifests"] = [
        capture.profile.artifacts["inventory"] + "/external.json"
    ]
    valid = capture_case(analyzer_catalog, analyzers=analyzers)
    assert subject.extension_input_projection(valid)["inputs"]


@pytest.mark.parametrize("output", ["src", "src/generated", "tests", "src/main.cs"])
def test_output_source_overlap_fails_instead_of_hiding_inputs(
    analyzer_catalog: SchemaCatalog, output: str
) -> None:
    """Block invalid profile layouts even when schema construction alone succeeds.

    analyzer_catalog (SchemaCatalog), output (str) choose a source overlap.
    Returns None; assertions enforce rejection without filesystem metadata.
    """
    artifacts = as_object(profile_document()["artifacts"])
    artifacts["inventory"] = output
    with pytest.raises(ValueError, match="overlap"):
        subject.extension_input_projection(
            capture_case(analyzer_catalog, artifacts=artifacts)
        )


@pytest.mark.parametrize(
    "path,category", [("outside/a.cs", "source"), ("src/a.cs", "test")]
)
def test_unconfigured_or_misclassified_inputs_fail_closed(
    analyzer_catalog: SchemaCatalog, path: str, category: str
) -> None:
    """Reject manufactured scope/category metadata instead of hashing a false claim.

    analyzer_catalog (SchemaCatalog), path/category (str) choose invalid metadata.
    Returns None; raises AssertionError on acceptance. Uses immutable memory only.
    """
    capture = capture_case(analyzer_catalog)
    file = SnapshotFile(
        path=path, content=b"x", category=cast("InputCategory", category)
    )
    capture = replace(
        capture, inputs=(InventoryInput(path=path, status="inspected", file=file),)
    )
    with pytest.raises(ValueError, match="configured source category"):
        subject.extension_input_projection(capture)


def test_exact_entrypoints_override_test_roots_without_prefix_scope(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Treat a configured exact project entrypoint as source, preserving sibling tests.

    analyzer_catalog (SchemaCatalog) supplies schemas. Returns None; assertions
    validate precedence and boundary matching. No files are read or created.
    """
    capture = capture_case(
        analyzer_catalog, project_entry_points=["tests/project.csproj"]
    )
    file = SnapshotFile(
        path="tests/project.csproj", content=b"<Project/>", category="source"
    )
    capture = replace(
        capture,
        inputs=capture.inputs
        + (InventoryInput(path=file.path, status="inspected", file=file),),
    )
    inputs = cast(
        "tuple[JsonObject, ...]", subject.extension_input_projection(capture)["inputs"]
    )
    assert inputs[-1]["category"] == "source" and inputs[-1]["entry_point"] is True
    assert inputs[-2]["category"] == "test" and inputs[-2]["entry_point"] is False


@pytest.mark.parametrize(
    "change", ["source", "document", "pin", "absence", "exclusion", "profile"]
)
def test_each_selected_input_dimension_changes_digest(
    analyzer_catalog: SchemaCatalog, change: str
) -> None:
    """Bind source/docs/pin/exclusion/profile state while retaining authored arrays.

    analyzer_catalog (SchemaCatalog), change (str) choose one semantic change.
    Returns None; assertions fail if a relevant change is omitted. Memory only.
    """
    original = capture_case(analyzer_catalog)
    modified = original
    # Isolate one identity dimension so each failure identifies the omitted field.
    if change in ("source", "document"):
        index = 1 if change == "source" else 0
        previous = original.inputs[index]
        assert previous.file is not None
        replacement = replace(previous, file=replace(previous.file, content=b"changed"))
        modified = replace(
            original,
            inputs=original.inputs[:index]
            + (replacement,)
            + original.inputs[index + 1 :],
        )
    elif change == "pin":
        modified = replace(
            original,
            repository_files=(
                replace(original.repository_files[0], content=b"different pin"),
            )
            + original.repository_files[1:],
        )
    elif change == "absence":
        modified = replace(original, repository_files=())
    elif change == "exclusion":
        modified = replace(
            original,
            exclusions=(row(path_or_glob="src/omitted", rationale="Root exclusion."),),
        )
    else:
        modified = replace(
            original,
            profile=inventory_profile(
                analyzer_catalog,
                test_roots=["tests"],
                required_feature_dimensions=["observable_outputs", "trigger"],
            ),
        )
    assert subject.extension_input_digest(modified) != subject.extension_input_digest(
        original
    )


@pytest.mark.parametrize("failure", ["duplicate", "revision", "type"])
def test_malformed_local_pins_are_not_silently_discarded(
    analyzer_catalog: SchemaCatalog, failure: str
) -> None:
    """Reject duplicate/conflicting selected pins and invalid public carrier rows.

    analyzer_catalog (SchemaCatalog), failure (str) choose the malformed carrier.
    Returns None; assertion failures expose acceptance. All values are synthetic.
    """
    capture = capture_case(analyzer_catalog)
    pins = capture.repository_files
    # Preserve the captured source while changing only immutable-object metadata.
    if failure == "duplicate":
        pins += pins[:1]
    elif failure == "revision":
        pins = (
            replace(pins[0], repository=replace(pins[0].repository, revision="b" * 40)),
        )
    else:
        pins = cast("tuple[RepositoryFile, ...]", ("invalid",))
    with pytest.raises(ValueError, match="Extension"):
        subject.extension_input_projection(replace(capture, repository_files=pins))


def test_unrelated_foreign_and_generated_pins_do_not_enter_projection(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Retain only selected local objects and preserve missing local-pin absence.

    analyzer_catalog (SchemaCatalog) supplies schemas. Returns None; assertions
    require stable selected identity. No foreign checkout or filesystem is read.
    """
    capture = capture_case(analyzer_catalog)
    extra = replace(
        capture.repository_files[0],
        repository=RepositoryIdentity(id="foreign", revision="b" * 40),
    )
    output = replace(
        capture.repository_files[0],
        path=capture.profile.artifacts["reports"] + "/report.md",
    )
    assert subject.extension_input_digest(
        replace(capture, repository_files=capture.repository_files + (extra, output))
    ) == subject.extension_input_digest(capture)


def test_manifest_hash_excludes_only_root_checksum_and_preserves_authored_arrays() -> (
    None
):
    """Hash all non-root-checksum fields, including nested checksums and array order.

    Takes no arguments; returns None. Assertion failures expose identity changes;
    only immutable memory values and the standard canonical serializer are used.
    """
    value = row(
        manifest_sha256="ignored", nested=row(manifest_sha256="bound"), order=("b", "a")
    )
    expected = row(nested=row(manifest_sha256="bound"), order=("b", "a"))
    digest = subject.extension_manifest_digest(value)
    assert digest == hashlib.sha256(canonical_json(expected)).hexdigest()
    assert digest == subject.extension_manifest_digest(
        row(manifest_sha256="replacement", **dict(expected))
    )
    assert digest != subject.extension_manifest_digest(
        row(nested=row(manifest_sha256="changed"), order=("b", "a"))
    )
    assert digest != subject.extension_manifest_digest(
        row(nested=row(manifest_sha256="bound"), order=("a", "b"))
    )


@pytest.mark.parametrize("conflict", [False, True])
def test_repository_roles_retain_pins_and_reject_conflicting_local_identity(
    analyzer_catalog: SchemaCatalog, conflict: bool
) -> None:
    """Retain sorted role pins while rejecting a second revision for the local ID.

    analyzer_catalog (SchemaCatalog), conflict (bool) choose valid or conflicting
    related metadata. Returns None; assertions enforce immutable role identity.
    """
    initial = capture_case(analyzer_catalog)
    related: list[dict[str, object]] = [
        {
            "id": initial.profile.repository.id if conflict else "related-target",
            "role": "modernization-target",
            "revision": "b" * 40,
            "snapshot_manifest": None,
            "clients": [],
        }
    ]
    capture = capture_case(analyzer_catalog, repositories=related)
    if conflict:
        with pytest.raises(ValueError, match="conflicting identities"):
            subject.extension_input_projection(capture)
    else:
        value = subject.extension_input_projection(capture)
        assert value["target_repositories"] == (
            row(id="related-target", revision="b" * 40),
        )
