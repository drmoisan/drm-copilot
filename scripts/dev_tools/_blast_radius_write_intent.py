"""Write-intent extraction for the blast-radius library (issue #722).

Purpose and responsibilities:
    Narrow the text harvest that derivation and validation run over a plan and a
    spec so that only write-intent tokens become radius entries. The rules are
    active only when the truth table carries ``write_intent_extraction: true``:

    - W1 glob mention: a token containing ``*`` or ``?`` is dropped.
    - W2 command span: every token of an inline span that splits into more than
      one word is dropped.
    - W3 read task: the tokens of a task attribution window (a task line plus
      the following non-task lines up to the next ATX heading) are dropped when
      the task title starts with a read verb, after an optional bold label, and
      carries no write verb anywhere.
    - W4 root anchoring: a concrete token whose first segment, after a leading
      ``./`` is stripped, is not in ``path_roots`` and which is not a configured
      root surface is dropped. An empty or absent ``path_roots`` disables W4.
    - W5 spec contracts only: the spec contributes contracts and no paths, and
      contract harvesting applies W1 and W2.
    - W6 placeholder stem: a concrete token whose final-component stem is in
      ``PLACEHOLDER_STEMS`` is dropped.

    W1, W4, and W6 are token-level and also apply in normalization of a recorded
    radius through ``select_write_intent_path_entries``, which always keeps the
    feature-folder glob. W2, W3, and W5 need line context and apply only to
    derivation and to the plan-side extraction of validation. Both of those call
    the one selector ``select_plan_paths``, so a derived radius still passes V1
    and V2 against its own plan.

Usage:
    ``scripts/dev_tools/compute_blast_radius.py`` branches on
    ``config_write_intent_extraction`` in derivation and normalization, and
    ``scripts/dev_tools/_blast_radius_validation.py`` calls ``select_plan_paths``
    for V1 and V2. The PowerShell port is
    ``.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1``; its constants are
    pinned equal to the three vocabularies below by a parity test.

Invariants, constraints, and side effects:
    With the flag absent or false the selector returns exactly the current
    extraction, so every caller behaves as before (fail-closed default). The
    rules only ever drop tokens the current classifier accepts; they never add a
    token. Returned collections are deduplicated and ordinally sorted. Every
    function is pure and mutates no input: no filesystem, subprocess, network,
    or wall-clock access. This module imports the extraction and guard leaves
    only, never the validation module, so no import cycle can form.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

from scripts.dev_tools._blast_radius_extraction import (
    CONTRACT_HEADING_KEYWORDS,
    CONTRACT_LETTER_RE,
    HEADING_RE,
    INLINE_CODE_SPAN_RE,
    LINE_SUFFIX_RE,
    PLAN_TASK_RE,
    classify_path_token,
    extract_plan_paths,
    normalize_lines,
)
from scripts.dev_tools._blast_radius_guards import require_str_tuple

if TYPE_CHECKING:
    from collections.abc import Iterable, Mapping, Sequence

# Truth-table keys read by this module.
CONFIG_WRITE_INTENT_EXTRACTION = "write_intent_extraction"
CONFIG_PATH_ROOTS = "path_roots"

# The three rule vocabularies. The PowerShell port declares the same members in
# the same order, and a parity test pins the two runtimes together, so edit
# both files together.
READ_VERBS: tuple[str, ...] = tuple(
    "Read Verify Confirm Inspect Review Baseline".split()
)
WRITE_VERBS: tuple[str, ...] = tuple(
    (
        "Fix Write Update Edit Add Create Delete Remove " "Rename Author Append Replace"
    ).split()
)
PLACEHOLDER_STEMS: tuple[str, ...] = tuple(
    (
        "a b c d e f g h i j k l m n o p q r s t u v w x y z "
        "foo bar baz example sample placeholder"
    ).split()
)

# W3 title parsing. An optional leading bold label such as "**Baseline:**" is
# skipped before the first word is read; write verbs match as whole words
# anywhere in the title, case-insensitively.
_BOLD_LABEL_RE = re.compile(r"^\*\*[^*]+\*\*\s*")
_FIRST_WORD_RE = re.compile(r"^[A-Za-z]+")
_WRITE_VERB_RE = re.compile(r"\b(?:" + "|".join(WRITE_VERBS) + r")\b", re.IGNORECASE)
_READ_VERB_SET = frozenset(verb.lower() for verb in READ_VERBS)
_PLACEHOLDER_STEM_SET = frozenset(PLACEHOLDER_STEMS)

# The feature-folder glob kept by the token-level filter.
_FEATURE_FOLDER_PREFIX = "docs/features/"
_FEATURE_FOLDER_SUFFIX = "/**"
_WILDCARDS = ("*", "?")


def config_write_intent_extraction(config: Mapping[str, object]) -> bool:
    """Read the ``write_intent_extraction`` flag strictly.

    Args:
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.

    Returns:
        bool: The flag value; an absent or null key reads as ``False``, which
        keeps current extraction (fail closed).

    Raises:
        TypeError: If the key is present and is not a boolean. The message
            names the key.
    """
    value = config.get(CONFIG_WRITE_INTENT_EXTRACTION)
    if value is None:
        return False
    if not isinstance(value, bool):
        raise TypeError(
            f'config["{CONFIG_WRITE_INTENT_EXTRACTION}"] must be a boolean, '
            f"got {type(value).__name__}."
        )
    return value


def config_path_roots(config: Mapping[str, object]) -> tuple[str, ...]:
    """Read the ``path_roots`` list strictly.

    Args:
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.

    Returns:
        tuple[str, ...]: First path segments, deduplicated and sorted; an absent
        or null key yields an empty tuple, which disables W4.

    Raises:
        TypeError: If the key is present and is not a list of strings.
        ValueError: If an entry is blank. Both messages name the key.
    """
    value = config.get(CONFIG_PATH_ROOTS)
    if value is None:
        return ()
    return require_str_tuple(value, f'config["{CONFIG_PATH_ROOTS}"]')


def is_read_task_title(title: str) -> bool:
    """Report whether a task title makes its attribution window a read task (W3).

    Args:
        title (str): The task title, the text after the task identifier.

    Returns:
        bool: ``True`` when the first word after an optional bold label is a
        read verb and no write verb appears anywhere in the title.
    """
    unlabeled = _BOLD_LABEL_RE.sub("", title.strip(), count=1)
    first_word = _FIRST_WORD_RE.match(unlabeled)
    if first_word is None or first_word.group(0).lower() not in _READ_VERB_SET:
        return False
    return _WRITE_VERB_RE.search(title) is None


def is_feature_folder_glob(entry: str) -> bool:
    """Report whether an entry is a feature-folder glob, which is never dropped.

    Args:
        entry (str): One radius entry.

    Returns:
        bool: ``True`` for an entry under ``docs/features/`` that ends with
        ``/**`` and carries no other wildcard.
    """
    if not (
        entry.startswith(_FEATURE_FOLDER_PREFIX)
        and entry.endswith(_FEATURE_FOLDER_SUFFIX)
    ):
        return False
    body = entry[: -len(_FEATURE_FOLDER_SUFFIX)]
    return not any(wildcard in body for wildcard in _WILDCARDS)


def _has_wildcard(token: str) -> bool:
    """Report whether a token carries a glob wildcard (W1).

    Args:
        token (str): One whitespace-free token.

    Returns:
        bool: ``True`` when the token contains ``*`` or ``?``.
    """
    return any(wildcard in token for wildcard in _WILDCARDS)


def _is_outside_path_roots(
    token: str, root_surfaces: Sequence[str], path_roots: Sequence[str]
) -> bool:
    """Report whether W4 drops a concrete token.

    Args:
        token (str): One concrete token.
        root_surfaces (Sequence[str]): Configured separator-free root surfaces.
        path_roots (Sequence[str]): Configured first segments; empty disables W4.

    Returns:
        bool: ``True`` when W4 is enabled, the token is not a root surface, and
        its first segment after a leading ``./`` is not a configured root.
    """
    # An empty root list disables the rule, and a configured root surface is a
    # repository-root file that has no first directory segment to test.
    if not path_roots or token in root_surfaces:
        return False
    stripped = token[2:] if token.startswith("./") else token
    return stripped.split("/", 1)[0] not in path_roots


def _has_placeholder_stem(token: str) -> bool:
    """Report whether W6 drops a concrete token.

    Args:
        token (str): One concrete token, possibly with a ``:<line>`` suffix.

    Returns:
        bool: ``True`` when the final component's stem, compared
        case-insensitively, is in ``PLACEHOLDER_STEMS``.
    """
    final_component = LINE_SUFFIX_RE.sub("", token.rsplit("/", 1)[-1])
    stem = (
        final_component.rsplit(".", 1)[0] if "." in final_component else final_component
    )
    return stem.lower() in _PLACEHOLDER_STEM_SET


def _passes_token_rules(
    token: str, root_surfaces: Sequence[str], path_roots: Sequence[str]
) -> bool:
    """Apply the token-level rules W1, W4, and W6 to one token.

    Args:
        token (str): One token already accepted by the current classifier.
        root_surfaces (Sequence[str]): Configured separator-free root surfaces.
        path_roots (Sequence[str]): Configured first segments.

    Returns:
        bool: ``True`` when the token survives all three rules.
    """
    return not (
        _has_wildcard(token)
        or _is_outside_path_roots(token, root_surfaces, path_roots)
        or _has_placeholder_stem(token)
    )


def _single_word_tokens(line: str) -> Iterable[str]:
    """Yield the token of every inline span that holds exactly one word (W2).

    Args:
        line (str): One normalized document line.

    Returns:
        Iterable[str]: One token per single-word span, in source order.
    """
    # A span that splits into several words is a command line or prose, so none
    # of its words is a write claim; a blank span yields nothing.
    for match in INLINE_CODE_SPAN_RE.finditer(line):
        words = match.group(1).split()
        if len(words) == 1:
            yield words[0]


def extract_write_intent_plan_paths(
    plan_text: str, *, root_surfaces: Sequence[str], path_roots: Sequence[str]
) -> tuple[str, ...]:
    """Extract plan paths under rules W1 through W4 and W6.

    Args:
        plan_text (str): Full atomic-plan document text.
        root_surfaces (Sequence[str]): Configured separator-free root surfaces,
            forwarded to the current classifier and exempt from W4.
        path_roots (Sequence[str]): Configured first segments for W4.

    Returns:
        tuple[str, ...]: Surviving tokens, deduplicated and ordinally sorted.
        Every token is also returned by ``extract_plan_paths`` for the same
        plan, because the rules only drop tokens.
    """
    accepted: set[str] = set()
    in_read_window = False

    # Walk the lines once. A task line opens a window whose read status comes
    # from its title; an ATX heading closes any window; every other line
    # belongs to the window that is open, if any. Tokens of a read window are
    # dropped (W3); every other line is harvested under W1, W2, W4, and W6.
    for line in normalize_lines(plan_text):
        task_match = PLAN_TASK_RE.match(line)
        if task_match is not None:
            in_read_window = is_read_task_title(task_match.group("title"))
        elif HEADING_RE.match(line) is not None:
            in_read_window = False
        if in_read_window:
            continue

        # Keep a single-word token only when the current classifier accepts it
        # and it survives the token-level rules.
        for token in _single_word_tokens(line):
            if classify_path_token(
                token, root_surfaces=root_surfaces
            ) is not None and _passes_token_rules(token, root_surfaces, path_roots):
                accepted.add(token)

    return tuple(sorted(accepted))


def extract_write_intent_contracts(spec_text: str) -> tuple[str, ...]:
    """Extract spec contract identifiers with W1 and W2 applied (W5).

    Mirrors the current interface-section walk: identifiers are harvested only
    inside a section whose heading, or an ancestor heading, names an API,
    interface, contract, or surface. A multi-word span and a wildcard token
    contribute nothing.

    Args:
        spec_text (str): Full feature ``spec.md`` document text.

    Returns:
        tuple[str, ...]: Identifiers carrying an ASCII letter and no separator,
        deduplicated and ordinally sorted.
    """
    identifiers: set[str] = set()
    qualifying_depth: int | None = None

    # Walk the document once, tracking the innermost qualifying heading level.
    for line in normalize_lines(spec_text):
        heading_match = HEADING_RE.match(line)

        # A deeper heading stays inside the qualifying section; a heading at or
        # above that level ends it and is judged on its own title.
        if heading_match is not None:
            level = len(heading_match.group("hashes"))
            if qualifying_depth is not None and level > qualifying_depth:
                continue
            title = heading_match.group("title")
            qualifies = any(word in title for word in CONTRACT_HEADING_KEYWORDS)
            qualifying_depth = level if qualifies else None
            continue
        if qualifying_depth is None:
            continue

        # Inside a qualifying section a single-word, wildcard-free token without
        # a separator and with a letter is a contract identifier.
        for token in _single_word_tokens(line):
            if (
                "/" not in token
                and not _has_wildcard(token)
                and CONTRACT_LETTER_RE.search(token) is not None
            ):
                identifiers.add(token)

    return tuple(sorted(identifiers))


def select_write_intent_path_entries(
    entries: Sequence[str], *, root_surfaces: Sequence[str], path_roots: Sequence[str]
) -> tuple[str, ...]:
    """Apply the token-level rules W1, W4, and W6 to recorded radius entries.

    Normalization calls this before the mandate-read filter when the flag is
    true. The feature-folder glob is always kept.

    Args:
        entries (Sequence[str]): Recorded entries already accepted by the
            current classifier.
        root_surfaces (Sequence[str]): Configured separator-free root surfaces.
        path_roots (Sequence[str]): Configured first segments for W4.

    Returns:
        tuple[str, ...]: Surviving entries, deduplicated and ordinally sorted.
    """
    return tuple(
        sorted(
            {
                entry
                for entry in entries
                if is_feature_folder_glob(entry)
                or _passes_token_rules(entry, root_surfaces, path_roots)
            }
        )
    )


def select_plan_paths(
    plan_text: str, config: Mapping[str, object], *, root_surfaces: Sequence[str]
) -> tuple[str, ...]:
    """Select the plan-side extractor from the truth table's flag.

    This is the single selector shared by derivation and by validation rules V1
    and V2, which is what keeps a derived radius passing V1 and V2 against its
    own plan in both modes.

    Args:
        plan_text (str): Full atomic-plan document text.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
        root_surfaces (Sequence[str]): Configured separator-free root surfaces.

    Returns:
        tuple[str, ...]: The write-intent plan paths when the flag is true, and
        exactly ``extract_plan_paths`` otherwise.

    Raises:
        TypeError: If either write-intent key has a wrong type.
        ValueError: If a ``path_roots`` entry is blank.
    """
    if config_write_intent_extraction(config):
        return extract_write_intent_plan_paths(
            plan_text, root_surfaces=root_surfaces, path_roots=config_path_roots(config)
        )
    return extract_plan_paths(plan_text, root_surfaces=root_surfaces)
