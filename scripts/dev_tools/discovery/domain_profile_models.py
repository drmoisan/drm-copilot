"""Frozen value objects and the error type for the discovery profile.

Purpose:
    Hold the domain-neutral dataclass graph (``DomainProfile`` and its four
    sub-configs) and the ``DomainProfileError`` exception. These are separated
    from ``domain_profile.py`` so both modules stay under the repository
    500-line file-size limit while keeping one public import surface (re-exported
    from the package ``__init__``).

Invariants / Constraints:
    - Every dataclass is ``frozen=True`` and re-asserts its local invariants in
      ``__post_init__`` so a direct constructor call cannot produce an invalid
      instance.
    - List fields are normalized to tuples so frozen instances are truly
      immutable and hashable.
    - Only ``profile_version`` equal to the integer ``1`` is accepted.

Side Effects:
    None.
"""

from __future__ import annotations

from dataclasses import dataclass


class DomainProfileError(ValueError):
    """Raised when a domain profile is missing, unreadable, or invalid.

    A specific, catchable subclass of ``ValueError``. The parse layer raises a
    single instance whose message enumerates every collected field defect; the
    CLI boundary catches only this type.
    """


@dataclass(frozen=True)
class LegacySourceConfig:
    """Legacy-source location and file-selection globs.

    Args:
        root: Non-empty path to the legacy source (absolute or relative to the
            profile file's directory).
        description: Optional free-form label.
        include: Glob patterns selecting files; empty selects all.
        exclude: Glob patterns excluding files; empty excludes none.
    """

    root: str
    description: str | None = None
    include: tuple[str, ...] = ()
    exclude: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        object.__setattr__(self, "include", tuple(self.include))
        object.__setattr__(self, "exclude", tuple(self.exclude))
        if not self.root.strip():
            raise DomainProfileError("legacy_source.root must be a non-empty string")


@dataclass(frozen=True)
class TargetConfig:
    """Modern-target location.

    Args:
        root: Non-empty path to the target checkout.
        description: Optional free-form label.
    """

    root: str
    description: str | None = None

    def __post_init__(self) -> None:
        if not self.root.strip():
            raise DomainProfileError("target.root must be a non-empty string")


@dataclass(frozen=True)
class TechnologyStackConfig:
    """Free-form technology-stack identifiers for legacy and target sides.

    Args:
        legacy: Non-empty tuple of non-empty stack identifiers.
        target: Optional tuple of non-empty stack identifiers.
    """

    legacy: tuple[str, ...]
    target: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        object.__setattr__(self, "legacy", tuple(self.legacy))
        object.__setattr__(self, "target", tuple(self.target))
        if not self.legacy:
            raise DomainProfileError("technology_stack.legacy must be a non-empty list")


@dataclass(frozen=True)
class ArtifactsConfig:
    """Discovery-artifact workspace root and free-form conventions mapping.

    Conventions are stored as ordered ``(key, value)`` pairs so the frozen
    instance stays immutable and hashable; ``conventions_map`` exposes a plain
    ``dict``. Convention keys are not validated against any vocabulary here.

    Args:
        root: Non-empty workspace root where discovery artifacts are written.
        conventions: Ordered pairs of non-empty artifact-kind key and path.
    """

    root: str
    conventions: tuple[tuple[str, str], ...] = ()

    def __post_init__(self) -> None:
        object.__setattr__(self, "conventions", tuple(self.conventions))
        if not self.root.strip():
            raise DomainProfileError("artifacts.root must be a non-empty string")
        for key, value in self.conventions:
            if not key.strip() or not value.strip():
                raise DomainProfileError(
                    "artifacts.conventions keys and values must be non-empty strings"
                )

    @property
    def conventions_map(self) -> dict[str, str]:
        """Return the conventions as a plain ``dict[str, str]``."""
        return dict(self.conventions)


@dataclass(frozen=True)
class DomainProfile:
    """A fully resolved, validated domain profile.

    Args:
        profile_version: Evolution gate; only the integer ``1`` is accepted.
        legacy_source: Legacy-source configuration.
        target: Target configuration.
        technology_stack: Technology-stack configuration.
        artifacts: Artifacts configuration.
        profile_name: Optional report label with no semantics.
    """

    profile_version: int
    legacy_source: LegacySourceConfig
    target: TargetConfig
    technology_stack: TechnologyStackConfig
    artifacts: ArtifactsConfig
    profile_name: str | None = None

    def __post_init__(self) -> None:
        if self.profile_version != 1:
            raise DomainProfileError(
                f"profile_version must be 1, got {self.profile_version!r}"
            )
