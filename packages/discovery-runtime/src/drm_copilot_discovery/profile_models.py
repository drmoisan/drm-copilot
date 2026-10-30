"""Typed immutable views of a validated discovery profile and inherited policy.

Views retain their validated profile rather than accepting unchecked field copies.
They perform no I/O and do not establish completion or native authority.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import TYPE_CHECKING, ClassVar, Literal, TypeAlias, cast

from drm_copilot_discovery.models import JsonObject, ParseLimits

if TYPE_CHECKING:
    from drm_copilot_discovery.profile_v2 import ProfileV2

SystemRole: TypeAlias = Literal["legacy-source", "modernization-target", "combined"]
RepositoryRole: TypeAlias = Literal["legacy-source", "modernization-target"]
RuntimeCapability: TypeAlias = Literal["none", "manual", "semi-automated", "automated"]
PlanningPrerequisite: TypeAlias = Literal[
    "none", "discovery-complete", "parity-complete"
]
CompletionGate: TypeAlias = Literal[
    "require_confirmed_scope",
    "require_current_inventory",
    "require_all_dispositions",
    "require_feature_evidence",
    "require_acceptance_scenarios",
    "require_runtime_for_declared_features",
    "block_on_unresolved_required_behavior",
    "require_approved_deviations",
]
ArtifactKey: TypeAlias = Literal[
    "root",
    "profile",
    "scope",
    "coverage_ledger",
    "unspecified_behaviors",
    "product_decisions",
    "parity_matrix",
    "feature_contracts",
    "characterization",
    "evidence",
    "inventory",
    "acceptance",
    "reports",
    "source_snapshots",
    "implementation_records",
]
CORE_CLAIM_RULES = frozenset(
    {
        "profile-validity",
        "path-safety",
        "claim-consistency",
        "verified-evidence",
        "passed-runtime-evidence",
        "exclusion-rationale",
    }
)
FEATURE_DIMENSIONS = frozenset(
    {
        "trigger",
        "preconditions",
        "inputs",
        "state_transitions",
        "observable_outputs",
        "side_effects",
        "ordering",
        "timing",
        "cancellation",
        "failure",
        "online",
        "offline",
        "mobile",
        "alternate_clients",
        "environment_constraints",
        "security_permissions",
    }
)


@dataclass(frozen=True)
class _Section:
    """Bind a fixed schema section to a validated root, optionally by array index."""

    profile: ProfileV2
    index: int | None = None
    section: ClassVar[str]
    array: ClassVar[bool] = False

    def __post_init__(self) -> None:
        """Reject unchecked roots and indexes before exposing narrowed field types."""
        from drm_copilot_discovery.profile_v2 import ProfileV2

        if not isinstance(cast("object", self.profile), ProfileV2):
            raise ValueError("Profile views require a validated ProfileV2")
        # Indexed records need a bounded array position; object sections forbid one.
        if self.array:
            values = cast("tuple[JsonObject, ...]", self.profile.document[self.section])
            if type(self.index) is not int or not 0 <= self.index < len(values):
                raise ValueError(f"Invalid {self.section} index")
        elif self.index is not None:
            raise ValueError(f"{self.section} is not an indexed section")

    @property
    def data(self) -> JsonObject:
        """Return only the immutable section whose schema was already validated."""
        value = self.profile.document[self.section]
        if self.array:
            return cast("tuple[JsonObject, ...]", value)[cast("int", self.index)]
        return cast("JsonObject", value)


@dataclass(frozen=True)
class SystemProfile(_Section):
    """Identify the consumer system without assigning domain-specific semantics."""

    section: ClassVar[str] = "system"

    @property
    def id(self) -> str:
        """Return the stable system identifier."""
        return cast("str", self.data["id"])

    @property
    def name(self) -> str:
        """Return the configured display name."""
        return cast("str", self.data["name"])

    @property
    def role(self) -> SystemRole:
        """Keep source, target and combined ownership explicit."""
        return cast("SystemRole", self.data["role"])


@dataclass(frozen=True)
class RepositoryProfile(_Section):
    """Describe the local Git identity and its configured revision policy."""

    section: ClassVar[str] = "repository"

    @property
    def id(self) -> str:
        """Return the local repository identifier."""
        return cast("str", self.data["id"])

    @property
    def revision(self) -> str | None:
        """Preserve a draft's absent revision instead of inventing a pin."""
        return cast("str | None", self.data["revision"])

    @property
    def revision_policy(self) -> Literal["pinned", "working-tree-at-pin"]:
        """Return the policy without claiming that a checkout has been inspected."""
        return cast(
            'Literal["pinned", "working-tree-at-pin"]', self.data["revision_policy"]
        )

    @property
    def vcs(self) -> Literal["git"]:
        """Expose the only supported repository identity format."""
        return "git"


