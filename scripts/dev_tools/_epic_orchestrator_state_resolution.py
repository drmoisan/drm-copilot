"""Additive, key-gated resolution helpers for the epic-orchestrator validator.

Purpose:
    Hold the issue_num-keyed dependency resolution and the presence-gated
    intent-block validation for ``validate_epic_orchestrator_state.py``, following
    the established sibling-delegate convention used by the orchestrator-state
    validator (``scripts/dev_tools/_orchestrator_state_*.py``). Extracting these
    into a sibling module keeps the main validator under the repository 500-line
    file-size limit while keeping the resolver a single shared helper consumed by
    every dependency-aware check.

Responsibilities:
    - Build a union index over the defined features (feature_folder set plus
      issue_num set) and resolve a single ``depends_on`` reference against it.
    - Resolve a ``feature_folder`` hint that may point into ``active/`` or
      ``completed/`` to its stable basename.
    - Validate the optional SAFe-style ``intent`` block, presence-gated.

Invariants / Constraints:
    - All helpers are additive and key-gated: on the legacy folder-basename-keyed,
      intent-free checkpoint shape they produce byte-identical results to the
      pre-change validator (the resolver is identity on a bare folder basename
      that names a defined feature, and intent validation is a no-op when the
      ``intent`` key is absent).
    - No function mutates its input; each returns new values / error lists.
    - No filesystem or network I/O; pure in-memory validation.
"""

from __future__ import annotations

from typing import Any, cast

# Lifecycle path prefixes a feature_folder hint may carry. A hint may point into
# active/ or completed/; stripping the prefix yields the stable basename used as
# the canonical resolution key, which is what lets a dependency expressed with
# either lifecycle location resolve to the same feature.
_LIFECYCLE_PREFIXES = (
    "docs/features/active/",
    "docs/features/completed/",
    "active/",
    "completed/",
)

_VALID_EPIC_TYPES = {"business", "enabler"}


def _normalize_folder_hint(value: str) -> str:
    """Return the stable basename of a feature_folder hint.

    Strips a leading ``active/`` or ``completed/`` lifecycle path prefix so a hint
    that points into either lifecycle location resolves to the same basename. A
    value with no known prefix is returned unchanged (the legacy bare-basename
    shape), which keeps legacy resolution byte-identical.

    Args:
        value (str): A feature_folder value or depends_on reference string.

    Returns:
        str: The basename with any lifecycle prefix removed.

    Raises:
        None.

    Side Effects:
        None.
    """
    # Check each known lifecycle prefix in order; the first match is stripped.
    for prefix in _LIFECYCLE_PREFIXES:
        if value.startswith(prefix):
            return value[len(prefix) :]
    return value


def build_feature_reference_index(
    features: list[dict[str, Any]],
) -> tuple[dict[str, str], dict[Any, str]]:
    """Build the union index used to resolve depends_on references.

    Produces two lookup maps over the defined features: one keyed by the
    normalized feature_folder basename and one keyed by ``issue_num``, each mapping
    to the raw feature_folder value (the canonical graph/lookup key used elsewhere
    in the validator). Building both is what makes the resolver a union index: a
    reference resolves whether it is a folder-basename hint or an ``issue_num``.

    Args:
        features (list[dict[str, Any]]): Object-shaped features[] entries.

    Returns:
        tuple[dict[str, str], dict[Any, str]]: The ``(by_folder_hint,
        by_issue_num)`` pair, each mapping to the raw feature_folder value.

    Raises:
        None.

    Side Effects:
        None.
    """
    by_folder_hint: dict[str, str] = {}
    by_issue_num: dict[Any, str] = {}
    # Index every defined feature by both its normalized folder basename and its
    # issue_num so a dependency expressed either way resolves to the same feature.
    for feature in features:
        folder = feature.get("feature_folder")
        if isinstance(folder, str) and folder:
            by_folder_hint[_normalize_folder_hint(folder)] = folder
            issue_num = feature.get("issue_num")
            if issue_num is not None:
                by_issue_num[issue_num] = folder
    return by_folder_hint, by_issue_num


def resolve_feature_reference(
    dependency: Any,
    by_folder_hint: dict[str, str],
    by_issue_num: dict[Any, str],
) -> str | None:
    """Resolve one depends_on reference to its canonical feature_folder.

    Detects whether the reference is an ``issue_num`` (non-string) or a
    feature_folder basename (string, with an optional ``active/`` or
    ``completed/`` prefix) and resolves it against the union index. Returns the
    raw feature_folder value the reference points to, or ``None`` when it resolves
    to no defined feature. On the legacy shape (a bare folder-basename string that
    names a defined feature) the return value is that same basename, so callers
    stay byte-identical.

    Args:
        dependency (Any): A single depends_on entry (issue_num or folder hint).
        by_folder_hint (dict[str, str]): Normalized-basename -> raw folder map.
        by_issue_num (dict[Any, str]): issue_num -> raw folder map.

    Returns:
        str | None: The canonical feature_folder, or ``None`` when unresolved.

    Raises:
        None.

    Side Effects:
        None.
    """
    # A non-string reference is treated as an issue_num lookup; a string is a
    # feature_folder hint resolved after stripping any lifecycle prefix. An
    # unhashable reference cannot index the map and is reported as unresolved.
    if not isinstance(dependency, str):
        try:
            return by_issue_num.get(dependency)
        except TypeError:
            return None
    return by_folder_hint.get(_normalize_folder_hint(dependency))


