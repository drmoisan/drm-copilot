# P4-T3 final specialist handoff

Timestamp: 2026-10-19T05-22
Command: Bind seven ordered gates, exact candidate/index/commit bytes and retained review
EXIT_CODE: 0
Output Summary: All 386 unit cases, 176 affected contracts and eight native Windows/Git checks passed in one ordered loop. Coverage is 610/611 statements and 259/260 branch destinations; every measured class/callable is at least 90%. All 14 source/test hashes remained unchanged. Executor acceptance remains pending.

The approved slice relocates shared masking/carriers and legacy C# inventory into the reusable runtime, adds bounded strict decoding/tokenization, separates declaration syntax from inferred members and handler relationships, and retains exact captured-byte hashes. Legacy adapters preserve class identity, constructor signatures and meaningful detection assertions; direct legacy emission is rejected in favor of guarded publication.

## Ordered results

| Stage | Seconds | Exact receipt |
| --- | ---: | --- |
| 1. format | 0.33 | [p4t3-final-format-051811.2026-10-19T05-18.json](p4t3-final-format-051811.2026-10-19T05-18.json) |
| 2. lint | 0.11 | [p4t3-final-lint-051811.2026-10-19T05-18.json](p4t3-final-lint-051811.2026-10-19T05-18.json) |
| 3. types | 11.78 | [p4t3-final-types-051823.2026-10-19T05-18.json](p4t3-final-types-051823.2026-10-19T05-18.json) |
| 4. architecture | 0.12 | [p4t3-final-architecture-051823.2026-10-19T05-18.json](p4t3-final-architecture-051823.2026-10-19T05-18.json) |
| 5. tests-reverse | 33.17 | [p4t3-final-tests-reverse-051856.2026-10-19T05-18.json](p4t3-final-tests-reverse-051856.2026-10-19T05-18.json) |
| 6. contracts | 1.88 | [p4t3-final-contracts-051858.2026-10-19T05-18.json](p4t3-final-contracts-051858.2026-10-19T05-18.json) |
| 7. native | 2.45 | [p4t3-final-native-051901.2026-10-19T05-19.json](p4t3-final-native-051901.2026-10-19T05-19.json) |

The paired JSON includes all fourteen exact paths, raw stdout/stderr hashes, executed node order, per-module/class/callable coverage, responsibility mappings from the 155-case baseline, all 38 unchanged accepted predecessor paths, twelve unchanged caller/fixture paths, Git attributes and working/index/checked-WIP blob identities. Three exact LF-only harness snapshots are stored beside this handoff; raw command diagnostics remain preserved externally.

## Review and preservation

The consolidated review identified contextual record misclassification, anonymous-delegate misclassification and unbounded declaration rescanning. One cohesive repair added 26 regression cases and one shared traversal budget. The original candidate/probes remain retained; bounded independent confirmation closed all three findings. The existing 470-line declaration test file and the other twelve candidate paths were unchanged by repair. The new test split has 117 lines; all source/test files remain below 500 lines.

The initial legacy modules covered 258/270 statements and 88/96 branch destinations. Rewritten or relocated legacy responsibilities now have full coverage, with explicit per-unit mappings in JSON; physical rewritten line counts are not claimed as unchanged. The new tokenizer retains one documented uncovered defensive 64 MiB direct-text guard and otherwise preserves its accepted focused proof. Ruff/type/failing-test deltas are zero.

## Downstream interfaces

**source_text** — strip_comments_and_strings(text: str) -> str preserves decoded character offsets and every CR/LF while blanking comments, chars, regular/verbatim/raw strings and entire interpolation expressions. numbered_lines(text: str) -> list[tuple[int,str]] uses CRLF/CR/LF physical boundaries and preserves a final empty line. All eight legacy exports retain canonical object identity; six evidence/carrier executable AST contracts and positional/default constructors are unchanged.

**tokens** — decode_source(content: bytes, *, max_bytes: int=67108864) -> str accepts strict UTF-8 with optional BOM or BOM UTF-16/32, rejects invalid encodings/NUL/size. tokenize_csharp(masked_text: str, *, max_tokens: int=100000) -> tuple[Token,...] retains literal Unicode/verbatim/escaped spelling and decoded-character offsets. Frozen Token has value/start/end/line/identifier; end is exclusive. No compiler normalization, preprocessing evaluation or byte-offset claim.

**declarations** — declaration_candidates(path: str, text: str, *, include_members: bool=True, max_tokens: int=100000) -> tuple[Detection,...] returns sorted namespace/type/record/delegate/event syntax plus optional inferred direct members. One max(32,4*token_count) private counter bounds all overlapping lookahead. SourceScanError.code identifies source-work-limit, source-declaration, token/encoding errors; failed files emit no partial claims.

**subscriptions** — subscription_candidates(path: str, text: str, *, max_tokens: int=100000) -> tuple[Detection,...] extracts possible handler assignments with operator/handler/offset/end_line metadata. Every relationship stays inferred, unresolved and potentially arithmetic; no runtime activation or event binding is established.

**v2_adapters** — CSharpDeclarationAnalyzer.identifier=csharp-symbols and EventSubscriptionAnalyzer.identifier=event-subscriptions expose analyze(capture: InventoryCapture) -> Analysis. They consume only captured bytes/pins, have no I/O/publication, classify facts vs inference, downgrade unmatched pins and bound records. Diagnostics preserve per-file failures and unresolved compiler/preprocessor semantics. Direct construction is tested; public registry selection is deferred to P4-T9.

**legacy** — classify_text(path: str,text: str) -> list[Detection] preserves the original declaration/event catalog and heuristic metadata. DotnetInventoryAnalyzer(fs=None) parses once into private captured-byte carriers, maps hashes from the same payload without rereads, and rejects direct emit in favor of guarded v2 publication. The old modules are identity-preserving re-exports.

## Limits and handoff

Lexical facts do not establish compiler binding, active preprocessing, complete grammar or runtime event behavior. Member/handler relationships remain inferred; source anchors refer to decoded characters while checksums refer to original bytes. No compiler dependency, optional domain import, automatic publication or production write was introduced by the pure adapters.

The operational proof covers native Windows Python/Git and direct adapter composition. Coding-agent host execution, other-platform CI and final registry wiring remain later planned work; public registry exposure is P4-T9. This task does not claim full-feature completion. The executor owns acceptance/checkoff; the parent owns the next commit/push and task release.
