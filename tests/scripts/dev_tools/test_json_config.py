from __future__ import annotations

import ast
import json
import re
from pathlib import Path, PurePosixPath  # noqa: TCH003 - required for pytest fixtures
from typing import cast

import pytest

from scripts.dev_tools import json_config as json_config_module
from scripts.dev_tools.json_config import (
    DEFAULT_DEVELOPMENT_DOCS_ROOT,
    DEVELOPMENT_DOCS_ROOT_KEY,
    EXCLUDE_GLOBS,
    GOVERNED_GLOBS,
    KNOWN_DEVELOPMENT_DOCS_ROOTS,
    FeatureFolderName,
    development_docs_path,
    development_docs_relative_path,
    format_feature_folder_name,
    iter_governed_files,
    known_root_prefixes,
    parse_feature_folder_name,
    resolve_development_docs_root,
    strip_date_first_prefix,
)


def test_governed_globs_constant() -> None:
    """Verify GOVERNED_GLOBS constant is defined."""
    assert isinstance(GOVERNED_GLOBS, tuple)
    assert len(GOVERNED_GLOBS) > 0
    # .vscode and .devcontainer contain JSONC (not pure JSON) and are excluded
    assert "scripts/**/*.json" in GOVERNED_GLOBS


def test_exclude_globs_constant() -> None:
    """Verify EXCLUDE_GLOBS constant is defined."""
    assert isinstance(EXCLUDE_GLOBS, tuple)
    assert len(EXCLUDE_GLOBS) > 0
    assert "data/**" in EXCLUDE_GLOBS


def test_iter_governed_files_empty(mem_fs_path: Path) -> None:
    """No JSON files should yield nothing."""
    result = list(iter_governed_files(mem_fs_path))
    assert result == []


def test_iter_governed_files_excludes_vscode_json(mem_fs_path: Path) -> None:
    """Files in .vscode/*.json should NOT be found (JSONC, not pure JSON)."""
    vscode_dir = mem_fs_path / ".vscode"
    vscode_dir.mkdir()
    tasks_json = vscode_dir / "tasks.json"
    tasks_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert tasks_json not in result


def test_iter_governed_files_excludes_nested_vscode_json(mem_fs_path: Path) -> None:
    """Files matching .vscode/**/*.json should NOT be found (JSONC)."""
    nested_dir = mem_fs_path / ".vscode" / "subdir"
    nested_dir.mkdir(parents=True)
    nested_json = nested_dir / "config.json"
    nested_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert nested_json not in result


def test_iter_governed_files_excludes_data_dir(mem_fs_path: Path) -> None:
    """Files under data/** should be excluded."""
    data_dir = mem_fs_path / "data"
    data_dir.mkdir()
    data_json = data_dir / "metadata.json"
    data_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert data_json not in result


def test_iter_governed_files_excludes_artifacts_dir(mem_fs_path: Path) -> None:
    """Files under artifacts/** should be excluded."""
    artifacts_dir = mem_fs_path / "artifacts"
    artifacts_dir.mkdir()
    artifact_json = artifacts_dir / "output.json"
    artifact_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert artifact_json not in result


def test_iter_governed_files_excludes_parent_in_excluded(mem_fs_path: Path) -> None:
    """Files with any parent in exclusion set should be excluded."""
    htmlcov_dir = mem_fs_path / "htmlcov" / "subdir"
    htmlcov_dir.mkdir(parents=True)
    report_json = htmlcov_dir / "report.json"
    report_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert report_json not in result


def test_iter_governed_files_excludes_devcontainer_json(mem_fs_path: Path) -> None:
    """Files in .devcontainer/*.json should NOT be found (JSONC)."""
    devcontainer_dir = mem_fs_path / ".devcontainer"
    devcontainer_dir.mkdir()
    devcontainer_json = devcontainer_dir / "devcontainer.json"
    devcontainer_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert devcontainer_json not in result


def test_iter_governed_files_finds_scripts_json(mem_fs_path: Path) -> None:
    """Files matching scripts/**/*.json should be found."""
    scripts_dir = mem_fs_path / "scripts" / "subdir"
    scripts_dir.mkdir(parents=True)
    script_json = scripts_dir / "config.json"
    script_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert script_json in result


