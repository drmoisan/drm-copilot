"""Regression contract for the issue #824 Addendum 2 follow-ups.

The file pins FU-823-2, FU-823-3, FU-823-5, and review note A over the
repo-local copies and their bundled mirrors under
``extensions/drm-copilot/resources/``: the pushed architecture and quota copies
name no consuming product, no pushed surface hard-codes a solution file, the
feature-review workflow's step 8 defers to the governing thresholds, and every
threshold-precedence copy states the per-metric fallback. A scan of every pushed
rule and skill file guards against the product names reappearing; the files in
``PRE_EXISTING_NAME_EXCEPTIONS`` are out of scope for issue #824 and are
checked for staleness.

Every phrase search runs over whitespace-normalized text, so a reflowed sentence
is still found. The module reads repository files only: it creates no file,
starts no process, and consults no external service.
"""

from __future__ import annotations

from pathlib import Path

import pytest

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]

CLAUDE_BUNDLE = "extensions/drm-copilot/resources/claude-customizations/"
CODEX_BUNDLE = "extensions/drm-copilot/resources/codex-and-agents-customizations/"
GITHUB_BUNDLE = "extensions/drm-copilot/resources/customizations/"

CONSUMING_NAMES = ("TaskMaster", "No-COM")
PRODUCT_NAME_COPIES = (
    ".claude/rules/architecture-boundaries.md",
    CLAUDE_BUNDLE + ".claude/rules/architecture-boundaries.md",
    ".agents/skills/architecture-boundaries/SKILL.md",
    CODEX_BUNDLE + ".agents/skills/architecture-boundaries/SKILL.md",
    ".claude/skills/quota-throttling/SKILL.md",
    CLAUDE_BUNDLE + ".claude/skills/quota-throttling/SKILL.md",
)

HARD_CODED_SOLUTION = "TaskMaster.sln"
SOLUTION_SURFACES = (
    ".github/instructions/csharp-code-change.instructions.md",
    GITHUB_BUNDLE + ".github/instructions/csharp-code-change.instructions.md",
    ".github/instructions/csharp-unit-test.instructions.md",
    GITHUB_BUNDLE + ".github/instructions/csharp-unit-test.instructions.md",
    ".github/agents/csharp-typed-engineer.agent.md",
    GITHUB_BUNDLE + ".github/agents/csharp-typed-engineer.agent.md",
    ".agents/skills/csharp/SKILL.md",
    CODEX_BUNDLE + ".agents/skills/csharp/SKILL.md",
    ".agents/skills/csharp-qa-gate/SKILL.md",
    CODEX_BUNDLE + ".agents/skills/csharp-qa-gate/SKILL.md",
    ".codex/codex-web-setup.sh",
    CODEX_BUNDLE + ".codex/codex-web-setup.sh",
    CODEX_BUNDLE + ".agents-variants/csharp-legacy/skills/csharp/SKILL.md",
    CODEX_BUNDLE + ".agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md",
)
SOLUTION_SCAN_ROOTS = (
    ".agents",
    ".codex",
    ".github",
    ".claude/rules",
    ".claude/skills",
    ".claude/agents",
    ".claude/hooks",
    ".claude/lib",
    "extensions/drm-copilot/resources",
)

STEP_EIGHT_COPIES = (
    ".claude/skills/feature-review-workflow/SKILL.md",
    CLAUDE_BUNDLE + ".claude/skills/feature-review-workflow/SKILL.md",
)
RETIRED_STEP_EIGHT_FIGURES = ("80%", "90%")
GOVERNING_THRESHOLDS_PHRASE = "governing thresholds"

FALLBACK_PHRASE = "falls back independently"
FALLBACK_COPIES = (
    ".claude/rules/quality-tiers.md",
    CLAUDE_BUNDLE + ".claude/rules/quality-tiers.md",
    ".claude/rules/general-unit-test.md",
    CLAUDE_BUNDLE + ".claude/rules/general-unit-test.md",
    ".agents/skills/quality-tiers/SKILL.md",
    CODEX_BUNDLE + ".agents/skills/quality-tiers/SKILL.md",
    ".agents/skills/general-unit-test/SKILL.md",
    CODEX_BUNDLE + ".agents/skills/general-unit-test/SKILL.md",
    ".claude/agents/feature-review.md",
    CLAUDE_BUNDLE + ".claude/agents/feature-review.md",
    ".claude/skills/feature-review-workflow/SKILL.md",
    CLAUDE_BUNDLE + ".claude/skills/feature-review-workflow/SKILL.md",
    ".claude/hooks/validate-feature-review-coverage.ps1",
    CLAUDE_BUNDLE + ".claude/hooks/validate-feature-review-coverage.ps1",
)
EXPECTED_LISTED_COPY_COUNT = 36

