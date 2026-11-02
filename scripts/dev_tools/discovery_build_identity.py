"""Prepare installed-content identity after the existing resource stage freezes.

All inputs come from the fixed runtime package. The build filesystem is injected;
unit tests use memory. This helper neither refreshes resources nor builds wheels.
"""

from __future__ import annotations

import tomllib
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.build_identity import (
    BUILD_MANIFEST,
    DEFAULT_LIMITS,
    build_file_paths,
    build_path_metadata,
    capture_build_payload,
    project_build_manifest,
    verify_build_identity,
)
from drm_copilot_discovery.models import JsonObject, JsonValue, ParseLimits
from drm_copilot_discovery.report_models import ReportBudget
from drm_copilot_discovery.resources import ResourceError

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    from scripts.dev_tools.build_discovery_runtime import BuildFileSystem

PACKAGE_ROOT = "packages/discovery-runtime"
SOURCE_ROOT = f"{PACKAGE_ROOT}/src/drm_copilot_discovery"
BUILD_MANIFEST_PATH = f"{SOURCE_ROOT}/{BUILD_MANIFEST}"
PROJECT_PATH = f"{PACKAGE_ROOT}/pyproject.toml"


def list_build_source_files(
    repository: Path, *, limits: ParseLimits = DEFAULT_LIMITS
) -> tuple[str, ...]:
    """Enumerate the fixed package below repository (Path) within limits.

    Returns repository-relative file names. ValueError/OSError rejects links,
    unusual members, access or capacity failures before retaining excess work.
    Performs directory metadata reads only; never reads or executes source.
    """
    root = repository
    # Reject every fixed-root ancestor before traversal can follow a link.
    for part in ("", *SOURCE_ROOT.split("/")):
        root = root / part if part else root
        build_path_metadata(root)
    paths = build_file_paths(root, limits=limits)
    budget = ReportBudget(limits)
    budget.spend(sum(len(SOURCE_ROOT) + len(path) + 1 for path in paths))
    return tuple(SOURCE_ROOT + "/" + path for path in paths)


def package_metadata(
    content: bytes, *, limits: ParseLimits = DEFAULT_LIMITS
) -> JsonObject:
    """Extract inert package declarations from content (bytes) under limits.

    Returns bounded immutable metadata; ResourceError rejects unsupported or
    excessive TOML. Does not import, install or execute declared dependencies.
    """
    if type(content) is not bytes or len(content) > min(limits.document_bytes, 65536):
        raise ResourceError("Package metadata exceeds limits")
    # Bound dotted/container syntax before the standard TOML decoder allocates.
    if sum(content.count(token) for token in (b".", b"[", b"{")) > 1024:
        raise ResourceError("Package metadata exceeds syntax limits")
    loads = cast("Callable[[str], object]", tomllib.loads)
    try:
        decoded = loads(content.decode("utf-8"))
        ReportBudget(limits).check(decoded)
        document = cast("dict[str, object]", decoded)
        tool = document.get("tool")
        if type(tool) is not dict:
            raise ValueError("Missing tool metadata")
        poetry = cast("dict[str, object]", tool).get("poetry")
        if type(poetry) is not dict:
            raise ValueError("Missing package metadata")
        values = cast("dict[str, object]", poetry)
        dependencies = values.get("dependencies")
        if type(dependencies) is not dict:
            raise ValueError("Missing dependency metadata")
        declared = cast("dict[str, object]", dependencies)
        # Only literal requirement strings enter the immutable identity projection.
        if any(type(value) is not str for value in declared.values()):
            raise ValueError("Dependency declarations must be literal")
        name, version = values.get("name"), values.get("version")
        if type(name) is not str or type(version) is not str:
            raise ValueError("Package identity requires strings")
        requirements = JsonObject(
            tuple(
                (key, cast("str", value))
                for key, value in declared.items()
                if key != "python"
            )
        )
        python = declared.get("python")
        if type(python) is not str:
            raise ValueError("Python requirement is missing")
        return JsonObject(
            (
                ("name", name),
                ("version", version),
                ("python", python),
                ("dependencies", requirements),
            )
        )
    except (ValueError, UnicodeError, RecursionError) as error:
        raise ResourceError("Invalid package identity metadata") from error


