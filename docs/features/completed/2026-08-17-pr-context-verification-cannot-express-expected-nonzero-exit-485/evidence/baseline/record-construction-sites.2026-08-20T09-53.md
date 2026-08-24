# Baseline — in-repo construction sites of the verification-evidence record

Timestamp: 2026-08-20T09-53

Task: [P0-T16]

Command: git grep -n "VerificationEvidenceRecord" -- extensions/drm-copilot/src extensions/drm-copilot/test scripts/dev_tools tests
Command (supporting filter, to find object-literal sites the identifier grep cannot see): git grep -n "normalizedResult:" -- extensions/drm-copilot/src extensions/drm-copilot/test ; git grep -n "normalized_result=" -- scripts tests
EXIT_CODE: 0

## Raw match count

The identifier grep returned **17 matching lines**. It returns EVERY mention of the identifier —
interface declaration, return-type annotations, imports, re-exports, local variable type
annotations, and one JSON test fixture that merely names the string — as well as construction sites,
so the enumeration below required manual filtering.

Raw matches by file:

| File | Lines | Kind |
| --- | --- | --- |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 40 | type-only import |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 74 | local array type annotation |
| `extensions/drm-copilot/src/lib/pr-context/index.ts` | 76 | type re-export |
| `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | 37 | interface declaration |
| `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | 97, 174 | return-type annotations |
| `scripts/dev_tools/pr_context/collector.py` | 66 | import |
| `scripts/dev_tools/pr_context/collector.py` | 130, 138 | local variable type annotations |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 33 | class declaration |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 85, 149 | return-type annotations |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 115, 127, 137 | **construction sites** |
| `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json` | 222 | string inside a blast-radius fixture; not code |

## Filtered construction-site count

**Filtered construction-site count: 6** — three in Python and three in TypeScript. Both runtimes
construct the record only inside `parse_verification_evidence_markdown` /
`parseVerificationEvidenceMarkdown`; no test module and no other production module builds one
directly.

### Python (keyword construction, `verification_evidence.py`)

1. line 115 — `return VerificationEvidenceRecord(` on the missing-required-field branch (`normalized_result="unparseable"` at 121)
2. line 127 — `return VerificationEvidenceRecord(` on the non-integer-`EXIT_CODE` branch (`normalized_result="unparseable"` at 133)
3. line 137 — `return VerificationEvidenceRecord(` on the success path (`normalized_result=normalized_result` at 143)

### TypeScript (object literals, `verification-evidence.ts`)

The identifier grep does NOT reach these: each is a bare object literal returned from a function
whose return type is annotated at line 97. They were located by the supporting
`normalizedResult:` filter and confirmed by reading lines 90-155.

4. lines 124-131 — missing-required-field branch (`normalizedResult: "unparseable"` at 130)
5. lines 135-143 — non-integer-`EXIT_CODE` branch (`normalizedResult: "unparseable"` at 142)
6. lines 147-154 — success path (`normalizedResult` shorthand at 153)

## Checklist Phase 4 must exhaust (risk R8)

Because `VerificationEvidenceRecord` is re-exported from
`extensions/drm-copilot/src/lib/pr-context/index.ts:76`, adding a required `expectedExitCode` member
is a public-surface addition and breaks any construction site that builds the record as an object
literal. The three TypeScript sites above (items 4-6) are the complete in-repo set that [P4-T8] must
update. `npm run typecheck` from `extensions/drm-copilot` is the independent cross-check that the
filtered list is complete: with a zero-error baseline recorded at [P0-T13], any error after the
interface change identifies a site missed here.

The Python analogue needs no site updates: `expected_exit_code: int = 0` is appended last with a
default, so existing keyword construction stays valid. Items 1-3 are nonetheless updated explicitly
by [P2-T6] and [P2-T7] to satisfy Invariant E.

Output Summary: 17 raw identifier matches; 6 filtered construction sites — Python
`verification_evidence.py:115,127,137` and TypeScript `verification-evidence.ts` object literals at
124-131, 135-143, and 147-154. No test module or other production module constructs the record
directly; the single `tests/fixtures/.../verification-integrity-485-486-487.json:222` match is a
string in a blast-radius fixture, not code. The three TypeScript literals are the checklist [P4-T8]
must exhaust, cross-checked by the zero-error `npm run typecheck` gate.