@dataclass(frozen=True)
class RelatedRepository(_Section):
    """Preserve source/target pins and explicit snapshot/client links separately."""

    section: ClassVar[str] = "repositories"
    array: ClassVar[bool] = True

    @property
    def id(self) -> str:
        """Return the related repository identifier."""
        return cast("str", self.data["id"])

    @property
    def role(self) -> RepositoryRole:
        """Return the source or target role for this reference."""
        return cast("RepositoryRole", self.data["role"])

    @property
    def revision(self) -> str | None:
        """Return an immutable revision or an explicitly incomplete draft value."""
        return cast("str | None", self.data["revision"])

    @property
    def snapshot_manifest(self) -> str | None:
        """Name the local transport manifest without reading or trusting its bytes."""
        return cast("str | None", self.data["snapshot_manifest"])

    @property
    def clients(self) -> tuple[str, ...]:
        """Return declared client links in authored order."""
        return cast("tuple[str, ...]", self.data["clients"])


@dataclass(frozen=True)
class ClientProfile(_Section):
    """Describe one target client without weakening inherited requirements."""

    section: ClassVar[str] = "clients"
    array: ClassVar[bool] = True

    @property
    def id(self) -> str:
        """Return the stable client identifier."""
        return cast("str", self.data["id"])

    @property
    def target_repository(self) -> str:
        """Return the target ownership reference."""
        return cast("str", self.data["target_repository"])

    @property
    def platforms(self) -> tuple[str, ...]:
        """Return the client's configured platform obligations."""
        return cast("tuple[str, ...]", self.data["platforms"])

    @property
    def modes(self) -> tuple[str, ...]:
        """Return explicit operating modes; offline is never inferred."""
        return cast("tuple[str, ...]", self.data["modes"])

    @property
    def required_feature_dimensions(self) -> tuple[str, ...]:
        """Return client additions to the global dimension requirements."""
        return cast("tuple[str, ...]", self.data["required_feature_dimensions"])

    @property
    def applicability_defaults(self) -> JsonObject:
        """Preserve classified applicability and rationale without approving waivers."""
        return cast("JsonObject", self.data["applicability_defaults"])


@dataclass(frozen=True)
class RuntimeProfile(_Section):
    """Keep characterization capability distinct from observed outcomes."""

    section: ClassVar[str] = "runtime"

    @property
    def capability(self) -> RuntimeCapability:
        """Return the declared means of collecting runtime evidence."""
        return cast("RuntimeCapability", self.data["capability"])

    @property
    def required_feature_ids(self) -> tuple[str, ...]:
        """Return explicit runtime obligations even when capability is absent."""
        return cast("tuple[str, ...]", self.data["required_feature_ids"])


