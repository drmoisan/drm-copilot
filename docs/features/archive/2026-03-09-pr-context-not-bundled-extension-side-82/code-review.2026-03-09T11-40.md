# Code Review: Bug #82 PR Context Not Bundled Extension-Side

**Review Date:** 2026-03-09T11-40  
**Base Branch:** `origin/development`  
**Feature Folder Selection Rule:** Explicit user-provided folder `docs/features/active/2026-03-09-pr-context-not-bundled-extension-side-82` (also aligned with issue `#82`).

## 1) Executive Summary

The implementation correctly shifts PR context collection to an extension-bundled script path, removing dependence on destination-workspace Python module availability. The wrapper now performs `sys.path` bootstrap and imports bundled collector code directly, while `extension.ts` explicitly passes `--repo-root` and retains destination `cwd` behavior.

### Top 3 risks
1. **Bundle drift risk (Minor):** bundled `pr_context` package can diverge from canonical `scripts/dev_tools/pr_context` unless refreshed intentionally.
2. **Runtime dependency risk (Minor):** feature still depends on `python` availability in PATH in destination environment.
3. **No live end-to-end host run in this audit (Minor):** validated by integration/unit tests and static inspection, not a manual VS Code host run in this pass.

### PR Readiness Recommendation
**Go** — no blocker findings.

---

## 2) Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/*` | package snapshot | Bundled package duplication introduces maintenance drift risk. | Add a documented sync step/script for re-bundling on source package changes. | Prevent silent behavior divergence between canonical and bundled collectors. | PR appendix shows newly added bundled package tree; wrapper imports bundled module. |
| Minor | `extensions/drm-copilot/src/extension.ts` | runtime probe path | Python runtime requirement remains a deployment precondition. | Keep explicit error messaging for missing runtime (already present), and document in extension README if not already. | Improves diagnosability in destination workspaces. | `detectRuntime("python")` throws explicit PATH error; command logs runtime probe events. |
| Nit | `extensions/drm-copilot/package.json` | scripts | Added `test:unit` alias mirrors `test`. | Keep both if CI/tasks rely on distinct command names; otherwise document why alias exists. | Avoid script sprawl ambiguity over time. | Diff adds `"test:unit": "node run-jest.cjs"`. |

No Blocker or Major findings.

---

## 3) Typed Python Audit (required)

- **No new `Any` abuse:** wrapper uses precise typing (`Callable[[], int]` + `cast`), no broad type suppression.
- **No type-check weakening:** no evidence of pyright config loosening or broad `type: ignore` usage in changed Python wrapper.
- **Interface clarity:** wrapper is intentionally thin; collector retains parser contract including `--repo-root`.
- **Exception handling:** no naked broad catch added in wrapper.
- **Public API/docs:** wrapper has robust docstrings and clear invariants.

Verdict: **PASS** for typed-Python expectations in changed Python files.

---

## 4) Test Quality Audit

- Updated tests are deterministic and isolated (Jest mocks for VS Code + process spawning).
- Assertions are behavior-oriented (script path, args, cwd, artifact args), not implementation-fragile internals.
- Regression intent is explicit: tests fail if command reverts to `-m` pattern or drops `--repo-root`.
- Run result in this review session: **3 suites, 37 tests, all pass**.

Verdict: **PASS**.

---

## 5) Security / Correctness Checks

- No secrets detected in changed files.
- Process execution remains non-shell spawn pattern in extension runtime path.
- Boundary correctness improved: extension now executes bundled script from extension install path while targeting destination repo via `--repo-root` + `cwd`.

Verdict: **PASS**.

---

## 6) Evidence References

Primary:
- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`

Direct inspected files:
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/resources/templates/collect_pr_context.py`
- `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`
- `extensions/drm-copilot/test/extension.integration.test.ts`
- `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/collector.py`

Tooling evidence from this review run:
- TS: lint/typecheck/test:unit pass
- Python: black --check, ruff, pyright, pytest+coverage pass (81% total coverage)

---

## 7) Final Code Review Verdict

**Recommendation: GO (PR-ready)**

This change set resolves the extension-side packaging/execution defect for PR context collection and preserves expected user workflow behavior.
