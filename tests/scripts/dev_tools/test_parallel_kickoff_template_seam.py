"""Producer/consumer seam tests for the parallel kickoff template.

Purpose:
    Bind the PRODUCER of parallel kickoff documents — the fenced ``markdown``
    template under ``## Kickoff Artifact`` in
    ``.claude/skills/parallel-plan/SKILL.md`` — to the CONSUMER that validates
    them, ``scripts/dev_tools/parallel_kickoff_contract.py``. The two surfaces
    are delivered by the same feature and were previously verified only against
    each other's hand-authored fixtures, which allowed the template and the
    matcher to disagree without any test failing.

Scope boundaries:
    Structural validation only. The suite reads one committed repository file
    and one committed fixture, renders documents as in-memory strings, and
    calls the contract module directly. It creates no files, starts no external
    process, and touches neither Git nor the network. Reading a committed
    runtime surface follows the convention already established by
    ``test_parallel_planner_surface_contracts.py``.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

from scripts.dev_tools.parallel_kickoff_contract import (
    RESUME_RE,
    parse_parallel_kickoff,
    validate_parallel_kickoff_text,
)

REPO_ROOT = Path(__file__).resolve().parents[3]

PARALLEL_PLAN_SKILL_RELATIVE = Path(".claude/skills/parallel-plan/SKILL.md")
VALID_KICKOFF_FIXTURE_RELATIVE = Path(
    "tests/fixtures/parallel_kickoff/valid-kickoff.md"
)

# Substitution values for the template's authoring placeholders. The TypeScript
# seam module `parallel-kickoff-template-seam.test.ts` uses byte-identical
# values so a rendering divergence between the runtimes cannot mask a contract
# divergence.
SLUG = "bugfix-batch"
ISO8601 = "2026-08-08T15:15:00Z"
PLANNING_COMMIT_HEX = "4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d"
PLAN_PATH = "docs/features/active/2026-08-07-parallel-planner-surface-443/plan.md"
PLAN_HASH_HEX = "9f2e4c7a1b5d8e0f3a6c9b2d5e8f1a4c7b0d3e6f"
ITEM_ROW = (
    "| 443 | docs/features/active/2026-08-07-parallel-planner-surface-443 "
    f"| 0 | C3 | feature/parallel-planner-surface-443 | {PLAN_PATH} |"
)
HASH_ROW = f"| {PLAN_PATH} | {PLAN_HASH_HEX} |"

# The template's own resume-boundary subject and verb, used as the anchor for
# the alternant-substitution test. The anchor spans the template's line break so
# that the later lowercase "each item opens its own pull request" clause is not
# rewritten by accident.
TEMPLATE_RESUME_ANCHOR = "Each item\nresumes"

KICKOFF_FENCE_RE = re.compile(r"^```markdown\r?\n(.*?)^```", re.DOTALL | re.MULTILINE)

STRUCTURAL_INVOCATION_ERROR = (
    "Parallel kickoff invocation must structurally name the manifest, "
    "plan-home branch, and atomic-execution resume boundary."
)


class KickoffTemplateError(Exception):
    """Raised when the skill's kickoff template cannot be extracted or rendered.

    Purpose:
        Signal that the PRODUCER surface no longer has the shape this suite
        depends on, so a silent extraction miss cannot make the seam tests pass
        vacuously against an empty or truncated string.

    Responsibilities:
        Carry a literal, actionable message naming what was missing. The class
        adds no state and no behavior beyond the base exception.

    Usage:
        Raised by :func:`extract_kickoff_template` and
        :func:`render_kickoff_template`; never caught inside this module, so a
        producer-shape regression surfaces as a test error rather than a
        misleading assertion failure.
    """


def extract_kickoff_template(text: str) -> str:
    """Return the fenced kickoff template published under ``## Kickoff Artifact``.

    Purpose:
        Locate the authoritative kickoff template inside the parallel-plan
        skill so the seam tests validate exactly the document a planner would
        emit, rather than a hand-copied approximation of it.

    Args:
        text (str): Full text of ``.claude/skills/parallel-plan/SKILL.md``. Not
            mutated.

    Returns:
        str: Inner text of the first fenced ``markdown`` code block that
        follows the ``## Kickoff Artifact`` heading, without the fence lines.

    Raises:
        KickoffTemplateError: When the ``## Kickoff Artifact`` heading is absent
            or no fenced ``markdown`` block follows it.

    Side Effects:
        None.
    """

    heading_index = text.find("\n## Kickoff Artifact\n")
    if heading_index < 0:
        raise KickoffTemplateError(
            "parallel-plan skill has no '## Kickoff Artifact' heading"
        )
    match = KICKOFF_FENCE_RE.search(text[heading_index:])
    if match is None:
        raise KickoffTemplateError(
            "no fenced markdown block follows '## Kickoff Artifact'"
        )
    return match.group(1)


def _substitute_placeholder_rows(rendered: str) -> str:
    """Replace each ``| ... |`` placeholder row with a concrete row.

    Purpose:
        Fill the template's two placeholder rows without hard-coding their line
        positions, so the helper keeps working if the template gains or loses
        surrounding prose.

    Args:
        rendered (str): Template text whose scalar placeholders are already
            substituted. Not mutated.

    Returns:
        str: The same text with every all-``...`` pipe row replaced by a
        concrete row selected by cell count.

    Raises:
        KickoffTemplateError: When a placeholder row has a cell count other
            than the six-cell item row or the two-cell integrity hash row.

    Side Effects:
        None.
    """

    lines: list[str] = []
    # Rewrite only rows whose every cell is the literal ellipsis, choosing the
    # replacement by width: six cells is the ## Item Summary row and two cells
    # is the ## Integrity hash row. Any other width means the template grew a
    # placeholder shape this suite does not know how to fill, which is reported
    # rather than silently passed through.
    for line in rendered.splitlines():
        stripped = line.strip()
        is_pipe_row = stripped.startswith("|") and stripped.endswith("|")
        cells = (
            [cell.strip() for cell in stripped[1:-1].split("|")] if is_pipe_row else []
        )
        if cells and set(cells) == {"..."}:
            if len(cells) == 6:
                lines.append(ITEM_ROW)
            elif len(cells) == 2:
                lines.append(HASH_ROW)
            else:
                raise KickoffTemplateError(
                    f"unexpected placeholder row width: {len(cells)}"
                )
            continue
        lines.append(line)
    return "\n".join(lines)


def render_kickoff_template(template: str, *, include_integrity: bool) -> str:
    """Substitute the template's placeholders into a concrete kickoff document.

    Purpose:
        Produce exactly the document a planner following the skill would write,
        so the contract module validates the real producer output.

    Args:
        template (str): Inner text of the fenced kickoff template. Not mutated.
        include_integrity (bool): When ``True`` the optional ``## Integrity``
            section is retained; when ``False`` the section is removed so the
            optional-section-absent path of the contract is exercised.

    Returns:
        str: A rendered kickoff document carrying no residual ``<slug>``,
        ``<iso8601>``, ``<hex>``, or ``...`` authoring token.

    Raises:
        KickoffTemplateError: When a placeholder row has an unrecognized cell
            count, when ``include_integrity`` is ``False`` but the template has
            no ``## Integrity`` section, or when a residual authoring token
            survives substitution.

    Side Effects:
        None.
    """

    rendered = template.replace("<slug>", SLUG)
    rendered = rendered.replace("<iso8601>", ISO8601)
    rendered = rendered.replace("<hex>", PLANNING_COMMIT_HEX)
    rendered = _substitute_placeholder_rows(rendered)
    # The integrity section is the template's only optional block, so removing
    # it is how the absent-section contract path is reached without authoring a
    # second, independently-maintained template.
    if not include_integrity:
        index = rendered.find("\n## Integrity\n")
        if index < 0:
            raise KickoffTemplateError("template has no '## Integrity' section")
        rendered = rendered[:index].rstrip() + "\n"
    # A surviving authoring token would make the document structurally invalid
    # for a reason unrelated to the contract under test, so it is reported here
    # rather than surfacing as a confusing validator error downstream.
    for token in ("<slug>", "<iso8601>", "<hex>", "..."):
        if token in rendered:
            raise KickoffTemplateError(
                f"residual authoring token in rendering: {token}"
            )
    return rendered


def read_skill_text() -> str:
    """Read the canonical parallel-plan skill from the repository root.

    Purpose:
        Resolve the PRODUCER surface once, from the repository root rather than
        the bundled payload mirror, so the seam binds the authoritative file.

    Args:
        None.

    Returns:
        str: Full UTF-8 text of ``.claude/skills/parallel-plan/SKILL.md``.

    Raises:
        OSError: When the canonical skill file is absent or unreadable.

    Side Effects:
        Reads one committed file from disk.
    """

    return (REPO_ROOT / PARALLEL_PLAN_SKILL_RELATIVE).read_text(encoding="utf-8")


def test_extracted_template_is_the_documented_kickoff_block() -> None:
    """The extracted block is the kickoff document, not some other fenced block."""

    # Arrange
    skill_text = read_skill_text()

    # Act
    template = extract_kickoff_template(skill_text)

    # Assert
    assert template.startswith("# Parallel Kickoff: <slug>")
    for heading in ("## Invocation Prompt", "## Item Summary", "## Integrity"):
        assert heading in template, f"extracted template lacks {heading}"


def test_rendered_template_with_integrity_validates_clean() -> None:
    """The skill's template, rendered with ## Integrity, satisfies the contract."""

    # Arrange
    template = extract_kickoff_template(read_skill_text())
    rendered = render_kickoff_template(template, include_integrity=True)

    # Act
    errors = validate_parallel_kickoff_text(rendered)

    # Assert
    assert errors == [], f"skill template rejected by contract module: {errors}"


