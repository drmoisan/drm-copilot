"""Exercise complete installed-content identity using immutable/in-memory bytes."""

from __future__ import annotations

import json
import stat
from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import build_identity as identity
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.resources import render_resource_manifest
from drm_copilot_discovery.service_contracts import ServiceRuntimeError

from tests.scripts.dev_tools.test_discovery_build_identity import (
    memory_build_metadata as memory_build_metadata,
)

if TYPE_CHECKING:
    from pathlib import Path


def package() -> JsonObject:
    """Return fixed inert package metadata; no arguments, I/O or exceptions."""
    return JsonObject(
        (
            ("name", "drm-copilot-discovery"),
            ("version", "2.0.0"),
            ("python", ">=3.10,<4.0"),
            (
                "dependencies",
                JsonObject(
                    (
                        ("PyYAML", ">=6"),
                        ("jsonschema", "^4"),
                        ("lxml", ">=5"),
                        ("referencing", ">=0.37"),
                    )
                ),
            ),
        )
    )


def payload() -> identity.Payload:
    """Return a minimal complete payload; no arguments, I/O or exceptions."""
    resources = {"schemas/discovery/v2/example.schema.json": b'{"type":"object"}'}
    return (
        ("__init__.py", b'__version__ = "2.0.0"\n'),
        ("helpers.py", b"value = 1\n"),
        ("py.typed", b""),
        ("_resources/manifest.json", render_resource_manifest(resources)),
        (
            "_resources/schemas/discovery/v2/example.schema.json",
            resources["schemas/discovery/v2/example.schema.json"],
        ),
    )


class MemoryStore:
    """Retain independent mutable storage for read/freshness boundary tests.

    Defaults to valid immutable payload bytes; mutations are explicit test setup.
    paths/read_bytes implement the real bounded store protocol without I/O.
    """

    def __init__(self) -> None:
        """Create a fresh memory installation; return None without external effects."""
        self.content = dict(payload())
        self.content[identity.BUILD_MANIFEST] = identity.project_build_manifest(
            payload(), package=package()
        )

    def paths(self, *, limits: ParseLimits) -> tuple[str, ...]:
        """Return memory names; limits (ParseLimits) is enforced by caller.

        Returns tuple[str,...] without mutation/I/O or expected exceptions.
        """
        return tuple(reversed(self.content))

    def read_bytes(self, path: str, *, limit: int) -> bytes:
        """Return path (str) bytes within limit (int); no external effects.

        Raises FileNotFoundError for absence and ValueError for excess.
        """
        if path not in self.content:
            raise FileNotFoundError(path)
        value = self.content[path]
        if len(value) > limit:
            raise ValueError("Memory member exceeds limit")
        return value


def test_complete_content_identity_is_deterministic_and_not_wheel_hash() -> None:
    """Verify canonical source/resource content; no parameters or external effects.

    Returns None; assertions may fail; only local test state changes.
    """
    content = identity.project_build_manifest(payload(), package=package())
    result = identity.verify_build_identity(content, tuple(reversed(payload())))
    assert content == identity.project_build_manifest(
        tuple(reversed(payload())), package=package()
    )
    assert result.build_sha256 == sha256(content).hexdigest()
    assert result.build_sha256 != sha256(b"wheel archive").hexdigest()
    assert result.policy_version == 2
    assert identity.load_build_identity(store=MemoryStore()) == result


@pytest.mark.parametrize("changed", ("source", "resource", "typing", "metadata"))
def test_identity_invalidates_the_correct_closure(changed: str) -> None:
    """changed (str) selects bytes/metadata; verify scope without I/O or errors.

    Returns None; assertions may fail; only local test state changes.
    """
    baseline = identity.load_build_identity(store=MemoryStore())
    members = dict(payload())
    metadata = package()
    # Source/resources affect policy; typing and declared metadata affect build only.
    if changed == "source":
        members["helpers.py"] = b"value = 2\n"
    elif changed == "resource":
        resource = "schemas/discovery/v2/example.schema.json"
        members["_resources/" + resource] = b'{"type":"array"}'
        members["_resources/manifest.json"] = render_resource_manifest(
            {resource: members["_resources/" + resource]}
        )
    elif changed == "typing":
        members["py.typed"] = b"partial\n"
    else:
        metadata = JsonObject(
            tuple(
                (key, ">=3.11" if key == "python" else value)
                for key, value in metadata.members
            )
        )
    candidate = tuple(members.items())
    result = identity.verify_build_identity(
        identity.project_build_manifest(candidate, package=metadata), candidate
    )
    assert result.build_sha256 != baseline.build_sha256
    assert (result.policy_sha256 != baseline.policy_sha256) == (
        changed in ("source", "resource")
    )


