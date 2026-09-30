"""Apply the destination exclusion manifest to the Claude push-down.

Purpose:
    Read ``.push-down-exclusions`` through the injected adapter, withhold every
    matched payload path at enumeration time, guard destination writes, and
    report skipped paths, conflicts, and unmatched entries in the returned
    summary, the summary artifact, and CLI lines.

Invariants / Constraints:
    - ``ExclusionFilterFileSystem`` is the outermost decorator, so a skipped
      path never reaches any merge or derive decorator beneath it.
    - The manifest path and every matched path are never written through the
      filter; the summary artifact directory is exempt from the manifest.
    - Nothing here deletes a destination file.
"""

from __future__ import annotations

import dataclasses
import json
from dataclasses import dataclass
from typing import TYPE_CHECKING, cast

try:
    from scripts.dev_tools.push_down_copilot_customizations import PushDownSummary
    from scripts.dev_tools.push_down_exclusion_manifest import (
        EXCLUSION_MANIFEST_RELATIVE_PATH,
        ExclusionEntry,
        ExclusionManifest,
        ExclusionManifestError,
        SkippedPath,
        find_first_match,
        parse_exclusion_manifest,
        plan_exclusions,
        unmatched_exclusion_entries,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_copilot_customizations import PushDownSummary
    from dev_tools.push_down_exclusion_manifest import (
        EXCLUSION_MANIFEST_RELATIVE_PATH,
        ExclusionEntry,
        ExclusionManifest,
        ExclusionManifestError,
        SkippedPath,
        find_first_match,
        parse_exclusion_manifest,
        plan_exclusions,
        unmatched_exclusion_entries,
    )

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )

__all__ = [
    "DEFAULT_ARTIFACT_DIRECTORY",
    "ClaudePushDownSummary",
    "ExclusionFilterFileSystem",
    "ExclusionReport",
    "ExclusionViolationError",
    "append_exclusions_to_artifact",
    "build_exclusion_report",
    "exclusion_report_payload",
    "extend_summary",
    "read_exclusion_manifest",
    "render_exclusion_lines",
]

# Destination-relative directory of the Claude summary artifact; it matches
# ``ARTIFACT_DIRECTORY`` in ``push_down_claude_customizations``, which passes
# its own constant explicitly.
DEFAULT_ARTIFACT_DIRECTORY = "artifacts/claude-customizations"


class ExclusionViolationError(RuntimeError):
    """Raised when a write targets the manifest path or an excluded path."""


@dataclass(frozen=True, slots=True)
class ExclusionReport:
    """The exclusion outcome of one push-down run with a manifest.

    Attributes:
        manifest_path (str): Destination-relative manifest path.
        entries (tuple[ExclusionEntry, ...]): Manifest entries in file order.
        skipped (tuple[SkippedPath, ...]): Skipped paths in enumeration order.
        unmatched_entries (tuple[ExclusionEntry, ...]): Entries that were the
            first match of no skipped path, in manifest order.
    """

    manifest_path: str
    entries: tuple[ExclusionEntry, ...]
    skipped: tuple[SkippedPath, ...]
    unmatched_entries: tuple[ExclusionEntry, ...]

    @property
    def skipped_count(self) -> int:
        """Return the number of skipped paths, conflicts included."""

        return len(self.skipped)

    @property
    def conflict_count(self) -> int:
        """Return the number of skipped paths present at the destination."""

        return sum(1 for skip in self.skipped if skip.destination_status == "present")


@dataclass(frozen=True, slots=True)
class ClaudePushDownSummary(PushDownSummary):
    """The engine summary plus the exclusion report (``None`` without manifest)."""

    exclusions: ExclusionReport | None = None


def _relative_posix(path: Path, root: Path) -> str | None:
    """Return ``path`` relative to ``root`` as POSIX text, or ``None`` outside it."""

    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return None


class ExclusionFilterFileSystem:
    """Outermost decorator that withholds manifest-matched payload paths.

    Purpose:
        Drop matched source files from ``list_files`` so the engine never
        reads, merges, derives, or writes them, record each skip with its
        destination status, and refuse any write to an excluded path.

    Attributes:
        skipped (list[SkippedPath]): Skip records in enumeration order.
    """

    def __init__(
        self,
        inner: PushDownFileSystem,
        source_root: Path,
        destination_root: Path,
        manifest: ExclusionManifest,
        *,
        artifact_directory: str = DEFAULT_ARTIFACT_DIRECTORY,
    ) -> None:
        """Wrap ``inner`` with the manifest filter.

        Args:
            inner (PushDownFileSystem): Adapter the engine would otherwise use.
            source_root (Path): Root the engine enumerates payload files under.
            destination_root (Path): Destination workspace root.
            manifest (ExclusionManifest): Parsed manifest.
            artifact_directory (str): Destination-relative summary-artifact
                directory exempt from the write guard.
        """

        self._inner = inner
        self._source_root = source_root
        self._destination_root = destination_root
        self._manifest = manifest
        self._artifact_prefix = artifact_directory.rstrip("/") + "/"
        self.skipped: list[SkippedPath] = []

    def _destination_has_file(self, relative_path: str) -> bool:
        """Probe the inner adapter for a destination file at a relative path."""

        return self._inner.is_file(self._destination_root / relative_path)

    def list_files(self, root: Path) -> list[Path]:
        """Return inner files minus manifest-matched paths, recording skips."""

        listed = self._inner.list_files(root)
        relative_by_path = {
            path: _relative_posix(path, self._source_root) for path in listed
        }
        candidates = [rel for rel in relative_by_path.values() if rel is not None]
        plan = plan_exclusions(candidates, self._manifest, self._destination_has_file)
        self.skipped.extend(plan.skipped)
        kept = set(plan.kept)
        # Paths outside the source root cannot map to a destination path and
        # are passed through unchanged.
        return [
            path
            for path, relative in relative_by_path.items()
            if relative is None or relative in kept
        ]

    def is_dir(self, path: Path) -> bool:
        """Delegate to the inner adapter."""

        return self._inner.is_dir(path)

    def is_file(self, path: Path) -> bool:
        """Delegate to the inner adapter."""

        return self._inner.is_file(path)

    def read_text(self, path: Path) -> str:
        """Delegate to the inner adapter."""

        return self._inner.read_text(path)

    def ensure_dir(self, path: Path) -> None:
        """Delegate to the inner adapter."""

        self._inner.ensure_dir(path)

    def write_text(self, path: Path, content: str) -> None:
        """Write through the inner adapter unless the target is excluded.

        Raises:
            ExclusionViolationError: When the destination-relative target is
                the manifest path or matches a manifest entry.
        """

        relative = _relative_posix(path, self._destination_root)
        # Targets outside the destination and the summary artifact are not
        # subject to the manifest and pass through unconditionally.
        if relative is not None and not relative.startswith(self._artifact_prefix):
            if relative == EXCLUSION_MANIFEST_RELATIVE_PATH:
                raise ExclusionViolationError(
                    f"Refusing to write the push-down exclusion manifest: {relative}"
                )
            entry = find_first_match(self._manifest, relative)
            if entry is not None:
                raise ExclusionViolationError(
                    f"Refusing to write excluded path {relative} "
                    f"(entry {entry.normalized}, line {entry.line})"
                )
        self._inner.write_text(path, content)