def test_iter_governed_files_finds_docs_json(mem_fs_path: Path) -> None:
    """Files matching docs/**/*.json should be found."""
    docs_dir = mem_fs_path / "docs" / "discovery"
    docs_dir.mkdir(parents=True)
    doc_json = docs_dir / "manifest.json"
    doc_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert doc_json in result


def test_iter_governed_files_finds_examples_json(mem_fs_path: Path) -> None:
    """Files matching examples/**/*.json should be found."""
    examples_dir = mem_fs_path / "examples" / "meta"
    examples_dir.mkdir(parents=True)
    example_json = examples_dir / "sample.json"
    example_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert example_json in result


def test_iter_governed_files_accepts_str_path(mem_fs_path: Path) -> None:
    """iter_governed_files should accept str paths."""
    scripts_dir = mem_fs_path / "scripts"
    scripts_dir.mkdir()
    script_json = scripts_dir / "config.json"
    script_json.write_text("{}")

    result = list(iter_governed_files(str(mem_fs_path)))
    assert script_json in result


def test_iter_governed_files_mixed_included_excluded(mem_fs_path: Path) -> None:
    """Mix of included and excluded files should only yield included ones."""
    scripts_dir = mem_fs_path / "scripts"
    scripts_dir.mkdir()
    included_json = scripts_dir / "config.json"
    included_json.write_text("{}")

    data_dir = mem_fs_path / "data"
    data_dir.mkdir()
    excluded_json = data_dir / "corpus.json"
    excluded_json.write_text("{}")

    result = list(iter_governed_files(mem_fs_path))
    assert included_json in result
    assert excluded_json not in result


def test_iter_governed_files_handles_non_file_matches(mem_fs_path: Path) -> None:
    """glob matches that are directories should be skipped."""
    scripts_dir = mem_fs_path / "scripts"
    scripts_dir.mkdir()
    # Create a directory with .json suffix (unusual but possible)
    json_dir = scripts_dir / "weird.json"
    json_dir.mkdir()

    result = list(iter_governed_files(mem_fs_path))
    assert json_dir not in result


def test_iter_governed_files_excludes_feature_records(mem_fs_path: Path) -> None:
    """Finalized feature records are excluded at any depth; other docs JSON is not.

    Scenario: evidence JSON sits in a nested evidence folder of an active
    feature, a ruleset snapshot sits outside any evidence folder of an archived
    feature, and a template sits elsewhere under docs. Expected outcome: neither
    feature record is yielded, the template is.
    """
    # Arrange
    evidence_dir = (
        mem_fs_path / "docs" / "features" / "active" / "f-1" / "evidence" / "qa-gates"
    )
    evidence_dir.mkdir(parents=True)
    evidence_json = evidence_dir / "coverage.json"
    evidence_json.write_text("{}")
    ruleset_dir = mem_fs_path / "docs" / "features" / "archive" / "f-2" / "ruleset"
    ruleset_dir.mkdir(parents=True)
    ruleset_json = ruleset_dir / "protect-main.json"
    ruleset_json.write_text("{}")
    template_dir = mem_fs_path / "docs" / "discovery" / "templates"
    template_dir.mkdir(parents=True)
    template_json = template_dir / "ledger.json"
    template_json.write_text("{}")

    # Act
    result = list(iter_governed_files(mem_fs_path))

    # Assert
    assert evidence_json not in result
    assert ruleset_json not in result
    assert template_json in result


# ---------------------------------------------------------------------------
# Development-docs root resolver (issue #1035): rules R-1 to R-8.
# ---------------------------------------------------------------------------

_WORKSPACE = PurePosixPath("/ws")
_CONFIG = "/ws/config/orchestration-routing.json"


