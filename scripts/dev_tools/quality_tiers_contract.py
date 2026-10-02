"""Pure validation core for the root ``quality-tiers.yml`` classification file.

Purpose:
    Parse the tier-classification manifest, discover the repository's projects
    from a supplied list of tracked paths, and report every classification
    error. The module performs no file, process, network, or console I/O; the
    CLI in ``scripts.dev_tools.check_quality_tiers`` owns those boundaries.

Failure codes produced here:
    QT002 invalid YAML, duplicate mapping key, or a root that is not a mapping.
    QT003 schema violation.
    QT004 tier outside T1-T4.
    QT005 duplicate entry path.
    QT006 malformed entry path.
    QT007 entry path that is not a discovered project.
    QT008 discovered project without an entry.

Discovery rules (applied after the excluded roots are removed):
    R1 the folder of every ``package.json`` or ``*.csproj``.
    R2 the folder of every ``*.psd1`` with a same-stem sibling ``*.psm1``.
    R3 every ``scripts/<name>`` folder directly holding a code file.
    R4 every ``.claude/lib/<name>`` folder holding any file.
    R5 ``.claude/hooks`` and ``.codex/hooks`` when they hold any file.
"""

from __future__ import annotations

import posixpath
import re
from dataclasses import dataclass
from typing import TYPE_CHECKING, Any, cast

import yaml

if TYPE_CHECKING:
    from collections.abc import Hashable, Iterable

SCHEMA_VERSION = 1
VALID_TIERS: frozenset[str] = frozenset({"T1", "T2", "T3", "T4"})
TOP_LEVEL_KEYS: tuple[str, ...] = ("version", "projects")
ENTRY_KEYS: tuple[str, ...] = ("path", "tier", "rationale")
ROOT_PATH = "."

_DRIVE_LETTER = re.compile(r"^[A-Za-z]:")


@dataclass(frozen=True)
class DiscoveryRules:
    """Roots, file markers, and exclusions used by project discovery."""

    excluded_prefixes: tuple[str, ...]
    excluded_segment: str
    manifest_file_name: str
    project_file_suffix: str
    module_manifest_suffix: str
    module_script_suffix: str
    script_root: str
    script_suffixes: tuple[str, ...]
    library_root: str
    hook_roots: tuple[str, ...]


DISCOVERY_RULES = DiscoveryRules(
    excluded_prefixes=(
        "tests/",
        "docs/",
        "extensions/drm-copilot/resources/",
        "node_modules/",
    ),
    excluded_segment="node_modules",
    manifest_file_name="package.json",
    project_file_suffix=".csproj",
    module_manifest_suffix=".psd1",
    module_script_suffix=".psm1",
    script_root="scripts",
    script_suffixes=(".py", ".ps1", ".psm1", ".sh"),
    library_root=".claude/lib",
    hook_roots=(".claude/hooks", ".codex/hooks"),
)
"""The single constant holding every discovery root and exclusion."""


@dataclass(frozen=True)
class QualityTierEntry:
    """One project classification: repository-relative path, tier, rationale."""

    path: str
    tier: str
    rationale: str


@dataclass(frozen=True)
class QualityTierManifest:
    """The parsed manifest: schema version and the entries that passed checks."""

    version: int
    entries: tuple[QualityTierEntry, ...]


@dataclass(frozen=True)
class QualityTierError:
    """A classification error identified by a ``QTnnn`` code."""

    code: str
    message: str
    path: str | None = None

    def render(self) -> str:
        """Return the error as ``<code>: <message>`` for line-oriented output."""
        return f"{self.code}: {self.message}"


class _UniqueKeySafeLoader(yaml.SafeLoader):
    """A ``yaml.SafeLoader`` that rejects a repeated key within one mapping."""

    # ``Any`` matches the PyYAML stub signature of the overridden method.
    def construct_mapping(
        self, node: yaml.MappingNode, deep: bool = False
    ) -> dict[Hashable, Any]:
        """Raise ``ConstructorError`` on a duplicate scalar key, then construct."""
        seen: set[tuple[str, str]] = set()
        for key_node, _value_node in node.value:
            if not isinstance(key_node, yaml.ScalarNode):
                continue
            identity = (str(key_node.tag), str(key_node.value))
            if identity in seen:
                raise yaml.constructor.ConstructorError(
                    "while constructing a mapping",
                    node.start_mark,
                    f"found duplicate key '{key_node.value}'",
                    key_node.start_mark,
                )
            seen.add(identity)
        return super().construct_mapping(node, deep=deep)


