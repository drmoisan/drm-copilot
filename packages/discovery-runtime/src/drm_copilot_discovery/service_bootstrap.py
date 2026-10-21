"""Compose initialization, activation and migration through accepted guarded I/O."""

from __future__ import annotations

from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.catalog import V1_KINDS, schema_aliases
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.init_projection import InitializationRequest
from drm_copilot_discovery.mutation_plan import MutationChange
from drm_copilot_discovery.operations import OperationContext, OperationFailure
from drm_copilot_discovery.service_contracts import ServiceArtifact
from drm_copilot_discovery.snapshot import InputManifest, SnapshotFile

if TYPE_CHECKING:
    from drm_copilot_discovery.init_projection import InitializationCapture
    from drm_copilot_discovery.service_contracts import DiscoveryResult

# Registered aliases are opaque identities, never caller-selected read locations.
_V1_IDENTITIES = tuple(
    (alias, kind) for kind in V1_KINDS for alias in schema_aliases(kind, "1.0.0")
)


def _failure_paths(paths: tuple[str, ...], code: str) -> tuple[Finding, ...]:
    """Return fixed findings for bounded paths (tuple[str]) and code (str).

    Caller reserves the complete effect population before publication. No error
    message text is copied; unsafe internal paths raise ValueError. Pure.
    """
    # Retain exact affected paths even when no file digest can truthfully be supplied.
    return tuple(
        Finding(
            code=code,
            artifact_path=path,
            message="The requested effect is incomplete.",
            next_action="Recapture and reconcile this path before retrying.",
        )
        for path in paths
    )


def _initialization(
    context: OperationContext, *, migration: bool = False
) -> InitializationRequest:
    """Return the requested InitializationRequest without inventing configuration.

    context supplies schema-checked identities/roots; migration (bool) selects
    the explicit new destination. Construction validates values without I/O;
    invalid fields raise ValueError before planning.
    """
    return InitializationRequest(
        system_id=context.text("system_id"),
        system_name=context.text("system_name"),
        role=cast(
            "Literal['legacy-source', 'modernization-target', 'combined']",
            context.text("system_role"),
        ),
        repository_id=context.text("repository_id"),
        production_roots=context.strings("production_roots"),
        test_roots=context.strings("test_roots"),
        draft_configuration=cast("bool", context.inputs.get("draft", False)),
        artifact_root=(
            context.text("destination") if migration else "docs/migration/discovery"
        ),
        artifact_overrides=(
            (("profile", context.request.profile_path),)
            if context.request.profile_path is not None
            else ()
        ),
    )


def _remember(context: OperationContext, capture: InitializationCapture) -> None:
    """Bind physical bootstrap inputs to context; return None without writing.

    capture (InitializationCapture) separates real files/absence from its virtual
    proposal. Preserve only real files, plus explicit migration inputs, with no
    invented source pin. Budget and conflicting observations raise before commit.
    """
    observed = context.manifest()
    context.budget.work(len(capture.physical_files) + len(capture.physical_metadata))
    # Start from real bounded observations, never the initializer's virtual overlay.
    files = {file.path: file for file in observed.files}
    # Real bootstrap reads remain inputs even when a virtual profile was proposed.
    for path, content in capture.physical_files:
        context.budget.spend(len(content))
        previous = files.get(path)
        if previous is not None and previous.content != content:
            raise OperationFailure("SERVICE_CAPTURE", exit_code=3)
        files[path] = SnapshotFile(path=path, content=content, category="documentation")
    # Preserve genuine absence only; virtual profile/directory bytes are excluded.
    absent = tuple(
        path for path, meta in capture.physical_metadata if meta.kind == "missing"
    )
    context.observed_manifest = InputManifest(
        files=tuple(files.values()),
        missing_paths=tuple(set(observed.missing_paths + absent)),
    )


