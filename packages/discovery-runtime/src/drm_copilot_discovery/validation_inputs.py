"""Check complete retained inputs and deterministic derived-report input identity."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

from drm_copilot_discovery.agent_output import REPORT_KINDS
from drm_copilot_discovery.findings import Finding, FindingCollector
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.snapshot import repository_pins
from drm_copilot_discovery.snapshot_io import document_format

if TYPE_CHECKING:
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

CONTROL_KINDS = frozenset(
    {
        "required-output-manifest",
        "validation-receipt",
        "discovery-invocation",
        "capability-attestation",
        "tool-authorization",
        "service-request",
        "service-result",
    }
)


def input_problem(code: str, message: str, path: str | None = None) -> Finding:
    """Keep mode/input failures actionable without inventing receipt authority."""
    return Finding(
        code=code,
        message=message,
        artifact_path=path,
        next_action="Correct the inputs and validate the requested mode.",
    )


def validate_inputs(snapshot: DiscoverySnapshot) -> tuple[Finding, ...]:
    """Check retained raw bytes once against their trusted kinds and profile value."""
    collector = FindingCollector(limit=snapshot.profile.limits.parse_limits().findings)
    # Captured I/O failures remain visible even when retained bytes parse successfully.
    for finding in snapshot.findings:
        collector.add(finding)
    # Exact captured paths bind parsed values to the bytes used for hashing.
    files = {item.path: item for item in snapshot.manifest.files}
    path = snapshot.profile.artifacts["profile"]
    profile = files.get(path)
    if profile is None:
        collector.add(
            input_problem(
                "PROFILE_REQUIRED", "Captured profile bytes are missing.", path
            )
        )
    else:
        checked = validate_document(
            profile.content,
            expected_kind="domain-profile",
            expected_version="2.0.0",
            format=document_format(path),
            artifact_path=path,
            catalog=snapshot.catalog,
            limits=snapshot.profile.limits.parse_limits(),
        )
        # Schema and value mismatches are independent failures, never first-success.
        for finding in checked.findings:
            collector.add(finding)
        if checked.document != snapshot.profile.document:
            collector.add(
                input_problem(
                    "PROFILE_BYTES",
                    "Captured profile differs from the validated configuration.",
                    path,
                )
            )
    # Unreferenced structured files need the same expected-kind validation as links.
    represented = {item.path for item in snapshot.artifacts}
    # Every captured structured artifact must have a trusted expected-kind descriptor.
    for item in snapshot.manifest.files:
        if (
            item.category
            in {"artifact", "scope", "inventory", "source-snapshot", "extension-result"}
            and item.path not in represented
        ):
            collector.add(
                input_problem(
                    "SNAPSHOT_UNCLASSIFIED",
                    "Captured structured input lacks an expected artifact kind.",
                    item.path,
                )
            )
    # Validate malformed and unreferenced files alike; no first-success dispatch exists.
    for artifact in snapshot.artifacts:
        raw = files[artifact.path].content
        # Derived reports use the recomputed projection contract after safe parsing.
        if artifact.expected_kind in REPORT_KINDS:
            parsed = parse_document(
                raw,
                format=document_format(artifact.path),
                artifact_path=artifact.path,
                limits=snapshot.profile.limits.parse_limits(),
            )
            document, findings = parsed.value, parsed.findings
        else:
            checked = validate_document(
                raw,
                expected_kind=artifact.expected_kind,
                expected_version="2.0.0",
                format=document_format(artifact.path),
                artifact_path=artifact.path,
                catalog=snapshot.catalog,
                limits=snapshot.profile.limits.parse_limits(),
            )
            document, findings = checked.document, checked.findings
        # Keep all malformed artifacts in the aggregate rather than failing early.
        for finding in findings:
            collector.add(finding)
        if document != artifact.document:
            collector.add(
                input_problem(
                    "SNAPSHOT_DOCUMENT",
                    "Parsed value differs from retained artifact bytes.",
                    artifact.path,
                )
            )
    # Profile declaration order cannot change the role-specific pin identity set.
    if tuple(
        frozenset(group)
        for group in (
            snapshot.manifest.source_repositories,
            snapshot.manifest.target_repositories,
        )
    ) != tuple(frozenset(group) for group in repository_pins(snapshot.profile)):
        collector.add(
            input_problem(
                "SNAPSHOT_PINS", "Captured role pins differ from the profile."
            )
        )
    return collector.findings


def report_input_digest(snapshot: DiscoverySnapshot) -> str:
    """Bind derived reports to semantic inputs without hashing their own output bytes.

    Full validation results still bind snapshot.sha256, including report/control
    bytes. This projection is only for deterministic derived report comparison.
    """
    # Report/control output bytes cannot participate in their own content digest.
    excluded = {
        item.path
        for item in snapshot.artifacts
        if item.expected_kind in REPORT_KINDS | CONTROL_KINDS
    }
    report_root = snapshot.profile.artifacts["reports"]
    # All actual source, profile and evidence bytes remain semantic report inputs.
    files = tuple(
        item
        for item in snapshot.manifest.files
        if item.path not in excluded and not item.path.startswith(report_root + "/")
    )
    # Report absence is also output state, not an inspected discovery fact.
    manifest = replace(
        snapshot.manifest,
        files=files,
        missing_paths=tuple(
            path
            for path in snapshot.manifest.missing_paths
            if path != report_root and not path.startswith(report_root + "/")
        ),
    )
    # Keep descriptors consistent with the filtered immutable byte manifest.
    core = tuple(
        item
        for item in snapshot.artifacts
        if item.path in {file.path for file in files}
    )
    return replace(snapshot, manifest=manifest, artifacts=core).sha256
