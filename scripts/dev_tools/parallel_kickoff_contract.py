"""Parse and validate the durable parallel kickoff Markdown contract.

Purpose:
    Own the structural contract for the operator-facing parallel kickoff
    document that a parallel planning run emits at
    ``artifacts/orchestration/parallel-kickoff-<slug>.md``. The module parses
    that document into a state-comparable structure and returns literal error
    strings for every structural violation it detects.

Ownership:
    ``docs/features/epics/parallel-orchestration/epic.md`` section "Planner
    Adjudication: the kickoff-contract boundary (F3 / F4)" assigns this module
    to the parallel-planner-surface feature by producer ownership, and
    ``.claude/rules/parallel-orchestration.md`` section "F3 Scope Boundary —
    kickoff contract deferred to F4" records the same boundary.

Scope boundaries:
    The parallel surface has no integration branch and no wave numbering, so
    this contract shares a shape but not a schema with the epic kickoff
    contract. This module therefore imports nothing from
    ``scripts/dev_tools/epic_kickoff_contract.py`` and never mutates its input.
    The Markdown table primitives live in
    ``scripts/dev_tools/_parallel_kickoff_tables.py`` so that both modules stay
    under the repository's 500-line file-size limit.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

from scripts.dev_tools._parallel_kickoff_tables import (
    HASH_HEADERS,
    INTEGRITY_COMMIT_RE,
    parse_integrity,
    table_rows,
)

__all__ = [
    "HASH_HEADERS",
    "INTEGRITY_COMMIT_RE",
    "ITEM_HEADERS",
    "KICKOFF_HEADING_RE",
    "KickoffItem",
    "MANIFEST_RE",
    "PARALLEL_RUN_RE",
    "PLAN_BRANCH_RE",
    "RESUME_RE",
    "ParsedParallelKickoff",
    "parse_parallel_kickoff",
    "validate_parallel_kickoff_text",
]

# The heading is the document identity line and carries the run slug.
KICKOFF_HEADING_RE = re.compile(r"^# Parallel Kickoff: (?P<slug>[a-z0-9][a-z0-9-]*)$")

# The invocation prompt must name the operator command that launches the run.
PARALLEL_RUN_RE = re.compile(r"Run `/parallel-run (?P<slug>[a-z0-9][a-z0-9-]*)`")

# The run manifest lives under the parallel feature tree, never the epic tree.
MANIFEST_RE = re.compile(r"docs/features/parallel/[a-z0-9][a-z0-9-]*/parallel\.md")

# The plan-home branch carries the committed plans. There is no integration
# branch on the parallel surface, so this pattern replaces the epic analogue's
# integration-branch pattern rather than supplementing it.
PLAN_BRANCH_RE = re.compile(r"parallel/[a-z0-9][a-z0-9-]*-plan")

# The resume boundary states that each item resumes at atomic execution from
# its committed plan-path on its own pushed feature branch. That per-item
# branch clause is what distinguishes the parallel resume contract from the
# epic surface's single shared integration branch, so it is matched explicitly.
RESUME_RE = re.compile(
    r"(?:Every item|items)\s+resumes?\s+at atomic execution\s+"
    r"from\s+(?:its|their)\s+committed plan-path\s+"
    r"on\s+(?:its|their)\s+own\s+(?:pushed\s+)?feature branch",
    flags=re.IGNORECASE,
)

ITEM_HEADERS = (
    "issue_num",
    "feature_folder",
    "cohort",
    "complexity",
    "branch",
    "plan-path",
)


@dataclass(frozen=True)
class KickoffItem:
    """One structurally parsed item-summary row.

    Purpose:
        Represent a single parallel-run item exactly as the kickoff table
        declares it, so a caller can cross-check the kickoff against the
        parallel planner checkpoint without re-parsing Markdown.

    Responsibilities:
        Carry the six declared cell values in typed form. The dataclass does
        not resolve paths, contact Git, or judge whether the declared values
        agree with repository state; those are caller concerns.

    Usage:
        Constructed only by this module's parser and consumed as an immutable
        value object.

    Key invariants:
        ``issue_num`` is the primary key for every item reference on the
        parallel surface, and ``cohort`` replaces the epic surface's wave
        number. There is no dependency-edge member: ordering on the parallel
        surface derives from blast-radius overlap, never a dependency graph.

    Attributes:
        issue_num (int): GitHub issue number that identifies the item.
        feature_folder (str): Repository-relative feature folder for the item.
        cohort (int): Scheduling cohort index the item belongs to.
        complexity (str): Complexity band, one of ``C1`` through ``C4``.
        branch (str): Per-item feature branch the item executes on.
        plan_path (str): Repository-relative path of the item's committed plan.
    """

    issue_num: int
    feature_folder: str
    cohort: int
    complexity: str
    branch: str
    plan_path: str


@dataclass(frozen=True)
class ParsedParallelKickoff:
    """Structured values required to cross-check a kickoff with planner state.

    Purpose:
        Expose the structural facts a caller needs to compare a kickoff
        document against ``artifacts/orchestration/parallel-planner-state.json``.

    Responsibilities:
        Hold parsed values only. The dataclass performs no validation itself;
        the parser returns it only when the document produced zero errors.

    Usage:
        Returned by :func:`parse_parallel_kickoff` and treated as immutable.

    Key invariants:
        ``slug`` and ``invocation_slug`` are captured separately so a caller
        can detect a kickoff whose heading and invocation disagree. There is no
        integration-branch member: the parallel surface has no integration
        branch, and each item opens its own pull request against ``main``.

    Attributes:
        slug (str): Run slug taken from the document heading.
        invocation_slug (str): Run slug taken from the ``/parallel-run`` call.
        manifest_path (str): Parallel run manifest path named by the prompt.
        plan_home_branch (str): The ``parallel/<slug>-plan`` branch name.
        items (tuple[KickoffItem, ...]): Parsed item-summary rows in order.
        planning_commit (str | None): Lowercased head commit of the plan-home
            branch, or ``None`` when the optional integrity section omits it.
        plan_hashes (dict[str, str]): Plan path to lowercased content hash.
    """

    slug: str
    invocation_slug: str
    manifest_path: str
    plan_home_branch: str
    items: tuple[KickoffItem, ...]
    planning_commit: str | None
    plan_hashes: dict[str, str]


def _split_sections(text: str) -> tuple[dict[str, list[str]], list[str]]:
    """Split exact level-two sections and reject duplicate required headings.

    Purpose:
        Partition the kickoff body into named level-two sections so each
        section is validated against its own contract, and reject documents
        that repeat a heading (which would make section lookup ambiguous).

    Args:
        text (str): Full kickoff document text. Not mutated.

    Returns:
        tuple[dict[str, list[str]], list[str]]: Section name to its body lines,
        paired with one error string per duplicate or missing required section.

    Raises:
        None.

    Side Effects:
        None.
    """

    sections: dict[str, list[str]] = {}
    errors: list[str] = []
    current: str | None = None
    # Skip the heading line, then accumulate each body line under the most
    # recent level-two heading. Lines before the first heading belong to no
    # section and are discarded, which is what makes the section set exact.
    for line in text.splitlines()[1:]:
        if line.startswith("## "):
            current = line[3:].strip()
            # A repeated heading is rejected rather than merged, because
            # merging would let a spoofed second table satisfy the contract.
            if current in sections:
                errors.append(
                    f"Parallel kickoff contains duplicate section: ## {current}"
                )
            else:
                sections[current] = []
            continue
        if current is not None:
            sections[current].append(line)
    # Both sections are load-bearing: the prompt carries the invocation
    # grammar and the table carries the per-item schedule.
    for required in ("Invocation Prompt", "Item Summary"):
        if required not in sections:
            errors.append(
                f"Parallel kickoff is missing required section: ## {required}"
            )
    return sections, errors


def _parse_items(lines: list[str]) -> tuple[tuple[KickoffItem, ...], list[str]]:
    """Parse and type-check the canonical item summary table.

    Purpose:
        Convert the ``## Item Summary`` table into typed :class:`KickoffItem`
        values, enforcing the numeric and enumerated cell contracts that the
        scheduler downstream depends on.

    Args:
        lines (list[str]): Body lines of the ``## Item Summary`` section.

    Returns:
        tuple[tuple[KickoffItem, ...], list[str]]: Parsed items in document
        order, paired with one row-indexed error string per violation.

    Raises:
        None.

    Side Effects:
        None.
    """

    rows, errors = table_rows(lines, ITEM_HEADERS)
    items: list[KickoffItem] = []
    # Type-check each accepted row positionally. A row whose numeric cells do
    # not parse is skipped because no usable item can be constructed from it,
    # while a bad complexity band is reported and the row is still recorded so
    # the remaining cross-checks stay meaningful.
    for index, row in enumerate(rows):
        issue_text, folder, cohort_text, complexity, branch, plan_path = row
        try:
            issue_num = int(issue_text)
        except ValueError:
            errors.append(
                f"Parallel kickoff item row {index} issue_num must be an integer."
            )
            continue
        try:
            cohort = int(cohort_text)
        except ValueError:
            errors.append(
                f"Parallel kickoff item row {index} cohort must be an integer."
            )
            continue
        if complexity not in {"C1", "C2", "C3", "C4"}:
            errors.append(
                f"Parallel kickoff item row {index} complexity must be C1-C4."
            )
        items.append(
            KickoffItem(issue_num, folder, cohort, complexity, branch, plan_path)
        )
    return tuple(items), errors


def parse_parallel_kickoff(text: str) -> tuple[ParsedParallelKickoff | None, list[str]]:
    """Parse the kickoff into a state-comparable structure.

    Purpose:
        Validate the whole kickoff document and, when it is structurally
        sound, return the values a caller needs to cross-check the kickoff
        against the parallel planner checkpoint.

    Args:
        text (str): Full kickoff document text. Not mutated.

    Returns:
        tuple[ParsedParallelKickoff | None, list[str]]: The parsed structure
        and an empty error list when the document is valid, otherwise ``None``
        and one error string per violation.

    Raises:
        None. Unparseable text yields error strings rather than an exception.

    Side Effects:
        None.
    """

    lines = text.splitlines()
    if not lines:
        return None, ["Parallel kickoff is empty."]
    heading = KICKOFF_HEADING_RE.fullmatch(lines[0])
    if heading is None:
        return None, [
            "Parallel kickoff first line must match '# Parallel Kickoff: <slug>'."
        ]
    sections, errors = _split_sections(text)
    # The invocation prompt must structurally name four things: the operator
    # command, the run manifest, the plan-home branch, and the per-item resume
    # boundary. The command is reported separately from the other three
    # because a missing command is the single most common authoring error.
    invocation = "\n".join(sections.get("Invocation Prompt", []))
    invocation_slug = PARALLEL_RUN_RE.search(invocation)
    manifest_match = MANIFEST_RE.search(invocation)
    branch_match = PLAN_BRANCH_RE.search(invocation)
    resume_match = RESUME_RE.search(invocation)
    if invocation_slug is None:
        errors.append(
            "Parallel kickoff invocation must contain `Run /parallel-run <slug>`."
        )
    if manifest_match is None or branch_match is None or resume_match is None:
        errors.append(
            "Parallel kickoff invocation must structurally name the manifest, "
            "plan-home branch, and atomic-execution resume boundary."
        )
    items, item_errors = _parse_items(sections.get("Item Summary", []))
    errors.extend(item_errors)
    commit, plan_hashes, integrity_errors = parse_integrity(
        sections.get("Integrity", [])
    )
    errors.extend(integrity_errors)
    # The match guards are repeated here so the type checker can narrow each
    # optional match before the structure is built.
    if (
        errors
        or invocation_slug is None
        or manifest_match is None
        or branch_match is None
        or resume_match is None
    ):
        return None, errors
    return (
        ParsedParallelKickoff(
            slug=heading.group("slug"),
            invocation_slug=invocation_slug.group("slug"),
            manifest_path=manifest_match.group(0),
            plan_home_branch=branch_match.group(0),
            items=items,
            planning_commit=commit,
            plan_hashes=plan_hashes,
        ),
        [],
    )


def validate_parallel_kickoff_text(text: str) -> list[str]:
    """Validate the standalone parallel kickoff Markdown contract.

    Purpose:
        Provide the thin validation-only entry point used by the orchestration
        artifact CLI and the MCP surface. The wrapper exists so callers that
        need only pass/fail do not depend on the parsed structure.

    Args:
        text (str): Full kickoff document text. Not mutated.

    Returns:
        list[str]: One error string per structural violation; empty when the
        document satisfies the contract.

    Raises:
        None.

    Side Effects:
        None.
    """

    _, errors = parse_parallel_kickoff(text)
    return errors
