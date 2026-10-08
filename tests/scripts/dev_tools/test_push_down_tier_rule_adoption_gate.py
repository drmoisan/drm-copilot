"""Regression contract for issue #823: the pushed tier rule is gated on adoption.

The push-down copies the Claude rules and the Codex skills verbatim into
consuming repositories. Before issue #823 those copies stated, without a
condition, that every project must be classified in ``quality-tiers.yml`` and
that an unclassified project fails CI, and they set coverage figures with no
precedence for a consuming repository's own root instructions. These tests pin
the adoption-gated wording in the repo-local copies and in their bundled
mirrors under ``extensions/drm-copilot/resources/``.

Every search runs over whitespace-normalized text, so a reflowed sentence is
still found. The module reads repository files only: it creates no file, starts
no process, and consults no external service.
"""

from __future__ import annotations

from pathlib import Path

import pytest

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]

CLAUDE_BUNDLE = "extensions/drm-copilot/resources/claude-customizations/"
CODEX_BUNDLE = "extensions/drm-copilot/resources/codex-and-agents-customizations/"

CLAUDE_QUALITY_TIERS = ".claude/rules/quality-tiers.md"
CLAUDE_GENERAL_CODE_CHANGE = ".claude/rules/general-code-change.md"
CLAUDE_GENERAL_UNIT_TEST = ".claude/rules/general-unit-test.md"
CLAUDE_FEATURE_REVIEW_AGENT = ".claude/agents/feature-review.md"
CLAUDE_FEATURE_REVIEW_SKILL = ".claude/skills/feature-review-workflow/SKILL.md"
CODEX_QUALITY_TIERS = ".agents/skills/quality-tiers/SKILL.md"
CODEX_GENERAL_CODE_CHANGE = ".agents/skills/general-code-change/SKILL.md"
CODEX_GENERAL_UNIT_TEST = ".agents/skills/general-unit-test/SKILL.md"


def claude_copies(relative_path: str) -> tuple[str, str]:
    """Return the repo-local path and the Claude bundle mirror path."""

    return (relative_path, CLAUDE_BUNDLE + relative_path)


def codex_copies(relative_path: str) -> tuple[str, str]:
    """Return the repo-local path and the Codex bundle mirror path."""

    return (relative_path, CODEX_BUNDLE + relative_path)


QUALITY_TIERS_COPIES = (
    *claude_copies(CLAUDE_QUALITY_TIERS),
    *codex_copies(CODEX_QUALITY_TIERS),
)
GENERAL_CODE_CHANGE_COPIES = (
    *claude_copies(CLAUDE_GENERAL_CODE_CHANGE),
    *codex_copies(CODEX_GENERAL_CODE_CHANGE),
)
GENERAL_UNIT_TEST_COPIES = (
    *claude_copies(CLAUDE_GENERAL_UNIT_TEST),
    *codex_copies(CODEX_GENERAL_UNIT_TEST),
)
CLAUDE_PRECEDENCE_COPIES = (
    *claude_copies(CLAUDE_QUALITY_TIERS),
    *claude_copies(CLAUDE_GENERAL_UNIT_TEST),
)
CODEX_PRECEDENCE_COPIES = (
    *codex_copies(CODEX_QUALITY_TIERS),
    *codex_copies(CODEX_GENERAL_UNIT_TEST),
)
CODEX_SKILL_COPIES = (
    *codex_copies(CODEX_QUALITY_TIERS),
    *codex_copies(CODEX_GENERAL_CODE_CHANGE),
    *codex_copies(CODEX_GENERAL_UNIT_TEST),
)
FEATURE_REVIEW_COPIES = (
    *claude_copies(CLAUDE_FEATURE_REVIEW_AGENT),
    *claude_copies(CLAUDE_FEATURE_REVIEW_SKILL),
)
FEATURE_REVIEW_AGENT_COPIES = claude_copies(CLAUDE_FEATURE_REVIEW_AGENT)
ALL_COPIES = (
    *QUALITY_TIERS_COPIES,
    *GENERAL_CODE_CHANGE_COPIES,
    *GENERAL_UNIT_TEST_COPIES,
    *FEATURE_REVIEW_COPIES,
)
EXPECTED_COPY_COUNT = 16

