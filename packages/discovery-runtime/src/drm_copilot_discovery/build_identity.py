"""Bind installed Python and resources to deterministic, verified build content.

The manifest describes content, not a signed release or native authority. Pure
projection and verification accept immutable bytes; the fixed package adapter
alone reads installation files. No dependency or supplied module is executed.
"""

from __future__ import annotations

import stat
from hashlib import sha256
from importlib.resources import files
from os import lstat, scandir
from pathlib import Path
from typing import TYPE_CHECKING, Protocol, cast

from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.path_models import relative_path
from drm_copilot_discovery.report_models import ReportBudget
from drm_copilot_discovery.resources import render_resource_manifest
from drm_copilot_discovery.snapshot import VERSIONS

if TYPE_CHECKING:
    from os import stat_result
    from typing import Literal, NoReturn

    from drm_copilot_discovery.service_contracts import RuntimeIdentity

BUILD_MANIFEST = "_build_manifest.json"
DEFAULT_LIMITS = ParseLimits()
DEPENDENCIES = ("PyYAML", "jsonschema", "lxml", "referencing")
_REQUIREMENT_CHARACTERS = (
    "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.*^<>=!~|,+- "
)
Payload = tuple[tuple[str, bytes], ...]


def _fail(code: Literal["RUNTIME_UNAVAILABLE", "RUNTIME_CORRUPT"]) -> NoReturn:
    """Raise the fixed service failure for code (literal); never return.

    Imports the shared error lazily to keep packaging projection independent of
    service initialization. No raw error data or external state is retained.
    """
    from drm_copilot_discovery.service_contracts import ServiceRuntimeError

    raise ServiceRuntimeError(code=code) from None


def _path(path: str, budget: ReportBudget) -> None:
    """Validate path (str) before splitting under budget; return None.

    ValueError rejects noncanonical paths; budget excess propagates. Only the
    local budget changes. Selected payloads additionally reject capitals.
    """
    if type(path) is not str or not path:
        raise ValueError("Invalid package path")
    budget.work(len(path))
    budget.text(path)
    if any(
        c not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_./-"
        for c in path
    ):
        raise ValueError("Invalid package path")
    relative_path(path)
    parts = path.split("/")
    if len(parts) > budget.limits.nesting_depth or any(
        part in ("", ".", "..") or part.endswith((".", " ")) for part in parts
    ):
        raise ValueError("Package path exceeds syntax or nesting limits")


def select_build_paths(
    paths: tuple[str, ...], *, limits: ParseLimits = DEFAULT_LIMITS
) -> tuple[str, ...]:
    """Return the sorted payload subset of paths (immutable tuple[str, ...]).

    Excludes only the manifest, bytecode and distribution metadata. Unknown
    package members, collisions or capacity excess raise ValueError. No I/O or
    mutation occurs; this is a build/reader seam, not caller-selected roots.
    """
    budget = ReportBudget(limits)
    if type(paths) is not tuple or len(paths) > limits.artifact_records:
        raise ValueError("Invalid package enumeration")
    budget.work(len(paths) * max(1, len(paths).bit_length()))
    seen: set[str] = set()
    selected: list[str] = []
    # Check all names, including excluded members, before retaining any payload.
    for path in paths:
        _path(path, budget)
        if path in seen:
            raise ValueError("Duplicate package path")
        seen.add(path)
        parts = path.split("/")
        # These installation-generated members do not belong to source identity.
        if (
            path == BUILD_MANIFEST
            or path.endswith(".pyc")
            or any(part.endswith(".dist-info") for part in parts)
        ):
            continue
        if path != path.lower():
            raise ValueError("Noncanonical package path case")
        if not (
            (path.endswith(".py") and not path.startswith("_resources/"))
            or path == "py.typed"
            or path == "_resources/manifest.json"
            or path.startswith(
                (
                    "_resources/schemas/discovery/",
                    "_resources/docs/discovery/templates/",
                )
            )
        ):
            raise ValueError("Unexpected package member")
        selected.append(path)
    # A path cannot be both a file and the ancestor of another file.
    for path in selected:
        parts = path.split("/")
        budget.work(len(path) * len(parts))
        if any("/".join(parts[:index]) in seen for index in range(1, len(parts))):
            raise ValueError("File-directory package collision")
    if not {"__init__.py", "py.typed", "_resources/manifest.json"}.issubset(selected):
        raise ValueError("Incomplete package payload")
    return tuple(sorted(selected))


