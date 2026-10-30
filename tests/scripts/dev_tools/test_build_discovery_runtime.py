"""Verify resource staging and closure using deterministic in-memory inputs."""

from __future__ import annotations

import json
import sys
from itertools import permutations
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import cli

# tomllib is stdlib only from Python 3.11; the supported floor 3.10 uses tomli.
if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib

from scripts.dev_tools import build_discovery_runtime as build

if TYPE_CHECKING:
    from drm_copilot_discovery.models import ParseLimits

ROOT = "schemas/discovery/v1"
SCHEMA_PATH = f"{ROOT}/example.schema.json"
SCHEMA = (
    b'{"$id":"urn:example","$defs":{"value":{"type":"string"}},'
    b'"allOf":[{"$ref":"#/$defs/value"}]}\n'
)


def allowlist_text() -> str:
    """Return an isolated one-schema allowlist for staging tests."""
    return json.dumps(
        {"manifest_version": 1, "resource_roots": [ROOT], "resources": [SCHEMA_PATH]}
    )


class MemoryFileSystem:
    """Model declared source bytes and generated writes without disk access."""

    def __init__(self) -> None:
        """Create isolated source/declaration bytes; return None without I/O.

        Literal mutable storage belongs to this test instance only; no parameters
        or expected exceptions. Later test operations record their own writes.
        """
        self.content = {
            build.ALLOWLIST_PATH: allowlist_text().encode(),
            SCHEMA_PATH: SCHEMA,
            f"{build.SOURCE_ROOT}/__init__.py": b"import yaml\n",
            f"{build.SOURCE_ROOT}/nested/__init__.py": b"import hashlib\n",
            f"{build.SOURCE_ROOT}/py.typed": b"",
            f"{build.PACKAGE_ROOT}/pyproject.toml": (
                b'[tool.poetry]\nname="drm-copilot-discovery"\nversion="2.0.0"\n'
                b'[tool.poetry.dependencies]\npython=">=3.10,<4.0"\n'
                b'PyYAML=">=6.0"\njsonschema="^4.25.1"\n'
                b'referencing=">=0.37,<0.38"\nlxml=">=5.3.0"\n'
            ),
        }
        self.writes: list[str] = []

    def read_bytes(self, path: str) -> bytes:
        """Raise the same missing-file error as the disk boundary."""
        if path not in self.content:
            raise FileNotFoundError(path)
        return self.content[path]

    def read_bounded(self, path: str, *, limit: int) -> bytes:
        """Return memory bytes at path (str) within limit (int), without I/O.

        Raises FileNotFoundError for absence and ResourceError for capacity.
        Reads existing immutable content only; no state changes occur.
        """
        content = self.read_bytes(path)
        if len(content) > limit:
            raise build.ResourceError("Memory content exceeds read limit")
        return content

    def write_bytes(self, path: str, content: bytes) -> None:
        """Record each write so check and repeat runs prove their side effects."""
        self.writes.append(path)
        self.content[path] = content

    def list_files(self, root: str) -> tuple[str, ...]:
        """Deliberately reverse enumeration to exercise deterministic sorting."""
        return tuple(
            sorted(
                (path for path in self.content if path.startswith(root + "/")),
                reverse=True,
            )
        )

    def list_build_files(self, *, limits: ParseLimits) -> tuple[str, ...]:
        """Return memory package paths within limits (ParseLimits), without I/O.

        ValueError rejects excess count; local enumeration does not change state.
        """
        result = self.list_files(build.SOURCE_ROOT)
        if len(result) > limits.artifact_records:
            raise ValueError("Memory enumeration exceeds limits")
        return result


