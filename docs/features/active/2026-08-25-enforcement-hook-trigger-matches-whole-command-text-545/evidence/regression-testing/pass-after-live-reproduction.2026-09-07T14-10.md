# Pass-after: replay of the promotion-hook live reproduction (issue #545)

Timestamp: 2026-09-07T14-10

Task: [P6-T10]

Replays the live reproduction recorded at
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/other/live-reproduction-promotion-hook-overmatch.2026-09-06T23-35.md`
through the promotion hook's pure decision seam.

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used, because
`pwsh`, `powershell`, and `cmd` are not invocable in this session; the replay is therefore driven
through the Pester case that carries the command text verbatim, and per-test results were read out of
`artifacts/pester/pester-junit.xml`.

## Command text used, quoted verbatim

The referenced artifact records the command in elided form:
`` `cat > artifacts/orchestration/orchestrator-state.json <<'JSON' ... JSON` (Bash heredoc writing the
orchestrator checkpoint; the JSON body contained promotion tool names as receipt *values*) ``, and
states in its Output Summary that the values were "recorded there because the orchestrator checkpoint
contract requires promotion receipts under `delegation_receipts.promotion.*`". The body itself was not
transcribed into that artifact, so it is reconstructed here from the artifact's own description:
the same `cat >` heredoc target, the same `<<'JSON'` header, and the promotion tool names as values
under `delegation_receipts.promotion`. This reconstruction is disclosed rather than presented as a
byte-for-byte transcript.

The reconstructed text is held in one place, `$script:LiveReproductionCommand`, and both replay
suites consume that same variable, so the Claude and Codex runs are driven on byte-identical input:

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

Length 305 characters. SHA-256 of the text with LF line endings:
`39a26ed2294ebfa5385022d881a540495668b6ef81820ab490caca030b630a8d`.

## BEFORE — the decision the unfixed hook produced

Two independent records.

**1. The observed live denial.** The referenced artifact records `EXIT_CODE: 2` and the deny reason
`PROMOTION_MCP_ONLY_BLOCKED: Direct Bash promotion-script execution is not allowed in agent sessions.
Use the drm-copilot MCP promotion tools instead.`, which is the value of
`Get-PromotionMcpOnlyBlockedReason` — the legacy promotion-script reason, not the gh-issue reason. No
promotion script was invoked; the command was a file write.

**2. Evaluation of the pre-change decisive predicate on the exact text above.** The pre-change
`Get-PromotionBypassReason` scanned the WHOLE `$CommandText` with
`$CommandText.IndexOf($token, [System.StringComparison]::OrdinalIgnoreCase) -ge 0` for each of the
four forbidden tokens, and returned `Get-PromotionMcpOnlyBlockedReason` on the first hit. Evaluating
that same ordinal case-insensitive containment over the text above gives:

| Forbidden token | Index in the whole command text | Pre-change predicate |
| --- | --- | --- |
| `new-potential-entry.ps1` | -1 | false |
| `new_potential_bug_entry` | 162 | **true** |
| `potential_to_issue` | 208 | **true** |
| `new_active_feature_folder` | 249 | **true** |

Command: `python` evaluation of the four ordinal case-insensitive `IndexOf` probes over the extracted
command text

EXIT_CODE: 0

Three of the four tokens are present in the raw text, so the pre-change loop returned the legacy
blocked reason on the first of them and the decision was **deny**. Recorded honestly: this is an
evaluation of the pre-change code's decisive expression against the exact text, not an execution of
the pre-change hook process, because `pwsh` cannot be invoked in this session. It agrees with the
live denial recorded in record 1.

**BEFORE decision: `deny`, carrying `PROMOTION_MCP_ONLY_BLOCKED`.**

## AFTER — the decision the fixed hook produces

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`, then the same tool with
`scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 0 for both replay cases (5 and 1 respectively at folder scope; the replay cases themselves
report zero failures)

| Runtime | Suite | Case | Seam | Result | Decision |
| --- | --- | --- | --- | --- | --- |
| Claude | `tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | `allows a heredoc whose JSON body names promotion tools as receipt values` | `Invoke-PromotionMcpOnlyDecision` | PASS | **allow** |
| Codex | `tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` | `allows a heredoc whose JSON body names promotion tools as receipt values` | `Invoke-PromotionMcpOnlyDecision` | PASS | **allow** |

Both cases assert `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'`, so a `deny`
would have failed them. Both pass.

**AFTER decision: `allow`, on both runtimes.**

## Why the decision changed

`cat` is not a member of the wrapper carve-out set returned by `Get-CommandLineWrapperName`, so the
segment is not wrapper-led, carries no live substitution, and is balanced. Under the three ordered
clauses of the D2 Piece 1 scan-text selection its `ScanText` is therefore its `MaskedText`, in which
the attached heredoc body is replaced by spaces. The four token literals are byte-unchanged and the
`IndexOf` comparison is byte-unchanged; only the text they are evaluated against changed. The three
tokens present at indexes 162, 208, and 249 of the raw text lie inside the masked span, so no token
is found and the reason is `$null`, which the decision seam renders as `allow`.

The control is not weakened. The paired case in the same suite,
`denies a genuine promotion-script invocation`, drives `pwsh ./scripts/new-potential-entry.ps1
-ShortName foo` and still returns `Get-PromotionMcpOnlyBlockedReason`, because `pwsh` IS in the
wrapper carve-out set and that segment scans raw.

## Consequence for the self-obstructing condition the artifact recorded

The referenced artifact recorded that the orchestrator-state schema requires the promotion receipt
fields while the gate governing those token names denied the ordinary Bash write route, making the two
requirements jointly unsatisfiable on that route. The workaround applied at the time was to write the
checkpoint with the Write tool and strip the literal tool-name values. With this change the heredoc
route allows, so the workaround is no longer required and the values may be recorded as the checkpoint
contract specifies.

Output Summary: the live reproduction replays to **allow** on both runtimes, where the referenced
artifact recorded a **deny** carrying `PROMOTION_MCP_ONLY_BLOCKED`. The command text is quoted
verbatim above, is 305 characters with LF endings and SHA-256
`39a26ed2294ebfa5385022d881a540495668b6ef81820ab490caca030b630a8d`, and is the same
`$script:LiveReproductionCommand` value both replay suites consume, so the before and after runs are
comparable. The before decision is corroborated twice: by the observed live denial in the referenced
artifact, and by evaluating the pre-change `IndexOf` predicate over the exact text, which hits three
of the four forbidden tokens at indexes 162, 208, and 249. The paired deny case for a genuine
promotion-script invocation still denies.
