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
