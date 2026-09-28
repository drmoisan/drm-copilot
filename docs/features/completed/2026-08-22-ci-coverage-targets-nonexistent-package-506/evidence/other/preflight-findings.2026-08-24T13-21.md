# Preflight findings — cycle 5

- Timestamp: 2026-08-24T13-21
- Plan under validation: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md` (Version 1.4)
- Validator: `atomic-executor`, directive `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Checkout: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a56705110f06fb612`, branch `bug/ci-coverage-targets-nonexistent-package-506-r2`
- Canonical issue number: 506. Every artifact path, cross-reference, and folder name in this artifact uses that number.
- Signal: `PREFLIGHT: ALL CLEAR`
- Blocking findings: **0**. Minor findings: **2** (R27, R28), both outstanding at clearance.
- No plan task was executed. No file in the repository working tree was created, modified, or deleted other than this findings artifact. One throwaway script was written to the session scratchpad outside the repository to test PowerShell quoting; it is not in the working tree and appears in no git output.
- The mandatory plan-gate validator was **not** re-run by this cycle, per the orchestrator's instruction. The supplied result (PASS, zero Blocking, one G3 at P0-T7 and four G4 at P0-T6, P0-T8, P4-T4, P4-T5) was accepted as given and was used only as the reference against which the plan's own self-description was checked (see R28).
- No evidence-location override was supplied to this cycle and none was rejected. This artifact is written to the canonical `evidence/other/` location.

**Clearing with minor findings outstanding.** Both R27 and R28 are recorded below with precise deltas.
Neither prevents correct execution in the measured environment, and minor findings alone do not
prevent an all-clear. They should be applied at the next revision of the plan if one occurs, but the
plan is executable as written.

---

## Directive-scoped verification of the planner's R21–R26 claims

Each claim was verified against the Version 1.4 plan text and, where it rested on an environment
premise, re-measured in this checkout. The plan header's claim of closure was not accepted as
evidence for any row. Three of the twenty-six prior findings had a claimed closure that was correct
in intent but inert on this platform (R4, R11, R21) and two were partial in a way that spawned a new
Blocking finding (R10, R15), so every closure below was re-tested rather than read.

| Claim | Verification performed this cycle | Verdict |
| --- | --- | --- |
| **R21** — both P6-T3 conditions use `"@{u}"`, with an inline hash-literal rationale and a Trap 5 cross-reference | Plan line 299 carries `git rev-parse --abbrev-ref --symbolic-full-name "@{u}"` in (b) and `git rev-parse "@{u}"` in (c). Line 301 states the PowerShell hash-literal reason inline and ends "See Trap 5." Re-measured both forms under `pwsh -NoProfile`: quoted returns `origin/main` exit 0; unquoted raises `ParserError: Missing '=' operator after key in hash literal`. | **Closed, remedy verified live in the primary shell.** |
| **R21 fold-in / R24** — condition (b) strips a leading `origin/` prefix rather than taking a last segment | Plan line 303: "**The prefix removal is exactly that: strip the leading `origin/` and compare everything that remains.**" with the slash-bearing-branch reason stated inline. | **Closed.** |
| **R22** — P6-T1 captures HEAD immediately before and after its commit and requires the two to differ | Plan line 297: `git rev-parse HEAD` **immediately before** the commit, then commit, then `git rev-parse HEAD` again and `git status --porcelain`; condition (b) requires post ≠ pre; the inline reason rejects both the clean-tree assertion and the `origin/main` comparison. | **Closed.** |
| **R22** — four false-premise prose statements corrected to a merge-base formulation | Enumerated every `origin/main` sentence in the plan (28 occurrences) and read each. Trap 2 (line 154), Phase 4 preamble (line 268), Phase 5 AC-14/AC-15 bullet (line 281), and the opening sentence of P6-T2 (line 298) all now read "the branch carries no commit of its own, so `HEAD` is the merge base…". **No fifth false-premise statement survives.** | **Closed; no residue.** |
| **R22** — the corrected merge-base prose is actually true | Re-measured: `HEAD = 9497c612…`, `origin/main = 4dbc48fb…`, `git merge-base origin/main HEAD = 9497c612…` (equals HEAD), `git diff --name-only origin/main...HEAD` empty, `git diff --name-only origin/main..HEAD` = `package-lock.json`, `package.json`. The merge-base formulation is exactly what obtains; the emptiness conclusion holds and does not depend on the two refs being equal. | **True as written.** |
| **R22** — P6-T2 records both SHAs | Plan line 298 requires the artifact to carry "the commit SHA P6-T1 produced, P6-T1's pre-commit and post-commit `git rev-parse HEAD` values". Consistent with P6-T1's carve-out classification (see the dedicated check below). | **Closed.** |
| **R22** — the three-dot diff form is unchanged | P6-T2 still uses `git diff --name-only origin/main...HEAD`; every committed-diff condition in the plan uses the three-dot form. | **Confirmed unchanged.** |
| **R23** — the preflight-findings count statement is now count-free at entry 7, P4-T11(b), P6-T2(d) | Entry 7 (line 54) declares the list "an open enumeration, not a closed set, and no task may treat them as a count" and states the plan "states no number of preflight-findings artifacts anywhere". P4-T11(b) and P6-T2(d) both read "**every** preflight-findings artifact under `evidence/other/`, however many there are". Searched the whole plan for a surviving numeric statement about these artifacts: none. This cycle's artifact makes a fifth; entry 7 covers it without amendment. | **Closed, and verified stable against this cycle's own write.** |
| **R24** — Trap 5 added, heading changed from "Four" to "Five", Traps 1-4 unrenumbered | Trap definitions at lines 146, 150, 159, 161, 169 (Traps 1–5 in order); heading at line 144 reads "Five environment traps". Every cross-reference enumerated: Trap 2 at 190 and 268, Trap 3 at 176 and 205, Trap 4 at 270 and 298, Trap 5 at 301. All resolve to the intended trap; none is off by one. Trap-count statement consistent with the five definitions. | **Closed; every cross-reference resolvable.** |
| **R25** — P0-T7 split retained, rationale replaced with the per-file expectation rule plus the uncollected-glob fact | Plan line 216 now cites the per-file rule in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` and states that `evidence/baseline/**` is not a collector glob, so the row is "a record of intent rather than an input to it". The later sentence is replaced as specified. Re-verified the underlying fact: `scripts/dev_tools/pr_context/verification_evidence.py` `CANONICAL_GLOBS` = `evidence/qa-gates/**/*.md`, `evidence/regression-testing/**/*.md`, `evidence/other/**/*.md` — `evidence/baseline/**` absent. Re-verified the last-wins `EXIT_CODE:` and first-wins `ExpectedExitCode:` parse at lines 121-131 of the same module, which is what P6-T5 and P6-T6 rely on. | **Closed, and the corrected rationale is factually accurate.** |
| **R26** — P0-T1 acceptance requires a present-or-absent statement for four documents, all four must be present, absence is BLOCKED at Phase 0 | Plan line 204 names `spec.md`, `issue.md`, the research document, and the plan file, requires a present-or-absent statement for each, and states "**All four must be present; an absent document is a BLOCKED verdict at this task and the plan must not proceed.**" with the reason stated inline. | **Closed.** |

