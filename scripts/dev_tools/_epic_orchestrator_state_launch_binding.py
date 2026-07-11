"""Validate durable launch binding evidence for epic execution children."""

from __future__ import annotations

import ntpath
import posixpath
import re
from typing import Any, TypeGuard, cast

_LAUNCH_ARTIFACT_PARTS = (
    "artifacts",
    "orchestration",
    "epic-child-launches",
)
_GENERATED_ORCHESTRATOR_AGENTS = frozenset(
    {
        "orchestrator-c1",
        "orchestrator-c2",
        "orchestrator-c3",
        "orchestrator-c3-elevated",
        "orchestrator-c4",
    }
)


def _is_non_empty_string(value: object) -> TypeGuard[str]:
    """Return whether value is a non-empty string without outer whitespace."""

    return isinstance(value, str) and bool(value.strip()) and value == value.strip()


def _is_canonical_worktree_path(value: object) -> bool:
    """Accept normalized absolute POSIX, drive-qualified, or UNC paths."""

    if not _is_non_empty_string(value) or "\x00" in value:
        return False
    path = value
    if path.startswith("/"):
        return "\\" not in path and posixpath.normpath(path) == path
    drive, tail = ntpath.splitdrive(path)
    fully_qualified = drive.startswith("\\\\") or (
        len(drive) == 2 and drive[1] == ":" and tail.startswith("\\")
    )
    if not fully_qualified or not ntpath.isabs(path) or "/" in path:
        return False
    return ntpath.normpath(path) == path


def _is_launch_artifact_path(value: object) -> bool:
    """Return whether value is below the canonical launch-artifact directory."""

    if not _is_non_empty_string(value) or "\x00" in value:
        return False
    normalized = value.replace("\\", "/")
    raw_parts = normalized.split("/")
    if any(part in {".", ".."} for part in raw_parts):
        return False
    parts = [part for part in raw_parts if part]
    marker_length = len(_LAUNCH_ARTIFACT_PARTS)
    marker_index = next(
        (
            index
            for index in range(len(parts) - marker_length + 1)
            if tuple(parts[index : index + marker_length]) == _LAUNCH_ARTIFACT_PARTS
        ),
        -1,
    )
    if marker_index < 0 or marker_index + marker_length >= len(parts):
        return False
    absolute = normalized.startswith("/") or bool(re.match(r"^[A-Za-z]:/", normalized))
    return marker_index == 0 or absolute


def _feature_prefix(feature: dict[str, Any]) -> str:
    """Return the stable error prefix for one feature launch binding."""

    folder = feature.get("feature_folder")
    label = folder if isinstance(folder, str) and folder else "<unknown>"
    return f"Epic checkpoint feature '{label}' launch binding"


def _validate_branch_and_paths(
    feature: dict[str, Any],
    *,
    prefix: str,
    seen_branches: set[str],
) -> list[str]:
    """Validate the feature branch, worktree, and durable artifact paths."""

    errors: list[str] = []
    branch = feature.get("branch_name")
    if not _is_non_empty_string(branch):
        errors.append(f"{prefix}.branch_name must be a non-empty unique string.")
    elif branch in seen_branches:
        errors.append(f"{prefix}.branch_name must be a non-empty unique string.")
    else:
        seen_branches.add(branch)

    if not _is_canonical_worktree_path(feature.get("worktree_path")):
        errors.append(
            f"{prefix}.worktree_path must be a non-empty canonical absolute path."
        )
    for key in ("launch_receipt_path", "launch_status_path"):
        if not _is_launch_artifact_path(feature.get(key)):
            errors.append(
                f"{prefix}.{key} must be under "
                "artifacts/orchestration/epic-child-launches/."
            )
    return errors


def _validate_delegation_receipt(
    feature: dict[str, Any],
    *,
    prefix: str,
    seen_delegation_ids: set[str],
    require_generated_orchestrator: bool = False,
) -> tuple[list[str], str | None, str | None]:
    """Validate exact feature, issue, agent, and delegation-id binding."""

    value = feature.get("delegation_receipt")
    if not isinstance(value, dict):
        return [f"{prefix}.delegation_receipt must be an object."], None, None
    receipt = cast("dict[str, Any]", value)
    errors: list[str] = []
    delegation_id = receipt.get("delegation_id")
    valid_id = delegation_id if _is_non_empty_string(delegation_id) else None
    if valid_id is None or valid_id in seen_delegation_ids:
        errors.append(
            f"{prefix}.delegation_receipt.delegation_id must be a non-empty "
            "unique string."
        )
    else:
        seen_delegation_ids.add(valid_id)

    if receipt.get("feature_folder") != feature.get("feature_folder"):
        errors.append(
            f"{prefix}.delegation_receipt.feature_folder must match the feature."
        )
    if (
        "issue_num" not in feature
        or "issue_num" not in receipt
        or receipt.get("issue_num") != feature.get("issue_num")
    ):
        errors.append(f"{prefix}.delegation_receipt.issue_num must match the feature.")
    agent_name = receipt.get("agent_name")
    valid_agent = agent_name if _is_non_empty_string(agent_name) else None
    if valid_agent is None:
        errors.append(
            f"{prefix}.delegation_receipt.agent_name must be a non-empty string."
        )
    elif (
        require_generated_orchestrator
        and valid_agent not in _GENERATED_ORCHESTRATOR_AGENTS
    ):
        errors.append(
            f"{prefix}.delegation_receipt.agent_name must name a generated "
            "orchestrator agent."
        )
    return errors, valid_id, valid_agent


