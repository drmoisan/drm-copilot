from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, Protocol

from scripts.dev_tools.atomic_executor.plan_parser import PlanParser

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable


class _PlanTaskLike(Protocol):
    """Protocol for the subset of PlanTask used by this script."""

    task_id: str
    title: str
    expect_fail: bool
    test_ref: str | None


class _PlanModelLike(Protocol):
    """Protocol for the subset of PlanModel used by this script."""

    @property
    def tasks(self) -> Iterable[_PlanTaskLike]:
        """Iterable of tasks in the plan model."""


class _PlanParserLike(Protocol):
    """Protocol for the plan parser used by this script."""

    def parse(self) -> _PlanModelLike:
        """Parse a plan file into a model."""


@dataclass(frozen=True)
class ParsedTaskSummary:
    """
    Renderable summary extracted from a parsed plan task.

    Purpose:
        Provide a stable, testable representation of the fields printed by the
        legacy script.

    Attributes:
        task_id (str): Task identifier (e.g., "P1-T1").
        title (str): Task title text.
        expect_fail (bool): Whether the task is tagged expect-fail.
        test_ref (str | None): Optional test reference for expectation routing.
    """

    task_id: str
    title: str
    expect_fail: bool
    test_ref: str | None

    def render_lines(self) -> list[str]:
        """
        Render the summary to the same line format printed by the legacy script.

        Returns:
            list[str]: Printable lines (without trailing newlines).
        """

        return [
            f"Task: {self.task_id}",
            f"Title: {self.title}",
            f"Expect Fail: {self.expect_fail}",
            f"Test Ref: {self.test_ref}",
        ]


DEFAULT_PLAN_PATH = Path(
    "docs/features/active/2026-02-01-extension-code-barrier-2/"
    "plan.2026-02-01T11-35.md"
)
DEFAULT_TASK_ID = "P1-T1"


def find_task_summary(
    model: _PlanModelLike,
    *,
    task_id: str,
) -> ParsedTaskSummary | None:
    """
    Find a task in a parsed plan model and return its printable summary.

    Purpose:
        Encapsulate the loop/filtering logic so it can be unit tested without
        filesystem access.

    Args:
        model (_PlanModelLike): Parsed plan model.
        task_id (str): Task identifier to search for.

    Returns:
        ParsedTaskSummary | None: Summary when found, otherwise None.
    """
    # Scan tasks and stop at the first match (stable and predictable output).
    for task in model.tasks:
        if task.task_id == task_id:
            return ParsedTaskSummary(
                task_id=task.task_id,
                title=task.title,
                expect_fail=task.expect_fail,
                test_ref=task.test_ref,
            )
    return None


def build_task_summary_output(
    model: _PlanModelLike,
    *,
    task_id: str,
) -> str | None:
    """
    Build the legacy script output for a given task ID.

    Purpose:
        Provide a pure function that matches the script's printed output.

    Args:
        model (_PlanModelLike): Parsed plan model.
        task_id (str): Task identifier to search for.

    Returns:
        str | None: Output text (with newlines) when found, otherwise None.
    """
    summary = find_task_summary(model, task_id=task_id)
    if summary is None:
        return None
    return "\n".join(summary.render_lines()) + "\n"


def run(
    *,
    plan_path: Path = DEFAULT_PLAN_PATH,
    task_id: str = DEFAULT_TASK_ID,
    parser_factory: Callable[[Path], _PlanParserLike] = PlanParser,
) -> str | None:
    """
    Parse a plan and return the legacy output for a specific task.

    Purpose:
        Preserve the original script intent while making it import-safe and
        unit-testable.

    Args:
        plan_path (Path): Path to the plan markdown file.
        task_id (str): Task identifier to print.
        parser_factory (Callable[[Path], _PlanParserLike]): Factory for creating
            a plan parser instance. Defaults to the real PlanParser.

    Returns:
        str | None: Output text when the task is found, otherwise None.

    Raises:
        FileNotFoundError: If the plan parser cannot read the plan file.
    """
    parser = parser_factory(plan_path)
    model = parser.parse()
    return build_task_summary_output(model, task_id=task_id)


def main() -> int:
    """
    Script entry point.

    Purpose:
        Keep behavior similar to the original file: parse a hardcoded plan and
        print a summary for a single task ID.

    Returns:
        int: Process exit code (0 when task found, 1 otherwise).
    """
    output = run()
    if output is None:
        print(f"Task not found: {DEFAULT_TASK_ID}")
        return 1
    print(output, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