# Legacy sentences that bound every consuming repository to tiers it never adopted.
LEGACY_CLASSIFICATION_SENTENCE = (
    "Every project must be classified in `quality-tiers.yml` at repo root."
)
LEGACY_CI_SENTENCE = "Adding a project without a tier classification fails CI."

ADOPTION_GATE_FRAGMENTS = (
    "applies only when `quality-tiers.yml` exists at the repository root",
    "is not a defect",
)
TIER_SECTION_FRAGMENTS = (
    "only when `quality-tiers.yml` exists at the repository root",
    "has not adopted tiers",
)
TEST_CATEGORIES_FRAGMENTS = (
    "tier-dependent obligations apply only when `quality-tiers.yml` exists at "
    "the repository root",
)
CLAUDE_PRECEDENCE_FRAGMENTS = (
    "Threshold precedence: when the repository's root `CLAUDE.md` states line "
    "or branch coverage thresholds, those thresholds govern.",
    "defaults that apply only when the root `CLAUDE.md` states none",
    "every restatement of these figures",
)
CODEX_PRECEDENCE_FRAGMENTS = (
    "Threshold precedence: when the repository's root `AGENTS.md` states line "
    "or branch coverage thresholds, those thresholds govern;",
    "thresholds stated in the repository's root `CLAUDE.md` govern",
    "defaults that apply only when neither root `AGENTS.md` nor root "
    "`CLAUDE.md` states thresholds",
    "every restatement of these figures",
)
CONSUMING_PRODUCT_TOKENS = ("TaskMaster", "No-COM", "SpamBayes", "Outlook")
HARM_MODEL_SENTENCES = (
    "Behavior bugs cause silent data loss, model drift, or security holes.",
    "Bugs cause feature regressions but not data loss.",
    "Glue around APIs the team does not own.",
)
BROKEN_CODEX_CITATION = ".agents/skills/quality-tiers.md"
CODEX_TIER_SKILL_CITATION = "`.agents/skills/quality-tiers/SKILL.md`"
REPOSITORY_SCOPE_PHRASE = "in this repository"
UNIT_TEST_SCOPE_PHRASE = "not used in this repository"
UNIFORM_TIER_CITATION = "uniform tier rule"
FEATURE_REVIEW_FRAGMENTS = (
    "root `CLAUDE.md`",
    "record tier classification as not applicable",
    "tier-classification check",
)
RETIRED_REVIEW_THRESHOLDS = ("80%", "90%")
GOVERNING_THRESHOLD_FRAGMENT = "governing repo-wide threshold"


def read_copy(relative_path: str) -> str:
    """Return the UTF-8 text of one committed copy; reads disk, writes nothing."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def normalize_whitespace(text: str) -> str:
    """Collapse every whitespace run, including line breaks, to one space."""

    return " ".join(text.split())


def present_fragments(text: str, fragments: tuple[str, ...]) -> list[str]:
    """Return the fragments found in ``text`` after whitespace normalization."""

    normalized = normalize_whitespace(text)
    return [item for item in fragments if normalize_whitespace(item) in normalized]


def missing_fragments(text: str, fragments: tuple[str, ...]) -> list[str]:
    """Return the fragments absent from ``text`` after whitespace normalization."""

    found = present_fragments(text, fragments)
    return [item for item in fragments if item not in found]


def preamble(text: str) -> str:
    """Return the lines before the first ``## `` heading; ``###`` does not end it."""

    kept: list[str] = []
    # Collect lines until the first level-two heading.
    for line in text.splitlines():
        if line.startswith("## "):
            break
        kept.append(line)
    return "\n".join(kept)


def section(text: str, heading: str) -> str:
    """Return a ``## `` section through the next ``## `` heading, or ``""``."""

    lines = text.splitlines()
    for start, line in enumerate(lines):
        if line.rstrip() != heading:
            continue
        collected = [line]
        # Extend the section until the next level-two heading.
        for following in lines[start + 1 :]:
            if following.startswith("## "):
                break
            collected.append(following)
        return "\n".join(collected)
    return ""


def test_every_scanned_copy_exists() -> None:
    """Require all sixteen scanned copies to exist as distinct files."""

    # Arrange
    distinct = set(ALL_COPIES)

    # Act
    missing = [path for path in ALL_COPIES if not (REPO_ROOT / path).is_file()]

    # Assert
    assert len(distinct) == EXPECTED_COPY_COUNT, f"scanned set: {sorted(distinct)}"
    assert missing == [], f"scanned copies missing: {missing}"