def _init(context: OperationContext) -> DiscoveryResult:
    """Create the explicit root through accepted initialization; return real effects.

    context (OperationContext) is authenticated local-user intent. Preflight the
    complete file result before commit; directories use counters, never fake
    digests. Preserve conflicts/uncertainty and exit 3 on interrupted effects.
    Planning errors propagate and dry_run performs no mutation.
    """
    from drm_copilot_discovery.init_flow import (
        commit_initialization,
        plan_initialization,
    )

    plan = plan_initialization(_initialization(context), io=context.io.initialization)
    _remember(context, plan.capture)
    context.budget.work(len(plan.mutation.writes) + len(plan.directories))
    # Include the exact bootstrap file in explicit local permission comparison.
    changes = tuple(write.change for write in plan.mutation.writes) + (
        MutationChange(
            artifact_kind="domain-profile",
            artifact_id="root-configuration",
            path=cast("str", plan.request.artifact_paths()["profile"]),
            content=plan.profile_bytes,
            expected_sha256=None,
        ),
    )
    context.grants(changes)
    context.result(artifacts=context.projected(changes))
    result = commit_initialization(
        plan, io=context.io.initialization, dry_run=context.request.dry_run
    )
    # Only file outputs with real planned/committed digests enter artifact rows.
    artifacts = tuple(
        ServiceArtifact(
            path=item.path, kind=item.kind, status=item.status, sha256=item.sha256
        )
        for item in result.outputs
        if item.sha256 is not None and item.kind != "directory"
    )
    # Directory effects retain their actual dispositions independently from file rows.
    counters = tuple(
        (
            "directories_" + status,
            sum(
                item.kind == "directory" and item.status == status
                for item in result.outputs
            ),
        )
        for status in ("planned", "created", "skipped", "conflict")
    )
    conflicts = tuple(item.path for item in result.outputs if item.status == "conflict")
    findings = result.validation.findings + _failure_paths(
        result.uncertain_paths + conflicts, "INITIALIZATION_EFFECT"
    )
    if not result.ok and not findings:
        findings = _failure_paths((changes[-1].path,), "INITIALIZATION_EFFECT")
    return context.result(
        artifacts=artifacts,
        findings=findings,
        counts=counters,
        exit_code=0 if result.ok else 3,
        validation=result.validation.validation_result,
    )


def _configure(context: OperationContext) -> DiscoveryResult:
    """Apply explicit protected activation/deactivation and preserve exact effects.

    context is authenticated OperationContext. Existing ActivationStore owns
    authorization, locks, freshness, CAS and revocation. Dry runs retain plans;
    protected/directory effects use counters. No registry content is disclosed.
    Typed configuration/I/O failures propagate before writes or remain exit 3.
    """
    from drm_copilot_discovery.configuration import (
        DEFAULT_PROFILE,
        LOCATOR_PATH,
        ConfigurationRequest,
        locator_bytes,
    )

    action = cast(
        "Literal['activate', 'deactivate']", context.text("configuration_action")
    )
    path = context.request.profile_path or context.text("input_path", DEFAULT_PROFILE)
    content = (
        context.read(context.text("input_path", path)) if action == "activate" else None
    )
    changes: tuple[MutationChange, ...] = ()
    if content is not None:
        context.reads.read(path, limit=context.limits.document_bytes, required=False)
        context.reads.read(
            LOCATOR_PATH, limit=context.limits.document_bytes, required=False
        )
        changes = (
            context.change("domain-profile", "root-configuration", path, content),
            context.change(
                "activation", "root-configuration", LOCATOR_PATH, locator_bytes(path)
            ),
        )
    context.grants(changes)
    projected = context.projected(changes)
    context.observed_manifest = context.manifest()
    context.result(artifacts=projected)
    result = context.io.activation.configure(
        ConfigurationRequest(
            action=action,
            profile_path=path if action == "activate" else DEFAULT_PROFILE,
            profile_bytes=content,
            dry_run=context.request.dry_run,
        )
    )
    originals = {item.path for item in context.observed_manifest.files}
    # Confirmed workspace changes retain known bytes; protected state is count-only.
    artifacts = tuple(
        replace(
            item,
            status=(
                "planned"
                if context.request.dry_run
                else ("updated" if item.path in originals else "created")
            ),
        )
        for item in projected
        if context.request.dry_run or item.path in result.changed
    )
    findings = _failure_paths(result.uncertain, "CONFIGURATION_EFFECT")
    if not result.ok and not findings:
        findings = _failure_paths(("protected-activation",), "CONFIGURATION_EFFECT")
    return context.result(
        artifacts=artifacts,
        findings=findings,
        exit_code=0 if result.ok else 3,
        counts=(
            ("confirmed_effects", len(result.changed)),
            ("uncertain_effects", len(result.uncertain)),
            ("authority_invalidated", int(result.authority_invalidated)),
        ),
    )


