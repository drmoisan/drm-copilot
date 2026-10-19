"""Verify public dispatch composition without repeating individual detector suites."""

from __future__ import annotations

import builtins
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import __version__
from drm_copilot_discovery.analyzer import (
    Analyzer,
    builtin_analyzer_identities,
    select_analyzers,
)
from drm_copilot_discovery.analyzer import registry as implementation
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
from drm_copilot_discovery.analyzer.pipeline import Analyzer as LegacyAnalyzer
from drm_copilot_discovery.analyzer.pipeline import run_inventory
from drm_copilot_discovery.analyzer.registry import InventoryAdapter
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.profile_v2 import ProfileError
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from types import ModuleType

    from drm_copilot_discovery.catalog import SchemaCatalog

IMPLEMENTATIONS = {
    "repository": ("inventory", "RepositoryAnalyzer"),
    "dotnet": ("dotnet_projects", "DotnetProjectAnalyzer"),
    "csharp-symbols": ("dotnet_inventory", "CSharpDeclarationAnalyzer"),
    "event-subscriptions": ("dotnet_inventory", "EventSubscriptionAnalyzer"),
    "configuration": ("configuration", "ConfigurationAnalyzer"),
    "filesystem-access": ("filesystem_access", "FilesystemAccessAnalyzer"),
    "registry-access": ("registry_access", "RegistryAccessAnalyzer"),
    "com-interop": ("com_interop", "ComInteropAnalyzer"),
    "ui-callbacks": ("ui_callbacks", "UiCallbackAnalyzer"),
    "test-references": ("test_references", "TestReferenceAnalyzer"),
    "dependencies": ("dependencies", "DependencyAnalyzer"),
    "office-vsto": ("optional.vsto_office", "VstoOfficeAnalyzer"),
}


def selection(enabled: tuple[str, ...]) -> dict[str, object]:
    """Return bounded analyzer configuration from tuple[str, ...] enabled IDs.

    Returns dict[str, object]; validation belongs to inventory_profile. No I/O,
    shared-state mutation or expected exceptions occur.
    """
    return {
        "enabled": list(enabled),
        "options": {},
        "ignored_paths": [],
        "extension_result_manifests": [],
    }


def combined_capture(
    catalog: SchemaCatalog, *, optional: bool = False
) -> InventoryCapture:
    """Build one synthetic cross-adapter capture with independent pinned objects.

    catalog (SchemaCatalog) validates the profile; optional (bool) adds explicit
    consent. Returns InventoryCapture; configuration/value failures propagate.
    All source bytes and Git objects are memory values; no I/O occurs.
    """
    # Explicit consent changes only fixed selectors, never source-derived activation.
    enabled = tuple(
        sorted(key for key in IMPLEMENTATIONS if optional or key != "office-vsto")
    )
    profile = inventory_profile(
        catalog, test_roots=["tests"], analyzers=selection(enabled)
    )
    payloads = (
        (
            "src/view.cs",
            b"""namespace Demo;
partial class View {
 event System.Action Changed;
 void OnClick(object sender) {
 Changed += Handler;
 System.IO.File.ReadAllText("VALUE_SENTINEL");
 Microsoft.Win32.Registry.GetValue("VALUE_SENTINEL", "key", null);
 System.Runtime.InteropServices.Marshal.ReleaseComObject(value);
 }
 void Handler() {}
}
class Widget {}""",
        ),
        (
            "src/app.csproj",
            b'<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup>'
            b"<TargetFramework>net8.0</TargetFramework></PropertyGroup><ItemGroup>"
            b'<COMReference Include="Interop"/>'
            b'<PackageReference Include="Example" Version="1.2.3"/>'
            b"</ItemGroup></Project>",
        ),
        (
            "src/view.xaml",
            b"<Window "
            b'xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" '
            b'xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" '
            b'x:Class="Demo.View">'
            b'<Button Click="OnClick"/></Window>',
        ),
        ("src/appsettings.json", b'{"logging":{"enabled":true}}'),
        ("src/requirements.txt", b"example==1.2.3\n"),
        (
            "tests/widget.cs",
            b"class Checks { [Fact] void Check() { var item = new Widget(); } }",
        ),
        (
            "src/ribbon.xml",
            b'<customUI xmlns="http://schemas.microsoft.com/office/2009/07/customui">'
            b'<ribbon><tabs><tab id="tab"><group id="group">'
            b'<button id="button" onAction="OnClick"/>'
            b"</group></tab></tabs></ribbon></customUI>",
        ),
    )
    # Keep selected roles and original bytes independent of the retained Git copies.
    files = tuple(
        SnapshotFile(
            path=path,
            content=content,
            category="test" if path.startswith("tests/") else "source",
        )
        for path, content in payloads
    )
    identity = RepositoryIdentity(
        id=profile.repository.id, revision=profile.repository.revision
    )
    # Construct separate immutable objects so pins cannot be inferred from status.
    return InventoryCapture(
        profile=profile,
        inputs=tuple(
            InventoryInput(path=file.path, status="inspected", file=file)
            for file in files
        ),
        repository_files=tuple(
            RepositoryFile(repository=identity, path=file.path, content=file.content)
            for file in files
        ),
    )


