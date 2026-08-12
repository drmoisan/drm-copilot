"""Pure Codex provenance and readiness checks for standalone parallel state.

The shared parallel checkpoints remain runtime-neutral. Codex launch provenance
is an external, versioned record supplied by the guarded launch/status path
loader; this module validates that record without reading the filesystem. The
planner and orchestrator validators compose these checks and retain ownership
of their existing backward-compatible state schemas.
"""

from __future__ import annotations

import re
from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from pathlib import PurePosixPath
from typing import cast

from scripts.dev_tools._orchestrator_state_codex_model_routing import (
    validate_codex_model_routing_receipts,
)
from scripts.dev_tools._orchestrator_state_codex_topology import (
    validate_codex_topology_receipts,
)

PARALLEL_LAUNCH_SCHEMA_VERSION = 2
PARALLEL_SURFACE = "parallel"
VALID_LEDGER_STATUSES = ("PRESERVED", "DEGRADED", "LOST")

_SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
_COMMIT_RE = re.compile(r"^[0-9a-f]{40,64}$")
_MIXED_STATE_KEYS = frozenset(
    {
        "epic_slug",
        "epic_manifest_path",
        "epic_status_doc_path",
        "integration_branch",
        "integration_branch_head",
        "integration_pr",
        "fan_in",
        "fan_in_pr",
        "final_integration_pr",
        "waves",
    }
)
_LAUNCH_RECORD_KEYS = (
    "schema_version",
    "surface",
    "parallel_slug",
    "item_key",
    "cohort",
    "batch",
    "base_branch",
    "pr_target",
    "head_branch",
    "worktree_path",
    "deployment_agent",
    "model",
    "model_reasoning_effort",
    "permissions",
    "authority_receipt_path",
    "delegation_receipt_path",
    "topology_receipt_path",
    "model_routing_receipt_path",
    "launch_status_path",
    "launch_spec_sha256",
)


@dataclass(frozen=True)
class ParallelCodexReadinessEvidence:
    """External evidence loaded by the guarded repository service boundary."""

    launch_records: Mapping[str, object]
    status_records: Mapping[str, object]
    receipt_records: Mapping[str, object]
    enforceability_ledger: object
    kickoff_identity: Mapping[str, object] | None = None


def _is_non_empty_string(value: object) -> bool:
    """Return whether ``value`` is a non-blank string."""

    return isinstance(value, str) and bool(value.strip())


def _mixed_state_paths(value: object, path: str = "") -> list[str]:
    """Return deterministic paths to epic or fan-in keys in parallel data."""

    paths: list[str] = []
    if isinstance(value, Mapping):
        for key, child in cast("Mapping[object, object]", value).items():
            key_text = str(key)
            child_path = f"{path}.{key_text}" if path else key_text
            if key_text in _MIXED_STATE_KEYS:
                paths.append(child_path)
            paths.extend(_mixed_state_paths(child, child_path))
    elif isinstance(value, Sequence) and not isinstance(value, (str, bytes)):
        for index, child in enumerate(cast("Sequence[object]", value)):
            paths.extend(_mixed_state_paths(child, f"{path}[{index}]"))
    return paths


def validate_parallel_state_is_standalone(
    state: Mapping[str, object], *, context: str
) -> list[str]:
    """Reject epic or fan-in keys without changing the shared state schema."""

    return [
        (f"{context} contains prohibited epic or fan-in key at {path}.")
        for path in _mixed_state_paths(state)
    ]


