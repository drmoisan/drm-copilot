"""Stage the discovery resource allowlist, verify closure, and build its wheel.

Canonical inputs remain outside the package. Generated copies carry a sorted
SHA-256 manifest and are checked before packaging. The filesystem and wheel
builder are injected boundaries; deterministic transforms require no disk I/O.
"""

from __future__ import annotations

import argparse
import ast
import hashlib
import json
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, Protocol, cast

from drm_copilot_discovery import __version__
from drm_copilot_discovery.resources import (
    MANIFEST_FILENAME,
    RESOURCE_DIRECTORY,
    ResourceError,
    render_resource_manifest,
    validate_resource_path,
)
from referencing import Registry, Resource
from referencing.exceptions import Unresolvable
from referencing.jsonschema import DRAFT202012, Schema

if TYPE_CHECKING:
    from collections.abc import Callable, Mapping, Sequence

PACKAGE_ROOT = "packages/discovery-runtime"
SOURCE_ROOT = f"{PACKAGE_ROOT}/src/drm_copilot_discovery"
STAGE_ROOT = f"{SOURCE_ROOT}/{RESOURCE_DIRECTORY}"
ALLOWLIST_PATH = f"{PACKAGE_ROOT}/resource-manifest.json"
RESOURCE_ROOTS = ("schemas/discovery", "docs/discovery/templates")
DEPENDENCY_IMPORTS = {
    "yaml": "PyYAML",
    "jsonschema": "jsonschema",
    "referencing": "referencing",
    "lxml": "lxml",
}


@dataclass(frozen=True)
class ResourceAllowlist:
    """Declare exact canonical files and the roots checked for unlisted inputs."""

    roots: tuple[str, ...]
    paths: tuple[str, ...]

    def __post_init__(self) -> None:
        """Prevent duplicate, overlapping, or noncanonical resource declarations."""
        for values in (self.roots, self.paths):
            if not values or len(set(values)) != len(values):
                raise ResourceError(
                    "Allowlist roots and resources must be nonempty and unique"
                )
            for value in values:
                validate_resource_path(value)
        for root in self.roots:
            if not any(
                root == parent or root.startswith(parent + "/")
                for parent in RESOURCE_ROOTS
            ):
                raise ResourceError(f"Unapproved canonical resource root: {root}")
            if any(
                root.startswith(other + "/") for other in self.roots if root != other
            ):
                raise ResourceError(f"Overlapping canonical resource root: {root}")
        for path in self.paths:
            if not any(path.startswith(root + "/") for root in self.roots):
                raise ResourceError(f"Resource lies outside declared roots: {path}")


class BuildFileSystem(Protocol):
    """Confine staging I/O to repository-relative byte operations."""

    def read_bytes(self, path: str) -> bytes:
        """Read a declared repository-relative file or raise its I/O error."""
        ...

    def write_bytes(self, path: str, content: bytes) -> None:
        """Write a generated file and create missing parent directories."""
        ...

    def list_files(self, root: str) -> tuple[str, ...]:
        """List all file paths below a repository-relative root."""
        ...


@dataclass(frozen=True)
class DiskBuildFileSystem:
    """Keep actual filesystem resolution outside deterministic staging logic."""

    root: Path

    def _path(self, relative: str) -> Path:
        """Reject lexical and resolved escapes before any filesystem operation."""
        validate_resource_path(relative)
        root = self.root.resolve()
        path = (root / relative).resolve()
        if not path.is_relative_to(root):
            raise ResourceError(
                f"Resource path resolves outside the repository: {relative}"
            )
        return path

    def read_bytes(self, path: str) -> bytes:
        """Read a contained file, propagating missing or unreadable inputs."""
        return self._path(path).read_bytes()

    def write_bytes(self, path: str, content: bytes) -> None:
        """Write only a contained generated-resource path."""
        if not path.startswith(STAGE_ROOT + "/"):
            raise ResourceError(
                f"Writes are restricted to generated package resources: {path}"
            )
        target = self._path(path)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(content)

    def list_files(self, root: str) -> tuple[str, ...]:
        """Return stable paths while rejecting any file that resolves outside root."""
        directory = self._path(root)
        paths = tuple(
            sorted(
                path.relative_to(self.root.resolve()).as_posix()
                for path in directory.rglob("*")
                if path.is_file()
            )
        )
        for path in paths:
            self._path(path)
        return paths


