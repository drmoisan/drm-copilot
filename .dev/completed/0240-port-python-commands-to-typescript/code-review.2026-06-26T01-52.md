# Code Review: F5 ts-resolve-prompts (Issue #240)

**Review Date:** 2026-06-26
**Branch:** `feat/ts-port-resolve-prompts-240` (head `f2425fb`)
**Base:** `main` (merge-base `c82de73`)
**Reviewer scope:** Full feature-vs-base branch diff.

## Executive Summary

F5 ports the bundled `resolve_hard_lock_prompt.py` and `resolve_file_prompt.py` to in-process TypeScript under `src/lib/resolve/` and wires the two `RepoAutomationService` resolve-prompt methods to call the port instead of spawning a Python interpreter. The implementation is clean, host-neutral, strongly typed, and well documented. All file I/O flows through the injected F1 `FileSystem`; clipboard and stdout are injectable seams with safe defaults so the quiet/MCP path and unit tests perform no real OS clipboard, subprocess, or process-stdout interaction. Work-mode resolution reuses `prompt-mode-contract.ts`.

The full toolchain (format, lint, typecheck, Jest with coverage) was rerun independently and passed in a single pass: 60 suites, 698 tests, 0 failures; All-files coverage 96.3% line / 88.06% branch. Every new `src/lib/resolve/**` file meets the uniform thresholds (line >= 85%, branch >= 75%).

Code quality is high. There are no blocking findings. One informational finding (interface relocation) and two low-severity observations (a thin branch-coverage margin on `file-prompt-variables.ts`; the `${research}` semantics noted for confirmation) are recorded for awareness. None require remediation.

Parity strengths observed:
- The minor-audit override block, placeholder strings, and error messages are reproduced verbatim to match the Python source (e.g., `Error: Template '<name>' not found. Checked locations:`, `Successfully resolved prompt and copied to clipboard.`, `Could not copy to clipboard; printing resolved prompt to stdout.`, the `✓ Copied to clipboard` / `✗ Could not copy to clipboard (no supported mechanism found)` lines).
- `splitLinesKeepEnds` reproduces Python `splitlines(keepends=True)` so line-removal/insertion transforms are byte-identical on re-join.
- `replaceAllVariables` substitutes in sorted key order and re-runs the placeholder extraction as a safety check, matching the Python unresolved-placeholder guard.
- The hard-lock `quiet`-without-`output` guard throws the exact preserved message at the service-call layer before any file work; a defensive command-level guard with the bundled CLI message is also present and documented.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Info | src/repo-automation-service-workflows.ts | L30 (interface), L207-262 | `RunCodexNativeConverterInput` was relocated from `repo-automation-service.ts` into this module (still exported; re-imported and used identically in the service). This is a small expansion beyond the plan's stated "two method bodies + import changes only." | Accept as-is; the move is behavior-neutral and keeps `repo-automation-service.ts` at the 500-line limit. No action required. | The interface remains exported and its consumers reference the same name at the same call sites; public surface unchanged. Serves the 500-line invariant. | `git diff` of the two service files; grep confirms 4 references at unchanged sites. |
| Low | src/lib/resolve/file-prompt-variables.ts | branch coverage 75.75% (uncovered 70-72,109-110,139-141,296-297,346-352) | Branch coverage clears the 75% floor with a thin margin; uncovered branches are the not-relative fallbacks and the issue.md unreadable path. | Optionally add tests for the `tryRelativeToWorkspace` outside-workspace branch and the `resolveWorkModeFromIssue` read-failure branch to raise the margin. | The file passes policy; the margin is narrow enough that a future edit could dip below 75%. This is a resilience suggestion, not a gate failure. | `f5-final-test-coverage.md`; independent coverage re-run. |
| Low | src/lib/resolve/file-prompt-core.ts | L104-109 | `${research}` handling: when research is missing, `removeLinesReferencingVariable(content, "research")` removes referencing lines; when present, the value is added to the map. Behavior matches the bundled source per the plan's parity notes. | Confirm against the bundled `resolve_file_prompt.py` that line-removal (not `(missing)` annotation) is the intended research semantics. Plan P0-T2/P3-T6 assert this; no change recommended. | Research differs from user-story (which annotates `(missing)`); the asymmetry is intentional per the plan but worth a one-line confirmation in the parity record. | Plan Parity Notes; `f5-port-parity.md`. |

## Detailed Notes

### Design and structure
- The four-file split (`hard-lock-prompt.ts`, `file-prompt-variables.ts`, `file-prompt-transforms.ts`, `file-prompt-core.ts`) plus the `resolve-prompts-service-call.ts` wiring keeps each module focused and under 500 lines. `file-prompt-transforms.ts` is a contingent further split (the plan permitted further splitting if the 500-line limit would be breached); `file-prompt-variables.ts` re-exports the transforms so consumers retain a single import surface. This is reasonable and documented in the module headers.
- The service stays thin: methods delegate through `runResolveExecuteHardLockPrompt` / `runResolveAtomicPlanPrompt` in the workflows module, which delegate to the service-call module — mirroring the F2 `validate-orchestration-service-call.ts` precedent.

### Correctness and parity
- `resolveTemplatePath` probes the explicit template root before the workspace `.github/codex` fallback and returns the ordered checked list for the not-found message — matching `_resolve_template_path`.
- `resolveIssueFileForTarget` implements the `v*` parent fallback with the `>= 2` component guard, matching `_resolve_issue_file_for_target`.
- The hard-lock output path resolution (absolute verbatim; relative joined to workspace; `ensureDir` on the parent before write) matches the Python `_write_resolved_prompt` path resolution and is exercised by the reworked `repo-automation-hard-lock-prompt.test.ts`.
- The service-call layer captures emitted lines and rethrows a non-zero command exit as an Error carrying the emitted text, so the MCP handler reports a non-zero outcome — matching the Python stderr+exit-1 behavior.

### Error handling
- The two `catch {}` blocks (issue.md read failure) fail closed to `full-feature` with the fixed reason `issue.md unreadable; fail closed to full-feature`, with an inline comment explaining the Python OSError parity. This is an intentional, documented fail-closed, not a silent swallow.

### Tests
- New tests under `test/lib/resolve/` use `@jest/globals`, `Map`-backed in-memory `FileSystem` fakes, and `jest.fn()` spies; one behavior per test; AAA structure. Hermetic: no real clipboard, subprocess, or temp files.
- The reworked extension tests preserve editor-reuse, picker, picker-cancellation, and registration assertions; the Python-wrapper spawn assertions are replaced with in-process assertions, and the missing-Python-runtime cases are converted to "completes via the in-process path without probing a Python runtime." No Python-wrapper spawn assertion remains for these two commands (grep: NO_PY_WRAPPER_SPAWN_ASSERTIONS).

## Verdict

No blocking findings. The branch is code-quality ready for PR pending the feature-audit acceptance-criteria verdicts.
