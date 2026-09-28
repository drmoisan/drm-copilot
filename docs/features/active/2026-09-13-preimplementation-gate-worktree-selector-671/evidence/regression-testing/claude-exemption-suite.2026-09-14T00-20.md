# Claude Command-Exemption Suite Result (issue #671)

Timestamp: 2026-09-17T08-07
Task: [P3-T3]
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks"]) as the route-compliance step; then `artifacts/pester/pester-junit.xml` (LastWriteTime 2026-09-17T08:06:45) read by a scratchpad parser under pwsh 7.6.6, per governing paragraph 2
EXIT_CODE: 4
Status: INCOMPLETE — all seven asserted nodes passed, but the suite's `testsuite` element carries `failures="3"`.

Output Summary:
- MCP call disposition: non-zero (`ok: false`, "Command exited with code 4."). The run had 4 failing nodes.
- Run totals (scoped run): tests=1659, failures=4, errors=0, disabled=0.
- Asserted suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`: `testsuite` matches=1; tests=83, failures=3, errors=0, skipped=0, disabled=0.
- All seven asserted nodes: match count 1 each, status `Passed`.
- New Context census: allow cases 7 of 7 Passed; deny cases 14 of 17 Passed.
- Failing nodes in this suite: `denies issue #671 LACS L3a - selector with no subcommand after the value`, `denies issue #671 LACS L3b - subcommand not immediately after the selector value`, `denies issue #671 LACS L8 - empty selector value`.
- The fourth failing node in the run, `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, is one of the two baseline failures recorded in [P0-T8] and is unrelated.

## Asserted nodes (classname scoped to the suite path)

| It label | Matches | classname | status |
| --- | --- | --- | --- |
| `allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand` | 1 | `.../tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | Passed |
| `allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector` | 1 | same | Passed |
| `denies issue #671 cd chain into the target worktree` | 1 | same | Passed |
| `denies issue #671 selector with a non-exempt pathspec operand` | 1 | same | Passed |
| `denies issue #671 selector with the tree-wide all flag` | 1 | same | Passed |
| `denies issue #671 selector with an absolute pathspec operand` | 1 | same | Passed |
| `denies issue #671 selector with an output redirection` | 1 | same | Passed |

(`...` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686`)

## Root cause of the three failing rows (spec-table defects, not production-code defects)

1. **L3a** (`git -C C:/repo/wt`) and **L3b** (`git -C C:/repo/wt -- docs/features/active/x/spec.md`): neither command carries an `add` or `commit` subcommand, so the gate's trigger never classifies them as implementation commands. Direct probe: `Test-ImplementationCommand` returns `False` for both, so the gate returns `allow` before the exemption is consulted. The new predicate does reject both (`Test-ExemptOrchestrationStagingCommand` returns `False`; rows 13 and 14 of the reproduction). These fixtures break the invariant stated in the existing deny context ("Every fixture matches the unchanged trigger regex"), so a gate-level deny assertion cannot pass for them under any implementation of LACS.
2. **L8** (`git -C "" add -- docs/features/active/x/spec.md`): the pre-existing empty-token fail-open at helpers line 221 (see `fail-before-lacs-repro.2026-09-13T22-40.md`, Row 20 finding). The empty token fails parameter binding before the selector predicate runs, and under the `Continue` preference `Test-ExemptOrchestrationStagingCommand` returns `True`. Direct probe: `Test-ImplementationCommand` returns `False` for this line (the exemption clears the only matching trigger index), so the gate allows. Fixing it requires adding `[AllowEmptyString()]` to the unchanged `param` line 221, which [P1-T3] and [P5-T4] do not permit.

A plan and spec revision is required for all three rows; the proposed delta is in the executor completion report.
