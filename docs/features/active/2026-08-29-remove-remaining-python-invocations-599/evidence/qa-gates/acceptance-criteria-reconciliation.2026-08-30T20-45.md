# P6-T17 — Acceptance-criteria reconciliation

Timestamp: 2026-08-30T20-45

Work mode: `full-feature`. The tracking contract therefore requires the check-off to land in the
requirement documents themselves, not only in this artifact. Both documents were edited; the
only change made to either was the two-character `- [ ]` -> `- [x]` at the start of a criterion
line. No criterion text was changed and no criterion was added or removed.

## Clause (h) — scoping-is-live demonstration

| Measurement | Command | Value |
| --- | --- | --- |
| `spec.md` checkboxes inside `## Acceptance Criteria` | `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' spec.md \| grep -c '^- \[[ x]\]'` | **20** |
| `spec.md` checkboxes whole-file | `grep -c '^- \[[ x]\]' spec.md` | **24** |

The two differ by exactly 4, which are the four `## Definition of Done` items at `spec.md:641`
and following. Those four remain `- [ ]` and are outside this task's edit scope, which is the
`## Acceptance Criteria` section only.

This comparison is what makes the section scoping in clauses (d) and (e) falsifiable. A
whole-file scanner and a correctly-scoped one return the same number on a document with no
out-of-section checkboxes and are indistinguishable there; the 20-versus-24 difference proves the
scoping was applied rather than merely described.

## Clauses (d) and (e) — counts agree with the PASS totals

| Document | In-section `- [x]` after edit | Criteria marked PASS below | Agree |
| --- | --- | --- | --- |
| `spec.md` | 20 | 20 | yes |
| `user-story.md` | 13 | 13 | yes |

## Clause (c)

No criterion is marked BLOCKED, so the "BLOCKED criteria remain `- [ ]`" obligation is satisfied
vacuously. Every criterion in both documents has an evidence artifact and is marked PASS.

The edit diff is 33 insertions and 33 deletions across the two files — 20 + 13 lines, one
two-character change each — which is consistent with no text change beyond the checkbox.

## `spec.md` — 20 criteria

| # | Line | Criterion (abbreviated) | Task | Evidence | Result |
| --- | --- | --- | --- | --- | --- |
| 1 | 556 | Both bash modules exist with the stated responsibilities | P1-T1..T7, P2-T1..T9 | `qa-gates/bash-lane-assertion-p1t1..p1t6.2026-08-30T06-46.md`, `qa-gates/bash-entry-point-lint.2026-08-30T07-10.md` | PASS |
| 2 | 559 | `parallel_lane_assertion.bats` passes, incl. the named case | P1-T1..T6 | `regression-testing/bash-unit-suite.2026-08-30T07-10.md` | PASS |
| 3 | 563 | Case asserting the finding-class tokens | P1-T1 | `qa-gates/bash-lane-assertion-p1t1.2026-08-30T06-46.md` | PASS |
| 4 | 566 | Case pinning divergence class 3 | P1-T4 | `qa-gates/bash-lane-assertion-p1t4.2026-08-30T06-46.md` | PASS |
| 5 | 576 | Case asserting the out-of-subset refusal line | P2-T6 | `regression-testing/bash-unit-suite.2026-08-30T07-10.md` | PASS |
| 6 | 580 | Both parity lanes pass | P3-T1..T9 | `regression-testing/parity-lanes.2026-08-30T11-39.md` | PASS |
| 7 | 585 | Parity case asserts each of the four `kind` tokens | P3-T5 | `regression-testing/parity-lanes.2026-08-30T11-39.md` | PASS |
| 8 | 588 | Parity case asserts `expected_status` is 0 for every fixture | P3-T6 | `regression-testing/parity-lanes.2026-08-30T11-39.md` | PASS |
| 9 | 591 | No file under `.claude/lib/bash/` sources the diagnostic | P6-T16 | `qa-gates/no-production-consumer.2026-08-30T20-45.md` | PASS |
| 10 | 595 | `parallel_payload_only.bats` passes with a payload-only case | P4-T8 | `other/bundle-mirror-parity.2026-08-30T07-47.md` | PASS |
| 11 | 598 | `git grep` for `python -m scripts.dev_tools.` returns exactly one match | P5-T1..T3 | `qa-gates/invocation-sites.2026-08-30T12-10.md` | PASS |
| 12 | 608 | No `parallel_lane_assertion` reference in `parallel-plan/SKILL.md` | P5-T3 | `qa-gates/invocation-sites.2026-08-30T12-10.md` | PASS |
| 13 | 611 | `parallel-planner.md` `tools:` list contains the bash grant | P5-T4 | `qa-gates/planner-persona-edit.2026-08-30T12-10.md` | PASS (see line-span note) |
| 14 | 616 | No `checkpoint-validator CLI fallback` in `parallel-orchestrator.md` | P5-T5 | `qa-gates/invocation-sites.2026-08-30T12-10.md` | PASS |
| 15 | 619 | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes | P5-T11 | `regression-testing/pushdown-contracts.2026-08-30T12-10.md` | PASS (clause (f)) |
| 16 | 621 | `core.json` lists both new bash files | P4-T5 | `other/bundle-mirror-parity.2026-08-30T07-47.md` | PASS |
| 17 | 625 | Entry-point enumerations are current | P4-T6, P4-T7 | `other/bundle-mirror-parity.2026-08-30T07-47.md` | PASS (see line-span note) |
| 18 | 629 | Bash line coverage >= 85% overall and per new file | P6-T4, P6-T5 | `qa-gates/final-bash-coverage.2026-08-30T20-45.md`, `qa-gates/bash-new-file-coverage.2026-08-30T20-45.md` | PASS |
| 19 | 633 | `wc -l` at most 500 for each new file | P6-T19 | `qa-gates/new-file-sizes.2026-08-30T20-45.md` | PASS |
| 20 | 635 | No changed line in the non-goal files | P6-T15 | `qa-gates/non-goals-untouched.2026-08-30T20-45.md` | PASS |