def read_exclusion_manifest(
    fs: PushDownFileSystem, destination_root: Path
) -> ExclusionManifest | None:
    """Read and parse the destination manifest, or return ``None`` when absent.

    Raises:
        ExclusionManifestError: When a directory sits at the manifest path, the
            text is not UTF-8, or an entry is malformed.
    """

    manifest_path = destination_root / EXCLUSION_MANIFEST_RELATIVE_PATH
    if not fs.is_file(manifest_path):
        if fs.is_dir(manifest_path):
            raise ExclusionManifestError(
                EXCLUSION_MANIFEST_RELATIVE_PATH, None, "path is not a regular file"
            )
        return None
    try:
        text = fs.read_text(manifest_path)
    except UnicodeDecodeError as error:
        raise ExclusionManifestError(
            EXCLUSION_MANIFEST_RELATIVE_PATH, None, "text is not valid UTF-8"
        ) from error
    return parse_exclusion_manifest(text, EXCLUSION_MANIFEST_RELATIVE_PATH)


def build_exclusion_report(
    manifest: ExclusionManifest, skipped: list[SkippedPath] | tuple[SkippedPath, ...]
) -> ExclusionReport:
    """Assemble the report from the manifest and the recorded skips."""

    return ExclusionReport(
        manifest_path=manifest.path,
        entries=manifest.entries,
        skipped=tuple(skipped),
        unmatched_entries=unmatched_exclusion_entries(manifest, skipped),
    )


def render_exclusion_lines(report: ExclusionReport) -> list[str]:
    """Render one line per skipped path, then one per unmatched entry."""

    lines: list[str] = []
    for skip in report.skipped:
        suffix = f"{skip.relative_path} (entry {skip.entry}, line {skip.line})"
        if skip.destination_status == "present":
            lines.append(
                "push-down exclusion conflict: destination file present, "
                f"not overwritten: {suffix}"
            )
        else:
            lines.append(f"push-down exclusion: skipped {suffix}")
    lines.extend(
        "push-down exclusion: entry matched no payload path: "
        f"{entry.normalized} (line {entry.line})"
        for entry in report.unmatched_entries
    )
    return lines


def exclusion_report_payload(report: ExclusionReport) -> dict[str, object]:
    """Return the JSON-ready ``exclusions`` object for the summary artifact."""

    return {
        "conflict_count": report.conflict_count,
        "entries": [entry.normalized for entry in report.entries],
        "manifest_path": report.manifest_path,
        "skipped": [
            {
                "destination_status": skip.destination_status,
                "entry": skip.entry,
                "line": skip.line,
                "relative_path": skip.relative_path,
            }
            for skip in report.skipped
        ],
        "skipped_count": report.skipped_count,
        "unmatched_entries": [entry.normalized for entry in report.unmatched_entries],
    }


def append_exclusions_to_artifact(
    fs: PushDownFileSystem, artifact_path: Path, report: ExclusionReport
) -> None:
    """Add the ``exclusions`` object to the written artifact with sorted keys.

    Raises:
        ValueError: When the artifact does not hold a JSON object.
    """

    payload: object = json.loads(fs.read_text(artifact_path))
    if not isinstance(payload, dict):
        raise ValueError(f"Summary artifact is not a JSON object: {artifact_path}")
    # json.loads yields str keys for an object; the cast records that fact.
    document = dict(cast("dict[str, object]", payload))
    document["exclusions"] = exclusion_report_payload(report)
    fs.write_text(artifact_path, json.dumps(document, indent=2, sort_keys=True))


def extend_summary(
    summary: PushDownSummary, exclusions: ExclusionReport | None
) -> ClaudePushDownSummary:
    """Copy the engine summary's fields into a ``ClaudePushDownSummary``."""

    values = {
        field.name: getattr(summary, field.name)
        for field in dataclasses.fields(PushDownSummary)
    }
    return ClaudePushDownSummary(**values, exclusions=exclusions)
