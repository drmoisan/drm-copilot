"""Verify bounded npm declarations, lock records and fixed redaction in memory."""

from __future__ import annotations

import json
from dataclasses import asdict, replace
from typing import Literal

import pytest
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
)
from drm_copilot_discovery.analyzer.dependency_node import parse_node_dependencies

FORMATS = Literal["package-json", "package-lock"]


def parse(
    value: object, *, format: FORMATS = "package-json", **limits: int
) -> DependencyResult:
    """Encode a synthetic JSON value and return bounded candidates; memory only.

    object value, literal format and int limit overrides select one input. Parser
    errors propagate without mutation, disk, processes or network dependencies.
    """
    return parse_node_dependencies(
        json.dumps(value, ensure_ascii=False).encode(),
        format=format,
        limits=replace(DependencyLimits(), **limits),
    )


def rendered(result: DependencyResult) -> str:
    """Return all immutable result fields as JSON for complete redaction checks.

    DependencyResult result is copied by asdict; returns a str containing every
    field. No caller mutation or I/O occurs; serialization errors propagate.
    """
    return json.dumps(asdict(result), ensure_ascii=False)


@pytest.mark.parametrize(
    "group",
    ["dependencies", "devDependencies", "optionalDependencies", "peerDependencies"],
)
@pytest.mark.parametrize("name", ["simple-name", "@scope/name"])
@pytest.mark.parametrize(
    "version,kind",
    [
        ("1.2.3", "literal"),
        ("^1.0 || ~2.0", "constraint"),
        ("*", "constraint"),
        ("", "missing"),
        ("next", "tag"),
    ],
)
def test_manifest_groups_preserve_declared_values_without_resolution(
    group: str, name: str, version: str, kind: str
) -> None:
    """Str group/name/version/kind cover the finite declaration grammar.

    Returns None; current/requested fields and honest container anchors stay distinct.
    """
    result = parse({"name": "root", group: {name: version}})
    item = result.candidates[0]
    assert item.kind == "declaration" and item.role == group and item.name == name
    assert item.owner == "root" and item.ecosystem == "node"
    assert item.version.kind == kind and item.version.value == (version or None)
    assert item.requested.kind == "missing"
    assert item.anchor.location == "/" + group and item.anchor.line is None
    assert item.operation == "reference" and not item.condition_present
    assert result.diagnostics == ("dependency-binding-unresolved",)


@pytest.mark.parametrize("version", [2, 3])
def test_lock_records_root_maps_and_edges_have_distinct_meanings(version: int) -> None:
    """Int version selects supported lock/shrinkwrap grammar; returns None.

    The compatibility tree and unsafe resolution metadata cannot become extra edges.
    """
    value = {
        "lockfileVersion": version,
        "packages": {
            "": {"name": "root", "dependencies": {"alpha": "^1"}},
            "node_modules/alpha": {
                "version": "1.2",
                "resolved": "https://VALUE_SENTINEL",
                "dependencies": {"beta": "^2"},
            },
            "node_modules/alpha/node_modules/@scope/beta": {"version": "2.0"},
        },
        "dependencies": {"compat": {"version": "VALUE_SENTINEL"}},
    }
    result = parse(value, format="package-lock")
    # Distinct syntax categories prevent lock edges becoming installed relationships.
    assert [item.kind for item in result.candidates] == [
        "declaration",
        "locked-package",
        "declared-lock-edge",
        "locked-package",
    ]
    direct, locked, edge, nested = result.candidates
    assert direct.owner == "root" and direct.version.value == "^1"
    assert locked.name == "alpha" and locked.version.value == "1.2"
    assert edge.owner == "alpha" and edge.name == "beta"
    assert edge.version.kind == "missing" and edge.requested.value == "^2"
    assert nested.name == "@scope/beta" and nested.version.value == "2.0"
    # Every lock occurrence refers only to the declared closed packages container.
    assert all(
        item.anchor.location == "/packages" and item.anchor.line is None
        for item in result.candidates
    )
    # Ordinals identify canonical declarations without disclosing source location keys.
    assert [item.anchor.occurrence for item in result.candidates] == [1, 2, 3, 4]
    assert "VALUE_SENTINEL" not in rendered(result) and "compat" not in rendered(result)


