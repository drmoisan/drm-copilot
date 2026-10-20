"""Pure text scanners for the pack-manifest dependency-closure test (issue #984).

Purpose:
    Test support for
    `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`.
    A pushed-down PowerShell hook that dot-sources or imports a sibling file
    through `$PSScriptRoot` fails to load in the destination when that sibling
    is absent from the pack manifests the destination selected. These
    functions read PowerShell and configuration text and report the
    dependency targets, the unrecognized `$PSScriptRoot` spellings, and the
    hook script paths named in command text, so the closure test can compare
    them with a manifest's effective path set.

Scope:
    Every function is pure: it takes text and returns values. No function
    reads or writes a file, so the self-tests run over in-memory strings.

Recognized `$PSScriptRoot` dependency forms (spec FR-4.5):
    F1 positional `Join-Path $PSScriptRoot '<child>'`; F2 named
    `Join-Path -Path $PSScriptRoot -ChildPath '<child>'`; F3 the F2 form split
    by a backtick line continuation; F4 the nested
    `Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '<a>') -ChildPath
    (Join-Path -Path '<b>' -ChildPath '<c>')`; F5 the parent form
    `Join-Path (Split-Path $PSScriptRoot -Parent) '<child>'`; F6 a variable
    assigned from F1 or F2 and imported later; F7 an F1 or F2 data file.

Named non-dependency forms:
    the repository-root chain `Split-Path (Split-Path $PSScriptRoot -Parent)
    -Parent`, the parameter default `$ScriptRoot = $PSScriptRoot`, the
    canonicalization base argument `-BasePath $PSScriptRoot`, and the F8 call
    `Get-CodexRoutingModuleCandidate -ScriptRoot $PSScriptRoot`, whose
    dynamic candidates are named by `CODEX_ROUTING_MODULE_CANDIDATES`.
"""

from __future__ import annotations

import json
import posixpath
import re
from typing import TYPE_CHECKING, Literal, cast

if TYPE_CHECKING:
    from collections.abc import Mapping
    from collections.abc import Set as AbstractSet

CODEX_ROUTING_MODULE_CANDIDATES: tuple[str, ...] = (
    ".codex/lib/codex-routing/CodexDeployment.psm1",
    ".codex/lib/codex-routing/CodexTopology.psm1",
)

HookCommandSource = Literal["settings", "frontmatter", "toml"]

# A literal child path: single-quoted, or double-quoted without interpolation.
_LITERAL = r"""(?:'([^']+)'|"([^"$`]+)")"""
_FLAGS = re.IGNORECASE

_NESTED_FORM = re.compile(
    r"Join-Path\s+-Path\s+\(\s*Join-Path\s+-Path\s+\$PSScriptRoot\s+-ChildPath\s+"
    + _LITERAL
    + r"\s*\)\s+-ChildPath\s+\(\s*Join-Path\s+-Path\s+"
    + _LITERAL
    + r"\s+-ChildPath\s+"
    + _LITERAL
    + r"\s*\)",
    _FLAGS,
)
_PARENT_FORM = re.compile(
    r"Join-Path\s+(?:-Path\s+)?\(\s*Split-Path\s+(?:-Path\s+)?\$PSScriptRoot\s+"
    r"-Parent\s*\)\s+(?:-ChildPath\s+)?" + _LITERAL,
    _FLAGS,
)
_NAMED_FORM = re.compile(
    r"Join-Path\s+-Path\s+\$PSScriptRoot\s+-ChildPath\s+" + _LITERAL, _FLAGS
)
_POSITIONAL_FORM = re.compile(r"Join-Path\s+\$PSScriptRoot\s+" + _LITERAL, _FLAGS)

_NON_DEPENDENCY_FORMS: tuple[re.Pattern[str], ...] = (
    re.compile(
        r"Split-Path\s+\(\s*Split-Path\s+\$PSScriptRoot\s+-Parent\s*\)\s+-Parent",
        _FLAGS,
    ),
    re.compile(r"\$ScriptRoot\s*=\s*\$PSScriptRoot\b", _FLAGS),
    re.compile(r"-BasePath\s+\$PSScriptRoot\b", _FLAGS),
    re.compile(
        r"Get-CodexRoutingModuleCandidate\s+-ScriptRoot\s+\$PSScriptRoot\b", _FLAGS
    ),
)