def _load_yaml(text: str) -> object:
    """Load one YAML document from ``text`` with the duplicate-key loader."""
    return _UniqueKeySafeLoader(text).get_single_data()


def _qt003(message: str, path: str | None = None) -> QualityTierError:
    """Build a QT003 schema error."""
    return QualityTierError(code="QT003", message=message, path=path)


def _check_version(
    document: dict[object, object],
) -> tuple[int, list[QualityTierError]]:
    """Return the schema version (0 when invalid) and any QT003 errors."""
    if "version" not in document:
        return 0, [_qt003("missing required top-level key 'version'")]
    version = document["version"]
    if type(version) is not int:
        return 0, [_qt003(f"'version' must be the integer {SCHEMA_VERSION}")]
    if version != SCHEMA_VERSION:
        return version, [
            _qt003(f"unsupported version {version}; expected {SCHEMA_VERSION}")
        ]
    return version, []


def _parse_entry(
    index: int, raw: object
) -> tuple[QualityTierEntry | None, list[QualityTierError]]:
    """Validate one ``projects`` item; return the entry or its QT003 errors."""
    label = f"projects[{index}]"
    if not isinstance(raw, dict):
        return None, [_qt003(f"{label} is not a mapping")]
    item = cast("dict[object, object]", raw)
    errors: list[QualityTierError] = []
    unknown = sorted(str(key) for key in item if key not in ENTRY_KEYS)
    errors.extend(_qt003(f"{label} has unknown key '{key}'") for key in unknown)
    values: dict[str, str] = {}
    for key in ENTRY_KEYS:
        if key not in item:
            errors.append(_qt003(f"{label} is missing required key '{key}'"))
            continue
        value = item[key]
        if not isinstance(value, str):
            errors.append(_qt003(f"{label} key '{key}' must be a string"))
        elif not value.strip():
            errors.append(_qt003(f"{label} key '{key}' must not be empty"))
        else:
            values[key] = value
    if errors:
        return None, errors
    entry = QualityTierEntry(
        path=values["path"], tier=values["tier"], rationale=values["rationale"]
    )
    return entry, []


def _parse_projects(
    document: dict[object, object],
) -> tuple[list[QualityTierEntry], list[QualityTierError]]:
    """Validate the ``projects`` list; return the valid entries and QT003 errors."""
    if "projects" not in document:
        return [], [_qt003("missing required top-level key 'projects'")]
    raw_projects = document["projects"]
    if not isinstance(raw_projects, list):
        return [], [_qt003("'projects' must be a list")]
    items = cast("list[object]", raw_projects)
    if not items:
        return [], [_qt003("'projects' must not be empty")]
    entries: list[QualityTierEntry] = []
    errors: list[QualityTierError] = []
    for index, raw in enumerate(items):
        entry, entry_errors = _parse_entry(index, raw)
        errors.extend(entry_errors)
        if entry is not None:
            entries.append(entry)
    return entries, errors


def parse_quality_tiers(
    text: str,
) -> tuple[QualityTierManifest | None, list[QualityTierError]]:
    """Parse manifest text into a manifest and its parse and schema errors.

    Args:
        text: The full text of ``quality-tiers.yml``.

    Returns:
        ``(None, [QT002])`` when the text is not valid YAML, repeats a mapping
        key, or has a root that is not a mapping. Otherwise a manifest holding
        every entry that passed entry-level checks, together with any QT003
        schema errors. An invalid ``version`` is carried as ``0``.
    """
    try:
        loaded = _load_yaml(text)
    except yaml.YAMLError as error:
        message = " ".join(str(error).split())
        return None, [
            QualityTierError(code="QT002", message=f"invalid YAML: {message}")
        ]
    if not isinstance(loaded, dict):
        return None, [
            QualityTierError(code="QT002", message="the document root is not a mapping")
        ]
    document = cast("dict[object, object]", loaded)
    errors: list[QualityTierError] = [
        _qt003(f"unknown top-level key '{key}'")
        for key in sorted(str(key) for key in document if key not in TOP_LEVEL_KEYS)
    ]
    version, version_errors = _check_version(document)
    entries, entry_errors = _parse_projects(document)
    errors.extend(version_errors)
    errors.extend(entry_errors)
    return QualityTierManifest(version=version, entries=tuple(entries)), errors


