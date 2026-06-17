"""MCP-path functional acceptance for the bundled orchestration validator.

Purpose:
    Verify that the bundled MCP wrapper template and the bundled validator it
    delegates to load and operate through the documented bundle import
    mechanism, accepting checkpoints the repo-source validator accepts and
    rejecting a known-bad checkpoint.

Usage:
    Run via pytest. Tests load the bundled wrapper template and the bundled
    `dev_tools.validate_orchestration_artifacts` module from their file paths
    with the bundled scripts directory inserted at `sys.path[0]`, and restore
    `sys.path`/`sys.modules` afterward.

Flow:
    1. Insert the bundled scripts dir at `sys.path[0]`.
    2. Load the wrapper template and the bundled dispatcher by file path.
    3. Exercise the validator contract on in-memory checkpoint fixtures.

Invariants / Constraints:
    - No temporary files are created; fixtures are in-memory JSON strings.
    - `sys.path` and `sys.modules` are restored in a `finally` block.

Side Effects:
    Reads bundled module files from disk and imports them in-process.
"""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from types import ModuleType

ROOT = Path(__file__).resolve().parents[5]
BUNDLED_SCRIPTS_DIR = ROOT / "extensions" / "drm-copilot" / "resources" / "scripts"
BUNDLED_DEV_TOOLS_DIR = BUNDLED_SCRIPTS_DIR / "dev_tools"
WRAPPER_TEMPLATE_PATH = (
    ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "templates"
    / "validate_orchestration_artifacts.py"
)

# The bundled `dev_tools.*` module names cleared from `sys.modules` before and
# after a bundled load so the canonical package and the bundled package never
# collide during the test run.
_BUNDLED_MODULE_NAMES = (
    "dev_tools",
    "dev_tools.validate_orchestration_artifacts",
    "dev_tools.validate_orchestrator_state",
    "dev_tools._orchestrator_state_human_interaction",
    "dev_tools.validate_orchestration_review_artifacts",
    "dev_tools.validate_policy_audit_artifact",
)
_WRAPPER_MODULE_NAME = "_bundled_wrapper_validate_orchestration_artifacts"


def _load_module_from_path(module_name: str, path: Path) -> ModuleType:
    """Load a module object from an explicit file path.

    Purpose:
        Centralize the `importlib.util.spec_from_file_location` load used by the
        wrapper and dispatcher tests.

    Args:
        module_name (str): Name to register the loaded module under.
        path (Path): File path of the module to load.

    Returns:
        ModuleType: The loaded module object.

    Raises:
        ImportError: When the module spec cannot be created or executed.

    Side Effects:
        Registers the module in `sys.modules` under ``module_name``.
    """

    spec = importlib.util.spec_from_file_location(module_name, path)
    if spec is None or spec.loader is None:
        raise ImportError(f"Unable to create spec for {path}.")
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


def _base_checkpoint() -> dict[str, Any]:
    """Build a minimal valid orchestrator-state checkpoint dict.

    Purpose:
        Provide a checkpoint with every required top-level key so a test can add
        specific fields without tripping unrelated missing-key errors.

    Args:
        None.

    Returns:
        dict[str, Any]: A checkpoint dict satisfying all required state keys.

    Raises:
        None.

    Side Effects:
        None.
    """

    return {
        "objective": "resync bundled validator",
        "change_budget_estimate": "small",
        "path_selected": "short",
        "promotion-type": "bug",
        "short-name": "resync-bundled-validator",
        "relativeFile": "docs/features/active/x/issue.md",
        "long-name": "Resync bundled orchestration validator",
        "issue-num": "196",
        "feature-folder": "docs/features/active/x",
        "work-mode": "full-bug",
        "plan-path": "docs/features/active/x/plan.md",
        "completed_steps": [],
        "next_step": "step5",
        "last_updated": "2026-06-17T19-05",
        "step5_status": "not_started",
        "step6_status": "not_started",
        "step7_status": "not_started",
        "step8_status": "not_started",
        "step9_status": "not_started",
        "step10_status": "not_started",
        "delegation_receipts": [],
        "blocked_reason": "none",
    }


def test_imports_bundled_module() -> None:
    """Assert the wrapper template loads and exposes a ``main`` entrypoint.

    Purpose:
        Confirm the wrapper template imports cleanly through the bundle path,
        transitively exercising the four new bundled dependency imports.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: When the loaded wrapper has no ``main`` attribute.

    Side Effects:
        Loads the wrapper template and bundled modules from disk.
    """

    original_sys_path = list(sys.path)
    saved_modules = {
        name: sys.modules.pop(name)
        for name in (*_BUNDLED_MODULE_NAMES, _WRAPPER_MODULE_NAME)
        if name in sys.modules
    }
    sys.path.insert(0, str(BUNDLED_SCRIPTS_DIR))
    try:
        # Act: load the wrapper template module by file path.
        wrapper = _load_module_from_path(_WRAPPER_MODULE_NAME, WRAPPER_TEMPLATE_PATH)

        # Assert: the wrapper exposes the stable CLI entrypoint.
        assert hasattr(wrapper, "main")
    finally:
        sys.path[:] = original_sys_path
        for name in (*_BUNDLED_MODULE_NAMES, _WRAPPER_MODULE_NAME):
            sys.modules.pop(name, None)
        sys.modules.update(saved_modules)


