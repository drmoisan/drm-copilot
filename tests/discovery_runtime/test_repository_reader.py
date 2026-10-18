"""Verify local Git selection and immutable byte reads without starting processes."""

from __future__ import annotations

import hashlib
from dataclasses import FrozenInstanceError
from typing import cast

import pytest
from drm_copilot_discovery.repository_reader import (
    LocalGitReader,
    RepositoryFile,
    RepositoryIdentity,
    full_revision,
)


class MemoryGit:
    """Answer a fixed command sequence from isolated bytes and retain exact argv."""

    def __init__(self, outputs: list[bytes]) -> None:
        """Copy responses so test mutation cannot affect another command adapter."""
        self.outputs = list(outputs)
        self.calls: list[tuple[tuple[str, ...], int]] = []

    def __call__(self, argv: tuple[str, ...], *, output_limit: int) -> bytes:
        """Return the next response; missing responses expose unexpected commands."""
        self.calls.append((argv, output_limit))
        return self.outputs.pop(0)


def blob_outputs(
    content: bytes, *, algorithm: str = "sha1", path: str = "src/a.py"
) -> list[bytes]:
    """Supply a verified exact-root, commit, ordinary-tree-entry and blob sequence."""
    digest = hashlib.new(
        algorithm, f"blob {len(content)}\0".encode() + content
    ).hexdigest()
    return [
        b"/workspace\n",
        b"commit\n",
        f"100644 blob {digest}\t{path}\0".encode(),
        content,
    ]


@pytest.mark.parametrize("revision", ["a" * 40, "b" * 64])
def test_identity_accepts_only_explicit_local_root_and_full_head(revision: str) -> None:
    """HEAD reads use fixed arguments and retain the configured repository ID."""
    runner = MemoryGit([b"/workspace\n", revision.encode() + b"\n"])
    reader = LocalGitReader(
        workspace_root="/workspace", repository_id="source", run=runner
    )
    result = reader.identity()
    assert result.to_dict() == {"id": "source", "revision": revision}
    assert runner.calls[-1][0][-3:] == ("rev-parse", "--verify", "HEAD")
    assert "--no-lazy-fetch" in runner.calls[0][0]
    assert "protocol.allow=never" in runner.calls[0][0]
    with pytest.raises(FrozenInstanceError):
        field = "revision"
        setattr(result, field, "c" * 40)


@pytest.mark.parametrize("algorithm", ["sha1", "sha256"])
def test_blob_bytes_are_retained_and_git_hash_is_independently_checked(
    algorithm: str,
) -> None:
    """Both Git hash formats preserve literal paths and exact bytes for SHA-256."""
    path = "src/odd [name];$(literal).py"
    content = b"first\x00line\r\nsecond\xff"
    runner = MemoryGit(blob_outputs(content, algorithm=algorithm, path=path))
    reader = LocalGitReader(
        workspace_root="/workspace", repository_id="source", run=runner
    )
    result = reader.read_file(revision="a" * 40, path=path, limit=1024)
    assert result.content == content and result.path == path
    assert result.sha256 == hashlib.sha256(content).hexdigest()
    assert runner.calls[2][0][-4:] == ("-z", "a" * 40, "--", path)
    assert len(runner.calls) == 4


@pytest.mark.parametrize(
    "value", ["HEAD", "abc", "A" * 40, "a" * 41, "-option", "a" * 40 + "~1"]
)
def test_revision_expressions_are_rejected_before_execution(value: str) -> None:
    """A revision cannot add options, name a branch or select another object."""
    runner = MemoryGit([])
    reader = LocalGitReader(
        workspace_root="/workspace", repository_id="source", run=runner
    )
    with pytest.raises(ValueError, match="full lowercase"):
        reader.read_file(revision=value, path="src/a.py", limit=10)
    assert not runner.calls


