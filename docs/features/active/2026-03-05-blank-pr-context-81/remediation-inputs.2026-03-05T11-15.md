# Remediation Inputs — blank-pr-context-81 (2026-03-05T11-15)

## Required fixes

1. **Enforce placeholder rejection on actual command-path artifact output (unit test layer)**
   - **File:** `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts`
   - **Location:** around `fails_when_summary_is_placeholder_only` (`~373-406`)
   - **Current problem:** assertions only validate helper behavior using hardcoded strings, not output produced by the command execution flow.
   - **Expected behavior:** test should fail when mocked command output represents placeholder-only artifact content and pass when output contains substantive sections.
   - **Acceptance criteria impacted:** AC #4 directly; AC #1 indirectly.
   - **Verification commands:**
     - `cd extensions/scaffold-extension && npm run test`
     - Targeted expectation: altered placeholder-output fixture causes failing assertion if content is placeholder-only.

2. **Strengthen integration assertion from line-count to substantive-content checks**
   - **File:** `extensions/scaffold-extension/test/extension.integration.test.ts`
   - **Location:** around placeholder fixture writes and assertions (`~363-393`)
   - **Current problem:** placeholder fixture strings pass because test only checks `split(...).length > 1`.
   - **Expected behavior:** assert for meaningful structural markers (e.g., `## Base/Head`, `## Changed files`, `## Numstat`) and explicitly reject placeholder-only pattern.
   - **Acceptance criteria impacted:** AC #4 and AC #1.
   - **Verification commands:**
     - `cd extensions/scaffold-extension && npm run test`
     - Optional targeted run: `node run-jest.cjs test/extension.integration.test.ts`

3. **Close feature-audit AC #6 with explicit evidence or mark scoped deferment**
   - **File:** `docs/features/active/2026-03-05-blank-pr-context-81/feature-audit.<new-timestamp>.md`
   - **Location:** criterion row #6
   - **Current problem:** manual destination-workspace repro not executed in this review session.
   - **Expected behavior:** either (a) run and record manual destination-workspace verification on Windows host, or (b) formally defer with explicit owner/date and rationale.
   - **Acceptance criteria impacted:** AC #6.
   - **Verification commands/tasks:**
     - In extension host, run `drm-copilot: Collect PR Context` in a destination repo and verify generated artifacts are substantive.

## Do Not Do

- Do **not** broaden scope into branch-discovery redesign or new command IDs.
- Do **not** weaken policy/tooling gates (no suppression creep, no check-skipping).
- Do **not** leave placeholder fixture content accepted by integration assertions.
- Do **not** silently alter artifact paths (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`).

## Unmet acceptance criteria and minimum required changes

- **AC #4 (PARTIAL):**
  - Minimum change: ensure regression tests verify actual command-path generated artifact quality and reject placeholder-only output deterministically.
- **AC #6 (UNVERIFIED):**
  - Minimum change: provide new verification evidence from manual Windows-host destination-workspace run, or document explicit approved deferment.
