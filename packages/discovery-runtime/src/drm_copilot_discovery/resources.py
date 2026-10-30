"""Load hash-verified package resources without depending on a source checkout.

The build stages canonical schemas and templates beside this module. Its closed
manifest names every permitted resource and binds the exact bytes. Readers are
injectable so validation and deterministic manifest generation require no I/O.
"""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from importlib.resources import files
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery import __version__

if TYPE_CHECKING:
    from collections.abc import Callable, Mapping

RESOURCE_DIRECTORY = "_resources"
MANIFEST_FILENAME = "manifest.json"
MANIFEST_VERSION = 1
_PATH_PATTERN = re.compile(r"[a-z0-9][a-z0-9._/-]*")
_HASH_PATTERN = re.compile(r"[0-9a-f]{64}")


class ResourceError(ValueError):
    """Report missing, malformed, or modified installed discovery resources."""


@dataclass(frozen=True)
class ResourceEntry:
    """Describe the immutable bytes expected at one package-relative path."""

    path: str
    sha256: str
    size: int

    def __post_init__(self) -> None:
        """Reject invalid direct construction as well as malformed manifest data."""
        _validate_entry(self.path, self.sha256, self.size)


@dataclass(frozen=True)
class ResourceManifest:
    """Represent a validated, ordered resource inventory for this runtime."""

    runtime_version: str
    resources: tuple[ResourceEntry, ...]

    def __post_init__(self) -> None:
        """Keep version and inventory invariants valid for every caller."""
        if self.runtime_version != __version__:
            raise ResourceError(f"Resource runtime version must equal {__version__}")
        if not self.resources:
            raise ResourceError("Resource manifest requires a nonempty resource list")
        paths = [entry.path for entry in self.resources]
        if paths != sorted(set(paths)) or MANIFEST_FILENAME in paths:
            raise ResourceError(
                "Resource paths must be sorted, unique, and exclude the manifest"
            )


def validate_resource_path(value: object) -> str:
    """Reject noncanonical paths before a reader can interpret them."""
    if not isinstance(value, str) or _PATH_PATTERN.fullmatch(value) is None:
        raise ResourceError(f"Invalid resource path: {value!r}")
    if any(part in {"", ".", ".."} for part in value.split("/")):
        raise ResourceError(f"Resource path contains an unsafe segment: {value!r}")
    return value


def _validate_entry(path: object, digest: object, size: object) -> None:
    """Validate both direct constructors and decoded untyped entry fields."""
    validate_resource_path(path)
    if not isinstance(digest, str) or _HASH_PATTERN.fullmatch(digest) is None:
        raise ResourceError(f"Resource {path} requires a lowercase SHA-256 digest")
    if not isinstance(size, int) or isinstance(size, bool) or size < 0:
        raise ResourceError(f"Resource {path} requires a nonnegative byte size")


def _unique_object(pairs: list[tuple[str, object]]) -> dict[str, object]:
    """Preserve manifest-key uniqueness at the JSON decoding boundary."""
    result: dict[str, object] = {}
    for key, value in pairs:
        if key in result:
            raise ResourceError(f"Duplicate manifest key: {key}")
        result[key] = value
    return result


def _closed_mapping(value: object, keys: set[str], context: str) -> dict[str, object]:
    """Require the precise manifest shape without coercing unsupported fields."""
    if not isinstance(value, dict):
        raise ResourceError(f"{context} requires exactly {', '.join(sorted(keys))}")
    mapping = cast("dict[str, object]", value)
    if set(mapping) != keys:
        raise ResourceError(f"{context} requires exactly {', '.join(sorted(keys))}")
    return mapping


def parse_resource_manifest(text: str) -> ResourceManifest:
    """Validate a staged manifest's version, paths, hashes, sizes, and order."""
    try:
        document: object = json.loads(text, object_pairs_hook=_unique_object)
    except json.JSONDecodeError as error:
        raise ResourceError(f"Invalid resource manifest JSON: {error.msg}") from error
    document = _closed_mapping(
        document, {"manifest_version", "runtime_version", "resources"}, "Manifest"
    )
    if (
        type(document["manifest_version"]) is not int
        or document["manifest_version"] != MANIFEST_VERSION
    ):
        raise ResourceError(
            f"Unsupported resource manifest version; expected {MANIFEST_VERSION}"
        )
    version = document["runtime_version"]
    if not isinstance(version, str):
        raise ResourceError("Resource runtime version must be a string")
    raw_entries = document["resources"]
    if not isinstance(raw_entries, list) or not raw_entries:
        raise ResourceError("Resource manifest requires a nonempty resource list")
    entries: list[ResourceEntry] = []
    for item in cast("list[object]", raw_entries):
        entry = _closed_mapping(item, {"path", "sha256", "size"}, "Resource entry")
        entries.append(
            ResourceEntry(
                cast("str", entry["path"]),
                cast("str", entry["sha256"]),
                cast("int", entry["size"]),
            )
        )
    return ResourceManifest(version, tuple(entries))


def render_resource_manifest(resources: Mapping[str, bytes]) -> bytes:
    """Bind a complete resource mapping to deterministic UTF-8 manifest bytes."""
    entries = [
        {
            "path": path,
            "sha256": hashlib.sha256(content).hexdigest(),
            "size": len(content),
        }
        for path, content in sorted(resources.items())
    ]
    text = (
        json.dumps(
            {
                "manifest_version": MANIFEST_VERSION,
                "runtime_version": __version__,
                "resources": entries,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n"
    )
    parse_resource_manifest(text)
    return text.encode("utf-8")


def _read_installed_bytes(path: str) -> bytes:
    """Resolve a validated package member through the installation resource API."""
    return (
        files("drm_copilot_discovery")
        .joinpath(RESOURCE_DIRECTORY, *path.split("/"))
        .read_bytes()
    )


def load_resource_manifest(
    *, read_bytes: Callable[[str], bytes] = _read_installed_bytes
) -> ResourceManifest:
    """Read the installed manifest, preserving an injectable byte-reader seam."""
    try:
        return parse_resource_manifest(read_bytes(MANIFEST_FILENAME).decode("utf-8"))
    except (OSError, UnicodeError) as error:
        raise ResourceError(
            f"Cannot read installed resource manifest: {error}"
        ) from error


def read_resource(
    path: str,
    *,
    manifest: ResourceManifest | None = None,
    read_bytes: Callable[[str], bytes] = _read_installed_bytes,
) -> bytes:
    """Return only a declared resource whose size and SHA-256 match its manifest."""
    path = validate_resource_path(path)
    manifest = (
        manifest
        if manifest is not None
        else load_resource_manifest(read_bytes=read_bytes)
    )
    entry = next((entry for entry in manifest.resources if entry.path == path), None)
    if entry is None:
        raise ResourceError(
            f"Resource is not declared in the installed manifest: {path}"
        )
    try:
        content = read_bytes(path)
    except OSError as error:
        raise ResourceError(
            f"Cannot read installed resource {path}: {error}"
        ) from error
    if (
        len(content) != entry.size
        or hashlib.sha256(content).hexdigest() != entry.sha256
    ):
        raise ResourceError(f"Installed resource checksum or size mismatch: {path}")
    return content
