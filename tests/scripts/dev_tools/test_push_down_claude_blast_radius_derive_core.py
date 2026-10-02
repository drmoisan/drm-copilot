"""Tests for the blast-radius derivation core port (issue #507).

Mirrors the classification, pruning, floor, ordering, and determinism cases of
``extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts``.
Every observation is constructed in memory; no filesystem access occurs.
"""

from __future__ import annotations

import copy
import json
from typing import cast

from scripts.dev_tools.push_down_claude_blast_radius_derive_core import (
    DirectoryObservation,
    derive_destination_module_map,
)

SOURCE = {
    "version": 1,
    "shared_surfaces": [
        ".claude/settings.json",
        "config/orchestration-routing.json",
        "config/blast-radius.json",
    ],
    "shared_surface_globs": [],
    "modules": {"config": ["config/**"]},
    "over_breadth_fraction": 0.25,
}
SOURCE_DOCUMENT = json.dumps(SOURCE, indent=2) + "\n"
FLOOR = {"config": ["config/**"]}


def _observe(relative_path: str, *file_names: str) -> DirectoryObservation:
    """Build an observation from a relative path and its shallow file names."""

    return DirectoryObservation(relative_path, tuple(file_names))


def _derive(
    observations: list[DirectoryObservation], source: str = SOURCE_DOCUMENT
) -> dict[str, object]:
    """Derive a document and return it parsed."""

    return json.loads(derive_destination_module_map(observations, source))


def _modules(observations: list[DirectoryObservation]) -> dict[str, object]:
    """Derive a document and return its parsed ``modules`` map."""

    modules = _derive(observations)["modules"]
    assert isinstance(modules, dict)
    return cast("dict[str, object]", modules)


def test_manifest_directory_promoted_to_module() -> None:
    """A directory holding a manifest one level below the root becomes a module."""

    modules = _modules([_observe(""), _observe("service", "pyproject.toml")])

    assert modules["service"] == ["service/**"]


def test_dotnet_manifest_is_structure_not_module() -> None:
    """A .csproj directory is structure; only the payload floor remains."""

    modules = _modules([_observe(""), _observe("Widget", "Widget.csproj")])

    assert list(modules) == ["config"]


def test_root_manifest_never_derives_module() -> None:
    """A root manifest never derives a module or the universal glob."""

    only_root = _modules([_observe("", "package.json")])
    with_nested = _modules(
        [_observe("", "package.json"), _observe("service", "package.json")]
    )

    assert list(only_root) == ["config"]
    assert '"**"' not in json.dumps(only_root)
    assert list(with_nested) == ["config", "service"]


def test_ancestor_pruning_keeps_leaf_projects() -> None:
    """Leaf projects are kept and their umbrella directory is dropped."""

    modules = _modules(
        [
            _observe(""),
            _observe("packages", "package.json"),
            _observe("packages/a", "package.json"),
            _observe("packages/b", "package.json"),
        ]
    )

    assert modules["packages/a"] == ["packages/a/**"]
    assert modules["packages/b"] == ["packages/b/**"]
    assert "packages" not in modules


def test_name_prefix_sibling_not_descendant() -> None:
    """A name-prefix sibling is not pruned as an ancestor."""

    modules = _modules(
        [_observe(""), _observe("pack", "go.mod"), _observe("packages", "go.mod")]
    )

    assert modules["pack"] == ["pack/**"]
    assert modules["packages"] == ["packages/**"]


def test_two_module_go_layout_derives_both_projects() -> None:
    """Both projects of a two-module Go layout are derived."""

    modules = _modules(
        [_observe(""), _observe("Foo", "go.mod"), _observe("Foo.Tests", "go.mod")]
    )

    assert modules["Foo"] == ["Foo/**"]
    assert modules["Foo.Tests"] == ["Foo.Tests/**"]


def test_top_level_fallback_for_src_only_layout() -> None:
    """With only a root manifest, top-level directories become modules."""

    modules = _modules(
        [
            _observe("", "pyproject.toml"),
            _observe("src"),
            _observe("src/app", "main.py"),
        ]
    )

    assert modules["src"] == ["src/**"]
    assert "src/app" not in modules


