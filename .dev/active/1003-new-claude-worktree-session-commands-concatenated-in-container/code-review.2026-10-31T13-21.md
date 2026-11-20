# Code Review: Worktree Session Encoded Delivery (#1003)

---

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003`
**Feature Folder Selection Rule:** Supplied by the caller; it is the only active folder whose suffix matches the branch issue number (1003) and it holds the material scoping-doc changes.
**Base Branch:** `main` (resolved `origin/main`, merge base `c7b2850fda58ef2c80624952e582738b76a546f4`)
**Head Branch:** `bug/new-claude-worktree-session-commands-concatenated-1003` (`0055f3ce131091ae62d7cfa27616f21c3852f674`)
**Review Type:** Initial review

---

## Executive Summary

The branch fixes issue #1003, in which the Claude and Codex worktree-session commands reached a Linux dev-container shell as one concatenated line and failed with a PowerShell `ParserError`. The fix removes all terminal input-stream writes: each session is composed into one fail-fast PowerShell script, encoded as base64 UTF-16LE, and passed at process start through `-NoLogo -NoExit -EncodedCommand`. The terminal is created with `hideFromUser: true` and then shown, which keeps the Python extension from injecting activation text and allows the 5-second `setTimeout` grace period to be deleted. The Windows-only venv activation literal is replaced by a runtime probe shared by both builders. The production delta is 4 TypeScript files (1 new, 244 lines); `extension.ts` shrank from 496 to 448 lines.

Evidence reviewed: the full branch diff, `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, all feature evidence under `evidence/`, `extensions/drm-copilot/coverage/lcov.info` (re-parsed by the reviewer), and reviewer re-runs of Prettier, ESLint, `tsc`, and the six changed Jest suites (114/114 passed). Implementation quality is high: the composition module is pure and small, the scripts avoid constructs that differ between pwsh 7 and Windows PowerShell 5.1, and every requirement in the spec is pinned by a decoded-script assertion.

**What changed:**
- `src/worktree-session-launch.ts` (new): `composeSessionScript` builds `& { $setupSucceeded = $false; try { <banner; step; guard>... $setupSucceeded = $true } catch { red message }; if ($setupSucceeded) { <banner>; <agent> } }`; `encodePowerShellCommand`, `buildEncodedShellArgs` with a 30000-character bound, and per-session wrappers.
- `src/claude-worktree-session.ts`: `VENV_ACTIVATE_COMMAND` runtime probe; `-ErrorAction Stop` on `New-Item` and `Set-Location`.
- `src/codex-worktree-session.ts`: imports the shared probe; same `-ErrorAction Stop` changes.
- `src/extension.ts`: both handlers build `shellArgs` before `createTerminal` (so the length guard fires first), pass `hideFromUser: true`, call `show()`, and no longer call `sendText` or `setTimeout`.
- Tests: new launch-module and Claude handler suites; Codex handler suite rewritten; Claude handler tests removed from `extension.workflow-commands.test.ts` (800 to 369 lines).
- `jest.config.cjs`: four per-file 85/75 threshold entries. README and CHANGELOG updated.

