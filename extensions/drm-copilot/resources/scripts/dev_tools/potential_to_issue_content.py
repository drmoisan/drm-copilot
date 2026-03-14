"""Content and metadata helpers for potential-to-issue promotion workflows."""

from __future__ import annotations

import json
import re
from datetime import datetime
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pathlib import Path

PLACEHOLDER = "(not provided in potential file)"
ISSUE_URL_PATTERN = re.compile(r"https?://\S+/issues/(\d+)")
BUG_SECTION_HEADINGS = [
    "Summary",
    "Environment",
    "Steps to Reproduce",
    "Expected Behavior",
    "Actual Behavior",
    "Logs / Screenshots",
    "Impact / Severity",
]
SMART_PUNCTUATION_MAP = {
    "\u201c": '"',
    "\u201d": '"',
    "\u2018": "'",
    "\u2019": "'",
    "\u2013": "-",
    "\u2014": "-",
    "\u00a0": " ",
}


def strip_potential_marker(value: str) -> str:
    """Remove `(Potential...)` suffix markers from heading values."""
    cleaned = re.sub(r"\s*\(Potential[^)]*\)", "", value, flags=re.IGNORECASE).strip()
    return cleaned or value.strip()


def get_feature_name(content: str, file_path: Path) -> str:
    """Derive feature name from markdown heading or filename fallback."""
    heading_match = re.search(r"^\s*#\s+(.+)$", content, flags=re.MULTILINE)
    if heading_match:
        feature_name = strip_potential_marker(heading_match.group(1))
        if feature_name:
            return feature_name

    name = file_path.name
    return name[:-3] if name.lower().endswith(".md") else name


def get_feature_path(feature_name: str) -> str:
    """Convert feature name into a safe path token."""
    replaced = re.sub(r"\s+", "_", feature_name)
    return re.sub(r"[^A-Za-z0-9_-]", "", replaced)


def get_section(content: str, heading: str) -> str:
    """Extract markdown section body for a top-level `##` heading."""
    escaped = re.escape(heading)
    pattern = rf"^##\s+{escaped}\s*\r?\n(.*?)(?=^##\s+|\Z)"
    match = re.search(pattern, content, flags=re.MULTILINE | re.DOTALL)
    if not match:
        return ""
    return match.group(1).strip()


def build_body(
    work_mode: str,
    problem: str,
    behavior: str,
    criteria: str,
    constraints: str,
    tests: str,
    relative_path: str,
) -> str:
    """Construct the standard full-feature issue body."""
    return (
        f"- Work Mode: {work_mode}\n"
        f"## Problem / Why\n{problem}\n\n"
        f"## Proposed Behavior\n{behavior}\n\n"
        f"## Acceptance Criteria\n{criteria}\n\n"
        f"## Constraints & Risks\n{constraints}\n\n"
        f"## Test Conditions\n{tests}\n\n"
        f"## Source\nFrom: {relative_path}\n"
    )


def build_bug_body(work_mode: str, sections: dict[str, str], relative_path: str) -> str:
    """Construct the bug issue body from canonical bug section headings."""
    parts = [f"- Work Mode: {work_mode}"]
    parts.extend(
        f"## {heading}\n{sections[heading]}" for heading in BUG_SECTION_HEADINGS
    )
    parts.append(f"## Source\nFrom: {relative_path}")
    return "\n\n".join(parts) + "\n"


def evaluate_minor_audit_eligibility(content: str) -> tuple[bool, str]:
    """Evaluate deterministic eligibility for minor-audit mode."""
    lower = content.lower()
    if "bootstrapped" in lower or "pre-cooked" in lower:
        return True, "eligible: bootstrapped/pre-cooked"

    production_files = len(
        re.findall(r"^\s*-\s*(?:production\s+)?file\s*:", content, flags=re.MULTILINE)
    )
    has_low_risk = "low integration risk" in lower or "risk: low" in lower
    if production_files <= 3 and has_low_risk:
        return True, "eligible: <=3 production files and low integration risk"
    if production_files > 3:
        return False, "fallback: production file count exceeds 3"
    return False, "fallback: missing low integration risk signal"


def build_minor_audit_body(
    work_mode: str,
    problem: str,
    implementation_intent: str,
    acceptance_criteria: str,
    dependencies_risks: str,
    verification_steps: str,
    evidence_checklist: str,
    relative_path: str,
) -> str:
    """Build required issue sections for the minor-audit mode."""
    return (
        f"- Work Mode: {work_mode}\n"
        f"## Problem / Why\n{problem}\n\n"
        f"## Implementation Intent\n{implementation_intent}\n\n"
        f"## Acceptance Criteria\n{acceptance_criteria}\n\n"
        f"## Dependencies / Risks\n{dependencies_risks}\n\n"
        f"## Verification Steps\n{verification_steps}\n\n"
        f"## Evidence Checklist\n{evidence_checklist}\n\n"
        f"## Source\nFrom: {relative_path}\n"
    )


def parse_issue_reference(output: list[str]) -> tuple[str | None, str | None]:
    """Parse created issue URL and number from gh output lines."""
    text = "\n".join(output)
    match = ISSUE_URL_PATTERN.search(text)
    if not match:
        return None, None
    return match.group(0), match.group(1)


def extract_last_updated(issue_json: str) -> str | None:
    """Extract issue updated date from gh JSON payload."""
    try:
        data = json.loads(issue_json)
    except json.JSONDecodeError:
        return None

    updated_raw = data.get("updatedAt")
    if not isinstance(updated_raw, str):
        return None

    try:
        dt = datetime.fromisoformat(updated_raw.replace("Z", "+00:00"))
    except ValueError:
        return None
    return dt.date().isoformat()


def find_meta_end(lines: list[str]) -> int:
    """Locate insertion point where header metadata block ends."""
    for idx, line in enumerate(lines):
        if line.lstrip().startswith("## "):
            return idx
    return len(lines)


def normalize_smart_punctuation(text: str) -> str:
    """Replace common smart punctuation characters with ASCII equivalents."""
    return text.translate(str.maketrans(SMART_PUNCTUATION_MAP))


def set_line_value(lines: list[str], label: str, value: str, meta_end: int) -> int:
    """Set or insert a metadata line and return updated metadata boundary index."""
    pattern = re.compile(rf"^- {re.escape(label)}:")
    for idx, line in enumerate(lines):
        if pattern.match(line):
            lines[idx] = f"- {label}: {value}"
            return meta_end
    lines.insert(meta_end, f"- {label}: {value}")
    return meta_end + 1


def update_metadata_lines(
    lines: list[str],
    feature_name: str,
    issue_number: str,
    issue_url: str,
    last_updated: str | None,
    feature_path: str,
) -> list[str]:
    """Apply issue metadata updates to potential markdown lines."""
    if lines:
        lines[0] = f"# {feature_name} (Issue #{issue_number})"

    meta_end = find_meta_end(lines)
    meta_end = set_line_value(lines, "Issue", f"#{issue_number}", meta_end)
    meta_end = set_line_value(lines, "Issue URL", issue_url, meta_end)
    if last_updated:
        meta_end = set_line_value(lines, "Last Updated", last_updated, meta_end)
    status_value = (
        f"Promoted -> docs/features/active/{feature_path}/ (Issue #{issue_number})"
    )
    set_line_value(lines, "Status", status_value, meta_end)
    return lines
