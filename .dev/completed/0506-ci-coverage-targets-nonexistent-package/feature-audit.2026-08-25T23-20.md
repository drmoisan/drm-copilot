# Feature Audit (Reaudit) — Issue #506 (ci-coverage-targets-nonexistent-package)

- **Timestamp:** 2026-08-25T23-20
- **Cycle:** exit reaudit of remediation cycle 1. The entry record is `feature-audit.2026-08-25T22-57.md`, which is not superseded and not overwritten.
- **Branch:** `bug/ci-coverage-targets-nonexistent-package-506-r3`
- **Branch head at reaudit:** `e825b5e62f7b816859eee8fae2c7e23ddb40679b`
- **Base:** `origin/main` at `8ca66c1d`; `git merge-base HEAD origin/main` equals `origin/main`
- **Work Mode:** `full-bug`, read from `issue.md` line 13 (`- Work Mode: full-bug`)
- **AC source:** `spec.md` **only** — the `full-bug` mode rule in `.claude/skills/acceptance-criteria-tracking/SKILL.md`. `user-story.md` does not exist in this feature folder and is not required by this mode. The five checkbox items in `issue.md` (`Blocker` / `High` / `Medium` / `Low` severity selectors and the "Attached minimal logs" item) are bug-report template fields, not acceptance criteria, and are correctly excluded from the AC set.

---

## 1. Baseline and Scope

The audit scope is the full branch diff against the resolved base. It is not narrowed to any plan, task, or phase.

| Fact | Value |
| --- | --- |
| `git rev-parse HEAD` | `e825b5e62f7b816859eee8fae2c7e23ddb40679b` |
| `git rev-parse origin/bug/...-506-r3` | `e825b5e62f7b816859eee8fae2c7e23ddb40679b` (identical) |
| `git rev-parse origin/main` | `8ca66c1db827cbfb59261ca0b85bb5b7a766908e` |
| `git merge-base HEAD origin/main` | `8ca66c1db827cbfb59261ca0b85bb5b7a766908e` (equals `origin/main`) |
| Branch diff | 48 files, 7310 insertions, 2 deletions |
| Diff composition | 1 `.yml`, 3 `.py`, 44 `.md` |

Because the merge base equals `origin/main`, the branch is fully up to date with `main` and the three-dot diff carries this work item's change only.

**Delta since the entry audit head `890e2ac9`:** five Markdown files under the feature folder (`post-merge-toolchain-verification.md` plus the four `2026-08-25T22-57` review artifacts). No production file, test file, or workflow file changed. Every AC verdict below was nonetheless re-derived at the current head rather than carried forward.

**PR-context artifacts:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent from this worktree. Scope was derived from the other authoritative source named in the scope invariant — the resolved base branch — by reading `git diff --name-status origin/main...HEAD` in full. This yields the same information the appendix carries.

---

## 2. Acceptance Criteria Evaluation

Nineteen criteria, AC-1 through AC-19, at `spec.md` lines 287-305. Each is evaluated against its own stated observable or named test, verified at this head.

