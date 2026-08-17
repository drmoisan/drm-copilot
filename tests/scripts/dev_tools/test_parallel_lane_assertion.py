"""Unit tests for the advisory lane-assertion diagnostic (issue #479, D3).

Covers connected-component derivation (isolated vertices, chains, cliques, the
13-lane transpose of 69 items), all four report classes, the report renderer,
the manifest readers, the edge parser, and the CLI entry point.

The 13-lane transpose is the motivating scale: 13 thematic lanes over 69 issues,
items within a lane mutually conflicting and lanes mutually disjoint. Derivation
must report exactly 13 components and confirm the asserted grouping with no
disagreement, which is the outcome that makes the surface usable at that scale.

No test creates a temporary file. The CLI happy path reads the checked-in
fixture manifest at ``tests/fixtures/parallel_manifest_payload/parallel.md``;
the failure paths use a path that does not exist and an existing non-manifest
file, so neither writes to the filesystem either.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools.parallel_lane_assertion import (
    EXPECTED_APART_DERIVED_TOGETHER,
    EXPECTED_TOGETHER_DERIVED_APART,
    ITEM_COVERED_BY_NO_COMPONENT,
    MEMBER_NAMES_NO_ITEM,
    ExpectedComponent,
    LaneAssertionFinding,
    LaneAssertionReport,
    build_parser,
    compare,
    derive_components,
    format_report,
    main,
    parse_edges,
    read_manifest_inputs,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_MANIFEST = REPO_ROOT / "tests/fixtures/parallel_manifest_payload/parallel.md"
NON_MANIFEST_FILE = REPO_ROOT / "pyproject.toml"
MISSING_MANIFEST = REPO_ROOT / "tests/fixtures/parallel_manifest_payload/absent.md"

# The motivating scale: 13 lanes covering 69 items. Four lanes carry six items
# and nine carry five, which is 4*6 + 9*5 = 69.
LANE_COUNT = 13
LANE_SIZES = tuple(6 if lane < 4 else 5 for lane in range(LANE_COUNT))


def lane_keys(lane: int) -> list[int]:
    """Return the item keys of one transpose lane, ascending."""

    return [100 + lane * 10 + offset for offset in range(LANE_SIZES[lane])]


def transpose_inputs() -> (
    tuple[list[int], list[tuple[int, int]], list[ExpectedComponent]]
):
    """Build the 13-lane transpose: keys, intra-lane cliques, and assertions."""

    keys: list[int] = []
    edges: list[tuple[int, int]] = []
    expected: list[ExpectedComponent] = []
    # Each lane is a clique, so its items are mutually conflicting; lanes share
    # no edge, so each lane is exactly one connected component.
    for lane in range(LANE_COUNT):
        members = lane_keys(lane)
        keys.extend(members)
        for first_index, first in enumerate(members):
            edges.extend((first, second) for second in members[first_index + 1 :])
        expected.append(ExpectedComponent(name=f"lane-{lane}", members=tuple(members)))
    return keys, edges, expected


class TestDeriveComponents:
    """Connected-component derivation over the normalized conflict graph."""

    def test_empty_input_yields_no_components(self) -> None:
        """A graph with no vertices has no components."""

        assert derive_components([], []) == ()

    def test_isolated_vertices_each_form_their_own_component(self) -> None:
        """A vertex in no edge is a single-member component, not dropped."""

        assert derive_components([30, 10, 20], []) == ((10,), (20,), (30,))

    def test_a_chain_is_one_component(self) -> None:
        """Transitive connectivity merges a chain into one component."""

        assert derive_components([1, 2, 3, 4], [(1, 2), (2, 3), (3, 4)]) == (
            (1, 2, 3, 4),
        )

    def test_two_disjoint_groups_are_two_components(self) -> None:
        """Groups sharing no edge stay separate and are ordered by lowest key."""

        components = derive_components([5, 6, 7, 8], [(7, 8), (5, 6)])

        assert components == ((5, 6), (7, 8))

    def test_edge_direction_and_repetition_are_normalized_away(self) -> None:
        """Reversed and duplicated edges collapse to the same component set."""

        assert derive_components([1, 2], [(2, 1), (1, 2), (2, 1)]) == ((1, 2),)

    def test_a_self_loop_is_skipped(self) -> None:
        """A self-conflicting key stays a single-member component."""

        assert derive_components([1, 2], [(1, 1)]) == ((1,), (2,))

    def test_an_edge_naming_an_unknown_vertex_is_skipped(self) -> None:
        """A diagnostic degrades on partial input rather than raising."""

        assert derive_components([1, 2], [(1, 99), (99, 2)]) == ((1,), (2,))

    def test_the_thirteen_lane_transpose_yields_thirteen_components(self) -> None:
        """69 items across 13 mutually disjoint lanes derive as 13 components."""

        keys, edges, _ = transpose_inputs()

        components = derive_components(keys, edges)

        assert len(keys) == 69
        assert len(components) == LANE_COUNT
        assert sorted(key for members in components for key in members) == sorted(keys)


class TestReportClasses:
    """The four report classes produced by ``compare``."""

    def test_a_matching_assertion_produces_no_findings(self) -> None:
        """Full agreement between assertion and derivation reports nothing."""

        report = compare(
            [ExpectedComponent(name="a", members=(1, 2))], [1, 2], [(1, 2)]
        )

        assert report.findings == ()
        assert report.disagreement_count == 0

    def test_the_transpose_assertion_is_confirmed_with_no_disagreement(self) -> None:
        """All 13 asserted lanes are confirmed against the derived components."""

        keys, edges, expected = transpose_inputs()

        report = compare(expected, keys, edges)

        assert len(report.derived_components) == LANE_COUNT
        assert report.findings == ()

    def test_expected_together_but_derived_apart_is_reported(self) -> None:
        """One lane whose members landed in two components reports once."""

        report = compare([ExpectedComponent(name="split", members=(1, 2))], [1, 2], [])

        assert [f.kind for f in report.findings] == [EXPECTED_TOGETHER_DERIVED_APART]
        assert report.findings[0].members == (1, 2)
        assert "'split'" in report.findings[0].detail

    def test_expected_apart_but_derived_together_is_reported(self) -> None:
        """One derived component spanning two asserted lanes reports once."""

        report = compare(
            [
                ExpectedComponent(name="left", members=(1,)),
                ExpectedComponent(name="right", members=(2,)),
            ],
            [1, 2],
            [(1, 2)],
        )

        assert [f.kind for f in report.findings] == [EXPECTED_APART_DERIVED_TOGETHER]
        assert report.findings[0].members == (1, 2)

    def test_a_member_naming_no_manifest_item_is_reported(self) -> None:
        """An asserted member outside the item table is an authoring error."""

        report = compare([ExpectedComponent(name=None, members=(1, 999))], [1], [])

        kinds = [f.kind for f in report.findings]
        assert MEMBER_NAMES_NO_ITEM in kinds
        assert EXPECTED_TOGETHER_DERIVED_APART not in kinds

    def test_an_uncovered_item_is_reported_informationally(self) -> None:
        """An item the assertion never mentions is informational, not a disagreement."""

        report = compare([ExpectedComponent(name="a", members=(1,))], [1, 2], [])

        assert [f.kind for f in report.findings] == [ITEM_COVERED_BY_NO_COMPONENT]
        assert report.disagreement_count == 0

    def test_an_absent_assertion_reports_only_uncovered_items(self) -> None:
        """With no assertion at all every item is reported informationally."""

        report = compare([], [1, 2], [(1, 2)])

        assert {f.kind for f in report.findings} == {ITEM_COVERED_BY_NO_COMPONENT}


class TestValueObjects:
    """The frozen value objects carrying the assertion and the report."""

    def test_a_named_component_labels_itself_by_name(self) -> None:
        """A declared name is used verbatim, quoted."""

        assert ExpectedComponent(name="hooks", members=(1,)).label(4) == "'hooks'"

    def test_an_unnamed_component_labels_itself_by_position(self) -> None:
        """Without a name the manifest position identifies the component."""

        assert ExpectedComponent(name=None, members=(1,)).label(4) == "component[4]"

    def test_disagreement_count_excludes_the_informational_class(self) -> None:
        """Only the three real disagreement classes are counted."""

        report = LaneAssertionReport(
            derived_components=((1,), (2,)),
            findings=(
                LaneAssertionFinding(MEMBER_NAMES_NO_ITEM, "unknown", (9,)),
                LaneAssertionFinding(ITEM_COVERED_BY_NO_COMPONENT, "uncovered", (2,)),
            ),
        )

        assert report.disagreement_count == 1


class TestFormatReport:
    """Rendering of the advisory report text."""

    def test_the_header_and_advisory_footer_are_always_present(self) -> None:
        """Even a clean report states the component count and the disclaimer."""

        text = format_report(compare([], [1], []))

        assert text.startswith("Lane assertion: 1 derived conflict component(s);")
        assert "never influences scheduling." in text.splitlines()[-1]

    def test_each_finding_renders_one_advisory_line(self) -> None:
        """Every finding contributes exactly one ADVISORY-prefixed line."""

        report = compare([ExpectedComponent(name="s", members=(1, 2))], [1, 2], [])

        lines = [
            line
            for line in format_report(report).splitlines()
            if line.startswith("ADVISORY")
        ]

        assert len(lines) == len(report.findings)
        assert f"[{EXPECTED_TOGETHER_DERIVED_APART}]" in lines[0]


class TestReadManifestInputs:
    """Defensive reading of the manifest mapping."""

    def test_an_absent_key_yields_no_components(self) -> None:
        """A manifest without the assertion reads as an empty assertion."""

        assert read_manifest_inputs({}) == ([], [])

    def test_a_non_list_assertion_is_ignored(self) -> None:
        """Shape enforcement is M8's; the reader only avoids crashing."""

        assert read_manifest_inputs({"expected_conflict_components": "x"})[0] == []

    @pytest.mark.parametrize("entry", ["not-a-mapping", 5, None])
    def test_a_non_mapping_component_entry_is_skipped(self, entry: object) -> None:
        """A malformed entry contributes no component."""

        mapping: dict[str, object] = {"expected_conflict_components": [entry]}

        assert read_manifest_inputs(mapping)[0] == []

    def test_a_component_without_a_members_list_is_skipped(self) -> None:
        """``members`` must be a list for the entry to be readable."""

        mapping: dict[str, object] = {
            "expected_conflict_components": [{"name": "a", "members": 5}]
        }

        assert read_manifest_inputs(mapping)[0] == []

    def test_a_non_string_name_reads_as_unnamed(self) -> None:
        """A malformed label degrades to the positional label."""

        mapping: dict[str, object] = {
            "expected_conflict_components": [{"name": 7, "members": [1]}]
        }

        assert read_manifest_inputs(mapping)[0] == [
            ExpectedComponent(name=None, members=(1,))
        ]

    @pytest.mark.parametrize("member", [0, -1, True, "1", 1.5, None])
    def test_a_non_positive_integer_member_is_dropped(self, member: object) -> None:
        """Only genuine positive integers survive into the typed component."""

        mapping: dict[str, object] = {
            "expected_conflict_components": [{"members": [member, 4]}]
        }

        assert read_manifest_inputs(mapping)[0][0].members == (4,)

    def test_item_keys_are_read_ascending_and_deduplicated(self) -> None:
        """Well-formed primary keys are collected; malformed entries are not."""

        mapping: dict[str, object] = {
            "items": [
                {"issue_num": 20},
                {"issue_num": 10},
                {"issue_num": 10},
                {"issue_num": True},
                {"issue_num": 0},
                {"no_key": 1},
                "not-a-mapping",
            ]
        }

        assert read_manifest_inputs(mapping)[1] == [10, 20]

    def test_a_non_list_items_value_yields_no_keys(self) -> None:
        """A malformed ``items`` collection is M6's to report, not this reader's."""

        assert read_manifest_inputs({"items": "x"})[1] == []


