# Feature Audit — F6 `ts-new-potential-bug-entry` (Issue #240)

- Timestamp: 2026-06-26T02-34
- Reviewer: feature-review agent

## Scope and Baseline

- Resolved base branch: `main` @ merge-base `1bccb0c37d81e803dd2df096e4c7005c596986d0`
- Head: `feat/ts-port-new-potential-bug-entry-240` @ `70ccc851fbfc9928d3b7c556363f0e8e183ece01`
- Work mode (from `issue.md`): `full-feature`.
- AC-source resolution: `full-feature` resolves to `spec.md` and `user-story.md`.
  - `spec.md` is present and carries epic-level acceptance criteria (AC-E1 through AC-E5), explicitly satisfied incrementally across features and fully realized at F11.
  - `user-story.md` is **absent** from the feature folder. Per `acceptance-criteria-tracking` fail-closed handling, this gap is documented; the epic-level user story is captured inline in `spec.md` ("## User Story").
  - Per the task input, per-feature ACs for this epic are tracked in the plan checklist. The authoritative per-feature AC source for F6 is the `## F6 Acceptance Criteria Checklist` in `plans/F6-new-potential-bug-entry.plan.md` (AC-F6-1 through AC-F6-9). These are evaluated below; the epic-level ACs are evaluated for their incremental F6 contribution.

## Acceptance Criteria Inventory

### Per-feature ACs (authoritative for F6) — `plans/F6-new-potential-bug-entry.plan.md`

- AC-F6-1: Port `new_potential_bug_entry.py` with byte-identical validation/message, replace-all rendering, author order, date/slug/path, template selection, launcher logic.
- AC-F6-2: Uses injected F1 `FileSystem` and `CommandRunner`/`which`/`env`/launcher seams; no direct `node:child_process`/`node:fs` in the library entry path; no `copyFile` added to `FileSystem`.
- AC-F6-3: `code`/`code-insiders` launch is a guarded no-op in the non-interactive/MCP path; warnings emitted via injected log sink.
- AC-F6-4: `newPotentialBugEntry` calls the in-process helper instead of spawning Python; inputs and return contract preserved; wiring extracted so `repo-automation-service.ts` stays <= 500 lines.
- AC-F6-5: Library and service-call tests mirror every behavioral scenario from the Python tests using Jest with mocked `FileSystem` and injected seams; hermetic.
- AC-F6-6: Extension tests asserting a Python spawn for the command are updated to the in-process expectation without weakening unrelated assertions; tool name / handler / input schema unchanged.
- AC-F6-7: No file exceeds 500 lines; ES modules; no `any`; kebab-case filenames; AAA tests.
- AC-F6-8: Format, lint, typecheck, coverage-enabled test pass; new files meet line >= 85% / branch >= 75%; no regression on overall `src/lib/**` coverage.
- AC-F6-9: Python sources, `command-runtime.ts`, and the `"python"` runtime branch are unmodified (removal is F11); scope containment evidenced.

### Epic ACs (incremental contribution) — `spec.md`

