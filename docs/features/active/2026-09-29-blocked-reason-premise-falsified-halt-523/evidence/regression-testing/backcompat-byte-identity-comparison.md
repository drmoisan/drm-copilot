# P7-T5 AC-13 Back-Compat Byte-Identity Comparison

Timestamp: 2026-09-30T11-02
Command: comparison of recorded artifacts (no new command); sources listed below.
EXIT_CODE: 0
Output Summary: All six cited runs passed with equal before/after counts, all twelve back-compat hashes matched, and the P7-T1 numstat removed count was `0`. Production code was untouched during capture (P1-T11).

Result: BYTE-IDENTICAL

## Cited runs (before / after)

| Runtime | Before | After | Before count | After count | Failed (before / after) |
|---|---|---|---|---|---|
| Python | P1-T4 `backcompat-python-before.md` | P7-T2 `backcompat-python-after.md` | 37 passed | 37 passed | 0 / 0 |
| TypeScript (Jest) | P1-T7 `backcompat-jest-before.md` | P7-T3 `backcompat-jest-after.md` | 28 passed | 28 passed | 0 / 0 |
| PowerShell (Pester) | P1-T10 `backcompat-pester-before.md` | P7-T4 `backcompat-pester-after.md` | 28 passed | 28 passed | 0 / 0 |

## Capture integrity

- P1-T11 `backcompat-production-untouched.md`: both the anchored `git diff --name-only` and `git status --porcelain` over `scripts/dev_tools`, `extensions/drm-copilot/src`, `.claude/lib`, and `extensions/drm-copilot/resources` printed nothing at capture time, so the expected lists were derived from the unmodified validators.
- P1-T12 `backcompat-hashes-before.md` / P7-T1 `backcompat-hashes-after.md`: all twelve SHA256 hashes (nine fixtures, `tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json`, and the TypeScript and PowerShell back-compat test files) are equal before and after.
- P7-T1 numstat against capture commit `1101c89c9e97a82e1ff35d8ec08b640e9b5b2f77`: `91	0` for `tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py` (additions only; removed count `0`).

## Modes covered per runtime

- Python: plain, require_complete, require_pr_creation_ready, require_model_routing (9 stems x 4 modes = 36 cases plus the count test).
- TypeScript: plain, require_complete, require_model_routing (9 stems x 3 modes = 27 cases plus the count case).
- PowerShell: plain, require_complete including the M family, PR readiness (9 stems x 3 modes = 27 cases plus the count case).

Stems: `absent`, `null`, `none`, `spawn_agent_unavailable`, `delegation_launch_failed`, `delegate_no_receipt`, `delegate_contract_incomplete`, `validator_failed`, `user_requested_stop`. Each case asserts ordered equality of the full, unfiltered error list against the expected file captured before the change.
