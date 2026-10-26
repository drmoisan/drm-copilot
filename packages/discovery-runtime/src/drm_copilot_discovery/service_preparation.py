"""Pin the pre-invocation baseline of every expected agent output for a root caller."""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.operations import OperationContext, OperationFailure
from drm_copilot_discovery.path_models import PathPolicyError, WriteGrant
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.service_contracts import ServiceArtifact

if TYPE_CHECKING:
    from drm_copilot_discovery.models import JsonObject
    from drm_copilot_discovery.service_contracts import DiscoveryResult


def _row_problem(code: str, path: str, message: str) -> Finding:
    """Return one blocking Finding for an expected-output row; perform no I/O.

    code (str) is a fixed PREPARE_* class, path (str) is the row's requested
    relative path and message (str) states the violated condition. No untrusted
    exception text or host path is copied into the diagnostic.
    """
    return Finding(
        code=code,
        pointer="/inputs/expected_outputs",
        artifact_path=path,
        message=message,
        next_action="Correct the expected output row and prepare again.",
    )


def _planned_row(
    context: OperationContext, policy: PathPolicy, row: JsonObject
) -> tuple[Finding | None, ServiceArtifact | None]:
    """Check one expected-output row against the configured capture.

    context (OperationContext) owns the captured files and budget; policy
    (PathPolicy) resolves the kind's exact output location; row (JsonObject) is
    one schema-validated `required-output-manifest` output. Returns a pair of an
    optional blocking Finding and an optional planned ServiceArtifact: both are
    None for a valid row whose path is absent, exactly one is set otherwise.
    Metadata reads go through the captured workspace only; OSError propagates.
    """
    kind = cast("str", row["artifact_kind"])
    identifier = cast("str", row["id"])
    path = cast("str", row["path"])
    expected = cast("str | None", row["expected_sha256"])
    # The grant must resolve through the same policy a later mutation will use,
    # so an output outside its kind's location is refused before any baseline is pinned.
    try:
        policy.resolve_write(
            path,
            grant=WriteGrant(artifact_kind=kind, artifact_id=identifier, path=path),
        )
    except PathPolicyError as error:
        return (
            _row_problem(
                "PREPARE_OUTPUT_LOCATION",
                path,
                f"The expected output is not writable for its kind ({error.code}).",
            ),
            None,
        )
    except ValueError:
        return (
            _row_problem(
                "PREPARE_OUTPUT_LOCATION",
                path,
                "The expected output has an invalid kind, identifier or path.",
            ),
            None,
        )
    captured = context.files.get(path)
    # A null digest asserts absence; a digest asserts the exact captured bytes.
    if captured is None:
        if expected is not None:
            return (
                _row_problem(
                    "PREPARE_OUTPUT_DIGEST",
                    path,
                    "The expected output is absent but a prior digest was supplied.",
                ),
                None,
            )
        return None, None
    if expected != captured.sha256:
        return (
            _row_problem(
                "PREPARE_OUTPUT_DIGEST",
                path,
                "The expected output digest differs from the captured bytes.",
            ),
            None,
        )
    context.budget.work(len(captured.content))
    try:
        text = captured.content.decode("utf-8")
    except UnicodeDecodeError:
        return (
            _row_problem(
                "PREPARE_OUTPUT_TEXT",
                path,
                "The existing expected output is not UTF-8 text.",
            ),
            None,
        )
    return None, ServiceArtifact(
        path=path, kind=kind, status="planned", sha256=captured.sha256, content=text
    )


def prepare_agent(context: OperationContext) -> DiscoveryResult:
    """Return the pre-invocation baseline for a root `prepare-agent` request.

    context (OperationContext) carries a local-user authority and a configured
    capture; the service refuses host markers before this route runs. The route
    checks every `expected_outputs` row for a unique path, a grant that resolves
    through PathPolicy.resolve_write, a digest equal to the captured bytes (or a
    null digest with an absent path) and UTF-8 content. Returns a DiscoveryResult
    with the complete captured input manifest and one planned ServiceArtifact per
    existing expected output on success (exit 0), or the blocking findings and no
    artifact row (exit 1). A non-structural mode raises OperationFailure. It
    performs no write and derives no grant or receipt.
    """
    # Only the structural root mode pins a baseline; other root modes are reports.
    if context.request.mode != "structural":
        raise OperationFailure("SERVICE_MODE")
    snapshot = context.snapshot
    baseline = context.baseline
    if baseline is None:
        raise OperationFailure("SERVICE_CAPTURE", exit_code=3)
    rows = cast("tuple[JsonObject, ...]", context.inputs["expected_outputs"])
    context.budget.work(4 * len(rows))
    policy = PathPolicy(
        snapshot.profile,
        workspace_root=baseline.workspace_root,
        metadata=baseline.inspect,
    )
    findings: list[Finding] = []
    artifacts: list[ServiceArtifact] = []
    seen: set[str] = set()
    # Check every row so the caller receives all defects in one round trip; a
    # duplicate path is refused because two rows cannot pin one baseline file.
    for row in rows:
        path = cast("str", row["path"])
        if path in seen:
            findings.append(
                _row_problem(
                    "PREPARE_OUTPUT_LOCATION",
                    path,
                    "The expected output path is listed more than once.",
                )
            )
            continue
        seen.add(path)
        finding, artifact = _planned_row(context, policy, row)
        if finding is not None:
            findings.append(finding)
        elif artifact is not None:
            artifacts.append(artifact)
    if findings:
        return context.result(findings=tuple(findings))
    return context.result(
        artifacts=tuple(artifacts),
        counts=(
            ("expected_outputs", len(rows)),
            ("existing_outputs", len(artifacts)),
        ),
    )
