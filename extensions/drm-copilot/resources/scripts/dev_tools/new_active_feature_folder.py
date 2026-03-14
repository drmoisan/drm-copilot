"""Create an active feature folder from templates and optional potential files."""

from __future__ import annotations

from dev_tools.new_active_feature_folder_docs import (
    should_use_minor_audit_mode,
    update_feature_docs,
)
from dev_tools.new_active_feature_folder_flow import (
    create_active_folder,
    main,
    parse_args,
)
from dev_tools.new_active_feature_folder_io import (
    build_folder_slug,
    copy_feature_template_for_minor_audit,
    copy_template,
    default_code_launcher,
    default_issue_fetcher,
    find_potential_file,
    materialize_plan_file,
    parse_issue_number,
)
from dev_tools.new_active_feature_folder_markdown import (
    format_checklist,
    get_section,
    set_header_placeholder,
    set_section,
    upsert_work_mode_marker,
)
from dev_tools.new_active_feature_folder_models import (
    EXCLUDED_POTENTIAL_NAMES,
    NAME_PATTERN,
    PLACEHOLDERS,
    PLAN_TIMESTAMP_TEMPLATE_NAME,
    ActiveFolderResult,
    FileSystem,
    IssueMeta,
    RealFileSystem,
    extract_date_from_timestamp,
    resolve_workspace,
    validate_feature_name,
)

__all__ = [
    "ActiveFolderResult",
    "EXCLUDED_POTENTIAL_NAMES",
    "FileSystem",
    "IssueMeta",
    "NAME_PATTERN",
    "PLACEHOLDERS",
    "PLAN_TIMESTAMP_TEMPLATE_NAME",
    "RealFileSystem",
    "build_folder_slug",
    "copy_feature_template_for_minor_audit",
    "copy_template",
    "create_active_folder",
    "default_code_launcher",
    "default_issue_fetcher",
    "extract_date_from_timestamp",
    "find_potential_file",
    "format_checklist",
    "get_section",
    "main",
    "materialize_plan_file",
    "parse_args",
    "parse_issue_number",
    "resolve_workspace",
    "set_header_placeholder",
    "set_section",
    "should_use_minor_audit_mode",
    "update_feature_docs",
    "upsert_work_mode_marker",
    "validate_feature_name",
]


if __name__ == "__main__":
    main()
