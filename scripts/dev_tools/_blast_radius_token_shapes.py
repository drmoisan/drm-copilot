"""Token-shape predicates that decide whether a citation is a write claim.

Purpose:
    Hold the pure, context-free shape tests that reject an inline-code token
    before the blast-radius classifier can record it as a repository path. A
    token can look like a path and still name no file: a placeholder or
    interpolation marker makes it a command or artifact *shape*, and a
    corpus-wide documentation glob makes it a cross-corpus claim. Neither is
    evidence that a work item will write anything.

Responsibilities:
    Own the placeholder-marker vocabulary and the two shape predicates
    ``contains_placeholder_marker`` and ``spans_multiple_feature_folders``,
    together with the documentation-corpus constants the second one reads.
    Also own the file-shape predicate ``is_file_shaped_component``, its
    extension pattern ``FILE_EXTENSION_PATTERN_TEXT``, and the closed
    ``KNOWN_FILE_NAMES`` set, which ``classify_path_token`` uses in place of
    the former extension allowlist to decide whether a final path component
    names a file (issue #797). Classification itself, line partitioning,
    inline-code extraction, and contract-identifier harvesting stay in
    ``scripts/dev_tools/_blast_radius_extraction.py``; radius construction,
    module resolution, and finding emission stay in the facade.

Usage:
    ``classify_path_token`` calls the two shape predicates as rejection tests
    and ``is_file_shaped_component`` as its file-shape acceptance test. This
    module is a leaf: it imports nothing from the blast-radius library, so it
    can be imported by the extraction module without any possibility of a
    cycle. That constraint is the reason the module exists as a separate file
    rather than as a section of the extraction module, which had two lines of
    headroom against the 500-line limit when this shape rule was added.

Invariants / Constraints:
    - ``PLACEHOLDER_MARKERS`` is a module constant, not a configuration key.
      The marker set describes what a path can never contain, not a policy
      choice a repository could tune, so there is nothing for an operator to
      configure and no truth-table key to read.
    - ``PLACEHOLDER_MARKERS`` is character-identical to the tuple of the same
      name in ``scripts/dev_tools/plan_gate_coverage.py``. The two subsystems
      answer the same question about the same text, so a test pins them equal
      rather than leaving the agreement to convention.
    - Every predicate is total on every ``str``, including the empty string, a
      token consisting only of a marker, a bare bracket pair, and a lone dot.
      None raises for any input.
    - ``KNOWN_FILE_NAMES`` and ``FILE_EXTENSION_PATTERN_TEXT`` are code
      constants, not configuration keys. The extension pattern uses explicit
      ASCII classes and whole-string matching so the PowerShell port accepts
      exactly the same components.
    - ``.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`` mirrors this
      module; this Python module remains the authoritative reference. A Pester
      parity test reads ``KNOWN_FILE_NAMES`` and ``FILE_EXTENSION_PATTERN_TEXT``
      from this source and pins the PowerShell values equal to them.

Side Effects:
    None. Every function is pure: no filesystem access, no subprocess, no
    network, and no wall-clock reads.
"""

from __future__ import annotations

import re

# Placeholder and interpolation markers. A token carrying any of these was
# written to document a shape, not to name a file, so it can never be a write
# claim. The set is character-identical to PLACEHOLDER_MARKERS in
# ``scripts/dev_tools/plan_gate_coverage.py``, whose origin is the
# checkable-literal placeholder guard recorded in
# ``.claude/rules/plan-acceptance-gates.md``.
#
# The angle brackets are the dominant corpus shape and are also the strongest
# case: Windows forbids both characters in a filename outright, so an
# angle-bracketed token cannot name a file on the platform this repository is
# developed on. The two dollar forms are shell and PowerShell interpolation, and
# the percent form is the Windows shell's environment-variable syntax; each
# resolves at run time to text that is not in the token.
PLACEHOLDER_MARKERS: tuple[str, ...] = ("<", ">", "${", "$(", "%")

# Documentation-corpus root and the index, counted after that prefix, of the
# segment that names one feature folder. A glob whose wildcard reaches this
# segment or any earlier one claims every feature folder in the corpus.
FEATURE_CORPUS_PREFIX = "docs/features/"
FEATURE_FOLDER_SEGMENT_INDEX = 1

# File-shape extension pattern (issue #797). A final component names a file when
# the text after its last dot, lower-cased, is an ASCII letter followed by ASCII
# letters or digits. Explicit ASCII classes are used instead of ``\w`` so the
# .NET port, which anchors the same text with ``\A`` and ``\z``, matches exactly
# the same inputs. A digit-led tail (a version such as ``v1.2.0``) and a tail
# carrying punctuation do not match.
FILE_EXTENSION_PATTERN_TEXT = "[a-z][a-z0-9]*"
FILE_EXTENSION_RE = re.compile(FILE_EXTENSION_PATTERN_TEXT)

