# Code Review — F6 `ts-new-potential-bug-entry` (Issue #240)

- Timestamp: 2026-06-26T02-34
- Reviewer: feature-review agent
- Base branch: `main` @ `1bccb0c37d81e803dd2df096e4c7005c596986d0`
- Head: `feat/ts-port-new-potential-bug-entry-240` @ `70ccc851fbfc9928d3b7c556363f0e8e183ece01`

## Executive Summary

F6 ports the bundled `new_potential_bug_entry.py` to in-process TypeScript across three production files and four/five test files, and rewires `RepoAutomationService.newPotentialBugEntry()` from a Python spawn to the new in-process helper. The implementation is well-structured: pure library logic is separated from service wiring, all host interactions (filesystem, git, PATH, environment, editor launch) are injectable seams, and the editor launcher is hard-coded to a no-op in the MCP/non-interactive path so no `code`/`code-insiders` subprocess can run. Documentation comments are thorough and explain parity decisions against the Python source.

All seven reviewer-run quality stages pass: format, lint, typecheck, and the full Jest suite (725/725) with coverage above policy floors for both new files. No blocking or material code-quality defects were identified. The findings below are minor observations and confirmations of intentional design choices; none require changes for the F6 PR to merge.

The review confirms behavior parity with the Python source for short-name validation (byte-identical error message), replace-all placeholder rendering, author resolution order (git `user.name` -> `USERNAME` -> `"Unknown"`), date/slug/target-path construction, template selection, the insiders-signal detection and CLI ordering, the guarded no-op launch path with its warning lines, and file-not-found behavior for a missing template. The service return contract is preserved (`tool`, `workspaceRoot`, exact `summary`) and enriched with the created-file path as a single `artifacts` entry.

This is a TypeScript-only change set; no typed-Python review section is required (no Python files changed).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `src/lib/new-potential-bug-entry.ts` | L1-2 (imports `node:fs`, `node:path`) | The library module imports `node:fs` (`existsSync`) and `node:path` directly. The general-code-change I/O-boundary rule asks that domain logic be testable without touching the filesystem. | No change required. Keep as-is. | The direct `node:fs` use is confined to `defaultWhichLookup`, an explicitly injectable production-default seam; the library entry point (`createBugEntry`) never calls it unless a caller omits the seam, and the service/MCP path always injects a no-op launcher. `node:path` is used only for pure path joining. This matches the plan's stated design (P1-T1 acceptance allows the injectable production which/launcher defaults). | `new-potential-bug-entry.ts` L248-274 (`defaultWhichLookup`); L398-409 (default-seam `??` construction); coverage shows these lines uncovered (263-272, 404-408), confirming the supported path does not reach them. |
| Info | `src/lib/new-potential-bug-entry.ts` | L361-367 (`todayIsoDate`) | `todayIsoDate()` reads wall-clock `new Date()` directly. The determinism rule prefers an injected clock. | No change required for F6. | The date is fully overridable via the `entryDate?` option, which all deterministic tests and the service path can supply; `new Date()` is reached only as the default when no override is given, matching the Python `date.today()` default. The general-unit-test determinism rule targets test code and code-under-test; the override seam satisfies determinism for the tested paths. | `createBugEntry` L396 `const dateStr = options.entryDate ?? todayIsoDate();`; tests inject `entryDate`. |
| Info | `src/lib/new-potential-bug-entry-service-call.ts` | L91 | The helper hard-codes `codeLauncher: () => false`, guaranteeing no editor subprocess in the MCP/non-interactive path. | No change required. Confirmed correct and intended (AC-F6-3). | This is the central safety property of the port for the service path; the warning lines are emitted through the injected log sink instead, preserving observable behavior without launching an editor. | Verified by `new-potential-bug-entry-service-call.test.ts` (warning-log assertions) and by inspection. |
| Info | `src/repo-automation-service.ts` | L273-282 | `newPotentialBugEntry` is declared `async` and returns the synchronous helper result (a plain object), which the `async` keyword wraps in a resolved Promise. | No change required. | The method signature returns `Promise<RepoAutomationExecutionResult>`; returning a non-Promise from an `async` method is correct and preserves the interface contract. No floating promise is introduced (the helper performs no async work). | `repo-automation-service.ts` diff hunk; `npm run lint` passes with `no-floating-promises`/`no-misused-promises` at error level. |
| Info | `test/lib/new-potential-bug-entry-launcher.test.ts` | L136-153 | The `defaultWhichLookup` empty-PATH test mutates `process.env["PATH"]`. | No change required. | The mutation is restored in a `finally` block, preserving test independence and determinism; no temp files or external processes are used. This is the minimal hermetic way to exercise the PATH-empty branch. | L138-152 save/restore logic. |

## Strengths

- Clear separation between pure port logic and service wiring, consistent with the F2/F5 precedents cited in the plan.
- Every external dependency is an injectable seam, enabling hermetic tests with no real git, editor, or temp files.
- Doc comments document parity decisions (replace-all semantics, single-read collapse of the Python copy-then-read, insiders-signal ordering, byte-identical error/warning text) so future maintainers can audit parity against the Python source.
- The service-call helper extraction keeps `repo-automation-service.ts` at 498 lines (under the 500 limit), and F6 net-reduced the over-limit `extension.workflow-commands.test.ts` by 90 lines rather than growing it.

## Conclusion

No blocking or material code-quality findings. The change set is ready for PR from a code-quality perspective. The single pre-existing over-limit test file (`extension.workflow-commands.test.ts`, 790 lines) is documented in the policy audit as out of F6 scope and was reduced, not grown, by this feature.
