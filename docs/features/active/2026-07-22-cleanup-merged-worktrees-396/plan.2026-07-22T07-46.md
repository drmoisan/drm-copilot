# cleanup-merged-worktrees - Plan

- **Issue:** #396
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-22
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature (per `issue.md` metadata)

## Required References

- Tone policy: `.github/copilot-instructions.md`
- General Coding Standards: `.github/instructions/general-code-change.instructions.md`
- General Unit Test Policy: `.github/instructions/general-unit-test.instructions.md`
- Shell toolchain and coding standards: `.claude/rules/shell.md`
- Quality tiers and coverage thresholds: `.claude/rules/quality-tiers.md`
- Spec: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/spec.md` (AC1-AC8)
- User story: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/user-story.md`
- Research: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/research/2026-07-22T08-30-cleanup-merged-worktrees-research.md`
- House-style references: `scripts/bash/shell-qc.sh`, `scripts/bash/shell_qc_lib.sh`, `tests/shell/test_shell_qc_discovery.bats`, `tests/shell/test_shell_qc_commands.bats`

**All work must comply with these policies; do not duplicate their content here.**

## Planner Decisions (binding for execution)

1. **File layout (500-line cap):** two library files plus one wrapper — `scripts/bash/cleanup_worktrees_lib.sh` (enumeration + classification + report formatting), `scripts/bash/cleanup_worktrees_actions_lib.sh` (consolidation + deletion + merge gate), `scripts/bash/cleanup-worktrees.sh` (thin CLI wrapper).
2. **Git test seam:** `CLEANUP_WT_GIT_BIN` (empty/nonexistent value treated as missing, falling back to `command -v git`), mirroring the `SHELL_QC_<TOOL>_BIN` convention. Scenario selection for the checked-in git stub uses `CLEANUP_WT_STUB_SCENARIO` (path to a checked-in scenario fixture directory).
3. **Report line contract (pinned):** pipe-delimited, one record per line, `LC_ALL=C` ordered: `BRANCH|<name>|<state>`; `COMMIT|<branch>|<sha>|<state>|<paths-csv>|<author>|<author-date>`; `WORKTREE|<path>|<branch-or-DETACHED>|<flags>`; `WARN|main-divergence|<local-sha>|<origin-sha>`; `DIRTY|<worktree-path>|<status-porcelain-line>`; `ACTION|<verb>|<target>|<result>` (apply mode only). Branch states: `NOT_MERGED | MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT | HAS_UNIQUE_RESIDUALS | PROTECTED_CURRENT`; ancestry errors report as `ANCESTRY_ERROR` and fail the run. Per-commit states: `EQUIVALENT | CONTENT_ON_MAIN | EMPTY | UNIQUE | CONFLICT`.
4. **Cherry-pick conflict policy:** on conflict, `cherry-pick --abort`, record the commit as `CONFLICT`, skip the remaining commits of that source branch (intra-branch dependency safety), and continue with the next branch. No `--keep-going` flag in v1.
5. **Consolidation worktree path:** derived as `<main-worktree-path>-wt/documentationandmemories` (main worktree path taken from the first `git worktree list --porcelain` stanza), overridable via `CLEANUP_WT_CONSOLIDATION_PATH`.
6. **PR number for the consolidation PR:** `<N> = 396` (this feature's issue) for the pr-author body/receipt contract, documented in the SKILL.md handoff section.
7. **Verification path (operational constraint):** shfmt and shellcheck are present on this Windows host and run locally via `bash scripts/bash/shell-qc.sh check`; bats and kcov are absent locally and WSL has no bash-capable distribution (verified in `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/shell-qc-orchestrator-verification.2026-07-21T23-20.md`). bats/kcov execution and coverage capture therefore run via CI dispatch of `.github/workflows/_shell-coverage.yml` (`gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57`). The `atomic-executor` Bash allowlist cannot invoke the native bash toolchain; toolchain command tasks below are executed by the main session (orchestrator) when the executor's allowlist blocks them.
8. **Evidence location:** all evidence artifacts live under `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/<kind>/` (canonical scheme; non-overridable). `<FEATURE>` below abbreviates `docs/features/active/2026-07-22-cleanup-merged-worktrees-396`. `<timestamp>` means the ISO-8601 `yyyy-MM-ddTHH-mm` value at execution time.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Bash Toolchain Baseline

- [x] [P0-T1] Read the policy files in this order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.claude/rules/shell.md`, `.claude/rules/quality-tiers.md`; then write `<FEATURE>/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read.
  - Acceptance: the artifact exists at the stated path with all three required fields and lists all five files.
- [x] [P0-T2] Run `bash scripts/bash/shell-qc.sh check` from the repo root and write `<FEATURE>/evidence/baseline/shell-qc-check.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (shfmt diff result + shellcheck result + discovered file count).
  - Acceptance: artifact exists with all four fields and a recorded integer `EXIT_CODE:` (expected 0 on the pre-change tree).
