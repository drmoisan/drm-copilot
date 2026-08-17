"""Compare a manifest's asserted lane grouping against the derived components.

Purpose:
    Answer one question for a parallel-run planner: did the hand-authored lane
    grouping in the manifest's optional ``expected_conflict_components`` key
    (invariant M8) survive blast-radius derivation? The module derives the
    connected components of the DERIVED conflict graph and reports every
    disagreement with the asserted grouping, in four classes.

Responsibilities and boundaries:
    This module is a DIAGNOSTIC. It never overrides a derived conflict edge,
    never feeds ``compute_cohorts``, and never influences scheduling. It is
    imported by no cohort-computation, validation, or mutation module, and
    writes no artifact. Every finding is advisory: the CLI reports and exits 0
    whether or not findings were produced, so a mismatch can never block a
    planning run. The asserted grouping is an ASSERTION, not a declaration -- a
    disagreement is a signal to re-examine the blast radii, never a licence to
    edit the graph, and narrowing a radius to suppress an edge stays prohibited.

Flow:
    Normalize the derived edge list into symmetric adjacency (the same
    normalization ``scripts/dev_tools/parallel_cohort_computation.py`` performs
    internally: direction-insensitive, duplicate-collapsing, every declared key
    seeded so an isolated vertex survives), walk it breadth-first for the
    connected components, then compare against the asserted grouping.

Key invariants:
    Item keys are ``int`` throughout -- F3's ``items[].issue_num``. The derived
    components partition the declared keys: every key appears in exactly one,
    and a key in no edge is its own single-member component. Components are
    ordered by lowest member and members sorted ascending, so the report is a
    function of the graph alone.

Raises and side effects (module-wide contract):
    Every function and method below EXCEPT ``main`` is pure: it raises nothing,
    performs no I/O, and reads but never mutates its arguments. Individual
    docstrings therefore omit ``Raises``/``Side Effects``; only ``main``, the
    module's single I/O boundary, documents its own.
"""

from __future__ import annotations

import argparse
import sys
from collections import deque
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, TypeGuard, cast

from scripts.dev_tools.parallel_manifest_contract import parse_manifest_frontmatter

if TYPE_CHECKING:
    from collections.abc import Iterable, Sequence

# The four report classes. Each is a stable token so a consumer can group
# findings without parsing the human-readable detail text.
EXPECTED_TOGETHER_DERIVED_APART = "expected_together_derived_apart"
EXPECTED_APART_DERIVED_TOGETHER = "expected_apart_derived_together"
MEMBER_NAMES_NO_ITEM = "member_names_no_item"
ITEM_COVERED_BY_NO_COMPONENT = "item_covered_by_no_component"

# The single informational class. The other three indicate a real disagreement
# with the derived graph; this one only reports that the assertion was silent.
INFORMATIONAL_KINDS: frozenset[str] = frozenset({ITEM_COVERED_BY_NO_COMPONENT})

# Endpoint separator on the CLI, matching the `--edges "<a>:<b> ..."`
# convention of the cohort-computation entry points.
EDGE_SEPARATOR = ":"


def _is_positive_int(value: object) -> TypeGuard[int]:
    """Report whether a deserialized value is a non-boolean integer above zero.

    The boolean exclusion matters because ``bool`` subclasses ``int``; the guard
    return form lets callers narrow an ``object`` without a cast.
    """

    return isinstance(value, int) and not isinstance(value, bool) and value > 0


@dataclass(frozen=True)
class ExpectedComponent:
    """One asserted lane, as authored in the manifest.

    Purpose:
        Carry one ``expected_conflict_components`` entry in a typed shape so the
        comparison never reaches back into the raw mapping. Frozen, so a read
        value cannot be edited into a scheduling input.

    Attributes:
        name (str | None): The optional diagnostic label, ``None`` when the
            entry omitted it. Never used for identity.
        members (tuple[int, ...]): The asserted member keys in manifest order.
            Identity is by membership, not by name.
    """

    name: str | None
    members: tuple[int, ...]

    def label(self, position: int) -> str:
        """Return the quoted name, or ``component[<position>]`` when unnamed."""

        return f"'{self.name}'" if self.name is not None else f"component[{position}]"


