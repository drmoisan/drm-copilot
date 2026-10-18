"""Portable path values and injected metadata, without filesystem operations.

These values describe a trusted caller's requested scope. They cannot mint native
authority, verify artifact contents, or replace the later atomic mutation layer.
"""

from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, Protocol, TypeAlias

from drm_copilot_discovery.findings import validate_finding_path

if TYPE_CHECKING:
    from collections.abc import Iterable

PathKind: TypeAlias = Literal[
    "file", "directory", "missing", "symlink", "reparse", "other"
]


class PathPolicyError(ValueError):
    """Report an actionable path failure without treating unsafe text as a path.

    Callers may project code/message into findings; repr protects diagnostics
    from control characters. Construction and rendering perform no I/O.
    """

    def __init__(self, code: str, path: str, message: str) -> None:
        """Retain the failed input and stable code; expose a safe error message."""
        self.code = code
        self.path = path
        super().__init__(f"{code}: {path!r}: {message}")


def relative_path(path: str) -> str:
    """Return unchanged portable POSIX spelling, or raise PathPolicyError.

    Reject aliases instead of normalizing attacker-selected input. Spaces,
    capitals and Unicode remain supported. No disk access or decoding occurs.
    """
    try:
        validate_finding_path(path)
    except (TypeError, ValueError, UnicodeError) as error:
        raise PathPolicyError(
            "PATH_SYNTAX", path, "Use a nonempty workspace-relative POSIX path."
        ) from error
    # Windows strips trailing dots/spaces and reserves device stems with suffixes.
    for part in path.split("/"):
        if part.endswith((".", " ")) or '"' in part or "\x7f" in part:
            raise PathPolicyError(
                "PATH_SYNTAX", path, "Remove trailing dots/spaces or unsafe characters."
            )
        stem = part.split(".", 1)[0].rstrip(" ").upper()
        if stem in {
            "CON",
            "PRN",
            "AUX",
            "NUL",
            "CONIN$",
            "CONOUT$",
            "CLOCK$",
        } or re.fullmatch(r"(?:COM|LPT)[1-9¹²³]", stem):
            raise PathPolicyError(
                "PATH_RESERVED", path, "Choose a name other than a Windows device."
            )
    return path


def collision_key(path: str) -> tuple[str, ...]:
    """Return a portable NFC/casefold component key; never grant an alias access."""
    relative_path(path)
    # Compare components, so a sibling textual prefix cannot become containment.
    return tuple(
        unicodedata.normalize("NFC", part).casefold() for part in path.split("/")
    )


def path_contains(root: str, path: str, *, strict: bool = False) -> bool:
    """Test component containment conservatively across case-sensitive hosts too."""
    parent, child = collision_key(root), collision_key(path)
    return child[: len(parent)] == parent and (not strict or len(child) > len(parent))


def check_path_collisions(paths: Iterable[str]) -> tuple[str, ...]:
    """Return sorted paths or reject duplicates and case/Unicode ancestor aliases.

    Shared identical ancestors are permitted. Different spellings of the same
    component are rejected even when their final file names differ. Pure only.
    """
    spellings: dict[tuple[str, ...], str] = {}
    leaves: set[tuple[str, ...]] = set()
    result: list[str] = []
    # Record every prefix to detect aliases such as Docs/a and docs/b.
    for path in paths:
        key = collision_key(path)
        if key in leaves:
            raise PathPolicyError(
                "PATH_COLLISION", path, "Remove duplicate or aliased paths."
            )
        leaves.add(key)
        parts = path.split("/")
        # Preserve exact authored spelling while comparing normalized identities.
        for length in range(1, len(parts) + 1):
            prefix = "/".join(parts[:length])
            prior = spellings.setdefault(key[:length], prefix)
            if prior != prefix:
                raise PathPolicyError(
                    "PATH_COLLISION",
                    path,
                    f"Use one spelling; conflicts with {prior!r}.",
                )
        result.append(path)
    return tuple(sorted(result))


@dataclass(frozen=True, kw_only=True)
class PathMetadata:
    """Describe one non-following inspection from the trusted filesystem adapter.

    Existing entries require stable filesystem identity and an absolute resolved
    path. Directories provide their complete immediate child names, including
    hidden entries, for alias checks. Missing entries have neither identity nor
    path. The policy rejects every link/reparse entry rather than following it.
    """

    kind: PathKind
    identity: str | None = None
    resolved_path: str | None = None
    children: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        """Freeze child names and reject contradictory metadata before use."""
        if self.kind not in {
            "file",
            "directory",
            "missing",
            "symlink",
            "reparse",
            "other",
        }:
            raise ValueError("Unsupported filesystem entry kind")
        if isinstance(self.children, str):
            raise ValueError("Directory children must be a sequence of names")
        object.__setattr__(self, "children", tuple(self.children))
        # Absence and existing identity are mutually exclusive metadata claims.
        if self.kind == "missing":
            if self.identity is not None or self.resolved_path is not None:
                raise ValueError(
                    "Missing entries cannot claim an identity or resolved path"
                )
        elif not self.identity or not self.resolved_path:
            raise ValueError("Existing entries need identity and resolved path")
        if self.kind != "directory" and self.children:
            raise ValueError("Only directories may provide child names")
        # Validate a directory's full namespace before a caller selects one child.
        for child in self.children:
            relative_path(child)
            if "/" in child:
                raise ValueError("Directory children must be immediate names")


class PathMetadataReader(Protocol):
    """Inspect relative entries without following links; '.' denotes the workspace.

    Implementations supply complete directory names and stable device/file IDs,
    raise OSError on unreadable metadata, and must not silently invent absence.
    Unit tests implement this protocol with memory only.
    """

    def __call__(self, path: str) -> PathMetadata:
        """Inspect one workspace-relative entry or raise an explicit I/O error."""
        ...


@dataclass(frozen=True, kw_only=True)
class WriteGrant:
    """Bind one output kind, ID and exact path supplied by a trusted caller.

    This structural value is not a protected host authorization. The path policy
    additionally checks the kind's configured location; the later mutation layer
    checks prospective content, role authority and compare-and-swap digests.
    """

    artifact_kind: str
    artifact_id: str
    path: str

    def __post_init__(self) -> None:
        """Reject malformed IDs and unsafe paths without granting a directory."""
        relative_path(self.path)
        if not re.fullmatch(r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*", self.artifact_id):
            raise ValueError("A write grant requires a stable artifact ID")
        if not re.fullmatch(r"[a-z]+(?:-[a-z]+)*", self.artifact_kind):
            raise ValueError("A write grant requires a literal artifact kind")


@dataclass(frozen=True, kw_only=True)
class PathStamp:
    """Retain identity/type/location for a single ancestor or leaf, without bytes.

    Directory contents are deliberately excluded: unrelated sibling creation
    need not invalidate a write, but aliases are checked again at revalidation.
    """

    path: str
    kind: PathKind
    identity: str | None
    resolved_path: str | None


@dataclass(frozen=True, kw_only=True)
class ResolvedPath:
    """Return a checked location and immutable parent/leaf observations.

    Call revalidate_write immediately before a later atomic filesystem commit.
    This result performs no I/O and cannot prove unchanged content bytes or
    eliminate races between separate OS operations.
    """

    path: str
    absolute_path: str
    observations: tuple[PathStamp, ...]
    grant: WriteGrant | None = None

    def __post_init__(self) -> None:
        """Detach the observation sequence so later caller mutation is harmless."""
        relative_path(self.path)
        object.__setattr__(self, "observations", tuple(self.observations))
