"""Verify deterministic synchronization of packaged customization surfaces."""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools import synchronize_customization_bundles as subject

PROFILE_SUFFIXES = ("", "-c1", "-c2", "-c3", "-c3-elevated", "-c4")
CODEX_AGENT_FAMILIES: dict[str, subject.Family] = {
    "feature-reviewer": "reviewer",
    "orchestrator": "orchestrator",
    "task-researcher": "researcher",
}
CODEX_SKILLS: dict[str, subject.Family] = {
    ".agents/skills/feature-review/SKILL.md": "reviewer",
    ".agents/skills/feature-review-workflow/SKILL.md": "reviewer",
    ".agents/skills/remediation-handoff-atomic-planner/SKILL.md": "reviewer",
    ".agents/skills/orchestrate/SKILL.md": "orchestrator",
    ".agents/skills/orchestrator-workflow/SKILL.md": "orchestrator",
    ".agents/skills/research-issue/SKILL.md": "researcher",
}
GITHUB_SURFACES: dict[str, subject.Family] = {
    ".github/agents/feature-review.agent.md": "reviewer",
    ".github/prompts/review-feature.prompt.md": "reviewer",
    ".github/skills/feature-review-workflow/SKILL.md": "reviewer",
    ".github/skills/remediation-handoff-atomic-planner/SKILL.md": "reviewer",
    ".github/agents/orchestrator.agent.md": "orchestrator",
    ".github/agents/python-orchestrator.agent.md": "orchestrator",
    ".github/agents/powershell-orchestrator.agent.md": "orchestrator",
    ".github/agents/csharp-orchestrator.agent.md": "orchestrator",
    ".github/prompts/orchestrate-work.prompt.md": "orchestrator",
    ".github/prompts/orchestrate-python-work.prompt.md": "orchestrator",
    ".github/prompts/orchestrate-powershell-work.prompt.md": "orchestrator",
    ".github/prompts/orchestrate-csharp-work.prompt.md": "orchestrator",
    ".github/agents/task-researcher.agent.md": "researcher",
    ".github/prompts/research-issue.prompt.md": "researcher",
}
CLAUDE_SURFACES: dict[str, subject.Family] = {
    ".claude/agents/feature-review.md": "reviewer",
    ".claude/skills/feature-review-workflow/SKILL.md": "reviewer",
    ".claude/skills/remediation-handoff-atomic-planner/SKILL.md": "reviewer",
    ".claude/agents/orchestrator.md": "orchestrator",
    ".claude/skills/orchestrate/SKILL.md": "orchestrator",
    ".claude/rules/orchestrator-state.md": "orchestrator",
    ".claude/agents/task-researcher.md": "researcher",
    ".claude/skills/research-issue/SKILL.md": "researcher",
}


def _expected_mapping_contract() -> set[tuple[Path, Path, subject.Family]]:
    """Build the independent P5-T8 source-to-destination inventory."""

    mappings: set[tuple[Path, Path, subject.Family]] = {
        (
            Path(".codex/agents/feature-review.toml"),
            subject.CODEX_BUNDLE_ROOT / ".codex/agents/feature-review.toml",
            "reviewer",
        )
    }
    for name, family in CODEX_AGENT_FAMILIES.items():
        for suffix in PROFILE_SUFFIXES:
            source = Path(f".codex/agents/{name}{suffix}.toml")
            mappings.add((source, subject.CODEX_BUNDLE_ROOT / source, family))
    for path_text, family in CODEX_SKILLS.items():
        source = Path(path_text)
        mappings.add((source, subject.CODEX_BUNDLE_ROOT / source, family))
    for path_text, family in GITHUB_SURFACES.items():
        source = Path(path_text)
        mappings.add(
            (
                source,
                subject.GITHUB_BUNDLE_ROOT / source.relative_to(".github"),
                family,
            )
        )
    for path_text, family in CLAUDE_SURFACES.items():
        source = Path(path_text)
        mappings.add(
            (
                source,
                subject.CLAUDE_BUNDLE_ROOT / source.relative_to(".claude"),
                family,
            )
        )
    mappings.add(
        (
            Path("config/orchestration-routing.json"),
            subject.ROUTING_BUNDLE_ROOT / "orchestration-routing.json",
            "routing",
        )
    )
    return mappings