@dataclass(frozen=True)
class LaneAssertionFinding:
    """One advisory finding about the assertion versus the derived graph.

    Attributes:
        kind (str): One of the four report-class tokens defined above.
        detail (str): A single-sentence human-readable description.
        members (tuple[int, ...]): The item keys the finding concerns, sorted
            ascending, so a consumer can act without re-parsing ``detail``.
    """

    kind: str
    detail: str
    members: tuple[int, ...]


@dataclass(frozen=True)
class LaneAssertionReport:
    """The full comparison outcome.

    Attributes:
        derived_components (tuple[tuple[int, ...], ...]): The derived conflict
            graph's components, each sorted ascending, ordered by lowest member.
        findings (tuple[LaneAssertionFinding, ...]): Every finding, grouped by
            report class in the order ``compare`` produces them.
    """

    derived_components: tuple[tuple[int, ...], ...]
    findings: tuple[LaneAssertionFinding, ...]

    @property
    def disagreement_count(self) -> int:
        """Return the count of findings outside ``INFORMATIONAL_KINDS``."""

        return sum(1 for f in self.findings if f.kind not in INFORMATIONAL_KINDS)


def derive_components(
    item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]
) -> tuple[tuple[int, ...], ...]:
    """Derive the connected components of the conflict graph.

    A lane whose items mutually conflict is one connected component; two lanes
    sharing no edge are two components.

    Args:
        item_keys (Iterable[int]): Every declared vertex, each seeded into the
            adjacency so an isolated vertex survives.
        conflict_edges (Iterable[tuple[int, int]]): Undirected edges in any
            direction, duplicates permitted. A self-loop, or an edge naming a
            vertex outside ``item_keys``, is skipped rather than raising:
            malformed-edge reporting belongs to the checkpoint validators, and a
            diagnostic must degrade gracefully on partial input.

    Returns:
        tuple[tuple[int, ...], ...]: One tuple per component, each sorted
        ascending, ordered by lowest member. Empty input returns an empty tuple,
        and the result partitions the declared keys exactly.
    """

    # Record each conflict on both endpoints; that symmetry, plus set-valued
    # neighbours, makes edge direction and repetition irrelevant. It is the same
    # normalization the cohort computation performs internally.
    adjacency: dict[int, set[int]] = {key: set() for key in item_keys}
    for first, second in conflict_edges:
        if first == second or first not in adjacency or second not in adjacency:
            continue
        adjacency[first].add(second)
        adjacency[second].add(first)

    seen: set[int] = set()
    components: list[tuple[int, ...]] = []
    # Seed a breadth-first walk from each unvisited vertex in ascending key
    # order, making the component sequence a function of the graph alone.
    for root in sorted(adjacency):
        if root in seen:
            continue
        seen.add(root)
        member_set: set[int] = {root}
        queue: deque[int] = deque([root])
        while queue:
            for neighbour in adjacency[queue.popleft()]:
                if neighbour in seen:
                    continue
                seen.add(neighbour)
                member_set.add(neighbour)
                queue.append(neighbour)
        components.append(tuple(sorted(member_set)))

    return tuple(sorted(components, key=lambda members: members[0]))


def _find_split_lanes(
    expected: Sequence[ExpectedComponent], derived_index: dict[int, int]
) -> list[LaneAssertionFinding]:
    """Report expected components whose members landed in different components.

    Args:
        expected (Sequence[ExpectedComponent]): The asserted lanes.
        derived_index (dict[int, int]): ``key -> derived component index``.

    Returns:
        list[LaneAssertionFinding]: One finding per split lane, in manifest
        order. A member absent from ``derived_index`` goes to the unknown class.
    """

    findings: list[LaneAssertionFinding] = []
    # One finding per lane, not per pair: an operator whose lane was split wants
    # one message naming the lane, not a quadratic list of member pairs.
    for position, component in enumerate(expected):
        resolved = [key for key in component.members if key in derived_index]
        landed = {derived_index[key] for key in resolved}
        if len(landed) > 1:
            findings.append(
                LaneAssertionFinding(
                    kind=EXPECTED_TOGETHER_DERIVED_APART,
                    detail=(
                        f"expected component {component.label(position)} was derived "
                        f"apart: its members occupy {len(landed)} distinct conflict "
                        f"components"
                    ),
                    members=tuple(sorted(resolved)),
                )
            )
    return findings


