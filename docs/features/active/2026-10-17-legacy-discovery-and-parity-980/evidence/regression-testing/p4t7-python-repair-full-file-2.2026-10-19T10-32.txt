"""Verify finite Python dependency declarations using captured in-memory bytes."""

import configparser
from dataclasses import replace
from typing import Literal, cast

import pytest
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyBudget,
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
)
from drm_copilot_discovery.analyzer.dependency_python import parse_python_dependencies


def parse(
    text: str,
    *,
    format: Literal["requirements", "setup-cfg"] = "requirements",
    limits: DependencyLimits | None = None,
) -> DependencyResult:
    """Encode text (str); select format (Literal['requirements', 'setup-cfg']).

    limits (DependencyLimits | None) defaults to shared capacities. Return
    DependencyResult; propagate DependencyInputError/ValueError. No side effects.
    """
    return parse_python_dependencies(
        text.encode("utf-8"), format=format, limits=limits or DependencyLimits()
    )


@pytest.mark.parametrize(
    "name", ["package", "gitpython", "foo-bar", "A.b_c", "x" * 128]
)
def test_safe_names_remain_unresolved_declarations(name: str) -> None:
    """Retain name (str) without invented versions or evaluated targets.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    result = parse(name)
    item = result.candidates[0]
    assert (item.name, item.kind, item.ecosystem, item.role) == (
        name,
        "declaration",
        "python",
        "direct",
    )
    assert item.version.kind == "missing"
    assert item.owner is None and item.requested.kind == "missing"
    assert not item.condition_present and item.markers == ()
    assert result.diagnostics == ()


@pytest.mark.parametrize(
    "version",
    ["==1.2", ">=1.0,<2", "~=3.1", "!=1.*", "<=3", ">2", "==1.0+cpu", "==1.0-rc1"],
)
def test_supported_constraints_retain_literal_spelling(version: str) -> None:
    """Retain version (str) without attempting version-range resolution.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    item = parse("pkg" + version).candidates[0]
    assert item.version.value == version


def test_extras_conditions_and_comments_are_sanitized() -> None:
    """Keep safe extras/names and omit quoted values/comments; no inputs.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    result = parse(
        "pkg[b,a,b] >= 1, < 3 ; python_version >= 'SECRET#VALUE' "
        'and os_name != "SECRET" # SECRET'
    )
    item = result.candidates[0]
    assert item.extras == ("a", "b")
    assert item.markers == ("os_name", "python_version")
    assert item.condition_present
    assert item.version.value == ">=1,<3"
    assert "SECRET" not in repr(result)


@pytest.mark.parametrize(
    "marker",
    [
        "extra in 'SECRET'",
        "sys_platform not in 'SECRET'",
        "os_name == 'SECRET\"VALUE'",
        "python_version == 'a' or os_name == 'b'",
    ],
)
def test_finite_marker_operators_never_evaluate_values(marker: str) -> None:
    """Record marker (str) applicability without evaluating comparison values.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    item = parse("pkg; " + marker).candidates[0]
    assert item.condition_present and item.markers
    assert "SECRET" not in repr(item)


@pytest.mark.parametrize(
    ("target", "kind"),
    [
        ("https://user:SECRET@example.invalid/a#SECRET", "url"),
        ("git+https://example.invalid/SECRET", "vcs"),
        ("hg+ssh://SECRET", "vcs"),
        ("git@host:SECRET", "vcs"),
        ("file:SECRET", "local"),
        ("../SECRET", "local"),
        ("/SECRET", "local"),
        ("C:\\SECRET", "local"),
        ("\\\\host\\SECRET", "local"),
    ],
)
@pytest.mark.parametrize("named", [False, True])
def test_reference_targets_are_classified_and_redacted(
    target: str, kind: str, named: bool
) -> None:
    """Classify target (str) as kind (str); named (bool) selects explicit name.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    result = parse(("pkg @ " if named else "") + target)
    item = result.candidates[0]
    assert item.name == ("pkg" if named else None)
    assert item.version.kind == kind and item.version.value is None
    assert "SECRET" not in repr(result)
    assert result.diagnostics == ("dependency-redacted",)


@pytest.mark.parametrize("newline", ["\n", "\r", "\r\n"])
def test_physical_lines_and_bom_have_stable_anchors(newline: str) -> None:
    """Anchor declarations using newline (str) while preserving source order.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    result = parse(
        "\ufeff# ignored" + newline + newline + "z" + newline + "a" + newline
    )
    # Compare every physical position without replacing source order with ID order.
    assert [
        (c.name, c.anchor.line, c.anchor.occurrence) for c in result.candidates
    ] == [("z", 3, 3), ("a", 4, 4)]
    # All emitted records must retain the same closed requirements container.
    assert all(c.anchor.location == "requirements" for c in result.candidates)