**Top 3 risks:**
1. Runtime behavior in a Linux dev container and on a Windows host is not exercised by any automated test; acceptance rests on decoded-script unit assertions by design (spec `## Test Strategy`). The root-cause mechanism is documented as likely, not reproduced.
2. The `hideFromUser` suppression of Python-extension auto-activation is cited from extension source in the research record and is not verified against the installed extension versions; if a future Python extension version stops honoring it, injected text would arrive after the agent starts.
3. VS Code shell-integration decorations are probably absent in these terminals because `shellArgs` carry `-EncodedCommand`; this is documented in the README and the handlers do not depend on it.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; the toolchain, coverage, and file-size gates pass and were independently re-verified.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003/spec.md` | `## Scope & Non-Goals` (line 67) | The spec states that `quality-tiers.yml` is "absent at the repository root". The file exists on the base branch and classifies `extensions/drm-copilot` as T3. | Correct the parenthetical to state that `quality-tiers.yml` exists and the extension is T3. No gate outcome changes: T3 carries no property-test, mutation, or golden-test obligation, and the escape-hatch limit is not approached. | An inaccurate statement about tier adoption could lead a later reader to skip tier-dependent gates on a T1 or T2 module. | `git ls-tree --name-only c7b2850fda58ef2c80624952e582738b76a546f4 quality-tiers.yml` lists the file; `quality-tiers.yml` line 7-9. |
| Nit | `extensions/drm-copilot/test/claude-worktree-session-command.test.ts` | lines 140-142 | `registers newClaudeWorktreeSession` has no explicit `expect`; it relies on `activateAndGetHandler` throwing when the command is missing. The test was moved verbatim from the base branch. | Optionally add `expect(handler).toEqual(expect.any(Function))` to make the assertion explicit. | Implicit assertions are less clear in failure output. | `git grep` on base: `extension.workflow-commands.test.ts:127-129` contains the same body. |
| Info | `extensions/drm-copilot/src/worktree-session-launch.ts` | `composeSessionScript` | The whole session, including the agent launch, runs inside `& { ... }`. `Set-Location` and the environment and `global:` function changes made by `Activate.ps1` persist after the block, so the interactive end state matches the base behavior, which also invoked `Activate.ps1` with `&`. | None. | Confirms that scoping the helper variable `$setupSucceeded` does not change the post-session prompt state. | Diff of `worktree-session-launch.ts` lines 79-99; base `activate` value `& './.venv/Scripts/Activate.ps1'`. |
| Info | `extensions/drm-copilot/src/extension.ts` | lines 182-199, 267-281 | `buildClaude/CodexSessionShellArgs` is called before `createTerminal`, so an over-length objective rejects the command without creating a terminal; both handler suites assert `createTerminal` is not called in that case. | None. | Prevents an orphaned terminal on the error path. | `claude-worktree-session-command.test.ts:325-337`; `codex-worktree-session-command.test.ts:345-356`. |

No Blocker or Major findings. No covered file is at or above 700 logical lines, so no file-size Warning applies (largest: `jest.config.cjs` at 559; `extension.ts` at 448).

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- The fix addresses the defect class rather than its timing: no text is written to the pty, so cooked-mode `\r` to `\n` translation and shell start-up timing cannot affect delivery.
- `composeSessionScript` is a single loop over a declarative step table, shared by both sessions; conditional steps are omitted by the same `undefined` rule the builders already used, so presence rules are unchanged.
- Fail-fast is implemented with per-step `-ErrorAction Stop` and `$LASTEXITCODE` checks instead of a block-wide `$ErrorActionPreference`, so repository-owned pre/post scripts keep their non-terminating-error semantics, as the spec requires.
- `VENV_ACTIVATE_COMMAND` is defined once and imported by the Codex builder, removing a duplicated literal and avoiding an import cycle with the launch module.
- `extension.ts` lost 48 lines and the `TERMINAL_AUTO_ACTIVATION_GRACE_MS` constant; the log text now states the delivery mechanism.

#### Type safety and maintainability

- All exported functions have explicit parameter and return types; the step and definition interfaces use `readonly` fields and are module-private.
- The launch module imports only types from the builders (`import type`), so it adds no runtime dependency edge.
- No `any`, `eslint-disable`, `@ts-ignore`, or `@ts-expect-error` in changed source or new tests (reviewer grep, 0 matches).
- Banner labels are fixed literals without single quotes; the `banner` TSDoc records that precondition.

#### Error handling and logging

- `buildEncodedShellArgs` throws an `Error` that names the measured encoded length, the limit, and the corrective action ("Shorten the objective and try again."). The handler lets it propagate through the existing command error reporting.
- In the script, the catch block writes `"<Session> session setup failed: $_"` in red, which includes the thrown step message (for example `git worktree add failed with exit code 128`).
- The output-channel log still records only the objective length, not the objective text.

---

## Test Quality Audit

