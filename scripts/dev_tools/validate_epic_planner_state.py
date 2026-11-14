"""Validate epic-planner checkpoints before prepared epic execution."""

from __future__ import annotations

import json
import re
from typing import Any, cast

from scripts.dev_tools._epic_orchestrator_state_launch_binding import (
    validate_epic_planner_child_launch_bindings,
)
from scripts.dev_tools._epic_orchestrator_state_resolution import (
    build_feature_reference_index,
    resolve_feature_reference,
)
from scripts.dev_tools._orchestrator_state_codex_model_routing import (
    validate_codex_model_routing_receipts,
)
from scripts.dev_tools._orchestrator_state_codex_topology import (
    validate_codex_topology_receipts,
)
from scripts.dev_tools.compute_complexity_floor import BAND_ORDER
from scripts.dev_tools.epic_kickoff_contract import (
    validate_epic_kickoff_text as _validate_epic_kickoff_text,
)
from scripts.dev_tools.epic_planner_readiness import (
    EpicReadinessContext,
    validate_epic_readiness_integrity,
)
from scripts.dev_tools.epic_wave_computation import (
    EpicWaveCycleError,
    EpicWaveUnresolvedReferenceError,
    compute_wave_numbers,
)

REQUIRED_KEYS = (
    "objective",
    "epic_feature_folder",
    "epic_manifest_path",
    "integration_branch",
    "max_parallel_features",
    "epic_worthiness",
    "features",
    "kickoff_prompt_path",
    "completed_steps",
    "next_step",
    "last_updated",
)
REQUIRED_FEATURE_KEYS = (
    "issue_num",
    "feature_folder",
    "depends_on",
    "wave",
    "complexity_band",
    "preparation_status",
    "research_path",
    "plan_path",
    "preflight_status",
)
READY_NEXT_STEP = "EPIC_EXECUTION_READY"
NON_EPIC_NEXT_STEP = "NON_EPIC_RECOMMENDED"


def _validate_planner_topology_receipt(value: object) -> list[str]:
    """Require the top-level forced epic-planner topology receipt."""

    errors = [
        error.replace(
            "Checkpoint codex_topology_receipts[0]", "Epic planner topology_receipt"
        )
        for error in validate_codex_topology_receipts([value])
    ]
    if not isinstance(value, dict):
        return errors
    receipt = cast("dict[str, Any]", value)
    expected = {
        "execution_context": "standalone",
        "root_persona": "epic-planner",
        "route": "epic",
        "topology": "epic_persona",
        "logical_agent": "epic-planner",
    }
    for key, expected_value in expected.items():
        if receipt.get(key) != expected_value:
            errors.append(
                f"Epic planner topology_receipt.{key} must be " f"{expected_value!r}."
            )
    return errors


def _validate_child_topology_receipt(value: object, *, prefix: str) -> list[str]:
    """Require an epic-preparation child orchestrator topology receipt."""

    errors = [
        error.replace("Checkpoint codex_topology_receipts[0]", prefix)
        for error in validate_codex_topology_receipts([value])
    ]
    if not isinstance(value, dict):
        return errors
    receipt = cast("dict[str, Any]", value)
    expected = {
        "execution_context": "epic_preparation_child",
        "root_persona": None,
        "route": "large",
        "topology": "orchestrator",
        "logical_agent": "orchestrator",
    }
    for key, expected_value in expected.items():
        if receipt.get(key) != expected_value:
            errors.append(f"{prefix}.{key} must be {expected_value!r}.")
    return errors


def _validate_worthiness(value: object) -> tuple[list[str], str | None]:
    """Validate the epic-worthiness verdict and rationale."""

    if not isinstance(value, dict):
        return ["Epic planner checkpoint epic_worthiness must be an object."], None
    worthiness = cast("dict[str, Any]", value)
    verdict = worthiness.get("verdict")
    errors: list[str] = []
    if verdict not in {"epic", "non_epic"}:
        errors.append(
            "Epic planner checkpoint epic_worthiness.verdict must be "
            "'epic' or 'non_epic'."
        )
    rationale = worthiness.get("rationale")
    if not isinstance(rationale, str) or not rationale.strip():
        errors.append(
            "Epic planner checkpoint epic_worthiness.rationale must be non-empty."
        )
    return errors, verdict if isinstance(verdict, str) else None


