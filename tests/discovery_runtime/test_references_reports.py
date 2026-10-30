"""Prove written derived reports never break or join the reference graph (#980)."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.references import index_references

from tests.discovery_runtime.test_references import artifact, graph, reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2

REPORT_KINDS = (
    "validation-report",
    "coverage-report",
    "parity-report",
    "completion-report",
)


@pytest.mark.parametrize("kind", REPORT_KINDS)
def test_written_reports_are_excluded_from_the_reference_graph(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str
) -> None:
    """A workspace holding a written report still indexes its authored artifacts.

    Reports carry an artifact_kind and an id but no catalog document, so they
    can neither hold nor satisfy references; before this guard the installed
    console failed with a KeyError once a validation report had been written.

    snapshot_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) are the
    shared fixtures; kind (str) is the derived report kind under test.
    """
    target = artifact("evidence-reference", "capture")
    source = artifact(
        "feature-contract",
        "feature",
        fields={"source_evidence_refs": [reference("evidence-reference", "capture")]},
    )
    report = artifact(
        kind,
        "review",
        path=f"docs/migration/discovery/reports/{kind}.json",
        fields={"validation_result": "pass", "findings": []},
    )

    index = index_references(
        graph(snapshot_profile, snapshot_catalog, source, target, report)
    )

    assert index.findings == ()
    assert {record.kind for record in index.records} == {
        "feature-contract",
        "evidence-reference",
    }
    assert len(index.links) == 1 and index.links[0].target is not None
    assert index.links[0].target.artifact == target


def test_a_reference_to_a_report_identity_is_not_satisfied_by_the_report(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A link naming a report id resolves against authored artifacts only.

    snapshot_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) are the
    shared fixtures.
    """
    report = artifact("validation-report", "capture")
    source = artifact(
        "feature-contract",
        "feature",
        fields={"source_evidence_refs": [reference("evidence-reference", "capture")]},
    )

    index = index_references(graph(snapshot_profile, snapshot_catalog, source, report))

    assert [link.target for link in index.links] == [None]
    assert index.findings != ()
