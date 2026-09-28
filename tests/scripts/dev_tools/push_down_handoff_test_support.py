"""Shared assertions for portable handoff publishing tests."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from pathlib import Path

HANDOFF_OPERATIONS = {
    "validate_orchestration_artifacts",
    "resolve_orchestration_topology",
    "resolve_provider_routing",
    "transition_prepared_orchestration",
}


def assert_installed_consumer_authority(
    repo_root: Path,
    bundled_root: Path,
    skill_path: Path,
) -> None:
    """Require published semantic tools with TypeScript-only runtime authority."""

    registry_path = bundled_root.parent / "config/orchestration-handoff-registry.json"
    registry = cast(
        "dict[str, object]",
        json.loads(registry_path.read_text(encoding="utf-8")),
    )
    semantic_tools = cast("dict[str, object]", registry["semantic_tools"])
    operations = {
        cast("dict[str, str]", entry)["operation"] for entry in semantic_tools.values()
    }
    skill = (bundled_root / skill_path).read_text(encoding="utf-8")
    handler_path = (
        repo_root
        / "extensions"
        / "drm-copilot"
        / "src"
        / "mcp-handlers"
        / "orchestration-handoff-handlers.ts"
    )
    handler = handler_path.read_text(encoding="utf-8")

    assert HANDOFF_OPERATIONS <= operations
    assert "transition_prepared_orchestration" in skill
    assert "scripts.dev_tools" not in handler
    assert "scripts/dev_tools" not in handler


INDEPENDENT_CONTEXT_KEYS = (
    "expected_repository_id",
    "expected_workspace_root",
    "expected_branch",
    "expected_source_head_sha",
    "allowed_head_relationship",
    "expected_issue_number",
    "expected_feature_folder",
    "expected_work_mode",
    "expected_plan_path",
    "expected_plan_sha256",
)

CONTEXT_BOUND_OPERATIONS = (
    "resolve_orchestration_topology",
    "resolve_provider_routing",
    "transition_prepared_orchestration",
)


def assert_independent_context_guidance(
    repo_root: Path,
    bundled_root: Path,
    guidance_paths: tuple[Path, ...],
) -> None:
    """Require published guidance to demand caller-supplied expected context.

    Source and bundled guidance must instruct callers to supply the complete
    independent expected context to every context-bound handoff operation. The
    envelope under validation must never be the source of the values it is
    validated against, so guidance that describes proving a handoff from the
    envelope alone is a publication-contract failure.
    """

    for relative_path in guidance_paths:
        for label, root in (("source", repo_root), ("bundled", bundled_root)):
            path = root / relative_path
            assert path.is_file(), f"Missing {label} guidance: {relative_path}"
            text = path.read_text(encoding="utf-8")
            for operation in CONTEXT_BOUND_OPERATIONS:
                assert operation in text, (
                    f"{label} guidance {relative_path} does not name the "
                    f"context-bound operation {operation}"
                )
            for key in INDEPENDENT_CONTEXT_KEYS:
                assert key in text, (
                    f"{label} guidance {relative_path} does not require the "
                    f"independent expected-context key {key}"
                )
