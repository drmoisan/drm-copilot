"""Bound a host read selection to the invocation scope and the resolved target.

A host-principal ``read-source`` request names workspace-relative paths. Each
path must lie within the invocation's ``selected_paths``, resolve through the
configured ``PathPolicy`` read scope, cross no symlink or reparse point in any
observed ancestor or leaf, and resolve to a target that, made workspace
relative, still lies within the selected paths. The policy's resolver is an
injected callable, so this module performs no filesystem call of its own and
every refusal is the exit-3 ``SERVICE_AUTHORITY`` failure.
"""

from __future__ import annotations

from pathlib import PurePosixPath, PureWindowsPath
from typing import TYPE_CHECKING

from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.protected_records import refusal
from drm_copilot_discovery.source_read_models import ReadGrant, ReadSelection

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.path_models import ResolvedPath

LINK_KINDS = frozenset({"symlink", "reparse"})


def within_selection(path: str, selected: tuple[str, ...]) -> bool:
    """Return whether path (str) equals or lies beneath one selected entry (lexical)."""
    return any(path == root or path.startswith(root + "/") for root in selected)


def workspace_relative(resolved: str, workspace_root: str) -> str | None:
    """Return resolved (str) relative to workspace_root in POSIX spelling, or None.

    Pure path arithmetic only: a Windows-spelled root (drive or UNC) compares
    case-insensitively, a POSIX root exactly. None means the resolved target is
    outside the workspace.
    """
    windows = ":" in workspace_root or workspace_root.startswith("\\\\")
    pure = PureWindowsPath if windows else PurePosixPath
    try:
        relative = pure(resolved).relative_to(pure(workspace_root))
    except ValueError:
        return None
    return relative.as_posix()


def select_reads(
    *,
    paths: tuple[str, ...],
    selected: tuple[str, ...],
    workspace_root: str,
    resolve: Callable[[str], ResolvedPath],
) -> ReadSelection:
    """Return the read grants for paths within selected, each resolved and re-checked.

    paths (tuple[str, ...]) are the requested workspace-relative paths; selected
    (tuple[str, ...]) the invocation's selected paths; workspace_root (str) the
    bound workspace; resolve (Callable[[str], ResolvedPath]) the configured
    policy's read resolver. Returns ReadSelection with one ReadGrant per path.
    Raises the SERVICE_AUTHORITY refusal when a path is outside the selection,
    outside the configured scope, crosses a symlink or reparse point, or resolves
    to a target outside the selection.
    """
    grants: list[ReadGrant] = []
    # Each requested path needs the invocation scope, the configured read scope
    # and a resolved target that still lies inside the invocation scope.
    for path in paths:
        if not within_selection(path, selected):
            raise refusal("The read is outside the invocation's selected paths.")
        try:
            target = resolve(path)
        except PathPolicyError as error:
            raise refusal("The read is outside the configured input scope.") from error
        if any(stamp.kind in LINK_KINDS for stamp in target.observations):
            raise refusal("The read crosses a symlink or reparse point.")
        leaf = target.observations[-1]
        relative = (
            None
            if leaf.resolved_path is None
            else workspace_relative(leaf.resolved_path, workspace_root)
        )
        if relative is None or not within_selection(relative, selected):
            raise refusal(
                "The resolved read target is outside the invocation's selected paths."
            )
        grants.append(ReadGrant(path=path, directory=leaf.kind == "directory"))
    return ReadSelection(grants=tuple(grants))
