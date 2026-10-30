"""Prove the public modernization-target workflow in memory through the service.

The target side binds a required source contract to an implementation record in a
parity matrix, validates in ``parity-complete`` mode, renders the parity report and
generates target acceptance. Every scenario runs the real rules over a schema-complete
graph seeded under the profile's configured roots, so the service captures every
record: an evidence-backed matrix passes, a failed or blocked verification or an
unassessed dimension never passes, a stale implementation byte invalidates the matrix,
a second required client is assessed independently, and reports never claim what the
rules refused.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.profile_v2 import ProfileV2

from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.public_parity_test_support import (
    PAYLOAD,
    ParityOptions,
    parity_graph,
)
from tests.discovery_runtime.public_workflow_test_support import (
    codes,
    seeded_workspace,
    validate,
)
from tests.discovery_runtime.test_completion_rules import policy_profile
from tests.discovery_runtime.test_service import MemoryService, invoke

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


def target_profile(catalog: SchemaCatalog) -> ProfileV2:
    """Return a profile whose completion gates are explicit waivers except parity.

    The waivers are recorded policy, not inferred passes: with every source gate
    off, ``parity-complete`` evaluates the parity rules alone, which is what this
    suite proves. Memory only; profile errors propagate.
    """
    return policy_profile(catalog)


@pytest.fixture
def catalog(initialization_catalog: SchemaCatalog) -> SchemaCatalog:
    """Return the installed catalog each seeded target workspace is built from."""
    return initialization_catalog


def parity_workspace(
    catalog: SchemaCatalog,
    profile: ProfileV2,
    options: ParityOptions | None = None,
) -> MemoryService:
    """Return a fresh activated target workspace holding one parity graph."""
    return seeded_workspace(catalog, parity_graph(profile, catalog, options))


def test_evidence_backed_parity_passes_and_reports(catalog: SchemaCatalog) -> None:
    """A verified implementation bound to its source contract completes parity."""
    io = parity_workspace(catalog, target_profile(catalog))
    result = validate(io, "parity-complete")
    assert result.ok, result.findings
    assert result.summary["validation_result"] == "pass"
    report = invoke(io, "parity-report", mode="parity-complete", format="both")
    assert report.ok, report.findings
    assert report.artifacts and all(r.status == "planned" for r in report.artifacts)
    published = invoke(io, "parity-report", mode="parity-complete", write=True)
    assert published.ok, published.findings
    assert any(r.status == "created" for r in published.artifacts)


@pytest.mark.parametrize(
    "fault", ["verification-failed", "verification-blocked", "missing-dimension"]
)
def test_unverified_or_incomplete_parity_never_passes(
    catalog: SchemaCatalog, fault: str
) -> None:
    """A failed, blocked or unassessed target coordinate fails parity closed."""
    if fault == "missing-dimension":
        options = ParityOptions(dimensions=("trigger",))
    else:
        options = ParityOptions(
            verification="failed" if fault == "verification-failed" else "blocked"
        )
    io = parity_workspace(catalog, target_profile(catalog), options)
    result = validate(io, "parity-complete")
    assert not result.ok and result.exit_code == 1, result.findings
    assert result.summary["validation_result"] != "pass"
    assert "ACCEPTANCE_SCOPE" not in codes(result), codes(result)
    structural = validate(io, "structural")
    # An absent required classification is a structural defect: the service
    # refuses the matrix before any gate runs, so no gate result is reported.
    # A failed or blocked verification is a well-formed matrix that the parity
    # gate itself rejects, and the structural pass is reported separately.
    if fault == "missing-dimension":
        assert codes(result) == {"PARITY_DIMENSION"}
        assert result.summary["validation_result"] is None
        assert not structural.ok and "PARITY_DIMENSION" in codes(structural)
    else:
        assert codes(result) == {"PARITY_INCOMPLETE"}
        assert result.summary["validation_result"] == "fail"
        assert structural.ok and structural.summary["validation_result"] == "pass"


def test_stale_implementation_bytes_invalidate_the_matrix(
    catalog: SchemaCatalog,
) -> None:
    """Changing a pinned implementation byte after capture fails parity."""
    io = parity_workspace(catalog, target_profile(catalog))
    assert validate(io, "parity-complete").ok
    io.disk.store.put("src/Target.cs", PAYLOAD + b" changed after capture")
    io.repository.files["src/Target.cs"] = PAYLOAD + b" changed after capture"
    result = validate(io, "parity-complete")
    assert not result.ok and result.exit_code in (1, 3)
    assert result.summary.get("validation_result") != "pass"


def test_multiple_clients_are_assessed_independently(catalog: SchemaCatalog) -> None:
    """A second required client without a parity row keeps parity incomplete."""
    base = target_profile(catalog)
    document = json.loads(canonical_json(base.document))
    document["clients"].append(
        {
            "id": "mobile",
            "target_repository": base.repository.id,
            "platforms": ["mobile"],
            "modes": ["online"],
            "required_feature_dimensions": [],
            "applicability_defaults": {},
        }
    )
    profile = ProfileV2(json.dumps(document), format="json", catalog=catalog)
    io = parity_workspace(catalog, profile)
    result = validate(io, "parity-complete")
    assert not result.ok and result.exit_code == 1, result.findings
    assert result.summary["validation_result"] == "fail"
    report = invoke(io, "parity-report", mode="parity-complete")
    assert report.exit_code in (0, 1) and report.input_manifest is not None


def test_target_acceptance_generation_is_a_preview_bound_to_facts(
    catalog: SchemaCatalog,
) -> None:
    """Generated target criteria are previews bound to approved or verified facts."""
    io = parity_workspace(catalog, target_profile(catalog))
    result = invoke(
        io,
        "generate-acceptance",
        {"acceptance_kind": "target-acceptance", "output_format": "both"},
    )
    assert result.exit_code in (0, 1), result.findings
    assert all(row.status == "planned" for row in result.artifacts)
    assert result.input_manifest is not None and io.writer_calls == 0
