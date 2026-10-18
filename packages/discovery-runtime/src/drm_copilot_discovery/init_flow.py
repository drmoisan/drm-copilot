"""Plan and initialize honest v2 drafts through a root-bound trusted I/O adapter."""

from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from typing import TYPE_CHECKING

from drm_copilot_discovery.init_models import EXPECTED_TEMPLATE_RELATIVE_PATHS
from drm_copilot_discovery.init_projection import (
    ARTIFACT_TEMPLATES,
    InitializationConflict,
    InitializationOutput,
    InitializationRequest,
    InitializationResult,
    InitializationTemplates,
    artifact_values,
    profile_proposal,
    require_compatible,
)
from drm_copilot_discovery.mutation_io import GuardedMutationWriter, commit_mutation
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationError,
    plan_mutation,
)
from drm_copilot_discovery.path_models import PathPolicyError, WriteGrant
from drm_copilot_discovery.path_policy import FILE_KEYS
from drm_copilot_discovery.profile_v2 import ProfileError

if TYPE_CHECKING:
    from collections.abc import Mapping
    from pathlib import Path

    from drm_copilot_discovery.init_io import InitializationIO
    from drm_copilot_discovery.init_models import FileSystem
    from drm_copilot_discovery.init_projection import InitializationCapture
    from drm_copilot_discovery.mutation_plan import MutationPlan


@dataclass(frozen=True, kw_only=True)
class InitializationPlan:
    """Bind a validated graph to actual physical inputs and exact draft bytes.

    The mutation plan's baseline is virtual and is never committed. Bootstrap
    must produce an equivalent real capture before ordinary artifact mutations.
    """

    request: InitializationRequest
    templates: InitializationTemplates
    capture: InitializationCapture
    profile_bytes: bytes
    directories: tuple[str, ...]
    mutation: MutationPlan


def _plan_initialization(
    request: InitializationRequest,
    *,
    io: InitializationIO,
    templates: InitializationTemplates | None = None,
) -> InitializationPlan:
    """
    Validate the complete creation graph before writes, preserving valid existing
    bytes.
    """
    selected = templates or InitializationTemplates.load()
    repository = io.available_repository()
    identity = repository.identity() if repository is not None else None
    if identity is not None and identity.id != request.repository_id:
        raise ValueError("Local Git identity differs from the requested repository")
    fallback = profile_proposal(
        request,
        templates=selected,
        catalog=io.catalog,
        revision=identity.revision if identity else None,
    )
    profile_path = str(request.artifact_paths()["profile"])
    initial = io.capture(profile_path=profile_path, profile_bytes=fallback)
    profile = initial.proposal_base.snapshot.profile
    require_compatible(request, profile)
    profile_bytes = initial.proposal_base.snapshot.file(profile_path).content
    # Only configured directory categories belong to root bootstrap publication.
    directories = tuple(
        sorted(
            str(value)
            for key, value in profile.artifacts.data.items()
            if key not in FILE_KEYS
        )
    )
    captured = io.capture(
        profile_path=profile_path, profile_bytes=profile_bytes, directories=directories
    )
    # The second complete capture must retain the effective profile selection.
    require_compatible(request, captured.proposal_base.snapshot.profile)
    if captured.proposal_base.snapshot.file(profile_path).content != profile_bytes:
        raise OSError("Profile changed while preparing initialization")
    snapshot = captured.proposal_base.snapshot
    if not snapshot.ok:
        raise InitializationConflict(
            profile_path,
            "Existing initialization inputs are invalid; correct the reported paths",
            findings=snapshot.findings,
        )
    # Existing validated records retain their IDs and exact original bytes.
    originals = {item.path: item for item in snapshot.artifacts}
    scope = originals.get(profile.artifacts["scope"])
    scope_id = (
        str(scope.document["id"])
        if scope and scope.document
        else "scope-" + profile.system.id
    )
    values = artifact_values(profile, scope_id=scope_id)
    changes: list[MutationChange] = []
    # Source-only workspaces have no target parity artifact to initialize.
    for key, kind, template in ARTIFACT_TEMPLATES:
        if key == "parity_matrix" and profile.system.role == "legacy-source":
            continue
        path = profile.artifacts[key]
        original = originals.get(path)
        if original is not None and original.document is None:
            raise InitializationConflict(
                path, f"Existing initialization artifact is invalid: {path}", kind=kind
            )
        content = (
            snapshot.file(path).content
            if original
            else selected.render(template, values)
        )
        document = original.document if original else None
        artifact_id = (
            str(document["id"])
            if document
            else {
                "scope": scope_id,
                "coverage_ledger": values["ledger_id"],
                "unspecified_behaviors": values["unresolved_id"],
                "product_decisions": values["decisions_id"],
                "parity_matrix": values["parity_id"],
            }[key]
        )
        changes.append(
            MutationChange(
                artifact_kind=kind,
                artifact_id=str(artifact_id),
                path=path,
                content=content,
                expected_sha256=sha256(content).hexdigest() if original else None,
            )
        )
    mutation = plan_mutation(
        captured.proposal_base,
        tuple(changes),
        # Each publication is restricted to its exact projected kind, ID and path.
        grants=tuple(
            WriteGrant(
                artifact_kind=item.artifact_kind,
                artifact_id=item.artifact_id,
                path=item.path,
            )
            for item in changes
        ),
    )
    return InitializationPlan(
        request=request,
        templates=selected,
        capture=captured,
        profile_bytes=profile_bytes,
        directories=directories,
        mutation=mutation,
    )


