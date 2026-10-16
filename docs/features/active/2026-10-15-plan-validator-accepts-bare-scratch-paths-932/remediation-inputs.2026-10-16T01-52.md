# Remediation Inputs: plan-validator-accepts-bare-scratch-paths (Issue #932)

Review-Verdict: REMEDIATION_REQUIRED

- Review timestamp: 2026-10-16T01-52 (UTC)
- Base: `origin/main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
- Head: `eaabea814519c1ada33121870fb8a00cb3433350`
- Summary: one autonomous finding requires remediation; five related items are recommended for the same cycle.

## Source artifacts

- policy-audit-path: docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/policy-audit.2026-10-16T01-52.md
- code-review-path: docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/code-review.2026-10-16T01-52.md
- feature-audit-path: docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/feature-audit.2026-10-16T01-52.md
- PR context: artifacts/pr_context.summary.txt, artifacts/pr_context.appendix.txt (Head SHA `eaabea814`)

## Remediation-required findings

### RF-1 Plan task [P3-T6] unmet: ESLint no-undef in jest.config.cjs (code-review CR-1, policy audit PA-1)

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the cause is a repository ESLint configuration gap that an in-repository config edit resolves; no operator decision, external service, or CI result is needed.
- Facts:
  - `plan.2026-10-15T15-45.md:203-205`: `[P3-T6]` is unchecked; its command lints `jest.config.cjs` together with six TypeScript files and requires exit 0.
  - `npx eslint jest.config.cjs` (package `extensions/drm-copilot`) reports `2:1 error 'module' is not defined no-undef`.
  - The merge-base content of the file produces the identical diagnostic, so the defect is pre-existing; `eslint.config.mjs:4-21` declares no CommonJS or Node globals; the `lint` script (`package.json:208`) lints only `src` and `test`.
  - This item modifies `jest.config.cjs` (+6 lines), so the file is in the changed set.
- Required remediation:
  1. Add a block to `extensions/drm-copilot/eslint.config.mjs` with `files: ["**/*.cjs"]` and `languageOptions: { sourceType: "commonjs", globals: { module: "writable", require: "readonly", __dirname: "readonly", process: "readonly" } }`. Do not edit `jest.config.cjs` (recorded concurrency restriction) and add no dependency.
  2. Run the format, lint, type-check, and jest stages for `extensions/drm-copilot` and confirm that the repository `lint` script still exits 0.
  3. Rerun the `[P3-T6]` command exactly as written; record a new `evidence/regression-testing/ts-lint-phase3.<timestamp>.md` with `EXIT_CODE: 0`; check off `[P3-T6]`.

## Related items to fix in this cycle (Severity: Non-blocking)

- CR-2: remove or re-document the unreachable heading and task-line checks in the continuation predicate (`scripts/dev_tools/plan_gate_scratch.py:83-85`, `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts:111-114`), and make the `heading` / `task-line` stop fixtures (`tests/scripts/dev_tools/test_plan_gate_scratch.py:98-99`, `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts:70-71`) claim only what they prove. Apply the same choice in both runtimes.
- CR-3: update `.claude/rules/plan-acceptance-gates.md:15` (rules described as command-only and fed by the extractor) and `:289` (`evaluates G1 through G6`) to reflect G1-G9 plus document-level G10; copy byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`. Within the operator approval recorded for this item.
- CR-4: align line splitting between `plan_gate_scratch.py:120` (`splitlines()`) and `plan-gate-scratch.ts:76-85` (`/\r\n|\n|\r/`) for `\v`, `\f`, `\x1c`-`\x1e`, `\x85`, ` `, ` `, and add a form-feed fixture with a frozen expected result to both suites; or record the limitation in NFR-2 and the rule file.
- CR-5: document in the rule file's G10 false-negative list (and bundle copy) that any `issue-<digits>` token after the definition accepts the line, including a cross-reference such as `(see issue-900 ...)`.
- CR-6: delete the stale duplicate `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/research/bare-scratch-plan-gate.2026-10-15T19-52.md`.
- Optional (CR-7, Info): convert the fixture tables in `plan-gate-scratch.test.ts:169-228` to `it.each`.

## Pending CI (not a remediation item)

- AC-23 stays unchecked until CI runs `test_bundled_claude_payload_contains_all_repo_runtime_contracts` on the PR head; the item's orchestrator run checks it off at S9. If CR-3 or CR-5 edits the rule file, keep the bundle copy byte-identical so the CI node remains green.

## Unrelated observations (no action in this item)

- Untracked `SCRATCH/` directory at the worktree root (orchestrator session state; not in the branch diff). Remove before worktree cleanup; do not stage.
- `issue.md:5` promotion path lacks the date prefix; promotion-tooling output shared by 53 of 89 active `issue.md` files.
