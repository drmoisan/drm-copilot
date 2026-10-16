# Feature Audit — Issue #940 (Dependabot bumps @types/vscode past engines.vscode), re-audit R4, remediation cycle 2

**Branch:** `bug/dependabot-bumps-types-vscode-past-engines-940`
**Head reviewed:** `94f4bd87045bef46e2bed63fe992fcf285eeb717`

## Total Blocking Findings: 0

## Scope and Baseline

- Baseline: `origin/main` at merge-base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`.
- Work mode: `minor-audit`. The AC source is the `## Acceptance Criteria` section of `issue.md`.
- Pre-change state was verified from the diff base (`git diff origin/main...HEAD`), not from executor claims alone.
- Remediation cycle 2 changed only `tests/scripts/dev_tools/test_dependabot_config_contract.py` (lines 100-106); this re-audit confirms that no acceptance criterion regressed.

## Acceptance Criteria Inventory

Six criteria (AC-1 to AC-6), all in checkbox format, all already checked in `issue.md`.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC-1 | PASS | `git diff origin/main...HEAD -- .github/dependabot.yml` hunk 1 adds `- dependency-name: "@types/vscode"` (no `update-types`, no `versions`) to the `/` npm entry; the `typescript` major-version ignore on the preceding lines is unchanged. Contract tests `[root]` pass (re-run: 5 passed). |
| AC-2 | PASS | Diff hunk 2 adds the same item to the `/extensions/drm-copilot` npm entry; the `typescript` ignore is retained. Contract tests `[extension]` pass. |
| AC-3 | PASS | The diff shows two pure insertions (`+2/-0`) that fall before the `/packages/mcp-server` and `github-actions` entries; neither entry is touched. `git diff 8c89607ef HEAD -- .github` is empty. Corroborated by `evidence/regression-testing/dependabot-yml-diff.2026-10-16T00-20.md` and `evidence/qa-gates/scope-boundary-files.2026-10-16T01-26.md`. |
| AC-4 | PASS | The module exists at `tests/scripts/dev_tools/test_dependabot_config_contract.py`, reads the real file via `read_text` and `yaml.safe_load`, uses no temporary files, asserts the all-update-types ignore for both directories (over all matching items), and asserts `len(entries) == 2`. |
| AC-5 | PASS | `evidence/regression-testing/dependabot-contract-red.2026-10-16T00-18.md` records exit 1 with exactly the two `@types/vscode` tests failing for the missing-ignore message; `dependabot-contract-green.2026-10-16T00-20.md` and `remediation-r2-targeted-green.2026-10-16T01-18.md` record `5 passed`. |
| AC-6 | PASS | `evidence/qa-gates/` (stamp 01-26) records Black, Ruff, Pyright, and targeted Pytest at exit 0 and the full suite at 7099 passed, 0 failed. This review recomputed coverage from `artifacts/python/lcov.info`: 93.80% lines and 88.11% branches, above the 85% and 75% gates, and re-ran Black, Ruff, Pyright, and the targeted test on the test file. `pyproject.toml` is not in the diff, so the gates are unchanged. |

## Summary

6 of 6 criteria PASS. The residual risk recorded in `issue.md` (runtime behavior of a bare ignore inside a Dependabot group) is not verifiable in-repo and is covered by the post-merge `@dependabot recreate` check on PRs #832 and #833, which is explicitly not an acceptance criterion.

## Acceptance Criteria Check-off

No change was needed: all six items were already `[x]` and this review confirms each. No CI-dependent criterion exists, so none is pending CI.

### Acceptance Criteria Status
- Source: `docs/features/active/dependabot-bumps-types-vscode-past-engines-940/issue.md`
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: none

## Findings

### Blocking

None.

### Non-blocking

None new. See `code-review.2026-10-16T01-29.md`. CR-N5 (items[0] in the `typescript` retention test) is resolved at lines 100-106 of `tests/scripts/dev_tools/test_dependabot_config_contract.py`. Post-merge action: comment `@dependabot recreate` on PRs #832 and #833 and confirm the regenerated PRs omit `@types/vscode`.

## Assumptions

- The stamp `2026-10-16T01-29` is read from the UTC host clock (`date -u`) and sorts after the prior review set (stamp 2026-10-16T01-03).
- Coverage was assessed from the existing `artifacts/python/lcov.info`; coverage generation was not rerun.
- CI status at HEAD is not available because no pull request exists yet.