def _extract_features(
    value: object,
) -> tuple[list[str], list[tuple[int, dict[str, Any]]]]:
    """Validate baseline feature shape and return indexed object entries."""

    if not isinstance(value, list):
        return ["Epic planner checkpoint features must be a list."], []
    errors: list[str] = []
    indexed_features: list[tuple[int, dict[str, Any]]] = []
    for index, item in enumerate(cast("list[object]", value)):
        prefix = f"Epic planner checkpoint features[{index}]"
        if not isinstance(item, dict):
            errors.append(f"{prefix} must be an object.")
            continue
        feature = cast("dict[str, Any]", item)
        indexed_features.append((index, feature))
        missing = [key for key in REQUIRED_FEATURE_KEYS if key not in feature]
        if missing:
            errors.append(f"{prefix} missing required keys: {', '.join(missing)}.")
            continue
        if not isinstance(feature["depends_on"], list):
            errors.append(f"{prefix}.depends_on must be a list.")
        if not isinstance(feature["wave"], int) or feature["wave"] < 0:
            errors.append(f"{prefix}.wave must be a non-negative integer.")
        if feature["complexity_band"] not in BAND_ORDER:
            errors.append(f"{prefix}.complexity_band must be one of {BAND_ORDER}.")
    return errors, indexed_features


def _validate_dependency_waves(
    indexed_features: list[tuple[int, dict[str, Any]]],
) -> list[str]:
    """Require unique, resolved dependencies and deterministic wave numbers."""

    features = [feature for _, feature in indexed_features]
    errors: list[str] = []
    seen_folders: set[str] = set()
    seen_issues: set[object] = set()
    for index, feature in indexed_features:
        prefix = f"Epic planner checkpoint features[{index}]"
        folder = feature.get("feature_folder")
        if isinstance(folder, str) and folder:
            if folder in seen_folders:
                errors.append(f"{prefix}.feature_folder must be unique: {folder!r}.")
            seen_folders.add(folder)
        issue_num = feature.get("issue_num")
        if issue_num is not None:
            if issue_num in seen_issues:
                errors.append(f"{prefix}.issue_num must be unique: {issue_num!r}.")
            seen_issues.add(issue_num)

    by_folder_hint, by_issue_num = build_feature_reference_index(features)
    manifest: dict[str, list[str]] = {}
    for index, feature in indexed_features:
        folder = feature.get("feature_folder")
        dependencies = feature.get("depends_on")
        if (
            not isinstance(folder, str)
            or not folder
            or not isinstance(dependencies, list)
        ):
            continue
        resolved_edges: list[str] = []
        for dependency in cast("list[Any]", dependencies):
            resolved = resolve_feature_reference(
                dependency, by_folder_hint, by_issue_num
            )
            if resolved is None:
                errors.append(
                    f"Epic planner checkpoint features[{index}].depends_on "
                    f"contains unresolved reference: {dependency!r}."
                )
                continue
            resolved_edges.append(resolved)
        manifest[folder] = resolved_edges

    try:
        expected_waves = compute_wave_numbers(manifest)
    except (EpicWaveCycleError, EpicWaveUnresolvedReferenceError) as exc:
        # A dependency on a feature skipped for shape errors is absent from the
        # manifest; report it rather than raising out of the validator.
        errors.append(str(exc))
        return errors
    for index, feature in indexed_features:
        folder = feature.get("feature_folder")
        if isinstance(folder, str) and folder in expected_waves:
            expected = expected_waves[folder]
            if feature.get("wave") != expected:
                errors.append(
                    f"Epic planner checkpoint features[{index}].wave must be "
                    f"{expected} from the dependency graph, found "
                    f"{feature.get('wave')!r}."
                )
    return errors


def _validate_feature_model_receipt(
    feature: dict[str, Any], *, prefix: str
) -> list[str]:
    """Validate one prepared child's orchestrator model routing receipt."""

    errors: list[str] = []
    model_receipt = feature.get("model_routing_receipt")
    receipt_errors = validate_codex_model_routing_receipts([model_receipt])
    errors.extend(
        error.replace(
            "Checkpoint codex_model_routing_receipts[0]",
            f"{prefix}.model_routing_receipt",
        )
        for error in receipt_errors
    )
    if (
        isinstance(model_receipt, dict)
        and cast("dict[str, Any]", model_receipt).get("logical_agent") != "orchestrator"
    ):
        errors.append(
            f"{prefix}.model_routing_receipt.logical_agent must be 'orchestrator'."
        )
    if isinstance(model_receipt, dict):
        model_map = cast("dict[str, Any]", model_receipt)
        if model_map.get("complexity_band") != feature.get("complexity_band"):
            errors.append(
                f"{prefix}.model_routing_receipt.complexity_band must match "
                f"feature complexity_band {feature.get('complexity_band')!r}."
            )
        if model_map.get("execution_context") != "epic_preparation_child":
            errors.append(
                f"{prefix}.model_routing_receipt.execution_context must be "
                "'epic_preparation_child'."
            )
    return errors


