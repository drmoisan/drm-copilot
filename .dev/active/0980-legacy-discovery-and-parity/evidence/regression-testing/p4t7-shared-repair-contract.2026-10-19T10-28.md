# Repaired shared dependency contract

Timestamp: 2026-10-19T10-28
Command: poetry run python SCRATCH/issue-980-p4t7-shared-repair-freeze.py
EXIT_CODE: 0
Output Summary: 191 focused cases; both modules and all measured ranges have 100% line/branch coverage. This is a checked subset awaiting bounded confirmation and full task integration.

The original public constructor/function/method signatures are identical. `dependency_inputs` explicitly re-exports `DependencyValue`, `Ecosystem`, `safe_identifier` and `dependency_value` from `dependency_values`; both import routes share object identity. Carrier fields, defaults, fixed errors and immutable output responsibilities remain unchanged.

- `DependencyLimits(max_bytes: 'int' = 1048576, max_nodes: 'int' = 100000, max_depth: 'int' = 64, max_candidates: 'int' = 10000, max_text_bytes: 'int' = 1048576, max_lines: 'int' = 100000) -> None`
- `DependencyAnchor(format: "Literal['json', 'xml', 'text']", location: 'str', occurrence: 'int' = 1, line: 'int | None' = None) -> None`
- `DependencyValue(kind: 'str', value: 'str | None' = None) -> None`
- `DependencyCandidate(kind: 'DependencyKind', ecosystem: 'Ecosystem', name: 'str | None', version: 'DependencyValue', role: 'str', anchor: 'DependencyAnchor', requested: 'DependencyValue' = DependencyValue(kind='missing', value=None), owner: 'str | None' = None, operation: 'str' = 'reference', condition_present: 'bool' = False, extras: 'tuple[str, ...]' = (), markers: 'tuple[str, ...]' = ()) -> None`
- `DependencyResult(candidates: 'tuple[DependencyCandidate, ...]' = (), diagnostics: 'tuple[str, ...]' = (), consumed_nodes: 'int' = 0, consumed_text_bytes: 'int' = 0) -> None`
- `DependencyBudget(limits: 'DependencyLimits') -> 'None'`
- `DependencyInputError(code: 'str') -> 'None'`
- `safe_identifier(value: 'str | None', *, ecosystem: 'Ecosystem' = 'python') -> 'str | None'`
- `dependency_value(value: 'str | None') -> 'DependencyValue'`
- `DependencyBudget.decode(self, content: 'bytes') -> 'str'`
- `DependencyBudget.reserve(self, *, nodes: 'int' = 0, candidates: 'int' = 0, text_bytes: 'int' = 0) -> 'None'`
- `DependencyBudget.note(self, code: 'str') -> 'None'`
- `DependencyBudget.add(self, *, kind: 'DependencyKind', ecosystem: 'Ecosystem', name: 'str | None', version: 'str | None', role: 'str', anchor: 'DependencyAnchor', requested: 'str | None' = None, owner: 'str | None' = None, operation: 'str' = 'reference', condition_present: 'bool' = False, extras: 'tuple[str, ...]' = (), markers: 'tuple[str, ...]' = ()) -> 'None'`
- `DependencyBudget.result(self) -> 'DependencyResult'`

SR1 replaces the overlapping version regexes with forward-only cursor scans. The 256-character cap precedes scanning; range separators partition bounded input, and operator prefixes do not overlap version components. Counted public-call regressions cover the original 59-character reproducer and maximum accepted/rejected inputs without timing assertions. SR3 classifies `*`, `x` and `X` wildcard components as constraints, retaining actual exact/prerelease syntax as literal. Neither category proves installed or evaluated resolution.

SR2 counts UTF-8 scalar widths before allocating an encoding. Independent remaining aggregate text capacity is checked during the scan; surrogates fail with the fixed encoding code. Counted public-collector regressions prohibit encode calls for ASCII, BMP and astral exact-capacity controls, early oversize rejection and surrogate failures. Raw selected UTF-8 work plus quoted retained ASCII values remain the conservative parser text budget; complete Analysis serialization is separately charged by integration. SR4 documents typed parameters, returns, exceptions, lifecycle and side effects in every shared carrier/helper and scoped test definition.

Accepted JSON parser mapping: `ParseLimits.artifact_records = min(max_nodes // 64, 1000000)`, with `max_nodes < 64` rejected before parsing. This bounds the existing parser's expanded-node allocation; its finite preflight token envelope remains the accepted lower-layer contract. Parsers independently charge extraction/index work, cap the accepted byte/depth hard ceilings and never edit parser infrastructure. XML has explicit element/depth limits. This clarifies the original 09:56 contract without rewriting it.

The original 152 cases and all original assertions, decorators and helper bodies are preserved after removing docstrings for comparison; eight tests moved to the approved boundary module. Thirty-nine new cases cover the four findings. Original failed review probes, operational timeout, and all original focused evidence remain immutable. The integration trio is byte-identical to its paused copies. No format-parser file, predecessor, policy, registry, checkpoint, plan, AC or Git state was mutated by this repair. One full task review/final sequence and integration remain pending.
