"""Unit tests for the unconditional extraction rules of the path classifier.

Cover the four shape rules the extractor applies so that a plan citation is
admitted only when it is evidence of a write: directory-shaped token rejection
and cross-corpus documentation-glob rejection plus letterless contract-token
rejection (issue #489), and placeholder-marker rejection (issue #502). Every
input is an in-memory literal; no temporary file is created and no external
process is started.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools._blast_radius_extraction import (
    PATH_KIND_CONCRETE,
    PATH_KIND_GLOB,
    classify_path_token,
    extract_contract_identifiers,
    extract_plan_paths,
)

# A minimal spec whose single qualifying heading puts every following inline
# token inside a contract section. ``{identifier}`` is substituted per case.
CONTRACT_SPEC_TEMPLATE = "## Interface\n\nThe surface exposes `{identifier}` here.\n"


@pytest.mark.parametrize(
    "token",
    [
        "extensions/drm-copilot",
        "scripts/dev_tools",
        "docs/features",
        ".claude/rules/",
        "artifacts/pr_context/",
    ],
)
def test_classify_path_token_rejects_a_directory_shaped_token(token: str) -> None:
    """Reject a wildcard-free token whose final component names no file.

    A directory reference is where work happens, not what it writes; admitting
    it made every item touching anything under that directory contend at the
    path level (issue #489).
    """
    # Arrange / Act
    kind = classify_path_token(token)

    # Assert
    assert kind is None, f"Expected {token!r} to be rejected; observed {kind!r}."


def test_classify_path_token_admits_a_subtree_glob_claim() -> None:
    """A ``**`` subtree claim is a deliberate write claim and stays admitted."""
    # Arrange / Act / Assert
    assert classify_path_token("scripts/dev_tools/**") == PATH_KIND_GLOB


def test_classify_path_token_admits_a_line_suffixed_file_citation() -> None:
    """A ``:<line>`` suffix does not turn a file citation into a non-path."""
    # Arrange / Act / Assert
    assert classify_path_token(".claude/rules/python.md:90") == PATH_KIND_CONCRETE


def test_classify_path_token_admits_an_extension_bearing_file() -> None:
    """An ordinary repository file reference is unaffected by the new rule."""
    # Arrange / Act / Assert
    assert (
        classify_path_token("scripts/dev_tools/compute_blast_radius.py")
        == PATH_KIND_CONCRETE
    )


def test_classify_path_token_rejects_the_artifacts_subtree_glob() -> None:
    """``artifacts/`` is no longer a known segment, so its subtree glob drops.

    The process-artifact tree is read by mandate rather than written by a work
    item, so a bare ``artifacts/**`` claim is not evidence of contention.
    """
    # Arrange / Act
    kind = classify_path_token("artifacts/**")

    # Assert
    assert kind is None, f"Expected artifacts/** to be rejected; observed {kind!r}."


@pytest.mark.parametrize(
    "token",
    [
        "docs/features/**/plan*.md",
        "docs/features/active/*/plan.md",
        "docs/features/**",
    ],
)
def test_classify_path_token_rejects_a_cross_corpus_doc_glob(token: str) -> None:
    """Reject a documentation glob whose wildcard spans every feature folder.

    Two unrelated work items both write documentation, so a corpus-wide glob
    made them contend on a claim neither of them actually asserted (#489).
    """
    # Arrange / Act
    kind = classify_path_token(token)

    # Assert
    assert kind is None, f"Expected {token!r} to be rejected; observed {kind!r}."


def test_classify_path_token_retains_an_own_feature_folder_doc_glob() -> None:
    """A glob naming one complete feature folder is a genuine write claim."""
    # Arrange
    own_folder_glob = (
        "docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/**"
    )

    # Act / Assert
    assert classify_path_token(own_folder_glob) == PATH_KIND_GLOB


def test_classify_path_token_retains_a_doc_glob_outside_the_feature_corpus() -> None:
    """The cross-corpus rule is scoped to ``docs/features/`` and nothing else."""
    # Arrange / Act / Assert
    assert classify_path_token("scripts/dev_tools/**") == PATH_KIND_GLOB


