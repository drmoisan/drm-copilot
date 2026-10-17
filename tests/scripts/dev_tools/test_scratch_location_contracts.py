"""Contract tests for the child-unique scratch location rule (issue #900).

Concurrent child runs in one session share one session scratchpad, so fixed
scratch file names can collide. The planner and executor personas, and their
Codex skill counterparts, therefore carry a ``## Scratch Location`` section
that resolves ``SCRATCH`` to a directory unique to the child.

The four repository-root persona and skill sources are asserted here, and so
are the two Codex base agent definitions ``.codex/agents/atomic-planner.toml``
and ``.codex/agents/atomic-executor.toml`` (issue #932). Bundled copies under
``extensions/drm-copilot/resources/`` are covered by the push-down parity
tests, which require the bundled payload to match the repository.

The normative-surface scan uses the production G10 detector
``bare_scratch_definitions`` from ``scripts.dev_tools.plan_gate_scratch`` plus
a scratchpad-root regex, so the plan gate and this scan share one detector.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

from scripts.dev_tools.plan_gate_scratch import bare_scratch_definitions

REPO_ROOT = Path(__file__).resolve().parents[3]

SECTION_HEADING = "## Scratch Location"
EVIDENCE_HEADING = "## Evidence Location Invariant"

CLAUDE_PLANNER = ".claude/agents/atomic-planner.md"
CLAUDE_EXECUTOR = ".claude/agents/atomic-executor.md"
AGENTS_PLANNER = ".agents/skills/atomic-planner/SKILL.md"
AGENTS_EXECUTOR = ".agents/skills/atomic-executor/SKILL.md"
CODEX_PLANNER = ".codex/agents/atomic-planner.toml"
CODEX_EXECUTOR = ".codex/agents/atomic-executor.toml"
PRIMARY_SOURCES = (CLAUDE_PLANNER, CLAUDE_EXECUTOR, AGENTS_PLANNER, AGENTS_EXECUTOR)

RULE_SOURCES = (
    pytest.param(CLAUDE_PLANNER, id="claude-planner"),
    pytest.param(CLAUDE_EXECUTOR, id="claude-executor"),
    pytest.param(AGENTS_PLANNER, id="agents-planner"),
    pytest.param(AGENTS_EXECUTOR, id="agents-executor"),
    pytest.param(CODEX_PLANNER, id="codex-planner"),
    pytest.param(CODEX_EXECUTOR, id="codex-executor"),
)
EXECUTOR_SOURCES = (
    pytest.param(CLAUDE_EXECUTOR, id="claude-executor"),
    pytest.param(AGENTS_EXECUTOR, id="agents-executor"),
    pytest.param(CODEX_EXECUTOR, id="codex-executor"),
)
PLANNER_PLACEMENTS = (
    pytest.param(
        CLAUDE_PLANNER,
        "## Requirements",
        "## Preflight Validation",
        id="claude-planner",
    ),
    pytest.param(
        AGENTS_PLANNER,
        "## Plan Requirements",
        "## Mandatory Preflight Loop",
        id="agents-planner",
    ),
    pytest.param(
        CODEX_PLANNER,
        "## Requirements",
        "## Preflight Validation",
        id="codex-planner",
    ),
)
EXECUTOR_PLACEMENTS = (
    pytest.param(
        CLAUDE_EXECUTOR,
        "## Toolchain Commands",
        "## Preflight Validation",
        id="claude-executor",
    ),
    pytest.param(
        AGENTS_EXECUTOR,
        "## Execution Rules",
        "## Non-Negotiable Constraints",
        id="agents-executor",
    ),
    pytest.param(
        CODEX_EXECUTOR,
        "## Toolchain Commands",
        "## Preflight Validation",
        id="codex-executor",
    ),
)

PINNED_RULE_PHRASE = "`SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`"
ISSUE_DIRECTORY_SEGMENT = "issue-<issue-num>"
SCOPE_PHRASE = "Every scratch file, helper script, staged copy, and coverage report"
LITERAL_MARKER_PHRASE = "record the literal token `SCRATCH`, never a host path"
PLANNER_NO_ROOT_PHRASE = (
    "never directs a scratch file to the scratchpad root or to a fixed shared name"
)
EXECUTOR_CREATE_PHRASE = "Create `SCRATCH` before the first scratch write"
EXECUTOR_PRE_RULE_PHRASE = (
    "treat that definition as `<session scratchpad>/issue-<issue-num>/`"
)

NPM_RUN_PATTERN = re.compile(r"`npm run [^`]+`")
ISSUE_NUMBER_PATTERN = re.compile(
    r"issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?\d+", re.IGNORECASE
)
ACTIVE_FEATURE_PATH = "docs/features/active/"

NORMATIVE_SURFACE_GLOBS = (
    ".claude/agents/*.md",
    ".claude/skills/**/SKILL.md",
    ".agents/skills/**/SKILL.md",
    ".codex/agents/*.toml",
)
SCRATCHPAD_ROOT_RE = re.compile(r"<[^>\n]*scratchpad[^>\n]*>/(?!issue-)", re.IGNORECASE)


def scratch_violations(text: str) -> list[str]:
    """Return every bare SCRATCH definition and scratchpad-root path in text.

    Args:
        text (str): Document text to scan.

    Returns:
        list[str]: One ``Line N: <normalized line>`` entry per G10 detector
        result, followed by one entry per scratchpad-root match.
    """

    violations = [
        f"Line {line_number}: {logical_line}"
        for line_number, logical_line in bare_scratch_definitions(text)
    ]
    violations.extend(match.group(0) for match in SCRATCHPAD_ROOT_RE.finditer(text))
    return violations


def read_repo_lines(relative_path: str) -> list[str]:
    """Return the lines of one checked-in repository file."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8").splitlines()


