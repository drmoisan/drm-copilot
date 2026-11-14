"""Wave-barrier ordering invariant for the epic-orchestrator checkpoint validator.

Purpose:
    Hold the retrospective wave-barrier ordering check consumed by
    ``validate_epic_orchestrator_state.py``, including the start guard that
    limits the check to dependent features that are treated as started, and the
    early-start exemption of issue #1097. The helper follows the
    sibling-delegate convention of
    ``scripts/dev_tools/_epic_orchestrator_state_*.py`` and keeps the main
    validator under the repository 500-line file-size limit.

Responsibilities:
    - Decide whether a feature is treated as started (``feature_has_started``).
    - Report one ``EPIC_WAVE_BARRIER_VIOLATION`` error per violated dependency
      edge of a started feature (``validate_wave_barrier_ordering``).
    - Decide which edge a valid ``early_start`` record exempts
      (``early_start_exempt_folder``) and judge that edge
      (``early_start_edge_error``) with one of two messages:

      - ``EPIC_WAVE_BARRIER_VIOLATION: <f> is at pr_open or later while
        early_start dependency <d> is not merged``
      - ``EPIC_WAVE_BARRIER_VIOLATION: <f> is at pr_open or later without a
        string synced_at for early_start dependency <d>``

Invariants / Constraints:
    - Error strings are identical to the TypeScript port in
      ``extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-wave-barrier.ts``
      and the PowerShell port ``OrchestratorStateEpicWaveBarrier.psm1``.
    - A feature without a valid ``early_start`` record takes exactly the
      pre-#1097 path, so older checkpoints validate byte-identically.
    - No function mutates its input; no filesystem or network I/O.
    - This module does not import ``validate_epic_orchestrator_state`` (the
      validator imports this module), so no circular import exists.
"""

from __future__ import annotations

from typing import Any, cast

from scripts.dev_tools._epic_orchestrator_state_resolution import (
    CROSS_EPIC_KEY,
    build_feature_reference_index,
    is_epic_slug,
    is_positive_int,
    resolve_feature_reference,
)

NOT_STARTED_MERGE_STATUS = "not_started"
MERGED_STATUSES = {"merged", "worktree_removed"}

# Dependent statuses before pr_open: an early-started dependent at one of these
# has not yet asked for review, so its exempt edge carries no requirement.
EARLY_START_KEY = "early_start"
EARLY_START_PRE_REVIEW_STATUSES = {NOT_STARTED_MERGE_STATUS, "worktree_created"}
EARLY_START_STRING_FIELDS = (
    "upstream_branch",
    "interface_settled_at",
    "interface_evidence",
)
EARLY_START_UNMERGED_FORMAT = (
    "EPIC_WAVE_BARRIER_VIOLATION: {0} is at pr_open or later while "
    "early_start dependency {1} is not merged"
)
EARLY_START_UNSYNCED_FORMAT = (
    "EPIC_WAVE_BARRIER_VIOLATION: {0} is at pr_open or later without a string "
    "synced_at for early_start dependency {1}"
)
# Issue #1162: a started feature whose cross-epic entry is not integrated.
CROSS_EPIC_INTEGRATED_STATUSES = ("integrated", "in_main")
CROSS_EPIC_VIOLATION_FORMAT = (
    "EPIC_CROSS_DEPENDENCY_VIOLATION: {0} is treated as started while cross-epic "
    "dependency {1}#{2} is not integrated"
)


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


def _is_non_empty_string(value: object) -> bool:
    """Report whether a value is a string of length above zero.

    Args:
        value (object): Any JSON value.

    Returns:
        bool: True for a non-empty string. No trimming is applied, because the
        three runtimes disagree on what counts as whitespace.

    Raises:
        None.

    Side Effects:
        None.
    """

    return isinstance(value, str) and len(value) > 0


def early_start_exempt_folder(
    feature: dict[str, Any],
    by_folder_hint: dict[str, str],
    by_issue_num: dict[Any, str],
) -> str | None:
    """Return the feature folder that a valid ``early_start`` record exempts.

    Purpose:
        Read ``feature["early_start"]`` and, when it is a valid record, resolve
        its ``dependency`` through the existing union index. The caller exempts
        only the edge that resolves to the same folder; every other edge keeps
        the pre-#1097 checks.

    Validity:
        The record is an object under the exact key ``early_start``; its
        ``dependency`` is a non-empty string or a number but never a boolean;
        and ``upstream_branch``, ``interface_settled_at``, and
        ``interface_evidence`` are non-empty strings. An invalid record is the
        same as no key.

    Args:
        feature (dict[str, Any]): One object-shaped ``features[]`` entry.
        by_folder_hint (dict[str, str]): Normalized-basename -> folder map.
        by_issue_num (dict[Any, str]): issue_num -> folder map.

    Returns:
        str | None: The exempt folder, or ``None`` when the record is absent,
        invalid, or names no defined feature.

    Raises:
        None.

    Side Effects:
        None.
    """

    record = feature.get(EARLY_START_KEY)
    if not isinstance(record, dict):
        return None
    fields = cast("dict[str, Any]", record)
    dependency = fields.get("dependency")
    # The dependency must be a usable reference: a boolean is excluded first
    # because Python treats True as the integer 1, which the TypeScript port
    # does not; a string must be non-empty; any other type is not a reference.
    if isinstance(dependency, bool):
        return None
    if not (_is_non_empty_string(dependency) or isinstance(dependency, (int, float))):
        return None
    # Every one of the three descriptive fields must hold a non-empty string.
    for name in EARLY_START_STRING_FIELDS:
        if not _is_non_empty_string(fields.get(name)):
            return None
    return resolve_feature_reference(dependency, by_folder_hint, by_issue_num)


