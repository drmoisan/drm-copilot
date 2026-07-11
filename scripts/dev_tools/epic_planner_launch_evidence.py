"""Verify completed epic-planner child launch evidence against its source spec."""

from __future__ import annotations

import hashlib
import json
import re
from datetime import datetime
from pathlib import Path, PurePosixPath
from typing import TYPE_CHECKING, TypeGuard, cast

if TYPE_CHECKING:
    from scripts.dev_tools.epic_planner_readiness import EpicReadinessContext

LAUNCH_ROOT = "artifacts/orchestration/epic-child-launches"
SHA256_RE = re.compile(r"[0-9a-f]{64}")


def _is_record(value: object) -> TypeGuard[dict[str, object]]:
    """Return whether a decoded JSON value is an object."""

    return isinstance(value, dict)


def _is_non_empty(value: object) -> TypeGuard[str]:
    """Return whether a value is a trimmed non-empty string."""

    return isinstance(value, str) and bool(value.strip()) and value == value.strip()


def _binding_equal(actual: object, expected: object) -> bool:
    """Compare JSON scalar bindings without Python bool/integer coercion."""

    return type(actual) is type(expected) and actual == expected


def _launch_path(
    value: object, context: EpicReadinessContext, *, field: str
) -> tuple[str | None, list[str]]:
    """Resolve a launch artifact path and reject paths outside this repository."""

    if not _is_non_empty(value) or "\x00" in value:
        return None, [f"{field} must identify a launch artifact in this repository."]
    normalized = value.replace("\\", "/")
    root = context.workspace_root.as_posix().rstrip("/")
    root_prefix = f"{root}/"
    if normalized.lower().startswith(root_prefix.lower()):
        normalized = normalized[len(root_prefix) :]
    path = PurePosixPath(normalized)
    if path.is_absolute() or ".." in path.parts or "." in path.parts:
        return None, [f"{field} must identify a launch artifact in this repository."]
    relative = path.as_posix()
    if not relative.startswith(f"{LAUNCH_ROOT}/"):
        return None, [f"{field} must identify a launch artifact in this repository."]
    return relative, []


def _read_json(
    relative: str, context: EpicReadinessContext, *, label: str
) -> tuple[dict[str, object] | None, bytes | None, list[str]]:
    """Read a required UTF-8 JSON object through the readiness filesystem seam."""

    path = context.workspace_root / Path(relative)
    if not context.file_system.is_file(path):
        return None, None, [f"Execution readiness requires {label}: {relative}"]
    try:
        raw = context.file_system.read_bytes(path)
        text = raw.decode("utf-8-sig")
    except (OSError, UnicodeError) as exc:
        return (
            None,
            None,
            [f"Execution readiness could not read {label} {relative}: {exc}"],
        )
    try:
        value: object = json.loads(text)
    except json.JSONDecodeError as exc:
        return None, raw, [f"Execution readiness {label} is not valid JSON: {exc}"]
    if not _is_record(value):
        return None, raw, [f"Execution readiness {label} must be a JSON object."]
    return value, raw, []


def _expected_feature_bindings(feature: dict[str, object]) -> dict[str, object]:
    """Collect launch bindings already validated by the structural gate."""

    delegation = feature.get("delegation_receipt")
    model = feature.get("model_routing_receipt")
    delegation_record = delegation if _is_record(delegation) else {}
    model_record = model if _is_record(model) else {}
    return {
        "issue_num": feature.get("issue_num"),
        "feature_folder": feature.get("feature_folder"),
        "delegation_id": delegation_record.get("delegation_id"),
        "deployment_agent": model_record.get("deployment_agent"),
        "model": model_record.get("model"),
        "model_reasoning_effort": model_record.get("model_reasoning_effort"),
        "execution_context": "epic_preparation_child",
        "branch_name": feature.get("branch_name"),
        "worktree_path": feature.get("worktree_path"),
    }


