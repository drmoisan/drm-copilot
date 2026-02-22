"""Orchestration and CLI flow for active feature folder creation."""

from __future__ import annotations

import argparse
from typing import TYPE_CHECKING

from scripts.dev_tools.new_active_feature_folder_docs import (
    should_use_minor_audit_mode,
    update_feature_docs,
)
from scripts.dev_tools.new_active_feature_folder_io import (
    build_folder_slug,
    copy_feature_template_for_minor_audit,
    copy_template,
    default_code_launcher,
    default_issue_fetcher,
    find_potential_file,
    materialize_plan_file,
    parse_issue_number,
)
from scripts.dev_tools.new_active_feature_folder_markdown import (
    get_section,
    upsert_work_mode_marker,
)
from scripts.dev_tools.new_active_feature_folder_models import (
    ActiveFolderResult,
    FileSystem,
    IssueMeta,
    RealFileSystem,
    get_est_timestamp,
    resolve_workspace,
    validate_feature_name,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable
    from datetime import datetime
    from pathlib import Path


def create_active_folder(
    feature_name: str,
    feature_type: str = "feature",
    issue_number: str | None = None,
    force: bool = False,
    *,
    workspace: Path | None = None,
    fs: FileSystem | None = None,
    issue_fetcher: Callable[[str], IssueMeta | None] = default_issue_fetcher,
    code_launcher: Callable[[Iterable[Path]], bool] = default_code_launcher,
    now_provider: Callable[[], datetime] | None = None,
    work_mode: str = "full",
) -> ActiveFolderResult:
    """Create and seed an active feature folder from templates and potential docs."""
    if feature_type not in {"feature", "refactor", "epic", "bug"}:
        raise ValueError("Type must be one of: feature, refactor, epic, bug")

    validate_feature_name(feature_name)
    workspace_path = workspace or resolve_workspace()
    filesystem = fs or RealFileSystem()

    template_dir = workspace_path / "docs" / "features" / "templates" / feature_type
    if not filesystem.exists(template_dir):
        raise FileNotFoundError(f"Template folder not found: {template_dir}")

    potential_file = find_potential_file(feature_name, workspace_path, filesystem)
    potential_content = filesystem.read_text(potential_file) if potential_file else ""
    use_minor_audit, fallback_reason = should_use_minor_audit_mode(
        work_mode=work_mode,
        feature_type=feature_type,
        potential_content=potential_content,
    )

    normalized_issue_number = (issue_number or "").strip() or None
    if normalized_issue_number and normalized_issue_number.lower() == "auto":
        normalized_issue_number = None
    if not normalized_issue_number:
        normalized_issue_number = parse_issue_number(potential_content)

    folder_slug = build_folder_slug(
        feature_name,
        potential_file,
        normalized_issue_number,
    )
    target_dir = workspace_path / "docs" / "features" / "active" / folder_slug

    if filesystem.exists(target_dir) and not force:
        raise FileExistsError(
            f"Target exists: {target_dir}. Re-run with --force to overwrite."
        )

    filesystem.ensure_dir(target_dir)
    if feature_type == "feature" and use_minor_audit:
        copy_feature_template_for_minor_audit(template_dir, target_dir, filesystem)
    else:
        copy_template(feature_type, template_dir, target_dir, filesystem)

    issue_meta = None
    if normalized_issue_number:
        issue_meta = issue_fetcher(normalized_issue_number)
    issue_field = f"#{normalized_issue_number}" if normalized_issue_number else "TBD"
    if issue_meta:
        issue_field = f"#{issue_meta.number}"
    owner_field = issue_meta.author if issue_meta else "TBD"
    parent_field = "none"
    status_field = "Draft"
    version_field = "0.1"

    plan_timestamp = get_est_timestamp(now_provider)
    updated_field = plan_timestamp
    plan_path = materialize_plan_file(
        feature_type=feature_type,
        target_dir=target_dir,
        feature_name=feature_name,
        issue_field=issue_field,
        owner_field=owner_field,
        parent_field=parent_field,
        status_field=status_field,
        version_field=version_field,
        plan_timestamp=plan_timestamp,
        fs=filesystem,
    )

    plan_updated_field = plan_timestamp

    sections: dict[str, str] = {
        "problem": get_section(potential_content, "Problem / Why"),
        "behavior": get_section(potential_content, "Proposed Behavior"),
        "criteria": get_section(potential_content, "Acceptance Criteria (early draft)"),
        "constraints": get_section(potential_content, "Constraints & Risks"),
        "tests": get_section(potential_content, "Test Conditions to Consider"),
        "bug_summary": get_section(potential_content, "Summary"),
        "bug_environment": get_section(potential_content, "Environment"),
        "bug_steps": get_section(potential_content, "Steps to Reproduce"),
        "bug_expected": get_section(potential_content, "Expected Behavior"),
        "bug_actual": get_section(potential_content, "Actual Behavior"),
        "bug_logs": get_section(potential_content, "Logs / Screenshots"),
        "bug_impact": get_section(potential_content, "Impact / Severity"),
        "bug_cause": get_section(potential_content, "Suspected Cause / Notes"),
        "bug_validation": get_section(
            potential_content,
            "Proposed Fix / Validation Ideas",
        ),
    }

    files_to_open: list[Path]
    potential_issue_path: Path | None = None
    if use_minor_audit:
        if potential_file:
            potential_issue_path = target_dir / "issue.md"
            filesystem.move(potential_file, potential_issue_path)
            moved_content = filesystem.read_text(potential_issue_path)
            filesystem.write_text(
                potential_issue_path,
                upsert_work_mode_marker(moved_content, "minor-audit"),
            )
            files_to_open = [potential_issue_path]
        else:
            issue_doc = target_dir / "issue.md"
            issue_body = "\n".join(
                [
                    f"# {feature_name}",
                    "",
                    "- Work Mode: minor-audit",
                    "## Problem / Why",
                    sections["problem"] or "(not provided in potential file)",
                    "",
                    "## Implementation Intent",
                    sections["behavior"] or "(not provided in potential file)",
                    "",
                    "## Acceptance Criteria",
                    sections["criteria"] or "(not provided in potential file)",
                    "",
                    "## Dependencies / Risks",
                    sections["constraints"] or "(not provided in potential file)",
                    "",
                    "## Verification Steps",
                    sections["tests"] or "(not provided in potential file)",
                    "",
                    "## Evidence Checklist",
                    "- [ ] baseline",
                    "- [ ] targeted verification",
                    "- [ ] end-state",
                ]
            )
            filesystem.write_text(issue_doc, issue_body)
            files_to_open = [issue_doc]
    else:
        files_to_open = update_feature_docs(
            feature_type,
            feature_name,
            target_dir,
            issue_field,
            owner_field,
            updated_field,
            parent_field,
            status_field,
            version_field,
            plan_updated_field,
            filesystem,
            sections,
            plan_path=plan_path,
        )

    if potential_file:
        if use_minor_audit:
            if potential_issue_path is not None:
                print(f"Moved potential file to {potential_issue_path}")
        else:
            potential_issue_path = target_dir / "issue.md"
            filesystem.move(potential_file, potential_issue_path)
            if work_mode == "minor-audit" and fallback_reason:
                moved_content = filesystem.read_text(potential_issue_path)
                filesystem.write_text(
                    potential_issue_path,
                    upsert_work_mode_marker(moved_content, "full"),
                )
            print(f"Moved potential file to {potential_issue_path}")

    if potential_file:
        print(f"Seeded docs from potential: {potential_file.name}")

    print(f"Selected mode: {'minor-audit' if use_minor_audit else 'full'}")
    if fallback_reason:
        print(f"Fallback reason: {fallback_reason}")

    if files_to_open:
        existing = [path for path in files_to_open if filesystem.exists(path)]
        if potential_issue_path:
            existing.append(potential_issue_path)
        if existing:
            opened = code_launcher(existing)
            if not opened:
                print("VS Code 'code' command not found. Files to edit:")
                for path in existing:
                    print(f"  {path}")

    print(f"Created/updated: {target_dir}")
    return ActiveFolderResult(
        target=target_dir,
        potential_issue_path=potential_issue_path,
    )


def parse_args() -> argparse.Namespace:
    """Parse CLI arguments for active-folder creation."""
    parser = argparse.ArgumentParser(
        description="Create docs/features/active/<name>/ from the selected template."
    )
    parser.add_argument(
        "--feature-name",
        required=True,
        help="Feature folder name (kebab/underscore)",
    )
    parser.add_argument(
        "--type",
        dest="feature_type",
        choices=["feature", "refactor", "epic", "bug"],
        default="feature",
        help="Type of folder to create",
    )
    parser.add_argument(
        "--issue-number",
        dest="issue_number",
        default=None,
        help="Issue number or 'auto'",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite existing target",
    )
    parser.add_argument(
        "--work-mode",
        choices=["minor-audit", "full"],
        default="full",
        help="Work mode routing for minor-audit vs full feature flow.",
    )
    return parser.parse_args()


def main() -> None:
    """CLI entry point for active-folder creation script."""
    args = parse_args()
    try:
        create_active_folder(
            feature_name=args.feature_name,
            feature_type=args.feature_type,
            issue_number=args.issue_number,
            force=args.force,
            work_mode=args.work_mode,
        )
    except (ValueError, FileExistsError) as exc:
        print(str(exc))
        raise SystemExit(1) from exc
    except FileNotFoundError as exc:
        print(f"Aborted: required file not found: {exc}")
        raise SystemExit(1) from exc
