"""Prove source export, target import, the no-runtime flow and host fixtures in memory.

The combined suite moves validated source identities between two memory workspaces
through ``snapshot-export`` and ``snapshot-import`` with the real transport rules,
proves that a tampered transported byte is refused, runs the no-runtime and
dry-run flows, and reconciles the committed workflow fixtures with the Python
authority: every request fixture is a valid service request the service accepts or
rejects for the stated reason, every well-formed result fixture validates against the
installed ``service-result`` schema, and the forged pass is refused by it.
"""

from __future__ import annotations

import io
import json
from datetime import UTC, datetime
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import gateway
from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.service import execute

from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.public_workflow_test_support import (
    BROWSER_CLIENT,
    fixture_document,
    fixture_names,
    seeded_workspace,
    validate,
    with_request_workspace,
    workspace,
)
from tests.discovery_runtime.test_service import MemoryService, invoke
from tests.discovery_runtime.validation_test_support import (
    mode_profile,
    no_scope_snapshot,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_projection import InitializationTemplates


@pytest.fixture
def source(initialization_catalog: SchemaCatalog) -> MemoryService:
    """Return a combined-role source workspace with a confirmed scope; memory only."""
    return seeded_workspace(
        initialization_catalog, no_scope_snapshot(initialization_catalog)
    )


def target_workspace(
    catalog: SchemaCatalog,
    templates: InitializationTemplates,
    source: MemoryService,
    manifest_path: str,
) -> MemoryService:
    """Return a target workspace that declares source as its legacy repository.

    The import contract binds the transported manifest to a declared related
    repository, so the target profile names the source repository, its pin and the
    manifest path. Memory only; plan errors propagate.
    """
    checkout = source.repository.identity()
    return workspace(
        catalog,
        templates,
        role="combined",
        system_id="target-system",
        repository_id="target-repository",
        related=(
            {
                "id": checkout.id,
                "role": "legacy-source",
                "revision": checkout.revision,
                "snapshot_manifest": manifest_path,
                "clients": [],
            },
        ),
    )


def test_export_then_import_transports_exact_bytes_between_workspaces(
    source: MemoryService,
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """Exported identities arrive unchanged; the importer verifies every digest."""
    assert validate(source, "discovery-complete").ok
    preview = invoke(
        source, "snapshot-export", {"selected_ids": ["scope"]}, dry_run=True
    )
    assert preview.ok, preview.findings
    assert all(row.status == "planned" for row in preview.artifacts)
    exported = invoke(source, "snapshot-export", {"selected_ids": ["scope"]})
    assert exported.ok, exported.findings
    manifest_row = next(
        r for r in exported.artifacts if r.kind == "source-snapshot-manifest"
    )
    transported = {
        row.path: source.disk.store.files[row.path]
        for row in exported.artifacts
        if row.status == "created"
    }
    assert manifest_row.path in transported and len(transported) >= 2

    target = target_workspace(
        initialization_catalog, initialization_templates, source, manifest_row.path
    )
    # The transported files are copied byte-for-byte into the target workspace.
    for path, content in transported.items():
        target.disk.store.put(path, content)
    rehearsal = invoke(
        target, "snapshot-import", {"manifest_path": manifest_row.path}, dry_run=True
    )
    assert rehearsal.ok, rehearsal.findings
    imported = invoke(target, "snapshot-import", {"manifest_path": manifest_row.path})
    assert imported.ok, imported.findings
    assert validate(target, "structural").ok


def test_tampered_transport_is_refused_before_publication(
    source: MemoryService,
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """A changed transported byte is refused at the gateway; nothing is published."""
    exported = invoke(source, "snapshot-export", {"selected_ids": ["scope"]})
    assert exported.ok, exported.findings
    manifest_row = next(
        r for r in exported.artifacts if r.kind == "source-snapshot-manifest"
    )
    target = target_workspace(
        initialization_catalog, initialization_templates, source, manifest_row.path
    )
    for row in exported.artifacts:
        if row.status != "created":
            continue
        content = source.disk.store.files[row.path]
        if row.kind == "scope":
            content = content + b"\n"
        target.disk.store.put(row.path, content)
    before = dict(target.disk.store.files)
    # The transport verifier raises inside the service; the public gateway boundary
    # reports exit 3 with a fixed stderr sentence and emits no result document, so
    # a host client sees a transport failure and never a pass.
    request = {
        "$schema": "urn:drm-copilot:discovery:2.0.0:service-request",
        "schema_version": "2.0.0",
        "artifact_kind": "service-request",
        "id": "tampered-import",
        "request_id": "tampered-import",
        "operation": "snapshot-import",
        "mode": "structural",
        "workspace_root": target.disk.root,
        "profile_path": None,
        "dry_run": False,
        "write": False,
        "format": "json",
        "inputs": {"manifest_path": manifest_row.path},
        "invocation_ref": None,
        "authorization_ref": None,
    }
    stdout, stderr = io.StringIO(), io.StringIO()
    code = gateway.run_gateway(
        stdin=io.BytesIO(json.dumps(request).encode("utf-8")),
        stdout=stdout,
        stderr=stderr,
        create_io=lambda: target,
        repository_reader=target.repository,
        clock=lambda: datetime(2026, 10, 20, tzinfo=UTC),
        analyzer_registry=InstalledInventoryRegistry(),
        limits=None,
        execute_request=execute,
    )
    assert code == 3, stderr.getvalue()
    assert stdout.getvalue() == ""
    assert "Discovery service failed unexpectedly" in stderr.getvalue()
    assert "Transport member" not in stderr.getvalue()
    assert target.disk.store.files == before


def test_no_runtime_capability_completes_without_runtime_claims(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """A no-runtime profile completes a confirmed scope and reports no runtime."""
    document = json.loads(canonical_json(mode_profile(initialization_catalog).document))
    document["runtime"] = {"capability": "none", "required_feature_ids": []}
    profile = ProfileV2(
        json.dumps(document), format="json", catalog=initialization_catalog
    )
    io = seeded_workspace(
        initialization_catalog,
        no_scope_snapshot(initialization_catalog, profile=profile),
    )
    result = validate(io, "discovery-complete")
    assert result.ok, result.findings
    report = invoke(io, "completion-report", mode="discovery-complete", format="both")
    assert report.ok, report.findings
    rendered = next(r for r in report.artifacts if r.path.endswith(".json"))
    completion = json.loads(rendered.content or "{}")
    # The report records the passing assessment and claims no runtime result.
    assert completion["validation_result"] == "pass"
    assert '"passed"' not in json.dumps(completion)
    assert json.loads(io.disk.store.files[profile.artifacts["profile"]])["runtime"] == {
        "capability": "none",
        "required_feature_ids": [],
    }


def test_multiple_clients_and_optional_dimensions_configure_without_inventing_results(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """Two clients with optional dimensions validate structurally and gate honestly."""
    mobile = {
        **BROWSER_CLIENT,
        "id": "mobile",
        "platforms": ["mobile"],
        "required_feature_dimensions": ["offline"],
        "applicability_defaults": {
            "mobile": {"applicability": "applicable", "rationale": "Selected."}
        },
    }
    io = workspace(
        initialization_catalog,
        initialization_templates,
        role="combined",
        clients=(BROWSER_CLIENT, mobile),
    )
    assert validate(io, "structural").ok
    result = validate(io, "discovery-complete")
    assert not result.ok and result.summary["validation_result"] == "fail"


def test_request_fixtures_are_accepted_by_the_python_authority(
    source: MemoryService,
) -> None:
    """Every committed request fixture is a valid v2 request the service executes."""
    names = fixture_names("requests")
    assert names
    for name in names:
        document = with_request_workspace(fixture_document(f"requests/{name}"), source)
        checked = validate_document(
            json.dumps(document),
            expected_kind="service-request",
            expected_version="2.0.0",
            catalog=source.initialization.catalog,
        )
        assert checked.ok, (name, checked.findings)
        operation = str(document.pop("operation"))
        fields = {key: value for key, value in document.items() if key != "inputs"}
        result = invoke(source, operation, document["inputs"], **fields)
        assert result.exit_code in (0, 1), (name, result.findings)
        assert result.operation == operation


@pytest.mark.parametrize("name", fixture_names("results"))
def test_result_fixtures_follow_the_installed_result_schema(
    source: MemoryService, name: str
) -> None:
    """Well-formed result fixtures validate; the forged pass is refused by schema."""
    document = fixture_document(f"results/{name}")
    checked = validate_document(
        json.dumps(document),
        expected_kind="service-result",
        expected_version="2.0.0",
        catalog=source.initialization.catalog,
    )
    forged = name == "false-pass.json"
    assert checked.ok is not forged, (name, checked.findings)
    if not forged:
        assert document["ok"] is (document["exit_code"] == 0)
