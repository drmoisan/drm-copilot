"""Tests for the canonical-timestamp contract of the drift-resolution comparison.

The comparison these tests pin is disjunct (b) of the drift-resolution derivation:
a radius re-recorded from a later observed diff resolves the drift only when its
`computed_at` is strictly later than the event's `at`. Comparing the two ordinally
without a shape contract fails open, because `-` (0x2D) sorts below `:` (0x3A), so a
colon-bearing `computed_at` such as `2026-01-09T10:00:00Z` compares greater than the
hyphen-bearing `at` `2026-01-09T10-00` even though the two name the same instant, and
would report the drift resolved with no later diff.

Every case is a pure predicate evaluation. No checkpoint is loaded, no clock is read
except by the one test that asserts the CLI's own clock format, and no file is
touched.
"""

from __future__ import annotations

import re

import pytest

from scripts.dev_tools._parallel_drift_shape import (
    CANONICAL_TIMESTAMP_RE,
    is_later_canonical_timestamp,
)
from scripts.dev_tools.parallel_drift_detection_cli import default_timestamp

# A conforming reference instant, and the two conforming instants that bracket it.
REFERENCE = "2026-01-09T10-00"
LATER = "2026-01-09T10-01"
EARLIER = "2026-01-09T09-59"

# The non-conforming value the finding names: an ISO-8601 form carrying colons and a
# seconds field. Ordinally it falls below `REFERENCE` because its day component is
# smaller, so it is the plain non-conforming case rather than the inverting one.
COLON_BEARING = "2026-01-01T10:00:00Z"

# The inverting non-conforming value: it names exactly the same instant as
# `REFERENCE` yet sorts ordinally above it, because the first differing character is
# `:` (0x3A) against `-` (0x2D). This is the value an ungated ordinal comparison
# reports as strictly later, which is the fail-open path the contract closes.
COLON_BEARING_INVERTING = "2026-01-09T10:00:00Z"


@pytest.mark.parametrize(
    ("candidate", "reference", "expected", "why"),
    [
        (LATER, REFERENCE, True, "strictly greater conforming candidate"),
        (REFERENCE, REFERENCE, False, "equal conforming pair is not later"),
        (EARLIER, REFERENCE, False, "strictly lesser conforming candidate"),
        (COLON_BEARING, REFERENCE, False, "colon-bearing candidate is unresolved"),
        (LATER, COLON_BEARING, False, "colon-bearing reference is unresolved"),
        (
            COLON_BEARING_INVERTING,
            REFERENCE,
            False,
            "ordinally inverting colon-bearing candidate is unresolved",
        ),
        (
            REFERENCE,
            COLON_BEARING_INVERTING,
            False,
            "ordinally inverting colon-bearing reference is unresolved",
        ),
        ("2026-01-09T10", REFERENCE, False, "truncated candidate is unresolved"),
        (REFERENCE, "2026-01-09T10", False, "truncated reference is unresolved"),
        (5, REFERENCE, False, "non-string candidate is unresolved"),
        (LATER, 5, False, "non-string reference is unresolved"),
        (None, REFERENCE, False, "None candidate is unresolved"),
        (LATER, None, False, "None reference is unresolved"),
        ("", REFERENCE, False, "blank candidate is unresolved"),
        (LATER, "", False, "blank reference is unresolved"),
        ("   ", REFERENCE, False, "whitespace candidate is unresolved"),
        (LATER, "   ", False, "whitespace reference is unresolved"),
    ],
)
def test_is_later_canonical_timestamp_verdicts(
    candidate: object, reference: object, expected: bool, why: str
) -> None:
    """Assert the predicate's verdict over the full conformance matrix.

    The two colon-bearing rows are the fail-open cases the contract exists to close:
    an ungated ordinal comparison would report ``True`` for the first of them.
    """
    assert is_later_canonical_timestamp(candidate, reference) is expected, why


def test_the_colon_bearing_value_would_invert_an_ungated_ordinal_comparison() -> None:
    """Assert the guarded fail-open case is real rather than vacuously excluded.

    A raw ordinal comparison reports the inverting value as strictly greater than a
    reference naming the same instant, which is exactly the spurious resolution the
    contract closes; the predicate reports it as not-later. Without this assertion
    the colon-bearing rows above could pass against a value that was simply
    ordinally smaller and so would never have resolved anything.
    """
    assert COLON_BEARING_INVERTING > REFERENCE
    assert is_later_canonical_timestamp(COLON_BEARING_INVERTING, REFERENCE) is False


def test_the_cli_default_timestamp_conforms_to_the_canonical_pattern() -> None:
    """Bind the CLI's clock format to the resolution predicate's shape contract.

    `default_timestamp` is the only clock read in the drift CLI, and its output
    becomes the `at` of every recorded drift event and the default `computed_at` of
    every emitted observed radius. If `TIMESTAMP_FORMAT` were changed to a shape the
    predicate rejects, every resolution would silently stop clearing and the Layer-2
    gate would never release. Matching the live output against the imported constant
    makes that divergence a test failure rather than a runtime deadlock.
    """
    assert re.match(CANONICAL_TIMESTAMP_RE, default_timestamp()) is not None


def test_canonical_timestamp_pattern_accepts_only_the_repository_shape() -> None:
    """Assert the constant matches the canonical shape and rejects near misses."""
    assert re.match(CANONICAL_TIMESTAMP_RE, REFERENCE) is not None
    assert re.match(CANONICAL_TIMESTAMP_RE, COLON_BEARING) is None
    assert re.match(CANONICAL_TIMESTAMP_RE, COLON_BEARING_INVERTING) is None
    assert re.match(CANONICAL_TIMESTAMP_RE, "2026-01-09t10-00") is None
    assert re.match(CANONICAL_TIMESTAMP_RE, "2026-01-09T10-00 ") is None
