# Remediation Inputs — Issue #506 (ci-coverage-targets-nonexistent-package)

- **Timestamp:** 2026-08-25T22-57
- **Branch:** `bug/ci-coverage-targets-nonexistent-package-506-r3`
- **Branch head at review:** `890e2ac9369e5a67f282bb7bc3ca438589427676`
- **Base:** `origin/main`
- **Work Mode:** `full-bug`

## Source Artifacts

| Artifact | Path |
| --- | --- |
| Policy audit | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/policy-audit.2026-08-25T22-57.md` |
| Code review | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/code-review.2026-08-25T22-57.md` |
| Feature audit | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/feature-audit.2026-08-25T22-57.md` |

## Summary

**Blocking findings: 1.** It requires no change to source code, tests, or the workflow file. It is a
sequencing obligation that plan task P6-T5 already schedules; two upstream tasks (P6-T3, P6-T4) must
be re-run first because the branch head advanced past the ref they targeted.

**Non-blocking findings: 2.** Neither is required for merge.

---

## Blocking Finding B-1 — no green workflow run against the branch head

- **Rule:** `modified-workflow-needs-green-run`, `.claude/skills/feature-review-workflow/SKILL.md`
  line 68.
- **Acceptance criterion:** AC-17, `spec.md` line 303.
- **Trigger:** the branch diff modifies `.github/workflows/_quality-checks.yml`, which matches
  `.github/workflows/**`.
- **File / location:** `.github/workflows/_quality-checks.yml` (the modified path that fires the
  rule). The missing artifact is
  `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/green-workflow-run.md`.
- **Severity:** Blocking.

### Observed state

| Fact | Value |
| --- | --- |
| Local branch head | `890e2ac9369e5a67f282bb7bc3ca438589427676` |
| Remote `origin/bug/ci-coverage-targets-nonexistent-package-506-r3` | `15db75d5b030fe4be2fe4edab9b9f1add0b8bf7a` |
| `gh run list --workflow=_quality-checks.yml --branch bug/ci-coverage-targets-nonexistent-package-506-r3` | zero runs |
| Runs whose head SHA equals `890e2ac9` | none |
| `evidence/qa-gates/green-workflow-run.md` | absent |
| Plan P6-T5 checkbox | `- [ ]` |
| Plan P6-T3 / P6-T4 checkboxes | `- [x]`, but recorded against the pre-merge `-r2` ref |

Two green `workflow_dispatch` runs exist on the sibling ref `...-506-r2`:
32923970683 @ `08c9c14f` (success) and 32924210756 @ `15db75d5` (success). Neither head SHA equals
the current branch head.

### Mitigating evidence (recorded, not accepted as satisfaction)

- `890e2ac9` is `Merge remote-tracking branch 'origin/main'`, second parent `15db75d5` — the exact
  SHA of green run 32924210756.
- `git diff --name-only 15db75d5 HEAD -- .github/workflows/_quality-checks.yml scripts/dev_tools/check_python_coverage_thresholds.py tests/scripts/dev_tools/test_check_python_coverage_thresholds.py tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` → **empty**.
- `git diff --name-only 15db75d5...origin/main -- .github/` → **empty**.

The green run exercised identical workflow content. The gap is one merge commit wide.

### Corrective action required

1. `git push --set-upstream origin HEAD` from the repository root. (Plan P6-T3, re-run: the remote
   ref stands at `15db75d5` and must advance to `890e2ac9`.)
2. `gh workflow run _quality-checks.yml --ref bug/ci-coverage-targets-nonexistent-package-506-r3`.
   (Plan P6-T4, re-run.)
3. Poll with
   `gh run list --workflow=_quality-checks.yml --branch bug/ci-coverage-targets-nonexistent-package-506-r3 --limit 5 --json databaseId,headSha,conclusion,url`
   until terminal, then write
   `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/green-workflow-run.md`
   with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, the run URL, and the run's head
   SHA. (Plan P6-T5.)
4. **Make no commit between steps 1 and 3.** Any commit moves the head and invalidates the
   head-SHA binding the rule requires.
5. Then run P6-T6 (D3 disposition) and P6-T7 (check off AC-12, AC-14, AC-15, AC-17 in `spec.md` and
   finalize the four `PENDING PHASE 6` rows in
   `evidence/other/ac-evidence-index.md`).

### Exit condition

A `_quality-checks.yml` run exists whose `conclusion` is `success` and whose `headSha` equals
`git rev-parse HEAD`, recorded in `evidence/qa-gates/green-workflow-run.md`.

### Contingency (pre-authorized, D3)

If the run fails **solely** because the enforcement step reports a coverage shortfall on a Python
leg other than 3.13, decision D3 pre-authorizes narrowing the enforcement step with
`if: matrix.python-version == '3.13'`, replacing
`test_threshold_step_runs_on_every_matrix_leg` with `test_threshold_step_is_narrowed_to_the_pinned_leg`,
filing a follow-up issue recording the shortfall, and **linking that issue** in the Rollout &
Follow-up section of `spec.md`. The link is mandatory: AC-12's alternative form is not satisfied by
a prose recommendation. This path then repeats P6-T1 through P6-T5.

This contingency is judged unlikely to fire: measured margins at head are +7.65 points on line and
+10.22 points on branch.

---

## Non-Blocking Finding NB-1 — two documented validation conditions carry no unit test

- **Severity:** Minor. Not remediation-required.
- **File / location:** `scripts/dev_tools/check_python_coverage_thresholds.py` lines 229-238.
  Uncovered lines 230 and 236; uncovered branches `229→230` and `235→236`.
- **Detail:** `spec.md` line 197 names four validation conditions. Two are tested (missing file,
  invalid JSON); two are not — "report root is not a JSON object" and "`totals` absent or not a
  mapping".
- **Why not blocking:** module coverage is 96.72 % line and 85.71 % branch, both clear of the
  85 / 75 floors; no acceptance criterion names either condition (AC-10 covers only the two tested
  cases); no threshold or remediation trigger fires.
- **Suggested action (optional, this change or a follow-up):** add two tests in the existing
  `_write_report` / `mem_fs_path` pattern — one supplying a JSON array or scalar root, one supplying
  `{"totals": 5}` — each asserting a non-zero exit and the report path in stderr. Roughly twenty
  lines.

## Non-Blocking Finding NB-2 — CLI writes to stderr via `print` rather than `logging`

- **Severity:** Informational. **No action recommended.**
- **File / location:** `scripts/dev_tools/check_python_coverage_thresholds.py` lines 309, 318.
- **Detail:** `.claude/rules/python.md` line 31 prefers the standard `logging` module over ad-hoc
  `print` for permanent behavior.
- **Why no action:** the rule targets permanent library behavior; this is a CLI entry point whose
  output contract is explicitly "human-readable messages on standard error" (`spec.md` lines 203,
  214). Twenty-three modules under `scripts/dev_tools/` already use this form, including the sibling
  gate the same workflow invokes at line 71. An unconfigured `logging` call in a GitHub Actions
  `run:` block would emit through the root handler at a `WARNING` default with a different format,
  which is a worse CI output contract, not a better one. Recorded so the deviation is on the record
  with its reasoning rather than re-raised later.

---

## Follow-Up Recommendations (out of scope for this change)

These are recorded for the orchestrator's follow-up backlog. None blocks this branch.

1. **Residual foreign-package-name occurrences** — the nine live occurrences catalogued in research
   section 6.1 items 2 and 4-11, plus the Copilot-surface documents in section 6.2. Already
   recommended in `spec.md` Rollout & Follow-up under D4. Correctly deferred.
2. **Blocked policy files (D5)** — the two `.github/instructions/` Python documents and their two
   bundled mirrors publish the defective command as the approved Python test command. Escalated as a
   `human_interaction` requirement with `response: scope_change`; recorded at
   `evidence/other/human-interaction-d5.md`. Requires a user decision.
3. **Repository-wide threshold absence** — no workflow in this repository enforces a coverage
   threshold in any language. This change closes the Python instance only.
4. **Missing actionlint CI job** — `.github/instructions/github-actions.instructions.md` names an
   `actionlint` job in `ci.yml` that does not exist among that workflow's jobs.
5. **Tracked `coverage.xml` at the repository root** (added by this review, not previously
   recorded) — the root `coverage.xml` is a tracked file holding a committed Pester JaCoCo report,
   and any local `--cov-report=xml` run overwrites it in place. This predates the branch and is not
   widened by it, but it required three explicit `git checkout -- coverage.xml` restore steps in
   this plan and will require them in every future plan that runs pytest with the XML reporter.
   Gitignoring the file, or setting `[tool.coverage.xml] output` to an `artifacts/` path, would
   remove a recurring hazard.

---

## Handoff

| Item | Value |
| --- | --- |
| Blocking findings | 1 (B-1) |
| Blocking findings requiring a code change | **0** |
| Non-blocking findings | 2 (NB-1 Minor, NB-2 Informational — no action) |
| Acceptance criteria passing | 18 of 19 |
| Acceptance criteria failing | 1 (AC-17, satisfied by B-1's corrective action) |
| Coverage verdicts | Python **PASS** (repo-wide 92.65 % line / 85.22 % branch; new file 96.72 % / 85.71 %). No other language has a changed file on this branch. |
| Toolchain | black, ruff, pyright, pytest, actionlint all clean at head |
| Evidence-location compliance | PASS — `validate_evidence_locations.py --root .` exit 0; no `artifacts/baselines`, `artifacts/qa`, `artifacts/evidence`, or `artifacts/coverage` path in the diff |
| Working tree at review | clean |
| Next owner | orchestrator — re-run plan tasks P6-T3, P6-T4, P6-T5, then P6-T6 and P6-T7 |
