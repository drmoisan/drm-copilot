"""Unit tests for the parallel mutation engine's per-operation behavior.

Covers these spec Test Strategy unit scenarios: 5 (the FR2 removal behavior
table, one test per row including both rejection rows), 6 (close gating), and
8 (mutation-log entry shape and per-op nullability against the landed F3 rule).
Scenarios 1, 3, 4, and 7 -- pinning, generation accounting, admission, and the
completion predicate -- live in
``tests/scripts/dev_tools/test_parallel_mutation_protocol.py`` so neither file
exceeds the repository's 500-line limit.

Every fixture is a literal dict keyed by ``int`` item keys, matching F3's
positive-integer ``items[].issue_num`` primary key. The clock is injected as a
fixed callable, so no test reads the wall clock. No test creates a temporary
file, starts a subprocess, or invokes ``git`` or ``gh``.
"""

from __future__ import annotations

from datetime import datetime, timezone

import pytest

from scripts.dev_tools._parallel_mutation_models import (
    CloseWhileInFlightRejectedError,
    InFlightRemovalRequiresDispositionError,
    ItemRecord,
    MergedItemRemovalRejectedError,
    MutationEntry,
    MutationEntryContractError,
    UnknownEnumMemberError,
    UnknownItemError,
)
from scripts.dev_tools.parallel_mutation_protocol import (
    build_add_entry,
    build_close_entry,
    build_remove_entry,
    build_requeue_entry,
    decide_close,
    decide_removal,
)

# The single timestamp every entry in this module records, so a test can assert
# the value came from the injected seam rather than from the wall clock.
FIXED_NOW = datetime(2026, 8, 8, 10, 15, tzinfo=timezone.utc)

# The generation every test starts from.
START_GENERATION = 7

# The seven fields F3 defines on a ``mutations[]`` entry, in schema order.
MUTATION_FIELDS = (
    "op",
    "item_key",
    "at",
    "prior_state",
    "new_state",
    "disposition",
    "recolor_generation",
)


def fixed_clock() -> datetime:
    """Return the module's fixed timestamp.

    Returns:
        datetime: ``FIXED_NOW``, so every constructed entry is deterministic.
    """

    return FIXED_NOW


def valid_entry_kwargs(op: str) -> dict[str, object]:
    """Build a valid ``MutationEntry`` kwargs set for one op.

    Contract-violation tests start from a valid set and override exactly one
    field, so each test breaks one rule and nothing else.

    Args:
        op (str): The F3 ``mutations[].op`` member to build for.

    Returns:
        dict[str, object]: Keyword arguments that construct successfully.
    """

    kwargs: dict[str, object] = {
        "op": op,
        "at": FIXED_NOW,
        "disposition": None,
        "recolor_generation": START_GENERATION,
    }

    # Each op has its own valid null pattern, so the base differs by op. An
    # in-flight remove additionally requires a disposition (F3 invariant 17).
    if op == "close":
        kwargs.update(item_key=None, prior_state=None, new_state=None)
    elif op == "add":
        kwargs.update(item_key=11, prior_state=None, new_state="scheduled")
    elif op == "remove":
        kwargs.update(
            item_key=21,
            prior_state="in_flight",
            new_state="withdrawn",
            disposition="detach",
        )
    else:
        kwargs.update(item_key=21, prior_state="in_flight", new_state="blocked")
    return kwargs


