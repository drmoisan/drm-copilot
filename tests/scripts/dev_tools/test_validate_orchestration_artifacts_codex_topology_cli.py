"""CLI parser coverage for the Codex topology completion gate."""

from __future__ import annotations

import pytest

from scripts.dev_tools.validate_orchestration_artifacts import build_parser


@pytest.mark.parametrize(
    "artifact_type", ["orchestrator-state", "epic-orchestrator-state"]
)
def test_checkpoint_parsers_accept_codex_topology_gate_flag(
    artifact_type: str,
) -> None:
    """Expose the mechanical topology gate for ordinary and epic checkpoints."""

    args = build_parser().parse_args(
        [artifact_type, "checkpoint.json", "--require-codex-topology"]
    )

    assert args.require_codex_topology is True