def _validate_ready_features(
    indexed_features: list[tuple[int, dict[str, Any]]], *, key_gated: bool = False
) -> list[str]:
    """Require every child to be fully prepared and preflight-cleared.

    When ``key_gated`` is true (no Codex flag), each per-feature receipt check
    runs only for a feature that carries its key (``model_routing_receipt``,
    ``topology_receipt``). Each error prefix uses the feature's original index
    in the checkpoint ``features`` array.
    """

    errors: list[str] = []
    if len(indexed_features) < 2:
        errors.append("Execution-ready epic planning requires at least two features.")
    for index, feature in indexed_features:
        prefix = f"Epic planner checkpoint features[{index}]"
        issue_num = feature.get("issue_num")
        if not isinstance(issue_num, int) or issue_num <= 0:
            errors.append(f"{prefix}.issue_num must be a positive integer.")
        for key in ("feature_folder", "research_path", "plan_path"):
            value = feature.get(key)
            if not isinstance(value, str) or not value.strip():
                errors.append(f"{prefix}.{key} must be a non-empty string.")
        if feature.get("preparation_status") != "prepared":
            errors.append(f"{prefix}.preparation_status must be 'prepared'.")
        if feature.get("preflight_status") != "PREFLIGHT: ALL CLEAR":
            errors.append(f"{prefix}.preflight_status must be 'PREFLIGHT: ALL CLEAR'.")
        if not key_gated or "model_routing_receipt" in feature:
            errors.extend(_validate_feature_model_receipt(feature, prefix=prefix))
        if not key_gated or "topology_receipt" in feature:
            errors.extend(
                _validate_child_topology_receipt(
                    feature.get("topology_receipt"),
                    prefix=f"{prefix}.topology_receipt",
                )
            )
    return errors


PLANNER_WORKTREE_STATUSES = "preparing prepared fanned_in removed abandoned".split()
_PLANNER_PREFIX = "Epic planner checkpoint planner_worktrees"
_PLANNER_BRANCH = re.compile(r"[A-Za-z0-9][A-Za-z0-9._/-]*")
# The recorded_at blank set: space, tab, LF, CR, VT, FF and nothing else. The
# TypeScript twin RECORDED_AT_BLANK uses the same six characters (not str.strip).
_RECORDED_AT_BLANK_CHARS = " \t\n\r\x0b\x0c"


def _is_planner_branch(value: object) -> bool:
    """Return whether ``value`` is a valid ``planner_worktrees[].branch`` name."""

    if not isinstance(value, str) or not _PLANNER_BRANCH.fullmatch(value):
        return False
    return ".." not in value and not value.endswith(("/", ".", ".lock"))


def _is_planner_relative_path(value: object) -> bool:
    """Return whether ``value`` is a safe path relative to the main checkout.

    A drive prefix or any colon, a leading ``/``, a backslash, and an empty,
    ``.``, or ``..`` segment each name a location outside the main checkout.
    """

    if not isinstance(value, str) or value[:1] in ("", "/") or ":" in value:
        return False
    return "\\" not in value and not {"", ".", ".."} & set(value.split("/"))


def _validate_planner_worktrees(
    state: dict[str, Any], indexed_features: list[tuple[int, dict[str, Any]]]
) -> list[str]:
    """Validate the optional ``planner_worktrees`` records (issue #1161).

    Args:
        state: The parsed checkpoint object; nothing is checked without the key.
        indexed_features: The object entries of ``features`` with their indices.

    Returns:
        Errors in entry order; within an entry: branch or uniqueness, path,
        purpose, preparation_status, feature_folder, recorded_at. A present
        ``recorded_at`` is blank when every character is in
        ``_RECORDED_AT_BLANK_CHARS``.
    """

    if "planner_worktrees" not in state:
        return []
    value = state["planner_worktrees"]
    if not isinstance(value, list):
        return [f"{_PLANNER_PREFIX} must be a list when present."]
    # Collect the feature_folder values an entry's string feature_folder may name.
    folders = [feature.get("feature_folder") for _, feature in indexed_features]
    errors: list[str] = []
    add = errors.append
    seen: set[str] = set()
    # Walk the entries in order; a repeated branch is reported after its first entry.
    for index, item in enumerate(cast("list[object]", value)):
        prefix = f"{_PLANNER_PREFIX}[{index}]"
        if not isinstance(item, dict):
            add(f"{prefix} must be an object.")
            continue
        entry = cast("dict[str, Any]", item)
        branch = entry.get("branch")
        # An invalid branch reports its shape only; a valid one is checked for repeats.
        if not _is_planner_branch(branch):
            add(f"{prefix}.branch must be a non-empty branch name.")
        elif branch in seen:
            add(f"{prefix}.branch must be unique: {branch}.")
        else:
            seen.add(cast("str", branch))
        # The optional path and recorded_at fields are checked only when present.
        if "path" in entry and not _is_planner_relative_path(entry["path"]):
            add(
                f"{prefix}.path must be a repository-relative path without a drive, "
                "a leading slash, a backslash, or dot segments."
            )
        if entry.get("purpose") != "preparation":
            add(f"{prefix}.purpose must be preparation.")
        if entry.get("preparation_status") not in PLANNER_WORKTREE_STATUSES:
            add(
                f"{prefix}.preparation_status must be one of: "
                "preparing, prepared, fanned_in, removed, abandoned."
            )
        folder = entry.get("feature_folder")
        if not isinstance(folder, str) or folder not in folders:
            add(f"{prefix}.feature_folder must name a features[] feature_folder.")
        recorded = entry.get("recorded_at", "absent")
        if not (isinstance(recorded, str) and recorded.strip(_RECORDED_AT_BLANK_CHARS)):
            add(f"{prefix}.recorded_at must be a non-empty string when present.")
    return errors


