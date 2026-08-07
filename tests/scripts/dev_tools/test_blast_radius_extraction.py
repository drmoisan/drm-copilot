"""Tests for the blast-radius text-extraction helpers.

Cover line normalization, plan task-line parsing, inline-code tokenization,
path-token classification, contract-identifier extraction, and the path
subsumption relation used by validation rule V1.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools import validate_orchestration_artifacts
from scripts.dev_tools._blast_radius_extraction import (
    PATH_KIND_CONCRETE,
    PATH_KIND_GLOB,
    PLAN_PHASE_RE,
    PLAN_TASK_RE,
    classify_path_token,
    extract_contract_identifiers,
    extract_inline_code_tokens,
    extract_paths_from_lines,
    extract_plan_paths,
    is_path_subsumed,
    matches_glob,
    normalize_lines,
    scan_plan_lines,
)

# A spec fragment whose interface section carries a nested subsection, used by
# the contract-extraction tests.
SPEC_WITH_INTERFACE_SECTION = """# Feature

## Overview

Mentions `overview_identifier` outside any interface section.

## Public API Contract

Exposes `derive_blast_radius` and `conflicts`.

### Python surface

Also `extract_plan_paths` and `scripts/dev_tools/compute_blast_radius.py`.

## Data & State

Mentions `state_identifier`.
"""


def test_plan_patterns_are_identical_to_the_orchestration_validator_patterns() -> None:
    """Pin both plan regexes to the validator's so the two parsers cannot drift."""
    assert (
        PLAN_PHASE_RE.pattern == validate_orchestration_artifacts.PLAN_PHASE_RE.pattern
    )
    assert PLAN_TASK_RE.pattern == validate_orchestration_artifacts.PLAN_TASK_RE.pattern


@pytest.mark.parametrize("terminator", ["\n", "\r\n", "\r"])
def test_normalize_lines_treats_every_line_ending_style_identically(
    terminator: str,
) -> None:
    """Split LF, CRLF, and CR documents into the same line tuple."""
    text = terminator.join(["alpha", "beta", "gamma"])

    lines = normalize_lines(text)

    assert lines == ("alpha", "beta", "gamma")


def test_normalize_lines_returns_empty_tuple_for_empty_text() -> None:
    """Return no lines for an empty document."""
    assert normalize_lines("") == ()


def test_normalize_lines_preserves_trailing_whitespace_inside_lines() -> None:
    """Drop line terminators while leaving trailing in-line whitespace intact."""
    text = "alpha  \r\nbeta\t\r\n"

    lines = normalize_lines(text)

    assert lines == ("alpha  ", "beta\t")


def test_extract_inline_code_tokens_strips_defensive_trailing_carriage_return() -> None:
    """Remove a carriage return left inside a span by unnormalized upstream text."""
    line = "See `scripts/dev_tools/alpha.py\r` for details."

    tokens = extract_inline_code_tokens(line)

    assert tokens == ("scripts/dev_tools/alpha.py",)


def test_extract_inline_code_tokens_splits_a_command_span_into_tokens() -> None:
    """Split a span holding a whole command line into individual tokens."""
    line = "Run `poetry run pytest tests/scripts/dev_tools/test_alpha.py` first."

    tokens = extract_inline_code_tokens(line)

    assert tokens == (
        "poetry",
        "run",
        "pytest",
        "tests/scripts/dev_tools/test_alpha.py",
    )


def test_extract_inline_code_tokens_returns_empty_tuple_without_inline_code() -> None:
    """Yield no tokens for a line that contains no backtick-delimited span."""
    assert extract_inline_code_tokens("Update scripts/dev_tools/alpha.py today.") == ()


@pytest.mark.parametrize("checkbox", ["- [ ]", "- [x]", "- [X]"])
def test_scan_plan_lines_captures_titles_for_every_checkbox_state(
    checkbox: str,
) -> None:
    """Match unchecked, lowercase-checked, and uppercase-checked task lines."""
    plan_text = f"{checkbox} [P1-T1] Create the extraction helper module"

    scan = scan_plan_lines(plan_text)

    assert scan.task_titles == ("Create the extraction helper module",)


@pytest.mark.parametrize(
    "malformed_line",
    [
        "- [] [P1-T1] Missing checkbox character",
        "- [y] [P1-T1] Unsupported checkbox character",
        "- [ ] [p1-t1] Lowercase task identifier",
        "- [ ] P1-T1 Missing identifier brackets",
        "  - [ ] [P1-T1] Indented task line",
    ],
)
def test_scan_plan_lines_treats_malformed_task_lines_as_prose(
    malformed_line: str,
) -> None:
    """Scan a line that fails the strict task pattern as a non-task line."""
    scan = scan_plan_lines(malformed_line)

    assert scan.task_titles == ()
    assert scan.other_lines == (malformed_line,)


