"""Exercise the installed repository binding over memory reads and a fake Git seam."""

from __future__ import annotations

import io
import json
from pathlib import Path
from typing import TYPE_CHECKING, NoReturn

import pytest
from drm_copilot_discovery import repository_binding
from drm_copilot_discovery.repository_binding import (
    LOCATOR_LIMIT,
    PROFILE_LIMIT,
    configured_repository_id,
    installed_repository,
    read_workspace_bytes,
)
from drm_copilot_discovery.repository_reader import LocalGitReader

if TYPE_CHECKING:
    from collections.abc import Callable

ROOT = "/workspace"
PROFILE_YAML = "docs/migration/discovery/domain-profile.yaml"
PROFILE_JSON = "docs/migration/discovery/domain-profile.json"
REVISION = "a" * 40


def locator_bytes(profile_path: object = PROFILE_YAML) -> bytes:
    """Return a locator naming profile_path (object), which may be an invalid type."""
    return json.dumps({"enabled": True, "profile_path": profile_path}).encode()


def profile_bytes(repository: object) -> bytes:
    """Return a minimal profile whose repository block is repository (object)."""
    return json.dumps({"id": "profile", "repository": repository}).encode()


class MemoryWorkspace:
    """Serve bounded workspace reads from a dictionary and record every request.

    files maps relative paths to bytes; reads records (path, limit) pairs so tests
    can assert that the derivation stops at the first missing input. No file,
    process or clock is touched.
    """

    def __init__(self, files: dict[str, bytes]) -> None:
        """Retain files (dict[str, bytes]) and start with no recorded reads."""
        self.files = files
        self.reads: list[tuple[str, int]] = []

    def read(self, relative: str, limit: int) -> bytes | None:
        """Return the bytes for relative (str) within limit (int), or None if absent."""
        self.reads.append((relative, limit))
        content = self.files.get(relative)
        return None if content is None or len(content) > limit else content


def fake_git(root: str) -> Callable[..., bytes]:
    """Return a Git seam answering only the two identity queries for root (str)."""

    def run(argv: tuple[str, ...], *, output_limit: int) -> bytes:
        """Answer rev-parse queries in argv (tuple[str, ...]) within output_limit."""
        assert output_limit > 0
        if argv[-1] == "--show-toplevel":
            return root.encode() + b"\n"
        if argv[-1] == "HEAD":
            return REVISION.encode() + b"\n"
        raise AssertionError(argv)

    return run


def test_explicit_identity_is_bound_without_reading_the_workspace() -> None:
    """An explicit id is outer data: the workspace is never consulted."""
    workspace = MemoryWorkspace({})

    reader = installed_repository(
        ROOT, "explicit-id", run=fake_git(ROOT), read_bytes=workspace.read
    )

    assert isinstance(reader, LocalGitReader)
    assert reader.identity().id == "explicit-id" and not workspace.reads


@pytest.mark.parametrize("profile_path", [PROFILE_YAML, PROFILE_JSON])
def test_configured_git_repository_is_derived_from_locator_and_profile(
    profile_path: str,
) -> None:
    """The locator names the profile and the profile names the Git repository.

    profile_path (str): selects the YAML or JSON profile syntax by suffix.
    """
    workspace = MemoryWorkspace(
        {
            "config/discovery.json": locator_bytes(profile_path),
            profile_path: profile_bytes({"id": "legacy-orders", "vcs": "git"}),
        }
    )

    reader = installed_repository(
        ROOT, None, run=fake_git(ROOT), read_bytes=workspace.read
    )

    assert isinstance(reader, LocalGitReader)
    assert reader.identity().id == "legacy-orders"
    assert workspace.reads == [
        ("config/discovery.json", LOCATOR_LIMIT),
        (profile_path, PROFILE_LIMIT),
    ]


