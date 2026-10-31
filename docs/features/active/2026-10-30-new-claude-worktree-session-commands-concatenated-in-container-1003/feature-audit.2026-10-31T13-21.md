# Feature Audit: Worktree Session Encoded Delivery (#1003)

---

**Audit Date:** 2026-10-31
**Feature Folder:** `docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003`
**Base Branch:** `main`
**Head Branch:** `bug/new-claude-worktree-session-commands-concatenated-1003`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main`, resolved `origin/main` (commit `c7b2850fda58ef2c80624952e582738b76a546f4`)
- **Head branch/commit:** `bug/new-claude-worktree-session-commands-concatenated-1003` (commit `0055f3ce131091ae62d7cfa27616f21c3852f674`)
- **Merge base:** `c7b2850fda58ef2c80624952e582738b76a546f4`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-31 13:18 UTC, head SHA matches)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003/evidence/**`
  - Additional evidence: `extensions/drm-copilot/coverage/lcov.info` (re-parsed by the reviewer); reviewer re-runs of `npx prettier --check`, `npx eslint`, `npm run typecheck`, and `node run-jest.cjs` on the six changed suites (114/114 passed); `git diff` inspection of the full range
- **Feature folder used:** `docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` line 12 carries the explicit marker `- Work Mode: full-bug`, so `spec.md` `## Acceptance Criteria` is the only AC source.
- **Scope note:** Full feature-vs-base diff (40 files). PR-context artifacts were current for the head SHA and were not regenerated.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003/spec.md` — only source

### Acceptance criteria

1. Neither `newClaudeWorktreeSession` nor `newCodexWorktreeSession` calls `Terminal.sendText` for setup or for the agent launch; a handler test asserts `sendText` is never called for each.
2. Each handler calls `vscode.window.createTerminal` exactly once, with `hideFromUser: true`, the expected `cwd` and `shellPath`, and `shellArgs` equal to `-NoLogo`, `-NoExit`, `-EncodedCommand`, followed by one encoded argument, in that order; `terminal.show()` is called once after creation.
3. The encoded argument decodes (base64, UTF-16LE) to a single script that contains the Claude steps in the order `ensureParentDirectory`, `git`, `setLocation`, `poetryInstall`, `activate`, `preClaude`, then the `claude` launch, with `poetryInstall` and `activate` present only when the workspace uses poetry, `preClaude` present only for a non-empty configured path, and the objective present only when non-blank.
4. The Codex script decodes to the steps in the order `ensureParentDirectory`, `git`, `setLocation`, `trustCodexProject`, `poetryInstall`, `activate`, `postCodex`, then the `codex` launch, with each conditional step present or absent under the same rules as before the change.
5. The composed script checks `$LASTEXITCODE` and throws after the `git worktree add` step and after the `poetry install --with dev` step, and `New-Item` and `Set-Location` carry `-ErrorAction Stop`.
6. The composed script launches the agent only after the setup `try` block completes without a caught error, and a setup failure writes a red step-failure message instead of launching the agent; a test asserts the launch statement is positioned after the guarded block.
7. The composed script contains a `Write-Host` banner for each emitted step.
8. The script avoids `&&`, `||`, and `$IsWindows`, and does not set a block-wide `$ErrorActionPreference`, so it is valid on pwsh 7 and Windows PowerShell 5.1.
9. The venv activation probe text (both candidate paths `./.venv/Scripts/Activate.ps1` and `./.venv/bin/Activate.ps1`, the `throw` message, and the `&` invocation) appears in the `activate` value returned by both the Claude and Codex builders, and is defined once in `claude-worktree-session.ts` and imported by `codex-worktree-session.ts`.
10. The length guard throws an `Error` before `createTerminal` when the encoded argument is longer than 30000 characters, and does not throw when it is exactly 30000 characters; a handler test asserts `createTerminal` is not called when the guard throws.
11. Paths and objectives that contain spaces, double quotes, and apostrophes survive encoding and decode to correctly quoted script text.
12. `TERMINAL_AUTO_ACTIVATION_GRACE_MS` and both `setTimeout` calls are removed from `extension.ts`, no handler test uses fake timers for the agent launch, and the output-channel log text no longer mentions a deferred send.
13. The cancelled-prompt, missing-powershell-runtime, and unresolved-Codex-executable paths behave as before and still do not create a terminal.
14. `worktree-session-launch.ts`, `claude-worktree-session.ts`, and `codex-worktree-session.ts` contain no `vscode`, `node:fs`, or `node:child_process` imports.
15. `extensions/drm-copilot/jest.config.cjs` has `coverageThreshold` entries with lines 85 and branches 75 for `./src/worktree-session-launch.ts`, `./src/claude-worktree-session.ts`, and `./src/codex-worktree-session.ts`, and Jest with coverage meets them.
16. Coverage of the changed lines in `extension.ts` is not lower than the recorded baseline, with baseline and post-change figures recorded from `coverage/lcov.info`.
17. Test-suite results are stable: a seeded shuffled Jest run passes, and the new tests create no temporary files and do not branch on `process.platform` except through the existing Codex executable helper.
18. `extension.workflow-commands.test.ts` has no more than 800 logical lines, `extension.ts` has no more than 500 logical lines, and no other changed or new file exceeds 800 lines.
19. The Claude handler tests are located in `claude-worktree-session-command.test.ts`, and the moved tests are no longer present in `extension.workflow-commands.test.ts`.
20. A fail-before record shows that the no-`sendText` and `hideFromUser: true` handler test and the activation-probe builder test fail on the pre-change tree and pass after the change.
21. `extensions/drm-copilot/README.md` `## New Claude Worktree Session` describes single-script delivery, `hideFromUser`, fail-fast behavior, and per-step banners, and no longer says commands are sent individually.
22. `extensions/drm-copilot/CHANGELOG.md` has a `### Fixed` bullet under `## [Unreleased]` for issue #1003 that records the fail-fast behavior change; `package.json` version is unchanged.
23. No file in `scripts/dev-tools/activate.ps1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1`, the `resources/templates` mirror, `.claude/rules/`, `.github/instructions/`, or the execution-environment brief is modified, and `quality-tiers.yml` is not created.
24. The full TypeScript toolchain (Prettier, ESLint, `tsc`, and Jest with coverage through `node run-jest.cjs`) passes in a single pass with no errors.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | No `sendText` in either handler; tests assert it | PASS | `extension.ts` contains no `sendText` (reviewer grep, 0 matches). `claude-worktree-session-command.test.ts:137` and `codex-worktree-session-command.test.ts:82` assert `sendText` not called. | `grep -nE 'setTimeout\|TERMINAL_AUTO_ACTIVATION_GRACE_MS\|sendText' src/extension.ts`; `node run-jest.cjs <suites>` | 114/114 passed in reviewer run. |
| 2 | One `createTerminal` with `hideFromUser`, cwd, shellPath, ordered shellArgs; `show()` once after | PASS | Claude tests lines 113-138 and 170-200 assert call count 1, `hideFromUser: true`, `cwd` `C:/workspace`, `shellPath` `pwsh`, `shellArgs` length 4 with the three switches first, `show` once with invocation order after create. Codex suite asserts the same through its shared helper (lines 60-82). | `node run-jest.cjs test/claude-worktree-session-command.test.ts test/codex-worktree-session-command.test.ts` | |
| 3 | Claude decoded script order and conditional presence | PASS | `worktree-session-launch.test.ts:149-182` (order and omission); handler tests for poetry on/off, non-poetry pyproject, default/configured/empty pre-claude, blank objective (`claude-worktree-session-command.test.ts:170-323`). | `node run-jest.cjs test/worktree-session-launch.test.ts` | |
| 4 | Codex decoded script order and conditional presence | PASS | `worktree-session-launch.test.ts:319-349`; Codex handler tests for full script, poetry, default post path, blank post and objective. | same | |
| 5 | `$LASTEXITCODE` guards after git and poetry; `-ErrorAction Stop` on `New-Item` and `Set-Location` | PASS | `GIT_EXIT_CODE_GUARD` and `POETRY_EXIT_CODE_GUARD` in `worktree-session-launch.ts`; test lines 184-206; builder diffs add `-ErrorAction Stop` to both commands in both builders; handler test line 193 asserts the `New-Item ... -ErrorAction Stop` text. | diff inspection; Jest | |
| 6 | Launch only after successful `try`; red failure message; positional test | PASS | `composeSessionScript` gates launch on `$setupSucceeded`; catch writes `-ForegroundColor Red`; tests lines 208-250 assert ordering and the catch text. | Jest | |
| 7 | `Write-Host` banner per emitted step | PASS | Banner counts 7/4/8/5 for full/minimal Claude/Codex and banner order asserted (test lines 252-273). | Jest | |
| 8 | No `&&`, `||`, `$IsWindows`, block-wide `$ErrorActionPreference` | PASS | Test lines 275-289 on both full scripts; PS 5.1 accepted `-NoLogo -NoExit -EncodedCommand` (`evidence/other/ps51-switch-support.2026-10-31T12-54.md`). | Jest; `powershell.exe -NoLogo -NoProfile -EncodedCommand <probe>` (executor) | |
| 9 | Probe text in both builders; defined once and imported | PASS | `VENV_ACTIVATE_COMMAND` exported from `claude-worktree-session.ts`, imported in `codex-worktree-session.ts`; `grep -rl "bin/Activate.ps1" src` lists only the Claude builder (`evidence/qa-gates/static-checks.2026-10-31T13-14.md`); builder tests assert both paths, the throw message, and `& $venvActivate`. | diff inspection; static-check grep | |
| 10 | Length guard: throws above 30000, accepts 30000, before `createTerminal` | PASS | `buildEncodedShellArgs` uses `>`; tests at 30000 (accept) and 30004 (reject); handler tests in both suites assert `createTerminal` not called. `shellArgs` are built before `createTerminal` in both handlers. | Jest | |
| 11 | Spaces, double quotes, apostrophes survive encoding | PASS | Test lines 291-315 decode and assert `''`-escaped paths and objective with `"auth"` and `don''t`. | Jest | |
| 12 | Grace constant and `setTimeout` removed; no fake timers; log text updated | PASS | Reviewer grep on `extension.ts`: 0 matches; `useFakeTimers` count 0 in both handler suites; log tests assert `-EncodedCommand` present and `deferred` absent. | grep; Jest | |
| 13 | Cancel, missing runtime, unresolved Codex executable create no terminal | PASS | Claude tests 144-168; Codex tests 243-281 and 330-343 assert `createTerminal` not called. | Jest | |
| 14 | Pure modules have no `vscode`, `node:fs`, `node:child_process` imports | PASS | Static-check counts 0 for all three; diff shows only `import type` from builders in the launch module. | `grep -c -e 'from "vscode"' ...` (executor); diff inspection | |
| 15 | Per-file thresholds 85/75 for the three modules and Jest meets them | PASS | `jest.config.cjs` diff adds the three entries plus `./src/extension.ts`; lcov: launch 100/100, Claude 100/95, Codex 100/100; no `coverage threshold` failure line. | `npm run test:coverage` (executor); reviewer `lcov-check.cjs` | |
| 16 | Changed-line coverage in `extension.ts` not below baseline | PASS | Baseline handler bodies 0 zero-hit of 101 and 88; post 0 of 72 and 75. Uncovered totals unchanged (13 lines, 6 branches), all outside handler bodies (reviewer: zero-hit DA 91-92, 319-325, 360-361, 367-368). | reviewer `lcov-check.cjs`; `evidence/qa-gates/coverage-comparison.2026-10-31T13-13.md` | |
| 17 | Shuffled run passes; no temp files; no new `process.platform` branching | PASS | Seeds 1003 and 7 pass 5277/5277; temp-file and platform greps 0 in new suites, 2 pre-existing in the Codex suite. | `node run-jest.cjs --randomize --seed=1003` (executor) | |
| 18 | File-size limits | PASS | Reviewer counts: `extension.workflow-commands.test.ts` 369, `extension.ts` 448, largest other changed covered file `jest.config.cjs` 559. | `awk 'END{print NR}' <file>` | |
| 19 | Claude handler tests moved | PASS | `claude-worktree-session-command.test.ts` holds 14 Claude handler tests; `newClaudeWorktreeSession` count 0 in `extension.workflow-commands.test.ts`. | static-check grep | |
| 20 | Fail-before / pass-after record | PASS | `evidence/regression-testing/fail-before.2026-10-31T12-58.md` (2 failed for the expected reasons) and `pass-after.2026-10-31T13-09.md`. | `node run-jest.cjs ... -t "emits the runtime venv activation probe\|creates one hidden terminal and never calls sendText"` | |
| 21 | README describes delivery, `hideFromUser`, fail-fast, banners; no individual-send text | PASS | README diff adds "How the session is delivered" with all four topics and rewrites "no additional command is sent". | diff inspection | |
| 22 | CHANGELOG `### Fixed` bullet under `## [Unreleased]` with fail-fast note; `package.json` unchanged | PASS | Bullet sits under `### Fixed` (line 35) of `## [Unreleased]` (line 8), before `## [0.0.1]` (line 58), and states the fail-fast change. `package.json` not in the diff. | `grep -n '^#' CHANGELOG.md`; `git diff --stat <range> -- extensions/drm-copilot/package.json` | |
| 23 | Out-of-scope files untouched; `quality-tiers.yml` not created | PASS | `git diff --stat` over `scripts/dev-tools`, `.claude`, `.github`, `extensions/drm-copilot/resources`, `quality-tiers.yml`, `config` is empty. `quality-tiers.yml` already exists on base and is unchanged. | `git diff --stat c7b2850f..HEAD -- <paths>` | The spec's statement that `quality-tiers.yml` is absent is inaccurate (Minor finding in code review); the criterion itself is met. |
| 24 | Full TypeScript toolchain passes in one pass | PASS | Executor pass 2 clean (Prettier, ESLint, tsc, Jest with coverage); reviewer re-runs clean. | `npx prettier --check`; `npm run lint`; `npm run typecheck`; `npm run test:coverage` | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 24 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the `drm-copilot Extension Tests` CI job passes on `ubuntu-latest` and `windows-latest` for the PR head (orchestrator CI green gate).
2. Optional post-merge: run `drm-copilot: New Claude Worktree Session` and the Codex variant in a Linux dev container and on a Windows host, as stated in `spec.md` `## Rollout & Follow-up`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003/spec.md`
- Total AC items: 24
- Checked off (delivered): 24
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003/spec.md` | 24 | 24 | 0 | Checkbox-backed |

No source-file checkbox change was made in this review: all 24 criteria were already checked off by the executor, and each was independently evaluated as PASS above.
