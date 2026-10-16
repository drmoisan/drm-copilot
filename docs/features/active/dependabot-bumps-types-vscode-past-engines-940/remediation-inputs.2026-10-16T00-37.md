# Remediation Inputs - Issue #940 (cycle 1, non-blocking observations)

Source: `code-review.2026-10-16T00-40.md` (Review-Verdict: PASS, 0 blocking findings). The orchestrator fixes related non-blocking observations inside the item before the pull request is opened. This cycle covers observations 1 and 2, both in the test file this item added.

Review-Verdict: REMEDIATION_REQUIRED

## Finding R1-1

- Severity: Non-blocking (observation), fixed in-item
- Remediability: autonomous
- Location: `tests/scripts/dev_tools/test_dependabot_config_contract.py` lines 75-82 (`test_npm_entry_ignores_types_vscode_for_all_update_types`)
- Problem: the assertions inspect only `items[0]`. If an entry listed a restricted `@types/vscode` item (one carrying `update-types` or `versions`) before an unrestricted one, the test would fail on a configuration that does ignore all update types. If a restricted item were the only `@types/vscode` item, the test would correctly fail, but the check is order-dependent.
- Required change: assert that at least one `@types/vscode` ignore item carries neither an `update-types` key nor a `versions` key (`any(...)` over all matching items), instead of inspecting `items[0]`. Keep the existing message that begins with `npm entry for directory` and contains `lacks an ignore item for @types/vscode` for the case where no item exists. Give the new assertion message the text `no unrestricted ignore item for`.
- Verification: `test_npm_entry_ignores_types_vscode_for_all_update_types[root]` and `[extension]` still pass against the current `.github/dependabot.yml`; the other three tests are unchanged and pass.

## Finding R1-2

- Severity: Non-blocking (observation), fixed in-item
- Remediability: autonomous
- Location: `tests/scripts/dev_tools/test_dependabot_config_contract.py` lines 28-56 (`load_target_npm_entries`, `npm_entry_for`)
- Problem: `load_target_npm_entries` reads and parses `.github/dependabot.yml` on every call (five parses per run).
- Required change: wrap `load_target_npm_entries` in `functools.lru_cache(maxsize=None)` so the file is parsed once per test session. The function takes no arguments and the tests never mutate the returned mappings.
- Verification: the five tests still pass; format, lint, type-check, and the full suite remain green.

## Observations not remediated (no defect)

- Observation 3 (evidence timestamps dated 2026-10-16 against a 2026-10-15 plan): the run crossed midnight UTC and each stamp is the host clock value read at write time, which the evidence conventions require. Nothing to change.
- Observation 4 (the `SCRATCH/940/` token in `coverage-thresholds-final` evidence): the plan mandates the token so that no host path appears in committed artifacts. The reviewer independently recomputed coverage. Nothing to change.