def parse_allowlist(text: str) -> ResourceAllowlist:
    """Validate the canonical allowlist without accepting arbitrary source roots."""
    try:
        document: object = json.loads(text)
    except json.JSONDecodeError as error:
        raise ResourceError(f"Invalid resource allowlist JSON: {error.msg}") from error
    if not isinstance(document, dict):
        raise ResourceError("Allowlist must be an object")
    values = cast("dict[str, object]", document)
    if set(values) != {
        "manifest_version",
        "resource_roots",
        "resources",
    }:
        raise ResourceError(
            "Allowlist requires manifest_version, resource_roots, and resources"
        )
    if type(values["manifest_version"]) is not int or values["manifest_version"] != 1:
        raise ResourceError("Unsupported resource allowlist version; expected 1")
    lists: list[tuple[str, ...]] = []
    for key in ("resource_roots", "resources"):
        raw = values[key]
        if not isinstance(raw, list):
            raise ResourceError(f"Allowlist {key} must be a list")
        lists.append(
            tuple(validate_resource_path(item) for item in cast("list[object]", raw))
        )
    return ResourceAllowlist(lists[0], lists[1])


def _schema_references(value: object) -> tuple[str, ...]:
    """Collect reference keywords without interpreting schema product semantics."""
    found: list[str] = []
    pending = [value]
    while pending:
        current = pending.pop()
        if isinstance(current, dict):
            mapping = cast("dict[str, object]", current)
            for key, child in mapping.items():
                if key in {"$ref", "$dynamicRef"} and isinstance(child, str):
                    found.append(child)
                else:
                    pending.append(child)
        elif isinstance(current, list):
            pending.extend(cast("list[object]", current))
    return tuple(sorted(set(found)))


def verify_schema_closure(resources: Mapping[str, bytes]) -> None:
    """Resolve schema references only from the staged offline resource set."""
    documents: dict[str, Schema] = {}
    for path, content in sorted(resources.items()):
        if path.endswith(".schema.json"):
            try:
                document: object = json.loads(content)
            except (json.JSONDecodeError, UnicodeError) as error:
                raise ResourceError(
                    f"Invalid schema JSON at {path}: {error}"
                ) from error
            if not isinstance(document, dict):
                raise ResourceError(f"Schema must be an object: {path}")
            identifier = cast("dict[str, object]", document).get("$id")
            if (
                not isinstance(identifier, str)
                or not identifier
                or identifier in documents
            ):
                raise ResourceError(f"Schema requires a unique nonempty $id: {path}")
            documents[identifier] = cast("dict[str, object]", document)
    registry = Registry[Schema]().with_resources(
        (
            identifier,
            Resource[Schema].from_contents(document, default_specification=DRAFT202012),
        )
        for identifier, document in documents.items()
    )
    for identifier, document in documents.items():
        for reference in _schema_references(document):
            try:
                registry.resolver(identifier).lookup(reference)
            except Unresolvable as error:
                raise ResourceError(
                    f"Unresolved offline schema reference in {identifier}: {reference}"
                ) from error


def make_resource_stage(
    allowlist: ResourceAllowlist, inputs: Mapping[str, bytes]
) -> dict[str, bytes]:
    """Reject missing or extra inputs and produce one deterministic resource set."""
    expected, actual = set(allowlist.paths), set(inputs)
    if expected != actual:
        raise ResourceError(
            f"Resource input mismatch; missing={sorted(expected - actual)}, "
            f"extra={sorted(actual - expected)}"
        )
    verify_schema_closure(inputs)
    stage = dict(sorted(inputs.items()))
    stage[MANIFEST_FILENAME] = render_resource_manifest(inputs)
    return dict(sorted(stage.items()))


def verify_import_closure(modules: Mapping[str, str]) -> tuple[str, ...]:
    """Reject undeclared third-party and absent absolute local imports statically."""
    external: set[str] = set()
    for module_name, source in sorted(modules.items()):
        for node in ast.walk(ast.parse(source, filename=module_name)):
            targets: tuple[str, ...] = ()
            if isinstance(node, ast.Import):
                targets = tuple(alias.name for alias in node.names)
            elif isinstance(node, ast.ImportFrom):
                if node.level:
                    raise ResourceError(
                        "Runtime import closure requires explicit absolute imports: "
                        f"{module_name}"
                    )
                targets = (node.module,) if node.module else ()
            for target in targets:
                root = target.split(".", 1)[0]
                if root == "drm_copilot_discovery":
                    if target not in modules:
                        raise ResourceError(
                            f"Missing runtime import {target} in {module_name}"
                        )
                elif root in DEPENDENCY_IMPORTS:
                    external.add(DEPENDENCY_IMPORTS[root])
                elif root not in sys.stdlib_module_names:
                    raise ResourceError(
                        f"Undeclared runtime dependency {target} in {module_name}"
                    )
    return tuple(sorted(external))


