"""Tests for the manifest vocabulary and classification port (issue #507).

Mirrors
``extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts``.
Every observation is constructed in memory; no filesystem access occurs.
"""

from __future__ import annotations

import json

import pytest

from scripts.dev_tools import push_down_claude_blast_radius_derive_core as core
from scripts.dev_tools.push_down_claude_blast_radius_derive_manifests import (
    EXCLUDED_DIR_NAMES,
    MANIFEST_FILENAMES,
    MANIFEST_SUFFIXES,
    MODULE_MANIFEST_SUFFIXES,
    NON_MODULE_MANIFEST_SUFFIXES,
    DirectoryObservation,
    classify_project_directories,
    compare_ordinal,
    is_excluded_directory_name,
    is_manifest_file_name,
    is_module_manifest_file_name,
    is_non_module_manifest_file_name,
)

SOURCE_DOCUMENT = (
    json.dumps(
        {
            "version": 1,
            "shared_surfaces": [".claude/settings.json"],
            "shared_surface_globs": [],
            "modules": {"config": ["config/**"]},
            "over_breadth_fraction": 0.25,
        },
        indent=2,
    )
    + "\n"
)


def _observe(relative_path: str, *file_names: str) -> DirectoryObservation:
    """Build an observation from a relative path and its shallow file names."""

    return DirectoryObservation(relative_path, tuple(file_names))


def _dotnet_solution(count: int) -> list[DirectoryObservation]:
    """Build the observation list for a .NET solution of ``count`` projects."""

    return [_observe("")] + [
        _observe(f"Proj{index}", f"Proj{index}.csproj") for index in range(1, count + 1)
    ]


def _derive_modules(observations: list[DirectoryObservation]) -> dict[str, object]:
    """Derive a document and return its parsed ``modules`` map."""

    parsed = json.loads(
        core.derive_destination_module_map(observations, SOURCE_DOCUMENT)
    )
    return parsed["modules"]


@pytest.mark.parametrize("file_name", sorted(MANIFEST_FILENAMES))
def test_every_exact_manifest_name_is_a_module_manifest(file_name: str) -> None:
    """Each exact manifest name marks both a project directory and a module."""

    assert is_manifest_file_name(file_name)
    assert is_module_manifest_file_name(file_name)
    assert not is_non_module_manifest_file_name(file_name)


def test_manifest_suffix_families_split_module_and_non_module() -> None:
    """The module family is empty and the non-module family has five members."""

    assert MODULE_MANIFEST_SUFFIXES == ()
    assert NON_MODULE_MANIFEST_SUFFIXES == (
        ".csproj",
        ".fsproj",
        ".vbproj",
        ".sln",
        ".slnx",
    )
    assert MANIFEST_SUFFIXES == MODULE_MANIFEST_SUFFIXES + NON_MODULE_MANIFEST_SUFFIXES


@pytest.mark.parametrize("suffix", MANIFEST_SUFFIXES)
def test_suffix_match_is_manifest_but_not_module(suffix: str) -> None:
    """A suffix-matched .NET file marks structure without making a module."""

    assert is_manifest_file_name(f"Widget{suffix}")
    assert not is_module_manifest_file_name(f"Widget{suffix}")
    assert is_non_module_manifest_file_name(f"Widget{suffix}")


@pytest.mark.parametrize("file_name", ["README.md", "package.json.bak", "main.py"])
def test_non_manifest_names_are_rejected(file_name: str) -> None:
    """A file that is neither an exact name nor a suffix match is rejected."""

    assert not is_manifest_file_name(file_name)
    assert not is_module_manifest_file_name(file_name)
    assert not is_non_module_manifest_file_name(file_name)


def test_excluded_directory_names_include_dot_prefixed_names() -> None:
    """Every bucket name and every dot-prefixed name is excluded."""

    for name in EXCLUDED_DIR_NAMES:
        assert is_excluded_directory_name(name), name
    assert is_excluded_directory_name(".git")
    assert is_excluded_directory_name(".claude")
    assert not is_excluded_directory_name("src")
    assert not is_excluded_directory_name("Foo.Tests")


def test_excluded_directory_names_match_typescript_members() -> None:
    """The exclusion set carries the same members as the TypeScript constant."""

    expected = {"__pycache__", "artifacts", "bin", "build", "coverage", "dist"}
    expected |= {"doc", "docs", "node_modules", "obj", "out", "target"}
    expected |= {"test", "tests", "venv"}

    assert expected == EXCLUDED_DIR_NAMES


@pytest.mark.parametrize(
    ("left", "right", "expected"),
    [("a", "b", -1), ("b", "a", 1), ("a", "a", 0), ("Z", "a", -1)],
)
def test_compare_ordinal_uses_code_point_order(
    left: str, right: str, expected: int
) -> None:
    """Ordinal comparison orders uppercase before lowercase."""

    assert compare_ordinal(left, right) == expected


def test_nine_project_dotnet_layout_has_structure_and_no_modules() -> None:
    """A nine-project .NET layout yields no module path and a structure signal."""

    classification = classify_project_directories(_dotnet_solution(9))

    assert classification.module_paths == ()
    assert classification.structure_observed is True


def test_nine_project_dotnet_layout_derives_only_config() -> None:
    """The structure signal suppresses the fallback, leaving the payload floor."""

    assert _derive_modules(_dotnet_solution(9)) == {"config": ["config/**"]}


def test_nested_solution_file_yields_no_module() -> None:
    """A solution beside a project directory stays at the payload floor."""

    observations = [
        _observe(""),
        _observe("src", "All.sln"),
        _observe("src/App", "App.csproj"),
    ]

    assert _derive_modules(observations) == {"config": ["config/**"]}


def test_mixed_layout_keeps_non_dotnet_module_beside_config() -> None:
    """In a mixed layout the Node module survives and .NET contributes nothing."""

    observations = [
        _observe(""),
        _observe("tools", "package.json"),
        _observe("Proj1", "Proj1.csproj"),
        _observe("Proj2", "Proj2.csproj"),
    ]

    assert sorted(_derive_modules(observations)) == ["config", "tools"]


def test_classification_skips_root_and_sorts_module_paths() -> None:
    """The root is skipped and module paths are returned ordinally sorted."""

    observations = [
        _observe("", "package.json"),
        _observe("b", "go.mod"),
        _observe("a", "go.mod"),
    ]

    classification = classify_project_directories(observations)

    assert classification.module_paths == ("a", "b")
    assert classification.structure_observed is True


def test_classification_reports_no_structure_for_plain_directories() -> None:
    """Directories without manifests report neither modules nor structure."""

    classification = classify_project_directories(
        [_observe(""), _observe("src", "a.py")]
    )

    assert classification.module_paths == ()
    assert classification.structure_observed is False


def test_core_reexports_the_manifest_observation_type() -> None:
    """The core exposes the same observation type the manifests module defines."""

    assert core.DirectoryObservation is DirectoryObservation
