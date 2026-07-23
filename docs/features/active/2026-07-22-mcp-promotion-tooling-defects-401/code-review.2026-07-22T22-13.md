# Code Review: MCP Promotion Tooling Defects (#401) — Remediation Cycle 1 Reaudit

---

**Review Date:** 2026-07-22
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/`
**Feature Folder Selection Rule:** Supplied by the caller; suffix `-401` matches the issue number in the branch name `bug/mcp-promotion-tooling-defects-401`.
**Base Branch:** `main` (merge-base `a0b251d330525b8307467f4cf529c5cc3e947445`)
**Head Branch:** `bug/mcp-promotion-tooling-defects-401` (`3ba0d3c4aab9a57d00a2a02591abcf0e0391c1e2` = original fix `9d2e7633` + remediation `3ba0d3c4`)
**Review Type:** Reaudit (remediation cycle 1)

---

## Executive Summary

This reaudit reviews the full branch diff against merge-base `a0b251d3` (102 files, +3745/−247), which now includes the remediation commit for cycle 1. The remediation code delta relative to the cycle-0 review is small and clean: (1) the five `run_poshqc_*` tool definitions were extracted byte-identically from `mcp-repo-automation-tool-definitions.ts` (504 → 402 lines) into a new 123-line sibling `mcp-repo-automation-tool-definitions-poshqc.ts`, re-exported and spliced back at the original array position via `...POSHQC_TOOL_DEFINITIONS`, with a type-only import avoiding any runtime cycle; and (2) a new tests-only file `tests/scripts/dev_tools/test_potential_to_issue_branches.py` (408 lines, 10 cases) raised `potential_to_issue.py` per-module branch coverage from 68.18% to 81.82% with no production change. The R3 pre-existing over-500-line Python files are deferred with documented rationale.

Independent verification this reaudit: `git diff 9d2e7633..HEAD` inspected hunk-by-hunk for the src changes (pure move confirmed; schemas, names, descriptions, and `required` arrays unchanged); both full toolchains rerun green in a single pass at head (Prettier/ESLint/tsc/Jest 2031 in 2.70 s; Black/Ruff/Pyright/pytest 1992 in 9.88 s); lcov parsed for both languages (both R1 files 100% line-covered; module branch 54/66).

**Cycle-0 finding disposition:**
1. Blocker (504-line file) — **RESOLVED** and verified.
2. Major (module branch coverage 68.18%) — **RESOLVED** (81.82%).
3. Major (coverage-delta evidence computed against the wrong denominator) — **RESOLVED** (corrected artifact `coverage-delta-py.2026-07-22T21-30.md` computes per-module and supersedes cycle-0).
4. Minor (pre-existing over-500 files grew) — **DEFERRED** with documented rationale and precedent; follow-up issue required post-merge.
5. Two Info items — unchanged, no action required.

**Top remaining risks:**
1. The breaking `workspace_root` requirement can strand out-of-repo agent callers that relied on the silent default; mitigated by the actionable error message and the in-repo doc sweep (unchanged from cycle 0).
2. The two R3-deferred files (639 / 1076 lines) remain over the 500-line limit until the follow-up decomposition lands; the decomposition is parity-sensitive and must be coordinated with `promotion.ts`.

**PR readiness recommendation:** **GO** — zero Blockers; both toolchains green on independent rerun; coverage above thresholds for both languages; the sole open item is a documented, precedented deferral.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (was Blocker) | `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | whole file | Cycle-0 Blocker: file was 504 lines (> 500). Now 402 lines; the five PoshQC definitions moved verbatim to the 123-line sibling and spliced back at the original position. Pure move independently confirmed (`git diff 9d2e7633..HEAD`): no schema, name, description, or `required` change; all 28 tools still require `workspace_root` (16+5+7 grep count); 168 suites / 2031 tests pass with zero test modifications. | None. | 500-line rule satisfied for every branch-attributable file. | `wc -l` = 402 / 123; diff inspection; Jest full run this reaudit; `evidence/other/r1-extraction-verify.2026-07-22T21-30.md`. |
| Resolved (was Major) | `scripts/dev_tools/potential_to_issue.py` | branch metric | Cycle-0 Major: per-module branch coverage 68.18% (45/66) < 75%. Now 81.82% (54/66) and line coverage 95.00% (190/200), via 10 new tests in `test_potential_to_issue_branches.py`; production file untouched in cycle 1 (verified by diff). | None. | Uniform gate (>= 75% branch, >= 85% line) met from per-module counts. | Live rerun `poetry run pytest ... --cov-branch` → `200 10 66 12 92%`; lcov BRH 54 / BRF 66; `evidence/qa-gates/coverage-delta-py.2026-07-22T21-30.md`. |
| Resolved (was Major) | `evidence/qa-gates/coverage-delta-py.2026-07-22T20-17.md` | line 15 | Cycle-0 Major: AC-11 branch check computed against the overall measured set (87.3%) instead of the changed module. The corrected artifact (`coverage-delta-py.2026-07-22T21-30.md`) states the per-module computation explicitly, labels itself CORRECTED, and cites the defect it supersedes. | None. Future coverage-delta artifacts must continue computing per-module figures from per-module counts. | Evidence-accuracy restored; audit trail preserved (defective artifact retained, superseded). | `coverage-delta-py.2026-07-22T21-30.md` sections "AC-11 Threshold Verdict — PER-MODULE" and "TOTAL row (... not used for the AC-11 verdict)". |
| Major (deferred follow-up) | `scripts/dev_tools/potential_to_issue.py`, `tests/scripts/dev_tools/test_potential_to_issue.py` | whole files | Pre-existing over-500-line files: 639 (634 at merge-base) and 1076 (1017 at merge-base). Deferred to a follow-up issue per `evidence/other/r3-deferral.2026-07-22T21-30.md` under the cycle-1 exit-condition discretion. This reaudit evaluates the deferral as acceptable: overages predate the branch; growth came from required lockstep/regression work; decomposition is parity-sensitive and a distinct work unit; April 2026 precedent for these same files. | File the follow-up decomposition issue post-merge; coordinate the production split with the `promotion.ts` byte-parity contract. | Non-blocking under the established precedent (`docs/features/archive/2026-04-05-potential-to-issue-missing-label-123/policy-audit.2026-04-05T15-30.md`); attribution verified via `git show a0b251d3:<file>`. | `wc -l` this reaudit; `r3-deferral.2026-07-22T21-30.md`. |
| Info | `extensions/drm-copilot/src/mcp-tools.ts` | lines 73–86, 147 | `inferWorkspaceRoot` still echoes `process.cwd()` into the failure envelope's `workspace_root` field when the input omits it (failure-envelope echo only; no write path uses it). Unchanged from cycle 0. | Optional follow-up: echo an empty string or sentinel for omitted `workspace_root`. No action required for this fix. | Fail-closed guarantee holds (resolvers throw before any write); the echo is cosmetic. | Cycle-0 review; `mcp-tools.workspace-root.test.ts`. |
| Info | `.claude/rules/typescript.md` vs `extensions/drm-copilot/` | n/a | Rule file names Vitest; the extension's established framework is Jest (ts-jest via `node run-jest.cjs`). Pre-existing discrepancy flagged in spec Rollout & Follow-up. | Separate docs correction; out of scope here. | Avoids future reviewer/executor confusion. | spec.md Rollout & Follow-up; `package.json` scripts. |