def plan_initialization(
    request: InitializationRequest,
    *,
    io: InitializationIO,
    templates: InitializationTemplates | None = None,
) -> InitializationPlan:
    """Expose typed existing-input conflicts without allowing any preflight writes."""
    path = str(request.artifact_paths()["profile"])
    try:
        return _plan_initialization(request, io=io, templates=templates)
    except PathPolicyError as error:
        raise InitializationConflict(error.path, str(error)) from error
    except (ProfileError, MutationError) as error:
        raise InitializationConflict(
            path, str(error), findings=error.findings
        ) from error


def _outputs(plan: InitializationPlan) -> tuple[InitializationOutput, ...]:
    """
    Project deterministic intended dispositions from physical absence, not virtual
    flags.
    """
    physical = dict(plan.capture.physical_metadata)
    profile = plan.capture.proposal_base.snapshot.profile
    directories = set(plan.directories)
    # Keep intermediate parents visible in dry-run and partial-effect reports.
    for path in (
        *plan.directories,
        profile.artifacts["profile"],
        *(write.change.path for write in plan.mutation.writes),
    ):
        parts = path.split("/")
        directories.update("/".join(parts[:index]) for index in range(1, len(parts)))
    outputs = [
        InitializationOutput(
            path=profile.artifacts["profile"],
            kind="domain-profile",
            status="planned" if plan.capture.profile_missing else "skipped",
            sha256=sha256(plan.profile_bytes).hexdigest(),
        )
    ]
    # Synthetic directory existence never changes a physical planned disposition.
    outputs.extend(
        InitializationOutput(
            path=path,
            kind="directory",
            status="planned" if physical[path].kind == "missing" else "skipped",
        )
        for path in sorted(directories)
    )
    # Ordinary artifact dispositions come from the accepted mutation projection.
    outputs.extend(
        InitializationOutput(
            path=write.change.path,
            kind=write.change.artifact_kind,
            status="skipped" if write.skipped else "planned",
            sha256=sha256(write.change.content).hexdigest(),
        )
        for write in plan.mutation.writes
    )
    return tuple(sorted(outputs, key=lambda item: item.path))


def commit_initialization(
    plan: InitializationPlan,
    *,
    io: InitializationIO,
    dry_run: bool = False,
    force: bool = False,
) -> InitializationResult:
    """
    Recheck physical inputs, bootstrap root paths, then use accepted artifact
    mutations.

    Dry-run performs no directory, file, activation, receipt or revocation writes.
    force is a deprecated compatibility argument and never permits replacement.
    """
    notes = (
        ("force is deprecated; initialization preserves existing valid content.",)
        if force
        else ()
    )
    outputs = _outputs(plan)
    revoked = False
    try:
        rebuilt = plan_initialization(plan.request, io=io, templates=plan.templates)
        plan.capture.require_same(rebuilt.capture)
        if (
            plan.profile_bytes != rebuilt.profile_bytes
            or plan.directories != rebuilt.directories
            or plan.mutation != rebuilt.mutation
        ):
            raise ValueError(
                "Initialization plan differs from its validated reconstruction"
            )
        if dry_run:
            return InitializationResult(
                ok=True,
                outputs=outputs,
                validation=plan.mutation.validation,
                authority_invalidated=False,
                notes=notes,
            )
        bootstrap = io.bootstrap(
            plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
        )
        revoked = bootstrap.authority_invalidated
        # Bootstrap effects remain visible even when a later stage fails.
        outputs = tuple(
            InitializationOutput(
                path=item.path,
                kind=item.kind,
                status=(
                    "created"
                    if item.path in bootstrap.created
                    else "conflict" if item.path in bootstrap.conflicts else item.status
                ),
                sha256=item.sha256,
            )
            for item in outputs
        )
        if not bootstrap.ok:
            return InitializationResult(
                ok=False,
                outputs=outputs,
                validation=plan.mutation.validation,
                authority_invalidated=revoked,
                uncertain_paths=bootstrap.uncertain,
                error=bootstrap.error,
                notes=notes,
            )
        profile_path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
        physical = io.physical_capture(profile_path)
        if (
            physical != bootstrap.physical
            or physical.snapshot.sha256 != plan.capture.proposal_base.snapshot.sha256
        ):
            raise OSError(
                "Physical bootstrap inputs differ from the validated proposal"
            )
        current = plan_mutation(
            physical,
            tuple(write.change for write in plan.mutation.writes),
            grants=plan.mutation.grants,
        )
        if current.prospective.sha256 != plan.mutation.prospective.sha256:
            raise OSError("Physical creation graph differs from the validated proposal")
        result = commit_mutation(
            current,
            writer=GuardedMutationWriter(
                capture=lambda: io.physical_capture(profile_path),
                invalidate_authority=io.invalidate_authority,
                primitives=io.primitives,
            ),
        )
        # Report only parents implied by confirmed ordinary artifact creation.
        statuses = {item.path: item.status for item in result.artifacts}
        # Successful children prove creation of their previously absent parents.
        created_parents = {
            item.path
            for item in outputs
            if item.kind == "directory"
            and item.status == "planned"
            and any(
                output.status == "created" and output.path.startswith(item.path + "/")
                for output in result.artifacts
            )
        }
        # Merge exact file outcomes without upgrading unperformed planned writes.
        outputs = tuple(
            InitializationOutput(
                path=item.path,
                kind=item.kind,
                status=(
                    "created"
                    if statuses.get(item.path) == "created"
                    or item.path in created_parents
                    else (
                        "conflict"
                        if statuses.get(item.path) == "conflict"
                        else item.status
                    )
                ),
                sha256=item.sha256,
            )
            for item in outputs
        )
        return InitializationResult(
            ok=result.ok,
            outputs=outputs,
            validation=result.validation,
            authority_invalidated=revoked or result.authority_invalidated,
            uncertain_paths=result.uncertain_paths,
            error="; ".join(finding.message for finding in result.findings) or None,
            notes=notes,
        )
    except (OSError, ValueError) as error:
        if isinstance(error, InitializationConflict):
            # Typed conflicts retain their exact paths through the result adapter.
            conflicts = {item.path for item in error.outputs}
            # Preserve all unaffected dispositions when a freshness check fails.
            outputs = tuple(
                InitializationOutput(
                    path=item.path,
                    kind=item.kind,
                    status="conflict" if item.path in conflicts else item.status,
                    sha256=item.sha256,
                )
                for item in outputs
            )
        if not dry_run and not revoked:
            try:
                io.invalidate_authority()
                revoked = True
            except OSError as invalidation_error:
                error = OSError(
                    f"{error}; authority invalidation failed: {invalidation_error}"
                )
        return InitializationResult(
            ok=False,
            outputs=outputs,
            validation=plan.mutation.validation,
            authority_invalidated=revoked,
            error=str(error),
            notes=notes,
        )


