"""Resolve Codex implementation topology from deterministic scope inputs.

This module owns only the file-count/language topology axis; model selection is
independent. It validates context and typed scope, normalizes languages,
enforces forced epic/parallel roots, applies escalation precedence, and returns
a serializable receipt. Pure helpers perform no I/O or input mutation. ``main``
alone parses arguments and writes JSON stdout.
"""

from __future__ import annotations

import argparse
import json
from typing import TYPE_CHECKING, Literal, TypedDict, cast

if TYPE_CHECKING:
    from collections.abc import Collection

ExecutionContext = Literal[
    "standalone",
    "epic_preparation_child",
    "epic_execution_child",
    "parallel_planning",
    "parallel_execution",
]
TopologyRoute = Literal["small", "large", "epic", "parallel"]
Topology = Literal["typed_engineer", "orchestrator", "epic_persona", "parallel_persona"]
RootPersona = Literal[
    "epic-planner",
    "epic-orchestrator",
    "parallel-planner",
    "parallel-orchestrator",
]

VALID_EXECUTION_CONTEXTS: frozenset[str] = frozenset(
    {
        "standalone",
        "epic_preparation_child",
        "epic_execution_child",
        "parallel_planning",
        "parallel_execution",
    }
)
EPIC_CHILD_CONTEXTS: frozenset[str] = frozenset(
    {"epic_preparation_child", "epic_execution_child"}
)
FORCED_ROOT_PERSONAS: frozenset[str] = frozenset(
    {
        "epic-planner",
        "epic-orchestrator",
        "parallel-planner",
        "parallel-orchestrator",
    }
)
PARALLEL_ROOT_CONTEXT_PERSONAS: dict[str, RootPersona] = {
    "parallel_planning": "parallel-planner",
    "parallel_execution": "parallel-orchestrator",
}
ORCHESTRATOR_LOGICAL_AGENT = "orchestrator"
ESCALATION_PRECEDENCE: tuple[str, ...] = (
    "epic_child_context",
    "invalid_estimate",
    "cross_language",
    "unsupported_language",
    "cross_cutting",
    "direct_mode_disabled",
    "production_budget_exceeded",
)


class LanguageBudget(TypedDict):
    """Describe one immutable-by-convention language routing budget.

    ``LANGUAGE_BUDGETS`` owns these mappings and the resolver reads them without
    mutation. Fields specify direct-mode enablement, production/test caps, and
    the typed engineer identity. The shape performs no validation or I/O.
    """

    direct_mode_enabled: bool
    max_production_files: int
    max_test_files: int
    logical_agent: str


class CodexTopologyReceipt(TypedDict):
    """Describe the complete topology decision persisted before delegation.

    ``resolve_codex_topology`` constructs the mapping after validating inputs and
    applying precedence. Fields retain normalized scope, selected route/topology,
    root and logical agents, reason, and applicable budgets. The shape has no
    behavior, mutation, or I/O.
    """

    execution_context: ExecutionContext
    languages: list[str]
    production_file_count: int
    test_file_count: int
    cross_cutting: bool
    root_persona: RootPersona | None
    route: TopologyRoute
    topology: Topology
    logical_agent: str
    routing_reason: str
    max_production_files: int | None
    max_test_files: int | None


LANGUAGE_BUDGETS: dict[str, LanguageBudget] = {
    "python": {
        "direct_mode_enabled": True,
        "max_production_files": 3,
        "max_test_files": 3,
        "logical_agent": "python-typed-engineer",
    },
    "powershell": {
        "direct_mode_enabled": True,
        "max_production_files": 2,
        "max_test_files": 3,
        "logical_agent": "powershell-typed-engineer",
    },
    "csharp": {
        "direct_mode_enabled": True,
        "max_production_files": 3,
        "max_test_files": 3,
        "logical_agent": "csharp-typed-engineer",
    },
    "typescript": {
        "direct_mode_enabled": False,
        "max_production_files": 0,
        "max_test_files": 0,
        "logical_agent": "typescript-engineer",
    },
}


def _validate_context(value: str) -> ExecutionContext:
    """Validate ``value`` and return its typed execution context.

    Raises:
        ValueError: The value is outside the supported context set.
    """

    if value not in VALID_EXECUTION_CONTEXTS:
        raise ValueError(
            "execution_context must be one of "
            f"{tuple(sorted(VALID_EXECUTION_CONTEXTS))}, found {value!r}."
        )
    return cast("ExecutionContext", value)