@pytest.mark.parametrize("text", ["", "\n", "  # comment\n\r\n", "   "])
def test_empty_or_comment_inputs_have_no_candidates(text: str) -> None:
    """Ignore empty/comment text (str) without synthetic dependencies.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    assert parse(text).candidates == ()


@pytest.mark.parametrize(
    ("text", "code"),
    [
        ("-r SECRET", "dependency-unsupported"),
        ("-c SECRET", "dependency-unsupported"),
        ("-e SECRET", "dependency-unsupported"),
        ("--index-url SECRET", "dependency-unsupported"),
        ("pkg --hash=SECRET", "dependency-unsupported"),
        ("pkg \\", "dependency-unsupported"),
        ("attr:SECRET", "dependency-unsupported"),
        ("pkg @ SECRET", "dependency-unsupported"),
        ("pkg===SECRET", "dependency-unsupported"),
        ("pkg==" + "1" * 257, "dependency-unsupported"),
        ("pkg==1,,,,", "dependency-unsupported"),
        ("pkg[]", "dependency-malformed"),
        ("pkg[a,]", "dependency-malformed"),
        ("pkg[SECRET/path]", "dependency-malformed"),
        ("$SECRET", "dependency-malformed"),
        ("x" * 129, "dependency-malformed"),
        ("pkg;", "dependency-malformed"),
        ("pkg; unknown == 'SECRET'", "dependency-unsupported"),
        ("pkg; python_version == SECRET", "dependency-unsupported"),
        ("pkg; python_version == 'SECRET' and", "dependency-unsupported"),
        ("pkg; (os_name == 'SECRET')", "dependency-unsupported"),
        ("pkg; os_name == 'SECRET' trailing", "dependency-unsupported"),
        ("pkg\u2028SECRET", "dependency-unsupported"),
    ],
)
def test_unsupported_and_malformed_requirements_fail_without_partial_results(
    text: str, code: str
) -> None:
    """Reject text (str) with fixed code (str), discarding valid prefixes.

    Return None; AssertionError/pytest failure signals mismatch. No side effects.
    """
    with pytest.raises(DependencyInputError) as captured:
        parse("valid\n" + text)
    assert captured.value.code == code
    assert "SECRET" not in str(captured.value)
    assert captured.value.__context__ is None


def test_setup_cfg_selected_lists_preserve_physical_anchors() -> None:
    """Extract explicit install/extras lists with closed anchors; no inputs.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    text = (
        "[metadata]\nname = ignored\n[options]\ninstall_requires = first>=1\n"
        "    second[a]\n# comment\n[options.extras_require]\n"
        "test = third; extra == 'SECRET'\n    fourth\n"
    )
    result = parse(text, format="setup-cfg")
    # Verify all selected records keep their physical positions and group roles.
    assert [(c.name, c.anchor.line, c.role) for c in result.candidates] == [
        ("first", 4, "install"),
        ("second", 5, "install"),
        ("third", 8, "test"),
        ("fourth", 9, "test"),
    ]
    # Both lists use fixed containers without embedding dynamic group keys.
    assert [c.anchor.location for c in result.candidates] == [
        "options.install_requires"
    ] * 2 + ["options.extras_require"] * 2
    assert "SECRET" not in repr(result)


