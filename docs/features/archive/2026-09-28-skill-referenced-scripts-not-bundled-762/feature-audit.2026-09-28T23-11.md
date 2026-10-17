# Feature Audit: Skill-Referenced Scripts Bundled With Their Skills (#762)

---

**Audit Date:** 2026-09-28
**Feature Folder:** `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762`
**Base Branch:** `main`
**Head Branch:** `fix/skill-bundled-scripts`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `42e95e275953d3235eeab7ed5cebf26c7b019f51`)
- **Head branch/commit:** `fix/skill-bundled-scripts` (commit `4606f5ab73dc8e5dabdcccc89a40b7e1ad585412`)
- **Merge base:** `42e95e275953d3235eeab7ed5cebf26c7b019f51`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-29 03:06 UTC for head `4606f5ab`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/evidence/**`
  - Additional evidence: GitHub Actions run 36514443218 (`workflow_dispatch`, head `7d8234ed`, conclusion `success`, 16/16 jobs) and its `poshqc-test-results` and `shell-coverage` artifacts; local check-only re-runs listed in the policy audit Appendix B
- **Feature folder used:** `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`; per the work-mode contract the only AC source is `spec.md`.
- **Scope note:** The branch was rebased onto `main` `42e95e27` after the executor's first CI run; `git range-diff` shows commits 1-7 unchanged in content. Head `4606f5ab` differs from the CI-verified `7d8234ed` only in feature-folder documentation (`ac-checkoff`, `ci-dispatch` evidence, plan, and spec checkbox lines), so CI results on `7d8234ed` apply to the code at head.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/spec.md` — only source

### Acceptance criteria

1. AC1: The audit table covering every skill is recorded in the research artifact.
2. AC2: `cleanup-merged-worktrees` invokes only scripts that are in its bundle (relocated under `.claude/skills/cleanup-merged-worktrees/scripts/`, mirrored, listed in `core.json`), and the skill text and `allowed-tools` name the bundled paths.
3. AC3: `orchestrate` and `epic-orchestrate` reference `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, which is mirrored and listed in `core.json`.
4. AC4: No remaining caller in the repository (skills, hooks, tests, CI, config, rules) points at the old script paths, excluding historical feature records.
5. AC5: Shell QC discovers, lints, tests, and measures coverage for bash scripts under `.claude/skills/`.
6. AC6: A CI-run guard fails when a skill references a script not in its bundle, does not fail because a script lives outside the skill folder, and checks every file in a skill folder is carried by the skill's packs.
7. AC7: The two unfixable Python CLI references are registered as issue-linked exceptions (#763) and the guard fails if an exception becomes stale.
8. AC8: Full toolchain passes for bash, PowerShell, and Python with coverage thresholds met.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1: audit table covers every skill | PASS | `research/2026-09-28T19-15-skill-bundle-audit-research.md` lists all 56 skills (no-script list plus table). Review re-check: 56 skill folders, 0 absent from the research file. | `for d in .claude/skills/*/; do grep -q "$(basename $d)" research/...md \|\| echo NOT IN AUDIT; done` | Matches executor evidence `evidence/qa-gates/ac1-audit-coverage.2026-09-28T22-17.md` (`AUDIT skills=56 missing=0`). |
| 2 | AC2: cleanup-merged-worktrees invokes only bundled scripts | PASS | Ten scripts renamed into `.claude/skills/cleanup-merged-worktrees/scripts/` (R093-R100); ten mirrors byte-identical (`cmp`); ten entries added to `core.json`; `allowed-tools` now `Bash(bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh *)`; body steps 1, 6, and fast path use the new path. Guard `test_every_skill_script_reference_is_bundled` fails before (`cleanup-merged-worktrees \| scripts/bash/cleanup-worktrees.sh \| not-in-bundle`) and passes after. | `git diff -M 42e95e27..HEAD -- .claude/skills/cleanup-merged-worktrees`; `cmp -s <src> <mirror>`; `poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` | Sourced libraries resolve via `$SCRIPT_DIR`, so the relocation is behavior-preserving; bats suites pass from the new path in CI. |
| 3 | AC3: orchestrate and epic-orchestrate reference bundled parser | PASS | Both SKILL.md files now invoke `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1`; mirror byte-identical; `core.json` lists the path; `CiGate.Manifest.Tests.ps1` (2 tests) passes; `test_ci_gate_parser_skills_invoke_bundled_parser` fails before and passes after. | `git grep -n Invoke-CiGateParser -- . ':(exclude)docs/features'`; Pester run recorded in `evidence/regression-testing/ci-gate-manifest-after-fix.2026-09-28T22-13.md` | Code-review Minor finding recommends documenting the pipeline input form for S9. |
| 4 | AC4: no remaining caller uses old paths | PASS | `git grep -E "scripts/bash/cleanup[-_]worktrees\|scripts/orchestration/Invoke-CiGateParser\|tests/scripts/orchestration/Invoke-CiGateParser" -- . ':(exclude)docs/features'` returns only `tests/fixtures/blast_radius/historical-runs/*.json` recorded run data. `git ls-files scripts/orchestration tests/scripts/orchestration` is empty. | Command shown in Evidence column; `evidence/qa-gates/old-path-sweep.2026-09-28T22-17.md`; `evidence/qa-gates/old-dirs-empty.2026-09-28T22-17.md` | The blast-radius fixtures are historical run records used as test input, not callers; treated as within the AC's historical-record exclusion. |
| 5 | AC5: Shell QC covers `.claude/skills/` | PASS | `shell_qc_lib.sh` adds `.claude/skills` to discovery roots and kcov include pattern; new bats case finds `.claude/skills/demo-skill/scripts/skill_entry.sh`; shellcheck call count 6 -> 7; kcov include assertion added (4 fail-before, pass after). CI `cov.xml` (run 36514443218) contains all ten scripts under `.claude/skills/cleanup-merged-worktrees/scripts/` with line-rates 0.870-1.000. | `gh run download 36514443218 -n shell-coverage`; grep of `cov.xml` class filenames | Lint and format stages run over the discovered set (`evidence/qa-gates/shell-lint...`, `shell-format...`). |
| 6 | AC6: CI-run guard with bundle, location, and skill-folder checks | PASS | `test_skill_bundle_contract_repo.py` runs in CI (`quality-checks7` 3.12 log shows 5 passing tests). Fails on unbundled reference (fail-before evidence); `test_evaluate_accepts_script_outside_skill_folder_when_bundled` proves location is not a reason; `test_every_skill_folder_file_is_carried_by_skill_packs` and `test_evaluate_reports_skill_folder_file_missing_from_packs` cover skill-folder carriage. Guard CLI exits 0 at head. | `poetry run pytest -q tests/scripts/dev_tools/test_skill_bundle_contract*.py`; `poetry run python -m scripts.dev_tools.skill_bundle_contract_cli` (exit 0) | Detection depends on the enumerated invocation grammar (code-review Minor finding). |
| 7 | AC7: #763 exceptions registered; stale exception fails guard | PASS | `KNOWN_UNBUNDLED_REFERENCES` holds `parallel-orchestrate` -> `scripts/dev_tools/parallel_drift_detection_cli.py` and `parallel-remove` -> `scripts/dev_tools/parallel_mutation_abandon_cli.py`, both `#763`. `test_known_unbundled_references_are_not_stale` (repo), `test_find_stale_exceptions_reports_unmatched_exception`, `test_main_returns_one_for_stale_exception`, and `test_known_unbundled_references_cite_issue_763` pass. | `poetry run pytest -q tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` | Issue #763 is open (PR context issue digest). |
| 8 | AC8: full toolchain passes with coverage thresholds met | PASS | Python: black/ruff/pyright clean (re-run by review); lcov 93.11% line / 85.92% branch; new modules 96.45%/95.00% and 92.98%/77.27%. PowerShell: format and analyze clean; 17/17 Pester; parser 94.12% line (CI artifact). Bash: shfmt and shellcheck clean; kcov 93.3% line, every changed script >= 86.5%. CI run 36514443218: 16/16 jobs `success`. | See policy audit Appendix B | Local-only failures (#510 state file; KL-SHELL-2 bats 282/304) are pre-existing, reproduce at baseline, and do not occur in CI. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After merge, run a push-down into a consumer repository and invoke `/cleanup-merged-worktrees` in report mode to confirm the relocated script path resolves in the destination (the original reproduction in `spec.md`).
2. Consider the code-review Minor findings (guard grammar scope, CLI error-branch tests, module split, S9 pipeline form) as a follow-up item.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/spec.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/spec.md` | 8 | 8 | 0 | Checkbox-backed; all eight were already checked by the executor (commits `7d8234ed`, `4606f5ab`). This review independently evaluated each as PASS and made no source-file change. |
