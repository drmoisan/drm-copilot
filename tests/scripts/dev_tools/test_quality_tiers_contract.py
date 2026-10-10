"""Unit tests for the pure quality-tiers validation core.

Covers manifest parsing and project discovery. Inputs are in-memory YAML strings
and tracked-path lists; no test in this module reads the committed
``quality-tiers.yml`` (the committed-tree tests live in the classification module).
"""

from __future__ import annotations

import pytest

from scripts.dev_tools.quality_tiers_contract import (
    QualityTierEntry,
    QualityTierError,
    discover_projects,
    parse_quality_tiers,
)
from tests.scripts.dev_tools.quality_tiers_contract_test_support import qt_codes

_VALID_ENTRY_TEXT = """\
  - path: "scripts/bash"
    tier: "T4"
    rationale: "Shell QC scripts."
"""

VALID_MANIFEST_TEXT = (
    'version: 1\nprojects:\n  - path: "extensions/drm-copilot"\n    tier: "T3"\n'
    '    rationale: "VS Code extension."\n' + _VALID_ENTRY_TEXT
)


def test_parse_quality_tiers_accepts_valid_manifest() -> None:
    """A well-formed manifest parses into entries with no errors."""
    # Arrange
    text = VALID_MANIFEST_TEXT

    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert errors == [], f"unexpected errors: {errors}"
    assert manifest is not None
    assert manifest.version == 1
    assert manifest.entries == (
        QualityTierEntry(
            path="extensions/drm-copilot", tier="T3", rationale="VS Code extension."
        ),
        QualityTierEntry(path="scripts/bash", tier="T4", rationale="Shell QC scripts."),
    )


def test_parse_quality_tiers_accepts_root_path_entry() -> None:
    """The bare root path ``.`` is accepted as an entry path."""
    # Arrange
    text = 'version: 1\nprojects:\n  - path: "."\n    tier: T4\n    rationale: root\n'

    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert errors == []
    assert manifest is not None
    assert [entry.path for entry in manifest.entries] == ["."]


def test_parse_quality_tiers_rejects_invalid_yaml_with_qt002() -> None:
    """Text that is not valid YAML yields QT002 and no manifest."""
    # Arrange
    text = "version: 1\nprojects: [unclosed\n"

    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert manifest is None
    assert qt_codes(errors) == ["QT002"]


def test_parse_quality_tiers_rejects_duplicate_top_level_key_with_qt002() -> None:
    """A repeated top-level ``projects`` key yields QT002 instead of hiding entries."""
    # Arrange
    text = (
        "version: 1\nprojects:\n"
        + _VALID_ENTRY_TEXT
        + "projects:\n"
        + _VALID_ENTRY_TEXT
    )

    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert manifest is None
    assert qt_codes(errors) == ["QT002"]
    assert "duplicate" in errors[0].message


def test_parse_quality_tiers_rejects_non_mapping_root_with_qt002() -> None:
    """A YAML document whose root is a list yields QT002."""
    # Arrange
    text = "- version\n- projects\n"

    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert manifest is None
    assert qt_codes(errors) == ["QT002"]


def test_parse_quality_tiers_non_scalar_key_reports_qt002() -> None:
    """A mapping key that is not a scalar yields QT002 and no manifest."""
    # Arrange
    text = "? [a, b]\n: 1\nversion: 1\n"

    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert manifest is None
    assert qt_codes(errors) == ["QT002"]


@pytest.mark.parametrize(
    "text",
    [
        pytest.param("projects:\n" + _VALID_ENTRY_TEXT, id="missing-version"),
        pytest.param(
            "version: 2\nprojects:\n" + _VALID_ENTRY_TEXT, id="version-not-one"
        ),
        pytest.param("version: 1\nprojects: []\n", id="projects-empty"),
        pytest.param("version: 1\nprojects: scripts/bash\n", id="projects-not-list"),
        pytest.param(
            "version: 1\nprojects:\n  - scripts/bash\n", id="entry-not-mapping"
        ),
        pytest.param(
            'version: 1\nprojects:\n  - path: "scripts/bash"\n    tier: "T4"\n',
            id="missing-key",
        ),
        pytest.param(
            "version: 1\nprojects:\n" + _VALID_ENTRY_TEXT + '    owner: "someone"\n',
            id="unknown-key",
        ),
        pytest.param(
            'version: 1\nprojects:\n  - path: "scripts/bash"\n    tier: 4\n'
            '    rationale: "Shell QC scripts."\n',
            id="non-string-value",
        ),
        pytest.param(
            'version: 1\nprojects:\n  - path: "scripts/bash"\n    tier: "T4"\n'
            '    rationale: ""\n',
            id="empty-value",
        ),
        pytest.param(
            "version: 1\nextra: true\nprojects:\n" + _VALID_ENTRY_TEXT,
            id="unknown-top-level-key",
        ),
        pytest.param(
            "version: true\nprojects:\n" + _VALID_ENTRY_TEXT, id="version-bool"
        ),
        pytest.param(
            'version: "1"\nprojects:\n' + _VALID_ENTRY_TEXT, id="version-string"
        ),
        pytest.param("version: 1\n", id="missing-projects"),
    ],
)
def test_parse_quality_tiers_rejects_schema_violation_with_qt003(text: str) -> None:
    """Each schema violation yields only QT003 errors and still returns a manifest."""
    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert manifest is not None, "schema violations must not discard the manifest"
    assert errors, "a schema violation must be reported"
    assert set(qt_codes(errors)) == {"QT003"}, f"unexpected codes: {errors}"