def validate_parallel_launch_provenance(
    value: object,
    *,
    context: str,
    parallel_slug: object,
    item_key: object,
    cohort: object,
    batch: object,
    head_branch: object,
    worktree_path: object,
    launch_receipt_path: str,
    launch_status_path: str,
) -> list[str]:
    """Validate one external Codex item-launch record against guarded paths."""

    prefix = f"{context} Codex launch provenance"
    if not isinstance(value, Mapping):
        return [f"{prefix} must be an object loaded from the guarded launch path."]
    record = cast("Mapping[str, object]", value)
    missing = [key for key in _LAUNCH_RECORD_KEYS if key not in record]
    if missing:
        return [f"{prefix} missing required keys: {', '.join(missing)}."]

    expected: tuple[tuple[str, object], ...] = (
        ("schema_version", PARALLEL_LAUNCH_SCHEMA_VERSION),
        ("surface", PARALLEL_SURFACE),
        ("parallel_slug", parallel_slug),
        ("item_key", item_key),
        ("cohort", cohort),
        ("batch", batch),
        ("base_branch", "main"),
        ("pr_target", "main"),
        ("head_branch", head_branch),
        ("worktree_path", worktree_path),
        ("launch_status_path", launch_status_path),
    )
    errors = [
        f"{prefix}.{key} must be {expected_value!r}; found: {record.get(key)!r}."
        for key, expected_value in expected
        if record.get(key) != expected_value
    ]
    if record.get("launch_receipt_path") not in (None, launch_receipt_path):
        errors.append(
            f"{prefix}.launch_receipt_path must match the guarded path "
            f"{launch_receipt_path!r}; found: {record.get('launch_receipt_path')!r}."
        )
    for key in (
        "deployment_agent",
        "model",
        "model_reasoning_effort",
        "permissions",
        "authority_receipt_path",
        "delegation_receipt_path",
        "topology_receipt_path",
        "model_routing_receipt_path",
    ):
        if not _is_non_empty_string(record.get(key)):
            errors.append(f"{prefix}.{key} must be a non-empty string.")
    digest = record.get("launch_spec_sha256")
    if not isinstance(digest, str) or _SHA256_RE.fullmatch(digest) is None:
        errors.append(
            f"{prefix}.launch_spec_sha256 must be 64 lowercase hex characters."
        )
    return errors


def validate_zero_lost_ledger(value: object, *, context: str) -> list[str]:
    """Require a complete-shaped enforceability ledger with no LOST row."""

    prefix = f"{context} enforceability_ledger"
    if not isinstance(value, list) or not value:
        return [f"{prefix} must be a non-empty list for execution readiness."]

    errors: list[str] = []
    seen_gate_ids: set[str] = set()
    for index, item in enumerate(cast("list[object]", value)):
        item_prefix = f"{prefix}[{index}]"
        if not isinstance(item, Mapping):
            errors.append(f"{item_prefix} must be an object.")
            continue
        entry = cast("Mapping[str, object]", item)
        gate_id = entry.get("gate_id")
        status = entry.get("status")
        if not _is_non_empty_string(gate_id):
            errors.append(f"{item_prefix}.gate_id must be a non-empty string.")
        elif cast("str", gate_id) in seen_gate_ids:
            errors.append(f"{item_prefix}.gate_id must be unique; found: {gate_id!r}.")
        else:
            seen_gate_ids.add(cast("str", gate_id))
        if status not in VALID_LEDGER_STATUSES:
            errors.append(
                f"{item_prefix}.status must be one of "
                f"{', '.join(VALID_LEDGER_STATUSES)}; found: {status!r}."
            )
        elif status == "LOST":
            errors.append(f"{item_prefix}.status LOST blocks parallel readiness.")
    return errors


def _guarded_path(value: object, *, field: str) -> tuple[str | None, list[str]]:
    """Return a safe repository-relative evidence path or one error."""

    if not _is_non_empty_string(value) or cast("str", value).find("\\") >= 0:
        return None, [f"{field} must be a repository-relative POSIX path."]
    path = PurePosixPath(cast("str", value))
    if path.is_absolute() or any(part in (".", "..") for part in path.parts):
        return None, [f"{field} must stay within the workspace root."]
    return path.as_posix(), []