def test_scan_plan_lines_captures_phase_titles() -> None:
    """Capture the title group of a phase heading that matches the phase pattern."""
    plan_text = "### Phase 1 — Python Extraction Helper Module"

    scan = scan_plan_lines(plan_text)

    assert scan.phase_titles == ("Python Extraction Helper Module",)


def test_scan_plan_lines_assigns_every_line_to_exactly_one_category() -> None:
    """Partition all lines across task titles, phase titles, and prose."""
    plan_text = "\r\n".join(
        [
            "### Phase 1 — Extraction",
            "",
            "- [ ] [P1-T1] First task",
            "- [x] [P1-T2] Second task",
            "Trailing prose line",
        ]
    )

    scan = scan_plan_lines(plan_text)

    assert len(scan.task_titles) == 2
    assert len(scan.phase_titles) == 1
    assert scan.other_lines == ("", "Trailing prose line")


@pytest.mark.parametrize(
    "segment",
    [
        "scripts/",
        "tests/",
        "docs/",
        "config/",
        "schemas/",
        "packages/",
        "extensions/",
        ".claude/",
        ".codex/",
        ".github/",
        ".agents/",
        "artifacts/",
    ],
)
def test_classify_path_token_accepts_each_known_top_level_segment(
    segment: str,
) -> None:
    """Accept an extensionless token solely because of its top-level segment."""
    assert classify_path_token(f"{segment}nested/item") == PATH_KIND_CONCRETE


@pytest.mark.parametrize(
    "token",
    ["src/app/main.ts", "vendor/module/Thing.psm1", "build/output/report.json"],
)
def test_classify_path_token_accepts_recognized_extension_outside_known_segments(
    token: str,
) -> None:
    """Accept a token outside the known segments via the extension fallback rule."""
    assert classify_path_token(token) == PATH_KIND_CONCRETE


@pytest.mark.parametrize(
    "token",
    ["tests/**", "scripts/dev_tools/validate_*.py", "src/**/*.ts"],
)
def test_classify_path_token_records_wildcard_tokens_as_globs(token: str) -> None:
    """Classify an accepted token containing a wildcard as a glob rather than a file."""
    assert classify_path_token(token) == PATH_KIND_GLOB


@pytest.mark.parametrize(
    "token",
    [
        "derive_blast_radius",
        "https://example.com/docs/readme.md",
        "/etc/hosts",
        "C:/Users/dev/alpha.py",
        "alpha/beta",
        "alpha/beta.unknownext",
    ],
)
def test_classify_path_token_rejects_non_path_tokens(token: str) -> None:
    """Reject bare identifiers, URLs, absolute paths, and unrecognized shapes."""
    assert classify_path_token(token) is None


def test_extract_plan_paths_collects_paths_from_a_crlf_plan() -> None:
    """Extract paths from task bodies, phase headings, and prose of a CRLF plan."""
    plan_text = "\r\n".join(
        [
            "### Phase 1 — Work on `config/blast-radius.json`",
            "- [ ] [P1-T1] Create `scripts/dev_tools/alpha.py`",
            "Evidence goes to `docs/features/active/sample/evidence/baseline/`",
        ]
    )

    paths = extract_plan_paths(plan_text)

    assert paths == (
        "config/blast-radius.json",
        "docs/features/active/sample/evidence/baseline/",
        "scripts/dev_tools/alpha.py",
    )


def test_extract_plan_paths_deduplicates_repeated_citations() -> None:
    """Report a path once even when several tasks cite it."""
    plan_text = "\n".join(
        [
            "- [ ] [P1-T1] Create `scripts/dev_tools/alpha.py`",
            "- [ ] [P1-T2] Extend `scripts/dev_tools/alpha.py`",
        ]
    )

    assert extract_plan_paths(plan_text) == ("scripts/dev_tools/alpha.py",)


def test_extract_plan_paths_orders_output_with_ordinal_comparison() -> None:
    """Sort output by code point so uppercase names precede lowercase ones."""
    plan_text = (
        "- [ ] [P1-T1] Touch `docs/alpha.md` `docs/Alpha.md` `.claude/rules/x.md`"
    )

    paths = extract_plan_paths(plan_text)

    assert paths == (".claude/rules/x.md", "docs/Alpha.md", "docs/alpha.md")


def test_extract_plan_paths_ignores_path_references_outside_inline_code() -> None:
    """Ignore a path mentioned in prose because only inline code is harvested."""
    plan_text = "- [ ] [P1-T1] Update scripts/dev_tools/alpha.py without backticks"

    assert extract_plan_paths(plan_text) == ()


def test_extract_plan_paths_returns_empty_tuple_for_a_plan_without_paths() -> None:
    """Return no paths for a plan whose inline code names no repository path."""
    plan_text = "- [ ] [P1-T1] Document `derive_blast_radius` behavior"

    assert extract_plan_paths(plan_text) == ()


