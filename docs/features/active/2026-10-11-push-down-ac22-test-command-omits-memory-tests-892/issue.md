# 2026-10-11-push-down-ac22-test-command-omits-memory-tests-892

- Work Mode: minor-audit
- Issue: #892
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/892
- Lifecycle record (by ref): `origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-11-push-down-ac22-test-command-omits-memory-tests.md`
- Research: `research/research.2026-10-11T13-00.md`

## Problem / Why
The Test Strategy Python pytest command in the #790 spec (`docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`, line 196) is the stated verification command for AC-22 (line 223) and is referenced by AC-24 (line 225). The command omits `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py` and `tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py`. Both files exercise `scripts.dev_tools.push_down_claude_customizations`, which delegates to the other measured modules. Under the original command, `push_down_claude_filesystem.py` was measured at 64.29% branch coverage versus 89.29% under the full suite, so the command can understate coverage relative to the AC-22 thresholds (85% line, 75% branch).

## Implementation Intent
Documentation-only amendment, made as a planning-agent amendment:

- Insert the two test file paths into the pytest path list at spec.md line 196, before the first `--cov=` flag. Leave the `--cov=`, `--cov-branch`, and `--cov-report=term-missing` options unchanged.
- Add a dated sub-bullet directly beneath line 196 in the form `- Amendment (2026-10-11, issue #892, planning agent): ...` stating the rationale.
- Do not change AC-22 text, any other AC text, or any checkbox state in the #790 spec.
- Run the amended command and record observed line and branch coverage for the four measured modules as evidence under this item's `evidence/` folder.
- No production or test code changes and no edits to other #790 artifacts. Ten other test files that reference the measured modules are recorded in the research as an observation only and are out of scope.
- `spec.md` and `user-story.md` are intentionally not created for this item (minor-audit).

## Acceptance Criteria
- [x] AC-1 The pytest command at spec.md line 196 of the #790 spec contains both `test_push_down_claude_memory_scope.py` and `test_push_down_claude_pack_memory_modes.py`, each as a `tests/scripts/dev_tools/` path placed before the first `--cov=` flag. Verification: a single-token Grep of each file name in the #790 `spec.md` matches line 196 (and the amendment note); do not pattern-match the full command because the line is long.
- [x] AC-2 A sub-bullet beginning `- Amendment (2026-10-11, issue #892, planning agent)` sits directly beneath the Python toolchain bullet and states the rationale. Verification: Grep for `Amendment (2026-10-11, issue #892` in the #790 `spec.md` returns one match on line 197.
- [x] AC-3 AC-22 (line 223), AC-24 (line 225), and every other acceptance-criterion line in the #790 spec are byte-unchanged versus `origin/main`, including checkbox state. Verification: `git diff origin/main -U0 -- <#790 spec.md>` shows added or changed hunks only at the line 196 command and the new amendment sub-bullet; no hunk touches a line beginning `- [x]` or `- [ ]`.
- [x] AC-4 The only file changed outside this item's feature folder is the #790 `spec.md`. Verification: `git diff --name-only origin/main` lists the #790 `spec.md` plus paths under `docs/features/active/2026-10-11-push-down-ac22-test-command-omits-memory-tests-892/` and no other path.
- [x] AC-5 The amended command (dotted `--cov=` form for the four modules `scripts.dev_tools.push_down_claude_gitignore_merge`, `scripts.dev_tools.push_down_claude_filesystem`, `scripts.dev_tools.push_down_claude_customizations`, and `scripts.dev_tools.push_down_claude_pack_selection`, with `--cov-branch` and `--cov-report=term-missing`) runs and exits 0, and a file under this item's `evidence/` folder records the exact command, the exit code, and numeric line and branch coverage for each of the four modules. Verification: read the evidence file and confirm four module rows with numeric percentages and an exit code of 0.
- [x] AC-6 The change is Markdown-only: no production or test file is modified. Verification: `git diff --name-only origin/main` lists no path under `scripts/`, `src/`, `tests/`, `extensions/`, or `.claude/`, and every listed path ends in `.md` except evidence capture files recorded under this item's `evidence/` folder.

## Dependencies / Risks
- Dependency: the #790 spec file must remain at its current path; no repository test, script, hook, or workflow reads it by path (per research section 5).
- Risk: the existing #790 coverage evidence was produced with the original narrower command and will not match the amended command text. The dated amendment note documents this; the evidence files are dated records and are not edited.
- Risk: the line 196 command is a single long physical line, so line-wrapped or full-command pattern checks are fragile. Verifications use short single-token patterns.
- Observation (out of scope): ten additional test files reference the measured modules and are not in the amended command. The wider `poetry run pytest tests/scripts/dev_tools -k push_down` pass in the same bullet covers them.
- Risk: coverage thresholds are asserted by AC-22 text and not enforced by pytest configuration; the evidence records observed values and does not by itself change AC-22 status.

## Verification Steps
1. Edit the #790 `spec.md` line 196 and add the amendment sub-bullet (AC-1, AC-2).
2. Run `git diff origin/main -U0 -- <#790 spec.md>` and confirm no AC line changed (AC-3).
3. Run `git diff --name-only origin/main` and confirm the file set (AC-4, AC-6).
4. From the repository root, run `poetry run pytest` with the amended path list followed by `--cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing`; save output and exit code under `evidence/` (AC-5).

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