## `user-story.md` — 13 criteria

| # | Line | Criterion (abbreviated) | Task | Evidence | Result |
| --- | --- | --- | --- | --- | --- |
| 1 | 119 | Planner with no interpreter completes the seeding step | P4-T8 | `other/bundle-mirror-parity.2026-08-30T07-47.md` | PASS |
| 2 | 123 | Same report as the Python reference over a shared corpus | P3-T1..T9 | `regression-testing/parity-lanes.2026-08-30T11-39.md` | PASS |
| 3 | 129 | Corpus exercises the full reporting surface | P3-T5 | `regression-testing/parity-lanes.2026-08-30T11-39.md` | PASS |
| 4 | 134 | Advisory-only semantics pinned by tests | P2-T5..T7 | `regression-testing/bash-unit-suite.2026-08-30T07-10.md` | PASS |
| 5 | 140 | Planner procedure and grants agree | P5-T4 | `qa-gates/planner-persona-edit.2026-08-30T12-10.md` | PASS (see line-span note) |
| 6 | 147 | Orchestrator offered only runnable spellings | P5-T5 | `qa-gates/invocation-sites.2026-08-30T12-10.md` | PASS |
| 7 | 156 | Grant rationale no longer names a deleted consumer | P5-T5 | `qa-gates/invocation-sites.2026-08-30T12-10.md` | PASS |
| 8 | 159 | Everything to mirror is mirrored | P5-T11 | `regression-testing/pushdown-contracts.2026-08-30T12-10.md` | PASS (clause (f)) |
| 9 | 162 | Both new files survive a manifest-scoped push-down | P4-T5, P4-T8 | `other/bundle-mirror-parity.2026-08-30T07-47.md` | PASS |
| 10 | 167 | Entry-point enumerations are current | P4-T6, P4-T7 | `other/bundle-mirror-parity.2026-08-30T07-47.md` | PASS (see line-span note) |
| 11 | 171 | Deliberate behavior difference is observable | P1-T4, P3-T7 | `qa-gates/bash-lane-assertion-p1t4.2026-08-30T06-46.md`, `regression-testing/parity-lanes.2026-08-30T11-39.md` | PASS |
| 12 | 178 | `shell-qc.sh check` exits 0 and coverage bar met | P6-T2, P6-T4 | `qa-gates/final-bash-check.2026-08-30T20-45.md`, `qa-gates/final-bash-coverage.2026-08-30T20-45.md` | PASS |
| 13 | 183 | Non-goals stay untouched | P6-T15 | `qa-gates/non-goals-untouched.2026-08-30T20-45.md` | PASS |

