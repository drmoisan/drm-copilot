"""Collector-level tests for the declared-expectation row line (issue #485).

A new sibling module of `test_collect_pr_context_part4.py`, which is already over
the 500-line limit and therefore receives no changed line. Every evidence file is
seeded through the in-memory `mem_fs_path` fixture; `tmp_path` is never used.
"""

from pathlib import Path

import pytest

from scripts.dev_tools.pr_context.models import FeatureDocExcerpt

FEATURE = "2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485"


def _render_section(root: Path, doc: FeatureDocExcerpt) -> str:
    """Render the verification-evidence section for one feature excerpt.

    The collector's renderer is module-private and the collector exposes no
    public rendering seam, so it is resolved inside this helper and the
    private-usage diagnostic is suppressed on that single import line only. The
    same rule is suppressed for the same reason by
    `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py`, which does it at
    file scope; this narrower line scope is preferred. Renaming the renderer or
    adding a public wrapper was rejected because it would exceed the five-added-line
    cap this change is held to for `collector.py`.

    Args:
        root: In-memory repository root supplied by `mem_fs_path`.
        doc: Feature excerpt whose context files name the evidence artifacts.

    Returns:
        The rendered section body.

    Side Effects:
        Reads the seeded evidence files from the in-memory filesystem.
    """
    from scripts.dev_tools.pr_context.collector import (
        _render_verification_evidence_section,  # pyright: ignore[reportPrivateUsage]
    )

    return _render_verification_evidence_section(resolved_root=root, feature_docs=[doc])


def _seed_evidence(root: Path, *, name: str, markdown: str) -> str:
    """Write one canonical evidence artifact into the in-memory root.

    Args:
        root: In-memory repository root supplied by `mem_fs_path`.
        name: Evidence file name under the feature's `evidence/qa-gates` folder.
        markdown: Raw artifact content.

    Returns:
        The repository-relative POSIX path of the seeded artifact.

    Side Effects:
        Creates directories and one file inside the in-memory filesystem.
    """
    relative = Path("docs/features/active") / FEATURE / "evidence/qa-gates" / name
    target = root / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(markdown, encoding="utf-8")
    return relative.as_posix()


def test_renderer_emits_expectation_line_for_non_zero_expectation(
    mem_fs_path: Path,
) -> None:
    """A non-zero declared expectation renders between EXIT_CODE and the result."""
    # Arrange
    relative = _seed_evidence(
        mem_fs_path,
        name="absence-gate.2026-08-20T09-53.md",
        markdown=(
            "Timestamp: 2026-08-20T09-53\n"
            "Command: git grep -n forbidden-token\n"
            "EXIT_CODE: 1\n"
            "ExpectedExitCode: 1\n"
        ),
    )
    doc = FeatureDocExcerpt(
        feature=FEATURE,
        excerpt="",
        issue_refs=[],
        context_files=[relative],
    )

    # Act
    body = _render_section(mem_fs_path, doc)

    # Assert
    lines = body.splitlines()
    assert "  - Expected EXIT_CODE: 1" in lines
    exit_index = lines.index("  - EXIT_CODE: 1")
    expected_index = lines.index("  - Expected EXIT_CODE: 1")
    result_index = lines.index("  - Normalized result: pass")
    assert exit_index + 1 == expected_index
    assert expected_index + 1 == result_index


@pytest.mark.parametrize(
    "expectation_row",
    ["", "ExpectedExitCode: 0\n"],
    ids=["key-omitted", "key-written-as-zero"],
)
def test_renderer_omits_expectation_line_for_zero_expectation(
    mem_fs_path: Path, expectation_row: str
) -> None:
    """No expectation line renders when the key is omitted or written as zero."""
    # Arrange
    relative = _seed_evidence(
        mem_fs_path,
        name="zero-gate.2026-08-20T09-53.md",
        markdown=(
            "Timestamp: 2026-08-20T09-53\n"
            "Command: poetry run pytest\n"
            "EXIT_CODE: 0\n"
            f"{expectation_row}"
        ),
    )
    doc = FeatureDocExcerpt(
        feature=FEATURE,
        excerpt="",
        issue_refs=[],
        context_files=[relative],
    )

    # Act
    body = _render_section(mem_fs_path, doc)

    # Assert — both inputs render the same six-line row as before the change.
    assert "Expected EXIT_CODE" not in body
    assert body.splitlines() == [
        f"- Feature: {FEATURE}",
        f"  - Source: {relative}",
        "  - Timestamp: 2026-08-20T09-53",
        "  - Command: poetry run pytest",
        "  - EXIT_CODE: 0",
        "  - Normalized result: pass",
    ]
