Timestamp: 2026-08-28T23-45

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -v

EXIT_CODE: 1

Output Summary: 1 failed. `AssertionError: Repo file missing from bundle: .claude\scheduled_tasks.lock`.

Discrepancy from plan prediction: The plan's P0-T2 acceptance criterion expected the
`AssertionError` to name `.claude/skills/cleanup-merged-worktrees/SKILL.md` as the
differing file. The actual assertion instead names `.claude\scheduled_tasks.lock`.

Root cause: `list_scoped_files()` in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` performs an
unfiltered `rglob("*")` over the entire `.claude` tree on disk, with no exclusion for
gitignored or session-local runtime artifacts (its only exclusions are
`.claude/settings.local.json` and the `.claude/agent-memory/**` subtree, applied by the
caller). `.claude/scheduled_tasks.lock` is a locally-present, gitignored (via
`.git/info/exclude`, not a repo-tracked `.gitignore` entry) session lock file. Its JSON
content records `"sessionId":"07af716e-bb93-4132-b3e7-c2225a367494"`, which matches this
very execution session, confirming it is this session's own active runtime lock, not a
stray artifact. The test's `for relative_path in repo_runtime_files: assert ...` loop
fails at the first path not present in the bundled payload; sorted lexicographically,
`.claude\scheduled_tasks.lock` precedes `.claude\skills\cleanup-merged-worktrees\SKILL.md`
(`'c' < 'k'` at the fourth character), so the loop reports the lock file and never
reaches the SKILL.md comparison in this run.

This matches a previously recorded defect: the bundle-parity contract test fails on
local gitignored state and is green in CI, where no such lock file exists (issue #510
per prior investigation). It is a pre-existing confound unrelated to this remediation's
scope and is not remediated here; the Scope Constraint in this plan explicitly
prohibits modifying any file other than the one named bundled `SKILL.md` mirror, and
this session's own active lock file is excluded from that scope on both grounds.

Non-zero EXIT_CODE is confirmed, satisfying the [expect-fail] intent of this task
(a fail-before state exists), but the specific AssertionError target named by the
plan's acceptance text is not the one observed in this run.