@pytest.mark.parametrize(
    "manifest",
    (
        b"{",
        b"[]",
        b"{}",
        b"\xff",
        b'{"package":{},"package":{}}',
        cast("bytes", bytearray(b"{}")),
    ),
)
def test_invalid_manifest_has_fixed_redacted_failure(manifest: bytes) -> None:
    """manifest (bytes) is rejected with fixed error, no I/O or partial identity.

    Returns None; assertions may fail; only local test state changes.
    """
    with pytest.raises(ServiceRuntimeError) as error:
        identity.verify_build_identity(manifest, payload())
    assert error.value.code == "RUNTIME_CORRUPT"
    assert error.value.findings[0].pointer == "/runtime"
    assert "package" not in str(error.value)


@pytest.mark.parametrize(
    "change",
    (
        "missing",
        "extra",
        "modified",
        "noncanonical",
        "version",
        "policy",
        "unknown-field",
    ),
)
def test_manifest_mismatch_cannot_return_identity(change: str) -> None:
    """change (str) selects a mismatch; only fixed typed failure is returned.

    Returns None; assertions may fail; only local test state changes.
    """
    members = dict(payload())
    manifest = identity.project_build_manifest(payload(), package=package())
    # Preserve valid JSON for semantic tampering; whitespace still changes identity.
    if change == "missing":
        del members["helpers.py"]
    elif change == "extra":
        members["extra.py"] = b""
    elif change == "modified":
        members["helpers.py"] = b"changed"
    elif change == "noncanonical":
        manifest += b" "
    else:
        document = json.loads(manifest)
        document[
            {
                "version": "manifest_version",
                "policy": "policy_sha256",
                "unknown-field": "extra",
            }[change]
        ] = "bad"
        manifest = json.dumps(document).encode()
    with pytest.raises(ServiceRuntimeError, match="RUNTIME_CORRUPT"):
        identity.verify_build_identity(manifest, tuple(members.items()))


@pytest.mark.parametrize(
    "path",
    (
        "../escape.py",
        "",
        "a/" * 100 + "deep.py",
        "/absolute.py",
        "C:/source.py",
        "UPPER.py",
        "con.py",
        "a//b.py",
        "a./b.py",
        "é.py",
        "data.bin",
        "_resources/evil.py",
        "_resources/foreign/data.json",
        "helpers.py/child.py",
    ),
)
def test_payload_paths_fail_before_publication(path: str) -> None:
    """path (str) adds invalid content; no I/O or partial manifest is permitted.

    Returns None; assertions may fail; only local test state changes.
    """
    with pytest.raises(ServiceRuntimeError, match="RUNTIME_CORRUPT"):
        identity.project_build_manifest((*payload(), (path, b"")), package=package())


