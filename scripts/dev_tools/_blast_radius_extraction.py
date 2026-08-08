"""Text-extraction helpers behind the blast-radius facade.

Purpose:
    Provide the pure text-scanning primitives that turn an approved atomic plan
    and a feature ``spec.md`` into the path and contract levels of the
    blast-radius model, keeping the facade
    ``scripts/dev_tools/compute_blast_radius.py`` under the file-size limit.

Responsibilities:
    Normalize line endings, partition plan lines, extract inline-code tokens,
    classify tokens as concrete repository paths or globs, and extract contract
    identifiers from a spec's interface sections. Glob translation, subsumption,
    and entry-pair overlap belong to
    ``scripts/dev_tools/_blast_radius_glob.py``. Building radius objects,
    resolving modules and shared surfaces, and emitting findings belong to the
    facade, not here.

Usage:
    The facade calls ``extract_plan_paths`` for both derivation and validation
    rule V1, so a radius derived from plan P always passes V1 against P. The
    PowerShell mirror ``.claude/lib/blast-radius/BlastRadius.psm1`` reproduces
    these rules; this Python module remains the authoritative reference.

Invariants / Constraints:
    - ``PLAN_PHASE_RE`` and ``PLAN_TASK_RE`` carry regex text character-identical
      to the patterns in ``scripts/dev_tools/validate_orchestration_artifacts.py``.
    - Returned collections are deduplicated and ordinally sorted, so identical
      inputs produce identical output in both languages.
    - The glob vocabulary is a deliberate fnmatch subset (``**``, ``*``, ``?``);
      character classes are unsupported because PowerShell's ``-like`` does not
      agree with fnmatch on their semantics.
    - Over-inclusion of read-only path references is accepted: the heuristic
      errs wide because radius under-reporting is the dominant design risk.

Side Effects:
    None. Every function is pure: no filesystem access, no subprocess, no
    network, and no wall-clock reads.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal

if TYPE_CHECKING:
    from collections.abc import Sequence

# Plan-structure patterns. The regex text is copied verbatim from
# ``scripts/dev_tools/validate_orchestration_artifacts.py`` so that radius
# derivation and the plan validator can never disagree about which lines are
# phase headings and which are tasks.
PLAN_PHASE_RE = re.compile(r"^### Phase (?P<phase>\d+) — (?P<title>.+)$")
PLAN_TASK_RE = re.compile(
    r"^- \[(?P<state>[ xX])\] \[P(?P<phase>\d+)-T(?P<task>\d+)\] (?P<title>.+)$"
)

# Inline code is the only accepted source of path and contract tokens. Matching
# spans per line keeps a fenced-code opening fence, which has no closing
# backtick on its own line, from producing spurious spans.
INLINE_CODE_SPAN_RE = re.compile(r"`([^`]+)`")

# Markdown ATX heading pattern used to locate spec interface sections.
HEADING_RE = re.compile(r"^(?P<hashes>#{1,6}) (?P<title>.+)$")

# Top-level directories of this repository. A token starting with one of these
# is accepted without needing a recognized extension, which admits
# directory-shaped tokens and ``**`` globs.
KNOWN_TOP_LEVEL_SEGMENTS: tuple[str, ...] = tuple(
    (
        "scripts/ tests/ docs/ config/ schemas/ packages/ extensions/ "
        ".claude/ .codex/ .github/ .agents/ artifacts/"
    ).split()
)

# Fallback acceptance rule: a token shaped ``<segment>/.../<name>.<ext>`` counts
# as a repository path when its final component carries one of these extensions.
RECOGNIZED_PATH_EXTENSIONS: frozenset[str] = frozenset(
    (
        "cfg cs csproj ini js json jsx lock md ps1 psd1 psm1 "
        "py sh sln toml ts tsx txt xml yaml yml"
    ).split()
)

# A spec section qualifies as an interface section when its heading, or the
# heading of an ancestor section, contains one of these words.
CONTRACT_HEADING_KEYWORDS: tuple[str, ...] = ("API", "Interface", "Contract", "Surface")

# Classification vocabulary for accepted path tokens. Concrete entries take part
# in exact-match checks; glob entries cannot and are matched by pattern.
PathTokenKind = Literal["concrete", "glob"]
PATH_KIND_CONCRETE: PathTokenKind = "concrete"
PATH_KIND_GLOB: PathTokenKind = "glob"


@dataclass(frozen=True)
class PlanLineScan:
    """Immutable line-level partition of an atomic plan document.

    Purpose and responsibilities:
        Carry one pass over a plan's normalized lines, split into the three
        categories the derivation heuristic treats differently. The class holds
        already-extracted text only; ``scan_plan_lines`` does the parsing and
        constructs it, and ``extract_plan_paths`` consumes it.

    Invariants and side effects:
        Every source line appears in exactly one tuple and source order is
        preserved within each tuple. The instance is frozen and holds immutable
        tuples, so it has no side effects.

    Attributes:
        task_titles (tuple[str, ...]): Title group of each ``PLAN_TASK_RE``
            match; the primary path signal.
        phase_titles (tuple[str, ...]): Title group of each ``PLAN_PHASE_RE``
            match.
        other_lines (tuple[str, ...]): Remaining lines verbatim, including
            lines that resemble a task but fail the strict task pattern.
    """

    task_titles: tuple[str, ...]
    phase_titles: tuple[str, ...]
    other_lines: tuple[str, ...]


def normalize_lines(text: str) -> tuple[str, ...]:
    """Split document text into lines independent of line-ending style.

    Args:
        text (str): Full document text, possibly mixing LF, CRLF, and CR
            endings, matching the plan-validator CRLF fix.

    Returns:
        tuple[str, ...]: Lines in source order without terminators; an empty
        string yields an empty tuple.

    Raises:
        None.

    Side Effects:
        None.
    """
    return tuple(text.splitlines())


def scan_plan_lines(plan_text: str) -> PlanLineScan:
    """Partition a plan's lines into task titles, phase titles, and prose.

    Args:
        plan_text (str): Full atomic-plan document text.

    Returns:
        PlanLineScan: The three-way partition. A plan with no task or phase
        lines yields empty title tuples and all lines in ``other_lines``.

    Raises:
        None.

    Side Effects:
        None.
    """
    task_titles: list[str] = []
    phase_titles: list[str] = []
    other_lines: list[str] = []

    # Classify every normalized line exactly once. Task lines are tested first
    # because a task line can never also be a phase heading and because task
    # bodies are the primary path signal. A line that resembles a task but fails
    # the strict pattern deliberately falls through to prose so its path
    # references are still collected rather than silently dropped.
    for line in normalize_lines(plan_text):
        task_match = PLAN_TASK_RE.match(line)
        if task_match is not None:
            task_title: str = task_match.group("title")
            task_titles.append(task_title)
            continue

        phase_match = PLAN_PHASE_RE.match(line)
        if phase_match is not None:
            phase_title: str = phase_match.group("title")
            phase_titles.append(phase_title)
            continue

        other_lines.append(line)

    return PlanLineScan(
        task_titles=tuple(task_titles),
        phase_titles=tuple(phase_titles),
        other_lines=tuple(other_lines),
    )


def extract_inline_code_tokens(line: str) -> tuple[str, ...]:
    """Extract whitespace-separated tokens from a line's inline-code spans.

    Args:
        line (str): A single normalized line of a plan or spec document.

    Returns:
        tuple[str, ...]: Tokens in source order with duplicates preserved; a
        line with no inline-code span yields an empty tuple.

    Raises:
        None.

    Side Effects:
        None.
    """
    tokens: list[str] = []

    # Strip a defensive trailing carriage return, left when upstream text was
    # split on "\n" alone rather than normalized, then split each span on
    # whitespace: a span may hold a whole command line (for example a pytest
    # invocation) rather than a single path-shaped token.
    for match in INLINE_CODE_SPAN_RE.finditer(line):
        span: str = match.group(1)
        if span.endswith("\r"):
            span = span[:-1]
        tokens.extend(span.split())

    return tuple(tokens)


def classify_path_token(
    token: str, *, root_surfaces: Sequence[str] = ()
) -> PathTokenKind | None:
    """Classify an inline-code token as a concrete repository path or a glob.

    Args:
        token (str): A single whitespace-free inline-code token.
        root_surfaces (Sequence[str]): Configured separator-free repository-root
            shared surfaces, supplied by the caller from
            ``config_root_surfaces``. Membership is exact and ordinal. The empty
            default reproduces pre-change behaviour for every caller that omits
            it.

    Returns:
        PathTokenKind | None: ``"glob"`` for an accepted token containing
        ``*``, ``"concrete"`` for an accepted token without one, and ``None``
        when the token is not a repository path reference.

    Raises:
        None.

    Side Effects:
        None; the input sequence is not mutated.
    """
    # A separator-free token is admitted only as an exact ordinal member of the
    # configured root-surface set (issue #452). Substring, suffix, and
    # case-insensitive comparison are all rejected: anything looser would
    # desynchronize this classifier from ``resolve_shared_surfaces``, which
    # tests plain membership. This runs before the separator guard because a
    # configured root surface has no separator by construction. The explicit
    # equality comparison is deliberate: a plain ``in`` test would fall back to
    # substring semantics if a caller ever passed a bare string.
    if any(token == surface for surface in root_surfaces):
        return PATH_KIND_CONCRETE

    # A path reference must name a separator; a bare word such as a function
    # name is a contract identifier, not a path. It must also be
    # repository-relative: a leading separator marks an absolute path and a
    # colon in the leading segment marks a URL scheme or a Windows drive.
    if "/" not in token or token.startswith("/"):
        return None
    if ":" in token.split("/", 1)[0]:
        return None

    # Read the final component's extension for the fallback acceptance rule; a
    # component with no dot (a directory name or ``**``) has no extension.
    final_component = token.rsplit("/", 1)[-1]
    extension = ""
    if "." in final_component:
        extension = final_component.rsplit(".", 1)[-1].lower()

    # Acceptance requires one of the two documented shape rules; failing both
    # means the token is prose or a non-path expression that merely contains a
    # separator, so it is dropped.
    if not (
        token.startswith(KNOWN_TOP_LEVEL_SEGMENTS)
        or extension in RECOGNIZED_PATH_EXTENSIONS
    ):
        return None

    # An accepted token carrying a wildcard names a set of files, so it cannot
    # take part in concrete exact-match comparisons and is recorded as a glob.
    if "*" in token:
        return PATH_KIND_GLOB
    return PATH_KIND_CONCRETE


def extract_paths_from_lines(
    lines: Sequence[str], *, root_surfaces: Sequence[str] = ()
) -> tuple[str, ...]:
    """Collect accepted path and glob tokens from already-normalized lines.

    Args:
        lines (Sequence[str]): Normalized document lines to scan. Shared by plan
            and spec extraction so both apply identical acceptance rules.
        root_surfaces (Sequence[str]): Configured separator-free root surfaces,
            forwarded unchanged to ``classify_path_token``. The empty default
            reproduces pre-change behaviour.

    Returns:
        tuple[str, ...]: Accepted tokens, deduplicated and ordinally sorted.

    Raises:
        None.

    Side Effects:
        None; the input sequence is not mutated.
    """
    accepted: set[str] = set()

    # Harvest every inline-code token from every supplied line and keep the ones
    # the classifier accepts. The set deduplicates repeated citations of a path
    # before the ordinal sort fixes the deterministic output order.
    for line in lines:
        for token in extract_inline_code_tokens(line):
            if classify_path_token(token, root_surfaces=root_surfaces) is not None:
                accepted.add(token)

    return tuple(sorted(accepted))


def extract_plan_paths(
    plan_text: str, *, root_surfaces: Sequence[str] = ()
) -> tuple[str, ...]:
    """Extract repository path references from an atomic plan.

    This is the single extraction function shared by radius derivation and
    validation rule V1; sharing it guarantees that a radius derived from plan P
    always passes V1 against P, leaving V1's force against hand-edited or stale
    declared radii and planner drift.

    Args:
        plan_text (str): Full atomic-plan document text.
        root_surfaces (Sequence[str]): Configured separator-free root surfaces,
            forwarded unchanged to ``extract_paths_from_lines``. The empty
            default reproduces pre-change behaviour.

    Returns:
        tuple[str, ...]: Concrete paths and globs cited in inline code,
        deduplicated and ordinally sorted; a plan with no path citations yields
        an empty tuple.

    Raises:
        None.

    Side Effects:
        None; the input sequence is not mutated.
    """
    scan = scan_plan_lines(plan_text)

    # Task bodies are the primary signal, but phase headings and remaining prose
    # are scanned too because plans cite paths in phase preambles, guardrail
    # clauses, and evidence clauses.
    return extract_paths_from_lines(
        scan.task_titles + scan.phase_titles + scan.other_lines,
        root_surfaces=root_surfaces,
    )


def extract_contract_identifiers(spec_text: str) -> tuple[str, ...]:
    """Extract contract identifiers from a spec's interface sections.

    Implements the contracts level of the radius model: exported symbols,
    schema names, and CLI identifiers named in inline code inside sections whose
    heading, or an ancestor heading, contains one of
    ``CONTRACT_HEADING_KEYWORDS``.

    Args:
        spec_text (str): Full feature ``spec.md`` document text.

    Returns:
        tuple[str, ...]: Identifiers, deduplicated and ordinally sorted. Tokens
        containing a separator are excluded as path references; a spec with no
        qualifying section yields an empty tuple.

    Raises:
        None.

    Side Effects:
        None.
    """
    identifiers: set[str] = set()
    qualifying_depth: int | None = None

    # Walk the document once, tracking the innermost qualifying heading level,
    # and harvest identifiers only while inside a qualifying section.
    for line in normalize_lines(spec_text):
        heading_match = HEADING_RE.match(line)

        # A heading changes the section context and contributes no identifiers
        # of its own. Markdown sections nest, so a heading deeper than the
        # innermost qualifying heading stays inside that section and inherits
        # its qualification; a heading at or above that level ends the section
        # and is judged on its own title.
        if heading_match is not None:
            heading_hashes: str = heading_match.group("hashes")
            heading_title: str = heading_match.group("title")
            heading_level = len(heading_hashes)
            if qualifying_depth is not None and heading_level > qualifying_depth:
                continue
            if any(word in heading_title for word in CONTRACT_HEADING_KEYWORDS):
                qualifying_depth = heading_level
            else:
                qualifying_depth = None
            continue

        if qualifying_depth is None:
            continue

        # Inside a qualifying section an inline-code token without a separator is
        # a contract identifier; a token with one is a path reference and is
        # recorded at the paths level instead.
        for token in extract_inline_code_tokens(line):
            if "/" not in token:
                identifiers.add(token)

    return tuple(sorted(identifiers))
