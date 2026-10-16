# Hook Refusal During P3-T4 (deviation record)

Timestamp: 2026-10-16T11-14
Command: git grep -n -F -e "hasMergeFlag" -- .claude/hooks/enforce-epic-merge-gate.ps1; echo "EXIT=$?"; git grep -c -F -e "Test-EpicMergeGateCommandInScope -CommandText" -- .claude/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE: 2
Output Summary: the PreToolUse:Bash merge-gate hook denied the P3-T4 verification command with the new F.1 deny text; the cause was the plan-ordered intermediate state of the hook under edit, and the same command passed after P3-T5 and P3-T6 were applied.

Refusal text (verbatim):
PreToolUse:Bash hook error: EPIC_MERGE_GATE_BLOCKED: a pull-request merge or merge-queue enqueue (gh pr merge with any method, --auto, or --admin, or a gh api merge or enqueue mutation) requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green". No checkpoint satisfied this gate.

Cause: the live PreToolUse hook for Bash in this worktree is `.claude/hooks/enforce-epic-merge-gate.ps1`, the file under edit. After P3-T4 the hook called `Test-EpicMergeGateCommandInScope`, but the dot-source that defines it is added only by P3-T6. PowerShell treats the undefined command inside the `if` condition as a statement-terminating error and skips the `if` statement, so every Bash command reached the final deny branch. The command itself named no merge invocation.

Action taken: no bypass route was used (no other tool ran the refused command). The next planned edits, P3-T5 (reader body and description) and P3-T6 (guarded dot-source), were applied with the Edit tool, which the Bash hook does not gate. The identical verification command was then re-run through the same hook and was allowed; its output satisfied the P3-T4 acceptance (`hasMergeFlag` search exited 1; the `Test-EpicMergeGateCommandInScope -CommandText` count was 1).

Note for later plans: any edit sequence on `.claude/hooks/enforce-epic-merge-gate.ps1` that inserts the predicate call before the dot-source leaves Bash unusable between the two edits in a worktree whose live hook is that file.