def test_order_and_repeated_groups_are_deterministic_without_precedence() -> None:
    """Reorder source members while preserving repeated groups; returns None.

    Normalized membership controls occurrence identity, never source text line order.
    """
    first = parse(
        {"peerDependencies": {"a": "2"}, "dependencies": {"z": "1", "a": "1"}}
    )
    second = parse(
        {"dependencies": {"a": "1", "z": "1"}, "peerDependencies": {"a": "2"}}
    )
    assert first == second
    # Keep overlapping groups separate without choosing effective precedence.
    assert [(item.name, item.version.value) for item in first.candidates] == [
        ("a", "1"),
        ("z", "1"),
        ("a", "2"),
    ]


@pytest.mark.parametrize(
    "raw,kind",
    [
        ("https://user:VALUE_SENTINEL@host/x", "url"),
        ("git+https://VALUE_SENTINEL", "vcs"),
        ("file:../VALUE_SENTINEL", "local"),
        ("workspace:VALUE_SENTINEL", "workspace"),
        ("npm:VALUE_SENTINEL@1", "alias"),
        ("${VALUE_SENTINEL}", "dynamic"),
        ("VALUE_SENTINEL", "unsupported"),
    ],
)
def test_unsafe_specifiers_are_classifications_without_target_text(
    raw: str, kind: str
) -> None:
    """Str raw/kind cover unresolved reference forms; returns None.

    Both direct versions and requested lock-edge values use the frozen sanitizer.
    """
    direct = parse({"dependencies": {"pkg": raw}})
    lock = parse(
        {
            "lockfileVersion": 3,
            "packages": {
                "node_modules/owner": {"version": "1", "dependencies": {"pkg": raw}}
            },
        },
        format="package-lock",
    )
    assert direct.candidates[0].version.kind == kind
    assert lock.candidates[1].requested.kind == kind
    assert direct.candidates[0].version.value is None
    assert lock.candidates[1].requested.value is None
    assert "VALUE_SENTINEL" not in rendered(direct) + rendered(lock)
    assert "dependency-redacted" in direct.diagnostics


@pytest.mark.parametrize(
    "location",
    [
        "https://VALUE_SENTINEL/a",
        "../VALUE_SENTINEL",
        "node_modules/",
        "node_modules/@scope",
        "node_modules/Bad",
        "node_modules/a/other/b",
        "node_modules/a//node_modules/b",
    ],
)
def test_unsafe_locations_never_enter_anchors_or_identities(location: str) -> None:
    """Str location supplies invalid or unselected package paths; returns None.

    Unknown names remain null, and the source is a closed container plus ordinal.
    """
    result = parse(
        {"lockfileVersion": 2, "packages": {location: {"version": "1"}}},
        format="package-lock",
    )
    assert result.candidates[0].name is None
    assert result.candidates[0].anchor.location == "/packages"
    assert "dependency-redacted" in result.diagnostics
    assert location not in rendered(result) and "VALUE_SENTINEL" not in rendered(result)


@pytest.mark.parametrize(
    "name,expected,code",
    [
        ("same", "same", None),
        ("other", None, "dependency-ambiguous"),
        ("https://VALUE_SENTINEL", None, "dependency-redacted"),
    ],
)
def test_explicit_names_do_not_resolve_conflicting_location_identity(
    name: str, expected: str | None, code: str | None
) -> None:
    """Str name/optional expected/code express observed identity ambiguity.

    Returns None; a mismatch cannot manufacture a bound alias or lock-edge owner.
    """
    result = parse(
        {
            "lockfileVersion": 3,
            "packages": {
                "node_modules/same": {"name": name, "dependencies": {"child": "1"}}
            },
        },
        format="package-lock",
    )
    assert (
        result.candidates[0].name == expected and result.candidates[1].owner == expected
    )
    if code is not None:
        assert code in result.diagnostics
    assert "VALUE_SENTINEL" not in rendered(result)


def test_metadata_only_links_and_explicit_names_remain_unevaluated() -> None:
    """Observe inert link and location-independent name declarations; returns None.

    Missing versions stay missing; link targets, scripts and other fields stay opaque.
    """
    result = parse(
        {
            "lockfileVersion": 3,
            "packages": {
                "local/VALUE_SENTINEL": {"name": "explicit", "version": "1"},
                "node_modules/link": {
                    "link": True,
                    "resolved": "VALUE_SENTINEL",
                    "dependencies": {"ignored": "VALUE_SENTINEL"},
                },
                "node_modules/optional": {"optional": True},
            },
        },
        format="package-lock",
    )
    first, link, optional = result.candidates
    assert first.name == "explicit" and link.role == "link"
    assert link.version.kind == optional.version.kind == "missing"
    assert "dependency-unsupported" in result.diagnostics
    assert "VALUE_SENTINEL" not in rendered(result) and "ignored" not in rendered(
        result
    )


