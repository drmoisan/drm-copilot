"""Durable parity guard for the bundled orchestration validator mirror.

Purpose:
    Guarantee that the bundled extension copies of the orchestration validator
    modules remain a faithful mirror of their canonical `scripts/dev_tools/`
    sources, differing only by the statement-anchored import-path rewrite, and
    that the bundled dispatcher loaded through the extension import path
    reproduces the repo-source validation behavior.

Usage:
    Run via pytest. The parity test reads each source module, applies the
    single in-test rewrite rule, and asserts byte-level equality against the
    bundled copy. The behavioral tests load the bundled dispatcher from its
    file path and exercise the checkpoint validator contract.

Flow:
    1. Apply `_apply_bundle_rewrite` to each source module text.
    2. Assert the transformed text equals the bundled module text exactly.
    3. Load the bundled dispatcher and assert accept/reject behavior on
       in-memory checkpoint fixtures.

Invariants / Constraints:
    - The rewrite rule is defined once here and targets only import statements.
    - No temporary files are created; all fixtures are in-memory JSON strings.
    - `sys.path` and `sys.modules` are restored after each bundled load.

Side Effects:
    Reads source and bundled module files from disk for comparison and import.
"""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING, Any

import pytest

if TYPE_CHECKING:
    from types import ModuleType

REPO_ROOT = Path(__file__).resolve().parents[3]
SOURCE_SCRIPTS_DIR = REPO_ROOT / "scripts" / "dev_tools"
BUNDLED_SCRIPTS_DIR = REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "scripts"
BUNDLED_DEV_TOOLS_DIR = BUNDLED_SCRIPTS_DIR / "dev_tools"

# The five modules that compose the bundled validator mirror.
MODULE_NAMES = (
    "validate_orchestration_artifacts.py",
    "validate_orchestrator_state.py",
    "_orchestrator_state_human_interaction.py",
    "validate_orchestration_review_artifacts.py",
    "validate_policy_audit_artifact.py",
)

# The `dev_tools.*` module names that the bundled dispatcher pulls in; these are
# popped from `sys.modules` before and after a bundled load so the canonical
# `scripts.dev_tools.*` package and the bundled package never collide.
_BUNDLED_MODULE_NAMES = (
    "dev_tools",
    "dev_tools.validate_orchestration_artifacts",
    "dev_tools.validate_orchestrator_state",
    "dev_tools._orchestrator_state_human_interaction",
    "dev_tools.validate_orchestration_review_artifacts",
    "dev_tools.validate_policy_audit_artifact",
)


def _apply_bundle_rewrite(text: str) -> str:
    """Apply the statement-anchored bundle import-path rewrite.

    Purpose:
        Implement the single source of truth for the bundle rewrite rule used
        by the parity test: rewrite only import statements that reference the
        canonical `scripts.dev_tools.` package prefix to the bundled
        `dev_tools.` prefix, leaving docstring prose and comments untouched.

    Args:
        text (str): Full source-module text to transform.

    Returns:
        str: The transformed text with import statements rewritten.

    Raises:
        None.

    Side Effects:
        None.
    """

    rewritten_lines: list[str] = []
    # Walk each line and rewrite only lines whose leading token is a `from ` or
    # `import ` keyword referencing the canonical package prefix. Docstring and
    # comment lines that merely contain the substring are left unchanged.
    for line in text.splitlines(keepends=True):
        if line.startswith("from scripts.dev_tools."):
            rewritten_lines.append(
                line.replace("from scripts.dev_tools.", "from dev_tools.", 1)
            )
        elif line.startswith("import scripts.dev_tools."):
            rewritten_lines.append(
                line.replace("import scripts.dev_tools.", "import dev_tools.", 1)
            )
        else:
            rewritten_lines.append(line)
    return "".join(rewritten_lines)


@pytest.mark.parametrize("module_name", MODULE_NAMES)
def test_bundled_module_matches_rewritten_source(module_name: str) -> None:
    """Assert each bundled module equals its rewritten source exactly.

    Purpose:
        Detect any source-to-bundle divergence so CI fails on drift between the
        canonical validator and its bundled mirror.

    Args:
        module_name (str): File name of the module under comparison.

    Returns:
        None.

    Raises:
        AssertionError: When the bundled text differs from the rewritten source.

    Side Effects:
        Reads source and bundled module files from disk.
    """

    # Arrange: read the canonical source and apply the rewrite rule.
    source_text = (SOURCE_SCRIPTS_DIR / module_name).read_text(encoding="utf-8")
    expected_bundle_text = _apply_bundle_rewrite(source_text)

    # Act: read the bundled mirror copy.
    bundle_text = (BUNDLED_DEV_TOOLS_DIR / module_name).read_text(encoding="utf-8")

    # Assert: the bundle must equal the rewritten source byte-for-byte.
    assert bundle_text == expected_bundle_text, (
        f"Bundled {module_name} diverges from rewritten source; "
        "resync the bundle from scripts/dev_tools."
    )


def _load_bundled_dispatcher() -> ModuleType:
    """Load the bundled orchestration dispatcher via its file path.

    Purpose:
        Import `dev_tools.validate_orchestration_artifacts` from the bundled
        scripts directory exactly as the MCP wrapper does, so behavioral tests
        exercise the bundled code path rather than the canonical source.

    Args:
        None.

    Returns:
        ModuleType: The loaded bundled dispatcher module.

    Raises:
        ImportError: When the bundled module spec cannot be created or executed.

    Side Effects:
        Temporarily inserts the bundled scripts dir at `sys.path[0]` and mutates
        `sys.modules`; both are restored in the caller's `finally` block.
    """

    spec = importlib.util.spec_from_file_location(
        "dev_tools.validate_orchestration_artifacts",
        BUNDLED_DEV_TOOLS_DIR / "validate_orchestration_artifacts.py",
    )
    if spec is None or spec.loader is None:
        raise ImportError("Unable to create spec for bundled dispatcher.")
    module = importlib.util.module_from_spec(spec)
    sys.modules["dev_tools.validate_orchestration_artifacts"] = module
    spec.loader.exec_module(module)
    return module