def early_start_edge_error(
    feature: dict[str, Any],
    dependency_feature: dict[str, Any],
    folder: str,
    dependency: object,
) -> str | None:
    """Judge the one dependency edge that a valid ``early_start`` record exempts.

    Purpose:
        Replace the status and timing checks on the exempt edge. An early
        dependent always starts before its upstream merges, so the timing check
        cannot apply; instead the dependent may reach ``pr_open`` only after the
        upstream merged and the dependent recorded its sync.

    Decision table:
        - dependent ``merge_status`` is ``not_started`` or ``worktree_created``:
          no error;
        - otherwise (an absent or unknown status included, the fail-closed rule
          of ``feature_has_started``), an upstream that is not ``merged`` or
          ``worktree_removed`` gives the unmerged message;
        - otherwise a ``synced_at`` that is not a non-empty string gives the
          unsynced message;
        - otherwise no error.

    Args:
        feature (dict[str, Any]): The dependent feature carrying the record.
        dependency_feature (dict[str, Any]): The resolved upstream feature.
        folder (str): The dependent's ``feature_folder``.
        dependency (object): The raw ``depends_on`` element, rendered as the
            existing messages render it.

    Returns:
        str | None: One ``EPIC_WAVE_BARRIER_VIOLATION`` error, or ``None``.

    Raises:
        None.

    Side Effects:
        None.
    """

    status = feature.get("merge_status")
    # A dependent before review carries no requirement on its exempt edge.
    if isinstance(status, str) and status in EARLY_START_PRE_REVIEW_STATUSES:
        return None
    upstream_status = dependency_feature.get("merge_status")
    # At pr_open or later the upstream must have merged first, and then the
    # dependent must have recorded its sync; the merge check comes first
    # because a sync before the upstream merge proves nothing.
    if not isinstance(upstream_status, str) or upstream_status not in MERGED_STATUSES:
        return EARLY_START_UNMERGED_FORMAT.format(folder, dependency)
    record = cast("dict[str, Any]", feature.get(EARLY_START_KEY))
    if not _is_non_empty_string(record.get("synced_at")):
        return EARLY_START_UNSYNCED_FORMAT.format(folder, dependency)
    return None


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

        The one edge exempted by a valid ``early_start`` record
        (``early_start_exempt_folder``) is judged by ``early_start_edge_error``
        instead.

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
        exempt_folder = early_start_exempt_folder(feature, by_folder_hint, by_issue_num)

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
            # The edge a valid early_start record names follows its own table
            # and skips both checks below; every other edge is unchanged.
            if exempt_folder is not None and resolved == exempt_folder:
                early_error = early_start_edge_error(
                    feature, dependency_feature, folder, dependency
                )
                if early_error is not None:
                    errors.append(early_error)
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
    # Key-gated issue #1162 check: a feature without cross_epic_depends_on adds
    # nothing, so the result above is unchanged for older checkpoints.
    errors.extend(validate_cross_epic_started_while_held(features))
    return errors


def validate_cross_epic_started_while_held(
    features: list[dict[str, Any]],
) -> list[str]:
    """Report started features whose cross-epic dependency is not integrated.

    Purpose:
        The Layer 2 analogue of the wave barrier for issue #1162. A feature
        that ``feature_has_started`` treats as started must not carry a
        ``cross_epic_depends_on`` entry whose ``status`` is not ``integrated``
        or ``in_main``. Entries without a valid epic slug or a positive integer
        ``issue_num`` are left to the shape check.

    Args:
        features (list[dict[str, Any]]): Object-shaped features[] entries.

    Returns:
        list[str]: One ``EPIC_CROSS_DEPENDENCY_VIOLATION`` error per held entry.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    # Only started features with a string folder and a list value are checked.
    for feature in features:
        folder = feature.get("feature_folder")
        entries = feature.get(CROSS_EPIC_KEY)
        if not isinstance(folder, str) or not isinstance(entries, list):
            continue
        if not feature_has_started(feature):
            continue
        # Every well-formed entry must record an integrated prerequisite.
        for entry in cast("list[Any]", entries):
            if not isinstance(entry, dict):
                continue
            record = cast("dict[str, Any]", entry)
            epic = record.get("epic")
            issue_num = record.get("issue_num")
            if not is_epic_slug(epic) or not is_positive_int(issue_num):
                continue
            status = record.get("status")
            if isinstance(status, str) and status in CROSS_EPIC_INTEGRATED_STATUSES:
                continue
            errors.append(CROSS_EPIC_VIOLATION_FORMAT.format(folder, epic, issue_num))
    return errors