No open Blockers. No open Major findings other than the documented R3 deferral.

---

## Implementation Audit

### TypeScript implementation audit (remediation delta)

#### What changed well

- The extraction is the smallest change that satisfies the rule: definitions moved without edits, spliced back with a single spread at the original array index, so tool ordering, schema content, and the `RepoAutomationToolName` contract are structurally guaranteed to be unchanged.
- The sibling's docblock states the extraction rationale, the splice-back invariant, and the reason the `ToolDefinition` import is type-only (avoiding a runtime cycle with the base module that re-exports the constant) — a "why" comment in the intended sense.
- The base module re-exports `POSHQC_TOOL_DEFINITIONS`, keeping a single public import point; the consumer sweep found no import-path updates were needed, and the zero-test-modification full-suite pass is strong behavior-invariance evidence.

#### Type safety and maintainability

- No `any`, no assertions, no new suppressions in the remediation diff (grep over `9d2e7633..HEAD` added lines: zero `eslint-disable`, `@ts-expect-error`, `@ts-ignore`).
- Both R1 files are 100% line-covered with no branch constructs; the 500-line ceiling now has 98 lines of headroom in the base module.

#### Error handling and logging

- No error-handling changes in the remediation delta; the cycle-0 fail-closed guard and failure envelope are unchanged and re-verified by the passing AC-4/AC-8 suites.

### Python implementation audit (remediation delta)

#### What changed well

