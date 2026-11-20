# Feature Audit: cd-chained-command-recurring-deny (#1165)

**Audit Date:** 2026-11-10
**Feature Folder:** `docs/features/active/cd-chained-command-recurring-deny-1165`
**Base Branch:** `main`
**Head Branch:** `bug/cd-chained-command-recurring-deny-1165`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `ff9d8afc0a61ac723cd449b0c0658ea42680cd2e`, equal to `origin/main` after fetch)
- **Head branch/commit:** `bug/cd-chained-command-recurring-deny-1165` (commit `eaf42f48d8792c7099ef5c411025d43413f0dca2`, clean worktree)
- **Merge base:** `ff9d8afc0a61ac723cd449b0c0658ea42680cd2e`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (Head SHA `eaf42f48d`, generated 2026-11-10 01:07 UTC)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/cd-chained-command-recurring-deny-1165/evidence/**`
  - Additional evidence: reviewer runs at head (pytest `-n auto` over nine modules, 145 passed; generator `--check` exit 0; evidence-location validator exit 0; mirror blob identity; JaCoCo parse of `artifacts/pester/powershell-coverage.xml`; direct-call probe of 17 command shapes)
- **Feature folder used:** `docs/features/active/cd-chained-command-recurring-deny-1165`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; `spec.md` is the sole AC source and no `user-story.md` exists.
- **Scope note:** full branch diff against the merge base (50 files). The PowerShell coverage artifact was written at 00:52 UTC, before the single commit at 01:07 UTC; the worktree is clean and the JaCoCo missed line numbers of `validate-bash.ps1` (320, 443, 445-447, 450) map onto the committed file, so the artifact is taken to describe the head content.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/cd-chained-command-recurring-deny-1165/spec.md` — only source (26 checkbox items under `## Acceptance Criteria`)

### Acceptance criteria

1. Helper exists, defines the two functions, dot-sources nothing, guarded dot-source with `Add-HookDependencyFailure`; guard-completeness S1 to S6 pass.
2. Helper tests assert Tools/IsMultiStep/CdTarget for the listed shapes, both legs, and empty/null input.
3. Plain read intent reason contents.
4. git intent reason contents.
5. poetry intent reason contents.
6. npm/npx intent reason contents.
7. Multi-step intent reason contents.
8. Every cd-chained reason keeps the first two sentences, names the rule file and the split, and drops the old remedy sentence.
9. Decision regression corpus with pre-edit baseline.
10. Pattern, read words, and match function textually unchanged; Codex hook and bundle copy unmodified.
11. Existing named suites pass without modification.
12. `.claude/rules/bash-command-shape.md` with `description:`, no `paths:`, rule, table, and context split.
13. `test_claude_rules_frontmatter.py` launch-loaded set and passes.
14. Codex skill with forms, split, and Claude-only statement.
15. Copilot instruction new file with frontmatter; no other `.github/instructions` or `copilot-instructions.md` change.
16. New files byte-identical to bundle copies; Copilot pair byte comparison recorded.
17. Pack manifests list the new files; named contract suites and generator check pass.
18. Six brief copies byte-identical; Codex attribution removed.
19. Preferred-forms table in `## Command-Text Restrictions`; brief contract test added.
20. `## Worktree Python Environment` sentence; brief diff confined to two sections.
21. Every venv policy copy carries the same reason with `poetry -C <worktree root>`; venv suites pass.
22. `parallel-orchestrate` copies use `reset --keep` and reference the brief table; keep allowed, hard denied.
23. Recurrence record under `evidence/baseline/`.
24. PowerShell toolchain, single parallel Pester run, coverage, leak scan, Python test modules, parallel and append-only.
25. No changed or new production file reaches 700 lines; no new Python production code.
26. Surfaces state the same forms; brief has no G11/G12 findings.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Helper file and guarded dot-source | PASS | Helper read at head: no dot-source; `validate-bash.ps1` line 49 guarded `try`; guard-completeness 731 of 731 | `git diff ff9d8afc0..HEAD -- .claude/hooks/validate-bash.ps1` | Bundle copy blob-identical |
| 2 | Helper intent tests | PASS | 22 of 22 in `pester-gate.2026-11-10T00-54.md`; reviewer probe reproduced Tools and CdTarget for each shape | direct-call probe `probe1165.ps1` | Raw leg reached by direct call, as the AC specifies |
| 3 | Plain read reason | PASS | Probe: reason contains `Read or Grep tool` and `against the absolute path`, no tool forms | direct-call probe | |
| 4 | git reason | PASS | Probe: `git -C <abs>` and `'/repo/wt'`, no `sh <SCRATCH>/` | direct-call probe | |
| 5 | poetry reason | PASS | Probe: `poetry -C <abs>`, `--directory`, `env -u VIRTUAL_ENV` | direct-call probe | |
| 6 | npm/npx reason | PASS | Probe: npm form; npx names `npm --prefix <abs> run <script>` and `sh <SCRATCH>/<file>.sh` | direct-call probe | |
| 7 | Multi-step reason | PASS | Probe: `sh <SCRATCH>/<file>.sh`, `git -C <abs>`, `poetry -C <abs>` | direct-call probe | |
| 8 | Common reason shape | PASS | Reason-shape Context asserts the byte prefix and tokens; 8 of 8 | test file inspection | Old remedy sentence asserted absent |
| 9 | Decision regression corpus | PASS | Baseline 60 of 60 (`evidence/baseline/pester-gate.2026-11-10T00-26.md`), post 60 of 60 | test file inspection | Corpus includes destructive byte checks |
| 10 | Detection text and Codex hook unchanged | PASS | Only two hunks in `validate-bash.ps1`; Codex hook and bundle absent from `git diff --name-only` | `git diff --name-only ff9d8afc0..HEAD` | |
| 11 | Existing suites unmodified and passing | PASS | Named suites 0 failures; none in the diff | `git diff --name-only ff9d8afc0..HEAD` | |
| 12 | Claude rule content | PASS | Rule read at head: `description:` only, table, both context sections | file inspection; pytest reviewer run | |
| 13 | Frontmatter test | PASS | `LAUNCH_LOADED_RULES` and new test; 9 passed in reviewer run | `pytest -n auto` reviewer run | |
| 14 | Codex skill | PASS | First body sentence states the deny is Claude-only | file inspection | Codex loads skills on demand (code-review Info) |
| 15 | Copilot instruction | PASS | `applyTo: "**"`, `name:`, `description:`; no other `.github/instructions` file in the diff | `git diff --name-only ff9d8afc0..HEAD` | |
| 16 | Bundle byte identity | PASS | Reviewer blob comparison of all new files and bundle copies; `evidence/other/copilot-instruction-parity.2026-11-10T00-32.md` | `git rev-parse HEAD:<path>` per pair | |
| 17 | Manifests and contract suites | PASS | Manifest diffs add three entries; six contract modules passed in reviewer run; generator `--check` exit 0 | reviewer runs | |
| 18 | Brief copies identical; attribution removed | PASS | Six copies share one blob; Repository-hooks bullet now states the Codex copy has no cd-chained leg | `git rev-parse HEAD:<path>` | |
| 19 | Preferred-forms table | PASS | Table with isolated and sibling columns; no backticked `npm run <script>`; brief contract test passes | file inspection; reviewer pytest | |
| 20 | Worktree Python Environment sentence | PASS | Sentence present; scope-check CHECK 3 shows hunks in the two sections only | diff inspection | |
| 21 | Venv reason copies | PASS | Four copies blob-identical; reason contains `poetry -C <worktree root>` and retained substrings; suites 89 and 63 pass | `git rev-parse HEAD:<path>` | |
| 22 | parallel-orchestrate `reset --keep` | PASS | Both copies blob-identical; probe: keep allowed, hard denied | direct-call probe | |
| 23 | Recurrence record | PASS | `evidence/baseline/recurrence.2026-11-10T00-09.md`: no denial log, figure labeled approximate, no host path | file inspection | |
| 24 | Toolchain and coverage | PASS | Static record 0 findings; Pester ExitCode 0; reviewer JaCoCo parse: helper 65 of 65, `validate-bash.ps1` changed lines covered; leak scan 0 failures; pytest `-n auto` passed | `python -I cov1165.py artifacts/pester/powershell-coverage.xml` | Reviewer reruns at head: Pester 21311 tests 0 failures, artifact written 01:38:48Z with identical figures; Python 97.11% lines |
| 25 | File size and no new Python production code | PASS | Logical counts: largest production file 450, largest test file 630; no `.py` outside `tests/` | reviewer logical line count | |
| 26 | Surface consistency and G11/G12 | PASS | `test_command_shape_forms_are_consistent_across_surfaces` and `test_brief_has_no_g11_or_g12_findings` passed in reviewer run | `pytest -n auto` reviewer run | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 26 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. The two coverage-evidence items of the 01-15 review were resolved by reviewer runs at head (`evidence/qa-gates/pytest-coverage.2026-11-10T01-28.md`, `evidence/qa-gates/pester-coverage.2026-11-10T01-38.md`).

**Recommended follow-up verification steps:**

1. After the PR opens, confirm `quality-checks7 / Code Quality & Tests (3.13)` and the `poshqc` jobs are green at the PR head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are markdown checkboxes and not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 26 items were already checked by the executor and all 26 evaluate PASS, so no source-file change was made by this review.

### AC Status Summary

- Source: `docs/features/active/cd-chained-command-recurring-deny-1165/spec.md`
- Total AC items: 26
- Checked off (delivered): 26
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/cd-chained-command-recurring-deny-1165/spec.md` | 26 | 26 | 0 | Checkbox-backed; no change by this review |
