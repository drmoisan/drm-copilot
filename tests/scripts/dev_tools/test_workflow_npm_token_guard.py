"""Guard against reintroducing a token-based npm publish under ``.github/``.

Purpose: ``.github/workflows/publish-mcp-npm.yml`` publishes the MCP server
package through npm trusted publishing (OIDC), which needs no stored token.
These tests fail if any YAML file under ``.github/`` configures a long-lived
npm token through any of four detected families: a reference to the
``NPM_TOKEN`` secret or variable (``secrets`` or ``vars`` context), any
mention of ``NODE_AUTH_TOKEN``, an ``_authToken`` configuration key in any
form (an ``.npmrc`` line, an ``npm_config_`` environment variable, or
``npm config set``), and an ``NPM_TOKEN`` assignment fed from any secret
(issues #712 and #739).

Scope: every ``*.yml`` and ``*.yaml`` file under ``.github/``, enumerated
recursively. Detection is textual and line-wise, so a match in any key,
block scalar, expression, or comment is reported. Detection is also proven
against in-memory strings, so no workflow edit is needed to show that the
helpers report a reintroduced route.

The repository root is derived from this file's own resolved location, and
files are enumerated and read from disk through ``pathlib`` only, whether or
not version control tracks them. The module has no dependency on the current
working directory, version-control state, or network access.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from collections.abc import Callable

REPO_ROOT: Path = Path(__file__).resolve().parents[3]
GITHUB_DIR: Path = REPO_ROOT / ".github"

_NPM_TOKEN_CONTEXT_REFERENCE = re.compile(
    r"\b(?:secrets|vars)\s*(?:\.\s*NPM_TOKEN\b|\[\s*['\"]NPM_TOKEN['\"]\s*\])",
    re.IGNORECASE,
)
_NODE_AUTH_TOKEN_REFERENCE = re.compile(r"\bNODE_AUTH_TOKEN\b", re.IGNORECASE)
_NPM_AUTH_TOKEN_CONFIG_REFERENCE = re.compile(
    r"(?<![A-Za-z0-9])_authtoken\b", re.IGNORECASE
)
_NPM_TOKEN_ASSIGNMENT = re.compile(
    r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=(?!=)", re.IGNORECASE
)


def _matching_line_numbers(pattern: re.Pattern[str], text: str) -> list[int]:
    """Return the 1-based numbers of the lines of ``text`` that ``pattern`` matches.

    Shared by every finder so each detected family scans text the same way:
    line by line, with ``pattern.search`` applied to each line on its own.

    Args:
        pattern: Compiled expression searched for within each line.
        text: YAML document text to scan.

    Returns:
        Ascending 1-based line numbers of matching lines, or an empty list.
    """
    # Scan each line independently so a diagnostic can name the exact line.
    return [
        line_number
        for line_number, line in enumerate(text.splitlines(), start=1)
        if pattern.search(line)
    ]


def find_npm_token_references(text: str) -> list[int]:
    """Return the line numbers of ``text`` that reference the ``NPM_TOKEN`` secret
    or variable.

    Both the ``secrets`` and ``vars`` contexts are detected, through dot access
    (``secrets.NPM_TOKEN``) or bracket access (``vars['NPM_TOKEN']``), in any
    casing and with optional whitespace. Both names are word-bounded, so
    ``NPM_TOKEN_V2``, ``mysecrets.NPM_TOKEN``, and a bare mention are ignored.

    Args:
        text: YAML document text to scan.

    Returns:
        Ascending 1-based line numbers of matching lines, or an empty list.
    """
    return _matching_line_numbers(_NPM_TOKEN_CONTEXT_REFERENCE, text)


def find_node_auth_token_references(text: str) -> list[int]:
    """Return the line numbers of ``text`` that mention ``NODE_AUTH_TOKEN``.

    Any word-bounded, case-insensitive occurrence is reported, whichever
    secret name feeds it, because OIDC trusted publishing needs no token.

    Args:
        text: YAML document text to scan.

    Returns:
        Ascending 1-based line numbers of matching lines, or an empty list.
    """
    return _matching_line_numbers(_NODE_AUTH_TOKEN_REFERENCE, text)


def find_npm_auth_token_config_references(text: str) -> list[int]:
    """Return the line numbers of ``text`` that set an ``_authToken`` config key.

    The key is reported in any casing and in any form: an ``.npmrc`` line, an
    ``npm_config_`` environment variable, or ``npm config set``. A letter- or
    digit-prefixed name such as ``GH_AUTHTOKEN`` is not reported.

    Args:
        text: YAML document text to scan.

    Returns:
        Ascending 1-based line numbers of matching lines, or an empty list.
    """
    return _matching_line_numbers(_NPM_AUTH_TOKEN_CONFIG_REFERENCE, text)


def find_npm_token_assignments(text: str) -> list[int]:
    """Return the line numbers of ``text`` that assign a value to ``NPM_TOKEN``.

    A YAML mapping key (block, flow, or quoted) and a shell or PowerShell
    assignment are reported whichever secret feeds them. A context read
    (``secrets.NPM_TOKEN``, ``env.NPM_TOKEN``), an ``==`` comparison, a longer
    or prefixed name, and prose without ``:`` or ``=`` after the name are not
    reported.

    Args:
        text: YAML document text to scan.

    Returns:
        Ascending 1-based line numbers of matching lines, or an empty list.
    """
    return _matching_line_numbers(_NPM_TOKEN_ASSIGNMENT, text)


def collect_offenders(
    relative_path: str, text: str, finder: Callable[[str], list[int]]
) -> list[str]:
    """Return one ``<relative_path>:<line>`` diagnostic per line ``finder`` reports.

    Formats the tree-scan diagnostics so every offending line is named, in the
    ascending order ``finder`` returns.

    Args:
        relative_path: POSIX path of the scanned file relative to the repo root.
        text: Full text of the scanned file.
        finder: Helper that returns the matching 1-based line numbers of text.

    Returns:
        Diagnostics in line order, or an empty list when ``finder`` reports none.
    """
    # Name each matching line separately so the failure message lists them all.
    return [f"{relative_path}:{line_number}" for line_number in finder(text)]


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
        pytest.param("${{ secrets[ 'NPM_TOKEN' ] }}", [1], id="spaced-bracket"),
        pytest.param("${{ secrets['npm_token'] }}", [1], id="lowercase-bracket"),
        pytest.param("${{ vars.NPM_TOKEN }}", [1], id="vars-dot"),
        pytest.param("${{ vars['NPM_TOKEN'] }}", [1], id="vars-bracket"),
    ],
)
def test_find_npm_token_references_detects_reintroduced_reference(
    text: str, expected: list[int]
) -> None:
    """A reintroduced ``NPM_TOKEN`` secret or variable reference is reported.

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
        pytest.param("${{ vars.NPM_TOKEN_V2 }}", id="vars-longer-name"),
        pytest.param("${{ mysecrets.NPM_TOKEN }}", id="prefixed-context-name"),
    ],
)
def test_find_npm_token_references_ignores_non_matching_text(text: str) -> None:
    """Text that does not consume the ``NPM_TOKEN`` secret or variable is ignored."""
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


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        pytest.param(
            'echo "//registry.npmjs.org/:_authToken=${TOKEN}" >> ~/.npmrc',
            [1],
            id="npmrc-echo-registry-scoped",
        ),
        pytest.param("_authToken=${TOKEN}", [1], id="npmrc-bare-key"),
        pytest.param(
            "NPM_CONFIG__AUTHTOKEN: ${{ secrets.PUBLISH }}",
            [1],
            id="npm-config-env-upper",
        ),
        pytest.param("npm_config__authToken: x", [1], id="npm-config-env-lower"),
        pytest.param(
            "npm_config_//registry.npmjs.org/:_authToken: x",
            [1],
            id="npm-config-env-registry-scoped",
        ),
        pytest.param(
            'npm config set _authToken "$TOKEN"', [1], id="npm-config-set-bare"
        ),
        pytest.param(
            'npm config set //registry.npmjs.org/:_authToken "$TOKEN"',
            [1],
            id="npm-config-set-registry-scoped",
        ),
    ],
)
def test_find_npm_auth_token_config_references_detects_config_key(
    text: str, expected: list[int]
) -> None:
    """An ``_authToken`` configuration key is reported in each supported form."""
    # Arrange: the parametrized text and its expected line numbers.

    # Act
    result = find_npm_auth_token_config_references(text)

    # Assert
    assert result == expected, f"input {text!a} returned {result}, expected {expected}"


