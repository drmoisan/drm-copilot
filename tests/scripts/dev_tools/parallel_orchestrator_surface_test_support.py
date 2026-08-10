"""Loaders and contract parsers for the parallel-orchestrator surface tests.

Purpose:
    Hold the repo-root-relative path constants, text loaders, Markdown
    structure parsers, and producer-side prescription parsers consumed by
    ``test_parallel_orchestrator_surface_contracts.py``. Every assertion lives
    in that test module; this module holds pure parsing helpers only, so the
    test module stays inside the repository 500-line file limit.

Usage:
    Imported as
    ``tests.scripts.dev_tools.parallel_orchestrator_surface_test_support``,
    following the precedent of ``epic_planner_launch_evidence_test_support``.

Invariants and constraints:
    The delivered surface is Markdown, so the contract is expressed as document
    structure and text fragments. Section-scoped criteria are matched against a
    section extracted by heading boundaries, never against whole-file text.
    ``collapse_whitespace`` exists so a multi-line prose obligation can be
    matched without depending on the file's line wrapping.

Side effects:
    Reads files that are committed to the checkout. No temporary file is
    created, no process is spawned, and no network access occurs, so every
    parser is deterministic for a given checkout.
"""

from __future__ import annotations

import hashlib
import re
from pathlib import Path
from typing import cast

import yaml

# ``parents[3]`` walks tests/scripts/dev_tools/<file> back to the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]

AGENT_RELATIVE = Path(".claude/agents/parallel-orchestrator.md")
ORCHESTRATE_SKILL_RELATIVE = Path(".claude/skills/parallel-orchestrate/SKILL.md")
RUN_SKILL_RELATIVE = Path(".claude/skills/parallel-run/SKILL.md")
STATUS_TEMPLATE_RELATIVE = Path("docs/features/templates/parallel/parallel-status.md")

# The three runtime files this feature delivers. The prescriptive-literal
# negatives are scoped to exactly these paths and to no other file.
DELIVERED_RUNTIME_FILES: tuple[Path, ...] = (
    AGENT_RELATIVE,
    ORCHESTRATE_SKILL_RELATIVE,
    RUN_SKILL_RELATIVE,
)

# Epic-surface literals that must not appear in the delivered parallel surface.
# They are held here as test data so no delivered file has to carry them.
PRESCRIPTIVE_EPIC_LITERALS: tuple[str, ...] = (
    "Epic mode: true",
    "--base epic/",
    "integration-to-main",
)

# Section headings the tests extract by boundary before matching content.
KICKOFF_HEADING = "## Parallel-Mode Kickoff Parameter"
BOUNDARIES_HEADING = "## Documentation Maintenance Boundaries"

_WHITESPACE_RUN = re.compile(r"\s+")
_BACKTICKED = re.compile(r"`([^`]+)`")
_HEADER_FIELDS = re.compile(r"Header block fields:([^.]*)\.")
_COHORT_PROJECTION = re.compile(r"Cohort table:.*?`cohorts\[\]\s*\{([^}]*)\}`")
_PROJECTION_SECTION = re.compile(r"section `(## [^`]+)`")
_DELIMITER_ROW = re.compile(r"^\|(?:\s*:?-{3,}:?\s*\|)+$")


def read_repo_text(relative_path: Path) -> str:
    """Return UTF-8 text for a repository file addressed from the repo root.

    Args:
        relative_path (Path): Repo-root-relative path of the file to read.

    Returns:
        str: The file's UTF-8 decoded content.

    Raises:
        OSError: If the file is absent or cannot be read.

    Side Effects:
        Reads from the filesystem.
    """

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def file_sha256(relative_path: Path) -> str:
    """Return the lowercase SHA-256 hex digest of a repository file's bytes.

    Hashing raw bytes rather than decoded text keeps the digest comparable to
    the ``Get-FileHash`` baseline recorded during Phase 0.

    Args:
        relative_path (Path): Repo-root-relative path of the file to hash.

    Returns:
        str: Lowercase hexadecimal SHA-256 digest of the file's bytes.

    Raises:
        OSError: If the file is absent or cannot be read.

    Side Effects:
        Reads from the filesystem.
    """

    return hashlib.sha256((REPO_ROOT / relative_path).read_bytes()).hexdigest()


def collapse_whitespace(text: str) -> str:
    """Collapse each whitespace run to a single space and trim the result.

    Args:
        text (str): Text whose line wrapping should be normalized away.

    Returns:
        str: The text with every whitespace run replaced by one space.

    Raises:
        None.

    Side Effects:
        None.
    """

    return _WHITESPACE_RUN.sub(" ", text).strip()


