# Scope Boundary (P9-T2)

Timestamp: 2026-11-17T10-13
Command: sh SCRATCH/issue-1035-p9t2-scope.sh and sh SCRATCH/issue-1035-p9t2-scope2.sh (git commands from the worktree root; the merge base is derived with `git merge-base origin/main HEAD`, as the plan preamble fixes)
EXIT_CODE: 0
Output Summary: All seven checks PASS. Checks 6 and 7 were first run with whole-range filters that also counted the epic-preparation commits on the integration branch; the follow-up script attributes each match to its commit, and the table records the attributed result.

| # | Check | Command and observation | Result |
| --- | --- | --- | --- |
| 1 | No `.dev/` path | `git status --porcelain --untracked-files=all` rows under `.dev/`: 0; `git ls-files -- .dev`: 0 files; `.dev` directory: absent | PASS |
| 2 | `development_docs_root` is `docs/features` in all three copies | `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` each carry `"development_docs_root": "docs/features"` (3 of 3) | PASS |
| 3 | No folder under `docs/features/` renamed | `git diff --name-status -M <merge base> HEAD -- docs/features`: 0 `R` rows | PASS |
| 4 | No new `.py` file under `scripts/` or `tests/scripts/dev_tools/` | `git diff --name-status --diff-filter=A <merge base> HEAD -- scripts tests/scripts/dev_tools`: 0 `.py` rows; untracked `.py`: 0 | PASS |
| 5 | No `pyproject.toml` change | `git diff --quiet <merge base> HEAD -- pyproject.toml` and the working-tree diff both exit 0 | PASS |
| 6 | No Closes, Fixes or Resolves line for #1016 | Lines that start with the keyword followed by `#1016`: 0 in added text and 0 in commit messages (`git log <merge base>..HEAD --format=%B`). A keyword-anywhere search over added text finds 3 prose sentences, none an autoclose line: "this child closes #1016" twice in the #1016 feature folder of epic child 7 (`spec.md`, `user-story.md`, added by the epic-preparation commit "docs(features): add issue 1016 phases 2-3 spec and user story"), and the negated "Does not close #1016." in the promoted potential record, added by the epic commit "docs(epics): re-key child 2 from #1016 to #1035 per owner decision E1" | PASS |
| 7 | Process-reduction ledger | `git diff --name-only <merge base> HEAD -- docs/engineering/process-reductions/` lists only `patches/0010-early-dependent-starts.patch`. `git diff -U0` of the patch shows three changed regions, all inside the one hunk on `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: the header `-219,46 +219,55` to `-219,52 +219,61`, the six added #1035 context lines, and the `+` digest line. `git log --no-merges <merge base>..HEAD -- <patch>` lists one commit, "feat(1035): add .dev write-scope literals to ten agents, reduction: 0010 (P7-T2)"; the path log without `--no-merges` also lists the integration branch's "Merge origin/main into epic/shared-agent-harness-layer-integration", which brings main's content and adds no change relative to the merge base | PASS |