def test_setup_cfg_nonselected_continuations_cannot_become_options() -> None:
    """An unrelated multiline value cannot create a dependency; no inputs.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    text = (
        "[options]\nother = initial\n    install_requires = fake\n    another\n\n"
        "install_requires = real\n; ignored\n"
    )
    result = parse(text, format="setup-cfg")
    # Only the real option may contribute a declaration and source position.
    assert [(c.name, c.anchor.line) for c in result.candidates] == [("real", 6)]


@pytest.mark.parametrize(
    ("text", "code"),
    [
        (
            "[DEFAULT]\nsecret = SECRET\n[options]\ninstall_requires = pkg",
            "dependency-ambiguous",
        ),
        ("[DEFAULT]\n[options]\ninstall_requires = pkg", "dependency-ambiguous"),
        (" [options]\ninstall_requires = pkg", "dependency-ambiguous"),
        ("[options] # SECRET\ninstall_requires = pkg", "dependency-unsupported"),
        (
            "[options]\ninstall_requires = a\nINSTALL_REQUIRES = SECRET",
            "dependency-malformed",
        ),
        ("[options]\n[options]\n", "dependency-malformed"),
        ("install_requires = SECRET", "dependency-malformed"),
        ("[options]\ninstall_requires = file: SECRET", "dependency-unsupported"),
        ("[options]\ninstall_requires = attr: SECRET", "dependency-unsupported"),
        ("[options]\ninstall_requires = %(SECRET)s", "dependency-malformed"),
        ("[options.extras_require]\nunsafe:SECRET = pkg", "dependency-unsupported"),
        ("[options]\ninstall_requires = pkg\n\n    other", "dependency-malformed"),
    ],
)
def test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure(
    text: str, code: str
) -> None:
    """Reject invalid/dynamic text (str) using redacted expected code (str).

    Return None; AssertionError/pytest failure signals mismatch. No side effects.
    """
    with pytest.raises(DependencyInputError) as captured:
        parse(text, format="setup-cfg")
    assert captured.value.code == code
    assert "SECRET" not in repr(captured.value)
    assert captured.value.__context__ is None


@pytest.mark.parametrize("content", [b"\xff", b"pkg\x00SECRET"])
def test_invalid_encoding_has_a_fixed_error(content: bytes) -> None:
    """Reject invalid UTF-8 or NUL-containing content (bytes) without results.

    Return None; AssertionError/pytest failure signals mismatch. No side effects.
    """
    with pytest.raises(DependencyInputError) as captured:
        parse_python_dependencies(
            content, format="requirements", limits=DependencyLimits()
        )
    assert captured.value.code == "dependency-encoding"
    assert str(captured.value) == "Dependency input must use valid UTF-8."


@pytest.mark.parametrize("newline", ["\n", "\r\n", "\r"])
def test_setup_cfg_line_endings_keep_physical_lines(newline: str) -> None:
    """Parse newline (str) consistently without changing physical anchors.

    Return None; AssertionError signals mismatch. No external side effects.
    """
    text = newline.join(["[options]", "install_requires =", "    first", "    second"])
    result = parse(text, format="setup-cfg")
    # Each list member must retain its original physical line after normalization.
    assert [(c.name, c.anchor.line) for c in result.candidates] == [
        ("first", 3),
        ("second", 4),
    ]


@pytest.mark.parametrize("format", ["requirements", "setup-cfg"])
@pytest.mark.parametrize(
    "field", ["max_bytes", "max_lines", "max_nodes", "max_text_bytes", "max_candidates"]
)
def test_resource_exhaustion_discards_complete_population(
    format: Literal["requirements", "setup-cfg"], field: str
) -> None:
    """Exhaust field (str) for format (Literal['requirements', 'setup-cfg']).

    Return None; AssertionError/pytest failure signals mismatch. No side effects.
    """
    # Select equivalent two-record populations for each format's boundary check.
    text = (
        "first\nsecond"
        if format == "requirements"
        else "[options]\ninstall_requires = first\n    second"
    )
    limits = replace(DependencyLimits(), **{field: 1})
    with pytest.raises(DependencyInputError) as captured:
        parse(text, format=format, limits=limits)
    assert captured.value.code == "dependency-limit"


@pytest.mark.parametrize("format", ["requirements", "setup-cfg"])
def test_exact_work_and_retention_budgets_are_deterministic(
    format: Literal["requirements", "setup-cfg"],
) -> None:
    """Prove exact budgets for format (Literal['requirements', 'setup-cfg']).

    Return None; AssertionError/pytest failure signals mismatch. No side effects.
    """
    # Both representations carry the same marker/extras declaration.
    text = (
        "pkg[a]; os_name == 'x'"
        if format == "requirements"
        else "[options]\ninstall_requires = pkg[a]; os_name == 'x'"
    )
    result = parse(text, format=format)
    limits = replace(
        DependencyLimits(),
        max_nodes=result.consumed_nodes,
        max_text_bytes=result.consumed_text_bytes,
        max_candidates=1,
        max_bytes=len(text.encode()),
        max_lines=text.count("\n") + 1,
    )
    assert parse(text, format=format, limits=limits) == result
    # Independently tighten work and retention to prove both exact boundaries.
    for field in ("max_nodes", "max_text_bytes"):
        with pytest.raises(DependencyInputError) as captured:
            parse(
                text,
                format=format,
                limits=replace(limits, **{field: getattr(limits, field) - 1}),
            )
        assert captured.value.code == "dependency-limit"


def test_unsupported_selector_is_a_fixed_caller_error() -> None:
    """Reject an unselected executable format without evaluation; no inputs.

    Return None; pytest failure signals mismatch. No external side effects.
    """
    with pytest.raises(ValueError, match="Unsupported Python dependency format"):
        parse("SECRET", format=cast("Literal['requirements', 'setup-cfg']", "setup.py"))


@pytest.mark.parametrize("width", [4000, 8000, 16000])
@pytest.mark.parametrize("valid", [False, True])
def test_ini_option_matcher_has_disjoint_linear_grammar(
    width: int, valid: bool, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Match width (int) spaces with/without delimiter selected by valid (bool).

    monkeypatch (pytest.MonkeyPatch) restores parser instrumentation. Return None;
    AssertionError/pytest failure signals drift. No external side effects.
    """
    calls: list[bool] = []
    original = configparser.ConfigParser.read_string
    text = "name" + " " * width + ("= SECRET" if valid else "SECRET")

    def read_string(
        self: configparser.ConfigParser, string: str, source: str = "<string>"
    ) -> None:
        """Check actual self (ConfigParser) matcher for string/source (str) input.

        Return None; AssertionError rejects drift, configparser.Error propagates.
        Mutates local parser/calls only; no external side effects.
        """
        assert self.OPTCRE.pattern == r"(?P<option>[^=]+)(?P<vi>=)(?P<value>.*)$"
        match = self.OPTCRE.match(text)
        assert (match is not None) == valid
        # A delimiter makes whitespace part of the name, never a competing group.
        if match is not None:
            assert match.group("option", "vi", "value") == (
                "name" + " " * width,
                "=",
                " SECRET",
            )
        calls.append(True)
        original(self, string, source)

    monkeypatch.setattr(configparser.ConfigParser, "read_string", read_string)
    # Both accepted and malformed lines must pass through the same bounded matcher.
    if valid:
        assert parse("[metadata]\n" + text, format="setup-cfg").candidates == ()
    else:
        with pytest.raises(DependencyInputError) as caught:
            parse("[metadata]\n" + text, format="setup-cfg")
        assert caught.value.code == "dependency-malformed"
    assert calls == [True]


