# Follow-Up Candidates ([P9-T27])

Timestamp: 2026-09-25T20-18

Status: recorded only. No GitHub issue was created from this list. `gh issue create` is blocked by a repository hook, and issue promotion is a separate step for the orchestrator or the operator.

1. **Codex gate-4 and gate-5 epic scope (D1).** Files: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`. Decision D1 deferred the epic-scope command-leg, path-leg, and completion-checkpoint handling on the Codex surface; this change touched only the byte-identical helpers copy (`.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`). `evidence/qa-gates/p7-d1-scope.md` confirms the three Codex hooks are unchanged. A Codex-driven epic can therefore still hit the gate-4 and gate-5 denials that issue #663 removed on the Claude surface.

2. **Completion-consistency Edit path reads on-disk content from the literal relative checkpoint path.** File: `.claude/hooks/enforce-completion-consistency.ps1` (the Edit-patch branch documented at lines 269-273 and implemented at lines 288-308, reading through the checkpoint reader at lines 82-85). For an Edit call, the hook applies `old_string` to `new_string` against the on-disk checkpoint. The plan's out-of-scope list (section 1) records that this on-disk read uses the literal relative checkpoint path. If the process working directory differs from the worktree the call targets, the read would resolve to a different file; this consequence was not exercised in this plan. Gate 5 is out of scope under D3 (pinning only).

3. **Header wording of the preimplementation modes file.** File: `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, lines 18-22. The PURITY paragraph states that "the per-mode read seams live in the main gate hook". [P5-T4] moved `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` into the dot-sourced sibling `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, so the sentence is now approximate. The modes file was not modified because of its purity contract and its 480-line size.

4. **Existing issue #510 (bundle-parity test fails on gitignored state).** `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` walks the filesystem and fails when untracked `.claude/state/*-batch-budget.*.json` files exist. This plan worked around it (RS-8) by deleting those files before each contract run; during the final QC loop the batch-budget hook wrote such a file after the pass-1 remediation edit, and it was deleted at the pass-2 [P8-T1]. The durable fix remains open under #510.

5. **Manual #655-sequence rerun on the next live epic (issue #655).** The spec (`spec.md` lines 220 and 292) requires rerunning the #655 sequence from its recorded provenance block on a live epic and recording zero denials. Automated tests do not use a live epic or live GitHub, so this verification has not been performed and remains open.

## Remediation cycle 1 - [P5-T13]

Timestamp: 2026-09-25T21-38

6. **CR-4: pre-existing gate suites read local epic state through the unmocked resolver.** Files: the pre-existing suites under `tests/scripts/claude-hooks/` matching `enforce-pr-author-skill*.Tests.ps1` (gate 1), `enforce-model-routing-receipt*.Tests.ps1` (gate 3), and `enforce-orchestration-preimplementation-gate*.Tests.ps1` (gate 4), excluding the `*.EpicScope.Tests.ps1` suites this feature added (per the CR-4 row of `code-review.2026-09-25T20-26.md`). Mock `Get-EpicScopeCheckpointText` (inside `EpicScopeResolution`) to `$null` in their fixtures so a gitignored local `artifacts/orchestration/epic-orchestrator-state.json` cannot change their outcome. Same class as #510; inert in CI, which has no such file.

7. **RR-1: spec wording of head matching.** File: `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md`, line 83 (design step 2(b)). The text describes head matching only "for a command or path leg with no branch signal", whereas remediation R2 (`.claude/lib/worktree-resolution/EpicScopeResolution.psm1`) makes head matching apply to every command or path leg and ignores any text branch signal. The AC text (AC-1, line 226) is unchanged and still holds; only the design prose is approximate.

8. **Unquoted backslash before a chain operator.** File: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and its three byte-identical copies). An unquoted `\;`, `\&`, or `\|` is still read as a chain operator by the scan, while a POSIX shell treats it as a literal character. The mismatch fails toward deny for chains (a line is split into more segments than the shell sees) and is outside the R1 scope, which covers backslashes before quote characters and inside double-quoted spans.