def test_ensure_path_adds_scripts_dir_to_sys_path() -> None:
    """Assert the wrapper prepends the bundled scripts dir to ``sys.path``.

    Purpose:
        Confirm `_ensure_bundled_scripts_import_path` makes the bundled
        ``resources/scripts`` directory importable.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: When the bundled scripts dir is not on ``sys.path``.

    Side Effects:
        Loads the wrapper template and mutates ``sys.path`` during the call.
    """

    original_sys_path = list(sys.path)
    saved_modules = {
        name: sys.modules.pop(name)
        for name in (*_BUNDLED_MODULE_NAMES, _WRAPPER_MODULE_NAME)
        if name in sys.modules
    }
    try:
        # Arrange: load the wrapper and ensure the scripts dir is absent first.
        wrapper = _load_module_from_path(_WRAPPER_MODULE_NAME, WRAPPER_TEMPLATE_PATH)
        scripts_dir = WRAPPER_TEMPLATE_PATH.resolve().parent.parent / "scripts"
        sys.path[:] = [p for p in sys.path if p != str(scripts_dir)]

        # Act: invoke the import-path helper.
        wrapper._ensure_bundled_scripts_import_path()

        # Assert: the bundled scripts dir is now at the front of sys.path.
        assert sys.path[0] == str(scripts_dir)
    finally:
        sys.path[:] = original_sys_path
        for name in (*_BUNDLED_MODULE_NAMES, _WRAPPER_MODULE_NAME):
            sys.modules.pop(name, None)
        sys.modules.update(saved_modules)


def _call_bundled_state_validator(checkpoint: dict[str, Any]) -> list[str]:
    """Load the bundled dispatcher and validate a checkpoint dict.

    Purpose:
        Load `dev_tools.validate_orchestration_artifacts` from the bundled file
        path with isolated import state and return the validator error list for
        the serialized checkpoint.

    Args:
        checkpoint (dict[str, Any]): In-memory checkpoint object to validate.

    Returns:
        list[str]: Validation errors returned by the bundled validator.

    Raises:
        ImportError: When the bundled dispatcher cannot be loaded.

    Side Effects:
        Inserts the bundled scripts dir at ``sys.path[0]`` and restores
        ``sys.path`` and ``sys.modules`` before returning.
    """

    original_sys_path = list(sys.path)
    saved_modules = {
        name: sys.modules.pop(name)
        for name in _BUNDLED_MODULE_NAMES
        if name in sys.modules
    }
    sys.path.insert(0, str(BUNDLED_SCRIPTS_DIR))
    try:
        module = _load_module_from_path(
            "dev_tools.validate_orchestration_artifacts",
            BUNDLED_DEV_TOOLS_DIR / "validate_orchestration_artifacts.py",
        )
        errors = module.validate_orchestrator_state_text(json.dumps(checkpoint))
        return list(errors)
    finally:
        sys.path[:] = original_sys_path
        for name in _BUNDLED_MODULE_NAMES:
            sys.modules.pop(name, None)
        sys.modules.update(saved_modules)


def test_bundled_validator_accepts_previously_failing_checkpoint() -> None:
    """Assert acceptance of a checkpoint the stale monolith would reject.

    Purpose:
        Exercise, through the bundled MCP import path, a checkpoint that
        simultaneously uses `completed` step statuses, the
        `delegation_receipts.promotion.*` namespace, a `human_interaction`
        block, and a `remediation_loop`.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: When the bundled validator reports any error.

    Side Effects:
        Loads the bundled dispatcher from disk.
    """

    # Arrange: a checkpoint combining all four previously-failing features.
    checkpoint = _base_checkpoint()
    checkpoint["step5_status"] = "completed"
    checkpoint["step6_status"] = "completed"
    checkpoint["delegation_receipts"] = {
        "promotion": {
            "potential_entry": "p",
            "issue": "196",
            "feature_folder": "docs/features/active/x",
        }
    }
    checkpoint["human_interaction"] = {
        "requirements": [
            {"response": "halt"},
            {"response": "exception", "runbook_path": "docs/runbook.md"},
        ]
    }
    checkpoint["remediation_loop"] = {
        "cycles": [
            {
                "plan_path": "docs/features/active/x/plan.md",
                "exit_condition_met": True,
                "blocking_count": 0,
                "execution_status": "complete",
                "preflight": {"final_status": "clear"},
            }
        ]
    }

    # Act: validate through the bundled MCP import path.
    errors = _call_bundled_state_validator(checkpoint)

    # Assert: the resync'd bundle accepts the checkpoint with no errors.
    assert errors == []


def test_bundled_validator_rejects_unknown_promotion_key() -> None:
    """Assert rejection of an unsupported promotion-namespace key.

    Purpose:
        Negative-path coverage through the bundled MCP import path: an
        unsupported nested key under `promotion` must produce an error.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: When the bundled validator does not flag the bad key.

    Side Effects:
        Loads the bundled dispatcher from disk.
    """

    # Arrange: a promotion namespace carrying an unsupported nested key.
    checkpoint = _base_checkpoint()
    checkpoint["delegation_receipts"] = {
        "promotion": {
            "potential_entry": "p",
            "issue": "196",
            "feature_folder": "docs/features/active/x",
            "unexpected_key": "bad",
        }
    }

    # Act: validate through the bundled MCP import path.
    errors = _call_bundled_state_validator(checkpoint)

    # Assert: the unsupported nested key is rejected.
    assert errors
    assert any("unsupported key: unexpected_key" in error for error in errors)