class TestRemovalBehaviorTable:
    """Scenario 5 -- one test per row of the normative FR2 behavior table."""

    @pytest.mark.parametrize(
        "prior_state", ["proposed", "admitted", "prepared", "scheduled"]
    )
    def test_unstarted_removal_withdraws_and_recomputes(self, prior_state: str) -> None:
        """Rows 1-4: an unstarted item is withdrawn and the coloring recomputes."""

        # Arrange
        items = {11: ItemRecord(11, prior_state)}

        # Act
        decision = decide_removal(11, items)

        # Assert
        assert decision.prior_state == prior_state
        assert decision.new_state == "withdrawn"
        assert decision.disposition is None
        assert decision.triggers_recompute is True

    def test_in_flight_removal_without_disposition_is_rejected(self) -> None:
        """Row 5: no default disposition is ever inferred for running work."""

        # Arrange
        items = {21: ItemRecord(21, "in_flight")}

        # Act / Assert
        with pytest.raises(InFlightRemovalRequiresDispositionError) as caught:
            decide_removal(21, items)
        assert caught.value.item_key == 21

    @pytest.mark.parametrize("disposition", ["detach", "abandon"])
    def test_in_flight_removal_with_a_disposition_withdraws_without_recomputing(
        self, disposition: str
    ) -> None:
        """Rows 6-7: both dispositions withdraw the item and change no cohort."""

        # Arrange
        items = {21: ItemRecord(21, "in_flight")}

        # Act
        decision = decide_removal(21, items, disposition)

        # Assert
        assert decision.prior_state == "in_flight"
        assert decision.new_state == "withdrawn"
        assert decision.disposition == disposition
        assert decision.triggers_recompute is False

    def test_merged_removal_is_rejected(self) -> None:
        """Row 8: a merged change is already in ``main`` and cannot be removed."""

        # Arrange
        items = {31: ItemRecord(31, "merged", "merged")}

        # Act / Assert
        with pytest.raises(MergedItemRemovalRejectedError) as caught:
            decide_removal(31, items)
        assert caught.value.item_key == 31

    @pytest.mark.parametrize(
        ("state", "merge_status"),
        [("withdrawn", "not_started"), ("blocked", "blocked_drift")],
    )
    def test_removal_of_a_non_live_item_is_rejected(
        self, state: str, merge_status: str
    ) -> None:
        """Neither a withdrawn nor a blocked item is a live removal target."""

        # Arrange
        items = {41: ItemRecord(41, state, merge_status)}

        # Act / Assert
        with pytest.raises(UnknownItemError):
            decide_removal(41, items)

    def test_removal_of_an_untracked_key_is_rejected(self) -> None:
        """A key resolving to no item fails fast rather than being assumed."""

        with pytest.raises(UnknownItemError) as caught:
            decide_removal(99, {11: ItemRecord(11, "scheduled")})
        assert caught.value.item_key == 99

    def test_in_flight_removal_with_an_unknown_disposition_is_rejected(self) -> None:
        """A disposition outside F3's enum is rejected, never coerced."""

        items = {21: ItemRecord(21, "in_flight")}

        with pytest.raises(UnknownEnumMemberError):
            decide_removal(21, items, "delete")

    def test_a_rejected_removal_produces_no_entry(self) -> None:
        """A rejected removal never yields a decision to build an entry from."""

        # Arrange
        items = {21: ItemRecord(21, "in_flight")}
        entries: list[MutationEntry] = []

        # Act: the rejection prevents the append that would otherwise follow.
        with pytest.raises(InFlightRemovalRequiresDispositionError):
            entries.append(
                build_remove_entry(
                    decide_removal(21, items),
                    current_generation=START_GENERATION,
                    clock=fixed_clock,
                )
            )

        # Assert
        assert entries == []

    def test_decide_removal_does_not_mutate_the_item_mapping(self) -> None:
        """Deciding a removal leaves the caller's item table unchanged."""

        # Arrange
        items = {11: ItemRecord(11, "scheduled")}

        # Act
        decide_removal(11, items)

        # Assert
        assert items == {11: ItemRecord(11, "scheduled")}


