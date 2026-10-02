# Acceptance-Criteria Verification

Timestamp: 2026-10-02T01-52
Source: `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/spec.md` (`## Acceptance Criteria`, AC-1 through AC-19; work mode `full-bug`)
Precondition: the [P12-T1], [P12-T3], and [P12-T5] commands were re-run after Phases 13 and 14. Each result is appended as `Post-QA re-run:` to `qa-gates/deferred-scope-diff`, `qa-gates/changed-file-set`, and `qa-gates/jest-config-unchanged`, and no new path was found.

Evidence paths are relative to `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/`.

| AC | Verifying task(s) | Evidence path(s) | Status |
|---|---|---|---|
| AC-1 | [P5-T4], [P11-T1] | `qa-gates/codex-orchestrate-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-2 | [P5-T4], [P11-T1] | `qa-gates/codex-orchestrate-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-3 | [P6-T4], [P11-T1] | `qa-gates/claude-orchestrate-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-4 | [P6-T4], [P11-T1] | `qa-gates/claude-orchestrate-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-5 | [P7-T7], [P11-T1] | `qa-gates/parallel-surface-new-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-6 | [P7-T7], [P11-T1] | `qa-gates/parallel-surface-new-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-7 | [P8-T7], [P5-T4], [P11-T1] | `qa-gates/ac-tracking-contracts.2026-09-30T03-18.md`, `qa-gates/codex-orchestrate-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-8 | [P7-T8], [P11-T2], [P11-T3], [P12-T2] | `qa-gates/parallel-surface-pinned-contracts.2026-09-30T03-18.md`, `regression-testing/parallel-surface-r2-8-nodes.2026-09-30T03-18.md`, `regression-testing/py-targeted-contracts.2026-09-30T03-18.md`, `qa-gates/pinned-expectations-diff.2026-09-30T03-18.md` | pass |
| AC-9 | [P9-T4], [P11-T1] | `qa-gates/feature-review-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-10 | [P9-T4], [P11-T1] | `qa-gates/feature-review-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-11 | [P1-T2] (fail-before, `ExpectedExitCode: 1`), [P2-T3] (pass-after) | `regression-testing/fail-before-two-gate-first-occurrence.2026-09-30T03-18.md`, `regression-testing/pass-after-two-gate-first-occurrence.2026-09-30T03-18.md` | pass |
| AC-12 | [P1-T3], [P2-T4] | `regression-testing/fail-before-first-occurrence-module.2026-09-30T03-18.md`, `regression-testing/pass-after-parser-modules.2026-09-30T03-18.md` | pass |
| AC-13 | [P2-T4], [P11-T3] | `regression-testing/pass-after-parser-modules.2026-09-30T03-18.md`, `regression-testing/py-targeted-contracts.2026-09-30T03-18.md` | pass |
| AC-14 | [P2-T4], [P2-T5], [P3-T3], [P3-T4], [P3-T5], [P14-T5] | `regression-testing/pass-after-parser-modules.2026-09-30T03-18.md`, `other/py-shape06-comment-check.2026-09-30T03-18.md`, `other/ts-comment-check.2026-09-30T03-18.md`, `other/ts-comment-only-diff.2026-09-30T03-18.md`, `regression-testing/ts-jest-verification-evidence.2026-09-30T03-18.md`, `qa-gates/ts-jest-coverage.2026-09-30T03-18.md` | pass (the code-review confirmation belongs to the reviewer, Spec Interpretation 3) |
| AC-15 | [P10-T10], [P11-T1] | `qa-gates/evidence-skill-contracts.2026-09-30T03-18.md`, `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md` | pass |
| AC-16 | Post-CI steps 1 and 2; local support [P11-T1], [P11-T4], [P5-T4], [P8-T7] | `regression-testing/pass-after-doc-contracts.2026-09-30T03-18.md`, `regression-testing/py-claude-bundle-parity.2026-09-30T03-18.md` (local pass; CI authoritative per issue #510), `qa-gates/ci-pr-head.2026-09-30T03-18.md` (Post-CI step 1: Code Quality & Tests 3.10-3.13 pass on PR #817 head) | pass |
| AC-17 | [P12-T1] | `qa-gates/deferred-scope-diff.2026-09-30T03-18.md` | pass |
| AC-18 | [P13-T4], [P13-T5] | `qa-gates/py-pytest-coverage.2026-09-30T03-18.md`, `qa-gates/python-coverage-final.2026-09-30T03-18.md` | pass |
| AC-19 | Phase 13 and Phase 14 loops (iteration 1 each), Post-CI step 1 (S9 CI on the PR head) | `qa-gates/py-black.2026-09-30T03-18.md`, `qa-gates/py-ruff.2026-09-30T03-18.md`, `qa-gates/py-pyright.2026-09-30T03-18.md`, `qa-gates/py-pytest-coverage.2026-09-30T03-18.md`, `qa-gates/python-coverage-final.2026-09-30T03-18.md`, `qa-gates/ts-prettier.2026-09-30T03-18.md`, `qa-gates/ts-eslint.2026-09-30T03-18.md`, `qa-gates/ts-tsc.2026-09-30T03-18.md`, `qa-gates/ts-dependency-cruiser.2026-09-30T03-18.md`, `qa-gates/ts-jest-coverage.2026-09-30T03-18.md`, `qa-gates/typescript-coverage-comparison.2026-09-30T03-18.md`, `qa-gates/ci-pr-head.2026-09-30T03-18.md` (Post-CI step 1: all 20 checks pass on PR #817 head) | pass |

Rows: 19. Rows with status `pass`: 19, each citing at least one evidence path that exists on disk. No row has status `pending-CI`.

Post-CI update (2026-10-02T03-11, Post-CI step 5): AC-16 and AC-19 moved from `pending-CI` to `pass`, citing Post-CI step 1 (`qa-gates/ci-pr-head.2026-09-30T03-18.md`, workflow run https://github.com/drmoisan/drm-copilot/actions/runs/36976529109 on head 5c4eb1a28e1ffc2e6e2ff5570fe4c738b83648cd).

Note for AC-19: the TypeScript coverage-comparison step passed on substituted evidence recorded in plan deviation D-V8-COMMENT-LINES. The v8 coverage provider counts the two added comment lines, so the line ratio of the `verification-evidence.ts` row moved from 96.92 to 96.94 while its uncovered-line set is unchanged apart from a +2 offset. The reviewer should confirm that substitution.