_OCCURRENCE = re.compile(r"\$PSScriptRoot\b", _FLAGS)
_CONTINUATION = re.compile(r"`\r?\n[ \t]*")
_HOOK_PATH = re.compile(r"\.(?:claude|codex)/hooks/[A-Za-z0-9_.-]+\.ps1")
_TOML_COMMAND = re.compile(r"^\s*command(?:_windows)?\s*=\s*(.+)$")
_COMMENT_PRECEDERS = frozenset(" \t\r\n;{}()|&,=")


def _here_string_opens(text: str, index: int) -> str | None:
    """Return the here-string quote that opens at ``index``, if one does.

    Args:
        text (str): The PowerShell text being scanned.
        index (int): Position of a candidate ``@`` character.

    Returns:
        str | None: ``"'"`` or ``'"'`` when ``@'`` or ``@"`` is followed only
        by spaces or tabs up to the end of the line; otherwise ``None``.
    """

    if text[index] != "@" or index + 1 >= len(text) or text[index + 1] not in "'\"":
        return None
    rest = text[index + 2 :]
    line_end = rest.find("\n")
    tail = rest if line_end < 0 else rest[:line_end]
    return text[index + 1] if tail.strip() == "" else None


def strip_powershell_comments(text: str) -> str:
    """Remove PowerShell comments while keeping every string literal intact.

    Removes ``<# ... #>`` block comments and ``#`` line comments that occur
    outside single-quoted strings, double-quoted strings, and here-strings. A
    ``#`` starts a line comment only at a token boundary (start of text,
    whitespace, or one of ``;{}()|&,=``). Newlines inside a removed block
    comment are kept so line positions stay stable.

    Args:
        text (str): PowerShell source text.

    Returns:
        str: The text without comments.
    """

    output: list[str] = []
    index = 0
    length = len(text)
    # Walk the text once as a small state machine; each branch consumes one
    # lexical unit (comment, string, here-string, or a single code character).
    while index < length:
        char = text[index]
        here_quote = _here_string_opens(text, index)
        if here_quote is not None:
            # A here-string ends at a line that starts with the closing quote
            # followed by '@'; its body is copied verbatim.
            close = text.find("\n" + here_quote + "@", index + 2)
            end = length if close < 0 else close + 3
            output.append(text[index:end])
            index = end
        elif text.startswith("<#", index):
            close = text.find("#>", index + 2)
            end = length if close < 0 else close + 2
            output.append("\n" * text.count("\n", index, end))
            index = end
        elif char == "#" and (index == 0 or text[index - 1] in _COMMENT_PRECEDERS):
            line_end = text.find("\n", index)
            index = length if line_end < 0 else line_end
        elif char in "'\"":
            end = _string_end(text, index)
            output.append(text[index:end])
            index = end
        else:
            output.append(char)
            index += 1
    return "".join(output)


def _string_end(text: str, start: int) -> int:
    """Return the index just past the string literal that opens at ``start``.

    Single-quoted strings escape a quote by doubling it; double-quoted strings
    also honor the backtick escape. An unterminated string runs to the end.

    Args:
        text (str): The PowerShell text being scanned.
        start (int): Position of the opening quote.

    Returns:
        int: The position after the closing quote.
    """

    quote = text[start]
    index = start + 1
    # Advance until the matching unescaped quote is found.
    while index < len(text):
        char = text[index]
        # A backtick escapes the next character, but only inside a
        # double-quoted string; single-quoted strings have no escape character.
        if quote == '"' and char == "`":
            index += 2
            continue
        # A doubled quote is an escaped quote and stays inside the string; a
        # single quote character closes it.
        if char == quote:
            if index + 1 < len(text) and text[index + 1] == quote:
                index += 2
                continue
            return index + 1
        index += 1
    return len(text)


def _normalize(text: str) -> str:
    """Strip comments and join backtick line continuations into one line.

    Args:
        text (str): PowerShell source text.

    Returns:
        str: Comment-free text in which each continuation is a single space.
    """

    return _CONTINUATION.sub(" ", strip_powershell_comments(text))