@pytest.mark.parametrize("relative_path", ALL_COPIES)
def test_copy_omits_legacy_classification_sentence(relative_path: str) -> None:
    """Forbid the unconditional classification sentence in every copy."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    found = present_fragments(text, (LEGACY_CLASSIFICATION_SENTENCE,))

    # Assert
    assert found == [], f"{relative_path} still states: {found}"


@pytest.mark.parametrize("relative_path", ALL_COPIES)
def test_copy_omits_unconditional_ci_sentence(relative_path: str) -> None:
    """Forbid the unconditional tier-classification CI sentence in every copy."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    found = present_fragments(text, (LEGACY_CI_SENTENCE,))

    # Assert
    assert found == [], f"{relative_path} still states: {found}"


@pytest.mark.parametrize("relative_path", QUALITY_TIERS_COPIES)
def test_quality_tiers_preamble_states_adoption_gate(relative_path: str) -> None:
    """Require the adoption gate before the first level-two heading."""

    # Arrange
    text = preamble(read_copy(relative_path))

    # Act
    missing = missing_fragments(text, ADOPTION_GATE_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} preamble lacks: {missing}"


@pytest.mark.parametrize("relative_path", QUALITY_TIERS_COPIES)
def test_quality_tiers_copy_drops_repo_scope_phrase(relative_path: str) -> None:
    """Forbid the phrase that scoped the tier rule to one repository."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    found = present_fragments(text, (REPOSITORY_SCOPE_PHRASE,))

    # Assert
    assert found == [], f"{relative_path} still says: {found}"


@pytest.mark.parametrize("relative_path", QUALITY_TIERS_COPIES)
def test_quality_tiers_copy_names_no_consuming_product(relative_path: str) -> None:
    """Forbid consuming-product names and keep the harm-model definitions."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    product_names = [token for token in CONSUMING_PRODUCT_TOKENS if token in text]
    missing_harm_models = missing_fragments(text, HARM_MODEL_SENTENCES)

    # Assert
    assert product_names == [], f"{relative_path} names: {product_names}"
    assert missing_harm_models == [], f"{relative_path} lost: {missing_harm_models}"


@pytest.mark.parametrize("relative_path", GENERAL_CODE_CHANGE_COPIES)
def test_general_code_change_tier_section_is_conditional(relative_path: str) -> None:
    """Require the Module Rigor Tiers section to state the adoption condition."""

    # Arrange
    text = section(read_copy(relative_path), "## Module Rigor Tiers")

    # Act
    missing = missing_fragments(text, TIER_SECTION_FRAGMENTS)

    # Assert
    assert text != "", f"{relative_path} has no `## Module Rigor Tiers` section"
    assert missing == [], f"{relative_path} tier section lacks: {missing}"


@pytest.mark.parametrize("relative_path", GENERAL_UNIT_TEST_COPIES)
def test_general_unit_test_copy_drops_repo_scope_phrase(relative_path: str) -> None:
    """Forbid the sentence that scoped the tier thresholds to one repository."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    found = present_fragments(text, (UNIT_TEST_SCOPE_PHRASE,))

    # Assert
    assert found == [], f"{relative_path} still says: {found}"


@pytest.mark.parametrize("relative_path", GENERAL_UNIT_TEST_COPIES)
def test_unit_test_categories_gate_tier_obligations(relative_path: str) -> None:
    """Require the Test Categories section to gate tier-dependent obligations."""

    # Arrange
    text = section(read_copy(relative_path), "## Test Categories")

    # Act
    missing = missing_fragments(text, TEST_CATEGORIES_FRAGMENTS)

    # Assert
    assert text != "", f"{relative_path} has no `## Test Categories` section"
    assert missing == [], f"{relative_path} test categories lack: {missing}"


@pytest.mark.parametrize("relative_path", CLAUDE_PRECEDENCE_COPIES)
def test_claude_copy_states_claude_md_precedence(relative_path: str) -> None:
    """Require the root CLAUDE.md coverage-threshold precedence statement."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    missing = missing_fragments(text, CLAUDE_PRECEDENCE_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} precedence lacks: {missing}"


