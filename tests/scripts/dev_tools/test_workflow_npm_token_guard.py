"""Guard against reintroducing a token-based npm publish under ``.github/``.

These tests prove each detection helper in
``tests/scripts/dev_tools/npm_token_guard_test_support.py`` against in-memory
strings and then scan every YAML file under ``.github/`` with it. The detected
families, the scan scope, and the filesystem-only reading rules are described
in that module's docstring (issues #712, #739, and #845).
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from tests.scripts.dev_tools.npm_token_guard_test_support import (
    GITHUB_DIR,
    REPO_ROOT,
    collect_offenders,
    enumerate_github_yaml_files,
    find_node_auth_token_references,
    find_npm_auth_token_config_references,
    find_npm_token_assignments,
    find_npm_token_references,
)

if TYPE_CHECKING:
    from collections.abc import Callable


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
        pytest.param(
            "NPM_TOKEN+=${{ secrets.X }}", [1], id="bash-append-secret-expression"
        ),
        pytest.param("export NPM_TOKEN+=x", [1], id="shell-export-append"),
        pytest.param("$env:NPM_TOKEN += 'x'", [1], id="powershell-env-append"),
        pytest.param("env.NPM_TOKEN += x", [1], id="dot-prefixed-append-reported"),
        pytest.param("MY-NPM_TOKEN+=x", [1], id="hyphen-prefixed-append-reported"),
        pytest.param("(( NPM_TOKEN += 1 ))", [1], id="arithmetic-compound-append"),
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
        pytest.param("NPM_TOKEN_V2+=x", id="longer-name-append"),
        pytest.param("(( NPM_TOKEN++ ))", id="arithmetic-increment"),
        pytest.param("NPM_TOKEN++=x", id="double-plus-equals-not-reported"),
    ],
)
def test_find_npm_token_assignments_ignores_non_matching_text(text: str) -> None:
    """Text with no assignment operator applied to ``NPM_TOKEN`` is not reported."""
    # Arrange: the parametrized non-matching text.

    # Act
    result = find_npm_token_assignments(text)

    # Assert
    assert result == [], f"input {text!a} returned {result}, expected []"


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        pytest.param(
            '[ $NPM_TOKEN = "" ]',
            [1],
            id="residual-single-equals-shell-test-reported",
        ),
        pytest.param(
            "[[ $NPM_TOKEN =~ ^npm_ ]]",
            [1],
            id="residual-bash-regex-match-reported",
        ),
        pytest.param("NPM_TOKEN+=x", [1], id="bash-append-reported"),
        pytest.param(
            "NPM_TOKEN==value",
            [],
            id="accepted-double-equals-narrowing-not-reported",
        ),
        pytest.param(
            "NPM_TOKEN+==x", [], id="accepted-append-double-equals-not-reported"
        ),
    ],
)
def test_find_npm_token_assignments_pins_documented_residuals(
    text: str, expected: list[int]
) -> None:
    """Pin the documented residual and narrowing behavior of the assignment finder.

    The #845 spec non-goal accepted a bash ``+=`` append as an unreported
    residual of the textual ``NPM_TOKEN`` assignment rule. Issue #933 reversed
    that non-goal, so ``NPM_TOKEN+=x`` is now reported. The other two #845
    residuals remain reported: a single ``=`` shell test and a bash ``=~``
    regex match. The #845 backward-compatibility section accepts the ``==``
    narrowing, so ``NPM_TOKEN==value`` is not reported, and the same narrowing
    leaves ``NPM_TOKEN+==x`` unreported. These rows pin the current behavior
    so a change to any outcome is visible.
    """
    # Arrange: the parametrized text and its expected line numbers.

    # Act
    result = find_npm_token_assignments(text)

    # Assert
    assert result == expected, f"input {text!a} returned {result}, expected {expected}"


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