- [x] [P0-T3] Push the branch head (`git push -u origin drm-copilot-wt-2026-07-21T21-57`), dispatch `gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57`, wait for completion (`gh run watch <run-id>`), and write `<FEATURE>/evidence/baseline/shell-coverage-ci.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, the workflow run URL, and `Output Summary:` including the numeric baseline `Bash coverage (lines): NN.N%` line extracted from the run log (`gh run view <run-id> --log`).
  - Acceptance: artifact exists with all fields, a run URL, and a numeric baseline coverage percentage (not a placeholder). Note: kcov measures line coverage only; there is no bash branch-coverage gate per `.claude/rules/shell.md`.

### Phase 1 — Git Seam, Enumeration, Exclusion, and Test Stub

- [x] [P1-T1] Create `scripts/bash/cleanup_worktrees_lib.sh` with the library header comment block (purpose, sourcing contract, `|| rc=$?` note) and the function `cleanup_wt_git()` that resolves the git binary honoring `CLEANUP_WT_GIT_BIN` (non-empty override must be executable; empty/nonexistent treated as missing; fallback `command -v git`) and executes it with the caller's arguments.
  - Acceptance: `bash -n scripts/bash/cleanup_worktrees_lib.sh` exits 0 and `grep -c '^cleanup_wt_git()' scripts/bash/cleanup_worktrees_lib.sh` returns 1.
- [x] [P1-T2] Implement `enumerate_branches()` in `scripts/bash/cleanup_worktrees_lib.sh` using `git for-each-ref --format='%(refname:short) %(objectname)' refs/heads/`, output `LC_ALL=C` sorted, one `name sha` pair per line; no `git branch` parsing.
  - Acceptance: `bash -n` exits 0; function defined; no occurrence of `git branch --merged` or `--grep` anywhere in the file.
- [x] [P1-T3] Implement `parse_worktree_list()` in `scripts/bash/cleanup_worktrees_lib.sh` parsing `git worktree list --porcelain` stanza-wise (`worktree`, `HEAD`, `branch`, `detached`, `bare`, `locked`, `prunable`), emitting one `path|head|branch-or-DETACHED|flags` record per worktree with the first stanza marked as the main worktree.
  - Acceptance: `bash -n` exits 0; function defined; parser keyed on the `worktree ` prefix per record.
- [x] [P1-T4] Implement `compute_protected()` in `scripts/bash/cleanup_worktrees_lib.sh` performing the dual exclusion: current branch via `git rev-parse --abbrev-ref HEAD` (a `HEAD` result protects only the worktree path) and current worktree path via `git rev-parse --show-toplevel` compared, after slash/case normalization, against each porcelain `worktree` path; the main worktree (first stanza) is always excluded; matches classify as `PROTECTED_CURRENT`.
  - Acceptance: `bash -n` exits 0; function defined; both `rev-parse` invocations present.
- [x] [P1-T5] Implement `check_main_freshness()` in `scripts/bash/cleanup_worktrees_lib.sh` comparing `git rev-parse main` with `git rev-parse origin/main` and emitting the `WARN|main-divergence|<local-sha>|<origin-sha>` report line on mismatch (warn-only; never blocks classification).
  - Acceptance: `bash -n` exits 0; function defined; divergence emits `WARN|main-divergence` and returns 0.
- [x] [P1-T6] Create the checked-in git stub `tests/fixtures/cleanup_worktrees/stub-bin/git` (bash script): reads `CLEANUP_WT_STUB_SCENARIO` (path to a checked-in scenario directory), dispatches on its argv (`for-each-ref`, `worktree list --porcelain`, `merge-base --is-ancestor`, `rev-list`, `diff`, `cherry`, `diff-tree`, `rev-parse`, `status --porcelain`, `cherry-pick`, `worktree add/remove`, `branch -D`, `fetch`) to replay canned stdout and exit codes from files in the scenario directory, and echoes each invocation as a `stub-git: <argv>` line so tests can assert which commands ran; the stub writes nothing to disk.
  - Acceptance: stub file exists, `bash -n` exits 0, and it contains no redirection to files (stdout/stderr only).
- [x] [P1-T7] Create scenario fixture directories under `tests/fixtures/cleanup_worktrees/scenarios/` for: `merged_no_worktree`, `merged_with_worktree`, `unmerged`, `ancestry_error` (merge-base exit 128), `content_neutral`, `residual_on_main`, `residual_unique_doc`, `current_exclusion`, `dirty_worktree`, `preexisting_consolidation_branch`, `main_divergence` — each containing the canned `for-each-ref`/`worktree list --porcelain` outputs and per-command exit-code/output files the stub replays. All fixtures are checked in; no temp files.
  - Acceptance: all eleven scenario directories exist and each contains at least a `for-each-ref` output file and a `worktree list --porcelain` output file.
- [x] [P1-T8] Create `tests/shell/test_cleanup_worktrees_enumeration.bats` (bats, sourcing `scripts/bash/cleanup_worktrees_lib.sh`, git stub wired via `CLEANUP_WT_GIT_BIN` + `CLEANUP_WT_STUB_SCENARIO`) with `@test` cases for: `enumerate_branches` output shape and `LC_ALL=C` ordering; `parse_worktree_list` handling of branch, detached, locked, and prunable stanzas; `cleanup_wt_git` seam behavior (executable override honored; empty/nonexistent override falls back); `compute_protected` dual exclusion (branch match, path match, main-worktree always excluded) using the `current_exclusion` scenario; and `check_main_freshness` emitting the `WARN|main-divergence` line using the `main_divergence` scenario.
  - Acceptance: file exists with one `@test` per listed behavior (>= 8 tests), uses no temp files and no real git repos; execution is verified by the Phase 7 CI dispatch.

### Phase 2 — Classification Ladder

- [x] [P2-T1] Implement `classify_ancestry()` in `scripts/bash/cleanup_worktrees_lib.sh` wrapping `git merge-base --is-ancestor <tip> main` with `|| rc=$?` capture: exit 0 → `MERGED_CLEAN`; exit 1 → continue the ladder; exit > 1 → `ANCESTRY_ERROR` (reported as a hard failure for that branch, never treated as "not merged").
  - Acceptance: `bash -n` exits 0; function defined; all three exit-code branches present.
- [x] [P2-T2] Implement `classify_content_neutral()` in `scripts/bash/cleanup_worktrees_lib.sh` running `git diff --quiet main...<branch>` with `|| rc=$?` capture: exit 0 → `MERGED_CONTENT_NEUTRAL` (short-circuit before per-commit analysis; catches revert pairs); exit 1 → continue; exit > 1 → error.
  - Acceptance: `bash -n` exits 0; function defined and invoked before any `git cherry` call in the ladder.
- [x] [P2-T3] Implement `classify_cherry_equivalent()` in `scripts/bash/cleanup_worktrees_lib.sh` parsing `git cherry main <branch>`: `-` lines are patch-id-equivalent; empty-diff residual commits (verified via `git diff-tree --no-commit-id -r <sha>` producing no output) count as equivalent; all residuals equivalent → `MERGED_EQUIVALENT`; otherwise emit the remaining `+` SHAs for the blob-level tier.
  - Acceptance: `bash -n` exits 0; function defined; empty-diff handling present.
- [x] [P2-T4] Implement `classify_residual_commit()` in `scripts/bash/cleanup_worktrees_lib.sh` performing the rename-aware blob-OID fallback per `+` commit: enumerate touched paths via `git diff-tree --no-commit-id --name-status -r -M <sha>`; for `A`/`M` compare blob OIDs `git rev-parse <branch>:<path>` vs `git rev-parse main:<path>`; for `D` droppable iff the path is also absent on `main`; for `Rnnn` compare at the new path; all paths equivalent → `CONTENT_ON_MAIN`; any path unique → `UNIQUE` with the path list.
  - Acceptance: `bash -n` exits 0; function defined; `-M` flag and all four status handlings (`A`, `M`, `D`, `R`) present.
- [x] [P2-T5] Implement `select_cherry_pick_candidates()` in `scripts/bash/cleanup_worktrees_lib.sh` enumerating residuals oldest-first via `git rev-list --reverse --no-merges main..<branch>` and emitting one `COMMIT|<branch>|<sha>|UNIQUE|<paths-csv>|<author>|<author-date>` record per `UNIQUE` commit; a branch with any `UNIQUE` residual classifies as `HAS_UNIQUE_RESIDUALS`.
  - Acceptance: `bash -n` exits 0; function defined; `--reverse` and `--no-merges` both present.
- [x] [P2-T6] Implement `classify_branch()` in `scripts/bash/cleanup_worktrees_lib.sh` orchestrating the full ladder in spec order (`PROTECTED_CURRENT` exclusion → ancestry → content-neutral → cherry-equivalence → blob fallback → `HAS_UNIQUE_RESIDUALS`/`NOT_MERGED`) and emitting the pinned report lines (Planner Decision 3) in `LC_ALL=C` order with stable field order; no commit-message text (`--grep` or subject matching) is used as a classification input anywhere.
  - Acceptance: `bash -n` exits 0; function defined; `grep -c 'grep' scripts/bash/cleanup_worktrees_lib.sh` shows no `git log --grep` usage; file is <= 500 lines (`wc -l`).
- [x] [P2-T7] Create `tests/shell/test_cleanup_worktrees_classification.bats` (git stub + scenarios from P1-T7) with `@test` cases asserting: `merged_no_worktree` → `BRANCH|...|MERGED_CLEAN` with no worktree record; `merged_with_worktree` → `MERGED_CLEAN` plus its `WORKTREE|` record; `unmerged` → `NOT_MERGED`; `ancestry_error` → run fails with `ANCESTRY_ERROR` (exit non-zero, not classified as unmerged); `content_neutral` → `MERGED_CONTENT_NEUTRAL`; `residual_on_main` → `MERGED_EQUIVALENT` (or per-commit `CONTENT_ON_MAIN`) with no cherry-pick candidates; `residual_unique_doc` → `HAS_UNIQUE_RESIDUALS` with a `COMMIT|...|UNIQUE|...` record carrying SHA, paths, author, and date; `current_exclusion` → `PROTECTED_CURRENT` and never delete-eligible.
  - Acceptance: file exists with one `@test` per listed scenario (>= 8 tests); no temp files; execution verified by the Phase 7 CI dispatch.

### Phase 3 — Consolidation onto `documentationandmemories`

- [x] [P3-T1] Create `scripts/bash/cleanup_worktrees_actions_lib.sh` with the library header comment block and the function `create_consolidation_worktree()`: precondition `git rev-parse --verify --quiet refs/heads/documentationandmemories` must fail (branch absent) — if the branch exists, stop and report (never reuse silently); otherwise run `git worktree add <path> -b documentationandmemories main` with `<path>` derived per Planner Decision 5.
  - Acceptance: `bash -n scripts/bash/cleanup_worktrees_actions_lib.sh` exits 0; function defined; pre-existing-branch path returns non-zero with a specific stderr message.
- [x] [P3-T2] Implement `cherry_pick_candidates()` in `scripts/bash/cleanup_worktrees_actions_lib.sh`: process source branches in `LC_ALL=C` sorted order, commits oldest-first within each branch, one `git -C <consolidation-worktree> cherry-pick -x <sha>` invocation per commit (authorship preserved by default; `-x` provenance); all git commands target the consolidation worktree via `-C`, never the caller's worktree.
  - Acceptance: `bash -n` exits 0; function defined; `-x` present; a per-commit loop (not a multi-SHA invocation) is used.
- [x] [P3-T3] Implement conflict and empty-result handling inside `cherry_pick_candidates()`: on non-zero exit with `CHERRY_PICK_HEAD` present, run `git -C <wt> cherry-pick --abort`, record the commit as `CONFLICT`, skip the remaining commits of that source branch, and continue with the next branch (Planner Decision 4); on a "now empty" result, run `git -C <wt> cherry-pick --skip` and reclassify the commit as droppable (`CONTENT_ON_MAIN`). Never auto-resolve conflicts; never use `--keep-redundant-commits` or `--allow-empty`.
  - Acceptance: `bash -n` exits 0; both `--abort` and `--skip` paths present; no auto-resolution logic.
- [x] [P3-T4] Implement `cleanup_consolidation_on_abort()` in `scripts/bash/cleanup_worktrees_actions_lib.sh`: on a hard consolidation failure, remove the consolidation worktree (`git worktree remove`) and delete the branch (`git branch -D documentationandmemories`), reporting each action; no silent leftovers.
  - Acceptance: `bash -n` exits 0; function defined; both removal commands present and reported via `ACTION|` lines.
- [x] [P3-T5] Implement `verify_consolidation_merged()` in `scripts/bash/cleanup_worktrees_actions_lib.sh`: run `git fetch origin main`, then `git merge-base --is-ancestor documentationandmemories main` with the same 0/1/>1 exit-code handling as `classify_ancestry()`; exit 0 is the only state that unlocks deletion of branches whose unique content was consolidated.
  - Acceptance: `bash -n` exits 0; function defined; file is <= 500 lines (`wc -l`).
- [x] [P3-T6] Create `tests/shell/test_cleanup_worktrees_consolidation.bats` (git stub + scenarios) with `@test` cases asserting: pre-existing `documentationandmemories` branch stops the run with a report (using `preexisting_consolidation_branch` scenario); `git worktree add <path> -b documentationandmemories main` appears in the stub argv log; source branches are processed in `LC_ALL=C` order and commits oldest-first with `-x` present on every `cherry-pick` argv; a conflicting pick produces `cherry-pick --abort` in the argv log, a `COMMIT|...|CONFLICT|...` record, and no further picks from that branch; an empty pick produces `cherry-pick --skip` and reclassification; abort cleanup removes the worktree and branch.
  - Acceptance: file exists with one `@test` per listed behavior (>= 6 tests); no temp files; execution verified by the Phase 7 CI dispatch.

### Phase 4 — Deletion Mechanics

- [x] [P4-T1] Implement `reverify_delete_eligible()` in `scripts/bash/cleanup_worktrees_actions_lib.sh`: immediately before any destructive action, in the same process, re-run the ancestry check (`git merge-base --is-ancestor <tip> main`) or re-evaluate the recorded equivalence verdict for `MERGED_CONTENT_NEUTRAL`/`MERGED_EQUIVALENT`; any mismatch aborts deletion of that candidate with a reported `ACTION|delete|<name>|BLOCKED-REVERIFY` line.
  - Acceptance: `bash -n` exits 0; function defined; called before every `worktree remove` and `branch -D` in the apply flow.
- [x] [P4-T2] Implement `remove_worktree_safe()` in `scripts/bash/cleanup_worktrees_actions_lib.sh`: run `git worktree remove <path>` with no `--force` anywhere in the invocation; a dirty worktree (non-zero exit) blocks removal — capture and report the worktree's `git -C <path> status --porcelain` output as `DIRTY|` lines and skip; skip silently when the branch has no worktree; the main worktree is never passed in.
  - Acceptance: `bash -n` exits 0; function defined; `grep -c '\-\-force' scripts/bash/cleanup_worktrees_actions_lib.sh` returns 0.
- [x] [P4-T3] Implement `delete_branch()` and the fixed per-candidate ordering in `scripts/bash/cleanup_worktrees_actions_lib.sh`: (1) `reverify_delete_eligible`, (2) `remove_worktree_safe` (when a worktree exists), (3) `git branch -D <name>` (`-D`, not `-d`, per spec deletion mechanics — safety comes from step 1's re-verification against `main`); prunable registrations are report-only (`git worktree prune` is never executed).
  - Acceptance: `bash -n` exits 0; ordering enforced in one code path; no `git worktree prune` execution present (report-only).
- [x] [P4-T4] Implement `run_apply()` in `scripts/bash/cleanup_worktrees_actions_lib.sh`: apply-mode flow that acts only on `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, and `MERGED_EQUIVALENT` candidates; never acts on `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`, or the main worktree; deletes branches whose unique content was consolidated only after `verify_consolidation_merged()` returns 0; emits `ACTION|` result lines for every action taken or blocked.
  - Acceptance: `bash -n` exits 0; function defined; the eligible-state gate is a single explicit allowlist.