def _validate_completed_receipt(
    receipt: dict[str, object], *, prefix: str
) -> list[str]:
    """Require a successful terminal receipt with durable session binding."""

    errors: list[str] = []
    if receipt.get("schema_version") != 2 or receipt.get("state") != "completed":
        errors.append(f"{prefix} must be a schema 2 completed launch receipt.")
    exit_code = receipt.get("exit_code")
    if not isinstance(exit_code, int) or isinstance(exit_code, bool) or exit_code != 0:
        errors.append(f"{prefix}.exit_code must be 0.")
    if not _is_non_empty(receipt.get("codex_session_id")):
        errors.append(f"{prefix}.codex_session_id must be a non-empty string.")
    timestamps: dict[str, datetime] = {}
    for key in ("session_bound_at", "completed_at"):
        value = receipt.get(key)
        if not isinstance(value, str):
            errors.append(f"{prefix}.{key} must be an ISO-8601 timestamp with offset.")
            continue
        try:
            parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
            if parsed.tzinfo is None:
                raise ValueError
            timestamps[key] = parsed
        except (AttributeError, ValueError):
            errors.append(f"{prefix}.{key} must be an ISO-8601 timestamp with offset.")
    bound = timestamps.get("session_bound_at")
    completed = timestamps.get("completed_at")
    if bound is not None and completed is not None and completed < bound:
        errors.append(f"{prefix}.completed_at must not precede session_bound_at.")
    return errors


def _validate_spec(
    receipt: dict[str, object],
    expected: dict[str, object],
    context: EpicReadinessContext,
    *,
    prefix: str,
) -> tuple[dict[str, object] | None, list[str]]:
    """Verify the receipt's immutable launch specification path and hash."""

    spec_path, errors = _launch_path(
        receipt.get("spec_path"), context, field=f"{prefix}.spec_path"
    )
    if spec_path is None:
        return None, errors
    receipt_path, _ = _launch_path(
        receipt.get("receipt_path"), context, field=f"{prefix}.receipt_path"
    )
    if (
        receipt_path is not None
        and PurePosixPath(spec_path).parent != PurePosixPath(receipt_path).parent
    ):
        errors.append(f"{prefix}.spec_path must share the receipt wave directory.")
    spec, raw, read_errors = _read_json(
        spec_path, context, label=f"{prefix} launch specification"
    )
    errors.extend(read_errors)
    digest = receipt.get("spec_sha256")
    if not _is_non_empty(digest) or SHA256_RE.fullmatch(digest) is None:
        errors.append(f"{prefix}.spec_sha256 must be a lowercase SHA-256 hash.")
    elif raw is not None and hashlib.sha256(raw).hexdigest() != digest:
        errors.append(f"{prefix}.spec_sha256 does not match spec_path bytes.")
    if spec is None:
        return None, errors
    if spec.get("wave_id") != receipt.get("wave_id"):
        errors.append(f"{prefix}.wave_id must match its launch specification.")
    launches = spec.get("launches")
    matching = (
        [
            item
            for item in cast("list[object]", launches)
            if _is_record(item) and item.get("launch_id") == receipt.get("launch_id")
        ]
        if isinstance(launches, list)
        else []
    )
    if len(matching) != 1:
        errors.append(
            f"{prefix}.launch_id must identify exactly one specification launch."
        )
    else:
        for key, value in expected.items():
            if not _binding_equal(matching[0].get(key), value):
                errors.append(
                    f"{prefix} specification launch.{key} must match the feature."
                )
    return spec, errors


def _validate_receipt(
    feature: dict[str, object],
    index: int,
    context: EpicReadinessContext,
) -> tuple[dict[str, object] | None, str | None, list[str]]:
    """Read and cross-bind one sealed preparation-child launch receipt."""

    prefix = f"Epic planner checkpoint features[{index}] launch receipt"
    relative, errors = _launch_path(
        feature.get("launch_receipt_path"), context, field=f"{prefix} path"
    )
    if relative is None:
        return None, None, errors
    receipt, _, read_errors = _read_json(relative, context, label=prefix)
    errors.extend(read_errors)
    if receipt is None:
        return None, relative, errors
    expected = _expected_feature_bindings(feature)
    for key, value in expected.items():
        if not _binding_equal(receipt.get(key), value):
            errors.append(f"{prefix}.{key} must match the feature.")
    receipt_path, receipt_path_errors = _launch_path(
        receipt.get("receipt_path"), context, field=f"{prefix}.receipt_path"
    )
    errors.extend(receipt_path_errors)
    if receipt_path is not None and receipt_path != relative:
        errors.append(f"{prefix}.receipt_path must identify the receipt file.")
    launch_id = receipt.get("launch_id")
    expected_name = f"{launch_id}.receipt.json" if _is_non_empty(launch_id) else None
    if expected_name is None or PurePosixPath(relative).name != expected_name:
        errors.append(f"{prefix}.launch_id must match the receipt filename.")
    status_path, status_path_errors = _launch_path(
        receipt.get("status_path"), context, field=f"{prefix}.status_path"
    )
    errors.extend(status_path_errors)
    feature_status, _ = _launch_path(
        feature.get("launch_status_path"), context, field=f"{prefix}.status_path"
    )
    if status_path is not None and status_path != feature_status:
        errors.append(f"{prefix}.status_path must match the feature status file.")
    errors.extend(_validate_completed_receipt(receipt, prefix=prefix))
    _, spec_errors = _validate_spec(receipt, expected, context, prefix=prefix)
    errors.extend(spec_errors)
    return receipt, relative, errors


