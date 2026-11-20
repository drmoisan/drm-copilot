# Code Review: MCP Promotion Tooling Defects (#401)

---

**Review Date:** 2026-07-22
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/`
**Feature Folder Selection Rule:** Supplied by the caller; suffix `-401` matches the issue number in the branch name `bug/mcp-promotion-tooling-defects-401`.
**Base Branch:** `main` (merge-base `a0b251d330525b8307467f4cf529c5cc3e947445`)
**Head Branch:** `bug/mcp-promotion-tooling-defects-401` (`9d2e7633bdb461e2c34b37a784e1f06f9628c73e`)
**Review Type:** Initial review

---

## Executive Summary

This branch fixes two defects in the drm-copilot MCP extension. Defect A: `normalizeWorkspaceRoot` no longer silently defaults to the server's `process.cwd()`; an omitted `workspace_root` with no explicit fallback now throws an actionable error, `workspace_root` is required in all 28 MCP tool input schemas (21 repo-automation + 7 discovery, plus the 18-tool test-only base mirror), and a workspace-relative `potential_path` is resolved against `workspace_root` at the resolver layer (extracted to a new 60-line sibling module to respect the 500-line limit). Defect B: `buildIssueBody` routes bug promotions to `buildBugBody` before the minor-audit branch, applied in lockstep to `promotion.ts` and its Python parity twin `potential_to_issue.py`. The diff spans 65 files (1851 insertions / 147 deletions), most of which are tests, documentation, and feature evidence.

Evidence reviewed: the full branch diff (regenerated `artifacts/pr_context.summary.txt` / `.appendix.txt`), independent toolchain reruns (Prettier/ESLint/tsc/Jest 2031 tests; Black/Ruff/Pyright/pytest), and lcov coverage artifacts for both languages. Implementation quality is high: minimal, precedent-following changes with strong fail-before/pass-after regression evidence. One Blocker was found: the schema `required` insertions pushed `mcp-repo-automation-tool-definitions.ts` from 490 to 504 lines, a new violation of the 500-line production-file limit that the executor's line-count evidence did not measure.

**What changed:**
- `workflow-command-arguments.ts`: fail-closed guard in `normalizeWorkspaceRoot` (throws on omitted value with no explicit fallback; VS Code surface keeps its explicit `getWorkspaceRoot()` fallback path).
- `mcp-repo-automation-tool-definitions.ts`, `mcp-discovery-tool-definitions.ts`, `mcp-tool-definitions.ts`: `"workspace_root"` added to every tool's `inputSchema.required`.
- `mcp-push-down-schema-properties.ts`: description rewritten (required; no `process.cwd()` default).
- `mcp-tool-inputs.ts` (477 lines) + new `mcp-tool-inputs-potential-to-issue.ts` (60 lines): `resolvePotentialToIssueToolInput` extracted; relative `potential_path` normalized via `normalizeWorkspaceDestinationPath`.
- `promotion.ts` + `potential_to_issue.py`: lockstep `buildIssueBody` bug-first reorder; docblock and stale parity-header path corrected.
- 14 TS test files (4 new) and the pytest suite updated; READMEs and four `execute-hard-lock/SKILL.md` copies swept for the required-`workspace_root` contract.

**Top 3 risks:**
1. `mcp-repo-automation-tool-definitions.ts` at 504 lines violates the 500-line hard limit (new violation introduced by this branch) — must be decomposed before merge.
2. The breaking `workspace_root` requirement can strand out-of-repo agent callers that relied on the silent default; mitigated by the actionable error message and the in-repo doc sweep, but external consumers of the published extension will hit `ok:false` failures until updated.
3. `potential_to_issue.py` branch coverage (68.18%) remains below the 75% uniform floor (pre-existing, not regressed) — untested branch paths in the promotion CLI carry latent regression risk.

**PR readiness recommendation:** **Needs Revision** — one Blocker (file-size violation) requires a small, precedented extraction plus reaudit; all functional behavior, tests, and toolchains are otherwise green.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | whole file | File is 504 lines (limit 500). It was 490 lines at merge-base; this branch's `required: ["workspace_root", ...]` insertions (+26/−12) pushed it over the limit. The executor's AC-14 evidence measured only `mcp-tool-inputs.ts` and its sibling. | Extract a cohesive subset of `REPO_AUTOMATION_TOOL_DEFINITIONS` entries (or the shared schema fragments) to a sibling module following the `mcp-tool-inputs-push-down.ts` extraction precedent; re-run the TS toolchain and pin the line counts in evidence. | `general-code-change.md` file-size rule is a hard limit for production files; precedent `docs/features/completed/portable-orchestrator-state-preflight/policy-audit.2026-07-06T10-56.md` treats a worsened production overage as Blocking. | `wc -l` = 504; `git show a0b251d3:<file> \| wc -l` = 490; `git diff --numstat` = +26/−12. |
| Major | `scripts/dev_tools/potential_to_issue.py` | whole file (branch metric) | Branch coverage is 68.18% (45/66), below the uniform 75% floor. Pre-existing at merge-base (identical 66/21 branch/partial counts in baseline evidence); zero regression from this branch; changed lines fully exercised. | Add pytest cases covering the 21 partially-covered branches (raising hits from 45/66 to >= 50/66) in the remediation cycle. | `.claude/rules/quality-tiers.md` uniform gate: branch coverage >= 75%. Non-blocking because it is pre-existing with no regression and does not meet the feature-review workflow's independent remediation triggers, but it should be closed while the module is in scope. | `artifacts/python/lcov.info` (BRH 45 / BRF 66); `evidence/baseline/baseline-py-test-coverage.2026-07-22T15-53.md` (66 branches, 21 partial at baseline). |
| Major | `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/qa-gates/coverage-delta-py.2026-07-22T20-17.md` | line 15 | The AC-11 threshold check computes branch coverage from the overall measured set ((4446−564)/4446 = 87.3%) and labels it PASS "for the changed module", masking the changed module's actual 68.18% branch coverage. | Correct the evidence artifact during remediation so the per-module branch figure is stated; future coverage-delta artifacts must compute per-module branch coverage from per-module counts. | Evidence artifacts must be accurate; a threshold check against the wrong denominator defeats the audit trail. | Comparison of `coverage-delta-py.2026-07-22T20-17.md` line 15 against lcov per-file record (45/66 = 68.18%). |
| Minor | `scripts/dev_tools/potential_to_issue.py`, `tests/scripts/dev_tools/test_potential_to_issue.py` | whole files | Pre-existing over-500-line files grew further: 634 → 639 (+5, required lockstep reorder) and 1017 → 1076 (+59, required regression cases). | Track a follow-up decomposition (production module into cohesive siblings alongside the existing `potential_to_issue_content.py`; test file split by concern). Not attributable to this bug fix. | Same 500-line rule; April 2026 precedent (`docs/features/archive/2026-04-05-potential-to-issue-missing-label-123/policy-audit.2026-04-05T15-30.md`) treated the pre-existing overage in these same files as non-blocking follow-up. | `wc -l` = 639 / 1076; `git show a0b251d3:<file> \| wc -l` = 634 / 1017. |
| Info | `extensions/drm-copilot/src/mcp-tools.ts` | lines 73–86, 147 | `inferWorkspaceRoot` still echoes `process.cwd()` into the failure envelope's `workspace_root` field when the input omits it. Unchanged by this branch and consistent with the spec (research classifies it "failure-envelope echo only"); no write path uses it. A caller reading the failure envelope could misread the echoed server cwd as the acted-upon root. | Optional follow-up: echo an empty string or sentinel in the failure envelope for omitted `workspace_root`. No action required for this fix. | The fail-closed guarantee holds (resolvers throw before any write); the echo is cosmetic but slightly misleading. | Read of `mcp-tools.ts` lines 73–86; `mcp-tools.workspace-root.test.ts` asserts the envelope shape. |
| Info | `.claude/rules/typescript.md` vs `extensions/drm-copilot/` | n/a | The TypeScript rule file names Vitest; the extension's established framework is Jest (ts-jest via `node run-jest.cjs`). Pre-existing discrepancy already flagged in spec Rollout & Follow-up. | Separate docs correction; out of scope here. | Avoids future confusion for reviewers/executors. | spec.md Rollout & Follow-up; `package.json` scripts. |

No other Blockers or Major findings.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- The fail-closed change is minimal and centralized: one guard in `normalizeWorkspaceRoot` covers every per-tool resolver without signature changes, and the optional-fallback design cleanly preserves the VS Code command surface (`getWorkspaceRoot()` callers).
- The `potential_path` fix is placed at the resolver layer, honoring the documented decision to keep `promotion-filesystem.ts` an untouched Python mirror; the reuse of `normalizeWorkspaceDestinationPath` avoids new path-handling code.
- The extraction of `resolvePotentialToIssueToolInput` to `mcp-tool-inputs-potential-to-issue.ts` follows the `mcp-tool-inputs-push-down.ts` precedent, keeps the public import surface stable via re-export, and carries a docblock explaining the why.
- The `buildIssueBody` reorder comment explains the ordering requirement (bug template headings vs minor-audit reads) rather than narrating the code.

#### Type safety and maintainability

- No `any`, no type assertions, and no new suppressions in the diff (grep over changed hunks: zero `eslint-disable`, `@ts-expect-error`, `@ts-ignore`). Resolver boundaries continue to take `unknown` and narrow.
- The schema `required` arrays remain literal and are pinned by tests (28/28 verified independently by grep count and by the AC-5 length-pinned Jest assertion).
- Maintainability gap: `mcp-repo-automation-tool-definitions.ts` at 504 lines (Blocker above).

#### Error handling and logging

- The new error message names the missing field and the corrective action verbatim: `workspace_root is required. The MCP server cannot infer the calling agent's checkout; pass the absolute worktree root explicitly.` It surfaces through the existing `toFailureToolResult` envelope (`ok:false`, `tool`, `workspace_root`, `summary`) — asserted at the dispatch boundary.
- No catch-all handlers introduced; failures propagate through the established structured-result path.