def test_rendered_template_without_integrity_validates_clean() -> None:
    """The optional ## Integrity section may be omitted without error."""

    # Arrange
    template = extract_kickoff_template(read_skill_text())
    rendered = render_kickoff_template(template, include_integrity=False)

    # Act
    errors = validate_parallel_kickoff_text(rendered)

    # Assert
    assert "## Integrity" not in rendered
    assert "planning_commit" not in rendered
    assert errors == [], f"integrity-free rendering rejected: {errors}"


def test_rendered_template_captures_planning_commit() -> None:
    """The template's integrity field name is the one the parser captures."""

    # Arrange
    template = extract_kickoff_template(read_skill_text())
    rendered = render_kickoff_template(template, include_integrity=True)

    # Act
    parsed, errors = parse_parallel_kickoff(rendered)

    # Assert
    assert errors == []
    assert parsed is not None
    assert parsed.planning_commit == PLANNING_COMMIT_HEX


@pytest.mark.parametrize(
    ("subject", "verb"),
    [
        ("Every item", "resumes"),
        ("Each item", "resumes"),
        ("items", "resume"),
    ],
)
def test_resume_boundary_accepts_each_documented_alternant(
    subject: str, verb: str
) -> None:
    """All three documented resume-subject spellings validate clean."""

    # Arrange
    template = extract_kickoff_template(read_skill_text())
    rendered = render_kickoff_template(template, include_integrity=True)
    respelled = rendered.replace(TEMPLATE_RESUME_ANCHOR, f"{subject}\n{verb}")

    # Act
    errors = validate_parallel_kickoff_text(respelled)

    # Assert
    assert TEMPLATE_RESUME_ANCHOR in rendered, "resume-boundary anchor not in template"
    assert errors == [], f"alternant {subject!r} rejected: {errors}"