@pytest.mark.parametrize(
    "text",
    [
        pytest.param("id-token: write", id="oidc-permission"),
        pytest.param(
            'registry-url: "https://registry.npmjs.org"', id="setup-node-registry-url"
        ),
        pytest.param("always-auth: true", id="always-auth"),
        pytest.param("NODE_AUTH_TOKEN: x", id="node-auth-token-is-separate-family"),
        pytest.param("GH_AUTHTOKEN: x", id="letter-prefixed-name"),
        pytest.param("", id="empty"),
    ],
)
def test_find_npm_auth_token_config_references_ignores_non_matching_text(
    text: str,
) -> None:
    """Text without an ``_authToken`` configuration key is not reported."""
    # Arrange: the parametrized non-matching text.

    # Act
    result = find_npm_auth_token_config_references(text)

    # Assert
    assert result == [], f"input {text!a} returned {result}, expected []"


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        pytest.param(
            "env:\n  NPM_TOKEN: ${{ secrets.PUBLISH }}",
            [2],
            id="yaml-env-key-other-secret",
        ),
        pytest.param("env: { NPM_TOKEN: x }", [1], id="yaml-flow-mapping"),
        pytest.param('"NPM_TOKEN": x', [1], id="quoted-key"),
        pytest.param("export NPM_TOKEN=x", [1], id="shell-export"),
        pytest.param(
            'echo "NPM_TOKEN=x" >> "$GITHUB_ENV"', [1], id="github-env-append"
        ),
        pytest.param("$env:NPM_TOKEN = 'x'", [1], id="powershell-env"),
        pytest.param("npm_token: x", [1], id="lowercase-key"),
        pytest.param("NPM_TOKEN=", [1], id="empty-assignment-end-of-line"),
    ],
)
def test_find_npm_token_assignments_detects_assignment(
    text: str, expected: list[int]
) -> None:
    """An ``NPM_TOKEN`` assignment is reported whichever secret feeds it."""
    # Arrange: the parametrized text and its expected line numbers.

    # Act
    result = find_npm_token_assignments(text)

    # Assert
    assert result == expected, f"input {text!a} returned {result}, expected {expected}"