def detect_dependency_cycle(features: list[dict[str, Any]]) -> str | None:
    """Detect a cycle in the depends_on dependency graph via DFS.

    Resolves every depends_on reference to its canonical feature_folder through
    the union index so the graph is keyed uniformly whether dependencies are
    issue_num references or (possibly lifecycle-prefixed) folder-basename hints.
    On the legacy shape each folder string resolves to itself, so the graph and
    any cycle it reveals are byte-identical to the pre-change validator.

    Args:
        features (list[dict[str, Any]]): Object-shaped features[] entries.

    Returns:
        str | None: An error string naming the cycle, or ``None`` when acyclic.

    Raises:
        None.

    Side Effects:
        None.
    """
    by_folder_hint, by_issue_num = build_feature_reference_index(features)
    graph: dict[str, list[str]] = {}
    for feature in features:
        folder = feature.get("feature_folder")
        if not isinstance(folder, str) or not folder:
            continue
        depends_on = feature.get("depends_on")
        if not isinstance(depends_on, list):
            graph[folder] = []
            continue
        # Keep only references that resolve to a defined feature; an unresolved
        # reference contributes no edge (as in the legacy code, where a
        # non-graph-key dependency was visited to a no-op).
        resolved_edges: list[str] = []
        for dependency in cast("list[Any]", depends_on):
            resolved = resolve_feature_reference(
                dependency, by_folder_hint, by_issue_num
            )
            if resolved is not None:
                resolved_edges.append(resolved)
        graph[folder] = resolved_edges

    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(node: str) -> str | None:
        """Return a node on a cycle reachable from ``node``, else ``None``."""
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

    # Start a DFS from every node so disconnected subgraphs are all covered.
    for start in list(graph):
        cycle_node = visit(start)
        if cycle_node is not None:
            return (
                "Epic checkpoint depends_on graph contains a cycle involving "
                f"feature_folder: {cycle_node}"
            )
    return None


def validate_intent_block(state: dict[str, Any]) -> list[str]:
    """Validate the optional intent block, only when it is present.

    Presence-gated: when the checkpoint has no top-level ``intent`` key this
    returns an empty list and the validator output is byte-identical to before.
    When present, enforces: (1) ``intent`` is an object; (2) ``epic_type`` present
    and in {business, enabler}; (3) ``business_outcome_hypothesis`` is a non-empty
    non-whitespace string; (4) ``leading_indicators`` / ``nfrs``, when present, are
    lists of strings. Uses the established append-one-error-per-invariant, literal
    checkpoint-context-prefixed message idiom and does not mutate input.

    Args:
        state (dict[str, Any]): Parsed checkpoint JSON object.

    Returns:
        list[str]: One error per violated intent invariant; empty when the block
        is absent or fully valid.

    Raises:
        None.

    Side Effects:
        None.
    """
    # Key-gate: an absent intent block leaves output byte-identical to before.
    if "intent" not in state:
        return []
    intent = state.get("intent")
    if not isinstance(intent, dict):
        return ["Epic checkpoint intent must be an object."]
    intent_map = cast("dict[str, Any]", intent)

    errors: list[str] = []
    # epic_type is required-when-block-present and enum-constrained.
    epic_type = intent_map.get("epic_type")
    if epic_type not in _VALID_EPIC_TYPES:
        errors.append(
            "Epic checkpoint intent.epic_type must be 'business' or 'enabler', "
            f"found: {epic_type!r}"
        )

    # business_outcome_hypothesis is required-when-block-present and must carry
    # real content, not whitespace.
    hypothesis = intent_map.get("business_outcome_hypothesis")
    if not isinstance(hypothesis, str) or not hypothesis.strip():
        errors.append(
            "Epic checkpoint intent.business_outcome_hypothesis must be a "
            "non-empty string."
        )

    # leading_indicators and nfrs are optional even within the block, but when
    # present each must be a list whose every element is a string.
    for field_name in ("leading_indicators", "nfrs"):
        if field_name not in intent_map:
            continue
        value = intent_map.get(field_name)
        if not isinstance(value, list) or not all(
            isinstance(item, str) for item in cast("list[Any]", value)
        ):
            errors.append(
                f"Epic checkpoint intent.{field_name} must be a list of strings."
            )
    return errors
