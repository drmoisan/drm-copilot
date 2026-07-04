# Code Review: bundle-resolve-atomic-plan-prompt-command (#152)

---

**Review Date:** 2026-04-18
**Reviewer:** GitHub Copilot
**Feature Folder:** `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152`
**Feature Folder Selection Rule:** Explicitly supplied by the request and confirmed by the refreshed PR-context artifacts.
**Base Branch:** `development`
**Head Branch:** `feature/bundle-resolve-atomic-plan-prompt-command-152`
**Review Type:** Post-remediation re-review

---

## Executive Summary

The remediation closed the previously reported behavioral blockers. The bundled Python resolver now accepts the extension-emitted `--workspace` argument, the direct wrapper invocation succeeds against the real feature plan, and the focused Python and TypeScript regression suites cover the repaired boundary more directly than the earlier review set. The changed-scope coverage-proof gate is also now satisfied for the reviewed Python and TypeScript files.

This branch is still not ready for PR because the review found a different blocker in the touched TypeScript structure: three touched files exceed the repository's 500-line file limit, including `extensions/drm-copilot/src/repo-automation-service.ts` and `extensions/drm-copilot/test/repo-automation-service.test.ts`, which were pushed over the limit by this feature branch.

**What changed:**
The branch adds the new `drmCopilotExtension.resolveAtomicPlanPrompt` command, wires it through the shared repo-automation service and MCP surface, bundles a Python wrapper plus resolver copy for destination-workspace execution, and adds focused TypeScript and Python regression coverage. Supporting README, spec, and evidence artifacts were updated to match the shipped behavior.

**Top 3 risks:**
1. The touched oversized TypeScript files violate an explicit repository policy and increase maintenance cost in a high-churn area.
2. Keeping `mcp-tools.ts` above the limit while expanding it further makes future tool-surface changes harder to review safely.
3. Leaving the oversized test file in place weakens the maintainability benefit gained from the otherwise improved runtime-boundary coverage.

**PR readiness recommendation:** **Blocked** — the runtime and coverage blockers are closed, but the touched-file size policy violation remains unresolved.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/src/repo-automation-service.ts` | `n/a` | The file is 502 lines after this branch and crossed the repository's 500-line hard limit. | Split the atomic-plan prompt and template-asset concerns into a helper module so the touched service file returns below 500 lines without changing public behavior. | The repository policy treats file size as a structural constraint, and this branch pushed the file over the threshold. | Live line-count review: `repo-automation-service.ts BEFORE=485`, `AFTER=502`. |
| Blocker | `extensions/drm-copilot/test/repo-automation-service.test.ts` | `n/a` | The touched test file is 544 lines after the feature and also crossed the 500-line limit. | Move the `resolveAtomicPlanPrompt` and policy-audit asset tests into a dedicated suite file and keep the remaining service tests focused by concern. | The repository applies the 500-line limit to test code as well as production code. | Live line-count review: `repo-automation-service.test.ts BEFORE=487`, `AFTER=544`. |
| Major | `extensions/drm-copilot/src/mcp-tools.ts` | `n/a` | The branch expanded an already oversized file from 537 to 559 lines. | As part of the remediation, stop adding more tool-surface logic to this file and extract a tool-family helper or registration map. | The file was already oversized, and the feature worsened the deviation in a central command-dispatch area. | Live line-count review: `mcp-tools.ts BEFORE=537`, `AFTER=559`. |

The previously reported runtime-contract, regression-fidelity, coverage-proof, and requirement-sync blockers are resolved.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The wrapper remains thin and delegates real prompt resolution to the bundled resolver module instead of duplicating logic.
- The resolver now explicitly accepts `--workspace`, which makes the CLI contract deterministic for both absolute and workspace-relative targets.

#### Typing and API notes

- The Python additions are strongly typed for this scope: `Path` values, a focused clipboard protocol, and concrete return types are used throughout.
- No new public Python API surface beyond the bundled CLI contract was introduced.

#### Error handling and logging

- CLI error handling remains explicit and user-facing.
- Clipboard fallback behavior remains deterministic and reports failure clearly before printing the resolved prompt to stdout.

### TypeScript implementation audit

#### What changed well

- The command remains additive and reuses the shared repo-automation service instead of introducing a parallel execution path.
- The active-plan selection rules are tightened around `docs/features/active/**/plan*.md`, which closes the earlier invalid-target drift.

#### Type safety and maintainability

- The service, tool unions, and command registration remain explicitly typed.
- Maintainability is the remaining issue: the touched service and test files are now above the repository limit, and `mcp-tools.ts` was further expanded instead of reduced.

#### Error handling and logging

- Runtime failures are surfaced through the output channel and propagated to the caller.
- The command-level invalid-target error remains specific and actionable.

---

## Test Quality Audit

The test evidence is materially stronger than in the prior review. The follow-up Python suite executes the real bundled wrapper with the production `--target` and `--workspace` contract. The TypeScript command and service suites cover both the successful runtime contract and failure surfacing when stderr reports an argument mismatch.

### Reviewed test and QA artifacts

- `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/regression-testing/p1-t3.resolve-atomic-plan-prompt-pass-after.2026-04-18T17-44.md` — proves the direct bundled wrapper invocation now succeeds with the production `--workspace` argument.
- `tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt.py` and `test_resolve_atomic_plan_prompt_part2.py` — verify real wrapper execution, workspace-relative target resolution, clipboard fallback, and fail-closed work-mode handling.
- `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts` and `repo-automation-service.test.ts` — verify command registration, plan selection, bundled-wrapper argv, and runtime-failure surfacing.
- `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/changed-scope-coverage-proof.2026-04-18T17-44.md` — closes the changed-source coverage gate for the reviewed runtime path.

### Quality assessment prompts

- **Determinism:** VS Code APIs, child-process behavior, clipboard behavior, and file-existence checks are mocked or patched deterministically.
- **Isolation:** Each reviewed test targets one boundary behavior or error path.
- **Speed:** Live focused rechecks completed in 0.04s for Python and 0.298s for TypeScript.
- **Diagnostics:** Failure messages are specific enough to identify contract regressions immediately, especially around `--workspace` handling.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No secrets or credentials were observed in the reviewed implementation or evidence files. |
| No unsafe subprocess or command construction | ✅ PASS | The Python clipboard fallback validates executables with `shutil.which`, and TypeScript subprocesses continue to use explicit argv arrays with `shell: false`. |
| Input validation at boundaries | ✅ PASS | The command helper restricts targets to `docs/features/active/**/plan*.md`, and the bundled resolver validates template and target existence. |
| Error handling remains explicit | ✅ PASS | Both TypeScript and Python reviewed paths surface actionable runtime errors instead of silently succeeding. |
| Configuration / path handling is safe | ✅ PASS | The repaired resolver honors an explicit workspace root and resolves relative targets against it deterministically. |

---

## Research Log

No external research was required for this follow-up review. The authoritative sources were the refreshed PR-context artifacts, feature-folder evidence, live command rechecks, and direct file inspection.

---

## Verdict

The earlier remediation closed the known functional blockers, and the feature now behaves correctly on the runtime and regression-coverage axes that were previously failing. Acceptance criteria are satisfied, and the changed-scope coverage proof is now adequate.

The branch is still blocked for PR readiness because the touched TypeScript structure violates the repository's 500-line file-size policy. A narrow follow-up remediation should split the oversized service, tool-surface, and test concerns without changing runtime behavior, then rerun the TypeScript QA loop and a follow-up review.