@pytest.mark.parametrize(
    "field",
    [
        "workspaces",
        "overrides",
        "resolutions",
        "bundledDependencies",
        "bundleDependencies",
    ],
)
def test_unsupported_controls_are_diagnosed_without_evaluation(field: str) -> None:
    """Str field selects an unimplemented dependency control; returns None.

    Retain ordinary declarations while withholding all control expressions.
    """
    result = parse(
        {
            field: "VALUE_SENTINEL",
            "dependencies": {"pkg": "1"},
            "scripts": {"preinstall": "VALUE_SENTINEL"},
        }
    )
    assert len(result.candidates) == 1
    assert result.diagnostics == (
        "dependency-binding-unresolved",
        "dependency-unsupported",
    )
    assert "VALUE_SENTINEL" not in rendered(result)


@pytest.mark.parametrize(
    "value",
    [
        None,
        [],
        {"dependencies": None},
        {"dependencies": []},
        {"dependencies": {"x": 1}},
        {"name": []},
        {"dependencies": {"a": "1"}, "peerDependencies": {"b": None}},
    ],
)
def test_malformed_manifest_shape_never_returns_partial_candidates(
    value: object,
) -> None:
    """Object value supplies invalid selected JSON shape; returns None.

    A later malformed declaration cannot return earlier collected candidates.
    """
    with pytest.raises(DependencyInputError) as caught:
        parse(value)
    assert caught.value.code == "dependency-malformed"


@pytest.mark.parametrize(
    "value,code",
    [
        ({}, "dependency-unsupported"),
        ({"lockfileVersion": 1}, "dependency-unsupported"),
        ({"lockfileVersion": 4}, "dependency-unsupported"),
        ({"lockfileVersion": True}, "dependency-malformed"),
        ({"lockfileVersion": 2.0}, "dependency-malformed"),
        ({"lockfileVersion": "2"}, "dependency-malformed"),
        ({"lockfileVersion": 2}, "dependency-malformed"),
        ({"lockfileVersion": 3, "packages": []}, "dependency-malformed"),
        (
            {"lockfileVersion": 3, "packages": {"node_modules/a": None}},
            "dependency-malformed",
        ),
        (
            {"lockfileVersion": 3, "packages": {"node_modules/a": {"link": "true"}}},
            "dependency-malformed",
        ),
        (
            {"lockfileVersion": 3, "packages": {"node_modules/a": {"version": 42}}},
            "dependency-malformed",
        ),
    ],
)
def test_lock_versions_and_selected_shapes_fail_closed(
    value: object, code: str
) -> None:
    """Object value/str code select version or shape failures; returns None.

    Exact integer versions2/3 are required; no fallback or partial result occurs.
    """
    with pytest.raises(DependencyInputError) as caught:
        parse(value, format="package-lock")
    assert caught.value.code == code


@pytest.mark.parametrize(
    "content,code",
    [
        (b'{"dependencies":{"x":"1","x":"VALUE_SENTINEL"}}', "dependency-malformed"),
        (b'{"VALUE_SENTINEL":NaN}', "dependency-malformed"),
        (b'{"VALUE_SENTINEL":Infinity}', "dependency-malformed"),
        (b'{"dependencies":', "dependency-malformed"),
        (b"\xffVALUE_SENTINEL", "dependency-encoding"),
        (b'{"dependencies":{"x":"\\ud800VALUE_SENTINEL"}}', "dependency-encoding"),
    ],
)
def test_parser_errors_withhold_messages_keys_and_selected_secret_text(
    content: bytes, code: str
) -> None:
    """Bytes content/str code cover malformed, duplicate and encoding failures.

    Returns None; exception string, repr, args and code contain only fixed data.
    """
    with pytest.raises(DependencyInputError) as caught:
        parse_node_dependencies(
            content, format="package-json", limits=DependencyLimits()
        )
    error = caught.value
    assert error.code == code
    assert "VALUE_SENTINEL" not in str(error) + repr(error) + repr(error.args)


def test_bom_empty_inputs_and_unicode_separator_are_honest_json() -> None:
    """Accept UTF-8 BOM and inert Unicode whitespace inside strings; returns None.

    Empty supported documents have no invented packages or physical line anchors.
    """
    result = parse_node_dependencies(
        b'\xef\xbb\xbf{"note":"a\xe2\x80\xa8b"}',
        format="package-json",
        limits=DependencyLimits(max_lines=1),
    )
    assert not result.candidates and result.diagnostics == (
        "dependency-binding-unresolved",
    )
    assert not parse(
        {"lockfileVersion": 3, "packages": {}}, format="package-lock"
    ).candidates