| AC | Criterion (abbreviated) | Stated verification | Verified how, in this reaudit | Verdict |
| --- | --- | --- | --- | --- |
| AC-1 | Workflow contains no `lexile_corpus_tuner` token, case-insensitively | `test_workflow_names_no_foreign_coverage_target` | Test present at line 83 of the contract file and passing in the 15-test run; the workflow diff removes the only occurrence; `evidence/regression-testing/workflow-contract-tests-fail-before.md` records the test failing pre-fix | **PASS** |
| AC-2 | Pytest step carries `--cov-branch` and no `--cov=` token | `test_pytest_step_uses_bare_cov_with_branch` | Test present at line 94 and passing; the diff shows `--cov --cov-branch` replacing `--cov=src/lexile_corpus_tuner` | **PASS** |
| AC-3 | Pytest step carries `--cov-report=json:artifacts/python/coverage.json` | `test_pytest_step_emits_json_coverage_report` | Test present at line 108 and passing; the token appears verbatim in the workflow diff | **PASS** |
| AC-4 | Live run measures a non-empty denominator and produces the JSON report | `TOTAL` row with statements > 0; `artifacts/python/coverage.json` exists with `totals.num_statements` > 0; exit code and `TOTAL` row recorded in `evidence/baseline/` | `evidence/baseline/corrected-coverage-command-repro.md` records exit 0, a verbatim `TOTAL` row with 14953 statements, and `num_statements` 14953. Independently re-confirmed at this head: `artifacts/python/coverage.json` (1,599,291 bytes) and `artifacts/python/lcov.info` (425,098 bytes) both exist; the reviewer's own parse of `lcov.info` sums 15014 statements across 181 files. Both figures exceed zero, and `poetry env info --path` provenance is recorded in `evidence/baseline/python-environment-provenance.md` | **PASS** |
| AC-5 | A deliberate coverage regression fails the build | `test_line_coverage_below_floor_exits_non_zero` supplying 84.9 | Test present at line 74 and passing; asserts non-zero exit and a message naming line coverage | **PASS** |
| AC-6 | The branch floor is enforced independently of the line floor | `test_branch_coverage_below_floor_exits_non_zero` supplying 74.9 with line above its floor | Test present at line 94 and passing | **PASS** |
| AC-7 | Both floors are inclusive at the boundary | `test_line_coverage_at_floor_is_accepted` (85.0) and `test_branch_coverage_at_floor_is_accepted` (75.0) | Both tests present (lines 44 and 59) and passing; both assert exit 0 | **PASS** |
| AC-8 | A run breaching both floors reports both metrics | `test_both_metrics_below_floor_are_both_reported` | Test present at line 114 and passing; `find_threshold_breaches` accumulates into a list rather than short-circuiting | **PASS** |
| AC-9 | Absent branch data fails loudly rather than silently disabling the gate | `test_absent_branch_data_exits_non_zero` | Test present at line 135 and passing; `_evaluate_metric` line 117 returns the absent message for a missing or non-numeric value | **PASS** |
| AC-10 | A missing or unparseable report fails loudly | `test_missing_report_file_exits_non_zero` and `test_unparseable_report_exits_non_zero` | Both tests present (lines 155 and 172) and passing; each asserts non-zero exit and the report path in the message | **PASS** |
| AC-11 | Enforcement step present and invokes the module with both floors | `test_threshold_step_invokes_the_checker_with_both_floors` | Test present at line 119 and passing; the workflow diff adds the step with `--min-line 85 --min-branch 75` | **PASS** |
| AC-12 | Enforcement step runs on every Python matrix leg | `test_threshold_step_runs_on_every_matrix_leg` (primary form), or the narrowed alternative plus a linked follow-up issue. Exactly one of the two tests is present | See section 3.1 | **PASS** |
| AC-13 | Codecov step uses `files`, not `file` | `test_codecov_step_uses_the_declared_files_input` | Test present at line 146 and passing; the workflow diff shows `file: ./coverage.xml` → `files: ./coverage.xml` | **PASS** |
| AC-14 | `pyproject.toml` is unmodified | `git diff --name-only origin/main...HEAD` does not list it | See section 3.2 | **PASS** |
| AC-15 | None of the four blocked policy files is modified | `git diff --name-only origin/main...HEAD` lists none of them | See section 3.3 | **PASS** |
| AC-16 | The modified workflow passes actionlint | `scripts/dev-tools/run-actionlint.ps1` exits 0, recorded in `evidence/qa-gates/` | `evidence/qa-gates/final-workflow-actionlint.md` records `EXIT_CODE: 0` with a PASS verdict; `evidence/qa-gates/post-merge-toolchain-verification.md` Gate 8 re-runs it at the post-merge head, also exit 0 with zero findings | **PASS** |
| AC-17 | A green workflow run exists against the branch head | A `_quality-checks.yml` run whose conclusion is `success` and whose head SHA equals `git rev-parse HEAD`, URL recorded in `evidence/qa-gates/` before feature review | See section 3.4 | **PASS** |
| AC-18 | The full toolchain passes in a single pass | Black, Ruff, Pyright, and pytest each exit 0 in one uninterrupted sequence, no file modified by the formatter, transcript in `evidence/qa-gates/` | `evidence/qa-gates/toolchain-single-pass-transcript.md` records the sequence with a PASS verdict; `post-merge-toolchain-verification.md` Gates 1-4 re-run it at the post-merge head (black exit 0 / 448 files unchanged; ruff exit 0; pyright 0 errors 0 warnings; pytest 4136 passed 5 skipped, exit 0). Independently re-confirmed at this head: black exit 0 on the three changed files, ruff exit 0, 15 feature tests passing. Strongest evidence: run `32925230528` executes all four stages on four matrix legs at this exact head, every step `success` | **PASS** |
| AC-19 | Repository coverage remains at or above both floors under the corrected scope | `totals.percent_statements_covered` >= 85 and `totals.percent_branches_covered` >= 75, recorded in `evidence/qa-gates/` | See section 3.5 | **PASS** |

