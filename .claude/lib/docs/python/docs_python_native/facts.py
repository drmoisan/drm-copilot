"""Raw facts and diagnostics that the native analyzers report to the protocol layer.

The helper never computes identifiers or digests: a Fact carries kind, declaration,
name, parent and line bounds only, and PowerShell builds every element from it.
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class RawDiagnostic:
    """A site or input diagnostic before it is reported under an analyzer identifier."""

    code: str
    line: int


FactValue = str | bool | int


@dataclass(frozen=True)
class Fact:
    """One raw element fact; PowerShell computes its identifiers and digest."""

    analyzer_id: str
    kind: str
    declaration: str
    name: str
    parent: tuple[str, str, str] | None
    line_start: int | None
    line_end: int | None
    properties: tuple[tuple[str, FactValue], ...]

    def to_json(self) -> dict[str, object]:
        """Return the protocol object of the fact."""
        parent: dict[str, str] | None = None
        if self.parent is not None:
            parent = {
                "kind": self.parent[0],
                "declaration": self.parent[1],
                "path": self.parent[2],
            }
        return {
            "analyzer_id": self.analyzer_id,
            "kind": self.kind,
            "declaration": self.declaration,
            "name": self.name,
            "parent": parent,
            "line_start": self.line_start,
            "line_end": self.line_end,
            "properties": dict(self.properties),
        }


@dataclass
class AnalyzerOutput:
    """Facts and raw diagnostics of one analyzer, keyed by request path."""

    analyzer_id: str
    facts: dict[str, list[Fact]] = field(default_factory=lambda: {})
    diagnostics: dict[str, list[RawDiagnostic]] = field(default_factory=lambda: {})

    def add_fact(
        self,
        path: str,
        kind: str,
        declaration: str,
        name: str,
        span: tuple[int, int] | None,
        properties: dict[str, FactValue],
        parent: tuple[str, str, str] | None = None,
    ) -> None:
        """Record one fact for a path; a None span records null line bounds."""
        start, end = (None, None) if span is None else span
        fact = Fact(
            self.analyzer_id,
            kind,
            declaration,
            name,
            parent,
            start,
            end,
            tuple(sorted(properties.items())),
        )
        self.facts.setdefault(path, []).append(fact)

    def add_diagnostic(self, path: str, code: str, line: int) -> None:
        """Record one raw diagnostic for a path."""
        self.diagnostics.setdefault(path, []).append(RawDiagnostic(code, line))
