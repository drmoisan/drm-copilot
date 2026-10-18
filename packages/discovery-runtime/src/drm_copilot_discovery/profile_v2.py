"""Authoritative pure v2 profile construction and inherited gate configuration."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal, cast

from drm_copilot_discovery.catalog import SchemaCatalog, load_catalog
from drm_copilot_discovery.domain_profile_models import DomainProfileError
from drm_copilot_discovery.findings import (
    Finding,
    FindingCollector,
    child_pointer,
    ordered_findings,
)
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.profile_models import (
    AnalyzerProfile,
    ArtifactRoots,
    ClientProfile,
    GatePolicy,
    ProfileLimits,
    ProfileRequirements,
    RelatedRepository,
    RepositoryProfile,
    RuntimeProfile,
    SystemProfile,
)
from drm_copilot_discovery.schema_validation import validate_document


class ProfileError(DomainProfileError):
    """Retain deterministic findings without exposing partial configuration."""

    def __init__(self, findings: tuple[Finding, ...]) -> None:
        """Keep bounded findings alongside the compatible text exception."""
        self.findings = ordered_findings(findings)
        # Stable pointer-prefixed messages are also usable by thin text adapters.
        super().__init__(
            "\n".join(
                f"{item.pointer or '/'}: {item.message}" for item in self.findings
            )
        )


def _binding_findings(
    document: JsonObject, catalog: SchemaCatalog
) -> tuple[Finding, ...]:
    """Validate profile-local identities and exact extension declarations only."""
    problems = FindingCollector()

    def problem(pointer: str, message: str) -> None:
        """Keep local graph defects in the same actionable finding vocabulary."""
        problems.add(
            Finding(
                code="PROFILE_BINDING",
                pointer=pointer,
                message=message,
                next_action="Correct identifiers or pinned extension declarations.",
            )
        )

    # Identity uniqueness is stronger than JSON Schema's whole-record uniqueItems.
    for key in ("repositories", "clients", "decision_owners"):
        seen: set[str] = set()
        # Distinct records sharing an ID cannot silently overwrite one another.
        for index, item in enumerate(cast("tuple[JsonObject, ...]", document[key])):
            identifier = cast("str", item["id"])
            if identifier in seen:
                problem(
                    f"/{key}/{index}/id", f"Duplicate {key} identifier: {identifier}"
                )
            seen.add(identifier)
    # Source and target declarations remain separate from the local checkout record.
    repositories = {
        cast("str", item["id"]): item
        for item in cast("tuple[JsonObject, ...]", document["repositories"])
    }
    # Index client ownership without treating display metadata as identity.
    clients = {
        cast("str", item["id"]): item
        for item in cast("tuple[JsonObject, ...]", document["clients"])
    }
    local = cast("JsonObject", document["repository"])
    role = cast("JsonObject", document["system"])["role"]
    # Every client must point to a target declaration or the local target/combined ID.
    for index, client in enumerate(cast("tuple[JsonObject, ...]", document["clients"])):
        target = cast("str", client["target_repository"])
        target_record = repositories.get(target)
        is_local_target = target == local["id"] and role in (
            "modernization-target",
            "combined",
        )
        if not is_local_target and (
            target_record is None or target_record["role"] != "modernization-target"
        ):
            problem(
                f"/clients/{index}/target_repository",
                f"Unknown target repository: {target}",
            )
    # Repository links must name existing clients with matching target ownership.
    for index, repository in enumerate(
        cast("tuple[JsonObject, ...]", document["repositories"])
    ):
        # Each backlink must agree with that client's declared target ownership.
        for client_id in cast("tuple[str, ...]", repository["clients"]):
            client = clients.get(client_id)
            if (
                repository["role"] != "modernization-target"
                or client is None
                or client["target_repository"] != repository["id"]
            ):
                problem(
                    f"/repositories/{index}/clients",
                    f"Invalid target client link: {client_id}",
                )
    declarations = cast("JsonObject", document.get("extension_schemas", JsonObject(())))
    # Configured extensions must bind exactly the bytes supplied by the trusted caller.
    supplied = {item.namespace: item for item in catalog.extensions}
    # Match every declared extension to its already verified local bytes.
    for namespace, value in declarations.items():
        declaration = cast("JsonObject", value)
        extension = supplied.get(namespace)
        if (
            extension is None
            or extension.path != declaration["path"]
            or extension.sha256 != declaration["sha256"]
        ):
            problem(
                child_pointer("/extension_schemas", namespace),
                "Configured extension schema is absent or its path/checksum "
                "differs from the trusted catalog.",
            )
    # Undeclared catalog entries cannot silently add validation policy.
    for namespace in supplied.keys() - declarations.keys():
        problem(
            child_pointer("/extension_schemas", namespace),
            "The catalog contains an extension not declared by this profile.",
        )
    return problems.findings


@dataclass(frozen=True, init=False)
class ProfileV2:
    """Expose one deeply immutable, schema-validated profile to every operation.

    Construction validates full v2 structure and local bindings. It accepts text
    or bytes and an optional offline catalog; it performs no consumer-file I/O.
    Declared extension bytes must already be present in that catalog. Configured
    state is readiness for subsequent checks, never a discovery-completion claim.
    Filesystem containment, snapshots and protected activation remain later gates.
    """

    document: JsonObject

    def __init__(
        self,
        content: bytes | str,
        *,
        format: Literal["json", "yaml"] = "yaml",
        catalog: SchemaCatalog | None = None,
        limits: ParseLimits | None = None,
    ) -> None:
        """Reject malformed configuration before publishing any typed section."""
        catalog = catalog if catalog is not None else load_catalog()
        result = validate_document(
            content,
            expected_kind="domain-profile",
            expected_version="2.0.0",
            format=format,
            catalog=catalog,
            limits=limits,
        )
        if not result.ok or result.document is None:
            raise ProfileError(result.findings)
        findings = _binding_findings(result.document, catalog)
        if findings:
            raise ProfileError(findings)
        object.__setattr__(self, "document", result.document)

    @property
    def id(self) -> str:
        """Return the profile's stable artifact identifier."""
        return cast("str", self.document["id"])

    @property
    def schema_version(self) -> Literal["2.0.0"]:
        """Expose the exact supported schema identity."""
        return "2.0.0"

    @property
    def profile_version(self) -> Literal[2]:
        """Keep the profile-format version distinct from artifact schema identity."""
        return 2

    @property
    def profile_state(self) -> Literal["draft", "configured"]:
        """Preserve explicit draft state without inferring completion."""
        return cast('Literal["draft", "configured"]', self.document["profile_state"])

    def require_configured(self) -> None:
        """Block callers that require configured input when only a draft exists."""
        if self.profile_state != "configured":
            raise ProfileError(
                (
                    Finding(
                        code="PROFILE_DRAFT",
                        pointer="/profile_state",
                        message="Draft configuration cannot satisfy completion "
                        "or planning prerequisites.",
                        next_action="Supply roots, repository pins and clients, "
                        "then configure the profile.",
                    ),
                )
            )

    @property
    def system(self) -> SystemProfile:
        """Return the typed system ownership view."""
        return SystemProfile(self)

    @property
    def repository(self) -> RepositoryProfile:
        """Return local repository identity without inspecting the checkout."""
        return RepositoryProfile(self)

    @property
    def repositories(self) -> tuple[RelatedRepository, ...]:
        """Keep related repository declarations in authored order."""
        # Views share the validated immutable root and cannot diverge from its pins.
        return tuple(
            RelatedRepository(self, index)
            for index in range(
                len(cast("tuple[JsonObject, ...]", self.document["repositories"]))
            )
        )

    @property
    def clients(self) -> tuple[ClientProfile, ...]:
        """Return typed views for every configured target client."""
        # Retain all configured clients, including independent platform/mode sets.
        return tuple(
            ClientProfile(self, index)
            for index in range(
                len(cast("tuple[JsonObject, ...]", self.document["clients"]))
            )
        )

    @property
    def production_roots(self) -> tuple[str, ...]:
        """Return explicitly configured production inputs."""
        return cast("tuple[str, ...]", self.document["production_roots"])

    @property
    def test_roots(self) -> tuple[str, ...]:
        """Return explicit test inputs without scanning implied locations."""
        return cast("tuple[str, ...]", self.document["test_roots"])

    @property
    def project_entry_points(self) -> tuple[str, ...]:
        """Return declared solution/project entry points."""
        return cast("tuple[str, ...]", self.document["project_entry_points"])

    @property
    def documentation_roots(self) -> tuple[str, ...]:
        """Return local documentation and extension-schema input roots."""
        return cast("tuple[str, ...]", self.document["documentation_roots"])

    @property
    def evidence_roots(self) -> tuple[str, ...]:
        """Return configured evidence inputs without granting writes."""
        return cast("tuple[str, ...]", self.document["evidence_roots"])

    @property
    def required_platforms(self) -> tuple[str, ...]:
        """Return the global platform obligations."""
        return cast("tuple[str, ...]", self.document["required_platforms"])

    @property
    def required_modes(self) -> tuple[str, ...]:
        """Return explicit modes without making offline mandatory."""
        return cast("tuple[str, ...]", self.document["required_modes"])

    @property
    def required_feature_dimensions(self) -> tuple[str, ...]:
        """Return the global feature-dimension obligations."""
        return cast("tuple[str, ...]", self.document["required_feature_dimensions"])

    @property
    def runtime(self) -> RuntimeProfile:
        """Return capability and declared runtime obligations independently."""
        return RuntimeProfile(self)

    @property
    def analyzers(self) -> AnalyzerProfile:
        """Return the analyzer selection and bounded input policy."""
        return AnalyzerProfile(self)

    @property
    def artifacts(self) -> ArtifactRoots:
        """Return exact artifact locations without interpreting them as authority."""
        return ArtifactRoots(self)

    @property
    def completion_gates(self) -> GatePolicy:
        """Return immutable configured gates and non-disableable claim rules."""
        return GatePolicy(self)

    @property
    def excluded_paths(self) -> tuple[JsonObject, ...]:
        """Retain each excluded path/glob and its required rationale."""
        return cast("tuple[JsonObject, ...]", self.document["excluded_paths"])

    @property
    def decision_owners(self) -> tuple[JsonObject, ...]:
        """Retain configured approver IDs and mandatory evidence classifications."""
        return cast("tuple[JsonObject, ...]", self.document["decision_owners"])

    @property
    def extensions(self) -> JsonObject:
        """Expose deeply immutable, schema-checked domain metadata."""
        return cast("JsonObject", self.document["extensions"])

    @property
    def extension_schemas(self) -> JsonObject:
        """Expose pinned local declarations without fetching or executing anything."""
        return cast(
            "JsonObject", self.document.get("extension_schemas", JsonObject(()))
        )

    @property
    def limits(self) -> ProfileLimits:
        """Project integral numbers to ints while retaining original wire data."""
        values = cast("JsonObject", self.document.get("limits", JsonObject(())))
        # JSON Schema includes integral floats in integer; normalize only these fields.
        return ProfileLimits(
            document_bytes=int(cast("int", values.get("document_bytes", 16777216))),
            nesting_depth=int(cast("int", values.get("nesting_depth", 64))),
            artifact_records=int(cast("int", values.get("artifact_records", 100000))),
            source_files=int(cast("int", values.get("source_files", 1000000))),
        )

    def requirements(
        self,
        *,
        client_id: str | None = None,
        feature: ProfileRequirements | None = None,
    ) -> ProfileRequirements:
        """Union three requirement layers; applicability never removes an obligation."""
        client = None
        if client_id is not None:
            # Select an explicitly configured client without inferring a default.
            client = next((item for item in self.clients if item.id == client_id), None)
            if client is None:
                raise ValueError(f"Unknown configured client: {client_id}")
        feature = (
            feature
            if feature is not None
            else ProfileRequirements(platforms=(), modes=(), dimensions=())
        )
        return ProfileRequirements(
            platforms=self.required_platforms
            + (() if client is None else client.platforms)
            + feature.platforms,
            modes=self.required_modes
            + (() if client is None else client.modes)
            + feature.modes,
            dimensions=self.required_feature_dimensions
            + (() if client is None else client.required_feature_dimensions)
            + feature.dimensions,
        )


def parse_profile_v2(
    content: bytes | str,
    *,
    format: Literal["json", "yaml"] = "yaml",
    catalog: SchemaCatalog | None = None,
    limits: ParseLimits | None = None,
) -> ProfileV2:
    """Parse one profile using the injected or installed offline catalog."""
    return ProfileV2(content, format=format, catalog=catalog, limits=limits)
