"""Analyzer pipeline abstraction, filesystem seam, and the thin runner.

Purpose:
    Define the host-neutral framework contract that concrete analyzers plug into:
    the ``Analyzer`` protocol (four ordered stages), the ``AnalyzerFileSystem``
    seam that isolates disk access, a real seam implementation, and the
    ``run_analyzer`` runner that drives the stages deterministically.

Invariants / Constraints:
    - ``Analyzer`` is a ``typing.Protocol`` (multiple implementations expected):
      this feature's inventory analyzer plus future stack-specific analyzers.
    - Protocol stage bodies are ``...`` (type-only; excluded from coverage).
    - ``run_analyzer`` invokes ``parse -> classify -> map -> emit`` in that fixed
      order and threads each stage's output into the next.
    - Enumeration/classification logic depends on the seam or plain data so it is
      testable without temporary files.

Side Effects:
    ``RealAnalyzerFileSystem`` reads and writes the real filesystem. The protocol
    and the runner have no side effects of their own.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol, runtime_checkable

from scripts.dev_tools.discovery.analyzer.models import AnalyzerRunResult

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.discovery.analyzer.models import (
        AnalyzerContext,
        ClassifyResult,
        EvidenceRecord,
        ParseResult,
    )


@runtime_checkable
class AnalyzerFileSystem(Protocol):
    """Disk-operation seam required by analyzers.

    A minimal surface: existence and type checks, a recursive file walk, a byte
    read (for integrity hashing), and a text write that creates parent
    directories. Implementations may be backed by the real filesystem or by an
    in-memory store in tests.
    """

    def exists(self, path: Path) -> bool:
        """Return whether ``path`` exists."""
        ...

    def is_dir(self, path: Path) -> bool:
        """Return whether ``path`` is a directory."""
        ...

    def walk_files(self, root: Path) -> tuple[Path, ...]:
        """Return every file path beneath ``root`` (directories excluded)."""
        ...

    def read_bytes(self, path: Path) -> bytes:
        """Return the byte content of the file at ``path``."""
        ...

    def write_text(self, path: Path, content: str) -> None:
        """Write ``content`` to ``path`` as UTF-8, creating parent directories."""
        ...


class Analyzer(Protocol):
    """Four-stage analyzer contract that concrete analyzers implement.

    A concrete analyzer plugs into ``run_analyzer`` by implementing ``name`` and
    the four stage methods. The stage bodies here are type-only.
    """

    name: str

    def parse(self, ctx: AnalyzerContext) -> ParseResult:
        """Read inputs described by ``ctx`` and return the parse result."""
        ...

    def classify(self, parsed: ParseResult) -> ClassifyResult:
        """Filter and tag the parsed units."""
        ...

    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
        """Build one evidence record per classified unit."""
        ...

    def emit(
        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
    ) -> tuple[Path, ...]:
        """Write one artifact per record via the seam and return their paths."""
        ...


class RealAnalyzerFileSystem:
    """Filesystem seam backed by ``pathlib.Path`` operations."""

    def exists(self, path: Path) -> bool:
        """Return whether ``path`` exists on disk."""
        return path.exists()

    def is_dir(self, path: Path) -> bool:
        """Return whether ``path`` is a directory on disk."""
        return path.is_dir()

    def walk_files(self, root: Path) -> tuple[Path, ...]:
        """Return every file beneath ``root`` via an iterative directory walk."""
        collected: list[Path] = []
        stack: list[Path] = [root]
        while stack:
            current = stack.pop()
            for child in current.iterdir():
                if child.is_dir():
                    stack.append(child)
                else:
                    collected.append(child)
        return tuple(collected)

    def read_bytes(self, path: Path) -> bytes:
        """Return the byte content of the file at ``path``."""
        return path.read_bytes()

    def write_text(self, path: Path, content: str) -> None:
        """Write ``content`` as UTF-8 to ``path``, creating parent directories."""
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")


def run_analyzer(
    analyzer: Analyzer, ctx: AnalyzerContext, fs: AnalyzerFileSystem
) -> AnalyzerRunResult:
    """Drive an analyzer through its four stages in fixed order.

    Args:
        analyzer: The concrete analyzer to run.
        ctx: The resolved run context.
        fs: The filesystem seam handed to the ``emit`` stage.

    Returns:
        An ``AnalyzerRunResult`` carrying the emitted records and written paths.
    """
    parsed = analyzer.parse(ctx)
    classified = analyzer.classify(parsed)
    records = analyzer.map(classified)
    written = analyzer.emit(records, fs)
    return AnalyzerRunResult(records=records, written_paths=written)
