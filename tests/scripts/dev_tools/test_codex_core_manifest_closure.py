"""Closure guard for the Codex `core.json` pack manifest (issue #697).

The `core` pack is always published, so every hook registered by the bundled
`.codex/config.toml`, every file those hooks dot-source (transitively), and the
routing wrappers with their module imports must be listed in `core.json` alone.
A missing entry means a pack-mode push-down installs a hook whose dependency is
absent, and the hook fails at run time in the destination.
"""

from __future__ import annotations

import json
import posixpath
import re
import sys
from collections.abc import Callable, Iterable
from pathlib import Path

from scripts.dev_tools.push_down_codex_and_agents_customizations import (
    VIRTUAL_RESOURCE_PAIRS,
)

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLE_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)
CORE_MANIFEST = BUNDLE_ROOT / "pack-manifests" / "core.json"
WRAPPER_PATHS: tuple[str, ...] = (
    ".codex/scripts/Resolve-CodexTopology.ps1",
    ".codex/scripts/Resolve-CodexDeployment.ps1",
)
MODULE_DESTINATIONS: tuple[str, ...] = (
    ".codex/lib/codex-routing/CodexTopology.psm1",
    ".codex/lib/codex-routing/CodexDeployment.psm1",
)

ReadText = Callable[[str], str | None]

# A path expression relative to the script directory, or to its parent.
_PATH_EXPRESSION = (
    r"Join-Path\s+(?P<base>\$PSScriptRoot|\(Split-Path\s+\$PSScriptRoot\s+-Parent\))"
    r"\s+'(?P<relative>[^']+)'"
)
_DIRECT_DOT_SOURCE = re.compile(r"^\s*\.\s+\(" + _PATH_EXPRESSION + r"\)\s*$")
_VARIABLE_ASSIGNMENT = re.compile(
    r"^\s*(?P<variable>\$[\w:]+)\s*=\s*" + _PATH_EXPRESSION + r"\s*$"
)
_VARIABLE_DOT_SOURCE = re.compile(r"^\s*\.\s+(?P<variable>\$[\w:]+)\s*$")
_HOOK_COMMAND_PATH = re.compile(r"/(?P<path>\.codex/hooks/[^/\"']+\.ps1)")


def _resolve(script_path: str, base: str, relative: str) -> str:
    """Resolve a dot-source target to a bundle-relative POSIX path.

    Args:
        script_path: Bundle-relative path of the script containing the line.
        base: `$PSScriptRoot` or the `Split-Path ... -Parent` expression.
        relative: The quoted path operand of `Join-Path`.

    Returns:
        str: Normalized bundle-relative target path.
    """
    directory = posixpath.dirname(script_path)
    # The Split-Path form resolves against the parent of the script directory.
    if base.startswith("("):
        directory = posixpath.dirname(directory)
    return posixpath.normpath(posixpath.join(directory, relative))


def _dot_source_targets(script_path: str, text: str) -> set[str]:
    """Return the files one script dot-sources.

    Recognizes `. (Join-Path $PSScriptRoot '<f>')`, the same with
    `(Split-Path $PSScriptRoot -Parent)`, and a variable assigned from either
    expression that a later line dot-sources with `. $variable`. A variable that
    is never dot-sourced (for example a config-file path) is not a dependency.

    Args:
        script_path: Bundle-relative path of the script.
        text: Script source text.

    Returns:
        set[str]: Bundle-relative dot-source targets.
    """
    targets: set[str] = set()
    assigned: dict[str, str] = {}
    # Walk lines in order so a variable counts only when dot-sourced after
    # its assignment.
    for line in text.splitlines():
        direct = _DIRECT_DOT_SOURCE.match(line)
        if direct:
            targets.add(_resolve(script_path, direct["base"], direct["relative"]))
            continue
        assignment = _VARIABLE_ASSIGNMENT.match(line)
        if assignment:
            assigned[assignment["variable"].lower()] = _resolve(
                script_path, assignment["base"], assignment["relative"]
            )
            continue
        variable_source = _VARIABLE_DOT_SOURCE.match(line)
        if variable_source and variable_source["variable"].lower() in assigned:
            targets.add(assigned[variable_source["variable"].lower()])
    return targets


def compute_dot_source_closure(
    entry_paths: Iterable[str], read_text: ReadText
) -> set[str]:
    """Return the entry paths plus every file they dot-source, transitively.

    Args:
        entry_paths: Bundle-relative script paths to start from.
        read_text: Returns a script's text, or None when the file is absent.

    Returns:
        set[str]: The closed set of bundle-relative paths.
    """
    closure: set[str] = set()
    pending = list(entry_paths)
    # Breadth-first walk; each file is read once.
    while pending:
        path = pending.pop()
        if path in closure:
            continue
        closure.add(path)
        text = read_text(path)
        if text is not None:
            pending.extend(_dot_source_targets(path, text) - closure)
    return closure


def registered_hook_paths(config_text: str) -> set[str]:
    """Return every `.codex/hooks` path registered by a Codex config.

    Args:
        config_text: Text of a Codex `config.toml`.

    Returns:
        set[str]: Bundle-relative hook script paths from every event.
    """
    config = tomllib.loads(config_text)
    paths: set[str] = set()
    # Visit each event's matcher groups and each group's hook commands.
    for groups in config.get("hooks", {}).values():
        for group in groups:
            for hook in group.get("hooks", []):
                match = _HOOK_COMMAND_PATH.search(str(hook.get("command", "")))
                if match:
                    paths.add(match["path"])
    return paths


