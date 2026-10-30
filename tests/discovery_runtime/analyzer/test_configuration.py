"""Verify key-only configuration declarations, redaction and bounded provenance."""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer import configuration as configuration_module
from drm_copilot_discovery.analyzer.configuration import ConfigurationAnalyzer
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import InventoryInput
from drm_copilot_discovery.models import canonical_json

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture, properties
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.analyzer.configuration_input import (
        ConfigurationFormat,
        ConfigurationKey,
    )
    from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject

    Projector = Callable[
        [
            InventoryCapture,
            InventoryInput,
            ConfigurationFormat,
            tuple[ConfigurationKey, ...],
        ],
        Analysis,
    ]

FIXTURES = Path(__file__).parents[2] / "fixtures/discovery_analyzers/configuration"


def serialized(analysis: Analysis) -> str:
    """Serialize every result family of Analysis; return str without external I/O.

    Assertions use this complete surface so diagnostics cannot conceal a leak.
    Invalid internal JSON would raise a serialization error.
    """
    return canonical_json(
        row(
            components=analysis.components,
            findings=analysis.findings,
            relationships=analysis.relationships,
            diagnostics=analysis.diagnostics,
        )
    ).decode()


def extension(finding: JsonObject) -> JsonObject:
    """Return fixed configuration extension of JsonObject; KeyError rejects misuse.

    No I/O or mutation occurs; this helper exposes assertions about presence.
    """
    return cast(
        "JsonObject", cast("JsonObject", finding["extensions"])["drm.configuration"]
    )


@pytest.mark.parametrize(
    "name,keys",
    [
        ("config.json", {"Outer", "Rows", "a/b~c", "Mode", "Enabled"}),
        ("application.config", {"Endpoint", "Obsolete", "Primary", "Layout", "Theme"}),
        ("settings.settings", {"Display"}),
        (
            "settings.ini",
            {
                "DEFAULT",
                "Client",
                "Alternate",
                "Theme",
                "Inherited",
                "Message",
                "Literal",
                "Case",
                "case",
                "Local",
            },
        ),
    ],
)
def test_fixtures_project_only_identifiers_with_valid_provenance(
    catalog: SchemaCatalog, name: str, keys: set[str]
) -> None:
    """For catalog/name/keys, preserve declared identifiers in valid inventory.

    Inputs are SchemaCatalog, fixture str and expected set[str]. Returns None;
    asserts complete value redaction, exact hashes and honest coverage proposals.
    Reads only immutable checked-in fixtures; analyzer execution stays in memory.
    """
    payload = (FIXTURES / (name + ".txt")).read_bytes()
    inputs = capture(catalog, (("src/" + name, payload),))
    analysis = ConfigurationAnalyzer().analyze(inputs)
    result = inventory_result(
        inputs,
        (analysis,),
        analyzer_ids=("configuration",),
        timestamp="2026-10-19T05:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=catalog,
    )
    # Compare the complete declared key set rather than selected successful rows.
    assert {properties(item)["key"] for item in analysis.findings} == keys
    assert "VALUE_SENTINEL" not in serialized(analysis)
    # Every diagnostic must preserve this valid fixture's nonblocking status.
    assert not any(item["blocking"] for item in analysis.diagnostics)
    # Inventory proposals cannot claim completed inspection or approved disposition.
    assert all(
        item["inspection_status"] == "uninspected"
        and item["disposition"] == "unassigned"
        for item in result.ledger_components
    )
    # Distinct declarations must remain independently traceable.
    assert len({item["finding_id"] for item in analysis.findings}) == len(
        analysis.findings
    )
    # Whole-file checksums retain provenance without retaining source values.
    for finding in analysis.findings:
        source = cast("JsonObject", finding["source"])
        assert source["sha256"] == hashlib.sha256(payload).hexdigest()
        assert source["revision"] == inputs.profile.repository.revision
        assert (
            finding["classification"] == "detected" and finding["confidence"] == "high"
        )
        assert extension(finding)["presence"] == "unresolved"