def test_parse_quality_tiers_keeps_valid_entries_alongside_qt003() -> None:
    """Valid entries survive when a sibling entry fails an entry-level check."""
    # Arrange
    text = (
        "version: 1\nprojects:\n"
        + _VALID_ENTRY_TEXT
        + '  - path: "scripts/dev_tools"\n    rationale: "Dev tooling."\n'
    )

    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert manifest is not None
    assert qt_codes(errors) == ["QT003"]
    assert [entry.path for entry in manifest.entries] == ["scripts/bash"]


def test_quality_tier_error_renders_code_prefix() -> None:
    """The rendered error starts with the code, a colon, and a space."""
    # Arrange
    error = QualityTierError(code="QT008", message="unclassified project 'x'")

    # Act
    rendered = error.render()

    # Assert
    assert rendered.startswith("QT008: ")
    assert rendered == "QT008: unclassified project 'x'"
    assert error.path is None


def test_discover_projects_root_package_json_yields_root() -> None:
    """A tracked root ``package.json`` makes the repository root a project."""
    # Act
    projects = discover_projects(["package.json", "README.md"])

    # Assert
    assert projects == frozenset({"."})


def test_discover_projects_csproj_directory_is_project() -> None:
    """The directory holding a tracked ``*.csproj`` is a project."""
    # Act
    projects = discover_projects(["tools/Thing/Thing.csproj", "tools/Thing/Program.cs"])

    # Assert
    assert projects == frozenset({"tools/Thing"})


def test_discover_projects_psd1_with_sibling_psm1_is_project() -> None:
    """A ``*.psd1`` with a same-stem sibling ``*.psm1`` marks a module root."""
    # Act
    projects = discover_projects(["modules/Tool/Tool.psd1", "modules/Tool/Tool.psm1"])

    # Assert
    assert projects == frozenset({"modules/Tool"})


def test_discover_projects_ignores_settings_psd1_without_sibling_psm1() -> None:
    """A settings ``*.psd1`` without a sibling module file is not a project."""
    # Act
    projects = discover_projects(
        ["config/PSScriptAnalyzerSettings.psd1", "config/Other.psm1"]
    )

    # Assert
    assert projects == frozenset()


@pytest.mark.parametrize(
    "tracked_path",
    [
        "extensions/drm-copilot/resources/claude-customizations/package.json",
        "tests/fixtures/sample/Sample.csproj",
        "docs/examples/package.json",
        "node_modules/left-pad/package.json",
    ],
)
def test_discover_projects_ignores_excluded_roots(tracked_path: str) -> None:
    """Manifests under the excluded roots never become projects."""
    # Act
    projects = discover_projects([tracked_path])

    # Assert
    assert projects == frozenset(), f"{tracked_path} must be excluded"


def test_discover_projects_ignores_scripts_child_without_direct_code_file() -> None:
    """A ``scripts/<name>`` folder without a direct code file is not a project."""
    # Act
    projects = discover_projects(["scripts/data/readme.md", "scripts/data/nested/x.py"])

    # Assert
    assert projects == frozenset()


def test_discover_projects_discovers_nested_poshqc_and_scripts_powershell() -> None:
    """A module root nested inside a script root is discovered alongside it."""
    # Arrange
    tracked = [
        "scripts/powershell/build.ps1",
        "scripts/powershell/PoshQC/PoshQC.psd1",
        "scripts/powershell/PoshQC/PoshQC.psm1",
    ]

    # Act
    projects = discover_projects(tracked)

    # Assert
    assert projects == frozenset({"scripts/powershell", "scripts/powershell/PoshQC"})


def test_discover_projects_discovers_claude_lib_child() -> None:
    """Each immediate ``.claude/lib/<name>`` folder with a tracked file is a project."""
    # Act
    projects = discover_projects(
        [".claude/lib/blast-radius/BlastRadius.psm1", ".claude/lib/README.md"]
    )

    # Assert
    assert projects == frozenset({".claude/lib/blast-radius"})


@pytest.mark.parametrize("hook_root", [".claude/hooks", ".codex/hooks"])
def test_discover_projects_discovers_hook_roots_only_with_tracked_file(
    hook_root: str,
) -> None:
    """A hook root is a project only when it contains a tracked file."""
    # Act
    with_file = discover_projects([f"{hook_root}/guard.sh"])
    without_file = discover_projects(["other/notes.txt"])

    # Assert
    assert hook_root in with_file
    assert hook_root not in without_file


def test_discover_projects_empty_list_yields_empty_set() -> None:
    """No tracked files yields no projects."""
    # Act
    projects = discover_projects([])

    # Assert
    assert projects == frozenset()