def _normalize_languages(languages: Collection[str]) -> list[str]:
    """Normalize ``languages`` and return unique lowercase values in order.

    Raises:
        ValueError: A member is not a non-blank string.
    """

    normalized: set[str] = set()
    # Validate and canonicalize every declared language before stable sorting.
    for language in cast("Collection[object]", languages):
        if not isinstance(language, str) or not language.strip():
            raise ValueError("languages must contain non-empty strings.")
        normalized.add(language.strip().lower())
    return sorted(normalized)


def _validate_counts(production_file_count: object, test_file_count: object) -> None:
    """Validate genuine integer file counts and return None.

    Raises:
        ValueError: Either count is a boolean or non-integer.
    """

    if isinstance(production_file_count, bool) or not isinstance(
        production_file_count, int
    ):
        raise ValueError("production_file_count must be an integer.")
    if isinstance(test_file_count, bool) or not isinstance(test_file_count, int):
        raise ValueError("test_file_count must be an integer.")


def _validate_cross_cutting(value: object) -> None:
    """Validate boolean ``value`` and return None.

    Raises:
        ValueError: The cross-cutting indicator is not boolean.
    """

    if not isinstance(value, bool):
        raise ValueError("cross_cutting must be a boolean.")


def _orchestrator_receipt(
    *,
    context: ExecutionContext,
    languages: list[str],
    production_file_count: int,
    test_file_count: int,
    cross_cutting: bool,
    reason: str,
    budget: LanguageBudget | None = None,
) -> CodexTopologyReceipt:
    """Build and return a large-route receipt from normalized routing inputs."""

    return {
        "execution_context": context,
        "languages": languages,
        "production_file_count": production_file_count,
        "test_file_count": test_file_count,
        "cross_cutting": cross_cutting,
        "root_persona": None,
        "route": "large",
        "topology": "orchestrator",
        "logical_agent": ORCHESTRATOR_LOGICAL_AGENT,
        "routing_reason": reason,
        "max_production_files": (
            budget["max_production_files"] if budget is not None else None
        ),
        "max_test_files": budget["max_test_files"] if budget is not None else None,
    }


def _parallel_root_context(root_persona: str) -> ExecutionContext | None:
    """Return the required parallel context for ``root_persona``, if any."""

    # Search the two forced identities rather than duplicating reverse constants.
    return next(
        (
            cast("ExecutionContext", candidate)
            for candidate, persona in PARALLEL_ROOT_CONTEXT_PERSONAS.items()
            if persona == root_persona
        ),
        None,
    )


