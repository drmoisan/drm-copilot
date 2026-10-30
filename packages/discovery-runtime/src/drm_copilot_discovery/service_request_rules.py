"""Check the approved finite service input matrix without dispatching operations."""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from drm_copilot_discovery.models import JsonObject

_ROOT_MODES = ("structural", "discovery-complete", "parity-complete", "planning")
_INPUTS = {
    "init": (
        "system_id",
        "system_name",
        "system_role",
        "repository_id",
        "production_roots",
        "test_roots",
        "draft",
    ),
    "configure": ("configuration_action", "input_path"),
    "profile": ("input_path",),
    "validate-profile": ("input_path",),
    "inventory": ("analyzer_ids",),
    "new-contract": ("feature_id", "name", "capability_group", "input_path"),
    "new-scenario": ("scenario_id", "feature_ids", "input_path"),
    "update-artifact": (
        "artifact_kind",
        "artifact_path",
        "artifact_id",
        "input_path",
        "expected_sha256",
        "update_action",
        "approval_owner",
        "approval_evidence_refs",
    ),
    "link-evidence": (
        "artifact_kind",
        "artifact_id",
        "evidence_path",
        "expected_sha256",
    ),
    "validate-feature-contract": ("artifact_path",),
    "validate-coverage-ledger": ("artifact_path",),
    "validate-runtime-scenario": ("artifact_path",),
    "validate-parity-matrix": ("artifact_path",),
    "validate-unspecified-behavior": ("artifact_path",),
    "validate-product-decision": ("artifact_path",),
    "validate-evidence-reference": ("artifact_path",),
    "validate-decisions": (),
    "validate-all": ("output_prefix",),
    "coverage-report": (),
    "parity-report": (),
    "completion-report": (),
    "generate-acceptance": (
        "acceptance_kind",
        "feature_ids",
        "repository_id",
        "client_ids",
        "mode_ids",
        "platform_ids",
        "output_format",
    ),
    "snapshot-export": ("selected_ids", "paths"),
    "snapshot-import": ("manifest_path",),
    "import-inventory": ("manifest_path",),
    "migrate": (
        "from_version",
        "to_version",
        "destination",
        "input_path",
        "paths",
        "system_id",
        "system_name",
        "system_role",
        "repository_id",
        "production_roots",
        "test_roots",
        "draft",
    ),
    "doctor": (),
    "read-source": (
        "read_operation",
        "paths",
        "query",
        "regex",
        "max_bytes",
        "line_start",
        "line_end",
    ),
    "prepare-agent": (
        "skill_id",
        "selected_ids",
        "paths",
        "expected_outputs",
        "execution_context",
        "complexity",
    ),
    "finalize-agent": (),
}
_REQUIRED = {
    "init": ("system_id", "system_name", "system_role", "repository_id"),
    "configure": ("configuration_action",),
    "new-contract": ("feature_id", "name"),
    "new-scenario": ("scenario_id", "feature_ids", "input_path"),
    "update-artifact": (
        "artifact_kind",
        "artifact_path",
        "input_path",
        "expected_sha256",
        "update_action",
    ),
    "link-evidence": (
        "artifact_kind",
        "artifact_id",
        "evidence_path",
        "expected_sha256",
    ),
    "generate-acceptance": ("acceptance_kind",),
    "snapshot-export": ("selected_ids",),
    "snapshot-import": ("manifest_path",),
    "import-inventory": ("manifest_path",),
    "migrate": (
        "from_version",
        "to_version",
        "destination",
        "system_id",
        "system_name",
        "system_role",
        "repository_id",
    ),
    "read-source": ("read_operation", "paths"),
    "prepare-agent": (
        "skill_id",
        "selected_ids",
        "paths",
        "expected_outputs",
        "execution_context",
        "complexity",
    ),
}
_REPORTS = ("validate-all", "coverage-report", "parity-report", "completion-report")
# The controlled operation set: the union of the native adapters' tool table,
# pinned by tests/fixtures/discovery_host/controlled-operations.json. A host
# principal is admitted only for these operations (finalize-agent is a member).
CONTROLLED_OPERATIONS = frozenset(
    {
        "completion-report",
        "coverage-report",
        "finalize-agent",
        "generate-acceptance",
        "inventory",
        "link-evidence",
        "new-contract",
        "new-scenario",
        "parity-report",
        "profile",
        "read-source",
        "sentinel",
        "update-artifact",
        "validate-all",
        "validate-coverage-ledger",
        "validate-decisions",
        "validate-evidence-reference",
        "validate-feature-contract",
        "validate-parity-matrix",
        "validate-product-decision",
        "validate-profile",
        "validate-runtime-scenario",
        "validate-unspecified-behavior",
    }
)
_ROLE_AWARE = (
    "inventory",
    "new-contract",
    "new-scenario",
    "update-artifact",
    "link-evidence",
    "generate-acceptance",
    "read-source",
)
_PLANNABLE = (
    "init",
    "configure",
    "inventory",
    "new-contract",
    "new-scenario",
    "update-artifact",
    "link-evidence",
    "generate-acceptance",
    "snapshot-export",
    "snapshot-import",
    "import-inventory",
    "migrate",
    *_REPORTS,
)


