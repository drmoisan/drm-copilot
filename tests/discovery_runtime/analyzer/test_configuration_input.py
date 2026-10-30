"""Verify bounded configuration grammars and source-free public error surfaces."""

from __future__ import annotations

import configparser
import json
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer import configuration_input as input_module
from drm_copilot_discovery.analyzer.configuration_input import (
    ConfigurationInputError,
    parse_configuration,
)
from drm_copilot_discovery.findings import child_pointer

if TYPE_CHECKING:
    import re

    from drm_copilot_discovery.analyzer.configuration_input import ConfigurationFormat


@pytest.mark.parametrize(
    "format,payload,code",
    [
        ("json", b'["VALUE_SENTINEL"]', "configuration-json-root"),
        ("json", b'{"K":"VALUE_SENTINEL",}', "configuration-json-invalid"),
        ("json", b'{"K":1,"\\u004b":"VALUE_SENTINEL"}', "configuration-json-invalid"),
        ("json", b'{"K":NaN}', "configuration-json-invalid"),
        ("json", b'{"K":Infinity}', "configuration-json-invalid"),
        ("json", b'{"K":"\xffVALUE_SENTINEL"}', "configuration-json-invalid"),
        ("json", b'{"K":"\\ud800VALUE_SENTINEL"}', "configuration-json-invalid"),
        ("xml", b"<VALUE_SENTINEL/>", "configuration-xml-root"),
        (
            "xml",
            b'<settings><setting name="K">VALUE_SENTINEL</bad>',
            "configuration-xml-invalid",
        ),
        (
            "xml",
            b'<!DOCTYPE settings [<!ENTITY x "VALUE_SENTINEL">]><settings/>',
            "configuration-xml-invalid",
        ),
        (
            "xml",
            b'<settings xmlns:x="http://www.w3.org/2001/XInclude">'
            b'<x:include href="VALUE_SENTINEL"/></settings>',
            "configuration-xml-invalid",
        ),
        (
            "xml",
            b'<settings><setting value="VALUE_SENTINEL"/></settings>',
            "configuration-xml-key",
        ),
        ("ini", b"K=VALUE_SENTINEL", "configuration-ini-section-required"),
        ("ini", b"[S]\nK=VALUE_SENTINEL\nK=second", "configuration-ini-invalid"),
        ("ini", b"[S]\nK=VALUE_SENTINEL\n[S]\nB=x", "configuration-ini-invalid"),
        ("ini", b"[S]\nVALUE_SENTINEL", "configuration-ini-invalid"),
        ("ini", b"[S]\nK=\xffVALUE_SENTINEL", "configuration-encoding"),
        ("ini", b"[S]\nK=\x00VALUE_SENTINEL", "configuration-encoding"),
    ],
)
def test_parser_failures_never_expose_source_through_error_surfaces(
    format: ConfigurationFormat, payload: bytes, code: str
) -> None:
    """Format literal, payload bytes and fixed code str exercise malformed inputs.

    Returns None; asserts no partial records or source-bearing exception chain.
    The parser executes only in memory; captured errors must have fixed messages.
    """
    with pytest.raises(ConfigurationInputError) as caught:
        parse_configuration(payload, format=format, max_bytes=4096, max_keys=100)
    assert caught.value.code == code
    assert "VALUE_SENTINEL" not in str(caught.value) + repr(caught.value) + repr(
        caught.value.args
    )
    assert caught.value.__context__ is None and caught.value.__cause__ is None


@pytest.mark.parametrize("newline", ["\n", "\r\n", "\r"])
def test_ini_defaults_continuations_and_case_have_physical_anchors(
    newline: str,
) -> None:
    """str newline selects physical boundaries; preserve default and explicit origins.

    Returns None; asserts no continuation key or interpolation evaluation.
    """
    content = newline.join(
        [
            "[DEFAULT]",
            "Inherited=VALUE_SENTINEL",
            "[S]",
            "K=first",
            "  Fake=VALUE_SENTINEL",
            "",
            " ; comment",
            "  More=VALUE_SENTINEL",
            "k=%(VALUE_SENTINEL)s",
        ]
    ).encode()
    result = parse_configuration(content, format="ini", max_bytes=4096, max_keys=100)
    # Verify every declaration anchor, excluding indented value continuations.
    assert [(item.name, item.kind, item.line) for item in result] == [
        ("DEFAULT", "ini-section", 1),
        ("Inherited", "ini-default-key", 2),
        ("S", "ini-section", 3),
        ("K", "ini-key", 4),
        ("k", "ini-key", 9),
        ("Inherited", "ini-inherited-key", 2),
    ]
    assert result[-1].origin_pointer == "/defaults/Inherited"
    assert result[-1].pointer == "/sections/S/Inherited"
    assert "VALUE_SENTINEL" not in repr(result)


