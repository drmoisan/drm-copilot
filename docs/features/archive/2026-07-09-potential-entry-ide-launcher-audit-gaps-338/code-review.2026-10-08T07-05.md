# Code Review: IDE launcher audit gaps (#338)

---

**Review Date:** 2026-10-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338`
**Feature Folder Selection Rule:** Folder suffix matches issue number 338 in the branch name.
**Base Branch:** `origin/main` (merge base `6dac65b0930b299dc7b3c3925a607735a05fca35`)
**Head Branch:** `bug/potential-entry-ide-launcher-audit-gaps-338` (`f8203e46ffad15fe27fd8a4f1ed774c6c640b323`)
**Review Type:** Initial review (structural regeneration; findings preserved)

---

## Executive Summary

The change removes a stray source fragment from two `_resolve_code_cli()` docstrings and adds deterministic unit tests for previously uncovered launcher branches in Python and TypeScript. No executable production code changed. The reviewed scope is two docstring edits, four test files, and feature docs and evidence.

**What changed:**
In `scripts/dev_tools/new_potential_bug_entry.py` and `scripts/dev_tools/new_active_feature_folder_io.py`, the line `[code_cmd, "--reuse-window", *[file_path.as_posix() ...]],` was replaced with a blank line after the docstring summary. Behavior is unchanged, and the stray token no longer appears anywhere outside `docs/` (git grep excluding docs returned no matches). Tests added or extended: `tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py` (new, 142 lines), `tests/scripts/dev_tools/test_new_potential_bug_entry.py` (+111), `extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts` (new, 290 lines), `extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts` (+239).

**Top 3 risks:**
1. AC-3 names `io.test.ts` but the new default-helper tests are in the sibling `io-launcher.test.ts` (CR-1); a literal rerun of the AC-3 command does not execute them.
2. Tests mutate process-global `process.platform` and `process.env`; they are restored correctly but depend on ordering discipline within a worker (CR-2).
3. Live Windows desktop-UI window reuse is not observed; it is accepted as a `scope_change` per AC-5.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; all five acceptance criteria PASS with evidence.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts` | file-level (AC-3 placement) | CR-1: AC-3 names `test/lib/new-active-feature-folder/io.test.ts` as the location of the new default-helper tests, but they were placed in the sibling `io-launcher.test.ts` because `io.test.ts` is 455 lines. The AC-3 command as written does not run `io-launcher.test.ts`. | Update AC-3 wording at the next planning pass; no code change needed. | Keeps the AC command aligned with where the tests live while respecting the 500-line limit. | Closure record; `evidence/regression-testing/ac3-jest-new-tests.2026-10-08T02-45.md`; full suite in `evidence/qa-gates/ts-jest-coverage.2026-10-08T02-50.md` |
| Minor | `extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts` | `process.platform` / `process.env` handling | CR-2: Process-global mutation is restored in `finally` blocks but depends on test ordering discipline within a single worker. | No action required; safe as written. | Global state mutation is a latent flakiness source if restoration is later removed. | Reviewer inspection of the file |
| Info | repository (outside `docs/`) | n/a | CR-3: The repository contains no bundled mirror copies of the two Python modules at this commit (the issue text mentions bundled copies); the token search across the repo outside `docs/` is clean. | None. | Confirms no additional copies need the docstring fix. | `git grep` for `as_posix() for file_path in files` excluding `docs/`; `evidence/qa-gates/ac1-stray-token-final.2026-10-08T02-51.md` |
| Info | `scripts/dev_tools/new_potential_bug_entry.py`, `scripts/dev_tools/new_active_feature_folder_io.py` | `_resolve_code_cli()` docstring | Production change is a one-line docstring edit in each module; behavior unchanged. Verdict: correct and minimal. | None. | No executable code changed, so no new-code coverage is computable. | Branch diff; `evidence/qa-gates/python-ruff.2026-10-08T02-48.md` EXIT_CODE 0 |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The stray fragment was removed with a minimal edit; no executable lines changed.

#### Typing and API notes

- No new public Python API surface was added. Pyright exited 0 on the four changed files.

#### Error handling and logging

- No production error handling or logging changed.

### TypeScript implementation audit

#### What changed well

- No TypeScript production source changed; only tests were added, using existing injection seams.

#### Type safety and maintainability

- No `any` usage or suppressions found in the launcher test files. ESLint and the type check exited 0.

#### Error handling and logging

- No production boundary or logging changes.

---

## Test Quality Audit

Automated verification evidence is present: baseline and post-change coverage for all four launcher files, a full TypeScript suite run, and a Python launcher run. Remaining gap: no live Windows desktop observation (accepted per AC-5).

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py` (142 lines) — Arrange-Act-Assert structure, descriptive names and docstrings, `monkeypatch` for `shutil.which` and `subprocess.run`, injected `which`/`env` lookups for CLI resolution, and `pytest.mark.parametrize` over `_INSIDERS_SIGNAL_NAMES` so each signal variable is driven individually. Covers backslash conversion, multi-file ordering, both fallback directions with probe-order assertions, negative Insiders detection, and the default env lookup (set and blank). No temp files, no clock use.
- `tests/scripts/dev_tools/test_new_potential_bug_entry.py` (+111) — parallel coverage for the sibling module.
- `extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts` (290 lines) — mocks `node:fs`, restores `PATH`, `PATHEXT`, and `process.platform` in `finally` blocks, injects the runner via `FakeCommandRunner`.
- `extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts` (+239) — covers backslash conversion, symmetric fallback, and signal variables.
- `evidence/qa-gates/coverage-delta.2026-10-08T02-51.md` — shows all four files above 85% line and 75% branch with no regression from baseline.

### Quality assessment prompts

- **Determinism:** `node:fs` mocked; subprocess and `shutil.which` patched; no clock or sleep usage.
- **Isolation:** each test targets a single launcher behavior.
- **Speed:** Python launcher run 109 passed in 0.97s; TypeScript full suite 254 suites passed.
- **Diagnostics:** assertions on argv lists and probe order identify the failing branch; names follow `test_launcher_*` and `launcher-gap:` and enable targeted runs.

Best-practice checks: simplicity and separation of concerns hold (no production logic added); all changed test files are below 500 lines (415, 142, 392, 290).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or tokens in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | Production unchanged; tests patch `subprocess.run` and never spawn processes. |
| Input validation at boundaries | N/A | No boundary code changed. |
| Error handling remains explicit | ✅ PASS | No production handler changed. |
| Configuration / path handling is safe | ✅ PASS | Tests mock `node:fs`; no temporary files or real paths used. |

---

## Research Log

No external research was required. The review relied on the branch diff, the feature-folder evidence, and the repository policy rules.

---

## Verdict

Approve. The production change is a minimal, behavior-neutral docstring correction, and the added tests are deterministic, isolated, and drive the previously untested launcher branches. The Findings Table contains no Blocker or Major items; CR-1 and CR-2 are Minor and need no code change. The change is ready for normal PR flow.