@pytest.mark.parametrize(
    "failure",
    (
        "duplicate",
        "missing-init",
        "resource-hash",
        "resource-empty",
        "excluded",
        "mutable",
        "bad-pair",
        "mutable-content",
    ),
)
def test_payload_contract_and_resource_closure_are_required(failure: str) -> None:
    """failure (str) selects invalid bytes/types; reject without external effects.

    Returns None; assertions may fail; only local test state changes.
    """
    members = dict(payload())
    candidate = payload()
    # Each branch isolates a distinct closure or immutable-carrier invariant.
    if failure == "duplicate":
        candidate += (candidate[0],)
    elif failure == "missing-init":
        del members["__init__.py"]
        candidate = tuple(members.items())
    elif failure == "resource-hash":
        members["_resources/schemas/discovery/v2/example.schema.json"] = b"changed"
        candidate = tuple(members.items())
    elif failure == "resource-empty":
        del members["_resources/schemas/discovery/v2/example.schema.json"]
        candidate = tuple(members.items())
    elif failure == "excluded":
        candidate += ((identity.BUILD_MANIFEST, b"{}"),)
    elif failure == "bad-pair":
        candidate = cast("identity.Payload", (("missing-content",),))
    elif failure == "mutable-content":
        candidate = cast("identity.Payload", (("__init__.py", bytearray(b"")),))
    else:
        candidate = cast("identity.Payload", list(candidate))
    with pytest.raises(ServiceRuntimeError, match="RUNTIME_CORRUPT"):
        identity.project_build_manifest(candidate, package=package())


@pytest.mark.parametrize(
    "metadata",
    (
        JsonObject(()),
        cast("JsonObject", {}),
        JsonObject((*package().members[:2], ("python", ""), package().members[-1])),
        JsonObject(
            (
                ("name", "another-package"),
                ("version", "2.0.0"),
                ("python", "*"),
                ("dependencies", JsonObject(())),
            )
        ),
    ),
)
def test_foreign_metadata_is_not_a_package_selector(metadata: JsonObject) -> None:
    """metadata (JsonObject) cannot select arbitrary identity; no I/O occurs.

    Returns None; assertions may fail; only local test state changes.
    """
    with pytest.raises(ServiceRuntimeError, match="RUNTIME_CORRUPT"):
        identity.project_build_manifest(payload(), package=metadata)


@pytest.mark.parametrize(
    "limits",
    (
        ParseLimits(document_bytes=50),
        ParseLimits(artifact_records=2),
        ParseLimits(nesting_depth=1),
    ),
)
def test_manifest_limits_stop_the_whole_projection(limits: ParseLimits) -> None:
    """limits (ParseLimits) bounds work/bytes/depth; no partial output or I/O.

    Returns None; assertions may fail; only local test state changes.
    """
    with pytest.raises(ServiceRuntimeError, match="RUNTIME_CORRUPT"):
        identity.project_build_manifest(payload(), package=package(), limits=limits)


def test_installation_generated_members_are_excluded() -> None:
    """Ignore only declared exclusions; return identity without mutable globals.

    Returns None; assertions may fail; only local test state changes.
    """
    store = MemoryStore()
    expected = identity.load_build_identity(store=store)
    store.content["__pycache__/helpers.cpython-313.pyc"] = b"cache"
    store.content["example.dist-info/record"] = b"archive metadata"
    assert identity.load_build_identity(store=store) == expected