def _validate_kickoff_identity(
    state: Mapping[str, object],
    evidence: ParallelCodexReadinessEvidence,
    *,
    context: str,
) -> list[str]:
    """Validate the service-verified committed kickoff identity."""

    if "kickoff_prompt_path" not in state:
        return []
    prefix = f"{context} committed kickoff identity"
    identity = evidence.kickoff_identity
    if not isinstance(identity, Mapping):
        return [f"{prefix} is required for execution readiness."]
    slug = state.get("parallel_slug")
    expected_path = f"docs/features/parallel/{slug}/parallel-kickoff.md"
    expected: tuple[tuple[str, object], ...] = (
        ("schema_version", 1),
        ("path", expected_path),
        ("plan_home_ref", f"origin/parallel/{slug}-plan"),
    )
    errors = [
        f"{prefix}.{key} must be {wanted!r}; found: {identity.get(key)!r}."
        for key, wanted in expected
        if identity.get(key) != wanted
    ]
    if state.get("kickoff_prompt_path") != expected_path:
        errors.append(
            f"{prefix}.path must match checkpoint kickoff_prompt_path "
            f"{expected_path!r}; found: {state.get('kickoff_prompt_path')!r}."
        )
    commit = identity.get("planning_commit")
    if not isinstance(commit, str) or _COMMIT_RE.fullmatch(commit) is None:
        errors.append(
            f"{prefix}.planning_commit must be 40-64 lowercase hex characters."
        )
    blob = identity.get("blob_sha256")
    worktree = identity.get("worktree_sha256")
    if not isinstance(blob, str) or _SHA256_RE.fullmatch(blob) is None:
        errors.append(f"{prefix}.blob_sha256 must be 64 lowercase hex characters.")
    if worktree != blob:
        errors.append(f"{prefix}.worktree_sha256 must match blob_sha256.")
    return errors


def _validate_status(
    value: object,
    *,
    context: str,
    launch_receipt_path: str,
) -> list[str]:
    """Validate one terminal status record and its receipt binding."""

    prefix = f"{context} external launch status"
    if not isinstance(value, Mapping):
        return [f"{prefix} must be an object loaded from the guarded status path."]
    record = cast("Mapping[str, object]", value)
    errors: list[str] = []
    if record.get("schema_version") != PARALLEL_LAUNCH_SCHEMA_VERSION:
        errors.append(
            f"{prefix}.schema_version must be {PARALLEL_LAUNCH_SCHEMA_VERSION}; "
            f"found: {record.get('schema_version')!r}."
        )
    if record.get("state") != "completed":
        errors.append(
            f"{prefix}.state must be 'completed'; found: {record.get('state')!r}."
        )
    if record.get("launch_receipt_path") != launch_receipt_path:
        errors.append(
            f"{prefix}.launch_receipt_path must match the guarded launch path."
        )
    return errors


def _receipt_document(
    evidence: ParallelCodexReadinessEvidence,
    record: Mapping[str, object],
    *,
    key: str,
    context: str,
) -> tuple[Mapping[str, object] | None, list[str]]:
    """Resolve one required external receipt object by its launch-record path."""

    label = key.removesuffix("_receipt_path").replace("_", "-")
    path = record.get(key)
    if not _is_non_empty_string(path):
        return None, [f"{context} {label} receipt path must be a non-empty string."]
    value = evidence.receipt_records.get(cast("str", path))
    if not isinstance(value, Mapping):
        return None, [f"{context} {label} receipt is missing at {path!r}."]
    return cast("Mapping[str, object]", value), []


