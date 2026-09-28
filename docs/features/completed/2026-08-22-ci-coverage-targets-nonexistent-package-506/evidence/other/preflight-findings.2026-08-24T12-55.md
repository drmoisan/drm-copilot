# Preflight findings — cycle 3

- Timestamp: 2026-08-24T12-55
- Plan under validation: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md` (Version 1.2)
- Validator: `atomic-executor`, directive `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Checkout: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a56705110f06fb612`, branch `bug/ci-coverage-targets-nonexistent-package-506-r2`
- Signal: `PREFLIGHT: REVISIONS REQUIRED`
- Blocking findings: 4 (R15, R16, R17, R19). Minor findings: 2 (R18, R20).
- No plan task was executed. No file in the working tree was created, modified, or deleted other than this findings artifact.
- The mandatory plan-gate validator was **not** re-run by this cycle. The orchestrator-supplied result (PASS, zero Blocking, one G3 at P0-T7 and four G4 at P0-T6, P0-T8, P4-T4, P4-T5) was accepted as given and cross-checked against the plan's own self-description only by reading the document.

---

## Cycle-1 and cycle-2 findings — disposition

Each disposition below was verified against the Version 1.2 plan text and, where the finding rested on an environment premise, against the working tree. A claimed closure was not accepted on the header's assertion alone.

| Finding | Severity as filed | Disposition at Version 1.2 |
| --- | --- | --- |
| R1 — Phase 4 scope gates gate nothing | Blocking | **Closed.** P4-T9, P4-T10 and P4-T11 read `git status --porcelain --untracked-files=all`; each carries an explicit non-empty condition (a) as well as its substantive exclusion (b). P6-T2 carries the committed form. Trap 2 states the reasoning. |
| R2 — tracked `coverage.xml` overwritten by three tasks | Blocking | **Closed.** Premises re-verified this cycle: `git ls-files coverage.xml` lists the file; `git check-ignore -v coverage.xml` exits 1; `pyproject.toml` declares no `[tool.coverage.xml]` override; `[tool.coverage.run] data_file = "artifacts/.coverage"` and `/artifacts` is line 6 of `.gitignore`. The restore-plus-confirm pair is present at P0-T7, P0-T8 and P4-T5, the not-a-tenth-entry paragraph is present, and P6-T1 carries the recovery instruction. |
| R3 — AC checked off before evidence exists | Blocking | **Closed**, superseded by R9 and extended to four criteria. Phase 5 covers fifteen; P6-T7 finalizes AC-12, AC-14, AC-15, AC-17. The commit boundary paragraph states the uncommitted terminal state explicitly. |
| R4 — hardcoded worktree root | Blocking | **Closed for the repository root.** Line 24 resolves the root once with `git rev-parse --show-toplevel`; line 26 records the preparation worktree as historical context only; no task compares against an absolute literal. **The same defect survives for the branch name** and is refiled as R15. |
| R5 — P0-T7 has no declared exit-code expectation | Minor | **Closed in intent, defeated in effect on this platform.** The `ExpectedExitCode:` row is present. Refiled as R18: the collector's last-wins `EXIT_CODE` parsing means the row the collector reads in a three-command artifact is not the pytest row the expectation is declared against. |
| R6 — self-description of coverage values wrong | Minor | **Closed.** The three-class accounting at lines 178-184 matches the orchestrator's validator run exactly: one G3 (P0-T7 `src/lexile_corpus_tuner`), four G4 (P0-T6, P0-T8, P4-T4, P4-T5), one clean dotted value (P3-T10). One residual imprecision refiled as R20. |
| R7 — evidence-schema claim broader than the tasks | Minor | **Closed**, superseded by R14. |
| R8 — loader must use `Path.read_text` | Minor | **Closed.** Premise re-verified this cycle at `tests/conftest.py:639-656`: `mem_fs_path` patches `read_text`, `write_text`, `exists`, `is_file` and `Path.open`; builtin `open` is not intercepted. The mandatory I/O constraint is stated in the New module design section and is cross-referenced by P3-T8 and by the Phase 3 preamble. |
| R9 — AC-14 and AC-15 checked off before their observable exists | Blocking | **Closed.** Phase 5 preamble enumerates all four deferrals with reasons; P5-T1 requires exactly four `PENDING PHASE 6` rows naming P6-T7; P5-T2 leaves exactly four unchecked; P6-T7 closes all four and requires the committed-scope artifact to record a PASS verdict. |
| R10 — write set omits two committed feature-folder files | Blocking | **Closed for the two files named.** Entries 8 and 9 are present and annotated; the explanatory paragraph is present; both gates read "nine". **The same defect survives for three further paths** and is refiled as R16. |
| R11 — Windows separator makes the containment test fail | Blocking | **Closed.** P0-T2's probe performs the comparison inside the probe on two resolved `pathlib` objects via `is_relative_to`, prints three lines, and requires the third to be `True`. The prohibition on a string-prefix comparison is stated inline with its reason. Premise re-verified: `scripts/dev_tools/plan_gate_coverage.py` exists, and `scripts/__init__.py` and `scripts/dev_tools/__init__.py` both exist, so `scripts.dev_tools` is a regular package and the current working directory deterministically wins on `sys.path`. |
| R12 — spec check-off condition cannot fail | Blocking | **Closed.** P5-T2's diff condition is replaced by four structural conditions (nineteen criterion lines, fifteen checked, four unchecked, unchanged total line count), each independently falsifiable, with the reason stated inline. |
| R13 — Trap 4 binding phrase and quoting case | Minor | **Closed.** Trap 4 now covers the status-field strip, the rename-arrow expansion and the quoted-path unescaping; it binds to the exact phrase "derived path list" used by P4-T9, P4-T10 and P4-T11, and distinguishes the "recorded name list" of P6-T2. P4-T9 references Trap 4 rather than restating one step. |
| R14 — evidence-accounting enumeration and carve-out | Minor | **Closed in substance; arithmetic re-verified.** 23 command tasks + 9 record-only tasks + 21 carve-out tasks = 53, which equals the plan's actual task count (9+7+5+10+12+3+7). One misclassification remains and is folded into R17: P6-T6 is listed in the carve-out as naming no artifact, but its skip branch names `green-workflow-run.md`. |
| Cycle-1 advisory — pyright `.venv` message | Advisory | **Applied** at P0-T5 and P4-T3, including the prohibition on creating a virtual environment in response. |

---

## Structure, counts and cross-references — verified this cycle

| Check | Result |
| --- | --- |
| Phase headings | Seven headings in the canonical `### Phase N — Title` form, N = 0 through 6, no gaps |
| Per-phase task IDs | Contiguous and sequential: P0 T1-T9, P1 T1-T7, P2 T1-T5, P3 T1-T10, P4 T1-T12, P5 T1-T3, P6 T1-T7 |
| Task form | Every task line begins `- [ ] [P#-T#]`; no task is pre-checked |
| `[expect-fail]` tagging | P1-T1 through P1-T7 tagged; no other task tagged; P1-T7 declares `ExpectedExitCode: 1` and its artifact is named as the fail-before evidence |
| Cross-references | Every referenced task ID (P0-T2, P0-T8, P3-T10, P4-T5, P4-T9, P4-T10, P4-T11, P6-T1, P6-T2, P6-T5, P6-T6, P6-T7) resolves; "Trap 2", "Trap 3", "Trap 4", "Write set", "New module design", "Workflow target state" all resolve to existing sections |
| Workflow-contract test count | Six authored (P1-T1 through P1-T6); P1-T7 and P2-T4 both assert exactly six; reconciles |
| Checker unit-test count | Nine authored (P3-T2 one, P3-T3 two, P3-T4 one, P3-T5 one, P3-T6 one, P3-T7 one, P3-T8 two); P3-T9 asserts exactly nine; reconciles |
| AC coverage | Nineteen criteria mapped: AC-1/2/3/11/13 to Phase 1-2 tests, AC-5 through AC-10 to Phase 3 tests, AC-4 to P0-T8, AC-16 to P4-T7, AC-18 to P4-T8, AC-19 to P4-T5, AC-14/15 to P6-T2, AC-17 to P6-T5, AC-12 to P6-T7. Fifteen at Phase 5 plus four at P6-T7 = nineteen; reconciles |
| Spec AC section | Contains exactly nineteen `- [ ]` criterion lines (AC-1 through AC-19), all currently unchecked; the four impact radios and the logs checkbox sit outside the section, as the plan states |
| Evidence locations | Every artifact path resolves under `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/` in the kinds `baseline`, `regression-testing`, `qa-gates`, `other`. No `artifacts/` evidence path and no `evidence/coverage/` path appears |
| Evidence-accounting arithmetic | 23 + 9 + 21 = 53 = actual task count. Internally consistent apart from R17 |
| No-SKIPPED rule | Names exactly one authorized skip branch, P6-T6, which matches the plan body |
| Phase 6 sequencing | The dispatch at P6-T4 is followed only by polling, the pre-authorized fallback, and non-committing documentation edits; the commit boundary is stated explicitly |

