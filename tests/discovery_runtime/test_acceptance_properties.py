"""Exercise immutable acceptance identities, bounded values and exact tag policy."""

from __future__ import annotations

import json
from dataclasses import FrozenInstanceError, replace
from hashlib import sha256
from itertools import permutations
from typing import cast

import pytest
from drm_copilot_discovery.acceptance_models import (
    AcceptanceGeneration,
    AcceptanceIdentity,
    AcceptanceSpecification,
    acceptance_tags,
)
from drm_copilot_discovery.findings import Finding, Severity
from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
from drm_copilot_discovery.report_models import ReportLimitError, bounded_object
from drm_copilot_discovery.repository_reader import RepositoryIdentity


def identity(**changes: object) -> AcceptanceIdentity:
    """Apply changes (object fields) to a valid target key; return AcceptanceIdentity.

    Invalid replacements propagate ValueError. Creates only in-memory values.
    """
    return replace(
        AcceptanceIdentity(
            source_repository_id="source",
            kind="target-acceptance",
            feature_id="feature",
            criterion_id="criterion",
            client_id="browser",
            platform_id="web",
            mode_id="online",
        ),
        **changes,
    )


def specification(
    *,
    key: AcceptanceIdentity | None = None,
    text: str = "Expected.",
    readiness: str = "ready",
    repository: RepositoryIdentity | None = None,
    limits: ParseLimits | None = None,
) -> AcceptanceSpecification:
    """Build model data from key/text/readiness/owner/limits; return specification.

    Parameters are immutable typed values; defaults provide one target coordinate.
    This fixture proves model consistency, not semantic graph readiness. Invalid
    arguments propagate ValueError; no I/O or caller mutation occurs.
    """
    limits = limits or ParseLimits()
    key = key or identity()
    document = bounded_object(
        {
            "$schema": "urn:drm-copilot:discovery:2.0.0:acceptance-specification",
            "schema_version": "2.0.0",
            "artifact_kind": "acceptance-specification",
            "id": key.scenario_id(limits=limits),
            "scenario_id": key.scenario_id(limits=limits),
            "kind": key.kind,
            "feature_id": key.feature_id,
            "criterion_id": key.criterion_id,
            "client_id": key.client_id,
            "platform_id": key.platform_id,
            "mode_id": key.mode_id,
            "readiness": readiness,
            "given": ("Known precondition.",),
            "when": "Invoke.",
            "then": (text,) if readiness == "ready" else None,
            "pending_reasons": () if readiness == "ready" else ("Unresolved.",),
            "expectation_basis": (
                "verified-source" if readiness == "ready" else "unresolved"
            ),
            "source_contract_refs": (),
            "evidence_refs": (),
            "product_decision_refs": (),
            "tags": acceptance_tags(key, limits=limits),
            "source_content_sha256": "a" * 64,
            "extensions": {},
        },
        limits=limits,
    )
    return AcceptanceSpecification(
        repository=repository
        or RepositoryIdentity(
            id="source" if key.kind == "legacy-characterization" else "target",
            revision="a" * 40,
        ),
        identity=key,
        document=document,
        limits=limits,
    )


def generation(
    specifications: tuple[AcceptanceSpecification, ...] = (),
    ready: tuple[AcceptanceSpecification, ...] = (),
    findings: tuple[Finding, ...] = (),
    **changes: object,
) -> AcceptanceGeneration:
    """Build a result from immutable tuples and optional policy overrides.

    Returns AcceptanceGeneration; invalid membership/capacity raises ValueError.
    No graph assessment or external effects are performed.
    """
    return replace(
        AcceptanceGeneration(
            specifications=specifications,
            ready=ready,
            findings=findings,
            limits=ParseLimits(),
        ),
        **changes,
    )


def test_canonical_identity_bytes_and_full_digest_are_fixed() -> None:
    """Assert the published eight-field identity encoding; no inputs or I/O."""
    expected = (
        b'{"client_id":"browser","criterion_id":"criterion","feature_id":"feature",'
        b'"kind":"target-acceptance","linked_scenario":null,"mode_id":"online",'
        b'"platform_id":"web","source_repository_id":"source"}\n'
    )
    assert canonical_json(identity().key(limits=ParseLimits())) == expected
    assert (
        identity().scenario_id(limits=ParseLimits())
        == "scn-" + sha256(expected).hexdigest()
    )


