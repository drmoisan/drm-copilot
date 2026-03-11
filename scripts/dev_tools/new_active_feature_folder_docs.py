"""Document update helpers for active feature folder creation."""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools.new_active_feature_folder_markdown import (
    format_checklist,
    prepend_to_section_body,
    set_header_placeholder,
    set_section,
    update_section_body,
)

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.new_active_feature_folder_models import FileSystem


def _apply_header_and_sections(
    path: Path,
    feature_name: str,
    issue_field: str,
    owner_field: str,
    updated_field: str,
    parent_field: str,
    status_field: str,
    version_field: str,
    fs: FileSystem,
    updates: list[tuple[str, str]],
) -> None:
    """Apply header metadata and optional section overrides to a doc file."""
    if not fs.exists(path):
        return
    content = fs.read_text(path)
    content = set_header_placeholder(
        content,
        feature_name,
        issue_field,
        owner_field,
        updated_field,
        status_field=status_field,
        parent_field=parent_field,
        version_field=version_field,
    )
    for section_name, body in updates:
        content = set_section(content, section_name, body)
    fs.write_text(path, content)


def update_feature_docs(
    feature_type: str,
    feature_name: str,
    target_dir: Path,
    issue_field: str,
    owner_field: str,
    updated_field: str,
    parent_field: str,
    status_field: str,
    version_field: str,
    plan_updated_field: str,
    fs: FileSystem,
    sections: dict[str, str],
    plan_path: Path | None = None,
) -> list[Path]:
    """Populate active docs with header metadata and seeded content."""
    files_to_open: list[Path] = []
    if feature_type == "feature":
        user_story = target_dir / "user-story.md"
        spec = target_dir / "spec.md"
        plan = plan_path or target_dir / "plan.md"
        _apply_header_and_sections(
            user_story,
            feature_name,
            issue_field,
            owner_field,
            updated_field,
            parent_field,
            status_field,
            version_field,
            fs,
            [
                ("Problem / Why", sections.get("problem", "")),
                ("Acceptance Criteria", format_checklist(sections.get("criteria", ""))),
            ],
        )
        _apply_header_and_sections(
            spec,
            feature_name,
            issue_field,
            owner_field,
            updated_field,
            parent_field,
            status_field,
            version_field,
            fs,
            [
                ("Overview", sections.get("problem", "")),
                ("Behavior", sections.get("behavior", "")),
                ("Constraints & Risks", sections.get("constraints", "")),
                (
                    "Seeded Test Conditions (from potential)",
                    format_checklist(sections.get("tests", "")),
                ),
            ],
        )
        _apply_header_and_sections(
            plan,
            feature_name,
            issue_field,
            owner_field,
            plan_updated_field,
            parent_field,
            status_field,
            version_field,
            fs,
            [],
        )
        files_to_open.extend([user_story, spec, plan])
    elif feature_type == "refactor":
        spec = target_dir / "spec.md"
        plan = plan_path or target_dir / "plan.md"
        _apply_header_and_sections(
            spec,
            feature_name,
            issue_field,
            owner_field,
            updated_field,
            parent_field,
            status_field,
            version_field,
            fs,
            [
                ("Intent & Outcomes", sections.get("problem", "")),
                ("Scope (structural changes)", sections.get("behavior", "")),
                ("Risks & Mitigations", sections.get("constraints", "")),
                (
                    "Seeded Test Conditions (from potential)",
                    format_checklist(sections.get("tests", "")),
                ),
            ],
        )
        _apply_header_and_sections(
            plan,
            feature_name,
            issue_field,
            owner_field,
            plan_updated_field,
            parent_field,
            status_field,
            version_field,
            fs,
            [],
        )
        files_to_open.extend([spec, plan])
    elif feature_type == "epic":
        initiative = target_dir / "initiative.md"
        _apply_header_and_sections(
            initiative,
            feature_name,
            issue_field,
            owner_field,
            updated_field,
            parent_field,
            status_field,
            version_field,
            fs,
            [],
        )
        files_to_open.append(initiative)
    elif feature_type == "bug":
        spec = target_dir / "spec.md"
        plan = plan_path or target_dir / "plan.md"

        context_parts: list[str] = []
        if sections.get("bug_summary"):
            context_parts.append(sections["bug_summary"])
        if sections.get("bug_environment"):
            context_parts.append(f"Environment:\n{sections['bug_environment']}")
        if sections.get("bug_impact"):
            context_parts.append(f"Impact / Severity:\n{sections['bug_impact']}")
        context_body = "\n\n".join(context_parts)

        repro_parts: list[str] = []
        if sections.get("bug_steps"):
            repro_parts.append(f"Steps to Reproduce:\n{sections['bug_steps']}")
        expected_actual: list[str] = []
        if sections.get("bug_expected"):
            expected_actual.append(f"Expected:\n{sections['bug_expected']}")
        if sections.get("bug_actual"):
            expected_actual.append(f"Actual:\n{sections['bug_actual']}")
        if expected_actual:
            repro_parts.append("\n\n".join(expected_actual))
        if sections.get("bug_logs"):
            repro_parts.append(f"Logs / Screenshots:\n{sections['bug_logs']}")
        repro_body = "\n\n".join(repro_parts)

        updates: list[tuple[str, str]] = []
        if context_body:
            updates.append(("Context", context_body))
        if repro_body:
            updates.append(("Repro & Evidence", repro_body))
        if sections.get("bug_cause"):
            updates.append(("Root Cause Analysis", sections["bug_cause"]))

        bug_validation = sections.get("bug_validation", "").strip()

        _apply_header_and_sections(
            spec,
            feature_name,
            issue_field,
            owner_field,
            updated_field,
            parent_field,
            status_field,
            version_field,
            fs,
            updates,
        )

        if bug_validation:
            spec_content = fs.read_text(spec)

            def update_test_strategy(body: str) -> str:
                return prepend_to_section_body(
                    body,
                    prefix=f"Seeded from issue:\n\n{bug_validation}",
                )

            spec_content, _ = update_section_body(
                spec_content,
                "Test Strategy",
                update_test_strategy,
            )
            fs.write_text(spec, spec_content)

        _apply_header_and_sections(
            plan,
            feature_name,
            issue_field,
            owner_field,
            plan_updated_field,
            parent_field,
            status_field,
            version_field,
            fs,
            [],
        )
        files_to_open.extend([spec, plan])

    return files_to_open


def should_use_minor_audit_mode(
    work_mode: str,
    feature_type: str,
    potential_content: str,
) -> tuple[bool, str]:
    """Return whether minor-audit path should be used and fallback reason."""
    del feature_type, potential_content
    if work_mode not in ("minor-audit", "full-feature", "full-bug", "full"):
        raise ValueError(
            "work_mode must be one of: minor-audit, full-feature, full-bug, full"
        )
    if work_mode != "minor-audit":
        return False, ""
    return True, ""
