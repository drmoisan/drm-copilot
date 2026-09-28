# Policy Audit (Reaudit) — Issue #506 (ci-coverage-targets-nonexistent-package)

- **Timestamp:** 2026-08-25T23-20
- **Issue:** #506
- **Cycle:** exit reaudit of remediation cycle 1. The entry record is `policy-audit.2026-08-25T22-57.md`, which is not superseded and not overwritten.
- **Work Mode:** `full-bug` (marker read from `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/issue.md` line 13). AC source is `spec.md` only.
- **Branch:** `bug/ci-coverage-targets-nonexistent-package-506-r3`
- **Branch head at reaudit:** `e825b5e62f7b816859eee8fae2c7e23ddb40679b`
- **Base:** `origin/main` at `8ca66c1db827cbfb59261ca0b85bb5b7a766908e`; `git merge-base HEAD origin/main` returns the same SHA, so the branch is fully up to date with `main` and the three-dot diff carries only this work item's change.
- **Review worktree:** `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae6ac3aa9ae64fae4`

---

## Scope Statement

The audited scope is the full branch diff `git diff origin/main...HEAD`, re-derived in this reaudit rather than carried over. It is 48 files, 7310 insertions, 2 deletions — five files larger than the 43 the entry audit recorded, because two commits landed after that audit:

| Commit | Subject | Effect on scope |
| --- | --- | --- |
| `15a9c6b3` | `docs(506): record post-merge toolchain verification at the branch head` | adds `evidence/qa-gates/post-merge-toolchain-verification.md` |
| `e825b5e6` | `docs(506): record the feature-review audit artifacts and remediation inputs` | adds the four `2026-08-25T22-57` review artifacts |

`git diff --name-only 890e2ac9 HEAD` returns exactly those five paths. **No production file, test file, or workflow file changed between the entry audit head and this reaudit head.** Every code-level verdict in the entry audit therefore still describes the code under review, and each is re-confirmed below by fresh measurement rather than by reference alone.

Production and test files in the diff (four, unchanged since the entry audit):

| Path | Status | Lines |
| --- | --- | --- |
| `.github/workflows/_quality-checks.yml` | modified | 96 |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | new | 324 |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | new | 188 |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | new | 157 |

The remaining 44 changed files are the feature-folder documents and the evidence subtree under `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/`.

**Languages with changed files in the branch diff:** Python (three files) and GitHub Actions YAML (one file). `git diff --name-only origin/main...HEAD | sed 's/.*\.//' | sort | uniq -c` returns `44 md`, `3 py`, `1 yml` and nothing else. No TypeScript, PowerShell, C#, or bash file is changed on this branch, so those four languages have zero changed files and no coverage verdict is owed for them.

### Working-tree state

The working tree is deliberately not clean. `git status --porcelain` reports:

```
 M docs/features/active/.../evidence/other/ac-evidence-index.md
 M docs/features/active/.../plan.2026-08-23T23-21.md
 M docs/features/active/.../spec.md
?? docs/features/active/.../evidence/qa-gates/d3-fallback-disposition.md
?? docs/features/active/.../evidence/qa-gates/green-workflow-run.md
```

All five paths are documentation under the feature folder. None is a production file, a test file, or a workflow file. This state is the plan's explicit commit-boundary design and is assessed in section 3.3.

## Rejected Scope Narrowing

None. The caller prompt supplied the full branch diff against `origin/main` as the review scope, named the branch head, and instructed that all nineteen acceptance criteria be re-evaluated. The prompt's "Focus specifically on" list directs attention to particular questions but does not restrict the audited scope: it neither excludes a changed file nor marks any language's coverage as out of scope, and the full-diff audit below was performed regardless. Nothing was rejected under the scope invariant.

## PR-Context Artifact Status

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in this worktree. Scope was therefore derived from the other authoritative source named in the scope invariant: the resolved base branch. `git merge-base HEAD origin/main` equals `origin/main`, and `git diff --name-status origin/main...HEAD` was read in full. This yields the same information the appendix would carry. The absence is recorded for transparency; it is not a finding, because the scope invariant admits the resolved base branch as a legitimate scope source in its own right.

