"""Verify dependency projection and provenance from immutable captured bytes."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer import dependencies
from drm_copilot_discovery.analyzer.dependencies import DependencyAnalyzer
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyAnchor,
    DependencyCandidate,
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
    DependencyValue,
)
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import (
    Analysis,
    InventoryCapture,
    InventoryInput,
)
from drm_copilot_discovery.models import JsonObject, canonical_json

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.catalog import SchemaCatalog


def item(*, edge: bool = False, line: int | None = None) -> DependencyCandidate:
    """Build DependencyCandidate from edge (bool) and line (int | None).

    Defaults select a declaration/container; no I/O, mutation or expected error.
    """
    return DependencyCandidate(
        "declared-lock-edge" if edge else "declaration",
        "python",
        "package",
        DependencyValue("literal", "1.0"),
        "install",
        DependencyAnchor(
            "text" if line else "json",
            "requirements" if line else "/dependencies",
            line=line,
        ),
        requested=DependencyValue("constraint", ">=1"),
        owner="parent" if edge else None,
    )


def configured(
    catalog: SchemaCatalog,
    *,
    limits: dict[str, int] | None = None,
    payloads: tuple[tuple[str, bytes], ...] = (("src/package.json", b"{}"),),
) -> InventoryCapture:
    """Build InventoryCapture using catalog (SchemaCatalog), limits and payloads.

    limits (dict[str, int] | None) overrides defaults; payloads (path/bytes tuples)
    remain in memory. Invalid profile values propagate validation errors; no I/O.
    """
    result = capture(catalog, payloads)
    if limits:
        result = replace(result, profile=inventory_profile(catalog, limits=limits))
    return result


def stub(
    monkeypatch: pytest.MonkeyPatch, result: DependencyResult
) -> list[DependencyLimits]:
    """Inject result (DependencyResult) with monkeypatch (pytest.MonkeyPatch).

    Return list[DependencyLimits] capturing calls; the fixture restores the isolated
    patch. No I/O or expected error occurs.
    """
    calls: list[DependencyLimits] = []

    def parse(
        content: bytes, format: str, limits: DependencyLimits
    ) -> DependencyResult:
        """Accept content (bytes), format (str), limits (DependencyLimits).

        Return DependencyResult; append limits locally without I/O or errors.
        """
        calls.append(limits)
        return result

    monkeypatch.setattr(dependencies, "_parse", parse)
    return calls


def codes(result: Analysis) -> tuple[str, ...]:
    """Return tuple[str, ...] codes from result (Analysis); no mutation/I/O/errors."""
    # Read only the fixed codes so assertions never depend on generated identifiers.
    return tuple(cast("str", value["code"]) for value in result.diagnostics)


@pytest.mark.parametrize(
    ("path", "expected"),
    [
        ("src/package.json", "package-json"),
        ("src/PACKAGE-LOCK.JSON", "package-lock"),
        ("src/npm-shrinkwrap.json", "package-lock"),
        ("src/setup.cfg", "setup-cfg"),
        ("src/requirements.txt", "requirements"),
        ("src/requirements-dev.txt", "requirements"),
        ("src/app.csproj", "project"),
        ("src/app.vbproj", "project"),
        ("src/app.fsproj", "project"),
        ("src/app.proj", "project"),
        ("src/Directory.Packages.props", "project"),
        ("src/app.targets", "project"),
        ("src/packages.config", "packages-config"),
        ("src/packages.lock.json", "packages-lock"),
        ("src/setup.py", "unsupported"),
        ("src/pyproject.toml", "unsupported"),
        ("src/poetry.lock", "unsupported"),
        ("src/yarn.lock", "unsupported"),
        ("src/pnpm-lock.yaml", "unsupported"),
        ("src/readme.txt", None),
    ],
)
def test_path_dispatch_is_finite_and_platform_independent(
    path: str, expected: str | None
) -> None:
    """Check finite path (str) against expected (str | None); return None.

    No I/O, evaluation, mutation or expected exception occurs.
    """
    selector = cast("Callable[[str], str | None]", vars(dependencies)["_format"])
    assert selector(path) == expected


@pytest.mark.parametrize(
    ("format", "function"),
    [
        ("package-json", "parse_node_dependencies"),
        ("package-lock", "parse_node_dependencies"),
        ("requirements", "parse_python_dependencies"),
        ("setup-cfg", "parse_python_dependencies"),
        ("project", "parse_dotnet_dependencies"),
        ("packages-config", "parse_dotnet_dependencies"),
        ("packages-lock", "parse_dotnet_dependencies"),
    ],
)
def test_dispatch_passes_exact_bytes_and_limits(
    monkeypatch: pytest.MonkeyPatch, format: str, function: str
) -> None:
    """Check format/function (str) via monkeypatch (pytest.MonkeyPatch); return None.

    The fixture restores parser patches; unsupported dispatch is asserted without I/O.
    """
    calls: list[tuple[bytes, str, DependencyLimits]] = []
    limits = DependencyLimits()

    def parse(
        content: bytes, *, format: str, limits: DependencyLimits
    ) -> DependencyResult:
        """Record content (bytes), format (str), limits (DependencyLimits).

        Return empty DependencyResult; only local call history mutates, without I/O.
        """
        calls.append((content, format, limits))
        return DependencyResult()

    monkeypatch.setattr(dependencies, function, parse)
    dispatch = cast(
        "Callable[[bytes, str, DependencyLimits], DependencyResult]",
        vars(dependencies)["_parse"],
    )
    assert dispatch(b"original", format, limits) == DependencyResult()
    assert calls == [(b"original", format, limits)]
    with pytest.raises(DependencyInputError) as error:
        dispatch(b"original", "unknown", limits)
    assert error.value.code == "dependency-unsupported"


def test_projected_facts_and_edges_preserve_source_semantics(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Check syntax/provenance using catalog and monkeypatch fixtures; return None.

    SchemaCatalog supplies validated input; pytest.MonkeyPatch isolates the parser.
    No I/O or expected error occurs; graph binding remains unresolved.
    """
    captured = configured(catalog)
    stub(monkeypatch, DependencyResult((item(line=1), item(edge=True))))
    result = DependencyAnalyzer().analyze(captured)
    assert len(result.components) == 1 and len(result.findings) == 2
    assert result.findings[0]["classification"] == "detected"
    assert result.components[0]["confidence"] == "high"
    source = cast("JsonObject", result.findings[0]["source"])
    assert source["sha256"] == hashlib.sha256(b"{}").hexdigest()
    assert source["revision"] == captured.profile.repository.revision
    assert source["line_range"] == JsonObject((("start", 1), ("end", 1)))
    relationship = result.relationships[0]
    assert relationship["classification"] == "inferred"
    assert (
        relationship["to_component_id"] is None and relationship["confidence"] == "low"
    )
    extension = cast(
        "JsonObject",
        cast("JsonObject", result.findings[0]["extensions"])["drm.dependencies"],
    )
    assert extension["version"] == "1.0" and extension["requested"] == ">=1"
    assert (
        extension["binding"] == "unresolved" and extension["execution"] == "unverified"
    )
    assert codes(result) == ("dependency-binding-unresolved",)


