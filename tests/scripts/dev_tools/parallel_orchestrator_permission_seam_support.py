"""Permission-seam parsers for the parallel-orchestrator surface (issue #441).

Purpose:
    Parse both halves of one producer/consumer seam at run time: the
    ``parallel-orchestrator`` persona's declared ``tools`` allowlist is the
    PRODUCER of permissions, and the ``parallel-orchestrate`` procedure text is
    the CONSUMER that prescribes actions requiring them. Holding both parsers
    here lets ``test_parallel_orchestrator_permission_contracts.py`` assert that
    every write target and every command invocation the procedure prescribes is
    covered by a declared grant, without either side's set being restated as a
    test literal.

Usage:
    Imported as
    ``tests.scripts.dev_tools.parallel_orchestrator_permission_seam_support``.
    Path constants, text loaders, and frontmatter parsers are reused from
    ``parallel_orchestrator_surface_test_support`` rather than re-implemented;
    the pinned closed sets that gate write-target retention are reused from
    ``parallel_orchestrator_surface_expectations``.

Invariants and constraints:
    Every function is pure with respect to its inputs and contains no assertion,
    so a failure is reported by the test module that owns the criterion rather
    than from inside a parser. No grant literal and no prescribed target literal
    appears here: a one-sided narrowing of the allowlist or a one-sided addition
    to the procedure changes a parsed result rather than leaving both sides
    silently agreeing. Grant coverage is prefix-based because the runtime
    allowlist syntax is a literal prefix followed by a wildcard.

Side effects:
    Reads files that are committed to the checkout. No temporary file is
    created, no process is spawned, and no network access occurs, so every
    parser is deterministic for a given checkout.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pathlib import Path

from tests.scripts.dev_tools.parallel_orchestrator_surface_expectations import (
    NON_PARENT_ACTOR_MARKERS,
    WRITE_DESTINATION_PREPOSITIONS,
    WRITE_VERBS,
)
from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    AGENT_RELATIVE,
    ORCHESTRATE_SKILL_RELATIVE,
    collapse_whitespace,
    parse_frontmatter,
    read_repo_text,
    split_frontmatter,
    string_sequence,
)

_WRITE_GRANT = re.compile(r"^Write\((.+)\)$")
_BASH_GRANT = re.compile(r"^Bash\((.+)\)$")

# A grant body ending in this suffix is a wildcard grant; the text before it is
# the literal prefix the grant covers.
_PATH_WILDCARD_SUFFIX = "**"
_COMMAND_WILDCARD_SUFFIX = "*"


def _grant_bodies(pattern: re.Pattern[str], relative_path: Path) -> tuple[str, ...]:
    """Return the bodies of the persona ``tools`` entries matching one grant shape.

    Args:
        pattern (re.Pattern[str]): Anchored pattern whose first capture group is
            the grant body, for example the glob inside ``Write(...)``.
        relative_path (Path): Repo-root-relative path of the persona document
            whose frontmatter declares the ``tools`` allowlist.

    Returns:
        tuple[str, ...]: The captured grant bodies in declaration order. An
        empty tuple means the persona declares no grant of that shape, which the
        caller surfaces as an uncovered prescription rather than as a pass.

    Raises:
        ValueError: If the persona frontmatter is missing, unterminated, or does
            not parse into a mapping.
        OSError: If the persona document cannot be read.

    Side Effects:
        Reads the persona document from the checkout.
    """

    frontmatter = parse_frontmatter(read_repo_text(relative_path))
    entries = string_sequence(frontmatter.get("tools"))

    # Keep only the entries whose whole text matches the requested grant shape,
    # so an entry such as ``Read`` or ``Agent(orchestrator)`` is not mistaken for
    # a write or command grant.
    bodies: list[str] = []
    for entry in entries:
        match = pattern.match(entry.strip())
        if match is not None:
            bodies.append(match.group(1).strip())
    return tuple(bodies)


def persona_write_grants(relative_path: Path = AGENT_RELATIVE) -> tuple[str, ...]:
    """Return the glob bodies of the persona's ``Write(...)`` grants.

    Args:
        relative_path (Path): Repo-root-relative path of the persona document.
            Defaults to the delivered ``parallel-orchestrator`` persona.

    Returns:
        tuple[str, ...]: One glob per ``Write(<glob>)`` entry, in declaration
        order. ``Edit(...)`` entries are excluded: the seam under test is the
        creation of a new finding file, which is a write rather than an edit.

    Raises:
        ValueError: If the persona frontmatter is malformed.
        OSError: If the persona document cannot be read.

    Side Effects:
        Reads the persona document from the checkout.
    """

    return _grant_bodies(_WRITE_GRANT, relative_path)


def persona_bash_grants(relative_path: Path = AGENT_RELATIVE) -> tuple[str, ...]:
    """Return the pattern bodies of the persona's ``Bash(...)`` grants.

    Args:
        relative_path (Path): Repo-root-relative path of the persona document.
            Defaults to the delivered ``parallel-orchestrator`` persona.

    Returns:
        tuple[str, ...]: One pattern per ``Bash(<pattern>)`` entry, in
        declaration order.

    Raises:
        ValueError: If the persona frontmatter is malformed.
        OSError: If the persona document cannot be read.

    Side Effects:
        Reads the persona document from the checkout.
    """

    return _grant_bodies(_BASH_GRANT, relative_path)


def write_grant_covers(grant: str, target: str) -> bool:
    """Report whether one ``Write`` grant glob covers one prescribed write target.

    Args:
        grant (str): A glob body parsed from a ``Write(<glob>)`` entry, for
            example ``docs/features/parallel/**``.
        target (str): A repo-relative path token the procedure prescribes as a
            write destination.

    Returns:
        bool: ``True`` when the grant admits the target. A ``**``-terminated
        grant covers any target beginning with the literal prefix that precedes
        the wildcard; a grant carrying no wildcard must equal the target exactly.

    Raises:
        None.

    Side Effects:
        None.
    """

    # A wildcard grant is a prefix grant, while a wildcard-free grant names one
    # exact path. Distinguishing them matters because treating a wildcard-free
    # grant as a prefix would silently widen the permission the test models.
    if grant.endswith(_PATH_WILDCARD_SUFFIX):
        return target.startswith(grant[: -len(_PATH_WILDCARD_SUFFIX)])
    return grant == target


def bash_grant_covers(grant: str, invocation: str) -> bool:
    """Report whether one ``Bash`` grant pattern covers one prescribed invocation.

    Args:
        grant (str): A pattern body parsed from a ``Bash(<pattern>)`` entry, for
            example ``git *``.
        invocation (str): A command invocation the procedure prescribes.

    Returns:
        bool: ``True`` when the grant admits the invocation. A ``*``-terminated
        grant covers any invocation beginning with the literal prefix that
        precedes the wildcard; a grant carrying no wildcard must equal the
        invocation exactly.

    Raises:
        None.

    Side Effects:
        None.
    """

    # The same prefix-versus-exact distinction as ``write_grant_covers``: a
    # wildcard-free command grant permits exactly one command line.
    if grant.endswith(_COMMAND_WILDCARD_SUFFIX):
        return invocation.startswith(grant[: -len(_COMMAND_WILDCARD_SUFFIX)])
    return grant == invocation


def _split_sentences(collapsed: str) -> tuple[str, ...]:
    """Split whitespace-collapsed procedure text into sentences.

    A terminator (``.``, ``!``, ``?``) ends a sentence only when it is followed
    by whitespace or the end of the text and is not inside a backticked span, so
    a dotted token such as ``remediation-inputs.<timestamp>.md`` or
    ``scripts.dev_tools.validate_orchestration_artifacts`` is never fragmented. A
    leading ordered-list marker (``<digits>.``) is treated as a sentence boundary
    rather than as a terminator, so a numbered procedure step opens a new
    sentence and the marker itself is discarded.

    Args:
        collapsed (str): Procedure text whose whitespace runs have already been
            collapsed to single spaces.

    Returns:
        tuple[str, ...]: The non-empty sentences in document order, each
        stripped of surrounding whitespace.

    Raises:
        None.

    Side Effects:
        None.
    """

    sentences: list[str] = []
    start = 0
    index = 0
    inside_backticks = False
    length = len(collapsed)

    # Walk the text one character at a time, because sentence membership depends
    # on backtick state that a stateless regex split cannot track.
    while index < length:
        character = collapsed[index]

        # Backtick state comes first: a terminator inside a span is literal text.
        if character == "`":
            inside_backticks = not inside_backticks
            index += 1
            continue
        if inside_backticks:
            index += 1
            continue

        # An ordered-list marker opens a step, so the digits and their dot are a
        # boundary to discard rather than the end of the preceding sentence.
        if character.isdigit():
            digits_end = index
            while digits_end < length and collapsed[digits_end].isdigit():
                digits_end += 1
            at_word_start = index == 0 or collapsed[index - 1] == " "
            marker = (
                at_word_start
                and digits_end < length
                and collapsed[digits_end] == "."
                and (digits_end + 1 >= length or collapsed[digits_end + 1] == " ")
            )
            if marker:
                sentences.append(collapsed[start:index])
                start = digits_end + 1
                index = digits_end + 1
                continue
            index = digits_end
            continue

        # A terminator followed by whitespace or end of text closes a sentence.
        if character in ".!?" and (index + 1 >= length or collapsed[index + 1] == " "):
            sentences.append(collapsed[start : index + 1])
            start = index + 1
            index += 1
            continue

        index += 1

    sentences.append(collapsed[start:])
    return tuple(item.strip() for item in sentences if item.strip())


def _preceding_word(prefix: str) -> str:
    """Return the lowercase word immediately preceding a token.

    Args:
        prefix (str): The sentence text that precedes the token, ending at the
            token's opening backtick.

    Returns:
        str: The final run of letters in the prefix, lowercased, or an empty
        string when the prefix contains no letter. The empty result places the
        token in neither closed set, so it is not retained as a destination.

    Raises:
        None.

    Side Effects:
        None.
    """

    words = re.findall(r"[A-Za-z][A-Za-z'-]*", prefix)
    return words[-1].lower() if words else ""


def _is_repo_relative_path_token(token: str) -> bool:
    """Report whether a backticked span is a repo-relative path token.

    Args:
        token (str): The content of one backticked span.

    Returns:
        bool: ``True`` when the span contains a path separator and no whitespace,
        which is the shape of a repo-relative path and excludes command lines,
        field names, and enum members.

    Raises:
        None.

    Side Effects:
        None.
    """

    return "/" in token and not any(character.isspace() for character in token)


def _sentence_write_targets(sentence: str) -> tuple[str, ...]:
    """Return the parent write targets one sentence prescribes.

    Applies the three retention conditions in order: the sentence must contain a
    verb from ``WRITE_VERBS``; it must contain no marker from
    ``NON_PARENT_ACTOR_MARKERS``; and the word immediately preceding the path
    token must be either a write verb (direct-object form, ``regenerate <path>``)
    or a write-destination preposition (destination form, ``writes to <path>``).
    The adjacency condition is required rather than optional: without it the
    sentence-scoped rule retains read sources, prompt-text literals, and branch
    bases as though they were write destinations.

    Args:
        sentence (str): One whitespace-collapsed sentence of the procedure.

    Returns:
        tuple[str, ...]: The retained path tokens in sentence order. Empty when
        the sentence prescribes no parent write.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Condition (a): the sentence must state a write. Whole-word matching keeps
    # an unrelated word that merely contains a verb from qualifying the sentence.
    words = {word.lower() for word in re.findall(r"[A-Za-z][A-Za-z'-]*", sentence)}
    if not words.intersection(WRITE_VERBS):
        return ()

    # Condition (b): a sentence naming another actor describes that actor's
    # write, so the parent's grants are not the ones under test.
    if any(marker in sentence for marker in NON_PARENT_ACTOR_MARKERS):
        return ()

    # Condition (c): retain a path token only when the immediately preceding word
    # places it in a write-destination position.
    targets: list[str] = []
    for span in re.finditer(r"`([^`]+)`", sentence):
        token = span.group(1)
        if not _is_repo_relative_path_token(token):
            continue
        preceding = _preceding_word(sentence[: span.start()])
        if preceding in WRITE_VERBS or preceding in WRITE_DESTINATION_PREPOSITIONS:
            targets.append(token)
    return tuple(targets)


def prescribed_parent_write_targets(
    relative_path: Path = ORCHESTRATE_SKILL_RELATIVE,
) -> tuple[str, ...]:
    """Return the write targets the delivered procedure prescribes for the parent.

    The procedure document is addressed to ``parallel-orchestrator``, so an
    unattributed write sentence is a parent write. Targets are derived from the
    delivered text at run time and are never restated here, so adding a write
    destination to the procedure without a matching persona grant changes this
    result and fails the owning test.

    Args:
        relative_path (Path): Repo-root-relative path of the procedure skill.
            Defaults to the delivered ``parallel-orchestrate`` skill.

    Returns:
        tuple[str, ...]: The distinct prescribed targets in first-appearance
        order.

    Raises:
        ValueError: If the skill frontmatter is missing or unterminated.
        OSError: If the skill document cannot be read.

    Side Effects:
        Reads the procedure skill from the checkout.
    """

    _, body = split_frontmatter(read_repo_text(relative_path))

    # Collect across sentences while preserving first-appearance order, so a
    # target prescribed in two sections is reported once.
    ordered: list[str] = []
    for sentence in _split_sentences(collapse_whitespace(body)):
        for target in _sentence_write_targets(sentence):
            if target not in ordered:
                ordered.append(target)
    return tuple(ordered)


def _command_candidate_spans(body: str) -> tuple[str, ...]:
    """Collect the spans that may hold a command invocation.

    Candidate spans are every inline backticked span plus every non-empty line
    inside a fenced code block. Fenced-block lines are included because a
    procedure may present a multi-line invocation as a fence rather than inline.

    Args:
        body (str): Procedure body text with frontmatter already removed.

    Returns:
        tuple[str, ...]: The candidate spans in document order.

    Raises:
        None.

    Side Effects:
        None.
    """

    candidates: list[str] = []
    inside_fence = False

    # Walk the body line by line so fence state is tracked, and treat a fenced
    # block's lines as whole candidates rather than scanning them for backticks.
    for line in body.splitlines():
        if line.lstrip().startswith("```"):
            inside_fence = not inside_fence
            continue
        if inside_fence:
            if line.strip():
                candidates.append(line.strip())
            continue
        candidates.extend(span.group(1) for span in re.finditer(r"`([^`]+)`", line))
    return tuple(candidates)


def prescribed_command_invocations(
    relative_path: Path = ORCHESTRATE_SKILL_RELATIVE,
) -> tuple[str, ...]:
    """Return the command invocations the delivered procedure prescribes.

    A candidate span is a command invocation when it contains at least one space
    and its first whitespace-separated token matches ``^[a-z][a-z0-9-]*$`` in
    full. That shape admits ``git ...``, ``gh ...``, and ``poetry run ...`` while
    rejecting field names, enum members, ``key: value`` markers, bracketed
    structures, and bare path tokens.

    Args:
        relative_path (Path): Repo-root-relative path of the procedure skill.
            Defaults to the delivered ``parallel-orchestrate`` skill.

    Returns:
        tuple[str, ...]: The distinct prescribed invocations in first-appearance
        order.

    Raises:
        ValueError: If the skill frontmatter is missing or unterminated.
        OSError: If the skill document cannot be read.

    Side Effects:
        Reads the procedure skill from the checkout.
    """

    _, body = split_frontmatter(read_repo_text(relative_path))
    first_token = re.compile(r"^[a-z][a-z0-9-]*$")

    # Filter candidates to command shape while preserving first-appearance order,
    # so an invocation named in two sections is reported once.
    ordered: list[str] = []
    for candidate in _command_candidate_spans(body):
        tokens = candidate.split()
        if len(tokens) < 2 or first_token.match(tokens[0]) is None:
            continue
        if candidate not in ordered:
            ordered.append(candidate)
    return tuple(ordered)
