"""Render caller-owned draft inputs without treating templates as observations."""

from __future__ import annotations

from dataclasses import dataclass, replace
from pathlib import PurePosixPath, PureWindowsPath
from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.path_models import (
    PathMetadata,
    check_path_collisions,
    relative_path,
)
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.resources import read_resource
from drm_copilot_discovery.snapshot import repository_pins

if TYPE_CHECKING:
    from collections.abc import Callable, Mapping

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_io import InitializationIO
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.profile_models import ArtifactKey
    from drm_copilot_discovery.validation import SnapshotValidation

TEMPLATE_ROOT = "docs/discovery/templates/v2"
TEMPLATE_NAMES = (
    "domain-profile.yaml",
    "scope.yaml",
    "coverage-ledger.json",
    "unspecified-behaviors.yaml",
    "product-decisions.yaml",
    "parity-matrix.json",
)
ARTIFACT_TEMPLATES: tuple[tuple[ArtifactKey, str, str], ...] = (
    ("scope", "scope", "scope.yaml"),
    ("coverage_ledger", "coverage-ledger", "coverage-ledger.json"),
    (
        "unspecified_behaviors",
        "unspecified-behavior-collection",
        "unspecified-behaviors.yaml",
    ),
    ("product_decisions", "product-decision-collection", "product-decisions.yaml"),
    ("parity_matrix", "parity-matrix", "parity-matrix.json"),
)
_DIRECTORIES = (
    "feature_contracts",
    "characterization",
    "evidence",
    "inventory",
    "acceptance",
    "reports",
    "source_snapshots",
    "implementation_records",
)


@dataclass(frozen=True, kw_only=True)
class InitializationRequest:
    """Require explicit consumer identity and roots or an explicit unconfigured draft.

    These values are configuration, not a native principal or a write capability.
    Existing compatible profile bytes remain authoritative for optional settings.
    """

    system_id: str
    system_name: str
    role: Literal["legacy-source", "modernization-target", "combined"]
    repository_id: str
    production_roots: tuple[str, ...] = ()
    draft_configuration: bool = False
    test_roots: tuple[str, ...] = ()
    documentation_roots: tuple[str, ...] = ()
    artifact_root: str = "docs/migration/discovery"
    artifact_overrides: tuple[tuple[ArtifactKey, str], ...] = ()

    def __post_init__(self) -> None:
        """Reject ambiguous identities, roots and duplicate overrides before reads."""
        RepositoryIdentity(id=self.system_id, revision=None)
        RepositoryIdentity(id=self.repository_id, revision=None)
        if not self.system_name.strip() or self.role not in {
            "legacy-source",
            "modernization-target",
            "combined",
        }:
            raise ValueError("Initialization requires a system name and explicit role")
        if not self.production_roots and not self.draft_configuration:
            raise ValueError(
                "Supply source roots or explicitly select draft_configuration"
            )
        relative_path(self.artifact_root)
        for name in ("production_roots", "test_roots", "documentation_roots"):
            object.__setattr__(self, name, check_path_collisions(getattr(self, name)))
        overrides = tuple(sorted(self.artifact_overrides))
        if len(dict(overrides)) != len(overrides):
            raise ValueError("Artifact overrides require unique keys")
        for _, path in overrides:
            relative_path(path)
        object.__setattr__(self, "artifact_overrides", overrides)

    def artifact_paths(self) -> JsonObject:
        """Project destinations; ProfileV2 remains responsible for semantic checks."""
        paths: dict[str, JsonValue] = {
            "root": self.artifact_root,
            "profile": self.artifact_root + "/domain-profile.yaml",
            **{
                key: self.artifact_root + "/" + name
                for key, _, name in ARTIFACT_TEMPLATES
            },
            **{
                key: self.artifact_root + "/" + key.replace("_", "-")
                for key in _DIRECTORIES
            },
        }
        for key, value in self.artifact_overrides:
            if key not in paths or key == "root":
                raise ValueError(
                    "Override only named artifact paths; use artifact_root for root"
                )
            paths[key] = value
        return JsonObject(tuple(paths.items()))


