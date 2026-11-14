# Contract and Scope Checks (P5-T4)

Timestamp: 2026-11-13T17-28
Command: sh SCRATCH/issue-1160-contract-scope.sh (from the worktree root: env -u VIRTUAL_ENV poetry run pytest -n auto tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py -q -p no:cacheprovider)
EXIT_CODE: 0
Output Summary:
- One parallel pytest run of the six P0-T3 contract-test files on the merged head: `68 passed in 5.44s`; 0 failed, 0 errors. Exit code 0.

Timestamp: 2026-11-13T17-28
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check (same launcher, worktree root)
EXIT_CODE: 0
Output Summary:
- The Codex generator check exited 0 and printed no drift report.

Timestamp: 2026-11-13T17-29
Command: git diff --name-status <merge base of origin/main and HEAD> HEAD; git status --porcelain; per-file search of both gate files and both siblings (`.claude/hooks/` and `.codex/hooks/` copies) for `python`, `python3`, `py `, and `poetry run python` (case-insensitive); test -e config/preimplementation-gate.json (same launcher, worktree root)
EXIT_CODE: 0
Output Summary:
- Merge base: origin/main at the time of the run equals the merge base, so the diff lists this item's changes only. Name-status diff: 52 paths (`git diff --stat origin/main HEAD`: 52 files changed, 4495 insertions, 20 deletions). `git status --porcelain` was empty.
- Protected files (spec `#### Files not to modify`): a search of the listed paths for the helpers, targets, cleanup, epic-scope, and modes gate siblings, `hook-epic-fan-in.ps1`, `hook-cleanup-context.ps1`, the six `hook-command-` matcher files, `HookTargetWorktree.psm1`, `hook-target-worktree.ps1`, `settings.json`, `config.toml`, and `config/preimplementation-gate.json` found 0 matches. No protected file is changed.
- `config/preimplementation-gate.json`: absent (CONFIG_EXISTS=no), and not in the diff.
- Added `.py` files: 0 (no listed path ends in `.py`).
- Python-invocation search: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` 0 matches; `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` 0; both bookkeeping copies 0; each commands copy 1 raw match, the comment-based help text of the `-PatternIndex` parameter (`The index of the stage-1 pattern that matched: 0 staging, 1 Python tools, 2 npm`). That match names the pattern group in documentation and is not an invocation, so Python-invocation matches total 0.
- Every listed path is under the spec's `#### Files/modules to change` set, this item's feature folder, or its promoted lifecycle record `docs/features/potential/promoted/2026-11-09-preimplementation-gate-false-positives.md`.