### R26 probe — is the new presence check itself falsifiable, and does it collide with the write set?

- **Falsifiable: yes.** The condition fails whenever any of the four documents is absent, and absence
  is the expected state of a worktree freshly branched from `origin/main`: all eight feature-folder
  paths are untracked here and `git diff --name-only origin/main...HEAD` is empty, so none of them
  exists in `origin/main`. The condition is not satisfied-by-emptiness in either direction — an empty
  or partial statement list also fails it.
- **No duplication and no contradiction.** The four paths P0-T1 names are exactly write-set entries 5,
  6, 8, and 9. Entry 7 (the evidence subtree) is deliberately not in the presence check, and that is
  correct rather than an omission: the scope gates assert that every path *present* falls inside the
  write set, never that any particular evidence artifact *is* present, so an absent preflight-findings
  artifact breaks no gate. Nothing in P0-T1 asserts a path that the write set excludes, and nothing in
  the write set asserts a presence P0-T1 contradicts.
- **Classification unaffected.** P0-T1 remains record-only. It executes no command; a presence
  statement is the same class of file observation as the policy reads the task already performs, and
  the evidence-accounting rule at plan line 16 was updated in step to name "the feature-folder presence
  statements its acceptance requires". The command-task enumeration and the total of twenty-three are
  unchanged.

### P6-T1 probe — is the pre/post HEAD capture consistent with the evidence-accounting classification?

P6-T1 sits in the carve-out (plan line 18) and names no artifact of its own. The new capture does not
disturb that:

- P6-T1 names no artifact. It records two values and hands them onward.
- P6-T2's task text (line 298) explicitly requires its artifact to carry "P6-T1's pre-commit and
  post-commit `git rev-parse HEAD` values", so both values are recorded exactly one hop away, which is
  what the carve-out promises.
- P6-T1's own text states the consolidation in the same terms: "Both SHA values are recorded in the
  P6-T2 artifact alongside the commit SHA, per the carve-out that consolidates this task's state into
  that artifact."
- The carve-out's stated rationale for P6-T1 — that P6-T2's artifact cannot record a non-empty
  committed diff unless the commit succeeded — remains true and is now reinforced rather than replaced.

No inconsistency. The carve-out membership, the twenty-task carve-out total, and the fifty-three-task
reconciliation are all unaffected.

