# [P12-T11] Manual replay of the five 2026-08-24 over-match instances

Timestamp: 2026-09-07T16-05

Command:

```
mcp__drm-copilot__run_poshqc_test
  workspace_root = C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31
  scan_folders   = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]
```

EXIT_CODE: 2 (folder-wide; see the exit-code decomposition below)

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context, so the pure decision seams could not be driven from an interactive PowerShell session. Each
replay below was executed by running the `It` block that already pins its command text, through
`mcp__drm-copilot__run_poshqc_test`, and the per-case decision was read from
`artifacts/pester/pester-junit.xml`. That is a stricter form of the replay rather than a weaker one:
the `It` block supplies the command text and asserts the decision, so a `Passed` status is the
observation that the seam returned the recorded decision for that exact text.

## How the replay set was fixed

The command text for each instance is **not composed here**. Each is taken verbatim from the named
`It` block that already pins it, so the replay set is fixed by that rule and is reproducible by a
third party who reads the same `It` blocks. Each instance below names the file path and the `It` name
its text came from.

## Output Summary

**All five over-match instances return `allow`. The relocating staging spelling returns `deny`, on
both sides.** Six of the seven cases below are the five instances plus the Claude relocating deny;
the seventh is the Codex sibling of the relocating deny, recorded because the same defect existed on
both sides.

| # | Instance | Decision asserted and observed | Case status |
| --- | --- | --- | --- |
| 1 | JSON receipt string containing `--body-file` | **allow** | Passed |
| 2 | Checkpoint write whose receipt list names the promotion tools | **allow** | Passed |
| 3 | Memory-file write quoting the staging literal | **allow** | Passed |
| 4 | Heredoc JSON body mentioning a Python tool name | **allow** | Passed |
| 5 | Prose quoting the two-word staging invocation | **allow** | Passed |
| 6 | Relocating staging spelling, Claude side | **deny** | Passed |
| 7 | Relocating staging spelling, Codex side | **deny** | Passed |

---

## Instance 1 — the JSON receipt string containing `--body-file`

- **Source file:** `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1`
- **Source `It`:** `allows a quoted --body-file mention inside a JSON receipt value` (created by [P7-T3])
- **Full node path:** `enforce-pr-author-skill trigger scoping (issue #545).over-match removal - a quoted mention is not an invocation.allows a quoted --body-file mention inside a JSON receipt value`
- **Seam driven:** `Invoke-PrAuthorSkillDecision`