@pytest.mark.parametrize(
    "failure",
    (
        "missing-manifest",
        "oversized-manifest",
        "missing-member",
        "changed-member",
        "changed-names",
        "changed-names-late",
        "changed-manifest",
        "mutable-listing",
        "mutable-member",
    ),
)
def test_reader_failure_and_mutation_are_distinct(
    failure: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """failure (str) drives memory reads; monkeypatch isolates callbacks, no I/O.

    Returns None; assertions may fail; only local test state changes.
    """
    store = MemoryStore()
    read = store.read_bytes
    calls: dict[str, int] = {}

    def changing_read(path: str, *, limit: int) -> bytes:
        """Read path (str)/limit (int), injecting one controlled mutation.

        Returns bytes or raises OSError/ValueError; only local memory/counters change.
        """
        calls[path] = calls.get(path, 0) + 1
        if failure == "mutable-member" and path == "helpers.py":
            return cast("bytes", bytearray(b""))
        if failure == "missing-member" and path == "helpers.py":
            raise FileNotFoundError("sensitive-location")
        if failure == "changed-member" and path == "helpers.py" and calls[path] == 2:
            return b"altered"
        if failure == "changed-names" and path == "helpers.py":
            store.content["new.py"] = b""
        if (
            failure == "changed-names-late"
            and path == "helpers.py"
            and calls[path] == 2
        ):
            store.content["new.py"] = b""
        if (
            failure == "changed-manifest"
            and path == identity.BUILD_MANIFEST
            and calls[path] == 2
        ):
            return b"{}"
        return read(path, limit=limit)

    def mutable_listing(*, limits: ParseLimits) -> tuple[str, ...]:
        """Return an invalid mutable listing for limits (ParseLimits), without I/O."""
        return cast("tuple[str, ...]", list(store.content))

    if failure == "mutable-listing":
        monkeypatch.setattr(store, "paths", mutable_listing)
    if failure == "missing-manifest":
        del store.content[identity.BUILD_MANIFEST]
    elif failure == "oversized-manifest":
        store.content[identity.BUILD_MANIFEST] = b"x" * 4097
    monkeypatch.setattr(store, "read_bytes", changing_read)
    with pytest.raises(ServiceRuntimeError) as error:
        identity.load_build_identity(
            store=store, limits=ParseLimits(document_bytes=4096)
        )
    assert error.value.code == (
        "RUNTIME_UNAVAILABLE" if failure == "missing-manifest" else "RUNTIME_CORRUPT"
    )
    assert "sensitive-location" not in str(error.value)


def test_fixed_installed_adapter_uses_memory_files(
    mem_fs_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    memory_build_metadata: dict[str, tuple[int, int]],
) -> None:
    """mem_fs_path (Path) and monkeypatch provide isolated in-memory package I/O.

    memory_build_metadata (dict[str,tuple[int,int]]) supplies non-native metadata.
    Returns None; assertions may fail; only local test state changes.
    """
    store = MemoryStore()
    # The repository memory filesystem intercepts every Path operation.
    for path, content in store.content.items():
        target = mem_fs_path / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(content)

    def package_files(anchor: str) -> Path:
        """Return memory root for anchor (str); reject other packages, no disk I/O."""
        assert anchor == "drm_copilot_discovery"
        return mem_fs_path

    monkeypatch.setattr(identity, "files", package_files)
    assert identity.load_build_identity() == identity.load_build_identity(store=store)
    with pytest.raises(ValueError, match="exceeds"):
        identity.PackageBuildStore().read_bytes("helpers.py", limit=0)
    with pytest.raises(ValueError, match="Invalid"):
        identity.PackageBuildStore().read_bytes("helpers.py", limit=-1)


@pytest.mark.parametrize("kind", ("root", "child", "junction", "other", "count"))
def test_fixed_adapter_rejects_links(
    kind: str,
    mem_fs_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    memory_build_metadata: dict[str, tuple[int, int]],
) -> None:
    """kind (str), memory Path and monkeypatch isolate metadata/bound failures.

    memory_build_metadata (dict[str,tuple[int,int]]) controls mode/reparse flags.
    Returns None; assertions may fail; only local test state changes.
    """
    (mem_fs_path / "helpers.py").write_bytes(b"")
    (mem_fs_path / "another.py").write_bytes(b"")

    def package_files(anchor: str) -> Path:
        """Return memory Path for anchor (str); no I/O or state changes."""
        return mem_fs_path

    monkeypatch.setattr(identity, "files", package_files)
    if kind in ("root", "junction"):
        memory_build_metadata[str(mem_fs_path)] = (
            stat.S_IFLNK if kind == "root" else stat.S_IFDIR,
            0x400 if kind == "junction" else 0,
        )
    elif kind in ("child", "other"):
        memory_build_metadata[str(mem_fs_path / "helpers.py")] = (
            stat.S_IFLNK if kind == "child" else 0,
            0,
        )
    limits = ParseLimits(artifact_records=1) if kind == "count" else ParseLimits()
    with pytest.raises(ValueError, match="Linked|Unsupported|limits"):
        identity.PackageBuildStore().paths(limits=limits)
    # Only links are rejected by the direct read, independent of enumeration.
    if kind in ("root", "child", "junction"):
        with pytest.raises(ValueError, match="Linked"):
            identity.PackageBuildStore().read_bytes("helpers.py", limit=100)