- AC-E1, AC-E2, AC-E3, AC-E4, AC-E5: realized incrementally; fully satisfied at F11.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-F6-1 | PASS | `new-potential-bug-entry.ts`: `validateShortName` (L75-84) throws byte-identical message; `renderContent` (L100-112) uses split/join replace-all for all three placeholders; `getAuthor` (L169-183) git->USERNAME->"Unknown"; `createBugEntry` (L415-443) builds `<workspace>/docs/features/potential/<date>-<shortName>.md` and selects templateRoot vs workspace fallback; `isInsidersSession`/`resolveCodeCli`/`defaultCodeLauncher` (L195-320) port insiders-signal detection and CLI ordering. Parity mapping in `evidence/regression-testing/f6-port-parity.md`. |
| AC-F6-2 | PASS | Library uses injected `FileSystem` (`ensureDir`/`readTextFile`/`writeTextFile`, L445-449) and `CommandRunner`/which/env/launcher seams. Direct `node:fs` use is confined to `defaultWhichLookup` (an injectable production default), not the entry path. No `copyFile` added to `FileSystem` (confirmed by inspection of `file-system.ts` import). |
| AC-F6-3 | PASS | `new-potential-bug-entry-service-call.ts` L91 hard-codes `codeLauncher: () => false`; warning lines emitted via `options.log?.(...)` in `createBugEntry` L451-458. Asserted by `new-potential-bug-entry-service-call.test.ts`. |
| AC-F6-4 | PASS | `repo-automation-service.ts` diff replaces the Python `executeScript({ runtimeKind: "python", ... })` body with a single `newPotentialBugEntryServiceCall({...})` delegation plus one import; method no longer spawns Python; return record preserves `tool`/`workspaceRoot`/exact `summary` and adds `artifacts`. File is 498 lines (<= 500). |
| AC-F6-5 | PASS | `test/lib/new-potential-bug-entry.test.ts` (414 lines), `new-potential-bug-entry-launcher.test.ts` (154), and `new-potential-bug-entry-service-call.test.ts` (160) use `@jest/globals`, a Map-backed in-memory `FileSystem` fake, and stub runners; no real git/editor/temp files. 725/725 tests pass. |
| AC-F6-6 | PASS | `extension.workflow-commands.test.ts` diff (7 ins / 97 del) removes Python-spawn cases for this command; in-process cases moved to new `extension.new-potential-bug-entry-inprocess.test.ts` (258 lines). Tool name `new_potential_bug_entry`, handler, and `mcp-tool-inputs.ts` are not in the diff (unchanged). Full suite passes. |
| AC-F6-7 | PARTIAL | New/production files all <= 500 (`new-potential-bug-entry.ts` 461, `-service-call.ts` 101, `repo-automation-service.ts` 498). ES modules, no `any` (comment-only matches), kebab-case, AAA tests confirmed. However, `extension.workflow-commands.test.ts` is 790 lines, exceeding 500. This is a pre-existing condition (880 lines at merge-base), reduced by F6 (-90), and out of F6 scope per the plan's "do not grow it" mandate, which is satisfied. The AC text says "No file exceeds 500 lines (including ... `extension.workflow-commands.test.ts`)"; that file still exceeds 500, so this AC is marked PARTIAL rather than PASS. Not a blocking F6 finding; full decomposition is a separate effort. |
| AC-F6-8 | PASS | Reviewer re-ran all four stages: format (exit 0), lint (exit 0), typecheck (exit 0), `node run-jest.cjs --coverage` (exit 0, 725/725). New-file coverage: `new-potential-bug-entry.ts` line 95.87% / branch 82.97%; `-service-call.ts` 100%/100%. Overall `src/lib/**` line 96.30% -> 96.33% (no regression). See `evidence/qa-gates/f6-coverage-delta.md`. |
| AC-F6-9 | PASS | `git diff --name-only` confirms no change to `command-runtime.ts`, the `"python"` branch, `resources/scripts/dev_tools/**/*.py`, `resources/templates/*.py`, `scripts/dev_tools/**`, `mcp-handlers/feature-entry-handlers.ts`, or `mcp-tool-inputs.ts`. Evidenced in `evidence/qa-gates/f6-scope-verification.md`. |
| AC-E1 (epic) | PARTIAL (incremental) | F6 adds one TS port (`new_potential_bug_entry`) with parity; epic AC realized fully at F11. |
| AC-E2 (epic) | PASS (for F6 scope) | New F6 modules meet line >= 85% / branch >= 75%. |
| AC-E3 (epic) | PARTIAL (incremental) | F6 wires one method in-process; `"python"` branch and bundled resources removal is F11. |
| AC-E4 (epic) | PARTIAL (incremental) | F6 removes the Python dependency for this one command; full removal at F11. |
| AC-E5 (epic) | PASS (for F6 scope) | All locally re-runnable gates pass. CI status at HEAD not available in PR context; subject to the orchestrator's S9 CI green gate. |

## Summary

All nine F6 per-feature acceptance criteria are satisfied except AC-F6-7, which is PARTIAL solely because the pre-existing `extension.workflow-commands.test.ts` (790 lines) remains over the 500-line limit. F6 reduced that file by 90 lines and did not grow it; bringing it fully under 500 is a separate decomposition effort outside F6 scope. No blocking findings. The feature is functionally complete and behavior-parity is evidenced for the ported command.

The absence of `user-story.md` is documented as an AC-source gap; the user story is captured in `spec.md`. This does not affect the F6 per-feature evaluation.

### Acceptance Criteria Status

- Source: `plans/F6-new-potential-bug-entry.plan.md` (per-feature, authoritative for F6); `spec.md` (epic-level)
- Total per-feature AC items: 9
- PASS: 8
- PARTIAL: 1 (AC-F6-7 — pre-existing over-limit test file, out of F6 scope)
- FAIL / UNVERIFIED: 0

## Acceptance Criteria Check-off

The F6 per-feature AC items (AC-F6-1 through AC-F6-9) in `plans/F6-new-potential-bug-entry.plan.md` were already marked `[x]` by the executor. The reviewer verified the evidence for each:

- AC-F6-1, AC-F6-2, AC-F6-3, AC-F6-4, AC-F6-5, AC-F6-6, AC-F6-8, AC-F6-9: evidence confirms PASS; check-off retained.
- AC-F6-7: evaluated as PARTIAL by the reviewer because `extension.workflow-commands.test.ts` (790 lines) still exceeds the 500-line limit named explicitly in the AC text. The plan's `[x]` reflects the "do not grow it" intent (satisfied). The reviewer does not silently flip the source checkbox; the PARTIAL rationale and the pre-existing/out-of-scope classification are documented here and in the policy audit (finding P-1). No source-file checkbox change is made by the reviewer for this item.

Epic ACs in `spec.md` (AC-E1 through AC-E5) remain `[ ]` by design (realized at F11); no check-off change is made.
