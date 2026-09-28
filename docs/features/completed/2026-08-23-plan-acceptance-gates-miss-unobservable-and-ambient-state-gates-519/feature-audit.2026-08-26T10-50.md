# Feature Audit — issue #519, plan acceptance gates G7/G8/G8b/G9

- Timestamp: 2026-08-26T10-50
- Branch: `bug/plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519-r3`
- Branch head: `2aa37434`; base `main` at `1e991b86`
- Work mode: `full-bug` (`issue.md` line 12) — **`spec.md` is the sole acceptance-criteria
  source**; `user-story.md` correctly absent
- AC source: `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/spec.md`,
  `## Acceptance Criteria` section, 37 checkbox criteria

## Method

Every one of the 37 criteria was evaluated independently against evidence on disk. Where a
criterion is checkable by command, I ran the command myself rather than reading the executor's
recorded output; where it is checkable only by reading, I read the artifact and the code it
cites. The executor's reconciliation artifact
(`evidence/qa-gates/ac-reconciliation.2026-08-24T00-00.md`) was read *after* forming each verdict
and is cited only where it agrees or where the divergence matters.

I checked nothing off and unchecked nothing. All 37 boxes were already `[x]` on arrival.

## Headline

**37 of 37 criteria PASS. 0 FAIL. 0 unearned check-offs. 0 blocking findings.**

Six criteria carry an observation — a caveat, a narrower-than-expected satisfaction, or a
disclosed limitation — recorded in the notes column and expanded below. None of the six rises to
PARTIAL: in each case the criterion **as written** is met by evidence I verified directly.

## Independent verification performed

| Check | Command | Result |
|---|---|---|
| Merge base | `git merge-base HEAD 1e991b86` | `1e991b86` — base confirmed |
| Plan-gate tests, Python | `poetry run pytest <7 files> -q --no-cov` | `92 passed` |
| Plan-gate tests, TypeScript | `npx jest test/lib/validate/plan-gate` | `7 suites, 81 passed` |
| Full Python suite | `poetry run pytest -q --no-cov` | `1 failed (issue #510 noise), 4194 passed, 5 skipped` |
| Full TypeScript suite | `npm test` | `199 suites, 2710 passed` |
| Corpus measurement reproduction | own driver over `docs/features/**/plan*.md` | G7 466, G8 82, G8b 19, G9 8 — **exact match** |
| Rules fire end to end | own probe plan via shipped entry point + real context | 4 warnings, one per rule |
| Feature's own plan | same, on `plan.2026-08-23T23-22.md` | `BLOCKING 0, WARNINGS 0` |
| Mirror byte-identity | `git hash-object` on both pairs | equal hashes |
| Toolchain | black --check / ruff --no-fix / pyright / tsc / eslint | all clean |
| Evidence locations | `validate_evidence_locations.py --root .` | `EXIT=0` |
| Coverage artifact | `grep -E "^(LF\|LH\|BRF\|BRH):" artifacts/python/lcov.info` | `139/135/62/57` |

## Criterion-by-criterion evaluation

### Rule behaviour (AC1–AC14)