def _path_form_problem(path: str) -> str | None:
    """Return why ``path`` is not repository-relative POSIX, or ``None``."""
    if path == ROOT_PATH:
        return None
    if path.startswith("/"):
        return "is absolute"
    if _DRIVE_LETTER.match(path):
        return "has a drive letter"
    if "\\" in path:
        return "contains a backslash"
    if path.endswith("/"):
        return "has a trailing slash"
    if any(segment in ("", ".", "..") for segment in path.split("/")):
        return "has an empty, '.', or '..' segment"
    return None


def find_entry_errors(manifest: QualityTierManifest) -> list[QualityTierError]:
    """Return QT004 (tier), QT005 (duplicate path), and QT006 (path form) errors."""
    errors: list[QualityTierError] = []
    seen: set[str] = set()
    reported_duplicates: set[str] = set()
    for entry in manifest.entries:
        if entry.tier not in VALID_TIERS:
            errors.append(
                QualityTierError(
                    code="QT004",
                    message=f"'{entry.path}' has invalid tier '{entry.tier}'; "
                    "expected one of T1, T2, T3, T4",
                    path=entry.path,
                )
            )
        if entry.path in seen and entry.path not in reported_duplicates:
            reported_duplicates.add(entry.path)
            errors.append(
                QualityTierError(
                    code="QT005",
                    message=f"duplicate entry for path '{entry.path}'",
                    path=entry.path,
                )
            )
        seen.add(entry.path)
        problem = _path_form_problem(entry.path)
        if problem is not None:
            errors.append(
                QualityTierError(
                    code="QT006",
                    message=f"malformed path '{entry.path}': {problem}",
                    path=entry.path,
                )
            )
    return errors


def _is_excluded(path: str) -> bool:
    """Return whether ``path`` lies under an excluded discovery root."""
    if path.startswith(DISCOVERY_RULES.excluded_prefixes):
        return True
    return DISCOVERY_RULES.excluded_segment in path.split("/")


def _folder_of(path: str) -> str:
    """Return the folder holding ``path``, using ``.`` for the root."""
    return posixpath.dirname(path) or ROOT_PATH


def _discover_from_path(path: str, tracked: frozenset[str]) -> set[str]:
    """Return the project roots that ``path`` establishes under R1-R5."""
    rules = DISCOVERY_RULES
    found: set[str] = set()
    name = posixpath.basename(path)
    parts = path.split("/")
    if name == rules.manifest_file_name or name.endswith(rules.project_file_suffix):
        found.add(_folder_of(path))
    if name.endswith(rules.module_manifest_suffix):
        stem = path[: -len(rules.module_manifest_suffix)]
        if stem + rules.module_script_suffix in tracked:
            found.add(_folder_of(path))
    if (
        len(parts) == 3
        and parts[0] == rules.script_root
        and name.endswith(rules.script_suffixes)
    ):
        found.add("/".join(parts[:2]))
    library_parts = rules.library_root.split("/")
    if len(parts) > len(library_parts) + 1 and parts[: len(library_parts)] == (
        library_parts
    ):
        found.add("/".join(parts[: len(library_parts) + 1]))
    for hook_root in rules.hook_roots:
        if path.startswith(hook_root + "/"):
            found.add(hook_root)
    return found


def discover_projects(tracked_paths: Iterable[str]) -> frozenset[str]:
    """Return every project root that the tracked paths establish under R1-R5.

    Args:
        tracked_paths: Repository-relative POSIX paths, as listed by git.

    Returns:
        The discovered project roots, with ``.`` for the repository root.
    """
    tracked = frozenset(path for path in tracked_paths if not _is_excluded(path))
    projects: set[str] = set()
    for path in tracked:
        projects.update(_discover_from_path(path, tracked))
    return frozenset(projects)


def find_classification_errors(
    manifest: QualityTierManifest, projects: frozenset[str]
) -> list[QualityTierError]:
    """Return entry errors plus QT007 (stale entry) and QT008 (unclassified).

    Entries with a malformed path are reported as QT006 only and are left out
    of the QT007 comparison.
    """
    errors = find_entry_errors(manifest)
    entry_paths = {entry.path for entry in manifest.entries}
    malformed = {path for path in entry_paths if _path_form_problem(path) is not None}
    for path in sorted(entry_paths - malformed - projects):
        errors.append(
            QualityTierError(
                code="QT007",
                message=f"entry '{path}' is not a discovered project",
                path=path,
            )
        )
    for path in sorted(projects - entry_paths):
        errors.append(
            QualityTierError(
                code="QT008",
                message=f"discovered project '{path}' has no entry",
                path=path,
            )
        )
    return errors
