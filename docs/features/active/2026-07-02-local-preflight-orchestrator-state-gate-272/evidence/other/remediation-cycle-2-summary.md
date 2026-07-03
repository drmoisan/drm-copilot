## Remediation Cycle 2 Closeout Summary (Issue #272)

Timestamp: 2026-07-02T22-05

### Disposition of the single Blocking finding

**Finding:** `--require-complete` is structurally impossible to satisfy before `gh pr create` is ever called, permanently deadlocking the action the hook is supposed to gate (`remediation/2026-07-02T22-05/remediation-inputs.md`).

**Resolution:** A new, additive `--require-pr-creation-ready` CLI flag was added to the `orchestrator-state` subcommand of `scripts/dev_tools/validate_orchestration_artifacts.py`, backed by a new pure function `validate_orchestrator_state_pr_creation_readiness` (extracted to `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` to respect the 500-line cap). The new flag validates only that upstream steps 5-8 are not pending/blocked, `blocked_reason` is clear, and the two override lists are empty when present — it never calls `validate_completion_pr_gate`, `_validate_completion_ci_gate`, `validate_phase_completeness`, or `validate_routing_contract`, so it never requires `ci_gate`, `pr_gate`, or routing-contract delegation receipts. Both `.claude/hooks/enforce-pr-author-skill.ps1`'s default `$Invoker` (all three copies) and the documented orchestrator `pr_author_preflight` step now reference this new flag instead of `--require-complete`.

**Status: RESOLVED for the flag's own logic, with one residual note (see below).**

### `--require-complete` unchanged confirmation

- `scripts/dev_tools/validate_orchestrator_state.py`'s `if require_complete:` block was not edited; the new `require_pr_creation_ready` handling is a sibling conditional block appended after it.
- `tests/scripts/dev_tools/test_validate_orchestrator_state.py` and `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` (the two files carrying `--require-complete`'s existing test coverage) were not edited in this cycle, per the plan's Do-Not-Do constraint.
- Direct re-run of `--require-complete` against the real live checkpoint (`require-complete-unchanged-confirmation.2026-07-02T22-05.md`) reproduces the identical 24-error output captured in the Phase 0 fail-before evidence, confirming no behavior change.
- `poetry run pytest ... -k "require_complete or complete"` (`phase6-require-complete-pytest-regression.md`): 11 passed, 0 failed.

### Residual note: real live checkpoint does not reach exit 0 under the new flag, for a reason outside this cycle's authorized edit scope

Phase 6 (`pr-creation-readiness-real-checkpoint-pass.2026-07-02T22-05.md`) found that `--require-pr-creation-ready` against the real, live `artifacts/orchestration/orchestrator-state.json` fails with three errors, not the two the plan anticipated:
1. `Checkpoint missing required key: relativeFile`
2. `Checkpoint missing required key: long-name`
3. `Checkpoint has invalid step5_status: complete`

The plan's P6-T2 authorizes a checkpoint repair (adding `relativeFile`/`long-name`) only when the failure is **solely** attributable to those two missing keys. Here a third, independent defect is also present: `step5_status` holds the literal value `"complete"`, which is not a member of `VALID_STEP_STATUS` (the valid form is `"completed"`). This is an unconditional enum-value check that runs regardless of which CLI flag is passed — it is unrelated to the `--require-complete`/`--require-pr-creation-ready` split this remediation cycle addresses, and it predates this cycle's edits (the same value already caused an identical error under `--require-complete` in both the Phase 0 fail-before run and the Phase 6 re-confirmation run). Correcting `step5_status`'s value is not a "field addition" and is not one of the two fields (`relativeFile`, `long-name`) the plan's Do-Not-Do section authorizes editing, so per the plan's literal P6-T2 branching ("If P6-T1 ... fails for any other reason, record 'no repair applicable' and make no checkpoint edit"), no checkpoint edit was made.

To confirm the new flag's own logic is sound (not merely asserted), an in-memory diagnostic (no file write) applied the same three field values a fully-authorized repair would have used and confirmed `validate_orchestrator_state_text(..., require_pr_creation_ready=True)` returns `[]` (zero errors) against the real checkpoint's actual step5-8/blocked_reason/override-list content. This isolates the residual failure to the one unrelated, out-of-scope `step5_status` typo, not to any defect in the new PR-creation-readiness check.

**Escalation:** the real, live checkpoint's `step5_status: "complete"` value is a pre-existing, orthogonal defect (likely a typo relative to the `VALID_STEP_STATUS` enum's `"completed"`) that should be corrected through the repository's normal orchestrator checkpoint-writing path, not through this remediation cycle's narrowly-scoped edit authorization. This is reported here for the calling orchestrator's awareness; no code, test, or documentation change addresses it in this cycle, consistent with the plan's explicit Do-Not-Do constraints.

