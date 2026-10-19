"""Verify bounded configuration grammars and source-free public error surfaces."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.analyzer.configuration_input import (
    ConfigurationInputError,
    parse_configuration,
)

if TYPE_CHECKING:
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