---

## Cycle-1 through cycle-4 findings — explicit disposition, R1 through R26

| Finding | Severity as filed | Disposition at Version 1.4 |
| --- | --- | --- |
| R1 — Phase 4 scope gates gate nothing | Blocking | **Closed.** P4-T9, P4-T10, P4-T11 each pair a non-empty condition (a) with a substantive exclusion (b). Re-read this cycle. |
| R2 — tracked `coverage.xml` overwritten by `--cov-report=xml` | Blocking | **Closed.** Premises re-measured: `git ls-files coverage.xml` lists it; `git check-ignore -v coverage.xml` exits 1 with no match; `pyproject.toml` declares no `[tool.coverage.xml]` override. Restore-plus-confirm pair present at P0-T7, P0-T8, P4-T5; recovery instruction at P6-T1. Additionally verified that `git checkout -- coverage.xml` and `git status --porcelain -- coverage.xml` both parse and exit 0 under `pwsh -NoProfile`, so the restore is not itself a Trap 5 casualty. |
| R3 — AC checked off before evidence exists | Blocking | **Closed**, superseded by R9. |
| R4 — hardcoded worktree root | Blocking | **Closed.** Root resolved once at P0-T2; no absolute path is compared anywhere. Branch half closed by R15; shell half by R21. |
| R5 — P0-T7 has no declared exit-code expectation | Minor | **Closed in form.** `ExpectedExitCode:` present at P0-T7. Practical effect nil for a `evidence/baseline/` artifact, which the plan now states outright (R25). |
| R6 — self-description of coverage values wrong | Minor | **Closed in the total, defective in one attribution sentence.** Plan lines 192-198 state one G3 plus four G4, which matches the supplied validator run. Plan line 111 attributes G4 findings to a preamble section that produces none; refiled as **R28**. |
| R7 — evidence-schema claim broader than the tasks | Minor | **Closed**, superseded by R14. |
| R8 — loader must use `Path.read_text` | Minor | **Closed.** Mandatory I/O constraint at plan line 138, cross-referenced by the Phase 3 preamble and P3-T8. Re-verified the premise: `tests/conftest.py` `mem_fs_path` monkeypatches `Path.write_text`, `read_text`, `exists`, `is_file` (lines 640-645), registers its memory root as a directory (line 203), raises `FileNotFoundError` for an unwritten key (line 360), and falls back to the real filesystem outside the memory root. Both P3-T8 cases are writable against it with no on-disk file. |
| R9 — AC-14/AC-15 checked off before their observable exists | Blocking | **Closed.** Phase 5 preamble enumerates four deferrals; P5-T1 requires exactly four `PENDING PHASE 6` rows; P6-T7 closes all four. |
| R10 — write set omits two committed feature-folder files | Blocking | **Closed.** Entries 8 and 9 present and annotated; residual half closed by R16. |
| R11 — Windows separator makes the containment test fail | Blocking | **Closed, and the remedy executed live this cycle.** The P0-T2 probe was run verbatim from a PowerShell script file: it printed exactly three lines — the resolved module path, the resolved repository root, and `True` — and exited 0. `scripts/dev_tools/plan_gate_coverage.py`, `scripts/__init__.py`, and `scripts/dev_tools/__init__.py` all present. The prohibition on a string-prefix comparison is stated inline at line 211. |
| R12 — spec check-off condition cannot fail | Blocking | **Closed.** P5-T2 carries four independently falsifiable structural conditions; the "five recorded numbers" statement reconciles to pre-edit count, post-edit count, and the three criterion-line counts of conditions (a) and (b). |
| R13 — Trap 4 binding phrase and quoting case | Minor | **Closed.** Trap 4 covers all three derivation steps, binds the phrase "derived path list", and distinguishes P6-T2's "recorded name list". |
| R14 — evidence-accounting enumeration and carve-out | Minor | **Closed.** Independently recounted this cycle: 23 + 10 + 20 = 53 = the plan's actual task count. See the counts table below. |
| R15 — Phase 6 hardcodes a branch name | Blocking | **Closed in substance and now also in effect.** The Branch name preamble is at line 26; P0-T2 resolves the branch name and requires it recorded, non-empty, and not the literal `HEAD`; P6-T3 pushes `HEAD`; P6-T4 and P6-T5 take the resolved name as operand. No literal branch string appears in the plan. The shell defect this closure introduced (R21) is now closed and verified live. |
| R16 — write set omits the preflight-findings artifacts | Blocking | **Closed.** Entry 7 reads "the entire evidence subtree"; the "Why entries 8 and 9 exist" paragraph carries the matching sentence. Verified against the actual tree: all eight untracked paths, plus this cycle's ninth, fall inside entries 5 through 9. The stale count this closure left behind (R23) is now closed. |
| R17 — P6-T6 skip branch renders the AC-17 artifact unparseable | Blocking | **Closed, and the collector premises re-verified.** The skip branch writes `evidence/qa-gates/d3-fallback-disposition.md` with `Disposition: SKIPPED`; the prohibition on any `EXIT_CODE:` row in `green-workflow-run.md` is stated at P6-T6 and mirrored at P6-T5. Re-read `verification_evidence.py`: `EXIT_CODE:` is last-wins, `ExpectedExitCode:` first-wins, and an artifact lacking `Command:`/`EXIT_CODE:` normalizes to `unparseable`, which `collector.py:148` filters out of the rendered set. The disposition artifact is dropped silently, never rendered as a failure. |
| R18 — P0-T7's exit-code expectation read against the wrong command | Minor | **Closed as applied.** P0-T7 is split into `defective-coverage-command-repro.md` and `defective-coverage-command-restore.md`; the acceptance requires both and states that the absence of either is a failure. The rationale defect this closure carried (R25) is now closed. |
| R19 — P6-T7 line-count condition unsatisfiable on the action path | Blocking | **Closed.** Condition (b) compares P6-T7's own pre-edit and post-edit counts of `spec.md`, with the reason stated inline; the closing paragraph records when P5-T2's count remains the reference. Self-sourced, so it has no dependency on an earlier task's value. |
| R20 — P6-T6 action branch does not satisfy AC-12's alternative form | Minor | **Closed.** The action branch requires filing the follow-up issue and linking it; P6-T7 condition (g) blocks the AC-12 check-off on the action path without that link. Cross-checked against the spec: AC-12's alternative form does require "a follow-up issue recording the shortfall is linked in Rollout & Follow-up", and `## Rollout & Follow-up` exists at spec.md line 326. |
| R21 — P6-T3 conditions cannot be evaluated in the primary shell | Blocking | **Closed, verified live.** See the directive table above. Both conditions now use `"@{u}"`; the quoted form was measured working and the unquoted form measured failing, under `pwsh -NoProfile` in this checkout. |
| R22 — P6-T1 condition (b) can no longer fail | Blocking | **Closed, verified against re-measured refs.** See the directive table above. The pre/post comparison is self-sourced and cannot be satisfied by an advance of `origin/main`. All four prose corrections applied; no fifth false-premise statement found. |
| R23 — stale "three preflight-findings artifacts" count | Minor | **Closed.** The plan now states no number of these artifacts anywhere and declares the enumeration open. Verified stable against this cycle's own fifth artifact. |
| R24 — undefined "branch component" extraction | Minor | **Closed.** Folded into R21's replacement text as specified, and stated explicitly at line 303 with the slash-bearing-branch reason. |
| R25 — P0-T7 rationale cites a collector that never reads the artifact | Minor | **Closed.** Rationale replaced with the per-file expectation rule; the uncollected-glob fact is now stated in the plan and was independently re-verified. |
| R26 — no precondition that the executing checkout holds the feature-folder documents | Minor | **Closed.** P0-T1 acceptance now carries the four-document presence check with a BLOCKED verdict on absence. Falsifiability and write-set consistency probed above. |
| Cycle-1 advisory — pyright `.venv` message | Advisory | **Applied**, unchanged, at P0-T5 and P4-T3. Premise re-verified: `pyproject.toml` sets `venvPath = "."` and `venv = ".venv"`, and no `.venv` directory exists at the repository root, so the message is expected. |

