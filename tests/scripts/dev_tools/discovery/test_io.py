"""Tests for `scripts.dev_tools.discovery.io`.

Covers the `ArtifactValidator` seam (`validate_or_raise`) and the thin
`read_artifact_text`/`write_report` filesystem wrappers, using
`monkeypatch.setattr(Path, ...)` in place of real file I/O per
`.claude/rules/general-unit-test.md` "External Dependencies".
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch

import pytest

from scripts.dev_tools.discovery.io import (
    ArtifactValidationError,
    read_artifact_text,
    validate_or_raise,
    write_report,
)


def _passing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports no errors."""
    del text
    return []


def _failing_validator(text: str) -> list[str]:
    """Fake `ArtifactValidator` that always reports one fixed error."""
    del text
    return ["bad field"]


def test_validate_or_raise_passes_with_no_errors() -> None:
    """A validator returning an empty error list must not raise."""
    # Arrange / Act / Assert: no exception should propagate.
    validate_or_raise("irrelevant text", _passing_validator)


def test_validate_or_raise_raises_with_errors() -> None:
    """A validator returning errors must raise ArtifactValidationError
    carrying those exact errors."""
    with pytest.raises(ArtifactValidationError) as exc_info:
        validate_or_raise("irrelevant text", _failing_validator)

    assert exc_info.value.errors == ["bad field"]


def test_read_artifact_text_returns_stubbed_text(monkeypatch: MonkeyPatch) -> None:
    """read_artifact_text should return whatever Path.read_text yields."""

    def fake_read_text(self: Path, *args: Any, **kwargs: Any) -> str:
        assert self == Path("/artifact.json")
        assert kwargs.get("encoding") == "utf-8"
        return '{"entries": []}'

    monkeypatch.setattr(Path, "read_text", fake_read_text, raising=False)

    result = read_artifact_text(Path("/artifact.json"))

    assert result == '{"entries": []}'


def test_write_report_calls_write_text_with_exact_content(
    monkeypatch: MonkeyPatch,
) -> None:
    """write_report should pass the exact content argument to
    Path.write_text."""
    captured: dict[str, Any] = {}

    def fake_write_text(self: Path, data: str, *args: Any, **kwargs: Any) -> int:
        captured["path"] = self
        captured["data"] = data
        captured["encoding"] = kwargs.get("encoding")
        return len(data)

    monkeypatch.setattr(Path, "write_text", fake_write_text, raising=False)

    write_report(Path("/report.json"), "rendered content")

    assert captured["path"] == Path("/report.json")
    assert captured["data"] == "rendered content"
    assert captured["encoding"] == "utf-8"
