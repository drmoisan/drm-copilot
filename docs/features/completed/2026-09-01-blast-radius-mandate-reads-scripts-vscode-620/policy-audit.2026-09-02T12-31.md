# Policy Audit — Issue #620 (blast-radius-mandate-reads-scripts-vscode) — Re-audit (remediation cycle 1)

- Timestamp: 2026-09-02T12-31
- Branch: `bug/blast-radius-mandate-reads-scripts-vscode-620` @ `bc92d6db99e4791fdce53b64fbe6a6958df9eaa4`
- Base: `origin/main` @ `dd98630c4b786280b2740eb01a75592870b22bbd`
- Merge-base: `dd98630c4b786280b2740eb01a75592870b22bbd`
- Work mode: `minor-audit` (from `issue.md` marker `- Work Mode: minor-audit`)
- AC source: `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md`, explicit `## Acceptance Criteria` section only
- Prior review cycle: `policy-audit.2026-09-02T11-48.md` (PASS, zero blocking findings) → PR #624 required check `drm-copilot-extension-tests` failed on head `7e74ed77` → remediation cycle 1 (`remediation-inputs.2026-09-02T12-02.md`, `remediation-plan.2026-09-02T12-02.md`) → this re-audit against the current head `bc92d6db`.

## Policy Reading Order