def _validate_model_receipt(
    feature: dict[str, Any],
    *,
    prefix: str,
    delegation_id: str | None,
    deployment_agent: str | None,
    expected_execution_context: str = "epic_execution_child",
) -> list[str]:
    """Validate the singular deployment receipt against its delegation."""

    value = feature.get("model_routing_receipt")
    if not isinstance(value, dict):
        return [f"{prefix}.model_routing_receipt must be an object."]
    receipt = cast("dict[str, Any]", value)
    errors: list[str] = []
    if delegation_id is not None and receipt.get("delegation_id") != delegation_id:
        errors.append(
            f"{prefix}.model_routing_receipt.delegation_id must match "
            "delegation_receipt.delegation_id."
        )
    model_agent = receipt.get("deployment_agent")
    if not _is_non_empty_string(model_agent):
        errors.append(
            f"{prefix}.model_routing_receipt.deployment_agent must be a "
            "non-empty string."
        )
    elif deployment_agent is not None and model_agent != deployment_agent:
        errors.append(
            f"{prefix}.model_routing_receipt.deployment_agent must match "
            "delegation_receipt.agent_name."
        )
    if receipt.get("execution_context") != expected_execution_context:
        errors.append(
            f"{prefix}.model_routing_receipt.execution_context must be "
            f"{expected_execution_context!r}."
        )
    return errors


def _validate_launch_bindings(
    features: list[object],
    *,
    planner: bool,
    expected_execution_context: str,
    require_generated_orchestrator: bool,
    skip_not_started: bool,
) -> list[str]:
    """Validate launch evidence using persona-specific context and prefixes."""

    errors: list[str] = []
    seen_branches: set[str] = set()
    seen_delegation_ids: set[str] = set()
    for index, item in enumerate(features):
        if not isinstance(item, dict):
            continue
        feature = cast("dict[str, Any]", item)
        if skip_not_started and feature.get("merge_status") == "not_started":
            continue
        prefix = (
            f"Epic planner checkpoint features[{index}] launch binding"
            if planner
            else _feature_prefix(feature)
        )
        errors.extend(
            _validate_branch_and_paths(
                feature, prefix=prefix, seen_branches=seen_branches
            )
        )
        receipt_errors, delegation_id, deployment_agent = _validate_delegation_receipt(
            feature,
            prefix=prefix,
            seen_delegation_ids=seen_delegation_ids,
            require_generated_orchestrator=require_generated_orchestrator,
        )
        errors.extend(receipt_errors)
        errors.extend(
            _validate_model_receipt(
                feature,
                prefix=prefix,
                delegation_id=delegation_id,
                deployment_agent=deployment_agent,
                expected_execution_context=expected_execution_context,
            )
        )
    return errors


def validate_epic_planner_child_launch_bindings(
    features: list[dict[str, Any]],
) -> list[str]:
    """Require durable preparation-child launch evidence for every feature."""

    return _validate_launch_bindings(
        cast("list[object]", features),
        planner=True,
        expected_execution_context="epic_preparation_child",
        require_generated_orchestrator=True,
        skip_not_started=False,
    )


def validate_epic_child_launch_bindings(
    state: dict[str, Any],
    *,
    require_codex_model_routing: bool = False,
    require_codex_topology: bool = False,
    require_complete: bool = False,
) -> list[str]:
    """Validate launched features when routing gates or completion are required."""

    if not (require_codex_model_routing or require_codex_topology or require_complete):
        return []
    value = state.get("features")
    if not isinstance(value, list):
        return []

    return _validate_launch_bindings(
        cast("list[object]", value),
        planner=False,
        expected_execution_context="epic_execution_child",
        require_generated_orchestrator=False,
        skip_not_started=not require_complete,
    )