def _migrate(context: OperationContext) -> DiscoveryResult:
    """Plan a v1 conversion into an explicit new root and retain partial effects.

    context (OperationContext) supplies exact captured legacy paths and identities.
    Return DiscoveryResult using registered v1 kinds and exact selected originals.
    Existing migration services own conversion and unresolved metadata. No
    feature binding, environment, source pin or execution claim is invented.
    Resource/planning errors propagate; dry-run never publishes.
    """
    from drm_copilot_discovery.migration_capture import bind_migration_inputs
    from drm_copilot_discovery.migration_models import MigrationRequest, MigrationSource
    from drm_copilot_discovery.migration_v1 import commit_migration, plan_migration

    paths = context.strings("paths") or (context.text("input_path"),)
    context.budget.work(len(paths))
    sources: list[MigrationSource] = []
    # Parse only explicit inputs; the accepted migration validates each actual v1 kind.
    for path in paths:
        document = context.document(path)
        schema = document.get("$schema")
        if type(schema) is not str:
            raise OperationFailure("SERVICE_KIND")
        # Prepay all fixed alias visits and worst-case character comparisons.
        context.budget.work(
            sum(len(schema) + len(alias) + 1 for alias, _ in _V1_IDENTITIES)
        )
        # Only a registered v1 identity selects the accepted migration validator.
        kind = next((kind for alias, kind in _V1_IDENTITIES if schema == alias), None)
        if kind is None:
            raise OperationFailure("SERVICE_KIND")
        sources.append(
            MigrationSource(path=path, kind=kind, content=context.read(path))
        )
    io = bind_migration_inputs(
        context.io.initialization, paths=paths, limits=context.budget.limits
    )
    plan = plan_migration(
        MigrationRequest(
            initialization=_initialization(context, migration=True),
            sources=tuple(sources),
            from_version=cast("int", context.inputs["from_version"]),
            to_version=cast("int", context.inputs["to_version"]),
        ),
        io=io,
    )
    _remember(context, plan.initialization.capture)
    context.budget.work(len(plan.mutation.writes))
    # Preflight exact planned file rows before bootstrap or artifact publication.
    changes = tuple(write.change for write in plan.mutation.writes)
    profile_path = cast("str", plan.initialization.request.artifact_paths()["profile"])
    profile_change = MutationChange(
        artifact_kind="domain-profile",
        artifact_id="root-configuration",
        path=profile_path,
        content=plan.initialization.profile_bytes,
        expected_sha256=None,
    )
    context.grants(changes + (profile_change,))
    projected = context.projected(changes)
    context.result(artifacts=projected)
    result = commit_migration(plan, io=io, dry_run=context.request.dry_run)
    artifacts = projected if context.request.dry_run and result.ok else ()
    if result.publication is not None:
        # Bounded planned identities provide exact content provenance for actual
        # effects.
        by_path = {row.path: row for row in projected}
        # Actual guarded writer dispositions supersede the preflight status only.
        artifacts = tuple(
            replace(by_path[row.path], status=row.status, sha256=row.sha256)
            for row in result.publication.artifacts
        )
    if profile_path in result.bootstrap_created:
        artifacts += (
            ServiceArtifact(
                path=profile_path,
                kind="domain-profile",
                status="created",
                sha256=sha256(profile_change.content).hexdigest(),
            ),
        )
    findings = _failure_paths(result.uncertain_paths, "MIGRATION_EFFECT")
    if not result.ok and not findings:
        findings = _failure_paths((context.text("destination"),), "MIGRATION_EFFECT")
    return context.result(
        artifacts=artifacts,
        findings=findings,
        exit_code=0 if result.ok else 3,
        counts=(
            (
                "bootstrap_directories_created",
                sum(path != profile_path for path in result.bootstrap_created),
            ),
            ("uncertain_paths", len(result.uncertain_paths)),
        ),
    )


def bootstrap(context: OperationContext) -> DiscoveryResult:
    """Run the fixed bootstrap operation from context; return DiscoveryResult.

    context (OperationContext) retains authenticated local intent and physical
    observations. Accepted initialization/configuration/migration services own
    publication. Unknown names raise OperationFailure before effects.
    """
    if context.request.operation == "init":
        return _init(context)
    if context.request.operation == "configure":
        return _configure(context)
    if context.request.operation == "migrate":
        return _migrate(context)
    raise OperationFailure("SERVICE_OPERATION")
