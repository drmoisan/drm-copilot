"""Select exact local inventory pins without expanding configured input discovery."""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Iterable, Mapping, Set

    from drm_copilot_discovery.models import JsonObject
    from drm_copilot_discovery.repository_reader import RepositoryIdentity
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, InputCategory


def local_inventory_requests(
    artifacts: Iterable[ArtifactSnapshot],
    *,
    valid_paths: Set[str],
    captured_paths: Iterable[str],
    categories: Mapping[str, InputCategory],
    local: RepositoryIdentity,
) -> set[tuple[str, str]]:
    """Return deduplicated (revision, path) requests from validated local claims.

    Args:
        artifacts (Iterable[ArtifactSnapshot]): Captured records with schema status.
        valid_paths (Set[str]): Paths that passed this load's trusted schema check.
        captured_paths (Iterable[str]): Read paths selected by root enumeration.
        categories (Mapping[str, InputCategory]): Authoritative captured path roles.
        local (RepositoryIdentity): Configured identity; foreign rows cannot read.

    Returns:
        Exact full-pin requests for inspected files and nested source claims.
        Imported, malformed and uncaptured claims add no requests. Performs no I/O
        or mutation; semantic mismatches remain the revision validator's concern.

    Raises:
        No contract exceptions for records with valid trusted schema status.
    """
    # Only captured inspection inputs can be authorized by an inventory claim.
    allowed = {
        path
        for path in captured_paths
        if categories.get(path) in {"source", "test", "documentation"}
    }
    requests: set[tuple[str, str]] = set()
    # Schema validation precedes access to every closed core inventory row shape.
    for artifact in artifacts:
        if (
            artifact.expected_kind != "inventory-snapshot"
            or artifact.path not in valid_paths
            or artifact.origin_path is not None
            or artifact.repository.id != local.id
        ):
            continue
        document = cast("JsonObject", artifact.document)
        if document["repository"] != local.id:
            continue
        # Match the revision rule's explicit groups without walking extension data.
        for group in ("files", "components", "findings", "relationships"):
            # Uninspected file rows describe omissions and cannot request Git bytes.
            for row in cast("tuple[JsonObject, ...]", document[group]):
                if group == "files" and row["status"] != "inspected":
                    continue
                source = row if group == "files" else cast("JsonObject", row["source"])
                owner = source.get("repository", document["repository"])
                revision = source.get("revision", document["revision"])
                path = cast("str", source["path"])
                if owner == local.id and isinstance(revision, str) and path in allowed:
                    requests.add((revision, path))
    return requests