@pytest.mark.parametrize("notation", ["->", "{", "=", "0"])
def test_extract_contract_identifiers_rejects_a_letterless_token(
    notation: str,
) -> None:
    """Reject punctuation-only notation harvested from an interface section.

    Notation such as an arrow or a brace appears in nearly every interface
    section, so admitting it made unrelated specs contend at the contract
    level on a token that names nothing (issue #489).
    """
    # Arrange
    spec_text = CONTRACT_SPEC_TEMPLATE.format(identifier=notation)

    # Act
    identifiers = extract_contract_identifiers(spec_text)

    # Assert
    assert notation not in identifiers, (
        f"Expected the letterless token {notation!r} to be dropped; observed "
        f"{identifiers}."
    )


def test_extract_contract_identifiers_retains_a_letterless_adjacent_identifier() -> (
    None
):
    """A letter-bearing identifier in the same section is still harvested."""
    # Arrange
    spec_text = CONTRACT_SPEC_TEMPLATE.format(identifier="normalize_declared_radius")

    # Act
    identifiers = extract_contract_identifiers(spec_text)

    # Assert
    assert identifiers == ("normalize_declared_radius",)


# One probe per placeholder or interpolation marker under repair (issue #502).
# Each probe carries exactly one marker so a failure names the marker that
# regressed rather than a token that happens to carry several. The angle-bracket
# probes are deliberately not a matched pair: a single bracket is enough to
# prove the marker is what the guard reads, and a matched pair would make the
# two cases indistinguishable. Every literal is written out in full rather than
# assembled, because a Python string literal performs no interpolation and the
# text below is exactly what reaches the classifier.
PLACEHOLDER_MARKER_PROBES = [
    pytest.param("docs/features/active/<feature/plan.md", id="angle-open"),
    pytest.param("docs/features/active/feature>/plan.md", id="angle-close"),
    pytest.param(".claude/state/${session_id}.json", id="dollar-brace"),
    pytest.param(".claude/state/$(session).json", id="dollar-paren"),
    pytest.param(".claude/state/%SESSION%.json", id="percent"),
]


@pytest.mark.parametrize("token", PLACEHOLDER_MARKER_PROBES)
def test_classify_path_token_rejects_placeholder_marker(token: str) -> None:
    """Reject a token carrying a placeholder or interpolation marker.

    A marker-bearing token is a command or artifact *shape*, not a write
    claim: it names no file, and on Windows the angle brackets cannot appear
    in a path at all. Admitting one made every item that cited the same
    mandated artifact shape contend at the path level on a string that
    resolves to nothing (issue #502).
    """
    # Arrange / Act
    kind = classify_path_token(token)

    # Assert
    assert kind is None, f"Expected {token!r} to be rejected; observed {kind!r}."


def test_real_path_on_same_task_line_survives_placeholder_rejection() -> None:
    """A real path cited beside a placeholder token is still harvested.

    The guard must drop the marker-bearing token only. Dropping the whole line,
    or the whole task, would silently narrow a genuine write claim, so this is
    the positive control that pins the rejection's scope to one token.

    This control asserts survival only, and deliberately makes no claim about
    the placeholder token itself. That is what lets it hold both before and
    after the guard exists: the rejection is asserted by the parametrized
    marker cases, so duplicating it here would turn the positive control into a
    second copy of the same negative assertion and it could no longer show that
    the guard's scope stayed narrow across the change.
    """
    # Arrange
    plan_text = (
        "### Phase 0 - Baseline\n"
        "\n"
        "- [ ] [P0-T1] Write the evidence artifact "
        "`<FEATURE>/evidence/baseline/phase0-instructions-read.md` and edit "
        "`scripts/dev_tools/compute_blast_radius.py`.\n"
    )

    # Act
    paths = extract_plan_paths(plan_text)

    # Assert
    assert "scripts/dev_tools/compute_blast_radius.py" in paths, (
        "Expected the real path cited on the same task line to survive; observed "
        f"{paths}."
    )