@pytest.mark.parametrize(
    "text",
    [
        pytest.param("${{ secrets.NPM_TOKEN }}", id="secrets-dot-context"),
        pytest.param("${{ env.NPM_TOKEN }}", id="env-context-read"),
        pytest.param("NPM_TOKEN_V2: x", id="longer-name-key"),
        pytest.param("MY_NPM_TOKEN: x", id="prefixed-name-key"),
        pytest.param("# NPM_TOKEN is no longer used", id="prose-comment"),
        pytest.param("", id="empty"),
        pytest.param("if: ${{ env.NPM_TOKEN == '' }}", id="equality-comparison"),
        pytest.param('[[ $NPM_TOKEN == "" ]]', id="shell-equality-test"),
        pytest.param("if: ${{ env.NPM_TOKEN != '' }}", id="inequality-comparison"),
    ],
)
def test_find_npm_token_assignments_ignores_non_matching_text(text: str) -> None:
    """Text that reads but does not assign ``NPM_TOKEN`` is not reported."""
    # Arrange: the parametrized non-matching text.

    # Act
    result = find_npm_token_assignments(text)

    # Assert
    assert result == [], f"input {text!a} returned {result}, expected []"


def test_collect_offenders_names_each_matching_line() -> None:
    """Each line the finder reports becomes one ``<path>:<line>`` diagnostic."""
    # Arrange
    relative_path = ".github/workflows/example.yml"
    text = "NPM_TOKEN: a\nname: b\nnpm_token: c"
    expected = [
        ".github/workflows/example.yml:1",
        ".github/workflows/example.yml:3",
    ]

    # Act
    result = collect_offenders(relative_path, text, find_npm_token_assignments)

    # Assert
    assert result == expected, f"input {text!a} returned {result}, expected {expected}"


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


@pytest.mark.parametrize(
    ("finder", "family_label"),
    [
        pytest.param(
            find_npm_token_references,
            "NPM_TOKEN secret or variable references",
            id="npm-token-context",
        ),
        pytest.param(
            find_node_auth_token_references,
            "NODE_AUTH_TOKEN references",
            id="node-auth-token",
        ),
        pytest.param(
            find_npm_auth_token_config_references,
            "_authToken configuration keys",
            id="npm-auth-token-config",
        ),
        pytest.param(
            find_npm_token_assignments,
            "NPM_TOKEN assignments",
            id="npm-token-assignment",
        ),
    ],
)
def test_github_yaml_files_contain_no_npm_token_route(
    finder: Callable[[str], list[int]], family_label: str
) -> None:
    """No YAML file under ``.github/`` has a line reported by the family finder."""
    # Arrange
    files = enumerate_github_yaml_files(GITHUB_DIR)
    offenders: list[str] = []

    # Act: record every matching line as ``<relative-posix-path>:<line>``.
    for path in files:
        relative_path = path.relative_to(REPO_ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        offenders.extend(collect_offenders(relative_path, text, finder))

    # Assert
    assert offenders == [], (
        f"{family_label} found; npm publishing uses OIDC trusted publishing and "
        f"needs no token: {offenders}"
    )