def _package(package: JsonObject, budget: ReportBudget) -> None:
    """Validate package (JsonObject) metadata within budget; return None.

    Rejects arbitrary package/dependency identities and executable declarations
    with ValueError. Only local budget state changes; no dependencies are read.
    """
    if type(package) is not JsonObject:
        raise ValueError("Invalid package metadata")
    budget.check(package)
    if (
        set(package) != {"name", "version", "python", "dependencies"}
        or package["name"] != "drm-copilot-discovery"
        or package["version"] != dict(VERSIONS)["runtime"]
    ):
        raise ValueError("Invalid package metadata")
    dependencies = package["dependencies"]
    if type(dependencies) is not JsonObject or set(dependencies) != set(DEPENDENCIES):
        raise ValueError("Invalid dependency declaration")
    # Requirements remain inert constrained strings, never URLs or executable data.
    for value in (package["python"], *dependencies.values()):
        if type(value) is not str or not value or len(value) > 4096:
            raise ValueError("Invalid dependency requirement")
        budget.work(len(value))
        if any(c not in _REQUIREMENT_CHARACTERS for c in value):
            raise ValueError("Invalid dependency requirement")


def _project(payload: Payload, package: JsonObject, limits: ParseLimits) -> bytes:
    """Project payload (Payload)/package (JsonObject) under limits (ParseLimits).

    Returns canonical manifest bytes. ValueError rejects integrity/resource
    failures; no I/O occurs and source byte objects remain immutable.
    """
    budget = ReportBudget(limits)
    _package(package, budget)
    if type(payload) is not tuple or len(payload) > limits.artifact_records:
        raise ValueError("Invalid build payload")
    budget.work(len(payload))
    paths: list[str] = []
    total = 0
    # Reserve complete input bytes before hashing, sorting or building dictionaries.
    for pair in payload:
        if type(pair) is not tuple or len(pair) != 2:
            raise ValueError("Invalid build entry")
        path, content = pair
        _path(path, budget)
        if type(content) is not bytes:
            raise ValueError("Invalid build content")
        budget.spend(len(content))
        total += len(content)
        paths.append(path)
    selected = select_build_paths(tuple(paths), limits=limits)
    if len(selected) != len(payload):
        raise ValueError("Excluded bytes cannot be manifest entries")
    budget.work(total + len(payload) * max(1, len(payload).bit_length()))
    content_by_path = dict(payload)
    entries: list[JsonObject] = []
    resources: dict[str, bytes] = {}
    resource_rows: list[dict[str, object]] = []
    # Entries bind all source bytes; the resource manifest must bind its own closure.
    for path in selected:
        content = content_by_path[path]
        row = {
            "path": path,
            "size": len(content),
            "sha256": sha256(content).hexdigest(),
        }
        budget.check(row)
        entries.append(JsonObject(tuple(row.items())))
        if path.startswith("_resources/") and path != "_resources/manifest.json":
            relative = path.removeprefix("_resources/")
            resources[relative] = content
            resource_rows.append(
                {
                    "path": relative,
                    "size": len(content),
                    "sha256": entries[-1]["sha256"],
                }
            )
    if not resources:
        raise ValueError("Empty resource closure")
    # Reserve the accepted pretty resource representation before it is allocated.
    ReportBudget(limits, pretty=True).check(
        {
            "manifest_version": 1,
            "runtime_version": dict(VERSIONS)["runtime"],
            "resources": resource_rows,
        }
    )
    if (
        render_resource_manifest(resources)
        != content_by_path["_resources/manifest.json"]
    ):
        raise ValueError("Resource closure differs")
    # The separately labelled policy projection includes code and all resources.
    policy = JsonObject(
        (
            ("domain", "drm-copilot-discovery-policy"),
            ("policy_version", dict(VERSIONS)["policy"]),
            ("files", tuple(entry for entry in entries if entry["path"] != "py.typed")),
        )
    )
    ReportBudget(limits).check(policy)
    document = JsonObject(
        (
            ("manifest_version", 1),
            ("package", package),
            ("schema_version", dict(VERSIONS)["schema"]),
            ("policy_version", dict(VERSIONS)["policy"]),
            ("policy_sha256", sha256(canonical_json(policy)).hexdigest()),
            ("files", tuple(entries)),
        )
    )
    ReportBudget(limits).check(document)
    return canonical_json(document)


