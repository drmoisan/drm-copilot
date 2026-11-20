# Code Review — Issue #620 (blast-radius-mandate-reads-scripts-vscode) — Re-audit (remediation cycle 1)

- Timestamp: 2026-09-02T12-31
- Branch: `bug/blast-radius-mandate-reads-scripts-vscode-620` @ `bc92d6db99e4791fdce53b64fbe6a6958df9eaa4`
- Base: `origin/main` @ `dd98630c4b786280b2740eb01a75592870b22bbd`
- Prior review: `code-review.2026-09-02T11-48.md` (no Blocking/Warning findings, covering commit `7e74ed77`)

## Change Summary

This re-audit covers the full branch diff `dd98630c..bc92d6db`, which is the previously-reviewed fix commit (`7e74ed77`, two identical JSON edits) plus one new remediation commit (`bc92d6db`):

```diff
       ".claude/agent-memory/**",
       ".agents/skills/**",
+      "scripts/vscode/**",
     ],
```
applied to `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`, inside the `SOURCE_BLAST_RADIUS` constant's `mandate_reads` array.

The two JSON config edits reviewed in the prior cycle are unchanged (`git diff 7e74ed77..bc92d6db -- config/blast-radius.json extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` is empty). No production TypeScript, Python, PowerShell, or C# source is touched. The remainder of the diff is feature-folder documentation and evidence artifacts.

## Diff Review — Remediation Commit

The edit adds exactly one line, `"scripts/vscode/**",`, as the eleventh (final) element of `mandate_reads` in the hand-maintained `SOURCE_BLAST_RADIUS` test fixture, in the same relative position as the corresponding entry in the real bundled `blast-radius.json` (`.agents/skills/**` immediately precedes it in both). Confirmed via independent `git diff` re-run: exactly one `@@` hunk, exactly one `+` line, no `-` lines. No other line in the file is touched.

## Root-Cause Understanding

The remediation correctly diagnosed the CI failure: `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`'s "keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource" test performs a structural `toEqual` between `JSON.parse(SOURCE_BLAST_RADIUS)` and the real committed bundled file. Issue #620's fix updated the real file but not this independently-maintained fixture literal, so the drift-guard test — whose entire purpose is to catch exactly this class of divergence — correctly failed. The fix targets the fixture, not the drift-guard test or the real config, which is the correct locus of change: the fixture is documentation-as-code that had gone stale, not a defect in the assertion or in the already-reviewed config edit.

## Design Principles Assessment

- **Simplicity first.** The remediation is the minimal change: one array entry, mirroring an existing entry's shape and position. No new abstraction, no test restructuring.
- **Scope discipline.** The remediation-plan and remediation-inputs artifacts both explicitly constrain the change to one file and one line, and independently verify that constraint post-edit (`git diff HEAD --stat`, `git status --porcelain`). This is a good practice for a CI-failure remediation: it keeps the fix auditable against the specific failure it targets.
- **Non-interaction verification.** The remediation plan verifies, by reading `blast-radius-derive.test.ts`, that it declares its own independent `MANDATE_READS` constant and does not import `SOURCE_BLAST_RADIUS`, so the edit cannot silently affect that file's assertions. This claim was not re-derived independently by this review beyond the full-suite regression run (2735/2735 passing, which would have caught an interaction had one existed) but the citation is specific and checkable.

## Correctness Observations

- The added entry is byte-identical in text and array position to the corresponding entry in the real bundled file (`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`), independently confirmed by this review via direct read of both files.
- Independently re-run: the previously-failing test now passes (`Tests: 17 passed, 17 total`, `test/lib/push-down/claude-config-carriage.test.ts`), and the full extension unit-test suite passes with zero regressions (`Test Suites: 203 passed, 203 total`, `Tests: 2735 passed, 2735 total`).
- Format, lint, and type-check are clean before and after the edit (all `EXIT_CODE: 0`), independently re-verified.

## Test Coverage of the Change

The change is itself a test-fixture edit; it has no separate "tests for the fix" beyond the drift-guard test it repairs, which is the correct model — the fixture's job is to mirror the real file, and the drift-guard test is what verifies that mirroring. No new test was added or was needed.

**Finding (Blocking, policy-level, cross-referenced from `policy-audit.2026-09-02T12-31.md`):** no coverage artifact (`coverage/lcov.info`) exists for TypeScript anywhere in the worktree, and this branch now has one changed `.ts` file. The remediation-plan's own "Coverage note" argues the changed file falls outside `jest.config.cjs`'s `collectCoverageFrom: ["src/**/*.ts"]` scope and therefore needed no dedicated coverage-capture task. That argument correctly explains why this specific file carries no per-file coverage number to gate, but the mandatory Coverage Verification Procedure this review applies requires a coverage artifact to exist for any language with a changed file, independent of whether that specific file is measured. This is a process gap (no coverage evidence was captured during execution), not a defect in the fixture edit itself. See `remediation-inputs.2026-09-02T12-31.md`.

## Stale Documentation (Non-Blocking, Explicitly Flagged by the Remediation's Own Plan)

`remediation-plan.2026-09-02T12-02.md`'s "Scope" section documents, by its own explicit instruction, that the doc comment above `SOURCE_BLAST_RADIUS` (lines 83-84 at the time of writing) states the array "carries the ten-entry read-by-mandate exclusion set," which is now stale (the array carries eleven entries after this fix). Independently confirmed present in the current file. The remediation-inputs directive explicitly forbade touching any part of the file beyond the one added array entry, so this staleness is a deliberate, documented, scope-constrained residual rather than an oversight. Recommended as a small follow-up (update the comment to "eleven-entry"), not a blocker.

## Naming, Style, and Readability

`"scripts/vscode/**"` matches the existing glob convention used by neighboring entries and by the real bundled file it mirrors. Consistent with existing style; no readability concerns.

## Evidence Quality

Both plans (original fix and remediation) produce evidence artifacts with consistent `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields. Two evidence artifacts from the remediation cycle are notable for candidly documenting observed discrepancies between the plan's literal acceptance text and the tool's actual behavior, rather than glossing over them:

- `p2-t4-target-test-final.2026-09-02T12-02.md` documents that Jest's `--verbose` flag did not itemize passing tests by name in this environment/version, contrary to what the plan's acceptance text expected, and shows this was verified by running the command twice with different output-capture methods.
- `p2-t5-diff-scope-final.2026-09-02T12-02.md` documents that `git status --porcelain` was not a single line as the plan's acceptance text literally demanded, because the plan's own earlier tasks mandate creating several untracked evidence/documentation files first — correctly distinguishing that from a scope violation (no *tracked* file other than the fixture was modified).

This evidence-first, non-defensive reporting is consistent with the repository's tonality policy and is worth preserving as a pattern in future remediation cycles.

## Findings Summary

- **Blocking:** TypeScript coverage artifact absent for a branch with a changed `.ts` file. Not a defect in the fixture edit; a missing evidence-capture step in the remediation's own toolchain execution. See `remediation-inputs.2026-09-02T12-31.md`.
- **Non-blocking observation (carried over from prior cycle):** no derivation-level regression test exists asserting `derive_blast_radius` no longer emits a `path_overlap` conflict edge for a `scripts/vscode/**` citation. Unchanged by this remediation; recorded as a follow-up, not a blocker.
- **Non-blocking observation (new):** the `SOURCE_BLAST_RADIUS` doc comment's "ten-entry" count is now stale by one; a documented, scope-constrained residual per the remediation's own explicit instruction. Recommended follow-up.