def split_frontmatter(text: str) -> tuple[str, str]:
    """Split a Markdown document into its YAML frontmatter and its body.

    Args:
        text (str): Raw document text expected to open with a ``---`` fence.

    Returns:
        tuple[str, str]: The frontmatter block text and the body text.

    Raises:
        ValueError: If the document does not open with a fence or the fence is
            never terminated. Failing fast keeps a malformed document from
            silently satisfying a body-only assertion.

    Side Effects:
        None.
    """

    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        raise ValueError("document does not open with a YAML frontmatter fence")

    # Walk forward to the closing fence; everything after it is the body.
    for index in range(1, len(lines)):
        if lines[index].strip() == "---":
            return "\n".join(lines[1:index]), "\n".join(lines[index + 1 :])
    raise ValueError("YAML frontmatter fence is not terminated")


def parse_frontmatter(text: str) -> dict[str, object]:
    """Parse a document's YAML frontmatter into a narrowed mapping.

    Isolates the untyped ``yaml.safe_load`` boundary so callers work against a
    ``dict[str, object]``.

    Args:
        text (str): Raw document text whose frontmatter should be parsed.

    Returns:
        dict[str, object]: The parsed frontmatter mapping.

    Raises:
        ValueError: If the frontmatter is missing, unterminated, or does not
            parse into a mapping.

    Side Effects:
        None.
    """

    block, _ = split_frontmatter(text)
    parsed = yaml.safe_load(block)
    if not isinstance(parsed, dict):
        raise ValueError("YAML frontmatter did not parse into a mapping")
    return cast("dict[str, object]", parsed)


def string_sequence(value: object) -> tuple[str, ...]:
    """Return the string members of a parsed YAML list value.

    Args:
        value (object): A value read from a parsed frontmatter mapping.

    Returns:
        tuple[str, ...]: The string members in order, or an empty tuple when the
        value is not a list. Non-string members are dropped rather than
        coerced, so a malformed entry cannot masquerade as a declared name.

    Raises:
        None.

    Side Effects:
        None.
    """

    if not isinstance(value, list):
        return ()
    items = cast("list[object]", value)
    return tuple(item for item in items if isinstance(item, str))


def subagent_stop_hook_commands(frontmatter: dict[str, object]) -> tuple[str, ...]:
    """Collect the command strings declared by ``hooks.SubagentStop`` entries.

    Args:
        frontmatter (dict[str, object]): A parsed agent frontmatter mapping.

    Returns:
        tuple[str, ...]: Every nested hook ``command`` string, in declaration
        order. An empty tuple means no well-formed ``SubagentStop`` command is
        declared, which the caller asserts against.

    Raises:
        None.

    Side Effects:
        None.
    """

    hooks = frontmatter.get("hooks")
    if not isinstance(hooks, dict):
        return ()
    entries = cast("dict[str, object]", hooks).get("SubagentStop")
    if not isinstance(entries, list):
        return ()

    # Each matcher entry carries its own nested hook list; flatten both levels
    # so the caller sees one sequence of command strings regardless of nesting.
    commands: list[str] = []
    for entry in cast("list[object]", entries):
        if not isinstance(entry, dict):
            continue
        nested = cast("dict[str, object]", entry).get("hooks")
        if not isinstance(nested, list):
            continue
        for hook in cast("list[object]", nested):
            if not isinstance(hook, dict):
                continue
            command = cast("dict[str, object]", hook).get("command")
            if isinstance(command, str):
                commands.append(command)
    return tuple(commands)


def top_level_headings(text: str) -> tuple[str, ...]:
    """Return the ``##`` headings of a Markdown body in document order.

    Only lines that begin with ``"## "`` count, so a heading name quoted inside
    a prose sentence or a deeper ``###`` heading is not mistaken for a section.

    Args:
        text (str): Markdown body text (frontmatter already removed).

    Returns:
        tuple[str, ...]: The heading lines, stripped of trailing whitespace.

    Raises:
        None.

    Side Effects:
        None.
    """

    return tuple(line.rstrip() for line in text.splitlines() if line.startswith("## "))


def extract_section(text: str, heading: str) -> str:
    """Return the body of one ``##`` section, bounded by the next ``##`` heading.

    Args:
        text (str): Markdown body text containing the heading.
        heading (str): Exact heading line that opens the section.

    Returns:
        str: The text between the heading line and the next top-level heading,
        excluding the heading line itself.

    Raises:
        ValueError: If the heading is absent, so a section-scoped assertion can
            never silently degrade into a match against an empty string.

    Side Effects:
        None.
    """

    lines = text.splitlines()
    try:
        start = lines.index(heading)
    except ValueError as exc:
        raise ValueError(f"section heading not found: {heading}") from exc

    # Walk forward to the next top-level heading, which terminates the section.
    end = len(lines)
    for index in range(start + 1, len(lines)):
        if lines[index].startswith("## "):
            end = index
            break
    return "\n".join(lines[start + 1 : end])


