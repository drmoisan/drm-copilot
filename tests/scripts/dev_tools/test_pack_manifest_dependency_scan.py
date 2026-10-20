"""In-memory self-tests for the pack-manifest dependency scanners (issue #984).

Purpose:
    Prove each `$PSScriptRoot` dependency form, the comment lexer, the
    exhaustiveness guard, the missing-target report, and the hook command
    extraction in `tests/scripts/dev_tools/pack_manifest_dependency_scan.py`
    with in-memory text only, so the real-bundle closure test cannot pass
    because a scanner silently matched nothing. No test reads or writes a file.
"""

from __future__ import annotations

import json

import pytest

from tests.scripts.dev_tools.pack_manifest_dependency_scan import (
    extract_dependency_targets,
    extract_hook_command_paths,
    find_missing_dependencies,
    find_unrecognized_psscriptroot,
    strip_powershell_comments,
)

FORM_CASES = [
    pytest.param(
        ".claude/hooks/gate.ps1",
        "try { . (Join-Path $PSScriptRoot 'gate-helpers.ps1') } catch { }",
        ".claude/hooks/gate-helpers.ps1",
        id="F1",
    ),
    pytest.param(
        ".claude/lib/state/State.psm1",
        "Import-Module (Join-Path -Path $PSScriptRoot "
        "-ChildPath 'StateValue.psm1') -Force",
        ".claude/lib/state/StateValue.psm1",
        id="F2",
    ),
    pytest.param(
        ".claude/hooks/gate.ps1",
        "$modulePath = Join-Path -Path $PSScriptRoot `\n"
        "    -ChildPath '../lib/discovery-validation/DiscoveryValidation.psm1'",
        ".claude/lib/discovery-validation/DiscoveryValidation.psm1",
        id="F3",
    ),
    pytest.param(
        ".claude/lib/orchestrator-state/Receipts.psm1",
        "$path = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '..') "
        "-ChildPath (Join-Path -Path 'codex-routing' "
        "-ChildPath 'CodexDeployment.psm1')",
        ".claude/lib/codex-routing/CodexDeployment.psm1",
        id="F4",
    ),
    pytest.param(
        ".codex/hooks/gate.ps1",
        "$contractPath = Join-Path (Split-Path $PSScriptRoot -Parent) "
        "'scripts/epic-child-launch-contract.ps1'",
        ".codex/scripts/epic-child-launch-contract.ps1",
        id="F5",
    ),
    pytest.param(
        ".claude/hooks/gate.ps1",
        "$script:MermaidModulePath = Join-Path -Path $PSScriptRoot -ChildPath "
        "'../lib/mermaid/MermaidValidation.psm1'\n"
        "Import-Module $script:MermaidModulePath -ErrorAction Stop",
        ".claude/lib/mermaid/MermaidValidation.psm1",
        id="F6",
    ),
    pytest.param(
        ".claude/hooks/enforce-completion-helpers.ps1",
        "$configPath = Join-Path $PSScriptRoot "
        "'../../config/orchestration-routing.json'",
        "config/orchestration-routing.json",
        id="F7",
    ),
]


@pytest.mark.parametrize(("source", "text", "expected"), FORM_CASES)
def test_extracts_target_for_form(source: str, text: str, expected: str) -> None:
    """Each dependency form resolves to its target and is fully recognized."""

    # Act
    targets = extract_dependency_targets(text, source)

    # Assert
    assert targets == [expected]
    assert find_unrecognized_psscriptroot(text) == []


def test_ignores_reference_in_line_comment() -> None:
    """A dependency spelled inside a `#` line comment is not a dependency."""

    text = "# . (Join-Path $PSScriptRoot 'gone.ps1')\n$value = 1\n"

    assert extract_dependency_targets(text, ".claude/hooks/gate.ps1") == []
    assert find_unrecognized_psscriptroot(text) == []


def test_ignores_reference_in_block_comment() -> None:
    """A dependency spelled inside comment-based help is not a dependency."""

    text = (
        "<#\n.NOTES\n    dot-sourced as: . (Join-Path $PSScriptRoot 'gone.ps1')\n#>\n"
    )

    assert extract_dependency_targets(text, ".claude/hooks/gate.ps1") == []
    assert strip_powershell_comments(text) == "\n\n\n\n"


