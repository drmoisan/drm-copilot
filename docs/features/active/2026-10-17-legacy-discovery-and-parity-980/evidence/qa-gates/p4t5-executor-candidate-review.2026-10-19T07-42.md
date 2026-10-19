# P4-T5 consolidated candidate review

Timestamp: 2026-10-19T07-42
Command: `poetry run python SCRATCH/issue-980-p4t5-review-binding.py`; retained independent probe command is recorded in the 07-34 JSON below.
EXIT_CODE: 0
Output Summary: **REPAIR_REQUIRED**. Evidence bindings pass; R1-R3 require correction. This is the complete candidate finding set, with no open behavioral probe and no task or AC checkoff.

The reviewed candidate contains five production modules and four tests. All nine working files match the frozen manifests, current index and pushed checked-WIP commit `a4a084f247b624a382d9c1356018b687d8aec59a` exactly. COM's earlier checked-WIP commit is `2aafdd818957f4067edd11ab1e08bea45759bda2`; the accepted baseline remains `957908053625c5a22099bafe5b6fd3dde2aedde2`.

## Complete findings

1. **R1 — P2: distinguish collection expressions and explicit interface declarations from attributes/calls.** `com_interop.py:128` treats `Take([ComImport])` and `Take(0, [ComVisible])` as COM attributes. It also treats an explicit `Marshal.IsComObject` interface implementation as a call. `api_syntax.py:131` similarly emits filesystem and registry invocations for explicit `File.Open` and `Registry.GetValue` implementations. All five negatives return one candidate; genuine attribute/call controls pass. These are unambiguous syntax contexts, independent of unresolved runtime binding. Repair the bounded lexical context discrimination and retain the five regressions plus positive controls. COM and access owners should correct their respective modules; helper scope expansion requires coordinator approval. The language references describe [collection expressions in method arguments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/collection-expressions) and [explicit interface member implementations](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/language-specification/interfaces).

2. **R2 — P2: enforce public scanner limits before masking allocation.** `api_syntax.py:170-172` accepts `max_sites=True`, `False` and `0.5`, and calls masking before rejecting a 64 MiB-plus-one string. The probe intercepted masking immediately, so it did not allocate the oversized mask and used no time threshold. Normal analyzer entry already performs bounded decoding; the defect is in the independently callable `access_sites` seam. Validate exact integer capacities/ranges and text size before masking/tokenization, preserve fixed redacted errors and no partial result, and add counted/intercepted-work regressions. No predecessor masking/tokenizer change is required.

3. **R3 — P2: add required intent comments to three COM-test comprehensions.** The metadata conversions selecting `ordinal`, `operation` and `embed_interop_types` in `test_com_candidates.py:262-277` lack immediate intent comments. Add concise purpose comments above the containing assertions or equivalently expand the comprehensions. Preserve all assertions and existing cases. This follows `.agents/skills/self-explanatory-code-commenting/SKILL.md:42`.

## Retained proof and limits

Both focused formatting, lint, scoped type and test sequences pass on the reviewed hashes: access **156 tests**, **212/212 statements**, **82/82 branches**, **15 ranges**; COM **111 tests**, **170/170 statements**, **74/74 branches**, **9 ranges**. Every measured range has 100% coverage. The existing tests did not cover the reproduced defects. No suite was rerun.

The source review covered fixed API allowlists, inferred source candidates versus detected project declarations, exact captured-byte provenance, immutable pin matching, deterministic output, bounded source/pin/record/text accounting, whole-overflow failure, redaction, optional-import isolation and memory-only unit isolation. All nine files are within 500 lines. Public registration remains P4-T9 work. Lexical analysis does not establish runtime binding, alias resolution, receiver types, runtime paths or execution.

The two manifests retain the shared baseline and 45 predecessor streams. Existing coordinator commit bindings cover the full checked-WIP evidence sets; this review adds only the nine current source/index/commit bindings and focused receipt/harness reconciliation. Access raw stdout/stderr and coverage digests were checked. COM's focused harness records path-sanitized combined output; this review does not claim separate unsanitized raw streams. Historical failures, binder corrections and evidence-only sanitation remain preserved.

## Bounded next sequence

After isolated R1-R3 repair and confirmation, run scoped Black, scoped Ruff, full Pyright and changed-scope architecture/size/import checks. Use two isolated unit batches in reversed module order: access, then COM. Retain the existing 267 cases and add the justified regressions, recording actual node order and per-unit/changed-line coverage. Follow with affected inventory/resource/quality-tier contracts and the actual domain-neutrality caller checks. Finish with bounded Windows/Git synthetic capture, immutable-pin and three-adapter composition, without real COM activation or registry access. Reuse unchanged predecessor proof.

## Evidence

- [Complete machine-readable review](p4t5-executor-candidate-review.2026-10-19T07-42.json).
- [Binding result](p4t5-executor-review-binding.2026-10-19T07-42.json), SHA-256 `99bf4dce51b12ed7daa75ff4f2c708e1b00b36fe07f363ebb34b6da35f7cc944`.
- [Exact binding harness](p4t5-executor-review-binding-harness.2026-10-19T07-42.txt), SHA-256 `8082cb2bb135ab5f1abb2b2d173055dce0a0d1101d3207a795970b7ac8700039`.
- [Original independent probe results](p4t5-executor-candidate-probes.2026-10-19T07-34.json), SHA-256 `6504b78d3b627259799ccefbbbcd798a8f8eae8ce41c1be7ced36289f2a7cb71`: 11 checks, two positive controls and nine reproduced negative expectations; exit zero denotes successful diagnostic execution, not a passing behavioral gate.
- [Exact probe harness](p4t5-executor-candidate-probe-harness.2026-10-19T07-34.txt), SHA-256 `99d10fa29a632e2fe2cd4233fc926b1cce800d4b4a8f261b9ea0df7c3cf6f38d`.

Plan remains **36/84**; authoritative source ACs remain **13/66**. No production, test, plan, AC, checkpoint or Git mutation was performed. P4-T5 remains unchecked pending repair confirmation and final gates.