---

## Verdict Summary

| # | Policy | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | `.claude/rules/ci-workflows.md` — pwsh exit-code rule | **PASS (not triggered)** | Workflow declares no `shell:` key and no `defaults.run.shell`; `runs-on: ubuntu-latest` |
| 2 | `.claude/rules/ci-workflows.md` — general workflow authoring | **PASS** | actionlint exit 0; run `32925230528` additionally executes the workflow end to end on the runner |
| 3 | `modified-workflow-needs-green-run` (feature-review-workflow SKILL) | **PASS** | Run `32925230528`, conclusion `success`, `headSha` `e825b5e6` == `git rev-parse HEAD`; see section 3 |
| 4 | `.claude/rules/quality-tiers.md` — uniform 85% line / 75% branch | **PASS** | Repo-wide 92.6469% line, 85.2161% branch; new file 96.7213% line, 85.7143% branch; see section 4 |
| 5 | `.claude/rules/general-unit-test.md` — Coverage Exclusion Policy | **PASS** | No `exclude`/`omit` entry added; `pyproject.toml` absent from the diff |
| 6 | `.claude/rules/general-unit-test.md` — no temp files in tests | **PASS** | Both new test files use the in-memory `mem_fs_path` fixture |
| 7 | `.claude/rules/general-unit-test.md` — test file location | **PASS** | Both tests under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/` |
| 8 | `.claude/rules/general-unit-test.md` — scenario completeness | **PARTIAL (non-blocking)** | Two named validation conditions carry no unit test; NB-1, re-affirmed non-blocking in section 8 |
| 9 | `.claude/rules/general-code-change.md` — 500-line file limit | **PASS** | Largest changed file is 324 lines |
| 10 | `.claude/rules/general-code-change.md` — I/O boundaries | **PASS** | `find_threshold_breaches` is pure; `load_totals` is the sole I/O seam |
| 11 | `.claude/rules/general-code-change.md` — fail fast, no broad catch | **PASS** | Two narrow `except` clauses (`OSError`, `json.JSONDecodeError`) plus one narrow domain handler |
| 12 | `.claude/rules/general-code-change.md` — seven-stage toolchain loop | **PASS** | Green run `32925230528` executes format, lint, type, test, and the new gate on all four matrix legs at this exact head |
| 13 | `.claude/rules/python.md` — Black | **PASS** | `poetry run black --check` on the three files: exit 0, "3 files would be left unchanged" |
| 14 | `.claude/rules/python.md` — Ruff | **PASS** | `poetry run ruff check` on the three files: exit 0, "All checks passed!" |
| 15 | `.claude/rules/python.md` — Pyright | **PASS** | 0 errors, 0 warnings (post-merge artifact and the four CI legs at this head) |
| 16 | `.claude/rules/python.md` — Pytest | **PASS** | 15 feature tests pass locally at this head; full suite green on all four CI legs |
| 17 | `.claude/rules/python.md` — logging, not `print` | **PARTIAL (informational)** | CLI writes to stderr via `print`; NB-2, re-affirmed no-action in section 8 |
| 18 | `.claude/rules/plan-acceptance-gates.md` (G1–G6) | **PASS** | Plan validator re-run against the **modified** plan: `plan validation passed`, five Warnings, zero Blocking |
| 19 | Evidence Location Invariant | **PASS** | `validate_evidence_locations.py --root .` exit 0; no prohibited path in the diff; see section 7 |
| 20 | `.claude/rules/tonality.md` | **PASS** | The five remediation-authored documents read neutral and evidence-first; see section 6 |
| 21 | `.claude/rules/orchestrator-state.md` | **N/A** | No orchestrator-state file in the branch diff |
| 22 | `.claude/rules/parallel-orchestration.md` | **N/A** | No parallel artifact in the branch diff |
| 23 | `.claude/rules/benchmark-baselines.md` | **N/A** | No `scripts/benchmarks/**` path in the branch diff |

**Blocking findings: 0.**

Row 3 moved from **FAIL (Blocking)** in the entry audit to **PASS** here. That is the only verdict that changed. Rows 8 and 17 remain PARTIAL and remain non-blocking; both were deliberately not remediated and section 8 re-examines whether that judgment still holds.

---

## 1. `.claude/rules/ci-workflows.md` — PASS

### 1.1 Deliberately-failing nested command pattern — NOT TRIGGERED

The rule binds only to a step whose `run:` block uses `shell: pwsh` (or a repo `pwsh` default) and intentionally invokes a command expected to fail.

- `.github/workflows/_quality-checks.yml` declares no `shell:` key on any step and no `defaults.run.shell` at workflow or job level.
- `runs-on: ubuntu-latest`, whose GitHub Actions default shell is `bash`.
- Neither step added by this change invokes a deliberately-failing nested command. The new `Enforce Python coverage thresholds` step is expected to succeed; its non-zero exit is the gate's intended failure signal, not a residual leaked `$LASTEXITCODE` from a nested command whose own verification already passed.

No `$LASTEXITCODE = 0` reset and no explicit `exit 0` is required.

### 1.2 General workflow authoring — PASS

Beyond actionlint, this reaudit has evidence the entry audit could not cite: the workflow was executed end to end on GitHub-hosted runners at this exact head. Every step of every one of the four matrix legs reports `conclusion: success`, including the new enforcement step. A workflow-authoring defect that only manifests on the runner would have surfaced there.

---

## 2. Toolchain (`.claude/rules/python.md`, `.claude/rules/general-code-change.md`) — PASS

Two independent lines of evidence, both bound to head `e825b5e6`.

### 2.1 Runner evidence — the authoritative line

`gh run view 32925230528` reports every step of every leg as `success`. The step sequence per leg, verified on the 3.13 leg and identical in structure on 3.10, 3.11, and 3.12:

| Step | Conclusion |
| --- | --- |
| Verify poetry.lock is in sync | success |
| Check formatting with Black | success |
| Lint with Ruff | success |
| Type check with Pyright | success |
| Verify Codex agent deployment profiles | success |
| Run tests with Pytest | success |
| **Enforce Python coverage thresholds** | success |
| Upload coverage to Codecov | success |

The enforcement step carries no `if` key, so it ran and passed on all four legs. This is the first execution of the new gate on a runner and it is the strongest available evidence that the change works where it is meant to work.

### 2.2 Local re-confirmation at this head

| Stage | Command | Exit | Output |
| --- | --- | --- | --- |
| Format | `poetry run black --check` on the three changed Python files | 0 | `3 files would be left unchanged` |
| Lint | `poetry run ruff check` on the three changed Python files | 0 | `All checks passed!` |
| Unit tests | `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_check_python_coverage_thresholds.py -q` | 0 | `15 passed in 0.08s` |

Type checking and the full suite are carried by `evidence/qa-gates/post-merge-toolchain-verification.md` (pyright `0 errors, 0 warnings, 0 informations`; pytest `4136 passed, 5 skipped`, exit 0) at head `890e2ac9`. That artifact's measurement remains valid at `e825b5e6` because the only files changed in between are five Markdown documents under the feature folder, and it is corroborated independently by the four green CI legs at `e825b5e6`.

Architecture-boundary tests, contract/schema checks, and integration tests: none applicable. The change adds one standalone dev-tooling module with no architectural boundary, no published contract, and no external system.

---

## 3. `modified-workflow-needs-green-run` — PASS (blocking finding B-1 is closed)

### 3.1 Rule text

`.claude/skills/feature-review-workflow/SKILL.md` line 70: a diff matching `.github/workflows/**` emits a Blocking finding unless evidence of a green workflow run against the branch head is present. Line 72 defines the term: "a workflow run whose head SHA matches the current branch head and whose conclusion is success for the affected workflow." Line 73 admits a `workflow_dispatch` run, not only a PR-context run.

The trigger fires: the diff modifies `.github/workflows/_quality-checks.yml`.

### 3.2 Independent verification

The reviewer re-ran the query itself rather than accepting the executor's transcript.

```
gh run list --workflow=_quality-checks.yml \
  --branch bug/ci-coverage-targets-nonexistent-package-506-r3 \
  --limit 5 --json databaseId,headSha,conclusion,status,url
```

Returned, verbatim, a single element:

```json
[{"conclusion":"success","databaseId":32925230528,"headSha":"e825b5e62f7b816859eee8fae2c7e23ddb40679b","status":"completed","url":"https://github.com/drmoisan/drm-copilot/actions/runs/32925230528"}]
```

Each condition of the rule, checked separately:

| Condition | Required | Observed | Result |
| --- | --- | --- | --- |
| Affected workflow | `_quality-checks.yml` | run's workflow is `_quality-checks.yml` (the `--workflow` filter) | met |
| Conclusion | `success` | `success` | met |
| Status terminal | `completed` | `completed` | met |
| Head SHA == branch head | `git rev-parse HEAD` | run `headSha` `e825b5e6…`; `git rev-parse HEAD` `e825b5e6…` | met, exact string equality |
| Branch identity | the feature branch | `headBranch` is `bug/ci-coverage-targets-nonexistent-package-506-r3` | met |
| Trigger admissible | dispatch or PR-context | `event` is `workflow_dispatch` | met, admitted by line 73 |

Two further checks the rule does not require but which strengthen the verdict:

- `git rev-parse origin/bug/ci-coverage-targets-nonexistent-package-506-r3` also returns `e825b5e6…`, so the remote ref the run was dispatched against is the same commit as the local head. There is no local-versus-remote divergence hiding behind the SHA match.
- All four Python matrix legs are green, not merely the aggregate run conclusion: `Code Quality & Tests (3.10)`, `(3.11)`, `(3.12)`, and `(3.13)` each report `success`, and the `Enforce Python coverage thresholds` step reports `success` in each.

The entry audit's B-1 stated the gap as "no run exists whose head SHA equals `890e2ac9`." That gap is closed at the new head by direct measurement. **B-1 is genuinely closed.**

### 3.3 Assessment of the uncommitted working tree and the moving head

The caller asked for an explicit judgment on two related facts: the working tree carries uncommitted P6-T5/T6/T7 artifacts by the plan's design, and a downstream commit will move the head past `e825b5e6`, at which point the recorded SHA equality no longer holds against the new tip.

**Judgment: acceptable. This is a structural property of the rule, not a defect in this branch, and the residual risk is closed by the pull request's own required run.**

Reasoning, in four steps.

1. **The obligation is unsatisfiable in the strict reading, for any branch.** The rule demands a green run at the branch head. Evidence of that run must be written down, and the writing produces a file. Committing the file moves the head, so the evidence no longer describes the tip. Not committing it leaves the evidence outside the branch. No ordering escapes this: the run must finish before the artifact can be written, and the artifact must exist before it can be committed. Any branch that modifies a workflow faces the same one-commit offset. Treating it as a defect here would make the rule unsatisfiable everywhere, which is not a defensible reading of a rule that exists to be satisfied.

2. **The plan anticipated it and chose the ordering that keeps the evidence honest.** `plan.2026-08-23T23-21.md` P6-T5 states "The artifact is left uncommitted per the commit boundary above," and P6-T7 states "These edits are left uncommitted and are handed to the downstream commit-and-pull-request step; committing them here would move the branch head and invalidate the AC-17 evidence." The executor followed that instruction: `git status --porcelain --untracked-files=all` returned empty at the moment the run's conclusion was read, which is recorded in the green-run artifact and is what makes the SHA equality a real assertion rather than a coincidence. Committing the artifacts to make the tree look clean would have broken the very binding the rule asks for.

3. **The evidence artifact does not conceal the offset.** `evidence/qa-gates/green-workflow-run.md` carries a section headed "Known and accepted structural offset in what follows" that states plainly that the equality "holds at the moment of this record and not after the handoff commit," and names the pull request's own run as what re-establishes the green result at the final head. A record that discloses its own limit is materially different from one that overstates.

4. **What actually moves is bounded, and the residual risk is closed downstream.** The pending change set is five Markdown files under the feature folder. It contains no production file, no test file, and no workflow file, so the code the green run exercised is byte-identical to the code that will exist at the post-handoff head. Verified: `git status --porcelain` lists only `ac-evidence-index.md`, `plan.2026-08-23T23-21.md`, `spec.md`, `d3-fallback-disposition.md`, and `green-workflow-run.md`. Beyond that, opening the pull request triggers `_quality-checks.yml` in PR context against the post-handoff head, which is a second green run at the final tip and is the run a reviewer of the pull request actually sees. The rule's stated purpose — a second, independent line of defense for CI-gate-modifying features, prior to the orchestrator's S9 CI green gate — is served by both.

**One condition attaches to this acceptance, and it is not a finding against the current state.** If the downstream handoff commit were to touch any production, test, or workflow file, step 4 would no longer hold and the green run would no longer describe the code at the tip. The handoff must therefore commit only the five documentation paths listed above. This is a constraint on the next step, recorded here so it is not lost; the branch as it stands satisfies it.

---

## 4. Coverage Verification — PASS

Mandatory for every language with changed files. Python is the only such language with source files; the workflow YAML is not a coverage language.

### 4.1 Artifact existence

| Language | Required artifact | Present | Evidence |
| --- | --- | --- | --- |
| Python | `artifacts/python/lcov.info` | **Yes** | 425,098 bytes; `artifacts/python/coverage.json` also present at 1,599,291 bytes |
| TypeScript | `coverage/lcov.info` | n/a | Zero changed `.ts` files; no verdict owed |
| PowerShell | `artifacts/pester/powershell-coverage.xml` | n/a | Zero changed `.ps1` files; no verdict owed |
| C# | `artifacts/csharp/coverage.xml` | n/a | Zero changed `.cs` files; no verdict owed |

### 4.2 Repo-wide Python coverage, parsed from the artifact

The reviewer parsed `artifacts/python/lcov.info` directly, summing `LF`/`LH` and `BRF`/`BRH` across all 181 measured files, rather than reading a number out of an evidence document:

| Metric | Measured | Uniform floor (`quality-tiers.md`) | Margin | Verdict |
| --- | --- | --- | --- | --- |
| Line coverage | **92.6469 %** (13910 / 15014) | 85 % | +7.65 points | **PASS** |
| Branch coverage | **85.2161 %** (4692 / 5506) | 75 % | +10.22 points | **PASS** |

Both figures agree to every recorded digit with `totals.percent_statements_covered` (92.64686292793392) and `totals.percent_branches_covered` (85.2161278605158) reported in `evidence/qa-gates/post-merge-toolchain-verification.md` Gate 6 and in `evidence/qa-gates/workflow-command-coverage-json.md`. Two independent parses of two report formats produce the same values, so neither the artifact nor the evidence document is being taken on trust.

Both figures also clear the reviewer's own 80 % repo-wide flag threshold by a wide margin.

### 4.3 New-file coverage

Three files are added by this branch. One is production code; two are test files, which the Coverage Exclusion Policy places outside the denominator.

| File | Tier | Line | Floor | Branch | Floor | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | new | **96.7213 %** (59/61) | 85 % (and the reviewer's 90 % new-file flag) | **85.7143 %** (12/14) | 75 % | **PASS** |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | new test file | — | — | — | — | not in denominator |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | new test file | — | — | — | — | not in denominator |

The two uncovered statements are lines 230 and 236, the `raise CoverageReportError` bodies for a non-object JSON root and an absent-or-non-mapping `totals`. The two uncovered branches are `229→230` and `235→236`, the arcs that reach them. This is finding NB-1, section 8.

### 4.4 Modified-file coverage and regression

`.github/workflows/_quality-checks.yml` is the only modified file, and it is not a coverage language. No pre-existing Python source file is modified, so there is no modified-file coverage tier to evaluate and no changed line in an existing file whose coverage could regress.

Repo-wide regression is separately excluded: before this change the CI coverage command named `src/lexile_corpus_tuner`, a package that does not exist, so it collected a zero-statement denominator and reported no percentage at all. There is no prior repo-wide figure this change could have lowered. `evidence/qa-gates/coverage-delta.md` records the before-and-after comparison.

### 4.5 Coverage exclusions

`pyproject.toml` is absent from the branch diff, confirmed by `git diff --name-only origin/main...HEAD`. No `omit`, `exclude`, or `exclude_also` entry is added or altered anywhere. No production path under `scripts/` is excluded from measurement. The Coverage Exclusion Policy is satisfied.

---

## 5. `.claude/rules/plan-acceptance-gates.md` (G1–G6) — PASS

The plan file was modified by the remediation (three checkbox characters), so the validator was re-run against the current working-tree content rather than the entry audit's result being carried forward.

```
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan \
  docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md \
  --workspace-root .
```

Result: `plan validation passed`. Exit 0. **Zero Blocking findings.** Five Warnings, unchanged in count and content from the entry audit:

| Task | Rule | Warning | Disposition |
| --- | --- | --- | --- |
| P0-T6 | G4 | `--cov` value `--cov-branch` supplied space-separated | Anticipated verbatim by spec decision D1. The gate's `cov_values` reads the token after a bare `--cov`; `argparse` does not. Warning, correct as authored. |
| P0-T7 | G3 | `src/lexile_corpus_tuner` resolves to neither a tracked file nor a tracked directory | This is the defect under repair. P0-T7 is the deliberate defect-reproduction task, so a G3 Warning on it is the gate correctly identifying the bug the plan exists to fix. |
| P0-T8 | G4 | same as P0-T6 | same |
| P4-T4 | G4 | same as P0-T6 | same |
| P4-T5 | G4 | same as P0-T6 | same |

The three checkbox edits did not introduce a new command span and did not change any existing one; the Warning set is byte-identical to the entry audit's.

---

## 6. `.claude/rules/tonality.md` — PASS

The five documents authored or edited by the remediation were read in full and assessed against the tone policy.

| Document | Assessment |
| --- | --- |
| `evidence/qa-gates/green-workflow-run.md` | Neutral and evidence-first. Records commands, exit codes, and outputs verbatim. States the structural offset plainly rather than minimizing it. No hyperbole, no celebratory phrasing. |
| `evidence/qa-gates/d3-fallback-disposition.md` | Neutral. States the disposition, the condition that was not met, and the five consequences. Explains why the value is a `Disposition:` field rather than an `EXIT_CODE:` row in technical terms. |
| `evidence/other/ac-evidence-index.md` (appended section) | Neutral. Tabular, with each condition stated and each result given as PASS with its measured value. |
| `spec.md` | Four checkbox characters. No prose changed. |
| `plan.2026-08-23T23-21.md` | Three checkbox characters. No prose changed. |

No instance of prohibited humor, hyperbole, or decorative metaphor was found. Claim strength matches evidence strength throughout: for example, the green-run artifact writes "holds at the moment of this record and not after the handoff commit" rather than an unqualified assertion.

---

## 7. Evidence Location Compliance — PASS

Required scan, performed two ways.

1. **Validator.** `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits **0**. No violation reported, so no path is added as a FAIL finding.

2. **Direct diff scan.** `git diff --name-only origin/main...HEAD | grep -E "artifacts/(baselines|qa|evidence|coverage)/"` returns **no match** (grep exit 1). No file in the branch diff is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.

Every evidence artifact this branch produces lives under `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/<kind>/`, using the four canonical kinds `baseline/`, `other/`, `qa-gates/`, and `regression-testing/`. The two artifacts the remediation added — `green-workflow-run.md` and `d3-fallback-disposition.md` — are both under `evidence/qa-gates/` and are canonical.

`EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none. No delegation prompt, plan task, or caller instruction in this cycle specified a non-canonical evidence path, so no override was rejected.

The artifacts written under `artifacts/python/` (`coverage.json`, `lcov.info`) are tool output consumed as coverage input, not evidence artifacts produced by this agent, and `artifacts/python/` is not one of the four prohibited prefixes. They are untracked and do not appear in the branch diff.

---

## 8. Non-Blocking Findings — both re-affirmed

The caller asked whether the two entry-audit non-blocking findings remain non-blocking, given that neither was remediated. Both were re-examined against the current code rather than carried forward by assertion. `scripts/dev_tools/check_python_coverage_thresholds.py` is byte-identical to the version the entry audit reviewed, confirmed by `git diff --name-only 890e2ac9 HEAD`, which does not list it.

### NB-1 — two documented validation conditions carry no unit test

- **Severity: Minor. Remains non-blocking. Not remediation-required.**
- **Location:** `scripts/dev_tools/check_python_coverage_thresholds.py` lines 229-238. Uncovered lines 230 and 236; uncovered branches `229→230` and `235→236`.
- **Detail:** the `load_totals` docstring at lines 204-208 names four raise conditions — unreadable file, invalid JSON, non-object root, and absent-or-non-mapping `totals`. `spec.md` line 197 names the same four. Two are exercised by `test_missing_report_file_exits_non_zero` and `test_unparseable_report_exits_non_zero`; two are not.
- **Why it remains non-blocking, re-verified:**
  1. No threshold is breached. Module line coverage is 96.7213 % against an 85 % floor and the reviewer's 90 % new-file flag; module branch coverage is 85.7143 % against a 75 % floor. Recomputed from `lcov.info` in this reaudit, not quoted.
  2. No acceptance criterion names either condition. AC-10 states "a missing or unparseable report fails loudly" and names exactly the two tests that exist. Neither untested condition is in any criterion's text.
  3. No remediation trigger in this agent's coverage procedure fires: repo-wide is above 80 %, the new file is above 90 %, and there is no modified-file regression.
  4. The guards themselves are correct and are retained deliberately. `evidence/qa-gates/checker-module-coverage.md` lines 47-52 records the decision and its reason: the behavioural contract requires `load_totals` to raise on both conditions, so removing the guards to raise the percentage would be the wrong response.
- **Optional follow-up, unchanged:** two tests in the existing `_write_report` / `mem_fs_path` pattern — one supplying a JSON array or scalar root, one supplying `{"totals": 5}` — each asserting a non-zero exit and the report path in stderr. Roughly twenty lines. Suitable for this change or a follow-up; required by neither.

### NB-2 — CLI writes to stderr via `print` rather than `logging`

- **Severity: Informational. Remains non-blocking. No action recommended.**
- **Location:** `scripts/dev_tools/check_python_coverage_thresholds.py` lines 309 and 318.
- **Detail:** `.claude/rules/python.md` line 31 prefers the standard `logging` module over ad-hoc `print` for permanent behavior.
- **Why no action, re-verified:** the rule targets permanent library behavior. These two calls are in `main`, the CLI entry point, whose output contract `spec.md` lines 203 and 214 state explicitly as "human-readable messages on standard error." Twenty-three modules under `scripts/dev_tools/` already use this form, including the sibling gate the same workflow invokes. An unconfigured `logging` call inside a GitHub Actions `run:` block would emit through the root handler at a `WARNING` default with a different format, which is a worse CI output contract than the current one, not a better one. Changing it would reduce output quality to satisfy the letter of a rule aimed at a different situation.
- **Recorded so the deviation stands on the record with its reasoning, rather than being re-raised in a later cycle as though it were new.**

### NB-3 — NEW, introduced by the remediation: stale present-tense heading in the evidence index

- **Severity: Informational. Non-blocking. No action required for merge.**
- **Location:** `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/ac-evidence-index.md` line 24.
- **Detail:** the heading reads `## Why exactly four rows are marked \`PENDING PHASE 6\`` in the present tense, and the section under it says "All four are finalized by [P6-T7], which replaces the four rows below." After P6-T7 ran, zero rows are marked `PENDING PHASE 6`, which the same document states forty lines later ("Rows marked `PENDING PHASE 6`: **0**"). A reader arriving at line 24 encounters a present-tense claim that the table below no longer supports.
- **Why non-blocking:** the section is a rationale record for the [P5-T1] state and reads correctly as history. The document is internally consistent on the substance — the table is finalized, the count line says 0, and the appended P6-T7 block states the finalization explicitly with its date. No acceptance criterion, no policy rule, and no gate depends on the heading's tense. Condition (c) of P6-T7 asks for exactly nineteen rows and zero `PENDING PHASE 6` rows, both of which hold; it says nothing about the heading.
- **Optional:** reword to past tense ("Why four rows were marked …") if the document is touched again. Not worth a commit on its own.

### NB-4 — NEW, introduced by the remediation: AC-12's evidence-index artifact column points at the disposition record rather than the test-result record

- **Severity: Informational. Non-blocking. No action required for merge.**
- **Location:** `evidence/other/ac-evidence-index.md`, the AC-12 row.
- **Detail:** the row's test column correctly names `test_threshold_step_runs_on_every_matrix_leg`; its artifact column names `FEATURE/evidence/qa-gates/d3-fallback-disposition.md`. The disposition artifact establishes *which form of AC-12 landed*; the artifact that records the test *passing* is `FEATURE/evidence/regression-testing/workflow-contract-tests-pass-after.md`, which lists the test at line 40 as item 5 of its passing set. The other twelve test-carried rows point at the test-result artifact.
- **Why non-blocking:** the plan's P6-T7 instruction for AC-12 was to supply "the landed test node ID," and it prescribed an artifact path only for AC-14, AC-15, and AC-17. The executor met the instruction as written, and the choice is defensible: the disposition is the fact P6-T7 was there to determine. The test's passing result is not lost — it is one hop away in an artifact the same index cites for five sibling rows, and it is independently confirmed by the reviewer's own run of the two test files (15 passed) and by all four green CI legs. The traceability cost is one indirection, not a gap.
- **Optional:** cite both artifacts in the AC-12 row, as the AC-14 and AC-15 rows already do for their two artifacts.

---

## 9. Findings Table

| ID | Finding | Severity | Status |
| --- | --- | --- | --- |
| B-1 | `modified-workflow-needs-green-run`: no green run at the branch head | **Blocking** (entry audit) | **CLOSED** — run `32925230528`, `success`, `headSha` == `git rev-parse HEAD`, independently verified in section 3.2 |
| NB-1 | Two documented `load_totals` validation conditions carry no unit test | Minor | Open, non-blocking, re-affirmed |
| NB-2 | CLI writes to stderr via `print` rather than `logging` | Informational | Open, no action recommended, re-affirmed |
| NB-3 | Stale present-tense heading in the evidence index | Informational | New this cycle, non-blocking |
| NB-4 | AC-12 index row cites the disposition artifact, not the test-result artifact | Informational | New this cycle, non-blocking |

**Blocking findings: 0.**

---

## Verdict

**PASS.** Zero Blocking findings.

The single Blocking finding of remediation cycle 1 is closed by direct, independently re-executed measurement: a `_quality-checks.yml` run exists whose conclusion is `success` and whose head SHA is exactly `git rev-parse HEAD`, on the correct branch, with all four Python matrix legs green and the new enforcement step passing on each. Every other policy verdict from the entry audit is re-confirmed against fresh measurement at the new head. The two remaining PARTIAL rows are the pre-existing non-blocking findings NB-1 and NB-2, both deliberately unremediated and both re-examined and re-affirmed as non-blocking. The remediation introduced two new findings, both Informational, neither affecting merge readiness.

One forward-looking constraint, stated in section 3.3 and not a finding against the current state: the downstream handoff commit must contain only the five documentation paths currently pending, so that the code exercised by the green run remains byte-identical to the code at the post-handoff head.
