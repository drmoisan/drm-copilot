"""Tests for manifest invariant M8, ``expected_conflict_components``.

This module is a sibling of
``tests/scripts/dev_tools/test_parallel_manifest_contract.py`` for a purely
mechanical reason: that parent module stands at 497 of the repository's 500-line
ceiling and has no headroom for a new invariant's case set. The same rationale
governs ``test_validate_parallel_planner_state_bounds.py``.

Scope: the negative paths for every M8 error class, the positive paths for a
named and an unnamed component in the mandatory block-sequence form, and the
key-absent backward-compatibility case that asserts a byte-identical error list
against a pre-change expectation.

Manifests are built as text and validated through the public entry point, so
each case exercises the same path a real document takes. No temporary file is
created.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools.parallel_manifest_contract import validate_parallel_manifest_text

CONTEXT = "Parallel manifest"

# One well-formed item block per declared key, indented for the items sequence.
ITEM_TEMPLATE = """  - issue_num: {key}
    feature_folder: docs/features/active/alpha-{key}
    kind: feature
    state: proposed
    blast_radius:
      paths:
        - src/alpha{key}.ts
      modules: []
      shared_surfaces: []
      contracts: []
      source: derived
      computed_at: "2026-08-10T00:00:00Z"
"""


def build_manifest(
    assertion_block: str = "", keys: tuple[int, ...] = (101, 102)
) -> str:
    """Return a valid manifest document, optionally carrying an M8 block.

    Args:
        assertion_block (str): Raw YAML for the ``expected_conflict_components``
            key, already indented for the document root. Empty omits the key
            entirely, which is the pre-M8 authoring shape.
        keys (tuple[int, ...]): The ``items[].issue_num`` values to declare.

    Returns:
        str: A complete manifest document whose only possible errors are M8's.
    """

    # Build the item table first so every case shares one known-valid M6 block
    # and any reported error is unambiguously attributable to M8.
    items = "".join(ITEM_TEMPLATE.format(key=key) for key in keys)
    return (
        "---\n"
        "parallel: alpha-run\n"
        "mode: closed\n"
        "max_concurrency: 4\n"
        'created_at: "2026-08-10T00:00:00Z"\n'
        f"items:\n{items}"
        f"{assertion_block}"
        "---\n"
        "\n"
        "# Parallel Run\n"
    )


class TestM8KeyAbsent:
    """The key-gated guarantee: an absent key changes nothing."""

    def test_a_manifest_without_the_key_validates_clean(self) -> None:
        """The pre-M8 authoring shape still produces an empty error list."""

        assert validate_parallel_manifest_text(build_manifest()) == []

    def test_the_error_list_is_byte_identical_to_the_pre_change_expectation(
        self,
    ) -> None:
        """A malformed pre-M8 manifest reports exactly the errors it did before.

        The expectation below is the literal error list the validator produced
        for this document before M8 existed, so any M8 leakage into the
        key-absent path fails this case.
        """

        malformed = (
            "---\n"
            "mode: paused\n"
            "max_concurrency: 33\n"
            "items: []\n"
            "---\n"
            "\n"
            "# Parallel Run\n"
        )

        assert validate_parallel_manifest_text(malformed) == [
            f"{CONTEXT} parallel must be a non-empty string.",
            f"{CONTEXT} mode must be one of closed, open; found: 'paused'.",
            (
                f"{CONTEXT} max_concurrency must be an integer from 1 through 32; "
                "found: 33."
            ),
            f"{CONTEXT} created_at must be a non-empty string.",
        ]


class TestM8ResolutionTargetDegradation:
    """M8's resolution target when the item table is itself malformed.

    Reporting a malformed ``items`` collection is invariant M6's job. M8 must
    contribute no SECOND error for the same defect: it simply resolves nothing
    against a malformed entry, so its members are reported as unresolved rather
    than crashing or double-reporting.
    """

    def test_a_non_list_items_value_leaves_every_member_unresolved(self) -> None:
        """A scalar ``items`` value yields M6's error plus an unresolved member."""

        document = (
            "---\n"
            "parallel: alpha-run\n"
            'created_at: "2026-08-10T00:00:00Z"\n'
            "items: alpha\n"
            "expected_conflict_components:\n"
            "  - members:\n"
            "      - 101\n"
            "---\n"
            "\n"
            "# Parallel Run\n"
        )

        assert validate_parallel_manifest_text(document) == [
            f"{CONTEXT} items must be a list.",
            f"{CONTEXT} expected_conflict_components[0] members[0] does not "
            "resolve to an items[] issue_num; found: 101.",
        ]

    def test_a_non_mapping_item_entry_contributes_no_resolvable_key(self) -> None:
        """A scalar entry inside ``items`` is skipped by M8's resolution scan."""

        document = (
            "---\n"
            "parallel: alpha-run\n"
            'created_at: "2026-08-10T00:00:00Z"\n'
            "items:\n"
            "  - alpha\n"
            "expected_conflict_components:\n"
            "  - members:\n"
            "      - 101\n"
            "---\n"
            "\n"
            "# Parallel Run\n"
        )

        assert validate_parallel_manifest_text(document) == [
            f"{CONTEXT} items[0] must be an object.",
            f"{CONTEXT} expected_conflict_components[0] members[0] does not "
            "resolve to an items[] issue_num; found: 101.",
        ]

    def test_an_item_with_a_malformed_issue_num_contributes_no_resolvable_key(
        self,
    ) -> None:
        """An entry whose primary key is non-positive resolves nothing for M8."""

        document = build_manifest(
            "expected_conflict_components:\n  - members:\n      - 101\n", keys=(102,)
        ).replace("issue_num: 102", "issue_num: 0")

        assert validate_parallel_manifest_text(document) == [
            f"{CONTEXT} items[0] issue_num must be a positive integer; found: 0.",
            f"{CONTEXT} expected_conflict_components[0] members[0] does not "
            "resolve to an items[] issue_num; found: 101.",
        ]