def _validate_status(
    feature: dict[str, object],
    index: int,
    receipt: dict[str, object],
    receipt_path: str,
    status: dict[str, object],
    status_path: str,
    context: EpicReadinessContext,
) -> list[str]:
    """Require a terminal successful status for the receipt-bound session."""

    prefix = f"Epic planner checkpoint features[{index}] launch status"
    errors: list[str] = []
    if status.get("schema_version") != 2 or status.get("state") != "completed":
        errors.append(f"{prefix} shared wave must be a schema 2 completed status.")
    failure = status.get("failure")
    if failure not in (None, ""):
        errors.append(f"{prefix} shared wave must not contain a failure.")
    if status.get("wave_id") != receipt.get("wave_id"):
        errors.append(f"{prefix}.wave_id must match the launch receipt.")
    launches = status.get("launches")
    launch_id = receipt.get("launch_id")
    entry = (
        launches.get(launch_id)
        if _is_record(launches) and isinstance(launch_id, str)
        else None
    )
    if not _is_record(entry):
        launch_label = repr(launch_id) if isinstance(launch_id, str) else "<invalid>"
        return [*errors, f"{prefix} must contain launch_id {launch_label}."]
    exit_code = entry.get("exit_code")
    if (
        entry.get("state") != "completed"
        or not isinstance(exit_code, int)
        or isinstance(exit_code, bool)
        or exit_code != 0
    ):
        errors.append(f"{prefix} launch must be completed with exit_code 0.")
    entry_receipt, path_errors = _launch_path(
        entry.get("receipt_path"), context, field=f"{prefix} launch.receipt_path"
    )
    errors.extend(path_errors)
    if entry_receipt is not None and entry_receipt != receipt_path:
        errors.append(f"{prefix} launch.receipt_path must match the feature receipt.")
    if entry.get("codex_session_id") != receipt.get("codex_session_id"):
        errors.append(f"{prefix} launch.codex_session_id must match the receipt.")
    if entry.get("completed_at") != receipt.get("completed_at"):
        errors.append(f"{prefix} launch.completed_at must match the receipt.")
    if PurePosixPath(status_path).parent != PurePosixPath(receipt_path).parent:
        errors.append(f"{prefix} path must share the receipt wave directory.")
    status_receipt = feature.get("launch_status_path")
    resolved_status, _ = _launch_path(status_receipt, context, field="status")
    if resolved_status != status_path:
        errors.append(f"{prefix} path must match the shared status file.")
    return errors


def validate_epic_planner_launch_evidence(
    state: dict[str, object], context: EpicReadinessContext
) -> list[str]:
    """Verify every prepared feature's receipt, specification, and final status."""

    features = state.get("features")
    if not isinstance(features, list):
        return []
    errors: list[str] = []
    status_path: str | None = None
    status: dict[str, object] | None = None
    for index, item in enumerate(cast("list[object]", features)):
        if not _is_record(item):
            continue
        receipt, receipt_path, receipt_errors = _validate_receipt(item, index, context)
        errors.extend(receipt_errors)
        feature_status, path_errors = _launch_path(
            item.get("launch_status_path"),
            context,
            field=f"Epic planner checkpoint features[{index}] launch status path",
        )
        errors.extend(path_errors)
        if (
            feature_status is not None
            and status_path is not None
            and feature_status != status_path
        ):
            errors.append(
                "Epic planner preparation features must share one launch_status_path."
            )
        if feature_status is not None and status_path is None:
            status_path = feature_status
            status, _, status_errors = _read_json(
                feature_status, context, label="the shared preparation launch status"
            )
            errors.extend(status_errors)
        if (
            receipt is not None
            and receipt_path is not None
            and status is not None
            and status_path is not None
        ):
            errors.extend(
                _validate_status(
                    item, index, receipt, receipt_path, status, status_path, context
                )
            )
    return errors