def rows(document: JsonObject, key: str) -> tuple[JsonObject, ...]:
    """Project a validated JsonObject row family named by str key; return tuple.

    Missing keys raise KeyError. No mutation, coercion or external access occurs.
    """
    return cast("tuple[JsonObject, ...]", document[key])


def test_public_metadata_is_complete_fresh_and_import_free(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Prove pure reserved metadata and protocol identity using MonkeyPatch.

    Returns None; assertions expose imports, mutable reuse or metadata drift.
    Patches are scoped to the call; no filesystem or process is used.
    """

    def forbidden(*args: object, **kwargs: object) -> ModuleType:
        """Reject import args/kwargs with AssertionError; no return or I/O."""
        del args, kwargs
        raise AssertionError("Metadata must not import implementations")

    with monkeypatch.context() as context:
        context.setattr(builtins, "__import__", forbidden)
        first, second = builtin_analyzer_identities(), builtin_analyzer_identities()
    # Metadata is independently consumable without constructing any adapter.
    assert Analyzer is InventoryAdapter and Analyzer is not LegacyAnalyzer
    assert first == second and first is not second
    assert [item["id"] for item in first] == sorted(IMPLEMENTATIONS)
    assert all(
        set(item) == {"id", "version"} and item["version"] == __version__
        for item in first
    )
    assert all(left is not right for left, right in zip(first, second, strict=True))


@pytest.mark.parametrize("identifier", sorted(IMPLEMENTATIONS))
def test_each_fixed_selector_resolves_its_public_class(
    analyzer_catalog: SchemaCatalog, identifier: str
) -> None:
    """Resolve str identifier through validated SchemaCatalog-backed configuration.

    Returns None; assertions expose wrong class/ID or duplicate selection. Imports
    only the explicitly selected implementation; no source access occurs.
    """
    selected = select_analyzers(
        inventory_profile(analyzer_catalog, analyzers=selection((identifier,)))
    )
    module, name = IMPLEMENTATIONS[identifier]
    # A selector never falls back to a different available implementation.
    assert len(selected) == 1 and selected[0].identifier == identifier
    assert type(selected[0]).__module__ == "drm_copilot_discovery.analyzer." + module
    assert type(selected[0]).__name__ == name


@pytest.mark.parametrize("extra", ["unknown", "module.path", "python -c command"])
def test_invalid_complete_selection_never_imports_optional(
    analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, extra: str
) -> None:
    """Reject unregistered/executable str extra before consented optional import.

    SchemaCatalog and MonkeyPatch isolate profile validation/import observation.
    Returns None; missing rejection/import isolation raises AssertionError. No I/O.
    """
    original = builtins.__import__

    def observe(
        name: str,
        globals: dict[str, object] | None = None,
        locals: dict[str, object] | None = None,
        fromlist: tuple[str, ...] = (),
        level: int = 0,
    ) -> ModuleType:
        """Forward typed import parameters, rejecting optional names; return module.

        AssertionError flags premature loading; original import failures propagate.
        Only ordinary module imports occur; patches are restored by the fixture.
        """
        assert ".analyzer.optional" not in name
        return original(name, globals, locals, fromlist, level)

    monkeypatch.setattr(builtins, "__import__", observe)
    with pytest.raises(ProfileError):
        select_analyzers(
            inventory_profile(
                analyzer_catalog, analyzers=selection(("office-vsto", extra))
            )
        )


def test_registry_checks_complete_metadata_before_optional_loading(
    analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject metadata/dispatch mismatch before importing a valid optional member.

    SchemaCatalog builds a valid selection; MonkeyPatch simulates an unavailable
    registered implementation. Returns None; missed rejection/imports assert.
    Changes are test-local and restored; no source or filesystem mutation occurs.
    """
    profile = inventory_profile(
        analyzer_catalog, analyzers=selection(("office-vsto", "dotnet"))
    )
    # Simulate a runtime catalog lacking one schema-supported implementation.
    supported = tuple(
        item for item in builtin_analyzer_identities() if item["id"] != "dotnet"
    )

    def identities() -> tuple[JsonObject, ...]:
        """Return the test-local immutable catalog; no parameters, errors or I/O."""
        return supported

    original = builtins.__import__

    def observe(
        name: str,
        globals: dict[str, object] | None = None,
        locals: dict[str, object] | None = None,
        fromlist: tuple[str, ...] = (),
        level: int = 0,
    ) -> ModuleType:
        """Forward typed import arguments while rejecting optional implementation.

        Returns ModuleType or propagates import failures; AssertionError denotes
        premature optional loading. The scoped patch is restored before reporting.
        """
        assert ".analyzer.optional" not in name
        return original(name, globals, locals, fromlist, level)

    with monkeypatch.context() as context:
        context.setattr(implementation, "builtin_analyzer_identities", identities)
        context.setattr(builtins, "__import__", observe)
        with pytest.raises(ValueError, match="Unavailable analyzer.*dotnet"):
            select_analyzers(profile)


@pytest.mark.parametrize("optional", [False, True])
def test_combined_dispatch_preserves_accounting_identity_and_provenance(
    analyzer_catalog: SchemaCatalog, optional: bool
) -> None:
    """Compose accepted adapters over one capture with optional bool consent.

    SchemaCatalog validates aggregate output. Returns None; failed coordination,
    provenance or determinism assertions raise. All bytes/objects are in memory.
    """
    capture = combined_capture(analyzer_catalog, optional=optional)
    author = row(id="tester", kind="agent")
    result = run_inventory(
        capture,
        timestamp="2026-01-01T00:00:00Z",
        author_or_agent=author,
        catalog=analyzer_catalog,
    )
    reordered = replace(
        capture,
        inputs=tuple(reversed(capture.inputs)),
        repository_files=tuple(reversed(capture.repository_files)),
        profile=inventory_profile(
            analyzer_catalog,
            test_roots=["tests"],
            analyzers=selection(tuple(reversed(capture.profile.analyzers.enabled))),
        ),
    )
    repeated = run_inventory(
        reordered,
        timestamp="2026-01-01T00:00:00Z",
        author_or_agent=author,
        catalog=analyzer_catalog,
        dry_run=True,
    )
    # Output order and source identities survive independent input permutations.
    assert result == repeated
    assert canonical_json(result.document) == canonical_json(repeated.document)
    assert {item["id"] for item in rows(result.document, "analyzers")} == set(
        capture.profile.analyzers.enabled
    )
    assert [item["path"] for item in rows(result.document, "files")] == [
        item.path for item in capture.inputs
    ]
    contributions: set[str] = set()
    # Verify each row family independently while retaining every producing adapter.
    for family, key in (
        ("components", "component_id"),
        ("findings", "finding_id"),
        ("relationships", "relationship_id"),
    ):
        entries = rows(result.document, family)
        assert len({item[key] for item in entries}) == len(entries)
        # Every producer must bind the same captured bytes and configured source pin.
        for item in entries:
            contributions.add(str(cast("JsonObject", item["analyzer"])["id"]))
            source = cast("JsonObject", item["source"])
            assert source["repository"] == capture.profile.repository.id
            assert source["revision"] == capture.profile.repository.revision
            assert source["sha256"] == next(
                value.sha256 for value in capture.inputs if value.path == source["path"]
            )
    assert contributions == set(capture.profile.analyzers.enabled)
    # Inventory findings remain inspection proposals and unresolved syntax claims.
    assert all(
        item["inspection_status"] == "uninspected" for item in result.ledger_components
    )
    assert any(
        item["classification"] == "inferred"
        for item in rows(result.document, "findings")
    )
    assert any(
        item["to_component_id"] is None
        for item in rows(result.document, "relationships")
    )
    assert b"VALUE_SENTINEL" not in canonical_json(result.document)


def test_combined_unavailable_inputs_preserve_blockers(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Keep unavailable/excluded/unpinned rows truthful under combined dispatch.

    SchemaCatalog supplies validation. Returns None; assertions expose accounting
    loss or duplicate diagnostics. No files, processes or network are accessed.
    """
    capture = combined_capture(analyzer_catalog)
    capture = replace(
        capture,
        repository_files=(),
        inputs=capture.inputs
        + (
            InventoryInput(
                path="src/missing.cs", status="unreadable", rationale="Unavailable."
            ),
            InventoryInput(
                path="src/ignored.cs", status="excluded", rationale="Excluded."
            ),
        ),
    )
    result = run_inventory(
        capture,
        timestamp="2026-01-01T00:00:00Z",
        author_or_agent=row(id="tester", kind="agent"),
        catalog=analyzer_catalog,
    )
    # Aggregation cannot erase failed reads, exclusions or absent Git provenance.
    files = {str(item["path"]): item for item in rows(result.document, "files")}
    assert files["src/missing.cs"]["status"] == "unreadable"
    assert files["src/ignored.cs"]["status"] == "excluded"
    assert files["src/missing.cs"]["sha256"] is None
    diagnostics = rows(result.document, "diagnostics")
    assert any(item["blocking"] for item in diagnostics)
    assert len({item["id"] for item in diagnostics}) == len(diagnostics)
    assert all(
        item["inspection_status"] == "uninspected" for item in result.ledger_components
    )
