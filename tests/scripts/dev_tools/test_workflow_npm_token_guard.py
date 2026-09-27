"""Guard against reintroducing a token-based npm publish under ``.github/``.

Purpose: ``.github/workflows/publish-mcp-npm.yml`` publishes the MCP server
package through npm trusted publishing (OIDC), which needs no stored token.
These tests fail if any YAML file under ``.github/`` references the
``NPM_TOKEN`` secret or assigns ``NODE_AUTH_TOKEN`` under any secret name, so
a token-based publish cannot be restored without a test failure (issue #712).

Scope: every ``*.yml`` and ``*.yaml`` file under ``.github/``, enumerated
recursively. Detection is textual and line-wise, so a reference in any key,
block scalar, expression, or comment is reported. Detection is also proven
against in-memory strings, so no workflow edit is needed to show that the
helpers report a reintroduced reference.

The repository root is derived from this file's own resolved location, and
tracked files are read through ``pathlib`` only. The module has no dependency
on the current working directory, version-control state, or network access.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

REPO_ROOT: Path = Path(__file__).resolve().parents[3]
GITHUB_DIR: Path = REPO_ROOT / ".github"

_NPM_TOKEN_SECRET_REFERENCE = re.compile(
    r"secrets\s*(?:\.\s*NPM_TOKEN\b|\[\s*['\"]NPM_TOKEN['\"]\s*\])", re.IGNORECASE
)
_NODE_AUTH_TOKEN_REFERENCE = re.compile(r"\bNODE_AUTH_TOKEN\b", re.IGNORECASE)


def find_npm_token_references(text: str) -> list[int]:
    """Return the line numbers of ``text`` that reference the ``NPM_TOKEN`` secret.

    Dot access (``secrets.NPM_TOKEN``) and bracket access
    (``secrets['NPM_TOKEN']`` or ``secrets["NPM_TOKEN"]``) are detected,
    case-insensitively, with optional whitespace. The name is word-bounded, so
    a longer secret name such as ``NPM_TOKEN_V2`` is not reported, and a bare
    mention of ``NPM_TOKEN`` without a ``secrets`` context is not reported.

    Args:
        text: YAML document text to scan.

    Returns:
        Ascending 1-based line numbers of matching lines, or an empty list.
    """
    # Scan each line independently so a diagnostic can name the exact line.
    return [
        line_number
        for line_number, line in enumerate(text.splitlines(), start=1)
        if _NPM_TOKEN_SECRET_REFERENCE.search(line)
    ]


def find_node_auth_token_references(text: str) -> list[int]:
    """Return the line numbers of ``text`` that mention ``NODE_AUTH_TOKEN``.

    Any word-bounded, case-insensitive occurrence is reported, whichever
    secret name feeds it, because OIDC trusted publishing needs no token.

    Args:
        text: YAML document text to scan.

    Returns:
        Ascending 1-based line numbers of matching lines, or an empty list.
    """
    # Scan each line independently so a diagnostic can name the exact line.
    return [
        line_number
        for line_number, line in enumerate(text.splitlines(), start=1)
        if _NODE_AUTH_TOKEN_REFERENCE.search(line)
    ]


def enumerate_github_yaml_files(github_dir: Path) -> list[Path]:
    """Return every ``*.yml`` and ``*.yaml`` file under ``github_dir``, recursively.

    Args:
        github_dir: Directory to enumerate, normally ``GITHUB_DIR``.

    Returns:
        File paths sorted by their POSIX path relative to ``github_dir``, so
        diagnostics are listed in a deterministic order. The list is empty when
        the directory holds no YAML file or does not exist.
    """
    # Collect both YAML extensions, since workflows, dependabot configuration,
    # and composite actions may use either spelling.
    candidates = [
        path
        for pattern in ("*.yml", "*.yaml")
        for path in github_dir.rglob(pattern)
        if path.is_file()
    ]
    return sorted(candidates, key=lambda path: path.relative_to(github_dir).as_posix())


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        pytest.param("NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}", [1], id="dot-access"),
        pytest.param("${{ secrets['NPM_TOKEN'] }}", [1], id="single-quoted-bracket"),
        pytest.param('${{ secrets["NPM_TOKEN"] }}', [1], id="double-quoted-bracket"),
        pytest.param("${{ secrets . npm_token }}", [1], id="spaced-lowercase-dot"),
        pytest.param(
            "\n".join(
                [
                    "env:",
                    "  CI: true",
                    "NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}",
                ]
            ),
            [3],
            id="third-line-of-three",
        ),
    ],
)
def test_find_npm_token_references_detects_reintroduced_reference(
    text: str, expected: list[int]
) -> None:
    """A reintroduced ``NPM_TOKEN`` secret reference is reported at its line.

    Each case is an in-memory reintroduction of a shape a token-based publish
    would use, so the helper that drives the tree scan is shown to return a
    non-empty result without editing any workflow file.
    """
    # Arrange: the parametrized text and its expected line numbers.

    # Act
    result = find_npm_token_references(text)

    # Assert
    assert result == expected, f"input {text!a} returned {result}, expected {expected}"


@pytest.mark.parametrize(
    "text",
    [
        pytest.param("${{ secrets.VSCE_PAT }}", id="unrelated-secret"),
        pytest.param("${{ secrets.NPM_TOKEN_V2 }}", id="longer-secret-name"),
        pytest.param("# NPM_TOKEN is no longer used", id="no-secrets-context"),
        pytest.param("", id="empty"),
    ],
)
def test_find_npm_token_references_ignores_non_matching_text(text: str) -> None:
    """Text that does not consume the ``NPM_TOKEN`` secret is not reported."""
    # Arrange: the parametrized non-matching text.

    # Act
    result = find_npm_token_references(text)

    # Assert
    assert result == [], f"input {text!a} returned {result}, expected []"


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        pytest.param(
            "NODE_AUTH_TOKEN: ${{ secrets.NPM_PUBLISH_TOKEN }}",
            [1],
            id="other-secret-name",
        ),
        pytest.param("env:\n  node_auth_token: x", [2], id="lowercase-second-line"),
    ],
)
def test_find_node_auth_token_references_detects_reference(
    text: str, expected: list[int]
) -> None:
    """A ``NODE_AUTH_TOKEN`` mention is reported whichever secret feeds it."""
    # Arrange: the parametrized text and its expected line numbers.

    # Act
    result = find_node_auth_token_references(text)

    # Assert
    assert result == expected, f"input {text!a} returned {result}, expected {expected}"


@pytest.mark.parametrize(
    "text",
    [
        pytest.param("id-token: write", id="oidc-permission"),
        pytest.param("MY_NODE_AUTH_TOKENS: x", id="longer-name"),
        pytest.param("", id="empty"),
    ],
)
def test_find_node_auth_token_references_ignores_non_matching_text(text: str) -> None:
    """Text without a word-bounded ``NODE_AUTH_TOKEN`` is not reported."""
    # Arrange: the parametrized non-matching text.

    # Act
    result = find_node_auth_token_references(text)

    # Assert
    assert result == [], f"input {text!a} returned {result}, expected []"


def test_github_yaml_enumeration_is_non_vacuous() -> None:
    """The scan enumerates real files, including the npm publish workflow.

    Guards the tree-scan tests against passing silently because of a wrong
    repository root or an empty enumeration.
    """
    # Arrange
    github_dir_label = GITHUB_DIR.relative_to(REPO_ROOT).as_posix()

    # Act
    files = enumerate_github_yaml_files(GITHUB_DIR)
    # Express each file relative to the repository root for membership checks.
    relative_paths = [path.relative_to(REPO_ROOT).as_posix() for path in files]

    # Assert
    assert files, f"no YAML files were enumerated under {github_dir_label}"
    assert ".github/workflows/publish-mcp-npm.yml" in relative_paths, (
        f".github/workflows/publish-mcp-npm.yml was not enumerated under "
        f"{github_dir_label}"
    )


def test_github_yaml_files_reference_no_npm_token_secret() -> None:
    """No YAML file under ``.github/`` references the ``NPM_TOKEN`` secret."""
    # Arrange
    files = enumerate_github_yaml_files(GITHUB_DIR)
    offenders: list[str] = []

    # Act: record every matching line as ``<relative-posix-path>:<line>``.
    for path in files:
        relative_path = path.relative_to(REPO_ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        # Report each matching line separately so every offender is named.
        for line_number in find_npm_token_references(text):
            offenders.append(f"{relative_path}:{line_number}")

    # Assert
    assert offenders == [], (
        "NPM_TOKEN secret references found; npm publishing uses OIDC trusted "
        f"publishing and needs no token: {offenders}"
    )


def test_github_yaml_files_reference_no_node_auth_token() -> None:
    """No YAML file under ``.github/`` mentions ``NODE_AUTH_TOKEN``."""
    # Arrange
    files = enumerate_github_yaml_files(GITHUB_DIR)
    offenders: list[str] = []

    # Act: record every matching line as ``<relative-posix-path>:<line>``.
    for path in files:
        relative_path = path.relative_to(REPO_ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        # Report each matching line separately so every offender is named.
        for line_number in find_node_auth_token_references(text):
            offenders.append(f"{relative_path}:{line_number}")

    # Assert
    assert offenders == [], (
        "NODE_AUTH_TOKEN references found; npm publishing uses OIDC trusted "
        f"publishing and needs no token: {offenders}"
    )
