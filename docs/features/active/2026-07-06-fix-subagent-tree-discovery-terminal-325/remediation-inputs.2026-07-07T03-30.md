# Remediation Inputs: fix-subagent-tree-discovery-terminal (Issue #325)

**Entry Timestamp:** 2026-07-07T03-30
**Triggering Audit Artifacts:**
- `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/policy-audit.2026-07-07T03-30.md`
- `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/code-review.2026-07-07T03-30.md`
- `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/feature-audit.2026-07-07T03-30.md`

**Trigger reason:** The code review and policy audit each contain Blocking findings identified during independent code inspection, per the `remediation-handoff-atomic-planner` trigger condition "Audit artifacts contain FAIL or meaningful PARTIAL findings" and the `feature-review-workflow` trigger condition "the code review contains blockers." All ten acceptance criteria in `issue.md` pass on their literal wording (see `feature-audit.2026-07-07T03-30.md`); remediation is required for code-quality/policy findings outside the literal AC text, not for unmet acceptance criteria.

---

## Enumerated Fix List

### Fix 1 — Extract `TerminalWriter` seam out of `command-runtime.ts` (file-size limit)

- **File(s):** `extensions/drm-copilot/src/command-runtime.ts` (source of the violation); new file to be created, e.g. `extensions/drm-copilot/src/terminal-writer.ts`
- **Expected behavior:** `extensions/drm-copilot/src/command-runtime.ts` returns to at or under 500 lines. The `TerminalWriter` interface, `SUBAGENT_TREE_TERMINAL_NAME` constant, `PseudoterminalTerminalWriter` class, and `createSubagentTreeTerminalWriter()` factory move into a new, cohesive module. `extensions/drm-copilot/src/subagent-tree-command.ts` updates its import to the new module path. No behavior change — this is a pure extraction/move.
- **Verification commands:**
  - `wc -l extensions/drm-copilot/src/command-runtime.ts` — must report <= 500.
  - `wc -l extensions/drm-copilot/src/terminal-writer.ts` (or chosen new filename) — must report <= 500.
  - `npm run format && npm run lint && npm run typecheck && npm run test:coverage && npm run build` (from `extensions/drm-copilot/`) — all five stages must exit 0 in a single pass.
  - Re-parse `extensions/drm-copilot/coverage/lcov.info` for the relocated code (whichever new filename is chosen) and for `command-runtime.ts`, confirming both remain at or above 85% lines / 75% branches with no regression versus the pre-remediation baseline (`command-runtime.ts` 94.02%/87.10%).
  - Add/update the `jest.config.cjs` `coverageThreshold` entry key to match the new file path.

### Fix 2 — Normalize terminal line endings for multi-line rendering

- **File(s):** `extensions/drm-copilot/src/command-runtime.ts` (or its post-Fix-1 relocated location), `PseudoterminalTerminalWriter.write()`
- **Expected behavior:** Every line break in the emitted content — both the header/body boundary and every internal line break within a multi-line `body` — is a `\r\n`, not a bare `\n`. A tree with multiple rendered lines (e.g. a root session with subagent children) must render as separate, correctly left-aligned lines in a real VS Code integrated terminal, not a diagonal "staircase."
- **Suggested approach:** Normalize once, e.g.:
  ```ts
  write(header: string, body: string): void {
    this.pendingContent = `${header}\r\n${body}`.replace(/\r?\n/g, "\r\n");
    ...
  }
  ```
  (Confirm this does not double up `\r\n` that may already be correctly formed; `\r?\n` matches both bare `\n` and existing `\r\n`, replacing each with a single `\r\n`.)
- **Verification commands:**
  - Add a new unit test in `extensions/drm-copilot/test/command-runtime.test.ts` that calls `writer.write("HEADER", "line1\nline2\nline3")`, captures the emitted `onDidWrite` content, and asserts it equals `"HEADER\r\nline1\r\nline2\r\nline3"` (every line break is `\r\n`, none are bare `\n`).
  - Add or extend a test in `extensions/drm-copilot/test/subagent-tree-command.test.ts` using a fixture that produces a multi-line `formatTree` output (e.g. a root session with at least one subagent), asserting the `FakeTerminalWriter`'s captured `body` matches the expected multi-line joined string (the fake does not need to model CRLF itself, but the production `write()` normalization must be exercised at the `command-runtime.ts` level per the previous bullet).
  - `npm run test:coverage` (from `extensions/drm-copilot/`) — all existing tests (1529) plus the new test(s) must pass; per-file coverage for the touched file must remain at or above 85%/75%.

---

## "Do Not Do" List

- Do not widen scope beyond the two fixes above (no unrelated refactors of `command-runtime.ts`, `subagent-tree-command.ts`, or `workspace-encoding.ts`).
- Do not weaken the `jest.config.cjs` per-file coverage thresholds to accommodate the file split; add a correctly-named entry for the new file instead.
- Do not remove or relax the existing single-line-body tests in `test/command-runtime.test.ts` — add the multi-line test alongside them.
- Do not introduce a new runtime dependency to solve the CRLF-normalization fix; a `String.prototype.replace` with a regular expression is sufficient.
- Do not silently skip re-running the full toolchain loop (`format`, `lint`, `typecheck`, `test:coverage`, `build`) after the fixes; all five stages must pass in a single clean pass per `general-code-change.md`'s "Mandatory Toolchain Loop."
- Do not check off, uncheck, or reword any acceptance-criteria checkbox in `issue.md` as part of this remediation — all ten criteria already evaluate PASS on their literal wording (see `feature-audit.2026-07-07T03-30.md`); this remediation addresses code-quality/policy findings outside the literal AC text.

---

## Pointer to Audit Artifacts

- Full findings and rationale: `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/code-review.2026-07-07T03-30.md` (Findings Table)
- Policy compliance detail: `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/policy-audit.2026-07-07T03-30.md` (§ 2.3 Module & File Structure; § 10 Compliance Verdict)
- Acceptance-criteria cross-reference: `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/feature-audit.2026-07-07T03-30.md` (criterion #5 Notes column)
