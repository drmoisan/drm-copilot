"""Tests for the Python-to-TypeScript twin literal comparison helper."""

from __future__ import annotations

import pytest

from tests.scripts.dev_tools.typescript_twin_test_support import (
    literals_missing_from_twin,
)


def test_missing_twin_fails_with_clear_assertion() -> None:
    """Name a missing TypeScript twin in an assertion, not an OS error."""
    twin = "lib/validate/no-such-twin.test.ts"

    with pytest.raises(AssertionError, match="TypeScript twin test file is missing"):
        literals_missing_from_twin(("message",), twin)


def test_present_twin_reports_only_absent_literals() -> None:
    """Report only the messages the twin does not quote verbatim."""
    present = "Epic planner checkpoint features[0] must be an object."
    absent = "Epic planner checkpoint features[9] must be an object."

    missing = literals_missing_from_twin(
        (present, absent), "lib/validate/epic-planner-state-feature-indices.test.ts"
    )

    assert missing == [absent]
