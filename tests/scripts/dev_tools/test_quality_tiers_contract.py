"""Unit tests for the pure quality-tiers validation core.

Inputs are in-memory YAML strings, manifests, and tracked-path lists. Only the two
committed-tree tests read the committed ``quality-tiers.yml``, read-only.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools.quality_tiers_contract import (
    QualityTierEntry,
    QualityTierError,
    QualityTierManifest,
    discover_projects,
    find_classification_errors,
    find_entry_errors,
    parse_quality_tiers,
)

REPO_ROOT = Path(__file__).resolve().parents[3]

_VALID_ENTRY_TEXT = """\
  - path: "scripts/bash"
    tier: "T4"
    rationale: "Shell QC scripts."
"""

VALID_MANIFEST_TEXT = (
    'version: 1\nprojects:\n  - path: "extensions/drm-copilot"\n    tier: "T3"\n'
    '    rationale: "VS Code extension."\n' + _VALID_ENTRY_TEXT
)


def _codes(errors: list[QualityTierError]) -> list[str]:
    """Return the QT codes of ``errors`` in their reported order."""
    return [error.code for error in errors]


def _manifest(*entries: tuple[str, str]) -> QualityTierManifest:
    """Build an in-memory manifest from ``(path, tier)`` pairs."""
    items = tuple(QualityTierEntry(path, tier, "rationale") for path, tier in entries)
    return QualityTierManifest(version=1, entries=items)


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
    assert _codes(errors) == ["QT002"]


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
    assert _codes(errors) == ["QT002"]
    assert "duplicate" in errors[0].message


def test_parse_quality_tiers_rejects_non_mapping_root_with_qt002() -> None:
    """A YAML document whose root is a list yields QT002."""
    # Arrange
    text = "- version\n- projects\n"

    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert manifest is None
    assert _codes(errors) == ["QT002"]


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
    ],
)
def test_parse_quality_tiers_rejects_schema_violation_with_qt003(text: str) -> None:
    """Each schema violation yields only QT003 errors and still returns a manifest."""
    # Act
    manifest, errors = parse_quality_tiers(text)

    # Assert
    assert manifest is not None, "schema violations must not discard the manifest"
    assert errors, "a schema violation must be reported"
    assert set(_codes(errors)) == {"QT003"}, f"unexpected codes: {errors}"


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
    assert _codes(errors) == ["QT003"]
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


SPEC_TIER_ASSIGNMENTS: tuple[tuple[str, str], ...] = (
    (".", "T4"),
    ("extensions/drm-copilot", "T3"),
    ("packages/mcp-server", "T4"),
    ("scripts/powershell/PoshQC", "T3"),
    ("scripts/dev_tools", "T4"),
    ("scripts/dev-tools", "T4"),
    ("scripts/bash", "T4"),
    ("scripts/powershell", "T4"),
    (".claude/hooks", "T3"),
    (".codex/hooks", "T3"),
    (".claude/lib/bash", "T3"),
    (".claude/lib/blast-radius", "T3"),
    (".claude/lib/ci-gate", "T3"),
    (".claude/lib/cleanup-manifest", "T3"),
    (".claude/lib/codex-routing", "T3"),
    (".claude/lib/discovery-validation", "T3"),
    (".claude/lib/hook-payload", "T3"),
    (".claude/lib/mermaid", "T3"),
    (".claude/lib/model-routing", "T3"),
    (".claude/lib/orchestrator-state", "T3"),
    (".claude/lib/parallel-drift", "T3"),
    (".claude/lib/project-file-merge", "T3"),
    (".claude/lib/requirements", "T3"),
    (".claude/lib/worktree-resolution", "T3"),
)
"""The 24 rows of the spec "Tier assignments" table, in table order."""


def test_find_classification_errors_valid_manifest_returns_no_errors() -> None:
    """A manifest matching the discovered set reports no errors."""
    # Arrange
    manifest = _manifest((".", "T4"), ("scripts/bash", "T4"))

    # Act
    errors = find_classification_errors(manifest, frozenset({".", "scripts/bash"}))

    # Assert
    assert errors == []


@pytest.mark.parametrize("tier", ["T5", "t3"])
def test_find_entry_errors_reports_qt004_for_invalid_tier(tier: str) -> None:
    """A tier outside T1-T4 (case-sensitive) yields QT004."""
    # Act
    errors = find_entry_errors(_manifest(("scripts/bash", tier)))

    # Assert
    assert _codes(errors) == ["QT004"]
    assert errors[0].path == "scripts/bash"


def test_find_entry_errors_reports_qt005_for_duplicate_path() -> None:
    """Two entries with the same path yield QT005."""
    # Act
    errors = find_entry_errors(
        _manifest(("scripts/bash", "T4"), ("scripts/bash", "T3"))
    )

    # Assert
    assert _codes(errors) == ["QT005"]
    assert "scripts/bash" in errors[0].message


@pytest.mark.parametrize(
    "path",
    [
        pytest.param("/scripts/bash", id="absolute"),
        pytest.param("C:/repo/scripts", id="drive-letter"),
        pytest.param("scripts\\bash", id="backslash"),
        pytest.param("scripts/bash/", id="trailing-slash"),
        pytest.param("scripts/../bash", id="dotdot-segment"),
        pytest.param("./scripts/bash", id="leading-dot-segment"),
    ],
)
def test_find_entry_errors_reports_qt006_for_malformed_path(path: str) -> None:
    """A path that is not repository-relative POSIX yields QT006."""
    # Act
    errors = find_entry_errors(_manifest((path, "T4")))

    # Assert
    assert _codes(errors) == ["QT006"]
    assert errors[0].path == path


def test_find_classification_errors_reports_qt007_for_undiscovered_entry() -> None:
    """An entry whose path is not a discovered project yields QT007."""
    # Arrange
    manifest = _manifest(("scripts/bash", "T4"), ("scripts/gone", "T4"))

    # Act
    errors = find_classification_errors(manifest, frozenset({"scripts/bash"}))

    # Assert
    assert _codes(errors) == ["QT007"]
    assert errors[0].path == "scripts/gone"


def test_find_classification_errors_reports_qt008_for_unclassified_project() -> None:
    """A discovered project without an entry yields QT008 naming the path."""
    # Arrange
    manifest = _manifest(("scripts/bash", "T4"))

    # Act
    errors = find_classification_errors(
        manifest, frozenset({"scripts/bash", "scripts/new"})
    )

    # Assert
    assert _codes(errors) == ["QT008"]
    assert "scripts/new" in errors[0].render()


def test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry():
    """An empty discovered set never passes silently: every entry yields QT007."""
    # Arrange
    manifest = _manifest(("scripts/bash", "T4"), (".", "T4"))

    # Act
    errors = find_classification_errors(manifest, frozenset())

    # Assert
    assert _codes(errors) == ["QT007", "QT007"]


def test_find_classification_errors_accumulates_qt004_and_qt008() -> None:
    """An invalid tier and an unclassified project are both reported in one call."""
    # Arrange
    manifest = _manifest(("scripts/bash", "T5"))

    # Act
    errors = find_classification_errors(
        manifest, frozenset({"scripts/bash", "scripts/new"})
    )

    # Assert
    assert sorted(_codes(errors)) == ["QT004", "QT008"]


def test_committed_quality_tiers_yml_matches_live_tree() -> None:
    """The committed manifest parses cleanly and every entry is an existing folder."""
    # Arrange
    text = (REPO_ROOT / "quality-tiers.yml").read_text(encoding="utf-8")

    # Act
    manifest, parse_errors = parse_quality_tiers(text)

    # Assert
    assert parse_errors == [], f"parse errors: {parse_errors}"
    assert manifest is not None
    assert find_entry_errors(manifest) == []
    missing = [
        entry.path
        for entry in manifest.entries
        if not (REPO_ROOT / entry.path).is_dir()
    ]
    assert missing == [], f"entries without a folder: {missing}"


def test_committed_quality_tiers_yml_assigns_spec_tiers() -> None:
    """Every spec tier-table row is present with its tier, and no entry is T1 or T2."""
    # Arrange
    text = (REPO_ROOT / "quality-tiers.yml").read_text(encoding="utf-8")

    # Act
    manifest, _ = parse_quality_tiers(text)

    # Assert
    assert manifest is not None
    assigned = {entry.path: entry.tier for entry in manifest.entries}
    assert len(SPEC_TIER_ASSIGNMENTS) == 24
    for path, tier in SPEC_TIER_ASSIGNMENTS:
        assert assigned.get(path) == tier, f"{path}: expected {tier}"
    elevated = sorted(path for path, tier in assigned.items() if tier in {"T1", "T2"})
    assert elevated == [], f"unexpected T1/T2 entries: {elevated}"
