"""Parse and validate the durable epic kickoff Markdown contract."""

from __future__ import annotations

import re
from dataclasses import dataclass

KICKOFF_HEADING_RE = re.compile(r"^# Epic Kickoff: (?P<slug>[a-z0-9][a-z0-9-]*)$")
EPIC_RUN_RE = re.compile(r"Run `/epic-run (?P<slug>[a-z0-9][a-z0-9-]*)`")
MANIFEST_RE = re.compile(r"docs/features/epics/[a-z0-9][a-z0-9-]*/epic\.md")
INTEGRATION_BRANCH_RE = re.compile(r"epic/[a-z0-9][a-z0-9-]*-integration")
RESUME_RE = re.compile(
    r"(?:Every child|child features)\s+resumes?\s+at atomic execution\s+"
    r"from\s+(?:its|their)\s+committed plan-path",
    flags=re.IGNORECASE,
)
INTEGRITY_COMMIT_RE = re.compile(
    r"^(?:-\s*)?planning_commit:\s*`?(?P<commit>[0-9a-fA-F]{7,64})`?\s*$"
)
FEATURE_HEADERS = (
    "issue_num",
    "feature_folder",
    "wave",
    "complexity",
    "plan-path",
)
HASH_HEADERS = {"plan-hash", "plan_hash", "git-blob-sha", "git_blob_sha"}


@dataclass(frozen=True)
class KickoffFeature:
    """One structurally parsed feature-summary row."""

    issue_num: int
    feature_folder: str
    wave: int
    complexity: str
    plan_path: str


@dataclass(frozen=True)
class ParsedEpicKickoff:
    """Structured values required to cross-check a kickoff with planner state."""

    slug: str
    invocation_slug: str
    manifest_path: str
    integration_branch: str
    features: tuple[KickoffFeature, ...]
    planning_commit: str | None
    plan_hashes: dict[str, str]


def _split_sections(text: str) -> tuple[dict[str, list[str]], list[str]]:
    """Split exact level-two sections and reject duplicate required headings."""

    sections: dict[str, list[str]] = {}
    errors: list[str] = []
    current: str | None = None
    for line in text.splitlines()[1:]:
        if line.startswith("## "):
            current = line[3:].strip()
            if current in sections:
                errors.append(f"Epic kickoff contains duplicate section: ## {current}")
            else:
                sections[current] = []
            continue
        if current is not None:
            sections[current].append(line)
    for required in ("Invocation Prompt", "Feature Summary"):
        if required not in sections:
            errors.append(f"Epic kickoff is missing required section: ## {required}")
    return sections, errors


def _parse_cells(line: str) -> list[str] | None:
    """Parse one pipe-delimited Markdown table row."""

    stripped = line.strip()
    if not stripped.startswith("|") or not stripped.endswith("|"):
        return None
    return [cell.strip().strip("`") for cell in stripped[1:-1].split("|")]


def _is_separator(cells: list[str]) -> bool:
    """Return whether every cell is a Markdown table separator."""

    return bool(cells) and all(re.fullmatch(r":?-{3,}:?", cell) for cell in cells)


def _table_rows(
    lines: list[str], expected_headers: tuple[str, ...]
) -> tuple[list[list[str]], list[str]]:
    """Parse a strict Markdown table with exact ordered headers."""

    nonempty = [line for line in lines if line.strip()]
    if len(nonempty) < 2:
        return [], ["Epic kickoff table is missing its header or separator row."]
    headers = _parse_cells(nonempty[0])
    separator = _parse_cells(nonempty[1])
    errors: list[str] = []
    if headers != list(expected_headers):
        errors.append(
            "Epic kickoff feature table headers must be: "
            + " | ".join(expected_headers)
        )
    if (
        separator is None
        or len(separator) != len(expected_headers)
        or not _is_separator(separator)
    ):
        errors.append("Epic kickoff table separator row is invalid.")
    rows: list[list[str]] = []
    for line in nonempty[2:]:
        cells = _parse_cells(line)
        if cells is None or len(cells) != len(expected_headers):
            errors.append(f"Epic kickoff table row is invalid: {line}")
            continue
        rows.append(cells)
    if not rows:
        errors.append(
            "Epic kickoff feature table must contain at least one feature row."
        )
    return rows, errors


