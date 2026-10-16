"""Detection helpers for the npm token guard tests (issue #903 split).

Purpose: ``.github/workflows/publish-mcp-npm.yml`` publishes the MCP server
package through npm trusted publishing (OIDC), which needs no stored token.
The guard tests in ``test_workflow_npm_token_guard.py`` fail if any YAML file
under ``.github/`` configures a long-lived npm token through any of four
detected families: a reference to the ``NPM_TOKEN`` secret or variable
(``secrets`` or ``vars`` context), any mention of ``NODE_AUTH_TOKEN``, an
``_authToken`` configuration key in any form (an ``.npmrc`` line, an
``npm_config_`` environment variable, or ``npm config set``), and an
``NPM_TOKEN`` assignment fed from any secret (issues #712 and #739).

Scope: every ``*.yml`` and ``*.yaml`` file under ``.github/``, enumerated
recursively. Detection is textual and line-wise, so a match in any key,
block scalar, expression, or comment is reported. Detection is also proven
against in-memory strings, so no workflow edit is needed to show that the
helpers report a reintroduced route.

The repository root is derived from this file's own resolved location, and
files are enumerated and read from disk through ``pathlib`` only, whether or
not version control tracks them. The module has no dependency on the current
working directory, version-control state, or network access. This module is
not collected by pytest; it holds the patterns and finders only.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

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
    r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*\+?=(?!=)", re.IGNORECASE
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
    assignment are reported whichever secret feeds them. An append is also
    reported (issue #933): a bash ``NPM_TOKEN+=x``, an ``export NPM_TOKEN+=x``,
    and a PowerShell ``$env:NPM_TOKEN += 'x'``. A dot- or hyphen-prefixed ``=``
    or ``+=`` assignment such as ``env.NPM_TOKEN += x`` or ``MY-NPM_TOKEN+=x``
    is also reported, because the assignment form needs only a word boundary
    before the name. A context read without an assignment operator
    (``secrets.NPM_TOKEN``, or ``env.NPM_TOKEN`` in an expression), an ``==``
    comparison, a ``+==`` sequence, a name extended by a letter, digit, or
    underscore (``NPM_TOKEN_V2``, ``MY_NPM_TOKEN``), and prose without ``:``,
    ``=``, or ``+=`` after the name are not reported.

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