def _find_merged_lanes(
    derived_components: Sequence[tuple[int, ...]], expected_index: dict[int, int]
) -> list[LaneAssertionFinding]:
    """Report derived components spanning more than one expected component.

    Args:
        derived_components (Sequence[tuple[int, ...]]): The derived partition.
        expected_index (dict[int, int]): ``key -> expected component index``.

    Returns:
        list[LaneAssertionFinding]: One finding per merged component, in derived
        order. A key covered by no expected component goes to the uncovered
        class.
    """

    findings: list[LaneAssertionFinding] = []
    # A derived component touching two asserted lanes means derivation found
    # contention between lanes asserted to be independent.
    for members in derived_components:
        covered = [key for key in members if key in expected_index]
        lanes = {expected_index[key] for key in covered}
        if len(lanes) > 1:
            findings.append(
                LaneAssertionFinding(
                    kind=EXPECTED_APART_DERIVED_TOGETHER,
                    detail=(
                        f"derived conflict component {list(members)} spans "
                        f"{len(lanes)} expected components that were asserted apart"
                    ),
                    members=tuple(sorted(covered)),
                )
            )
    return findings


def compare(
    expected: Sequence[ExpectedComponent],
    item_keys: Sequence[int],
    conflict_edges: Sequence[tuple[int, int]],
) -> LaneAssertionReport:
    """Compare an asserted lane grouping against the derived components.

    Args:
        expected (Sequence[ExpectedComponent]): The asserted lanes in manifest
            order. An empty sequence produces only the informational class.
        item_keys (Sequence[int]): Every declared ``items[].issue_num``.
        conflict_edges (Sequence[tuple[int, int]]): The DERIVED conflict edges.

    Returns:
        LaneAssertionReport: The derived components plus every finding, ordered
        by class -- split lanes, merged lanes, unknown members, uncovered items.
    """

    derived_components = derive_components(item_keys, conflict_edges)
    # Flat key -> component-index lookups on both sides turn every membership
    # question below into a constant-time comparison.
    derived_index = {
        key: index
        for index, members in enumerate(derived_components)
        for key in members
    }
    expected_index = {
        key: position
        for position, component in enumerate(expected)
        for key in component.members
    }

    findings: list[LaneAssertionFinding] = []
    findings.extend(_find_split_lanes(expected, derived_index))
    findings.extend(_find_merged_lanes(derived_components, expected_index))
    # An asserted member naming no manifest item is an authoring error in the
    # assertion itself, so it is reported apart from a grouping disagreement.
    findings.extend(
        LaneAssertionFinding(
            kind=MEMBER_NAMES_NO_ITEM,
            detail=f"expected member {key} names no manifest item",
            members=(key,),
        )
        for key in sorted(k for k in expected_index if k not in derived_index)
    )
    # Informational only: an item the assertion did not mention, which is
    # legitimate when the operator asserts a subset of the run.
    findings.extend(
        LaneAssertionFinding(
            kind=ITEM_COVERED_BY_NO_COMPONENT,
            detail=f"manifest item {key} is covered by no expected component",
            members=(key,),
        )
        for key in sorted(k for k in derived_index if k not in expected_index)
    )

    return LaneAssertionReport(
        derived_components=derived_components, findings=tuple(findings)
    )


def format_report(report: LaneAssertionReport) -> str:
    """Render a report as advisory-only plain text.

    Args:
        report (LaneAssertionReport): The comparison outcome.

    Returns:
        str: A header line naming the derived-component and disagreement counts,
        one ``ADVISORY``-prefixed line per finding, and a closing line stating
        that the diagnostic blocks nothing.
    """

    lines = [
        f"Lane assertion: {len(report.derived_components)} derived conflict "
        f"component(s); {report.disagreement_count} disagreement(s)."
    ]
    lines.extend(
        f"ADVISORY [{finding.kind}] {finding.detail}." for finding in report.findings
    )
    lines.append(
        "Advisory only: this diagnostic never blocks, never modifies a derived "
        "edge, never feeds compute_cohorts, and never influences scheduling."
    )
    return "\n".join(lines)


