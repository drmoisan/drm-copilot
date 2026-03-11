# Code Review: blank-pr-context-81

## Executive summary

Feature-branch changes remain tightly scoped to:
- `extensions/scaffold-extension/resources/templates/collect_pr_context.py`
- `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts`
- `extensions/scaffold-extension/test/extension.integration.test.ts`

Top risks (current state):
1. Future parity drift between bundled collector and canonical collector logic.
2. Real-world git edge cases not represented in mocked test fixtures.
3. Reviewer confusion from branch range showing `base==head` while work is still in working tree.

**PR readiness recommendation:** **Go** (ready to open/merge into `development` once CI reproduces local green checks).

**Feature folder selection rule:** user-specified folder `docs/features/active/2026-03-05-blank-pr-context-81` was used as authoritative, and it matches issue/branch suffix `-81`.

---

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `extensions/scaffold-extension/resources/templates/collect_pr_context.py` | `run_git`, renderer helpers | Bundled and canonical PR collectors can diverge over time. | Track parity in follow-up maintenance (shared helper or parity tests). | Prevents subtle behavior drift between extension-bundled and repo-native collector paths. | PR context appendix diff + collector structure inspection. |
| Nit | `artifacts/pr_context.summary.txt` | Base/head section | Current commit-range comparison shows `base==head` while active changes are unstaged. | Commit remediation changes before final PR-context collection used for PR body generation. | Keeps generated PR context aligned with actual review delta. | Refreshed summary + appendix status sections. |

No blockers or major defects identified.

---

## Typed Python audit

- **No new `Any` / weak typing introduced:** PASS.
- **No type-check weakening:** PASS (no `type: ignore`, no pyright config loosening).
- **Exception hygiene:** PASS (explicitly handles `FileNotFoundError`, `CalledProcessError`, `RuntimeError`).
- **Suppression policy alignment:** PASS (`# noqa: S603 - static analysis can't verify runtime validation` paired with `shutil.which("git")`).
- **Public API clarity/docs:** PASS (module and function docstrings are present and intent-focused).

---

## Test quality audit

- Deterministic and isolated: PASS.
- Fast execution: PASS (36 tests, 3 suites, ~0.307s).
- Regression quality: PASS after remediation.
  - `extension.collect-pr-context.test.ts` asserts substantive sections and placeholder rejection.
  - `extension.integration.test.ts` now verifies multi-section artifact content (`## Base/Head`, `## Changed files`, `## Numstat`) instead of weak line-count-only checks.

---

## Security and correctness checks

- No secrets introduced.
- No unsafe subprocess pattern in Python collector (validated executable path via `shutil.which`).
- Input boundary handling remains explicit (`--base` resolution failures return non-zero with diagnostics).

---

## Commands run for this review

- `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
- `npm exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- `npm run lint`
- `npm run typecheck`
- `npm run test`
- `poetry run black --check extensions/scaffold-extension/resources/templates/collect_pr_context.py`
- `poetry run ruff check extensions/scaffold-extension/resources/templates/collect_pr_context.py`
- `poetry run pyright extensions/scaffold-extension/resources/templates/collect_pr_context.py`
