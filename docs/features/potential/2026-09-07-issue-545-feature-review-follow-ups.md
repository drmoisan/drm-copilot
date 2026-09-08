# Potential: follow-ups surfaced by the issue #545 feature review

- Date captured: 2026-09-07
- Source: feature review of issue #545 (`enforcement-hook-trigger-matches-whole-command-text`), child E of the `cleanup-merged-worktrees-hardening` epic
- Audit artifacts: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/` — `code-review.2026-09-07T17-44.md`, `policy-audit.2026-09-07T17-44.md`, `feature-audit.2026-09-07T17-44.md`, `remediation-inputs.2026-09-07T17-44.md`
- Status: filed, not fixed. Each entry below is independently promotable; they are grouped here because they were surfaced by one review pass, not because they must be delivered together.

This entry discharges exit condition 7 of the issue #545 remediation cycle: "F-1 through F-7 are filed as
follow-up entries or carried into the epic register, not fixed here." None of the seven blocks the #545
pull request. Each was deliberately left unfixed to avoid widening the nine-hook scope that spec D11
defines, per the epic's EA-3 scope guard.

---

## F-1 — Leaf-of-path wrapper resolution

`Get-CommandLineWrapperName` tests membership against the command word verbatim, per spec D2 Piece 2's
"exactly these members". A path-qualified spelling of a wrapper that IS in the set — `/bin/bash -c 'git add .'`,
or `/usr/bin/env git add .` — is therefore not wrapper-led, so its argument is masked and no hook classifies it.

This is the same class as the accepted residual D4.3, but D4.3's justification covers *unlisted* wrappers and
does not extend to an absolute-path spelling of a listed one.

**Why not fixed here.** Acceptance criterion AC-05 pins the **exact** membership of the fourteen-name set. A fix
requires amending D2 Piece 2 and AC-05 in the same change, so the constant, the test, and the specification
continue to agree. That is a specification change, not a defect fix.

## F-2 — Duplicated worktree-removal operand extractor

`Get-EpicWorktreeRemovalCommandPath` and `Get-ParallelWorktreeRemovalCommandPath` are now byte-identical
copy-pasted bodies in two files. Extract into `hook-command-invocation.ps1` as, for example,
`Get-WorktreeRemovalTargetPath`, and make both hooks one-line delegations preserving their names, signatures,
and null-on-miss contracts.

**Why not fixed here.** A refactor, not a defect. The pinning cases at
`enforce-epic-worktree-removal-gate.Tests.ps1:136,141` and `enforce-parallel-worktree-removal-gate.Tests.ps1:78`
would be unaffected, but the change touches four files for no behavioural gain in this cycle.

## F-3 — A write-only constant that can drift

`$script:CdChainedReadCommandPattern` at `.claude/hooks/validate-bash.ps1:204` is referenced nowhere and pinned
by no test, while a parallel live constant `$script:CdChainedReadCommandWords` drives the actual logic. Add a
Pester case deriving the word set from the pattern and asserting equality, so the two cannot drift apart
silently.

**Why not fixed here.** The right action depends on the AC-07 amendment delivered in the #545 remediation
cycle. Now that the byte-unchanged obligation on that constant is recorded as retained, a drift-guard test is
the correct route; deleting the constant is the alternative if that obligation is later dropped.

## F-4 — A test that depends on gitignored ambient state

`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, `Context 'allowed commands'`, does not mock
`Get-PrAuthorCheckpointContent` — unlike three sibling contexts at lines 297, 317, and 363. It therefore reads
the real, gitignored `artifacts/orchestration/orchestrator-state.json` and fails locally whenever that file
carries `epic_mode: true`. The fix is one line: `Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { $null }`.

This violates the rule in `.claude/rules/general-unit-test.md` that tests must not rely on mutable global state
or external configuration that can change between runs.

**Why not fixed here.** Confirmed **not** caused by the #545 change: the pre-#545 code path yields the identical
deny for the identical ambient state. The suite is outside the nine-hook scope D11 defines.

**Worth noting for whoever picks this up.** During the #545 run this case was first recorded as a pre-existing
baseline failure. That attribution was later corrected: the failure is caused by the orchestrator's own
checkpoint, written before the baseline was captured. It is green on a clean CI checkout because `artifacts/`
is gitignored. A reader of the original baseline artifact would be misled.

## F-5 — Epic merge gate authorizes any pull request (EA-3), and the scope has grown

`Test-ChildCheckpointAllowsEpicMerge` at `.claude/hooks/enforce-epic-merge-gate.ps1:177` declares only a
`$Checkpoint` parameter, its call site passes no PR number, and it is consulted first. A checkpoint carrying
`epic_mode: true` and `step9_status: "passed"` therefore authorizes merging **any** pull request.

**Scope correction, discovered during #545 Phase 9 and not known when EA-3 was written.** The Codex sibling has
the same shape: `Test-CodexChildMergeReady` at `.codex/hooks/enforce-epic-merge-gate.ps1:69`, consulted at line
137 with only `-Checkpoint $child`. A fix needs **both** copies, not just the Claude one.

Note also that the earlier EA-3 record named the Codex function as `Test-CodexCheckpointAllowsMerge`; the
feature review corrected that to `Test-CodexChildMergeReady`.

**Why not fixed here.** A pre-existing authorization hole that #545 neither introduces nor widens. Fixing it
exceeds the nine-hook scope and changes a checkpoint contract.

**This entry is the durable record.** EA-3 currently lives only in the epic manifest and in a specification that
is about to be archived when issue #545 closes. Carry this into the epic follow-up register.

## F-6 — Abandon gate normalizes whitespace before segmentation

`enforce-parallel-abandon-gate.ps1` applies `-replace '\s+', ' '` **before** segmentation, so newlines are
collapsed before `Read-CommandLineSegment` sees the text and the hook cannot recognise a heredoc terminator
line. The direction is safe — a flattened heredoc becomes `Unbalanced` and falls back to a raw scan — but the
ordering is undocumented.

**Why not fixed here.** Cosmetic and documentary. Either pass the raw `CommandText` to the scanner, or state the
ordering in the function help.

## F-7 — A hook family at exactly the line cap, with edits scheduled

`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle mirror sit at **exactly 500
lines**, the policy cap, with zero headroom. Spec D12 names this hook family as the subject of imminent edits by
epic children D and G.

**Why not fixed here.** No defect exists today. But the next edit to that file is blocked by the cap before it
begins, so extracting a helper — the mode-routing block or the exemption-consultation block are natural seams —
should happen before child D or G starts, not during.

---

## Suggested promotion grouping

- **Promote first:** F-5. It is an authorization hole in a merge gate, its scope spans two runtime copies, and
  its only other record is about to be archived.
- **Promote before epic children D or G begin:** F-7. It blocks their first edit rather than failing it.
- **Promote together:** F-1 and F-3, since both turn on how much of the wrapper and denylist constant surface is
  pinned by specification versus by test.
- **Low urgency:** F-2, F-4, F-6.