## Environment preconditions — verified this cycle

| Precondition asserted or relied on by the plan | Result |
| --- | --- |
| `git rev-parse HEAD` equals `git rev-parse origin/main` | Confirmed, both `9497c612f5e7e6bfa63454285205c69691bae8d6`; `git diff --name-only origin/main...HEAD` is empty, which is why the plan's Trap 2 reasoning is correct |
| `scripts/dev_tools/plan_gate_coverage.py` (P0-T2 probe target) | Present |
| `scripts/__init__.py`, `scripts/dev_tools/__init__.py` | Both present; regular packages, so cwd wins on `sys.path` |
| `coverage.xml` tracked and not ignored | `git ls-files` lists it; `git check-ignore` exits 1 |
| `/artifacts` ignored | `.gitignore` line 6 |
| `scripts/dev-tools/run-actionlint.ps1` | Present; `actionlint` on PATH |
| `poetry`, `pwsh`, `gh` | All on PATH. `gh auth status` logged in as `drmoisan`, token scopes include `workflow`, so the P6-T4 dispatch is authorized |
| `_quality-checks.yml` declares `workflow_dispatch` | Confirmed at line 5 |
| Step name `Run tests with Pytest` | Confirmed; its `run` value is the defective `--cov=src/lexile_corpus_tuner` form |
| Codecov step uses `file:` and `if: matrix.python-version == '3.13'` | Both confirmed, so P2-T3 and the P6-T6 fallback both have a real target |
| Enforcement step insertion point (after pytest, before Codecov) | Confirmed adjacent in the committed file |
| The three new files do not yet exist | Confirmed, so P1-T1, P3-T1 and P3-T2 create rather than overwrite |
| `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py` precedent, `parents[3]` | Confirmed at line 7; the Phase 1 preamble's "fourth parent" is correct |
| `mem_fs_path` patches `read_text`/`write_text`/`exists`/`is_file`, not builtin `open` | Confirmed at `tests/conftest.py:639-656` |
| Ten policy documents named by P0-T1 | All ten present |
| `shlex.split` on the two target `run` blocks | Verified empirically. The POSIX backslash-newline yields a spurious `n` token, but `--min-line` is still immediately followed by `85`, `--min-branch` immediately by `75`, `--cov-branch` is present, and no token begins with `--cov=`. Every Phase 1 and Phase 2 assertion holds |
| `quality-tiers.yml` at repository root | Absent. Recorded as a known pre-existing environment defect per the orchestrator's fact 4. No plan task reads it — P0-T1 reads `.claude/rules/quality-tiers.md`, which is present — so this is **not** a plan finding and no file was created |