## Clause (f) — the two push-down criteria

`spec.md:619` and `user-story.md:159` assert that
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes. Clause (f) makes their
disposition depend on the exit code **P5-T11 recorded for that node ID**, not on any later run.

`evidence/regression-testing/pushdown-contracts.2026-08-30T12-10.md` records, for the explicit
single-node-ID invocation of that test, `EXIT_CODE: 0` with `1 passed in 0.17s`. The accepted
non-zero outcome anticipated by open issue #510 did not occur: that artifact records
`ls -a .claude/state` reporting `No such file or directory` on the worktree, so no gitignored
state file existed for `list_scoped_files` to walk.

The condition for PASS is therefore met and **both criteria are marked PASS** and checked off.
The BLOCKED limb of clause (f) does not apply.

This is corroborated but not established by P6-T9, which ran the same suite again in this phase
and recorded `EXIT_CODE: 0` with all 11 cases passing. P6-T9's own artifact records why #510 did
not fire in this phase either: the only file created in Phase 6 was a `.bats` suite, which does
not match the `\.py$` trigger of the batch-budget hook
(`.claude/hooks/enforce-python-batch-budget.ps1:181-183`).

The seven-file `cmp -s` loop P5-T11 recorded, also `EXIT_CODE: 0`, is the durable half of that
gate and is independent of `.claude/state/` entirely. It is noted here as supporting evidence
that the mirrored files are byte-identical.

## Clause (g) — criteria whose cited line spans this feature's own edits move

Four criteria carry literal line spans that this feature's edits shift. Each is marked PASS **on
its substance**, its criterion text is left unedited, and the shift is recorded here as a
line-span note.

| Criterion | Cited span | What moved it | Substance asserted by |
| --- | --- | --- | --- |
| `spec.md:625-628` | `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:242-244` | P4-T6 places its new entry below line 244 | P4-T6 clause (b), which names content rather than a line number |
| `user-story.md:167-170` | `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:451-453` | P4-T7 places its new entry below line 453 | P4-T7's `git grep -c` clause |
| `spec.md:611-615` | `.claude/agents/parallel-planner.md:147-156` (the PowerShell paragraph) | The single `tools:` entry P5-T4 adds inside lines 5-20 moves it down one line | P5-T4 clauses (a) through (d) and (f) |
| `user-story.md:140-146` | `.claude/agents/parallel-planner.md:185-186` (the stale sentence) | That same `tools:` addition, plus the bash-paragraph documentation P5-T4 adds at lines 158-168 | P5-T4 clauses (a) through (d) and (f) |

In every case the evidence clause names content rather than a line number, so the substance is
verifiable independently of the shifted span. This follows the pattern established in P5-T4's
"Reconciliation note for P6-T17".

## Scope note — the Phase 6 remediation

The P6-T5 remediation added `tests/shell/report_lane_assertion_dispatch.bats`. It introduces no
new acceptance criterion and satisfies none on its own. Its effect on this reconciliation is
confined to criterion 18 (`spec.md:629`), whose per-file coverage clause it is what makes
satisfiable: before the remediation `.claude/lib/bash/report-lane-assertion.sh` measured
`line-rate="0.814"`, below the 85% floor that criterion asserts. Criterion 2 (`spec.md:559`) is
unaffected, because it names `tests/shell/parallel_lane_assertion.bats` specifically and that
file was not modified.

## Definition of Done

The four `## Definition of Done` items at `spec.md:641` and following remain `- [ ]`. They are
outside the `## Acceptance Criteria` section and outside this task's stated edit scope, which is
the acceptance criteria only. Their disposition belongs to the feature review and the epic owner,
not to this task. Item 4 in particular ("the residual recorded in Known Residual is reported to
the epic owner") is discharged by `evidence/other/known-residual.2026-08-30T20-45.md` but its
acknowledgement is the epic owner's action, not this executor's.