### Tally

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: none
```

| Verdict | Count |
| --- | --- |
| PASS | **19** |
| PARTIAL | 0 |
| FAIL | 0 |
| UNVERIFIED | 0 |

Change from the entry audit: AC-17 moves FAIL → PASS. The other eighteen were PASS then and are PASS now, each re-verified rather than carried forward. **No criterion regressed.**

---

## 3. Detailed Verification of the Four Criteria Checked Off During Remediation

The caller asked specifically whether each of the four newly checked criteria is backed by evidence that exists on disk. Each is examined against its own stated observable, and the backing artifact was opened and read, not merely confirmed to exist.

### 3.1 AC-12 — enforcement step runs on every Python matrix leg — **PASS**

AC-12 is a two-form criterion. The primary form requires `test_threshold_step_runs_on_every_matrix_leg`; the alternative form (pre-authorised by decision D3 if a version-specific shortfall appeared) requires `test_threshold_step_is_narrowed_to_the_pinned_leg` **and** a follow-up issue linked in Rollout & Follow-up. The criterion also requires that **exactly one** of the two tests is present.

| Condition | Check | Result |
| --- | --- | --- |
| Which branch did D3 take? | `evidence/qa-gates/d3-fallback-disposition.md` records `Disposition: SKIPPED` | skip branch, so the **primary** form applies |
| Was the skip branch's precondition genuinely met? | The action branch is reachable only if the run failed solely on a non-3.13 coverage shortfall. Run `32925230528` did not fail at all — all four legs `success` | precondition correctly evaluated |
| Primary-form test present? | `grep -n` in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` → line 134 | present |
| Alternative-form test absent? | `grep -rn "test_threshold_step_is_narrowed_to_the_pinned_leg" --include=*.py .` → **no match anywhere in the repository** | absent |
| "Exactly one of the two" | one present, one absent | satisfied |
| Does the test pass? | included in the reviewer's `15 passed in 0.08s` run at this head | passes |
| Does the asserted property actually hold on the runner? | The enforcement step has no `if` key, and `gh run view 32925230528 --json jobs` shows `Enforce Python coverage thresholds` with conclusion `success` on **each** of the 3.10, 3.11, 3.12, and 3.13 legs | holds empirically, not only structurally |
| Follow-up-issue obligation | Applies to the action branch only; the skip branch was taken | not applicable |

**Backing evidence on disk:** `evidence/qa-gates/d3-fallback-disposition.md` (present, read in full) and `evidence/regression-testing/workflow-contract-tests-pass-after.md` (present; lists the test at line 40 as item 5 of its passing set).

Note: the evidence index's AC-12 row cites only the disposition artifact in its artifact column. This is recorded as Informational finding NB-4 in `code-review.2026-08-25T23-20.md` and does not affect the verdict — the plan's P6-T7 instruction for AC-12 asked for the landed test node ID and prescribed no artifact path, the executor met that instruction, and the test result is independently confirmed above.

This criterion is unusually well-supported: it is the only one where the reaudit can confirm the asserted property not just in the parsed YAML but in four actual runner executions.

### 3.2 AC-14 — `pyproject.toml` is unmodified — **PASS**

The stated observable is that `git diff --name-only origin/main...HEAD` does not list `pyproject.toml`.

