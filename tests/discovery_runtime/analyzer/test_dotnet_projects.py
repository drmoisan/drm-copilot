"""Verify literal .NET declarations, exact provenance and unresolved build semantics."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.dotnet_projects import DotnetProjectAnalyzer
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
from drm_copilot_discovery.analyzer.models import (
    Analysis,
    InventoryCapture,
    InventoryInput,
)
from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject

FIXTURES = Path(__file__).parents[2] / "fixtures/discovery_analyzers/dotnet"


@pytest.fixture(scope="module")
def catalog() -> SchemaCatalog:
    """Load immutable checked-in schemas once; return SchemaCatalog or loader error.

    Takes no arguments. Reads only the installed versioned schema resources.
    """
    return load_catalog()


def capture(
    catalog: SchemaCatalog,
    payloads: tuple[tuple[str, bytes], ...],
    *,
    pinned: bool = True,
    records: int = 100000,
    max_bytes: int = 16777216,
) -> InventoryCapture:
    """Construct isolated captured source and exact optional Git provenance.

    catalog (SchemaCatalog), payloads (path/bytes tuples), pinned (bool), records/
    max_bytes (int) describe synthetic inputs. Returns InventoryCapture; invalid
    configuration raises ProfileError/ValueError. No I/O or shared state mutation.
    """
    profile = inventory_profile(
        catalog,
        limits={"artifact_records": records},
        analyzers={
            "enabled": ["repository", "dotnet"],
            "options": {"max_file_bytes": max_bytes},
            "ignored_paths": [],
            "extension_result_manifests": [],
        },
    )
    identity = RepositoryIdentity(
        id=profile.repository.id, revision=profile.repository.revision
    )
    # Build exact immutable byte inputs independently from their Git provenance.
    files = tuple(
        SnapshotFile(path=path, content=content, category="source")
        for path, content in payloads
    )
    # Optional pins model absence explicitly instead of reusing working-copy claims.
    return InventoryCapture(
        profile=profile,
        inputs=tuple(
            InventoryInput(path=file.path, status="inspected", file=file)
            for file in files
        ),
        repository_files=(
            tuple(
                RepositoryFile(
                    repository=identity, path=file.path, content=file.content
                )
                for file in files
            )
            if pinned
            else ()
        ),
    )


def properties(finding: JsonObject) -> dict[str, object]:
    """Return readable scalar properties from finding (JsonObject), without I/O.

    Returns dict[str,object]; malformed internal rows raise KeyError/TypeError.
    """
    # Project scalar declarations only; structured context remains separate.
    return {
        cast("str", item["name"]): item["value"]
        for item in cast("tuple[JsonObject, ...]", finding["properties"])
    }


def findings(analysis: Analysis, kind: str) -> tuple[JsonObject, ...]:
    """Select analysis (Analysis) findings of kind (str); return tuple, without I/O."""
    # Tests select semantic finding families without depending on unrelated rows.
    return tuple(item for item in analysis.findings if item["kind"] == kind)


@pytest.mark.parametrize(
    "name,kind",
    [
        ("Application.csproj", "implicit-sdk"),
        ("Legacy.vbproj", "target-framework-version"),
        ("Directory.Build.props", "package-reference"),
        ("Directory.Build.targets", "import"),
        ("Workspace.slnx", "solution-project"),
        ("Workspace.sln", "solution-entry"),
    ],
)
def test_synthetic_fixtures_emit_valid_composed_inventory(
    catalog: SchemaCatalog, name: str, kind: str
) -> None:
    """Given catalog/name/kind, preserve literal fixtures in schema-valid inventory.

    catalog (SchemaCatalog), name/kind (str) select static fixture expectations.
    Returns None; asserts exact hashes, anchors, unresolved targets and honest seeds.
    Reads only immutable checked-in fixtures; analyzers themselves perform no I/O.
    """
    content = (FIXTURES / name).read_bytes()
    inputs = capture(catalog, (("src/" + name, content),))
    analysis = DotnetProjectAnalyzer().analyze(inputs)
    result = inventory_result(
        inputs,
        (RepositoryAnalyzer().analyze(inputs), analysis),
        analyzer_ids=("repository", "dotnet"),
        timestamp="2026-10-19T03:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=catalog,
    )
    assert findings(analysis, kind), f"Expected {kind} in {name}"
    assert len(analysis.components) == 1
    # Valid literal fixtures may warn about evaluation but must not block discovery.
    assert not any(item["blocking"] for item in analysis.diagnostics)
    # All syntax observations retain strong provenance without claiming activation.
    assert all(
        item["classification"] == "detected" and item["confidence"] == "high"
        for item in analysis.findings
    )
    # A known source does not resolve the referenced dependency graph.
    assert all(item["to_component_id"] is None for item in analysis.relationships)
    # Detection remains distinct from feature inspection and authored disposition.
    assert all(
        item["inspection_status"] == "uninspected"
        and item["disposition"] == "unassigned"
        for item in result.ledger_components
    )
    # Every declaration must identify its actual immutable source and anchor.
    for finding in analysis.findings:
        source = cast("JsonObject", finding["source"])
        anchor = cast("JsonObject", source["line_range"])
        assert source["sha256"] == hashlib.sha256(content).hexdigest()
        assert source["revision"] == inputs.profile.repository.revision
        assert 1 <= cast("int", anchor["start"]) <= len(content.splitlines())
        assert anchor["start"] == anchor["end"]


def test_project_reference_operations_conditions_and_metadata_are_literal(
    catalog: SchemaCatalog,
) -> None:
    """For catalog (SchemaCatalog), distinguish declarations from active dependencies.

    Returns None; assertions require literal conditions, operations and metadata.
    Reads only the immutable synthetic fixture; no target/import path is followed.
    """
    content = (FIXTURES / "Application.csproj").read_bytes()
    analysis = DotnetProjectAnalyzer().analyze(
        capture(catalog, (("src/app.csproj", content),))
    )
    references = findings(analysis, "project-reference")
    # Inclusion and removal remain separate declared operations.
    assert [properties(item) for item in references] == [
        {"include": "../Peer/Peer.csproj"},
        {"remove": "**/*.csproj"},
    ]
    extension = cast(
        "JsonObject", cast("JsonObject", references[0]["extensions"])["drm.dotnet"]
    )
    context = cast("tuple[JsonObject, ...]", extension["context"])
    # Preserve ancestor and local conditions without evaluating either expression.
    assert [item.get("condition") for item in context] == [
        None,
        "'$(TargetFramework)' != ''",
        "Exists('ignored')",
        None,
    ]
    assert properties(findings(analysis, "target-frameworks")[0]) == {
        "value": "net8.0;net9.0"
    }
    com = cast(
        "JsonObject",
        cast("JsonObject", findings(analysis, "com-reference")[0]["extensions"])[
            "drm.dotnet"
        ],
    )
    metadata = cast("tuple[JsonObject, ...]", com["context"])[-1]["metadata"]
    # COM wrapper metadata remains literal build information only.
    assert any(
        item["element"] == "WrapperTool" and item["text"] == "tlbimp"
        for item in cast("tuple[JsonObject, ...]", metadata)
    )
    # Relationship context must preserve the operation behind its unresolved target.
    removal = next(
        item
        for item in analysis.relationships
        if item["target_description"] == "**/*.csproj"
    )
    assert (
        cast("JsonObject", cast("JsonObject", removal["extensions"])["drm.dotnet"])[
            "declaration"
        ]
        == references[1]["properties"]
    )
    assert "$(CustomTargets)" in {
        item["target_description"] for item in analysis.relationships
    }


def test_branches_and_deferred_targets_remain_in_context(
    catalog: SchemaCatalog,
) -> None:
    """For catalog (SchemaCatalog), retain Choose/Otherwise/Target placement.

    Returns None; assertions reject unconditional activation claims. Static fixture
    reads only; no MSBuild process or interpretation is used.
    """
    # Exercise both conditional branches and deferred target placement.
    for filename, marker in (
        ("Directory.Build.props", "Otherwise"),
        ("Directory.Build.targets", "Deferred"),
    ):
        analysis = DotnetProjectAnalyzer().analyze(
            capture(catalog, (("src/" + filename, (FIXTURES / filename).read_bytes()),))
        )
        assert marker in str(analysis.findings)
        # No declaration can silently become an evaluated dependency.
        assert all(
            "not-performed" in str(item["extensions"]) for item in analysis.findings
        )


@pytest.mark.parametrize(
    "suffix",
    [
        ".csproj",
        ".fsproj",
        ".vbproj",
        ".vcxproj",
        ".proj",
        ".props",
        ".targets",
        ".CSPROJ",
    ],
)
def test_project_family_suffixes_share_literal_xml_contract(
    catalog: SchemaCatalog, suffix: str
) -> None:
    """Given catalog (SchemaCatalog) and suffix (str), detect a minimal project root.

    Returns None; assertion failures indicate a supported family regression. No I/O.
    """
    analysis = DotnetProjectAnalyzer().analyze(
        capture(catalog, (("src/app" + suffix, b"<Project/>"),))
    )
    assert len(findings(analysis, "project")) == 1
    assert len(analysis.components) == 1


@pytest.mark.parametrize(
    "body,code",
    [
        (b"<Other/>", "xml-root"),
        (b"<Project>", "xml-malformed"),
        (b'<Project xmlns="urn:foreign"/>', "xml-namespace"),
        (b'<Project><x:Reference xmlns:x="urn:foreign"/></Project>', "xml-namespace"),
        (b'<!DOCTYPE Project SYSTEM "https://invalid.invalid/a"><Project/>', "xml-dtd"),
        (b'<Project><Reference Include=" "/></Project>', "build-declaration"),
        (b'<Project Sdk=" "/>', "build-declaration"),
    ],
)
def test_invalid_build_input_becomes_blocking_diagnostic(
    catalog: SchemaCatalog, body: bytes, code: str
) -> None:
    """For catalog/body/code, reject unsupported input with no partial claims.

    catalog (SchemaCatalog), body (bytes), code (str) specify an isolated case.
    Returns None; asserts stable error provenance. No I/O or remote fetching.
    """
    analysis = DotnetProjectAnalyzer().analyze(
        capture(catalog, (("src/app.csproj", body),))
    )
    assert analysis.components == analysis.findings == analysis.relationships == ()
    assert [item["code"] for item in analysis.diagnostics] == [code]
    assert (
        analysis.diagnostics[0]["path"] == "src/app.csproj"
        and analysis.diagnostics[0]["blocking"]
    )


def test_unavailable_excluded_and_nonmatching_inputs_are_not_fabricated(
    catalog: SchemaCatalog,
) -> None:
    """For catalog (SchemaCatalog), account for read failures without empty source rows.

    Returns None; assertions require only the relevant unreadable diagnostic. No I/O.
    """
    inputs = capture(catalog, (("src/code.cs", b"opaque"),))
    # Retain explicit excluded/unreadable accounting without fabricating source bytes.
    inputs = replace(
        inputs,
        inputs=inputs.inputs
        + (
            InventoryInput(
                path="src/blocked.csproj", status="unreadable", rationale="Denied."
            ),
            InventoryInput(
                path="src/excluded.csproj",
                status="excluded",
                rationale="External scope.",
            ),
        ),
    )
    analysis = DotnetProjectAnalyzer().analyze(inputs)
    assert analysis.components == analysis.findings == analysis.relationships == ()
    assert len(analysis.diagnostics) == 1
    assert (
        analysis.diagnostics[0]["code"] == "input-unreadable"
        and analysis.diagnostics[0]["message"] == "Denied."
    )


@pytest.mark.parametrize("pinned", [False, True])
def test_absent_or_mismatched_pin_cannot_receive_high_confidence(
    catalog: SchemaCatalog, pinned: bool
) -> None:
    """Given catalog/pinned, fail provenance despite syntactically valid declarations.

    catalog (SchemaCatalog), pinned (bool) select absence or byte mismatch. Returns
    None; assertions require low confidence and a blocker. No I/O or source reread.
    """
    inputs = capture(catalog, (("src/app.csproj", b"<Project/>"),), pinned=pinned)
    inputs = replace(
        inputs,
        repository_files=tuple(
            replace(item, content=b"different") for item in inputs.repository_files
        ),
    )
    analysis = DotnetProjectAnalyzer().analyze(inputs)
    assert all(
        item["confidence"] == "low" for item in analysis.components + analysis.findings
    )
    assert {item["code"] for item in analysis.diagnostics} == {
        "source-revision-unverified",
        "build-evaluation-not-performed",
    }


@pytest.mark.parametrize(
    "body,records,code",
    [
        (b"<Project/>", 2, "analysis-limit"),
        (b'<Project Sdk="Synthetic"/>', 1, "declaration-limit"),
        (b"<Project><Child/></Project>", 1, "xml-limit"),
    ],
)
def test_parser_and_result_budgets_are_independent(
    catalog: SchemaCatalog, body: bytes, records: int, code: str
) -> None:
    """For catalog/body/records/code, prevent bounded parser success bypassing rows.

    catalog (SchemaCatalog), body (bytes), records (int), code (str) select a limit.
    Returns None; requires a blocker without partial components. No I/O.
    """
    analysis = DotnetProjectAnalyzer().analyze(
        capture(catalog, (("src/app.csproj", body),), records=records)
    )
    assert analysis.components == ()
    assert [item["code"] for item in analysis.diagnostics] == [code]


def test_aggregate_budget_and_byte_limit_apply_before_projection(
    catalog: SchemaCatalog,
) -> None:
    """For catalog (SchemaCatalog), bound repeated failures and oversized source bytes.

    Returns None; assertions require explicit limits. No I/O or partial success.
    """
    inputs = capture(
        catalog, (("src/a.csproj", b"bad"), ("src/b.csproj", b"bad")), records=1
    )
    assert (
        DotnetProjectAnalyzer().analyze(inputs).diagnostics[0]["code"]
        == "analysis-limit"
    )
    inputs = capture(catalog, (("src/a.csproj", b"<Project/>"),), max_bytes=1)
    assert (
        DotnetProjectAnalyzer().analyze(inputs).diagnostics[0]["code"] == "input-limit"
    )
    inputs = capture(catalog, (("src/a.sln", b"invalid"),))
    assert (
        DotnetProjectAnalyzer().analyze(inputs).diagnostics[0]["code"]
        == "solution-header"
    )


def test_duplicate_same_line_declarations_have_distinct_stable_ids(
    catalog: SchemaCatalog,
) -> None:
    """For catalog (SchemaCatalog), preserve duplicate source declarations by ordinal.

    Returns None; requires deterministic distinct IDs and exact retained hashes.
    Uses CRLF byte inputs only; no I/O or input mutation.
    """
    body = (
        b'<Project>\r\n<Reference Include="A"/><Reference Include="A"/>\r\n</Project>'
    )
    inputs = capture(
        catalog, (("src/app.csproj", body), ("src/empty.fsproj", b"<Project/>"))
    )
    first = DotnetProjectAnalyzer().analyze(inputs)
    second = DotnetProjectAnalyzer().analyze(
        replace(
            inputs,
            inputs=tuple(reversed(inputs.inputs)),
            repository_files=tuple(reversed(inputs.repository_files)),
        )
    )
    refs = findings(first, "assembly-reference")
    assert len(refs) == 2 and refs[0]["finding_id"] != refs[1]["finding_id"]
    assert first == second
    assert (
        cast("JsonObject", refs[0]["source"])["sha256"]
        == hashlib.sha256(body).hexdigest()
    )


@pytest.mark.parametrize(
    "value", ["../Peer/P.csproj", "C:\\External\\P.csproj", "$(Project)", "**/*.csproj"]
)
def test_relationships_round_trip_unresolved_literal_targets(
    catalog: SchemaCatalog, value: str
) -> None:
    """For catalog/value, retain inert target spelling without an invented binding.

    catalog (SchemaCatalog), value (str) generate the supported declaration family.
    Returns None; assertions require exact round trip. No I/O or path evaluation.
    """
    body = (
        f'<Project><ProjectReference Update="{value}" ' 'Exclude="skip"/></Project>'
    ).encode()
    analysis = DotnetProjectAnalyzer().analyze(
        capture(catalog, (("src/app.csproj", body),))
    )
    assert len(analysis.relationships) == 1
    assert analysis.relationships[0]["target_description"] == value
    assert analysis.relationships[0]["to_component_id"] is None
    assert properties(findings(analysis, "project-reference")[0]) == {
        "update": value,
        "exclude": "skip",
    }
