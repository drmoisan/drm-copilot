# Preflight Fixes

Timestamp: 2026-10-31T01-37
Plan: docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/plan.2026-10-30T20-58.md
Directive: PREFLIGHT VALIDATION ONLY (no task executed, no checkbox changed)

## Fix 1 — `## Declared Blast Radius` (feature documents line)

- Defect class: scope-list path correction (preamble).
- Finding: `git diff --name-status` from the merge base of `origin/main` and `HEAD` already lists `<FEATURE>/issue.md`, `<FEATURE>/spec.md`, and `<FEATURE>/research/2026-10-30T21-30-preserve-modified-merge-research.md`, and the executor edits `spec.md` when it checks off acceptance criteria. The blast radius named only the plan file and the evidence folders, so the P7-T7 scope acceptance ("each one inside `## Declared Blast Radius`") could not pass.
- Change: the feature-documents line now names `<FEATURE>/issue.md`, `<FEATURE>/spec.md` (acceptance-criteria check-offs), `<FEATURE>/research/`, this plan file, and the evidence folders. No production, test, or fixture path changed.

## Fix 2 — `[P0-T4]` acceptance

- Defect class: evidence-content detail required by later acceptance conditions.
- Finding: P1-T1 and P4-T4 compare against "the P0-T4 counts for those files", and P4-T5 against "two more tests than P0-T4" for one file, but P0-T4 recorded only the aggregate TAP plan line and `ok`/`not ok` totals over six files.
- Change: P0-T4 now also records the test count of each of the six files. The command and the asserted outcome are unchanged.

## Fix 3 — `[P4-T3]` source position of MLIB in the wrapper

- Defect class: literal placement that falsifies an unchanged file's stated contract; intent unchanged.
- Finding: `cleanup_worktrees_preserve_eol_lib.sh` (declared "Not changed") states in its header that it "MUST be sourced immediately BEFORE cleanup_worktrees_preserve_lib.sh". Sourcing MLIB "immediately before `cleanup_worktrees_preserve_lib.sh`" would put MLIB between the two and leave that header false, a predictable code-review finding.
- Change: P4-T3 now sources MLIB before `cleanup_worktrees_preserve_lib.sh`, placed immediately before `cleanup_worktrees_preserve_eol_lib.sh`. MLIB is still sourced before the preserve library (the P2-T1 sourcing contract), every acceptance condition is unchanged, and the EOL library remains untouched.

## Validator

- `mcp__drm-copilot__validate_orchestration_artifacts` (`artifact_type: plan`) re-run after the fixes: ok.
- Branch-current CLI `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan path>`: "plan validation passed", EXIT_CODE 0.