- **Re-executed by the reviewer at this head.** The 48-path listing was read in full. `pyproject.toml` does not appear. Neither does any other `.toml` file — the extension histogram is `44 md`, `3 py`, `1 yml` with no `.toml` entry, so the absence is established by two independent readings of the same listing.
- **Why it matters, not just that it holds:** `pyproject.toml` is where coverage `omit` / `exclude` entries would live. Its absence from the diff is what proves the repo-wide coverage figures in AC-19 were not obtained by narrowing the denominator. The criterion is a guard against a specific way of faking the result, and it holds.
- **Backing evidence on disk:** `evidence/qa-gates/committed-diff-scope.md` condition (b) records **PASS**; `evidence/qa-gates/post-merge-toolchain-verification.md` Gate 10 verdict (b) re-runs the gate at the post-merge head and also records **PASS**. Both files are present and were read.
- **Working-tree half:** `evidence/qa-gates/worktree-scope-pyproject.md` is present and records the pre-commit half.

### 3.3 AC-15 — none of the four blocked policy files is modified — **PASS**

The stated observable is that the same diff listing contains none of four specific paths.

| Blocked path | Present in the 48-path listing? |
| --- | --- |
| `.github/instructions/python-unit-test.instructions.md` | no |
| `.github/instructions/python-suppressions.instructions.md` | no |
| `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md` | no |
| `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md` | no |

Stronger than a four-path check: **no path under `.github/instructions/` appears in the diff at all**, and no path under `extensions/` appears either. The only `.github/` path in the diff is `.github/workflows/_quality-checks.yml`. The blocked set could not have been touched.

- **Why the block exists:** those four documents publish the defective coverage command as the approved Python test command. Correcting them is in scope for the issue but was escalated as a `human_interaction` requirement with `response: scope_change`, recorded at `evidence/other/human-interaction-d5.md` (present on disk). The criterion records that the escalation was honoured rather than quietly overridden — and it was.
- **Backing evidence on disk:** `evidence/qa-gates/committed-diff-scope.md` condition (c) records **PASS**; `post-merge-toolchain-verification.md` Gate 10 verdict (c) records **PASS**. `evidence/qa-gates/worktree-scope-blocked-policy-files.md` records the pre-commit half.

### 3.4 AC-17 — a green workflow run exists against the branch head — **PASS**

This is the criterion that failed at entry. It is examined most closely.

The stated observable has four parts: a `_quality-checks.yml` run; conclusion `success`; head SHA equal to `git rev-parse HEAD` on the branch; and the run URL recorded in `evidence/qa-gates/` before feature review.

**Independent verification.** The reviewer re-ran the query rather than reading the executor's transcript:

```
gh run list --workflow=_quality-checks.yml \
  --branch bug/ci-coverage-targets-nonexistent-package-506-r3 \
  --limit 5 --json databaseId,headSha,conclusion,status,url
```

```json
[{"conclusion":"success","databaseId":32925230528,"headSha":"e825b5e62f7b816859eee8fae2c7e23ddb40679b","status":"completed","url":"https://github.com/drmoisan/drm-copilot/actions/runs/32925230528"}]
```

| Part of the observable | Required | Observed | Met |
| --- | --- | --- | --- |
| A `_quality-checks.yml` run | yes | the `--workflow` filter returned it | yes |
| Conclusion | `success` | `success` | yes |
| Status terminal | — | `completed` | yes |
| Head SHA == `git rev-parse HEAD` | exact equality | run `e825b5e62f7b816859eee8fae2c7e23ddb40679b`; `git rev-parse HEAD` `e825b5e62f7b816859eee8fae2c7e23ddb40679b` | yes, character for character |
| URL recorded in `evidence/qa-gates/` | before review | `evidence/qa-gates/green-workflow-run.md` line 25 carries the URL; the file is on disk and was read in full | yes |

Two supporting checks the criterion does not require:

- `git rev-parse origin/bug/ci-coverage-targets-nonexistent-package-506-r3` also returns `e825b5e6…`, so there is no local-versus-remote divergence behind the SHA match.
- All four matrix legs are individually green, not just the aggregate: `Code Quality & Tests (3.10)`, `(3.11)`, `(3.12)`, `(3.13)`, each `success`, and the `Enforce Python coverage thresholds` step `success` on each.

**The criterion's closing sentence — "The dispatch is the final action; any later commit invalidates the evidence."** This was honoured. `evidence/qa-gates/green-workflow-run.md` records `git status --porcelain --untracked-files=all` returning empty at the moment the conclusion was read, so no commit intervened between the push and the record. The artifact then discloses, under a heading of its own, that a downstream handoff commit will move the head past `e825b5e6`.