@pytest.mark.parametrize(
    "files,profile_read",
    [
        pytest.param({}, False, id="missing-locator"),
        pytest.param({"config/discovery.json": b"{not json"}, False, id="bad-locator"),
        pytest.param(
            {"config/discovery.json": locator_bytes(7)}, False, id="path-not-text"
        ),
        pytest.param(
            {"config/discovery.json": locator_bytes("../outside.yaml")},
            False,
            id="unsafe-path",
        ),
        pytest.param(
            {"config/discovery.json": locator_bytes()}, True, id="missing-profile"
        ),
        pytest.param(
            {"config/discovery.json": locator_bytes(), PROFILE_YAML: b"[unclosed"},
            True,
            id="bad-profile",
        ),
        pytest.param(
            {
                "config/discovery.json": locator_bytes(),
                PROFILE_YAML: json.dumps({"id": "profile"}).encode(),
            },
            True,
            id="no-repository",
        ),
        pytest.param(
            {
                "config/discovery.json": locator_bytes(),
                PROFILE_YAML: profile_bytes({"id": "legacy", "vcs": "svn"}),
            },
            True,
            id="other-vcs",
        ),
        pytest.param(
            {
                "config/discovery.json": locator_bytes(),
                PROFILE_YAML: profile_bytes({"id": 3, "vcs": "git"}),
            },
            True,
            id="id-not-text",
        ),
        pytest.param(
            {
                "config/discovery.json": locator_bytes(),
                PROFILE_YAML: b" " * (PROFILE_LIMIT + 1),
            },
            True,
            id="oversized-profile",
        ),
    ],
)
def test_unconfigured_or_malformed_workspaces_yield_no_reader(
    files: dict[str, bytes], profile_read: bool
) -> None:
    """Every incomplete configuration yields None and reads nothing past the gap.

    files (dict[str, bytes]): workspace contents. profile_read (bool): whether the
    locator was complete enough for the profile read to be attempted.
    """
    workspace = MemoryWorkspace(files)

    identifier = configured_repository_id(ROOT, read_bytes=workspace.read)
    reader = installed_repository(
        ROOT, None, run=fake_git(ROOT), read_bytes=workspace.read
    )

    assert identifier is None and reader is None
    assert len(workspace.reads) == 2 * (2 if profile_read else 1)


@pytest.mark.parametrize(
    "behavior,expected",
    [
        ("content", b'{"enabled": true}'),
        ("missing", None),
        ("directory", None),
        ("oversized", None),
    ],
)
def test_default_reader_bounds_one_workspace_file(
    monkeypatch: pytest.MonkeyPatch, behavior: str, expected: bytes | None
) -> None:
    """The filesystem seam returns bounded bytes, or None for absent or oversized files.

    monkeypatch (pytest.MonkeyPatch): replaces Path.open with a memory stream.
    behavior (str): selects the modeled file state. expected (bytes | None): result.
    """
    opened: list[Path] = []

    def fake_open(
        self: Path, mode: str = "r", *_args: object, **_kwargs: object
    ) -> io.BytesIO:
        """Serve the modeled state for self (Path) opened with mode (str)."""
        opened.append(self)
        assert mode == "rb"
        if behavior == "missing":
            raise FileNotFoundError(str(self))
        if behavior == "directory":
            raise IsADirectoryError(str(self))
        return io.BytesIO(
            b"x" * 33 if behavior == "oversized" else b'{"enabled": true}'
        )

    monkeypatch.setattr(Path, "open", fake_open)

    actual = read_workspace_bytes(ROOT, "config/discovery.json", 32)

    assert actual == expected
    assert opened == [Path(ROOT, "config/discovery.json")]


def test_default_reader_propagates_other_errors(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A permission failure is not an absent file and must reach the caller unchanged.

    monkeypatch (pytest.MonkeyPatch): replaces Path.open with a failing seam.
    """

    def fail(
        self: Path, mode: str = "r", *_args: object, **_kwargs: object
    ) -> NoReturn:
        """Raise the modeled failure for self (Path) and mode (str)."""
        raise PermissionError(f"{self}:{mode}")

    monkeypatch.setattr(Path, "open", fail)

    with pytest.raises(PermissionError):
        read_workspace_bytes(ROOT, "config/discovery.json", 16)


def test_installed_binding_uses_the_filesystem_seam_by_default(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Without an injected reader the derivation reads the workspace files by path.

    monkeypatch (pytest.MonkeyPatch): routes read_workspace_bytes to memory.
    """
    files = {
        "config/discovery.json": locator_bytes(),
        PROFILE_YAML: profile_bytes({"id": "legacy-orders", "vcs": "git"}),
    }
    requests: list[tuple[str, str, int]] = []

    def read(root: str, relative: str, limit: int) -> bytes | None:
        """Serve files for root (str)/relative (str) within limit (int) from memory."""
        requests.append((root, relative, limit))
        return files.get(relative)

    monkeypatch.setattr(repository_binding, "read_workspace_bytes", read)

    reader = installed_repository(ROOT, None, run=fake_git(ROOT))

    assert isinstance(reader, LocalGitReader)
    assert reader.identity().id == "legacy-orders"
    assert [request[:2] for request in requests] == [
        (ROOT, "config/discovery.json"),
        (ROOT, PROFILE_YAML),
    ]
