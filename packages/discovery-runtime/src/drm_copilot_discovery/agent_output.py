"""Check exact role output data without treating it as protected host authority."""

from __future__ import annotations

from dataclasses import dataclass, replace
from hashlib import sha256
from typing import TYPE_CHECKING

from drm_copilot_discovery.coverage_scope_rules import object_rows
from drm_copilot_discovery.findings import Finding, FindingCollector
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.path_policy import FILE_KEYS, OUTPUT_LOCATIONS
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.schema_validation import validate_document

if TYPE_CHECKING:
    from drm_copilot_discovery.profile_models import ArtifactKey
    from drm_copilot_discovery.references import ReferenceIndex
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot

REPORT_KINDS = frozenset(
    {"coverage-report", "parity-report", "completion-report", "validation-report"}
)
_COMMON = frozenset({"required-output-manifest"})
_QUESTIONS = frozenset({"unspecified-behavior", "unspecified-behavior-collection"})
_OUTPUTS = {
    "legacy-parity-analyst": _COMMON
    | _QUESTIONS
    | {
        "inventory-snapshot",
        "coverage-ledger",
        "feature-contract",
        "evidence-reference",
    },
    "runtime-characterization-analyst": _COMMON
    | _QUESTIONS
    | {"runtime-characterization-scenario", "evidence-reference", "evidence-payload"},
    "requirements-reconciler": _COMMON
    | _QUESTIONS
    | {
        "parity-matrix",
        "product-decision",
        "product-decision-collection",
        "acceptance-specification",
        "acceptance-view",
    },
    "migration-coverage-reviewer": _COMMON | REPORT_KINDS,
}
_MEMBERS = {
    "coverage-ledger": "components",
    "parity-matrix": "entries",
    "product-decision-collection": "records",
    "unspecified-behavior-collection": "records",
}


@dataclass(frozen=True, kw_only=True)
class InvocationContext:
    """Carry caller-verified invocation data and immutable pre-invocation inputs.

    Native code must authenticate this context before calling Python. Constructing
    this value or validating its mirrored JSON never grants tool/write authority.
    Selected IDs constrain changes to members of existing shared artifacts.
    """

    baseline: DiscoverySnapshot
    role: str
    invocation_id: str
    workspace: JsonObject
    required_outputs: JsonObject
    selected_ids: tuple[str, ...] = ()
    review_mode: str | None = None

    def __post_init__(self) -> None:
        """Detach selector values; contextual identity is checked with output bytes."""
        # Native-selected identities remain deterministic even if caller order varies.
        object.__setattr__(self, "selected_ids", tuple(sorted(set(self.selected_ids))))


@dataclass(frozen=True)
class OutputValidation:
    """Return output-contract findings without asserting the reviewed gate passed."""

    findings: tuple[Finding, ...]
    manifest_sha256: str


def required_output_digest(manifest: JsonObject) -> str:
    """Hash exact manifest content excluding its own checksum; perform no I/O."""
    # Array order remains bound; only the self-referential checksum field is omitted.
    content = JsonObject(
        tuple(
            (key, value) for key, value in manifest.items() if key != "manifest_sha256"
        )
    )
    return sha256(canonical_json(content)).hexdigest()


def historical_report(
    snapshot: DiscoverySnapshot,
    artifact: ArtifactSnapshot,
    invocation: InvocationContext,
) -> bool:
    """Preserve unchanged unrequested prior views during a bounded analyst update."""
    # A requested report always has current obligations, even when its bytes match.
    if any(
        row.get("path") == artifact.path
        for _, row in object_rows(invocation.required_outputs.get("outputs"))
    ):
        return False
    # Baseline presence and exact bytes establish a preserved historical view.
    previous = next(
        (
            file
            for file in invocation.baseline.manifest.files
            if file.path == artifact.path
        ),
        None,
    )
    return previous is not None and previous == snapshot.file(artifact.path)


