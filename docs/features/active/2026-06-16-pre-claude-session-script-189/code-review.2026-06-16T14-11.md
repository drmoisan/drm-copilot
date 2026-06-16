# Code Review: pre-claude-session-script (Issue #189)

**Review Date:** 2026-06-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-06-16-pre-claude-session-script-189`
**Feature Folder Selection Rule:** Selected because its suffix (`-189`) matches the canonical issue number and it holds the primary changed scoping docs (`spec.md`, `user-story.md`).
**Base Branch:** `main` (merge-base `93d83d5ea01d40b229e2721f057210d9ef698206`)
**Head Branch:** `drm-copilot-wt-2026-06-16-13-41` (`72e415c389423e7a213bb899970278dff47ce7d5`)
**Review Type:** Initial review

---

## Executive Summary

This change adds a configurable pre-`claude` hook to the "New Claude Worktree Session" VS Code command. It is an additive, TypeScript-only change confined to the `extensions/drm-copilot` package.

**What changed:**
- `src/claude-worktree-session.ts`: extends `WorktreeSessionCommandInput` with `preClaudeScriptPath: string | undefined` and `WorktreeSessionCommands` with `preClaude: string | undefined`. In `buildWorktreeSessionCommands`, a trimmed path of length > 0 produces `if (Test-Path -LiteralPath '<path>') { & '<path>' }`, embedding the path twice via the existing `quoteForPwsh` helper; an undefined/empty/whitespace path yields `preClaude === undefined`.
- `src/extension.ts`: reads `drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath` (default `.claude/hooks/pre-claude-session.ps1`), passes it into the builder, sends `commands.preClaude` after the poetry activate step and before the deferred `claude` send, and extends the output-channel log note to record whether a pre-claude command was emitted.
- `package.json`: declares `contributes.configuration` for the new setting (type string, default, description).
- Tests: 5 builder tests and 4 handler tests, plus a `getConfiguration` mock and `setPreClaudeScriptPathConfig` helper in the test harness; existing ordering tests set an empty path to isolate prior behavior.

The implementation matches `spec.md` exactly, including the pure-module constraint (no `vscode`/`node:fs`/`node:child_process` import in `claude-worktree-session.ts`) and the runtime existence guard. The TypeScript toolchain passed (format/lint/typecheck/test, all EXIT 0). Coverage thresholds are met on both changed production files; the reviewer re-verified the figures from `coverage/lcov.info`.

**Top 3 risks:**
1. Test maintainability: `test/extension.workflow-commands.test.ts` is 957 lines, above the 500-line policy limit (pre-existing, aggravated by +162 lines here).
2. Untrusted-path execution surface: the emitted command invokes whatever script exists at the configured worktree-relative path; this matches the existing trust model for the worktree session command but is the only new execution surface.
3. The runtime `Test-Path` guard cannot be exercised by unit tests (PowerShell-runtime behavior), so the missing-script path is verified by the emitted command string only, not by execution.

**PR readiness recommendation:** **Conditional Go** — The feature is correct, typed, and covered. One Minor maintainability finding (oversized pre-existing test file) is recommended for a separate follow-up and does not block this PR.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `extensions/drm-copilot/test/extension.workflow-commands.test.ts` | whole file (957 lines) | Test file exceeds the 500-line limit that `general-code-change.md` applies to test code. Pre-existing (795 at baseline); this change added 162 lines. | Split the worktree-session handler tests into a dedicated `*.test.ts` file in a separate maintenance change. | The 500-line limit applies to test code per policy; a 957-line suite reduces maintainability. Pre-existing, not introduced by this feature. | `wc -l` = 957; `git show 93d83d5:...` = 795 baseline. |
| Info | `extensions/drm-copilot/test/*`, `package.json` | test framework | Package uses Jest while `.claude/rules/typescript.md` names Vitest. This is the package's pre-existing, established toolchain (`jest`, `ts-jest`, `run-jest.cjs`); the feature did not introduce it. | No action required for this feature; framework alignment is a repo-wide decision outside this scope. | `general-code-change.md` directs use of the established pattern. Recorded for transparency only. | `package.json` devDependencies; `scripts.test = "node run-jest.cjs"`. |
| Info | `extensions/drm-copilot/src/extension.ts` | log note | Output-channel note now records `pre-claude script: emitted|none`; the configured path content is not logged. Matches `spec.md` logging guidance. | None. | Confirms no sensitive content leak in logs. | `extension.ts` diff lines for `preClaudeNote`. |

No Blocker or Major findings.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- The new logic reuses the existing `quoteForPwsh` single-quote escaping helper rather than re-implementing PowerShell quoting, so the spaces/apostrophes handling is consistent with the rest of the command builder.
- The pure-module constraint is respected: existence is checked at PowerShell runtime via `Test-Path`, so `claude-worktree-session.ts` adds no `vscode`/`node:fs`/`node:child_process` import. The undefined/empty/whitespace contract is centralized in the builder, and the handler stays thin.
- Command ordering is precise: the handler sends `commands.preClaude` only when defined, after the optional activate step and before the deferred `claude` send, matching AC6 and the spec's "immediately before claude" requirement. The deferred-claude grace window is preserved.

#### Type safety and maintainability

- New fields are typed `string | undefined`; the configuration read uses `get<string>("preClaudeScriptPath")` with a string default via `??`, so the value passed to the builder is always a string. No `any`, no new `as` assertions in production code, no new suppressions.
- The control flow `input.preClaudeScriptPath?.trim() ?? ""` then `length > 0` correctly collapses undefined, empty, and whitespace-only into the no-command branch.
- Maintainability gap is limited to the oversized handler test file (Minor finding above); the production modules remain small (184 and 301 lines).

#### Error handling and logging

- Failure behavior is explicit and matches the spec: a missing script is intentionally not an error (the `Test-Path` guard short-circuits at runtime); an empty/whitespace configured path emits no command at all.
- The output-channel log note is extended to indicate emission state without logging script content beyond the non-sensitive configured value. No catch-all handlers introduced.

---

## Test Quality Audit

The verification evidence reviewed includes the feature's QA-gate artifacts (final format/lint/typecheck/test-coverage), the coverage-delta artifact, and the machine-readable `coverage/lcov.info`. Coverage, no-regression, and per-file figures are all present. The only gap is the inherent inability of unit tests to exercise the PowerShell-runtime `Test-Path` guard, which is acceptable because the pure builder asserts the exact emitted command string and the runtime behavior is a host concern.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/claude-worktree-session.test.ts` — 5 builder tests covering undefined/empty/whitespace (no command), guarded command for a normal path, and quote escaping for spaces/apostrophes. Exact-string assertions.
- `extensions/drm-copilot/test/extension.workflow-commands.test.ts` — 4 handler tests covering default-applied, ordering with poetry, ordering without poetry, and no-extra-send when empty; uses fake timers to assert the deferred-claude boundary.
- `extensions/drm-copilot/test/extension-test-harness.ts` — adds `getConfiguration` mock and `setPreClaudeScriptPathConfig`, with reset wired into `resetExtensionHarnessState`.
- `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/coverage-delta.md` — proves no regression on changed lines and full coverage of feature-introduced lines.
- `extensions/drm-copilot/coverage/lcov.info` — reviewer-parsed: `claude-worktree-session.ts` 184/184 line, 17/17 branch; `extension.ts` 297/301 line, 30/33 branch.

### Quality assessment prompts

- **Determinism:** Fake timers (`jest.useFakeTimers`/`advanceTimersByTime`) drive the deferred-claude window; no wall-clock or randomness in the new tests.
- **Isolation:** Each test asserts a single emission/ordering behavior; harness state is reset between tests, including `preClaudeScriptPathConfig`.
- **Speed:** Pure builder tests are synchronous; handler tests avoid real waits.
- **Diagnostics:** Exact-string `toBe` assertions on the emitted PowerShell command produce precise failure output.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No secrets added; the configured path is a non-sensitive repo-relative string. |
| No unsafe subprocess or command construction | ✅ PASS | The path is embedded via `quoteForPwsh` (single-quote literal with doubled apostrophes) inside both `Test-Path -LiteralPath` and the call operator; `-LiteralPath` avoids wildcard interpretation. The execution surface matches the existing worktree-session trust model documented in `spec.md`. |
| Input validation at boundaries | ✅ PASS | Undefined/empty/whitespace path collapses to no command; default applied when the setting is unset. |
| Error handling remains explicit | ✅ PASS | Missing script handled by the runtime `Test-Path` guard by design; no silent catch-all. |
| Configuration / path handling is safe | ✅ PASS | Path resolved relative to the worktree root and quoted literally; no shell interpolation of the raw value. |

---

## Research Log

No external research was required. All conclusions are grounded in the branch diff, the feature-folder evidence, the bundled review templates, and the repository policy rule files.

---

## Verdict

The change is ready for normal PR flow with one recommended, non-blocking follow-up. It correctly and minimally implements the configurable pre-`claude` hook, preserves the pure-module separation, reuses existing escaping, orders the command correctly relative to poetry activation and the deferred `claude` send, and is fully covered by deterministic unit tests with no coverage regression. The single Minor finding — the 957-line `extension.workflow-commands.test.ts` file exceeding the 500-line limit — is pre-existing and recommended for a separate maintenance change; it does not affect correctness, security, or coverage. This conclusion is consistent with the Findings Table and the Conditional Go recommendation above.