@pytest.mark.parametrize("width", [4000, 8000, 16000])
@pytest.mark.parametrize("section", ["metadata", "options"])
def test_ini_whitespace_work_is_linear_for_selected_and_other_sections(
    width: int, section: str
) -> None:
    """Charge width (int) extra spaces in section (str) without quadratic work.

    Return None; AssertionError signals budget/result drift. No side effects.
    """
    prefix = "[" + section + "]\ninstall_requires"
    base = parse(prefix + "=pkg", format="setup-cfg")
    padded = parse(prefix + " " * width + "=pkg", format="setup-cfg")
    assert padded.candidates == base.candidates
    assert padded.consumed_nodes - base.consumed_nodes == 2 * width
    assert padded.consumed_text_bytes - base.consumed_text_bytes == 5 * width


@pytest.mark.parametrize("width", [4000, 8000, 16000])
@pytest.mark.parametrize("section", ["metadata", "options"])
def test_ini_malformed_whitespace_is_reserved_before_matching(
    width: int, section: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Bound invalid width (int) spaces in section (str) using monkeypatch fixture.

    monkeypatch (pytest.MonkeyPatch) restores budget instrumentation. Return None;
    AssertionError/pytest failure signals mismatch. No external side effects.
    """
    budgets: list[DependencyBudget] = []
    original = DependencyBudget.reserve

    def reserve(
        self: DependencyBudget,
        *,
        nodes: int = 0,
        candidates: int = 0,
        text_bytes: int = 0,
    ) -> None:
        """Capture self (DependencyBudget); charge nodes/candidates/text_bytes (int).

        Return None; propagate DependencyInputError; mutate local budget/list only.
        """
        budgets.append(self)
        original(self, nodes=nodes, candidates=candidates, text_bytes=text_bytes)

    monkeypatch.setattr(DependencyBudget, "reserve", reserve)
    text = "[" + section + "]\ninstall_requires" + " " * width + "SECRET"
    with pytest.raises(DependencyInputError) as caught:
        parse(text, format="setup-cfg")
    assert caught.value.code == "dependency-malformed"
    assert "SECRET" not in str(caught.value)
    charged = budgets[-1].result()
    assert charged.candidates == ()
    assert charged.consumed_nodes == 2 * (len(text) + 1)
    assert charged.consumed_text_bytes == 5 * len(text)