---

## R15 — BLOCKING. P6-T3, P6-T4 and P6-T5 hardcode a branch name that is not the executing branch.

**Finding.** The three Phase 6 git and `gh` tasks quote the literal branch string `bug/ci-coverage-targets-nonexistent-package-506` in four places: the `git push --set-upstream origin` argument and the `git rev-parse origin/...` comparand of P6-T3, the `--ref` value of P6-T4, and the `--branch` value of P6-T5. This is the identical defect class R4 and R11 removed for the repository root, left in place for the branch name.

**Evidence.**

- `git rev-parse --abbrev-ref HEAD` in this checkout is `bug/ci-coverage-targets-nonexistent-package-506-r2`, not the quoted literal.
- `git branch -a --list "*506*"` returns two local branches: `+ bug/ci-coverage-targets-nonexistent-package-506` (the `+` marks it checked out in another worktree — the stale ref of the killed predecessor agent) and `* bug/ci-coverage-targets-nonexistent-package-506-r2` (this one).
- Consequently, run in this checkout, `git push --set-upstream origin bug/ci-coverage-targets-nonexistent-package-506` resolves the refspec against the *other* local branch and pushes the predecessor's commits. P6-T3's own acceptance then compares `git rev-parse HEAD` (this branch) against `git rev-parse origin/bug/ci-coverage-targets-nonexistent-package-506` (the other branch) and fails.
- Run in the fresh worktree the parallel orchestrator will create, whose branch name is chosen by that surface and is not knowable at authoring time, the quoted branch will not exist locally and the push fails with `src refspec ... does not match any`.
- In both cases P6-T4 dispatches against, and P6-T5 polls, a ref that is not the branch head, so AC-17's head-SHA equality is unsatisfiable and the plan halts in Phase 6 after its only commit.