def _literal_values(match: re.Match[str]) -> list[str]:
    """Return the literal child-path values captured by a form match, in order.

    Each literal contributes two alternative groups (single and double
    quoted); exactly one of each pair is set.

    Args:
        match (re.Match[str]): A match of one of the dependency forms.

    Returns:
        list[str]: One value per literal in the form.
    """

    groups = match.groups()
    values: list[str] = []
    # Pair the single-quoted and double-quoted alternatives of each literal.
    for position in range(0, len(groups), 2):
        single, double = groups[position], groups[position + 1]
        values.append(single if single is not None else cast("str", double))
    return values


def _dependency_spans(normalized: str) -> list[tuple[int, int, str]]:
    """Return ``(start, end, relative_child)`` for every dependency-form match.

    Forms are applied from the most specific (nested) to the least specific
    (positional); a match that overlaps an earlier, more specific match is
    skipped so the inner ``-ChildPath '..'`` of an F4 form is not read twice.
    The parent form yields a child prefixed with ``../``.

    Args:
        normalized (str): Output of ``_normalize``.

    Returns:
        list[tuple[int, int, str]]: The claimed spans and their child paths
        relative to the source directory.
    """

    claimed: list[tuple[int, int, str]] = []
    forms = (
        (_NESTED_FORM, "nested"),
        (_PARENT_FORM, "parent"),
        (_NAMED_FORM, "direct"),
        (_POSITIONAL_FORM, "direct"),
    )
    # Claim spans form by form so specific spellings win over general ones.
    for pattern, kind in forms:
        for match in pattern.finditer(normalized):
            start, end = match.span()
            if any(start < c_end and c_start < end for c_start, c_end, _ in claimed):
                continue
            values = _literal_values(match)
            # F4 joins its three literals; F5 is relative to the parent of
            # the source directory; F1 and F2 carry the child path directly.
            if kind == "nested":
                child = posixpath.join(values[0], values[1], values[2])
            elif kind == "parent":
                child = posixpath.join("..", values[0])
            else:
                child = values[0]
            claimed.append((start, end, child))
    return sorted(claimed)


def extract_dependency_targets(text: str, source_path: str) -> list[str]:
    """Return the bundle-relative targets a file reaches through ``$PSScriptRoot``.

    Args:
        text (str): PowerShell source text.
        source_path (str): Bundle-relative POSIX path of the source file, for
            example ``.claude/hooks/gate.ps1``; targets resolve against its
            directory with ``posixpath.normpath``.

    Returns:
        list[str]: Sorted, de-duplicated bundle-relative target paths.

    Raises:
        ValueError: When a target resolves outside the bundle root.
    """

    directory = posixpath.dirname(source_path)
    targets: set[str] = set()
    # Resolve each claimed child path against the source directory.
    for _start, _end, child in _dependency_spans(_normalize(text)):
        resolved = posixpath.normpath(posixpath.join(directory, child))
        if resolved == ".." or resolved.startswith("../") or posixpath.isabs(resolved):
            raise ValueError(
                f"{source_path}: dependency '{child}' resolves outside the bundle "
                f"root ({resolved})"
            )
        targets.add(resolved)
    return sorted(targets)


def find_unrecognized_psscriptroot(text: str) -> list[str]:
    """Return each ``$PSScriptRoot`` occurrence that no named form recognizes.

    Comments are ignored. An occurrence is recognized when it lies inside a
    dependency-form match or a named non-dependency-form match.

    Args:
        text (str): PowerShell source text.

    Returns:
        list[str]: The trimmed source line of each unrecognized occurrence, in
        order; an empty list when every occurrence is recognized.
    """

    normalized = _normalize(text)
    spans = [(start, end) for start, end, _child in _dependency_spans(normalized)]
    # Add the spans of every named non-dependency form.
    for pattern in _NON_DEPENDENCY_FORMS:
        spans.extend(match.span() for match in pattern.finditer(normalized))
    unrecognized: list[str] = []
    # Report every occurrence outside all recognized spans.
    for occurrence in _OCCURRENCE.finditer(normalized):
        position = occurrence.start()
        if any(start <= position < end for start, end in spans):
            continue
        line_start = normalized.rfind("\n", 0, position) + 1
        line_end = normalized.find("\n", position)
        line_end = len(normalized) if line_end < 0 else line_end
        unrecognized.append(normalized[line_start:line_end].strip())
    return unrecognized


