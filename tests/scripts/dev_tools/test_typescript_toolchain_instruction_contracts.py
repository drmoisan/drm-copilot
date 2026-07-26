"""Regression contracts for the TypeScript toolchain instruction mirrors.

Issue #422: the Claude and Codex/agents rule mirrors instructed agents to use
Vitest while this repository actually runs Jest, and named two ``npm run``
commands that are wrong here -- ``npm run test`` (bound to ``vscode-test``, the
integration-test runner) and ``npm run test:coverage`` (no such script). These
tests lock the corrected state.

Only the six repo-root mirrors are asserted. Their bundled copies under
``extensions/drm-copilot/resources/`` are covered transitively by the two
push-down parity tests, which require the bundled payload to be
content-identical to the repo-root originals.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import cast

import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]

TYPESCRIPT_RULE_RELATIVE_PATH = ".claude/rules/typescript.md"

MIRROR_RELATIVE_PATHS = (
    TYPESCRIPT_RULE_RELATIVE_PATH,
    ".claude/rules/general-unit-test.md",
    ".claude/rules/general-code-change.md",
    ".claude/agents/atomic-executor.md",
    ".agents/skills/general-unit-test/SKILL.md",
    ".agents/skills/general-code-change/SKILL.md",
)

# The framework name in any casing, and the Vitest global-API prefix.
VITEST_NAME_PATTERN = re.compile(r"vitest", re.IGNORECASE)
VITEST_API_PATTERN = re.compile(r"\bvi\.[a-zA-Z]")

# Backtick-wrapped `npm run <script>` tokens anywhere in the rule text.
NPM_RUN_PATTERN = re.compile(r"`npm run ([^`]+)`")

TESTING_TOOLCHAIN_MARKER = "**Testing"
COVERAGE_COMMAND_MARKER = "Coverage command:"

UNIT_TEST_COMMAND = "`npm run test:unit`"
INTEGRATION_TEST_COMMAND = "`npm run test`"
COVERAGE_COMMAND = "`npm run test:unit:coverage`"


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 text for one checked-in repo-root instruction mirror."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def read_root_package_script_names() -> frozenset[str]:
    """Return every script name declared by the root ``package.json``."""

    loaded: object = json.loads(
        (REPO_ROOT / "package.json").read_text(encoding="utf-8")
    )
    assert isinstance(loaded, dict), "root package.json must decode to an object"
    # Treat the decoded mapping as untyped JSON values; the leaf is narrowed
    # explicitly below.
    document = cast("dict[str, object]", loaded)
    scripts = document.get("scripts")
    assert isinstance(scripts, dict), "root package.json must declare `scripts`"
    named = cast("dict[str, object]", scripts)
    return frozenset(named)


def find_matching_lines(text: str, pattern: re.Pattern[str]) -> list[str]:
    """Return ``"<line-number>: <line>"`` for each line matching ``pattern``."""

    return [
        f"{number}: {line}"
        for number, line in enumerate(text.splitlines(), start=1)
        if pattern.search(line)
    ]


def find_unique_line(text: str, marker: str) -> str:
    """Return the single line of ``text`` that contains ``marker``."""

    matches = [line for line in text.splitlines() if marker in line]
    assert (
        len(matches) == 1
    ), f"expected exactly one line containing {marker!r}, found {len(matches)}"
    return matches[0]


@pytest.mark.parametrize("relative_path", MIRROR_RELATIVE_PATHS)
def test_mirror_does_not_name_the_vitest_framework(relative_path: str) -> None:
    """Forbid the Vitest framework name in each repo-root instruction mirror."""

    # Arrange
    text = read_repo_text(relative_path)

    # Act
    offending_lines = find_matching_lines(text, VITEST_NAME_PATTERN)

    # Assert
    assert offending_lines == [], (
        f"{relative_path} names Vitest, but this repository runs Jest "
        f"(root package.json devDependency `jest`): {offending_lines}"
    )


@pytest.mark.parametrize("relative_path", MIRROR_RELATIVE_PATHS)
def test_mirror_does_not_reference_the_vitest_api(relative_path: str) -> None:
    """Forbid Vitest ``vi.*`` API references in each repo-root mirror."""

    # Arrange
    text = read_repo_text(relative_path)

    # Act
    offending_lines = find_matching_lines(text, VITEST_API_PATTERN)

    # Assert
    assert offending_lines == [], (
        f"{relative_path} references the Vitest `vi.*` API; Jest exposes the "
        f"equivalent helpers as `jest.*`: {offending_lines}"
    )


def test_typescript_rule_npm_commands_resolve_to_root_package_scripts() -> None:
    """Require every ``npm run`` command in the rule to exist as a script."""

    # Arrange
    text = read_repo_text(TYPESCRIPT_RULE_RELATIVE_PATH)
    declared_scripts = read_root_package_script_names()

    # Act
    referenced = sorted({str(name) for name in NPM_RUN_PATTERN.findall(text)})
    unresolved = [name for name in referenced if name not in declared_scripts]

    # Assert
    assert referenced, (
        f"{TYPESCRIPT_RULE_RELATIVE_PATH} must name at least one "
        "backtick-wrapped `npm run <script>` command"
    )
    assert unresolved == [], (
        f"{TYPESCRIPT_RULE_RELATIVE_PATH} names npm scripts that do not exist "
        f"in root package.json: {unresolved}"
    )


def test_typescript_rule_testing_line_names_the_unit_test_command() -> None:
    """Require the Testing toolchain line to name ``npm run test:unit``."""

    # Arrange
    text = read_repo_text(TYPESCRIPT_RULE_RELATIVE_PATH)

    # Act
    testing_line = find_unique_line(text, TESTING_TOOLCHAIN_MARKER)

    # Assert
    assert UNIT_TEST_COMMAND in testing_line, (
        "the Testing toolchain line must name the unit-test command "
        f"{UNIT_TEST_COMMAND}; found: {testing_line!r}"
    )
    assert INTEGRATION_TEST_COMMAND not in testing_line, (
        f"{INTEGRATION_TEST_COMMAND} resolves to `vscode-test`, the "
        "integration-test runner, so it is not the unit-test command; "
        f"found: {testing_line!r}"
    )


def test_typescript_rule_coverage_line_names_the_coverage_command() -> None:
    """Require the coverage line to name ``npm run test:unit:coverage``."""

    # Arrange
    text = read_repo_text(TYPESCRIPT_RULE_RELATIVE_PATH)

    # Act
    coverage_line = find_unique_line(text, COVERAGE_COMMAND_MARKER)

    # Assert
    assert COVERAGE_COMMAND in coverage_line, (
        "the coverage line must name the coverage command "
        f"{COVERAGE_COMMAND}; found: {coverage_line!r}"
    )