def test_project_metadata_matches_runtime_contract() -> None:
    """The committed pyproject declares the runtime version, scripts and dependencies.

    The wheel is built from ``packages/discovery-runtime/pyproject.toml``; this pins
    its contract to the runtime package: the poetry-core backend, the package
    version, one console entry per ``cli.main_*`` function (and no other), exactly
    the approved runtime dependencies, the Python floor, and the typed marker plus
    build manifest in the wheel includes.
    """
    project = tomllib.loads(
        (
            Path(__file__).resolve().parents[3] / build.PACKAGE_ROOT / "pyproject.toml"
        ).read_text(encoding="utf-8")
    )
    poetry = project["tool"]["poetry"]
    scripts: dict[str, str] = poetry["scripts"]

    assert project["build-system"]["build-backend"] == "poetry.core.masonry.api"
    assert poetry["name"] == "drm-copilot-discovery"
    assert poetry["version"] == build.__version__
    # Every console entry targets an existing CLI function, and every CLI entry
    # function is exposed exactly once under the dev.discovery.* namespace.
    targets = sorted(scripts.values())
    assert targets == sorted(set(targets))
    for name, target in scripts.items():
        module, attribute = target.split(":")
        assert name.startswith("dev.discovery.")
        assert module == "drm_copilot_discovery.cli"
        assert callable(getattr(cli, attribute))
    main_functions = sorted(
        f"drm_copilot_discovery.cli:{name}"
        for name in dir(cli)
        if name.startswith("main_") and callable(getattr(cli, name))
    )
    assert targets == main_functions
    dependencies = dict(poetry["dependencies"])
    assert dependencies.pop("python") == ">=3.10,<4.0"
    assert sorted(dependencies) == sorted(build.DEPENDENCY_IMPORTS.values())
    includes = [
        entry if isinstance(entry, str) else entry["path"]
        for entry in poetry["include"]
    ]
    assert includes == [
        "src/drm_copilot_discovery/py.typed",
        f"src/drm_copilot_discovery/{build.BUILD_MANIFEST_PATH.rsplit('/', 1)[1]}",
    ]


def test_stage_then_check_is_idempotent_and_reports_closure() -> None:
    """A completed stage remains unchanged on repeat and passes read-only checks."""
    filesystem = MemoryFileSystem()

    first = build.stage_resources(filesystem)
    writes = list(filesystem.writes)
    second = build.stage_resources(filesystem)
    checked = build.stage_resources(filesystem, check=True)

    assert first["resources"] == [SCHEMA_PATH]
    assert first["changed_paths"] == writes
    assert second["changed_paths"] == checked["changed_paths"] == []
    assert filesystem.writes == writes
    assert first["resource_manifest_sha256"] == second["resource_manifest_sha256"]
    assert first["imported_runtime_dependencies"] == ["PyYAML"]
    assert first["declared_runtime_dependencies"] == [
        "PyYAML",
        "jsonschema",
        "lxml",
        "referencing",
    ]
    assert first["checked_runtime_modules"] == [
        "drm_copilot_discovery",
        "drm_copilot_discovery.nested",
    ]
    assert filesystem.content[f"{build.STAGE_ROOT}/{SCHEMA_PATH}"] == SCHEMA


@pytest.mark.parametrize("order", tuple(permutations(("alpha", "beta", "gamma"))))
def test_stage_bytes_are_order_invariant(order: tuple[str, ...]) -> None:
    """Input and allowlist order cannot alter generated bytes or manifest order."""
    paths = tuple(f"{ROOT}/{name}.schema.json" for name in order)
    inputs = {
        path: json.dumps({"$id": f"urn:{name}"}).encode()
        for path, name in zip(paths, order, strict=True)
    }

    actual = build.make_resource_stage(build.ResourceAllowlist((ROOT,), paths), inputs)
    expected = build.make_resource_stage(
        build.ResourceAllowlist((ROOT,), tuple(sorted(paths))),
        dict(sorted(inputs.items())),
    )

    assert actual == expected
    assert list(actual) == sorted(actual)


@pytest.mark.parametrize("extra", (False, True))
def test_input_mismatch_rejects_missing_and_extra_files(extra: bool) -> None:
    """Canonical source enumeration must equal the explicit allowlist exactly."""
    inputs = {SCHEMA_PATH: SCHEMA, f"{ROOT}/extra.json": b"{}"} if extra else {}

    with pytest.raises(build.ResourceError, match="Resource input mismatch"):
        build.make_resource_stage(build.parse_allowlist(allowlist_text()), inputs)


@pytest.mark.parametrize(
    "text",
    (
        "{",
        "[]",
        "{}",
        '{"manifest_version":true,"resource_roots":[],"resources":[]}',
        '{"manifest_version":1,"resource_roots":{},"resources":[]}',
    ),
)
def test_invalid_allowlist_fails_closed(text: str) -> None:
    """Unsupported versions, keys, and collection types cannot configure staging."""
    with pytest.raises(build.ResourceError):
        build.parse_allowlist(text)


