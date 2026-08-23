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
    Classification itself, line partitioning, inline-code extraction, and
    contract-identifier harvesting stay in
    ``scripts/dev_tools/_blast_radius_extraction.py``; radius construction,
    module resolution, and finding emission stay in the facade.

Usage:
    ``classify_path_token`` calls both predicates as rejection tests. This
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
    - Both predicates are total on every ``str``, including the empty string, a
      token consisting only of a marker, and a bare bracket pair. Neither
      raises for any input.
    - ``.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`` mirrors this
      module; this Python module remains the authoritative reference.

Side Effects:
    None. Every function is pure: no filesystem access, no subprocess, no
    network, and no wall-clock reads.
"""

from __future__ import annotations

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
