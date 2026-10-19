"""Verify dependency work and allocation boundaries using only memory values."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, SupportsIndex, cast

import pytest
from drm_copilot_discovery.analyzer import dependency_values
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyBudget,
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
    dependency_value,
    safe_identifier,
)

from tests.discovery_runtime.analyzer.test_dependency_inputs import add

if TYPE_CHECKING:
    from collections.abc import Iterator


@pytest.mark.parametrize(
    "field",
    [
        "max_bytes",
        "max_nodes",
        "max_depth",
        "max_candidates",
        "max_text_bytes",
        "max_lines",
    ],
)
@pytest.mark.parametrize("value", [True, False, 0, -1, 1.5, "2", None])
def test_limits_reject_nonpositive_and_noninteger_capacities(
    field: str, value: object
) -> None:
    """Reject field (str) with invalid value (object) before input processing.

    Return None; the expected ValueError is caught. No external mutation occurs."""
    with pytest.raises(ValueError, match="positive integers"):
        replace(DependencyLimits(), **{field: value})


@pytest.mark.parametrize(
    ("limits", "content", "code"),
    [
        (DependencyLimits(max_bytes=1), b"ab", "dependency-limit"),
        (DependencyLimits(max_lines=1), b"a\nb", "dependency-limit"),
        (DependencyLimits(), b"\xffsecret", "dependency-encoding"),
    ],
)
def test_decode_failures_poison_partial_result(
    limits: DependencyLimits, content: bytes, code: str
) -> None:
    """Reject content (bytes) under limits (DependencyLimits) with code (str).

    Return None; catch fixed errors and verify local result poisoning, with no I/O."""
    budget = DependencyBudget(limits)
    add(budget)
    with pytest.raises(DependencyInputError) as caught:
        budget.decode(content)
    assert caught.value.code == code and "secret" not in str(caught.value)
    with pytest.raises(DependencyInputError, match="limit"):
        budget.result()


@pytest.mark.parametrize("capacity", ["nodes", "candidates", "text_bytes"])
def test_reservations_are_prospective_independent_and_fail_closed(
    capacity: str,
) -> None:
    """Exhaust capacity (str counter name), then reject all output; return None.

    Catch DependencyInputError; mutate only an isolated collector."""
    budget = DependencyBudget(
        DependencyLimits(max_nodes=2, max_candidates=2, max_text_bytes=2)
    )
    budget.reserve(**{capacity: 2})
    with pytest.raises(DependencyInputError) as caught:
        budget.reserve(**{capacity: 1})
    assert caught.value.code == "dependency-limit"
    with pytest.raises(DependencyInputError):
        budget.result()
    with pytest.raises(DependencyInputError):
        budget.decode(b"")


@pytest.mark.parametrize("value", [True, -1, 0.5, "1"])
def test_invalid_reservation_does_not_consume_capacity(value: object) -> None:
    """Reject value (object) as an invalid work reservation; return None.

    Catch ValueError and verify unchanged local counters; no I/O occurs."""
    budget = DependencyBudget(DependencyLimits())
    with pytest.raises(ValueError):
        budget.reserve(nodes=cast("int", value))
    assert budget.result() == DependencyResult()


def test_encoded_candidate_and_raw_text_reservations_are_aggregate() -> None:
    """Verify exact UTF-8/retained cost and aggregate overflow; return None.

    No arguments or I/O; catch DependencyInputError from local collectors."""
    probe = DependencyBudget(DependencyLimits())
    add(probe, name="café")
    used = probe.result().consumed_text_bytes
    budget = DependencyBudget(DependencyLimits(max_text_bytes=used))
    add(budget, name="café")
    assert budget.result() == probe.result()
    with pytest.raises(DependencyInputError):
        add(budget)
    with pytest.raises(DependencyInputError):
        budget.result()
    short = DependencyBudget(DependencyLimits(max_text_bytes=used - 1))
    with pytest.raises(DependencyInputError):
        add(short, name="café")


@pytest.mark.parametrize(
    ("text", "capacity", "code"),
    [
        ("secret" * 9, 10, "dependency-limit"),
        ("é" * 4, 5, "dependency-limit"),
        ("\ud800secret", 500, "dependency-encoding"),
    ],
)
def test_selected_scalar_bounds_precede_unsafe_storage(
    text: str, capacity: int, code: str
) -> None:
    """Reject text (str) against capacity (int bytes) with code (str).

    Return None; catch fixed errors and assert poisoning without external effects."""
    budget = DependencyBudget(DependencyLimits(max_text_bytes=capacity))
    with pytest.raises(DependencyInputError) as caught:
        add(budget, name=text)
    assert caught.value.code == code and "secret" not in str(caught.value)
    with pytest.raises(DependencyInputError):
        budget.result()


@pytest.mark.parametrize(
    "changes", [{"extras": ["extra"]}, {"markers": ["extra"]}, {"name": 1}]
)
def test_collector_rejects_invalid_argument_types(changes: dict[str, object]) -> None:
    """Reject changes (dict[str, object]) injected as invalid parser arguments.

    Return None; catch ValueError and inspect the isolated collector without I/O."""
    budget = DependencyBudget(DependencyLimits())
    with pytest.raises(ValueError):
        add(budget, **changes)
    assert budget.result().candidates == ()


def test_public_contract_invalid_types_and_fixed_error_messages() -> None:
    """Verify malformed public calls retain only fixed errors; return None.

    No arguments or I/O; catch expected ValueErrors from local values/collectors."""
    with pytest.raises(ValueError, match="validated limits"):
        DependencyBudget(cast("DependencyLimits", None))
    with pytest.raises(ValueError, match="text or null"):
        safe_identifier(cast("str", 1))
    with pytest.raises(ValueError, match="text or null"):
        dependency_value(cast("str", 1))
    with pytest.raises(ValueError, match="retained bytes"):
        DependencyBudget(DependencyLimits()).decode(cast("bytes", "raw"))
    with pytest.raises(ValueError, match="Unknown"):
        DependencyInputError("raw secret")
    with pytest.raises(ValueError, match="Unknown"):
        DependencyBudget(DependencyLimits()).note("raw secret")


class _TextProbe(str):
    """Count local character work and forbid encoding allocation in memory tests.

    Construct one probe per case, invoke the scanner, then inspect visits and
    encode_calls. Reads mutate only these counters; text stays immutable. No
    timing, filesystem, process or global state participates in the assertions.
    """

    visits: int
    encode_calls: int

    def __new__(cls, value: str) -> _TextProbe:
        """Construct value (str) with fresh counters; return _TextProbe without I/O.

        No expected errors; only the newly created instance is initialized.
        """
        result = super().__new__(cls, value)
        result.visits = result.encode_calls = 0
        return result

    def __getitem__(self, key: SupportsIndex | slice) -> str:
        """Read key (index or slice), count its characters and return str.

        Mutate visits only; ordinary IndexError propagates for an invalid index.
        """
        result = super().__getitem__(key)
        self.visits += len(result)
        return result

    def __iter__(self) -> Iterator[str]:
        """Yield characters as Iterator[str], counting each visit; no arguments.

        Only visits mutates; no expected errors or external effects.
        """
        # Count scalar inspection independently of the implementation's byte math.
        for character in super().__iter__():
            self.visits += 1
            yield character

    def encode(self, encoding: str = "utf-8", errors: str = "strict") -> bytes:
        """Reject allocation for encoding/errors (str codec options); never return.

        Increment encode_calls and raise AssertionError if production encodes.
        """
        self.encode_calls += 1
        raise AssertionError("UTF-8 reservation must precede encoding allocation")


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("1-" + "a-" * 28 + "!", None),
        ("1-" + "a" * 253 + "!", None),
        ("1-" + "a" * 254, "literal"),
        ("1.a.b.c-alpha+build", "literal"),
        ("1-a+a+a+!", None),
        ("1-a+", None),
        ("1-+a", None),
        ("1.", None),
        ("v", None),
        ("1.2.*", "constraint"),
    ],
)
def test_version_scanning_has_linear_counted_character_work(
    raw: str,
    expected: str | None,
) -> None:
    """Scan raw (str) with expected (str | None) grammar category; return None.

    Assert a deterministic character-work bound; only local probe counters mutate.
    No elapsed-time assertion, external effects or expected exception is involved.
    """
    probe = _TextProbe(raw)
    classified = dependency_value(probe)
    assert probe.visits <= 16 * len(raw) + 64
    assert probe.encode_calls == 0
    assert classified.kind == (expected or "unsupported")
    assert classified.value == (raw if expected else None)


@pytest.mark.parametrize(
    ("raw", "kind"),
    [
        ("1.*", "constraint"),
        ("1.x", "constraint"),
        ("1.X", "constraint"),
        ("1.2.*", "constraint"),
        ("x", "constraint"),
        ("X", "constraint"),
        (">=1.x,<2", "constraint"),
        (">=1-" + "a" * 252, "constraint"),
        ("1.2.3-alpha.1+build-2", "literal"),
        ("1.xx", "literal"),
        ("1.0-beta-x", "literal"),
        ("1.2.3", "literal"),
        (">===1", "unsupported"),
        (">=1-" + "a-" * 28 + "!", "unsupported"),
        ("1..2", "unsupported"),
        ("1-é", "unsupported"),
        ("1-a++b", "unsupported"),
        ("1\n", "unsupported"),
    ],
)
def test_wildcards_and_adversarial_constraints_remain_syntactic(
    raw: str,
    kind: str,
) -> None:
    """Classify raw (str) as kind (str) without resolution; return None.

    No mutation, expected errors or I/O; unsafe grammar must discard its value.
    """
    result = dependency_value(raw)
    assert result.kind == kind
    assert result.value == (None if kind == "unsupported" else raw)


def test_overlength_values_never_enter_version_scanning(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Reject overlength grammar before scanning; return None.

    monkeypatch (pytest.MonkeyPatch) isolates a scanner fault restored by pytest.
    AssertionError is forbidden; the classifier must return a redacted value.
    """

    def forbidden(value: str) -> str | None:
        """Reject any value (str); raise AssertionError instead of returning.

        No mutation or I/O; this proves the public length guard executes first.
        """
        raise AssertionError("Overlength value reached the grammar scanner")

    monkeypatch.setattr(dependency_values, "_version_term", forbidden)
    assert dependency_value("1" * 257).kind == "unsupported"