class TestCloseGating:
    """Scenario 6 -- close is rejected while any item is in flight."""

    def test_close_is_rejected_while_an_item_is_in_flight(self) -> None:
        """A run with running work cannot be closed."""

        # Arrange
        items = {11: ItemRecord(11, "scheduled"), 21: ItemRecord(21, "in_flight")}

        # Act / Assert
        with pytest.raises(CloseWhileInFlightRejectedError) as caught:
            decide_close(items)
        assert caught.value.in_flight_keys == (21,)

    def test_close_rejection_reports_every_in_flight_key_ascending(self) -> None:
        """All blocking keys are reported at once, in ascending order."""

        # Arrange
        items = {
            33: ItemRecord(33, "in_flight"),
            21: ItemRecord(21, "in_flight"),
            11: ItemRecord(11, "scheduled"),
        }

        # Act / Assert
        with pytest.raises(CloseWhileInFlightRejectedError) as caught:
            decide_close(items)
        assert caught.value.in_flight_keys == (21, 33)

    def test_close_is_permitted_when_no_item_is_in_flight(self) -> None:
        """With nothing running the close proceeds and returns None."""

        # Arrange
        items = {11: ItemRecord(11, "scheduled"), 12: ItemRecord(12, "withdrawn")}

        # Act / Assert
        assert decide_close(items) is None

    def test_close_is_permitted_for_a_run_tracking_no_item(self) -> None:
        """An empty run has nothing in flight, so the close is permitted."""

        assert decide_close({}) is None

    def test_a_rejected_close_produces_no_entry(self) -> None:
        """A rejected close appends nothing and changes no state."""

        # Arrange
        items = {21: ItemRecord(21, "in_flight")}
        entries: list[MutationEntry] = []

        # Act
        with pytest.raises(CloseWhileInFlightRejectedError):
            decide_close(items)
            entries.append(
                build_close_entry(
                    current_generation=START_GENERATION, clock=fixed_clock
                )
            )

        # Assert
        assert entries == []