def _conditions(operation: str, inputs: dict[str, object], profile: object) -> None:
    """Check fixed conditional inputs; return None or fixed ValueError.

    operation is a known name; inputs is a prechecked flat field dictionary;
    profile is the nullable top-level profile path. No lookup, copying, I/O or
    graph evaluation occurs. Captured existence/identity checks remain downstream.
    """
    if (
        operation == "init"
        and not inputs.get("draft", False)
        and not inputs.get("production_roots")
    ):
        raise ValueError("Configured initialization requires production roots")
    if operation == "configure":
        if inputs["configuration_action"] == "activate" and not (
            inputs.get("input_path") or profile
        ):
            raise ValueError("Activation requires an explicit profile selection")
        if inputs["configuration_action"] == "deactivate" and "input_path" in inputs:
            raise ValueError("Deactivation does not accept an input path")
    if (
        operation in ("profile", "validate-profile")
        and profile is not None
        and "input_path" in inputs
        and inputs["input_path"] != profile
    ):
        raise ValueError("Profile selections must agree")
    if operation == "new-scenario" and not inputs["feature_ids"]:
        raise ValueError("Scenario creation requires selected feature IDs")
    if operation == "snapshot-export" and not inputs["selected_ids"]:
        raise ValueError("Snapshot export requires selected identities")
    if (
        operation == "inventory"
        and "analyzer_ids" in inputs
        and not inputs["analyzer_ids"]
    ):
        raise ValueError("Explicit analyzer selection cannot be empty")
    if operation == "update-artifact":
        approval = ("approval_owner", "approval_evidence_refs")
        # Approval binds a decision identity; replacement cannot imply approval.
        if inputs["update_action"] == "approve-decision":
            if inputs["artifact_kind"] != "product-decision" or not all(
                inputs.get(key) for key in (*approval, "artifact_id")
            ):
                raise ValueError("Decision approval requires identity and proof")
        elif any(key in inputs for key in approval):
            raise ValueError("Replacement does not accept approval fields")
    if operation == "link-evidence" and inputs["expected_sha256"] is None:
        raise ValueError("Evidence links require the captured target digest")
    if operation == "migrate" and (
        bool(inputs.get("input_path")) == bool(inputs.get("paths"))
    ):
        raise ValueError("Migration requires exactly one source selection")
    if operation == "read-source":
        action = inputs["read_operation"]
        if action == "search" and not inputs.get("query"):
            raise ValueError("Source search requires a query")
        if action != "search" and any(key in inputs for key in ("query", "regex")):
            raise ValueError("Non-search reads cannot carry search fields")
        if action != "read" and any(
            key in inputs for key in ("line_start", "line_end")
        ):
            raise ValueError("Line selection applies only to read")
        if (
            "line_start" in inputs
            and "line_end" in inputs
            and cast("int", inputs["line_start"]) > cast("int", inputs["line_end"])
        ):
            raise ValueError("Source line range must be ordered")


def check_combinations(fields: dict[str, object]) -> None:
    """Check bounded schema-shaped fields against the fixed operation matrix.

    Return None or raise fixed ValueError for foreign/missing inputs or invalid
    mode/format/flag/conditional combinations. The caller reserves flat-field
    traversal before this function. No callbacks, modules, authority, graph
    assessment or filesystem operations are selected or executed.
    """
    operation = cast("str", fields["operation"])
    mode = fields["mode"]
    inputs = cast("JsonObject", fields["inputs"])
    if type(operation) is not str or operation not in _INPUTS:
        raise ValueError("Service operation is unsupported")
    modes = ("structural",)
    # Root reports and protected role-aware operations have distinct mode sets.
    if operation in (*_REPORTS, "prepare-agent"):
        modes = _ROOT_MODES
    elif operation in _ROLE_AWARE:
        modes = ("structural", "agent-output")
    elif operation == "finalize-agent":
        modes = ("agent-output",)
    if mode not in modes or (
        mode == "agent-output" and fields["invocation_ref"] is None
    ):
        raise ValueError("Service operation does not accept the selected mode")
    if operation not in _REPORTS and fields["format"] != "json":
        raise ValueError("This operation requires JSON representation")
    if operation not in _PLANNABLE and (fields["dry_run"] or fields["write"]):
        raise ValueError("This operation does not support a publication plan")
    allowed = _INPUTS[operation]
    # Small fixed allowlists bound exact comparisons before the single index copy.
    if any(key not in allowed for key, _ in inputs.members):
        raise ValueError("Service operation contains inapplicable input fields")
    values: dict[str, object] = dict(inputs.members)
    required = _REQUIRED.get(operation, ())
    if operation.startswith("validate-") and allowed == ("artifact_path",):
        required = ("artifact_path",)
    if any(key not in values for key in required):
        raise ValueError("Service operation requires additional input fields")
    _conditions(operation, values, fields["profile_path"])
