# Preflight findings — cycle 1

- Timestamp: 2026-08-24T00-28
- Plan under validation: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md`
- Validator: `atomic-executor`, directive `PREFLIGHT VALIDATION ONLY`
- Signal: `PREFLIGHT: REVISIONS REQUIRED`
- Blocking findings: 4 (R1 through R4). Minor findings: 4 (R5 through R8).
- No plan task was executed and no file in the worktree was created, modified, or deleted during preflight.

## Environment preconditions — verified during preflight

| Check | Result |
| --- | --- |
| `poetry env info --path` | `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-23T20-24\.venv` — a different checkout, as expected |
| resolved module `__file__` from worktree root | resolves inside this worktree; cwd wins on `sys.path` |
| `poetry`, `gh`, `pwsh` | all on PATH; `gh auth status` logged in, token scopes include `workflow` |
| `actionlint` | already on PATH; `pwsh -File scripts/dev-tools/run-actionlint.ps1` exits 0 today |
| `_quality-checks.yml` `workflow_dispatch` | declared, and present at `origin/main`, so the Phase 6 dispatch is viable |
| coverage 7.13.2 JSON keys | `percent_statements_covered` always emitted; `percent_branches_covered` only when branch data was collected. The plan's key names and the AC-9 absent-branch scenario are correct |
| `shlex.split` on the planned run blocks | POSIX backslash-newline yields spurious tokens, but every Phase 1 assertion still holds. No revision needed |
| preimplementation gate hook | checkpoint carries `issue-num`, `feature-folder`, `route_id`, `lifecycle_ready: true`; `git commit` and the Python toolchain commands will be allowed |
| structure | phase headings, task form, per-phase ID sequencing all conform; `[expect-fail]` tagging correct; test counts check out |
| evidence kinds | only `baseline`, `regression-testing`, `qa-gates`, `other` are used; no task names a non-canonical kind |
| Phase 6 sequencing | dispatch precedes only polling and the pre-authorized D3 fallback |

## R1 — BLOCKING. P4-T9, P4-T10 and P4-T11 gate nothing.

This is a self-inflicted repeat of the defect under repair. Verified during preflight: `git rev-parse HEAD` and `git rev-parse origin/main` are both `e96e32e01662035faacec460a12441b253b6f3b2`, and `git diff --name-only origin/main...HEAD` produces no output.

The plan makes its first commit at P6-T1. At Phase 4, HEAD is still `origin/main`, so the diff prints an empty list, and all three acceptance conditions are satisfied by that empty list regardless of what the executor did. The three-dot base against `origin/main` is correct; the timing is the defect. AC-14 and AC-15 are therefore unverified by the plan as written.

Replace P4-T9, P4-T10 and P4-T11 with working-tree-form gates based on `git status --porcelain --untracked-files=all`, each of which must additionally assert that the recorded path list is NON-EMPTY — an empty list at that point proves the Phase 1 through Phase 3 edits are absent and is a failure, not a pass. Retain the substantive assertions: the list must not contain the project manifest; it must contain none of the four blocked policy paths; and every path in it must fall inside the closed write set.

Insert a new task immediately after P6-T1 that re-runs `git diff --name-only origin/main...HEAD` against the committed tree and applies the same three assertions. That committed-form gate is the falsifiable form of AC-14 and AC-15, because HEAD carries the change only after P6-T1. Renumber the remaining Phase 6 tasks and update the acceptance-criteria index references accordingly.

## R2 — BLOCKING. `coverage.xml` is a tracked file that three tasks overwrite, and it is not in the write set.

Verified during preflight: `git ls-files coverage.xml` lists the file, `git check-ignore -v coverage.xml` exits 1, and the committed content is a Pester JaCoCo report committed in `9bfe62e1`.

`pyproject.toml` declares no `[tool.coverage.xml]` output override, so every `--cov-report=xml` run writes the default repository-root `coverage.xml`, overwriting the tracked file in place. Three tasks pass that flag: P0-T7, P0-T8 and P4-T5.

This makes P6-T1 and P4-T11 mutually unsatisfiable. If the file is not restored, `git status --porcelain` at P6-T1 reports it as modified and the clean-tree acceptance fails. If it is committed instead, it appears in the committed diff outside the closed write set and the write-set gate halts.

The sibling artifacts `artifacts/python/coverage.json`, `artifacts/python/lcov.info` and `artifacts/.coverage` are covered by the `/artifacts` entry in `.gitignore` and need no handling.

Record the tracked-output constraint in the plan's write-set section, and append to the acceptance text of P0-T7, P0-T8 and P4-T5 a requirement to run `git checkout -- coverage.xml` from the worktree root immediately after the run, record that command and its exit code in the same artifact, and additionally require that `git status --porcelain -- coverage.xml` produce no output after the restore.

## R3 — BLOCKING. P5-T1 and P5-T2 check off AC-12 and AC-17 before their evidence exists.

P5-T2 requires the acceptance-criteria section to contain zero unchecked criteria, and P5-T1 requires every named artifact path to exist on disk. Both run in Phase 5, before Phase 6.

AC-17 (a green run against the branch head) is evidenced only by the Phase 6 green-run artifact. AC-12 is a two-form criterion whose landed form is settled only at the Phase 6 D3 fallback branch. Checking either off in Phase 5 violates the evidence-before-check-off rule in the `acceptance-criteria-tracking` skill, and P5-T1's acceptance is unsatisfiable because the AC-17 artifact does not yet exist.

Scope P5-T1 and P5-T2 to the seventeen criteria whose evidence exists at that point, leaving AC-12 and AC-17 explicitly unchecked and marked pending in the index. Add a final Phase 6 task that checks off those two and finalizes the index.

Resolve explicitly a tension the current plan leaves implied: the green-run artifact is written after P6-T1 declared the tree clean and forbade further commits, and the plan is silent on whether that artifact is ever committed. The final Phase 6 documentation edits and the green-run artifact must be left UNCOMMITTED and handed to the downstream commit-and-pull-request step, because committing them would move the branch head and invalidate the green-run evidence that `modified-workflow-needs-green-run` binds to the branch head SHA.

## R4 — BLOCKING. The hardcoded worktree root will hard-block the plan if it is executed in a different checkout.

The plan pins its working directory to a literal absolute worktree path, and P0-T2's acceptance stops with BLOCKED when the resolved module path does not begin with that literal.

The orchestrator checkpoint records `route_id: preparation`, `preparation_mode: true` and `parallel_slug: critical-bug-fixes`. This plan is prepared for later execution as an item in a parallel run, and that surface schedules each item into its own worktree branched from `origin/main`. If the executing worktree is not the preparation worktree, the plan hard-blocks at its second task for an environment difference that is not a defect.

Restate the working-directory declaration so the executor resolves the repository root once with `git rev-parse --show-toplevel` and compares against that resolved value thereafter, with no comparison against a hardcoded absolute path. Record the preparation-time value as historical context only, and note that every pathspec in the plan is repo-relative because a bare-filename pathspec resolves against the current directory rather than the repository root.

## R5 — Minor. P0-T7 has no declared exit-code expectation.

P0-T7 deliberately runs the defective command. Its verdict is the absence of a `TOTAL` row, not the exit code, but the evidence collector normalizes on `EXIT_CODE` against a default expectation of `0`. If the run exits non-zero, the artifact renders as a failure for a task that succeeded. Record `ExpectedExitCode:` equal to the observed exit code and state in the output summary that the exit code is not the task's verdict.

## R6 — Minor. The plan's self-description of its own coverage values is factually wrong.

The plan asserts that no filesystem-path coverage value and no space-separated coverage value is asserted anywhere. P0-T7 quotes the defective filesystem-path value (the accepted G3), and the bare `--cov` form is read by the gate as space-separated (the four accepted G4s). For a document whose stated purpose is avoiding unfalsifiable gates, state the three cases accurately instead: the single defective filesystem-path value under repair, the four bare-form occurrences settled by decision D1, and the one targeted dotted coverage argument.

## R7 — Minor. The plan's evidence-schema claim is broader than its own tasks.

The plan states that each command-bearing task records the four schema fields in its named artifact, but roughly twenty command-bearing tasks in Phases 1 through 3 name no artifact. Their state is captured by the phase-consolidating artifacts, which satisfies the atomic-plan contract. Scope the claim to the Phase 0 baseline tasks, the Phase 4 final-QC tasks, and the phase-consolidating tasks, and state that intermediate test-authoring tasks are consolidated.

## R8 — Minor. The new module's file I/O must use `Path.read_text`, not builtin `open`.

The repository's in-memory filesystem fixture `mem_fs_path` in `tests/conftest.py` monkeypatches `pathlib.Path` methods and does not intercept builtin `open`. `pyfakefs` is not installed. If the report loader is implemented with `open()`, the unparseable-report test cannot be written without an on-disk temporary file, which `.claude/rules/general-unit-test.md` prohibits outright. Record the constraint in the module design section.

## Advisory — no delta required

`poetry run pyright` in the preparation worktree prints a message about a missing `.venv` subdirectory, because `pyproject.toml` sets `venvPath` and `venv` and no `.venv` exists in this checkout. It still resolved a probe with zero errors and exit 0. Note in the Phase 0 and Phase 4 type-check tasks that this message is expected and is not a finding, so the executor does not attempt to create a virtual environment, which would be an unstated write.

## Write-set boundary — preflight result

No task writes the project manifest, anything under the canonical instructions tree, the bundled customization mirrors, any of the nine deferred occurrences, or anything under the archive, completed, or potential feature trees. The only file a task touches that is not in the declared write set is the tracked root `coverage.xml` recorded in R2. For blast-radius purposes the declared write set is otherwise accurate.
