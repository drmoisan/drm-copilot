"""Preserve generated tag spelling and configured applicability during rendering."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.acceptance_generation import generate_acceptance
from drm_copilot_discovery.acceptance_models import acceptance_tags
from drm_copilot_discovery.gherkin import render_acceptance
from drm_copilot_discovery.models import ParseLimits

from tests.discovery_runtime.test_acceptance_decisions import policy_snapshot
from tests.discovery_runtime.test_acceptance_generation import (
    generation_snapshot,
)
from tests.discovery_runtime.test_acceptance_generation import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.test_acceptance_properties import (
    generation,
    identity,
    specification,
)
from tests.discovery_runtime.test_gherkin import blocks, changed, file_text
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


@pytest.mark.parametrize(
    "mode,mobile",
    [
        ("online", False),
        ("offline", False),
        ("mobile", False),
        ("custom", True),
        ("offline", True),
    ],
)
def test_exact_generated_tags_survive_without_name_inference(
    mode: str, mobile: bool
) -> None:
    """Preserve mode (str)/mobile (bool) tags exactly; return None.

    Names confer no applicability. Only local values are constructed; no I/O.
    """
    key = identity(mode_id=mode, feature_id="feat.a_b-c", client_id="mobile-named")
    tags = acceptance_tags(key, limits=ParseLimits(), mobile_applicable=mobile)
    item = changed(specification(key=key), tags=tags)
    feature = file_text(render_acceptance(generation((item,), (item,))), ".feature")
    lines = feature.splitlines()
    # Locate the generated scenario without depending on its digest value.
    scenario = next(
        index for index, line in enumerate(lines) if line.startswith("  Scenario:")
    )
    assert lines[scenario - 1].strip().split(" ") == list(tags)
    assert "@feature_feat.a_b-c" in tags
    assert ("@offline" in tags) == (mode == "offline")
    assert ("@mobile" in tags) == mobile


@pytest.mark.parametrize(
    "tags",
    [
        None,
        "tag",
        (1,),
        ("@x", "@x"),
        ("@z", "@a"),
        ("@bad space",),
        ("@Upper",),
        ("@a\nScenario: x",),
        ("@é",),
        ("@a/b",),
        ("@a\x7f",),
    ],
)
def test_unsafe_ambiguous_or_unsorted_tags_fail_closed(tags: object) -> None:
    """Reject tags (object, invalid data) with ValueError; return None, no I/O."""
    item = changed(specification(), tags=tags)
    with pytest.raises(ValueError):
        render_acceptance(generation((item,), (item,)))


def test_shared_tags_across_distinct_scenarios_are_not_collisions() -> None:
    """Allow repeated tags across distinct files; return None without I/O."""
    first = specification(key=identity(criterion_id="alpha"))
    second = specification(key=identity(criterion_id="beta"))
    bundle = render_acceptance(generation((second, first), (second, first)))
    assert len(bundle.files) == 3
    # Shared tags are allowed across distinct complete scenario identities.
    assert all(b"@feature_feature" in item.content for item in bundle.files[1:])
    assert bundle == render_acceptance(generation((first, second), (first, second)))


def test_distinct_punctuation_is_preserved_in_tags_and_identity() -> None:
    """Keep punctuation distinct; return None without I/O or shared mutation.

    No arguments; only local identities and rendered values are constructed.
    """
    # Each legal spelling must retain its own canonical scenario and exact tag.
    items = tuple(
        specification(key=identity(feature_id=name)) for name in ("a.b", "a_b", "a-b")
    )
    bundle = render_acceptance(generation(items, items))
    assert len(bundle.files) == 4
    # Each complete feature carries only its own generated feature tag.
    tags = {
        token
        for item in bundle.files[1:]
        for token in item.content.decode().split()
        if token.startswith("@feature_")
    }
    assert tags == {"@feature_a.b", "@feature_a_b", "@feature_a-b"}


def test_empty_tag_tuple_does_not_create_an_inferred_tag() -> None:
    """Keep structural empty tags empty; no inputs, return None without I/O."""
    item = changed(specification(), tags=())
    feature = file_text(render_acceptance(generation((item,), (item,))), ".feature")
    assert "\n  @" not in feature
    assert "\n  Scenario:" in feature


def test_approved_target_trace_retains_original_decision_and_owner(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Retain approved captured target refs with snapshot_catalog (SchemaCatalog).

    Return None after composition assertions; no I/O or fixture mutation.
    """
    result = generate_acceptance(
        policy_snapshot(snapshot_catalog), kind="target-acceptance"
    )
    assert result.ready, result.findings
    bundle = render_acceptance(result)
    # Select the approved criterion explicitly; the observed source is also ready.
    item = next(
        item
        for item in result.ready
        if item.identity.criterion_id == "target-criterion"
    )
    # Find its own trace without relying on document or section position.
    trace = next(
        as_object(value)
        for value in blocks(file_text(bundle, ".md"))[2:]
        if as_object(as_object(value)["identity"])["criterion_id"] == "target-criterion"
    )
    assert (
        as_object(trace["specification"])["product_decision_refs"]
        == item.to_dict()["product_decision_refs"]
    )
    assert as_object(trace["specification"])["product_decision_refs"]
    assert trace["repository"] == item.repository.to_dict()


def test_unknown_expected_behavior_remains_pending_markdown(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Keep generator uncertainty using snapshot_catalog (SchemaCatalog).

    Return None after assertions of no executable fallback; no I/O occurs.
    """
    snapshot = generation_snapshot(snapshot_catalog)
    # Missing captured evidence must not become a ready-looking renderer fixture.
    artifacts = tuple(
        item
        for item in snapshot.artifacts
        if item.expected_kind != "evidence-reference"
    )
    snapshot = replace(snapshot, artifacts=artifacts)
    result = generate_acceptance(snapshot, kind="legacy-characterization")
    assert not result.ready
    bundle = render_acceptance(result)
    assert len(bundle.files) == 1
    views = blocks(file_text(bundle, ".md"))
    assert as_object(views[0])["ready"] == 0
    assert cast("list[object]", views[1])