| # | Criterion | Verdict | Evidence verified |
|---|---|---|---|
| AC1 | G7 positive | **PASS** | `test_plan_gate_observability.py:150-168` asserts the exact finding string, opening `[P1-T1]` and rendering the span in backticks; TS twin `plan-gate-observability.test.ts:138`. Both pass in my runs. Independently reproduced: my probe plan produced the G7 finding verbatim. |
| AC2 | G7 exoneration | **PASS** | `test_plan_gate_observability.py:171-184`; the same fixture plus the marker `left unchanged` yields `findings == []`. TS twin at :158. |
| AC3 | G7 register membership | **PASS** | `WRITE_MODE_REGISTER` carries `poshqc-analyze-autofix` (`plan_gate_observability.py:189-194`) and `poshqc-suite` (:195-200), neither of which appears in `issue.md`'s inventory. `test_g7_every_register_entry_is_exercised_by_a_fixture` asserts `set(_REGISTER_FIXTURES) == registered` and `len(registered) == 6`, so an entry cannot be added without a fixture. TS twin at :172-190. |
| AC4 | G7 register exclusions | **PASS** | `git add` and `npm ci` are absent from the register; `test_g7_ignores_git_add_and_npm_ci_exclusions` asserts a task invoking both with no marker yields `findings == []`. The rule file records both exclusions with a distinct reason for each (staging carries no acceptance condition and is already a G8b companion; `npm ci` writes only git-ignored output). Verified by reading the diff. |
| AC5 | G7 register wording | **PASS** | The rule file's membership-criterion heading states "**A tool belongs in the write-mode register when it rewrites tracked source and still exits 0 after rewriting.**" A dedicated subsection "Two writers that are not register members and are not exclusions" names the Python test runner and the PoshQC test tool and states both write under the artifacts tree without rewriting tracked source. `grep -c -F "rewrites tracked source"` → 2. |
| AC6 | G8 positive and negative | **PASS** | Four tests: bare `git diff` (exact string asserted), pathspec-without-ref (`git diff -- scripts/dev_tools`), ref operand (zero findings), `--cached` (zero findings). `test_plan_gate_observability.py:220-284` plus TS twins :206-264. |
| AC7 | G8 pairing exoneration | **PASS** | `test_g8_exonerates_task_carrying_a_second_diff_or_status_span`; TS :266. The self-exoneration trap is closed by removing the offending span once before the search (`plan_gate_observability.py:314`), which I verified reading the code. |
| AC8 | G8b positive and exoneration | **PASS** | Positive asserts the exact string; two exonerations, one per companion form (`git add`, `git status --porcelain`). `:303-354`; TS `:280-327`. |
| AC9 | G9 positive and negative | **PASS** | Positive asserts the exact string against the project's real `addopts`; terminal-reporter and `--cov-fail-under` each yield zero. `:357-407`; TS `:329-375`. |
| AC10 | G9 message content | **PASS** | `test_g9_message_states_the_terminal_reporter_remedy` asserts the presence of `Add --cov-report=term-missing.` and `no coverage table is printed`, and the **absence** of `unfalsifiable` and `cannot fail`. The negative half is what the criterion actually turns on and it is present. |
| AC11 | G9 graceful degradation | **PASS** | Two distinct injections: `_RaisingGitRepository` (every method raises) and `_NonZeroExitGitRepository` (every method returns the adapter's empty answer). Both assert both channels empty; no exception escapes, which the test comment correctly identifies as itself the assertion. `test_plan_gate_observability_boundaries.py:158-183`; TS `:161-189`. |
| AC12 | Context-free split preserved | **PASS** | `test_blocking_channel_is_unchanged_without_context` asserts `blocking_g1 == [_EXPECTED_BLOCKING_G1]` against a string transcribed from the [P0-T13] baseline artifact, asserts `blocking_g4 == []`, and asserts an empty blocking channel for the four seam-requiring fixtures. `test_g9_does_not_run_without_context` covers the G9 half. Six fixtures, byte-exact. |
| AC13 | Extraction-floor limitation pinned | **PASS** | `test_single_token_tool_name_span_produces_no_findings` asserts both channels empty for the span `run_poshqc_format`. The floor test is unmodified — verified directly: `git diff 1e991b86...HEAD -- tests/scripts/dev_tools/test_plan_gate_commands.py \| grep "^-"` returns exactly two lines, both inside `test_extract_plan_commands_returns_exact_record_fields`, so `test_extract_plan_commands_skips_command_without_operand` is untouched. It passes in my run. |
| AC14 | Attribution boundaries | **PASS** | Three tests, one per boundary (document preamble, phase preamble, after an intervening `####` heading), each asserting both channels empty. `:229-288`; TS `:233-287`. |

### Invariants and parity (AC15–AC21)

| # | Criterion | Verdict | Evidence verified |
|---|---|---|---|
| AC15 | Existing G1–G6 output unchanged | **PASS** (see note O-1) | `git diff --stat 1e991b86...HEAD -- <the four named test files>` returns **no output**; all four pass in my full-suite run. `git diff 1e991b86...HEAD -- <both parity test files> \| grep "^-"` returns no output, so no pre-existing expected finding string was modified or deleted. |
| AC16 | Attributed task text is additive | **PASS** (see note O-2) | Python: `task_text: str = ""` is trailing with a default, asserted directly by `assert PlanCommand.__dataclass_fields__["task_text"].default == ""`. Two tests per runtime: `..._populates_task_text_from_the_owning_task` asserts the whole-window text and asserts the next task's title is *not* in it; `..._leaves_task_text_empty_outside_any_window` asserts `commands == []`. |
| AC17 | File-size limit respected | **PASS** | Independently measured with `wc -l`. Largest is `plan-gate-observability.ts` at **494**. `plan-gate-rules.ts` is **437**, unmodified. Every changed source, test, and config file is at or under 500. |
| AC18 | Message-formatting prohibitions hold | **PASS** | Ran the three greps myself: `repr(` → 0, `!r` → 0 in `plan_gate_observability.py`; `pythonRepr(` → 0 in `plan-gate-observability.ts`. Both modules registered in their runtime's prohibition list (`test_plan_gate_parity.py:45-49`, `plan-gate-parity.test.ts:314-319`). Both prohibition tests pass. |
| AC19 | Apostrophe parity fixtures | **PASS** | All four new rules render an offending value and all four have an apostrophe-bearing fixture: `PARITY_G7/G8/G8B/G9_APOSTROPHE`, duplicated verbatim in both runtimes with identical expected strings built by `_expected_g7`/`expectedG7` and siblings. Read both files side by side. |
| AC20 | Severity constants exist and agree | **PASS** | Four constants per runtime; four parity assertions in the shape of the existing G5 assertion (`test_plan_gate_parity.py:445-470`), each reading the TypeScript literal by regex and comparing to the Python constant. All pass. |
| AC21 | No dispatch or MCP contract change | **PASS** | `git diff --stat 1e991b86...HEAD -- scripts/dev_tools/validate_orchestration_artifacts.py extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` returns **no output**. `mcp-tools.ts` is absent from the branch diff, so no input-schema key changed. |

### Severity discipline (AC22–AC26)

| # | Criterion | Verdict | Evidence verified |
|---|---|---|---|
| AC22 | Corpus measurement recorded | **PASS** | `evidence/qa-gates/corpus-measurement.2026-08-24T00-00.md` reproduces the pre-declared rule verbatim **ahead of** the counts, then records corpus files (194), candidates, findings, true positives, and false positives per rule, with **every** false positive named by plan path, task identifier, and offending span — 22 for G7 in two tabulated classes, 7 for G8 in two classes, 4 for G9 with a per-row reason. |
| AC23 | Vacuity declared where it applies | **PASS** | No rule recorded a zero finding count, so the invalid-measurement declaration applies to none — and the artifact records that explicitly, per rule, with the count, rather than omitting the section. The four driver-integrity checks were nonetheless run and are reproduced verbatim: non-vacuous enumeration (519/237/47/273), a working seam (5856 chars of `pyproject.toml`, `contains addopts=True`), `sampled=10 self_hits=10`, and `findings_subset_of_candidates=True` for all four. The candidate discrepancy between checks 1 and 4 (519 vs 509 etc.) is explained as occurrence-vs-triple deduplication rather than glossed. |
| AC24 | Shipped severity follows the measurement | **PASS** | **Independently reproduced.** My own driver over the same corpus returned G7 466, G8 82, G8b 19, G9 8 — an exact match on all four. Applying the pre-declared rule to those counts and the recorded false-positive counts (22/7/0/4) yields warning for G7, G8, G9 (second conjunct fails) and warning for G8b (unconditional clause). The shipped constants are `warning` in both runtimes for all four. **No rule ships Blocking.** Ordering verified from git: `7a339fac` contains only the decision-rule file and lands 15 minutes before the measurement commit `5216a51d`. |
| AC25 | Driver deleted, no sweep introduced | **PASS** | `git ls-files "scripts/dev_tools/_tmp*"` returns nothing; `ls scripts/dev_tools/ \| grep -i "tmp\|driver"` returns nothing; the branch diff contains no path matching `tmp` or `driver` outside the two deletion-evidence artifacts. No `.github/workflows` file and no committed test scanning the corpus appears in the diff. Working tree is clean. |
| AC26 | No suppression surface introduced | **PASS** | The evidence artifact reports **non-zero raw match counts** (grandfather 10, exemption 6, allowlist 4, suppress 15, toggle 3; 21 distinct added lines) before stating its `none` classification, and classifies all 21 into three named classes with quoted lines. The source/test/config/workflow scope returns 0 for all five patterns. I confirmed the diff's only non-Markdown, non-source file is `jest.config.cjs`, whose addition is a coverage *threshold*. Reporting the raw counts rather than only the conclusion is what makes this criterion checkable. |

### Regression against measured defects (AC27–AC29)

| # | Criterion | Verdict | Evidence verified |
|---|---|---|---|
| AC27 | Six-revision regression run recorded | **PASS** | `evidence/regression-testing/six-revision-regression.2026-08-24T00-00.md` records the verbatim driver output and a 6×4 table — 24 integers. `six-revision-extraction.2026-08-24T00-00.md` records the `git show` extraction command per commit. All six commits (`e2aa6446`, `eff8f196`, `30414365`, `e913e0a9`, `ceacb5a5`, `5a8ede0f`) are named. |
| AC28 | The rules exercise the case they were written for | **PASS** | Total at `e2aa6446` is 6; total at `5a8ede0f` is 1; 6 > 1. Both endpoint finding lists are reproduced verbatim so the integers are auditable. The artifact additionally records — rather than smooths — the non-monotonic G7 column (2, 4, 4, 4, 4, 1) and explains the intermediate rise as a genuine intermediate regression in observability. Reporting the awkward shape is the right call. |
| AC29 | Corrected forms do not fire | **PASS** (see notes O-3, O-4) | The re-derived artifact is non-vacuous: the vacuity guard records 75 of 75 non-empty acceptance texts at `e2aa6446` and 75 of 76 at `5a8ede0f`, each above half its task count, and both guard rows read PASS. The derivation is a stated LCS alignment with a fixed tie-break, not executor selection; 42 matched pairs, 35 unchanged, 7 corrected, 33 deletions, 34 additions, with the arithmetic checked (42+33=75, 42+34=76, 35+7=42). All 7 corrected forms are reproduced with their text under both commits and each records `G7=0 G8=0 G8b=0 G9=0`. The verbatim driver output including `GUARD_PASS` is quoted. |

### Policy documentation (AC30–AC33)

| # | Criterion | Verdict | Evidence verified |
|---|---|---|---|
| AC30 | Rule file amended | **PASS** (see note O-5) | Read the full diff. The rule table gains a row for each of G7, G8, G8b, G9, each stating **Warning**. A per-rule severity-decision subsection exists for each, citing the measurement artifact by path (`grep -c` → 5 citations). The single-token limitation is stated in the style of the existing known-false-negative section (`grep -c -F "single-token"` → 3). All three deliberately uncovered sub-classes are recorded under `## Deliberately Uncovered Sub-Classes`: the general unobservable-success-output class, the task-ordering class, and the rejected executor-choice heuristic with its reason and an explicit "closed, not deferred". |
| AC31 | Authoring skill amended | **PASS** | Read the full diff. `SKILL.md` gains one mandatory-section bullet per new rule (G7, G8, G8b, G9), plus a bullet requiring the author to observe a command's success-case output before asserting over it (marked mandatory), plus the fix-the-evidence-in-the-plan bullet that replaces the rejected heuristic, plus a task-ordering bullet. All nine added lines are additive; nothing was removed. |
| AC32 | Bundled mirrors byte-identical | **PASS** | Verified by content-addressed hash, which is stronger than a digest recorded in an artifact: `git hash-object` returns `ea905f5e…` for both copies of the rule file and `e3b2198e…` for both copies of the skill file. Identical blob hashes prove byte-identity. The push-down contract test passes in my full-suite run modulo the issue-#510 `.claude/state/` noise. |
| AC33 | Stale citation corrected | **PASS** | The rule file now cites `docs/features/completed/2026-08-17-…/g5-corpus-measurement.2026-08-20T12-02.md` (count 1) and the `active/` spelling appears 0 times. **The corrected path resolves on disk** — `ls` on it returns `EXIT=0` — so this is a fix rather than a relabel. The mirror carries the same correction by hash equality. |

### Delivery quality (AC34–AC37)

| # | Criterion | Verdict | Evidence verified |
|---|---|---|---|
| AC34 | Coverage thresholds met | **PASS** | New modules: Python `plan_gate_observability.py` 97.12 line / 91.94 branch — corroborated independently by the LCOV artifact (`LF:139 LH:135 BRF:62 BRH:57`); TypeScript `plan-gate-observability.ts` 98.38 / 91.91. Invoking modules: `plan_gate_commands.py` 98.99 / 94.44, `plan_gate_discrimination.py` 97.71 / 86.54, `plan-gate-commands.ts` 95.93 / 84.88, `plan-gate-discrimination.ts` 100 / 98.14. All clear 85 line and 75 branch. Figures were read from printed terminal reports obtained by passing a terminal reporter explicitly — which is the criterion's own requirement and is the defect class G9 exists to report. The changed-line detail is recorded rather than glossed: the two uncovered constructs in `plan_gate_commands.py` (`325->327`, `332`) are named in the reconciliation artifact. |
| AC35 | Full toolchain passes in a single pass | **PASS** (see note O-6) | I re-ran every stage independently: `black --check` clean, `ruff check --no-fix` clean, `pyright` 0/0/0, `tsc --noEmit` clean, `eslint` clean, full Jest suite 2710 passed, full pytest 4194 passed with only the issue-#510 noise. No stage rewrote a file in my runs, and the check-only invocations make that observable rather than inferred. |
| AC36 | This feature's own gates observe more than an exit code | **PASS** | `evidence/qa-gates/write-mode-observations.2026-08-24T00-00.md` names the three write-mode tools this plan ran, quotes a non-exit-code observation for each, and names the artifact path each was read from: black — `455 files left unchanged.` present and `reformatted` absent; ruff — `All checks passed!` present and `Fixed` absent; `npm run format` — 408 processed lines and 408 `(unchanged)` lines, plus an independent empty `git status --porcelain`. It also lists the tools deliberately not covered and why. Independently corroborated: my own `black --check` and `ruff check --no-fix` runs reproduce the same discriminating literals. |
| AC37 | Mode integrity | **PASS** | `ls` on the feature folder returns exactly `evidence/`, `issue.md`, `plan.2026-08-23T23-22.md`, `research/`, `spec.md` — **no `user-story.md`**. `issue.md` line 12 reads `- Work Mode: full-bug`. `spec.md` line 9 restates it. Consistent. |

## Observations attached to specific criteria

These do not change any verdict. Each is recorded because a reader evaluating the criterion
should see the caveat rather than only the conclusion.

**O-1 (AC15) — an existing test fixture had to move.**
`tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py::_G1_PLAN` gained
`--cov-report=term-missing` because G9 correctly reported the original fixture and the extra
warning broke that file's stderr assertion. The criterion as written concerns **G1 through G6
output for a given input**, and that is unchanged: the `--cov` value is untouched, and
`evidence/regression-testing/g1-fixture-isolation.2026-08-24T00-00.md` records a direct
confirmation that the finding count is 1 and the string is byte-identical to the baseline. The
repair was applied to the fixture, not to any assertion — the artifact states that explicitly and
states why the alternative was rejected. Separately, one pre-existing TypeScript assertion was
*weakened*: `expect(runner.calls[0]).toEqual(...)` became `expect(runner.calls).toContainEqual(...)`,
dropping the guarantee that the grep query is the first git call. Necessary and commented, but a
reduction in strength rather than a re-expression.

**O-2 (AC16) — "is empty for a span belonging to no task" is satisfied structurally, not
observationally.** No record is produced at all for such a span, so no record with an empty
`task_text` can be observed. The Python test compensates by asserting the dataclass field default
directly; the TypeScript test asserts only `commands == []`, because `taskText` is a required
field there with no default. The criterion is met; the mechanism differs between runtimes, and
`spec.md:213`'s "trailing and defaulted" compatibility claim holds in Python but not literally in
TypeScript. Only one construction site exists in the repository (inside the module itself), so
nothing breaks.

**O-3 (AC29) — the vacuity guard does not bound the corrected-form list size.** The guard tests
that each commit's non-empty-acceptance-text count exceeds half its task count, which correctly
closes the failure mode that made the first run vacuous. It does not test `corrected_count > 0`.
A derivation yielding an empty list would pass the guard and satisfy the criterion vacuously. In
this run `corrected_count=7` with all seven entries reproduced in full, so the recorded result is
non-vacuous **in fact** — the guard simply does not guarantee it. Worth adding to the guard if
this derivation is ever re-run.

**O-4 (AC29) — one new-rule finding does fire against the final revision, and it is disclosed.**
The single evaluation of the `5a8ede0f` extraction produced a G7 finding on `[P0-T10]`
(`npm run format`). That task is classified by the alignment as an **addition**, not a
correction, so step 5 excludes it from the derived list and it contributes nothing to the
criterion's counts. The artifact reproduces the finding verbatim and states the exclusion and its
reason rather than omitting it, and the same finding is separately classified as a G7 false
positive (class 2, tree-observation) in the corpus measurement. The criterion's stated intent —
"so a rule that fires on the fix is caught" — was served: it fired, it was caught, and it was
reported in two places. The mechanical reading of "corrected form" as an aligned matched pair is
defensible and was fixed before the counts were taken.

**O-5 (AC30) — two documentation inaccuracies in the amended rule file.** First, the file lists
the six register entries as "`black-write`, `ruff-fix`, `prettier-write`, `poshqc-format`,
`run_poshqc_analyze_autofix`, and `poshqc-suite`"; the fifth entry's `name` field is
`poshqc-analyze-autofix` — `run_poshqc_analyze_autofix` is the MCP tool its argv suffix matches,
which the next sentence states correctly. Second, all five new citations of the measurement
artifact name the **active** feature tree and will go stale when this folder moves to
`completed/` — reproducing, for the new rules, exactly the defect AC33 corrects for G5. Both are
documentation-only.

**O-6 (AC35) — "single pass" means the second pass.** Phase 8 ran twice; the first reached
[P8-T7] and stopped when `npm run lint` exited 2 with `ERR_MODULE_NOT_FOUND: '@eslint/js'`, an
incomplete dependency tree rather than a lint violation. The plan's own phase preamble required a
restart from [P8-T1], and the criterion is evaluated against the completed second pass. The
artifact states this explicitly rather than presenting the second pass as the only pass, and
records the per-stage non-exit-code evidence that no stage rewrote a file. The reading is
defensible and disclosed. My own independent re-run of all stages reproduces the clean result.

## Gaps not required by any acceptance criterion

Recorded here so they are not lost, and stated plainly as **not** unearned check-offs — no
criterion claims them:

1. **Three negative flows in the new module are unreachable by any test in either runtime**, per
   the coverage tooling's own missing-line lists: the `excludes` mechanism
   (`plan_gate_observability.py:250`, `plan-gate-observability.ts:253-254`), the single-quoted
   `addopts` pattern (`397->395`, `399`, TS `413-414`), and G9's project-supplies-a-reporter
   exoneration (`422`, TS `441-442`). The `excludes` gap is the most consequential: it guards
   `black --check`, `black --diff`, and `ruff check --no-fix`.
2. **`spec.md:375`'s stated mitigation for the cross-runtime regex-divergence risk was not
   delivered.** The mitigation was "a parity fixture whose configuration value exercises quoting
   and whitespace variation"; both runtimes' fixtures use only the double-quoted form. This sits
   in `## Risks & Mitigations`, not in `## Acceptance Criteria`, so no criterion is falsely
   checked — but the risk the spec named is unmeasured.
3. **The write-mode register's `markers` and `excludes` data are not pinned equal across the two
   runtimes.** `spec.md:207` asserts a parity assertion; what ships pins each entry's argv shape
   (via mirrored fixture lists) and `black-write`'s markers (via `PARITY_G7`), leaving the other
   five entries' marker tuples and every `excludes` tuple uncompared.

All three are detailed in `code-review.2026-08-26T10-50.md` (MAJOR-1, MAJOR-2) and in
`policy-audit.2026-08-26T10-50.md`. **No remediation-inputs artifact is produced**, because there
are zero remediation-required findings and emitting one would falsely trigger a remediation
cycle. These three are follow-up work for a separate issue.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/spec.md
- Total AC items: 37
- Checked off (delivered): 37
- Remaining (unchecked): 0
- Items remaining: none
```

Verification: `grep -c '^- \[x\]'` over the `## Acceptance Criteria` section → **37**;
`grep -c '^- \[ \]'` → **0**. The four impact/severity radios and the logs-attached checkbox sit
outside the acceptance-criteria section, are not criteria, and were not modified.

No criterion was checked off or unchecked by this review. All 37 were already `[x]` and all 37
are independently earned.

## Verdict

**PASS. 37 of 37 acceptance criteria verified against evidence on disk. 0 FAIL, 0 unearned
check-offs, 0 blocking findings.**

The check-offs are earned, and in several cases the underlying evidence is stronger than the
criterion demands — the corpus measurement, the mirror byte-identity, and the coverage figures
were all independently reproducible and I reproduced them. The evidence set is notable for
reporting against itself where it could have stayed silent: the supersession notice that declares
an earlier run vacuous, the non-zero raw match counts under a `none` verdict, the non-monotonic
G7 column, the two uncovered constructs named explicitly, and the two-pass disclosure under
AC35. That habit is what made this audit checkable rather than a matter of trust.

This branch is genuinely clean. The three gaps recorded above are follow-up work, not
remediation blockers.
