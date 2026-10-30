"""Constrain direct discovery routing to the fixed operation contracts.

This module is the pure companion of ``resolve_codex_topology``. Its constants
mirror ``discovery_operations`` and the four discovery generated-agent families
recorded in ``config/orchestration-routing.json``. A discovery receipt names a
specialist role and its permissible output kinds; it grants no filesystem,
configuration, approval, installation, or native tool authority.
"""

from __future__ import annotations

from typing import Literal, TypedDict

InvocationKind = Literal["ordinary", "discovery"]

VALID_INVOCATION_KINDS: tuple[InvocationKind, ...] = ("ordinary", "discovery")
DISCOVERY_ROUTE = "discovery"
DISCOVERY_TOPOLOGY = "discovery_specialist"
DISCOVERY_ROUTING_REASON = "fixed_discovery_operation"
DISCOVERY_OUTPUT_CONTRACT_VERSION = "2.0.0"
DISCOVERY_GATE_MODE = "agent-output"
DISCOVERY_GENERATED_AGENT_FAMILIES: tuple[str, ...] = (
    "legacy-parity-analyst",
    "runtime-characterization-analyst",
    "requirements-reconciler",
    "migration-coverage-reviewer",
)

# Exact rejection messages shared by the Python, PowerShell, and TypeScript
# resolvers; the CLI corpus asserts these substrings.
INVOCATION_KIND_MESSAGE = "invocation_kind must be ordinary or discovery."
ORDINARY_SKILL_MESSAGE = "skill_id is only valid for discovery invocations."
ROOT_PERSONA_MESSAGE = "Discovery invocations do not accept root_persona."
PRODUCTION_COUNT_MESSAGE = "Discovery invocations require production_file_count=0."
TEST_COUNT_MESSAGE = "Discovery invocations require test_file_count=0."
LANGUAGES_MESSAGE = "Discovery invocations do not accept languages."
CROSS_CUTTING_MESSAGE = "Discovery invocations do not accept cross_cutting."
SKILL_ID_MESSAGE = "Discovery invocations require a supported skill_id."


class DiscoveryOperation(TypedDict):
    """Fixed routing contract for one canonical discovery workflow."""

    logical_agent: str
    output_contract_version: str
    permissible_artifact_kinds: tuple[str, ...]
    gate_mode: str


class CodexDiscoveryTopologyReceipt(TypedDict):
    """Deterministic discovery topology decision persisted before delegation.

    The twelve ordinary receipt keys are retained so that consumers reading an
    ordinary receipt shape still find them; five discovery-only keys follow.
    """

    execution_context: str
    languages: list[str]
    production_file_count: int
    test_file_count: int
    cross_cutting: bool
    root_persona: None
    route: str
    topology: str
    logical_agent: str
    routing_reason: str
    max_production_files: int
    max_test_files: int
    invocation_kind: str
    skill_id: str
    output_contract_version: str
    permissible_artifact_kinds: list[str]
    gate_mode: str


def _operation(logical_agent: str, kinds: tuple[str, ...]) -> DiscoveryOperation:
    """Build one fixed operation row with the shared version and gate mode.

    Args:
        logical_agent: The specialist role the skill routes to.
        kinds: Sorted permissible artifact kinds for the skill.

    Returns:
        DiscoveryOperation: The completed operation row.
    """

    return {
        "logical_agent": logical_agent,
        "output_contract_version": DISCOVERY_OUTPUT_CONTRACT_VERSION,
        "permissible_artifact_kinds": kinds,
        "gate_mode": DISCOVERY_GATE_MODE,
    }


# Each exact skill keeps its own kinds: sharing a role never broadens them.
DISCOVERY_OPERATIONS: dict[str, DiscoveryOperation] = {
    "inventory-legacy-system": _operation(
        "legacy-parity-analyst",
        (
            "coverage-ledger",
            "evidence-reference",
            "inventory-snapshot",
            "required-output-manifest",
            "unspecified-behavior",
            "unspecified-behavior-collection",
        ),
    ),
    "extract-feature-contract": _operation(
        "legacy-parity-analyst",
        (
            "coverage-ledger",
            "evidence-reference",
            "feature-contract",
            "required-output-manifest",
            "unspecified-behavior",
            "unspecified-behavior-collection",
        ),
    ),
    "characterize-runtime-behavior": _operation(
        "runtime-characterization-analyst",
        (
            "evidence-payload",
            "evidence-reference",
            "required-output-manifest",
            "runtime-characterization-scenario",
            "unspecified-behavior",
            "unspecified-behavior-collection",
        ),
    ),
    "reconcile-parity-matrix": _operation(
        "requirements-reconciler",
        (
            "parity-matrix",
            "required-output-manifest",
            "unspecified-behavior",
            "unspecified-behavior-collection",
        ),
    ),
    "review-discovery-coverage": _operation(
        "migration-coverage-reviewer",
        (
            "completion-report",
            "coverage-report",
            "parity-report",
            "required-output-manifest",
            "validation-report",
        ),
    ),
    "adjudicate-unspecified-behavior": _operation(
        "requirements-reconciler",
        (
            "acceptance-specification",
            "acceptance-view",
            "product-decision",
            "product-decision-collection",
            "required-output-manifest",
            "unspecified-behavior",
            "unspecified-behavior-collection",
        ),
    ),
    "generate-acceptance-scenarios": _operation(
        "requirements-reconciler",
        ("acceptance-specification", "acceptance-view", "required-output-manifest"),
    ),
    "initialize-discovery-workspace": _operation(
        "migration-coverage-reviewer",
        ("coverage-report", "required-output-manifest", "validation-report"),
    ),
    "validate-discovery-artifacts": _operation(
        "migration-coverage-reviewer",
        ("coverage-report", "required-output-manifest", "validation-report"),
    ),
}


