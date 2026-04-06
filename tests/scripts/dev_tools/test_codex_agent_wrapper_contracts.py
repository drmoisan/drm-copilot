"""Regression tests for Codex agent-wrapper parity against GitHub sources."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 content for a repository contract file."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def assert_contains_all(text: str, fragments: tuple[str, ...]) -> None:
    """Require every fragment to appear in the target text."""

    for fragment in fragments:
        assert fragment in text


def test_atomic_planner_wrapper_preserves_github_preflight_handoff_contract() -> None:
    """Require Codex planner wrapper to preserve GitHub preflight semantics."""

    github_text = read_repo_text(".github/agents/atomic_planning.agent.md")
    codex_text = read_repo_text(".codex/agents/atomic-planner.toml")

    assert_contains_all(
        github_text,
        (
            "label: Preflight validate plan (atomic_executor)",
            "DIRECTIVE: PREFLIGHT VALIDATION ONLY",
            "PREFLIGHT: ALL CLEAR or PREFLIGHT: REVISIONS REQUIRED",
            "precise plan delta (exact edits)",
            "MUST NOT create additional timestamped sibling files",
        ),
    )
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
        ),
    )


def test_atomic_executor_wrapper_preserves_github_preflight_return_handoff() -> None:
    """Require Codex executor wrapper to preserve planner-return handoff rules."""

    github_text = read_repo_text(".github/agents/atomic_executor.agent.md")
    codex_text = read_repo_text(".codex/agents/atomic-executor.toml")

    assert_contains_all(
        github_text,
        (
            "DIRECTIVE: PREFLIGHT VALIDATION ONLY",
            "Validation-only required output:",
            "Include a precise **plan delta** that `atomic_planner` can apply",
            "Automatically hand off back to `atomic_planner` requesting it "
            "apply the delta",
            "Continue this validate → delta → planner-revise → validate loop "
            "until you can return",
        ),
    )
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
        ),
    )


def test_feature_reviewer_wrapper_preserves_github_remediation_handoff() -> None:
    """Require Codex reviewer wrapper to preserve automatic remediation handoff."""

    github_text = read_repo_text(".github/agents/feature-review.agent.md")
    codex_text = read_repo_text(".codex/agents/feature-reviewer.toml")

    assert_contains_all(
        github_text,
        (
            "label: Create remediation plan (atomic_planner)",
            "`${spec}`: `<FEATURE_FOLDER>/remediation-inputs.<timestamp>.md` "
            "(PRIMARY requirements source)",
            "The delegated prompt MUST inline the full text (verbatim) of:",
            "Use the provided handoff “Create remediation plan " "(atomic_planner)”.",
            "If remediation is needed: confirm the atomic_planner "
            "delegation occurred",
        ),
    )
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
        ),
    )


def test_orchestrator_wrapper_preserves_github_mandatory_delegation_contract() -> None:
    """Require Codex orchestrator wrapper to preserve GitHub delegation gates."""

    github_text = read_repo_text(".github/agents/orchestrator.agent.md")
    codex_text = read_repo_text(".codex/agents/orchestrator.toml")

    assert_contains_all(
        github_text,
        (
            "agent: atomic_planner",
            "agent: atomic_executor",
            "agent: feature_code_review_agent",
            "Do not mark Step 4 complete until delegate output includes "
            "both a concrete `plan-path` and final `PREFLIGHT: ALL CLEAR`.",
            "Do not mark Step 6 complete until expected review artifacts "
            "are present on disk in `${feature-folder}`.",
            "all required delegations completed",
        ),
    )
    assert_contains_all(
        codex_text,
        (
            "If `atomic-planner` is available, you must delegate planning " "to it;",
            "If `atomic-executor` is available, you must delegate plan "
            "preflight validation, execution, and post-delivery validation "
            "to it;",
            "If `feature-reviewer` is available, you must delegate "
            "post-implementation review to it;",
            "Do not treat a delegated step as complete until the delegate "
            "returns the required output contract for that step and the "
            "required on-disk artifacts exist.",
            "Do not claim mission completion unless all required "
            "delegations completed",
            "Do not accept PASS outcomes that rely on stale PR-context " "artifacts",
        ),
    )