---

## Structure and counts — independently recomputed this cycle

Every value below was recomputed from the document, not read from the plan's statement of it.

| Check | Recomputed result | Plan's stated value | Agree |
| --- | --- | --- | --- |
| Phase headings | Seven, canonical `### Phase N — Title`, N = 0..6, no gap | seven | yes |
| Total unchecked tasks | **53** | fifty-three | yes |
| Per-phase task counts | 9, 7, 5, 10, 12, 3, 7 | "nine plus seven plus five plus ten plus twelve plus three plus seven" | yes |
| Task IDs | Contiguous and sequential within every phase; no duplicate, no gap, no out-of-order ID | — | yes |
| Command-task enumeration | P0-T2..P0-T9 (8) + P1-T7 (1) + P2-T4,T5 (2) + P3-T9,T10 (2) + P4-T1..T7 (7) + P4-T9 (1) + P6-T2,T5 (2) = **23** | twenty-three | yes |
| Record-only enumeration | P0-T1 (1) + P4-T8,T10,T11,T12 (4) + P5-T1,T2,T3 (3) + P6-T6,T7 (2) = **10** | ten | yes |
| Carve-out enumeration | P1-T1..T6 (6) + P2-T1..T3 (3) + P3-T1..T8 (8) + P6-T1,T3,T4 (3) = **20** | twenty | yes |
| Accounting reconciliation | 23 + 10 + 20 = 53 | fifty-three | yes |
| Distinct evidence artifacts named by tasks | 33 artifact-naming tasks, P0-T7 naming two (34 slots), less one shared by P4-T10/P4-T11 and two shared across P5-T1/P5-T2/P6-T7 = **31 distinct paths**; enumerated 31 distinct paths from the document | — | yes, exact |
| Write-set entries | Nine numbered entries, 1 through 9 | nine (three occurrences: entry-7 paragraph, P4-T11(b), P6-T2(d)) | yes |
| Workflow-contract tests authored | P1-T1..P1-T6 = **6** | six (P1-T7, P2-T4) | yes |
| Checker unit tests authored | P3-T2 (1) + P3-T3 (2) + P3-T4..T7 (4) + P3-T8 (2) = **9** | nine (P3-T9) | yes |
| Spec acceptance criteria | `grep -c "^- \[ \] AC-"` = **19**; `grep -c "^- \[x\] AC-"` = **0** | nineteen, all unchecked | yes |
| Phase 5 / Phase 6 AC split | 15 at P5-T2 + 4 at P6-T7 = 19; deferred set is exactly AC-12, AC-14, AC-15, AC-17 | fifteen, four, nineteen | yes |
| P0-T2 command count | 6 (`--show-toplevel`, `--abbrev-ref HEAD`, `poetry env info --path`, probe, `rev-parse HEAD`, `rev-parse origin/main`) | six | yes |
| P0-T8 / P4-T5 command count | 4 each | four each | yes |
| P0-T1 policy documents | 10 enumerated in the task text | all ten | yes |
| P6-T1 acceptance conditions | (a), (b), (c) = **3** | all three | yes |
| P6-T2 acceptance conditions | (a) through (d) = **4** | all four | yes |
| P6-T3 acceptance conditions | (a), (b), (c) = **3** | all three | yes |
| P6-T7 acceptance conditions | (a) through (g) = **7** | all seven | yes |
| P5-T2 acceptance conditions / recorded numbers | 4 conditions; 5 numbers (pre, post, and the three counts of (a)+(b)) | all four; all five | yes |
| Environment traps | Five definitions, five-way heading, every cross-reference resolvable | Five | yes |
| Preflight-findings artifact count stated anywhere in the plan | **none** | none, by explicit design | yes |