class _FakeLayout:
    """In-memory reader and directory probe for the resolver.

    Purpose:
        Stand in for the file system so no test reads the real routing file
        or probes for ``.dev``.

    Attributes:
        files: Readable files keyed by POSIX path.
        directories: Existing directories keyed by POSIX path.
        unreadable: Paths whose read raises ``PermissionError``.
        probes: Every directory probed, in call order.
    """

    def __init__(
        self,
        files: dict[str, str] | None = None,
        directories: set[str] | None = None,
        unreadable: set[str] | None = None,
    ) -> None:
        """Store the in-memory layout.

        Args:
            files: Readable files keyed by POSIX path.
            directories: Existing directories keyed by POSIX path.
            unreadable: Paths whose read raises.
        """
        self.files = files or {}
        self.directories = directories or set()
        self.unreadable = unreadable or set()
        self.probes: list[str] = []

    def read_text(self, path: Path) -> str:
        """Return the stored text, or raise as an absent or unreadable file.

        Args:
            path: Path to read.

        Returns:
            The stored text.

        Raises:
            PermissionError: For an unreadable path.
            FileNotFoundError: For an absent path.
        """
        key = path.as_posix()
        if key in self.unreadable:
            raise PermissionError(key)
        if key not in self.files:
            raise FileNotFoundError(key)
        return self.files[key]

    def is_dir(self, path: Path) -> bool:
        """Record the probe and report whether the directory exists.

        Args:
            path: Directory to probe.

        Returns:
            True when the path is a stored directory.
        """
        key = path.as_posix()
        self.probes.append(key)
        return key in self.directories


def _routing_with(value: object) -> str:
    """Return routing JSON text carrying the key with the given value."""
    return json.dumps({"version": 1, DEVELOPMENT_DOCS_ROOT_KEY: value})


def _resolve(layout: _FakeLayout) -> str:
    """Resolve the root of the synthetic workspace through the fake layout."""
    return resolve_development_docs_root(
        cast("Path", _WORKSPACE), read_text=layout.read_text, is_dir=layout.is_dir
    )


def test_r1_resolves_docs_features_when_routing_file_absent() -> None:
    """R-1: an absent routing file resolves the default root without a probe."""
    layout = _FakeLayout()
    assert _resolve(layout) == "docs/features"
    assert layout.probes == []


def test_r1_resolves_docs_features_when_routing_file_unreadable() -> None:
    """R-1: an unreadable routing file resolves the default root."""
    layout = _FakeLayout(unreadable={_CONFIG})
    assert _resolve(layout) == "docs/features"


def test_r2_resolves_docs_features_when_key_absent_without_probe() -> None:
    """R-2: a missing key resolves the default root and never probes .dev (OQ-1)."""
    layout = _FakeLayout({_CONFIG: '{"version": 1}'}, {"/ws/.dev"})
    assert _resolve(layout) == "docs/features"
    assert layout.probes == []


def test_r3_malformed_json_names_file_key_and_value() -> None:
    """R-3: malformed JSON raises an error naming the file, key, and value."""
    layout = _FakeLayout({_CONFIG: "{ not json"})
    with pytest.raises(
        ValueError,
        match=re.escape(
            "config/orchestration-routing.json is not valid JSON, so "
            "development_docs_root cannot be read (value: unparseable;"
        ),
    ):
        _resolve(layout)


def test_r3_non_object_document_names_file_key_and_value() -> None:
    """R-3: a non-object document raises an error naming the value."""
    layout = _FakeLayout({_CONFIG: "[1]"})
    with pytest.raises(ValueError) as caught:
        _resolve(layout)
    assert str(caught.value) == (
        "config/orchestration-routing.json is not a JSON object, so "
        "development_docs_root "
        "cannot be read (value: [1])."
    )


@pytest.mark.parametrize(
    ("label", "value", "rendered"),
    [
        ("other string", "docs/other", '"docs/other"'),
        ("blank", "  ", '"  "'),
        ("non-string", 7, "7"),
        ("backslash", "docs\\features", '"docs\\\\features"'),
        ("leading slash", "/docs/features", '"/docs/features"'),
        ("dot-dot segment", "../.dev", '"../.dev"'),
        ("null", None, "null"),
    ],
)
def test_r4_out_of_set_value_names_file_key_and_value(
    label: str, value: object, rendered: str
) -> None:
    """R-4: an out-of-set value raises an error naming file, key, and value."""
    layout = _FakeLayout({_CONFIG: _routing_with(value)})
    with pytest.raises(ValueError) as caught:
        _resolve(layout)
    assert str(caught.value) == (
        f"config/orchestration-routing.json development_docs_root value {rendered} "
        "is not one of: docs/features, .dev."
    ), label


