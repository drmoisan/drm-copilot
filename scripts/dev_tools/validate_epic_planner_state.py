"""Validate epic-planner checkpoints before prepared epic execution."""

from __future__ import annotations

import json
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


def _extract_features(value: object) -> tuple[list[str], list[dict[str, Any]]]:
    """Validate baseline feature shape and return object entries."""

    if not isinstance(value, list):
        return ["Epic planner checkpoint features must be a list."], []
    errors: list[str] = []
    features: list[dict[str, Any]] = []
    for index, item in enumerate(cast("list[object]", value)):
        prefix = f"Epic planner checkpoint features[{index}]"
        if not isinstance(item, dict):
            errors.append(f"{prefix} must be an object.")
            continue
        feature = cast("dict[str, Any]", item)
        features.append(feature)
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
    return errors, features


def _validate_dependency_waves(features: list[dict[str, Any]]) -> list[str]:
    """Require unique, resolved dependencies and deterministic wave numbers."""

    errors: list[str] = []
    seen_folders: set[str] = set()
    seen_issues: set[object] = set()
    for index, feature in enumerate(features):
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
    for index, feature in enumerate(features):
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
    except EpicWaveCycleError as exc:
        errors.append(str(exc))
        return errors
    for index, feature in enumerate(features):
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


def _validate_ready_features(features: list[dict[str, Any]]) -> list[str]:
    """Require every child to be fully prepared and preflight-cleared."""

    errors: list[str] = []
    if len(features) < 2:
        errors.append("Execution-ready epic planning requires at least two features.")
    for index, feature in enumerate(features):
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
            and cast("dict[str, Any]", model_receipt).get("logical_agent")
            != "orchestrator"
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
        errors.extend(
            _validate_child_topology_receipt(
                feature.get("topology_receipt"),
                prefix=f"{prefix}.topology_receipt",
            )
        )
    return errors


def validate_epic_planner_state_text(
    text: str,
    *,
    require_ready_for_execution: bool = False,
    readiness_context: EpicReadinessContext | None = None,
) -> list[str]:
    """Validate planner checkpoint structure and optional execution readiness."""

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
    feature_errors, features = _extract_features(state.get("features"))
    errors.extend(feature_errors)
    errors.extend(_validate_dependency_waves(features))
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

    if verdict == "non_epic" and state.get("next_step") != NON_EPIC_NEXT_STEP:
        errors.append(
            f"Non-epic planner checkpoint next_step must be {NON_EPIC_NEXT_STEP!r}."
        )
    if require_ready_for_execution:
        if verdict != "epic":
            errors.append(
                "Execution readiness requires epic_worthiness.verdict 'epic'."
            )
        if state.get("next_step") != READY_NEXT_STEP:
            errors.append(
                "Execution-ready planner checkpoint next_step must be "
                f"{READY_NEXT_STEP!r}."
            )
        errors.extend(_validate_ready_features(features))
        errors.extend(validate_epic_planner_child_launch_bindings(features))
        errors.extend(_validate_planner_topology_receipt(state.get("topology_receipt")))
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
                validate_epic_readiness_integrity(state, text, readiness_context)
            )
    return errors


def validate_epic_kickoff_text(text: str) -> list[str]:
    """Validate the committed or ignored epic kickoff Markdown contract."""

    return _validate_epic_kickoff_text(text)