def validate_invocation_kind(value: object) -> InvocationKind:
    """Return the exact invocation kind or reject every other value.

    Args:
        value: The caller-supplied selector. Only the exact lowercase strings
            ``ordinary`` and ``discovery`` are accepted; no coercion applies.

    Returns:
        InvocationKind: The validated selector.

    Raises:
        ValueError: If the value is not one of the two exact selectors.
    """

    # Identity membership on the exact tuple rejects case variants, blanks,
    # and non-string values without string coercion.
    if value == "ordinary":
        return "ordinary"
    if value == "discovery":
        return "discovery"
    raise ValueError(INVOCATION_KIND_MESSAGE)


def resolve_codex_discovery_topology(
    *,
    invocation_kind: object,
    skill_id: object,
    execution_context: str,
    languages: list[str],
    production_file_count: int,
    test_file_count: int,
    cross_cutting: bool,
    root_persona: object,
) -> CodexDiscoveryTopologyReceipt | None:
    """Select a fixed discovery role or allow the unchanged ordinary route.

    Called after the topology resolver has validated the execution context,
    normalized the languages, and checked the count and boolean types. The
    guards run in the shared contract order so that every language resolver
    reports the same first failure for the same malformed request.

    Args:
        invocation_kind: Exact ``ordinary`` or ``discovery`` selector.
        skill_id: Exact canonical skill for discovery; ``None`` for ordinary.
        execution_context: Already validated execution context.
        languages: Already normalized languages; discovery requires none.
        production_file_count: Already validated count; discovery requires 0.
        test_file_count: Already validated count; discovery requires 0.
        cross_cutting: Already validated flag; discovery requires ``False``.
        root_persona: Raw root override; discovery requires ``None``.

    Returns:
        CodexDiscoveryTopologyReceipt | None: A fresh discovery receipt, or
        ``None`` when the ordinary path must continue unchanged.

    Raises:
        ValueError: If the selector, an ordinary ``skill_id``, or any
            discovery-forbidden field is present or malformed.
    """

    kind = validate_invocation_kind(invocation_kind)
    # Ordinary requests must not carry a skill; otherwise the unchanged
    # ordinary root/epic/count path continues in the caller.
    if kind == "ordinary":
        if skill_id is not None:
            raise ValueError(ORDINARY_SKILL_MESSAGE)
        return None

    # Discovery scope is rejected before the role lookup so that the guard
    # order is stable even when several fields are malformed at once.
    if root_persona is not None:
        raise ValueError(ROOT_PERSONA_MESSAGE)
    if production_file_count != 0:
        raise ValueError(PRODUCTION_COUNT_MESSAGE)
    if test_file_count != 0:
        raise ValueError(TEST_COUNT_MESSAGE)
    if languages:
        raise ValueError(LANGUAGES_MESSAGE)
    if cross_cutting:
        raise ValueError(CROSS_CUTTING_MESSAGE)
    if not isinstance(skill_id, str) or skill_id not in DISCOVERY_OPERATIONS:
        raise ValueError(SKILL_ID_MESSAGE)

    operation = DISCOVERY_OPERATIONS[skill_id]
    return {
        "execution_context": execution_context,
        "languages": [],
        "production_file_count": 0,
        "test_file_count": 0,
        "cross_cutting": False,
        "root_persona": None,
        "route": DISCOVERY_ROUTE,
        "topology": DISCOVERY_TOPOLOGY,
        "logical_agent": operation["logical_agent"],
        "routing_reason": DISCOVERY_ROUTING_REASON,
        "max_production_files": 0,
        "max_test_files": 0,
        "invocation_kind": "discovery",
        "skill_id": skill_id,
        "output_contract_version": operation["output_contract_version"],
        "permissible_artifact_kinds": list(operation["permissible_artifact_kinds"]),
        "gate_mode": operation["gate_mode"],
    }
