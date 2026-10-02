"""Wave-barrier ordering invariant for the epic-orchestrator checkpoint validator.

Purpose:
    Hold the retrospective wave-barrier ordering check consumed by
    ``validate_epic_orchestrator_state.py``, including the start guard that
    limits the check to dependent features that are treated as started. The
    helper follows the sibling-delegate convention of
    ``scripts/dev_tools/_epic_orchestrator_state_*.py`` and keeps the main
    validator under the repository 500-line file-size limit.

Responsibilities:
    - Decide whether a feature is treated as started (``feature_has_started``).
    - Report one ``EPIC_WAVE_BARRIER_VIOLATION`` error per violated dependency
      edge of a started feature (``validate_wave_barrier_ordering``).

Invariants / Constraints:
    - Error strings are identical to the TypeScript port in
      ``extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts``.
    - No function mutates its input; no filesystem or network I/O.
    - This module does not import ``validate_epic_orchestrator_state`` (the
      validator imports this module), so no circular import exists.
"""

from __future__ import annotations

from typing import Any, cast

from scripts.dev_tools._epic_orchestrator_state_resolution import (
    build_feature_reference_index,
    resolve_feature_reference,
)

NOT_STARTED_MERGE_STATUS = "not_started"
MERGED_STATUSES = {"merged", "worktree_removed"}


def feature_has_started(feature: dict[str, Any]) -> bool:
    """Report whether a feature is treated as started for the wave barrier.

    Purpose:
        Decide whether the wave-barrier invariant applies to a dependent
        feature. A feature that has not started cannot have violated the
        ordering of its dependencies, so it is not checked.

    Fail-closed rule:
        A feature is treated as started when its ``worktree_created_at`` is a
        string (any string, including an empty one), or when its
        ``merge_status`` is not the literal ``"not_started"``. A missing
        ``merge_status`` key, ``None``, or any other non-string value therefore
        counts as started, so malformed state is still checked.

    Difference from the parallel orchestrator:
        ``_has_started`` in
        ``scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py``
        treats an absent ``merge_status`` as not started and ignores an empty
        start timestamp. This predicate deliberately does not reuse it: the epic
        checkpoint schema records ``merge_status`` for every feature, so an
        absent value is treated as malformed and checked rather than skipped.

    Args:
        feature (dict[str, Any]): One object-shaped ``features[]`` entry.

    Returns:
        bool: True when the feature is treated as started.

    Raises:
        None.

    Side Effects:
        None.
    """

    if isinstance(feature.get("worktree_created_at"), str):
        return True
    return feature.get("merge_status") != NOT_STARTED_MERGE_STATUS


def validate_wave_barrier_ordering(features: list[dict[str, Any]]) -> list[str]:
    """Validate the retrospective wave-barrier ordering invariant.

    Purpose:
        For every feature f that is treated as started (``feature_has_started``)
        and has a list ``depends_on``, each resolvable dependency d must have a
        string ``merge_status`` in {merged, worktree_removed}, and, when both
        timestamps are strings, a ``merge_confirmed_at`` that is not later than
        f's ``worktree_created_at``. Exactly one error is reported per violated
        edge; the status case takes precedence over the timing case:

        - ``EPIC_WAVE_BARRIER_VIOLATION: <f> is treated as started while
          dependency <d> is not merged``
        - ``EPIC_WAVE_BARRIER_VIOLATION: <f> worktree_created_at precedes
          dependency <d> merge_confirmed_at``

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
    # Resolve dependencies through the union index so a barrier edge is found
    # whether the reference is an issue_num or a folder-basename hint; on legacy
    # folder strings the resolved key equals the reference, so lookups match.
    by_folder_hint, by_issue_num = build_feature_reference_index(features)

    for feature in features:
        folder = feature.get("feature_folder")
        depends_on = feature.get("depends_on")
        if not isinstance(folder, str) or not isinstance(depends_on, list):
            continue
        # Start guard: a dependent that has not started cannot have violated
        # the ordering of its dependencies, so its edges are not checked.
        if not feature_has_started(feature):
            continue
        worktree_created_at = feature.get("worktree_created_at")

        # Every dependency edge must be durably confirmed merged before this
        # feature is considered to have safely started its own wave.
        for dependency in cast("list[Any]", depends_on):
            resolved = resolve_feature_reference(
                dependency, by_folder_hint, by_issue_num
            )
            dependency_feature = (
                by_folder.get(resolved) if resolved is not None else None
            )
            if dependency_feature is None:
                continue
            dep_merge_status = dependency_feature.get("merge_status")
            dep_confirmed_at = dependency_feature.get("merge_confirmed_at")
            # The isinstance check precedes set membership so an unhashable
            # merge_status (for example a list) is reported, not raised.
            status_violation = (
                not isinstance(dep_merge_status, str)
                or dep_merge_status not in MERGED_STATUSES
            )
            timing_violation = (
                isinstance(dep_confirmed_at, str)
                and isinstance(worktree_created_at, str)
                and dep_confirmed_at > worktree_created_at
            )
            if status_violation:
                errors.append(
                    f"EPIC_WAVE_BARRIER_VIOLATION: {folder} is treated as started "
                    f"while dependency {dependency} is not merged"
                )
            elif timing_violation:
                errors.append(
                    f"EPIC_WAVE_BARRIER_VIOLATION: {folder} worktree_created_at "
                    f"precedes dependency {dependency} merge_confirmed_at"
                )
    return errors