def section_start(lines: list[str]) -> int:
    """Return the index of the ``## Scratch Location`` heading, or -1."""

    return lines.index(SECTION_HEADING) if SECTION_HEADING in lines else -1


def scratch_section(relative_path: str) -> str:
    """Return the ``## Scratch Location`` body, or an empty string when absent.

    The body runs from the line after the heading to the next ``## `` heading.
    """

    lines = read_repo_lines(relative_path)
    start = section_start(lines)
    if start < 0:
        return ""
    body: list[str] = []
    for line in lines[start + 1 :]:
        if line.startswith("## "):
            break
        body.append(line)
    return "\n".join(body)


def neighbouring_headings(relative_path: str) -> tuple[str, str]:
    """Return the ``## `` headings directly before and after the section.

    Both values are empty strings when the section is absent; one value is
    empty when the section is the first or last top-level section.
    """

    lines = read_repo_lines(relative_path)
    start = section_start(lines)
    if start < 0:
        return ("", "")
    before = [line for line in lines[:start] if line.startswith("## ")]
    after = [line for line in lines[start + 1 :] if line.startswith("## ")]
    return (before[-1] if before else "", after[0] if after else "")


def normative_surface_paths() -> list[Path]:
    """Return every persona and skill file the scratch rule governs."""

    paths: set[Path] = set()
    for pattern in NORMATIVE_SURFACE_GLOBS:
        paths.update(path for path in REPO_ROOT.glob(pattern) if path.is_file())
    return sorted(paths)


@pytest.mark.parametrize("relative_path", RULE_SOURCES)
def test_scratch_location_section_states_the_rule(relative_path: str) -> None:
    """Require the child-unique ``SCRATCH`` rule in each primary source."""

    # Arrange
    required = (
        PINNED_RULE_PHRASE,
        ISSUE_DIRECTORY_SEGMENT,
        SCOPE_PHRASE,
        LITERAL_MARKER_PHRASE,
    )

    # Act
    section = scratch_section(relative_path)
    missing = [phrase for phrase in required if phrase not in section]

    # Assert
    assert section.strip(), f"{relative_path} has no {SECTION_HEADING} section"
    assert missing == [], f"{relative_path} scratch rule lacks {missing}"