**Plan delta.**

1. In **P0-T2**, add a sixth command, `git rev-parse --abbrev-ref HEAD`, run from the resolved repository root immediately after `git rev-parse --show-toplevel`. Treat its output as **the resolved branch name** for every remaining task in this plan. Change the artifact requirement from "the four required fields for each of the five commands" to "for each of the six commands". Append to the acceptance: "the artifact records the resolved branch name verbatim, and that value is non-empty and is not the literal `HEAD`."
2. In the **Working directory** paragraph (line 24), append: "The executor likewise resolves the branch name once, as part of P0-T2, by running `git rev-parse --abbrev-ref HEAD`, and uses that resolved value for every push, dispatch and poll in Phase 6. No task names a literal branch string. The preparation-time branch name is not a precondition, because the parallel surface schedules each item onto a branch of its own choosing."
3. Replace **P6-T3** with: "Push the branch by running `git push --set-upstream origin HEAD` from the resolved repository root. The `HEAD` refspec is used deliberately in place of a literal branch name, so the push targets whatever branch the executing checkout is on. Acceptance: the command exits 0; `git rev-parse --abbrev-ref --symbolic-full-name @{u}` names a remote-tracking ref whose branch component equals the resolved branch name recorded by P0-T2; and `git rev-parse HEAD` equals `git rev-parse @{u}`."
4. In **P6-T4**, replace the `--ref` operand with the resolved branch name recorded by P0-T2, phrased as: "run `gh workflow run _quality-checks.yml --ref` with the resolved branch name recorded by P0-T2 as its operand".
5. In **P6-T5**, replace the `--branch` operand the same way: "run `gh run list --workflow=_quality-checks.yml --branch` with the resolved branch name recorded by P0-T2 as its operand, followed by `--limit 5 --json databaseId,headSha,conclusion,url`".

## R16 — BLOCKING. The closed write set omits the preflight-findings artifacts that P6-T1 will commit.

**Finding.** Write-set entry 7 is qualified: "`docs/.../evidence/` — artifacts named below." Three preflight-findings artifacts sit under `evidence/other/` and are named by no task in the plan. P6-T1 commits every remaining working-tree change; P4-T11 condition (b) and P6-T2 condition (d) then require every path in their lists to fall under one of the nine declared entries, and P4-T11 states that "any other path outside the write set halts the phase". This is the R10 defect for three further paths.

**Evidence.**

- `git status --porcelain --untracked-files=all` in this checkout lists six untracked paths, two of which are `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T00-28.md` and `.../preflight-findings.2026-08-24T00-45.md`. This cycle adds `.../preflight-findings.2026-08-24T12-55.md`, for three.
- No task in the plan names any file whose name begins `preflight-findings`. Under the strict reading the plan's own R10 remedy establishes — entries 8 and 9 were added precisely because a directory prefix was judged insufficient — these three paths fall outside the closed write set.
- For the parallel run's blast-radius computation the three paths are files this work item commits to the branch and are currently undeclared.

**Plan delta.** Replace write-set entry 7 with:

