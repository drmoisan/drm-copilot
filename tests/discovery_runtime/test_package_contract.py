"""Package extraction contracts and deterministic v1 compatibility properties."""

from __future__ import annotations

import ast
import importlib
import json
from itertools import permutations
from pathlib import Path
from typing import TYPE_CHECKING

import drm_copilot_discovery as runtime
import pytest
from drm_copilot_discovery import domain_profile, domain_profile_models
from drm_copilot_discovery.io import validate_or_raise
from drm_copilot_discovery.rendering import render_pretty_json, sort_rows

from scripts.dev_tools import discovery as compatibility

if TYPE_CHECKING:
    from collections.abc import Iterator

REPOSITORY = Path(__file__).resolve().parents[2]
PACKAGE = REPOSITORY / "packages" / "discovery-runtime"
SOURCE = PACKAGE / "src" / "drm_copilot_discovery"
MODULES = (
    "domain_profile",
    "domain_profile_models",
    "init_models",
    "io",
    "rendering",
)
PROFILE_FIELDS = (
    "profile_version: 1",
    "legacy_source: {root: src/legacy}",
    "target: {root: src/target}",
    "technology_stack: {legacy: [example]}",
    "artifacts: {root: docs/discovery}",
)


def _public_definitions(module_text: str) -> Iterator[str]:
    """Yield public definitions from supplied source without executing any code."""
    # Inspect only top-level definitions: adapters must contain no copied models.
    for node in ast.parse(module_text).body:
        if isinstance(node, (ast.ClassDef, ast.FunctionDef)):
            if not node.name.startswith("_"):
                yield node.name


def test_root_package_reexports_identical_authoritative_values() -> None:
    """Legacy public names resolve to the canonical objects, preserving identity."""
    assert set(compatibility.__all__) == set(runtime.__all__)
    # Check every documented public name so omitted adapters cannot pass silently.
    for name in compatibility.__all__:
        assert getattr(compatibility, name) is getattr(runtime, name), name
    assert runtime.DomainProfile.__module__ == domain_profile_models.__name__
    assert runtime.parse_domain_profile_text.__module__ == domain_profile.__name__


@pytest.mark.parametrize("name", MODULES)
def test_legacy_module_reexports_have_no_duplicate_implementation(name: str) -> None:
    """Adapters preserve their exports without retaining a second semantic engine."""
    legacy = importlib.import_module(f"scripts.dev_tools.discovery.{name}")
    canonical = importlib.import_module(f"drm_copilot_discovery.{name}")
    allowed_local: set[str] = (
        {"resolve_default_template_root"} if name == "init_models" else set()
    )
    # The only non-runtime helper is the repository initializer's path adapter.
    for export in legacy.__all__:
        if export not in allowed_local:
            assert getattr(legacy, export) is getattr(canonical, export), export
    adapter = REPOSITORY / "scripts" / "dev_tools" / "discovery" / f"{name}.py"
    assert (
        set(_public_definitions(adapter.read_text(encoding="utf-8"))) == allowed_local
    )


def test_runtime_metadata_has_bounded_dependencies_and_minimum_python() -> None:
    """The standalone package declares the approved runtime-only dependency set."""
    text = (PACKAGE / "pyproject.toml").read_text(encoding="utf-8")
    dependency_text = text.split("[tool.poetry.dependencies]\n", 1)[1]
    dependency_names = {
        line.split("=", 1)[0].strip()
        for line in dependency_text.splitlines()
        if "=" in line
    }
    assert dependency_names == {"python", "PyYAML", "jsonschema", "referencing", "lxml"}
    assert 'name = "drm-copilot-discovery"' in text
    assert 'version = "2.0.0"' in text
    assert 'python = ">=3.11,<4.0"' in text
    assert 'build-backend = "poetry.core.masonry.api"' in text
    assert runtime.__version__ == "2.0.0"
    assert (SOURCE / "py.typed").is_file()


def test_root_tooling_includes_the_local_runtime_for_types_and_coverage() -> None:
    """Root tooling installs and measures the canonical source package."""
    text = (REPOSITORY / "pyproject.toml").read_text(encoding="utf-8")
    # Read the dependency declaration itself, not an unrelated path occurrence.
    dependency = next(
        line for line in text.splitlines() if line.startswith("drm-copilot-discovery =")
    )
    assert 'path = "packages/discovery-runtime", develop = true' in dependency
    assert '"packages/discovery-runtime/src"' in text.split("[tool.coverage.run]", 1)[1]
    assert '"packages/discovery-runtime/src"' in text.split("[tool.pyright]", 1)[1]


@pytest.mark.parametrize("name", ("__init__", *MODULES))
def test_canonical_modules_do_not_import_repository_tooling(name: str) -> None:
    """The extracted package has no source-checkout dependency or policy lookup."""
    tree = ast.parse((SOURCE / f"{name}.py").read_text(encoding="utf-8"))
    # Import targets are checked structurally so prose references cannot mask drift.
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module:
            assert not node.module.startswith("scripts."), node.module
        elif isinstance(node, ast.Import):
            assert all(not item.name.startswith("scripts.") for item in node.names)


@pytest.mark.parametrize("fields", tuple(permutations(PROFILE_FIELDS)))
def test_v1_profile_is_invariant_under_mapping_order(fields: tuple[str, ...]) -> None:
    """Every top-level ordering produces the same immutable v1 value graph."""
    expected = runtime.parse_domain_profile_text("\n".join(PROFILE_FIELDS))

    actual = runtime.parse_domain_profile_text("\n".join(fields))

    assert actual == expected
    assert hash(actual) == hash(expected)
    assert actual.profile_version == 1


@pytest.mark.parametrize("ids", tuple(permutations(("alpha", "beta", "gamma"))))
def test_rendering_sort_is_idempotent_and_preserves_rows(ids: tuple[str, ...]) -> None:
    """All row permutations sort identically without mutating supplied dictionaries."""
    rows = [{"id": item} for item in ids]

    ordered = sort_rows(rows)

    assert ordered == [{"id": item} for item in sorted(ids)]
    assert sort_rows(ordered) == ordered
    assert rows == [{"id": item} for item in ids]
    assert all(any(result is original for original in rows) for result in ordered)


@pytest.mark.parametrize("keys", tuple(permutations(("alpha", "beta", "gamma"))))
def test_json_rendering_is_order_invariant_and_round_trips(
    keys: tuple[str, ...],
) -> None:
    """Rendering preserves values while producing identical bytes for key orderings."""
    data = dict.fromkeys(keys, "value")

    rendered = render_pretty_json(data)

    assert json.loads(rendered) == data
    assert rendered == render_pretty_json(dict.fromkeys(sorted(keys), "value"))
    assert rendered.endswith("\n") and "\r" not in rendered


@pytest.mark.parametrize("text", ("", "{}", "arbitrary text"))
def test_validation_seam_passes_exact_input_to_supplied_validator(text: str) -> None:
    """Validation neither rewrites caller text nor invents validation outcomes."""
    received: list[str] = []

    def validator(text: str) -> list[str]:
        """Capture the supplied value and return a successful injected result."""
        received.append(text)
        return []

    validate_or_raise(text, validator)

    assert received == [text]