def assert_fragments(section: str, fragments: tuple[str, ...], where: str) -> None:
    """Assert every whitespace-collapsed fragment appears in the given text.

    Args:
        section (str): Text to search, normally an extracted section body.
        fragments (tuple[str, ...]): Required obligations, each pinned as text.
        where (str): Human-readable location used in the failure message.

    Returns:
        None: Returns normally when every fragment is present.

    Raises:
        AssertionError: If any fragment is absent, naming that fragment.

    Side Effects:
        None.
    """

    collapsed = collapse_whitespace(section)

    # Check each obligation separately so a failure names the missing fragment
    # rather than reporting an opaque whole-section mismatch.
    for fragment in fragments:
        assert fragment in collapsed, f"{where} is missing required text: {fragment}"


def orchestrate_skill_section(heading: str) -> str:
    """Return one section body of the parallel-orchestrate skill.

    Args:
        heading (str): Exact ``##`` heading line opening the section.

    Returns:
        str: The section body, bounded by the next top-level heading.

    Raises:
        ValueError: If the frontmatter is malformed or the heading is absent.

    Side Effects:
        Reads the skill file from the checkout.
    """

    _, body = split_frontmatter(read_repo_text(ORCHESTRATE_SKILL_RELATIVE))
    return extract_section(body, heading)


def prescribed_header_fields(section_text: str) -> tuple[str, ...]:
    """Extract the header field names the producer section prescribes.

    Parses the ``Header block fields:`` sentence of the producer's
    ``## Documentation Maintenance Boundaries`` section, so the consumer-side
    seam assertion binds to the producer text instead of restating a list.

    Args:
        section_text (str): Extracted producer section body.

    Returns:
        tuple[str, ...]: The backticked field names in prescription order, or an
        empty tuple when the sentence is absent.

    Raises:
        None.

    Side Effects:
        None.
    """

    match = _HEADER_FIELDS.search(collapse_whitespace(section_text))
    if match is None:
        return ()
    return tuple(item.group(1) for item in _BACKTICKED.finditer(match.group(1)))


def prescribed_cohort_table_columns(section_text: str) -> tuple[str, ...]:
    """Extract the cohort-table column names the producer section prescribes.

    Args:
        section_text (str): Extracted producer section body.

    Returns:
        tuple[str, ...]: The field names listed inside the ``cohorts[] { ... }``
        projection, with any ``[]`` array suffix removed so each name compares
        against a status-document table column heading. Empty when the
        projection sentence is absent.

    Raises:
        None.

    Side Effects:
        None.
    """

    match = _COHORT_PROJECTION.search(collapse_whitespace(section_text))
    if match is None:
        return ()

    # Split the brace list and drop array suffixes; the status document renders
    # ``item_keys[]`` as a column headed ``item_keys``.
    parts = str(match.group(1)).split(",")
    return tuple(part.strip().removesuffix("[]") for part in parts if part.strip())


def prescribed_projection_sections(section_text: str) -> tuple[str, ...]:
    """Extract the read-only projection section names the producer prescribes.

    Args:
        section_text (str): Extracted producer section body.

    Returns:
        tuple[str, ...]: Each heading named by a ``section `## X``` phrase, in
        prescription order. Empty when no such phrase is present.

    Raises:
        None.

    Side Effects:
        None.
    """

    collapsed = collapse_whitespace(section_text)
    return tuple(item.group(1) for item in _PROJECTION_SECTION.finditer(collapsed))


def markdown_table_header_cells(text: str) -> tuple[frozenset[str], ...]:
    """Return the cell-name set of every Markdown table header row in a document.

    A header row is any pipe-delimited line immediately followed by a delimiter
    row. Cell names are stripped of surrounding whitespace and backticks so a
    column rendered as ``` `index` ``` matches the name ``index``.

    Args:
        text (str): Markdown document text to scan.

    Returns:
        tuple[frozenset[str], ...]: One frozen set of cell names per table, in
        document order.

    Raises:
        None.

    Side Effects:
        None.
    """

    lines = [line.strip() for line in text.splitlines()]

    # Pair each candidate header row with the delimiter row that confirms it, so
    # an ordinary pipe-bearing prose line is not treated as a table header.
    header_sets: list[frozenset[str]] = []
    for index in range(len(lines) - 1):
        if lines[index].startswith("|") and _DELIMITER_ROW.match(lines[index + 1]):
            cells = lines[index].strip("|").split("|")
            header_sets.append(frozenset(cell.strip().strip("`") for cell in cells))
    return tuple(header_sets)