def _validate_referenced_receipts(
    evidence: ParallelCodexReadinessEvidence,
    record: Mapping[str, object],
    *,
    context: str,
    parallel_slug: object,
    item_key: object,
) -> list[str]:
    """Validate authority, delegation, topology, and model receipt binding."""

    documents: dict[str, Mapping[str, object]] = {}
    errors: list[str] = []
    for key in (
        "authority_receipt_path",
        "delegation_receipt_path",
        "topology_receipt_path",
        "model_routing_receipt_path",
    ):
        document, document_errors = _receipt_document(
            evidence, record, key=key, context=context
        )
        errors.extend(document_errors)
        if document is not None:
            documents[key] = document

    authority = documents.get("authority_receipt_path")
    if authority is not None:
        for key, expected in (
            ("surface", PARALLEL_SURFACE),
            ("parallel_slug", parallel_slug),
            ("item_key", item_key),
            ("authorized", True),
        ):
            if authority.get(key) != expected:
                errors.append(
                    f"{context} authority receipt.{key} must be {expected!r}; "
                    f"found: {authority.get(key)!r}."
                )
    delegation = documents.get("delegation_receipt_path")
    if delegation is not None:
        if not _is_non_empty_string(delegation.get("delegation_id")):
            errors.append(
                f"{context} delegation receipt.delegation_id must be non-empty."
            )
        if delegation.get("agent_name") != record.get("deployment_agent"):
            errors.append(
                f"{context} delegation receipt.agent_name must match launch agent."
            )
    topology = documents.get("topology_receipt_path")
    if topology is not None:
        for error in validate_codex_topology_receipts([topology]):
            errors.append(
                error.replace(
                    "Checkpoint codex_topology_receipts[0]",
                    f"{context} topology receipt",
                )
            )
    model = documents.get("model_routing_receipt_path")
    if model is not None:
        for error in validate_codex_model_routing_receipts([model]):
            errors.append(
                error.replace(
                    "Checkpoint codex_model_routing_receipts[0]",
                    f"{context} model-routing receipt",
                )
            )
        for key in ("deployment_agent", "model", "model_reasoning_effort"):
            if record.get(key) != model.get(key):
                errors.append(f"{context} {key} must match model-routing receipt.")
    return errors


def validate_parallel_codex_checkpoint_readiness(
    state: Mapping[str, object],
    *,
    context: str,
    evidence: ParallelCodexReadinessEvidence | None,
) -> list[str]:
    """Validate guarded external evidence for an explicit ready/complete gate."""

    if evidence is None:
        return [f"{context} Codex readiness evidence is required."]
    errors = validate_zero_lost_ledger(evidence.enforceability_ledger, context=context)
    errors.extend(_validate_kickoff_identity(state, evidence, context=context))
    items = state.get("items")
    if not isinstance(items, list):
        return errors
    seen_paths: set[str] = set()
    for index, value in enumerate(cast("list[object]", items)):
        if not isinstance(value, Mapping):
            continue
        item = cast("Mapping[str, object]", value)
        item_context = f"{context} items[{index}]"
        receipt_path, receipt_errors = _guarded_path(
            item.get("launch_receipt_path"),
            field=f"{item_context}.launch_receipt_path",
        )
        status_path, status_errors = _guarded_path(
            item.get("launch_status_path"),
            field=f"{item_context}.launch_status_path",
        )
        errors.extend(receipt_errors)
        errors.extend(status_errors)
        for key in ("branch", "worktree_path", "cohort", "batch"):
            if key not in item:
                errors.append(f"{item_context}.{key} is required for Codex readiness.")
        if receipt_path is None or status_path is None:
            continue
        if receipt_path in seen_paths or status_path in seen_paths:
            errors.append(f"{item_context} launch and status paths must be unique.")
        seen_paths.update((receipt_path, status_path))
        record_value = evidence.launch_records.get(receipt_path)
        if not isinstance(record_value, Mapping):
            errors.append(
                f"{item_context} external launch record is missing at {receipt_path!r}."
            )
            continue
        record = cast("Mapping[str, object]", record_value)
        errors.extend(
            validate_parallel_launch_provenance(
                record,
                context=item_context,
                parallel_slug=state.get("parallel_slug"),
                item_key=item.get("issue_num"),
                cohort=item.get("cohort"),
                batch=item.get("batch"),
                head_branch=item.get("branch"),
                worktree_path=item.get("worktree_path"),
                launch_receipt_path=receipt_path,
                launch_status_path=status_path,
            )
        )
        errors.extend(
            _validate_status(
                evidence.status_records.get(status_path),
                context=item_context,
                launch_receipt_path=receipt_path,
            )
        )
        errors.extend(
            _validate_referenced_receipts(
                evidence,
                record,
                context=item_context,
                parallel_slug=state.get("parallel_slug"),
                item_key=item.get("issue_num"),
            )
        )
    return errors