def test_r5_value_docs_features_resolves_docs_features_even_with_dev() -> None:
    """R-5: value docs/features resolves docs/features whether or not .dev exists."""
    layout = _FakeLayout({_CONFIG: _routing_with("docs/features")}, {"/ws/.dev"})
    assert _resolve(layout) == "docs/features"
    assert layout.probes == []


def test_r6_value_dev_resolves_dev_when_dev_exists() -> None:
    """R-6: value .dev resolves .dev when the .dev directory exists."""
    layout = _FakeLayout({_CONFIG: _routing_with(".dev")}, {"/ws/.dev"})
    assert _resolve(layout) == ".dev"


def test_r7_value_dev_falls_back_when_only_docs_features_exists() -> None:
    """R-7: value .dev falls back to docs/features when only docs/features exists."""
    layout = _FakeLayout({_CONFIG: _routing_with(".dev")}, {"/ws/docs/features"})
    assert _resolve(layout) == "docs/features"


def test_r8_value_dev_resolves_dev_when_neither_exists() -> None:
    """R-8: value .dev resolves .dev when neither directory exists."""
    layout = _FakeLayout({_CONFIG: _routing_with(".dev")})
    assert _resolve(layout) == ".dev"
    assert layout.probes == ["/ws/.dev", "/ws/docs/features"]


def test_resolver_defaults_read_the_real_path_api(mem_fs_path: Path) -> None:
    """The default reader and probe use the Path API (in-memory fixture)."""
    (mem_fs_path / "config").mkdir(parents=True, exist_ok=True)
    (mem_fs_path / "config" / "orchestration-routing.json").write_text(
        _routing_with(".dev"), encoding="utf-8"
    )
    (mem_fs_path / ".dev").mkdir(parents=True, exist_ok=True)
    assert resolve_development_docs_root(mem_fs_path) == ".dev"
    assert (
        development_docs_path(mem_fs_path, "active") == mem_fs_path / ".dev" / "active"
    )


def test_known_roots_constants() -> None:
    """The closed set lists the default root first."""
    assert KNOWN_DEVELOPMENT_DOCS_ROOTS == ("docs/features", ".dev")
    assert DEFAULT_DEVELOPMENT_DOCS_ROOT == "docs/features"
    assert DEVELOPMENT_DOCS_ROOT_KEY == "development_docs_root"


_AREA_TABLE = [
    ("active", "docs/features/active", ".dev/active"),
    ("completed", "docs/features/completed", ".dev/completed"),
    ("archive", "docs/features/archive", ".dev/archive"),
    ("potential", "docs/features/potential", ".dev/potential"),
    (
        "potential/promoted",
        "docs/features/potential/promoted",
        ".dev/potential/promoted",
    ),
    ("epics", "docs/features/epics", ".dev/epics"),
    ("parallel", "docs/features/parallel", ".dev/parallel"),
    ("templates", "docs/features/templates", ".dev/templates"),
    ("backlog", "docs/features/backlog.md", ".dev/backlog.md"),
    ("research", "docs/research", ".dev/research"),
    ("discovery-templates", "docs/discovery/templates", ".dev/discovery/templates"),
    ("engineering", "docs/engineering", ".dev/engineering"),
]


@pytest.mark.parametrize(("area", "docs_form", "dev_form"), _AREA_TABLE)
def test_development_docs_path_maps_area_under_both_roots(
    area: str, docs_form: str, dev_form: str
) -> None:
    """Each area maps onto both roots per the area map."""
    workspace = Path("ws")
    assert (
        development_docs_path(workspace, area, root="docs/features")
        == workspace / docs_form
    )
    assert development_docs_path(workspace, area, root=".dev") == workspace / dev_form
    assert development_docs_relative_path(".dev", area) == dev_form


@pytest.mark.parametrize(("area", "docs_form", "dev_form"), _AREA_TABLE)
def test_known_root_prefixes_lists_both_roots(
    area: str, docs_form: str, dev_form: str
) -> None:
    """Prefixes carry both root forms; directory areas end with a slash."""
    suffix = "" if area == "backlog" else "/"
    assert known_root_prefixes(area) == (f"{docs_form}{suffix}", f"{dev_form}{suffix}")