def project_build_manifest(
    payload: Payload, *, package: JsonObject, limits: ParseLimits = DEFAULT_LIMITS
) -> bytes:
    """Return deterministic manifest bytes for payload/package under limits.

    payload (Payload) and package (JsonObject) must be immutable complete inputs.
    ServiceRuntimeError(RUNTIME_CORRUPT) rejects shape/closure/resource failures.
    No file is generated and no installed or host authority is established.
    """
    try:
        return _project(payload, package, limits)
    except ValueError:
        _fail("RUNTIME_CORRUPT")


def verify_build_identity(
    manifest: bytes, payload: Payload, *, limits: ParseLimits = DEFAULT_LIMITS
) -> RuntimeIdentity:
    """Verify exact manifest (bytes) against complete payload (Payload).

    Returns RuntimeIdentity with the installed-content hash, never a wheel hash.
    limits (ParseLimits) bounds decoding/projection. ServiceRuntimeError rejects
    malformed, stale, noncanonical or mismatched data; no I/O occurs.
    """
    from drm_copilot_discovery.service_contracts import RuntimeIdentity

    if type(manifest) is not bytes:
        _fail("RUNTIME_CORRUPT")
    parsed = parse_document(manifest, format="json", limits=limits)
    if parsed.value is None or type(parsed.value.get("package")) is not JsonObject:
        _fail("RUNTIME_CORRUPT")
    document = parsed.value
    expected = project_build_manifest(
        payload, package=cast("JsonObject", document["package"]), limits=limits
    )
    if manifest != expected:
        _fail("RUNTIME_CORRUPT")
    return RuntimeIdentity(
        package_version=dict(VERSIONS)["runtime"],
        schema_version=dict(VERSIONS)["schema"],
        build_sha256=sha256(manifest).hexdigest(),
        policy_version=2,
        policy_sha256=cast("str", document["policy_sha256"]),
    )


class InstalledBuildStore(Protocol):
    """Supply bounded fixed-package enumeration/reads without dependency execution.

    Production uses PackageBuildStore; tests supply memory. Implementations must
    reject links/escapes and honor limits before allocating returned content.
    """

    def paths(self, *, limits: ParseLimits) -> tuple[str, ...]:
        """Return package-relative files bounded by limits (ParseLimits).

        Raises OSError/ValueError on access, unsafe names or capacity. Read-only.
        """
        ...

    def read_bytes(self, path: str, *, limit: int) -> bytes:
        """Read path (str) with limit (int) before allocation; return bytes.

        Raises OSError/ValueError on access/size failures. Performs read-only I/O.
        """
        ...


class PackageBuildStore:
    """Read only the fixed installed package through importlib resources.

    No constructor-selected package/root is accepted. Streaming traversal rejects
    links/reparse points; unsupported resource stores fail closed. Read-only.
    """

    def paths(self, *, limits: ParseLimits) -> tuple[str, ...]:
        """Enumerate the fixed package under limits (ParseLimits); return paths.

        Raises OSError/ValueError for inaccessible, linked or excessive content.
        Traverses directories without reading source or executing modules.
        """
        root = files("drm_copilot_discovery")
        if not isinstance(root, Path):
            raise ValueError("Unsupported installation resource store")
        return build_file_paths(root, limits=limits)

    def read_bytes(self, path: str, *, limit: int) -> bytes:
        """Read fixed-package path (str) within limit (int); return exact bytes.

        Raises OSError/ValueError for links, invalid paths or oversized content.
        Reads at most limit+1 bytes; never imports a selected module.
        """
        if type(limit) is not int or not 0 <= limit <= 64 * 1024 * 1024:
            raise ValueError("Invalid installed read limit")
        _path(path, ReportBudget(DEFAULT_LIMITS))
        member = files("drm_copilot_discovery")
        if not isinstance(member, Path):
            raise ValueError("Unsupported installation resource store")
        build_path_metadata(member)
        # Check each ancestor before opening so symlinks cannot redirect reads.
        for part in path.split("/"):
            member = member.joinpath(part)
            build_path_metadata(member)
        with member.open("rb") as stream:
            content = stream.read(limit + 1)
        if len(content) > limit:
            raise ValueError("Installed member exceeds limits")
        return content