@dataclass(frozen=True, kw_only=True)
class InitializationTemplates:
    """Retain six parsed immutable production templates with typed value slots."""

    documents: tuple[tuple[str, JsonObject], ...]

    def __post_init__(self) -> None:
        """Require the complete exact template set without accepting duplicate names."""
        documents = tuple(sorted(self.documents))
        if tuple(name for name, _ in documents) != tuple(sorted(TEMPLATE_NAMES)):
            raise ValueError("Initialization requires all six distinct v2 templates")
        object.__setattr__(self, "documents", documents)

    @classmethod
    def load(
        cls, *, read: Callable[[str], bytes] = read_resource
    ) -> InitializationTemplates:
        """Read declared package resources through an injectable bounded parser seam."""
        documents: list[tuple[str, JsonObject]] = []
        for name in TEMPLATE_NAMES:
            parsed = parse_document(read(TEMPLATE_ROOT + "/" + name), format="yaml")
            if parsed.value is None:
                raise ValueError(f"Invalid initialization template: {name}")
            documents.append((name, parsed.value))
        return cls(documents=tuple(documents))

    def render(self, name: str, values: Mapping[str, JsonValue]) -> bytes:
        """Substitute complete typed slots, so quotes/newlines remain ordinary data."""

        def substitute(value: JsonValue) -> JsonValue:
            """Recursively retain structure and reject missing named template values."""
            if isinstance(value, JsonObject):
                return JsonObject(
                    tuple((key, substitute(child)) for key, child in value.members)
                )
            if isinstance(value, tuple):
                return tuple(substitute(child) for child in value)
            if (
                isinstance(value, str)
                and value.startswith("{{")
                and value.endswith("}}")
            ):
                key = value[2:-2]
                if key not in values:
                    raise ValueError(f"Missing initialization template value: {key}")
                return values[key]
            return value

        return canonical_json(substitute(dict(self.documents)[name]))


def profile_proposal(
    request: InitializationRequest,
    *,
    templates: InitializationTemplates,
    catalog: SchemaCatalog,
    revision: str | None,
) -> bytes:
    """Render a draft whose only repository pin is an explicitly observed local one."""
    RepositoryIdentity(id=request.repository_id, revision=revision)
    paths = request.artifact_paths()
    content = templates.render(
        "domain-profile.yaml",
        {
            "profile_id": "profile-" + request.system_id,
            "system_id": request.system_id,
            "system_name": request.system_name,
            "role": request.role,
            "repository_id": request.repository_id,
            "revision": revision,
            "production_roots": request.production_roots,
            "test_roots": request.test_roots,
            "documentation_roots": request.documentation_roots
            or (request.artifact_root,),
            "evidence_roots": (paths["evidence"],),
            "artifacts": paths,
        },
    )
    profile = ProfileV2(content, catalog=catalog)
    if profile.profile_state != "draft":
        raise ValueError(
            "Initialization templates must produce an honest draft profile"
        )
    return content


def require_compatible(request: InitializationRequest, profile: ProfileV2) -> None:
    """Preserve settings only when identity and explicit requested roots agree."""
    paths = request.artifact_paths()
    identity = (
        profile.system.id,
        profile.system.name,
        profile.system.role,
        profile.repository.id,
    )
    expected = (
        request.system_id,
        request.system_name,
        request.role,
        request.repository_id,
    )
    if (
        identity != expected
        or tuple(sorted(profile.production_roots)) != request.production_roots
    ):
        raise InitializationConflict(
            profile.artifacts["profile"],
            "Existing profile conflicts with requested identity or source roots",
        )
    if request.test_roots and tuple(sorted(profile.test_roots)) != request.test_roots:
        raise InitializationConflict(
            profile.artifacts["profile"],
            "Existing profile conflicts with requested test roots",
        )
    if (
        request.documentation_roots
        and tuple(sorted(profile.documentation_roots)) != request.documentation_roots
    ):
        raise InitializationConflict(
            profile.artifacts["profile"],
            "Existing profile conflicts with requested documentation roots",
        )
    for key in ("root", "profile", *(key for key, _ in request.artifact_overrides)):
        if profile.artifacts[cast("ArtifactKey", key)] != paths[key]:
            raise InitializationConflict(
                profile.artifacts["profile"],
                f"Existing profile conflicts with requested artifact path: {key}",
            )


def artifact_values(profile: ProfileV2, *, scope_id: str) -> dict[str, JsonValue]:
    """Populate empty draft collections from the effective consumer profile only."""
    source, target = repository_pins(profile)
    return {
        "system_id": profile.system.id,
        "repository_id": profile.repository.id,
        "revision": profile.repository.revision,
        "production_roots": profile.production_roots,
        "required_modes": profile.required_modes,
        "scope_id": scope_id,
        "ledger_id": "ledger-" + profile.system.id,
        "unresolved_id": "unresolved-" + profile.system.id,
        "decisions_id": "decisions-" + profile.system.id,
        "parity_id": "parity-" + profile.system.id,
        "source_repositories": tuple(
            JsonObject(tuple(pin.to_dict().items())) for pin in source
        ),
        "target_repositories": tuple(
            JsonObject(tuple(pin.to_dict().items())) for pin in target
        ),
    }


