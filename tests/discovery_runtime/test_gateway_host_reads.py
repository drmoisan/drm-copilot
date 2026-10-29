"""Prove the host read selection re-checks every resolved target against the scope."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.gateway_host_reads import (
    select_reads,
    within_selection,
    workspace_relative,
)
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.path_models import PathPolicyError, PathStamp, ResolvedPath

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.path_models import PathKind

WORKSPACE = "C:/workspace"
SELECTED = ("application", "docs/readme.md")


def stamp(path: str, kind: PathKind = "file", resolved: str | None = None) -> PathStamp:
    """Return one observation for path; by default it resolves inside the workspace."""
    return PathStamp(
        path=path,
        kind=kind,
        identity=None if kind == "missing" else path,
        resolved_path=(
            None if kind == "missing" else (resolved or f"{WORKSPACE}/{path}")
        ),
    )


def resolved(*stamps: PathStamp) -> ResolvedPath:
    """Return a resolution whose observations are stamps, keyed by the leaf path."""
    leaf = stamps[-1]
    return ResolvedPath(
        path=leaf.path,
        absolute_path=f"{WORKSPACE}/{leaf.path}",
        observations=tuple(stamps),
    )


def ordinary(path: str, kind: PathKind = "file") -> ResolvedPath:
    """Return the ordinary resolution of path (str): root, ancestors and the leaf."""
    parts = path.split("/")
    ancestors = [stamp(".", "directory", WORKSPACE)]
    # Every ancestor is an ordinary directory; only the leaf carries kind.
    for index in range(1, len(parts)):
        ancestors.append(stamp("/".join(parts[:index]), "directory"))
    return resolved(*ancestors, stamp(path, kind))


def refused(action: Callable[[], object]) -> str:
    """Return the refusal message of action (a zero-argument callable)."""
    with pytest.raises(OperationFailure) as caught:
        action()
    assert caught.value.exit_code == 3
    assert [finding.code for finding in caught.value.findings] == ["SERVICE_AUTHORITY"]
    return caught.value.findings[0].message


def test_ordinary_targets_inside_the_selection_are_granted() -> None:
    """A file and a directory inside the selected paths yield exact read grants."""
    selection = select_reads(
        paths=("application/orders.cs", "application/billing", "docs/readme.md"),
        selected=SELECTED,
        workspace_root=WORKSPACE,
        resolve=lambda path: ordinary(
            path, "directory" if path == "application/billing" else "file"
        ),
    )

    assert [(grant.path, grant.directory) for grant in selection.grants] == [
        ("application/billing", True),
        ("application/orders.cs", False),
        ("docs/readme.md", False),
    ]


def test_a_path_outside_the_selection_is_refused_before_resolution() -> None:
    """The invocation scope is checked lexically before the policy resolves anything."""
    calls: list[str] = []

    def resolve(path: str) -> ResolvedPath:
        """Record a resolution that must never happen."""
        calls.append(path)
        return ordinary(path)

    message = refused(
        lambda: select_reads(
            paths=("applications/orders.cs",),
            selected=SELECTED,
            workspace_root=WORKSPACE,
            resolve=resolve,
        )
    )

    assert "outside the invocation's selected paths" in message
    assert calls == []


def test_a_policy_refusal_is_reported_as_the_configured_scope() -> None:
    """A PathPolicyError from the resolver is the configured-scope refusal."""

    def resolve(path: str) -> ResolvedPath:
        """Refuse every path as the policy does for an undeclared root."""
        raise PathPolicyError("PATH_READ_DENIED", path, "Select a configured path.")

    message = refused(
        lambda: select_reads(
            paths=("application/orders.cs",),
            selected=SELECTED,
            workspace_root=WORKSPACE,
            resolve=resolve,
        )
    )

    assert "outside the configured input scope" in message


@pytest.mark.parametrize("kind", ["symlink", "reparse"])
@pytest.mark.parametrize("position", ["ancestor", "leaf"])
def test_a_link_in_any_observation_is_refused(kind: PathKind, position: str) -> None:
    """A symlink or reparse stamp anywhere in the observations refuses the read."""
    # The link resolves inside the selection, so only the link check can refuse it.
    observations = [
        stamp(".", "directory", WORKSPACE),
        stamp("application", kind if position == "ancestor" else "directory"),
        stamp("application/orders.cs", kind if position == "leaf" else "file"),
    ]

    message = refused(
        lambda: select_reads(
            paths=("application/orders.cs",),
            selected=SELECTED,
            workspace_root=WORKSPACE,
            resolve=lambda _path: resolved(*observations),
        )
    )

    assert message == "The read crosses a symlink or reparse point."


@pytest.mark.parametrize(
    "target",
    [
        f"{WORKSPACE}/verification/orders.cs",
        f"{WORKSPACE}/applications/orders.cs",
        "C:/elsewhere/application/orders.cs",
        "D:/workspace/application/orders.cs",
    ],
)
def test_a_resolved_target_outside_the_selection_is_refused(target: str) -> None:
    """An ordinary leaf resolving outside the selection or the workspace is refused."""
    message = refused(
        lambda: select_reads(
            paths=("application/orders.cs",),
            selected=SELECTED,
            workspace_root=WORKSPACE,
            resolve=lambda _path: resolved(
                stamp(".", "directory", WORKSPACE),
                stamp("application", "directory"),
                stamp("application/orders.cs", "file", target),
            ),
        )
    )

    assert message == (
        "The resolved read target is outside the invocation's selected paths."
    )


def test_a_leaf_without_a_resolved_path_is_refused() -> None:
    """A missing leaf carries no resolved target and grants nothing."""
    message = refused(
        lambda: select_reads(
            paths=("application/orders.cs",),
            selected=SELECTED,
            workspace_root=WORKSPACE,
            resolve=lambda _path: resolved(
                stamp(".", "directory", WORKSPACE),
                stamp("application", "directory"),
                stamp("application/orders.cs", "missing"),
            ),
        )
    )

    assert "resolved read target" in message


def test_workspace_relative_follows_the_root_spelling() -> None:
    """Windows roots compare case-insensitively and POSIX roots exactly."""
    assert workspace_relative("C:/Workspace/app/a.cs", "C:/workspace") == "app/a.cs"
    assert workspace_relative("C:/elsewhere/app/a.cs", "C:/workspace") is None
    assert workspace_relative("/workspace/app/a.cs", "/workspace") == "app/a.cs"
    assert workspace_relative("/Workspace/app/a.cs", "/workspace") is None
    assert workspace_relative("/workspace", "/workspace") == "."
    assert within_selection("application/x", ("application",)) is True
    assert within_selection("applications/x", ("application",)) is False
    assert within_selection("docs/readme.md", ("docs/readme.md",)) is True