- [x] [P4-T5] Create `tests/shell/test_cleanup_worktrees_deletion.bats` (git stub + scenarios) with `@test` cases asserting: dirty worktree (`dirty_worktree` scenario) blocks removal, emits `DIRTY|` lines with the status output, and no `--force` token ever appears in the stub argv log; a candidate whose re-verification flips (stub returns exit 1 at re-check) is blocked with `ACTION|delete|...|BLOCKED-REVERIFY` and no `branch -D` follows; the argv log shows `worktree remove` strictly before `branch -D` for a worktree-bearing candidate; a merged branch with no worktree gets only `branch -D`; `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS`/`PROTECTED_CURRENT` candidates produce no destructive argv at all; consolidated-content branch deletion is blocked until the stubbed `merge-base --is-ancestor documentationandmemories main` returns 0.
  - Acceptance: file exists with one `@test` per listed behavior (>= 6 tests); no temp files; execution verified by the Phase 7 CI dispatch.

### Phase 5 — CLI Wrapper

- [x] [P5-T1] Create `scripts/bash/cleanup-worktrees.sh` matching the `shell-qc.sh` house style: `set -euo pipefail`; `SCRIPT_DIR` self-resolution; `source` of both libraries with justified `# shellcheck disable=SC1091` comments; `usage()` heredoc documenting report mode (default), `--apply`, `--help`, and the `CLEANUP_WT_GIT_BIN`/`CLEANUP_WT_STUB_SCENARIO`/`CLEANUP_WT_CONSOLIDATION_PATH` environment seams; `main()` dispatching no-args/`report` → report mode (no mutation of any kind), `--apply`/`apply` → apply mode, `--help|-h|help` → usage exit 0, anything else → usage to stderr exit 2; source-guard `if [[ ${BASH_SOURCE[0]} == "${0}" ]]` with explicit `rc` capture and re-exit.
  - Acceptance: `bash -n scripts/bash/cleanup-worktrees.sh` exits 0; file is <= 500 lines; contains no classification/consolidation/deletion logic beyond dispatch.