class TestM8PositivePaths:
    """Block-sequence components that satisfy the invariant."""

    def test_a_named_component_validates_clean(self) -> None:
        """A labelled lane in block-sequence form reports nothing."""

        block = (
            "expected_conflict_components:\n"
            "  - name: hooks-lane\n"
            "    members:\n"
            "      - 101\n"
            "      - 102\n"
        )

        assert validate_parallel_manifest_text(build_manifest(block)) == []

    def test_an_unnamed_component_validates_clean(self) -> None:
        """``name`` is optional, so omitting it is not an error."""

        block = (
            "expected_conflict_components:\n"
            "  - members:\n"
            "      - 101\n"
            "      - 102\n"
        )

        assert validate_parallel_manifest_text(build_manifest(block)) == []

    def test_two_disjoint_components_validate_clean(self) -> None:
        """Distinct components may partition the item table."""

        block = (
            "expected_conflict_components:\n"
            "  - name: first\n"
            "    members:\n"
            "      - 101\n"
            "  - name: second\n"
            "    members:\n"
            "      - 102\n"
        )

        assert validate_parallel_manifest_text(build_manifest(block)) == []

    def test_an_empty_component_list_validates_clean(self) -> None:
        """An empty list asserts nothing, which is not itself a violation."""

        assert validate_parallel_manifest_text(build_manifest("")) == []