@dataclass(frozen=True, kw_only=True)
class InitializationCapture:
    """Separate a validation-only proposal from exact observed physical inputs."""

    proposal_base: CapturedWorkspace
    physical_metadata: tuple[tuple[str, PathMetadata], ...]
    physical_files: tuple[tuple[str, bytes], ...]
    profile_missing: bool

    def require_same(self, other: InitializationCapture) -> None:
        """
        Reject any changed byte, checkout, namespace, absence or physical identity.
        """
        if (
            self.physical_metadata != other.physical_metadata
            or self.physical_files != other.physical_files
            or self.proposal_base.snapshot.sha256 != other.proposal_base.snapshot.sha256
            or self.proposal_base.workspace_root != other.proposal_base.workspace_root
            or self.profile_missing != other.profile_missing
        ):
            before, after = dict(self.physical_metadata), dict(other.physical_metadata)
            paths = sorted(
                path
                for path in before.keys() | after.keys()
                if path != "." and before.get(path) != after.get(path)
            )
            raise InitializationConflict(
                (
                    paths[0]
                    if paths
                    else self.proposal_base.snapshot.profile.artifacts["profile"]
                ),
                "Initialization inputs changed; reload the complete proposal",
            )


class ProposalInputs:
    """Overlay explicit proposals while separately recording every actual inspection."""

    def __init__(
        self,
        owner: InitializationIO,
        profile_path: str,
        profile_bytes: bytes,
        directories: tuple[str, ...],
    ) -> None:
        """Retain one transient overlay; never reuse it for another capture."""
        self.owner, self.profile_path, self.profile_bytes = (
            owner,
            profile_path,
            profile_bytes,
        )
        self.metadata: dict[str, PathMetadata] = {}
        self.files: dict[str, bytes] = {}
        self.profile_missing = self.physical(profile_path).kind == "missing"
        self.directories: set[str] = set()
        # Include only ancestors of proposed outputs, never invent source inputs.
        for path in (*directories, profile_path if self.profile_missing else ""):
            if path:
                parts = relative_path(path).split("/")
                count = len(parts) - (path == profile_path)
                self.directories.update(
                    "/".join(parts[:index]) for index in range(1, count + 1)
                )

    def physical(self, path: str) -> PathMetadata:
        """Record exact stable observations before adding any virtual children."""
        value = self.owner.metadata(path)
        value = replace(value, children=tuple(sorted(value.children)))
        if self.metadata.setdefault(path, value) != value:
            raise OSError("Initialization metadata changed during capture")
        return value

    def inspect(self, path: str) -> PathMetadata:
        """Expose virtual entries only where the physical reader proved absence."""
        value = self.physical(path)
        virtual_file = self.profile_missing and path == self.profile_path
        if value.kind == "missing" and (path in self.directories or virtual_file):
            root = (
                PureWindowsPath(self.owner.workspace_root)
                if ":" in self.owner.workspace_root
                or self.owner.workspace_root.startswith("\\\\")
                else PurePosixPath(self.owner.workspace_root)
            )
            value = PathMetadata(
                kind="file" if virtual_file else "directory",
                identity="initialization-proposal:" + path,
                resolved_path=root.joinpath(path).as_posix(),
            )
        if value.kind == "directory":
            prefix = "" if path == "." else path + "/"
            proposed = set(self.directories)
            if self.profile_missing:
                proposed.add(self.profile_path)
            names = {
                item[len(prefix) :].split("/")[0]
                for item in proposed
                if item.startswith(prefix) and item != path
            }
            value = replace(value, children=tuple(sorted(set(value.children) | names)))
        return value

    def read(self, path: str, *, limit: int) -> bytes:
        """Never record synthetic profile bytes as an observed physical input."""
        if self.profile_missing and path == self.profile_path:
            if len(self.profile_bytes) > limit:
                raise OSError("Proposed profile exceeds the read limit")
            return self.profile_bytes
        value = self.owner.read_bytes(path, limit=limit)
        if self.files.setdefault(path, value) != value:
            raise OSError("Initialization bytes changed during capture")
        return value


@dataclass(frozen=True, kw_only=True)
class InitializationOutput:
    """Describe one file/directory disposition without implying completion authority."""

    path: str
    kind: str
    status: Literal["planned", "created", "skipped", "conflict"]
    sha256: str | None = None


@dataclass(frozen=True, kw_only=True)
class InitializationResult:
    """
    Report structural validity and exact partial effects, never a completion receipt.
    """

    ok: bool
    outputs: tuple[InitializationOutput, ...]
    validation: SnapshotValidation
    authority_invalidated: bool
    uncertain_paths: tuple[str, ...] = ()
    error: str | None = None
    notes: tuple[str, ...] = ()


class InitializationConflict(ValueError):
    """Expose exact conflicting paths and findings without parsing exception prose."""

    def __init__(
        self,
        path: str,
        message: str,
        *,
        kind: str = "artifact",
        findings: tuple[Finding, ...] = (),
    ) -> None:
        """Retain a compatible ValueError and deterministic typed conflict outputs."""
        paths = tuple(
            sorted(
                {item.artifact_path for item in findings if item.artifact_path}
                or {path}
            )
        )
        self.outputs = tuple(
            InitializationOutput(path=item, kind=kind, status="conflict")
            for item in paths
        )
        self.findings = findings or (
            Finding(
                code="INITIALIZATION_CONFLICT",
                artifact_path=path,
                message=message,
                next_action="Correct existing content and reload initialization.",
            ),
        )
        super().__init__(message)
