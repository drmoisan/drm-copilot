"""Pin the G10 whitespace class shared by the Python and TypeScript runtimes.

The G10 module decides three things with one explicit whitespace class,
`PLAN_WHITESPACE_CLASS`: whether a physical line is blank, whether it continues
the current logical line, and how a logical line is normalized. The fixtures
below are duplicated in
`extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`, so a
divergence in either runtime fails on both sides (issue #932 remediation
cycle 2).

Every special character is written as an escape: NEL, the unit separator, the
byte-order mark, and the no-break space are the characters on which the Python
whitespace predicate and the JavaScript whitespace class disagree, or which
pin the class against shrinking to ASCII.

Since remediation cycle 3 the class and its normalizer are declared once
per runtime, in `scripts/dev_tools/plan_gate_commands.py` and
`extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`, and G6
uses them as well; the declaration-count test pins that location.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

import scripts.dev_tools.plan_gate_commands as plan_gate_commands
from scripts.dev_tools.plan_gate_scratch import bare_scratch_definitions

_REPO_ROOT = Path(__file__).resolve().parents[3]
_TYPESCRIPT_MODULE = (
    _REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "src"
    / "lib"
    / "validate"
    / "plan-gate-commands.ts"
)
_WHITESPACE_CLASS_TS_RE = re.compile(
    r"PLAN_WHITESPACE_CLASS\s*=\s*String\.raw`([^`]*)`"
)
_PYTHON_DECLARATION_RE = re.compile(r"^PLAN_WHITESPACE_CLASS = ", re.MULTILINE)
_DECLARATION_COUNTS = {
    "scripts/dev_tools/plan_gate_commands.py": 1,
    "scripts/dev_tools/plan_gate_scratch.py": 0,
    "scripts/dev_tools/plan_gate_discrimination.py": 0,
    "extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts": 1,
    "extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts": 0,
    "extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts": 0,
}

_DEFINITION_LINE = "- SCRATCH means the session scratchpad."

_CONTINUATION_FIXTURES = (
    pytest.param(
        _DEFINITION_LINE + "\n\x85continued text",
        (1, "- SCRATCH means the session scratchpad."),
        id="nel-led",
    ),
    pytest.param(
        _DEFINITION_LINE + "\n\x1fcontinued text",
        (1, "- SCRATCH means the session scratchpad."),
        id="unit-separator-led",
    ),
    pytest.param(
        _DEFINITION_LINE + "\n\ufeffcontinued text",
        (1, "- SCRATCH means the session scratchpad."),
        id="bom-led",
    ),
    pytest.param(
        _DEFINITION_LINE + "\n\xa0continued text",
        (1, "- SCRATCH means the session scratchpad. continued text"),
        id="nbsp-led",
    ),
    pytest.param(
        _DEFINITION_LINE + "\n \x85",
        (1, "- SCRATCH means the session scratchpad. \x85"),
        id="space-then-nel",
    ),
)

_NORMALIZATION_FIXTURES = (
    pytest.param(
        "intro\x85SCRATCH is the session scratchpad.",
        (1, "intro\x85SCRATCH is the session scratchpad."),
        id="nel-inline",
    ),
    pytest.param(
        "intro\x1fSCRATCH is the session scratchpad.",
        (1, "intro\x1fSCRATCH is the session scratchpad."),
        id="unit-separator-inline",
    ),
    pytest.param(
        "intro\ufeffSCRATCH is the session scratchpad.",
        (1, "intro\ufeffSCRATCH is the session scratchpad."),
        id="bom-inline",
    ),
    pytest.param(
        "intro\xa0SCRATCH is the session scratchpad.",
        (1, "intro SCRATCH is the session scratchpad."),
        id="nbsp-inline",
    ),
)


def test_whitespace_class_matches_typescript() -> None:
    """The TypeScript module declares the identical whitespace class string."""

    # Arrange
    python_class: str = vars(plan_gate_commands)["PLAN_WHITESPACE_CLASS"]
    source = _TYPESCRIPT_MODULE.read_text(encoding="utf-8")

    # Act
    match = _WHITESPACE_CLASS_TS_RE.search(source)

    # Assert
    assert match is not None, (
        "PLAN_WHITESPACE_CLASS is not declared with String.raw in "
        "plan-gate-commands.ts"
    )
    typescript_class = match.group(1)
    assert typescript_class == python_class, (
        f"PLAN_WHITESPACE_CLASS differs: TypeScript `{typescript_class}`, "
        f"Python `{python_class}`"
    )
    assert typescript_class.isascii(), (
        "PLAN_WHITESPACE_CLASS in plan-gate-commands.ts must be written with "
        "escapes, not raw characters"
    )


def test_whitespace_class_declared_once_per_runtime() -> None:
    """Each runtime declares the class once, in its command extractor module."""

    # Arrange
    sources = {
        relative: (_REPO_ROOT / relative).read_text(encoding="utf-8")
        for relative in _DECLARATION_COUNTS
    }

    # Act
    counts = {
        relative: len(
            (
                _PYTHON_DECLARATION_RE
                if relative.endswith(".py")
                else _WHITESPACE_CLASS_TS_RE
            ).findall(source)
        )
        for relative, source in sources.items()
    }

    # Assert
    assert (
        counts == _DECLARATION_COUNTS
    ), f"PLAN_WHITESPACE_CLASS declarations differ: {counts}"


@pytest.mark.parametrize(("text", "expected"), _CONTINUATION_FIXTURES)
def test_continuation_uses_plan_whitespace_class(
    text: str, expected: tuple[int, str]
) -> None:
    """Continuation and the blank-line test use the shared whitespace class."""

    # Arrange
    document = text

    # Act
    findings = bare_scratch_definitions(document)

    # Assert
    assert findings == [expected], f"unexpected findings {findings}"


@pytest.mark.parametrize(("text", "expected"), _NORMALIZATION_FIXTURES)
def test_normalization_uses_plan_whitespace_class(
    text: str, expected: tuple[int, str]
) -> None:
    """Whitespace normalization uses the shared whitespace class."""

    # Arrange
    document = text

    # Act
    findings = bare_scratch_definitions(document)

    # Assert
    assert findings == [expected], f"unexpected findings {findings}"