class _OutputRules:
    """Compare one prospective graph with the caller's exact baseline and output set.

    All checks are pure except the call-local bounded finding collector. Existing
    unrelated bytes, unselected collection members and approved policy stay fixed.
    """

    def __init__(
        self, snapshot: DiscoverySnapshot, invocation: InvocationContext
    ) -> None:
        """Map immutable captured files for deterministic comparison."""
        self.snapshot, self.invocation = snapshot, invocation
        self.collector = FindingCollector(
            limit=snapshot.profile.limits.parse_limits().findings
        )
        # Full captured sets detect additions, deletions and category substitutions.
        self.before = {file.path: file for file in invocation.baseline.manifest.files}
        self.after = {file.path: file for file in snapshot.manifest.files}
        self.artifacts = {item.path: item for item in snapshot.artifacts}

    def add(self, code: str, message: str, path: str | None = None) -> None:
        """Append an actionable finding with an optional captured path."""
        self.collector.add(
            Finding(
                code=code,
                message=message,
                artifact_path=path,
                next_action="Restore the exact invocation outputs and revalidate.",
            )
        )

    def manifest(self) -> bool:
        """Validate the fixed manifest schema and independent invocation bindings."""
        context = self.invocation
        manifest = context.required_outputs
        checked = validate_document(
            canonical_json(manifest),
            expected_kind="required-output-manifest",
            expected_version="2.0.0",
            catalog=self.snapshot.catalog,
            limits=self.snapshot.profile.limits.parse_limits(),
        )
        # Malformed control data cannot supply output paths to later checks.
        for finding in checked.findings:
            self.collector.add(finding)
        if not checked.ok:
            return False
        # Compare independent caller bindings rather than trusting authored mirrors.
        if (
            context.role not in _OUTPUTS
            or manifest.get("role") != context.role
            or manifest.get("invocation_id") != context.invocation_id
            or manifest.get("workspace") != context.workspace
            or manifest.get("manifest_sha256") != required_output_digest(manifest)
        ):
            self.add(
                "OUTPUT_BINDING",
                "Output manifest differs from the caller's invocation binding.",
            )
        profile_path = context.workspace.get("profile_path")
        profile = (
            self.after.get(profile_path) if isinstance(profile_path, str) else None
        )
        if (
            profile is None
            or profile.sha256 != context.workspace.get("profile_sha256")
            or profile_path != self.snapshot.profile.artifacts["profile"]
            or self.snapshot.profile.document != context.baseline.profile.document
        ):
            self.add("OUTPUT_PROFILE", "Invocation profile bytes or identity changed.")
        return True

    def output(self, row: JsonObject) -> None:
        """Bind one required identity/format/path to current bytes and baseline hash."""
        kind, path, identifier = (
            row.get("artifact_kind"),
            row.get("path"),
            row.get("id"),
        )
        if not isinstance(kind, str) or not isinstance(path, str):
            return
        if kind not in _OUTPUTS.get(self.invocation.role, frozenset()):
            self.add(
                "OUTPUT_ROLE",
                "The invocation role cannot produce this artifact kind.",
                path,
            )
        # Profile roots cap the exact grant without granting arbitrary neighboring
        # paths.
        location: ArtifactKey | None = next(
            (key for candidate, key in OUTPUT_LOCATIONS if candidate == kind), None
        )
        root = self.snapshot.profile.artifacts[location] if location else None
        if root is None or not (
            path == root if location in FILE_KEYS else path.startswith(root + "/")
        ):
            self.add(
                "OUTPUT_PATH",
                "Output path does not match the configured artifact location.",
                path,
            )
        before, after = self.before.get(path), self.after.get(path)
        if row.get("expected_sha256") != (before.sha256 if before else None):
            self.add(
                "OUTPUT_PRECONDITION",
                "Output baseline content precondition does not match.",
                path,
            )
        if after is None:
            self.add("OUTPUT_MISSING", "A required output is absent.", path)
            return
        format = row.get("format")
        suffix = path.rsplit(".", 1)[-1].lower()
        if format != "binary" and suffix not in {
            "json": {"json"},
            "yaml": {"yaml", "yml"},
            "markdown": {"md"},
            "gherkin": {"feature"},
        }.get(str(format), set()):
            self.add(
                "OUTPUT_FORMAT", "Output format does not match its exact path.", path
            )
        artifact = self.artifacts.get(path)
        # Structured identity is mandatory except for explicitly allowed opaque views.
        if format in ("json", "yaml"):
            if (
                artifact is None
                or artifact.expected_kind != kind
                or artifact.document is None
                or artifact.document.get("id") != identifier
            ):
                self.add(
                    "OUTPUT_IDENTITY",
                    "Required artifact kind/ID does not match parsed bytes.",
                    path,
                )
        elif (
            kind not in {"evidence-payload", "acceptance-view"} | REPORT_KINDS
            or not after.content
        ):
            self.add(
                "OUTPUT_FORMAT",
                "This output requires a structured artifact or nonempty view.",
                path,
            )
        if kind == "required-output-manifest" and (
            artifact is None or artifact.document != self.invocation.required_outputs
        ):
            self.add(
                "OUTPUT_MANIFEST",
                "Stored output manifest differs from the required invocation manifest.",
                path,
            )
        if (
            self.invocation.role == "migration-coverage-reviewer"
            and kind in REPORT_KINDS
            and format == "json"
        ):
            if (
                artifact is None
                or artifact.document is None
                or artifact.document.get("mode") != self.invocation.review_mode
            ):
                self.add(
                    "OUTPUT_REVIEW_MODE",
                    "Reviewer output must use the invocation's requested mode.",
                    path,
                )

    def preserve_members(
        self, previous: ArtifactSnapshot, current: ArtifactSnapshot
    ) -> None:
        """Keep unselected members fixed when a granted collection file is updated."""
        field = _MEMBERS.get(previous.expected_kind)
        if field is None or previous.document is None or current.document is None:
            return
        # Shared files may contain unrelated identities outside this invocation.
        old = {
            str(row.get("id", row.get("component_id"))): row
            for _, row in object_rows(previous.document.get(field))
        }
        new = {
            str(row.get("id", row.get("component_id"))): row
            for _, row in object_rows(current.document.get(field))
        }
        # A file-level output grant cannot silently expand the selected member IDs.
        for identity in old.keys() | new.keys():
            before, after = old.get(identity), new.get(identity)
            selectors = {identity}
            for item in (before, after):
                if item is not None:
                    selectors.add(str(item.get("feature_id", item.get("component_id"))))
            if before != after and not selectors.intersection(
                self.invocation.selected_ids
            ):
                self.add(
                    "OUTPUT_UNSELECTED",
                    "An unselected shared-artifact member changed.",
                    current.path,
                )

    def changes(
        self, rows: tuple[tuple[int, JsonObject], ...], index: ReferenceIndex
    ) -> None:
        """Limit changes and preserve protected decisions and collection members."""
        paths = tuple(str(row.get("path")) for _, row in rows)
        if len(paths) != len(set(paths)):
            self.add("OUTPUT_DUPLICATE", "Required outputs contain duplicate paths.")
        if not any(
            row.get("artifact_kind") == "required-output-manifest" for _, row in rows
        ):
            self.add(
                "OUTPUT_MANIFEST",
                "The exact output set must include its stored manifest.",
            )
        if self.invocation.role == "migration-coverage-reviewer" and not any(
            row.get("artifact_kind") in REPORT_KINDS and row.get("format") == "json"
            for _, row in rows
        ):
            self.add(
                "OUTPUT_REVIEW",
                "Reviewer output needs a recomputable structured report.",
            )
        # Every added, deleted or changed captured path is part of the comparison.
        for path in self.before.keys() | self.after.keys():
            if self.before.get(path) != self.after.get(path) and path not in paths:
                self.add(
                    "OUTPUT_UNEXPECTED", "An ungranted captured input changed.", path
                )
        # Granted file replacement still preserves unselected collection members.
        previous = {item.path: item for item in self.invocation.baseline.artifacts}
        for path, current in self.artifacts.items():
            if path in previous:
                self.preserve_members(previous[path], current)
        baseline_snapshot = self.invocation.baseline
        # Historical derived views are not authored identities in the decision graph.
        baseline = index_references(
            replace(
                baseline_snapshot,
                artifacts=tuple(
                    item
                    for item in baseline_snapshot.artifacts
                    if item.expected_kind not in REPORT_KINDS
                ),
            )
        )
        # Protected historical states must match by trusted repository and record ID.
        old_decisions = {
            (record.repository, record.id): record
            for record in baseline.records
            if record.kind == "product-decision"
        }
        new_decisions = {
            (record.repository, record.id): record
            for record in index.records
            if record.kind == "product-decision"
        }
        # These roles may propose decisions; approval and historical statuses stay
        # fixed.
        for key in old_decisions.keys() | new_decisions.keys():
            old, new = old_decisions.get(key), new_decisions.get(key)
            if old is not None and new is not None and old.document == new.document:
                continue
            if (
                old is not None
                and old.document.get("status") != "proposed"
                or new is not None
                and new.document.get("status") != "proposed"
            ):
                self.add(
                    "OUTPUT_APPROVAL",
                    "Analyst output cannot change approved or historical decisions.",
                )


def validate_agent_output(
    snapshot: DiscoverySnapshot, *, invocation: InvocationContext, index: ReferenceIndex
) -> OutputValidation:
    """Validate exact outputs against caller context without issuing authority."""
    rules = _OutputRules(snapshot, invocation)
    if rules.manifest():
        rows = object_rows(invocation.required_outputs.get("outputs"))
        # Check every declared output even when another output has already failed.
        for _, row in rows:
            rules.output(row)
        rules.changes(rows, index)
    return OutputValidation(
        rules.collector.findings, required_output_digest(invocation.required_outputs)
    )
