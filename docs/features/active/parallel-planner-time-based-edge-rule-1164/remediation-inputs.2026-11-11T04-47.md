# Remediation Inputs — Issue 1164 (related non-blocking rows, cycle 1)

Timestamp: 2026-11-11T04-47
Remediation-Mode: design
Source: orchestrator, under owner directive OD-7 ("Fix related findings inside this item before merge; file issues only for completely unrelated findings").
Opening review: `code-review.2026-11-11T04-32.md` (verdict PASS, head `35e8a26275d7f89e559449f2437dfc18aa654b0f`). The review recorded no blocking finding; the rows below are the related Minor and Info rows of its findings table that are fixed inside this item before merge. None is a blocking finding.

Mode rationale: design, because finding R1 changes `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts`, a file outside the branch diff.

## Findings

### R1 — Python/TypeScript error-string divergence for values containing an apostrophe (Minor)

- Files: `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts` (`pythonRepr`), consumers in `extensions/drm-copilot/src/lib/validate/parallel-state-records.ts` (the `read_paths`/`separable_paths` membership error and the `tolerated_overlaps[].reasons` error).
- Finding: CPython `repr` of a string containing `'` and no `"` uses double quotes (`"it's.md"`); `pythonRepr` always single-quotes and escapes (`'it\'s.md'`). The two runtimes then emit different error strings, contrary to US-AC6 (byte-identical strings).
- Required change: make `pythonRepr` follow CPython's quote selection (double quotes when the string contains `'` and no `"`; otherwise single quotes with `'` escaped), with the bundle mirror updated if one exists. Add an apostrophe case to the shared corpus under `tests/fixtures/parallel_state_scheduling/` that both the Python and the TypeScript parity tests consume, so a one-sided edit fails. Identify every existing test that asserts `pythonRepr` output and state its disposition.

### R2 — `# pyright: ignore[reportPrivateUsage]` in a new test (Minor)

- File: `tests/scripts/dev_tools/test_blast_radius_access_weights.py` (import of `_path_pair_weight`).
- Finding: the suppression form is not among the pre-authorized patterns of `.claude/rules/python-suppressions.md`.
- Required change: test the weight rows through the public `pair_cost` with single-path radii (or another public entry point) and remove the private import and its suppression, keeping the same row coverage.

### R3 — Write-verb matching misses inflected forms (Info)

- File: `.claude/lib/blast-radius/BlastRadiusAccess.psm1` (`$script:WriteTitleVerb`, `Test-ReadOnlyWindowSet`), plus its bundle mirror.
- Finding: write verbs match as whole title words, so `writes`, `updates`, `adds`, `Regenerate`, and `Overwrite` do not mark a write; a task title beginning with a read verb then yields a read-only path that is in fact written.
- Required change: extend matching to the common inflections of the listed write verbs (`-s`, `-es`, `-ed`, `-ing`) and add `Regenerate` and `Overwrite`, with Pester cases for each added form, in a fail-safe direction (more paths classified as written, never fewer).

### R4 — One uncovered changed line (Info)

- File: `.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1` (the null band for an item key absent from `items`).
- Required change: add a Pester case with a `kind: "cost"` entry naming a key absent from `items`, asserting the resulting decision.

## Out of scope (accepted, no change)

- The `0 min / 0 min` message for a hand-written tolerated entry without estimates, and the current-directory-relative config resolution of `test-precedence`: the review recorded both as requiring no change; both fail loudly and match existing conventions.