- [x] [P5-T2] Create `tests/shell/test_cleanup_worktrees_cli.bats` (running the wrapper end-to-end through the git stub) with `@test` cases asserting: `--help` exits 0 and prints usage; an unknown argument exits 2 with usage on stderr; default (report) mode over the `merged_with_worktree` scenario emits classification lines and the stub argv log contains no `worktree remove`, `branch -D`, `cherry-pick`, or `worktree add` invocation; `--apply` over the same scenario emits `ACTION|` lines and destructive argv only for delete-eligible states; sourcing the wrapper does not execute `main` (source-guard).
  - Acceptance: file exists with one `@test` per listed behavior (>= 5 tests); no temp files; execution verified by the Phase 7 CI dispatch.

### Phase 6 — Skill Documentation

- [x] [P6-T1] Create `.claude/skills/cleanup-merged-worktrees/SKILL.md` following house skill conventions: frontmatter with `name: cleanup-merged-worktrees` (matching the folder) and a single-quoted `description` stating what + when; `allowed-tools` scoped to `Read`, `"Bash(bash scripts/bash/cleanup-worktrees.sh *)"`, and the narrow read-only/push git commands the skill layer needs (`"Bash(git fetch *)"`, `"Bash(git merge-base *)"`, `"Bash(git push *)"`, `"Bash(git rev-parse *)"`) — no `gh pr create`/`gh pr edit` capability. Body sections: overview; `## When to Use This Skill`; the end-to-end numbered workflow (1 detect/report via dry-run, 2 editorial triage of `CHERRY_PICK_CANDIDATE` entries — the LLM-judgment boundary, 3 consolidate onto `documentationandmemories`, 4 push the branch, refresh the PR-context bundle via `mcp__drm-copilot__collect_pr_context` with base `main`, validate the orchestrator-state checkpoint with `--require-pr-creation-ready`, and delegate PR creation to `Agent(pr-author)` per `.claude/skills/pr-author/SKILL.md` with `<N> = 396`, 5 wait for merge and verify git-natively via `git fetch` + `git merge-base --is-ancestor documentationandmemories main`, 6 run `--apply` deletion, which also cleans up the now-merged `documentationandmemories` branch/worktree); a prohibited-shortcuts section (no direct `gh pr create`/`gh pr edit --body*`, no `git worktree remove --force`, no `git worktree prune` execution, never act on `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS`/`PROTECTED_CURRENT`); the nothing-to-consolidate short path; and cross-references by path to `.claude/skills/pr-author/SKILL.md`, `.claude/skills/pr-context-artifacts/SKILL.md`, and `.claude/rules/shell.md`.
  - Acceptance: file exists; frontmatter `name` equals the folder name; all six workflow steps and the prohibited-shortcuts section present; body <= 500 lines.