def find_missing_manifest_paths(
    config_text: str, manifest_paths: Iterable[str], read_text: ReadText
) -> list[str]:
    """Return registered hooks and their closure that a manifest omits.

    Args:
        config_text: Text of a Codex `config.toml`.
        manifest_paths: The manifest `paths` entries.
        read_text: Returns a script's text, or None when the file is absent.

    Returns:
        list[str]: Sorted closure paths absent from the manifest.
    """
    closure = compute_dot_source_closure(registered_hook_paths(config_text), read_text)
    return sorted(closure - set(manifest_paths))


def _memory_reader(files: dict[str, str]) -> ReadText:
    """Build a reader over an in-memory map of script texts.

    Args:
        files: Bundle-relative path to script text.

    Returns:
        ReadText: Reader returning None for an unknown path.
    """
    return files.get


def _bundle_reader(path: str) -> str | None:
    """Read a bundle file's text, or None when it does not exist.

    Args:
        path: Bundle-relative POSIX path.

    Returns:
        str | None: The file text, or None when absent.
    """
    file_path = BUNDLE_ROOT / path
    return file_path.read_text(encoding="utf-8") if file_path.is_file() else None


def test_closure_follows_join_path_dot_source() -> None:
    """The direct `. (Join-Path $PSScriptRoot ...)` form is followed (AC-5.3)."""
    files = {
        ".codex/hooks/a.ps1": ". (Join-Path $PSScriptRoot 'b.ps1')\n",
        ".codex/hooks/b.ps1": ". (Join-Path $PSScriptRoot 'c.ps1')\n",
        ".codex/hooks/c.ps1": "Write-Output 'c'\n",
    }

    closure = compute_dot_source_closure([".codex/hooks/a.ps1"], _memory_reader(files))

    assert closure == set(files)


def test_closure_follows_variable_dot_source() -> None:
    """A variable assigned from Join-Path counts only when dot-sourced (AC-5.3)."""
    files = {
        ".codex/hooks/a.ps1": (
            "$script:HelpersPath = Join-Path $PSScriptRoot 'helpers.ps1'\n"
            ". $script:HelpersPath\n"
            "$configPath = Join-Path $PSScriptRoot '../../config/x.json'\n"
        ),
        ".codex/hooks/helpers.ps1": "Write-Output 'h'\n",
    }

    closure = compute_dot_source_closure([".codex/hooks/a.ps1"], _memory_reader(files))

    assert closure == {".codex/hooks/a.ps1", ".codex/hooks/helpers.ps1"}


def test_closure_follows_parent_scripts_join_path() -> None:
    """The `(Split-Path $PSScriptRoot -Parent)` form resolves one level up (AC-5.3)."""
    files = {
        ".codex/hooks/a.ps1": (
            "$contractPath = Join-Path (Split-Path $PSScriptRoot -Parent) "
            "'scripts/contract.ps1'\n"
            "if ($true) {\n"
            "    . $contractPath\n"
            "}\n"
        ),
        ".codex/scripts/contract.ps1": "Write-Output 'c'\n",
    }

    closure = compute_dot_source_closure([".codex/hooks/a.ps1"], _memory_reader(files))

    assert closure == {".codex/hooks/a.ps1", ".codex/scripts/contract.ps1"}


def test_guard_reports_hook_absent_from_manifest() -> None:
    """A registered hook missing from the manifest is reported (AC-5.3 negative)."""
    config_text = (
        "[[hooks.PreToolUse]]\n"
        'matcher = "^Bash$"\n'
        "[[hooks.PreToolUse.hooks]]\n"
        'type = "command"\n'
        "command = 'pwsh -NoProfile -File \"$(git rev-parse --show-toplevel)"
        "/.codex/hooks/listed.ps1\"'\n"
        "[[hooks.PreToolUse.hooks]]\n"
        'type = "command"\n'
        "command = 'pwsh -NoProfile -File \"$(git rev-parse --show-toplevel)"
        "/.codex/hooks/unlisted.ps1\"'\n"
    )
    files = {
        ".codex/hooks/listed.ps1": "Write-Output 'l'\n",
        ".codex/hooks/unlisted.ps1": "Write-Output 'u'\n",
    }

    missing = find_missing_manifest_paths(
        config_text, [".codex/hooks/listed.ps1"], _memory_reader(files)
    )

    assert missing == [".codex/hooks/unlisted.ps1"]


def test_core_manifest_contains_registered_hook_closure_and_resolver_paths() -> None:
    """`core.json` alone lists every hook, its closure, and the resolvers (AC-5.2)."""
    # Arrange
    config_text = (BUNDLE_ROOT / ".codex" / "config.toml").read_text(encoding="utf-8")
    manifest = json.loads(CORE_MANIFEST.read_text(encoding="utf-8"))
    core_paths = set(manifest["paths"])
    virtual_destinations = {
        destination.as_posix() for destination, _resource in VIRTUAL_RESOURCE_PAIRS
    }

    # Act
    required = compute_dot_source_closure(
        [*registered_hook_paths(config_text), *WRAPPER_PATHS], _bundle_reader
    )
    required.update(MODULE_DESTINATIONS)
    missing = sorted(required - core_paths)
    unresolvable = sorted(
        path
        for path in required
        if not (BUNDLE_ROOT / path).is_file() and path not in virtual_destinations
    )

    # Assert
    assert missing == [], f"core.json is missing: {missing}"
    assert unresolvable == [], f"not in the bundle or virtual: {unresolvable}"