def test_unknown_area_raises_explicit_error() -> None:
    """An unknown area name is an explicit error."""
    with pytest.raises(ValueError, match="Unknown development docs area: nope"):
        known_root_prefixes("nope")
    with pytest.raises(ValueError, match="Unknown development docs area: nope"):
        development_docs_path(Path("ws"), "nope", root=".dev")


def test_unknown_root_raises_explicit_error() -> None:
    """An unknown root is an explicit error."""
    with pytest.raises(ValueError, match="Unknown development docs root: docs"):
        development_docs_relative_path("docs", "active")


def test_json_config_imports_no_dev_tools_module() -> None:
    """json_config.py imports nothing from scripts.dev_tools (AST check)."""
    source = Path(json_config_module.__file__).read_text(encoding="utf-8")
    tree = ast.parse(source)
    offenders: list[str] = []
    # Collect every import of a repository package, in either import form.
    for node in ast.walk(tree):
        if (
            isinstance(node, ast.ImportFrom)
            and node.module
            and node.module.startswith("scripts")
        ):
            offenders.append(node.module)
        if isinstance(node, ast.Import):
            offenders.extend(a.name for a in node.names if a.name.startswith("scripts"))
    assert offenders == []


# ---------------------------------------------------------------------------
# Feature-folder name rules (issue #1035): F-1 to F-6, N-1 to N-5.
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("case_id", "name", "expected"),
    [
        (
            "F-1",
            "2026-10-30-foo-bar-1016",
            FeatureFolderName("date-first", "foo-bar", 1016, "2026-10-30"),
        ),
        (
            "F-2",
            "2026-10-30-foo-bar",
            FeatureFolderName("date-first", "foo-bar", None, "2026-10-30"),
        ),
        ("F-3", "1016-foo-bar", FeatureFolderName("issue-first", "foo-bar", 1016)),
        ("F-4", "0042-foo-bar", FeatureFolderName("issue-first", "foo-bar", 42)),
        (
            "F-5",
            "subagentstop-envelope-core-897",
            FeatureFolderName("other", "subagentstop-envelope-core", 897),
        ),
        ("F-6", "notes-feature", FeatureFolderName("other", "notes-feature", None)),
        ("zero issue", "0000-foo", FeatureFolderName("other", "0000-foo", None)),
    ],
)
def test_parse_feature_folder_name(
    case_id: str, name: str, expected: FeatureFolderName
) -> None:
    """F-1 to F-6: each folder-name shape parses as specified."""
    assert parse_feature_folder_name(name) == expected, case_id


@pytest.mark.parametrize(
    ("case_id", "issue", "feature", "expected"),
    [
        ("N-1", 1016, "move-development-docs", "1016-move-development-docs"),
        ("N-2", 42, "notes", "0042-notes"),
        ("trailing issue", 1016, "2026-10-30-foo-1016", "1016-foo"),
        ("other number", 5, "foo-12", "0005-foo-12"),
    ],
)
def test_format_feature_folder_name(
    case_id: str, issue: int, feature: str, expected: str
) -> None:
    """N-1, N-2: the formatter pads to four digits and strips date and issue."""
    assert format_feature_folder_name(issue, feature) == expected, case_id


@pytest.mark.parametrize("issue", [0, -3, 4.5, True])
def test_n3_rejects_invalid_issue_number(issue: object) -> None:
    """N-3: zero, negative, and non-integer issue numbers are rejected."""
    with pytest.raises(ValueError, match="must be a positive integer"):
        format_feature_folder_name(cast("int", issue), "notes")


def test_n4_rejects_issue_above_9999() -> None:
    """N-4: an issue above 9999 is rejected."""
    with pytest.raises(ValueError, match="must be at most 9999"):
        format_feature_folder_name(10000, "notes")


@pytest.mark.parametrize("feature", ["", "Bad Name", "10-30-foo", "2026-10-30-"])
def test_n5_rejects_invalid_feature(feature: str) -> None:
    """N-5: empty, pattern-failing, and partial-date features are rejected."""
    with pytest.raises(ValueError, match="Feature folder feature name is invalid"):
        format_feature_folder_name(7, feature)


def test_strip_date_first_prefix() -> None:
    """A leading date is removed; other stems are unchanged."""
    assert strip_date_first_prefix("2026-10-30-foo") == "foo"
    assert strip_date_first_prefix("foo-2026-10-30") == "foo-2026-10-30"