def read_manifest_inputs(
    mapping: dict[str, object],
) -> tuple[list[ExpectedComponent], list[int]]:
    """Read the asserted lanes and the declared item keys from a manifest.

    Reads defensively: every shape rule is enforced by invariants M6 and M8 in
    ``parallel_manifest_contract``, so a malformed entry is skipped rather than
    raised -- a diagnostic must not fail on input a validator already rejects.
    The positive-integer test matches the M8 resolution target, so the two agree
    on what "resolves to an item" means.

    Args:
        mapping (dict[str, object]): A parsed manifest frontmatter mapping.

    Returns:
        tuple[list[ExpectedComponent], list[int]]: Readable
        ``expected_conflict_components`` entries in manifest order, and every
        well-formed ``items[].issue_num`` ascending. Either may be empty.
    """

    components: list[ExpectedComponent] = []
    raw_components = mapping.get("expected_conflict_components")
    if isinstance(raw_components, list):
        for entry in cast("list[object]", raw_components):
            if not isinstance(entry, dict):
                continue
            fields = cast("dict[str, object]", entry)
            raw_members = fields.get("members")
            if not isinstance(raw_members, list):
                continue
            name = fields.get("name")
            components.append(
                ExpectedComponent(
                    name=name if isinstance(name, str) else None,
                    members=tuple(
                        member
                        for member in cast("list[object]", raw_members)
                        if _is_positive_int(member)
                    ),
                )
            )

    keys: set[int] = set()
    items = mapping.get("items")
    if isinstance(items, list):
        for entry in cast("list[object]", items):
            if not isinstance(entry, dict):
                continue
            issue_num = cast("dict[str, object]", entry).get("issue_num")
            if _is_positive_int(issue_num):
                keys.add(issue_num)

    return components, sorted(keys)


def parse_edges(edge_text: str) -> list[tuple[int, int]]:
    """Parse a whitespace-separated ``<a>:<b>`` edge list.

    Args:
        edge_text (str): The derived conflict edges in the
            ``"<a>:<b> <c>:<d>"`` form the cohort-computation entry points
            accept. An empty or whitespace-only string yields no edges.

    Returns:
        list[tuple[int, int]]: The parsed edges in input order. A token that is
        not two integers separated by ``:`` is dropped rather than aborting the
        diagnostic, which would deny the operator the derivable findings.
    """

    edges: list[tuple[int, int]] = []
    for token in edge_text.split():
        first, separator, second = token.partition(EDGE_SEPARATOR)
        if not separator:
            continue
        try:
            edges.append((int(first), int(second)))
        except ValueError:
            continue
    return edges


def build_parser() -> argparse.ArgumentParser:
    """Build the parser accepting ``--manifest`` (required) and ``--edges``."""

    parser = argparse.ArgumentParser(
        prog="parallel_lane_assertion",
        description=(
            "Compare a parallel manifest's expected_conflict_components "
            "assertion against the derived conflict components. Advisory only: "
            "always exits 0 and never influences scheduling."
        ),
    )
    parser.add_argument(
        "--manifest",
        required=True,
        help="Path to docs/features/parallel/<slug>/parallel.md",
    )
    parser.add_argument(
        "--edges",
        default="",
        help='Derived conflict edges as "<a>:<b> <c>:<d>"; empty means no edges.',
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    """Run the diagnostic and print its advisory report.

    Args:
        argv (Sequence[str] | None): Arguments, or ``None`` for ``sys.argv[1:]``.

    Returns:
        int: Always 0. The diagnostic is advisory and never blocks, so a
        disagreement must not be expressible as a non-zero exit status. An
        unreadable or unparseable manifest also returns 0, after printing why.

    Raises:
        None. ``OSError`` from the manifest read is caught and reported;
        ``argparse`` still exits 2 on a malformed command line, a usage error
        rather than a diagnostic verdict.

    Side Effects:
        Reads the manifest named by ``--manifest`` and writes to stdout.
    """

    args = build_parser().parse_args(argv)
    try:
        text = Path(cast("str", args.manifest)).read_text(encoding="utf-8")
    except OSError as exc:
        print(f"Lane assertion: manifest unreadable ({exc}); no comparison made.")
        return 0

    mapping, parse_errors = parse_manifest_frontmatter(text)
    if mapping is None:
        print(f"Lane assertion: manifest unparseable ({parse_errors[0]}).")
        return 0

    expected, item_keys = read_manifest_inputs(mapping)
    edges = parse_edges(cast("str", args.edges))
    print(format_report(compare(expected, item_keys, edges)))
    return 0


if __name__ == "__main__":  # pragma: no cover - thin process entry point
    sys.exit(main())
