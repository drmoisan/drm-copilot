"""Discriminate falsifiable from non-discriminating atomic-plan acceptance gates.

Purpose:
    Evaluate the fixed G1 through G6 rule set against the commands an atomic
    plan states as acceptance conditions, and report each finding on the
    Blocking or Warning channel the specification assigns to its rule. The
    module re-exports `PlanCommand` and `extract_plan_commands` so the
    specification's public surface is a single module. It imports the extractor
    and never imports `scripts.dev_tools.validate_orchestration_artifacts`,
    which imports this module.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Protocol

from scripts.dev_tools.epic_planner_readiness import (
    LocalReadinessFileSystem,
    ReadinessFileSystem,
)
from scripts.dev_tools.plan_gate_commands import (
    COV_FLAG,
    COV_FLAG_PREFIX,
    KIND_GREP,
    PlanCommand,
    extract_plan_commands,
    grep_executable_index,
)
from scripts.dev_tools.pr_context.git import SubprocessRunner

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.pr_context.git import CommandRunner

PLACEHOLDER_MARKERS = ("<", ">", "${", "$(", "%")
REGEX_METACHARACTERS = frozenset(".*[]^$\\(){}|+?")
FIXED_STRING_FLAG = "-F"
PATH_SEPARATORS = ("/", "\\")
PYTHON_SUFFIX = ".py"
PYTEST_NODE_SEPARATOR = "::"
BLOCKING_CHANNEL = "blocking"
WARNING_CHANNEL = "warning"
_WINDOW_SIZE = 4

# G5's severity channel, fixed by the pre-declared corpus measurement recorded
# in docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-
# atomic-plans-486/evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md
# and by nothing else. That run scanned 166 plan files, evaluated 100 candidate
# literals, and produced a total G5 finding count of 0, so the zero
# false-positive count measures nothing and does not license Blocking.
G5_SEVERITY: str = WARNING_CHANNEL


@dataclass(frozen=True)
class PlanGateReport:
    """Findings produced by one evaluation of the plan acceptance-gate rules.

    Purpose:
        Carry the two severity channels separately so a Warning can never be
        mistaken for a rejection by a caller that treats a non-empty error
        list as the failure signal.

    Attributes:
        blocking (list[str]): Findings that must fail the gate.
        warnings (list[str]): Findings surfaced without failing the gate.
    """

    blocking: list[str] = field(default_factory=list[str])
    warnings: list[str] = field(default_factory=list[str])


class PlanGateGitRepository(Protocol):
    """Focused Git query surface the context-requiring rules depend on."""

    def files_containing(self, literal: str) -> list[str]: ...

    def is_tracked_file(self, path: str) -> bool: ...

    def is_tracked_directory(self, path: str) -> bool: ...

    def read_tracked_text(self, path: str) -> str: ...


class GitPlanGateRepository:
    """Git-backed plan-gate repository adapter over an injectable runner.

    Purpose and responsibilities:
        Answer the tracked-tree questions the rules ask by shelling out to the
        same `git` binary the command under validation would use, so the gate
        never reimplements matching or tracked-path resolution. It issues
        `git grep -F -l`, `git ls-files`, and `git show HEAD:` and translates
        their output; findings and severities are not its concern.

    Usage, invariants, and side effects:
        Construct with the workspace root and an optional command runner, then
        pass the instance as the `git` member of a `PlanGateContext`. Every
        invocation passes `allow_error=True`, so a non-zero `git` exit becomes
        a negative answer rather than a raised error, and each query spawns one
        `git` subprocess through the injected runner.
    """

    def __init__(
        self, workspace_root: Path, runner: CommandRunner | None = None
    ) -> None:
        self._root = workspace_root
        self._runner = runner or SubprocessRunner()

    def _run(self, arguments: list[str]) -> tuple[int, str]:
        """Run one `git` invocation and return its exit code and stripped stdout."""

        result = self._runner.run(["git", *arguments], cwd=self._root, allow_error=True)
        return result.code, result.stdout.strip()

    def files_containing(self, literal: str) -> list[str]:
        """Return tracked paths carrying the literal on a single line."""

        code, output = self._run(["grep", "-F", "-l", "--", literal])
        if code != 0 or not output:
            return []
        return [line.strip() for line in output.splitlines() if line.strip()]

    def is_tracked_file(self, path: str) -> bool:
        """Return whether `git ls-files` lists the path itself."""

        normalized = path.replace("\\", "/")
        code, output = self._run(["ls-files", "--", normalized])
        if code != 0 or not output:
            return False
        return any(line.strip() == normalized for line in output.splitlines())

    def is_tracked_directory(self, path: str) -> bool:
        """Return whether entries exist beneath the path but none equals it."""

        normalized = path.replace("\\", "/").rstrip("/")
        code, output = self._run(["ls-files", "--", normalized])
        if code != 0 or not output:
            return False
        listed = [line.strip() for line in output.splitlines() if line.strip()]
        return bool(listed) and all(entry != normalized for entry in listed)

    def read_tracked_text(self, path: str) -> str:
        """Return the committed text of the path at `HEAD`, or an empty string."""

        normalized = path.replace("\\", "/")
        code, output = self._run(["show", f"HEAD:{normalized}"])
        return output if code == 0 else ""


@dataclass(frozen=True)
class PlanGateContext:
    """Injected repository context for the context-requiring plan-gate rules.

    Purpose:
        Mirror the shape of `EpicReadinessContext` so the plan route acquires a
        repository seam the same way the epic planner route already does.

    Attributes:
        workspace_root (Path): Absolute root the `git` adapter runs against.
        file_system (ReadinessFileSystem): Read-only filesystem seam.
        git (PlanGateGitRepository): Tracked-tree query seam.
    """

    workspace_root: Path
    file_system: ReadinessFileSystem
    git: PlanGateGitRepository


def build_plan_gate_context(
    workspace_root: Path,
    *,
    runner: CommandRunner | None = None,
    file_system: ReadinessFileSystem | None = None,
) -> PlanGateContext:
    """Build the production plan-gate context with injectable I/O seams.

    Args:
        workspace_root (Path): Workspace root, resolved to an absolute path.
        runner (CommandRunner | None): Optional command runner for `git`.
        file_system (ReadinessFileSystem | None): Optional filesystem seam.

    Returns:
        PlanGateContext: Context whose `git` member is a `GitPlanGateRepository`.

    Raises:
        None. No I/O occurs here; the returned adapters act only when called.
    """

    root = workspace_root.absolute()
    return PlanGateContext(
        workspace_root=root,
        file_system=file_system or LocalReadinessFileSystem(),
        git=GitPlanGateRepository(root, runner),
    )


def _is_placeholder(value: str) -> bool:
    """Return whether the value carries a placeholder or interpolation marker.

    A value the plan spelled with a placeholder was never intended to run
    verbatim, so its resolvability is not decidable and no rule may report it.
    """

    return any(marker in value for marker in PLACEHOLDER_MARKERS)


def _dotted_remedy(value: str) -> str:
    """Return the importable dotted form of a filesystem-path coverage value."""

    stem = value[: -len(PYTHON_SUFFIX)] if value.endswith(PYTHON_SUFFIX) else value
    return stem.replace("/", ".").replace("\\", ".")


def _cov_values(command: PlanCommand) -> list[tuple[str, bool]]:
    """Return each `--cov` value paired with whether it was space-separated.

    A word is a `--cov` argument if and only if it equals `--cov` exactly or
    begins with the six characters `--cov=`, so prefix matching never treats
    `--cov-branch` or `--cov-report=term-missing` as a `--cov` argument.
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


