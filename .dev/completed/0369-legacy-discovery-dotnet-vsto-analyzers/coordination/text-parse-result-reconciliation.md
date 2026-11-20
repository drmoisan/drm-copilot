# TextParseResult Reconciliation — Coordination Decision Record

- Feature: legacy-discovery-dotnet-vsto-analyzers (#369)
- Depends on: legacy-discovery-analyzer-framework (#363)
- Date: 2026-07-18
- Status: Adopted (no #363 change required); open reconciliation item recorded

## Decision

The two stack-specific analyzers delivered by #369 adopt a frozen dataclass
subtype `TextParseResult(ParseResult)` defined in
`scripts/dev_tools/discovery/analyzer/source_text.py`. It adds a single field:

```python
@dataclass(frozen=True, slots=True)
class TextParseResult(ParseResult):
    file_texts: tuple[tuple[str, str], ...] = ()
```

`file_texts` is an ordered tuple of `(consumer-relative POSIX path, text)` pairs,
in the same order as the inherited `paths` field. Each analyzer's `parse` stage
returns `TextParseResult`; each analyzer's `classify` stage accepts the base
`ParseResult` (matching the `Analyzer` protocol signature) and isinstance-narrows
to `TextParseResult`, raising the #363 `AnalyzerError` on a plain `ParseResult`.

## Why file text is required between parse and classify

The #363 `Analyzer` contract is a fixed four-stage pipeline
`parse -> classify -> map -> emit` where `parse` performs I/O and `classify` is
pure. The .NET/C# and VSTO/Office analyzers must scan file *text* (comment/string
stripping, line-anchored pattern matching). Reading that text is an I/O operation
and must occur in `parse`, not `classify`. Performing the read inside `classify`
would violate both the framework's pure-classify design and the repository
I/O-boundaries rule (`.claude/rules/general-code-change.md`, Separation of
concerns). Therefore file text must travel from `parse` to `classify` as data.

The merged #363 `ParseResult` (`scripts/dev_tools/discovery/analyzer/models.py`)
is paths-only:

```python
@dataclass(frozen=True, slots=True)
class ParseResult:
    paths: tuple[str, ...]
```

It has no payload field to carry text.

## Chosen approach: no-#363-change subtype

A frozen subtype adds the payload without modifying the merged #363 contract:

- `parse` returning `TextParseResult` is a covariant return that satisfies the
  structural `Analyzer` protocol (`parse(ctx) -> ParseResult`).
- `classify(parsed: ParseResult)` keeps the protocol signature and narrows at
  runtime via `isinstance`, failing fast with `AnalyzerError` if handed a plain
  `ParseResult`. This preserves the fail-fast, explicit-error policy.
- No change is required to any #363 module, so #369 is not blocked on a #363 edit
  and does not silently diverge from the merged framework contract.

## Open reconciliation item (raise with #363 at integration-branch time)

The preferred long-term resolution is for #363 to genericize `ParseResult` with an
optional payload field (for example an optional, type-parameterized payload or an
optional `file_texts`-style attribute on the base) *before the #363 ParseResult
contract freezes*. If #363 adopts a first-class payload, #369 should migrate off
the local subtype to the framework-provided mechanism to avoid two parallel
payload conventions.

Action: raise this as an explicit coordination item on the
`epic/legacy-discovery-and-parity-integration` branch before the #363 `ParseResult`
contract is frozen. Until then, the subtype approach above is authoritative for
#369 and requires no #363 change.