PUSHED_RULE_AND_SKILL_GLOBS: tuple[tuple[str, str], ...] = (
    (".claude/rules", "*.md"),
    (".claude/skills", "**/SKILL.md"),
    (".agents/skills", "**/SKILL.md"),
    (CLAUDE_BUNDLE + ".claude/rules", "*.md"),
    (CLAUDE_BUNDLE + ".claude/skills", "**/SKILL.md"),
    (CLAUDE_BUNDLE + ".claude-variants", "*/rules/*.md"),
    (CLAUDE_BUNDLE + ".claude-variants", "*/skills/**/SKILL.md"),
    (CODEX_BUNDLE + ".agents/skills", "**/SKILL.md"),
    (CODEX_BUNDLE + ".agents-variants", "*/skills/**/SKILL.md"),
)
# Pushed files outside the FU-823-2 listed set that still name a product. They
# are out of scope for issue #824 and recorded as a follow-up; the staleness
# test below fails once an entry no longer names one.
PRE_EXISTING_NAME_EXCEPTIONS: frozenset[str] = frozenset(
    {
        ".claude/rules/typescript.md",
        ".claude/rules/csharp.md",
        CLAUDE_BUNDLE + ".claude/rules/typescript.md",
        CLAUDE_BUNDLE + ".claude/rules/csharp.md",
    }
)


def read_copy(relative_path: str) -> str:
    """Return the UTF-8 text of one committed copy; reads disk, writes nothing."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def normalize_whitespace(text: str) -> str:
    """Collapse every whitespace run, including line breaks, to one space."""

    return " ".join(text.split())


def files_naming_solution() -> list[str]:
    """Return the sorted relative paths under the scan roots that name the solution."""

    needle = HARD_CODED_SOLUTION.encode("utf-8")
    found: list[str] = []
    for root in SOLUTION_SCAN_ROOTS:
        base = REPO_ROOT / root
        if not base.is_dir():
            continue
        for candidate in base.rglob("*"):
            if candidate.is_file() and needle in candidate.read_bytes():
                found.append(candidate.relative_to(REPO_ROOT).as_posix())
    return sorted(found)


def pushed_rule_and_skill_files() -> list[str]:
    """Return the sorted relative paths of every pushed rule and skill file."""

    found: set[str] = set()
    for root, pattern in PUSHED_RULE_AND_SKILL_GLOBS:
        for candidate in (REPO_ROOT / root).glob(pattern):
            if candidate.is_file():
                found.add(candidate.relative_to(REPO_ROOT).as_posix())
    return sorted(found)


def step_eight(text: str) -> str:
    """Return the lines of step 8 up to, not including, step 9, or an empty string."""

    lines = text.splitlines()
    start = next(
        (index for index, line in enumerate(lines) if line.startswith("8. **")), None
    )
    if start is None:
        return ""
    end = next(
        (
            index
            for index in range(start + 1, len(lines))
            if lines[index].startswith("9. **")
        ),
        len(lines),
    )
    return "\n".join(lines[start:end])


def test_every_follow_up_copy_exists() -> None:
    """Every copy this module pins is a committed file."""

    # Arrange
    listed = (
        *PRODUCT_NAME_COPIES,
        *SOLUTION_SURFACES,
        *STEP_EIGHT_COPIES,
        *FALLBACK_COPIES,
    )

    # Act
    missing = [path for path in listed if not (REPO_ROOT / path).is_file()]

    # Assert
    assert len(listed) == EXPECTED_LISTED_COPY_COUNT
    assert missing == [], f"missing copies: {missing}"


@pytest.mark.parametrize("relative_path", PRODUCT_NAME_COPIES)
def test_listed_copy_names_no_consuming_product(relative_path: str) -> None:
    """FU-823-2: the pushed copy names no consuming product (TaskMaster, No-COM)."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    found = [name for name in CONSUMING_NAMES if name in text]

    # Assert
    assert found == [], f"{relative_path} still names: {found}"