Read in this order before evaluation, per `.claude/skills/policy-compliance-order/SKILL.md`:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/typescript.md` (the remediation commit touches a `.ts` file)
6. `.claude/rules/python.md` (Python parity test suite is in scope, pre-existing/unmodified)
7. `.claude/rules/powershell.md` (Pester parity suite is in scope, pre-existing/unmodified, via evidence)
8. `.claude/rules/plan-acceptance-gates.md` (auto-loaded; two plan artifacts under review)
9. `.claude/rules/tonality.md`

## Rejected Scope Narrowing

None detected in the delegating prompt for this re-audit. The prompt supplies factual context (CI failure on PR #624, the remediation commit, AC6's pre-existing DEFERRED status) and explicitly instructs: "Evaluate the full current branch diff against main, not just the remediation delta, per the standard feature-review-workflow scope invariant." This is a correct restatement of the scope invariant, not an attempt to narrow it. The full range `dd98630c..bc92d6db` (both the original fix commit `7e74ed77` and the remediation commit `bc92d6db`) is audited below without narrowing.

A distinct narrowing attempt was found and rejected in a plan artifact under review (not the delegating prompt): `remediation-plan.2026-09-02T12-02.md`'s "Coverage note" states "No dedicated coverage-capture task is included for that reason" (the reason being that the one changed file is a test file outside `jest.config.cjs`'s `collectCoverageFrom: ["src/**/*.ts"]` scope). This reasoning correctly explains why the *specific changed file* carries no per-file coverage threshold obligation, but it does not exempt the *language* from the mandatory Coverage Verification Procedure, which requires a coverage artifact to exist for any language with a changed file in the branch diff, independent of which specific file changed. This review does not accept that argument as a basis for omitting the coverage-artifact check — see "Coverage Verification" below.

## Full Branch Diff Scope

`git diff --name-status dd98630c..bc92d6db` — 32 files changed (16 from the original fix commit `7e74ed77`, plus 16 more added/modified by the remediation commit `bc92d6db`):

- 2 JSON config files modified: `config/blast-radius.json`, `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` (unchanged by the remediation commit — confirmed empty diff for both paths across `7e74ed77..bc92d6db`)
- 1 TypeScript test-fixture file modified: `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` (+1 line, added by the remediation commit)
- 29 Markdown files added: feature folder docs (`issue.md`, both plans), the promoted potential-feature record, both prior review-cycle artifacts (`code-review.2026-09-02T11-48.md`, `feature-audit.2026-09-02T11-48.md`, `policy-audit.2026-09-02T11-48.md`), the remediation-cycle artifacts (`remediation-inputs.2026-09-02T12-02.md`, `remediation-plan.2026-09-02T12-02.md`), and evidence artifacts under `evidence/{baseline,other,qa-gates,remediation-baseline}/`

No Python, PowerShell, or C# production or test source file is added, modified, or deleted by this branch (confirmed: `git diff --name-only dd98630c..bc92d6db | grep -E "\.(py|ps1|psm1|cs)$"` returns no matches). The two Python (`tests/scripts/dev_tools/test_blast_radius_config_parity.py`) and PowerShell (`tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`) test suites cited in the issue and plans remain pre-existing and unmodified across the full range.

## Coverage Verification

| Language | Changed files in full branch diff (`dd98630c..bc92d6db`) | Coverage artifact | Verdict |
|---|---|---|---|
| TypeScript | 1 — `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` (modified, test-fixture file added by the remediation commit) | `coverage/lcov.info` under `extensions/drm-copilot/` — **searched, not found** (`find` over the full worktree, excluding `node_modules`, produced zero matches; confirmed independently by this audit) | **FAIL** |
| Python | 0 | — | **N/A** — zero `.py` files changed on this branch (verified via `git diff --name-status` over the full merge-base range) |
| PowerShell | 0 | — | **N/A** — zero `.ps1`/`.psm1` files changed on this branch |
| C# | 0 | — | **N/A** — zero `.cs` files changed on this branch |

**Reason for the TypeScript FAIL:** "coverage artifact absent for TypeScript; coverage verification is mandatory for all languages with changed files." No `coverage/lcov.info` (or any `lcov.info`) exists anywhere in the worktree. The remediation cycle's own toolchain loop ran `format`, `lint`, `typecheck`, and `test:unit` (all independently re-verified as passing by this audit — see "Toolchain Loop" below) but never ran the coverage command (`npm run test:coverage`, which is `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`), so no coverage evidence was produced during execution to inspect. Per this review's Coverage Verification procedure, the agent does not rerun coverage generation to manufacture the missing evidence; the absence is recorded as-is.

This finding is not waived by the fact that the one changed file is a test-fixture file excluded from `jest.config.cjs`'s `collectCoverageFrom: ["src/**/*.ts"]` scope. That exclusion is correct and policy-compliant on its own terms (`.claude/rules/general-unit-test.md`: "Configure coverage tooling to exclude test files... so metrics reflect application code, not tests"; the Coverage Exclusion Policy's permitted-exclude list names `tests/**`-style test infrastructure). It explains why this specific file would report no line/branch numbers if coverage were run — it does not substitute for the repo-wide TypeScript coverage-artifact-existence check, which applies whenever the language has any changed file in the branch diff, per this review's explicit, unconditional Coverage Verification Procedure (no per-file-type carve-out is stated there). This is recorded as a **Blocking** finding and added to remediation triggers.

## Evidence Location Compliance

- `git diff --name-only dd98630c..bc92d6db | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"` returned no matches (grep exit code 1, independently re-run for the full range).
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no violations reported (independently re-run).
- All evidence artifacts added across both commits (11 from the original fix, 9 from the remediation cycle) are written under the canonical `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/{baseline,other,qa-gates,remediation-baseline}/` path, consistent with `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries apply; no non-canonical path was instructed or used.

## Toolchain Loop (`.claude/rules/general-code-change.md`, `.claude/rules/typescript.md`)

The two committed JSON edits (unchanged from the prior cycle) required only JSON-validity plus the two named parity test suites, as previously audited and re-confirmed here (Python parity suite independently re-run: `17 passed in 0.06s`).

The remediation commit's one-line TypeScript fixture edit was run through the full TypeScript toolchain (format → lint → type-check → test), independently re-verified by this audit from the current worktree, not merely re-read from evidence files:

- **Format** (`npx prettier --check "test/lib/push-down/config-carriage.test-helpers.ts"`, from `extensions/drm-copilot`): `EXIT_CODE: 0`, `All matched files use Prettier code style!`. Matches recorded baseline and final evidence. **PASS.**
- **Lint** (`npx eslint --no-error-on-unmatched-pattern test/lib/push-down/config-carriage.test-helpers.ts`): `EXIT_CODE: 0`, empty stdout. Matches recorded evidence. **PASS.**
- **Type-check** (`npm run typecheck`, i.e. `tsc -p ./ --noEmit`): `EXIT_CODE: 0`, no diagnostics. Matches recorded evidence. **PASS.**
- **Test — target file** (`npm run test:unit -- test/lib/push-down/claude-config-carriage.test.ts --verbose`): `EXIT_CODE: 0`, `Tests: 17 passed, 17 total`, including the previously-failing test "keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource". Matches recorded evidence. **PASS — the CI failure described in `remediation-inputs.2026-09-02T12-02.md` is resolved.**
- **Test — full extension suite** (`npm run test:unit`): `EXIT_CODE: 0`, `Test Suites: 203 passed, 203 total`, `Tests: 2735 passed, 2735 total`. Matches recorded evidence (`p2-t6-full-suite-regression.2026-09-02T12-02.md`). **PASS — no regression.**
- **Coverage** (`npm run test:coverage`): not run as part of this branch's execution trail; no artifact exists. **FAIL** — see "Coverage Verification" above.
- `.claude/rules/parallel-orchestration.md` unmodified across the full range: `git diff dd98630c..bc92d6db -- .claude/rules/parallel-orchestration.md` produces empty output, confirming AC7 (the planner's obligation to declare a genuine write under `scripts/vscode/` is not weakened). **PASS.**

## File Size Limit (`.claude/rules/general-code-change.md`)

All changed/added files are well under 500 lines. `config-carriage.test-helpers.ts`'s edit is a single added line inside an existing file; no file added or modified by this branch approaches the 500-line limit. **PASS.**

## Dependencies / I/O Boundaries / Naming

Not applicable — no new dependency, I/O boundary, or naming change is introduced. The remediation is a single string-literal array entry inside an existing test-fixture object literal, added in the same relative position as the entry it mirrors. **N/A.**

## Tonality (`.claude/rules/tonality.md`)

`remediation-inputs.2026-09-02T12-02.md` and `remediation-plan.2026-09-02T12-02.md` use factual, measured, non-hyperbolic language throughout, including the explicit "Discrepancy note" in `p2-t4-target-test-final.2026-09-02T12-02.md` documenting an observed gap between the plan's stated acceptance text (an itemized `✓` line) and the tool's actual output (a summary-only block), and the equivalent discrepancy note in `p2-t5-diff-scope-final.2026-09-02T12-02.md` regarding untracked evidence files appearing in `git status --porcelain`. Both are evidence-first, non-defensive disclosures consistent with policy. No violations observed. **PASS.**

## Work-Mode Routing Verdict

Work mode marker `- Work Mode: minor-audit` is present and unambiguous in `issue.md` (unchanged by the remediation commit). `issue.md` contains the exact heading `## Acceptance Criteria`. No `spec.md` or `user-story.md` exists in the feature folder. AC source correctly resolved to `issue.md`'s explicit AC section only. **PASS.**

## Overall Policy Compliance Verdict

**FAIL — remediation required.** One Blocking finding: no TypeScript coverage artifact (`coverage/lcov.info`) exists for a branch that now has a changed `.ts` file (`extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`), per the mandatory, per-language Coverage Verification Procedure. Every other gate evaluated in this re-audit — the toolchain loop (format, lint, type-check, target test, full-suite regression), evidence location compliance, file size, tonality, and work-mode routing — is **PASS**, and the original CI failure that triggered this remediation cycle (`drm-copilot-extension-tests` on PR #624) is independently confirmed resolved. AC6 remains a documented, evidence-backed DEFERRED scope item, unchanged from the prior cycle and out of scope for this remediation per its own explicit scope constraint; it is evaluated in full in `feature-audit.2026-09-02T12-31.md`.

See `remediation-inputs.2026-09-02T12-31.md` for the coverage-artifact remediation trigger.
