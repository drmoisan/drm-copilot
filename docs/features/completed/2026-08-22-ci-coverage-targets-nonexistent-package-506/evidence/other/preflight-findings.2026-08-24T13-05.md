# Preflight findings — cycle 4

- Timestamp: 2026-08-24T13-05
- Plan under validation: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md` (Version 1.3)
- Validator: `atomic-executor`, directive `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Checkout: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a56705110f06fb612`, branch `bug/ci-coverage-targets-nonexistent-package-506-r2`
- Signal: `PREFLIGHT: REVISIONS REQUIRED`
- Blocking findings: 2 (R21, R22). Minor findings: 4 (R23, R24, R25, R26).
- No plan task was executed. No file in the working tree was created, modified, or deleted other than this findings artifact.
- The mandatory plan-gate validator was **not** re-run by this cycle. The orchestrator-supplied result (PASS, zero Blocking, one G3 at P0-T7 and four G4 at P0-T6, P0-T8, P4-T4, P4-T5) was accepted as given.
- No evidence-location override was supplied to this cycle and none was rejected. This artifact is written to the canonical `evidence/other/` location.

---

## Cycle-1 through cycle-3 findings — disposition

Each closure below was verified against the Version 1.3 plan text, and where the finding rested on an
environment premise, re-measured against the working tree. The plan header's claim of closure was not
accepted as evidence for any row.

| Finding | Severity as filed | Disposition at Version 1.3 |
| --- | --- | --- |
| R1 — Phase 4 scope gates gate nothing | Blocking | **Closed.** Unchanged from cycle 3. P4-T9/T10/T11 each pair a non-empty condition (a) with a substantive exclusion (b). |
| R2 — tracked `coverage.xml` overwritten | Blocking | **Closed.** Premises re-measured this cycle against the advanced `origin/main`: `git ls-files coverage.xml` lists it, `git check-ignore -v coverage.xml` exits 1. Restore-plus-confirm pair present at P0-T7, P0-T8, P4-T5; recovery instruction present at P6-T1. |
| R3 — AC checked off before evidence exists | Blocking | **Closed**, superseded by R9. |
| R4 — hardcoded worktree root | Blocking | **Closed.** Root resolved once at P0-T2 (plan line 24, line 193). Branch half closed by R15 below. |
| R5 — P0-T7 has no declared exit-code expectation | Minor | **Closed in form.** `ExpectedExitCode:` present at P0-T7. Its practical effect is nil for a `evidence/baseline/` artifact; see R25. |
| R6 — self-description of coverage values wrong | Minor | **Closed.** Plan lines 180-186 state one G3 plus four G4, matching the orchestrator's validator run. |
| R7 — evidence-schema claim broader than the tasks | Minor | **Closed**, superseded by R14. |
| R8 — loader must use `Path.read_text` | Minor | **Closed.** Mandatory I/O constraint at plan line 138, cross-referenced by the Phase 3 preamble and P3-T8. |
| R9 — AC-14/AC-15 checked off before their observable exists | Blocking | **Closed.** Phase 5 preamble enumerates four deferrals; P5-T1 requires exactly four `PENDING PHASE 6` rows; P6-T7 closes all four. |
| R10 — write set omits two committed feature-folder files | Blocking | **Closed.** Entries 8 and 9 present and annotated. Residual half closed by R16. |
| R11 — Windows separator makes the containment test fail | Blocking | **Closed.** Probe compares two resolved `pathlib` objects; prohibition on a string-prefix comparison stated inline. `scripts/dev_tools/plan_gate_coverage.py`, `scripts/__init__.py`, `scripts/dev_tools/__init__.py` all re-verified present this cycle. |
| R12 — spec check-off condition cannot fail | Blocking | **Closed.** P5-T2 carries four independently falsifiable structural conditions. |
| R13 — Trap 4 binding phrase and quoting case | Minor | **Closed.** Trap 4 covers all three derivation steps and binds the phrase "derived path list". |
| R14 — evidence-accounting enumeration and carve-out | Minor | **Closed.** Re-counted independently this cycle; see the counts table below. 23 + 10 + 20 = 53 = the plan's actual task count. |
| R15 — Phase 6 hardcodes a branch name | Blocking | **Closed in substance, defeated in effect on this platform.** The Branch name preamble is present at plan line 26; P0-T2 resolves a sixth value `git rev-parse --abbrev-ref HEAD` and requires it recorded, non-empty, and not the literal `HEAD`; the artifact requirement reads "six commands"; P6-T3 is `git push --set-upstream origin HEAD`; P6-T4 `--ref` and P6-T5 `--branch` take the resolved name as operand. `grep -c "bug/ci-coverage"` against the plan returns 0. **However, the two new P6-T3 conditions cannot be evaluated in the repository's primary shell.** Refiled as R21 (Blocking) and R24 (minor). |
| R16 — write set omits the preflight-findings artifacts | Blocking | **Closed.** Entry 7 now reads "**the entire evidence subtree**" (plan line 54); the "Why entries 8 and 9 exist" paragraph carries the matching sentence and states that entry 7 was widened in place. Entry count independently re-counted as nine; P4-T11(b) and P6-T2(d) both read "nine" and both name entries 8 and 9 plus the entry-7 subtree. Verified that the widened entry covers every path the first commit will include (see the write-set table below). One stale count survives inside the widened entry and is refiled as R23 (minor). |
| R17 — P6-T6 skip branch renders the AC-17 artifact unparseable | Blocking | **Closed, and the remedy independently verified sound.** The skip branch now writes `evidence/qa-gates/d3-fallback-disposition.md` with a `Disposition: SKIPPED` row; the prohibition on any `EXIT_CODE:` row in `green-workflow-run.md` is stated at P6-T6 and mirrored at P6-T5. P6-T6 is moved out of the carve-out into the record-only list. Counts restated as 23 command, 10 record-only, 20 carve-out, reconciling to 53 — independently re-counted and correct. The new artifact was checked against the collector: it lands under a canonical glob, parses to `normalized_result="unparseable"` for want of `Command:`/`EXIT_CODE:`, and `scripts/dev_tools/pr_context/collector.py:148` filters records to `{"pass", "fail"}`, so it is dropped silently and never rendered as a failure. It does not trip the collector, and the record-only classification is consistent with the evidence-accounting rule. |
| R18 — P0-T7's exit-code expectation read against the wrong command | Minor | **Closed as applied.** P0-T7 is split into `defective-coverage-command-repro.md` (pytest only, one `EXIT_CODE:` row, carrying `ExpectedExitCode:`) and `defective-coverage-command-restore.md` (restore plus status confirmation, no expectation row); the acceptance requires both artifacts and states that the absence of either is a failure. The planner's claim that P0-T8 and P4-T5 do not have the defect because they declare no `ExpectedExitCode:` row is correct on its own terms. The split is retained, but its stated rationale is inaccurate for the evidence kind it names; refiled as R25 (minor). |
| R19 — P6-T7 line-count condition unsatisfiable on the action path | Blocking | **Closed.** P6-T7 condition (b) now compares this task's own pre-edit and post-edit counts of `spec.md`, with the reason stated inline; the closing paragraph records that P5-T2's count is the reference only on the skip path, and that the P6-T6 action branch's superseding count is recorded in the evidence index. The condition remains falsifiable — a checkbox edit that wraps or reflows a line changes the count — and P6-T7 can obtain its pre-edit count because it takes it itself immediately before its own edit, with no dependency on any earlier task. |
| R20 — P6-T6 action branch does not satisfy AC-12's alternative form | Minor | **Closed.** The action branch now requires the executor to file the follow-up issue and link it in the Rollout and Follow-up section, with the reason stated inline. P6-T7 gained condition (g), which blocks the AC-12 check-off on the action path unless that link is present. Condition count independently re-counted as seven, (a) through (g), matching the stated "all seven conditions required". |
| Cycle-1 advisory — pyright `.venv` message | Advisory | **Applied**, unchanged, at P0-T5 and P4-T3. |

---

## Structure and counts — independently recounted this cycle

Every count below was recomputed from the document rather than read from the plan's own statement of it.

| Check | Recomputed result | Plan's stated value | Agree |
| --- | --- | --- | --- |
| Phase headings | Seven, canonical `### Phase N — Title`, N = 0..6, no gaps | seven | yes |
| Total unchecked tasks | 53 | fifty-three | yes |
| Per-phase task counts | 9, 7, 5, 10, 12, 3, 7 | "nine plus seven plus five plus ten plus twelve plus three plus seven" | yes |
| Task IDs | Contiguous and sequential within every phase; no duplicate, no gap | — | yes |
| Command-task enumeration | P0-T2..P0-T9 (8) + P1-T7 (1) + P2-T4,T5 (2) + P3-T9,T10 (2) + P4-T1..T7,T9 (8) + P6-T2,T5 (2) = **23** | twenty-three | yes |
| Record-only enumeration | P0-T1 (1) + P4-T8,T10,T11,T12 (4) + P5-T1,T2,T3 (3) + P6-T6,T7 (2) = **10** | ten | yes |
| Carve-out enumeration | P1-T1..T6 (6) + P2-T1..T3 (3) + P3-T1..T8 (8) + P6-T1,T3,T4 (3) = **20** | twenty | yes |
| Accounting reconciliation | 23 + 10 + 20 = 53 | fifty-three | yes |
| Write-set entries | Nine numbered entries, 1 through 9 | nine (three occurrences: entry-7 paragraph, P4-T11(b), P6-T2(d)) | yes |
| Workflow-contract tests authored | P1-T1..P1-T6 = **6** | six (P1-T7, P2-T4) | yes |
| Checker unit tests authored | P3-T2 (1) + P3-T3 (2) + P3-T4..T7 (4) + P3-T8 (2) = **9** | nine (P3-T9) | yes |
| Spec acceptance criteria | `grep -c "^- \[ \] AC-" spec.md` = **19**, all unchecked | nineteen | yes |
| Phase 5 / Phase 6 AC split | 15 at P5-T2 + 4 at P6-T7 = 19 | fifteen, four, nineteen | yes |
| P0-T2 command count | 6 (`--show-toplevel`, `--abbrev-ref HEAD`, `poetry env info --path`, probe, `rev-parse HEAD`, `rev-parse origin/main`) | six | yes |
| P0-T8 / P4-T5 command count | 4 each | four each | yes |
| P6-T7 acceptance conditions | (a) through (g) = **7** | all seven | yes |
| Preflight-findings artifacts named by entry 7 | 3 named; **4** will exist once this cycle's artifact is written | "three" (three occurrences) | **no — see R23** |