@pytest.mark.parametrize(
    "changes",
    [
        {"source_repository_id": "other"},
        {"client_id": "other"},
        {"platform_id": "other"},
        {"mode_id": "offline"},
        {"mode_id": "custom-mode"},
        {"feature_id": "other"},
        {"criterion_id": "other"},
        {"linked_scenario": ("source", "original")},
        {"linked_scenario": ("other", "original")},
        {"kind": "legacy-characterization", "client_id": None},
    ],
)
def test_each_identity_coordinate_distinguishes_scenarios(
    changes: dict[str, object],
) -> None:
    """Vary changes (identity fields); assert distinct IDs without side effects."""
    assert identity(**changes).scenario_id(
        limits=ParseLimits()
    ) != identity().scenario_id(limits=ParseLimits())


@pytest.mark.parametrize(
    "value",
    ["", "Upper", "1start", "bad space", "a..b", "a-", "a/b", "é", "\ud800", 1, None],
)
def test_invalid_required_identifiers_are_rejected(value: object) -> None:
    """Reject malformed value (object) before retaining a key; expect ValueError."""
    with pytest.raises(ValueError):
        identity(feature_id=value)


@pytest.mark.parametrize(
    "changes",
    [
        {"kind": "unknown"},
        {"client_id": None},
        {"platform_id": None},
        {"kind": "legacy-characterization"},
        {"linked_scenario": ["source", "scenario"]},
        {"linked_scenario": ("source",)},
        {"linked_scenario": ("source", "Bad")},
    ],
)
def test_coordinate_contracts_reject_ambiguous_shapes(
    changes: dict[str, object],
) -> None:
    """Reject changes (invalid coordinate shapes); retain no mutable input."""
    with pytest.raises(ValueError):
        identity(**changes)


def test_identity_byte_boundary_and_limits_type() -> None:
    """Check exact canonical byte capacity and strict policy type; no I/O."""
    key = identity()
    size = len(canonical_json(key.key(limits=ParseLimits())))
    assert key.key(limits=ParseLimits(document_bytes=size))
    with pytest.raises(ReportLimitError):
        key.scenario_id(limits=ParseLimits(document_bytes=size - 1))
    with pytest.raises(ValueError):
        key.key(limits=cast("ParseLimits", {}))
    with pytest.raises(ReportLimitError):
        identity(feature_id="a" * 1000).key(limits=ParseLimits(artifact_records=1))


@pytest.mark.parametrize(
    "mode,mobile,expected",
    [
        ("online", False, ()),
        ("offline", False, ("@offline",)),
        ("mobile", False, ()),
        ("custom", True, ("@mobile",)),
        ("offline", True, ("@mobile", "@offline")),
    ],
)
def test_tags_require_actual_mode_and_explicit_mobile(
    mode: str,
    mobile: bool,
    expected: tuple[str, ...],
) -> None:
    """Use mode/mobile (explicit coordinates); assert exact special tags."""
    key = identity(mode_id=mode, feature_id="feat.a_b-c", client_id="mobile-name")
    tags = acceptance_tags(key, limits=ParseLimits(), mobile_applicable=mobile)
    # Ordinary coordinate tags must not silently imply either special applicability tag.
    assert tuple(tag for tag in tags if tag in ("@offline", "@mobile")) == expected
    assert "@feature_feat.a_b-c" in tags and "@client_mobile-name" in tags
    assert "@mode_" + mode in tags and "@platform_web" in tags
    assert "@scenario_" + key.scenario_id(limits=ParseLimits()) in tags
    assert tags == tuple(sorted(set(tags)))


def test_legacy_tags_omit_null_coordinates_and_reject_invalid_inputs() -> None:
    """Preserve explicit legacy absence; reject malformed tag arguments."""
    key = identity(kind="legacy-characterization", client_id=None, platform_id=None)
    tags = acceptance_tags(key, limits=ParseLimits())
    assert len(tags) == 3
    with pytest.raises(ValueError):
        acceptance_tags(cast("AcceptanceIdentity", {}), limits=ParseLimits())
    with pytest.raises(ValueError):
        acceptance_tags(key, limits=ParseLimits(), mobile_applicable=cast("bool", 1))
    with pytest.raises(ReportLimitError):
        acceptance_tags(key, limits=ParseLimits(document_bytes=10))