@pytest.mark.parametrize(
    "format,payload,keys,depth",
    [
        ("json", b'{"A":1,"B":2}', 1, 64),
        ("json", b'{"A":{"B":1}}', 100, 1),
        ("xml", b'<settings><setting name="A"/></settings>', 1, 64),
        ("xml", b'<settings><setting name="A"/></settings>', 100, 1),
        ("ini", b"[S]\nA=1", 1, 64),
        ("ini", b"[DEFAULT]\nA=1\n[S]", 3, 64),
    ],
)
def test_parser_budgets_reject_partial_output(
    format: ConfigurationFormat, payload: bytes, keys: int, depth: int
) -> None:
    """Format/bytes/int key and depth bounds reject before exposing partial claims.

    Returns None; assertions require only fixed errors from pure parser calls.
    """
    with pytest.raises(ConfigurationInputError):
        parse_configuration(
            payload, format=format, max_bytes=4096, max_keys=keys, max_depth=depth
        )


def test_byte_budget_and_invalid_caller_limits_fail_explicitly() -> None:
    """No inputs; reject oversized bytes and invalid limits without external effects.

    Returns None; fixed errors distinguish captured data from caller policy defects.
    """
    with pytest.raises(ConfigurationInputError, match="over budget"):
        parse_configuration(b'{"K":1}', format="json", max_bytes=2, max_keys=10)
    with pytest.raises(ValueError, match="key budget"):
        parse_configuration(b"{}", format="json", max_bytes=100, max_keys=100001)
    with pytest.raises(ValueError, match="must be an integer"):
        parse_configuration(b"{}", format="json", max_bytes=0, max_keys=1)


@pytest.mark.parametrize("count", [64, 128, 256])
def test_repeated_long_json_prefixes_fail_within_a_finite_text_budget(
    count: int,
) -> None:
    """int count repeats the review's exact long-prefix reproduction in memory.

    Returns None; the default finite output budget rejects rather than amplifying
    a small input into an unbounded set of repeated structural addresses.
    """
    # Retain the original nested-key family while varying only its bounded count.
    content = json.dumps(
        {"p" * 2048: {"key" + str(index): 0 for index in range(count)}},
        separators=(",", ":"),
    ).encode()
    with pytest.raises(ConfigurationInputError) as caught:
        parse_configuration(content, format="json", max_bytes=8192, max_keys=count + 1)
    assert caught.value.code == "configuration-text-limit"


@pytest.mark.parametrize("prefix", ["plain", "Ω/~", 'Control\n\t"\\', "\U0001f680/~"])
def test_pointer_expansion_is_charged_before_construction(
    monkeypatch: pytest.MonkeyPatch, prefix: str
) -> None:
    """Patch fixture and str prefix verify prospective escaping, not elapsed time.

    Returns None; a child-pointer spy rejects any construction beyond the encoded
    byte reservation. This includes both JSON ASCII policies and RFC 6901 growth.
    """
    prefix *= 8
    content = json.dumps({prefix: {"Child": 0}}, ensure_ascii=False).encode()
    escaped = "/" + prefix.replace("~", "~0").replace("/", "~1")
    budget = 12 * len(escaped) - 1
    created: list[str] = []
    original = child_pointer

    def guarded_pointer(parent: str, part: str | int) -> str:
        """Record str parent/str-or-int segment construction; return real pointer.

        Mutates only the test list; an unexpected invocation fails the assertion.
        """
        created.append(original(parent, part))
        return created[-1]

    monkeypatch.setattr(input_module, "child_pointer", guarded_pointer)
    with pytest.raises(ConfigurationInputError) as caught:
        parse_configuration(
            content, format="json", max_bytes=8192, max_keys=100, max_text_bytes=budget
        )
    assert caught.value.code == "configuration-text-limit" and created == []


