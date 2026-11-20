# QA Gate — Workflow Review (P4-T3) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: cat + grep -nE "poetry|snok/install-poetry|setup-python|python -m|shell-qc" over both
         modified workflow files
EXIT_CODE: 0

## .github/workflows/_shell-coverage.yml
- Removed steps: "Set up Python 3.13" (actions/setup-python@v7), "Install Poetry"
  (snok/install-poetry@v1), "Load cached venv" (actions/cache@v6 on .venv), "Install
  dependencies" (poetry install --no-interaction --no-root), "Install project"
  (poetry install --no-interaction).
- Kept unchanged: "Check out repository"; "Install shell tooling (shellcheck, shfmt, bats)"
  (apt shellcheck + bats, pinned shfmt 3.8.0 binary); "Cache kcov build"; "Build kcov from
  source" (v43); "Install kcov from cache"; "Upload shell coverage artifacts"
  (upload-artifact@v7, path artifacts/pester/kcov/**, if-no-files-found: error).
- Run step (line ~46): `run: bash scripts/bash/shell-qc.sh test --coverage` — a single native
  command; its non-zero exit fails the step directly.
- `grep -nE "poetry|snok/install-poetry|setup-python|python -m"` -> no hits.

## .github/workflows/_build-check.yml
- Removed `shell-qc --help` from the wheel-install verification step; kept `atomic-executor
  --help`. `poetry build` and the Python setup are unrelated to the shell path and remain.
- Added step "Shell QC smoke (native)" (line 37): `run: bash scripts/bash/shell-qc.sh --help`,
  requiring no tool installs.
- The only `shell-qc` reference is the native wrapper path.

## ci-workflows.md determination
Neither workflow contains a deliberately-failing nested command: each new/changed `run:` step
is a single bash command whose non-zero exit propagates directly to the step result. The
`.claude/rules/ci-workflows.md` `$LASTEXITCODE`-reset pattern targets `pwsh` steps with an
intentionally-failing nested command and imposes no requirement here. The wrapper preserves
the deliberate behavior of a final explicit `exit "$rc"` so intermediate `|| rc=$?` captures
cannot mask a failure.

## Green-run
Green-run verification is deferred to P5-T9 (`modified-workflow-needs-green-run` pre-merge
gate); the executor does not push branches.

Output Summary: Both workflows invoke the native wrapper; no Poetry/Python on the shell path;
exit codes propagate directly; no deliberately-failing nested command; artifact-upload
contract unchanged.
