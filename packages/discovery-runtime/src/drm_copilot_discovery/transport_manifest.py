"""Bind immutable local transport bytes without granting native write authority.

The existing parser/catalog validate the envelope. This component adds only the
transport digest, exact member set and replica provenance contract. It performs
no I/O; every physical input remains in the caller's complete snapshot.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from hashlib import sha256
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
from drm_copilot_discovery.path_models import WriteGrant, check_path_collisions
from drm_copilot_discovery.repository_reader import RepositoryIdentity, full_revision
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.snapshot import SnapshotFile

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot


def transport_digest(document: JsonObject) -> str:
    """Hash canonical UTF-8/LF content excluding only digest and importer fields.

    Export time, author, tool, source pin and all member declarations remain bound.
    The three verification fields describe a later local check, never authority.
    """
    transport = cast("JsonObject", document["transport"])
    # Import attribution is intentionally outside the immutable export identity.
    payload = JsonObject(
        tuple(
            (key, value)
            for key, value in transport.items()
            if key not in {"verification_status", "verified_at", "verified_by"}
        )
    )
    # Bind every other field while excluding the digest's own recursive value.
    value = JsonObject(
        tuple(
            (key, payload if key == "transport" else child)
            for key, child in document.items()
            if key != "manifest_sha256"
        )
    )
    return sha256(canonical_json(value)).hexdigest()


@dataclass(frozen=True, kw_only=True)
class TransportMember:
    """Bind a physical grant to original path, byte digest and finite byte count.

    Routes derive members from a validated manifest; consumers compare exact
    identity and bytes. A null origin denotes the header, published last.
    """

    grant: WriteGrant
    origin: str | None
    sha256: str
    size: int


@dataclass(frozen=True, kw_only=True)
class TransportRoute:
    """Retain a checked manifest and its complete output set, including the header.

    Construct through bind_transport. Plans and guarded writers reconstruct this
    value from its raw header before using it; caller-created values are not proof.
    """

    manifest: SnapshotFile
    document: JsonObject
    source: RepositoryIdentity
    members: tuple[TransportMember, ...]

    def allows(self, grant: WriteGrant, *, root: str) -> bool:
        """Match one exact member beneath the configured transport root, purely."""
        # The root constrains location; only exact membership grants this output.
        return (
            self.manifest.path.startswith(root + "/")
            and self.manifest.path != root + "/manifest.json"
            and any(member.grant == grant for member in self.members)
        )

    def check(self, grant: WriteGrant, content: bytes) -> None:
        """Reject a substituted member identity or byte sequence with ValueError."""
        # Identity selects the declaration before size and digest establish its bytes.
        member = next((item for item in self.members if item.grant == grant), None)
        if member is None or (
            member.size != len(content) or member.sha256 != sha256(content).hexdigest()
        ):
            raise ValueError("Transport member identity, size or checksum differs")

    def check_files(self, files: tuple[SnapshotFile, ...]) -> None:
        """Require every declared member exactly once; never accept an extra file."""
        check_path_collisions(file.path for file in files)
        by_path = {file.path: file.content for file in files}
        if set(by_path) != {member.grant.path for member in self.members}:
            raise ValueError("Transport requires its exact complete declared file set")
        # Set equality alone cannot prove the declared immutable content of a member.
        for member in self.members:
            self.check(member.grant, by_path[member.grant.path])

    def revalidate(self, *, catalog: SchemaCatalog, limits: ParseLimits) -> None:
        """Reconstruct all fields from raw bytes; reject forged or stale route data."""
        if self != bind_transport(
            self.manifest.path, self.manifest.content, catalog=catalog, limits=limits
        ):
            raise ValueError("Transport route differs from its original manifest")


def bind_transport(
    path: str, content: bytes, *, catalog: SchemaCatalog, limits: ParseLimits
) -> TransportRoute:
    """Validate one local manifest and derive its exact immutable member route.

    Raises ValueError for unsupported/malformed envelopes, mutable bytes, non-full
    pins, digest/count/identity/path conflicts, or finite-limit violations. This
    verifies declarations only; check_files and the complete loader verify bytes.
    """
    manifest = SnapshotFile(path=path, content=content, category="source-snapshot")
    if not path.endswith("/manifest.json"):
        raise ValueError("A transport requires a child manifest.json path")
    result = validate_document(
        content,
        expected_kind="source-snapshot-manifest",
        expected_version="2.0.0",
        artifact_path=path,
        catalog=catalog,
        limits=limits,
    )
    if not result.ok or result.document is None:
        raise ValueError(
            "Transport manifest is malformed or uses an unsupported schema"
        )
    document = result.document
    owner = cast("JsonObject", document["source_repository"])
    revision = owner["revision"]
    if not isinstance(revision, str):
        raise ValueError("Transport requires a full immutable source revision")
    source = RepositoryIdentity(
        id=cast("str", owner["id"]), revision=full_revision(revision)
    )
    if transport_digest(document) != document["manifest_sha256"]:
        raise ValueError("Transport manifest checksum differs")
    artifacts = cast("tuple[JsonObject, ...]", document["artifacts"])
    payloads = cast("tuple[JsonObject, ...]", document["payloads"])
    transport = cast("JsonObject", document["transport"])
    if (transport["artifact_count"], transport["payload_count"]) != (
        len(artifacts),
        len(payloads),
    ):
        raise ValueError("Transport member counts differ")
    if len(artifacts) + len(payloads) + 1 > limits.artifact_records:
        raise ValueError("Transport member count exceeds the configured limit")
    identities = [(row["artifact_kind"], row["id"]) for row in artifacts]
    if len(set(identities)) != len(identities):
        raise ValueError("Transport contains duplicate artifact identities")
    parent = path.rsplit("/", 1)[0]
    members: list[TransportMember] = []
    # Original kinds remain intact; only the physical destination gains the prefix.
    for row in artifacts + payloads:
        origin = cast("str", row["path"])
        if origin.split("/")[-1] == "manifest.json":
            raise ValueError("A transport member cannot introduce another manifest")
        size = cast("int", row["size"])
        if size > limits.document_bytes:
            raise ValueError("Transport member exceeds the configured byte limit")
        members.append(
            TransportMember(
                grant=WriteGrant(
                    artifact_kind=cast(
                        "str", row.get("artifact_kind", "evidence-payload")
                    ),
                    artifact_id=cast(
                        "str",
                        row.get("id", "payload-" + sha256(origin.encode()).hexdigest()),
                    ),
                    path=parent + "/" + origin,
                ),
                origin=origin,
                sha256=cast("str", row["sha256"]),
                size=size,
            )
        )
    # Publish the header after its members so a partial write cannot advertise success.
    members.append(
        TransportMember(
            grant=WriteGrant(
                artifact_kind="source-snapshot-manifest",
                artifact_id=cast("str", document["id"]),
                path=path,
            ),
            origin=None,
            sha256=manifest.sha256,
            size=len(content),
        )
    )
    paths = set(check_path_collisions(member.grant.path for member in members))
    # A file cannot also be a parent directory, even when every leaf is unique.
    if any(
        "/".join(path.split("/")[:length]) in paths
        for path in paths
        for length in range(1, len(path.split("/")))
    ):
        raise ValueError("Transport file and directory paths collide")
    return TransportRoute(
        manifest=manifest, document=document, source=source, members=tuple(members)
    )


def replica_aliases(snapshot: DiscoverySnapshot) -> dict[str, str]:
    """Coalesce proven replicas while retaining the sole ordinary local identity.

    Invalid or incomplete manifests grant no equivalence. Ordinary duplicates and
    unbound imported copies remain visible to the existing duplicate validator.
    All physical files, manifests and loader findings remain untouched.
    """
    bound: set[str] = set()
    artifacts = {item.path: item for item in snapshot.artifacts}
    root = snapshot.profile.artifacts["source_snapshots"]
    # Only actual complete local manifests establish eligible replica provenance.
    for header in snapshot.artifacts:
        if (
            header.expected_kind != "source-snapshot-manifest"
            or not header.path.startswith(root + "/")
        ):
            continue
        try:
            route = bind_transport(
                header.path,
                snapshot.file(header.path).content,
                catalog=snapshot.catalog,
                limits=snapshot.profile.limits.parse_limits(),
            )
            # Presence alone is insufficient: every declared physical byte is checked.
            route.check_files(
                tuple(snapshot.file(item.grant.path) for item in route.members)
            )
        except (KeyError, ValueError):
            # Failure preserves ordinary duplicate rejection; it grants no exemption.
            continue
        # Match loader ownership, origin and kind against the exact physical member.
        for member in route.members:
            artifact = artifacts.get(member.grant.path)
            if (
                artifact is not None
                and member.origin is not None
                and artifact.origin_path == member.origin
                and artifact.repository == route.source
                and artifact.expected_kind == member.grant.artifact_kind
                and artifact.document is not None
                and artifact.document.get("id") == member.grant.artifact_id
            ):
                bound.add(artifact.path)
    groups: dict[
        tuple[RepositoryIdentity, str, str, str, bytes], list[ArtifactSnapshot]
    ] = defaultdict(list)
    # Full pin, origin, kind, ID and raw bytes must all agree before coalescing.
    for artifact in snapshot.artifacts:
        if artifact.document is None or artifact.repository.revision is None:
            continue
        if artifact.origin_path is not None and artifact.path not in bound:
            continue
        key = (
            artifact.repository,
            artifact.origin_path or artifact.path,
            artifact.expected_kind,
            str(artifact.document.get("id")),
            snapshot.file(artifact.path).content,
        )
        groups[key].append(artifact)
    aliases: dict[str, str] = {}
    # Preserve ordinary local mutation identity and never exempt ordinary duplicates.
    for copies in groups.values():
        # Stable imported order supplies a canonical identity when no local file exists.
        imported = sorted(item.path for item in copies if item.path in bound)
        local = [item.path for item in copies if item.origin_path is None]
        if imported and len(local) <= 1:
            representative = local[0] if local else imported[0]
            # Only noncanonical proven physical copies receive aliases.
            aliases.update(
                (item.path, representative)
                for item in copies
                if item.path != representative
            )
    return aliases
