# Final QC — acceptance-criteria reconciliation — [P8-T13]

Timestamp: 2026-08-26T10-52
Task: [P8-T13]
Command: reconciliation of `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/spec.md` against the evidence on disk, plus the verification commands quoted per row below
EXIT_CODE: 0

Output Summary: **37 criteria reconciled, 37 PASS, 0 FAIL.** Checkboxes checked in `spec.md`: **37**. Checkboxes left unchecked: **0**. 37 + 0 = **37**. Of the 37 checked, **8** were already checked by earlier phases (AC20, AC22 through AC28) and **29** were changed from unchecked to checked by this task. No criterion text was rewritten; only checkbox state changed. The four impact radios at lines 21 through 24 and the logs checkbox at line 63 are not acceptance criteria and were not touched.

Numbering follows the acceptance-criteria coverage map at the end of `plan.2026-08-23T23-22.md`, which maps AC1 through AC37 to the criteria in document order.

## Merge base

The anchored diffs below use `1e991b86`, the merge base of this branch with `main`.

## Reconciliation table

| AC | Criterion | Establishing evidence | Verdict |
| --- | --- | --- | --- |
| AC1 | G7 positive | `tests/scripts/dev_tools/test_plan_gate_observability.py::test_g7_reports_write_mode_command_without_observation_marker` and its TypeScript twin; both in the 28-passed run of `evidence/qa-gates/python-new-module-coverage.2026-08-24T00-00.md` and the 2710-passed run of `evidence/qa-gates/typescript-test-final.2026-08-24T00-00.md` | PASS |
| AC2 | G7 exoneration | `tests/scripts/dev_tools/test_plan_gate_observability.py::test_g7_exonerates_task_carrying_observation_marker` and its TypeScript twin | PASS |
| AC3 | G7 register membership | `tests/scripts/dev_tools/test_plan_gate_observability.py::test_g7_every_register_entry_is_exercised_by_a_fixture`; the register carries six entries including `poshqc-analyze-autofix` and `poshqc-suite` | PASS |
| AC4 | G7 register exclusions | `tests/scripts/dev_tools/test_plan_gate_observability.py::test_g7_ignores_git_add_and_npm_ci_exclusions`; `grep -c -F "run_poshqc_analyze_autofix" .claude/rules/plan-acceptance-gates.md` reports 1, and the exclusions with reasons are recorded there by [P7-T2] | PASS |
| AC5 | G7 register wording | `grep -c -F "rewrites tracked source" .claude/rules/plan-acceptance-gates.md` reports 2 | PASS |
| AC6 | G8 positive and negative | `test_g8_reports_bare_git_diff_without_ref_operand`, `test_g8_reports_pathspec_only_git_diff`, `test_g8_ignores_git_diff_with_ref_operand`, `test_g8_ignores_git_diff_with_cached_flag`, all in `tests/scripts/dev_tools/test_plan_gate_observability.py`, plus TypeScript twins | PASS |
| AC7 | G8 pairing exoneration | `tests/scripts/dev_tools/test_plan_gate_observability.py::test_g8_exonerates_task_carrying_a_second_diff_or_status_span` and its twin | PASS |
| AC8 | G8b positive and exoneration | `test_g8b_reports_anchored_name_only_diff_without_companion`, `test_g8b_exonerates_task_carrying_staging_span`, `test_g8b_exonerates_task_carrying_porcelain_status_span`, plus twins | PASS |
| AC9 | G9 positive and negative | `test_g9_reports_coverage_command_without_terminal_reporter`, `test_g9_ignores_command_carrying_terminal_reporter`, `test_g9_ignores_command_carrying_fail_under_threshold`, plus twins | PASS |
| AC10 | G9 message content | `tests/scripts/dev_tools/test_plan_gate_observability.py::test_g9_message_states_the_terminal_reporter_remedy` and its twin | PASS |
| AC11 | G9 graceful degradation | `tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py::test_g9_skipped_when_repository_seam_raises` and `::test_g9_skipped_when_repository_seam_reports_nonzero_exit`, plus twins; both assert zero findings and that no exception escaped | PASS |
| AC12 | Context-free split preserved | `tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py::test_blocking_channel_is_unchanged_without_context` and `::test_g9_does_not_run_without_context`, plus twins; byte-identity reference in `evidence/baseline/plan-gate-preexisting-output.2026-08-24T00-00.md`, asserted by [P4-T7] | PASS |
| AC13 | Extraction-floor limitation pinned by test | `tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py::test_single_token_tool_name_span_produces_no_findings`; `git diff 1e991b86 -- tests/scripts/dev_tools/test_plan_gate_commands.py` shows exactly two removed lines, both inside `test_extract_plan_commands_returns_exact_record_fields`, so `test_extract_plan_commands_skips_command_without_operand` is unmodified and passes; recorded in `evidence/qa-gates/extraction-floor-untouched.2026-08-24T00-00.md` | PASS |
| AC14 | Attribution boundaries | `test_write_mode_command_in_document_preamble_produces_no_findings`, `test_write_mode_command_in_phase_preamble_produces_no_findings`, `test_write_mode_command_after_heading_produces_no_findings`, plus twins | PASS |
| AC15 | Existing G1 through G6 output unchanged | `git diff --name-only 1e991b86` lists none of the four named test files; `git diff 1e991b86 -- tests/scripts/dev_tools/test_plan_gate_parity.py extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts \| grep "^-"` produces **no output**, so no pre-existing expected finding string was modified or deleted; `evidence/qa-gates/existing-gates-unchanged.2026-08-24T00-00.md` and `evidence/regression-testing/g1-fixture-isolation.2026-08-24T00-00.md` | PASS |
| AC16 | Attributed task text is additive | `task_text: str = ""` is a trailing defaulted field; `test_extract_plan_commands_populates_task_text_from_the_owning_task` and `test_extract_plan_commands_leaves_task_text_empty_outside_any_window` exist in both runtimes and pass | PASS |
| AC17 | File-size limit respected | Measured line counts, all at most 500 — see the table below; includes `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` at 437 | PASS |
| AC18 | Message-formatting prohibitions hold | `grep -c -F "repr(" scripts/dev_tools/plan_gate_observability.py` reports 0; `grep -c "!r" scripts/dev_tools/plan_gate_observability.py` reports 0; `grep -c -F "pythonRepr(" extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` reports 0; both modules are registered in the parity gate-module lists by [P4-T1]; `evidence/qa-gates/message-formatting-prohibitions.2026-08-24T00-00.md` | PASS |
| AC19 | Apostrophe parity fixtures | `grep -c -F "APOSTROPHE" tests/scripts/dev_tools/test_plan_gate_parity.py` reports 20 and the case-insensitive TypeScript count reports 22; the eight fixtures added by [P4-T3] assert the same expected string in both runtimes | PASS |
| AC20 | Severity constants exist and agree | `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py -k severity` reports 5 passed, recorded by [P4-T2] and re-verified by [P6-T5]; already checked before this task | PASS |
| AC21 | No dispatch or MCP contract change | `git diff --name-only 1e991b86 -- scripts/dev_tools/validate_orchestration_artifacts.py extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` produces **no output**; the full `git diff --name-only 1e991b86` list contains no schema file; `evidence/qa-gates/dispatch-untouched.2026-08-24T00-00.md`, with the `mcp-plan-gate-warning-projection` suite passing | PASS |
| AC22 | Corpus measurement recorded | `evidence/qa-gates/corpus-measurement.2026-08-24T00-00.md` and `evidence/qa-gates/corpus-measurement-decision-rule.2026-08-24T00-00.md`; already checked | PASS |
| AC23 | Vacuity declared where it applies | `evidence/qa-gates/corpus-measurement.2026-08-24T00-00.md`, [P6-T4]; already checked | PASS |
| AC24 | Shipped severity follows the measurement | `evidence/qa-gates/severity-assignment.2026-08-24T00-00.md`, [P6-T5]; already checked | PASS |
| AC25 | Measurement driver deleted, no sweep introduced | `evidence/qa-gates/measurement-driver-deleted.2026-08-24T00-00.md` and `evidence/regression-testing/regression-driver-deleted.2026-08-24T00-00.md`; the full branch-diff name list contains no file under `.github/workflows`; already checked | PASS |
| AC26 | No suppression surface introduced | `evidence/qa-gates/no-suppression-surface.2026-08-24T00-00.md`; already checked | PASS |
| AC27 | Six-revision regression run recorded | `evidence/regression-testing/six-revision-extraction.2026-08-24T00-00.md` and `evidence/regression-testing/six-revision-regression.2026-08-24T00-00.md`; already checked | PASS |
| AC28 | The rules exercise the case they were written for | `evidence/regression-testing/six-revision-regression.2026-08-24T00-00.md`: total 6 at `e2aa6446` against total 1 at `5a8ede0f`; already checked | PASS |
| AC29 | Corrected forms do not fire | `evidence/regression-testing/corrected-forms-no-fire.2026-08-24T00-00.md`, re-derived by [P5-T5] with marker-split field extraction; 7 corrected forms, each with 0 findings from G7, G8, G8b, and G9; vacuity guard passes at 75 of 75 and 75 of 76 | PASS |
| AC30 | Rule file amended | `grep -c -F "G8b" .claude/rules/plan-acceptance-gates.md` reports 10; `"G9"` reports 10; `"corpus-measurement.2026-08-24T00-00.md"` reports 5; `"single-token"` reports 3; `"executor-choice"` reports 1 | PASS |
| AC31 | Authoring skill amended | `grep -c -F "success-case output" .claude/skills/atomic-plan-contract/SKILL.md` reports 2; `"G8b"` reports 2 | PASS |
| AC32 | Bundled mirrors byte-identical | SHA-256 digests below are equal in both pairs; the push-down contract test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` **passes** in the [P8-T4] run (`4195 passed, 0 failed`) | PASS |
| AC33 | Stale citation corrected | `grep -c -F "docs/features/completed/2026-08-17-.../g5-corpus-measurement.2026-08-20T12-02.md"` reports 1 and the `active/` spelling reports 0, in `.claude/rules/plan-acceptance-gates.md`; the mirror carries the same correction because its digest is identical | PASS |
| AC34 | Coverage thresholds met | See the coverage table below; both new modules and both invoking modules exceed 85 line and 75 branch in both runtimes, read from printed terminal reports obtained by passing a terminal reporter explicitly | PASS |
| AC35 | Full toolchain passes in a single pass | The second Phase 8 pass completed all eight stages without error and without any stage rewriting a file — [P8-T1] through [P8-T9]. See the pass note below | PASS |
| AC36 | This feature's own gates observe more than an exit code | `evidence/qa-gates/write-mode-observations.2026-08-24T00-00.md`, [P8-T11]: three write-mode tools, each with a quoted non-exit-code observation and the artifact path it was read from | PASS |
| AC37 | Mode integrity | The feature folder contains `evidence/`, `issue.md`, `plan.2026-08-23T23-22.md`, `research/`, and `spec.md`, and **no `user-story.md`**; `issue.md` line 12 carries `- Work Mode: full-bug`; `evidence/baseline/mode-integrity.2026-08-24T00-00.md` | PASS |

## AC17 — measured line counts

| File | Lines | Limit |
| --- | --- | --- |
| `scripts/dev_tools/plan_gate_observability.py` | 477 | 500 |
| `scripts/dev_tools/plan_gate_discrimination.py` | 392 | 500 |
| `scripts/dev_tools/plan_gate_commands.py` | 365 | 500 |
| `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` | 494 | 500 |
| `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` | 284 | 500 |
| `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` | 443 | 500 |
| `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` | 437 | 500 |
| `tests/scripts/dev_tools/test_plan_gate_observability.py` | 427 | 500 |
| `tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py` | 333 | 500 |
| `tests/scripts/dev_tools/test_plan_gate_parity.py` | 493 | 500 |
| `tests/scripts/dev_tools/test_plan_gate_commands.py` | 297 | 500 |
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py` | 449 | 500 |
| `extensions/drm-copilot/test/lib/validate/plan-gate-observability.test.ts` | 394 | 500 |
| `extensions/drm-copilot/test/lib/validate/plan-gate-observability-boundaries.test.ts` | 327 | 500 |
| `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts` | 389 | 500 |
| `extensions/drm-copilot/test/lib/validate/plan-gate-commands.test.ts` | 245 | 500 |
| `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-plan-gates.test.ts` | 274 | 500 |
| `extensions/drm-copilot/jest.config.cjs` | 245 | 500 |

