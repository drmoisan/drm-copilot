"""Validate receipt-bound mutations through the canonical decision authorities.

Purpose:
    Replay persisted remove and close decisions and bind confirmed in-flight
    removals to their durable receipt records.

Responsibilities and usage:
    Translate readable checkpoint records into mutation-authority inputs,
    preserve the authorities' existing decisions, and return stable additive
    diagnostics. The public validator is called after base checkpoint shape
    validation and does not duplicate schema ownership.

High-level flow and invariants:
    Normalize mutations, replay their decisions in persisted order, validate
    receipt shape, and bind each confirmed detach or abandon to its item,
    worktree identity, disposition, and confirmation token. Malformed shapes
    stay non-throwing because their owning base validator reports them.

Raises and side effects:
    None. Every function is pure, performs no I/O, and does not mutate input.
    Individual docstrings therefore omit duplicate Raises and Side Effects
    sections.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from scripts.dev_tools._parallel_mutation_models import (
    CloseWhileInFlightRejectedError,
    InFlightRemovalRequiresDispositionError,
    ItemRecord,
    MergedItemRemovalRejectedError,
    ParallelMutationError,
)
from scripts.dev_tools._parallel_state_common import is_positive_integer
from scripts.dev_tools.parallel_mutation_protocol import decide_close, decide_removal

if TYPE_CHECKING:
    from collections.abc import Mapping

MUTATION_RECEIPTS_KEY = "mutation_receipts"
REMOVE_OPERATION = "remove"
CLOSE_OPERATION = "close"
CONFIRMED_DISPOSITIONS = frozenset({"detach", "abandon"})


def _mapping_entries(value: object) -> list[dict[str, object]]:
    """Extract object-shaped list entries in persisted order.

    Args:
        value (object): Candidate deserialized list.

    Returns:
        list[dict[str, object]]: Mapping entries only; malformed entries are
        excluded because the base validator owns their diagnostics.
    """

    if not isinstance(value, list):
        return []
    # Preserve mutation order while retaining only records this gate can inspect.
    return [
        cast("dict[str, object]", entry)
        for entry in cast("list[object]", value)
        if isinstance(entry, dict)
    ]


def _item_records(state: Mapping[str, object]) -> dict[int, dict[str, object]]:
    """Index the first readable checkpoint item for each positive key.

    Args:
        state (Mapping[str, object]): Parsed parallel checkpoint.

    Returns:
        dict[int, dict[str, object]]: First readable item keyed by issue number.
    """

    records: dict[int, dict[str, object]] = {}
    # Retain first ownership so malformed duplicate items cannot rewrite bindings.
    for entry in _mapping_entries(state.get("items")):
        key = entry.get("issue_num")
        if is_positive_integer(key):
            records.setdefault(cast("int", key), entry)
    return records


def _authority_item(record: Mapping[str, object]) -> ItemRecord | None:
    """Translate a readable checkpoint item into the authority model.

    Args:
        record (Mapping[str, object]): Persisted item mapping.

    Returns:
        ItemRecord | None: Authority input, or None when the base shape is
        unreadable or rejected by the mutation model.
    """

    key = record.get("issue_num")
    state = record.get("state")
    merge_status = record.get("merge_status", "not_started")
    # The authority requires all three identity and lifecycle inputs to be readable.
    if (
        not is_positive_integer(key)
        or not isinstance(state, str)
        or not isinstance(merge_status, str)
    ):
        return None
    # Model construction remains authoritative for lifecycle combinations.
    try:
        return ItemRecord(cast("int", key), state, merge_status)
    except ParallelMutationError:
        return None


def _current_authority_items(
    records: Mapping[int, Mapping[str, object]],
) -> dict[int, ItemRecord]:
    """Build the readable current item table consumed by close authority.

    Args:
        records (Mapping[int, Mapping[str, object]]): Indexed checkpoint items.

    Returns:
        dict[int, ItemRecord]: Authority-compatible records keyed by issue.
    """

    result: dict[int, ItemRecord] = {}
    # Exclude unreadable records because their shape diagnostics already exist.
    for key, record in records.items():
        authority_record = _authority_item(record)
        if authority_record is not None:
            result[key] = authority_record
    return result


def _prior_authority_item(
    item_key: int, prior_state: object
) -> dict[int, ItemRecord] | None:
    """Reconstruct the pre-remove authority table for one item.

    Args:
        item_key (int): Positive issue identity being removed.
        prior_state (object): Persisted lifecycle state before removal.

    Returns:
        dict[int, ItemRecord] | None: One-item authority table, or None when
        prior state cannot be replayed safely.
    """

    if not isinstance(prior_state, str):
        return None
    # Map each readable prior state to the merge status the authority would see.
    merge_status_by_state = {
        "proposed": "not_started",
        "admitted": "not_started",
        "prepared": "not_started",
        "scheduled": "not_started",
        "in_flight": "pr_open",
        "merged": "merged",
    }
    merge_status = merge_status_by_state.get(prior_state)
    if merge_status is None:
        return None
    # Leave lifecycle validity to the canonical mutation model.
    try:
        return {item_key: ItemRecord(item_key, prior_state, merge_status)}
    except ParallelMutationError:
        return None


def _decision_errors(
    state: Mapping[str, object],
    mutations: list[dict[str, object]],
    context: str,
) -> list[str]:
    """Replay persisted remove and close decisions through Python authorities.

    Args:
        state (Mapping[str, object]): Parsed parallel checkpoint.
        mutations (list[dict[str, object]]): Readable persisted mutations.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Ordered authority and recolor-generation diagnostics.
    """

    errors: list[str] = []
    current_items = _current_authority_items(_item_records(state))
    preceding_generation = 0
    # Replay in persistence order because generation preservation is sequential.
    for position, mutation in enumerate(mutations):
        scoped = f"{context} mutations[{position}]"
        op = mutation.get("op")
        generation = mutation.get("recolor_generation")
        # Route only close and remove operations through their owning authorities.
        if op == CLOSE_OPERATION:
            try:
                decide_close(current_items)
            except CloseWhileInFlightRejectedError as error:
                errors.append(f"{scoped} {str(error).partition(': ')[2]}")
        elif op == REMOVE_OPERATION:
            item_key = mutation.get("item_key")
            if not is_positive_integer(item_key):
                continue
            key = cast("int", item_key)
            authority_items = _prior_authority_item(key, mutation.get("prior_state"))
            if authority_items is None:
                continue
            disposition = mutation.get("disposition")
            if disposition is not None and not isinstance(disposition, str):
                continue
            # Replay the removal and translate only contract-relevant outcomes.
            try:
                decision = decide_removal(key, authority_items, disposition)
            except MergedItemRemovalRejectedError:
                errors.append(
                    f"{scoped} cannot remove item {key} from prior_state 'merged'."
                )
            except InFlightRemovalRequiresDispositionError:
                pass
            else:
                # In-flight removal does not recolor remaining work by contract.
                if (
                    not decision.triggers_recompute
                    and isinstance(generation, int)
                    and not isinstance(generation, bool)
                    and generation != preceding_generation
                ):
                    errors.append(
                        f"{scoped} in-flight remove must preserve "
                        f"recolor_generation {preceding_generation}; found: "
                        f"{generation}."
                    )
        # Advance the running generation only from genuine persisted integers.
        if isinstance(generation, int) and not isinstance(generation, bool):
            preceding_generation = max(preceding_generation, generation)
    return errors


def _receipt_field_error(context: str, position: int, detail: str) -> str:
    """Render one stable receipt-bound mutation diagnostic.

    Args:
        context (str): Caller-provided checkpoint label.
        position (int): Zero-based receipt position.
        detail (str): Specific violated binding requirement.

    Returns:
        str: Stable diagnostic prefixed with its receipt location.
    """

    return f"{context} mutation_receipts[{position}] {detail}"


def _validate_receipt_shape(
    receipt: Mapping[str, object], position: int, context: str
) -> list[str]:
    """Require the complete additive receipt-reference field set.

    Args:
        receipt (Mapping[str, object]): Persisted mutation receipt.
        position (int): Zero-based receipt position.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Ordered missing-field and receipt-path diagnostics.
    """

    fields = (
        "mutation_index",
        "receipt_path",
        "operation",
        "item_key",
        "worktree_identity",
        "confirmation_token",
    )
    errors: list[str] = []
    # Report every absent binding field so one run exposes the complete deficit.
    for field in fields:
        if field not in receipt:
            errors.append(
                _receipt_field_error(context, position, f"is missing field: {field}.")
            )
    # A present path must still identify a durable non-blank artifact.
    path = receipt.get("receipt_path")
    if "receipt_path" in receipt and (not isinstance(path, str) or not path.strip()):
        errors.append(
            _receipt_field_error(
                context, position, "receipt_path must be a non-empty string."
            )
        )
    return errors


def _receipt_binding_errors(
    state: Mapping[str, object],
    mutations: list[dict[str, object]],
    context: str,
) -> list[str]:
    """Bind every confirmed in-flight removal to its durable receipt tuple.

    Args:
        state (Mapping[str, object]): Parsed parallel checkpoint.
        mutations (list[dict[str, object]]): Readable persisted mutations.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Ordered receipt-shape and exact-binding diagnostics.
    """

    receipts_value = state.get(MUTATION_RECEIPTS_KEY)
    # Absence preserves legacy checkpoints; presence activates additive validation.
    if MUTATION_RECEIPTS_KEY not in state:
        return []
    if not isinstance(receipts_value, list):
        return [f"{context} mutation_receipts must be a list."]
    receipts = _mapping_entries(cast("object", receipts_value))
    errors: list[str] = []
    # Validate each receipt shape before relying on its binding fields.
    for position, receipt in enumerate(receipts):
        errors.extend(_validate_receipt_shape(receipt, position, context))

    items = _item_records(state)
    by_mutation_index: dict[int, tuple[int, dict[str, object]]] = {}
    # Keep the first receipt per mutation so duplicates cannot replace ownership.
    for position, receipt in enumerate(receipts):
        index = receipt.get("mutation_index")
        if isinstance(index, int) and not isinstance(index, bool) and index >= 0:
            by_mutation_index.setdefault(index, (position, receipt))

    # Require receipts only for confirmed detach/abandon of in-flight work.
    for mutation_index, mutation in enumerate(mutations):
        if (
            mutation.get("op") != REMOVE_OPERATION
            or mutation.get("prior_state") != "in_flight"
            or mutation.get("disposition") not in CONFIRMED_DISPOSITIONS
        ):
            continue
        item_key = mutation.get("item_key")
        disposition = cast("str", mutation.get("disposition"))
        if not is_positive_integer(item_key):
            continue
        key = cast("int", item_key)
        binding = by_mutation_index.get(mutation_index)
        # Report an absent binding before attempting field-level comparisons.
        if binding is None:
            errors.append(
                f"{context} mutations[{mutation_index}] {disposition} removal of "
                f"item {key} requires one matching mutation_receipts[] entry."
            )
            continue
        # Compare the durable tuple to the exact mutation and owning item.
        receipt_position, receipt = binding
        item = items.get(key)
        expected_worktree = item.get("worktree_identity") if item is not None else None
        if receipt.get("operation") != disposition:
            errors.append(
                _receipt_field_error(
                    context,
                    receipt_position,
                    f"operation must match disposition {disposition!r}; found: "
                    f"{receipt.get('operation')!r}.",
                )
            )
        if receipt.get("item_key") != key:
            errors.append(
                _receipt_field_error(
                    context,
                    receipt_position,
                    f"item_key must match mutation item {key}; found: "
                    f"{receipt.get('item_key')!r}.",
                )
            )
        if receipt.get("worktree_identity") != expected_worktree:
            errors.append(
                _receipt_field_error(
                    context,
                    receipt_position,
                    f"worktree_identity must match item {key}; found: "
                    f"{receipt.get('worktree_identity')!r}.",
                )
            )
        expected_token = f"confirm:{disposition}:{key}:{expected_worktree}"
        if receipt.get("confirmation_token") != expected_token:
            errors.append(
                _receipt_field_error(
                    context,
                    receipt_position,
                    f"token must equal {expected_token!r}; found: "
                    f"{receipt.get('confirmation_token')!r}.",
                )
            )
    return errors


def _validate_mutation_state_parts(
    state: Mapping[str, object],
    mutations: list[dict[str, object]],
    context: str,
) -> list[str]:
    """Validate already-normalized mutation decisions and receipt bindings.

    This seam lets tests isolate additive behavior after base list-shape parsing.

    Args:
        state (Mapping[str, object]): Parsed parallel checkpoint.
        mutations (list[dict[str, object]]): Readable persisted mutations.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Decision diagnostics followed by receipt diagnostics.
    """

    # Preserve the established diagnostic order across the two validation layers.
    return [
        *_decision_errors(state, mutations, context),
        *_receipt_binding_errors(state, mutations, context),
    ]


def validate_receipt_bound_mutation_state(
    state: Mapping[str, object], context: str
) -> list[str]:
    """Validate mutation decisions and additive confirmation receipts.

    Args:
        state (Mapping[str, object]): Parsed parallel checkpoint.
        context (str): Caller-provided checkpoint label.

    Returns:
        list[str]: Ordered diagnostics, or an empty list when mutations are not
        list-shaped and therefore remain owned by the base validator.
    """

    mutations_value = state.get("mutations")
    if not isinstance(mutations_value, list):
        return []
    mutations = _mapping_entries(cast("object", mutations_value))
    return _validate_mutation_state_parts(state, mutations, context)


__all__ = ["validate_receipt_bound_mutation_state"]
