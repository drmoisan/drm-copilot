"""Discover and parse canonical feature verification evidence artifacts.

Purpose:
    Provide deterministic discovery and strict schema parsing for canonical
    evidence markdown files so PR context generation can make traceable
    verification claims.

Flow:
    1. Discover canonical evidence files under active feature folders.
    2. Parse required schema fields from each markdown file.
    3. Normalize pass/fail/unparseable status from EXIT_CODE.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal

if TYPE_CHECKING:
    from pathlib import Path

REQUIRED_FIELDS: tuple[str, str, str] = ("Timestamp", "Command", "EXIT_CODE")
CANONICAL_GLOBS: tuple[str, str, str] = (
    "evidence/qa-gates/**/*.md",
    "evidence/regression-testing/**/*.md",
    "evidence/other/**/*.md",
)

NormalizedResult = Literal["pass", "fail", "unparseable"]


@dataclass(frozen=True)
class VerificationEvidenceRecord:
    """Represent one parsed canonical evidence artifact.

    Purpose:
        Carry all fields needed to render verification rows and preserve source
        traceability to a specific feature evidence file.

    Attributes:
        feature: Active feature folder identifier.
        source_file: Repository-relative evidence file path.
        timestamp: Parsed `Timestamp` field when present.
        command: Parsed `Command` field when present.
        exit_code: Parsed `EXIT_CODE` integer when parseable.
        normalized_result: Deterministic status (`pass`, `fail`, `unparseable`).
    """

    feature: str
    source_file: str
    timestamp: str | None
    command: str | None
    exit_code: int | None
    normalized_result: NormalizedResult


def discover_canonical_evidence_files(root: Path, feature: str) -> list[Path]:
    """Discover canonical evidence files for one active feature.

    Args:
        root: Repository root path.
        feature: Active feature directory name under `docs/features/active`.

    Returns:
        Sorted, deduplicated repository-relative paths for canonical evidence files.

    Side Effects:
        Reads filesystem metadata through globbing.
    """
    feature_root = root / "docs" / "features" / "active" / feature
    if not feature_root.exists() or not feature_root.is_dir():
        return []

    discovered: set[Path] = set()
    # Search canonical evidence roots in a fixed order, then sort for stability.
    for pattern in CANONICAL_GLOBS:
        for candidate in feature_root.glob(pattern):
            if candidate.is_file():
                discovered.add(candidate.relative_to(root))
    return sorted(discovered)


def parse_verification_evidence_markdown(
    *, feature: str, source_file: str, markdown: str
) -> VerificationEvidenceRecord:
    """Parse required schema fields and normalize verification status.

    Args:
        feature: Active feature identifier owning the evidence file.
        source_file: Repository-relative evidence file path.
        markdown: Raw markdown content to parse.

    Returns:
        A normalized evidence record with `pass`, `fail`, or `unparseable` result.

    Side Effects:
        None.
    """
    parsed: dict[str, str] = {}

    # Parse `Key: value` rows once and keep only required schema fields.
    for raw_line in markdown.splitlines():
        if ":" not in raw_line:
            continue
        key, value = raw_line.split(":", 1)
        key = key.strip()
        if key in REQUIRED_FIELDS:
            parsed[key] = value.strip()

    timestamp = parsed.get("Timestamp")
    command = parsed.get("Command")
    exit_code_raw = parsed.get("EXIT_CODE")

    if not timestamp or not command or exit_code_raw is None:
        return VerificationEvidenceRecord(
            feature=feature,
            source_file=source_file,
            timestamp=timestamp,
            command=command,
            exit_code=None,
            normalized_result="unparseable",
        )

    try:
        exit_code = int(exit_code_raw)
    except ValueError:
        return VerificationEvidenceRecord(
            feature=feature,
            source_file=source_file,
            timestamp=timestamp,
            command=command,
            exit_code=None,
            normalized_result="unparseable",
        )

    normalized_result: NormalizedResult = "pass" if exit_code == 0 else "fail"
    return VerificationEvidenceRecord(
        feature=feature,
        source_file=source_file,
        timestamp=timestamp,
        command=command,
        exit_code=exit_code,
        normalized_result=normalized_result,
    )


def parse_verification_evidence_file(
    *, root: Path, feature: str, relative_path: Path
) -> VerificationEvidenceRecord:
    """Read and parse one canonical evidence file.

    Args:
        root: Repository root path.
        feature: Active feature identifier.
        relative_path: Repository-relative evidence file path.

    Returns:
        Parsed normalized evidence record.

    Raises:
        OSError: Propagated when the evidence file cannot be read.

    Side Effects:
        Reads evidence file content from disk.
    """
    markdown = (root / relative_path).read_text(encoding="utf-8")
    return parse_verification_evidence_markdown(
        feature=feature,
        source_file=relative_path.as_posix(),
        markdown=markdown,
    )
