"""Select physical imported targets from already proven typed index aliases."""

from __future__ import annotations

from dataclasses import replace

import pytest
from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex

from tests.discovery_runtime.test_references import (
    artifact,
    immutable,
    source_reference,
)


@pytest.mark.parametrize("context", ["representative", "alias", "source", "unmatched"])
def test_imported_representative_preserves_exact_physical_selection(
    context: str,
) -> None:
    """Use proven index inputs to select each own member or reject an absent copy."""
    imported = artifact(
        "feature-contract",
        "feature",
        repository="source",
        path="docs/transport/a/contracts/feature.json",
        origin="contracts/feature.json",
        fields={"feature_id": "feature"},
    )
    assert imported.document is not None
    representative = ArtifactRecord(
        artifact=imported, kind="feature-contract", document=imported.document
    )
    alias = replace(
        representative,
        artifact=replace(imported, path="docs/transport/b/contracts/feature.json"),
    )
    # Alias provenance is a supplied index invariant; this unit tests only resolution.
    index = ReferenceIndex(
        records=(representative,), replicas=((imported.path, alias),)
    )
    folder = {"representative": "a", "alias": "b", "source": "a", "unmatched": "c"}[
        context
    ]
    header = artifact(
        "source-snapshot-manifest",
        "manifest",
        path=f"docs/transport/{folder}/manifest.json",
    )
    assert header.document is not None
    source = ArtifactRecord(
        artifact=header, kind="source-snapshot-manifest", document=header.document
    )
    # Source contracts choose a deterministic copy; manifests require their own member.
    reference = (
        source_reference(imported)
        if context == "source"
        else dict(
            artifact_kind="feature-contract", id="feature", path=imported.origin_path
        )
    )
    result = index.resolve(
        immutable(reference),
        source=source,
        pointer="/artifacts/0",
        transport=context != "source",
    )
    expected = {
        "representative": representative,
        "alias": alias,
        "source": representative,
        "unmatched": None,
    }
    assert result.target is expected[context]
    assert bool(result.findings) == (context == "unmatched")
