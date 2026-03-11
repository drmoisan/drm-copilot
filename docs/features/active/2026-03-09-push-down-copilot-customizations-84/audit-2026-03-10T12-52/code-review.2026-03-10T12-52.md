# Code Review: push-down-copilot-customizations (#84)

## Executive Summary

This working tree adds a dedicated one-way publisher at `scripts/dev_tools/push_down_copilot_customizations.py`, extends `extensions/drm-copilot` with placeholder command registrations, adds focused Python and Jest tests, and updates feature documentation/README to describe the new workflow.

**Feature folder selection rule:** Used the user-provided active feature folder `docs/features/active/2026-03-09-push-down-copilot-customizations-84`, which also matches issue `#84` in the branch name and the active scoping docs.

**Important scope assumption:** After refreshing `artifacts/pr_context.summary.txt`, the canonical PR context reported no committed diff between `development` and `feature/push-down-copilot-customizations-84`. I therefore reviewed the current **working tree diff** relative to `origin/development` as the authoritative branch state.

### Top 3 risks

1. `scripts/dev_tools/push_down_copilot_customizations.py` is too large for repo policy (`510` lines), which makes future maintenance and auditing harder.
2. The new Python module lands at **89%** coverage on the reviewer rerun, below the repo threshold for new modules.
3. The implementation is narrower than the spec in one place: it assumes UTF-8 text for every copied file, while the spec says non-text files should bypass rewrite safely.

### PR readiness recommendation

**No-Go / Needs revision** until the policy gaps are remediated. The feature behavior is close, and all rerun toolchains passed, but the line-limit and coverage requirements are explicit merge gates in this repository.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/dev_tools/push_down_copilot_customizations.py` | file-level (`line 45` through `line 614`) | New production module exceeds the repo’s 500-line limit. | Split the file into cohesive modules, e.g. filesystem adapter, rewrite catalog/renderer, and CLI/orchestration. Keep `main()` and the public entry point stable. | The repo policy applies the 500-line cap to production code, tests, and reusable scripts. Large single-file orchestration makes future review and change isolation harder. | Reviewer measurement: `scripts/dev_tools/push_down_copilot_customizations.py` = `510` lines; major sections begin at lines `45`, `95`, `483`, and `614`. |
| Major | `scripts/dev_tools/push_down_copilot_customizations.py` | coverage result for module | New-module coverage is **89%**, below the required `>=90%`. | Add targeted tests for uncovered branches (real-FS adapter paths, CLI/main behavior, and uncovered artifact/Protocol-related lines) or refactor executable stubs out of the measured module. | Repo policy requires new modules/classes/methods to target `>=90%` coverage. The branch-wide total improved, but the new module still misses the bar. | Reviewer Pytest coverage rerun: `809 passed`; `scripts/dev_tools/push_down_copilot_customizations.py` reported `194 stmts / 22 miss / 89%`; branch total `82%`. |
| Minor | `scripts/dev_tools/push_down_copilot_customizations.py` | lines `111`, `139`, `144` | The implementation hard-codes UTF-8 text I/O for every copied file, which is narrower than the spec’s non-text bypass behavior. | Either implement a binary-safe pass-through branch with explicit summary reporting, or tighten the spec/docs to state that the scoped roots are markdown-only by contract. | Current scoped roots only contain `.md` files, so this is not a present blocker. Still, the current code path will fail if assets or other non-text files are later introduced under the scoped `.github` trees. | Line `111` says the trees are “text-based repository content”; lines `139` and `144` unconditionally call `read_text(..., encoding="utf-8")` and `write_text(..., encoding="utf-8")`. |
| Minor | `docs/features/active/2026-03-09-push-down-copilot-customizations-84/plan.2026-03-09T23-14.md` | lines `90-91` | The plan still leaves `P1-T10` unchecked and references a fail-before evidence file that is not present, even though the green-path Jest test now exists and passes. | Update the plan to reflect actual execution state and add or explicitly waive the missing `p1-t10-placeholder-error...md` regression evidence. | Supporting docs are part of the repo contract. This is small, but stale plan state makes later audits and handoffs less trustworthy. | `P1-T10` is unchecked at lines `90-91`; `P4-T10` is checked at line `162`; `evidence/regression-testing/` has no `p1-t10-placeholder-error.2026-03-09T23-14.md`. |

## Typed Python Audit

### What looks good

- No new `Any` usage surfaced in the new Python module.
- The design uses `Protocol`, `TypedDict`, and frozen slot-based dataclasses appropriately.
- Public helpers and data shapes are strongly typed and documented.
- Input validation exists for invalid destination handling before copy begins.
- Tests use an in-memory filesystem instead of prohibited temp files.

### Risks / deviations

- **Coverage threshold miss:** The new module is `89%`, which is below the required `>=90%` target for new modules.
- **Module-size violation:** The new publisher file is `510` lines.
- **CLI exit ergonomics remain lightly tested:** `main()` is exercised via direct calls in unit tests, but reviewer coverage shows uncovered CLI/guard paths remain.

## Test Quality Audit

- **Deterministic:** PASS — Python uses an in-memory filesystem; TypeScript uses targeted mocks.
- **Isolated:** PASS — No network, temp files, or live VS Code host required.
- **Readable:** PASS — Test names are descriptive and assertions are direct.
- **Regression-first evidence:** PARTIAL — Red-path evidence exists for `P1-T1` through `P1-T9`, but the plan-required `P1-T10` fail-before artifact is missing.
- **Coverage gate:** FAIL — branch total is healthy (`82%`), but the new Python module does not reach `90%`.

## Security and Correctness Notes

- No secrets or credentials were introduced.
- The new Python publisher does not shell out to subprocesses.
- The new placeholder commands fail with explicit deterministic messages rather than dead-path errors.
- The destination validation is explicit and blocks copy when the destination is not a valid directory.
- Future-proofing gap: the copy path is text-only even though the spec speaks about non-text bypass behavior.

## Research Log

No external research was needed for this review. All findings are based on repository policy files, the active feature docs, refreshed PR-context artifacts, the working tree diff, and reviewer rerun command output.

## Reviewer Verification

### Commands rerun during review

- `git status --short`
- `git diff --name-status origin/development -- .`
- `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
- `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- `npm --prefix extensions/drm-copilot run lint`
- `npm --prefix extensions/drm-copilot run typecheck`
- `npm --prefix extensions/drm-copilot run test:unit`
- `poetry run black --check .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

### Outcome summary

- TypeScript reviewer loop: **PASS** (`4` suites, `39` tests)
- Python reviewer loop: **PASS** (`809` tests, total coverage `82%`)
- Merge readiness: **FAIL** pending remediation of the oversized Python module, the new-module coverage shortfall, and the stale plan/evidence entry.