The largest file is `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` at 494 lines, six under the limit.

## AC32 — SHA-256 digests

```text
ffd4eae4d7d5816694ab634fb4a390d1e7e39a24df2c3c1172066f759b547689  .claude/rules/plan-acceptance-gates.md
ffd4eae4d7d5816694ab634fb4a390d1e7e39a24df2c3c1172066f759b547689  extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md
203d11bd19b19131cb2ab7e4e405596ad91edd33880394d84bdae5bb6fe8905a  .claude/skills/atomic-plan-contract/SKILL.md
203d11bd19b19131cb2ab7e4e405596ad91edd33880394d84bdae5bb6fe8905a  extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
```

Both pairs are equal, so both mirrors are byte-identical to their repository originals.

## AC34 — coverage figures

Python figures are derived from the printed `term-missing` columns, which report one combined `Cover` value: line coverage is `(Stmts - Miss) / Stmts` and branch coverage is `(Branch - BrPart) / Branch`.

| Module | Runtime | Line % | Branch % | Line limit | Branch limit |
| --- | --- | --- | --- | --- | --- |
| `plan_gate_observability.py` | Python | 97.12 (135/139) | 91.94 (57/62) | 85 | 75 |
| `plan_gate_discrimination.py` | Python | 97.71 (128/131) | 86.54 (45/52) | 85 | 75 |
| `plan_gate_commands.py` | Python | 98.99 (98/99) | 94.44 (34/36) | 85 | 75 |
| `plan-gate-observability.ts` | TypeScript | 98.38 | 91.91 | 85 | 75 |
| `plan-gate-discrimination.ts` | TypeScript | 100 | 98.14 | 85 | 75 |
| `plan-gate-commands.ts` | TypeScript | 95.93 | 84.88 | 85 | 75 |