The changed scope is covered by deterministic, in-memory unit tests. Every acceptance criterion that concerns script content is asserted on the decoded `-EncodedCommand` argument, which tests the exact bytes the terminal receives. Coverage, fail-before/pass-after regression, and seeded shuffle evidence are present. No end-to-end terminal test exists, which the spec accepts.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/worktree-session-launch.test.ts` — 15 tests: encoding round trip, `shellArgs` order, 30000 boundary (accept at 30000, reject at 30004), step order, omission, exit-code guards, try/flag/launch structure, red catch message, banner counts (7/4/8/5), forbidden tokens, quoting round trip.
- `extensions/drm-copilot/test/claude-worktree-session-command.test.ts` — 14 handler tests: one hidden terminal, `show` after create, no `sendText`, cwd/shellPath/name, decoded order with and without poetry and pre-claude, blank objective, length guard, cancel, missing runtime, log text.
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts` — 14 handler tests, rewritten from `sendText`/fake-timer assertions to terminal-option and decoded-script assertions; pre-existing executable-resolution tests retained.
- `extensions/drm-copilot/test/claude-worktree-session.test.ts`, `codex-worktree-session.test.ts` — probe text and `-ErrorAction Stop` assertions.
- `evidence/regression-testing/fail-before.2026-10-31T12-58.md` and `pass-after.2026-10-31T13-09.md` — the `hideFromUser`/no-`sendText` handler test and the probe builder test fail on the pre-change tree for the expected reasons and pass after.
- `evidence/regression-testing/jest-shuffle.2026-10-31T13-13.md` — seeds 1003 and 7, 5277/5277 each.
- `evidence/qa-gates/jest-coverage.2026-10-31T13-13.md`, `coverage-comparison.2026-10-31T13-13.md` — figures confirmed by reviewer re-parse of `lcov.info`.
- `evidence/other/ps51-switch-support.2026-10-31T12-54.md` — Windows PowerShell 5.1 executed an `-EncodedCommand` probe (`ps51-encoded-ok 5`) and lists `-NoLogo`, `-NoExit`, `-EncodedCommand`.

### Quality assessment prompts

- **Determinism:** no timers, fake timers, wall-clock reads, temp files, or new `process.platform` branches; shuffled runs pass.
- **Isolation:** each test asserts one behavior; the pure module is tested without mocks.
- **Speed:** the six suites (114 tests) ran in one reviewer invocation without timeouts.
- **Diagnostics:** `expectInOrder` reports the specific missing or out-of-order needle.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no credentials, tokens, or keys. |
| No unsafe subprocess or command construction | ✅ PASS | User-controlled values (paths, branch, objective, script paths) pass through the existing `quoteForPwsh` single-quote escaping before entering the script; the script reaches the shell as base64, which contains no spaces or quotes. Quote and apostrophe round trip is tested. |
| Input validation at boundaries | ✅ PASS | Encoded length bounded at 30000 characters, below the Windows `CreateProcess` 32,767-character limit, checked before terminal creation. |
| Error handling remains explicit | ✅ PASS | Native exit codes and cmdlet failures become terminating errors inside the guarded block; the agent does not launch after a setup failure. |
| Configuration / path handling is safe | ✅ PASS | Venv layout is probed with `Test-Path -LiteralPath`; probe throws a specific message when neither script exists. Settings keys and defaults are unchanged. |
| PowerShell 5.1 / 7 compatibility | ✅ PASS | No `&&`, `||`, `$IsWindows`, or `$ErrorActionPreference` in either composed script (tested); PS 5.1 switch support verified on the executor host. |

---

## Research Log

No external research was performed during this review. The design relies on the research record `research/research.2026-10-30T11-30.md` (VS Code `TerminalInstance.sendText` and `TerminalProcessManager.write`, .NET `KeyParser`, PSReadLine key tables, microsoft/vscode-python `activation.ts`). The reviewer checked that the implementation matches the research option (d) adopted by the spec; the cited upstream behavior was not re-fetched.

---

## Verdict

The change is ready for normal PR flow. It replaces input-stream delivery with process-start delivery for both worktree-session commands, preserves step order and conditional presence rules, adds fail-fast setup with explicit failure output, and is fully covered by deterministic tests (new module 100% lines and branches; changed handler bodies with no unexecuted lines). The toolchain is clean and was re-verified by the reviewer.

The findings are one Minor documentation inaccuracy in `spec.md` about `quality-tiers.yml` and one Nit on a moved assertion-free test; neither blocks merge. Runtime confirmation in a Linux dev container remains an optional post-merge check as stated in the spec, and the CI matrix (`ubuntu-latest`, `windows-latest`) on the PR head remains the responsibility of the orchestrator's CI green gate.
