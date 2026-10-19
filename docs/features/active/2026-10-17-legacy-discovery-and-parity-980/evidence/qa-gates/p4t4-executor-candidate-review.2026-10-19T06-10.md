# P4-T4 consolidated candidate review

Timestamp: 2026-10-19T06-10
Command: `poetry run python SCRATCH/issue-980-p4t4-review-bindings.py`
EXIT_CODE: 0
Output Summary: Read-only reconciliation passed 179 checks. Candidate review requires one cohesive repair for R1, R2 and R3; final gates and task acceptance remain pending.

Candidate: `d6d00ae2a5a612fdfb026bf954f868edf4c5ff9e`. Accepted baseline: `132a8be5c2088926e92b20df33bd17ee57d9f987`.

Reviewed the two configuration modules, their two tests and four synthetic fixtures. The immutable [freeze](p4t4-focused-wip-freeze.2026-10-19T05-54.json) and [evidence index](p4t4-wip-evidence-index.2026-10-19T05-55.json) retain complete file/evidence identities. [Independent binding](p4t4-executor-review-bindings.2026-10-19T06-07.json) verifies all eight working/index/commit bindings, 34 preserved dependencies, 29 evidence files, three worker harnesses, four ordered focused receipts and all 18 measured class/callable ranges. The existing 61 tests pass with 251/254 statements and 104/110 branch destinations. No predecessor or focused suite was replayed.

## Complete findings

### R1 — Bound expanded identifier and structural-path text before allocation (P1)

Location: `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration_input.py`, lines 86, 111, 230, 321, 350.

The only _Keys output limit counts records. JSON child_pointer constructs a full ancestor prefix for each descendant before _Keys.add, and the adapter likewise accounts only row counts. The public parser returned 65/129/257 keys with 133559/265107/528275 UTF-8 pointer bytes from 2684/3352/4760-byte inputs, each under max_bytes=8192. These measurements do not redefine the input byte limit as an output limit: they establish that no separate aggregate text budget exists.

At the accepted 64 MiB document and 100000-key ceilings, repeated long prefixes permit impractical output allocations despite bounded source bytes and record counts. INI section/default-derived paths and aggregation across multiple files need the same explicit accounting.

Required correction: Introduce a finite documented text/identifier/pointer allocation budget; charge prospective expanded addresses before constructing them and account for complete projected output across files before rows are retained. Keep fixed redacted limit diagnostics and discard partial failed-file or aggregate-overflow claims. Do not weaken input, key-count, depth or source-provenance checks.

Required proof: Retain the small long-prefix reproductions and add deterministic allocation/work assertions for over-budget path construction, multibyte/escaped identifiers, inherited INI paths, and aggregate output across files. Assert rejection before the prohibited allocation, plus ordinary supported inputs and stable identities.

### R2 — Bound or remove INI option-regex backtracking for invalid and valid lines (P1)

Location: `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration_input.py`, lines 315, 331.

The locator invokes ConfigParser.OPTCRE and parser.read_file later uses the same permissive option grammar. The overlapping lazy option match and whitespace match repeatedly scan internal spaces. Malformed delimiter-free lines with 1024/2048/4096 spaces took about 0.005/0.019/0.078 seconds. Valid keys K + spaces + Suffix=VALUE_SENTINEL also took about 0.005/0.020/0.079 seconds and were accepted. Both samples remain below 8192 input bytes.

The physical-line count and total byte limits do not supply a practical aggregate parser-work bound; a single much longer permitted line can consume excessive CPU. Rejecting lines with no delimiter alone leaves the valid-line reproduction unchanged.

Required correction: Remove the overlapping backtracking path or establish deterministic preflight line/aggregate work limits before both locator and ConfigParser option matching. Preserve the explicitly supported strict/case-preserving/default/continuation grammar and fixed redacted errors. A delimiter-presence check alone is insufficient.

Required proof: Add regressions for the exact invalid and valid whitespace cases, with operation/allocation counters or fail-before-parser seams. Include many individually admissible lines to demonstrate the aggregate bound, and positive whitespace/continuation/default cases. Do not use wall-clock timing thresholds as correctness gates.

### R3 — Complete the required immediate intent comments in the same repair (P2)

Location: `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration_input.py`, lines 342.

The section-validation for loop at line 342 has no immediately preceding intent comment. The listed nontrivial test comprehensions perform fixture projection, disposition checks, pointer validation, filtered inheritance assertions or combined anchor projection without immediate intent comments. All class/function docstrings are present; all four Python files are below 500 lines.

Required correction: Add concise intent comments at the identified iteration/assertion sites while making the resource fixes. Preserve assertions and all 61 existing cases. Recheck documentation accuracy for any new budget or parsing behavior before the final ordered sequence.

Required proof: Bounded source-policy confirmation of only the repair delta; retain the completed remaining candidate review and existing proof bindings.

## Retained checks and limits

Finite format selection, strict/secure parser reuse, scalar and condition redaction, fixed public error surfaces, immutable captured-source provenance, low confidence for unmatched pins, deterministic identifiers, unresolved effective presence, domain neutrality, read-only execution and test isolation were reviewed. All classes/functions have docstrings and all four Python files are under 500 lines. Public analyzer registry integration remains P4-T9; this is not native coding-agent-host or whole-feature acceptance.

The [initial eight targeted probes](p4t4-executor-candidate-probes.2026-10-19T06-02.json) and [three valid-INI follow-ups](p4t4-executor-ini-work-probe.2026-10-19T06-05.json) are preserved with exact inert harnesses. Timings are diagnostic observations, not proposed acceptance thresholds. Unicode value separators remain values, the physical-line guard rejects excess input, and the observed exception surfaces remain redacted.

The first binding attempt recorded one checker-only path-rendering mismatch: Windows supplied a short user-directory alias while the worker rendered its resolved path. Resolving that checker path produced 179/179 passing comparisons. The [original failure](p4t4-executor-review-bindings.2026-10-19T06-06.json), both checker harnesses and all original worker diagnostics remain preserved. No source/test or worker evidence was changed.

The paired JSON records exact evidence hashes, full review scope, corrections and reuse qualifications. There are no open probes. Parent authorization may now release the single cohesive repair; subsequent confirmation should cover only the changed delta and retained reproductions. No task/AC checkoff occurred: **35/84 tasks and 13/66 ACs** remain complete.
