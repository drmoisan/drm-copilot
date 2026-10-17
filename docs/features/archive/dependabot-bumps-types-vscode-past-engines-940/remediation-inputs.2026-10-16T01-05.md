# Remediation Inputs - Issue #940 (cycle 2, non-blocking observation CR-N5)

Source: `code-review.2026-10-16T01-03.md` and `remediation-inputs.2026-10-16T01-03.md` (re-audit of cycle 1, Review-Verdict: PASS, 0 blocking findings). The orchestrator fixes related non-blocking observations inside the item before the pull request is opened. CR-N5 is the same class as the fixed observation R1-1, in the same test file that this item added.

Review-Verdict: REMEDIATION_REQUIRED

## Finding R2-1

- Severity: Non-blocking (observation), fixed in-item
- Remediability: autonomous
- Location: `tests/scripts/dev_tools/test_dependabot_config_contract.py`, `test_npm_entry_retains_typescript_major_ignore` (line 100 in the cycle 1 head: `assert items[0].get("update-types") == [SEMVER_MAJOR_UPDATE_TYPE]`)
- Problem: the assertion inspects only `items[0]` of the matching `typescript` ignore items, so its result depends on item order. It is the same order-dependence that cycle 1 removed from the `@types/vscode` test.
- Required change: assert over all matching `typescript` ignore items, for example `assert any(item.get("update-types") == [SEMVER_MAJOR_UPDATE_TYPE] for item in items), f"..."`, where the message begins with the text `no typescript ignore item restricted to`. Keep the existing `assert items, ...` check above it unchanged, so the message `lacks a typescript ignore` is preserved. After the edit the file must contain no `items[0]` occurrence. Make no other change to the file.
- Verification: the five test node IDs still pass against the unchanged `.github/dependabot.yml`; format, lint, type-check, the full suite and the coverage gates remain green; `.github/dependabot.yml` is byte-identical to its state at the cycle 1 head.

## Observations not remediated (no defect)

- None. The cycle 1 observations 3 and 4 remain as recorded in `remediation-inputs.2026-10-16T00-37.md`.
