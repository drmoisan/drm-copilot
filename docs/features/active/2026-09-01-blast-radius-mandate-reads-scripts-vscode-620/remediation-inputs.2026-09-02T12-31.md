# Remediation Inputs — issue #620 (remediation cycle 2 trigger)

Canonical issue number: 620

## Source

Feature-review re-audit (remediation cycle 1 verification), per `feature-review-workflow` SKILL contract.

- Reviewed head: `bc92d6db99e4791fdce53b64fbe6a6958df9eaa4`
- Related artifacts: `policy-audit.2026-09-02T12-31.md`, `code-review.2026-09-02T12-31.md`, `feature-audit.2026-09-02T12-31.md`

## Finding — Severity: Blocking

**Missing evidence:** No TypeScript coverage artifact exists anywhere in the worktree (`coverage/lcov.info` under `extensions/drm-copilot/`, or any `lcov.info`). Confirmed via `find . -iname "lcov.info" -not -path "*/node_modules/*"` returning zero matches.

**Why this is now a gate:** This review's Coverage Verification Procedure requires a coverage artifact for every language with a changed file in the full branch diff (`dd98630c..bc92d6db`), with the verdict resolved to explicit PASS or FAIL — never N/A or "informational only" — whenever a language has at least one changed file. The remediation commit (`bc92d6db`) added one changed `.ts` file, `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`, which makes TypeScript newly subject to this gate on this branch. (In the original fix commit `7e74ed77`, TypeScript was correctly N/A — zero `.ts` files had changed.)

**Root cause:** `remediation-plan.2026-09-02T12-02.md`'s "Coverage note" reasoned that because `jest.config.cjs`'s `collectCoverageFrom` is scoped to `src/**/*.ts` only, and the one changed file is under `test/`, "there is no new/changed executable-code coverage delta for the Coverage Evidence Contract to gate," and therefore no coverage-capture task was included in the remediation plan's Phase 0 or Phase 2. That reasoning is correct as far as it goes — the specific changed file legitimately reports no coverage number under the existing, policy-compliant `collectCoverageFrom` scope (test files are permitted excludes under the Coverage Exclusion Policy) — but it does not address the separate, unconditional requirement that a coverage artifact exist for the language at all when any file in that language changed. No task in either the original plan or the remediation plan ran `npm run test:coverage` (`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`) at any point in this branch's execution history, so no artifact was ever produced to inspect.

**Required change:** Run the coverage command from `extensions/drm-copilot`:

```
npm run test:coverage
```

Capture the resulting `coverage/lcov.info` and the printed `text-summary` repo-wide coverage percentages as an evidence artifact under the canonical evidence path `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/` (per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`; do not write to `artifacts/coverage/` or any other non-canonical path). Record `Timestamp:`, `Command:`, `EXIT_CODE:`, and the repo-wide line/branch coverage percentages in `Output Summary:`.

**Expected outcome once captured:** Repo-wide TypeScript line coverage should be verified >= 80% (the artifact-existence/repo-wide floor this review's Coverage Verification Procedure applies) and, per `.claude/rules/quality-tiers.md` and `.claude/rules/typescript.md`, >= 85% line / >= 75% branch as the standing repository threshold. The single changed file (`config-carriage.test-helpers.ts`) is expected to report no coverage number, consistent with its correct, policy-compliant exclusion from `collectCoverageFrom`; this is not itself a defect and requires no code change — only the artifact needs to exist and the repo-wide number needs to be confirmed within threshold.

**Scope constraint:** This remediation trigger requires only a coverage-capture-and-evidence step. It does not require any change to `config/blast-radius.json`, the bundled copy, `config-carriage.test-helpers.ts`, or `jest.config.cjs`'s `collectCoverageFrom` scope, all of which are already correct and independently re-verified by this re-audit cycle.