@dataclass(frozen=True)
class AnalyzerProfile(_Section):
    """Expose read-only analyzer selection, limits, exclusions and enrichment inputs."""

    section: ClassVar[str] = "analyzers"

    @property
    def enabled(self) -> tuple[str, ...]:
        """Return only schema-declared analyzer names."""
        return cast("tuple[str, ...]", self.data["enabled"])

    @property
    def max_file_bytes(self) -> int:
        """Normalize this schema-valid integer field and apply its finite default."""
        return int(
            cast(
                "int",
                cast("JsonObject", self.data["options"]).get(
                    "max_file_bytes", 16777216
                ),
            )
        )

    @property
    def ignored_paths(self) -> tuple[JsonObject, ...]:
        """Keep each exclusion together with its mandatory rationale."""
        return cast("tuple[JsonObject, ...]", self.data["ignored_paths"])

    @property
    def extension_result_manifests(self) -> tuple[str, ...]:
        """Return inert local adapter results, never executable plugin paths."""
        return cast("tuple[str, ...]", self.data["extension_result_manifests"])


@dataclass(frozen=True)
class ArtifactRoots(_Section):
    """Expose exact configured artifact paths without resolving filesystem authority."""

    section: ClassVar[str] = "artifacts"

    def __getitem__(self, key: ArtifactKey) -> str:
        """Return an exact artifact key; unknown names raise KeyError."""
        return cast("str", self.data[key])


@dataclass(frozen=True)
class GatePolicy(_Section):
    """Separate configurable completion prerequisites from mandatory claim validity."""

    section: ClassVar[str] = "completion_gates"

    def required(self, gate: CompletionGate) -> bool:
        """Return an explicit boolean completion switch, rejecting other field names."""
        value = self.data[gate]
        if type(value) is not bool:
            raise ValueError("A completion switch must name a boolean gate")
        return value

    @property
    def planning_prerequisite(self) -> PlanningPrerequisite:
        """Return root-authored planning policy without analyst overrides."""
        return cast("PlanningPrerequisite", self.data["planning_prerequisite"])

    @property
    def mandatory_claim_rules(self) -> frozenset[str]:
        """Keep claim validity, evidence and path safety mandatory."""
        return CORE_CLAIM_RULES


@dataclass(frozen=True, kw_only=True)
class ProfileLimits:
    """Supply finite documented defaults for optional root-configured input limits."""

    document_bytes: int = 16777216
    nesting_depth: int = 64
    artifact_records: int = 100000
    source_files: int = 1000000

    def __post_init__(self) -> None:
        """Reuse parser ceilings and reject unbounded source enumeration."""
        self.parse_limits()
        if type(self.source_files) is not int or not 1 <= self.source_files <= 10000000:
            raise ValueError("source_files must be an integer between 1 and 10000000")

    def parse_limits(self) -> ParseLimits:
        """Project the same configured limits into the structured-input parser."""
        return ParseLimits(
            document_bytes=self.document_bytes,
            nesting_depth=self.nesting_depth,
            artifact_records=self.artifact_records,
        )


@dataclass(frozen=True, kw_only=True)
class ProfileRequirements:
    """Hold deterministic unions of global, client and feature-specific obligations."""

    platforms: tuple[str, ...]
    modes: tuple[str, ...]
    dimensions: tuple[str, ...]

    def __post_init__(self) -> None:
        """Detach and normalize obligations while rejecting invalid identifiers."""
        # No layer may remove earlier obligations; each axis is an independent set.
        for name in ("platforms", "modes", "dimensions"):
            raw: object = getattr(self, name)
            if not isinstance(raw, (tuple, list)):
                raise ValueError(f"Invalid required {name}")
            values = cast("tuple[object, ...] | list[object]", raw)
            pattern = r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*"
            # Validate all members before applying any obligations from this axis.
            if any(
                not isinstance(item, str)
                or re.fullmatch(pattern, item) is None
                or (name == "dimensions" and item not in FEATURE_DIMENSIONS)
                for item in values
            ):
                raise ValueError(f"Invalid required {name}")
            object.__setattr__(
                self, name, tuple(sorted(set(cast("tuple[str, ...]", values))))
            )