def build_path_metadata(path: Path) -> stat_result:
    """Return non-following metadata for trusted build path (Path); read-only.

    ValueError rejects links, Windows reparse points and unusual file types on
    every supported Python version; OSError propagates access failures.
    """
    info = lstat(path)
    if stat.S_ISLNK(info.st_mode) or getattr(info, "st_file_attributes", 0) & 0x400:
        raise ValueError("Linked build member")
    if not (stat.S_ISREG(info.st_mode) or stat.S_ISDIR(info.st_mode)):
        raise ValueError("Unsupported build member")
    return info


def build_file_paths(
    root: Path, *, limits: ParseLimits = DEFAULT_LIMITS
) -> tuple[str, ...]:
    """Stream relative file names below trusted root (Path) under limits.

    Returns immutable names after prospective count/text/depth checks. ValueError
    rejects excess or unsafe names/metadata; OSError propagates. Reads metadata
    only and closes each scanner even on failure; no caller-selected provider.
    """
    budget = ReportBudget(limits)
    pending = [(root, "")]
    found: list[str] = []
    count = 0
    # scandir yields one entry at a time; reject the first excess before retention.
    while pending:
        parent, prefix = pending.pop()
        build_path_metadata(parent)
        with scandir(parent) as entries:
            for entry in entries:
                count += 1
                if count > limits.artifact_records:
                    raise ValueError("Build enumeration exceeds limits")
                budget.spend(len(prefix) + len(entry.name))
                path = prefix + entry.name
                _path(path, budget)
                child = parent / entry.name
                info = build_path_metadata(child)
                if stat.S_ISDIR(info.st_mode):
                    pending.append((child, path + "/"))
                else:
                    found.append(path)
    return tuple(found)


def capture_build_payload(
    *, store: InstalledBuildStore, limits: ParseLimits = DEFAULT_LIMITS
) -> Payload:
    """Capture and recheck store (InstalledBuildStore) under limits (ParseLimits).

    Returns immutable complete payload. ValueError/OSError rejects excessive or
    changing input. Only store reads occur; no generated file is written.
    """
    paths = select_build_paths(store.paths(limits=limits), limits=limits)
    payload: list[tuple[str, bytes]] = []
    remaining = limits.document_bytes
    # One retained copy per member is bounded by the aggregate input capacity.
    for path in paths:
        content = store.read_bytes(path, limit=remaining)
        if type(content) is not bytes or len(content) > remaining:
            raise ValueError("Payload exceeds limits")
        remaining -= len(content)
        payload.append((path, content))
    if select_build_paths(store.paths(limits=limits), limits=limits) != paths:
        raise ValueError("Package membership changed")
    # Re-read exact original lengths to reject changes during capture.
    for path, content in payload:
        if store.read_bytes(path, limit=len(content)) != content:
            raise ValueError("Package content changed")
    if select_build_paths(store.paths(limits=limits), limits=limits) != paths:
        raise ValueError("Package membership changed during verification")
    return tuple(payload)


def load_build_identity(
    *, store: InstalledBuildStore | None = None, limits: ParseLimits = DEFAULT_LIMITS
) -> RuntimeIdentity:
    """Return verified identity from fixed installation or injected store.

    store (InstalledBuildStore | None) is a trusted boundary; limits (ParseLimits)
    bounds every read/capture. Missing manifest raises RUNTIME_UNAVAILABLE;
    inconsistent payload raises RUNTIME_CORRUPT. Performs reads only.
    """
    reader = store if store is not None else PackageBuildStore()
    try:
        manifest = reader.read_bytes(BUILD_MANIFEST, limit=limits.document_bytes)
    except OSError:
        _fail("RUNTIME_UNAVAILABLE")
    except ValueError:
        _fail("RUNTIME_CORRUPT")
    try:
        payload = capture_build_payload(store=reader, limits=limits)
        identity = verify_build_identity(manifest, payload, limits=limits)
        if reader.read_bytes(BUILD_MANIFEST, limit=len(manifest)) != manifest:
            raise ValueError("Build manifest changed")
        return identity
    except (ValueError, OSError):
        _fail("RUNTIME_CORRUPT")