@pytest.mark.parametrize("relative_path", SOLUTION_SURFACES)
def test_surface_does_not_hard_code_solution_file(relative_path: str) -> None:
    """FU-823-3: the pushed surface does not hard-code the TaskMaster solution."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    hard_coded = HARD_CODED_SOLUTION in text

    # Assert
    assert not hard_coded, f"{relative_path} still names {HARD_CODED_SOLUTION}"


def test_pushed_roots_carry_no_hard_coded_solution_file() -> None:
    """FU-823-3: no file under the pushed roots names the TaskMaster solution."""

    # Arrange
    expected: list[str] = []

    # Act
    found = files_naming_solution()

    # Assert
    assert found == expected, f"files still naming the solution: {found}"


@pytest.mark.parametrize("relative_path", STEP_EIGHT_COPIES)
def test_review_workflow_step_eight_uses_governing_thresholds(
    relative_path: str,
) -> None:
    """FU-823-5: step 8 cites the governing thresholds, not the 80/90 figures."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    step = step_eight(text)
    retired = [figure for figure in RETIRED_STEP_EIGHT_FIGURES if figure in step]

    # Assert
    assert step != "", f"{relative_path} has no step 8"
    assert retired == [], f"{relative_path} step 8 still states: {retired}"
    assert GOVERNING_THRESHOLDS_PHRASE in normalize_whitespace(step)


@pytest.mark.parametrize("relative_path", FALLBACK_COPIES)
def test_precedence_copy_states_per_metric_fallback(relative_path: str) -> None:
    """Review note A: the precedence copy states that each metric falls back alone."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    normalized = normalize_whitespace(text)

    # Assert
    assert FALLBACK_PHRASE in normalized, f"{relative_path} lacks {FALLBACK_PHRASE}"


def test_consuming_product_detection_flags_a_reintroduced_name() -> None:
    """Prove the product-name check can fail: a reintroduced name is flagged."""

    # Arrange
    reintroduced = "- `TaskMaster.Domain` must have zero references to host types.\n"
    neutral = "- `<Product>.Domain` must have zero references to host types.\n"

    # Act
    flagged = [name for name in CONSUMING_NAMES if name in reintroduced]
    clean = [name for name in CONSUMING_NAMES if name in neutral]

    # Assert
    assert flagged == ["TaskMaster"]
    assert clean == []


def test_step_eight_extraction_stops_at_step_nine() -> None:
    """Step 8 extraction starts at step 8 and stops before step 9."""

    # Arrange
    synthetic = (
        "7. **Seven**\n   - seven body\n8. **Eight**\n   - eight body\n"
        "9. **Nine**\n   - nine body\n"
    )

    # Act
    step = step_eight(synthetic)

    # Assert
    assert step == "8. **Eight**\n   - eight body"


def test_pushed_rule_and_skill_scan_covers_the_listed_copies() -> None:
    """The pushed-file scan reaches every FU-823-2 listed copy."""

    # Arrange
    listed = set(PRODUCT_NAME_COPIES)

    # Act
    scanned = set(pushed_rule_and_skill_files())

    # Assert
    missed = sorted(listed - scanned)
    assert missed == [], f"scan misses listed copies: {missed}"


def test_pushed_rule_and_skill_files_name_no_consuming_product() -> None:
    """FU-823-2: no pushed rule or skill file names a consuming product."""

    # Arrange
    scanned = [
        path
        for path in pushed_rule_and_skill_files()
        if path not in PRE_EXISTING_NAME_EXCEPTIONS
    ]

    # Act
    offenders = [
        path
        for path in scanned
        if any(name in read_copy(path) for name in CONSUMING_NAMES)
    ]

    # Assert
    assert offenders == [], f"pushed files naming a product: {offenders}"


def test_name_exceptions_still_name_a_consuming_product() -> None:
    """Each documented exception still names a product, so the set is not stale."""

    # Arrange
    exceptions = sorted(PRE_EXISTING_NAME_EXCEPTIONS)

    # Act
    stale = [
        path
        for path in exceptions
        if not (REPO_ROOT / path).is_file()
        or not any(name in read_copy(path) for name in CONSUMING_NAMES)
    ]

    # Assert
    assert stale == [], f"remove stale entries from the exception set: {stale}"
