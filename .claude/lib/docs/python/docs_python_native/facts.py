"""Raw facts and diagnostics that the native analyzers report to the protocol layer.

The helper never computes identifiers or digests: a Fact carries kind, declaration,
name, parent and line bounds only, and PowerShell builds every element from it.
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class RawDiagnostic:
    """A site or input diagnostic before it is reported under an analyzer identifier.

    Recognizers and the import-table builder record these; the protocol layer attaches
    the analyzer identifier and the non-blocking flag when it writes the response.

    Attributes:
        code: The 1022 diagnostic code, spelled exactly as the scanner spells it.
        line: The one-based canonical line the diagnostic points at.
    """

    code: str
    line: int


FactValue = str | bool | int


@dataclass(frozen=True)
class Fact:
    """One raw element fact; PowerShell computes its identifiers and digest.

    Built by AnalyzerOutput.add_fact and serialized by to_json into the protocol
    response. Properties are stored as a sorted tuple so equal facts compare and hash
    equal.

    Attributes:
        analyzer_id: The scanner analyzer identifier the fact belongs to.
        kind: The element kind (for example cli-command or http-route).
        declaration: The declaration string that forms the element identity.
        name: The element display name.
        parent: (kind, declaration, path) of the parent element, or None.
        line_start: First canonical line of the span, or None for a whole-file kind.
        line_end: Last canonical line of the span, or None for a whole-file kind.
        properties: Sorted (name, value) pairs of the element properties.
    """

    analyzer_id: str
    kind: str
    declaration: str
    name: str
    parent: tuple[str, str, str] | None
    line_start: int | None
    line_end: int | None
    properties: tuple[tuple[str, FactValue], ...]

    def to_json(self) -> dict[str, object]:
        """Return the protocol object of the fact.

        Returns:
            A dict with the eight protocol keys; parent becomes {kind, declaration,
            path} or None and properties becomes a dict.
        """
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
    """Facts and raw diagnostics of one analyzer, keyed by request path.

    Each analyzer creates one instance, appends to it while it walks the parsed files,
    and returns it to the protocol layer, which merges every output per path. Not
    thread-safe; one analyzer run owns it.

    Attributes:
        analyzer_id: The analyzer identifier stamped on every fact.
        facts: Request path to the facts recorded for that path, in record order.
        diagnostics: Request path to the raw diagnostics recorded for that path.
    """

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
        """Record one fact for a request path.

        Args:
            path: The request path the fact belongs to.
            kind: The element kind.
            declaration: The declaration string.
            name: The element display name.
            span: (first line, last line), or None to record null line bounds.
            properties: The element properties; stored sorted by name.
            parent: (kind, declaration, path) of the parent element, or None.

        Returns:
            None. Appends to facts[path].
        """
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
        """Record one raw diagnostic for a request path.

        Args:
            path: The request path the diagnostic belongs to.
            code: The 1022 diagnostic code.
            line: The one-based canonical line.

        Returns:
            None. Appends to diagnostics[path].
        """
        self.diagnostics.setdefault(path, []).append(RawDiagnostic(code, line))