def initialize_workspace(
    request: InitializationRequest,
    *,
    io: InitializationIO,
    templates: InitializationTemplates | None = None,
    dry_run: bool = False,
    force: bool = False,
) -> InitializationResult:
    """
    Provide the typed root entrypoint; invalid existing content fails before writes.
    """
    plan = plan_initialization(request, io=io, templates=templates)
    return commit_initialization(plan, io=io, dry_run=dry_run, force=force)


def validate_template_set(template_root: Path, fs: FileSystem) -> None:
    """
    Preserve the legacy helper's complete missing-template diagnostics without writes.
    """
    # Report every missing legacy template in one actionable diagnostic.
    missing = (
        [str(template_root)]
        if not fs.exists(template_root)
        else [
            str(path)
            for path in EXPECTED_TEMPLATE_RELATIVE_PATHS
            if not fs.exists(template_root / path)
        ]
    )
    if missing:
        raise FileNotFoundError(
            "Missing required discovery template path(s): " + ", ".join(missing)
        )


def validate_target_path(target_dir: Path, fs: FileSystem, *, force: bool) -> None:
    """Preserve path-type diagnostics; a nonempty directory alone is not a conflict."""
    del force
    if not fs.exists(target_dir.parent):
        raise FileNotFoundError(
            f"Target directory's parent does not exist: {target_dir.parent}"
        )
    if fs.exists(target_dir) and not fs.is_dir(target_dir):
        raise NotADirectoryError(
            f"Target path exists and is not a directory: {target_dir}"
        )


def substitute_placeholders(text: str, tokens: Mapping[str, str] | None = None) -> str:
    """
    Retain the legacy literal substitution helper, separate from typed v2 rendering.
    """
    # Legacy callers rely on literal token substitution with no parsing semantics.
    for token, value in (tokens or {}).items():
        text = text.replace(token, value)
    return text


def create_discovery_workspace(
    target_dir: Path,
    template_root: Path,
    fs: FileSystem,
    *,
    force: bool = False,
) -> None:
    """Reject unsafe legacy writes with actionable v2 migration instructions.

    Import/helper/template-error compatibility remains. FileSystem.write_text
    cannot prove exclusive creation or native authority, and force cannot fix it.
    """
    validate_template_set(template_root, fs)
    validate_target_path(target_dir, fs, force=force)
    raise ValueError(
        "Legacy initialization lacks explicit v2 identity/configuration "
        "and trusted writes. Use initialize_workspace(InitializationRequest(...), "
        "io=InitializationIO.local(...)) with system ID/name, repository ID, "
        "role and source roots or explicit draft_configuration. "
        "force never permits overwriting existing content."
    )