def test_extract_paths_from_lines_scans_only_the_supplied_lines() -> None:
    """Collect accepted tokens from a caller-supplied line sequence."""
    lines = ("Touch `tests/fixtures/blast_radius/basic.json`", "No code here")

    assert extract_paths_from_lines(lines) == (
        "tests/fixtures/blast_radius/basic.json",
    )


@pytest.mark.parametrize(
    "heading",
    ["## Public API", "## Interface Notes", "## Contract", "### CLI Surface"],
)
def test_extract_contract_identifiers_accepts_each_qualifying_keyword(
    heading: str,
) -> None:
    """Treat a heading containing any of the four keywords as an interface section."""
    spec_text = f"{heading}\n\nExposes `alpha_symbol`.\n"

    assert extract_contract_identifiers(spec_text) == ("alpha_symbol",)


def test_extract_contract_identifiers_includes_nested_subsections() -> None:
    """Inherit qualification in a deeper subsection of an interface section."""
    identifiers = extract_contract_identifiers(SPEC_WITH_INTERFACE_SECTION)

    assert "extract_plan_paths" in identifiers


def test_extract_contract_identifiers_excludes_non_qualifying_sections() -> None:
    """Ignore identifiers named outside any interface section."""
    identifiers = extract_contract_identifiers(SPEC_WITH_INTERFACE_SECTION)

    assert "overview_identifier" not in identifiers
    assert "state_identifier" not in identifiers


def test_extract_contract_identifiers_excludes_path_like_tokens() -> None:
    """Exclude tokens containing a separator because they belong to the paths level."""
    identifiers = extract_contract_identifiers(SPEC_WITH_INTERFACE_SECTION)

    assert identifiers == ("conflicts", "derive_blast_radius", "extract_plan_paths")


def test_extract_contract_identifiers_deduplicates_repeated_identifiers() -> None:
    """Report an identifier once even when the section names it repeatedly."""
    spec_text = "## API\n\nUses `conflicts`.\n\nAnd `conflicts` again.\n"

    assert extract_contract_identifiers(spec_text) == ("conflicts",)


def test_extract_contract_identifiers_returns_empty_tuple_without_a_section() -> None:
    """Return no identifiers for a spec with no qualifying heading."""
    spec_text = "## Overview\n\nUses `alpha_symbol`.\n"

    assert extract_contract_identifiers(spec_text) == ()


@pytest.mark.parametrize(
    ("path", "covering_paths", "expected"),
    [
        ("scripts/dev_tools/alpha.py", ("scripts/dev_tools/alpha.py",), True),
        ("scripts/dev_tools/alpha.py", ("scripts/dev_tools",), True),
        ("scripts/dev_tools/alpha.py", ("scripts/dev_tools/",), True),
        ("scripts/dev_tools/alpha.py", ("scripts/**",), True),
        ("scripts/dev_tools/alpha.py", ("scripts/dev_tools/*.py",), True),
        ("scripts/dev_tools/alpha.py", ("scripts/*.py",), False),
        ("scripts/dev_tools/alpha.py", ("scripts/dev_tools/alpha.p",), False),
        ("scripts/dev_tools/alpha.py", ("tests/**", "docs/alpha.py"), False),
        ("scripts/dev_tools/alpha.py", (), False),
    ],
)
def test_is_path_subsumed_boundary_matrix(
    path: str, covering_paths: tuple[str, ...], expected: bool
) -> None:
    """Return the documented verdict for exact, prefix, glob, and non-match cases."""
    assert is_path_subsumed(path, covering_paths) is expected


def test_is_path_subsumed_accepts_a_single_character_wildcard_entry() -> None:
    """Cover a path through an entry using the single-character wildcard."""
    assert is_path_subsumed("scripts/dev_tools/ab.py", ("scripts/dev_tools/a?.py",))


def test_is_path_subsumed_does_not_treat_a_sibling_prefix_as_a_directory() -> None:
    """Reject a directory-prefix entry that only shares a name prefix."""
    assert not is_path_subsumed("scripts/dev_toolsX/alpha.py", ("scripts/dev_tools",))


@pytest.mark.parametrize(
    ("pattern", "candidate", "expected"),
    [
        ("scripts/*.py", "scripts/alpha.py", True),
        ("scripts/*.py", "scripts/nested/alpha.py", False),
        ("scripts/**", "scripts/nested/alpha.py", True),
        ("scripts/**/alpha.py", "scripts/nested/deep/alpha.py", True),
        ("scripts/a?.py", "scripts/ab.py", True),
        ("scripts/a?.py", "scripts/abc.py", False),
        ("docs/[draft].md", "docs/[draft].md", True),
        ("docs/[draft].md", "docs/d.md", False),
    ],
)
def test_matches_glob_implements_the_supported_fnmatch_subset(
    pattern: str, candidate: str, expected: bool
) -> None:
    """Match ``**`` across separators, ``*`` and ``?`` within one, brackets as text."""
    assert matches_glob(pattern, candidate) is expected
