"""Exercise the shared dependency contract entirely with immutable memory values."""

from dataclasses import FrozenInstanceError, replace
from typing import Protocol, cast

import pytest
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyAnchor,
    DependencyBudget,
    DependencyCandidate,
    DependencyLimits,
    DependencyResult,
    DependencyValue,
    Ecosystem,
    dependency_value,
    safe_identifier,
)


class _InjectedAdd(Protocol):
    """Typed injection seam for malformed parser kwargs in isolated tests.

    Cast a bound collector method, call once, and require its runtime validation.
    This protocol stores no state and introduces no filesystem or process effects."""

    def __call__(self, **values: object) -> None:
        """Forward values (object kwargs) to validation; return None.

        The collector may raise ValueError; any mutation remains in its local budget."""
        ...


def candidate(**changes: object) -> DependencyCandidate:
    """Build a valid carrier with changes (object kwargs) for constructor tests.

    Return DependencyCandidate; propagate ValueError for rejected overrides.
    Only isolated immutable values are constructed; no I/O occurs."""
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
    """Call budget (DependencyBudget) with changes (object kwargs); return None.

    Mutate only this isolated collector. Propagate its ValueError or
    DependencyInputError so each test can assert the intended rejection."""
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
    """Classify raw (str | None) using ecosystem (Ecosystem).

    Return None after comparing expected (str | None); no I/O or expected error."""
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
    """Classify raw (str | None) into kind (str) and value (str | None).

    Return None after safe/redacted comparison; no mutation or expected error."""
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
    """Reject a noncanonical kind (str) and value (str | None) carrier pair.

    Return None; catch expected ValueError without I/O or state mutation."""
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
    """Reject values (dict[str, object]) overriding a closed source anchor.

    Return None; catch ValueError without accessing source bytes or global state."""
    with pytest.raises(ValueError, match="Dependency|JSON|Text"):
        replace(DependencyAnchor("json", ""), **values)


def test_closed_anchors_preserve_json_occurrences_and_xml_lines() -> None:
    """Verify closed JSON occurrences and parser-reported XML lines; return None.

    No arguments, expected errors, external mutation or source reads."""
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
    """Reject changes (dict[str, object]) that bypass candidate sanitization.

    Return None; catch ValueError using only local immutable fixtures."""
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
    """Reject changes (dict[str, object]) to result tuples or usage counters.

    Return None; catch ValueError without external side effects."""
    with pytest.raises(ValueError):
        replace(DependencyResult(), **changes)


def test_carriers_are_immutable_and_preserve_distinct_dependency_kinds() -> None:
    """Verify separate declaration/locked/edge facts and immutability; return None.

    No arguments or I/O; catch FrozenInstanceError on local assignment attempts."""
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
    """Decode content (bytes) within lines (int) into expected (str).

    Return None; exercise exact capacity/BOM/newlines without I/O or expected errors."""
    budget = DependencyBudget(
        DependencyLimits(max_bytes=max(len(content), 1), max_lines=lines)
    )
    assert budget.decode(content) == expected
    assert budget.result() == DependencyResult()


def test_shared_collector_redacts_values_and_keeps_requested_separate() -> None:
    """Verify sanitized fields and separate requested/version roles; return None.

    No arguments or expected errors; only the local collector is mutated."""
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
    """Charge each fixed code once while preserving earlier snapshots; return None.

    No arguments, expected errors or I/O; mutate only the local collector."""
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


def test_empty_and_repeated_results_are_deterministic() -> None:
    """Compare two independent empty/repeated collection sequences; return None.

    No arguments or expected errors; mutate only each isolated collector."""
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


def test_value_split_preserves_public_import_identity_and_signatures() -> None:
    """Verify moved public values remain identical re-exports; return None.

    No arguments, expected errors or mutation; inspect only imported callables.
    """
    from inspect import signature

    from drm_copilot_discovery.analyzer import dependency_values

    assert DependencyValue is dependency_values.DependencyValue
    assert Ecosystem is dependency_values.Ecosystem
    assert safe_identifier is dependency_values.safe_identifier
    assert dependency_value is dependency_values.dependency_value
    assert tuple(signature(safe_identifier).parameters) == ("value", "ecosystem")
    assert signature(safe_identifier).parameters["ecosystem"].default == "python"
    assert tuple(signature(dependency_value).parameters) == ("value",)
    assert tuple(signature(DependencyValue).parameters) == ("kind", "value")
    assert signature(DependencyValue).parameters["value"].default is None
