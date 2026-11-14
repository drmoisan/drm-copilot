"""Contract tests for the bash command-shape surfaces of issue #1165.

The command-shape rule exists on three surfaces (the Claude rule, the Codex
converted-rule skill, and the Copilot instruction) and as a table in the
``## Command-Text Restrictions`` section of the ``execution-environment`` brief.
These tests pin that the four surfaces state the same forms and context split,
that the new files carry the frontmatter their runtimes read, that the Copilot
instruction matches its push-down bundle copy, and that the ``parallel-orchestrate``
conflict-resolution step no longer instructs a command the Claude hook denies.

Every assertion reads committed repository text only. No test creates, writes, or
removes a file, and no test consults an external service.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import cast

import yaml

_REPO_ROOT = Path(__file__).resolve().parents[3]
_RESOURCES = "extensions/drm-copilot/resources"
_CLAUDE_RULE = ".claude/rules/bash-command-shape.md"
_CODEX_SKILL = ".agents/skills/bash-command-shape/SKILL.md"
_COPILOT_INSTRUCTION = ".github/instructions/bash-command-shape.instructions.md"
_COPILOT_INSTRUCTION_BUNDLE = (
    f"{_RESOURCES}/customizations/.github/instructions/"
    "bash-command-shape.instructions.md"
)
_BRIEF = ".claude/skills/execution-environment/SKILL.md"
_PARALLEL_ORCHESTRATE_COPIES = (
    ".claude/skills/parallel-orchestrate/SKILL.md",
    f"{_RESOURCES}/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md",
)

# Tokens every command-shape surface must carry so the forms and the context
# split stay the same wherever an agent reads them.
_SHARED_FORM_TOKENS = (
    "| Intent | Agent-isolated worktree | Sibling worktree |",
    "git -C <abs>",
    "poetry -C <abs>",
    "--directory",
    "npm --prefix <abs>",
    "npm --prefix <abs> run <script>",
    "sh <SCRATCH>/<file>.sh",
    "Read or Grep tool",
    "absolute-path read",
    "sibling worktree",
)

_WHITESPACE = re.compile(r"\s+")


def _read(relative_path: str) -> str:
    """Return the UTF-8 text of a committed file.

    Args:
        relative_path (str): Repository-relative path with forward slashes.

    Returns:
        str: The file's UTF-8 decoded content.

    Side Effects:
        Reads from disk. Writes nothing.
    """

    return (_REPO_ROOT / relative_path).read_text(encoding="utf-8")


def _collapse(text: str) -> str:
    """Collapse whitespace runs so a wrapped phrase stays searchable.

    Args:
        text (str): Raw text, possibly spanning many lines.

    Returns:
        str: The text with every whitespace run replaced by one space. The
        function is pure and has no side effects.
    """

    return _WHITESPACE.sub(" ", text)


def _section(heading: str, relative_path: str) -> str:
    """Return the whitespace-collapsed body of one `## ` section of a document.

    Args:
        heading (str): The full heading line, for example
            ``## Command-Text Restrictions``.
        relative_path (str): Repository-relative path of the document.

    Returns:
        str: The collapsed text between the heading and the next `## ` heading.

    Raises:
        ValueError: If the heading is absent from the document.

    Side Effects:
        Reads the named file. Writes nothing.
    """

    text = _read(relative_path)
    start = text.index(f"\n{heading}\n") + len(heading) + 2
    end = text.find("\n## ", start)
    return _collapse(text[start : end if end != -1 else len(text)])


def _frontmatter(relative_path: str) -> dict[str, object]:
    """Parse the leading YAML frontmatter block of a document into a mapping.

    Isolates the untyped ``yaml.safe_load`` boundary so callers work against a
    ``dict[str, object]``.

    Args:
        relative_path (str): Repository-relative path of the document.

    Returns:
        dict[str, object]: The parsed mapping, or an empty mapping when the
        document has no frontmatter block or the block is not a mapping.

    Side Effects:
        Reads the named file. Writes nothing.
    """

    text = _read(relative_path)
    if not text.startswith("---\n"):
        return {}
    closing = text.find("\n---\n", 4)
    if closing == -1:
        return {}
    parsed = yaml.safe_load(text[4:closing])
    if not isinstance(parsed, dict):
        return {}
    return cast("dict[str, object]", parsed)


def _body(relative_path: str) -> str:
    """Return the collapsed text of a document after its frontmatter block.

    Args:
        relative_path (str): Repository-relative path of the document.

    Returns:
        str: The collapsed body text, or the collapsed whole text when the
        document has no frontmatter block.

    Side Effects:
        Reads the named file. Writes nothing.
    """

    text = _read(relative_path)
    closing = text.find("\n---\n", 4) if text.startswith("---\n") else -1
    return _collapse(text if closing == -1 else text[closing + 5 :])


def _is_non_empty_string(value: object) -> bool:
    """Report whether a parsed frontmatter value is a non-blank string.

    Args:
        value (object): A value read from a parsed frontmatter mapping.

    Returns:
        bool: ``True`` when the value is a string with visible characters. The
        function is pure and has no side effects.
    """

    return isinstance(value, str) and bool(value.strip())


def test_command_shape_forms_are_consistent_across_surfaces() -> None:
    """The rule, the Codex skill, the Copilot instruction, and the brief agree."""

    # Arrange
    surfaces = {
        _CLAUDE_RULE: _body(_CLAUDE_RULE),
        _CODEX_SKILL: _body(_CODEX_SKILL),
        _COPILOT_INSTRUCTION: _body(_COPILOT_INSTRUCTION),
        f"{_BRIEF} ## Command-Text Restrictions": _section(
            "## Command-Text Restrictions", _BRIEF
        ),
    }

    # Act
    missing = {
        name: [token for token in _SHARED_FORM_TOKENS if token not in text]
        for name, text in surfaces.items()
    }

    # Assert
    assert all(not tokens for tokens in missing.values()), (
        "command-shape surfaces lack shared form tokens: "
        f"{ {name: tokens for name, tokens in missing.items() if tokens} }"
    )


def test_rule_states_command_shape_rule_and_isolated_refusal() -> None:
    """The Claude rule states the rule and the isolated-worktree refusal."""

    # Arrange
    body = _body(_CLAUDE_RULE)

    # Act
    missing = [
        token
        for token in (
            "Never chain `cd` before a read command",
            "`git -C <other worktree>` is refused",
        )
        if token not in body
    ]

    # Assert
    assert missing == [], f"{_CLAUDE_RULE} lacks {missing}"


def test_codex_skill_frontmatter_source_and_claude_only_statement() -> None:
    """The Codex skill names itself, cites its source rule, and scopes the deny."""

    # Arrange
    mapping = _frontmatter(_CODEX_SKILL)
    body = _body(_CODEX_SKILL)

    # Act
    missing = [
        token
        for token in (
            "Source: legacy Claude rule",
            "cd-chained deny is produced only on Claude Code",
        )
        if token not in body
    ]

    # Assert
    assert mapping.get("name") == "bash-command-shape", f"name is {mapping.get('name')}"
    assert _is_non_empty_string(mapping.get("description")), "description is empty"
    assert missing == [], f"{_CODEX_SKILL} lacks {missing}"


def test_copilot_instruction_frontmatter_is_always_loaded() -> None:
    """The Copilot instruction applies to every file and names and describes itself."""

    # Arrange
    mapping = _frontmatter(_COPILOT_INSTRUCTION)

    # Act
    apply_to = mapping.get("applyTo")

    # Assert
    assert apply_to == "**", f"applyTo is {apply_to!r}"
    assert _is_non_empty_string(mapping.get("name")), "name is empty"
    assert _is_non_empty_string(mapping.get("description")), "description is empty"


def test_copilot_instruction_matches_bundle_copy() -> None:
    """The Copilot instruction is byte-identical to its push-down bundle copy."""

    # Arrange
    source = (_REPO_ROOT / _COPILOT_INSTRUCTION).read_bytes()

    # Act
    bundle = (_REPO_ROOT / _COPILOT_INSTRUCTION_BUNDLE).read_bytes()

    # Assert
    assert bundle == source, f"{_COPILOT_INSTRUCTION_BUNDLE} differs from the source"


def test_parallel_orchestrate_step_c_uses_keep_and_references_brief_table() -> None:
    """Conflict-resolution step (c) reverts with --keep and cites the brief table."""

    # Arrange
    defects: list[str] = []

    # Act
    # Slice step (c) of each copy so the assertions cannot be met by text in
    # another step of the same skill.
    for relative_path in _PARALLEL_ORCHESTRATE_COPIES:
        text = _read(relative_path)
        start = text.index("- (c) On")
        end = text.index("- (d) On success", start)
        step_c = _collapse(text[start:end])
        if "reset --keep HEAD~1" not in step_c:
            defects.append(f"{relative_path}: no `reset --keep HEAD~1`")
        if "Command-Text Restrictions table" not in step_c:
            defects.append(f"{relative_path}: no `Command-Text Restrictions table`")
        if "reset --hard HEAD~1" in step_c:
            defects.append(f"{relative_path}: still carries `reset --hard HEAD~1`")

    # Assert
    assert defects == [], "parallel-orchestrate step (c) defects: " + "; ".join(defects)
