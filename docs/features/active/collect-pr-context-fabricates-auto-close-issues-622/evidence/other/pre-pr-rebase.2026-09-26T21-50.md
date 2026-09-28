# Pre-PR rebase record for #622

Timestamp: 2026-09-26T21-50
Command: git rebase origin/main
EXIT_CODE: 0
Output Summary: The item branch was rebased onto origin/main at b924a9e2 (includes the #697, #694, #528, and #513 merges) with no conflicts, per the operator's pre-PR instruction (fetch, rebase onto origin/main, force-with-lease push). #588 is still not on origin/main, so the N588 branch taken by the plan remains correct.

## Deviation from plan D13

The plan and spec D13 state the branch is integrated by merge and never rebased or force-pushed. The operator's delegation instruction for this parallel run requires a rebase onto origin/main and a `--force-with-lease` push before the PR is opened; the operator instruction takes precedence. As a consequence, the SHAs recorded in `evidence/other/commit-log.2026-09-25T23-29.md` and in other evidence artifacts identify the pre-rebase commits. The mapping below relates each pre-rebase commit to its rebased equivalent (same subject, same tree change).

| Pre-rebase | Post-rebase | Subject |
|---|---|---|
| 10072690 | 9abc8e55 | docs(bug): create active feature folder for #622 |
| 806757db | 76cd32b8 | docs(research): record auto-close candidate scraping research for #622 |
| 25080143 | e4e6fc98 | docs(spec): write full-bug spec for #622 auto-close candidate filtering |
| f2a79973 | 53bb72c4 | docs(plan): author atomic plan for #622 auto-close candidate filtering |
| b46901d6 | de8653a3 | docs(plan): apply preflight round 1 revisions for #622 plan |
| 9265ce76 | 14131fe6 | docs(plan): apply preflight round 2 revisions and canonical coverage evidence paths for #622 |
| b6946592 | 0dbd91b4 | docs(plan): apply preflight round 3 revisions for #622 plan |
| 1ace7e1b | 9aa444a3 | docs(spec): make #622 merge-order independent of #588 (D9-D14) |
| 4a37e8e8 | 59dfaa1c | docs(plan): remove #588 merge gate; add M588/N588 detection branches for #622 |
| 59530fb9 | 02c97406 | docs(plan): apply preflight revision round 1 deltas for #622 |
| 8cab21f4 | 364bd162 | docs(plan): apply preflight revision round 2 delta for #622 |
| b90a9d73 | af1d2e6d | docs(bug): record phase 0 baselines for #622 |
| f61dfd9f | 2b9960c3 | feat(pr-context): add shared issue-reference and autoclose literals (#622) |
| 148a9a31 | 303f166c | test(pr-context): add fail-first autoclose regression tests (#622) |
| 3738726c | 69fd4ab8 | fix(pr-context): stop publishing scraped refs as autoclose targets in Python (#622) |
| 6fda4b51 | 191be5f0 | fix(pr-context): stop publishing scraped refs as autoclose targets in TypeScript (#622) |
| 9faa3921 | 3d682a09 | docs(bug): record pass-after evidence for #622 |
| a79d30e0 | d620a0a4 | test(pr-context): cover autoclose selection and invert JIRA extraction tests (#622) |
| 67b71d21 | 737b3005 | test(pr-context): cover TypeScript autoclose selection and builders (#622) |
| f93b3733 | 468a866b | docs(bug): record final QA evidence for #622 |
| 57490e0c | ab1f5ea7 | docs(bug): record scope and hermeticity evidence for #622 |
| 690db2d6 | d8df9ca8 | docs(bug): check off #622 acceptance criteria |
| 7fba38c7 | 173713e0 | docs(review): record feature review for #622 |

## Post-rebase toolchain re-run (rebased tree at 173713e0)

- `npm ci` (dependency bump #694 landed on main): 452 packages installed.
- `npx prettier --check "src/**/*.ts" "test/**/*.ts"`: exit 0.
- `npx eslint src test`: exit 0.
- `npx tsc --noEmit -p .`: exit 0.
- `node run-jest.cjs --coverage --coverageReporters=text-summary`: exit 0; Test Suites 225 passed; Tests 3108 passed; Lines 96.88%, Branches 90.76%.
- `poetry run black --check .`: exit 0.
- `poetry run ruff check .`: exit 0.
- `poetry run pyright`: exit 0.
- `poetry run pytest -q -p no:cacheprovider --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`: exit 0; 5126 passed, 5 skipped, 1 deselected (#510).