def test_resume_boundary_rejects_an_undocumented_subject() -> None:
    """A subject outside the alternation still fails, so widening stayed narrow."""

    # Arrange
    # `Each entry` is chosen because RESUME_RE is applied with `search` and
    # carries no word boundary, so a negative subject must contain none of
    # `Every item`, `Each item`, or `items` as a substring. `Some items` would
    # match both before and after the widening and is therefore not a valid
    # negative.
    template = extract_kickoff_template(read_skill_text())
    rendered = render_kickoff_template(template, include_integrity=True)
    respelled = rendered.replace(TEMPLATE_RESUME_ANCHOR, "Each entry\nresumes")

    # Act
    errors = validate_parallel_kickoff_text(respelled)

    # Assert
    assert TEMPLATE_RESUME_ANCHOR in rendered, "resume-boundary anchor not in template"
    assert errors == [STRUCTURAL_INVOCATION_ERROR]


def test_committed_fixture_and_template_agree_on_the_resume_clause() -> None:
    """The committed fixture and the skill template both satisfy RESUME_RE."""

    # Arrange
    # `tests/fixtures/parallel_kickoff/valid-kickoff.md` and the skill template
    # are independently maintained: the fixture is test-owned and the template
    # is runtime-owned. Their agreement on the resume clause is therefore
    # asserted rather than assumed.
    fixture_text = (REPO_ROOT / VALID_KICKOFF_FIXTURE_RELATIVE).read_text(
        encoding="utf-8"
    )
    template = extract_kickoff_template(read_skill_text())
    rendered = render_kickoff_template(template, include_integrity=True)

    # Act
    fixture_errors = validate_parallel_kickoff_text(fixture_text)

    # Assert
    assert fixture_errors == []
    assert RESUME_RE.search(fixture_text) is not None
    assert RESUME_RE.search(rendered) is not None
