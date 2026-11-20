"""Repository layout configuration shared by the developer tools.

Purpose:
    Hold the repository layout facts that several developer tools read: the
    governed JSON globs, the development-docs root resolved from the flat key
    ``development_docs_root`` of ``config/orchestration-routing.json`` with
    its area map and known-root prefixes (issue #1035), and the feature-folder
    name rules (date-first, issue-first, other) with the ``<NNNN>-<feature>``
    formatter.

Side effects:
    ``iter_governed_files`` and the default reader and probe of
    ``resolve_development_docs_root`` touch the file system; every other
    function is pure. This module imports nothing from ``scripts.dev_tools``.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable, Sequence

# Governed JSON config globs (relative to repo root)
# Note: .vscode and .devcontainer files are JSONC (JSON with Comments)
# and cannot be formatted by jq. They are excluded from formatting.
GOVERNED_GLOBS: Sequence[str] = (
    "scripts/**/*.json",
    "docs/**/*.json",
    # JSON under the .dev development-docs root (issue #1035); EXCLUDE_GLOBS
    # is unchanged, so whether .dev records are excluded is decided later.
    ".dev/**/*.json",
    "examples/**/*.json",
)

# Exclude large/generated data and artifacts
EXCLUDE_GLOBS: Sequence[str] = (
    "data/**",
    "artifacts/**",
    # Feature folders hold finalized records (evidence, ruleset snapshots) that
    # must never be rewritten by formatting or validation tooling.
    "docs/features/**",
    "htmlcov/**",
    "coverage*/**",
    "**/node_modules/**",
    ".venv",
    ".venv/**",
    "**/.venv",
    "**/.venv/**",
)


def iter_governed_files(root: Path | str) -> Iterable[Path]:
    """Yield governed JSON files under the repo root respecting excludes."""
    root_path = Path(root)
    # Resolve include matches first
    includes: list[Path] = []
    for pattern in GOVERNED_GLOBS:
        includes.extend(root_path.glob(pattern))

    # Build exclusion set
    excluded: set[Path] = set()
    for pattern in EXCLUDE_GLOBS:
        excluded.update(root_path.glob(pattern))

    for path in includes:
        if any(parent in excluded for parent in path.parents):
            continue
        if path in excluded:
            continue
        if path.is_file():
            yield path


# ---------------------------------------------------------------------------
# Repository layout configuration: the development-docs root (issue #1035).
# ---------------------------------------------------------------------------

DEVELOPMENT_DOCS_ROOT_KEY = "development_docs_root"
DEVELOPMENT_DOCS_ROUTING_FILE = "config/orchestration-routing.json"
DEFAULT_DEVELOPMENT_DOCS_ROOT = "docs/features"
KNOWN_DEVELOPMENT_DOCS_ROOTS: tuple[str, ...] = ("docs/features", ".dev")

_ROOT_CHILD_AREAS: frozenset[str] = frozenset(
    {
        "active",
        "completed",
        "archive",
        "potential",
        "potential/promoted",
        "epics",
        "parallel",
        "templates",
    }
)
_SIBLING_AREA_PATHS: dict[str, dict[str, str]] = {
    "backlog": {"docs/features": "docs/features/backlog.md", ".dev": ".dev/backlog.md"},
    "research": {"docs/features": "docs/research", ".dev": ".dev/research"},
    "discovery-templates": {
        "docs/features": "docs/discovery/templates",
        ".dev": ".dev/discovery/templates",
    },
    "engineering": {"docs/features": "docs/engineering", ".dev": ".dev/engineering"},
}
_FILE_AREAS: frozenset[str] = frozenset({"backlog"})


def _default_read_text(path: Path) -> str:
    """Read a file as UTF-8 text; the default reader of the resolver.

    Args:
        path: File to read.

    Returns:
        The file text.

    Raises:
        OSError: When the file is absent or unreadable.
    """
    return path.read_text(encoding="utf-8")


def _default_is_dir(path: Path) -> bool:
    """Return whether a directory exists; the default probe of the resolver.

    Args:
        path: Directory to probe.

    Returns:
        True when the path is an existing directory.
    """
    return path.is_dir()


def _describe_value(value: object) -> str:
    """Render a parsed JSON value for an error message, as JavaScript does.

    Args:
        value: Any parsed JSON value.

    Returns:
        Compact JSON text without ASCII escaping, so messages match the
        TypeScript resolver.
    """
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def resolve_development_docs_root(
    workspace: Path,
    *,
    read_text: Callable[[Path], str] | None = None,
    is_dir: Callable[[Path], bool] | None = None,
) -> str:
    """Resolve the development-docs root of a workspace (rules R-1 to R-8).

    Args:
        workspace: Root that holds ``config/orchestration-routing.json``.
        read_text: Injected reader; raises ``OSError`` when the file is absent
            or unreadable. Defaults to UTF-8 ``Path.read_text``.
        is_dir: Injected directory probe. Defaults to ``Path.is_dir``.

    Returns:
        ``"docs/features"`` or ``".dev"``.

    Raises:
        ValueError: For malformed JSON (R-3) or a value outside the closed set
            (R-4); the message names the file, the key, and the value.
    """
    reader = read_text if read_text is not None else _default_read_text
    probe = is_dir if is_dir is not None else _default_is_dir
    file_name = DEVELOPMENT_DOCS_ROUTING_FILE
    key = DEVELOPMENT_DOCS_ROOT_KEY
    try:
        text = reader(workspace / file_name)
    except OSError:
        # R-1: an absent or unreadable file resolves the default root.
        return DEFAULT_DEVELOPMENT_DOCS_ROOT
    try:
        parsed: object = json.loads(text)
    except ValueError as error:
        raise ValueError(
            f"{file_name} is not valid JSON, so {key} cannot be read "
            f"(value: unparseable; {error})."
        ) from error
    if not isinstance(parsed, dict):
        raise ValueError(
            f"{file_name} is not a JSON object, so {key} cannot be read "
            f"(value: {_describe_value(parsed)})."
        )
    record = cast("dict[str, object]", parsed)
    if key not in record:
        # R-2: no .dev probe when the key is absent.
        return DEFAULT_DEVELOPMENT_DOCS_ROOT
    value = record[key]
    if not isinstance(value, str) or value not in KNOWN_DEVELOPMENT_DOCS_ROOTS:
        raise ValueError(
            f"{file_name} {key} value {_describe_value(value)} is not one of: "
            f"{', '.join(KNOWN_DEVELOPMENT_DOCS_ROOTS)}."
        )
    # R-5 to R-8: the default value never probes; the .dev value prefers an
    # existing .dev, falls back to an existing docs/features for one release,
    # and otherwise resolves .dev so creators make the configured layout.
    if value == DEFAULT_DEVELOPMENT_DOCS_ROOT:
        return value
    if probe(workspace / ".dev"):
        return ".dev"
    if probe(workspace / DEFAULT_DEVELOPMENT_DOCS_ROOT):
        return DEFAULT_DEVELOPMENT_DOCS_ROOT
    return ".dev"


def development_docs_relative_path(root: str, area: str) -> str:
    """Return the repository-relative forward-slash path of an area under a root.

    Args:
        root: A member of ``KNOWN_DEVELOPMENT_DOCS_ROOTS``.
        area: Area name of the area map.

    Returns:
        The area path, for example ``.dev/active`` or ``docs/research``.

    Raises:
        ValueError: For an unknown root or area.
    """
    if root not in KNOWN_DEVELOPMENT_DOCS_ROOTS:
        raise ValueError(f"Unknown development docs root: {root}")
    if area in _ROOT_CHILD_AREAS:
        return f"{root}/{area}"
    sibling = _SIBLING_AREA_PATHS.get(area)
    if sibling is None:
        raise ValueError(f"Unknown development docs area: {area}")
    return sibling[root]


def development_docs_path(
    workspace: Path, area: str, *, root: str | None = None
) -> Path:
    """Return the path of an area under the workspace (spec area map).

    Args:
        workspace: Workspace root.
        area: Area name of the area map.
        root: Known root; resolved from the workspace when omitted.

    Returns:
        The workspace-joined area path.

    Raises:
        ValueError: For an unknown root or area, or a resolver error.
    """
    selected = root if root is not None else resolve_development_docs_root(workspace)
    return workspace / development_docs_relative_path(selected, area)


def known_root_prefixes(area: str) -> tuple[str, ...]:
    """Return the prefixes of an area under every known root, in root order.

    Directory areas end with ``/``; the file area ``backlog`` is the exact path.

    Args:
        area: Area name of the area map.

    Returns:
        One prefix per known root.

    Raises:
        ValueError: For an unknown area.
    """
    suffix = "" if area in _FILE_AREAS else "/"
    # Emit the area's prefix under every known root, default root first.
    return tuple(
        f"{development_docs_relative_path(root, area)}{suffix}"
        for root in KNOWN_DEVELOPMENT_DOCS_ROOTS
    )


# ---------------------------------------------------------------------------
# Feature-folder name rules (issue #1035; spec D-18, D-19).
# ---------------------------------------------------------------------------

# Own copy of the feature-name expression of new_active_feature_folder_models,
# kept here so this module imports nothing from scripts.dev_tools.
FEATURE_NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:[-_][a-z0-9]+)*$")
MAX_FEATURE_FOLDER_ISSUE = 9999
_DATE_FIRST = re.compile(r"^([0-9]{4}-[0-9]{2}-[0-9]{2})-(.+)$")
_ISSUE_FIRST = re.compile(r"^([0-9]{4})-(.+)$")
_TRAILING_ISSUE = re.compile(r"^(.+)-([0-9]+)$")
_DATE_PREFIX = re.compile(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}-")
_PARTIAL_DATE_PREFIX = re.compile(r"^[0-9]{2}-[0-9]{2}-")


@dataclass(frozen=True)
class FeatureFolderName:
    """A parsed feature-folder name.

    Purpose:
        Value object returned by ``parse_feature_folder_name``.

    Attributes:
        format: ``date-first``, ``issue-first`` or ``other``.
        feature: Feature part of the name.
        issue_number: Parsed issue number, or ``None``.
        date: ``yyyy-MM-dd`` prefix of a date-first name, else ``None``.
    """

    format: str
    feature: str
    issue_number: int | None
    date: str | None = None


def _split_trailing_issue(text: str) -> tuple[str, int | None]:
    """Split a trailing ``-<digits>`` issue suffix from a name.

    Args:
        text: Folder name or date-first remainder.

    Returns:
        The feature and the issue number, or the whole text and ``None``.
    """
    match = _TRAILING_ISSUE.fullmatch(text)
    if match is None:
        return text, None
    return match.group(1), int(match.group(2))


def parse_feature_folder_name(name: str) -> FeatureFolderName:
    """Parse a feature-folder name (F-1 to F-6).

    Args:
        name: Folder basename.

    Returns:
        The parsed name. The date-first shape is tried before the issue-first
        shape because both begin with four digits; ``0000-`` is not an issue.
    """
    dated = _DATE_FIRST.fullmatch(name)
    if dated is not None:
        feature, issue = _split_trailing_issue(dated.group(2))
        return FeatureFolderName("date-first", feature, issue, dated.group(1))
    issue_first = _ISSUE_FIRST.fullmatch(name)
    if issue_first is not None and int(issue_first.group(1)) > 0:
        return FeatureFolderName(
            "issue-first", issue_first.group(2), int(issue_first.group(1))
        )
    feature, issue = _split_trailing_issue(name)
    return FeatureFolderName("other", feature, issue)


def strip_date_first_prefix(stem: str) -> str:
    """Remove a leading ``yyyy-MM-dd-`` date from a potential stem.

    Args:
        stem: Potential file stem.

    Returns:
        The stem without its date prefix.
    """
    return _DATE_PREFIX.sub("", stem, count=1)


def format_feature_folder_name(issue_number: int, feature: str) -> str:
    """Format the issue-first folder name ``<NNNN>-<feature>`` (N-1 to N-5).

    The feature has its date-first prefix and a trailing ``-<issue>`` removed
    before validation.

    Args:
        issue_number: Integer issue number from 1 to 9999.
        feature: Potential stem or feature name.

    Returns:
        The folder name, for example ``0042-notes``.

    Raises:
        ValueError: For an issue that is not an integer from 1 to 9999, or for
            an empty feature, a feature failing the name pattern, or a feature
            beginning with ``dd-dd-``.
    """
    # Callers may pass a float or a bool despite the annotation; both are rejected.
    candidate = cast("object", issue_number)
    is_integer = isinstance(candidate, int) and not isinstance(candidate, bool)
    if not is_integer or issue_number <= 0:
        raise ValueError(
            f"Feature folder issue number must be a positive integer: {issue_number}"
        )
    if issue_number > MAX_FEATURE_FOLDER_ISSUE:
        raise ValueError(
            f"Feature folder issue number must be at most {MAX_FEATURE_FOLDER_ISSUE}: "
            f"{issue_number}"
        )
    stem = strip_date_first_prefix(feature)
    issue_suffix = f"-{issue_number}"
    if stem.endswith(issue_suffix) and len(stem) > len(issue_suffix):
        stem = stem[: -len(issue_suffix)]
    if (
        not stem
        or FEATURE_NAME_PATTERN.fullmatch(stem) is None
        or _PARTIAL_DATE_PREFIX.match(stem) is not None
    ):
        raise ValueError(
            f"Feature folder feature name is invalid: {_describe_value(feature)}"
        )
    return f"{issue_number:04d}-{stem}"