def test_hash_inside_quoted_literal_does_not_start_comment() -> None:
    """A `#` inside a single-, double-, or here-string does not start a comment."""

    text = (
        "$a = 'x#y'; $b = \"p#q\"; . (Join-Path $PSScriptRoot 'kept.ps1')\n"
        "$c = @'\n# not a comment\n'@\n"
        ". (Join-Path $PSScriptRoot 'also-kept.ps1')\n"
    )

    targets = extract_dependency_targets(text, ".claude/hooks/gate.ps1")

    assert targets == [".claude/hooks/also-kept.ps1", ".claude/hooks/kept.ps1"]
    assert "# not a comment" in strip_powershell_comments(text)


def test_named_non_dependency_forms_are_recognized() -> None:
    """Repository-root, parameter-default, base-path, and F8 forms are recognized."""

    text = (
        "$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent\n"
        "param([string]$ScriptRoot = $PSScriptRoot)\n"
        "$canonical = Get-CanonicalPath -Path $root -BasePath $PSScriptRoot\n"
        "$candidates = Get-CodexRoutingModuleCandidate -ScriptRoot $PSScriptRoot "
        "-ModuleName 'CodexTopology.psm1'\n"
    )

    assert find_unrecognized_psscriptroot(text) == []
    assert extract_dependency_targets(text, ".codex/scripts/tool.ps1") == []


def test_unrecognized_psscriptroot_form_fails_exhaustiveness_guard() -> None:
    """An interpolated `$PSScriptRoot` spelling is reported, not silently ignored."""

    text = "$known = Join-Path $PSScriptRoot 'a.ps1'\n. \"$PSScriptRoot/b.ps1\"\n"

    assert find_unrecognized_psscriptroot(text) == ['. "$PSScriptRoot/b.ps1"']


def test_synthetic_manifest_missing_target_is_reported() -> None:
    """A two-file manifest that omits a dot-sourced sibling reports that pair (AC2)."""

    # Arrange: the manifest lists two hooks; gate.ps1 dot-sources an unlisted helper.
    manifest = frozenset({".claude/hooks/gate.ps1", ".claude/hooks/other.ps1"})
    sources = {
        ".claude/hooks/gate.ps1": ". (Join-Path $PSScriptRoot 'gate-helpers.ps1')\n",
        ".claude/hooks/other.ps1": ". (Join-Path $PSScriptRoot 'gate.ps1')\n",
    }

    # Act
    missing = find_missing_dependencies(sources, manifest)

    # Assert
    assert missing == [(".claude/hooks/gate.ps1", ".claude/hooks/gate-helpers.ps1")]
    assert find_missing_dependencies(sources, manifest | {missing[0][1]}) == []


def test_target_escaping_bundle_root_is_rejected() -> None:
    """A target that resolves above the bundle root raises ValueError."""

    text = ". (Join-Path $PSScriptRoot '../../../outside.ps1')"

    with pytest.raises(ValueError, match="outside the bundle root"):
        extract_dependency_targets(text, ".claude/hooks/gate.ps1")


def test_hook_command_paths_from_settings_frontmatter_and_toml() -> None:
    """Hook paths come from settings commands, frontmatter hooks, and TOML commands."""

    settings = json.dumps(
        {
            "permissions": {"allow": ["Read(.claude/hooks/ignored.ps1)"]},
            "hooks": {
                "PreToolUse": [
                    {"hooks": [{"command": "pwsh -File .claude/hooks/a-gate.ps1"}]}
                ]
            },
        }
    )
    frontmatter = (
        "---\nname: sample\nhooks:\n  SubagentStop:\n    - hooks:\n"
        "        - command: pwsh -NoProfile -File .claude/hooks/b-stop.ps1\n"
        "model: sonnet\n---\n\nBody text names .claude/hooks/body-only.ps1\n"
    )
    toml = (
        "[[hooks.PreToolUse.hooks]]\n"
        "command = 'pwsh -File "
        '"$(git rev-parse --show-toplevel)/.codex/hooks/c.ps1"\'\n'
        "command_windows = 'pwsh -File .codex/hooks/d.ps1'\n"
        "description = '.codex/hooks/not-a-command.ps1'\n"
    )

    assert extract_hook_command_paths(settings, "settings") == [
        ".claude/hooks/a-gate.ps1"
    ]
    assert extract_hook_command_paths(frontmatter, "frontmatter") == [
        ".claude/hooks/b-stop.ps1"
    ]
    assert extract_hook_command_paths(toml, "toml") == [
        ".codex/hooks/c.ps1",
        ".codex/hooks/d.ps1",
    ]
