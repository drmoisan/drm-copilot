"""Validate epic-orchestrator checkpoint state artifacts.

Purpose:
    Hold the epic-checkpoint validation logic as a sibling module to
    ``validate_orchestrator_state.py``, following the existing sibling-module
    convention (``validate_orchestrator_state.py``,
    ``validate_policy_audit_artifact.py``,
    ``validate_orchestration_review_artifacts.py``) rather than folding the
    epic-checkpoint's structurally different required-key/status shape into the
    per-feature validator.

Usage:
    Import ``validate_epic_orchestrator_state_text`` from this module, or via
    the dispatch branch in ``scripts.dev_tools.validate_orchestration_artifacts``.

Flow:
    Parse the epic checkpoint JSON, validate the baseline and epic-specific
    required fields, validate ``features[]`` shape (uniqueness, ``depends_on``
    resolution, cycle rejection, ``merge_status`` enum membership), validate the
    wave-barrier ordering invariant and the ``waves[]``/``wave_number``
    consistency, then, under ``require_complete``, enforce the completion gate.

Invariants / Constraints:
    - The validator returns a list of error strings and never mutates its input,
      matching the convention established by ``validate_orchestrator_state_text``.
    - This module stays under the repository's 500-line file-size limit.
"""

from __future__ import annotations

import json
from typing import Any, cast

REQUIRED_BASELINE_KEYS = (
    "objective",
    "completed_steps",
    "next_step",
    "last_updated",
)
REQUIRED_EPIC_KEYS = (
    "route_id",
    "epic_feature_folder",
    "integration_branch",
    "waves",
    "features",
)
EXPECTED_ROUTE_ID = "epic"
VALID_MERGE_STATUS = {
    "not_started",
    "worktree_created",
    "pr_open",
    "ci_green",
    "merge_conflict",
    "blocked_conflict_loop_limit",
    "merged",
    "worktree_removed",
}
MERGED_STATUSES = {"merged", "worktree_removed"}


def _missing_baseline_and_epic_keys(state: dict[str, Any]) -> list[str]:
    """Return errors for any missing baseline or epic-specific required key.

    Purpose:
        Enforce presence of the four carried-over baseline fields (so the
        existing structural checks in ``validate-orchestrator-output.ps1``
        apply unmodified when reused for the epic-orchestrator SubagentStop
        matcher) plus the epic-specific required fields from spec.md section 6.

    Args:
        state (dict[str, Any]): Parsed checkpoint JSON object.

    Returns:
        list[str]: One error string per missing required key.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    for key in REQUIRED_BASELINE_KEYS + REQUIRED_EPIC_KEYS:
        if key not in state:
            errors.append(f"Epic checkpoint missing required key: {key}")
    return errors


def _validate_route_id(state: dict[str, Any]) -> list[str]:
    """Validate that route_id, when present, is exactly 'epic'.

    Args:
        state (dict[str, Any]): Parsed checkpoint JSON object.

    Returns:
        list[str]: An error when route_id is present but not 'epic'.

    Raises:
        None.

    Side Effects:
        None.
    """

    if "route_id" in state and state.get("route_id") != EXPECTED_ROUTE_ID:
        return [
            "Epic checkpoint route_id must be 'epic', found: "
            f"{state.get('route_id')!r}"
        ]
    return []


def _extract_features(state: dict[str, Any]) -> list[dict[str, Any]]:
    """Return the features[] list as typed dicts, skipping non-object entries.

    Args:
        state (dict[str, Any]): Parsed checkpoint JSON object.

    Returns:
        list[dict[str, Any]]: Each object-shaped entry in features[]; malformed
        (non-object) entries are silently skipped here because shape errors for
        them are reported by the caller's own iteration where relevant.

    Raises:
        None.

    Side Effects:
        None.
    """

    features = state.get("features")
    if not isinstance(features, list):
        return []
    # Keep only well-formed feature objects; a non-object entry is not a valid
    # feature record and cannot be used for uniqueness/reference resolution.
    return [f for f in cast("list[Any]", features) if isinstance(f, dict)]


def _validate_feature_folder_uniqueness_and_dependencies(
    features: list[dict[str, Any]],
) -> list[str]:
    """Validate feature_folder uniqueness and depends_on reference resolution.

    Purpose:
        Reject a manifest-derived checkpoint whose features[] contains a
        duplicate feature_folder or a depends_on entry that does not resolve to
        another features[].feature_folder, per spec.md section 6.

    Args:
        features (list[dict[str, Any]]): Object-shaped features[] entries.

    Returns:
        list[str]: One error per duplicate feature_folder or unresolved
        depends_on reference.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    seen: set[str] = set()
    duplicates: set[str] = set()
    # Walk once to collect the full set of defined feature_folder values before
    # checking depends_on resolution, so forward references are not misreported.
    all_folders: set[str] = set()
    for feature in features:
        folder = feature.get("feature_folder")
        if isinstance(folder, str) and folder:
            all_folders.add(folder)

    for feature in features:
        folder = feature.get("feature_folder")
        if not isinstance(folder, str) or not folder:
            continue
        if folder in seen:
            duplicates.add(folder)
        seen.add(folder)

        depends_on = feature.get("depends_on")
        if not isinstance(depends_on, list):
            continue
        # Every declared dependency must resolve to a defined feature_folder;
        # an unresolved reference is a malformed manifest, rejected up front.
        for dependency in cast("list[Any]", depends_on):
            if dependency not in all_folders:
                errors.append(
                    f"Epic checkpoint feature '{folder}' depends_on unresolved "
                    f"feature_folder: {dependency!r}"
                )

    for folder in sorted(duplicates):
        errors.append(
            f"Epic checkpoint has duplicate features[].feature_folder: {folder}"
        )
    return errors