@pytest.mark.parametrize(
    "outputs,match",
    [
        ([b"/parent\n"], "root differs"),
        ([b"/workspace\n", b"tree\n"], "not a local Git commit"),
        ([b"/workspace\n", b"commit\n", b""], "missing or ambiguous"),
        (
            [b"/workspace\n", b"commit\n", b"100644 blob " + b"a" * 40 + b"\tother\0"],
            "missing or ambiguous",
        ),
        (
            [
                b"/workspace\n",
                b"commit\n",
                b"120000 blob " + b"a" * 40 + b"\tsrc/a.py\0",
            ],
            "ordinary Git",
        ),
        (
            [
                b"/workspace\n",
                b"commit\n",
                b"100644 tree " + b"a" * 40 + b"\tsrc/a.py\0",
            ],
            "ordinary Git",
        ),
        ([b"/workspace\n", b"commit\n", b"100644\tsrc/a.py\0"], "ordinary Git"),
        (
            [
                b"/workspace\n",
                b"commit\n",
                b"100644 blob " + b"a" * 40 + b"\tsrc/a.py\0",
                b"different",
            ],
            "identity does not match",
        ),
    ],
)
def test_git_rejects_wrong_roots_objects_entries_and_changed_bytes(
    outputs: list[bytes], match: str
) -> None:
    """No fallback or neighboring read repairs a failed local object lookup."""
    runner = MemoryGit(outputs)
    reader = LocalGitReader(
        workspace_root="/workspace", repository_id="source", run=runner
    )
    with pytest.raises(OSError, match=match):
        reader.read_file(revision="a" * 40, path="src/a.py", limit=1024)


@pytest.mark.parametrize("root", ["relative", "/workspace/../other"])
def test_git_constructor_rejects_implicit_workspaces(root: str) -> None:
    """No caller-selected relative path may trigger cwd or parent discovery."""
    with pytest.raises(ValueError, match="explicit absolute"):
        LocalGitReader(workspace_root=root, repository_id="source", run=MemoryGit([]))


def test_windows_root_remains_explicit_without_host_platform_dependence() -> None:
    """Windows separators normalize only the trusted absolute root argument."""
    runner = MemoryGit([b"C:/Workspace\n", b"a" * 40 + b"\n"])
    reader = LocalGitReader(
        workspace_root="C:\\Workspace", repository_id="source", run=runner
    )
    assert reader.identity().revision == "a" * 40
    assert "C:/Workspace" in runner.calls[0][0]


@pytest.mark.parametrize("limit", [0, -1, True])
def test_git_rejects_unbounded_or_boolean_byte_limits(limit: int) -> None:
    """Invalid limits cannot reach the blob execution call."""
    reader = LocalGitReader(
        workspace_root="/workspace",
        repository_id="source",
        run=MemoryGit(blob_outputs(b"a")),
    )
    with pytest.raises(ValueError, match="positive"):
        reader.read_file(revision="a" * 40, path="src/a.py", limit=limit)


@pytest.mark.parametrize(
    "response",
    [b"x" * 32769, cast("bytes", "not bytes")],
    ids=["oversized", "wrong-type"],
)
def test_command_adapter_output_contract_is_checked(response: bytes) -> None:
    """Injected adapters cannot silently bypass type or allocation limits."""
    reader = LocalGitReader(
        workspace_root="/workspace", repository_id="source", run=MemoryGit([response])
    )
    with pytest.raises(OSError, match="invalid or oversized"):
        reader.identity()


def test_identity_and_file_values_reject_missing_or_invalid_pins() -> None:
    """Draft identities remain explicit, but immutable Git file inputs need pins."""
    assert RepositoryIdentity(id="draft", revision=None).revision is None
    assert full_revision("a" * 40) == "a" * 40
    with pytest.raises(ValueError, match="stable repository"):
        RepositoryIdentity(id="-bad", revision=None)
    with pytest.raises(ValueError, match="pinned identities"):
        RepositoryFile(
            repository=RepositoryIdentity(id="draft", revision=None),
            path="a",
            content=b"",
        )
    with pytest.raises(ValueError, match="pinned identities"):
        RepositoryFile(
            repository=RepositoryIdentity(id="source", revision="a" * 40),
            path="a",
            content=cast("bytes", bytearray()),
        )


def test_execution_errors_propagate_without_success_or_retry() -> None:
    """An unavailable local object/process remains an explicit failed read."""

    def failure(argv: tuple[str, ...], *, output_limit: int) -> bytes:
        """Model an injected operating-system failure without launching Git."""
        raise PermissionError("denied")

    reader = LocalGitReader(
        workspace_root="/workspace", repository_id="source", run=failure
    )
    with pytest.raises(PermissionError, match="denied"):
        reader.identity()