### Python implementation audit

#### What changed well

- The lockstep reorder in `potential_to_issue.py` is branch-for-branch identical to the TypeScript twin (`if promotion_type == "bug"` → `elif selected_mode == "minor-audit"` → `else`), preserving the byte-parity contract for messages, constants, emitted lines, and decision branches.
- The decision-logic comment above the routing block documents the ordering rationale, consistent with the commenting policy.

#### Typing and API notes

- No public Python API surface changed; `promote_potential` signature, `PromotionError` semantics, and the CLI workspace default (`Path(__file__).resolve().parents[2]`) are unchanged (verified by targeted diff grep in `evidence/qa-gates/scope-integrity.2026-07-22T20-17.md` and re-confirmed this review).
- Pyright passes with zero errors on the changed files and test tree.

#### Error handling and logging

- Invalid mode/type combinations still raise `PromotionError` before body build (pytest matrix assertions unchanged in semantics).

---

## Test Quality Audit

The regression surface is comprehensive on both sides, with recorded fail-before evidence for both defects and pass-after evidence at the same command granularity. This audit independently reran both full toolchains green (Jest 2031/2031 in 3.32 s; pytest target suites 38/38 in 0.10 s).

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts` — new (bug, minor-audit) regression case asserting bug-headed body, authored content per section, first-line `- Work Mode: minor-audit`, and zero placeholders. Directly pins AC-1.
- `extensions/drm-copilot/test/lib/potential-to-issue/promotion.matrix.test.ts` (NEW, 128 lines) — full routing matrix guard including invalid-combination throws and the partial-sections placeholder edge case. Pins AC-2.
- `extensions/drm-copilot/test/workflow-command-arguments.test.ts` — six new `normalizeWorkspaceRoot` cases (fail-closed, explicit fallback, valid string, invalid type, empty, whitespace). Pins AC-4 boundaries.
- `extensions/drm-copilot/test/mcp-tool-inputs.workspace-root.test.ts` (NEW) — resolver-level fail-closed and relative/absolute `potential_path` cases. Pins AC-4/AC-6.
- `extensions/drm-copilot/test/mcp-tools.workspace-root.test.ts` (NEW) — dispatch-boundary failure envelope (`ok:false`, message, shape). Pins AC-8.
- `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` — length-pinned all-tools `required` assertion plus the no-`process.cwd()` description assertion. Pins AC-5.
- `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` — pins the exact summary string for a resolver-normalized relative `potential_path` (AC-6 summary-drift risk from spec Risks).
- `tests/scripts/dev_tools/test_potential_to_issue.py` — mirrored (bug, minor-audit) regression case plus inverted routing assertion in the pre-existing minor-audit bug test. Pins AC-3.
- `evidence/regression-testing/expect-fail-*.2026-07-22T15-53.md` (exit 1) and `pass-after-*.2026-07-22T20-17.md` (exit 0) — fail-before/pass-after pairs for both defects; `vscode-surface-intact.2026-07-22T20-17.md` (exit 0) for AC-7.

### Quality assessment prompts

- **Determinism:** All collaborators faked (`FakePotentialFileSystem`, `FakeGhClient`, `FakeFileSystem`); no clocks, RNG, network, or real filesystem; no temp files.
- **Isolation:** One behavior per test; matrix cells asserted individually; envelope shape asserted separately from resolver behavior.
- **Speed:** Jest 3.32 s for 2031 tests; pytest 0.10 s for 38 target tests (observed this review).
- **Diagnostics:** Exact-string/regex assertions (`/workspace_root is required/`, first-line equality, exact summary pinning) yield precise failure output.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no credentials, tokens, or `.env` content in any changed file. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess changes; gh interaction stays behind the existing faked client abstraction on both sides. |
| Input validation at boundaries | ✅ PASS | `workspace_root` now schema-required and resolver-validated (empty/whitespace/type-checked); `potential_path` normalized through the field-named `normalizeWorkspaceDestinationPath` validation. |
| Error handling remains explicit | ✅ PASS | New error is specific and actionable; surfaces via the preserved `toFailureToolResult` envelope; no broad catches added. |
| Configuration / path handling is safe | ✅ PASS | Relative paths resolve against the validated `workspace_root`, eliminating the silent server-cwd misdirection (the defect under fix); absolute paths preserved; `~` expansion and `..` semantics delegated to the existing helper. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff, repository policy rules, feature-folder research/spec/evidence, lcov artifacts, and independent toolchain reruns. Repository precedents consulted: `docs/features/completed/portable-orchestrator-state-preflight/policy-audit.2026-07-06T10-56.md` (worsened production file-size overage treated as Blocking) and `docs/features/archive/2026-04-05-potential-to-issue-missing-label-123/policy-audit.2026-04-05T15-30.md` (pre-existing overage in the same Python file family treated as non-blocking follow-up).

---

## Verdict

The two defect fixes are correct, minimal, parity-preserving, and thoroughly tested; both language toolchains pass in a single pass on independent rerun, and coverage is verified from existing artifacts (TypeScript comfortably above thresholds; Python repo-wide above thresholds with a pre-existing, non-regressed per-module branch gap). The change is not ready for PR in its current state due to one Blocker: this branch pushed `mcp-repo-automation-tool-definitions.ts` over the 500-line production-file limit (490 → 504), which requires a small, precedented module extraction and a reaudit. Remediation inputs are recorded at `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/remediation-inputs.2026-07-22T21-07.md`. Once R1 is fixed (and R2 optionally closed in the same cycle), this change is ready for normal PR flow.