def _detect_dependency_cycle(features: list[dict[str, Any]]) -> str | None:
    """Detect a cycle in the depends_on dependency graph via DFS.

    Args:
        features (list[dict[str, Any]]): Object-shaped features[] entries.

    Returns:
        str | None: An error string naming the cycle, or None when acyclic.

    Raises:
        None.

    Side Effects:
        None.
    """

    graph: dict[str, list[str]] = {}
    for feature in features:
        folder = feature.get("feature_folder")
        if not isinstance(folder, str) or not folder:
            continue
        depends_on = feature.get("depends_on")
        graph[folder] = (
            [d for d in cast("list[Any]", depends_on) if isinstance(d, str)]
            if isinstance(depends_on, list)
            else []
        )

    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(node: str) -> str | None:
        if node in visiting:
            return node
        if node in visited or node not in graph:
            return None
        visiting.add(node)
        # Depth-first traversal of this node's dependencies; a revisit of a node
        # still on the current path (in `visiting`) indicates a cycle.
        for dependency in graph[node]:
            cycle_node = visit(dependency)
            if cycle_node is not None:
                return cycle_node
        visiting.discard(node)
        visited.add(node)
        return None

    for start in list(graph):
        cycle_node = visit(start)
        if cycle_node is not None:
            return (
                "Epic checkpoint depends_on graph contains a cycle involving "
                f"feature_folder: {cycle_node}"
            )
    return None


def _validate_merge_status_enum(features: list[dict[str, Any]]) -> list[str]:
    """Validate merge_status enum membership for every feature record.

    Args:
        features (list[dict[str, Any]]): Object-shaped features[] entries.

    Returns:
        list[str]: One error per feature with an invalid merge_status value.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    for feature in features:
        folder = feature.get("feature_folder", "<unknown>")
        merge_status = feature.get("merge_status")
        if merge_status is not None and merge_status not in VALID_MERGE_STATUS:
            errors.append(
                f"Epic checkpoint feature '{folder}' has invalid merge_status: "
                f"{merge_status!r}"
            )
    return errors


def _validate_wave_barrier_ordering(features: list[dict[str, Any]]) -> list[str]:
    """Validate the retrospective wave-barrier ordering invariant.

    Purpose:
        For every feature f with non-empty depends_on, each dependency d must
        have merge_status in {merged, worktree_removed} and a non-null
        merge_confirmed_at timestamp that is chronologically <=
        f.worktree_created_at (when both are non-null), per spec.md section 6.

    Args:
        features (list[dict[str, Any]]): Object-shaped features[] entries.

    Returns:
        list[str]: One EPIC_WAVE_BARRIER_VIOLATION error per violated edge.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    by_folder = {
        f["feature_folder"]: f
        for f in features
        if isinstance(f.get("feature_folder"), str)
    }

    for feature in features:
        folder = feature.get("feature_folder")
        depends_on = feature.get("depends_on")
        if not isinstance(folder, str) or not isinstance(depends_on, list):
            continue
        worktree_created_at = feature.get("worktree_created_at")

        # Every dependency edge must be durably confirmed merged before this
        # feature is considered to have safely started its own wave.
        for dependency in cast("list[Any]", depends_on):
            dependency_feature = by_folder.get(dependency)
            if dependency_feature is None:
                continue
            dep_merge_status = dependency_feature.get("merge_status")
            dep_confirmed_at = dependency_feature.get("merge_confirmed_at")
            status_violation = dep_merge_status not in MERGED_STATUSES
            timing_violation = (
                isinstance(dep_confirmed_at, str)
                and isinstance(worktree_created_at, str)
                and dep_confirmed_at > worktree_created_at
            )
            if status_violation or timing_violation:
                errors.append(
                    f"EPIC_WAVE_BARRIER_VIOLATION: {folder} started before "
                    f"dependency {dependency} merged"
                )
    return errors