def stage_resources(
    filesystem: BuildFileSystem, *, check: bool = False
) -> dict[str, object]:
    """Verify complete canonical inputs/imports before writing generated resources."""
    allowlist = parse_allowlist(filesystem.read_bytes(ALLOWLIST_PATH).decode("utf-8"))
    paths = {path for root in allowlist.roots for path in filesystem.list_files(root)}
    inputs = {path: filesystem.read_bytes(path) for path in sorted(paths)}
    stage = make_resource_stage(allowlist, inputs)
    modules: dict[str, str] = {}
    for path in filesystem.list_files(SOURCE_ROOT):
        if path.endswith(".py"):
            suffix = path.removeprefix(SOURCE_ROOT + "/")[:-3].replace("/", ".")
            module = "drm_copilot_discovery" + (
                "." + suffix if suffix != "__init__" else ""
            )
            modules[module.removesuffix(".__init__")] = filesystem.read_bytes(
                path
            ).decode("utf-8")
    if "drm_copilot_discovery" not in modules:
        raise ResourceError("Canonical runtime package __init__.py is missing")
    imported_dependencies = verify_import_closure(modules)
    expected = {f"{STAGE_ROOT}/{name}": content for name, content in stage.items()}
    existing = set(filesystem.list_files(STAGE_ROOT))
    if existing - set(expected):
        raise ResourceError(
            f"Undeclared staged resources: {sorted(existing - set(expected))}"
        )
    changed = tuple(
        path
        for path, content in expected.items()
        if path not in existing or filesystem.read_bytes(path) != content
    )
    if check and changed:
        raise ResourceError(
            f"Generated resources are missing or stale: {list(changed)}"
        )
    if not check:
        for path in changed:
            filesystem.write_bytes(path, expected[path])
    return {
        "runtime_version": __version__,
        "resources": sorted(inputs),
        "resource_manifest_sha256": hashlib.sha256(
            stage[MANIFEST_FILENAME]
        ).hexdigest(),
        "declared_runtime_dependencies": sorted(DEPENDENCY_IMPORTS.values()),
        "imported_runtime_dependencies": list(imported_dependencies),
        "checked_runtime_modules": sorted(modules),
        "changed_paths": list(changed),
    }


def build_wheel(repository: Path, output: Path) -> Path:
    """Build locally with the approved backend without resolving dependencies."""
    executable = shutil.which(sys.executable)
    if executable is None:
        raise ResourceError(
            "The active Python executable is unavailable for wheel building"
        )
    output.mkdir(parents=True, exist_ok=True)
    result = (
        subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
            [
                executable,
                "-m",
                "pip",
                "wheel",
                "--no-index",
                "--no-deps",
                "--no-build-isolation",
                "--wheel-dir",
                str(output),
                str(repository / PACKAGE_ROOT),
            ],
            capture_output=True,
            text=True,
            check=False,
        )
    )
    if result.returncode:
        raise ResourceError(
            "Wheel build failed; install the approved poetry-core build backend: "
            f"{result.stderr.strip() or result.stdout.strip()}"
        )
    wheel = output / f"drm_copilot_discovery-{__version__}-py3-none-any.whl"
    if not wheel.is_file():
        raise ResourceError(f"Build did not produce the expected wheel: {wheel.name}")
    return wheel


def main(
    argv: Sequence[str] | None = None,
    *,
    filesystem: BuildFileSystem | None = None,
    wheel_builder: Callable[[Path, Path], Path] = build_wheel,
    read_wheel: Callable[[Path], bytes] = Path.read_bytes,
) -> int:
    """Expose noninteractive stage/check/build operations with actionable failures."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--repository", type=Path, default=Path(__file__).resolve().parents[2]
    )
    parser.add_argument("--output", type=Path, default=Path("dist/discovery"))
    parser.add_argument(
        "--check",
        action="store_true",
        help="Verify staged bytes without writing or building",
    )
    parser.add_argument(
        "--stage-only",
        action="store_true",
        help="Stage resources without building a wheel",
    )
    args = parser.parse_args(argv)
    repository = cast("Path", args.repository).resolve()
    output = cast("Path", args.output)
    output = output if output.is_absolute() else repository / output
    try:
        report = stage_resources(
            filesystem or DiskBuildFileSystem(repository), check=bool(args.check)
        )
        if not args.check and not args.stage_only:
            wheel = wheel_builder(repository, output)
            report["wheel"] = wheel.name
            report["wheel_sha256"] = hashlib.sha256(read_wheel(wheel)).hexdigest()
        print(json.dumps(report, indent=2, sort_keys=True))
    except (ResourceError, OSError, UnicodeError, SyntaxError) as error:
        print(f"Discovery runtime build: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
