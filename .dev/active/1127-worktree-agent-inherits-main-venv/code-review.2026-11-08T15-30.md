# Code Review: Worktree Poetry Virtual-Environment Guard (Issue #1127)

- **Branch:** `bug/worktree-own-venv` @ `3c8e5375a543d90b6d19cb1bc46f09e88b496b3d`
- **Base:** `main`, merge base `cdcff3871765396183590128e142a929cf78327b` (equal to `origin/main`); trial merge clean
- **Scope:** full branch diff against the merge base; the head includes a plain merge of `origin/main`, and only the branch's own paths are reviewed
- **Reviewer:** feature-review agent, 2026-11-08

## Executive Summary

- **The guard does what the spec asks and no more.**
  - It denies `poetry install|sync|add|remove|update` only when the hook process `VIRTUAL_ENV` is non-empty, not neutralized, and outside the target project.
  - Real-process probes: the reproduction denies with JSON on stdout and exit 0; every other probed shape allows with no output and exit 0.
- **Over-matching is controlled.** A commit message naming `poetry install`, a `gh pr create --body "run poetry install"`, and a trailing `# poetry install` comment all allow in a real process. The case table has two rows for the quoted-prose shape (`commit message naming poetry install`, `echo argument naming poetry install`). The matcher is structural (`Read-CommandLineInvocationSegment`), and Unbalanced and Opaque records are skipped.
- **Failure conventions are as specified.**
  - Claude hook: non-JSON stdin allows with exit 0 and no output (fail open, header states the guard is not a security control). A dependency load failure denies through the standard guard.
  - Codex twin: non-JSON and empty stdin exit 2 with a `WORKTREE_VENV_BLOCKED:` stderr line; a valid payload that allows writes nothing and exits 0.
- **No gate is weakened.** No existing hook, validator, threshold, option table, or exclusion changes. The shared `hook-command-*` files are untouched. The branch adds one registration to each of the Claude and Codex configurations, plus exemption and dependency-table rows in three existing tests that name the new hook.
- **Mirror parity holds.** Four hook and helper bundle copies are byte-identical to their sources; the Claude and Codex helpers are byte-identical to each other; the six `execution-environment/SKILL.md` copies share one MD5; the two bundle configuration files are byte-identical to their sources; both `core.json` manifests list the hook and helper.
- **Coverage.** All four new production files are at 100% line coverage (117/117, 35/35, 117/117, 38/38). Repo-wide PowerShell lines 95.56% to 95.60%.

No blocking finding.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/orchestrator-state/OrchestratorState.psm1` (unchanged) | root LINE counter of the post-change coverage report | CR-I1. The file reads 112 covered of 113, against 113 of 113 at the Phase 0 baseline. A lazy-import line is covered only when the shard that runs it has not already loaded the module, so shard composition decides the figure. The branch does not change this file, nor any file it imports. This is not a regression on a changed line: the owner's rule applies to lines the change touches, and the diff contains none of this file's lines. Repo-wide coverage rose from 95.56% to 95.60%. | No action in this branch. If the owner wants the figure stable, cover the lazy-import line in a dedicated test in a separate change. | The no-regression rule is defined on changed lines. Recording the shard-composition variation keeps the next reviewer from reading it as a branch effect. | `git diff --name-only <merge-base> HEAD` lists no `.claude/lib/orchestrator-state/` path; report counter `missed="1" covered="112"` for the file; baseline `evidence/baseline/pester-parallel.2026-11-08T14-22.md`; gate `evidence/qa-gates/pester-parallel.2026-11-08T15-20.md` |
| Nit | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | `.codex/hooks/` entries near `enforce-promotion-mcp-only.ps1` | CR-N1. The two new entries sit between `enforce-promotion-mcp-only.ps1` and `enforce-python-batch-budget.ps1`, which breaks the alphabetical order of the surrounding hook entries (the Claude manifest keeps its order). Completeness tests pass, so there is no functional effect. | Place `enforce-worktree-poetry-venv.ps1` and `worktree-poetry-venv-policy.ps1` in sorted position in a later manifest edit. | Keeps manifest diffs predictable for later insertions. | `git diff <merge-base> HEAD -- .../codex-and-agents-customizations/pack-manifests/core.json` |
| Nit | `.claude/hooks/worktree-poetry-venv-policy.ps1` | `Get-WorktreePoetryPrefixEnd`, wrapper loop | CR-N2. The wrapper list (`env`, `command`, `nohup`, `time`, `timeout`) does not include other transparent wrappers such as `sudo` or `exec`. A mutating Poetry command behind such a wrapper allows. This follows the spec's guard-not-security-control stance and the documented fail-open direction. | Record only; extend the list if a real incident shows a missed form. | Documents the boundary of the guard. | Helper source lines 170 to 197 |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` at 594 logical lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Decision logic

- `Get-WorktreePoetryVenvDenyReason` evaluates each mutating invocation independently and returns the fixed reason on the first that is un-neutralized and outside the target. A target that cannot be derived (`~`, `$`, missing base) allows, as the spec states.
- `Test-WorktreePoetryPathWithin` requires a separator boundary, so `.venv-old` is not within `.venv`; normalization is string-only with no `$IsWindows` read, so the Linux job exercises Windows forms.
- Neutralization is recognized for `env -u VIRTUAL_ENV`, `-uVIRTUAL_ENV`, `--unset VIRTUAL_ENV`, `--unset=VIRTUAL_ENV`, an earlier `unset VIRTUAL_ENV` at the same depth, and a neutralized root of a wrapper payload; `env -u OTHER` does not neutralize (case row `deny`).
- The `cd` handling accumulates earlier `cd` values at the same depth; an unknown value makes the target underivable and the command allows.

### Hook shells

- The Claude hook returns the dependency decision first, then parses; `ConvertFrom-Json` failure returns `$null` (allow). An allow decision is never emitted, so the hook cannot bypass the permission prompt.
- The Codex twin shares the helper byte for byte, reads stdin directly, and routes empty or malformed input to exit 2 through `Assert-WorktreePoetryVenvPayloadText`. It reads `cwd` from the payload as the spec assumed; the Codex test suite pins the shape.
- Both hooks start no process and invoke no Poetry or Python command.

### Skill text and registration

- The `## Worktree Python Environment` section is identical in six copies and is pinned by a required-heading entry and a content test that checks five tokens.
- Registration appears in `.claude/settings.json` (Bash matcher group) and `.codex/config.toml` (the `^Bash$` group) and in both bundle copies; registration tests assert both.

### Security and correctness

The hook is a deliberate fail-open guard. No secret, path escape, or command construction exists in the new code. The `VIRTUAL_ENV` read is a single seam.

## Verification Performed

- `git fetch`, merge base, `merge-tree` (clean); `diff --name-status` over the range.
- `cmp` of four hook/helper source and bundle pairs and of the two registration files; `md5sum` of six skill copies.
- Real `pwsh` runs of the Claude hook (deny, commit-message prose, `gh pr create --body` prose, comment, `poetry run`, bare `poetry`, non-JSON) and the Codex twin (non-JSON, empty, valid non-Poetry).
- Parse of `artifacts/pester/powershell-coverage.xml`: root and per-file LINE counters, and the `OrchestratorState.psm1` counter.
- Set comparison of the paths brought in by the `origin/main` merge against the branch paths (no shared path).
