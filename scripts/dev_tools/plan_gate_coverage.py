"""Evaluate the G1 through G4 coverage-argument cascade of the plan gate.

Purpose:
    Hold the rule group that judges the `--cov` arguments an atomic plan states
    as acceptance conditions, so that `plan_gate_discrimination` carries only
    the shared report and context types, the G5/G6 literal rules, and the public
    entry point. The split is behaviour-preserving: every finding string,
    severity channel, cascade order, and graceful-degradation guard is
    unchanged from the single-module form.

Responsibilities and scope boundaries:
    This module decides coverage values only. It never constructs a
    `PlanGateReport` or a `PlanGateContext`; both arrive as parameters, so the
    dependency on `plan_gate_discrimination` is annotation-level and lives under
    `TYPE_CHECKING`. The runtime import graph therefore holds exactly one edge,
    `plan_gate_discrimination` importing this module, and stays acyclic.

Key invariants:
    G1 through G4 form a cascade over each `--cov` value: the value is decided
    once, so a value G1 rejects is never additionally reported by G2 or G3. G4
    is evaluated independently of the cascade because the ambiguous
    space-separated form is a defect whatever the value resolves to. G1 and G4
    are context-free; G2 and G3 require the tracked-tree seam and do not run
    without a context.

Side effects:
    The tracked-tree rules query the injected `git` seam of the supplied
    context. Nothing else performs I/O, and no function mutates its inputs
    beyond appending findings to the report it is given.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools.plan_gate_commands import COV_FLAG, COV_FLAG_PREFIX

if TYPE_CHECKING:
    from scripts.dev_tools.plan_gate_commands import PlanCommand
    from scripts.dev_tools.plan_gate_discrimination import (
        PlanGateContext,
        PlanGateReport,
    )

PLACEHOLDER_MARKERS = ("<", ">", "${", "$(", "%")
PATH_SEPARATORS = ("/", "\\")
PYTHON_SUFFIX = ".py"
PYTEST_NODE_SEPARATOR = "::"


def is_placeholder(value: str) -> bool:
    """Return whether the value carries a placeholder or interpolation marker.

    A value the plan spelled with a placeholder was never intended to run
    verbatim, so its resolvability is not decidable and no rule may report it.

    Args:
        value (str): Coverage value or search literal read from a plan command.

    Returns:
        bool: `True` when any marker in `PLACEHOLDER_MARKERS` appears in the
            value, otherwise `False`.

    Raises:
        None.
    """

    return any(marker in value for marker in PLACEHOLDER_MARKERS)


def _dotted_remedy(value: str) -> str:
    """Return the importable dotted form of a filesystem-path coverage value.

    Args:
        value (str): Coverage value, already truncated at the pytest node
            separator by the caller when one was present.

    Returns:
        str: The value with any trailing `.py` suffix removed and both path
            separators replaced by `.`, suitable for the `--cov=` remedy text.

    Raises:
        None.
    """

    stem = value[: -len(PYTHON_SUFFIX)] if value.endswith(PYTHON_SUFFIX) else value
    return stem.replace("/", ".").replace("\\", ".")


def cov_values(command: PlanCommand) -> list[tuple[str, bool]]:
    """Return each `--cov` value paired with whether it was space-separated.

    A word is a `--cov` argument if and only if it equals `--cov` exactly or
    begins with the six characters `--cov=`, so prefix matching never treats
    `--cov-branch` or `--cov-report=term-missing` as a `--cov` argument.

    Args:
        command (PlanCommand): One extracted plan command whose `argv` is
            scanned positionally.

    Returns:
        list[tuple[str, bool]]: One `(value, space_separated)` pair per `--cov`
            argument, in argv order.

    Raises:
        None.
    """

    values: list[tuple[str, bool]] = []
    argv = command.argv
    # Walk positionally: the space-separated form takes its value from the
    # following word, which a per-word filter cannot see.
    for index, word in enumerate(argv):
        if word == COV_FLAG:
            if index + 1 < len(argv):
                values.append((argv[index + 1], True))
            continue
        if word.startswith(COV_FLAG_PREFIX):
            values.append((word[len(COV_FLAG_PREFIX) :], False))
    return values


def evaluate_cov_value(
    report: PlanGateReport,
    command: PlanCommand,
    value: str,
    *,
    space_separated: bool,
    context: PlanGateContext | None,
) -> None:
    """Apply the G1 through G4 cascade to one `--cov` value, in place.

    The cascade decides each value once, so a value G1 rejects is never
    additionally reported by G2 or G3.

    Args:
        report (PlanGateReport): Report mutated in place; findings are appended
            to its Blocking or Warning channel.
        command (PlanCommand): Command the value was read from, supplying the
            `P#-T#` task identifier every finding string is prefixed with.
        value (str): The `--cov` value exactly as the plan spelled it.
        space_separated (bool): Whether the value followed a bare `--cov` word
            rather than the `--cov=` form; drives the G4 warning.
        context (PlanGateContext | None): Tracked-tree seam. When `None`, only
            the context-free rules G1 and G4 run.

    Returns:
        None. The function reports by mutating `report`.

    Raises:
        None. A repository seam that raises is absorbed by the graceful
        degradation guard below.
    """

    task = command.task_id

    # G4 is independent of resolvability: the ambiguous form is always reported.
    if space_separated:
        report.warnings.append(
            f"[{task}] --cov argument value `{value}` is supplied "
            "space-separated; the ambiguous form can bind the following "
            "positional argument. Use the --cov=<module> form."
        )

    if is_placeholder(value):
        return

    truncated = value.split(PYTEST_NODE_SEPARATOR, 1)[0]

    # G1 is context-free: a `.py` suffix proves a filesystem path, so no lookup.
    if truncated.endswith(PYTHON_SUFFIX):
        report.blocking.append(
            f"[{task}] --cov argument `{value}` names a filesystem path; "
            "coverage.py accepts only directories or importable names. "
            f"Use --cov={_dotted_remedy(truncated)}."
        )
        return

    # No path separator means a dotted name, `.`, or empty: all accepted forms.
    if not any(separator in value for separator in PATH_SEPARATORS):
        return

    # G2 and G3 need the tracked tree, so without a context they do not run.
    if context is None:
        return

    try:
        _evaluate_tracked_cov_value(report, task, value, truncated, context)
    except Exception:
        # Broad by contract: a validation run must never fail because the
        # repository could not be queried (spec AC10, graceful degradation).
        return


def _evaluate_tracked_cov_value(
    report: PlanGateReport,
    task: str,
    value: str,
    truncated: str,
    context: PlanGateContext,
) -> None:
    """Apply the tracked-tree rules G2 and G3 to one `--cov` value, in place.

    Args:
        report (PlanGateReport): Report mutated in place.
        task (str): The `P#-T#` identifier the finding string is prefixed with.
        value (str): The `--cov` value exactly as the plan spelled it; rendered
            in the finding text.
        truncated (str): The value truncated at the first pytest node
            separator, computed once by `evaluate_cov_value` and passed in
            rather than recomputed, matching the TypeScript twin's signature.
        context (PlanGateContext): Tracked-tree seam, queried for the module
            file and the directory forms of `truncated`.

    Returns:
        None. The function reports by mutating `report`.

    Raises:
        None of its own. Any error raised by the `git` seam propagates to the
        caller's graceful degradation guard.
    """

    # G2: value plus `.py` is a tracked module, so the remedy is known exactly.
    if context.git.is_tracked_file(truncated + PYTHON_SUFFIX):
        report.blocking.append(
            f"[{task}] --cov argument `{value}` names a tracked module file "
            "path; coverage.py accepts only directories or importable names. "
            f"Use --cov={_dotted_remedy(truncated)}."
        )
        return

    # A tracked directory is an accepted coverage target.
    if context.git.is_tracked_directory(truncated):
        return

    # G3: nothing tracked resolves, so warn rather than reject: data collection
    # is unknown rather than provably absent.
    report.warnings.append(
        f"[{task}] --cov argument `{value}` contains a path separator but "
        "resolves to neither a tracked file nor a tracked directory; coverage "
        "may collect no data. Use the importable dotted form or a tracked "
        "directory."
    )