def validate_epic_planner_state_text(
    text: str,
    *,
    require_ready_for_execution: bool = False,
    readiness_context: EpicReadinessContext | None = None,
    require_codex_model_routing: bool = False,
    require_codex_topology: bool = False,
) -> list[str]:
    """Validate planner checkpoint structure and optional execution readiness.

    ``require_codex_model_routing`` and ``require_codex_topology`` make launch
    evidence, the per-feature receipt checks, and the planner ``topology_receipt``
    unconditional under execution readiness. When neither is set, launch evidence
    is validated only for features that carry a launch path key, the per-feature
    ``model_routing_receipt`` and ``topology_receipt`` checks only for features
    that carry that key, and the planner receipt only when the checkpoint carries
    a top-level ``topology_receipt`` key.
    """

    try:
        value = json.loads(text)
    except json.JSONDecodeError as exc:
        return [f"Epic planner checkpoint is not valid JSON: {exc}"]
    if not isinstance(value, dict):
        return ["Epic planner checkpoint root must be a JSON object."]
    state = cast("dict[str, Any]", value)

    errors = [
        f"Epic planner checkpoint missing required key: {key}"
        for key in REQUIRED_KEYS
        if key not in state
    ]
    worthiness_errors, verdict = _validate_worthiness(state.get("epic_worthiness"))
    errors.extend(worthiness_errors)
    raw_features = state.get("features")
    feature_errors, indexed_features = _extract_features(raw_features)
    errors.extend(feature_errors)
    checkpoint_entries: list[object] = (
        cast("list[object]", raw_features) if isinstance(raw_features, list) else []
    )
    errors.extend(_validate_dependency_waves(indexed_features))
    max_parallel = state.get("max_parallel_features")
    if (
        not isinstance(max_parallel, int)
        or isinstance(max_parallel, bool)
        or not 1 <= max_parallel <= 8
    ):
        errors.append(
            "Epic planner checkpoint max_parallel_features must be an integer "
            "from 1 through 8."
        )
    errors.extend(_validate_planner_worktrees(state, indexed_features))

    if verdict == "non_epic" and state.get("next_step") != NON_EPIC_NEXT_STEP:
        errors.append(
            f"Non-epic planner checkpoint next_step must be {NON_EPIC_NEXT_STEP!r}."
        )
    if require_ready_for_execution:
        # Launch evidence and the per-feature receipt checks
        # (model_routing_receipt, topology_receipt) are key-gated per feature, and
        # the planner topology receipt by its top-level key, unless a Codex flag
        # is asserted.
        key_gated = not (require_codex_model_routing or require_codex_topology)
        if verdict != "epic":
            errors.append(
                "Execution readiness requires epic_worthiness.verdict 'epic'."
            )
        if state.get("next_step") != READY_NEXT_STEP:
            errors.append(
                "Execution-ready planner checkpoint next_step must be "
                f"{READY_NEXT_STEP!r}."
            )
        errors.extend(_validate_ready_features(indexed_features, key_gated=key_gated))
        errors.extend(
            validate_epic_planner_child_launch_bindings(
                checkpoint_entries, require_launch_paths=key_gated
            )
        )
        if not key_gated or "topology_receipt" in state:
            errors.extend(
                _validate_planner_topology_receipt(state.get("topology_receipt"))
            )
        slug = state.get("epic_feature_folder")
        expected_kickoff = f"artifacts/orchestration/epic-kickoff-{slug}.md"
        if state.get("kickoff_prompt_path") != expected_kickoff:
            errors.append(
                "Execution-ready planner checkpoint kickoff_prompt_path must be "
                f"{expected_kickoff!r}."
            )
        if readiness_context is None:
            errors.append(
                "Execution-ready planner validation requires repository context."
            )
        else:
            errors.extend(
                validate_epic_readiness_integrity(
                    state, text, readiness_context, require_launch_paths=key_gated
                )
            )
    return errors


def validate_epic_kickoff_text(text: str) -> list[str]:
    """Validate the committed or ignored epic kickoff Markdown contract."""

    return _validate_epic_kickoff_text(text)
