# Code Review — Issue #940 (Dependabot bumps @types/vscode past engines.vscode), re-audit R4

**Branch:** `bug/dependabot-bumps-types-vscode-past-engines-940`
**Base:** `main`; merge-base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
**Head reviewed:** `8c89607ef8ae2844f427178929669ec0fa7be712`
**Files reviewed:** `.github/dependabot.yml`, `tests/scripts/dev_tools/test_dependabot_config_contract.py`

## Total Blocking Findings: 0

## Executive Summary

The production change is unchanged from the prior review: two inserted lines, each `- dependency-name: "@types/vscode"`, appended to the `ignore` list of the `/` and `/extensions/drm-copilot` npm entries. Remediation cycle 1 edited only the test module. Both earlier non-blocking observations are resolved: the parse is cached once per session, and the `@types/vscode` assertion now checks every matching item. One new non-blocking observation (CR-N5) concerns the `typescript` retention test, which still inspects only the first matching item. No defect requires remediation.

## Configuration Review (`.github/dependabot.yml`)

- Diff `origin/main...HEAD`: two hunks, both pure insertions (`+2/-0`), placed after the existing `typescript` major-version ignore in each entry. Existing ignores are retained.
- The `/packages/mcp-server` and `github-actions` entries are outside both hunks.
- `evidence/regression-testing/remediation-r1-dependabot-yml-untouched.2026-10-16T00-52.md` and `evidence/qa-gates/scope-boundary-files.2026-10-16T00-58.md` record that cycle 1 did not touch the file (`2 0` numstat unchanged).

## Test Design Review (`test_dependabot_config_contract.py`)

- `REPO_ROOT = Path(__file__).resolve().parents[3]` resolves to the repository root for a file at `tests/scripts/dev_tools/`. Verified by the passing run.
- `load_target_npm_entries` (line 29-48) is decorated with `@functools.cache`, returns an immutable tuple, isolates the untyped `yaml.safe_load` boundary, and documents that the result must not be mutated. The prior request named `functools.lru_cache(maxsize=None)`; `functools.cache` is the equivalent form for this Python version and satisfies the intent.
- `test_npm_entry_ignores_types_vscode_for_all_update_types` (lines 71-87) keeps the `lacks an ignore item for` message for the no-item case and adds `any("update-types" not in item and "versions" not in item for item in items)` with the message `no unrestricted ignore item for`. The check is now independent of item order.
- `test_exactly_two_target_npm_entries_are_checked` still prevents the parametrized tests from passing vacuously.
- Cycle 1 evidence: `remediation-r1-targeted-green.2026-10-16T00-52.md` lists all five node IDs passing; this review re-ran the module (5 passed in 0.16s), Black (unchanged), and Ruff (clean).
- No temporary files, clock, RNG, or network access. The cache does not break test independence because the cached value is read-only and derived from a committed file.

## Resolution of Prior Observations

- CR-N1 (items[0]-only assertion): resolved at lines 84-87.
- CR-N2 (repeated YAML parse): resolved at lines 29-30.
- CR-N3 (evidence timestamps dated 2026-10-16): no change needed; unchanged.
- CR-N4 (`SCRATCH/940/` token in evidence): no change needed; unchanged. This review recomputed coverage from `artifacts/python/lcov.info` (93.80% lines, 88.11% branches).

## Findings Table

Blocking findings: 0. Non-blocking findings: 1 new (CR-N5).

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking | `tests/scripts/dev_tools/test_dependabot_config_contract.py` | line 100 | CR-N5: `test_npm_entry_retains_typescript_major_ignore` asserts `items[0].get("update-types") == [SEMVER_MAJOR_UPDATE_TYPE]`, which depends on the order of matching `typescript` ignore items. | Optionally assert with `any(...)` over all `typescript` items, as done for `@types/vscode`. | No present effect: each target entry has exactly one `typescript` ignore item, so the test passes and detects removal of the item. The order dependence matches the class of CR-N1 and is outside the cycle 1 scope. | `.github/dependabot.yml` shows one `typescript` item per target entry; 5 passed. |

## Positive Observations

- Cycle 1 made the two requested changes only, in one test file, with a baseline, a targeted green run, a full toolchain loop with no restart, and a recorded scope-boundary check.
- Minimal blast radius: only the two files named in `issue.md` changed outside the feature folder.
- Plan and evidence trail is complete and each artifact records its command and exit code.