- [x] [P6-T2] Verify with `grep -rn "gh pr create" .claude/skills/cleanup-merged-worktrees/ scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh` that no invocation instruction or command for `gh pr create` (or `gh pr edit`) exists in the new skill or scripts — occurrences are permitted only inside the prohibited-shortcuts prose.
  - Acceptance: every match (if any) is within the SKILL.md prohibition section; zero matches in the three script files.

### Phase 7 — Final QA Loop and Coverage Verification

Loop rule: if any task in this phase fails or rewrites files, fix the cause and restart from P7-T1 until P7-T1 through P7-T4 complete cleanly in a single pass. `SKIPPED` is not a valid outcome for any task in this phase.

- [x] [P7-T1] Run `bash scripts/bash/shell-qc.sh format` from the repo root and write `<FEATURE>/evidence/qa-gates/final-shell-format.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (whether any file was rewritten). If files were rewritten, the loop restarts here after committing the formatting.
  - Acceptance: artifact exists with all four fields; final recorded pass shows no rewrites.
- [x] [P7-T2] Run `bash scripts/bash/shell-qc.sh check` from the repo root and write `<FEATURE>/evidence/qa-gates/final-shell-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (shfmt diff clean + shellcheck findings count, including the new files in the discovered set).
  - Acceptance: artifact exists; final recorded `EXIT_CODE: 0`.