> 7. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/` — the entire evidence subtree. This covers both the artifacts named by tasks below and the preflight-findings artifacts written by the preflight validation cycles that ran before execution began (`evidence/other/preflight-findings.2026-08-24T00-28.md`, `evidence/other/preflight-findings.2026-08-24T00-45.md`, and `evidence/other/preflight-findings.2026-08-24T12-55.md`). The preflight-findings artifacts are authored upstream of this plan, are untracked at `origin/main`, and are committed unmodified by P6-T1. No task in this plan edits any of them.

And append one sentence to the "Why entries 8 and 9 exist" paragraph: "The same reasoning applies to the preflight-findings artifacts covered by the widened entry 7: they are untracked at `origin/main`, are committed unmodified by P6-T1, and therefore appear in both scope gates' lists."

## R17 — BLOCKING. P6-T6's skip branch renders the sole AC-17 evidence artifact unparseable.

**Finding.** P6-T6's skip branch instructs the executor to "record this task as `EXIT_CODE: SKIPPED` in `.../evidence/qa-gates/green-workflow-run.md`". That artifact is the sole evidence for AC-17. Appending a non-integer `EXIT_CODE` row to it makes the whole artifact unparseable to the repository's own evidence collector, so it is dropped rather than counted, and by the plan's own fail-closed evidence rule the verdict becomes BLOCKED.

**Evidence.** `scripts/dev_tools/pr_context/verification_evidence.py`:

- Line 25: `evidence/qa-gates/**/*.md` is a canonical discovery glob, so `green-workflow-run.md` is collected.
- Lines 122-128: rows are parsed in file order and, for the three required fields, later occurrences overwrite earlier ones — there is no `key not in parsed` guard on the `REQUIRED_FIELDS` branch. The guard exists only on the `ExpectedExitCode` branch at line 129. **`EXIT_CODE` is therefore last-wins.** A skip row appended after P6-T5's rows is the row the collector reads.
- Lines 148-159: `int(exit_code_raw)` raising `ValueError` returns a record with `normalized_result="unparseable"` for the entire artifact.

Secondary, same task: the carve-out paragraph asserts that P6-T6 is one of four Phase 6 tasks that "name no artifact of their own", which the skip-branch text contradicts.

**Plan delta.**

1. Replace the **skip branch** of P6-T6 with: "**Skip branch:** if the P6-T5 artifact records a `success` conclusion, write `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/d3-fallback-disposition.md` carrying `Timestamp:`, a `Disposition: SKIPPED` row, and a citation of `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/green-workflow-run.md` as the proof of that conclusion; the task is then complete. **No `EXIT_CODE:` row may be written into the green-run artifact by this task.** The green-run artifact's `EXIT_CODE` rows are last-wins to the repository's evidence collector, and a non-integer value there would make the sole AC-17 evidence artifact unparseable and drop it from verification."
2. In the **Evidence accounting rule**, move P6-T6 from the carve-out sentence into the record-only list, giving "P0-T1; P4-T8, P4-T10, P4-T11, and P4-T12; P5-T1, P5-T2, and P5-T3; and P6-T6 and P6-T7. That is **ten** tasks." Change the carve-out sentence from "Four command-bearing Phase 6 git-operation tasks" to "Three command-bearing Phase 6 git-operation tasks likewise name no artifact of their own: P6-T1, P6-T3, and P6-T4", and delete the clause that names P6-T6 as consolidated into the green-run artifact.

## R18 — Minor. P0-T7's declared exit-code expectation is read against the wrong command.

**Finding.** P0-T7 records three commands in one artifact and declares one `ExpectedExitCode:` equal to the pytest exit code. The collector reads the **last** `EXIT_CODE` row in the file, which is the `git status --porcelain -- coverage.xml` confirmation and is always 0, while the expectation is declared against the first. If the defective pytest run exits non-zero the artifact normalizes to `fail` — the exact rendering R5 was raised to prevent, now inverted.

**Evidence.** Same parser as R17: last-wins on `EXIT_CODE` (lines 122-128), first-wins on `ExpectedExitCode` (line 129), equality comparison at line 74. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` states the expectation field is per-file and directs that "a gate that needs a non-zero expectation [be recorded] in its own artifact file". Severity is minor rather than Blocking because the spec's recorded reproduction (`4078 passed, 5 skipped`) indicates the defective command exits 0, in which case observed and expected are both 0 and the artifact normalizes to pass; the defect is latent, not certain.

**Plan delta.** In P0-T7, split the evidence: "Write `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-repro.md` with the four required fields for the pytest command only, carrying exactly one `EXIT_CODE:` row, plus an `ExpectedExitCode:` row whose value equals that exit code. Record the restore command and the status confirmation, with their own four fields each, in a second artifact `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-restore.md`. The split is required because the evidence collector reads the last `EXIT_CODE` row in a file and compares it against the file's single declared expectation, so a restore row recorded after the pytest row would be the row the expectation is tested against." Leave the acceptance conditions otherwise unchanged, and add the second artifact path to the acceptance so its absence is a failure.

## R19 — BLOCKING. P6-T7's line-count condition is unsatisfiable whenever the P6-T6 action branch is taken.

