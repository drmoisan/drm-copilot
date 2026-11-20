# P2-T1 independent executor verification

Timestamp: 2026-10-18T08-00
Command: poetry run python SCRATCH/issue-980-verify-p2t1.py 2026-10-18T07-59
EXIT_CODE: 0
Output Summary: 49 final-byte probes passed; nine exact staged paths, 165 accepted prior paths and 24 frozen v1/export paths verified; 587/587 executable lines and 251/258 branch arcs covered; all 67 new callable/class ranges have 100% line coverage.

## Verified behavior

The [specialist handoff](../other/p2t1-snapshot.2026-10-18T07-59.md) and [independent machine receipt](p2t1-executor-checks.2026-10-18T07-59.json) verify immutable snapshot values, injected bounded workspace reads, explicit local Git reads and complete configured input loading. Raw profile/activation bytes, pinned local extension schemas, structured artifacts, referenced runtime payloads, imported manifests/content, adapter results and selected source/test/documentation files retain their exact bytes. Missing configured paths remain explicit. Manifest entries are sorted ordinally and hash the captured bytes; the snapshot digest additionally binds selected Git objects, checkout identity and exclusions.

The final 49-case probe passed against all four final production hashes. It covers malformed and unrecognized artifact retention, trusted expected-kind routing, source exclusions that cannot conceal artifact files, extension schema containment and pins, transported content, adapter read scope, byte/metadata changes, read limits, immutable values and deterministic input order. Local extension schemas are rejected outside exactly spelled documentation roots before their bytes are read. Related source manifests must remain inside the configured source-snapshot root. Runtime evidence with distinct general and runtime-artifact payload paths captures both files.

The three [initial review findings](p2t1-executor-review.2026-10-18T07-46.json) are corrected and independently reproduced as passing regressions. Runtime revisions no longer require newly captured evidence to exist in the application commit. A payload reference cannot erase a selected source file's category or pinned read. Equivalent directory listing order is normalized while duplicate and aliased names remain errors. The fixed Git argument prefix includes `--no-replace-objects`, `--no-lazy-fetch`, `--literal-pathspecs` and `protocol.allow=never`; the independent SHA-1 and SHA-256 cases assert these arguments on every operation and verify exact blob bytes. Parent-repository discovery, nonordinary objects, altered blobs, oversized output and revision expressions fail explicitly.

Only four new production modules and five new test modules belong to this task. The checker recomputed every staged object identity, current SHA-256, raw coverage count, measured callable/class range and physical line count. All 165 accepted prior-task paths and 24 frozen v1/export paths remain unchanged. Maximum file length is 486; staged whitespace checks pass. The nine-file scope uses the permitted same-component loading and test splits.

## Quality evidence

| Check | Verified result | Evidence |
| --- | --- | --- |
| Black, pass 6 | Exit 0; nine unchanged files | [Formatting](p2t1-format-pass6.2026-10-18T07-55.md) |
| Ruff, pass 6 | Exit 0; zero findings | [Lint](p2t1-lint-pass6.2026-10-18T07-55.md) |
| Full Pyright, pass 6 | Exit 0; zero code diagnostics | [Types](p2t1-types-pass6.2026-10-18T07-55.md) |
| Focused Pytest | Exit 0; 112 passed in 85.00 seconds | [Tests](p2t1-tests-pass6.2026-10-18T07-57.md) |
| Reversed five-module order | Exit 0; 112 passed in 36.30 seconds | [Isolation](p2t1-tests-reversed.2026-10-18T07-58.md) |
| Packaged schema closure | Exit 0; unchanged packaged resources | [Resources](p2t1-resource-check.2026-10-18T07-58.md) |
| Tracked quality tiers | Exit 0; 26 entries/26 discovered projects | [Classification](p2t1-tracked-tiers.2026-10-18T07-58.md) |
| Final source/coverage audit | Exit 0; no findings | [Audit](p2t1-task-audit.2026-10-18T07-59.md) |

Raw coverage independently confirms repository_reader.py at 83/83 lines and 24/24 arcs; snapshot.py at 116/116 and 27/28; snapshot_io.py at 186/186 and 88/88; and snapshot_loading.py at 202/202 and 112/118. All added executable lines and all 67 measured callable/class ranges have 100% line coverage. Existing production bytes are unchanged, so no changed-line coverage regression is introduced. The tests use injected memory metadata, bytes and Git responses; they create no temporary files and launch no subprocess or network operation. TypeScript, PowerShell and C# gates are not applicable to these Python-only additions. Full repository QA remains Phase 11.

Earlier failed evidence remains explicit. Pass 4 records 102 passes, three fixture/diagnostic assertion failures and two Windows setup/teardown errors from an oversized automatic pytest parameter ID. Pass 5 records 110 passes and two missing control-fixture lookups. The corrected fixtures use the accepted checksum wording, matching imported identity, a short parameter ID and the existing pure control-fixture helper. The initial independent 47-case run records 45 passes and two overly narrow diagnostic assertions; its failed cases and original hashes are retained in the machine receipt. The corrected final probe passed all 49 cases. No failed run is represented as a passing gate.

The [review evidence](p2t1-executor-review.2026-10-18T07-46.md) also retains the exact rejected shell command, guard message, intended evidence paths and zero mutated files. The evidence was then written through the structured file-edit tool. No hook bypass, policy change or external action occurred.

## Checkoff and continuation

P2-T1 is verified and checked. Plan progress is 16/84, with P2-T2 next. AC-10, AC-11, AC-12 and AC-14 remain checked, 4/66 per requirement source; no broader criterion is inferred from snapshot loading alone.

The host must supply trustworthy, workspace-anchored, non-following and allocation-bounded read adapters. This task does not implement native process execution, writes, compare-and-swap, host authority or atomic filesystem transactions. A missing Git adapter leaves checkout/object evidence unavailable. Loading success does not establish discovery or parity completion. Typed reference resolution, semantic manifest/checksum validation, revision integrity, observed claims, decisions, coverage, parity and report authenticity remain assigned to the following plan tasks.