No count drift was found other than the "three preflight-findings artifacts" statement recorded as R23.

## Environment premises — re-measured this cycle

`origin/main` has advanced since cycle 3. Every premise was therefore re-measured rather than carried forward.

| Premise | Measured result |
| --- | --- |
| `git rev-parse HEAD` | `9497c612f5e7e6bfa63454285205c69691bae8d6` |
| `git rev-parse origin/main` | `4dbc48fb1baff170e904576f992e539c7cd37cb5` — **advanced past the branch point since cycle 3** |
| `git merge-base origin/main HEAD` | `9497c612…` — HEAD is an ancestor of `origin/main` |
| `git diff --name-only origin/main...HEAD` | empty (three-dot resolves to the merge base, so Trap 2's conclusion survives the advance) |
| `git diff --name-only origin/main..HEAD` | `package-lock.json`, `package.json` — non-empty; the plan uses the three-dot form in every committed-diff condition, which is correct |
| `git status --porcelain --untracked-files=all` | 7 untracked paths, 0 modified tracked paths |
| `git rev-parse --abbrev-ref --symbolic-full-name "@{u}"` (bash, quoted) | `origin/main`, exit 0 |
| Same command unquoted under `pwsh -NoProfile` | **`ParserError: Missing '=' operator after key in hash literal.`** — see R21 |
| Same command quoted under `pwsh -NoProfile` | `origin/main`, exit 0 |
| `_quality-checks.yml` declares `workflow_dispatch` | line 5, confirmed |
| Pytest step name and defective value | line 74 `Run tests with Pytest`, line 76 `--cov=src/lexile_corpus_tuner`, confirmed |
| Codecov step position and keys | lines 79-86, immediately after the pytest step; `file: ./coverage.xml` plus exactly three other `with` keys (`flags`, `name`, `fail_ci_if_error`); `if: matrix.python-version == '3.13'`. P2-T2's insertion point, P2-T3's "three other keys", and the P6-T6 fallback condition all have a real target |
| `coverage.xml` tracked and not ignored | `git ls-files` lists it; `git check-ignore` reports no match |
| `scripts/dev_tools/plan_gate_coverage.py`, `scripts/__init__.py`, `scripts/dev_tools/__init__.py` | all present |
| `gh run list --json` field set | includes `databaseId`, `headSha`, `conclusion`, `url` — P6-T5's field list is valid |
| `scripts/dev_tools/pr_context/verification_evidence.py` `CANONICAL_GLOBS` | `evidence/qa-gates/**/*.md`, `evidence/regression-testing/**/*.md`, `evidence/other/**/*.md`. **`evidence/baseline/**` is not collected** — see R25 |
| `scripts/dev_tools/pr_context/collector.py:148` | filters records to `{"pass", "fail"}`, so an `unparseable` record is dropped, never rendered as a failure |
| `quality-tiers.yml` at repository root | absent; known pre-existing per the orchestrator's fact 4; no plan task reads it; not a plan finding and no file was created |

## Write-set boundary — verified against the actual working tree

The seven untracked paths present are the three prior preflight-findings artifacts, `issue.md`,
the plan, the research document, and `spec.md`. This cycle's artifact makes eight. All eight fall
inside entries 5, 6, 7, 8, and 9, entry 7 by its "entire evidence subtree" wording. No tracked file
is modified. Every artifact the plan's tasks write lands under `evidence/baseline/`,
`evidence/regression-testing/`, `evidence/qa-gates/`, or `evidence/other/`, all inside entry 7. The
new-file and modified-file paths of Phases 1 through 3 are entries 1 through 4. The widened entry 7
therefore does cover every path the first commit will include, including artifacts written by
preflight cycles the plan does not enumerate.

## Evidence-location compliance

Every artifact path named by the plan resolves under
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/` in one of the
canonical kinds. No task names `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`,
`artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/evidence/`, or `evidence/coverage/`. The
inherited `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record is restated in the plan and no task
contradicts it.

## Falsifiability sweep

Every acceptance condition was read for both failure modes: satisfied-by-emptiness, and
cannot-be-evaluated. All three Phase 4 scope gates pair a non-empty-list condition with their
substantive exclusion; P0-T7 pairs the absent-`TOTAL`-row condition with a positive passed count;
P5-T2 carries four independently falsifiable structural counts; P6-T2 pairs a non-empty name list
with three exclusions; P6-T7's own-count comparison is falsifiable and self-sourced. Two defects
were found and are recorded as R21 (a condition that cannot be evaluated) and R22 (a condition that
can no longer fail).

---

## R21 — BLOCKING. P6-T3 conditions (b) and (c) cannot be evaluated in the repository's primary shell.

**Finding.** Both new conditions pass the upstream ref as the bare token `@{u}`. In PowerShell — the
primary shell of this environment — `@{` opens a hash-literal expression, so the argument is consumed
by the parser before `git` is ever invoked and the command raises a `ParserError`. Neither condition
can return a result, so the R15 remedy is inert on this platform in exactly the way the R4 remedy was
inert in cycle 2.

**Evidence.** Measured in this checkout:

```
pwsh -NoProfile -Command 'git rev-parse --abbrev-ref --symbolic-full-name @{u}'
  ParserError:
  Line |
     1 |  git rev-parse --abbrev-ref --symbolic-full-name @{u}
       |                                                     ~
       |  Missing '=' operator after key in hash literal.

pwsh -NoProfile -Command 'git rev-parse --abbrev-ref --symbolic-full-name "@{u}"'
  origin/main
```

The same unquoted form succeeds under Git Bash, which is why the defect is invisible unless the shell
is named. The plan names no shell, and the environment declares PowerShell primary.

**Plan delta.** In **P6-T3**, replace conditions (b) and (c) with:

> **(b)** `git rev-parse --abbrev-ref --symbolic-full-name "@{u}"` prints a value of the form
> `origin/<branch>`, and that value with the leading `origin/` prefix removed equals the resolved
> branch name recorded by P0-T2; and **(c)** `git rev-parse HEAD` equals `git rev-parse "@{u}"`.
> **The upstream ref must be written in double quotes in both conditions.** An unquoted `@{u}` is
> parsed by PowerShell as the opening of a hash literal and raises
> `ParserError: Missing '=' operator after key in hash literal` before `git` is invoked, so the
> condition returns no result at all rather than a failing one. A later editor must not remove the
> quotes.

## R22 — BLOCKING. P6-T1 condition (b) can no longer fail: `origin/main` has advanced past the branch point.

**Finding.** P6-T1 condition (b) requires that `git rev-parse HEAD` differ from `git rev-parse
origin/main`, and states that this "is what distinguishes a successful commit from a command that
never ran". That inference holds only while the remote-tracking ref `origin/main` still points at the
branch point. It does not in this checkout, and it need not in the execution worktree either: any
fetch during a parallel run advances `origin/main` while the item's branch stands still. Once that
happens the condition is true with zero commits made, so P6-T1's only proof that the commit occurred
is a condition satisfied by an unrelated fact — the same unfalsifiable-gate class this work item
exists to repair, reintroduced at the plan's single commit.

**Evidence.** Measured in this checkout, with no commit made and none possible from a preflight run:

- `git rev-parse HEAD` = `9497c612f5e7e6bfa63454285205c69691bae8d6`
- `git rev-parse origin/main` = `4dbc48fb1baff170e904576f992e539c7cd37cb5`
- The two differ. Condition (b) is therefore already satisfied before P6-T1 runs.
- `git merge-base --is-ancestor HEAD origin/main` succeeds, so the advance is a fast-forward of the
  remote-tracking ref, not a divergence. Cycle 3 measured both refs equal at `9497c612…`; the ref
  advanced between cycles, which demonstrates the mechanism rather than merely hypothesising it.
- Condition (c), the clean-tree assertion, is satisfied by emptiness by the plan's own account, and
  condition (a) only reports that the commit command exited 0 — which `git commit` also does not do
  when there is nothing to commit, but which the executor could satisfy by recording the exit of a
  command that staged nothing. With (b) inert, no condition of P6-T1 proves a commit was created.

Secondary, same cause: the plan asserts as fact at lines 154, 256, 269, and 286 that "before P6-T1
`HEAD` still equals `origin/main`". That premise is measurably false here. The conclusion the plan
draws from it — that `git diff --name-only origin/main...HEAD` is empty before the first commit —
nevertheless survives, because the three-dot form resolves to the merge base, which is `HEAD`. The
prose should be corrected so a later editor does not rebuild a condition on the false premise.

**Plan delta.**

1. In **P6-T1**, change the command list from "then run `git rev-parse HEAD`, `git rev-parse
   origin/main`, and `git status --porcelain`" to: "run `git rev-parse HEAD` **immediately before**
   the commit command and record its value; then commit; then run `git rev-parse HEAD` again and
   `git status --porcelain`, from the resolved repository root."
2. Replace condition **(b)** with:

   > **(b)** the post-commit `git rev-parse HEAD` differs from the pre-commit `git rev-parse HEAD`
   > recorded above, proving a commit was actually created. A clean-tree assertion is by construction
   > satisfied by emptiness, and a comparison against `origin/main` cannot serve as the proof either:
   > the remote-tracking ref `origin/main` may already have advanced past the branch point, in which
   > case `HEAD` differs from it with zero commits made and the condition passes vacuously. Both SHA
   > values are recorded in the P6-T2 artifact alongside the commit SHA, per the carve-out that
   > consolidates P6-T1's state into that artifact.
3. In the **Trap 2** paragraph (line 154), replace "Before that point `HEAD` still equals
   `origin/main`" with: "Before that point the branch carries no commit of its own, so `HEAD` is the
   merge base of `origin/main` and `HEAD`". Apply the same correction to the Phase 4 preamble (line
   256), the Phase 5 preamble (line 269), and the opening sentence of P6-T2 (line 286). The
   three-dot form's emptiness before the first commit is unaffected by whether `origin/main` has
   advanced, and the corrected wording states the reason it is unaffected.

## R23 — Minor. The "three preflight-findings artifacts" count is stale the moment a preflight cycle writes a fourth.

**Finding.** Write-set entry 7 enumerates exactly three preflight-findings artifacts by name, and
P4-T11(b) and P6-T2(d) each say "the three preflight-findings artifacts under `evidence/other/`".
This cycle writes a fourth, `preflight-findings.2026-08-24T13-05.md`, and any further cycle writes a
fifth. The gates themselves still pass, because entry 7's operative clause is "**the entire evidence
subtree**" and a fourth artifact falls inside it; only the count statement becomes false. The plan has
now been broken twice by a self-stated count that fell out of agreement with the artefacts, so the
count should be removed rather than incremented.

**Evidence.** `git status --porcelain --untracked-files=all` lists three preflight-findings artifacts
at the time of this reading; this artifact makes four. Plan lines 54, 260, and 286 each state
"three".

**Plan delta.**

1. In **write-set entry 7**, replace the sentence "Those three artifacts are authored upstream of
   this plan…" with: "Those artifacts are authored upstream of this plan, are untracked at
   `origin/main`, and are committed unmodified by P6-T1. No task in this plan edits any of them. The
   three named above were present when this plan was last revised; a later preflight cycle may add
   further artifacts of the same form, and the subtree wording of this entry covers them without
   amendment."
2. In **P4-T11(b)** and in **P6-T2(d)**, replace "the three preflight-findings artifacts under
   `evidence/other/`" with "every preflight-findings artifact under `evidence/other/`".

## R24 — Minor. P6-T3 condition (b)'s "branch component" extraction is undefined for a slash-bearing branch name.

**Finding.** Condition (b) requires that the upstream ref's "branch component" equal the resolved
branch name, but does not say how the component is obtained. `--abbrev-ref` prints `origin/<branch>`,
and branch names in this repository routinely contain a slash (`bug/ci-coverage-…`). Taking the last
slash-separated segment yields `ci-coverage-…` and never equals the resolved name; taking everything
after the first slash is correct. An executor that picks the wrong reading fails a correct push.

**Evidence.** Measured: `git rev-parse --abbrev-ref --symbolic-full-name "@{u}"` returns `origin/main`
in this checkout. The current branch is `bug/ci-coverage-targets-nonexistent-package-506-r2`, which
contains a slash, so the two readings diverge on the very branch class this work item uses.

**Plan delta.** Fold into the R21 replacement text, which already states the extraction explicitly:
"that value with the leading `origin/` prefix removed". If R21's delta is applied as written, R24 is
closed by it; apply the two together and do not apply R21 in any form that omits the prefix wording.

## R25 — Minor. P0-T7's split rationale cites a collector that never reads the artifact in question.

**Finding.** P0-T7 justifies the R18 split, and justifies the `ExpectedExitCode:` row, by the
behaviour of "the repository's evidence collector". Both artifacts are written under
`evidence/baseline/`, which is not one of the collector's canonical globs, so neither the last-wins
`EXIT_CODE:` hazard nor the expectation-normalization benefit applies to them at all. The task's
stated reason for its own structure is therefore wrong. The split itself is harmless and should be
kept — it matches the per-file expectation guidance in
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md` and costs nothing — but a task that
records a false reason invites a later editor to recombine the artifacts on the grounds that the
cited mechanism does not exist.

**Evidence.** `scripts/dev_tools/pr_context/verification_evidence.py:24-28`:

```
CANONICAL_GLOBS: tuple[str, str, str] = (
    "evidence/qa-gates/**/*.md",
    "evidence/regression-testing/**/*.md",
    "evidence/other/**/*.md",
)
```

`evidence/baseline/**` is absent. By contrast P1-T7's `ExpectedExitCode: 1` sits under
`evidence/regression-testing/`, which is collected, so that declaration is load-bearing and correct.
The last-wins parse at lines 122-128 and the first-wins expectation parse at line 129 are as cycle 3
described; only the applicability to a baseline-kind artifact is wrong.

**Plan delta.** In **P0-T7**, replace the sentence beginning "The repository's evidence collector
reads the **last** `EXIT_CODE:` row in a file…" with:

> The split follows the per-file expectation rule in
> `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, which states that the expectation
> field is per-file and not per-command and directs that a gate needing a non-zero expectation be
> recorded in its own artifact file. A restore row recorded after the pytest row would be the row a
> per-file expectation is tested against, so the two are separated. Note that
> `evidence/baseline/**` is **not** one of the canonical globs the repository's verification-evidence
> collector discovers, so neither artifact is read by that collector and the `ExpectedExitCode:` row
> is a record of intent rather than an input to it; the split is retained regardless, because the
> per-file rule is what governs the artifact's shape.

And replace the later sentence "The `ExpectedExitCode:` row is required so the evidence collector
normalizes this artifact to a pass instead of rendering a succeeded task as a failure against the
default expectation of zero" with: "The `ExpectedExitCode:` row records that a non-zero exit is the
expected outcome of a deliberately defective command, so a reader does not mistake it for a failed
task."

## R26 — Minor. The plan does not verify that the executing checkout contains the feature-folder documents it edits and commits.

**Finding.** The plan states that the entire feature folder is untracked at `origin/main`, and the
orchestrator's fact 1 states that execution happens in a fresh worktree the parallel orchestrator
branches from `origin/main`. A worktree branched from `origin/main` contains no untracked file, so
unless the preparation surface copies the feature folder into it, `spec.md`, `issue.md`, the research
document, the plan, and the preflight-findings artifacts are all absent at execution time. The plan
has no precondition that detects this. Phases 0 through 4 would complete normally — they only create
files — and the run would halt at P5-T2, the forty-sixth of fifty-three tasks, when it tries to edit
a `spec.md` that is not there, after the whole toolchain loop has been paid for. Write-set entries 5
through 9 and both scope gates also silently describe a state that does not obtain.

**Evidence.** `git status --porcelain --untracked-files=all` in this preparation checkout reports all
seven feature-folder documents as untracked (`??`), and `git diff --name-only origin/main...HEAD` is
empty, so none of them exists in `origin/main`. Plan lines 46, 55, 56, 58, and 276 all depend on the
documents being present-and-untracked in the executing checkout; no task asserts it. Severity is
minor rather than Blocking because the failure is loud rather than silent and the preparation surface
plausibly carries the folder across, but the failure arrives late and with no stated diagnosis.

**Plan delta.** Append to the acceptance of **P0-T1** (a record-only task, so the command-task
enumeration and the count of twenty-three are unaffected):

> The artifact additionally records, as a present-or-absent statement for each, whether
> `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md`,
> `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/issue.md`,
> `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/research/2026-08-23T23-45-ci-coverage-target-remedy-research.md`,
> and this plan file exist in the executing checkout. All four must be present. An absent document is
> a BLOCKED verdict at this task and the plan must not proceed, because P5-T2 edits `spec.md` and
> write-set entries 5 through 9 and both scope gates all presuppose the feature folder is present and
> untracked in the executing checkout. Detecting the absence here costs one task; detecting it at
> P5-T2 costs the entire toolchain loop first.

---

PREFLIGHT: REVISIONS REQUIRED