def test_redacted_edge_and_repeated_container_identity(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Check redaction using catalog/monkeypatch fixtures; return None.

    SchemaCatalog and pytest.MonkeyPatch isolate validated rows/parser output.
    No I/O, target evaluation or expected exception occurs.
    """
    redacted = replace(item(edge=True), name=None, version=DependencyValue("url"))
    stub(monkeypatch, DependencyResult((redacted, redacted), ("dependency-redacted",)))
    result = DependencyAnalyzer().analyze(configured(catalog))
    assert result.findings[0]["finding_id"] != result.findings[1]["finding_id"]
    assert result.relationships[0]["target_description"] == "redacted-dependency"
    assert len(result.relationships) == 2
    assert set(codes(result)) == {
        "dependency-binding-unresolved",
        "dependency-redacted",
    }


@pytest.mark.parametrize(
    "pin_case",
    [
        "absent",
        "wrong-bytes",
        "wrong-revision",
        "wrong-path",
        "wrong-repository",
        "duplicate",
    ],
)
def test_pin_identity_controls_confidence(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, pin_case: str
) -> None:
    """Check pin_case (str) with catalog/monkeypatch fixtures; return None.

    SchemaCatalog supplies pins; pytest.MonkeyPatch isolates parsing. No I/O occurs.
    Duplicate pins retain a valid match; no expected exception occurs.
    """
    captured = configured(catalog)
    source = captured.repository_files[0]
    # Change exactly one provenance dimension while retaining captured input bytes.
    if pin_case == "absent":
        pins = ()
    elif pin_case == "wrong-bytes":
        pins = (replace(source, content=b"different"),)
    elif pin_case == "wrong-revision":
        pins = (
            replace(source, repository=replace(source.repository, revision="b" * 40)),
        )
    elif pin_case == "wrong-path":
        pins = (replace(source, path="src/other.json"),)
    elif pin_case == "wrong-repository":
        pins = (
            replace(source, repository=replace(source.repository, id="another-source")),
        )
    else:
        pins = (replace(source, content=b"different"), source)
    stub(monkeypatch, DependencyResult((item(),)))
    result = DependencyAnalyzer().analyze(replace(captured, repository_files=pins))
    matched = pin_case == "duplicate"
    assert result.components[0]["confidence"] == ("high" if matched else "low")
    assert ("source-revision-unverified" in codes(result)) is not matched


def test_unavailable_excluded_and_unsupported_inputs_do_not_parse(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Check capture failures using catalog/monkeypatch fixtures; return None.

    SchemaCatalog and pytest.MonkeyPatch isolate inputs/parser calls. Fixed result
    errors retain no read rationale; no I/O or uncontrolled exception occurs.
    """
    captured = configured(
        catalog,
        payloads=(
            ("src/package.json", b"secret"),
            ("src/setup.py", b"secret"),
            ("src/requirements.txt", b"secret"),
        ),
    )
    # Preserve each selected path while injecting distinct capture failure states.
    changed = tuple(
        (
            InventoryInput(
                path=value.path,
                status=(
                    "excluded"
                    if value.path.endswith("requirements.txt")
                    else "unreadable"
                ),
                rationale="private secret",
            )
            if value.path != "src/setup.py"
            else value
        )
        for value in captured.inputs
    )
    calls = stub(monkeypatch, DependencyResult((item(),)))
    result = DependencyAnalyzer().analyze(replace(captured, inputs=changed))
    assert not calls and not result.components
    assert codes(result) == ("input-unreadable", "dependency-unsupported")
    assert b"private secret" not in canonical_json(result.diagnostics)


@pytest.mark.parametrize(
    "code",
    [
        "dependency-malformed",
        "dependency-encoding",
        "dependency-unsupported",
        "dependency-limit",
    ],
)
def test_parser_failures_use_fixed_diagnostics(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, code: str
) -> None:
    """Check code (str) through catalog/monkeypatch fixtures; return None.

    SchemaCatalog and pytest.MonkeyPatch isolate two inputs and a failing parser.
    The fixed error is asserted; no I/O or external mutation occurs.
    """
    captured = configured(
        catalog,
        payloads=(("src/a/package.json", b"ok"), ("src/b/package.json", b"bad")),
    )

    def parse(
        content: bytes, format: str, limits: DependencyLimits
    ) -> DependencyResult:
        """Accept content (bytes), format (str), limits (DependencyLimits).

        Return DependencyResult or raise the selected fixed error on the second
        input; no I/O or mutation occurs.
        """
        if content == b"bad":
            raise DependencyInputError(code)
        return DependencyResult((item(),))

    monkeypatch.setattr(dependencies, "_parse", parse)
    result = DependencyAnalyzer().analyze(captured)
    assert code in codes(result)
    assert len(result.components) == (0 if code == "dependency-limit" else 1)
    assert result.diagnostics[-1]["path"] == (
        None if code == "dependency-limit" else "src/b/package.json"
    )


def test_analysis_is_deterministic_and_schema_valid(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Compose catalog/monkeypatch fixtures through the emitter; return None.

    SchemaCatalog validates rows; pytest.MonkeyPatch isolates parser output.
    No I/O or expected exception occurs; inventory does not complete coverage.
    """
    captured = configured(
        catalog, payloads=(("src/b/package.json", b"{}"), ("src/a/package.json", b"{}"))
    )
    stub(monkeypatch, DependencyResult((item(), item(edge=True))))
    first = DependencyAnalyzer().analyze(captured)
    second = DependencyAnalyzer().analyze(
        replace(captured, inputs=tuple(reversed(captured.inputs)))
    )
    assert first == second
    result = inventory_result(
        captured,
        (first,),
        analyzer_ids=("dependencies",),
        timestamp="2026-10-19T00:00:00Z",
        author_or_agent=row(kind="tool", id="synthetic"),
        catalog=catalog,
    )
    assert len(result.ledger_components) == 2
    # Inventory proposes components without approving discovery inspection coverage.
    assert all(
        value["inspection_status"] == "uninspected"
        for value in result.ledger_components
    )
    # Disposition remains a consuming-repository decision after declaration extraction.
    assert all(
        value["disposition"] == "unassigned" for value in result.ledger_components
    )


def test_empty_capture_and_irrelevant_inputs_have_no_fabricated_fact(
    catalog: SchemaCatalog,
) -> None:
    """Use catalog (SchemaCatalog) to check absent/irrelevant input; return None.

    No I/O, mutation or expected error occurs, and no fact is fabricated.
    """
    assert DependencyAnalyzer().analyze(configured(catalog, payloads=())) == Analysis()
    assert (
        DependencyAnalyzer().analyze(
            configured(catalog, payloads=(("src/readme.txt", b"text"),))
        )
        == Analysis()
    )


def test_real_parser_families_compose_with_inventory_schema(
    catalog: SchemaCatalog,
) -> None:
    """Compose catalog (SchemaCatalog) with three real parsers; return None.

    Use synthetic retained bytes only; no install, filesystem or expected error.
    Schema validation must preserve declaration facts and unresolved graph edges.
    """
    payloads = (
        (
            "src/package-lock.json",
            b'{"lockfileVersion":3,"packages":{"node_modules/alpha":{"version":"1","dependencies":{"beta":"^2"}}}}',
        ),
        ("src/requirements.txt", b'gamma>=1; python_version >= "3.10"\r\n'),
        (
            "src/app.csproj",
            b'<Project><ItemGroup><PackageReference Include="Delta" Version="2" />'
            b"</ItemGroup></Project>",
        ),
    )
    captured = configured(catalog, payloads=payloads)
    result = DependencyAnalyzer().analyze(captured)
    assert len(result.components) == 3 and len(result.findings) == 4
    assert len(result.relationships) == 1
    # Compare explicit ecosystems rather than inferring them from source filenames.
    metadata = tuple(
        cast("JsonObject", cast("JsonObject", value["extensions"])["drm.dependencies"])
        for value in result.findings
    )
    # Ecosystem labels must come from all three actual parser families.
    assert {value["ecosystem"] for value in metadata} == {"node", "python", "dotnet"}
    # Every parser's syntax remains separate from package installation or execution.
    assert all(
        value["installed_state"] == "unverified" and value["graph"] == "not-evaluated"
        for value in metadata
    )
    assert result.relationships[0]["to_component_id"] is None
    document = inventory_result(
        captured,
        (result,),
        analyzer_ids=("dependencies",),
        timestamp="2026-10-19T00:00:00Z",
        author_or_agent=row(kind="tool", id="synthetic"),
        catalog=catalog,
    )
    assert len(document.ledger_components) == 3