def _parse_features(lines: list[str]) -> tuple[tuple[KickoffFeature, ...], list[str]]:
    """Parse and type-check the canonical feature summary table."""

    rows, errors = _table_rows(lines, FEATURE_HEADERS)
    features: list[KickoffFeature] = []
    for index, row in enumerate(rows):
        issue_text, folder, wave_text, complexity, plan_path = row
        try:
            issue_num = int(issue_text)
        except ValueError:
            errors.append(
                f"Epic kickoff feature row {index} issue_num must be an integer."
            )
            continue
        try:
            wave = int(wave_text)
        except ValueError:
            errors.append(f"Epic kickoff feature row {index} wave must be an integer.")
            continue
        if complexity not in {"C1", "C2", "C3", "C4"}:
            errors.append(f"Epic kickoff feature row {index} complexity must be C1-C4.")
        features.append(KickoffFeature(issue_num, folder, wave, complexity, plan_path))
    return tuple(features), errors


def _parse_integrity(lines: list[str]) -> tuple[str | None, dict[str, str], list[str]]:
    """Parse optional planning-commit and Git-blob integrity fields."""

    commit: str | None = None
    plan_hashes: dict[str, str] = {}
    errors: list[str] = []
    table_lines: list[str] = []
    for line in lines:
        if not line.strip():
            continue
        match = INTEGRITY_COMMIT_RE.fullmatch(line.strip())
        if match:
            if commit is not None:
                errors.append(
                    "Epic kickoff integrity has duplicate planning_commit fields."
                )
            commit = match.group("commit").lower()
        elif line.strip().startswith("|"):
            table_lines.append(line)
        else:
            errors.append(f"Epic kickoff integrity line is invalid: {line}")
    if table_lines:
        header = _parse_cells(table_lines[0])
        if (
            header is None
            or len(header) != 2
            or header[0] != "plan-path"
            or header[1] not in HASH_HEADERS
        ):
            errors.append(
                "Epic kickoff integrity table headers must be plan-path and plan-hash."
            )
        elif len(table_lines) < 2:
            errors.append("Epic kickoff integrity table is missing its separator row.")
        else:
            separator = _parse_cells(table_lines[1])
            if separator is None or len(separator) != 2 or not _is_separator(separator):
                errors.append("Epic kickoff integrity table separator row is invalid.")
            for line in table_lines[2:]:
                cells = _parse_cells(line)
                if (
                    cells is None
                    or len(cells) != 2
                    or not re.fullmatch(r"[0-9a-fA-F]{40,64}", cells[1])
                ):
                    errors.append(
                        f"Epic kickoff integrity table row is invalid: {line}"
                    )
                    continue
                if cells[0] in plan_hashes:
                    errors.append(
                        f"Epic kickoff integrity repeats plan path: {cells[0]!r}."
                    )
                plan_hashes[cells[0]] = cells[1].lower()
    return commit, plan_hashes, errors


def parse_epic_kickoff(text: str) -> tuple[ParsedEpicKickoff | None, list[str]]:
    """Parse the kickoff into a state-comparable structure."""

    lines = text.splitlines()
    if not lines:
        return None, ["Epic kickoff is empty."]
    heading = KICKOFF_HEADING_RE.fullmatch(lines[0])
    if heading is None:
        return None, ["Epic kickoff first line must match '# Epic Kickoff: <slug>'."]
    sections, errors = _split_sections(text)
    invocation = "\n".join(sections.get("Invocation Prompt", []))
    invocation_slug = EPIC_RUN_RE.search(invocation)
    manifest_match = MANIFEST_RE.search(invocation)
    branch_match = INTEGRATION_BRANCH_RE.search(invocation)
    resume_match = RESUME_RE.search(invocation)
    if invocation_slug is None:
        errors.append("Epic kickoff invocation must contain `Run /epic-run <slug>`.")
    if manifest_match is None or branch_match is None or resume_match is None:
        errors.append(
            "Epic kickoff invocation must structurally name the manifest, integration "
            "branch, and atomic-execution resume boundary."
        )
    features, feature_errors = _parse_features(sections.get("Feature Summary", []))
    errors.extend(feature_errors)
    commit, plan_hashes, integrity_errors = _parse_integrity(
        sections.get("Integrity", [])
    )
    errors.extend(integrity_errors)
    if (
        errors
        or invocation_slug is None
        or manifest_match is None
        or branch_match is None
        or resume_match is None
    ):
        return None, errors
    return (
        ParsedEpicKickoff(
            slug=heading.group("slug"),
            invocation_slug=invocation_slug.group("slug"),
            manifest_path=manifest_match.group(0),
            integration_branch=branch_match.group(0),
            features=features,
            planning_commit=commit,
            plan_hashes=plan_hashes,
        ),
        [],
    )


def validate_epic_kickoff_text(text: str) -> list[str]:
    """Validate the standalone kickoff Markdown contract."""

    _, errors = parse_epic_kickoff(text)
    return errors