def _evaluate_cov_value(
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
    """

    task = command.task_id

    # G4 is independent of resolvability: the ambiguous form is always reported.
    if space_separated:
        report.warnings.append(
            f"[{task}] --cov argument value `{value}` is supplied "
            "space-separated; the ambiguous form can bind the following "
            "positional argument. Use the --cov=<module> form."
        )

    if _is_placeholder(value):
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


def _pattern_operand(argv: tuple[str, ...]) -> str | None:
    """Return the first non-flag operand after the grep-family executable."""

    executable = grep_executable_index(argv)
    if executable is None:
        return None
    # Flags and the `--` separator precede the pattern; the first plain word
    # after the executable is the operand.
    for word in argv[executable + 1 :]:
        if word.startswith("-"):
            continue
        return word
    return None


def _is_checkable_literal(argv: tuple[str, ...], pattern: str) -> bool:
    """Return whether the pattern can be checked as a fixed literal.

    The condition is conservative in POSIX BRE, POSIX ERE, PCRE, and the Rust
    regex dialect simultaneously, so no dialect-selection logic is required. A
    placeholder operand is excluded because a command that was never intended
    to run verbatim states no real acceptance assertion.
    """

    if _is_placeholder(pattern):
        return False
    if FIXED_STRING_FLAG in argv:
        return True
    return not any(character in REGEX_METACHARACTERS for character in pattern)


def _plan_quotes_literal(text: str, literal: str, *, exclude_span: str) -> bool:
    """Return whether the plan quotes the literal outside its own command span.

    The literal is read out of a command that is itself part of the plan text,
    so the originating span must be removed or the answer would be `True`
    unconditionally. Only the originating span is excluded: erasing every
    extracted span would delete the plan's normal way of instructing the
    executor to create a literal.
    """

    remainder = text.replace(exclude_span, " ")
    needle = " ".join(literal.split())
    if not needle:
        return False
    return needle in " ".join(remainder.split())


def _window_join(lines: list[str], size: int = _WINDOW_SIZE) -> list[str]:
    """Return the whitespace-normalised join of each sliding window of lines."""

    dense = [" ".join(line.split()) for line in lines if line.strip()]
    # One window per start position keeps the boundary exact: lines further
    # apart than `size` never appear in the same join.
    return [" ".join(dense[index : index + size]) for index in range(len(dense))]


def _has_cross_line_presence(context: PlanGateContext, literal: str) -> bool:
    """Return whether a tracked file carries the literal only across lines.

    Candidate files are located by searching for the literal's first word,
    which stays contiguous on one line however the literal wraps.
    """

    words = literal.split()
    if len(words) < 2:
        return False
    needle = " ".join(words)

    # A candidate carries the first word on one line: necessary for a wrap.
    for path in context.git.files_containing(words[0]):
        lines = context.git.read_tracked_text(path).splitlines()
        if any(needle in " ".join(line.split()) for line in lines):
            continue
        if any(needle in window for window in _window_join(lines)):
            return True
    return False


def _evaluate_literal(
    report: PlanGateReport,
    text: str,
    command: PlanCommand,
    context: PlanGateContext,
) -> None:
    """Apply the G5 and G6 cascade to one grep-family command, in place."""

    pattern = _pattern_operand(command.argv)
    if pattern is None or not _is_checkable_literal(command.argv, pattern):
        return

    # Presence anywhere in the tree exonerates it; the pathspec is ignored.
    if context.git.files_containing(pattern):
        return

    # A literal the plan quotes elsewhere is one the executor must create.
    if _plan_quotes_literal(text, pattern, exclude_span=command.raw_span):
        return

    # G6 precedes G5: cross-line presence falsifies G5's tree-absence claim.
    if _has_cross_line_presence(context, pattern):
        report.warnings.append(
            f"[{command.task_id}] search literal `{pattern}` is present only "
            "across adjacent lines of a tracked file and matches no single "
            "line; a line-oriented search returns zero matches. Search a "
            "shorter single-line token."
        )
        return

    finding = (
        f"[{command.task_id}] search literal `{pattern}` is absent from the "
        "tracked tree and is not quoted in the plan; the search returns zero "
        "matches whatever the executor does. Quote the exact literal the task "
        "will create, or assert a literal that exists."
    )
    channel = report.blocking if G5_SEVERITY == BLOCKING_CHANNEL else report.warnings
    channel.append(finding)


def _evaluate_literal_rules(
    report: PlanGateReport,
    text: str,
    commands: list[PlanCommand],
    context: PlanGateContext,
) -> None:
    """Apply G5 and G6 to every grep-family command, degrading on seam failure.

    A failing or unavailable repository seam discards the whole literal group
    rather than reporting it partially, and never propagates an exception.
    """

    literal_findings = PlanGateReport()
    try:
        # Only grep-family commands carry a search literal to judge.
        for command in commands:
            if command.kind != KIND_GREP:
                continue
            _evaluate_literal(literal_findings, text, command, context)
    except Exception:
        # Broad by contract: a validation run must never fail because the
        # repository could not be queried (spec AC10, graceful degradation).
        return

    report.blocking.extend(literal_findings.blocking)
    report.warnings.extend(literal_findings.warnings)


def evaluate_plan_gates(
    text: str, *, context: PlanGateContext | None = None
) -> PlanGateReport:
    """Evaluate the plan acceptance-gate rule set against plan text.

    Args:
        text (str): Full plan document text.
        context (PlanGateContext | None): Repository seam. When `None` only the
            context-free rules G1 and G4 run, so the returned Blocking list is
            byte-identical to the pre-change output for the same text.

    Returns:
        PlanGateReport: Blocking and Warning findings in source order.

    Raises:
        None. A failing repository seam degrades to zero findings rather than
        propagating. The only side effect is querying the injected `git` seam.
    """

    report = PlanGateReport()
    commands = extract_plan_commands(text)

    # Coverage-argument rules run for every command, because a wrapper such as
    # `poetry run` can place a `--cov` argument in any command shape.
    for command in commands:
        for value, space_separated in _cov_values(command):
            _evaluate_cov_value(
                report,
                command,
                value,
                space_separated=space_separated,
                context=context,
            )

    if context is not None:
        _evaluate_literal_rules(report, text, commands, context)

    return report
