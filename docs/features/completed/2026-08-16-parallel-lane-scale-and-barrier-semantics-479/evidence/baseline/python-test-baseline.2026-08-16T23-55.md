# Python Test + Coverage Baseline (Issue #479)

Timestamp: 2026-08-16T23-55

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (repo root)

EXIT_CODE: 1

## Output Summary

### Test counts

`1 failed, 3784 passed, 5 skipped in 17.66s`

### Numeric coverage totals (repo-wide)

- Combined (coverage.py `percent_covered` with `--cov-branch`): **90.25%**
- Line coverage: **92.30%** (13288 covered / 14396 statements)
- Branch coverage: **84.66%** (4475 covered / 5286 branch exits)
- Both exceed the uniform thresholds (line >= 85%, branch >= 75%).

### Per-module baseline values required by the plan

| Module | Stmts | Miss | Branch | BrPart | Cover |
|---|---|---|---|---|---|
| `scripts/dev_tools/parallel_mutation_protocol.py` | 49 | 0 | 24 | 0 | **100%** |
| `scripts/dev_tools/parallel_manifest_contract.py` | 65 | 0 | 22 | 0 | **100%** |
| `scripts/dev_tools/_parallel_mutation_models.py` | 93 | 0 | 30 | 0 | **100%** |

### PRE-EXISTING FAILURE (environmental, not repository state)

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

Assertion:

```
AssertionError: Repo file missing from bundle:
  .claude\worktrees\agent-afc9f4fd25ec235a5\.agent_logs\atomic_executor_2026-08-15_151958.log
```

Cause: the test enumerates `REPO_ROOT/.claude/**` from the filesystem with `rglob`
(`test_push_down_claude_resource_contracts.py:34-43`). This working copy contains a live,
gitignored `git worktree` at `.claude/worktrees/agent-afc9f4fd25ec235a5/` (confirmed by
`git worktree list --porcelain`; it holds branch `feature/enforcement-hooks-must-not-invoke-python-475`)
which carries a full second copy of the repository plus agent log files. Those files are
gitignored, are therefore absent from the bundle, and cannot be present in it.

Established as pre-existing and environmental:

- The failure is reproduced at the untouched baseline commit `a43deb73` with a clean tracked
  working tree, before any change made by this feature.
- No `.claude` file tracked by git is implicated. The test iterates paths in sorted order and
  `-x` reports the FIRST failing path; `.claude/worktrees/...` sorts after every real payload
  path (`agents/`, `hooks/`, `lib/`, `rules/`, `settings.json`, `skills/`), so every tracked
  `.claude` file passed BOTH the presence assertion and the byte-identity assertion before the
  loop reached the worktree path. Baseline mirror parity is therefore intact.
- In CI the `.claude/worktrees/` directory does not exist (gitignored, never checked out), so
  this failure does not occur there.

Handling for this feature: the four mirror-gate tasks (P1-T15, P2-T9, P3-T11, P4-T3) run this
suite as instructed and additionally verify per-pair byte-identity of the specific mirrored
files touched, so the acceptance substance ("per-pair byte-identity confirmed") is discharged
with direct evidence rather than by relying on a suite that is environmentally blocked. No
assertion, test, or threshold is weakened.