- [x] [P7-T3] Push the branch head, dispatch `gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57`, wait for completion (`gh run watch <run-id>`), and write `<FEATURE>/evidence/qa-gates/final-shell-coverage-ci.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, the run URL, the bats pass/fail counts, and `Output Summary:` including the numeric post-change `Bash coverage (lines): NN.N%` line from the run log. The run must be green (all new bats suites pass on `ubuntu-latest`).
  - Acceptance: artifact exists with a green run URL and a numeric post-change coverage percentage; any red run triggers remediation and a loop restart.
- [x] [P7-T4] Download the merged coverage report from the P7-T3 run (`gh run download <run-id> --name shell-coverage --dir artifacts/pester/kcov-ci`), extract per-file line rates from `cov.xml` for `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh`, and `scripts/bash/cleanup-worktrees.sh`, and write `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` recording: baseline overall coverage (from P0-T3), post-change overall coverage (from P7-T3), and per-file line coverage for the three new production files, each >= 85%. Branch coverage is not applicable for bash (kcov line-only, per `.claude/rules/shell.md`).
  - Acceptance: artifact exists with all numeric values (no placeholders); overall coverage >= 85% and not regressed below baseline; each of the three new files >= 85% line coverage. If any value is unavailable or below threshold, the outcome is remediation-required, never PASS.
- [x] [P7-T5] Verify file-size caps with `wc -l` over `scripts/bash/cleanup-worktrees.sh`, `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh`, `tests/fixtures/cleanup_worktrees/stub-bin/git`, and every `tests/shell/test_cleanup_worktrees_*.bats` file; record the counts in `<FEATURE>/evidence/qa-gates/file-size-caps.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: artifact exists; every listed file is <= 500 lines.
- [x] [P7-T6] Record the single-pass loop confirmation: append to `<FEATURE>/evidence/qa-gates/final-qa-summary.<timestamp>.md` a table of P7-T1 through P7-T5 with each task's final `EXIT_CODE`, artifact path, and the statement that P7-T1..P7-T4 completed without failures or rewrites in one uninterrupted pass, plus `Timestamp:` and `Output Summary:`.
  - Acceptance: artifact exists and every referenced artifact path resolves on disk.

