from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path, PurePosixPath, PureWindowsPath
from typing import cast

Registry = dict[str, object]
MCP_TRANSPORT_ID = re.compile(r"^mcp__([a-z0-9_-]+)__([a-z0-9_]+)$")
SERVER_ALIASES = frozenset({"drm-copilot", "drm_copilot"})
SHA256 = re.compile(r"^[a-f0-9]{64}$")


class HandoffContractError(ValueError):
    def __init__(self, field: str, message: str) -> None:
        super().__init__(f"{field}: {message}")
        self.field = field


@dataclass(frozen=True, slots=True)
class SemanticMcpIdentity:
    semantic_id: str
    server: str
    operation: str
    transport_id: str


def normalize_repository_relative_path(value: str, *, field: str) -> str:
    if not value.strip():
        raise HandoffContractError(field, "must be a non-empty string")
    if "\\" in value or PurePosixPath(value).is_absolute():
        raise HandoffContractError(field, "must be repository-relative POSIX syntax")
    if PureWindowsPath(value).is_absolute():
        raise HandoffContractError(field, "must not be an absolute Windows path")
    parts = value.split("/")
    if any(part in {"", ".", ".."} for part in parts):
        raise HandoffContractError(field, "must be normalized and cannot traverse")
    normalized = PurePosixPath(*parts).as_posix()
    if normalized != value:
        raise HandoffContractError(field, "must already be normalized")
    return normalized


def resolve_pinned_plan_path(workspace_root: Path, plan_path: str) -> Path:
    normalized = normalize_repository_relative_path(plan_path, field="plan.path")
    root = workspace_root.resolve(strict=True)
    candidate = root.joinpath(*PurePosixPath(normalized).parts).resolve(strict=True)
    if not candidate.is_relative_to(root):
        raise HandoffContractError("plan.path", "resolves outside the workspace")
    if not candidate.is_file():
        raise HandoffContractError("plan.path", "must name one existing file")
    return candidate


def raw_sha256(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def raw_file_sha256(path: Path) -> str:
    return raw_sha256(path.read_bytes())


def read_legacy_v1(
    source_bytes: bytes,
    *,
    source_provider: str | None,
    plan: object | None,
    lifecycle: object | None,
    scheduler_context: object | None,
) -> bytes:
    """Accept legacy bytes only when every portable migration fact is explicit."""

    checkpoint = json.loads(source_bytes)
    if not isinstance(checkpoint, dict) or "schema_version" in checkpoint:
        raise HandoffContractError("legacy.checkpoint", "is invalid")
    if source_provider not in {"claude", "codex"}:
        raise HandoffContractError("legacy.source_provider", "must be explicit")
    facts = (("plan", plan), ("lifecycle", lifecycle), ("scheduler", scheduler_context))
    for field, fact in facts:
        if fact is None:
            raise HandoffContractError(f"legacy.{field}", "must be explicitly proven")
    return source_bytes


def validate_bounded_scheduler_return(
    result: dict[str, object],
    *,
    scheduler_kind: str,
    expected_bindings: dict[str, object],
    plan_sha256: str,
    child_checkpoint_sha256: str,
    result_sha256: str,
) -> str | None:
    """Validate an exact, evidence-bound child result without scheduler authority."""

    evidence_keys = {"plan_sha256", "child_checkpoint_sha256", "result_sha256"}
    if (
        scheduler_kind == "ordinary"
        or set(result) != set(expected_bindings).union(evidence_keys)
        or any(result.get(key) != value for key, value in expected_bindings.items())
    ):
        return "HANDOFF_SCHEDULER_BINDING_MISMATCH"
    if result.get("plan_sha256") != plan_sha256:
        return "HANDOFF_PLAN_HASH_MISMATCH"
    observed = (child_checkpoint_sha256, result_sha256)
    recorded = (
        result.get("child_checkpoint_sha256"),
        result.get("result_sha256"),
    )
    if (
        any(SHA256.fullmatch(digest) is None for digest in observed)
        or recorded != observed
    ):
        return "HANDOFF_SCHEDULER_BINDING_MISMATCH"
    return None


def parse_semantic_mcp_identity(
    transport_id: str, registry: Registry
) -> SemanticMcpIdentity | None:
    match = MCP_TRANSPORT_ID.fullmatch(transport_id)
    if match is None or match.group(1) not in SERVER_ALIASES:
        return None
    operation = match.group(2)
    semantic_tools = registry.get("semantic_tools")
    if not isinstance(semantic_tools, dict):
        return None
    typed_tools = cast("dict[str, object]", semantic_tools)
    for semantic_id, value in typed_tools.items():
        if not isinstance(value, dict):
            continue
        entry = cast("dict[str, object]", value)
        registered_operation = entry.get("operation")
        aliases_value = entry.get("transport_aliases")
        aliases = (
            cast("list[object]", aliases_value)
            if isinstance(aliases_value, list)
            else None
        )
        if (
            registered_operation == operation
            and isinstance(aliases, list)
            and transport_id in aliases
            and semantic_id == f"drm-copilot.{operation}"
        ):
            return SemanticMcpIdentity(
                semantic_id, "drm-copilot", operation, transport_id
            )
    return None
