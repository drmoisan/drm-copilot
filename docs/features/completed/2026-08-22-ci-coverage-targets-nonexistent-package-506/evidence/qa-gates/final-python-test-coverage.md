# Phase 4 — Final Python Test and Coverage Gate (P4-T4)

Timestamp: 2026-08-25T22-29

Task: [P4-T4]
Class: command task — one command, four required fields.
Working directory: the resolved repository root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by P0-T2)

This is stage 4 of the four-stage uninterrupted toolchain pass P4-T1 through P4-T4. Per the
Phase 4 preamble this artifact records the **successful** pass and overwrites the record of the
attempt that preceded it. One restart preceded this pass; its cause — a gitignored runtime
batch-budget state file under `.claude/state/` that broke the pre-existing push-down parity test —
is recorded in
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/batch-budget-clear-before-toolchain-restart.md`.

---

## Command 1 of 1 — run the suite with coverage

Timestamp: 2026-08-25T22-29
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Output Summary:

- **Exit code 0**, captured directly from the command with no pipe consumer between the command
  and the status.
- **Summary line, verbatim:**

```text
====================== 4136 passed, 5 skipped in 14.48s =======================
```

- **Passed: 4136. Failed: 0. Skipped: 5.** Zero tests failed, which is the task's acceptance
  condition. The five skips are the pre-existing declared skips in
  `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py`, unrelated to this work item and
  identical in number to the five recorded at baseline by P0-T6.
- The passed count rose from the baseline 4121 to 4136, a difference of **15**, which is exactly
  the six workflow-contract tests added by Phase 1 plus the nine checker unit tests added by
  Phase 3.

### The verbatim `TOTAL` row

```text
TOTAL                                                               15014   1104   5506    560    91%
```

| Cell | Value | What it is |
| --- | --- | --- |
| Stmts | **15014** | Total measured statements |
| Miss | **1104** | Missed statements |
| Branch | **5506** | Total measured branches |
| BrPart | **560** | Partially-taken branches — **not** the missing-branch count |
| Cover | **91%** | **The combined statements-plus-branches ratio, NOT line coverage** |

**The `Cover` cell is not a policy metric.** With branch measurement on, the terminal reporter's
`Cover` column reports the combined statements-plus-branches ratio, and its `BrPart` column is the
partial-branch count rather than the missing-branch count. Neither of the two policy metrics —
line coverage against the 85% floor and branch coverage against the 75% floor, both defined in
`.claude/rules/quality-tiers.md` — is printed by this reporter at all. Both are read from the JSON
report by P4-T5 and recorded in
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-command-coverage-json.md`.

No placeholder value appears anywhere in this artifact; every figure above is the literal value
the reporter printed.

---

## Acceptance

| Condition | Result |
| --- | --- |
| The command exits 0 | PASS — `EXIT_CODE: 0` |
| Zero tests failed | PASS — 4136 passed, 0 failed, 5 skipped |
| `Output Summary:` records the verbatim `TOTAL` row with its five numeric cells | PASS — 15014 / 1104 / 5506 / 560 / 91% |
| The cover value is labelled as the combined statements-plus-branches ratio, not as line coverage | PASS |
| No placeholder value is accepted | PASS |

Verdict: PASS.
