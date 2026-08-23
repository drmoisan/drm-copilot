"""Verify deterministic orchestration customization-surface generation."""

from __future__ import annotations

import hashlib
from pathlib import Path

import pytest

from scripts.dev_tools import generate_orchestration_customization_surfaces as subject

REVIEWER_TARGETS = frozenset(
    {
        Path(".codex/agents/feature-review.toml"),
        Path(".github/agents/feature-review.agent.md"),
        Path(".github/prompts/review-feature.prompt.md"),
        Path(".github/skills/feature-review-workflow/SKILL.md"),
        Path(".github/skills/remediation-handoff-atomic-planner/SKILL.md"),
        Path(".claude/agents/feature-review.md"),
        Path(".claude/skills/feature-review-workflow/SKILL.md"),
        Path(".claude/skills/remediation-handoff-atomic-planner/SKILL.md"),
    }
)
ORCHESTRATOR_TARGETS = frozenset(
    {
        Path(".github/agents/orchestrator.agent.md"),
        Path(".github/prompts/orchestrate-work.prompt.md"),
        Path(".github/prompts/orchestrate-python-work.prompt.md"),
        Path(".github/prompts/orchestrate-powershell-work.prompt.md"),
        Path(".github/prompts/orchestrate-csharp-work.prompt.md"),
        Path(".claude/agents/orchestrator.md"),
        Path(".claude/skills/orchestrate/SKILL.md"),
        Path(".claude/rules/orchestrator-state.md"),
    }
)
RESEARCHER_TARGETS = frozenset(
    {
        Path(".github/agents/task-researcher.agent.md"),
        Path(".github/prompts/research-issue.prompt.md"),
        Path(".claude/agents/task-researcher.md"),
        Path(".claude/skills/research-issue/SKILL.md"),
    }
)


def _digest(path: Path) -> str:
    """Return the digest rendered by the production generator."""

    text = subject.read_source(path)
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def _no_extra_targets(_paths: set[Path]) -> list[Path]:
    """Return an empty generated-target drift set."""

    return []


def _missing_file(_path: Path) -> bool:
    """Represent a missing virtual path."""

    return False


def _existing_file(_path: Path) -> bool:
    """Represent an existing virtual path."""

    return True


def _stale_text(
    _path: Path, encoding: str | None = None, errors: str | None = None
) -> str:
    """Return stale virtual file content."""

    return "stale"


def _expected_text(
    _path: Path, encoding: str | None = None, errors: str | None = None
) -> str:
    """Return current virtual file content."""

    return "expected"


def test_declares_only_the_exact_planned_target_inventory() -> None:
    """Keep the generated surface inventory identical to P5-T4."""

    targets_by_family = {
        family: frozenset(
            surface.path for surface in subject.SURFACES if surface.family == family
        )
        for family in ("reviewer", "orchestrator", "researcher")
    }

    assert targets_by_family == {
        "reviewer": REVIEWER_TARGETS,
        "orchestrator": ORCHESTRATOR_TARGETS,
        "researcher": RESEARCHER_TARGETS,
    }
    assert len(subject.SURFACES) == 20
    assert len({surface.path for surface in subject.SURFACES}) == 20


def test_every_reviewer_target_is_driven_by_all_three_canonical_inputs() -> None:
    """Require each reviewer surface to carry all canonical source identities."""

    outputs = subject.expected_outputs()

    for target in REVIEWER_TARGETS:
        generated = outputs[target]
        for source in subject.REVIEWER_SOURCES:
            assert f"`{source.as_posix()}`" in generated
            assert f"sha256:{_digest(source)}" in generated
        assert "REVIEW_VERDICT: PASS | BLOCKED" in generated
        assert "REMEDIATION_ACTION: NONE | AUTONOMOUS" in generated
        assert "Only `BLOCKED` plus `AUTONOMOUS`" in generated
        assert "no actionable repository candidate" in generated


def test_every_orchestrator_target_delegates_to_the_single_use_exception_gate() -> None:
    """Keep stagnation, exception consumption, and loop limits canonical."""

    outputs = subject.expected_outputs()

    for target in ORCHESTRATOR_TARGETS:
        generated = outputs[target]
        for source in subject.ORCHESTRATOR_SOURCES:
            assert f"`{source.as_posix()}`" in generated
            assert f"sha256:{_digest(source)}" in generated
        assert "Canonical Post-R4 Fingerprint and Exception Gate" in generated
        assert "one exact unused exception" in generated
        assert "atomically set `consumed_at`" in generated
        assert "can never authorize another transition" in generated
        assert "no exact unused valid exception" in generated
        assert "blocked_remediation_loop_limit" in generated
        assert "`blocked_cycle_limit` is rejected legacy input" in generated
        assert (
            "Only `REVIEW_VERDICT: BLOCKED` plus `REMEDIATION_ACTION: AUTONOMOUS`"
            in generated
        )


