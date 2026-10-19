"""Exercise the shared dependency contract entirely with immutable memory values."""

from dataclasses import FrozenInstanceError, replace
from typing import Protocol, cast

import pytest
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyAnchor,
    DependencyBudget,
    DependencyCandidate,
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
    DependencyValue,
    Ecosystem,
    dependency_value,
    safe_identifier,
)


class _InjectedAdd(Protocol):
    """Allow intentional malformed keyword values at the isolated runtime boundary."""

    def __call__(self, **values: object) -> None:
        """Forward injected values; the real collector must validate or reject them."""
        ...


def candidate(**changes: object) -> DependencyCandidate:
    """Return an isolated valid candidate with intentional constructor overrides."""
    item = DependencyCandidate(
        "declaration",
        "python",
        "package",
        DependencyValue("literal", "1.2"),
        "install",
        DependencyAnchor("text", "requirements", line=1),
    )
    return replace(item, **changes)


def add(budget: DependencyBudget, **changes: object) -> None:
    """Append valid or intentionally malformed values; mutate only its budget."""
    values: dict[str, object] = {
        "kind": "declaration",
        "ecosystem": "python",
        "name": "package",
        "version": "1.2",
        "role": "install",
        "anchor": DependencyAnchor("text", "requirements", line=1),
    }
    values.update(changes)
    cast("_InjectedAdd", budget.add)(**values)


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
    """Reject invalid capacities before processing input; return no result."""
    with pytest.raises(ValueError, match="positive integers"):
        replace(DependencyLimits(), **{field: value})


@pytest.mark.parametrize(
    ("ecosystem", "raw", "expected"),
    [
        ("node", "@scope/pkg", "@scope/pkg"),
        ("node", "pkg-name", "pkg-name"),
        ("node", "Upper", None),
        ("python", "Example_Package", "Example_Package"),
        ("dotnet", "Example.Package", "Example.Package"),
        ("python", None, None),
        ("python", "", None),
        ("node", "node_modules/pkg", None),
        ("python", "../secret", None),
        ("python", "https://user:secret@example.test", None),
        ("node", "@scope/../../secret", None),
        ("python", "café", None),
        ("python", "a" * 128, "a" * 128),
        ("python", "a" * 129, None),
    ],
)
def test_identifier_allowlists_keep_only_literal_names(
    ecosystem: Ecosystem, raw: str | None, expected: str | None
) -> None:
    """Classify a package name without exposing an unsafe spelling in output."""
    assert safe_identifier(raw, ecosystem=ecosystem) == expected


@pytest.mark.parametrize(
    ("raw", "kind", "value"),
    [
        (None, "missing", None),
        ("", "missing", None),
        ("1.2.3", "literal", "1.2.3"),
        ("v1.0-beta+build", "literal", "v1.0-beta+build"),
        (">=1.2,<2", "constraint", ">=1.2,<2"),
        ("[1.0,2.0)", "constraint", "[1.0,2.0)"),
        ("^1.0 || ~2.0", "constraint", "^1.0 || ~2.0"),
        ("*", "constraint", "*"),
        ("next", "tag", "next"),
        ("workspace:*", "workspace", None),
        ("npm:other@1", "alias", None),
        ("git+https://secret", "vcs", None),
        ("hg+ssh://secret", "vcs", None),
        ("svn+https://secret", "vcs", None),
        ("https://name:secret@example.test/a", "url", None),
        ("file:../secret", "local", None),
        ("link:../secret", "local", None),
        ("./secret", "local", None),
        ("../secret", "local", None),
        ("/secret", "local", None),
        ("\\secret", "local", None),
        ("Z:\\secret", "local", None),
        ("$(Secret)", "dynamic", None),
        ("%Secret%", "dynamic", None),
        ("{secret}", "dynamic", None),
        ("private-token", "unsupported", None),
        ("1.0; secret", "unsupported", None),
        ("1" * 257, "unsupported", None),
        ("|||", "unsupported", None),
    ],
)
def test_version_classification_never_retains_reference_targets(
    raw: str | None, kind: str, value: str | None
) -> None:
    """Retain finite version grammar or a fixed redacted reference classification."""
    assert dependency_value(raw) == DependencyValue(kind, value)


