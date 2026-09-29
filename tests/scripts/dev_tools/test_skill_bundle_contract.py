"""Unit tests for skill frontmatter parsing and script-reference extraction.

Covers ``parse_allowed_tools`` and ``extract_script_references`` in
``scripts/dev_tools/skill_bundle_contract.py`` with inline skill texts only.
Every path in these strings is fictitious so that no test string names a real
relocated script path.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools.skill_bundle_contract import (
    extract_script_references,
    parse_allowed_tools,
)


def _skill(frontmatter: str, body: str) -> str:
    """Build a skill text from frontmatter lines and a body.

    Args:
        frontmatter (str): Lines placed between the ``---`` fences.
        body (str): Text after the closing fence.

    Returns:
        str: The assembled ``SKILL.md`` text.
    """

    return f"---\n{frontmatter}\n---\n{body}"


def test_parse_allowed_tools_returns_list_entries() -> None:
    """A YAML list value is returned entry by entry, in order."""

    # Arrange
    text = _skill('name: demo\nallowed-tools:\n  - Read\n  - "Bash(git log *)"', "Body.")

    # Act
    tools = parse_allowed_tools(text)

    # Assert
    assert tools == ("Read", "Bash(git log *)"), f"Unexpected tools: {tools}"


def test_parse_allowed_tools_returns_empty_without_frontmatter() -> None:
    """A text with no leading fence declares no tools."""

    # Arrange
    text = "# Title\n\nallowed-tools: Read\n"

    # Act
    tools = parse_allowed_tools(text)

    # Assert
    assert tools == (), f"Expected no tools, got {tools}"


def test_parse_allowed_tools_raises_on_unterminated_frontmatter() -> None:
    """An opening fence without a closing fence is rejected."""

    # Arrange
    text = "---\nname: demo\nallowed-tools: Read\n"

    # Act / Assert
    with pytest.raises(ValueError, match="never closed"):
        parse_allowed_tools(text)


def test_parse_allowed_tools_ignores_unparseable_description() -> None:
    """An unquoted colon in ``description`` does not block tool parsing."""

    # Arrange
    text = _skill(
        "name: demo\ndescription: Routes work: by budget\nallowed-tools:\n  - Read\n  - Grep",
        "Body.",
    )

    # Act
    tools = parse_allowed_tools(text)

    # Assert
    assert tools == ("Read", "Grep"), f"Unexpected tools: {tools}"


def test_parse_allowed_tools_splits_scalar_string_value() -> None:
    """The space-separated scalar form is split on whitespace."""

    # Arrange
    text = _skill("name: demo\nallowed-tools: Bash Read", "Body.")

    # Act
    tools = parse_allowed_tools(text)

    # Assert
    assert tools == ("Bash", "Read"), f"Unexpected tools: {tools}"


def test_extract_reads_bash_allowed_tools_pattern() -> None:
    """A ``Bash(bash <path> *)`` permission entry yields its script path."""

    # Arrange
    text = _skill(
        'name: demo\nallowed-tools:\n  - "Bash(bash .claude/lib/example/example.sh *)"',
        "No invocation in the body.",
    )

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == (".claude/lib/example/example.sh",), f"Got {references}"


@pytest.mark.parametrize("verb", ["bash", "sh", "source"])
def test_extract_reads_bash_sh_and_source_forms(verb: str) -> None:
    """Each shell invocation verb yields the invoked path."""

    # Arrange
    text = f"Run `{verb} scripts/tools/example.sh --flag` first."

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == ("scripts/tools/example.sh",), f"{verb}: got {references}"


def test_extract_reads_pwsh_file_form() -> None:
    """``pwsh ... -File <path>`` on one line yields the script path."""

    # Arrange
    text = "Run `pwsh -NoProfile -File scripts/tools/Example.ps1 -Name x`."

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == ("scripts/tools/Example.ps1",), f"Got {references}"


@pytest.mark.parametrize("operator", ["&", "."])
def test_extract_reads_call_operator_and_dot_source_forms(operator: str) -> None:
    """The call operator and dot-source forms yield the invoked path."""

    # Arrange
    text = f"Invoke it with `{operator} ./scripts/tools/Example.ps1`."

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == ("scripts/tools/Example.ps1",), f"{operator}: got {references}"


def test_extract_reads_import_module_path_form() -> None:
    """``Import-Module <path>`` yields the module path."""

    # Arrange
    text = "Import-Module .claude/lib/example/Example.psm1 -Force"

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == (".claude/lib/example/Example.psm1",), f"Got {references}"


def test_extract_reads_import_module_join_path_form() -> None:
    """``Import-Module (Join-Path <expr> '<path>')`` yields the quoted path."""

    # Arrange
    text = "Import-Module (Join-Path $root '.claude/lib/example/Example.psm1')"

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == (".claude/lib/example/Example.psm1",), f"Got {references}"


def test_extract_reads_python_path_form() -> None:
    """``python <path>.py`` yields the script path."""

    # Arrange
    text = "Run `python3 scripts/tools/example.py --check`."

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == ("scripts/tools/example.py",), f"Got {references}"


def test_extract_resolves_python_module_form() -> None:
    """``python -m <dotted.name>`` resolves to the module's .py path."""

    # Arrange
    text = "Run `poetry run python -m scripts.tools.example_cli --flag`."

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == ("scripts/tools/example_cli.py",), f"Got {references}"


def test_extract_normalizes_leading_dot_slash() -> None:
    """A leading ``./`` is removed from the returned path."""

    # Arrange
    text = "Run `bash ./scripts/tools/example.sh`."

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == ("scripts/tools/example.sh",), f"Got {references}"


def test_extract_ignores_placeholder_paths() -> None:
    """Tokens carrying ``<``, ``>``, ``{``, ``}``, or ``$`` name no file."""

    # Arrange
    text = (
        "Run `bash scripts/tools/<name>.sh`, `bash $ROOT/tools/example.sh`, "
        "and `bash scripts/{a,b}/example.sh`."
    )

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == (), f"Expected no references, got {references}"


def test_extract_ignores_glob_paths() -> None:
    """A token containing ``*`` is a glob, not a file."""

    # Arrange
    text = "Run `bash scripts/tools/*.sh`."

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == (), f"Expected no references, got {references}"


def test_extract_ignores_backticked_citation_without_invocation() -> None:
    """A backticked path with no invocation form is a citation only."""

    # Arrange
    text = "See `scripts/tools/example.sh` for the implementation."

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == (), f"Expected no references, got {references}"


def test_extract_deduplicates_and_sorts_references() -> None:
    """Repeated references collapse, and the result is sorted."""

    # Arrange
    text = (
        "Run `bash scripts/tools/zeta.sh`, then `sh scripts/tools/alpha.sh`, "
        "then `bash scripts/tools/zeta.sh` again."
    )

    # Act
    references = extract_script_references(text)

    # Assert
    assert references == (
        "scripts/tools/alpha.sh",
        "scripts/tools/zeta.sh",
    ), f"Got {references}"