def _bundle_family_text(
    files: dict[Path, bytes], root: Path, family: subject.Family
) -> str:
    """Combine one semantic family's mapped text within one packaged runtime."""

    return "\n".join(
        files[mapping.destination].decode("utf-8")
        for mapping in subject.MAPPINGS
        if mapping.family == family and root in mapping.destination.parents
    )


def _assert_stale_after_replacement(old: bytes, new: bytes, path: Path) -> None:
    """Require a semantic byte replacement to be reported as package drift."""

    expected = {path: old}
    errors = subject.compare_bundle_files({path: new}, expected)

    assert len(errors) == 1
    assert errors[0].startswith(f"Packaged customization is stale: {path}")
    assert "actual sha256:" in errors[0]
    assert "expected sha256:" in errors[0]


def test_declares_every_exact_reviewer_and_orchestrator_mapping() -> None:
    """Keep the complete 48-entry mapping inventory exact."""

    actual = {
        (mapping.source, mapping.destination, mapping.family)
        for mapping in subject.MAPPINGS
    }

    assert actual == _expected_mapping_contract()
    assert len(actual) == 48
    assert sum(mapping.family == "reviewer" for mapping in subject.MAPPINGS) == 17
    assert sum(mapping.family == "orchestrator" for mapping in subject.MAPPINGS) == 19
    assert sum(mapping.family == "researcher" for mapping in subject.MAPPINGS) == 11


def test_expected_bundle_files_copy_exact_deterministic_source_bytes() -> None:
    """Copy every mapped source byte-for-byte with stable repeated results."""

    first = subject.expected_bundle_files()
    second = subject.expected_bundle_files()

    assert first == second
    assert len(first) == 48
    for mapping in subject.MAPPINGS:
        assert first[mapping.destination] == subject.read_source(mapping.source)


def test_mapping_inventory_rejects_missing_and_extra_entries() -> None:
    """Fail closed when any required mapping is removed or invented."""

    with pytest.raises(ValueError, match="Missing source-to-bundle mapping"):
        subject.validate_mapping_inventory(subject.MAPPINGS[:-1])

    extra = subject.BundleMapping(
        Path("unexpected/source.md"),
        subject.CODEX_BUNDLE_ROOT / "unexpected/destination.md",
        "reviewer",
    )
    with pytest.raises(ValueError, match="Unexpected source-to-bundle mapping"):
        subject.validate_mapping_inventory((*subject.MAPPINGS, extra))


def test_comparison_rejects_missing_extra_and_digest_divergent_files() -> None:
    """Report every bundle inventory and deterministic-byte failure mode."""

    first_path, second_path = tuple(subject.expected_bundle_files())[:2]
    expected = {first_path: b"first", second_path: b"second"}
    extra_path = Path("extensions/drm-copilot/resources/unexpected.md")
    actual = {first_path: b"changed", extra_path: b"extra"}

    errors = subject.compare_bundle_files(actual, expected)

    assert any("is missing" in error and str(second_path) in error for error in errors)
    assert any("Unexpected" in error and str(extra_path) in error for error in errors)
    assert any("is stale" in error and str(first_path) in error for error in errors)


def test_exception_gate_and_loop_limit_divergence_are_digest_failures() -> None:
    """Reject package bytes that weaken the canonical remediation transition rules."""

    files = subject.expected_bundle_files()
    path = subject.GITHUB_BUNDLE_ROOT / "agents/orchestrator.agent.md"
    original = files[path]
    exception_divergence = original.replace(
        b"one exact unused exception", b"any matching exception", 1
    )
    limit_divergence = original.replace(
        b"blocked_remediation_loop_limit", b"blocked_cycle_limit", 1
    )

    assert exception_divergence != original
    assert limit_divergence != original
    _assert_stale_after_replacement(original, exception_divergence, path)
    _assert_stale_after_replacement(original, limit_divergence, path)