def _validate_waves_consistency(state: dict[str, Any]) -> list[str]:
    """Validate consistency between waves[].feature_folders and wave_number.

    Args:
        state (dict[str, Any]): Parsed checkpoint JSON object.

    Returns:
        list[str]: One error per feature_folder whose recorded wave_number does
        not match the wave it is listed under in waves[].

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    waves = state.get("waves")
    if not isinstance(waves, list):
        return errors
    features_by_folder = {f.get("feature_folder"): f for f in _extract_features(state)}

    for wave_item in cast("list[Any]", waves):
        if not isinstance(wave_item, dict):
            continue
        wave = cast("dict[str, Any]", wave_item)
        wave_number = wave.get("wave_number")
        folders = wave.get("feature_folders")
        if not isinstance(folders, list):
            continue
        # Every feature listed under this wave must record the same
        # wave_number on its own features[] entry.
        for folder in cast("list[Any]", folders):
            feature = features_by_folder.get(folder)
            if feature is None:
                continue
            if feature.get("wave_number") != wave_number:
                errors.append(
                    f"Epic checkpoint waves[] lists '{folder}' under wave "
                    f"{wave_number} but its own wave_number is "
                    f"{feature.get('wave_number')!r}"
                )
    return errors


def _validate_completion(
    features: list[dict[str, Any]], state: dict[str, Any]
) -> list[str]:
    """Validate the require_complete gate.

    Args:
        features (list[dict[str, Any]]): Object-shaped features[] entries.
        state (dict[str, Any]): Parsed checkpoint JSON object.

    Returns:
        list[str]: Completion-gate errors: any feature not merged/removed, or a
        missing/empty epic_merge_pr.merge_commit_sha.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    for feature in features:
        folder = feature.get("feature_folder", "<unknown>")
        if feature.get("merge_status") not in MERGED_STATUSES:
            errors.append(
                "Epic checkpoint completion validation failed: feature "
                f"'{folder}' merge_status is not merged/worktree_removed."
            )

    epic_merge_pr = state.get("epic_merge_pr")
    merge_commit_sha = (
        cast("dict[str, Any]", epic_merge_pr).get("merge_commit_sha")
        if isinstance(epic_merge_pr, dict)
        else None
    )
    if not isinstance(merge_commit_sha, str) or not merge_commit_sha.strip():
        errors.append(
            "Epic checkpoint completion validation failed: "
            "epic_merge_pr.merge_commit_sha is missing or empty."
        )
    return errors


def validate_epic_orchestrator_state_text(
    text: str,
    *,
    require_complete: bool = False,
) -> list[str]:
    """Validate epic checkpoint schema and wave-barrier/completion invariants.

    Purpose:
        Enforce the repository contract for epic-orchestrator checkpoint
        artifacts (``artifacts/orchestration/epic-orchestrator-state.json``)
        before resume or completion-gate workflows rely on its contents.

    Args:
        text (str): Raw epic checkpoint JSON text.
        require_complete (bool): When True, require every feature's
            merge_status to be completion-safe and epic_merge_pr.merge_commit_sha
            to be recorded.

    Returns:
        list[str]: Validation errors for malformed or incomplete checkpoint
        state; an empty list when the checkpoint is valid.

    Raises:
        None.

    Side Effects:
        None.
    """

    try:
        state = json.loads(text)
    except json.JSONDecodeError as exc:
        return [f"Epic checkpoint is not valid JSON: {exc}"]

    if not isinstance(state, dict):
        return ["Epic checkpoint root must be a JSON object."]
    state_map = cast("dict[str, Any]", state)

    errors: list[str] = []
    errors.extend(_missing_baseline_and_epic_keys(state_map))
    errors.extend(_validate_route_id(state_map))

    features = _extract_features(state_map)
    errors.extend(_validate_feature_folder_uniqueness_and_dependencies(features))
    cycle_error = _detect_dependency_cycle(features)
    if cycle_error is not None:
        errors.append(cycle_error)
    errors.extend(_validate_merge_status_enum(features))
    errors.extend(_validate_wave_barrier_ordering(features))
    errors.extend(_validate_waves_consistency(state_map))

    if require_complete:
        errors.extend(_validate_completion(features, state_map))

    return errors
