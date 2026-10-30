"""Exercise required timestamp and HTTP evidence formats without optional extras."""

from __future__ import annotations

import json

import pytest
from drm_copilot_discovery.schema_validation import (
    discovery_format_checker,
    is_http_evidence_uri,
    is_rfc3339_timestamp,
    validate_document,
)
from jsonschema import FormatChecker

from tests.schemas.discovery.v2_schema_test_support import load_fixture


def test_required_formats_are_registered_without_mutating_library_defaults() -> None:
    """Each schema-test validator owns explicit date-time and HTTP URI checks."""
    previous = dict(FormatChecker.checkers)
    first = discovery_format_checker()
    second = discovery_format_checker()

    assert set(first.checkers) == {"date-time", "uri"}
    assert first is not second
    assert first.checkers is not second.checkers
    assert dict(FormatChecker.checkers) == previous
    assert first.conforms("2026-02-30T00:00:00Z", "date-time") is False
    assert first.conforms("https://[invalid", "uri") is False


@pytest.mark.parametrize(
    "timestamp",
    [
        "2026-01-01T00:00:00Z",
        "2026-01-01t00:00:00z",
        "2000-02-29T23:59:59.123456789+23:59",
        "2024-02-29T00:00:00-23:59",
        "2026-01-01T00:00:00+00:00",
        "2026-01-01T00:00:00-00:00",
        "1937-01-01T12:00:27.87+00:20",
        "0000-02-29T00:00:00Z",
        "9999-12-31T23:59:59Z",
        "1990-12-31T23:59:60Z",
        "1990-12-31T15:59:60-08:00",
        "1991-01-01T00:59:60+01:00",
        "2017-01-01T00:59:60.5+01:00",
        "1972-07-01T00:29:60+00:30",
    ],
)
def test_timestamp_schema_accepts_calendar_and_offset_boundaries(
    timestamp: str,
) -> None:
    """The declared format supports RFC syntax, leap dates and real insertions."""
    assert discovery_format_checker().conforms(timestamp, "date-time")


@pytest.mark.parametrize(
    "timestamp",
    [
        "2026-02-30T00:00:00Z",
        "1900-02-29T00:00:00Z",
        "2025-02-29T00:00:00Z",
        "2026-04-31T00:00:00Z",
        "2026-00-01T00:00:00Z",
        "2026-13-01T00:00:00Z",
        "2026-01-00T00:00:00Z",
        "2026-01-01T24:00:00Z",
        "2026-01-01T00:60:00Z",
        "2026-01-01T00:00:61Z",
        "2026-01-01T00:00:00+24:00",
        "2026-01-01T00:00:00+00:60",
        "2026-01-01T00:00:00",
        "2026-01-01T00:00:00+0000",
        "2026-01-01T00:00:00+00:00:00",
        "2026-01-01 00:00:00Z",
        "2026-01-01T00:00:00.Z",
        "2026-01-01T00:00:00,5Z",
        "2026-1-1T0:0:0Z",
        "２０２６-01-01T00:00:00Z",
        "2026-01-01T00:00:00Z\n",
        "2026-01-01T00:00:00Z\u2028",
        "2026-12-31T23:59:60Z",
        "1990-12-31T22:59:60Z",
        "1990-12-31T23:59:60+01:00",
        "1990-06-30T23:59:60Z",
        "1900-12-31T23:59:60Z",
    ],
)
def test_timestamp_schema_rejects_invalid_dates_and_non_rfc_syntax(
    timestamp: str,
) -> None:
    """Impossible dates, malformed zones and invented leap seconds fail closed."""
    assert not discovery_format_checker().conforms(timestamp, "date-time")


@pytest.mark.parametrize(
    "uri",
    [
        "https://example.invalid",
        "http://example.invalid:/",
        "https://example.invalid:443/a%20b?value=%2f#section",
        "https://user:pass@example.invalid/a",
        "https://%65xample.invalid/%00?x=%7F",
        "https://127.0.0.1/a",
        "https://[::1]:443/",
        "https://[::ffff:192.0.2.1]/",
        "https://[vF.alpha:beta]/",
        "https://example.invalid//a/./b/../c",
        "https://example.invalid/?a=/path?b=value#fragment/part?query",
        "https://example.invalid/!$&'()*+,;=:@_~.-",
        "https://example.invalid/?#",
    ],
)
def test_evidence_uri_schema_accepts_descriptive_http_references(uri: str) -> None:
    """Syntax acceptance does not decode data, resolve names or fetch a resource."""
    evidence = load_fixture("evidence-reference")
    evidence["uri"] = uri

    assert validate_document(
        json.dumps(evidence),
        expected_kind="evidence-reference",
        expected_version="2.0.0",
    ).ok


@pytest.mark.parametrize(
    "uri",
    [
        "https://[invalid",
        "https://",
        "https:///path",
        "https://:443/path",
        "https://user@/path",
        "https://user@@example.invalid/",
        "https://example.invalid:abc/",
        "https://example.invalid:80:90/",
        "https://[::1]suffix/",
        "https://[127.0.0.1]/",
        "https://[v1.]/",
        "https://[fe80::1%25eth0]/",
        "https://exa%GGmple.invalid/",
        "https://example.invalid/%",
        "https://example.invalid/%2",
        "https://example.invalid/%GG",
        "https://example.invalid/?a=%G0",
        "https://example.invalid/#%0",
        "https://example.invalid/#part#part",
        "https://example.invalid/[path]",
        "https://example.invalid/?[query]",
        "https://example.invalid/back\\slash",
        "https://example.invalid/{path}",
        "https://example.invalid/<path>",
        "https://example.invalid/space here",
        "https://example.invalid/\npath",
        "https://example.invalid/\tpath",
        "https://example.invalid/\x00",
        "https://example.invalid/\x7f",
        "https://éxample.invalid/",
        "https://example.invalid/é",
        "ftp://example.invalid/reference",
        "//example.invalid/reference",
        "https:example.invalid/reference",
    ],
)
def test_evidence_uri_schema_rejects_malformed_authority_and_components(
    uri: str,
) -> None:
    """Illegal characters and incomplete escapes are rejected before any decoding."""
    evidence = load_fixture("evidence-reference")
    evidence["uri"] = uri

    assert not validate_document(
        json.dumps(evidence),
        expected_kind="evidence-reference",
        expected_version="2.0.0",
    ).ok


@pytest.mark.parametrize("value", (None, True, 123, [], {}))
def test_format_checks_leave_non_string_rejection_to_schema_types(
    value: object,
) -> None:
    """JSON Schema format functions do not redefine primitive type validation."""
    assert is_rfc3339_timestamp(value)
    assert is_http_evidence_uri(value)
    evidence = load_fixture("evidence-reference")
    evidence["timestamp"] = value
    assert not validate_document(
        json.dumps(evidence),
        expected_kind="evidence-reference",
        expected_version="2.0.0",
    ).ok