class _RepositoryStore:
    """Adapt a fixed source root to the runtime's bounded capture protocol.

    filesystem (BuildFileSystem) owns repository I/O. This adapter only enumerates
    and reads; resource refresh and generated manifest writes remain caller-owned.
    """

    def __init__(self, filesystem: BuildFileSystem) -> None:
        """Retain filesystem (BuildFileSystem); return None without I/O."""
        self.filesystem = filesystem

    def paths(self, *, limits: ParseLimits) -> tuple[str, ...]:
        """Return fixed-root paths bounded by limits (ParseLimits).

        ResourceError rejects a foreign enumeration or excessive count/text.
        Reads directory metadata only; no source bytes or mutations occur.
        """
        paths = self.filesystem.list_build_files(limits=limits)
        if type(paths) is not tuple or len(paths) > limits.artifact_records:
            raise ResourceError("Build source enumeration exceeds limits")
        budget = ReportBudget(limits)
        budget.work(len(paths))
        result: list[str] = []
        # Validate containment before removing the only allowed source prefix.
        for path in paths:
            if type(path) is not str:
                raise ResourceError("Invalid build source path")
            budget.work(len(path))
            budget.text(path)
            if not path.startswith(SOURCE_ROOT + "/"):
                raise ResourceError("Build source lies outside package")
            result.append(path[len(SOURCE_ROOT) + 1 :])
        return tuple(result)

    def read_bytes(self, path: str, *, limit: int) -> bytes:
        """Read relative path (str), rejecting content beyond limit (int).

        Returns immutable bytes; ResourceError rejects a boundary contract
        violation. The underlying approved build filesystem performs the read.
        """
        content = self.filesystem.read_bounded(f"{SOURCE_ROOT}/{path}", limit=limit)
        if type(content) is not bytes or len(content) > limit:
            raise ResourceError("Build source content exceeds limits")
        return content


def stage_build_identity(
    filesystem: BuildFileSystem,
    *,
    check: bool = False,
    limits: ParseLimits = DEFAULT_LIMITS,
) -> dict[str, JsonValue]:
    """Stage or check identity after resources using filesystem (BuildFileSystem).

    check (bool) forbids writes; limits (ParseLimits) bounds pure capture/projection.
    Returns digest/policy/change metadata. ResourceError, ServiceRuntimeError or
    OSError blocks stale/changing inputs. Writes only the exact generated manifest
    after all reads/checks succeed; never refreshes resource files.
    """
    if type(check) is not bool:
        raise ResourceError("Build check mode must be boolean")
    project = filesystem.read_bounded(
        PROJECT_PATH, limit=min(limits.document_bytes, 65536)
    )
    package = package_metadata(project, limits=limits)
    payload = capture_build_payload(store=_RepositoryStore(filesystem), limits=limits)
    manifest = project_build_manifest(payload, package=package, limits=limits)
    identity = verify_build_identity(manifest, payload, limits=limits)
    if filesystem.read_bounded(PROJECT_PATH, limit=len(project)) != project:
        raise ResourceError("Package declarations changed during capture")
    try:
        existing = filesystem.read_bounded(
            BUILD_MANIFEST_PATH, limit=limits.document_bytes
        )
    except FileNotFoundError:
        existing = None
    changed = existing != manifest
    if check and changed:
        raise ResourceError("Installed build manifest is missing or stale")
    # Check mode and idempotent repeats never rewrite generated content.
    if changed and not check:
        filesystem.write_bytes(BUILD_MANIFEST_PATH, manifest)
    return {
        "build_sha256": identity.build_sha256,
        "policy_version": identity.policy_version,
        "policy_sha256": identity.policy_sha256,
        "build_manifest_changed": changed,
    }