@pytest.mark.parametrize(
    ("kind", "value"),
    [
        ("wrong", None),
        ("literal", "secret"),
        ("constraint", "1.0"),
        ("tag", None),
        ("local", "secret"),
    ],
)
def test_value_constructor_cannot_bypass_sanitization(
    kind: str, value: str | None
) -> None:
    """Directly construct an invalid carrier; expect a fixed contract error."""
    with pytest.raises(ValueError, match="dependency|Dependency|Redacted"):
        DependencyValue(kind, value)


@pytest.mark.parametrize(
    "values",
    [
        {"format": "json", "location": "/packages/secret~1path"},
        {"format": "json", "location": "/packages/https:~1~1secret"},
        {"format": "json", "location": '/packages/secret"key'},
        {"format": "xml", "location": "unknown", "line": 1},
        {"format": "other", "location": ""},
        {"format": "json", "location": "/packages", "occurrence": True},
        {"format": "json", "location": "/packages", "occurrence": 0},
        {"format": "json", "location": "/packages", "line": 1},
        {"format": "text", "location": "requirements"},
        {"format": "xml", "location": "PackageVersion", "line": False},
        {"format": "text", "location": "requirements", "line": -1},
    ],
)
def test_anchor_rejects_dynamic_keys_or_fabricated_spans(
    values: dict[str, object],
) -> None:
    """Reject unsafe key interpolation and invalid locations without source access."""
    with pytest.raises(ValueError, match="Dependency|JSON|Text"):
        replace(DependencyAnchor("json", ""), **values)


def test_closed_anchors_preserve_json_occurrences_and_xml_lines() -> None:
    """Keep container membership and parser-reported line identity without raw keys."""
    first = DependencyAnchor("json", "/packages", occurrence=1)
    second = replace(first, occurrence=2)
    xml = DependencyAnchor("xml", "VersionOverride", occurrence=4, line=9)
    assert first != second
    assert first.line is None and second.location == "/packages"
    assert xml.line == 9 and xml.occurrence == 4


@pytest.mark.parametrize(
    "changes",
    [
        {"kind": "executed"},
        {"ecosystem": "unknown"},
        {"name": "../secret"},
        {"owner": "https://secret"},
        {"role": ""},
        {"role": "secret/path"},
        {"version": "1.0"},
        {"requested": "1.0"},
        {"anchor": "secret"},
        {"operation": "execute"},
        {"condition_present": 1},
        {"extras": ["extra"]},
        {"markers": ["extra"]},
        {"extras": ("",)},
        {"extras": ("../secret",)},
        {"markers": ("secret",)},
    ],
)
def test_candidate_rejects_unsanitized_or_mutable_metadata(
    changes: dict[str, object],
) -> None:
    """Attempt a direct carrier bypass and expect a deterministic ValueError."""
    with pytest.raises(ValueError):
        candidate(**changes)


@pytest.mark.parametrize(
    "changes",
    [
        {"candidates": []},
        {"candidates": ("raw",)},
        {"diagnostics": []},
        {"diagnostics": ("raw",)},
        {"consumed_nodes": -1},
        {"consumed_text_bytes": True},
    ],
)
def test_result_rejects_mutable_unsanitized_and_invalid_usage(
    changes: dict[str, object],
) -> None:
    """Construct malformed result payloads; expect validation without side effects."""
    with pytest.raises(ValueError):
        replace(DependencyResult(), **changes)


def test_carriers_are_immutable_and_preserve_distinct_dependency_kinds() -> None:
    """Keep independent declaration/locked/edge facts with unresolved identity."""
    item = candidate()
    locked = replace(
        item, kind="locked-package", requested=DependencyValue("constraint", ">=1")
    )
    edge = replace(item, kind="declared-lock-edge", owner="parent")
    result = DependencyResult(
        (item, locked, edge), ("dependency-binding-unresolved",), 3, 100
    )
    assert result.candidates[1].version.value == "1.2"
    assert result.candidates[1].requested.value == ">=1"
    assert result.candidates[2].owner == "parent"
    # Assignment through dynamic field names exercises frozen runtime enforcement.
    for target, field in ((item, "name"), (result, "candidates")):
        with pytest.raises(FrozenInstanceError):
            setattr(target, field, None)