That disclosure deserves an explicit judgment rather than silence. **The verdict is PASS, for four reasons set out in full in section 3.3 of `policy-audit.2026-08-25T23-20.md` and summarised here:** the strict reading is unsatisfiable for any workflow-modifying branch, because the evidence file must exist before it can be committed and committing it moves the head; the plan anticipated this and chose the ordering that keeps the SHA binding honest; the artifact discloses its own limit rather than overstating; and the pending change set is five Markdown files under the feature folder with no production, test, or workflow file among them, so the code the run exercised is byte-identical to the code at the post-handoff head — with the pull request's own required run providing a second green result at the final tip.

**Backing evidence on disk:** `evidence/qa-gates/green-workflow-run.md` — present, 172 lines, read in full, containing the run identity table, the per-leg results, the consolidated P6-T3 push record, the P6-T4 dispatch record, the P6-T5 poll records, and the acceptance section.

### 3.5 AC-19 — repository coverage remains at or above both floors — **PASS**

Not one of the four newly checked criteria, but re-derived here because it is the criterion the whole change exists to make meaningful.

The reviewer parsed `artifacts/python/lcov.info` directly, summing `LF`/`LH` and `BRF`/`BRH` across all 181 measured files:

| Metric | Measured | Floor | Margin | Verdict |
| --- | --- | --- | --- | --- |
| Line (`percent_statements_covered`) | **92.6469 %** (13910 / 15014) | 85 | +7.65 points | PASS |
| Branch (`percent_branches_covered`) | **85.2161 %** (4692 / 5506) | 75 | +10.22 points | PASS |

These agree to every printed digit with the JSON-report figures recorded in `evidence/qa-gates/workflow-command-coverage-json.md` and `post-merge-toolchain-verification.md` Gate 6 (92.64686292793392 and 85.2161278605158). Two independent parses of two report formats produce identical values.

The new module's own coverage is 96.7213 % line (59/61) and 85.7143 % branch (12/14), both above their floors.

**Backing evidence on disk:** `evidence/qa-gates/workflow-command-coverage-json.md` (PASS verdict), `evidence/qa-gates/checker-module-coverage.md` (PASS verdict), `evidence/qa-gates/coverage-delta.md`, and `post-merge-toolchain-verification.md` Gate 6.

---

## 4. Evidence-Artifact Existence Audit

Every artifact named by the AC evidence index was confirmed present on disk. `find evidence -type f` returns 38 files across the four canonical kinds.

| AC | Named backing artifact(s) | On disk |
| --- | --- | --- |
| AC-1, AC-2, AC-3, AC-11, AC-13 | `evidence/regression-testing/workflow-contract-tests-pass-after.md` | yes |
| AC-1..AC-3, AC-11..AC-13 (pre-fix) | `evidence/regression-testing/workflow-contract-tests-fail-before.md` | yes |
| AC-4 | `evidence/baseline/corrected-coverage-command-repro.md`, `evidence/baseline/python-environment-provenance.md` | yes, both |
| AC-5..AC-10 | `evidence/regression-testing/checker-unit-tests-pass.md` | yes |
| AC-12 | `evidence/qa-gates/d3-fallback-disposition.md` | yes (new this cycle) |
| AC-14, AC-15 | `evidence/qa-gates/committed-diff-scope.md`, `evidence/qa-gates/post-merge-toolchain-verification.md` | yes, both |
| AC-16 | `evidence/qa-gates/final-workflow-actionlint.md` | yes |
| AC-17 | `evidence/qa-gates/green-workflow-run.md` | yes (new this cycle) |
| AC-18 | `evidence/qa-gates/toolchain-single-pass-transcript.md` | yes |
| AC-19 | `evidence/qa-gates/workflow-command-coverage-json.md` | yes |

**Zero missing artifacts.** Every artifact named by a checked criterion exists, and each one named by the four newly checked criteria was opened and read in this reaudit rather than merely stat-ed.

---

## 5. Integrity of the Check-Off Itself

The acceptance-criteria tracking protocol requires that check-off changes only `- [ ]` to `- [x]` and never alters criterion text or adds criteria. Verified directly.

