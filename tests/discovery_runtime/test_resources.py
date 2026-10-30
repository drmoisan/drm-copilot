"""Exercise deterministic installed-resource contracts with in-memory readers."""

from __future__ import annotations

import hashlib
import json
from itertools import permutations
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import __version__, resources
from drm_copilot_discovery.resources import (
    ResourceEntry,
    ResourceError,
    ResourceManifest,
    load_resource_manifest,
    parse_resource_manifest,
    read_resource,
    render_resource_manifest,
    validate_resource_path,
)

if TYPE_CHECKING:
    from collections.abc import Callable

RESOURCE_PATH = "schemas/discovery/v1/example.schema.json"
CONTENT = b'{"$id":"example","type":"object"}\n'


def _document() -> dict[str, object]:
    """Provide a fresh valid manifest for isolated negative cases."""
    return {
        "manifest_version": 1,
        "runtime_version": __version__,
        "resources": [
            {
                "path": RESOURCE_PATH,
                "sha256": hashlib.sha256(CONTENT).hexdigest(),
                "size": len(CONTENT),
            }
        ],
    }


def test_load_and_read_verify_exact_bytes_and_immutable_metadata() -> None:
    """A supplied store resolves the manifest and preserves resource bytes."""
    store = {
        RESOURCE_PATH: CONTENT,
        "manifest.json": render_resource_manifest({RESOURCE_PATH: CONTENT}),
    }

    manifest = load_resource_manifest(read_bytes=store.__getitem__)
    actual = read_resource(
        RESOURCE_PATH, manifest=manifest, read_bytes=store.__getitem__
    )

    assert actual == CONTENT
    assert manifest == ResourceManifest(
        __version__,
        (
            ResourceEntry(
                RESOURCE_PATH, hashlib.sha256(CONTENT).hexdigest(), len(CONTENT)
            ),
        ),
    )
    assert hash(manifest) == hash(load_resource_manifest(read_bytes=store.__getitem__))


@pytest.mark.parametrize("order", tuple(permutations(("alpha", "beta", "gamma"))))
def test_manifest_bytes_are_invariant_under_input_order(order: tuple[str, ...]) -> None:
    """Every input permutation yields sorted, reproducible UTF-8 manifest bytes."""
    inputs = {f"schemas/{name}.json": name.encode() for name in order}

    actual = render_resource_manifest(inputs)

    assert actual == render_resource_manifest(dict(sorted(inputs.items())))
    assert actual.endswith(b"\n") and b"\r" not in actual
    manifest = parse_resource_manifest(actual.decode())
    assert tuple(entry.path for entry in manifest.resources) == tuple(sorted(inputs))


@pytest.mark.parametrize(
    "value",
    (
        "",
        "../outside",
        "/absolute",
        "a//b",
        "a/./b",
        "a/../b",
        "C:/outside",
        "a\\b",
        "a/",
        "https://example.invalid/schema",
        None,
        4,
    ),
)
def test_resource_path_rejects_ambiguous_or_escaping_inputs(value: object) -> None:
    """A path cannot escape the manifest through host-specific interpretation."""
    with pytest.raises(ResourceError, match="resource path|Resource path"):
        validate_resource_path(value)


@pytest.mark.parametrize(
    "text", ("{", "[]", "{}", '{"manifest_version":1,"manifest_version":2}')
)
def test_manifest_rejects_invalid_json_shape_and_duplicate_keys(text: str) -> None:
    """Malformed or ambiguous JSON never produces a partial resource inventory."""
    with pytest.raises(ResourceError):
        parse_resource_manifest(text)


@pytest.mark.parametrize(
    ("key", "value"),
    [
        ("manifest_version", True),
        ("manifest_version", 2),
        ("runtime_version", "99.0.0"),
        ("runtime_version", 2),
        ("resources", []),
        ("resources", {}),
        ("resources", [4]),
        ("resources", [{"path": RESOURCE_PATH}]),
    ],
)
def test_manifest_rejects_unsupported_fields(key: str, value: object) -> None:
    """Wrong versions and malformed entries fail closed before resource reads."""
    document = _document()
    document[key] = value

    with pytest.raises(ResourceError):
        parse_resource_manifest(json.dumps(document))