Command text, verbatim from that `It`, as it appears in the PowerShell source (the doubled single
quotes are PowerShell's escape for a literal single quote inside a single-quoted string):

```powershell
$command = 'echo ''{"cmd":"gh pr create --body-file artifacts/pr_body_545.md"}'' > artifacts/receipt.json'
```

The command text the seam actually receives:

```
echo '{"cmd":"gh pr create --body-file artifacts/pr_body_545.md"}' > artifacts/receipt.json
```

- **Observed decision: `allow`.** Case status **Passed**, 0.013 s.
- Reason recorded in the `It`: the `echo` segment mentions the phrase inside a quoted span and
  invokes nothing.

## Instance 2 — the checkpoint write whose receipt list names the promotion tools

- **Source file:** `tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1`
- **Source `It`:** `allows a heredoc whose JSON body names promotion tools as receipt values` (created by [P6-T3])
- **Full node path:** `enforce-promotion-mcp-only.ps1 trigger scoping (issue #545).the over-match allow case - a receipt value is not an invocation.allows a heredoc whose JSON body names promotion tools as receipt values`
- **Seam driven:** `Get-PromotionTriggerScopingDecision`

The `It` reads its text from `$script:LiveReproductionCommand`, declared in the same file's
`BeforeAll` so that this suite and the [P6-T10] replay exercise byte-identical input. Command text,
verbatim:

```
cat > artifacts/orchestration/orchestrator-state.json <<'JSON'
{
  "issue-num": "545",
  "route_id": "epic",
  "delegation_receipts": {
    "promotion": {
      "new_potential_bug_entry": "completed",
      "potential_to_issue": "completed",
      "new_active_feature_folder": "completed"
    }
  }
}
JSON
```

- **Observed decision: `allow`.** Case status **Passed**, 0.011 s.
- Reason recorded in the `It`: a heredoc body attached to a non-wrapper segment is masked, so the
  names are data.

This is the live reproduction recorded at
`evidence/other/live-reproduction-promotion-hook-overmatch.2026-09-06T23-35.md`: the
orchestrator-state schema requires those three tool names as values under
`delegation_receipts.promotion`, so the write and the gate were individually reasonable and jointly
unsatisfiable while the heredoc body was scanned as command text.

## Instance 3 — the memory-file write quoting the staging literal

- **Source file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`
- **Source `It`:** `allows a heredoc body that quotes the staging invocation in prose` (created by [P1-T4])
- **Full node path:** `enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc body that quotes the staging invocation in prose`
- **Seam driven:** `Invoke-OrchestrationPreimplementationGateDecision`, via the suite's single act
  helper `Get-TriggerScopingDecisionForCommand`, against
  `ConvertTo-TriggerScopingNotReadyCheckpointRaw`

Command text, verbatim:

```
cat <<'NOTE' > docs/features/active/sample/notes.md
Run git add docs/features/active/sample/spec.md once the scaffold lands.
NOTE
```

- **Observed decision: `allow`.** Case status **Passed**, 0.011 s.
- Reason recorded in the `It`: a non-wrapper heredoc body is consumed as data and never executes.

This is the class of the reported friction: writing a document that necessarily quotes the token it
describes. The heredoc feeds a file, not a shell.

## Instance 4 — the heredoc JSON body mentioning a Python tool name

- **Source file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`
- **Source `It`:** `allows a heredoc whose JSON body names a governed tool as a receipt value` (created by [P1-T4])
- **Full node path:** `enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc whose JSON body names a governed tool as a receipt value`
- **Seam driven:** `Invoke-OrchestrationPreimplementationGateDecision`, via
  `Get-TriggerScopingDecisionForCommand`, against a not-ready checkpoint

Command text, verbatim:

```
cat > artifacts/orchestration/orchestrator-state.json <<'JSON'
{
  "route_id": "large",
  "qa_gates": ["pytest", "black", "ruff"]
}
JSON
```

- **Observed decision: `allow`.** Case status **Passed**, 0.012 s.
- Reason recorded in the `It`: a JSON value naming a tool is a receipt value, not an invocation.

The Python tool names mentioned are `pytest`, `black`, and `ruff`, all three of which trigger
pattern 2 of the preimplementation gate when scanned as raw command text.

## Instance 5 — prose quoting the two-word staging invocation

- **Source file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`
- **Source `It`:** `allows a quoted mention of the staging invocation inside an echo argument` (created by [P1-T4])
- **Full node path:** `enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a quoted mention of the staging invocation inside an echo argument`
- **Seam driven:** `Invoke-OrchestrationPreimplementationGateDecision`, via
  `Get-TriggerScopingDecisionForCommand`, against a not-ready checkpoint

Command text, verbatim:

```
echo "run git add scripts/powershell/Sample.ps1 after the checkpoint is ready"
```

- **Observed decision: `allow`.** Case status **Passed**, 0.016 s.
- Reason recorded in the `It`: a quoted mention in a non-wrapper segment is data, not execution.

## Instance 6 — the relocating staging spelling denies (Claude)

- **Source file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`
- **Source `It`:** `denies a relocating git add carrying a directory global option`
- **Full node path:** `enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a directory global option`

Command text, verbatim:

```
git -C ../other-worktree add .
```

- **Observed decision: `deny`.** Case status **Passed**, 0.009 s.
- The `It` additionally asserts
  `$decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'`,
  so the deny carries the expected reason prefix and is not a deny for some unrelated cause.

### Two recorded differences from the task's literal wording

Both are stated so the reader is not left to reconcile them silently.

1. **The directory operand spelling.** [P12-T11] names the command `git -C ../x add .`. The delivered
   pinning case spells the directory `../other-worktree`. The two are the same form — a relocating
   `-C <dir>` global option between the command word and the `add` subcommand, with a `.` operand —
   and the delivered text is the one that is actually pinned by a named case, which is the standard
   this task sets for the other five instances. A search of `tests/` for the literal `git -C ../x`
   returns no match, so no case pins the shorter spelling.
2. **The seam driven.** [P12-T11] names `Test-ImplementationCommand`. The delivered pinning case
   drives `Invoke-OrchestrationPreimplementationGateDecision` against a not-ready checkpoint, which
   is a **superset** of that classifier rather than a substitute for it: under a not-ready
   checkpoint, the gate returns `deny` only when the command classifies as an implementation command,
   so the classifier returning `$true` is a necessary condition of the observed `deny`. The observed
   deny therefore establishes the classification the task asks about, and additionally establishes
   that the classification reaches the decision.

## Instance 7 — the relocating staging spelling denies (Codex)

Recorded because the same latent bypass existed in the Codex copy and the plan requires the fix on
both sides.

- **Source file:** `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`
- **Source `It`:** `denies a relocating git add carrying a directory global option`
- **Full node path:** `Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a directory global option`
- **Seam driven:** `Invoke-OrchestrationPreimplementationGateDecision`, via
  `Get-CodexTriggerScopingDecisionForCommand`, against
  `ConvertTo-CodexTriggerScopingNotReadyCheckpointRaw`

Command text, verbatim:

```
git -C ../other-worktree add .
```

- **Observed decision: `deny`.** Case status **Passed**, 0.006 s.

## Exit-code decomposition

The MCP runner returned exit code 2 for the two scanned folders together. The folder-wide totals were
**2272 tests, 2 failures, 0 errors** across 94 suites. Both failures are pre-existing and documented
as outside this change's scope in the execution delegation, and neither is a member of the [P1-T13]
known-red inventory:

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ::
   `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. Cause: the case does
   not mock `Get-PrAuthorCheckpointContent`, so it reads this run's real orchestrator-state
   checkpoint, which carries `epic_mode: true`, while the fixture command carries no `--base`. The
   hook denies correctly.
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` ::
   `allows every registered handler for every tool name its own matcher admits`. Cause: ambient state
   driven by this worktree's epic checkpoint.

**Every one of the seven replay cases above is in the Passed set**, so the exit code carries no
information about them. The six suites this replay draws from all reported zero failures:

| Suite | Tests | Failures |
| --- | --- | --- |
| `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 18 | 0 |
| `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | 8 | 0 |
| `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | 19 | 0 |
| `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` (Codex) | 23 | 0 |