class TestParseEdges:
    """The ``<a>:<b>`` edge-list parser."""

    def test_an_empty_string_yields_no_edges(self) -> None:
        """An absent edge list is an empty graph, not an error."""

        assert parse_edges("   ") == []

    def test_well_formed_tokens_parse_in_input_order(self) -> None:
        """Each token becomes one integer pair."""

        assert parse_edges("1:2 30:40") == [(1, 2), (30, 40)]

    def test_a_token_without_a_separator_is_dropped(self) -> None:
        """A malformed token does not abort the remaining findings."""

        assert parse_edges("12 3:4") == [(3, 4)]

    def test_a_non_integer_token_is_dropped(self) -> None:
        """A non-numeric endpoint is skipped rather than raised."""

        assert parse_edges("a:b 5:6") == [(5, 6)]


class TestCommandLineEntry:
    """The thin argparse entry point, the module's only I/O boundary."""

    def test_the_parser_requires_a_manifest_and_defaults_the_edges(self) -> None:
        """``--edges`` is optional and defaults to the empty edge list."""

        args = build_parser().parse_args(["--manifest", "m.md"])

        assert args.manifest == "m.md"
        assert args.edges == ""

    def test_an_unreadable_manifest_reports_and_still_exits_zero(
        self, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """A missing file is advisory output, never a non-zero exit."""

        code = main(["--manifest", str(MISSING_MANIFEST)])

        assert code == 0
        assert "manifest unreadable" in capsys.readouterr().out

    def test_an_unparseable_manifest_reports_and_still_exits_zero(
        self, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """A file with no frontmatter fence is reported, not raised."""

        code = main(["--manifest", str(NON_MANIFEST_FILE)])

        assert code == 0
        assert "manifest unparseable" in capsys.readouterr().out

    def test_the_checked_in_fixture_manifest_produces_an_advisory_report(
        self, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """The happy path renders the report and exits 0.

        The fixture declares two items and no assertion, so both items are
        reported informationally and the run reports zero disagreements.
        """

        code = main(["--manifest", str(FIXTURE_MANIFEST), "--edges", "101:202"])

        out = capsys.readouterr().out
        assert code == 0
        assert (
            "Lane assertion: 1 derived conflict component(s); 0 disagreement(s)." in out
        )
        assert out.count(f"ADVISORY [{ITEM_COVERED_BY_NO_COMPONENT}]") == 2