@pytest.mark.parametrize("relative_path", RULE_SOURCES)
def test_scratch_location_section_avoids_forbidden_shapes(relative_path: str) -> None:
    """Forbid npm commands, issue-number assignments, and active feature paths."""

    # Arrange
    section = scratch_section(relative_path)

    # Act
    npm_tokens = [match.group(0) for match in NPM_RUN_PATTERN.finditer(section)]
    issue_shapes = [match.group(0) for match in ISSUE_NUMBER_PATTERN.finditer(section)]

    # Assert
    assert section.strip(), f"{relative_path} has no {SECTION_HEADING} section"
    assert npm_tokens == [], f"{relative_path} names npm commands {npm_tokens}"
    assert issue_shapes == [], f"{relative_path} states issue numbers {issue_shapes}"
    assert (
        ACTIVE_FEATURE_PATH not in section
    ), f"{relative_path} names {ACTIVE_FEATURE_PATH}"


@pytest.mark.parametrize(
    ("relative_path", "preceding", "following"), PLANNER_PLACEMENTS
)
def test_planner_scratch_location_placement(
    relative_path: str, preceding: str, following: str
) -> None:
    """Require the planner rule after its requirements and before preflight."""

    # Arrange
    expected = (preceding, following)

    # Act
    neighbours = neighbouring_headings(relative_path)
    section = scratch_section(relative_path)

    # Assert
    assert neighbours == expected, f"{relative_path} placed between {neighbours}"
    assert PLANNER_NO_ROOT_PHRASE in section, f"{relative_path} allows root names"


@pytest.mark.parametrize(
    ("relative_path", "preceding", "following"), EXECUTOR_PLACEMENTS
)
def test_executor_scratch_location_placement(
    relative_path: str, preceding: str, following: str
) -> None:
    """Require the executor rule in place and ahead of any evidence invariant."""

    # Arrange
    expected = (preceding, following)
    lines = read_repo_lines(relative_path)

    # Act
    neighbours = neighbouring_headings(relative_path)
    start = section_start(lines)
    evidence = lines.index(EVIDENCE_HEADING) if EVIDENCE_HEADING in lines else -1

    # Assert
    assert neighbours == expected, f"{relative_path} placed between {neighbours}"
    assert start >= 0, f"{relative_path} has no {SECTION_HEADING} section"
    assert evidence < 0 or start < evidence, f"{relative_path} rule follows evidence"


@pytest.mark.parametrize("relative_path", EXECUTOR_SOURCES)
def test_executor_scratch_location_handles_pre_rule_plans(relative_path: str) -> None:
    """Require directory creation and bare-scratchpad reinterpretation."""

    # Arrange
    required = (EXECUTOR_CREATE_PHRASE, EXECUTOR_PRE_RULE_PHRASE)

    # Act
    section = scratch_section(relative_path)
    missing = [phrase for phrase in required if phrase not in section]

    # Assert
    assert section.strip(), f"{relative_path} has no {SECTION_HEADING} section"
    assert missing == [], f"{relative_path} executor rule lacks {missing}"


def test_normative_surfaces_name_no_bare_fixed_scratch_path() -> None:
    """Forbid bare SCRATCH definitions and scratchpad-root paths on surfaces."""

    # Arrange
    surfaces = normative_surface_paths()
    scanned = {path.relative_to(REPO_ROOT).as_posix() for path in surfaces}

    # Act
    offending = [
        f"{path.relative_to(REPO_ROOT).as_posix()}: {violation}"
        for path in surfaces
        for violation in scratch_violations(path.read_text(encoding="utf-8"))
    ]

    # Assert
    assert set(PRIMARY_SOURCES) <= scanned, "scan missed a primary scratch source"
    assert offending == [], f"bare scratch definitions or paths found: {offending}"


@pytest.mark.parametrize(
    ("text", "flagged"),
    [
        pytest.param("<scratchpad>/run-ps.sh", True, id="scratchpad-root"),
        pytest.param(
            "<SCRATCHPAD>/derive-worklists.ps1", True, id="uppercase-scratchpad-root"
        ),
        pytest.param(
            "SCRATCH is the session scratchpad outside the repository.",
            True,
            id="bare-definition",
        ),
        pytest.param(
            "<session scratchpad>/issue-<issue-num>/run-ps.sh",
            False,
            id="issue-namespaced-path",
        ),
    ],
)
def test_scratch_pattern_check_self_test(text: str, flagged: bool) -> None:
    """The pattern check flags bare forms and accepts the namespaced path."""

    # Arrange / Act
    violations = scratch_violations(text)

    # Assert
    assert bool(violations) is flagged, f"{text!r} produced {violations}"
