# P4-T7 frozen parser contract

Timestamp: 2026-10-19T09-56
Command: poetry run python SCRATCH/issue-980-p4t7-lead-freeze.py
EXIT_CODE: 0
Output Summary: verified shared seam only; 152 in-memory cases, 221/221 statements and 108/108 branches.

Parsers accept captured immutable bytes plus `DependencyLimits`, then return `DependencyResult` or raise `DependencyInputError`. They do not create Analysis rows, IDs, provenance, confidence, evaluated resolution or execution claims.

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

The three candidate kinds are `declaration`, `locked-package` and `declared-lock-edge`. `version` is the declaration/current locked value; `requested` is separate. `role` preserves finite parser-selected groups, XML elements or lock labels. `operation` is `reference`, `include`, `update` or `remove`. `owner` is only a safe package spelling, never a resolved record target. `condition_present` records presence only. Extras are safe identifiers; marker names use the fixed standard vocabulary. No raw condition or marker expression is retained.

Anchor locations are closed constants. JSON permits the root, `/dependencies`, `/devDependencies`, `/optionalDependencies`, `/peerDependencies` and `/packages`, with no line claim. XML permits `PackageReference`, `PackageVersion`, `Version`, `VersionOverride` and `package`, preserving the accepted parser-reported line. Text permits `requirements`, `options.install_requires` and `options.extras_require`, with a physical line. Occurrence is positive and parser-defined; JSON normalized member order must not be described as physical source order. Container anchors deliberately omit all package-location keys, including safe-looking ones. No hashes of redacted keys or values may enter identities.

Each parser creates one `DependencyBudget`. `decode` checks retained byte count before physical CRLF/CR/LF counting and strict UTF-8 decoding; a UTF-8 BOM is accepted. Parsers pass `max_nodes`/`max_depth` into accepted JSON/XML parsers and reserve traversal/index work before their own allocations. `reserve` independently charges nonnegative nodes, candidate slots and text bytes. `add` reserves its own candidate and extras/marker slots; callers must not double-reserve that candidate. Raw selected UTF-8 text is charged before sanitization. Every retained ASCII string includes its two JSON quote bytes in the same text budget, and a distinct diagnostic is charged once. This is a conservative parser text/work budget; complete Analysis rows, keys, numeric values, arrays, diagnostics and serialized output are separately budgeted by integration.

Any limit exhaustion invalidates result access and must discard the complete parser population. Invalid UTF-8 or surrogate-selected strings also invalidate result access. Parser shape or unsupported-format failures must be raised with a fixed code, never the underlying exception text; a caller must not catch a blocking error and return earlier candidates. Repeated diagnostics are a sorted set in parser results and later aggregate by `(code, path, analyzer)`.

Fixed codes: `dependency-limit`, `dependency-malformed`, `dependency-encoding`, `dependency-unsupported`, `dependency-redacted`, `dependency-ambiguous`, `dependency-binding-unresolved`. Public contract misuse raises fixed ValueError. Safe values retain a bounded literal/constraint/tag, or null plus `missing`, `dynamic`, `url`, `vcs`, `local`, `workspace`, `alias` or `unsupported`. This finite grammar does not evaluate semver, PEP508 or MSBuild.

The scoped toolchain passed on identical frozen bytes. Initial formatting/import/docstring diagnostics are retained; no unit assertion failed. A final comment-only clarification was followed by the clean focused4 loop. One consolidated task review and final ordered suite remain. Native dispatch, registry exposure, complete feature acceptance and other platforms are not claimed.
