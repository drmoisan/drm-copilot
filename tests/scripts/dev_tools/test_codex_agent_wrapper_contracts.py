"""Regression tests for Codex agent-wrapper contracts."""

from __future__ import annotations

from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]

pytestmark = pytest.mark.skipif(
    not (REPO_ROOT / ".codex" / "agents").exists(),
    reason=".codex/agents is gitignored and unavailable in CI",
)
BUNDLED_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 content for a repository contract file."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def read_bundle_text(relative_path: str) -> str:
    """Return UTF-8 content for a bundled Codex contract file."""

    return (BUNDLED_ROOT / relative_path).read_text(encoding="utf-8")


def assert_contains_all(text: str, fragments: tuple[str, ...]) -> None:
    """Require every fragment to appear in the target text."""

    for fragment in fragments:
        assert fragment in text


def test_atomic_planner_wrapper_preserves_codex_preflight_handoff_contract() -> None:
    """Require the Codex planner wrapper to preserve strict preflight semantics."""

    root_text = read_repo_text(".codex/agents/atomic-planner.toml")
    codex_text = read_bundle_text(".codex/agents/atomic-planner.toml")

    assert_contains_all(
        codex_text,
        (
            "explicitly spawn the `atomic-executor` subagent",
            "The delegated prompt MUST include the exact directive "
            "`DIRECTIVE: PREFLIGHT VALIDATION ONLY`.",
            "`PREFLIGHT: ALL CLEAR`",
            "`PREFLIGHT: REVISIONS REQUIRED`",
            "Treat executor preflight findings as binding plan defects",
            "Reuse the same target plan file for every preflight revision "
            "iteration in the same planning cycle.",
            "stop and report blocked state",
            "validate_orchestration_artifacts` MCP tool",
        ),
    )
    assert root_text == codex_text


def test_atomic_executor_wrapper_preserves_codex_preflight_return_handoff() -> None:
    """Require the Codex executor wrapper to preserve planner-return handoff rules."""

    root_text = read_repo_text(".codex/agents/atomic-executor.toml")
    codex_text = read_bundle_text(".codex/agents/atomic-executor.toml")

    assert_contains_all(
        codex_text,
        (
            "perform validation only and return exactly one of "
            "`PREFLIGHT: ALL CLEAR` or `PREFLIGHT: REVISIONS REQUIRED`",
            "include a precise plan delta that can be applied to the same " "plan file",
            "automatically hand off back to `atomic-planner` and request "
            "that it apply the delta to the same plan file",
            "Continue the validate -> delta -> planner-revise -> validate "
            "loop until preflight can return `PREFLIGHT: ALL CLEAR`.",
            "stop and report blocked state",
            "validate_orchestration_artifacts` MCP tool",
        ),
    )
    assert root_text == codex_text


def test_feature_reviewer_wrapper_preserves_codex_remediation_handoff() -> None:
    """Require the Codex reviewer wrapper to preserve automatic remediation handoff."""

    root_text = read_repo_text(".codex/agents/feature-reviewer.toml")
    codex_text = read_bundle_text(".codex/agents/feature-reviewer.toml")

    assert_contains_all(
        codex_text,
        (
            "Then automatically delegate remediation planning to the "
            "atomic-planner agent",
            "Create the remediation plan target file on disk before the "
            "planning handoff.",
            "Remediation planning must treat remediation-inputs as the "
            "primary requirements source.",
            "The delegated remediation context package must include "
            "remediation inputs, canonical PR-context artifacts, review "
            "artifacts, and the original feature plan file(s).",
            "Do not claim completion when remediation is triggered unless "
            "the remediation plan file exists on disk.",
            "pass their validators",
            "stop and report blocked state",
        ),
    )
    assert root_text == codex_text


def test_orchestrator_wrapper_preserves_codex_mandatory_delegation_contract() -> None:
    """Require the Codex orchestrator wrapper to preserve delegation gates."""

    root_text = read_repo_text(".codex/agents/orchestrator.toml")
    codex_text = read_bundle_text(".codex/agents/orchestrator.toml")

    assert_contains_all(
        codex_text,
        (
            "Treat `spawn_agent` availability as the mechanical availability " "signal",
            "you must delegate or stop execution",
            "do not perform planning locally",
            "do not perform preflight validation, execution, or post-delivery "
            "validation locally",
            "do not perform post-implementation review locally",
            "Do not treat a delegated step as complete until the delegate "
            "returns the required output contract for that step and the "
            "required on-disk artifacts exist.",
            "Do not claim mission completion unless all required "
            "delegations completed with receipts",
            "Do not accept PASS outcomes that rely on stale PR-context " "artifacts",
            "Do not rename, back up, or create sidecar checkpoint files",
            "Do not persist placeholder lifecycle values such as `NONE`, `TBD`",
        ),
    )
    assert root_text == codex_text