@pytest.mark.parametrize(
    "name,payload",
    [
        ("APPSETTINGS.JSON", b'{"K":1}'),
        ("appsettings.a.json", b'{"K":1}'),
        ("settings.json", b'{"K":1}'),
        ("config.json", b'{"K":1}'),
        (
            "a.CONFIG",
            b'<configuration><appSettings><add key="K"/></appSettings></configuration>',
        ),
        (
            "a.settings",
            b'<SettingsFile><Settings><Setting Name="K"/></Settings></SettingsFile>',
        ),
        ("settings.xml", b'<settings><setting name="K"/></settings>'),
        (
            "configuration.xml",
            b'<configuration><appSettings><add key="K"/></appSettings></configuration>',
        ),
        ("a.INI", b"[S]\nK=VALUE_SENTINEL"),
    ],
)
def test_finite_supported_filename_families(
    catalog: SchemaCatalog, name: str, payload: bytes
) -> None:
    """SchemaCatalog/name str/payload bytes select only documented grammar families.

    Returns None; asserts key detection without runtime activation or value leaks.
    """
    result = ConfigurationAnalyzer().analyze(
        capture(catalog, (("src/" + name, payload),))
    )
    assert any(properties(item)["key"] == "K" for item in result.findings)
    assert "VALUE_SENTINEL" not in serialized(result)


@pytest.mark.parametrize(
    "name",
    [
        "data.json",
        "source.cs",
        "appsettings..json",
        "other.xml",
        "source.py",
        "config.yaml",
        "settings",
    ],
)
def test_unrelated_files_are_ignored_without_payload_diagnostics(
    catalog: SchemaCatalog, name: str
) -> None:
    """Given SchemaCatalog and unrelated str name, ignore malformed bytes entirely.

    Returns None; asserts an empty result, with no I/O or external effects.
    """
    result = ConfigurationAnalyzer().analyze(
        capture(catalog, (("src/" + name, b"VALUE_SENTINEL{<"),))
    )
    assert not (
        result.components
        or result.findings
        or result.relationships
        or result.diagnostics
    )


def test_json_uses_exact_pointer_segments_without_inventing_lines(
    catalog: SchemaCatalog,
) -> None:
    """Given SchemaCatalog, escape RFC6901 keys and retain nested array positions.

    Returns None; assertions use immutable records and require absent JSON lines.
    """
    result = ConfigurationAnalyzer().analyze(
        capture(
            catalog, (("src/config.json", b'{"a/b~c":[{}, {"N":null}],"Empty":{}}'),)
        )
    )
    # Check each escaped object address, including the actual array index.
    assert {properties(item)["structural_path"] for item in result.findings} == {
        "/a~1b~0c",
        "/a~1b~0c/1/N",
        "/Empty",
    }
    # JSON parsing supplies structural addresses without fabricated line anchors.
    assert all(
        "line_range" not in cast("JsonObject", item["source"])
        for item in result.findings
    )


@pytest.mark.parametrize(
    "name,payload",
    [
        ("config.json", b'{"K":"VALUE_SENTINEL",}'),
        ("settings.xml", b'<settings><setting name="K" value="VALUE_SENTINEL"/></bad>'),
        ("settings.ini", b"[S]\nVALUE_SENTINEL"),
        ("settings.toml", b'K="VALUE_SENTINEL"'),
    ],
)
def test_malformed_and_unsupported_selected_inputs_fail_closed(
    catalog: SchemaCatalog, name: str, payload: bytes
) -> None:
    """SchemaCatalog/name/payload select invalid syntax or unsupported TOML.

    Returns None; complete Analysis must contain one sanitized blocking diagnostic.
    """
    result = ConfigurationAnalyzer().analyze(
        capture(catalog, (("src/" + name, payload),))
    )
    assert not result.components and not result.findings
    assert len(result.diagnostics) == 1 and result.diagnostics[0]["blocking"] is True
    assert "VALUE_SENTINEL" not in serialized(result)