def resolve_codex_topology(
    languages: Collection[str],
    production_file_count: int,
    test_file_count: int,
    execution_context: str,
    *,
    cross_cutting: bool = False,
    root_persona: str | None = None,
) -> CodexTopologyReceipt:
    """Resolve an implementation topology from language, count, and context.

    A standalone, single-language change inside a canonical direct-mode budget
    selects that language's typed engineer. All escalation conditions select
    the orchestrator. Epic child work always selects the orchestrator, while an
    explicit root epic persona selects itself. Parallel root contexts require
    their matching forced parallel persona and reject every other root.

    Args:
        languages: Declared implementation languages.
        production_file_count: Estimated production-file scope.
        test_file_count: Estimated test-file scope retained in the receipt.
        execution_context: Standalone, epic-child, or parallel-root context.
        cross_cutting: Whether the change crosses architectural surfaces.
        root_persona: Optional forced epic or parallel root persona.

    Returns:
        CodexTopologyReceipt: Deterministic route, topology, and logical agent.

    Raises:
        ValueError: Any input or forced-persona invariant is invalid.
    """

    context = _validate_context(execution_context)
    normalized_languages = _normalize_languages(languages)
    _validate_counts(production_file_count, test_file_count)
    _validate_cross_cutting(cross_cutting)

    # A parallel root context accepts only its exact forced root persona.
    parallel_persona = PARALLEL_ROOT_CONTEXT_PERSONAS.get(context)
    if parallel_persona is not None:
        if root_persona != parallel_persona:
            raise ValueError(
                f"Parallel context {context!r} requires its forced root persona "
                f"{parallel_persona!r}."
            )
        return {
            "execution_context": context,
            "languages": normalized_languages,
            "production_file_count": production_file_count,
            "test_file_count": test_file_count,
            "cross_cutting": cross_cutting,
            "root_persona": parallel_persona,
            "route": "parallel",
            "topology": "parallel_persona",
            "logical_agent": parallel_persona,
            "routing_reason": "forced_root_persona",
            "max_production_files": None,
            "max_test_files": None,
        }

    # Outside parallel contexts, validate explicit roots before normal routing.
    if root_persona is not None:
        if root_persona not in FORCED_ROOT_PERSONAS:
            raise ValueError(f"Unsupported Codex root persona: {root_persona!r}.")
        parallel_context = _parallel_root_context(root_persona)
        if parallel_context is not None:
            raise ValueError(
                f"Parallel persona {root_persona!r} requires "
                f"{parallel_context!r} context."
            )
        if context != "standalone":
            raise ValueError("A forced root persona requires standalone context.")
        persona = cast("RootPersona", root_persona)
        return {
            "execution_context": context,
            "languages": normalized_languages,
            "production_file_count": production_file_count,
            "test_file_count": test_file_count,
            "cross_cutting": cross_cutting,
            "root_persona": persona,
            "route": "epic",
            "topology": "epic_persona",
            "logical_agent": persona,
            "routing_reason": "forced_root_persona",
            "max_production_files": None,
            "max_test_files": None,
        }

    def escalate(
        reason: str, budget: LanguageBudget | None = None
    ) -> CodexTopologyReceipt:
        """Return a large-route receipt for ``reason`` and optional ``budget``."""

        return _orchestrator_receipt(
            context=context,
            languages=normalized_languages,
            production_file_count=production_file_count,
            test_file_count=test_file_count,
            cross_cutting=cross_cutting,
            reason=reason,
            budget=budget,
        )

    # Apply escalation precedence exactly as declared by ESCALATION_PRECEDENCE.
    if context in EPIC_CHILD_CONTEXTS:
        return escalate("epic_child_context")
    if production_file_count <= 0 or test_file_count < 0:
        return escalate("invalid_estimate")
    if len(normalized_languages) > 1:
        return escalate("cross_language")
    if len(normalized_languages) != 1:
        return escalate("unsupported_language")

    budget = LANGUAGE_BUDGETS.get(normalized_languages[0])
    if budget is None:
        return escalate("unsupported_language")
    if cross_cutting:
        return escalate("cross_cutting", budget)
    if not budget["direct_mode_enabled"]:
        return escalate("direct_mode_disabled", budget)
    if production_file_count > budget["max_production_files"]:
        return escalate("production_budget_exceeded", budget)
    return {
        "execution_context": context,
        "languages": normalized_languages,
        "production_file_count": production_file_count,
        "test_file_count": test_file_count,
        "cross_cutting": cross_cutting,
        "root_persona": None,
        "route": "small",
        "topology": "typed_engineer",
        "logical_agent": budget["logical_agent"],
        "routing_reason": "within_language_budget",
        "max_production_files": budget["max_production_files"],
        "max_test_files": budget["max_test_files"],
    }


def build_parser() -> argparse.ArgumentParser:
    """Build and return the side-effect-free topology CLI parser."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--language", action="append", default=[])
    parser.add_argument("--production-file-count", type=int, default=0)
    parser.add_argument("--test-file-count", type=int, default=0)
    parser.add_argument(
        "--execution-context",
        choices=tuple(sorted(VALID_EXECUTION_CONTEXTS)),
        required=True,
    )
    parser.add_argument("--cross-cutting", action="store_true")
    parser.add_argument("--root-persona", choices=tuple(sorted(FORCED_ROOT_PERSONAS)))
    return parser


def main(argv: list[str] | None = None) -> int:
    """Parse ``argv``, emit one stable JSON receipt, and return zero.

    Side Effects:
        Writes the resolved receipt to stdout.
    """

    args = build_parser().parse_args(argv)
    receipt = resolve_codex_topology(
        args.language,
        args.production_file_count,
        args.test_file_count,
        args.execution_context,
        cross_cutting=args.cross_cutting,
        root_persona=args.root_persona,
    )
    # Stable formatting makes the CLI receipt suitable for durable evidence.
    print(json.dumps(receipt, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