**Finding.** P6-T7 condition (b) requires that the total line count of `spec.md` be "identical to the value P5-T2 recorded, proving this task changed only checkbox states". P6-T6's action branch instructs the executor to "record the shortfall as a recommended follow-up in the Rollout and Follow-up section of the spec", which adds lines to `spec.md` between P5-T2 and P6-T7. On that pre-authorized path condition (b) fails for a reason unrelated to what it is stated to prove, and the plan halts at its last task with no recovery branch.

**Evidence.** Plan lines 272 (P5-T2 records the pre-edit and post-edit counts), 288 (P6-T6 action branch edits the Rollout and Follow-up section of `spec.md`), and 289 condition (b) (P6-T7 compares against P5-T2's recorded value). The three are mutually inconsistent on the action path. The action path is pre-authorized by decision D3 of the spec and is reachable whenever a Python leg other than 3.13 reports a shortfall, which the spec itself records as a live risk.

**Plan delta.** Rewrite P6-T7 condition (b) as: "**(b)** this task records the total line count of `spec.md` immediately before making its edit and again immediately after, and the two values are identical, proving this task changed only checkbox states. The comparison is against this task's own pre-edit count, not against the value P5-T2 recorded, because the P6-T6 action branch may legitimately have added lines to the Rollout and Follow-up section in between. Both values are recorded in the evidence index." Additionally, append to the P6-T6 action branch: "and record the new total line count of `spec.md` in `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/ac-evidence-index.md`, superseding the count P5-T2 recorded."

## R20 — Minor. The P6-T6 action branch does not satisfy AC-12's alternative form as the spec states it.

**Finding.** AC-12's pre-authorized alternative form requires both the narrowed test **and** that "a follow-up issue recording the shortfall is linked in Rollout & Follow-up". P6-T6's action branch requires only that the shortfall be recorded "as a recommended follow-up in the Rollout and Follow-up section of the spec", which is a prose entry rather than a linked issue. On the action path P6-T7 would check AC-12 off against a criterion whose second conjunct was not delivered.

**Evidence.** Spec line 298 (AC-12 alternative form, "a follow-up issue recording the shortfall is linked in Rollout & Follow-up") against plan line 288 (P6-T6 action branch). Severity is minor because the path is a low-probability fallback and the spec's other follow-ups are recorded as recommendations rather than filed issues; the mismatch is nonetheless a real gap between the criterion and the task that claims it.

**Plan delta.** In the P6-T6 action branch, replace "record the shortfall as a recommended follow-up in the Rollout and Follow-up section of the spec" with "file a follow-up issue recording the shortfall and link it in the Rollout and Follow-up section of the spec, as the alternative form of AC-12 requires".

---

## Write-set boundary — preflight result

With the widened entry 7 required by R16, the write set is closed and accurate against the working tree. Re-verified this cycle: the six untracked paths present are the plan, the spec, the issue document, the research document, and the two prior preflight-findings artifacts — all inside entries 5, 6, 7, 8 and 9 once R16 is applied. No tracked file is modified. No task writes `pyproject.toml`, anything under `.github/instructions/`, either bundled customization mirror, any of the nine deferred foreign-target occurrences, or anything under the archive, completed, or potential feature trees. `artifacts/python/coverage.json`, `artifacts/python/checker-coverage.json`, `artifacts/python/lcov.info` and `artifacts/.coverage` are all matched by `/artifacts` in `.gitignore`. The tracked root `coverage.xml` is written by exactly the three tasks the plan names and is restored by each.

## Acceptance-condition falsifiability — preflight result

Every acceptance condition in the plan was read for the "satisfied by emptiness" defect this work item exists to repair. All three scope gates pair a non-empty-list condition with their substantive exclusion; P0-T7 pairs the absent-`TOTAL`-row condition with a positive passed count; P5-T2 replaces a vacuous diff condition with four independently falsifiable structural counts; P6-T1 pairs the clean-tree assertion with a HEAD-differs-from-`origin/main` assertion. No surviving condition in the plan is satisfied by emptiness. Two conditions are defective for the opposite reason — they cannot be satisfied on a reachable path — and are recorded as R15 and R19.

## Evidence-location compliance — preflight result

Every artifact named by the plan resolves under `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/` in a canonical kind. No plan task names `artifacts/baselines/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/evidence/`, or `evidence/coverage/`. The inherited `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record is restated in the plan and no task contradicts it. This findings artifact is written to the canonical `evidence/other/` location. No evidence-location override was supplied to this cycle and none was rejected.

PREFLIGHT: REVISIONS REQUIRED
