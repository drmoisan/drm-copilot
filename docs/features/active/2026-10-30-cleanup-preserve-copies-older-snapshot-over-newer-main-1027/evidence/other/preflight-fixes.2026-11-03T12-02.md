# Preflight Fixes

Timestamp: 2026-11-03T12-02
Plan: docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/plan.2026-10-30T20-58.md
Directive: PREFLIGHT VALIDATION ONLY (second preflight, after the branch merged origin/main at the merge base used below; no task executed, no checkbox changed)

## Tree re-validation summary

- Merge base of `origin/main` and `HEAD`: the `Merge pull request #1060` commit. The branch diff from it contains only the feature folder and its promoted lifecycle record.
- No commit since 2026-10-29 touches `.claude/skills/cleanup-merged-worktrees/`, its bundle mirror, `tests/shell/`, `tests/fixtures/cleanup_worktrees/`, `scripts/bash/shell-qc.sh`, `.github/workflows/_shell-coverage.yml`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, or `tests/scripts/dev_tools/merge_queue_documentation_expectations.py`. Commits that touched `pack-manifests/core.json` changed other entries only.
- Physical line counts (`wc -l`): `cleanup_worktrees_preserve_lib.sh` 492, `cleanup-worktrees.sh` 243, `tests/fixtures/cleanup_worktrees/stub-bin/git` 416, `test_cleanup_worktrees_preserve.bats` 471, `test_cleanup_worktrees_preserve_eol.bats` 175, `test_cleanup_worktrees_preserve_failures.bats` 264. The plan's 492-line claim holds.
- The three bundle mirrors are byte-identical to their sources (`cmp`). In `core.json`, `cleanup_worktrees_preserve_lib.sh` is followed by `cleanup_worktrees_report_records_lib.sh`, so the new entry's placement is sorted.
- Contract-test node IDs: `test_merge_procedure_records_merge_only_after_confirmation` is parametrized by `MERGE_QUEUE_FRAGMENT_PINS` ids and `test_edited_surface_matches_bundled_mirror` by `MIRROR_PAIRS + MERGE_QUEUE_MIRROR_PAIRS` ids; both contain `claude-cleanup-merged-worktrees`. The pinned fragments sit under `## End-to-End Workflow`.
- SKILL.md headings `## Sanctioned Removal Manifest`, `### Example`, `### Accepted residual`, and the `change_class` bullet exist. Wrapper anchors (`Copies each named source file`, the library-order comment, the EOL library source pair) exist. Preserve-library anchors (`NOT change the staging`, `IGNORED-TARGET` check before `preserve_plan_index`, the eight-column `printf -v entry`) exist.
- Test-tree search for the changed symbols and asserted output (`cleanup_worktrees_preserve`, `run_preserve`, `preserve_plan`, `preserve_commit`, `preserve-stage`, `hash-object`, `merge-file`, `cat-file`, `Copies each named source`, `Sanctioned Removal Manifest`, `change_class`): no suite outside the plan's list asserts changed behavior. Every existing preserve scenario's target is `/dev/null` or absent from its consolidation directory (only `MEMORY.md` exists there). The multi-record scenarios sharing target `null` (`ht-patterns`, `exit-codes/skipped`) stop at `HOST-TOKEN-BLOCKED` or `MISSING-SOURCE` before the duplicate check. The dirt suites issue `hash-object` without `-w`, so their stub keys are unchanged. No test pins the stub header text.
- `scripts/bash/shell_qc_lib.sh` `discover_shell_scripts` and the kcov include pattern both cover `.claude/skills`. `_shell-coverage.yml` accepts `workflow_dispatch` and uploads `artifacts/pester/kcov/**`, so Route C is viable.

## Fix 1 — `[P1-T4]` base-unavailable scenario stub responses

- Defect class: fixture-content omission whose correction keeps the assertion's meaning (validator-blind).
- Finding: the design decision states that empty git stdout counts as an unavailable base, and the stub's default is empty stdout with exit 0. `merge-nobase-mergebase` and `merge-nobase-absent` listed only their failing response. Without the earlier successful responses, both scenarios would stop at the worktree-HEAD step, so the "for each cause" fallback (spec AC "Base-unavailable fallback") would be exercised for one cause only while the tests still passed.
- Change: P1-T4 now requires `merge-nobase-mergebase` to hold `rev-parse.verify.HEAD.out` (`wthead01`) and `merge-nobase-absent` to hold `rev-parse.verify.HEAD.out` (`wthead01`) and `merge-base-of.wthead01.HEAD.out` (`mbase001`). The acceptance condition is unchanged.

## Fix 2 — `[P4-T2]` header quotation

- Defect class: citation correction.
- Finding: the task quoted the header as "the copy is verbatim"; the file reads "The copy is verbatim.", and the same header lists "a verbatim byte copy of the source" as an operation. The failure reason `the verbatim byte copy failed` is asserted by `a failed verbatim byte copy is reported as FAILED` in `test_cleanup_worktrees_preserve_failures.bats`.
- Change: the quotation matches the file, the operation-list wording is named, and the task states that the asserted failure reason stays unchanged. The acceptance condition is unchanged.

## Fix 3 — `[P4-T4]` setup comment library count

- Defect class: comment that the planned edit would make false (same class as the earlier P4-T3 fix).
- Finding: the `test_cleanup_worktrees_preserve.bats` setup comment states "The five libraries are sourced here"; after MLIB is added to setup, six are sourced.
- Change: the setup-sourcing update now includes that comment. The acceptance condition is unchanged.

## Fix 4 — `[P4-T5]` writing-phase section comment

- Defect class: comment that the planned edit would make false.
- Finding: the section comment above `preserve_commit_one` in `test_cleanup_worktrees_preserve_failures.bats` states that the eight columns are the ones `preserve_plan_one` emits; after P4-T1 it emits ten.
- Change: P4-T5 now rewords that comment to describe the eight-column helper as the copy-mode form. The five existing `preserve_commit_one` tests and the acceptance condition are unchanged.

## Fix 5 — `[P7-T1]` format observation

- Defect class: write-mode observation that cannot fail (G7 class; correction keeps the assertion's meaning).
- Finding: by P7-T1 every production file the plan edits is already modified or untracked, so `git status --porcelain` shows the same listing whether or not `shfmt -w` rewrote one of them. An undetected rewrite after P6-T1 would leave a mirror out of parity without triggering the loop restart that re-copies mirrors. The task also named the wrapper without its `format` subcommand.
- Change: P7-T1 now also records the `sha256sum` of every changed or new `.sh` file under `.claude/skills/cleanup-merged-worktrees/scripts/` before and after the run and requires identical hashes, and it names `scripts/bash/shell-qc.sh format`. The asserted outcome (no file rewritten) is unchanged.

## Validator

- `mcp__drm-copilot__validate_orchestration_artifacts` (`artifact_type: plan`) re-run after the fixes: `ok: true`, no warnings.
- Branch-current CLI `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan path>`: "plan validation passed", EXIT_CODE 0.