def test_dotnet_structure_suppresses_top_level_fallback() -> None:
    """Observed .NET structure suppresses the top-level-directory fallback."""

    modules = _modules(
        [_observe(""), _observe("src"), _observe("src/App", "App.csproj")]
    )

    assert modules == FLOOR


def test_empty_destination_emits_payload_modules_only() -> None:
    """An empty destination root yields exactly the payload modules."""

    assert _modules([_observe("")]) == FLOOR


def test_empty_observation_list_emits_payload_modules_only() -> None:
    """An empty observation list yields exactly the payload modules."""

    assert _modules([]) == FLOOR


def test_config_payload_module_wins_name_collision() -> None:
    """A destination config directory with a manifest keeps the payload glob."""

    modules = _modules([_observe(""), _observe("config", "package.json")])

    assert modules["config"] == ["config/**"]


def test_module_names_sorted_ordinally() -> None:
    """Module names sort ordinally: uppercase before lowercase."""

    modules = _modules(
        [
            _observe(""),
            _observe("beta", "go.mod"),
            _observe("Alpha", "go.mod"),
            _observe("alpha", "go.mod"),
        ]
    )

    assert list(modules) == ["Alpha", "alpha", "beta", "config"]


def test_literal_star_directory_yields_nested_glob_not_universal() -> None:
    """A literal ``*`` directory yields ``*/**``, never the bare universal glob."""

    modules = _modules([_observe(""), _observe("*", "package.json")])

    assert modules["*"] == ["*/**"]


def test_keys_emitted_in_fixed_contract_order() -> None:
    """Every carried key is emitted in the fixed contract order."""

    full_source = {
        "over_breadth_fraction": 0.5,
        "path_roots": [],
        "write_intent_extraction": {"enabled": True},
        "conflict_tolerance": {"level": 1},
        "mergeable_paths": ["a"],
        "mandate_reads": ["b"],
        "shared_surface_globs": [],
        "shared_surfaces": [],
        "version": 2,
        "unrelated": "dropped",
    }

    document = _derive([_observe("")], json.dumps(full_source))

    assert list(document) == [
        "version",
        "shared_surfaces",
        "shared_surface_globs",
        "mandate_reads",
        "mergeable_paths",
        "conflict_tolerance",
        "write_intent_extraction",
        "path_roots",
        "modules",
        "over_breadth_fraction",
    ]


def test_absent_optional_source_keys_are_omitted() -> None:
    """Carried keys the source does not declare are omitted, not null."""

    document = _derive([_observe("")])

    assert list(document) == [
        "version",
        "shared_surfaces",
        "shared_surface_globs",
        "modules",
        "over_breadth_fraction",
    ]
    assert "mandate_reads" not in document


def test_carried_keys_copied_verbatim() -> None:
    """The source document's carried keys are copied verbatim."""

    document = _derive([_observe("")])

    for key in ("version", "shared_surfaces", "shared_surface_globs"):
        assert document[key] == SOURCE[key], key
    assert document["over_breadth_fraction"] == SOURCE["over_breadth_fraction"]


def test_output_two_space_indent_trailing_newline() -> None:
    """Output is 2-space indented with exactly one trailing newline."""

    output = derive_destination_module_map([_observe("")], SOURCE_DOCUMENT)

    assert output.endswith("}\n")
    assert not output.endswith("\n\n")
    assert '\n  "version": 1,' in output


def test_identical_inputs_produce_identical_output() -> None:
    """Identical observations and source text produce byte-identical output."""

    observations = [
        _observe(""),
        _observe("service", "pyproject.toml"),
        _observe("web", "package.json"),
    ]

    first = derive_destination_module_map(observations, SOURCE_DOCUMENT)
    second = derive_destination_module_map(observations, SOURCE_DOCUMENT)

    assert second == first


def test_observations_not_mutated() -> None:
    """The supplied observation list is not mutated or reordered."""

    observations = [_observe("b", "go.mod"), _observe("a", "go.mod")]
    before = copy.deepcopy(observations)

    derive_destination_module_map(observations, SOURCE_DOCUMENT)

    assert observations == before