@pytest.mark.parametrize(
    ("content", "lines", "expected"),
    [
        (b"", 1, ""),
        (b"one", 1, "one"),
        (b"one\r\ntwo\rthree\n", 3, "one\r\ntwo\rthree\n"),
        (b"\r\n", 1, "\r\n"),
        (b"\xef\xbb\xbfhello", 1, "hello"),
        ("café".encode(), 1, "café"),
    ],
)
def test_decode_preserves_valid_text_with_physical_line_boundaries(
    content: bytes, lines: int, expected: str
) -> None:
    """Decode exact-capacity retained bytes, including BOM and CRLF/CR/LF boundaries."""
    budget = DependencyBudget(
        DependencyLimits(max_bytes=max(len(content), 1), max_lines=lines)
    )
    assert budget.decode(content) == expected
    assert budget.result() == DependencyResult()


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
    """Reject byte/line/encoding violations and forbid returning earlier candidates."""
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
    """Reserve the exact independent capacity; the next unit invalidates all output."""
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
    """Reject noninteger/negative reservations without mutating the valid budget."""
    budget = DependencyBudget(DependencyLimits())
    with pytest.raises(ValueError):
        budget.reserve(nodes=cast("int", value))
    assert budget.result() == DependencyResult()


def test_shared_collector_redacts_values_and_keeps_requested_separate() -> None:
    """Sanitize output while retaining factual version roles and conditions."""
    budget = DependencyBudget(DependencyLimits())
    add(
        budget,
        name="../private",
        owner="https://credential",
        version="file:private",
        requested=">=1",
        role="private/path",
        extras=("safe", "bad/path", "safe"),
        markers=("python_version", "secret", "python_version"),
        condition_present=True,
    )
    result = budget.result()
    item = result.candidates[0]
    assert item.name is item.owner is None
    assert item.version == DependencyValue("local")
    assert item.requested == DependencyValue("constraint", ">=1")
    assert item.role == "redacted" and item.condition_present
    assert item.extras == ("safe",) and item.markers == ("python_version",)
    assert result.diagnostics == ("dependency-redacted",)
    assert "private" not in repr(result) and "credential" not in repr(result)


def test_diagnostic_deduplication_and_snapshot_isolation() -> None:
    """Charge fixed diagnostics once and isolate immutable snapshots."""
    budget = DependencyBudget(DependencyLimits())
    add(budget)
    before = budget.result()
    budget.note("dependency-ambiguous")
    charged = budget.result().consumed_text_bytes
    budget.note("dependency-ambiguous")
    budget.note("dependency-binding-unresolved")
    assert (
        budget.result().consumed_text_bytes
        == charged + len("dependency-binding-unresolved") + 2
    )
    assert before.diagnostics == () and len(before.candidates) == 1
    assert budget.result().diagnostics == (
        "dependency-ambiguous",
        "dependency-binding-unresolved",
    )


def test_encoded_candidate_and_raw_text_reservations_are_aggregate() -> None:
    """Charge UTF-8 work plus quoted retained strings before candidate storage."""
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
    """Reject oversized text, encoded bytes and surrogates with fixed errors."""
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
    """Inject invalid parser arguments; require an explicit ValueError before append."""
    budget = DependencyBudget(DependencyLimits())
    with pytest.raises(ValueError):
        add(budget, **changes)
    assert budget.result().candidates == ()


def test_public_contract_invalid_types_and_fixed_error_messages() -> None:
    """Reject public misuse without exposing raw parser messages or values."""
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


def test_empty_and_repeated_results_are_deterministic() -> None:
    """Preserve stable order without mutating earlier results or global state."""
    first, second = DependencyBudget(DependencyLimits()), DependencyBudget(
        DependencyLimits()
    )
    # Execute the same finite parser sequence in independent local collectors.
    for budget in (first, second):
        budget.reserve(nodes=4)
        add(budget, name=None, version=None, role="optional", owner=None)
        add(budget, ecosystem="node", name="@scope/pkg", version="^1.0", role="peer")
    assert first.result() == second.result()
    assert first.result().consumed_nodes == 4
    assert first.result().diagnostics == ()