@pytest.mark.parametrize("relative_path", CODEX_PRECEDENCE_COPIES)
def test_codex_copy_states_agents_md_precedence(relative_path: str) -> None:
    """Require the root AGENTS.md then CLAUDE.md threshold precedence statement."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    missing = missing_fragments(text, CODEX_PRECEDENCE_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} precedence lacks: {missing}"


@pytest.mark.parametrize("relative_path", CODEX_SKILL_COPIES)
def test_codex_skill_copy_cites_existing_tier_skill(relative_path: str) -> None:
    """Require the existing tier-skill path and forbid the non-existent one."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    broken = present_fragments(text, (BROKEN_CODEX_CITATION,))
    cited = present_fragments(text, (CODEX_TIER_SKILL_CITATION,))

    # Assert
    assert broken == [], f"{relative_path} cites a missing path: {broken}"
    assert cited == [CODEX_TIER_SKILL_CITATION], f"{relative_path} lacks citation"


@pytest.mark.parametrize("relative_path", FEATURE_REVIEW_COPIES)
def test_feature_review_copy_gates_tier_finding(relative_path: str) -> None:
    """Require adoption-gated tier findings and the CLAUDE.md precedence."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    retired = present_fragments(text, (UNIFORM_TIER_CITATION,))
    missing = missing_fragments(text, FEATURE_REVIEW_FRAGMENTS)

    # Assert
    assert retired == [], f"{relative_path} still cites: {retired}"
    assert missing == [], f"{relative_path} lacks: {missing}"


@pytest.mark.parametrize("relative_path", FEATURE_REVIEW_AGENT_COPIES)
def test_review_agent_copy_uses_governing_thresholds(relative_path: str) -> None:
    """Forbid the 80/90 figures and require the governing-threshold wording."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    retired = [token for token in RETIRED_REVIEW_THRESHOLDS if token in text]
    governing = present_fragments(text, (GOVERNING_THRESHOLD_FRAGMENT,))

    # Assert
    assert retired == [], f"{relative_path} still states: {retired}"
    assert governing == [GOVERNING_THRESHOLD_FRAGMENT], f"{relative_path} lacks it"


def test_legacy_detection_flags_wrapped_legacy_sentences() -> None:
    """Prove the detection can fail: wrapped legacy sentences are flagged."""

    # Arrange
    synthetic = (
        "## Module Rigor Tiers\n\nTiers are defined elsewhere. Every project must"
        "\nbe classified in `quality-tiers.yml` at repo root. Adding a project\n"
        "without a tier classification fails CI.\n"
    )

    # Act
    found = present_fragments(
        synthetic, (LEGACY_CLASSIFICATION_SENTENCE, LEGACY_CI_SENTENCE)
    )

    # Assert
    assert found == [LEGACY_CLASSIFICATION_SENTENCE, LEGACY_CI_SENTENCE]


def test_legacy_detection_accepts_adoption_gated_wording() -> None:
    """Gated wording that keeps the obligation conditional is not flagged."""

    # Arrange
    synthetic = (
        "Tiers apply only when `quality-tiers.yml` exists at the repository root;"
        " in that case every project must be classified in it. A repository"
        " without `quality-tiers.yml` has not adopted tiers. A repository that"
        " runs a `tier-classification` CI stage fails CI for an unclassified"
        " project.\n"
    )

    # Act
    found = present_fragments(
        synthetic, (LEGACY_CLASSIFICATION_SENTENCE, LEGACY_CI_SENTENCE)
    )
    missing = missing_fragments(synthetic, TIER_SECTION_FRAGMENTS)

    # Assert
    assert found == []
    assert missing == []


def test_preamble_and_section_split_on_level_two_headings() -> None:
    """Level-two headings bound the preamble and sections; level three does not."""

    # Arrange
    synthetic = (
        "# Title\n\nGate text.\n\n## Tiers\n\n### Detail\nBody text.\n\n"
        "## Next\nTail text.\n"
    )

    # Act
    head = preamble(synthetic)
    tiers = section(synthetic, "## Tiers")
    absent = section(synthetic, "## Missing")

    # Assert
    assert "Gate text." in head
    assert "Body text." not in head
    assert "### Detail" in tiers
    assert "Body text." in tiers
    assert "Tail text." not in tiers
    assert absent == ""