**Changed-line detail, recorded so the claim is precise rather than sweeping.** In `scripts/dev_tools/plan_gate_discrimination.py` the change is one import and one four-line rule-group call at lines 385 through 388; the module's uncovered lines are 209, 248, and 277, none of which is a changed line, so every changed line in that module is covered. In `scripts/dev_tools/plan_gate_commands.py` two of the changed constructs are not fully exercised: the false branch of line 325 (`325->327`, a fence delimiter encountered outside any task window) and line 332 (the `continue` for a fenced line outside any task window). Both are outside-any-window paths that produce no record. They are recorded here rather than glossed; the module's line and branch figures, 98.99 and 94.44, remain well above the 85 and 75 thresholds, which is what this criterion requires.

## AC35 — the single-pass claim, stated precisely

Phase 8 ran twice. The **first** pass reached [P8-T7], where `npm run lint` exited 2 with `Error [ERR_MODULE_NOT_FOUND]: Cannot find package '@eslint/js'`. The cause was an incomplete dependency tree, not a lint violation. `npm ci` restored it (`added 457 packages, and audited 458 packages in 6s`), writing only into the git-ignored `node_modules` directory.

Because a stage failed, the phase preamble required a restart from [P8-T1]. The **second** pass is the one this criterion is evaluated against, and it satisfies the criterion literally: all eight stages — Python format, lint, type-check, test; TypeScript format, lint, typecheck, test — completed without error and without any stage rewriting a file, in one uninterrupted pass. The evidence that no stage rewrote a file is recorded per stage and is not the exit code:

