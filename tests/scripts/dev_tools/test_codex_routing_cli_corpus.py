"""Prove the codex-routing parity corpus reflects the Python CLIs (issue #697).

The committed corpus under `tests/fixtures/codex_routing/` is the oracle the
PowerShell wrappers are compared against. These tests run every record through
the Python CLI `main(argv)` in-process and assert the recorded exit code,
stdout, and error message, so a drift in either the CLI or the corpus fails.
"""

from __future__ import annotations

import io
import json
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from typing import TYPE_CHECKING, TypedDict

import pytest

from scripts.dev_tools import resolve_codex_deployment, resolve_codex_topology

if TYPE_CHECKING:
    from collections.abc import Callable

CORPUS_ROOT = Path(__file__).resolve().parents[2] / "fixtures" / "codex_routing"


class CorpusRecord(TypedDict):
    """One corpus case: CLI tokens and the Python CLI's observed result."""

    id: str
    argv: list[str]
    expected_exit: int
    expected_stdout: str
    expected_stderr_contains: str | None


def _load_corpus(name: str) -> list[CorpusRecord]:
    """Read one corpus file.

    Args:
        name: Corpus file stem (`topology` or `deployment`).

    Returns:
        list[CorpusRecord]: Records in file order.
    """
    text = (CORPUS_ROOT / f"{name}.json").read_text(encoding="utf-8")
    records: list[CorpusRecord] = json.loads(text)
    return records


def _normalize(text: str) -> str:
    """Apply the parity normalization: CRLF to LF, trailing whitespace stripped.

    Args:
        text: Captured stdout.

    Returns:
        str: Normalized text.
    """
    return text.replace("\r\n", "\n").rstrip()


def _assert_record(
    main: Callable[[list[str] | None], int], record: CorpusRecord
) -> None:
    """Run one record through a CLI `main` and assert its recorded outcome.

    Args:
        main: Python CLI entry point accepting an argv list.
        record: Corpus record under test.

    Raises:
        AssertionError: When the CLI outcome differs from the record.
    """
    stdout = io.StringIO()
    stderr = io.StringIO()
    # Routing table: exit 0 returns normally, exit 2 is an argparse
    # SystemExit, and exit 1 is a resolver ValueError that escapes main.
    if record["expected_exit"] == 0:
        with redirect_stdout(stdout), redirect_stderr(stderr):
            result = main(record["argv"])
        assert result == 0
        assert _normalize(stdout.getvalue()) == record["expected_stdout"]
    elif record["expected_exit"] == 2:
        with pytest.raises(SystemExit) as raised:
            with redirect_stdout(stdout), redirect_stderr(stderr):
                main(record["argv"])
        assert raised.value.code == 2
        assert stdout.getvalue() == ""
    else:
        assert record["expected_exit"] == 1
        expected_message = record["expected_stderr_contains"]
        assert expected_message is not None
        with pytest.raises(ValueError) as raised_error:
            with redirect_stdout(stdout), redirect_stderr(stderr):
                main(record["argv"])
        assert expected_message in str(raised_error.value)
        assert stdout.getvalue() == ""


TOPOLOGY_RECORDS = _load_corpus("topology")
DEPLOYMENT_RECORDS = _load_corpus("deployment")


@pytest.mark.parametrize("record", TOPOLOGY_RECORDS, ids=lambda record: record["id"])
def test_topology_corpus_matches_python_cli(record: CorpusRecord) -> None:
    """Each topology record reproduces the Python CLI outcome (AC-4.6)."""
    _assert_record(resolve_codex_topology.main, record)


@pytest.mark.parametrize("record", DEPLOYMENT_RECORDS, ids=lambda record: record["id"])
def test_deployment_corpus_matches_python_cli(record: CorpusRecord) -> None:
    """Each deployment record reproduces the Python CLI outcome (AC-4.6)."""
    _assert_record(resolve_codex_deployment.main, record)


def test_corpus_covers_required_cases() -> None:
    """The corpus holds the 23 required case ids and the named inputs (AC-4.8)."""
    # Arrange
    expected_ids = {
        "topo-standalone-small",
        "topo-powershell-budget-exceeded",
        "topo-epic-preparation-child",
        "topo-epic-execution-child",
        "topo-cross-cutting",
        "topo-root-persona-epic-planner",
        "topo-root-persona-epic-orchestrator",
        "topo-repeated-language",
        "topo-non-ascii-language",
        "topo-missing-required",
        "topo-invalid-choice",
        "topo-non-integer-count",
        "topo-empty-language",
        "topo-root-persona-non-standalone",
        "dep-c1-standalone",
        "dep-commit-steward",
        "dep-feature-review-alias-epic-preparation",
        "dep-c3-epic-execution-c4-ceiling",
        "dep-forced-epic-planner",
        "dep-missing-required",
        "dep-invalid-choice",
        "dep-ceiling-below-band",
        "dep-unsupported-agent",
    }
    records = [*TOPOLOGY_RECORDS, *DEPLOYMENT_RECORDS]

    # Act
    actual_ids = [record["id"] for record in records]
    tokens = [token for record in records for token in record["argv"]]

    # Assert
    assert len(actual_ids) == 23
    assert set(actual_ids) == expected_ids
    assert any(any(ord(char) > 127 for char in token) for token in tokens)
    assert "commit-steward" in tokens