def test_repeated_default_headers_keep_distinct_declaration_ids(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog fixture supports legal repeated DEFAULT with distinct keys.

    Returns None; asserts unique findings and inherited origin references.
    """
    payload = (
        b"[DEFAULT]\nA=VALUE_SENTINEL\n[DEFAULT]\nB=VALUE_SENTINEL\n[S]\nA=override"
    )
    result = ConfigurationAnalyzer().analyze(
        capture(catalog, (("src/settings.ini", payload),))
    )
    # Repeated DEFAULT headers have separate declarations and stable unique IDs.
    assert len({item["finding_id"] for item in result.findings}) == len(result.findings)
    # Only the non-overridden default becomes inherited in the target section.
    assert [
        properties(item)["key"]
        for item in result.findings
        if item["kind"] == "ini-inherited-key"
    ] == ["B"]
    # Legal repeated DEFAULT headers do not introduce a blocking diagnostic.
    assert not any(item["blocking"] for item in result.diagnostics)


@pytest.mark.parametrize(
    "name,first,second",
    [
        ("config.json", b'{"K":"VALUE_SENTINEL_1"}', b'{"K":["VALUE_SENTINEL_2"]}'),
        (
            "settings.xml",
            b'<settings condition="VALUE_SENTINEL_1">'
            b'<setting name="K">one</setting></settings>',
            b'<settings condition="VALUE_SENTINEL_2">\n'
            b'<setting name="K">two</setting></settings>',
        ),
        ("settings.ini", b"[S]\nK=VALUE_SENTINEL_1", b"[S]\n\nK=VALUE_SENTINEL_2"),
    ],
)
def test_value_and_condition_changes_do_not_define_semantic_ids(
    catalog: SchemaCatalog, name: str, first: bytes, second: bytes
) -> None:
    """SchemaCatalog, str name and two byte payloads vary values/conditions/lines.

    Returns None; semantic IDs stay stable while exact source checksums differ.
    """
    original = ConfigurationAnalyzer().analyze(
        capture(catalog, (("src/" + name, first),))
    )
    changed = ConfigurationAnalyzer().analyze(
        capture(catalog, (("src/" + name, second),))
    )
    # Compare all semantic identities while allowing whole-file provenance to vary.
    assert [item["finding_id"] for item in original.findings] == [
        item["finding_id"] for item in changed.findings
    ]
    assert (
        original.components[0]["component_id"] == changed.components[0]["component_id"]
    )
    assert original.components[0]["source"] != changed.components[0]["source"]
    assert "VALUE_SENTINEL" not in serialized(original) + serialized(changed)


def test_excluded_and_unreadable_inputs_do_not_leak_read_rationales(
    catalog: SchemaCatalog,
) -> None:
    """SchemaCatalog builds unavailable inputs with source-bearing error rationales.

    Returns None; excluded files vanish and unreadable files get a fixed diagnostic.
    """
    base = capture(catalog, ())
    inputs = replace(
        base,
        inputs=(
            InventoryInput(
                path="src/a.ini", status="excluded", rationale="VALUE_SENTINEL_EXCLUDED"
            ),
            InventoryInput(
                path="src/b.ini", status="unreadable", rationale="VALUE_SENTINEL_READ"
            ),
        ),
    )
    result = ConfigurationAnalyzer().analyze(inputs)
    assert (
        len(result.diagnostics) == 1
        and result.diagnostics[0]["code"] == "input-unreadable"
    )
    assert "VALUE_SENTINEL" not in serialized(result)


def test_missing_immutable_provenance_is_low_confidence_and_blocking(
    catalog: SchemaCatalog,
) -> None:
    """Given SchemaCatalog, a working payload alone cannot confer verified source.

    Returns None; asserts low confidence and an explicit source-pin diagnostic.
    """
    result = ConfigurationAnalyzer().analyze(
        capture(catalog, (("src/config.json", b'{"K":1}'),), pinned=False)
    )
    # No declaration may infer verified provenance from an unpinned working file.
    assert all(item["confidence"] == "low" for item in result.findings)
    # The missing immutable source must also remain an explicit blocking finding.
    assert any(
        item["code"] == "source-revision-unverified" and item["blocking"]
        for item in result.diagnostics
    )


@pytest.mark.parametrize(
    "records,payloads",
    [
        (1, (("src/config.json", b"{}"),)),
        (2, (("src/a.toml", b"K=1"), ("src/b.toml", b"K=1"), ("src/c.ini", b"[S]"))),
    ],
)
def test_aggregate_output_limit_drops_partial_claims(
    catalog: SchemaCatalog, records: int, payloads: tuple[tuple[str, bytes], ...]
) -> None:
    """SchemaCatalog/int records/payload tuples exhaust the complete Analysis budget.

    Returns None; assertions require a single limit diagnostic and no partial data.
    """
    result = ConfigurationAnalyzer().analyze(
        capture(catalog, payloads, records=records)
    )
    assert not result.components and not result.findings
    # Overflow replaces every partial finding with one fixed limit diagnostic.
    assert [item["code"] for item in result.diagnostics] == ["analysis-limit"]


@pytest.mark.parametrize("kind", ["base", "findings", "parser", "astral"])
def test_text_overflow_rejects_before_projecting_an_excess_batch(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, kind: str
) -> None:
    """Catalog/patch fixture and str kind exercise aggregate allocation boundaries.

    Returns None; counts actual projection calls and requires whole-result failure.
    All captures and patches remain local memory; no source values may escape.
    """
    first = ("src/a/config.json", b"{}")
    second = ("src/b/config.json", b'{"K":"VALUE_SENTINEL"}')
    budget = 10000
    # Choose inputs that exhaust distinct gates before any excess row batch exists.
    if kind == "findings":
        payloads = (("src/config.json", b'{"A":1,"B":2,"C":3}'),)
        budget = 8192
    elif kind == "parser":
        payloads = (("src/config.json", b'{"' + b"K" * 256 + b'":1}'),)
        budget = 8192
    elif kind == "astral":
        payload = json.dumps({"\U0001f680" * 4096: 0}, ensure_ascii=False).encode()
        payloads = (("src/config.json", payload),)
        budget = 80000
    else:
        payloads = (first, second)
    inputs = replace(
        capture(catalog, payloads),
        profile=inventory_profile(catalog, limits={"document_bytes": budget}),
    )
    projected: list[str] = []
    original = cast("Projector", vars(configuration_module)["_project"])

    def counted_project(
        captured: InventoryCapture,
        item: InventoryInput,
        format: ConfigurationFormat,
        keys: tuple[ConfigurationKey, ...],
    ) -> Analysis:
        """Record immutable capture/item/format/key projection; return real Analysis.

        Mutates only the test's path list; underlying invariant errors propagate.
        """
        projected.append(item.path)
        return original(captured, item, format, keys)

    monkeypatch.setattr(configuration_module, "_project", counted_project)
    result = ConfigurationAnalyzer().analyze(inputs)
    assert projected == ([first[0]] if kind == "base" else [])
    assert not result.components and not result.findings and not result.relationships
    assert len(result.diagnostics) == 1
    assert result.diagnostics[0]["code"] == "analysis-text-limit"
    assert "VALUE_SENTINEL" not in serialized(result)


@pytest.mark.parametrize("key", ["Ω/~", 'Control\n\t"\\', "\U0001f680/~"])
@pytest.mark.parametrize("ensure_ascii", [False, True])
def test_complete_serialized_projection_fits_the_documented_byte_bound(
    catalog: SchemaCatalog, key: str, ensure_ascii: bool
) -> None:
    """Catalog, Unicode str key and bool encoding cover compact JSON representations.

    Returns None; compares full encoded Analysis to the prospective byte bound.
    Astral, BMP, control and pointer escapes stay identifiers; values stay absent.
    """
    payload = json.dumps({key: "VALUE_SENTINEL"}, ensure_ascii=False).encode()
    inputs = replace(
        capture(catalog, (("src/config.json", payload),)),
        profile=inventory_profile(catalog, limits={"document_bytes": 16384}),
    )
    result = ConfigurationAnalyzer().analyze(inputs)
    encoded = json.dumps(
        json.loads(serialized(result)), ensure_ascii=ensure_ascii, separators=(",", ":")
    ).encode()
    assert len(result.findings) == 1 and len(result.components) == 1
    assert properties(result.findings[0])["key"] == key
    assert properties(result.findings[0])["structural_path"] == (
        "/" + key.replace("~", "~0").replace("/", "~1")
    )
    assert len(encoded) <= inputs.profile.limits.document_bytes
    assert "VALUE_SENTINEL" not in encoded.decode()