@pytest.mark.parametrize(
    ("key", "value"),
    [
        ("sha256", "f"),
        ("sha256", "A" * 64),
        ("sha256", None),
        ("size", -1),
        ("size", True),
        ("size", "12"),
        ("path", "../escape"),
        ("path", "manifest.json"),
    ],
)
def test_manifest_validates_entry_construction(key: str, value: object) -> None:
    """Entry invariant failures propagate through the manifest reader."""
    document = _document()
    entries = cast("list[dict[str, object]]", document["resources"])
    entries[0][key] = value

    with pytest.raises(ResourceError):
        parse_resource_manifest(json.dumps(document))


@pytest.mark.parametrize("duplicate", (True, False))
def test_manifest_rejects_duplicate_or_unsorted_paths(duplicate: bool) -> None:
    """Manifest order is canonical and cannot disguise duplicate inventory rows."""
    entry = ResourceEntry("schemas/z.json", "a" * 64, 0)
    second = entry if duplicate else ResourceEntry("schemas/a.json", "b" * 64, 0)

    with pytest.raises(ResourceError, match="sorted, unique"):
        ResourceManifest(__version__, (entry, second))


def test_empty_direct_manifest_is_invalid() -> None:
    """Direct construction cannot bypass the nonempty inventory invariant."""
    with pytest.raises(ResourceError, match="nonempty"):
        ResourceManifest(__version__, ())


@pytest.mark.parametrize("payload", (b"different content", b"x" * len(CONTENT)))
def test_modified_payload_is_rejected(payload: bytes) -> None:
    """Size changes and same-size byte changes both invalidate installed evidence."""
    store = {
        "manifest.json": render_resource_manifest({RESOURCE_PATH: CONTENT}),
        RESOURCE_PATH: payload,
    }

    with pytest.raises(ResourceError, match="checksum or size"):
        read_resource(RESOURCE_PATH, read_bytes=store.__getitem__)


def test_unlisted_resource_is_rejected_before_reading_payload() -> None:
    """The manifest controls access even when an undeclared file exists."""
    manifest = parse_resource_manifest(
        render_resource_manifest({RESOURCE_PATH: CONTENT}).decode()
    )

    with pytest.raises(ResourceError, match="not declared"):
        read_resource(
            "schemas/undeclared.json",
            manifest=manifest,
            read_bytes=lambda _: pytest.fail("unexpected resource read"),
        )


def _missing(_: str) -> bytes:
    """Represent a missing installed resource without filesystem access."""
    raise FileNotFoundError("missing resource")


def _invalid_encoding(_: str) -> bytes:
    """Represent a non-UTF-8 installed manifest."""
    return b"\xff"


@pytest.mark.parametrize("reader", (_missing, _invalid_encoding))
def test_manifest_read_errors_are_actionable(reader: Callable[[str], bytes]) -> None:
    """Missing and non-UTF-8 manifests preserve actionable failure context."""
    with pytest.raises(ResourceError, match="Cannot read installed resource manifest"):
        load_resource_manifest(read_bytes=reader)


def test_resource_read_error_preserves_context() -> None:
    """A declared but unreadable payload cannot be treated as an empty resource."""
    manifest = parse_resource_manifest(
        render_resource_manifest({RESOURCE_PATH: CONTENT}).decode()
    )
    with pytest.raises(ResourceError, match="Cannot read installed resource"):
        read_resource(RESOURCE_PATH, manifest=manifest, read_bytes=_missing)


def test_installed_lookup_uses_importlib_resources_without_cwd(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A fake installation proves lookup never asks for the process directory."""
    store = {
        "_resources/manifest.json": render_resource_manifest({RESOURCE_PATH: CONTENT}),
        f"_resources/{RESOURCE_PATH}": CONTENT,
    }
    observed: list[str] = []

    class Node:
        """Implement just the resource traversal operations the loader needs."""

        def __init__(self, name: str = "") -> None:
            self.name = name

        def joinpath(self, *parts: str) -> Node:
            return Node("/".join(parts))

        def read_bytes(self) -> bytes:
            observed.append(self.name)
            return store[self.name]

    def package_files(package: str) -> Node:
        assert package == "drm_copilot_discovery"
        return Node()

    def unexpected_cwd() -> Path:
        pytest.fail("resource lookup must not use cwd")

    monkeypatch.setattr(resources, "files", package_files)
    monkeypatch.setattr(Path, "cwd", unexpected_cwd)

    assert read_resource(RESOURCE_PATH) == CONTENT
    assert observed == ["_resources/manifest.json", f"_resources/{RESOURCE_PATH}"]