class TestMutationLogShape:
    """Scenario 8 -- entry shape, injected clock, and per-op nullability."""

    def _entries(self) -> dict[str, MutationEntry]:
        """Build one entry per op case of the spec's per-op table.

        Returns:
            dict[str, MutationEntry]: Each labelled op case, so a test can name
            the case it asserts against.
        """

        in_flight = {21: ItemRecord(21, "in_flight")}
        unstarted = {11: ItemRecord(11, "scheduled")}
        return {
            "add_admit": build_add_entry(
                11,
                deferred=False,
                current_generation=START_GENERATION,
                clock=fixed_clock,
            ),
            "add_deferred": build_add_entry(
                11,
                deferred=True,
                current_generation=START_GENERATION,
                clock=fixed_clock,
            ),
            "remove_unstarted": build_remove_entry(
                decide_removal(11, unstarted),
                current_generation=START_GENERATION,
                clock=fixed_clock,
            ),
            "remove_detach": build_remove_entry(
                decide_removal(21, in_flight, "detach"),
                current_generation=START_GENERATION,
                clock=fixed_clock,
            ),
            "remove_abandon": build_remove_entry(
                decide_removal(21, in_flight, "abandon"),
                current_generation=START_GENERATION,
                clock=fixed_clock,
            ),
            "close": build_close_entry(
                current_generation=START_GENERATION, clock=fixed_clock
            ),
            "requeue": build_requeue_entry(
                21, current_generation=START_GENERATION, clock=fixed_clock
            ),
        }

    def test_every_op_case_yields_exactly_the_seven_f3_fields(self) -> None:
        """No field is added to or missing from any constructed entry."""

        # Arrange / Act
        entries = self._entries()

        # Assert: every case exposes exactly the seven schema fields.
        for label, entry in entries.items():
            fields = tuple(entry.__dataclass_fields__)
            assert fields == MUTATION_FIELDS, f"{label} field set drifted"

    def test_every_entry_takes_its_timestamp_from_the_injected_clock(self) -> None:
        """No constructor reads the wall clock."""

        for label, entry in self._entries().items():
            assert entry.at == FIXED_NOW, f"{label} did not use the injected clock"

    @pytest.mark.parametrize("label", ["add_admit", "add_deferred"])
    def test_both_add_cases_carry_null_prior_state_and_scheduled_new_state(
        self, label: str
    ) -> None:
        """The landed F3 rule: ``prior_state`` is null for ``add``."""

        # Arrange / Act
        entry = self._entries()[label]

        # Assert
        assert entry.op == "add"
        assert entry.prior_state is None
        assert entry.new_state == "scheduled"
        assert entry.disposition is None
        assert entry.item_key == 11

    def test_close_carries_null_key_prior_state_and_new_state(self) -> None:
        """A close is run-scoped, so it names no item and records no transition."""

        entry = self._entries()["close"]

        assert entry.op == "close"
        assert entry.item_key is None
        assert entry.prior_state is None
        assert entry.new_state is None
        assert entry.disposition is None

    def test_remove_carries_non_null_prior_and_new_state(self) -> None:
        """A removal records the transition it applied."""

        entry = self._entries()["remove_unstarted"]

        assert entry.op == "remove"
        assert entry.prior_state == "scheduled"
        assert entry.new_state == "withdrawn"
        assert entry.disposition is None

    def test_requeue_carries_non_null_prior_and_new_state(self) -> None:
        """A drift requeue moves the item from ``in_flight`` to ``blocked``."""

        entry = self._entries()["requeue"]

        assert entry.op == "requeue"
        assert entry.prior_state == "in_flight"
        assert entry.new_state == "blocked"
        assert entry.disposition is None

    @pytest.mark.parametrize(
        ("label", "disposition"),
        [("remove_detach", "detach"), ("remove_abandon", "abandon")],
    )
    def test_in_flight_removal_records_its_disposition(
        self, label: str, disposition: str
    ) -> None:
        """Only an in-flight removal carries a disposition, per F3 invariant 17."""

        entry = self._entries()[label]

        assert entry.prior_state == "in_flight"
        assert entry.disposition == disposition

    def test_a_successful_op_appends_exactly_one_entry(self) -> None:
        """Each accepted operation contributes one record, never two."""

        # Arrange
        log: list[MutationEntry] = []

        # Act: three accepted ops.
        log.append(
            build_add_entry(
                11,
                deferred=False,
                current_generation=START_GENERATION,
                clock=fixed_clock,
            )
        )
        log.append(
            build_requeue_entry(
                21, current_generation=START_GENERATION, clock=fixed_clock
            )
        )
        log.append(
            build_close_entry(current_generation=START_GENERATION, clock=fixed_clock)
        )

        # Assert
        assert len(log) == 3

    @pytest.mark.parametrize(
        ("op", "overrides", "expected_field"),
        [
            # The landed F3 rule: ``prior_state`` must be null for ``add``.
            ("add", {"prior_state": "prepared"}, "prior_state"),
            # F3 invariant 17: a disposition only on an in-flight removal.
            ("add", {"disposition": "detach"}, "disposition"),
            # A run-scoped close cannot name an item.
            ("close", {"item_key": 11}, "item_key"),
            # A close must record no transition.
            ("close", {"new_state": "withdrawn"}, "new_state"),
            # The ``op`` vocabulary is F3's and is not extended.
            ("close", {"op": "rename"}, "op"),
            # The generation counter is a non-negative integer.
            ("close", {"recolor_generation": -1}, "recolor_generation"),
            # Every item-scoped op requires a resolving key.
            ("add", {"item_key": None}, "item_key"),
            ("requeue", {"item_key": 0}, "item_key"),
            # An in-flight removal's disposition must be an F3 member.
            ("remove", {"disposition": "delete"}, "disposition"),
            ("remove", {"disposition": None}, "disposition"),
        ],
    )
    def test_an_entry_violating_the_f3_contract_is_rejected(
        self, op: str, overrides: dict[str, object], expected_field: str
    ) -> None:
        """Each F3 contract rule is enforced at construction, naming its field."""

        # Arrange: start from a valid entry for the op, then break one rule.
        kwargs = valid_entry_kwargs(op)
        kwargs.update(overrides)

        # Act / Assert
        with pytest.raises(MutationEntryContractError) as caught:
            MutationEntry(**kwargs)  # pyright: ignore[reportArgumentType]
        assert caught.value.field_name == expected_field

    @pytest.mark.parametrize("field_name", ["prior_state", "new_state"])
    def test_a_state_outside_the_item_state_enum_is_rejected(
        self, field_name: str
    ) -> None:
        """A non-member state cannot reach a mutation entry on either field."""

        # Arrange
        kwargs = valid_entry_kwargs("requeue")
        kwargs[field_name] = "paused"

        # Act / Assert
        with pytest.raises(UnknownEnumMemberError):
            MutationEntry(**kwargs)  # pyright: ignore[reportArgumentType]