| Check | Method | Result |
| --- | --- | --- |
| Only four criteria changed state | `git diff --stat -- spec.md` | `8 ++++----` — 4 insertions, 4 deletions |
| Only the checkbox character changed | `git diff --word-diff=porcelain -U0 -- spec.md` | four hunks, each `-[ ]` → `+[x]`, with the criterion text on the unchanged context line in every case |
| Which four | same word-diff | AC-12 (line 298), AC-14 (300), AC-15 (301), AC-17 (303) — exactly the four the plan's P6-T7 names |
| Total line count unchanged | `wc -l spec.md` | **345**, matching both the pre-edit count and the [P5-T2] reference count recorded in the evidence index |
| No criterion added | criterion-line count | **19**, unchanged |
| No criterion removed | criterion-line count | **19**, unchanged |
| Final state | fixed-string counts over the checked and unchecked criterion forms | 19 checked, 0 unchecked |

The P6-T7 acceptance table in `evidence/other/ac-evidence-index.md` claims 345 = 345 for its own pre-edit and post-edit measurement. The reviewer's independent `wc -l` at the current state returns 345, and the word-diff shows no line added or removed, so the claim is corroborated by two independent methods rather than accepted on assertion.

**Plan state:** `grep -c "^- \[ \] \[P"` on `plan.2026-08-23T23-21.md` returns **0** unchecked tasks; `grep -c "^- \[x\] \[P"` returns **53** checked. The plan diff is three checkbox characters (P6-T5, P6-T6, P6-T7), with no prose altered. Re-running the plan validator against the modified file returns `plan validation passed`, exit 0, five Warnings, zero Blocking — byte-identical to the entry audit's Warning set.

**Evidence index:** row count 19, `PENDING PHASE 6` rows 0. All four previously-pending rows now carry landed evidence.

No phantom criteria were introduced. No criterion text was edited. No criterion was checked off ahead of its evidence.

---

## 6. Reviewer Check-Off Obligation

The tracking protocol requires the reviewer to check off any criterion evaluated PASS that is not already checked. All nineteen criteria evaluate PASS and all nineteen are already `[x]` in `spec.md`. **No check-off action is required or taken by this reviewer**, and no source file was modified by this audit.

---

## 7. Findings

| ID | Finding | Severity | Status |
| --- | --- | --- | --- |
| B-1 | `modified-workflow-needs-green-run`: no green run at the branch head | Blocking (entry audit) | **CLOSED** — verified in section 3.4 |
| NB-1 | Two documented `load_totals` validation conditions carry no unit test | Minor | Open, non-blocking, re-affirmed |
| NB-2 | CLI writes to stderr via `print` rather than `logging` | Informational | Open, no action recommended, re-affirmed |
| NB-3 | Stale present-tense heading in `ac-evidence-index.md` line 24 | Informational | New this cycle, non-blocking |
| NB-4 | AC-12 index row cites the disposition artifact, not the test-result artifact | Informational | New this cycle, non-blocking |

**Blocking findings: 0.** No remediation-inputs artifact is produced for this cycle, because there is nothing to remediate.

---

## 8. Verdict

**PASS. All nineteen acceptance criteria are satisfied. Zero Blocking findings.**

The single Blocking finding of remediation cycle 1 is closed by direct, independently re-executed measurement. The four criteria checked off during remediation are each backed by an artifact that exists on disk and that was opened and read in this reaudit, and each criterion's own stated observable was re-derived rather than inferred from the artifact's own claim. The check-off itself is clean: four checkbox characters, no text change, no criterion added or removed, total line count unchanged at 345, verified by word-diff and by independent line count.

The other fifteen criteria were re-verified at the current head and all hold. No criterion regressed.

The remediation introduced two new findings, both Informational documentation-consistency nits, neither affecting merge readiness. The two pre-existing non-blocking findings were deliberately not remediated; both were re-examined against the current code and both remain correctly classified as non-blocking.

One forward-looking constraint, recorded in section 3.4 and in the policy audit, is not a finding against the current state: the downstream handoff commit must contain only the five documentation paths currently pending in the working tree, so that the code exercised by green run `32925230528` remains byte-identical to the code at the post-handoff head.