## Test Plan

- Unit (bats, `tests/shell/`, git-binary stub via `CLEANUP_WT_GIT_BIN` + `CLEANUP_WT_STUB_SCENARIO`, checked-in fixtures under `tests/fixtures/cleanup_worktrees/`, no temp files, no scratch git repos):
  - Enumeration/parsing: `test_cleanup_worktrees_enumeration.bats` (P1-T8)
  - Classification ladder incl. the six AC8 scenarios: `test_cleanup_worktrees_classification.bats` (P2-T7)
  - Consolidation: `test_cleanup_worktrees_consolidation.bats` (P3-T6)
  - Deletion incl. dirty-worktree refusal: `test_cleanup_worktrees_deletion.bats` (P4-T5)
  - CLI dry-run vs apply: `test_cleanup_worktrees_cli.bats` (P5-T2)
- Integration: intentionally out of scope; real-git scratch-repo fixtures conflict with the no-temp-files policy (spec "Seeded Test Conditions"). Stub-driven end-to-end CLI tests are the compliant equivalent.
- Manual/CLI: example invocations documented in the SKILL.md (P6-T1).
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/shell-coverage-ci.<timestamp>.md` (P0-T3); post-change `<FEATURE>/evidence/qa-gates/final-shell-coverage-ci.<timestamp>.md` (P7-T3); comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` (P7-T4).

## Open Questions / Notes

- The `atomic-executor` Bash allowlist cannot run the native bash toolchain or `gh`; Phase 0 and Phase 7 command tasks are executed by the main session (orchestrator) as in the #393 cycle. This is an execution-routing note, not a plan gap.
- The pinned report line contract (Planner Decision 3) is the machine contract between the script, the bats tests, and the skill layer; changing it after delivery is a breaking change per the spec.
- Squash-merge support is explicitly out of scope (spec Constraints & Risks); the ancestry primary path assumes merge commits.
