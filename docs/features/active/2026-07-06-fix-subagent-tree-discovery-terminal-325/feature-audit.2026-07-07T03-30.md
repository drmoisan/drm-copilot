# Feature Audit: fix-subagent-tree-discovery-terminal (Issue #325)

**Audit Date:** 2026-07-07
**Feature Folder:** `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325`
**Base Branch:** `main`
**Head Branch:** `bug/fix-subagent-tree-discovery-terminal-325`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `4db27ebed2bde1919eda5991ff0de938204aef03`)
- **Head branch/commit:** `bug/fix-subagent-tree-discovery-terminal-325` (commit `f13414af56995c8b64d471e7f749f07f54b48e5d`)
- **Merge base:** `4db27ebed2bde1919eda5991ff0de938204aef03` (independently confirmed via `git merge-base HEAD main`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (fresh — base/head/merge-base match current git state exactly)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/**`
  - Additional evidence: direct `git diff main...HEAD`, independent toolchain re-execution, direct parsing of `extensions/drm-copilot/coverage/lcov.info`, and a live directory listing of `~/.claude/projects/` on the audit host
- **Feature folder used:** `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325`
- **Requirements source:** `issue.md` (`## Acceptance Criteria` section only, per `minor-audit` work mode)
- **Work mode resolution note:** `issue.md` line 10 states `- Work Mode: minor-audit` explicitly; no fallback resolution was needed.
- **Scope note:** This is a single-version (non-versioned) active feature folder; no `v1/`/`v2/` selection was required. The audit covers the full branch-vs-`main` diff (single commit `f13414a`), not any plan-subset narrowing. No caller instruction attempted to narrow scope (see `policy-audit.2026-07-07T03-30.md` → `## Rejected Scope Narrowing`).

---

## Acceptance Criteria Inventory

**Authoritative AC source file for this run:**
- `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/issue.md` — only source (work mode `minor-audit`)

### Acceptance criteria

1. Transcript discovery resolves the user-global Claude projects directory (`~/.claude/projects/`, honoring a home-dir / CLAUDE config dir override) rather than globbing `<repo>/.claude/projects/`.
2. Candidate discovery is narrowed to the encoded directory name for the current workspace path (separators and `:` replaced by `-`), verified against on-disk examples, and includes per-worktree sibling folders.
3. Existing selection behavior is preserved: flattened `/subagents/` transcripts are excluded, a single candidate auto-selects, multiple candidates prompt via quick-pick.
4. The zero-candidates error message names the real user-global search location.
5. The rendered tree (existing header line plus full `formatTree` output) is written to an integrated VS Code terminal, and the terminal is revealed.
6. The terminal uses a stable, recognizable name and repeated runs reuse/replace a single named terminal rather than accumulating terminals.
7. Genuine errors (failures, zero-candidates, user-cancel) still route to the error path (`showErrorMessage` / diagnostic sink), not solely to the terminal.
8. The pure module boundary is preserved: `extensions/drm-copilot/src/lib/subagent-tree/` contains no `vscode` imports and `formatTree` remains a pure string renderer; filesystem-root resolution and terminal wiring live in the host-bound command file or behind injectable seams.
9. The command remains testable without a live VS Code host: the terminal factory is injected the same way the FileSystem seam is, and unit tests assert on captured terminal output.
10. The extension toolchain passes: `npm run format`, `lint`, `typecheck`, `test:coverage`, `build`. Per-file coverage meets lines >= 85% and branches >= 75%; no production file is excluded from coverage.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Transcript discovery resolves the user-global Claude projects directory | PASS | `src/command-runtime.ts` `getClaudeProjectsRoot()` resolves `CLAUDE_CONFIG_DIR`/`HOME`/`USERPROFILE`, honoring an injectable `env` override; `src/subagent-tree-command.ts` calls it instead of globbing `workspaceRoot`. Tested in `test/command-runtime.test.ts` (`describe("getClaudeProjectsRoot")`, 5 cases) and `test/subagent-tree-command.test.ts` ("resolves candidates from the user-global Claude projects directory rather than the workspace root"). | `npm run test -- command-runtime.test.ts subagent-tree-command.test.ts` (independently re-run as part of full `npm run test`, 1529/1529 pass) | None. |
| 2 | Candidate discovery narrowed to encoded workspace directory incl. worktree siblings | PASS | `src/lib/subagent-tree/workspace-encoding.ts` (`encodeWorkspacePath`, `matchEncodedDirectories`); rule confirmed against real on-disk directory names in `evidence/other/encoding-rule-confirmation.2026-07-07T02-50.md`, independently re-confirmed by this audit via `ls ~/.claude/projects/ \| grep drm-copilot-wt-2026-07-06-22-28` on the live audit host (directory present as claimed). Tested in `test/lib/subagent-tree/workspace-encoding.test.ts` (6 cases incl. case-insensitive drive letter, worktree sibling, nested worktree-of-a-worktree). | `ls ~/.claude/projects/` (live verification, this audit); `npm run test` | None. |
| 3 | Existing selection behavior preserved | PASS | `discoverRootSessionCandidates` filter/sort logic and `selectRootSession` prompting logic carried over from the pre-existing implementation. Tested: "auto-selects a single discovered root session without prompting", "prompts via showQuickPick among multiple candidates...", "excludes flattened /subagents/ transcripts from candidates". | `npm run test` | None. |
| 4 | Zero-candidates error names real search location | PASS | `selectRootSession`'s zero-candidates branch constructs `` `No root session transcripts found under ${claudeProjectsRoot}.` `` instead of the old literal glob string. Tested: "names the real resolved user-global search location in the zero-candidates error message" (asserts message contains the resolved root and does not contain the old literal). | `npm run test` | None. |
| 5 | Rendered tree written to terminal and revealed | PASS | `registerSubagentTreeCommand` routes `header` + `formatTree(tree)` to `terminalWriter.write(...)` and calls `terminalWriter.reveal()`. Tested: "writes the header plus full formatTree output to the terminal seam and reveals it". | `npm run test` | **Quality caveat (not an AC failure on literal wording):** `code-review.2026-07-07T03-30.md` identifies a Blocking defect — `PseudoterminalTerminalWriter.write()` does not normalize internal `\n` line breaks within a multi-line body to `\r\n`, which will visibly corrupt real-terminal rendering for any tree with more than one line. The literal criterion text ("is written... and the terminal is revealed") is satisfied — the write and reveal calls do occur with the correct content string — but the *quality* of that rendering in a live terminal is compromised. This criterion is evaluated PASS strictly on its literal wording; the rendering defect is tracked as a Blocking code-review finding and a remediation-inputs item, not as an AC failure, to keep AC evaluation evidence-first and not over-interpret unwritten requirements into a checkbox. |
| 6 | Stable terminal name; reuse/replace single terminal | PASS | `SUBAGENT_TREE_TERMINAL_NAME = "drm-copilot: Subagent Tree"`; `PseudoterminalTerminalWriter` reuses the live terminal or replaces an exited one; the writer instance is constructed once at command-registration time. Tested: "reuses the same terminal across repeated writes while it remains open", "creates a replacement terminal once the previous terminal has exited", "reuses the same terminal-writer instance across two consecutive invocations". | `npm run test` | None. |
| 7 | Genuine errors still route to the error path | PASS | The zero-candidates, user-cancel, and generic-failure paths all call `output.appendLine`/`showErrorMessage` and never `terminalWriter.write`. Tested: "routes a discovery failure to the error path and does not write to the terminal seam", "names the real resolved user-global search location..." (also asserts zero writes), "routes a user-cancel selection to the output log and does not write to the terminal seam". | `npm run test` | Minor code-review observation: no dedicated test for a `getClaudeProjectsRoot()`-throws failure specifically (only `getWorkspaceRoot()`-throws is tested), though the code path is identical; does not affect this criterion's PASS status. |
| 8 | Pure module boundary preserved | PASS | `src/lib/subagent-tree/workspace-encoding.ts` has no `vscode` import (confirmed both by the new `test/lib/subagent-tree/module-boundary.test.ts` static scan and by direct manual reading of the file's imports during this audit). `formatTree` (`src/lib/subagent-tree/tree-formatter.ts`) is unchanged, remains a pure string renderer. | `npm run test` (module-boundary.test.ts); manual `git diff main...HEAD -- extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts` inspection (this audit) | None. |
| 9 | Testable without a live VS Code host | PASS | `registerSubagentTreeCommand` options extend with `createFileSystem?`/`createTerminalWriter?`, both optional with real-implementation defaults, mirroring the pre-existing `FileSystem` injection pattern. Every scenario in `test/subagent-tree-command.test.ts` injects `InMemoryFileSystem` and `FakeTerminalWriter` and asserts directly on captured `writes`/`revealCallCount`. | `npm run test` | None. |
| 10 | Toolchain passes; per-file coverage thresholds met; no exclusion | PASS | Independently re-run by this audit: `npx prettier --check` (equivalent to `npm run format`) clean; `npm run lint` clean (0 errors/warnings); `npm run typecheck` clean (0 errors); `npm run test` 133/133 suites, 1529/1529 tests pass; `npm run build` clean. Coverage inspected (not regenerated) from `extensions/drm-copilot/coverage/lcov.info`: `command-runtime.ts` 629/669 lines (94.02%) / 81/93 branches (87.10%); `subagent-tree-command.ts` 179/179 (100.00%) / 18/19 (94.74%); `workspace-encoding.ts` 64/64 (100.00%) / 4/4 (100.00%) — all above 85%/75%. `jest.config.cjs`'s `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` excludes no production `.ts` file. | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`; `npm run lint`; `npm run typecheck`; `npm run test`; `npm run build` (all independently re-run by this audit, 2026-07-07) | This criterion's literal wording covers toolchain + per-file coverage + no exclusion only; it does not reference the repository-wide 500-line file-size limit. The `command-runtime.ts` file-size violation (669 lines) is a separate General Code Change Policy finding (`policy-audit.2026-07-07T03-30.md` § 2.3), not a failure of this specific AC. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 10 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

All ten acceptance criteria are satisfied on their literal wording, independently re-verified against the branch diff, toolchain output, and coverage artifacts. However, the overall feature readiness verdict is **NEEDS REVISION**, not PASS, because `code-review.2026-07-07T03-30.md` and `policy-audit.2026-07-07T03-30.md` identify two Blocking findings outside the literal AC text that must be resolved before this branch is ready to merge:

**Top gaps preventing PASS:**

1. `extensions/drm-copilot/src/command-runtime.ts` exceeds the repository's 500-line file-size limit (669 lines; limit 500) — a `general-code-change.md` Blocking finding, worsened (not introduced) by this feature's +138-line addition to an already-over-limit file.
2. `PseudoterminalTerminalWriter.write()` does not normalize internal newlines within a multi-line body to `\r\n`, which will corrupt real-terminal rendering for any tree with subagent children — a code-quality Blocking finding tied to AC #5's underlying intent, tracked separately from the AC's literal-wording PASS.

**Recommended follow-up verification steps:**

1. After remediation extracts the terminal-writer seam into its own module and file sizes are re-verified under 500 lines, re-run `npm run format`/`lint`/`typecheck`/`test:coverage`/`build` and re-parse `coverage/lcov.info` to confirm no coverage regression on the relocated code.
2. After the CRLF-normalization fix, add and run a unit test asserting a multi-line body is emitted with `\r\n` between every line, and re-run the full suite to confirm no regression in the existing single-line-body assertions.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules, all ten criteria evaluate PASS on their literal wording and are already checked (`- [x]`) in `issue.md` from the executor's own Phase 1 verification (`evidence/other/ac-verification.2026-07-07T03-09.md`, P1-T18). This audit independently re-verified each criterion against the current branch state and confirms no checkbox change is required.

### AC Status Summary

- Source: `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/issue.md`
- Total AC items: 10
- Checked off (delivered): 10
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/issue.md` | 10 | 10 | 0 | Checkbox-backed; all ten already checked prior to this audit and independently re-verified PASS. No AC checkbox changes made by this audit. |

**Note:** Despite full AC PASS, the overall feature readiness verdict is NEEDS REVISION due to two Blocking findings recorded in `code-review.2026-07-07T03-30.md` and `policy-audit.2026-07-07T03-30.md` that fall outside the literal AC text (file-size limit, terminal CRLF normalization). See `remediation-inputs.2026-07-07T03-30.md` for the required remediation task list.