class TestM8NegativePaths:
    """One case per M8 error class."""

    def test_a_non_list_value_is_rejected(self) -> None:
        """The key must carry a list, not a scalar or mapping."""

        block = "expected_conflict_components: hooks-lane\n"

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components must be a list."
        ]

    def test_a_non_object_entry_is_rejected(self) -> None:
        """Each entry must be a mapping carrying ``members``."""

        block = "expected_conflict_components:\n  - hooks-lane\n"

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] must be an object."
        ]

    def test_a_missing_members_key_is_rejected(self) -> None:
        """``members`` is required even when ``name`` is present."""

        block = "expected_conflict_components:\n  - name: hooks-lane\n"

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] members must be a "
            "non-empty list of positive integers."
        ]

    def test_an_empty_members_list_is_rejected(self) -> None:
        """A component asserting no membership carries no information."""

        block = "expected_conflict_components:\n  - members: []\n"

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] members must be a "
            "non-empty list of positive integers."
        ]

    def test_a_non_list_members_value_is_rejected(self) -> None:
        """A scalar in the ``members`` slot is the same violation as an empty list."""

        block = "expected_conflict_components:\n  - members: 101\n"

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] members must be a "
            "non-empty list of positive integers."
        ]

    @pytest.mark.parametrize(
        ("literal", "rendered"), [("0", "0"), ("-1", "-1"), ("true", "True")]
    )
    def test_a_non_positive_member_is_rejected(
        self, literal: str, rendered: str
    ) -> None:
        """Zero, a negative key, and a boolean are all rejected in the key slot."""

        block = f"expected_conflict_components:\n  - members:\n      - {literal}\n"

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] members[0] must be a "
            f"positive integer; found: {rendered}."
        ]

    @pytest.mark.parametrize(
        ("literal", "rendered"), [('"101"', "'101'"), ("1.5", "1.5")]
    )
    def test_a_non_integer_member_is_rejected(
        self, literal: str, rendered: str
    ) -> None:
        """A string or float in the key slot is not an ``issue_num``."""

        block = f"expected_conflict_components:\n  - members:\n      - {literal}\n"

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] members[0] must be a "
            f"positive integer; found: {rendered}."
        ]

    def test_a_member_resolving_to_no_item_is_rejected(self) -> None:
        """Every asserted key must name a declared ``items[].issue_num``."""

        block = (
            "expected_conflict_components:\n"
            "  - members:\n"
            "      - 101\n"
            "      - 999\n"
        )

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] members[1] does not "
            "resolve to an items[] issue_num; found: 999."
        ]

    def test_duplicate_membership_across_components_is_rejected(self) -> None:
        """One item may belong to at most one asserted component."""

        block = (
            "expected_conflict_components:\n"
            "  - name: first\n"
            "    members:\n"
            "      - 101\n"
            "  - name: second\n"
            "    members:\n"
            "      - 101\n"
            "      - 102\n"
        )

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[1] members[0] repeats "
            "issue_num 101, already claimed by an earlier component."
        ]

    def test_duplicate_membership_within_one_component_is_rejected(self) -> None:
        """A key repeated inside one component is the same violation."""

        block = (
            "expected_conflict_components:\n"
            "  - members:\n"
            "      - 101\n"
            "      - 101\n"
        )

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] members[1] repeats "
            "issue_num 101, already claimed by an earlier component."
        ]

    def test_an_empty_string_name_is_rejected(self) -> None:
        """A present ``name`` must carry an identifier."""

        block = (
            'expected_conflict_components:\n  - name: ""\n    members:\n      - 101\n'
        )

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] name must be a "
            "non-empty string."
        ]

    def test_a_whitespace_only_name_is_rejected(self) -> None:
        """A blank label is as unusable as an empty one."""

        block = (
            "expected_conflict_components:\n"
            '  - name: "   "\n'
            "    members:\n"
            "      - 101\n"
        )

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] name must be a "
            "non-empty string."
        ]

    def test_name_and_member_errors_are_reported_in_field_order(self) -> None:
        """Within one component the name error precedes the member errors."""

        block = 'expected_conflict_components:\n  - name: ""\n    members:\n      - 0\n'

        assert validate_parallel_manifest_text(build_manifest(block)) == [
            f"{CONTEXT} expected_conflict_components[0] name must be a "
            "non-empty string.",
            f"{CONTEXT} expected_conflict_components[0] members[0] must be a "
            "positive integer; found: 0.",
        ]
