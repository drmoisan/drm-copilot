"""Verify ordered, tag-authorized MCP package release transitions."""

from __future__ import annotations

import re
from pathlib import Path

import pytest

RELEASE_STATES = ("SOURCE_READY", "BUILT", "TESTED", "PUBLISHED", "PINNED")
RELEASE_TRANSITIONS: dict[str, str] = dict(
    zip(RELEASE_STATES, RELEASE_STATES[1:], strict=False)
)
AUTHORIZED_TAG_PATTERN = re.compile(r"mcp-server-v.+\Z")
WORKFLOW_PATH = Path(".github/workflows/publish-mcp-npm.yml")


def _assert_release_transition(
    previous: str,
    current: str,
    *,
    tag_name: str | None = None,
    target_version: str | None = None,
    published_version: str | None = None,
) -> None:
    """Reject invalid release ordering, publication tags, and package pins."""

    expected = RELEASE_TRANSITIONS.get(previous)
    assert (
        current == expected
    ), f"release transition must be {previous} -> {expected}, received {current}"
    if current == "PUBLISHED":
        assert tag_name is not None and AUTHORIZED_TAG_PATTERN.fullmatch(
            tag_name
        ), "PUBLISHED requires an mcp-server-v* tag"
    if current == "PINNED":
        assert target_version is not None, "PINNED requires a target version"
        assert (
            published_version == target_version
        ), "PINNED requires exact publication evidence for the target version"


def _workflow_text() -> str:
    """Return the tracked MCP publication workflow text."""

    return WORKFLOW_PATH.read_text(encoding="utf-8")


def _job_block(workflow: str, job_name: str) -> str:
    """Return one top-level release job block from the workflow."""

    match = re.search(
        rf"(?ms)^  {re.escape(job_name)}:\n(?P<body>.*?)(?=^  [A-Z_]+:\n|\Z)",
        workflow,
    )
    assert match is not None, f"workflow job {job_name} is missing"
    return match.group("body")


@pytest.mark.parametrize(
    ("previous", "current", "target_version", "published_version"),
    (
        ("SOURCE_READY", "BUILT", None, None),
        ("BUILT", "TESTED", None, None),
        ("PUBLISHED", "PINNED", "1.0.24", "1.0.24"),
    ),
)
def test_release_order_accepts_only_the_next_non_publish_state(
    previous: str,
    current: str,
    target_version: str | None,
    published_version: str | None,
) -> None:
    """Accept each adjacent release transition that does not publish."""

    _assert_release_transition(
        previous,
        current,
        target_version=target_version,
        published_version=published_version,
    )


@pytest.mark.parametrize(
    ("previous", "current"),
    (
        ("SOURCE_READY", "TESTED"),
        ("BUILT", "PUBLISHED"),
        ("TESTED", "PINNED"),
        ("PUBLISHED", "SOURCE_READY"),
    ),
)
def test_release_order_rejects_out_of_order_transitions(
    previous: str,
    current: str,
) -> None:
    """Reject skipped or reversed release-state transitions."""

    with pytest.raises(AssertionError, match="release transition must be"):
        _assert_release_transition(previous, current)


def test_release_order_accepts_authorized_publish_tag() -> None:
    """Permit publication only at the adjacent transition with an authorized tag."""

    _assert_release_transition(
        "TESTED",
        "PUBLISHED",
        tag_name="mcp-server-v1.0.24",
    )


@pytest.mark.parametrize(
    "tag_name",
    (None, "", "v1.0.24", "drm-copilot-v1.0.24"),
)
def test_publication_rejects_unauthorized_tags(tag_name: str | None) -> None:
    """Reject publication attempts outside the mcp-server-v* tag family."""

    with pytest.raises(AssertionError, match=r"mcp-server-v\*"):
        _assert_release_transition("TESTED", "PUBLISHED", tag_name=tag_name)


@pytest.mark.parametrize("published_version", (None, "1.0.23"))
def test_pinning_rejects_target_without_exact_publication_evidence(
    published_version: str | None,
) -> None:
    """Reject a target pin until evidence names that exact published version."""

    with pytest.raises(AssertionError, match="exact publication evidence"):
        _assert_release_transition(
            "PUBLISHED",
            "PINNED",
            target_version="1.0.24",
            published_version=published_version,
        )


def test_workflow_dependency_graph_is_exact() -> None:
    """Require the five release jobs and their exact linear dependencies."""

    workflow = _workflow_text()
    job_names = tuple(re.findall(r"(?m)^  ([A-Z_]+):$", workflow))

    assert job_names == RELEASE_STATES
    assert "needs:" not in _job_block(workflow, "SOURCE_READY")
    for previous, current in zip(RELEASE_STATES[:-1], RELEASE_STATES[1:], strict=True):
        assert f"    needs: {previous}\n" in _job_block(workflow, current)


def test_source_ready_builds_and_smokes_the_source_bundle() -> None:
    """Require source bundle construction before its JSON-RPC smoke gate."""

    source_ready = _job_block(_workflow_text(), "SOURCE_READY")
    build = "npm --prefix extensions/drm-copilot run bundle:mcp-server"
    smoke = "--server extensions/drm-copilot/out/mcp-server.js"

    assert source_ready.index(build) < source_ready.index(smoke)
    assert "--mode source" in source_ready


def test_built_stage_prepares_both_bundles_and_local_pack() -> None:
    """Require prepack, both esbuild bundle builds, and local pack in order."""

    built = _job_block(_workflow_text(), "BUILT")
    required_commands = (
        "npm --prefix packages/mcp-server run prepack",
        "npm --prefix extensions/drm-copilot run bundle:mcp-server",
        "npm --prefix packages/mcp-server run build",
        "npm --prefix packages/mcp-server pack",
    )
    positions = tuple(built.index(command) for command in required_commands)

    assert positions == tuple(sorted(positions))


def test_built_and_packed_smoke_gates_precede_publication() -> None:
    """Require both standalone candidate smoke gates before npm publication."""

    workflow = _workflow_text()
    tested = _job_block(workflow, "TESTED")
    published = _job_block(workflow, "PUBLISHED")

    assert "--mode built" in tested
    assert "--mode packed" in tested
    assert tested.index("--mode built") < tested.index("--mode packed")
    assert "needs: TESTED" in published
    assert workflow.index("--mode built") < workflow.index("npm publish")
    assert workflow.index("--mode packed") < workflow.index("npm publish")


def test_publication_and_pin_stages_enforce_release_evidence() -> None:
    """Require an authorized tag before publish and exact registry evidence after."""

    workflow = _workflow_text()
    published = _job_block(workflow, "PUBLISHED")
    pinned = _job_block(workflow, "PINNED")
    authorized_condition = (
        "if: github.event_name == 'push' && "
        "startsWith(github.ref, 'refs/tags/mcp-server-v')"
    )

    assert authorized_condition in published
    assert "npm publish" in published
    assert authorized_condition in pinned
    assert (
        'npm view "@danmoisan/drm-copilot-mcp@$targetVersion" version --json' in pinned
    )
    assert "[string]$publishedVersion -ne $targetVersion" in pinned
    assert "git tag" not in workflow
    assert "git push" not in workflow


def test_expected_failure_pwsh_guard_resets_exit_code() -> None:
    """Require the negative pin search to clear its expected nonzero exit code."""

    source_ready = _job_block(_workflow_text(), "SOURCE_READY")

    assert "$grepExitCode = $LASTEXITCODE" in source_ready
    assert "$LASTEXITCODE = 0" in source_ready
    assert "exit 0" in source_ready