@pytest.mark.parametrize("text", ["Expected.", 'é😀\n\t\\"', "A changed statement."])
def test_detached_serialization_keeps_content_out_of_identity(text: str) -> None:
    """Vary text (str); verify exact JSON, detached views and unchanged identity."""
    item = specification(text=text)
    other = specification(text="Different.")
    plain = item.to_dict()
    assert json.loads(item.to_json()) == plain
    assert item.to_json().endswith("\n") and item.identity == other.identity
    assert item.document != other.document
    cast("list[object]", plain["given"]).append("Caller mutation.")
    assert item.document["given"] == ("Known precondition.",)
    assert "repository" not in plain
    attribute = "document"
    with pytest.raises(FrozenInstanceError):
        setattr(item, attribute, other.document)


def test_revisions_and_nonidentity_metadata_leave_scenario_id_unchanged() -> None:
    """Change pins/display metadata; retain identity while source content changes."""
    first = specification()
    second = replace(
        first, repository=RepositoryIdentity(id="target", revision="b" * 40)
    )
    document = first.to_dict()
    document["extensions"] = {"display_name": "Renamed", "unrelated": 3}
    third = replace(first, document=bounded_object(document, limits=ParseLimits()))
    assert first.identity == second.identity == third.identity
    assert first.repository != second.repository and first.document != third.document


@pytest.mark.parametrize(
    "field,value",
    [
        ("feature_id", "other"),
        ("id", "other"),
        ("scenario_id", "other"),
        ("artifact_kind", "other"),
        ("schema_version", "1.0.0"),
    ],
)
def test_specification_rejects_identity_projection_mismatch(
    field: str, value: str
) -> None:
    """Replace field with value (str); require explicit consistency failure."""
    item = specification()
    document = item.to_dict()
    document[field] = value
    with pytest.raises(ValueError, match="differs"):
        replace(item, document=bounded_object(document, limits=ParseLimits()))


@pytest.mark.parametrize("field", ["repository", "identity", "document", "limits"])
def test_specification_requires_exact_immutable_types(field: str) -> None:
    """Replace field (str) with a mutable mapping; expect ValueError."""
    with pytest.raises(ValueError):
        replace(specification(), **{field: {}})


def test_legacy_owner_and_unicode_encoded_budget() -> None:
    """Check source ownership and byte accounting without external fixtures."""
    key = identity(kind="legacy-characterization", client_id=None)
    item = specification(key=key, text="é😀")
    assert item.repository.id == "source"
    with pytest.raises(ValueError, match="source repository"):
        replace(item, repository=RepositoryIdentity(id="other", revision="a" * 40))
    size = (
        len(canonical_json(item.document))
        + len(
            canonical_json(
                bounded_object(item.repository.to_dict(), limits=ParseLimits())
            )
        )
        - 1
    )
    assert (
        replace(item, limits=ParseLimits(document_bytes=size)).to_json()
        == item.to_json()
    )
    with pytest.raises(ReportLimitError):
        replace(item, limits=ParseLimits(document_bytes=size - 1))
    plain = item.to_dict()
    plain["given"] = ["\ud800"]
    with pytest.raises(ValueError, match="Unicode"):
        bounded_object(plain, limits=ParseLimits())


def test_permutations_and_exact_duplicates_have_identical_results() -> None:
    """Check all finite permutations; deduplicate exact data and keep ready order."""
    left = specification()
    right = specification(key=identity(platform_id="desktop"))
    warning = Finding(
        code="REVIEW", message="Review.", next_action="Inspect.", severity="warning"
    )
    expected = generation((left, right), (right, left), (warning,))
    # Every ordering must retain the same qualified identity population and bytes.
    for records in permutations((left, right, left)):
        current = generation(records, (left, right), (warning, warning))
        assert current == expected
        # The ready view must retain the same serialized record ordering.
        assert tuple(item.to_json() for item in current.ready) == tuple(
            item.to_json() for item in expected.ready
        )
    assert generation().specifications == ()


