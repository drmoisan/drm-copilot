# Feature Audit: Worktree Poetry Virtual-Environment Guard (Issue #1127)

- **Branch:** `bug/worktree-own-venv` @ `3c8e5375a543d90b6d19cb1bc46f09e88b496b3d`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`; `artifacts/pr_context.summary.txt` resolves `origin/main` @ `cdcff3871765396183590128e142a929cf78327b` for head `3c8e5375a`.
- Merge base: `cdcff3871765396183590128e142a929cf78327b`, equal to `origin/main` after fetch. `git merge-tree --write-tree origin/main HEAD` is clean.
- Range audited: the full branch diff. The head includes a plain merge of `origin/main`; the paths that merge brought in share no path with the branch's own paths.
- Work mode: `full-bug`, so the AC source is `spec.md` (AC1 to AC22).
- Inputs: `plan.2026-11-08T08-08.md`, `research/research.md`, `evidence/`.

## Acceptance Criteria Inventory

| ID | Criterion (abridged) |
|---|---|
| AC1 | Mutating Poetry subcommands deny with `WORKTREE_VENV_BLOCKED:`, JSON on stdout, exit 0, when `VIRTUAL_ENV` is outside the target. |
| AC2 | The reason names the legitimate path and forbids repointing the main environment. |
| AC3 | `env -u VIRTUAL_ENV` and `unset VIRTUAL_ENV` forms allow. |
| AC4 | Unset, empty, or inside-target `VIRTUAL_ENV` allows. |
| AC5 | Quoted prose naming a Poetry command allows. |
| AC6 | Non-mutating subcommands and non-Poetry commands allow. |
| AC7 | Target honors `cwd`, `-C`/`--directory`/`-P`/`--project`, and `cd`. |
| AC8 | Path comparison handles separator, Git Bash, case, and sibling-prefix forms as strings. |
| AC9 | Malformed payload fails open (Claude); header records the guard stance. |
| AC10 | Hook-dependency guard completeness and no Python. |
| AC11 | Pure helper; injected inputs; leak scan clean. |
| AC12 | Registered for Claude and Codex; twin equivalent. |
| AC13 | Bundle copies and manifest entries; contract tests pass. |
| AC14 | Dependency-failure table rows. |
| AC15 | `## Worktree Python Environment` section content. |
| AC16 | Six byte-identical skill copies; brief contract test passes. |
| AC17 | New Pester tests pass in the single gate with no new failure against Phase 0. |
| AC18 | Line coverage of each new PowerShell file >= 85%; no exclusion added. |
| AC19 | Shared option table: git/gh suites unchanged if changed. |
| AC20 | Integration evidence of main `.venv` unchanged. |
| AC21 | Full toolchain pass, no gate weakened. |
| AC22 | Rollout notes record the push-down refresh. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC1 | PASS | Reproduction rows for the five subcommands deny in the shared case table; the reviewer's real-process run of `poetry install` denied with deny JSON and exit 0. |
| AC2 | PASS | `Get-WorktreePoetryVenvBlockedReason` carries `env -u VIRTUAL_ENV poetry install`, "worktree root", and "never repoint the main checkout's environment"; asserted in the Pester suites. |
| AC3 | PASS | Case rows `env -u`, `--unset=`, `-u` attached, `unset VIRTUAL_ENV;`, and neutralized wrapper payload allow; `env -u OTHER` denies as the control. |
| AC4 | PASS | Rows `VIRTUAL_ENV unset`, `VIRTUAL_ENV empty`, `main checkout own .venv` allow. |
| AC5 | PASS | Rows for a commit message and an `echo` argument allow; the reviewer's real-process runs of a `git commit -m` message, a `gh pr create --body` string, and a trailing comment allowed with no output. |
| AC6 | PASS | `poetry run pytest` and bare `poetry` allowed in a real process; the table carries `run`, `env info`, `show`, `check`, and non-Poetry rows. |
| AC7 | PASS | Rows for `-C`, `--directory`, `-P`, `--project`, `--directory=`, relative `-C`, and `cd` variants, each paired with the plain command from the same `cwd` so the override changes the decision. |
| AC8 | PASS | Backslash, forward-slash, `/c/`, trailing separator, case, POSIX worktree, and `.venv-old` rows; the helper reads no `$IsWindows`; suites live under the Linux hook-suite folders. |
| AC9 | PASS | Real-process run with non-JSON stdin exited 0 with no output; the header comment states "a guard against a known foot-gun, not a security control". The Codex twin exits 2 on malformed or empty input, as the spec note states. |
| AC10 | PASS | Hook-dependency guard shape present in both hooks (load failure exits 2, dependency failure denies with the prefix); the no-Python suite passed in the gate (`evidence/qa-gates/pester-parallel.2026-11-08T15-20.md`). |
| AC11 | PASS | Logic in `worktree-poetry-venv-policy.ps1`; tests inject text, `VIRTUAL_ENV`, and `cwd`; one mocked seam; leak scan 0 failures (`leak-scan.2026-11-08T14-58.md`). |
| AC12 | PASS | `settings.json` and `config.toml` entries present and byte-identical to their bundle copies; registration tests; the Codex twin differs from the Claude hook only in header, payload read, and exit path, and shares the helper byte for byte. |
| AC13 | PASS | Four bundle copies `cmp`-identical to sources; both `core.json` manifests list hook and helper; the push-down, manifest-completeness, and bundle-probe suites pass in the gate. |
| AC14 | PASS | Rows added to the Claude and Codex dependency-failure tables and to the worktree-cleanup exemption table. |
| AC15 | PASS | Section present in the skill; text states the inherited-`VIRTUAL_ENV` behavior, the `env -u VIRTUAL_ENV poetry install` bootstrap, the empty-`.venv` warning, the hook, and the `PYTHONPATH` note (five tokens pinned by the content test). |
| AC16 | PASS | One MD5 (`aa524014de5884b273b4dae80e899032`) for all six copies; required-heading list updated; the content test is part of the pytest gate. |
| AC17 | PASS | Single Pester and single pytest gates with 0 failures; fail-before evidence shows the new tests fail without the hook. The Linux hook-suite CI job has not run; that part is pending-CI and not a finding. |
| AC18 | PASS | Per-file LINE counters 117/117, 35/35, 117/117, 38/38 in `artifacts/pester/powershell-coverage.xml`; no exclusion entry added. |
| AC19 | PASS | The shared command-option table and `hook-command-*` files are untouched, so the git/gh suites are unaffected. |
| AC20 | PASS | `evidence/regression-testing/venv-isolation.2026-11-08T14-50.md` records the before/after comparison. |
| AC21 | PASS | Format, lint, type-check, and test artifacts under `evidence/qa-gates/`; no threshold lowered. |
| AC22 | PASS | `spec.md` `## Rollout & Follow-up` records the push-down refresh after the release. |

## Summary

All 22 criteria evaluate PASS. The guard blocks the foot-gun, allows the neutralized and legitimate forms, treats quoted prose as inert, fails open on the Claude side and closed on the Codex side, and ships with identical bundle and skill copies. The `OrchestratorState.psm1` 113/113 to 112/113 variation is in an unchanged file and is not a changed-line regression (code review CR-I1).

No blocking finding. Verdict: PASS. CI on this head has not run; the Linux hook-suite job is pending-CI.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-08-worktree-agent-inherits-main-venv-1127/spec.md`
- Total AC items: 22
- Checked off (delivered): 22
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

All 22 items were already checked in `spec.md` and each evaluates PASS in this review, so they stay checked. No criterion was added, and no criterion text was changed. AC17 carries a CI-dependent clause (the Linux hook-suite job); the orchestrator confirms it at S9.
