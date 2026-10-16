"""Compare Python test message constants with their TypeScript twin literals."""

from __future__ import annotations

from pathlib import Path

TYPESCRIPT_TEST_ROOT = (
    Path(__file__).resolve().parents[3] / "extensions" / "drm-copilot" / "test"
)


def literals_missing_from_twin(messages: tuple[str, ...], twin: str) -> list[str]:
    """Return each message the TypeScript twin does not quote verbatim.

    ``twin`` is relative to ``extensions/drm-copilot/test``. A message counts as
    present only when the twin contains it as one double-quoted literal.
    """

    text = (TYPESCRIPT_TEST_ROOT / twin).read_text(encoding="utf-8")
    return [message for message in messages if f'"{message}"' not in text]
