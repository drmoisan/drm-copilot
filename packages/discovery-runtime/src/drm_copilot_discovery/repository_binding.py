"""Bind the installed Git reader from an explicit id or the activated profile.

The service pins source bytes to the repository the domain profile declares. A
console or gateway invocation that names no ``--repository-id`` previously ran
without any reader, so every pinned-source rule failed with
``REVISION_CONTENT_UNAVAILABLE`` on a correctly configured workspace. This
module derives the default identity from the workspace's own configuration:
the ``config/discovery.json`` locator names the profile, and the profile's
``repository`` block names the Git repository. An explicit id always wins and
reads nothing. The derivation is a default, never authority: the snapshot
loader still rejects a reader whose identity disagrees with the captured
profile, and a locator or profile that cannot be read or parsed yields no
reader so the service reports the configuration defect itself.
"""

from __future__ import annotations

from functools import partial
from pathlib import Path
from typing import TYPE_CHECKING

from drm_copilot_discovery.configuration import LOCATOR_PATH
from drm_copilot_discovery.gateway_local import run_local_git
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.path_models import PathPolicyError, relative_path
from drm_copilot_discovery.repository_reader import LocalGitReader
from drm_copilot_discovery.snapshot_io import document_format

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.repository_reader import GitCommand, RepositoryReader

LOCATOR_LIMIT = 65536
PROFILE_LIMIT = 16777216


def read_workspace_bytes(root: str, relative: str, limit: int) -> bytes | None:
    """Read at most limit bytes of one workspace file; absent or oversized is None.

    root (str): trusted absolute workspace. relative (str): validated relative
    POSIX path. limit (int): positive byte ceiling. Returns the complete bytes, or
    None when the file is missing, is a directory, or exceeds limit; the service
    reports those states through its own configuration rules. Other OSErrors
    propagate unchanged. Reads one file and writes nothing.
    """
    try:
        with Path(root, relative).open("rb") as handle:
            content = handle.read(limit + 1)
    except (FileNotFoundError, NotADirectoryError, IsADirectoryError):
        return None
    return None if len(content) > limit else content


def configured_repository_id(
    root: str, *, read_bytes: Callable[[str, int], bytes | None]
) -> str | None:
    """Return the Git repository id the activated profile declares, or None.

    root (str): trusted absolute canonical workspace. read_bytes
    (Callable[[str, int], bytes | None]): bounded reader of workspace-relative
    files returning None for an absent file. Returns str when the locator names a
    readable profile whose ``repository.vcs`` is ``git``; None when the locator or
    profile is absent, malformed, over its limit, names an unsafe path, or
    declares another VCS. Reads at most two files; no reader is constructed.
    """
    locator = read_bytes(LOCATOR_PATH, LOCATOR_LIMIT)
    if locator is None:
        return None
    parsed = parse_document(
        locator, format="json", limits=ParseLimits(document_bytes=LOCATOR_LIMIT)
    )
    profile_path = parsed.value.get("profile_path") if parsed.value else None
    # The locator only names the profile; an unsafe spelling never reaches disk.
    if type(profile_path) is not str:
        return None
    try:
        relative = relative_path(profile_path)
    except PathPolicyError:
        return None
    raw = read_bytes(relative, PROFILE_LIMIT)
    if raw is None:
        return None
    profile = parse_document(raw, format=document_format(relative))
    repository = profile.value.get("repository") if profile.value else None
    # Only a Git-backed declared repository can be served by the local Git reader.
    if type(repository) is not JsonObject or repository.get("vcs") != "git":
        return None
    identifier = repository.get("id")
    return identifier if type(identifier) is str else None


def installed_repository(
    root: str,
    repository_id: str | None,
    *,
    run: GitCommand = run_local_git,
    read_bytes: Callable[[str, int], bytes | None] | None = None,
) -> RepositoryReader | None:
    """Bind root to one LocalGitReader for the explicit or configured identity.

    root (str): trusted absolute canonical workspace. repository_id (str | None):
    explicit outer identity, which is used unchanged without any read. run
    (GitCommand): bounded Git execution seam. read_bytes (Callable[[str, int],
    bytes | None] | None): workspace file reader for the derivation; None selects
    the bounded filesystem reader rooted at root. Returns a reader, or None when
    neither an explicit nor a configured Git identity exists. ValueError from an
    invalid identity or root propagates; Git is not executed here.
    """
    identifier = repository_id
    # The explicit identity is outer data and bypasses the workspace entirely.
    if identifier is None:
        reader: Callable[[str, int], bytes | None] = read_bytes or partial(
            read_workspace_bytes, root
        )
        identifier = configured_repository_id(root, read_bytes=reader)
    if identifier is None:
        return None
    return LocalGitReader(workspace_root=root, repository_id=identifier, run=run)
