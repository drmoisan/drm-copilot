"""Parity tests for bundled hard-lock prompt resolver behavior."""

from __future__ import annotations

import importlib
import importlib.util
import sys
from pathlib import Path
from typing import TYPE_CHECKING, Protocol, cast

if TYPE_CHECKING:
    from types import ModuleType

REPO_ROOT = Path(__file__).resolve().parents[3]
ROOT_RESOLVER_MODULE = "scripts.dev_tools.resolve_hard_lock_prompt"
BUNDLED_RESOLVER_PATH = REPO_ROOT / (
    "extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py"
)
BUNDLED_SCRIPTS_ROOT = REPO_ROOT / "extensions/drm-copilot/resources/scripts"
PLAN_FIXTURE_PATH = REPO_ROOT / (
    "docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/"
    "remediation-plan.2026-04-18T18-50.md"
)


class HardLockPromptModule(Protocol):
    """Represent the prompt resolver operation used by parity tests."""

    def resolve_prompt(
        self,
        template_content: str,
        target_path: Path,
        workspace_root: Path,
        *,
        work_mode: str | None = None,
        fallback_reason: str | None = None,
    ) -> str:
        """Resolve the supplied template content for a target plan path."""
        ...


def _load_module_from_path(module_name: str, file_path: Path) -> ModuleType:
    """Load a checked-in Python module from an explicit file path."""
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    if spec is None or spec.loader is None:
        raise AssertionError(f"Unable to load module spec for {file_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules.pop(module_name, None)
    spec.loader.exec_module(module)
    return module


def _as_hard_lock_prompt_module(module: ModuleType) -> HardLockPromptModule:
    """Return a typed view over a dynamically loaded hard-lock prompt module."""
    if not hasattr(module, "resolve_prompt"):
        raise AssertionError("Module does not expose resolve_prompt")
    return cast(HardLockPromptModule, module)


def _restore_modules(preserved_modules: dict[str, ModuleType | None]) -> None:
    """Restore module entries changed while importing bundled resources."""
    for module_name, module in preserved_modules.items():
        if module is None:
            sys.modules.pop(module_name, None)
            continue
        sys.modules[module_name] = module


def test_bundled_resolve_hard_lock_prompt_matches_root_resolved_prompt() -> None:
    """Compare root and bundled prompt resolver output for the same plan fixture."""
    root_module = _as_hard_lock_prompt_module(
        importlib.import_module(ROOT_RESOLVER_MODULE)
    )
    template_content = (
        "Plan=${plan-path}\nMode=${work-mode}\nReason=${fallback-reason}\n"
    )
    preserved_sys_path = list(sys.path)
    preserved_modules = {
        "bundled_resolve_hard_lock_prompt_parity": sys.modules.get(
            "bundled_resolve_hard_lock_prompt_parity"
        ),
        "dev_tools": sys.modules.get("dev_tools"),
        "dev_tools.prompt_mode_contract": sys.modules.get(
            "dev_tools.prompt_mode_contract"
        ),
    }

    try:
        if str(BUNDLED_SCRIPTS_ROOT) not in sys.path:
            sys.path.insert(0, str(BUNDLED_SCRIPTS_ROOT))
        bundled_module = _as_hard_lock_prompt_module(
            _load_module_from_path(
                "bundled_resolve_hard_lock_prompt_parity",
                BUNDLED_RESOLVER_PATH,
            )
        )

        assert bundled_module.resolve_prompt(
            template_content,
            PLAN_FIXTURE_PATH,
            REPO_ROOT,
        ) == root_module.resolve_prompt(
            template_content,
            PLAN_FIXTURE_PATH,
            REPO_ROOT,
        )
    finally:
        sys.path[:] = preserved_sys_path
        _restore_modules(preserved_modules)