def test_binary_only_review_status_is_rejected_in_any_packaged_file() -> None:
    """Reject the retired REVIEW_STATUS decision path before package writes."""

    files = subject.expected_bundle_files()
    path = subject.GITHUB_BUNDLE_ROOT / "agents/feature-review.agent.md"
    invalid = dict(files)
    invalid[path] += b"\nREVIEW_STATUS: PASS\n"

    with pytest.raises(ValueError, match="binary-only REVIEW_STATUS"):
        subject.validate_bundle_semantics(invalid, subject.MAPPINGS)


@pytest.mark.parametrize(
    "root",
    (
        subject.CODEX_BUNDLE_ROOT,
        subject.GITHUB_BUNDLE_ROOT,
        subject.CLAUDE_BUNDLE_ROOT,
    ),
)
def test_each_packaged_orchestrator_family_has_single_use_exception_rules(
    root: Path,
) -> None:
    """Require exception-free stagnation, atomic consumption, and reuse rejection."""

    text = _bundle_family_text(subject.expected_bundle_files(), root, "orchestrator")

    for token in (
        "blocked_stagnation",
        "one exact unused exception",
        "consumed_at` and `consumed_by_attempt_id` are both null before use",
        "atomically set `consumed_at`",
        "can never authorize another transition",
    ):
        assert token in text


@pytest.mark.parametrize(
    "root",
    (
        subject.CODEX_BUNDLE_ROOT,
        subject.GITHUB_BUNDLE_ROOT,
        subject.CLAUDE_BUNDLE_ROOT,
    ),
)
def test_external_human_and_ci_outcomes_cannot_trigger_remediation(
    root: Path,
) -> None:
    """Permit planner handoff only for an actionable autonomous disposition."""

    text = _bundle_family_text(subject.expected_bundle_files(), root, "orchestrator")

    for action in ("EXTERNAL_RUNTIME", "AWAITING_CI", "HUMAN_DECISION"):
        assert f"| `BLOCKED` | `{action}` | `NONE` | `NONE` |" in text
    assert (
        "Only `REVIEW_VERDICT: BLOCKED` plus `REMEDIATION_ACTION: AUTONOMOUS`" in text
    )
    assert (
        "permits remediation artifact creation and `atomic-planner` delegation" in text
    )


@pytest.mark.parametrize(
    "root",
    (
        subject.CODEX_BUNDLE_ROOT,
        subject.GITHUB_BUNDLE_ROOT,
        subject.CLAUDE_BUNDLE_ROOT,
    ),
)
def test_each_packaged_family_uses_only_the_canonical_three_cycle_terminal(
    root: Path,
) -> None:
    """Retain the canonical terminal enum and explicit legacy-enum rejection."""

    text = _bundle_family_text(subject.expected_bundle_files(), root, "orchestrator")

    assert "transitions only to `blocked_remediation_loop_limit`" in text
    assert "`blocked_cycle_limit` is rejected legacy input" in text


@pytest.mark.parametrize(
    "root",
    (
        subject.CODEX_BUNDLE_ROOT,
        subject.GITHUB_BUNDLE_ROOT,
        subject.CLAUDE_BUNDLE_ROOT,
    ),
)
def test_each_packaged_reviewer_family_preserves_no_delta_terminal_handling(
    root: Path,
) -> None:
    """Keep the accepted no-candidate result terminal before remediation."""

    text = _bundle_family_text(subject.expected_bundle_files(), root, "reviewer")

    assert "`BLOCKED` | `NO_CANDIDATE` | `NONE` | `NONE`" in text
    assert "no-delta disposition; do not delegate `atomic-planner`" in text
    assert "REVIEW_STATUS:" not in text