@pytest.mark.parametrize(
    ("roots", "paths"),
    [
        ((), (SCHEMA_PATH,)),
        ((ROOT,), ()),
        ((ROOT, ROOT), (SCHEMA_PATH,)),
        ((ROOT,), (SCHEMA_PATH, SCHEMA_PATH)),
        (("src/secrets",), ("src/secrets/file.json",)),
        (("schemas/discovery", ROOT), (SCHEMA_PATH,)),
        ((ROOT,), ("docs/outside.json",)),
        (("schemas/../outside",), (SCHEMA_PATH,)),
    ],
)
def test_invalid_allowlist_construction_is_rejected(
    roots: tuple[str, ...], paths: tuple[str, ...]
) -> None:
    """Direct construction preserves all root, uniqueness, and path invariants."""
    with pytest.raises(build.ResourceError):
        build.ResourceAllowlist(roots, paths)


@pytest.mark.parametrize(
    "content",
    (
        b"{",
        b"\xff",
        b"[]",
        b"{}",
        b'{"$id":"urn:example","$ref":"https://example.invalid/missing"}',
        b'{"$id":"urn:example","$ref":"#/$defs/missing"}',
    ),
)
def test_schema_closure_rejects_malformed_and_unresolved_schemas(
    content: bytes,
) -> None:
    """Offline closure never retrieves unknown resources or ignores broken pointers."""
    with pytest.raises(build.ResourceError):
        build.verify_schema_closure({SCHEMA_PATH: content})


def test_schema_closure_resolves_local_urns_and_ignores_template_payloads() -> None:
    """All referenced schema resources come from the supplied mapping."""
    inputs = {
        SCHEMA_PATH: SCHEMA,
        f"{ROOT}/caller.schema.json": (
            b'{"$id":"urn:caller","$ref":"urn:example#/$defs/value"}'
        ),
        "docs/discovery/templates/example.yaml": b"draft: true\n",
    }
    assert build.verify_schema_closure(inputs) is None


def test_schema_closure_rejects_duplicate_ids() -> None:
    """Distinct paths cannot conceal an ambiguous schema identity."""
    with pytest.raises(build.ResourceError, match="unique"):
        build.verify_schema_closure(
            {SCHEMA_PATH: SCHEMA, f"{ROOT}/duplicate.schema.json": SCHEMA}
        )


def test_import_closure_distinguishes_stdlib_declared_and_local_modules() -> None:
    """Closure reports only approved dependencies and verifies local module names."""
    modules = {
        "drm_copilot_discovery": (
            "import json\nimport yaml\n"
            "from drm_copilot_discovery.helpers import value\n"
        ),
        "drm_copilot_discovery.helpers": (
            "value = 1\nfrom referencing import Registry\n"
        ),
    }
    assert build.verify_import_closure(modules) == ("PyYAML", "referencing")


@pytest.mark.parametrize(
    "source",
    (
        "import unexpected_library",
        "import drm_copilot_discovery.missing",
        "from .relative import value",
    ),
)
def test_import_closure_rejects_unclosed_imports(source: str) -> None:
    """Missing local modules and undeclared dependencies block the build."""
    with pytest.raises(build.ResourceError):
        build.verify_import_closure({"drm_copilot_discovery": source})


def test_check_fails_without_writing_missing_or_stale_resources() -> None:
    """Read-only checking preserves the store on both missing and stale outputs."""
    filesystem = MemoryFileSystem()
    with pytest.raises(build.ResourceError, match="missing or stale"):
        build.stage_resources(filesystem, check=True)
    assert filesystem.writes == []
    build.stage_resources(filesystem)
    writes = list(filesystem.writes)
    filesystem.content[f"{build.STAGE_ROOT}/{SCHEMA_PATH}"] = b"changed"
    with pytest.raises(build.ResourceError, match="missing or stale"):
        build.stage_resources(filesystem, check=True)
    assert filesystem.writes == writes


def test_extra_staged_resource_is_not_silently_packaged() -> None:
    """An undeclared generated file blocks staging before any write occurs."""
    filesystem = MemoryFileSystem()
    filesystem.content[f"{build.STAGE_ROOT}/unexpected.json"] = b"{}"
    with pytest.raises(build.ResourceError, match="Undeclared staged resources"):
        build.stage_resources(filesystem)
    assert filesystem.writes == []


def test_missing_runtime_package_blocks_resource_staging() -> None:
    """Resource copies are not emitted for an incomplete runtime source package."""
    filesystem = MemoryFileSystem()
    del filesystem.content[f"{build.SOURCE_ROOT}/__init__.py"]
    with pytest.raises(build.ResourceError, match="__init__.py is missing"):
        build.stage_resources(filesystem)
    assert filesystem.writes == []