# Known extensionless file names and dotfiles (issue #797). A final component
# that is an exact, case-sensitive member names a file even though it carries no
# dotted extension, or carries only a leading dot. The set is closed: extending
# it is a data-only change made together with the PowerShell port, whose Pester
# parity test reads this constant from the source text and pins the two equal.
KNOWN_FILE_NAMES: frozenset[str] = frozenset(
    (
        "Dockerfile Makefile LICENSE CODEOWNERS NOTICE .gitignore .gitattributes "
        ".gitkeep .gitmodules .vscodeignore .npmignore .npmrc .nvmrc .editorconfig "
        ".prettierrc .prettierignore .eslintignore .shellcheckrc"
    ).split()
)


def contains_placeholder_marker(token: str) -> bool:
    """Report whether a token carries a placeholder or interpolation marker.

    A marker-bearing token documents a shape rather than naming a file. Two
    work items that cite the same mandated artifact shape therefore acquired a
    path-level conflict edge on a string that resolves to nothing, which made
    thematically unrelated items contend and serialized runs that had no reason
    to serialize (issue #502).

    The test is a plain substring scan over a fixed vocabulary, deliberately
    context-free: it needs no repository lookup, no configuration, and no
    knowledge of which segment the marker sits in. A marker anywhere in the
    token is disqualifying, including in the filename position, because an
    interpolated filename is as unresolvable as an interpolated directory.

    Args:
        token (str): A single whitespace-free inline-code token. The empty
            string is accepted and reports ``False``.

    Returns:
        bool: ``True`` when any member of ``PLACEHOLDER_MARKERS`` appears
        anywhere in ``token``, otherwise ``False``.

    Raises:
        None.

    Side Effects:
        None; the input is not mutated.
    """

    return any(marker in token for marker in PLACEHOLDER_MARKERS)


def spans_multiple_feature_folders(token: str) -> bool:
    """Report whether a glob claims more than one documentation feature folder.

    The documentation corpus is laid out as
    ``docs/features/<bucket>/<feature-folder>/...``. A glob whose wildcard
    occupies or truncates the feature-folder segment therefore claims every
    feature folder in the corpus, which made two unrelated work items contend
    purely because both wrote documentation (issue #489). A glob that carries a
    complete, wildcard-free feature-folder segment claims one folder and is
    retained.

    Args:
        token (str): A wildcard-bearing token already accepted by the shape
            rules of ``classify_path_token``.

    Returns:
        bool: ``True`` when the token is rooted in the documentation corpus and
        its wildcard reaches the feature-folder segment or any earlier one;
        ``False`` for every other token, including one rooted elsewhere.

    Raises:
        None.

    Side Effects:
        None.
    """
    if not token.startswith(FEATURE_CORPUS_PREFIX):
        return False

    segments = token[len(FEATURE_CORPUS_PREFIX) :].split("/")

    # A token that stops at or before the feature-folder segment has had that
    # segment truncated away by the wildcard, so it spans the whole corpus.
    if len(segments) <= FEATURE_FOLDER_SEGMENT_INDEX:
        return True

    # Every segment up to and including the feature-folder name must be a
    # literal for the claim to resolve to exactly one folder.
    naming = segments[: FEATURE_FOLDER_SEGMENT_INDEX + 1]
    return any("*" in segment for segment in naming)


def is_file_shaped_component(component: str) -> bool:
    """Report whether a final path component names a file (issue #797).

    The classifier formerly admitted a wildcard-free token only when its
    extension appeared in a fixed allowlist, so files a plan writes with an
    unlisted extension (``.bats``, ``.cjs``, ``.out``), dotfiles, and
    extensionless names were dropped from the derived radius. This predicate
    replaces that allowlist with a structural rule. It still rejects the
    directory-shaped tokens of issue #489: a component with no dot, a
    dot-leading component outside the known-name set (``.claude``, ``.git``), a
    digit-led tail, and a trailing dot all return ``False``.

    Args:
        component (str): The final path component, after any ``:<line>``
            suffix has been stripped. The empty string is accepted and reports
            ``False``.

    Returns:
        bool: ``True`` when ``component`` is an ordinal member of
        ``KNOWN_FILE_NAMES``, or when it has a non-empty stem before its last
        dot and the lower-cased text after that dot fully matches
        ``FILE_EXTENSION_PATTERN_TEXT``; otherwise ``False``.

    Raises:
        None.

    Side Effects:
        None; the input is not mutated.
    """
    if component in KNOWN_FILE_NAMES:
        return True

    stem, separator, extension = component.rpartition(".")
    if not separator or not stem:
        return False

    return FILE_EXTENSION_RE.fullmatch(extension.lower()) is not None
