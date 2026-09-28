"""Tests for checked-in Codex agent deployment-profile generation."""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools import generate_codex_agent_variants as generator
from scripts.dev_tools.generate_codex_agent_variants import (
    BUNDLE_ROOT,
    CORE_FAMILIES,
    PACK_FAMILIES,
    PACK_ROOT,
    PROFILES,
    REPO_ROOT,
    expected_variant_files,
    main,
    render_agent_variant,
    render_base_alias,
    render_manifest,
)
from scripts.dev_tools.resolve_codex_deployment import GENERATED_AGENT_FAMILIES


def test_expected_inventory_contains_five_profiles_per_agent_family() -> None:
    """Generate C1, C2, C3, elevated C3, and C4 for every family."""

    expected = expected_variant_files()

    assert len(expected) == len(GENERATED_AGENT_FAMILIES) * len(PROFILES)


def test_render_variant_replaces_only_top_level_profile_fields() -> None:
    """Preserve persona instructions while changing identity and deployment."""

    base = (
        'name = "atomic-executor"\n'
        'description = "Executor"\n'
        'model = "old"\n'
        'model_reasoning_effort = "low"\n'
        "developer_instructions = '''\n"
        'model = "instruction example"\n'
        "'''\n"
    )

    rendered = render_agent_variant(base, "atomic-executor", PROFILES[-1])

    assert 'name = "atomic-executor-c4"' in rendered
    assert 'model = "gpt-5.6-sol"' in rendered
    assert 'model_reasoning_effort = "max"' in rendered
    assert 'model = "instruction example"' in rendered
    assert 'model = "old"' not in rendered


@pytest.mark.parametrize(
    ("base", "expected_message"),
    [
        (
            'name = "wrong-agent"\ndescription = "Executor"\n',
            'Canonical agent does not declare name = "atomic-executor".',
        ),
        (
            'name = "atomic-executor"\n',
            "Canonical agent 'atomic-executor' has no description field.",
        ),
    ],
)
def test_render_variant_rejects_invalid_canonical_agents(
    base: str, expected_message: str
) -> None:
    """Reject source agents whose identity or description cannot be preserved."""

    with pytest.raises(ValueError, match=expected_message):
        render_agent_variant(base, "atomic-executor", PROFILES[0])


def test_render_base_alias_pins_default_c3_profile_without_renaming() -> None:
    """Keep compatibility agent names while pinning Terra/high explicitly."""

    base = 'name = "atomic-executor"\ndescription = "Executor"\n'

    rendered = render_base_alias(base, "atomic-executor")

    assert 'name = "atomic-executor"' in rendered
    assert 'model = "gpt-5.6-terra"' in rendered
    assert 'model_reasoning_effort = "high"' in rendered


def test_checked_in_variants_match_generator_output_in_both_surfaces() -> None:
    """Require repo-root and bundled variants to equal deterministic output."""

    for relative_path, expected_text in expected_variant_files().items():
        expected_bytes = expected_text.encode("utf-8")
        assert (REPO_ROOT / relative_path).read_bytes() == expected_bytes
        assert (BUNDLE_ROOT / relative_path).read_bytes() == expected_bytes


def test_commit_steward_is_a_core_family_with_complete_generated_profiles() -> None:
    """Keep commit-steward aliases, profiles, and core manifest synchronized."""

    assert "commit-steward" in CORE_FAMILIES
    expected = expected_variant_files()
    base_path = Path(".codex") / "agents" / "commit-steward.toml"
    assert (REPO_ROOT / base_path).read_bytes() == (
        BUNDLE_ROOT / base_path
    ).read_bytes()
    manifest = (PACK_ROOT / "core.json").read_text(encoding="utf-8")
    assert str(base_path).replace("\\", "/") in manifest
    for profile in PROFILES:
        path = generator.generated_agent_relative_path("commit-steward", profile)
        assert (REPO_ROOT / path).read_bytes() == expected[path].encode("utf-8")
        assert (BUNDLE_ROOT / path).read_bytes() == expected[path].encode("utf-8")
        assert str(path).replace("\\", "/") in manifest


def test_affected_pack_manifests_include_each_generated_profile() -> None:
    """Make every generated agent deployable through its applicable pack."""

    for manifest_name, families in PACK_FAMILIES.items():
        manifest_text = (PACK_ROOT / manifest_name).read_text(encoding="utf-8")
        for family in families:
            for profile in PROFILES:
                expected_path = (
                    Path(".codex") / "agents" / f"{family}-{profile.suffix}.toml"
                )
                assert str(expected_path).replace("\\", "/") in manifest_text


class StubManifestPath:
    """Provide manifest text without creating a temporary test file."""

    def __init__(self, text: str) -> None:
        self._text = text

    def read_text(self, *, encoding: str) -> str:
        """Return the configured JSON document using the requested encoding."""

        assert encoding == "utf-8"
        return self._text

    def __str__(self) -> str:
        """Return a stable diagnostic path."""

        return "stub-manifest.json"


@pytest.mark.parametrize(
    "document",
    [
        "[]",
        json.dumps({"paths": "not-an-array"}),
        json.dumps({"paths": [1]}),
    ],
)
def test_render_manifest_rejects_invalid_path_documents(document: str) -> None:
    """Reject non-object manifests and non-string path arrays."""

    path = cast("Path", StubManifestPath(document))

    with pytest.raises(ValueError, match="Pack manifest"):
        render_manifest(path, ("atomic-executor",))


def test_render_manifest_adds_missing_base_and_generated_profiles() -> None:
    """Add every required family path without mutating a filesystem fixture."""

    path = cast("Path", StubManifestPath(json.dumps({"paths": []})))

    rendered = json.loads(render_manifest(path, ("atomic-executor",)))

    assert ".codex/agents/atomic-executor.toml" in rendered["paths"]
    for profile in PROFILES:
        assert (
            f".codex/agents/atomic-executor-{profile.suffix}.toml" in rendered["paths"]
        )


def test_generator_check_mode_reports_no_drift() -> None:
    """Keep checked-in profiles and manifests synchronized with the generator."""

    assert main(["--check"]) == 0


def test_generator_main_reports_each_synchronization_error(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Return failure and emit every deterministic drift message."""

    def synchronize_with_drift(*, check: bool) -> list[str]:
        """Return deterministic errors only for check mode."""

        return ["first drift", "second drift"] if check else []

    monkeypatch.setattr(
        generator,
        "_synchronize",
        synchronize_with_drift,
    )

    assert main(["--check"]) == 1
    assert capsys.readouterr().err.splitlines() == ["first drift", "second drift"]