def test_inherited_ini_paths_cannot_exceed_accumulated_text_reservations(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Patch fixture observes bounded INI pointer allocations across inherited keys.

    Returns None; count encoded prospective paths before the real helper runs,
    and require fixed failure with no returned partial declaration collection.
    """
    # Each individually small section inherits the same escaped Unicode default.
    content = (
        "[DEFAULT]\nΩ/~=VALUE_SENTINEL\n"
        + "\n".join("[" + "Section" * 8 + str(index) + "]" for index in range(8))
    ).encode()
    remaining = 18000
    created = 0
    original = child_pointer

    def bounded_pointer(parent: str, part: str | int) -> str:
        """Check str/int path arguments against byte budget; return real pointer.

        Mutates only counters; assertion fails before any prohibited allocation.
        """
        nonlocal remaining, created
        segment = str(part)
        cost = 12 * (
            len(parent) + 1 + len(segment) + segment.count("~") + segment.count("/")
        )
        assert cost <= remaining
        remaining -= cost
        created += 1
        return original(parent, part)

    monkeypatch.setattr(input_module, "child_pointer", bounded_pointer)
    with pytest.raises(ConfigurationInputError) as caught:
        parse_configuration(
            content, format="ini", max_bytes=8192, max_keys=100, max_text_bytes=18000
        )
    assert caught.value.code == "configuration-text-limit" and created > 10
    assert "VALUE_SENTINEL" not in repr(caught.value)


@pytest.mark.parametrize("spaces", [1024, 2048, 4096])
@pytest.mark.parametrize("valid", [False, True])
def test_ini_internal_spaces_use_only_the_fixed_linear_matcher(
    monkeypatch: pytest.MonkeyPatch, spaces: int, valid: bool
) -> None:
    """Patch fixture, int spaces and bool validity retain both original reproducers.

    Returns None; forbid the old overlapping matcher at both locator/parser sites.
    A larger explicit output budget keeps this work regression separate from R1.
    """

    class ProhibitedMatcher:
        """Fail if either INI stage requests the inherited overlapping expression."""

        def match(self, text: str) -> None:
            """Reject str text before matching; raises AssertionError, no I/O."""
            raise AssertionError("The overlapping stdlib option matcher was used")

    monkeypatch.setattr(configparser.ConfigParser, "OPTCRE", ProhibitedMatcher())
    key = "K" + " " * spaces + "Suffix"
    payload = (
        "[S]\n"
        + (key + "=VALUE_SENTINEL" if valid else "K" + " " * spaces + "VALUE_SENTINEL")
    ).encode()
    # Both original input families use the fixed matcher; only valid syntax returns.
    if valid:
        result = parse_configuration(
            payload, format="ini", max_bytes=8192, max_keys=100, max_text_bytes=262144
        )
        assert result[1].name == key and result[1].line == 2
        assert "VALUE_SENTINEL" not in repr(result)
    else:
        with pytest.raises(ConfigurationInputError) as caught:
            parse_configuration(
                payload,
                format="ini",
                max_bytes=8192,
                max_keys=100,
                max_text_bytes=262144,
            )
        assert caught.value.code == "configuration-ini-invalid"


@pytest.mark.parametrize("delimiter", ["=", ":"])
def test_many_ini_lines_have_linear_aggregate_match_input(
    monkeypatch: pytest.MonkeyPatch, delimiter: str
) -> None:
    """Patch fixture and delimiter str measure work over many admissible lines.

    Returns None; both stages must match each option once with total character
    input bounded by twice the source length. No elapsed-time assertion is used.
    """
    parser_type = cast(
        "type[configparser.ConfigParser]", vars(input_module)["_IniParser"]
    )
    original = parser_type.OPTCRE
    visits: list[int] = []

    class CountedMatcher:
        """Record each fixed linear expression invocation without changing grammar."""

        def match(self, text: str) -> re.Match[str] | None:
            """Count str text length; return Match-or-None without I/O or retention."""
            visits.append(len(text))
            return original.match(text)

    # Internal spaces and surrounding whitespace retain the supported option grammar.
    lines = [
        "K" + str(index) + " " * 16 + "Suffix  " + delimiter + " VALUE_SENTINEL"
        for index in range(64)
    ]
    content = ("[S]\n" + "\n".join(lines)).encode()
    monkeypatch.setattr(parser_type, "OPTCRE", CountedMatcher())
    result = parse_configuration(
        content, format="ini", max_bytes=8192, max_keys=100, max_text_bytes=262144
    )
    assert len(result) == 65 and len(visits) == 128
    assert sum(visits) <= 2 * len(content)
    assert result[1].name == "K0" + " " * 16 + "Suffix"
    assert "VALUE_SENTINEL" not in repr(result)


@pytest.mark.parametrize("budget", [0, -1, True, 67108865])
def test_invalid_encoded_text_budgets_fail_as_caller_errors(budget: int) -> None:
    """int budget exercises unsupported text bounds before parsing; return None.

    Invalid limits raise a fixed ValueError without source inspection or effects.
    """
    with pytest.raises(ValueError, match="text budget"):
        parse_configuration(
            b"{}", format="json", max_bytes=8192, max_keys=10, max_text_bytes=budget
        )