def _call_bundled_state_validator(
    checkpoint: dict[str, Any], *, require_complete: bool = False
) -> list[str]:
    """Load the bundled dispatcher and validate a checkpoint dict.

    Purpose:
        Provide a single helper that loads the bundled validator with isolated
        `sys.path`/`sys.modules` state, serializes the in-memory checkpoint to
        JSON, and returns the validator's error list.

    Args:
        checkpoint (dict[str, Any]): In-memory checkpoint object to validate.
        require_complete (bool): Forwarded to the bundled validator's
            completion gate.

    Returns:
        list[str]: Validation errors returned by the bundled validator.

    Raises:
        ImportError: Propagated from `_load_bundled_dispatcher` on load failure.

    Side Effects:
        Inserts the bundled scripts dir at `sys.path[0]` for the duration of the
        load and restores `sys.path` and `sys.modules` before returning.
    """

    original_sys_path = list(sys.path)
    # Preserve any pre-existing bundled module objects so the canonical package
    # state is restored after the bundled load.
    saved_modules = {
        name: sys.modules.pop(name)
        for name in _BUNDLED_MODULE_NAMES
        if name in sys.modules
    }
    sys.path.insert(0, str(BUNDLED_SCRIPTS_DIR))
    try:
        module = _load_bundled_dispatcher()
        errors = module.validate_orchestrator_state_text(
            json.dumps(checkpoint), require_complete=require_complete
        )
        return list(errors)
    finally:
        sys.path[:] = original_sys_path
        # Drop any bundled modules loaded during this call, then restore the
        # originals so global module state is unchanged after the test.
        for name in _BUNDLED_MODULE_NAMES:
            sys.modules.pop(name, None)
        sys.modules.update(saved_modules)


def _base_checkpoint() -> dict[str, Any]:
    """Build a minimal valid orchestrator-state checkpoint dict.

    Purpose:
        Provide a checkpoint that contains every required top-level key so tests
        can layer specific fields (statuses, receipts, blocks) without tripping
        unrelated missing-key errors.

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


def test_bundled_validator_accepts_completed_step_status() -> None:
    """Assert the bundled validator accepts `completed` step statuses.

    Purpose:
        Regression for Bug 1: the stale monolith rejected the `completed`
        lifecycle status; the resync'd bundle must accept it.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: When the validator reports any error.

    Side Effects:
        Loads the bundled dispatcher from disk.
    """

    # Arrange: a checkpoint whose tracked steps use the `completed` status.
    checkpoint = _base_checkpoint()
    checkpoint["step5_status"] = "completed"
    checkpoint["step6_status"] = "completed"

    # Act: validate through the bundled code path.
    errors = _call_bundled_state_validator(checkpoint)

    # Assert: the resync'd bundle accepts the completed status.
    assert errors == []


def test_bundled_validator_accepts_namespaced_delegation_receipts() -> None:
    """Assert the bundled validator accepts the promotion receipt namespace.

    Purpose:
        Regression for Bug 2: the stale monolith rejected the object-form
        `delegation_receipts.promotion.*` namespace.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: When the validator reports any error.

    Side Effects:
        Loads the bundled dispatcher from disk.
    """

    # Arrange: object-form delegation receipts using only the promotion key.
    checkpoint = _base_checkpoint()
    checkpoint["delegation_receipts"] = {
        "promotion": {
            "potential_entry": "p",
            "issue": "196",
            "feature_folder": "docs/features/active/x",
        }
    }

    # Act: validate through the bundled code path.
    errors = _call_bundled_state_validator(checkpoint)

    # Assert: the resync'd bundle accepts the namespaced receipts.
    assert errors == []


def test_bundled_validator_accepts_human_interaction_and_remediation_loop() -> None:
    """Assert acceptance of valid human_interaction and remediation_loop blocks.

    Purpose:
        Regression for Bug 3: the stale monolith lacked the additive
        human_interaction and remediation_loop validation paths.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: When the validator reports any error.

    Side Effects:
        Loads the bundled dispatcher from disk.
    """

    # Arrange: a checkpoint with a valid human_interaction block and a single
    # well-formed remediation cycle.
    checkpoint = _base_checkpoint()
    checkpoint["human_interaction"] = {
        "requirements": [
            {"response": "scope_change"},
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

    # Act: validate through the bundled code path.
    errors = _call_bundled_state_validator(checkpoint)

    # Assert: the resync'd bundle accepts both additive blocks.
    assert errors == []


def test_bundled_validator_rejects_unknown_promotion_namespace_key() -> None:
    """Assert the bundled validator rejects an unsupported namespace key.

    Purpose:
        Negative-path coverage: an unsupported key alongside `promotion` in the
        object-form receipts must produce an error.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: When the validator does not flag the unsupported key.

    Side Effects:
        Loads the bundled dispatcher from disk.
    """

    # Arrange: object-form receipts containing an unsupported sibling key.
    checkpoint = _base_checkpoint()
    checkpoint["delegation_receipts"] = {
        "promotion": {
            "potential_entry": "p",
            "issue": "196",
            "feature_folder": "docs/features/active/x",
        },
        "extra": {"unexpected": True},
    }

    # Act: validate through the bundled code path.
    errors = _call_bundled_state_validator(checkpoint)

    # Assert: the unsupported-key diagnostic is present.
    assert errors
    assert any("unsupported key: extra" in error for error in errors)