### Links to evidence produced in Phases 0-7

- Phase 0: `evidence/remediation-baseline/phase0-instructions-read.md`, `evidence/remediation-baseline/branch-commit-baseline.md`, `evidence/remediation-baseline/python-pytest-baseline.md`, `evidence/remediation-baseline/poshqc-test-baseline.md`, `evidence/regression-testing/fail-before.pr-creation-readiness.2026-07-02T22-05.md`.
- Phase 1: `evidence/qa-gates/pr-creation-readiness-file-size-check.md`, `evidence/qa-gates/phase1-black.md`, `evidence/qa-gates/phase1-ruff.md`, `evidence/qa-gates/phase1-pyright.md`.
- Phase 2: `evidence/qa-gates/phase2-pytest-new-tests.md`.
- Phase 3: `evidence/qa-gates/phase3-hook-line-count-root.md`, `evidence/qa-gates/phase3-hook-line-count-claude-customizations.md`, `evidence/qa-gates/phase3-hook-line-count-codex.md`, `evidence/qa-gates/phase3-hook-diff-scope.md`.
- Phase 4: `evidence/qa-gates/phase4-pester-flag-reference-check.md`, `evidence/qa-gates/phase4-poshqc-format.md`, `evidence/qa-gates/phase4-poshqc-analyze.md`.
- Phase 5: `evidence/qa-gates/phase5-docs-flag-reference-check.md`, `evidence/qa-gates/phase5-mirror-parity.md`.
- Phase 6: `evidence/regression-testing/pr-creation-readiness-real-checkpoint-pass.2026-07-02T22-05.md`, `evidence/regression-testing/live-checkpoint-preserved-confirmation.2026-07-02T22-05.md`, `evidence/regression-testing/require-complete-unchanged-confirmation.2026-07-02T22-05.md`, `evidence/qa-gates/phase6-require-complete-pytest-regression.md`.
- Phase 7: `evidence/qa-gates/final-black.md`, `evidence/qa-gates/final-ruff.md`, `evidence/qa-gates/final-pyright.md`, `evidence/qa-gates/final-pytest-coverage.md`, `evidence/qa-gates/final-poshqc-format.md`, `evidence/qa-gates/final-poshqc-analyze.md`, `evidence/qa-gates/final-poshqc-coverage.md`, `evidence/qa-gates/final-mirror-parity.md`, `evidence/qa-gates/final-diff-scope-confirmation.md`, this summary.

### Deviations from literal plan text (disclosed)

1. **P3-T2/P3-T5 clarifying-clause wording differs between the root/`.claude` mirror and the Codex mirror.** The Codex copy started this cycle at exactly 500 lines (zero margin); the 3-line clarifying clause applied to the root/`.claude` mirror pushed the Codex copy to 501 lines, so the Codex copy's clause was trimmed to 2 lines per the plan's own explicit P3-T11 remediation instruction ("trim the clarifying clause further ... shorten wording only"). Documented in `evidence/qa-gates/phase3-hook-line-count-codex.md`.
2. **P5-T1's clause could not literally contain the string `--require-complete`** without failing P5-T9's zero-match grep check across the same six files. Rephrased to convey the same meaning ("the validator's full-lifecycle completion flag") without the literal substring. Documented in `evidence/qa-gates/phase5-docs-flag-reference-check.md`.
3. **P2-T9's test function name was shortened** from `test_pr_creation_readiness_does_not_require_ci_or_pr_gate_or_pr_author_receipt` to `test_pr_creation_readiness_excludes_ci_pr_gate_and_pr_author_receipt` to satisfy Ruff's `E501` line-length limit after Black's line-wrap of the original name still exceeded 88 columns. Same scenario, same assertions. Documented in `evidence/qa-gates/final-ruff.md`.
4. **P6-T3 does not confirm exit code 0** against the real live checkpoint, per the residual note above. This is a plan-anticipated outcome (P6-T2 explicitly provides for the "no repair applicable" branch) rather than an unaddressed defect in the new flag itself.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/spec.md` `## Acceptance Criteria` (work mode `full-bug`).
- This remediation cycle's scope is the single Blocking finding in `remediation/2026-07-02T22-05/remediation-inputs.md`; it does not re-evaluate every original spec AC, all of which were already checked `[x]` (except the last-item, live-orchestrator-execution AC, which is explicitly deferred by its own text) prior to this cycle's entry. This cycle added a new `## Addendum` section to `spec.md` documenting the corrected mechanism; no existing AC checkbox was altered.