def test_researcher_targets_use_only_tracked_research_roots() -> None:
    """Propagate the feature-local and one-off tracked research destinations."""

    outputs = subject.expected_outputs()

    for target in RESEARCHER_TARGETS:
        generated = outputs[target]
        for source in subject.ORCHESTRATOR_SOURCES:
            assert f"`{source.as_posix()}`" in generated
            assert f"sha256:{_digest(source)}" in generated
        assert "<feature-folder>/research/" in generated
        assert "docs/research/" in generated
        assert "artifacts/research/" not in generated


def test_generated_outputs_reject_binary_review_status_paths() -> None:
    """Exclude the retired binary-only review decision contract everywhere."""

    outputs = subject.expected_outputs()

    assert all("REVIEW_STATUS:" not in generated for generated in outputs.values())


def test_semantically_divergent_output_fails_closed() -> None:
    """Reject a target that replaces the canonical review verdict grammar."""

    outputs = subject.expected_outputs()
    target = next(iter(REVIEWER_TARGETS))
    outputs[target] = outputs[target].replace(
        "REVIEW_VERDICT: PASS | BLOCKED",
        "REVIEW_STATUS: PASS | REMEDIATION_REQUIRED",
        1,
    )

    with pytest.raises(ValueError, match="Binary-only review status"):
        subject.validate_outputs(outputs)


def test_check_mode_reports_a_missing_target(monkeypatch: pytest.MonkeyPatch) -> None:
    """Report a declared target that is absent without creating files."""

    target = Path("generated/missing.md")
    monkeypatch.setattr(subject, "expected_outputs", lambda: {target: "expected"})
    monkeypatch.setattr(subject, "find_extra_generated_targets", _no_extra_targets)
    monkeypatch.setattr(Path, "is_file", _missing_file)

    assert subject.synchronize(check=True) == [
        "Generated orchestration surface is missing: generated/missing.md"
    ]


def test_check_mode_reports_a_stale_target(monkeypatch: pytest.MonkeyPatch) -> None:
    """Report byte drift in a declared target without using temporary files."""

    target = Path("generated/stale.md")
    monkeypatch.setattr(subject, "expected_outputs", lambda: {target: "expected"})
    monkeypatch.setattr(subject, "find_extra_generated_targets", _no_extra_targets)
    monkeypatch.setattr(Path, "is_file", _existing_file)
    monkeypatch.setattr(Path, "read_text", _stale_text)

    assert subject.synchronize(check=True) == [
        "Generated orchestration surface is stale: generated/stale.md"
    ]


def test_check_mode_reports_an_extra_target(monkeypatch: pytest.MonkeyPatch) -> None:
    """Reject a marked generated target outside the declared exact inventory."""

    target = Path("generated/current.md")
    extra = Path("generated/extra.md")

    def extra_targets(_paths: set[Path]) -> list[Path]:
        return [extra]

    monkeypatch.setattr(subject, "expected_outputs", lambda: {target: "expected"})
    monkeypatch.setattr(subject, "find_extra_generated_targets", extra_targets)
    monkeypatch.setattr(Path, "is_file", _existing_file)
    monkeypatch.setattr(Path, "read_text", _expected_text)

    assert subject.synchronize(check=True) == [
        "Unexpected generated orchestration surface: generated/extra.md"
    ]


def test_extra_target_scan_ignores_embedded_codex_variant_markers() -> None:
    """Ignore generated-source markers embedded inside Codex variant payloads."""

    extras = subject.find_extra_generated_targets(set(subject.expected_outputs()))

    assert not [path for path in extras if path.stem.startswith("task-researcher")]


def test_loop_limit_enum_matches_spec_and_both_runtimes() -> None:
    """Use one executable loop-limit enum and retain only explicit legacy rejection."""

    spec = Path(
        "docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/spec.md"
    ).read_text(encoding="utf-8")
    python_runtime = Path(
        "scripts/dev_tools/_orchestrator_state_remediation_transitions.py"
    ).read_text(encoding="utf-8")
    typescript_runtime = Path(
        "extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation-transitions.ts"
    ).read_text(encoding="utf-8")

    assert "`blocked_cycle_limit` is rejected legacy input only" in spec
    for runtime in (python_runtime, typescript_runtime):
        assert "blocked_remediation_loop_limit" in runtime
        assert "blocked_cycle_limit" not in runtime


def test_expected_outputs_are_deterministic() -> None:
    """Render identical bytes for repeated reads of unchanged canonical inputs."""

    assert subject.expected_outputs() == subject.expected_outputs()
