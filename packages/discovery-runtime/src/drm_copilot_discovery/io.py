"""I/O boundary helpers for the discovery report subpackage.

Purpose:
    Isolate every filesystem-touching operation used by the discovery report
    CLIs (`coverage_report.py`, `parity_report.py`, `completion_report.py`)
    behind thin, individually monkeypatchable wrapper functions, plus the
    shared `ArtifactValidator` seam used to validate artifact text before any
    parsing or rendering occurs.

Constraints:
    Per `.claude/rules/general-code-change.md` "I/O Boundaries", this module
    contains only I/O and validation-dispatch logic; it performs no parsing
    or rendering of report content itself.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from pathlib import Path


class ArtifactValidator(Protocol):
    """Callable contract for validating raw discovery-artifact text.

    Purpose:
        Describe the shape of a validator function the discovery report CLIs
        depend on, without importing any concrete upstream validator module
        at class-definition time. This lets report modules bind a real
        validator lazily (inside a function body) while unit tests inject a
        fake implementation that satisfies this same `Protocol`.

    Responsibilities:
        Define only the call signature; this `Protocol` performs no
        validation itself.

    Usage:
        A concrete validator (real or fake) is passed to
        `validate_or_raise` as the `validator` argument.
    """

    def __call__(self, text: str) -> list[str]:
        """Validate raw artifact text and report any errors found.

        Args:
            text (str): Raw artifact document text to validate.

        Returns:
            list[str]: Empty list when `text` is valid; otherwise one or
            more human-readable error strings.
        """
        ...


class ArtifactValidationError(Exception):
    """Raised when an artifact fails validation before rendering.

    Purpose:
        Carry the validator's reported errors out of `validate_or_raise` so
        a CLI `main()` function can print them and return a non-zero exit
        code without re-invoking the validator.

    Attributes:
        errors (list[str]): The non-empty list of validator-reported error
            strings that caused this exception to be raised.
    """

    def __init__(self, errors: list[str]) -> None:
        """Initialize the exception with the validator's error list.

        Args:
            errors (list[str]): Non-empty list of human-readable validation
                error strings.

        Side Effects:
            Builds a human-readable exception message by joining `errors`.
        """
        super().__init__("; ".join(errors))
        self.errors = errors


def read_artifact_text(path: Path) -> str:
    """Read a discovery artifact file as UTF-8 text.

    Purpose:
        Provide a single, easily monkeypatched seam for reading artifact
        files from disk, so pure parsing/rendering functions never touch
        `Path` I/O directly.

    Args:
        path (Path): Filesystem path to the artifact file.

    Returns:
        str: The file's raw text content.

    Raises:
        OSError: Propagated unchanged when the file cannot be read.

    Side Effects:
        Reads from the filesystem.
    """
    return path.read_text(encoding="utf-8")


def validate_or_raise(text: str, validator: ArtifactValidator) -> None:
    """Validate artifact text and raise if the validator reports errors.

    Purpose:
        Provide the single fail-fast checkpoint every report CLI calls
        before parsing or rendering an artifact, per the "validate before
        render" contract in `spec.md` "API / CLI Surface".

    Args:
        text (str): Raw artifact document text to validate.
        validator (ArtifactValidator): Callable that inspects `text` and
            returns a list of error strings (empty when valid).

    Returns:
        None.

    Raises:
        ArtifactValidationError: When `validator(text)` returns a non-empty
            list of errors.

    Side Effects:
        None beyond invoking `validator`, whose own side effects (if any)
        are outside this function's control.
    """
    errors = validator(text)
    if errors:
        raise ArtifactValidationError(errors)


def write_report(path: Path, content: str) -> None:
    """Write rendered report content to a file as UTF-8 text.

    Purpose:
        Provide a single, easily monkeypatched seam for writing rendered
        report output to disk, so pure rendering functions never touch
        `Path` I/O directly.

    Args:
        path (Path): Destination filesystem path for the rendered report.
        content (str): Rendered report text to write.

    Returns:
        None.

    Raises:
        OSError: Propagated unchanged when the file cannot be written.

    Side Effects:
        Writes to the filesystem.
    """
    path.write_text(content, encoding="utf-8")