def find_missing_dependencies(
    source_texts: Mapping[str, str], effective_paths: AbstractSet[str]
) -> list[tuple[str, str]]:
    """Return every ``(source, target)`` pair whose target is not effective.

    Args:
        source_texts (Mapping[str, str]): Bundle-relative source path to its
            PowerShell text.
        effective_paths (AbstractSet[str]): The paths a destination receives
            when the owning manifest is selected (core plus that manifest).

    Returns:
        list[tuple[str, str]]: Sorted missing pairs; empty when closed.

    Raises:
        ValueError: When a target resolves outside the bundle root.
    """

    missing: list[tuple[str, str]] = []
    # Check every dependency of every source against the effective set.
    for source in sorted(source_texts):
        for target in extract_dependency_targets(source_texts[source], source):
            if target not in effective_paths:
                missing.append((source, target))
    return missing


def _settings_commands(text: str) -> list[str]:
    """Return every string ``command`` value in a settings JSON document.

    Args:
        text (str): The JSON text of a ``.claude/settings.json`` file.

    Returns:
        list[str]: The command strings in document order.
    """

    commands: list[str] = []
    stack: list[object] = [json.loads(text)]
    # Walk the decoded JSON depth-first and collect each command string.
    while stack:
        node = stack.pop()
        # Objects may carry a command and nest further values; arrays only
        # nest values; scalars carry nothing to collect.
        if isinstance(node, dict):
            mapping = cast("dict[str, object]", node)
            value = mapping.get("command")
            if isinstance(value, str):
                commands.append(value)
            stack.extend(mapping.values())
        elif isinstance(node, list):
            stack.extend(cast("list[object]", node))
    return commands


def _frontmatter_hook_lines(text: str) -> list[str]:
    """Return the lines of the frontmatter ``hooks:`` block of an agent file.

    Args:
        text (str): The Markdown text of an agent file.

    Returns:
        list[str]: The indented lines under the top-level ``hooks:`` key of
        the leading ``---`` frontmatter; empty when there is none.
    """

    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return []
    block: list[str] = []
    inside = False
    # Scan the frontmatter only; the closing '---' ends the scan.
    for line in lines[1:]:
        if line.strip() == "---":
            break
        # A non-indented, non-blank line is the next top-level key, so it
        # ends the hooks block; indented and blank lines belong to the block.
        if inside and line[:1] not in (" ", "\t", ""):
            inside = False
        # Collect lines while inside the block; the top-level "hooks:" key
        # line itself only opens the block.
        if inside:
            block.append(line)
        elif line.rstrip() == "hooks:":
            inside = True
    return block


def extract_hook_command_paths(text: str, source_kind: HookCommandSource) -> list[str]:
    """Return the hook script paths named by the command text of one file.

    Args:
        text (str): The file text.
        source_kind (HookCommandSource): ``"settings"`` for a settings JSON
            file (every ``command`` value), ``"frontmatter"`` for an agent
            Markdown file (the frontmatter ``hooks:`` block only), or
            ``"toml"`` for a Codex TOML file (``command`` and
            ``command_windows`` values).

    Returns:
        list[str]: Sorted, de-duplicated ``.claude/hooks/<name>.ps1`` or
        ``.codex/hooks/<name>.ps1`` paths.
    """

    # Select the command-bearing text according to the file kind.
    if source_kind == "settings":
        values = _settings_commands(text)
    elif source_kind == "frontmatter":
        values = _frontmatter_hook_lines(text)
    else:
        values = [
            match.group(1)
            for match in map(_TOML_COMMAND.match, text.splitlines())
            if match is not None
        ]
    paths: set[str] = set()
    # Collect every hook script path named in the selected text.
    for value in values:
        paths.update(_HOOK_PATH.findall(value))
    return sorted(paths)