| Stage | Non-exit-code evidence of no rewrite |
| --- | --- |
| `poetry run black .` | summary line `455 files left unchanged.`; no line containing `reformatted` |
| `poetry run ruff check .` | final line `All checks passed!`; no line containing `Fixed` |
| `poetry run pyright` | read-only analyser; `0 errors, 0 warnings, 0 informations` |
| `poetry run pytest ...` | `4195 passed, 0 failed`; test runner writes only under the artifacts tree |
| `npm run format` | 408 processed-file lines, 408 carrying `(unchanged)`; `git status --porcelain -- extensions/drm-copilot` empty |
| `npm run lint` | `eslint` invoked without `--fix`; no diagnostic line emitted |
| `npm run typecheck` | `tsc` invoked with `--noEmit`; no diagnostic line emitted |
| `npm test -- --coverage` | `2710 passed, 0 failed` across 199 suites |

## Checkbox accounting

| Quantity | Integer |
| --- | --- |
| Criteria reconciled | 37 |
| Verdict PASS | 37 |
| Verdict FAIL | 0 |
| Checkboxes checked in `spec.md` | **37** |
| Checkboxes left unchecked in `spec.md` | **0** |
| Sum | **37** |
| Of the 37 checked: already checked by earlier phases | 8 (AC20, AC22, AC23, AC24, AC25, AC26, AC27, AC28) |
| Of the 37 checked: changed from unchecked to checked by this task | 29 |

The 29 changed by this task are AC1 through AC19, AC21, AC29, AC30 through AC37.

No criterion text was rewritten and no criterion was added. The four impact radios (`Blocker`, `High`, `Medium`, `Low`) and the `Attached minimal logs or screenshot` checkbox sit outside the acceptance-criteria sections, are not acceptance criteria, and were not modified. The three test-plan bullets were already checked and are likewise not among the 37.

## Verdict

**PASS.** All 37 acceptance criteria reconcile to PASS against evidence on disk. No FAIL row exists, so the plan outcome is not remediation-required.