@pytest.mark.parametrize("change", ["content", "owner"])
def test_conflicting_equal_keys_never_choose_by_order(change: str) -> None:
    """Create change (content/owner) under one key; reject both arrival orders."""
    first = specification()
    second = (
        specification(text="Conflict.")
        if change == "content"
        else replace(
            first, repository=RepositoryIdentity(id="other-target", revision="a" * 40)
        )
    )
    # Both orderings must fail rather than retaining whichever candidate arrives last.
    for records in ((first, second), (second, first)):
        with pytest.raises(ValueError, match="conflicting"):
            generation(records)


@pytest.mark.parametrize(
    "kind", ["absent", "content", "owner", "pending", "duplicate", "invalid"]
)
def test_ready_membership_requires_exact_unique_ready_candidate(kind: str) -> None:
    """Construct kind (invalid subset variant); require no ready authority."""
    item = specification()
    variants = {
        "absent": (specification(key=identity(platform_id="other")),),
        "content": (specification(text="Different."),),
        "owner": (
            replace(item, repository=RepositoryIdentity(id="other", revision=None)),
        ),
        "pending": (specification(readiness="pending"),),
        "duplicate": (item, item),
        "invalid": (cast("AcceptanceSpecification", object()),),
    }
    records = variants["pending"] if kind == "pending" else (item,)
    with pytest.raises(ValueError, match="ready subset"):
        generation(records, variants[kind])


@pytest.mark.parametrize("severity", ["error", "warning", "info"])
def test_findings_preserve_blocking_authority(severity: str) -> None:
    """Use severity (str) to distinguish errors from informational diagnostics."""
    finding = Finding(
        code="DIAGNOSTIC",
        message="Inspect.",
        next_action="Review.",
        severity=cast("Severity", severity),
    )
    item = specification()
    # Errors revoke ready membership; informational diagnostics remain visible.
    if severity == "error":
        with pytest.raises(ValueError, match="Blocking"):
            generation((item,), (item,), (finding,))
        assert generation((item,), findings=(finding,)).ready == ()
    else:
        assert generation((item,), (item,), (finding,)).ready == (item,)


@pytest.mark.parametrize(
    "field,value",
    [
        ("specifications", []),
        ("ready", []),
        ("findings", []),
        ("specifications", (None,)),
        ("findings", (None,)),
        ("limits", {}),
    ],
)
def test_generation_rejects_mutable_or_mistyped_values(
    field: str, value: object
) -> None:
    """Replace field with value (invalid data); require ValueError without traversal."""
    with pytest.raises(ValueError):
        replace(generation(), **{field: value})


def test_aggregate_limits_reject_before_unbounded_work(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Count key visits with monkeypatch; reject oversized populations before visits."""
    item = specification()
    calls: list[None] = []
    original = AcceptanceIdentity.key

    def observe(self: AcceptanceIdentity, *, limits: ParseLimits) -> JsonObject:
        """Count one bounded key request, then return original; propagate errors."""
        calls.append(None)
        return original(self, limits=limits)

    monkeypatch.setattr(AcceptanceIdentity, "key", observe)
    with pytest.raises(ReportLimitError):
        AcceptanceGeneration(
            specifications=(item,) * 3,
            ready=(),
            findings=(),
            limits=ParseLimits(artifact_records=2),
        )
    assert calls == []
    with pytest.raises(ReportLimitError):
        AcceptanceGeneration(
            specifications=(item,),
            ready=(),
            findings=(),
            limits=ParseLimits(document_bytes=500),
        )
    warning = Finding(
        code="REVIEW", message="Review.", next_action="Inspect.", severity="warning"
    )
    with pytest.raises(ReportLimitError):
        AcceptanceGeneration(
            specifications=(),
            ready=(),
            findings=(warning, warning),
            limits=ParseLimits(findings=1),
        )


def test_hash_collision_is_rejected(monkeypatch: pytest.MonkeyPatch) -> None:
    """Force equal digests through monkeypatch; distinct canonical keys must fail."""

    def collide(self: AcceptanceIdentity, *, limits: ParseLimits) -> str:
        """Return fixed valid ID for self/limits; no I/O or mutation."""
        return "scn-" + "a" * 64

    monkeypatch.setattr(AcceptanceIdentity, "scenario_id", collide)
    left, right = specification(), specification(key=identity(platform_id="other"))
    with pytest.raises(ValueError, match="collision"):
        generation((left, right))