- R2 is strictly additive test code: `git diff 9d2e7633..HEAD` shows zero changes to `scripts/dev_tools/potential_to_issue.py`, honoring the remediation do-not-do list (no production change, no parity impact).
- The new test file targets named partial branches (each docstring cites the branch arc, e.g. "Cover branch 397->398"), which makes the coverage intent auditable against the term-missing report.
- Placement in a new mirrored file rather than the 1076-line existing test file respects the 500-line rule interaction called out in remediation-inputs R2.

#### Typing and API notes

- Fakes implement the module's existing seam interfaces (`FileSystem`, `GhClient`) with complete annotations; Pyright clean (0 errors, 184 files).
- `monkeypatch` is applied at the import location used by the unit under test (module attribute), per the pytest rules.

#### Error handling and logging

- New negative cases assert specific exceptions with message matches (`PromotionError` "Invalid work mode" / "Potential file is empty", `RuntimeError` "gh CLI path was not resolved"); no broadened exception checks.

---

## Test Quality Audit

This reaudit independently reran both full toolchains green at head `3ba0d3c4`: Jest 2031/2031 (168 suites, 2.70 s, explicit forward-slashed `--testMatch` glob required under the worktree path); pytest 1992/1992 with branch coverage (9.88 s).

### Reviewed test and QA artifacts (remediation cycle)

- `tests/scripts/dev_tools/test_potential_to_issue_branches.py` (NEW, 408 lines, 10 cases) — branch-targeted cases across `RealGhClient` guards, `promote_potential` validation branches, the relpath ValueError fallback, the minor-audit evidence-checklist read, missing-label non-retry, and the created-issue-without-number path. Full-file inspection: docstrings, AAA comments, in-memory fakes, zero suppressions, zero temp files.
- `evidence/other/r1-extraction-verify.2026-07-22T21-30.md` — 168/2031 identical-count Jest pass with zero test modifications (behavior invariance).
- `evidence/other/r2-no-production-change.2026-07-22T21-30.md` and this reaudit's direct diff — production Python untouched in cycle 1.
- `evidence/qa-gates/linecount-all-changed.2026-07-22T21-30.md` — per-file counts for every changed/new production and test file; independently reproduced this reaudit via `git diff --name-only ... | xargs wc -l` with matching numbers.
- `evidence/qa-gates/final-*.2026-07-22T21-30.md` and `coverage-delta-*.2026-07-22T21-30.md` — single-pass toolchain records with commands and exit codes; concur with this reaudit's independent reruns.

### Quality assessment prompts

- **Determinism:** All collaborators faked; the `RealGhClient` guard cases are constructed so guards fire before any subprocess path; `monkeypatch` for the cross-drive relpath simulation. No clocks, RNG, network, or temp files.
- **Isolation:** One branch/behavior per test; fakes constructed per test.
- **Speed:** 2.70 s (TS full) / 9.88 s (Py full with coverage), observed this reaudit.
- **Diagnostics:** `pytest.raises(..., match=...)` with exact message fragments; assertion messages identify the covered branch via docstrings.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Remediation diff inspection: no credentials, tokens, or `.env` content. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess changes; new tests deliberately avoid executing any external process (guards asserted before the subprocess path). |
| Input validation at boundaries | ✅ PASS | Unchanged from cycle 0; schema `required` contract re-verified at head (28/28). |
| Error handling remains explicit | ✅ PASS | No catch-all handlers introduced; new tests pin specific exception types and messages. |
| Configuration / path handling is safe | ✅ PASS | No path-handling changes in the remediation delta; cycle-0 `potential_path`/`workspace_root` verdicts re-verified by the passing suites. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff (`a0b251d3..HEAD` and the remediation delta `9d2e7633..HEAD`), repository policy rules, feature-folder evidence, lcov artifacts, and independent toolchain reruns. Precedents consulted: `docs/features/archive/2026-04-05-potential-to-issue-missing-label-123/policy-audit.2026-04-05T15-30.md` (pre-existing overage in the same Python file family treated as non-blocking follow-up) and `docs/features/completed/portable-orchestrator-state-preflight/policy-audit.2026-07-06T10-56.md` (branch-caused overage treated as Blocking — the condition that R1 has now cured).

---

## Verdict

Remediation cycle 1 fully resolves the cycle-0 Blocker (verified pure module split, 402 + 123 lines, zero behavior change) and both Major findings (per-module branch coverage 81.82%; corrected coverage-delta evidence). The R3 deferral of the two pre-existing over-500-line Python files is acceptable under the granted discretion and the April 2026 precedent, and is recorded as a Major non-blocking follow-up requiring a post-merge issue. Both toolchains pass in a single pass on independent rerun at head `3ba0d3c4`. **Zero open Blockers; blocking-finding count: 0. GO for PR authoring.**