No count drift was found anywhere in this cycle.

---

## Environment premises — re-measured this cycle

`origin/main` is unchanged from cycle 4 at `4dbc48fb…`. Every premise was nonetheless re-measured
rather than carried forward.

| Premise | Measured result |
| --- | --- |
| `git rev-parse HEAD` | `9497c612f5e7e6bfa63454285205c69691bae8d6` |
| `git rev-parse origin/main` | `4dbc48fb1baff170e904576f992e539c7cd37cb5` |
| `git merge-base origin/main HEAD` | `9497c612…` — equals HEAD, so HEAD is an ancestor of `origin/main` and the plan's merge-base formulation is exactly what obtains |
| `git diff --name-only origin/main...HEAD` | empty |
| `git diff --name-only origin/main..HEAD` | `package-lock.json`, `package.json` only — so `.github/workflows/_quality-checks.yml` is byte-identical between HEAD and `origin/main`, and every workflow premise below holds against `origin/main` at `4dbc48fb…` without a second read |
| `git status --porcelain --untracked-files=all` | 8 untracked paths, 0 modified tracked paths |
| Quoted `git rev-parse --abbrev-ref --symbolic-full-name "@{u}"` under `pwsh -NoProfile` | `origin/main`, exit 0 |
| Unquoted same command under `pwsh -NoProfile` | `ParserError: Missing '=' operator after key in hash literal` — R21's remedy is necessary and its quoted form is correct |
| `git checkout -- coverage.xml` and `git status --porcelain -- coverage.xml` under `pwsh -NoProfile` | both exit 0; the `--` pathspec separator is passed through to the native command and is not consumed by the PowerShell parser |
| Pytest node-ID tokens (`path.py::test_name`) as native-command arguments under `pwsh -NoProfile` | passed through verbatim as separate argv elements; the `::` accessor is not triggered in argument position, so every Phase 1–3 acceptance command is parseable in the primary shell |
| P0-T2 containment probe, run verbatim from a PowerShell script file | printed the resolved module path, the resolved repository root, and `True`, on three lines, exit 0 |
| `_quality-checks.yml` triggers | `workflow_call:` and `workflow_dispatch:` at lines 4-5; P6-T4's dispatch has a real trigger, and the file is identical on `origin/main` so the default-branch requirement is met |
| Pytest step name and defective value | line 74 `Run tests with Pytest`; line 76 `poetry run pytest --cov=src/lexile_corpus_tuner --cov-report=xml --cov-report=term-missing` |
| Codecov step position and keys | immediately after the pytest step; `if: matrix.python-version == '3.13'`; `with` carries `file: ./coverage.xml` plus exactly three other keys (`flags`, `name`, `fail_ci_if_error`). P2-T2's insertion point, P2-T3's "three other keys", and P6-T6's fallback condition all have a real target |
| `coverage.xml` tracked and not ignored | `git ls-files` lists it; `git check-ignore -v` exits 1 with no match |
| `pyproject.toml` coverage config | `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, `data_file = "artifacts/.coverage"`, `omit` limited to test and cache paths. The new module lands inside the configured source, so the plan's "not written" claim for `pyproject.toml` is sound; no `[tool.coverage.xml]` override exists, confirming the root-`coverage.xml` hazard |
| `/artifacts` ignore coverage | `.gitignore:6` is `/artifacts`; `git check-ignore` matches `artifacts/python/coverage.json` and `artifacts/python/checker-coverage.json`. `.coverage` is separately ignored at `.gitignore:49`. Every JSON/XML sibling the plan names is invisible to the scope gates |
| `black --check .` | exit 0, "442 files would be left unchanged" — P4-T1's zero-reformat acceptance is satisfiable |
| `ruff check .` | "All checks passed!" — P4-T2's zero-diagnostic acceptance is satisfiable |
| `pwsh -File scripts/dev-tools/run-actionlint.ps1` | exit 0, zero findings, and the run created no file — P0-T9's baseline, P2-T5's and P4-T7's exit-0 acceptances, and AC-16 are all satisfiable |
| `actionlint` on PATH | present at the user-scoped WinGet location, so the script's download branch is not reached — see **R27** |
| `tools/` directory | absent before and after the live actionlint run; `git check-ignore tools/actionlint/bin/actionlint.exe` exits 1 (not ignored); `.gitignore` contains no `tools` entry — see **R27** |
| `.venv` at repository root | absent; `pyproject.toml` sets `venvPath = "."` and `venv = ".venv"`, so the pyright message the plan anticipates is expected |
| The ten policy documents P0-T1 enumerates | all ten present (`copilot-instructions`, general code-change, general unit-test, Python code-change, Python unit-test, GitHub Actions, and the four rules files for Python, quality tiers, plan acceptance gates, CI workflows) |
| The four blocked policy paths P4-T10 and P6-T2 exclude | all four present, so the exclusions name real files |
| The three new code paths (checker module, both test files) | absent from the working tree and, by the two-dot diff above, absent from `origin/main` — they are genuinely new |
| `tests/conftest.py` `mem_fs_path` | present and behaves as the plan's Phase 3 preamble and P3-T8 describe |
| `scripts/dev_tools/pr_context/verification_evidence.py` `CANONICAL_GLOBS` | `evidence/qa-gates/**/*.md`, `evidence/regression-testing/**/*.md`, `evidence/other/**/*.md`; `evidence/baseline/**` absent |
| `scripts/dev_tools/pr_context/collector.py:148` | filters records to `{"pass", "fail"}`, so an `unparseable` record is dropped and never rendered as a failure |
| `gh run list --json` field set | not re-measured this cycle (network- and auth-dependent); cycle 4 verified `databaseId`, `headSha`, `conclusion`, `url` are all valid, and nothing in Version 1.4 changed P6-T5's field list |
| `quality-tiers.yml` at repository root | absent; known pre-existing per the orchestrator's fact 4; no plan task reads it; not a plan finding and no file was created |
| Full pytest suite | not re-measured this cycle (cost). P0-T6 captures it as a baseline before any P4 assertion depends on it, so a pre-existing failure is surfaced loudly at the sixth task rather than silently |

---

## Write-set boundary — verified against the actual working tree and against `origin/main` at `4dbc48fb`

The eight untracked paths present are the four prior preflight-findings artifacts, `issue.md`, the
plan, the research document, and `spec.md`. This cycle's artifact makes nine. Every one falls inside
entries 5, 6, 7, 8, and 9 — entry 7 by its "entire evidence subtree" wording, which absorbs this
cycle's artifact with no amendment. No tracked file is modified.

Against `origin/main` at `4dbc48fb`: the only tree difference between HEAD and `origin/main` is
`package.json` and `package-lock.json`, so `origin/main` contains none of the feature folder and none
of the three new code paths. Entries 5 through 9's "untracked at `origin/main`" claim is exact, and
entries 2 through 4 are genuinely new files rather than modifications.

Every artifact the plan's tasks write lands under `evidence/baseline/`,
`evidence/regression-testing/`, `evidence/qa-gates/`, or `evidence/other/`, all inside entry 7. The
transient writes the plan identifies are all accounted for: the root `coverage.xml` is tracked and is
restored by each of the three tasks that overwrites it, and the `artifacts/**` siblings are covered by
the `/artifacts` ignore entry. One further transient write is possible under a condition that does not
hold in this environment and is recorded as **R27**.

## Evidence-location compliance

Enumerated all 31 distinct evidence paths named in the plan. Every one resolves under
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/` in a canonical
kind: 10 under `baseline/`, 3 under `regression-testing/`, 16 under `qa-gates/`, 2 under `other/`
(plus the 4 preflight artifacts named in entry 7). No task names `artifacts/baselines/`,
`artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`,
`artifacts/evidence/`, `artifacts/regression-testing/`, `artifacts/post-change/`, or
`evidence/coverage/`. The inherited `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record is restated at plan
line 38 and no task contradicts it. This findings artifact is itself written to `evidence/other/`.

## Falsifiability sweep

Every one of the 53 tasks' acceptance conditions was read for both failure modes —
satisfied-by-emptiness, and cannot-be-evaluated — and no condition of either kind was found.

- **Satisfied-by-emptiness.** All three Phase 4 scope gates pair a non-empty derived-path-list
  condition with their substantive exclusion. P6-T2 pairs a non-empty recorded name list with three
  exclusions. P0-T7 pairs its absent-`TOTAL`-row condition with a positive passed count, and states
  explicitly why. P5-T2 carries four independently falsifiable structural counts and states why it
  does not assert a committed diff. P6-T1 condition (b) is now a self-sourced before-and-after
  comparison that no movement of `origin/main` can satisfy. P6-T7 condition (b) takes its own pre-edit
  count. P5-T1 requires exact row counts and on-disk existence of fifteen named artifacts.
- **Cannot-be-evaluated.** Every command carrying shell-significant punctuation was checked against
  the primary shell, and three classes were measured live rather than reasoned about: the quoted
  `"@{u}"` upstream ref, the `--` pathspec separator in the `coverage.xml` restore and status
  commands, and pytest `::` node IDs in argument position. All three parse correctly under
  `pwsh -NoProfile`. The single-line `-c` probe of P0-T2 was executed verbatim and returned its three
  expected lines. No command in the plan contains `$`, a backtick, or an unquoted brace.
- **Sequencing.** Every artifact a later task reads is produced by an earlier one: P4-T12 reads
  P0-T8, P4-T5, and P3-T10; P5-T1's fifteen non-pending rows all name artifacts written by the end of
  Phase 4; P6-T7 reads P6-T2's and P6-T5's artifacts and P6-T6's disposition. No forward dependency.
- **Coverage-evidence contract.** Baseline coverage is captured at P0-T6 and P0-T8, post-change at
  P4-T4 and P4-T5, new-code at P3-T10, and the delta/threshold verification at P4-T12 reports all
  three pairs numerically with placeholders explicitly prohibited.
- **Expect-fail contract.** P1-T1 through P1-T7 are tagged `[expect-fail]`; P1-T7's artifact carries
  `ExpectedExitCode: 1` and sits under `evidence/regression-testing/`, which is a collected glob, so
  the declaration is load-bearing there. The pass-after counterpart is P2-T4.

Two defects were found, both minor, both recorded below.

---

## R27 — Minor. `scripts/dev-tools/run-actionlint.ps1` can write into `tools/`, which is untracked, un-ignored, and outside the closed write set.

**Finding.** Three tasks — P0-T9, P2-T5, and P4-T7 — run
`pwsh -File scripts/dev-tools/run-actionlint.ps1`. When `actionlint` is neither on `PATH` nor already
present at `tools/actionlint/bin/actionlint.exe`, the script creates that directory and downloads the
executable into it. `tools/` is not in `.gitignore` and `git check-ignore` does not match it, so the
downloaded binary would appear as an untracked path in
`git status --porcelain --untracked-files=all`. That is the input the three Phase 4 scope gates read.
P4-T11 condition (b) would then find a path outside the nine write-set entries and, by its own terms,
"halts the phase" — at the forty-second of fifty-three tasks, after the entire toolchain loop has been
paid for. If the halt were bypassed, P6-T1 condition (c) would fail on a non-empty status, and
committing instead would put the binary into the diff and halt P6-T2 condition (d). This is precisely
the mutual unsatisfiability the plan identifies and solves for the tracked root `coverage.xml` at plan
lines 64-68; the analogous hazard for `tools/` is unhandled.

**Severity is Minor, not Blocking, because the triggering condition is measurably absent.** Measured
in this checkout:

- `Get-Command actionlint` resolves to
  `C:\Users\DanMoisan\AppData\Local\Microsoft\WinGet\Packages\rhysd.actionlint_Microsoft.Winget.Source_8wekyb3d8bbwe\actionlint.exe`,
  so the script's `Find-ActionlintOnPath` succeeds and the download branch is never reached.
- A live `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1` exited 0 and created no file:
  `tools/` did not exist before the run and does not exist after it, and
  `git status --porcelain --untracked-files=all` was byte-identical before and after.
- `PATH` is user-scoped rather than checkout-scoped, so the same resolution holds in any worktree the
  parallel orchestrator creates on this machine.

The plan is therefore executable as written in the expected environment. The finding is recorded
because the write set is declared closed and because the plan already treats one conditional transient
write explicitly rather than leaving it to chance.

**Evidence.** `scripts/dev-tools/run-actionlint.ps1` lines 140-153 (main flow) and lines 48-83
(`Install-Actionlint`, which calls `New-Item -ItemType Directory -Force -Path $BinDir` and
`Invoke-WebRequest -OutFile $zipPath` under `tools\actionlint\bin`). `Resolve-ActionlintPath` roots
`$binDir` at the executing checkout, so the write lands inside the tree the scope gates read.
`git check-ignore -v tools/actionlint/bin/actionlint.exe` exits 1 with no output; `.gitignore`
contains no `tools` entry.

**Plan delta.** In the **Write set** section, immediately after the paragraph beginning "`coverage.xml`
is therefore **not** a tenth write-set entry", insert:

> **Conditional tool download — must not be committed.** `scripts/dev-tools/run-actionlint.ps1`, which
> P0-T9, P2-T5, and P4-T7 invoke, downloads `actionlint` into `tools/actionlint/bin/` when the
> executable is neither on `PATH` nor already present there. `tools/` is not covered by the repository
> ignore file, so a downloaded binary would appear in the working-tree path list the Phase 4 scope
> gates read and would halt P4-T11. In the environment this plan is prepared for, `actionlint` is on
> `PATH` and the download branch is not reached. If P0-T9 nevertheless reports that it downloaded a
> local copy, or if `tools/` appears in the P4-T9 command output, the executor must not commit it:
> record the occurrence in the P4-T11 artifact and remove the directory before continuing. `tools/` is
> not a tenth write-set entry.

And append to the acceptance of **P0-T9**:

> The artifact additionally states whether the script reported downloading a local copy of
> `actionlint`. If it did, `tools/` now exists in the executing checkout and must be removed before
> Phase 4, because it is outside the closed write set and would halt P4-T11.

## R28 — Minor. Plan line 111 attributes G4 Warnings to a section that produces none, contradicting the plan's own correct total.

**Finding.** The "Workflow target state" section closes with: "**Known and accepted plan-gate
finding.** The coverage commands quoted in this section use the bare `--cov` form and contribute G4
Warnings." They do not contribute any finding. That section sits in the document preamble, before the
first task line, and the attribution window defined in `.claude/rules/plan-acceptance-gates.md` states
that "a span in the document preamble, in a phase preamble, or after an intervening heading belongs to
no task and is dropped rather than reported". The four G4 findings actually reported are attributed to
P0-T6, P0-T8, P4-T4, and P4-T5 — all task lines. The plan's own total at lines 192-198 ("one G3
Warning and four G4 Warnings") is correct; only line 111's attribution is wrong, and it contradicts the
basis of that total: if the preamble block contributed, the total would be five rather than four.

This is the same class as R6 in cycle 1 — a self-description of the gate output that does not match the
gate. The consequence for execution is nil, but the plan instructs the executor that "an executor that
sees that exact set has seen the expected result", so an inaccurate statement of where the findings
come from invites a later editor to reconcile the two sentences in the wrong direction.

**Evidence.** The document contains exactly four bare `--cov` occurrences on task lines — in P0-T6,
P0-T8, P4-T4, and P4-T5 — matching the four G4 findings the orchestrator's validator run reported by
task ID. The "Workflow target state" block at plan lines 78-86 contains a fifth bare `--cov`
occurrence, in the pytest step it quotes; it is not among the reported findings, which is what the
attribution window predicts. The plan-gate validator was not re-run by this cycle; the supplied result
was used as the reference.

**Plan delta.** In the **Workflow target state** section, replace:

> **Known and accepted plan-gate finding.** The coverage commands quoted in this section use the bare
> `--cov` form and contribute G4 Warnings.

with:

> **No plan-gate finding arises from this section.** The coverage commands quoted here use the bare
> `--cov` form, but this section sits in the document preamble, before the first task line, and the
> attribution window in `.claude/rules/plan-acceptance-gates.md` drops a command span that belongs to
> no `P#-T#`. The four G4 Warnings this document does receive are attributed to P0-T6, P0-T8, P4-T4,
> and P4-T5, which are task lines.

---

## Signal

Zero Blocking findings. Two minor findings, R27 and R28, are recorded above with precise deltas and
are outstanding at clearance. Minor findings alone do not prevent an all-clear, and the plan is
executable as written in the measured environment.

PREFLIGHT: ALL CLEAR