@pytest.mark.parametrize(
    ("text", "width"),
    [("A", 1), ("é", 2), ("漢", 3), ("😀", 4)],
)
def test_exact_utf8_capacity_requires_no_encoding_allocation(
    text: str,
    width: int,
) -> None:
    """Reserve text (str) at width (int UTF-8 bytes); return None.

    Mutate only local probes/budgets, catch subsequent overflow, and forbid encode.
    """
    reference = DependencyBudget(DependencyLimits())
    add(reference, version="Z")
    expected = reference.result().consumed_text_bytes - 1 + width
    probe = _TextProbe(text)
    budget = DependencyBudget(DependencyLimits(max_text_bytes=expected + 2))
    budget.reserve(text_bytes=2)
    add(budget, version=probe)
    assert budget.result().consumed_text_bytes == expected + 2
    assert probe.visits <= 8 * len(text) + 32 and probe.encode_calls == 0
    with pytest.raises(DependencyInputError, match="limit"):
        add(budget, version=text)
    with pytest.raises(DependencyInputError):
        budget.result()


@pytest.mark.parametrize(
    ("text", "used", "capacity", "code", "visits"),
    [
        ("😀" * 3, 0, 5, "dependency-limit", 2),
        ("é" * 3, 3, 8, "dependency-limit", 3),
        ("A" * 6, 0, 5, "dependency-limit", 0),
        ("A\ud800", 0, 5, "dependency-encoding", 2),
        ("\udfff", 0, 5, "dependency-encoding", 1),
    ],
)
def test_public_collection_rejects_before_encoding_or_candidate_allocation(
    text: str,
    used: int,
    capacity: int,
    code: str,
    visits: int,
) -> None:
    """Reject text (str) after used bytes (int) within capacity (int).

    Return None; catch code (str), compare visits (int) and forbid encoding.
    All mutation is confined to local probes/budgets; no external side effects.
    """
    probe = _TextProbe(text)
    budget = DependencyBudget(DependencyLimits(max_text_bytes=capacity))
    budget.reserve(text_bytes=used)
    with pytest.raises(DependencyInputError) as caught:
        add(budget, name=probe)
    assert caught.value.code == code
    assert probe.visits == visits and probe.encode_calls == 0
    with pytest.raises(DependencyInputError):
        budget.result()
