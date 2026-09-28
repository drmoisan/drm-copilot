# Research — cleanup-worktrees consolidation PR merge gate (Issue #634)

- **Issue:** #634 (bug, work mode `full-bug`)
- **Feature folder:** `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/`
- **Branch under analysis:** `bug/cleanup-worktrees-consolidation-pr-merge-gate-634`, branched off
  `origin/epic/cleanup-merged-worktrees-hardening-integration`
- **Timestamp:** 2026-09-06T23-15
- **Epic position:** child G (gap 4) of `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`
- **Autonomous execution:** in scope; see `## Automation Feasibility`

Every line number below was re-derived in this pass by reading the file on this branch. Line counts
were derived with a whole-file line-count scan (ripgrep `^` in count mode) rather than quoted from
any prior document. Where a prior document's number disagrees, the disagreement is recorded.

---

## 0. Summary of load-bearing findings

Five findings drive the recommendation. Each is expanded below with citations.

1. **The prompt's central premise about assurance asymmetry is false.** All three existing accept
   paths already trust a CI conclusion that was recorded by the very agent that then issues the
   merge. A fourth shape would not be "materially weaker"; it would be exactly as strong as shapes 2
   and 3, and *stronger* than shape 1 (which requires no PR-number match at all).
2. **The gate's own header records a deliberate decision not to shell out to `gh`.** Any Option B
   constraint that requires live `gh` or live `git` at decision time contradicts that recorded
   decision and has no precedent: no hook under `.claude/hooks/` or `.codex/hooks/` invokes `git` or
   `gh` at all.
3. **The cleanup skill never claims the agent performs the merge, and cannot perform it.** Step 5 is
   written in the passive voice, `gh pr merge` is absent from the skill's `allowed-tools`, and
   `Bash(gh *)` is absent from both `.claude/settings.json` and `.claude/settings.local.json`. The
   permission layer, not the merge gate, is the first blocker. Option A is therefore a small,
   honest documentation change; Option B is a four-surface change that would additionally require
   widening the skill's tool surface and the project permission allow-list.
4. **Issue #545's committed `spec.md` explicitly excludes `enforce-epic-merge-gate.ps1` from scope
   and carries an acceptance criterion requiring that file to have no diff.** The epic manifest
   asserts the opposite. This contradiction is unresolved on this branch and must be resolved before
   #634 can express a composition boundary against #545.
5. **Option B's `head_sha` is unverifiable by the hook without breaking a standing rule.** Of the
   five candidate binding mechanisms in Q3, only the `pr_number` match (mechanism d) is both
   feasible and consistent with the gate's posture — and it is a consistency check, not an assurance
   that CI ran.

---

## 1. Q1 — Provenance of the three existing accept paths

The gate's three accept branches are implemented in
`.claude/hooks/enforce-epic-merge-gate.ps1`:

| Shape | Checkpoint path constant | Predicate function | Cascade call site |
| --- | --- | --- | --- |
| 1 (child feature) | line 44 | `Test-ChildCheckpointAllowsEpicMerge` (lines 160–187) | lines 383–386 |
| 2 (epic integration) | line 45 | `Test-EpicCheckpointAllowsMerge` (lines 189–245) | lines 388–391 |
| 3 (parallel) | line 46 | `Test-ParallelCheckpointAllowsMerge` (lines 247–308) | lines 393–396 |

### Shape 1 — `orchestrator-state.json`, `epic_mode == true` and `step9_status == "passed"`

**Writer.** The per-feature `orchestrator` agent, acting under
`.claude/skills/orchestrate/SKILL.md`.

**Evidence it sets it on.** `SKILL.md` line 228 has the orchestrator resolve the live head SHA with
`gh pr view --json headRefOid`; line 229 has it invoke
`gh pr checks --required --json bucket,name,state,link,workflow`; line 230 pipes that JSON into
`scripts/orchestration/Invoke-CiGateParser.ps1`; line 232 states the orchestrator writes the
`ci_gate` object and sets `step9_status` to `passed` only when `ci_gate.conclusion == "success"` and
`ci_gate.head_sha` equals the current PR head SHA.

`scripts/orchestration/Invoke-CiGateParser.ps1` lines 13–17 state explicitly: "This script is the
single source of truth for `ci_gate.conclusion` derivation. It does NOT invoke `gh`. The
orchestrator runs `gh` and passes the resulting JSON to this script."

**Same agent that merges?** Yes. `SKILL.md` line 233 (S9 step 6): "If the checkpoint's `epic_mode`
is `true`, execute `gh pr merge --merge <PR>`." The orchestrator that wrote `step9_status: passed`
is the orchestrator that then issues the merge.

**Additional weakness specific to shape 1:** `Test-ChildCheckpointAllowsEpicMerge` (lines 160–187)
takes no `CommandPrNumber` parameter at all. Shape 1 authorizes *any* `gh pr merge --merge`, for
*any* PR number, on the strength of two boolean-ish fields. It is the weakest of the three.

### Shape 2 — `epic-orchestrator-state.json`, `epic_merge_pr.ci_gate.conclusion == "success"`

**Writer.** The `epic-orchestrator` agent. `.claude/skills/epic-orchestrate/SKILL.md` lines 105–111:
"`epic-orchestrator` runs the same S9 CI-green procedure
(`scripts/orchestration/Invoke-CiGateParser.ps1`) directly against this PR, records the result under
the epic checkpoint's `epic_merge_pr` object, then executes `gh pr merge --merge` once green, gated
by `enforce-epic-merge-gate.ps1`."

**Same agent that merges?** **Yes, in one continuous sentence of the skill text.** The
`epic-orchestrator` agent definition `.claude/agents/epic-orchestrator.md` grants
`"Write(artifacts/orchestration/**)"` and `"Edit(artifacts/orchestration/**)"` (lines 13–14) and
`"Bash(gh *)"` (line 16) to the same agent. It writes the conclusion and it runs the merge.

**Validator constraint on the `ci_gate` shape.** There is none. A grep of
`scripts/dev_tools/validate_epic_orchestrator_state.py` for `ci_gate` returns zero matches; the only
`epic_merge_pr` constraint is at lines 391–400, which requires a non-empty
`epic_merge_pr.merge_commit_sha` at completion — a *post*-merge field, not a pre-merge one. So no
validator constrains `epic_merge_pr.ci_gate.conclusion` at all.

### Shape 3 — `parallel-orchestrator-state.json`, `route_id == "parallel"`, item `merge_status == "ci_green"`

**Writer.** The `parallel-orchestrator` agent (the parent).
`.claude/skills/parallel-orchestrate/SKILL.md` lines 318–322: "On child completion, durably confirm
pull-request state and check conclusion with `gh pr view --json state,mergedAt,headRefOid`, and with
`gh pr checks` when the check conclusion must be re-read — never from an in-memory completion
notification — then record `merge_status: ci_green`."

**Same agent that merges?** Yes. The next numbered step, line 322: "Execute
`gh pr merge --merge <PR>` for that item's pull request."

### Verdict on the delegation brief's assertion

The delegation brief states that a fourth shape "would then trust a CI conclusion recorded by the
same agent that wants to merge, which is a materially weaker assurance than the three existing
shapes."

**That assertion is contradicted by the evidence.** All three existing shapes have exactly that
property:

- Shape 1: the child orchestrator records `step9_status: passed` (SKILL.md line 232) and merges
  (line 233).
- Shape 2: `epic-orchestrator` records `epic_merge_pr.ci_gate` and merges (epic-orchestrate SKILL.md
  lines 108–111).
- Shape 3: `parallel-orchestrator` records `merge_status: ci_green` (line 321) and merges (line 322).

The gate is not, and has never been, a separation-of-duties control. Its own header says so — see
Q2. The correct framing for the specification is therefore **not** "a fourth shape is weaker than
the three"; it is "a fourth shape would be exactly as strong as shapes 2 and 3 and stronger than
shape 1, and the whole gate is a *procedure* deterrent, not an *attestation* control." The
specification should make that argument, because the false version of the argument is easy to
falsify at review and would then discredit the surrounding reasoning.

What *does* differ, and is a legitimate concern to state: the three existing writers are
**orchestration agents whose skill text pins a specific verification procedure** and whose
checkpoints are additionally shape-validated at other gates (for example
`.claude/hooks/enforce-completion-consistency.ps1` lines 213–226 require a completion-asserting
checkpoint to carry `ci_gate.conclusion == "success"` and a non-empty `ci_gate.head_sha`, and
`.claude/lib/orchestrator-state/OrchestratorState.psm1` line 93 pins the `step9_status` vocabulary).
A cleanup run has no such surrounding validator ecosystem, so a fourth shape would enter the tree
with a thinner validation perimeter than the other three — a real, statable difference that is about
*ecosystem maturity*, not about who signs the record.

---

## 2. Q2 — The gate's stated design posture

`.claude/hooks/enforce-epic-merge-gate.ps1` lines 29–32, verbatim:

```
    Design decision: this gate trusts the on-disk checkpoint rather than shelling out live
    to gh pr view for a real-time head-SHA check, matching the same non-adversarial,
    policy-level-not-cryptographic posture already accepted for
    enforce-pr-author-skill.ps1's own receipt mechanism. It is not a cryptographic control.
```

Two implications:

1. **A live `gh` or live `git` call at decision time is explicitly the rejected alternative.** Any
   Option B constraint of that form is not a neutral hardening; it reverses a recorded design
   decision and must be argued as such, in this file's header, not smuggled in as an implementation
   detail.
2. **The precedent it cites has a specific, checkable meaning**, examined next.

### What the cited precedent actually verifies

`.claude/hooks/enforce-pr-author-skill.ps1` lines 35–41 state the enforcement strength:

```
    Enforcement strength: the SHA-256 receipt is a policy-level integrity check that binds the
    PR body bytes to the receipt the pr-author agent wrote. It is not a cryptographic or security
    boundary: any actor with Write access to artifacts/ can replace both the body file and the
    receipt together ... It MUST NOT be described as tamper-proof or as a security boundary.
```

The mechanism itself lives in `.claude/hooks/enforce-pr-author-skill-helpers.ps1`,
`Test-PrAuthorReceiptVerification` (lines 29–137). Its six ordered checks:

| # | Lines | What it checks |
| --- | --- | --- |
| 1 | 65–67 | `--body-file` matches the canonical `artifacts/pr_body_<N>.md` pattern, case-sensitively |
| 2 | 74–84 | the sibling `artifacts/pr_body_<N>.receipt.json` exists and parses as JSON |
| 3 | 86–94 | `receipt.number` equals the `<N>` from the path |
| 4 | 96–112 | inline SHA-256 of the body-file **bytes** equals `receipt.sha256` |
| 5 | 114–128 | `receipt.created_at` is strictly newer than the last-write time of `artifacts/pr_context.summary.txt` |
| 6 | 130–134 | under `epic_mode`, `gh pr create` carries a matching `--base` |

**Hash of what, against what.** Check 4 hashes the local body file's bytes and compares against a
value in a local sibling JSON file that the same agent wrote. **It binds no external fact.** It
binds one local artifact to another local artifact. Check 5 is likewise entirely local: it compares
one artifact's recorded timestamp against another artifact's filesystem mtime. Both sides of every
comparison are files the agent can write.

**Conclusion for Option B.** The precedent the merge gate cites is a *local-artifact consistency
mechanism with no external binding whatsoever*. That is the exact ceiling on what an Option B
"constraint that prevents a self-recorded success conclusion" could achieve while remaining
consistent with the family. Any specification wording promising that Option B's constraint
"prevents a self-recorded success conclusion" would be overstating what the mechanism can do; the
honest wording is "makes an accidental or careless self-recording detectable, and makes a
deliberate one a disclosed act."

---

## 3. Q3 — Candidate mechanisms for binding a self-recorded CI conclusion

Evaluated against: (i) what it proves; (ii) hook-verifiable without network; (iii) survivable under
`.claude/rules/powershell.md` determinism rules (lines 69–76: no network, no external services or
live executables; lines 80–84: never mock `git`/`gh` directly, mock the wrapper seam); (iv)
pinnable by Pester.

### (a) `consolidation_pr.head_sha` must equal the tip of local `documentationandmemories`, re-derived by the hook from git

- **Proves:** that the recorded SHA matches a local ref *at hook-decision time*. It does **not**
  prove CI ran, that CI passed, that the SHA is the PR head on GitHub, or that the local ref was not
  moved after the checks were read.
- **Network-free?** Yes for `git rev-parse`; but it requires a subprocess.
- **Precedent:** **none.** A scan of `.claude/hooks/**` and `.codex/hooks/**` for a leading `git` or
  `gh` command invocation returns zero matches. No enforcement hook in this repository launches an
  external process.
- **Determinism rules:** survivable only through a `Invoke-GitExe -GitArgs <string[]>` wrapper seam
  per `.claude/rules/powershell.md` lines 47–50, mocked in tests per lines 80–84. That is mechanical
  and pinnable.
- **Conflicts:** directly reverses the recorded design decision at
  `enforce-epic-merge-gate.ps1` lines 29–32. Also introduces a per-invocation subprocess into a
  PreToolUse hook that currently runs pure in-process logic, on a matcher that fires for **every**
  Bash command (the scope filter at lines 377–379 runs after the payload parse).
- **Additional failure mode:** the hook has no working-directory guarantee. Its checkpoint paths are
  repository-relative bare strings (lines 44–46) and it never resolves a repository root; a
  `git rev-parse` issued from a different CWD would read a different repository. The `.codex` sibling
  had to compute a root explicitly (`.codex/hooks/enforce-epic-merge-gate.ps1` line 127) precisely
  because bare relative paths are unsafe there.
- **Verdict:** feasible but strongly disrecommended. It buys a local-ref consistency check at the
  cost of the gate's stated posture, a new subprocess class in the hook family, and a CWD hazard.

### (b) Hook shells out to `gh pr checks` / `gh pr view` at decision time

- **Proves:** the most, of any candidate — an actual external CI conclusion for an actual PR.
- **Network-free?** **No.** Requires network at hook time.
- **Determinism rules:** the *production* code would require network; the *tests* could still mock
  an `Invoke-GhExe` wrapper and stay deterministic. So the tests survive; the production hook does
  not survive the design posture.
- **Conflicts:** this is the named, explicitly rejected alternative in the hook header (lines 29–32:
  "rather than shelling out live to gh pr view"). It also makes every Bash command in every session
  potentially incur a network round-trip and a new failure mode (rate limit, auth expiry, offline)
  in a gate whose failure mode is a hard deny.
- **Verdict:** reject. Reversing the header decision would need to be its own issue with its own
  argument, applied to all three existing shapes, not a side effect of adding a fourth.

### (c) Receipt artifact carrying a hash over `gh`-produced output

- **Proves:** that a `gh`-shaped blob existed on disk and was hashed by whoever wrote the receipt.
  It does **not** prove the blob came from `gh`, nor that its content is truthful: the same agent
  writes both the blob and the receipt. This is precisely the property established in Q2 for the
  pr-author receipt.
- **Network-free?** Yes, at verification time.
- **Determinism rules:** fully survivable — the existing pr-author suite already demonstrates the
  idiom with injectable byte/text read seams (`Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent` at
  `enforce-pr-author-skill.ps1` lines 67–120).
- **Pinnable by Pester:** yes, directly.
- **Honest characterization:** a **consistency check**, not an assurance. It raises the cost of a
  careless bypass from "edit one field" to "write two coordinated files", and creates a durable
  artifact a human reviewer can inspect after the fact. It proves nothing about CI.
- **Verdict:** the strongest *available* mechanism that is consistent with the family's posture, and
  the only one that adds real forensic value. Its cost is a second artifact contract and a second
  set of read seams inside a hook that has 48 lines of headroom (Q5).

### (d) Recorded `pr_number` must match the command's explicit PR number

- **Proves:** that the checkpoint's authorization is scoped to one PR. It prevents a stale or
  unrelated cleanup checkpoint from authorizing an arbitrary merge. It proves nothing about CI.
- **Network-free?** Yes — pure string/int comparison on already-parsed data.
- **Determinism rules:** trivially satisfied; no new seam at all.
- **Pinnable by Pester:** yes. The existing suite already pins both directions for shape 2
  (`enforce-epic-merge-gate.Tests.ps1` lines 86–96 deny on mismatch; lines 64–72 allow on match) and
  shape 3 (lines 161–171 deny on no-match; lines 136–145 allow on match).
- **Already in use:** yes, by shapes 2 and 3 (`Test-EpicCheckpointAllowsMerge` lines 231–242;
  `Test-ParallelCheckpointAllowsMerge` lines 286–305).
- **Verdict:** mandatory for any fourth shape. It is free, precedented, and it closes the widest
  real-world hole (a stale `artifacts/**` checkpoint — `artifacts/` is gitignored and persists across
  runs, an accepted residual already documented at
  `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` lines 38–46).

**Sub-decision the specification must make explicitly:** shape 3 denies a *bare* `gh pr merge --merge`
with no PR number (`Test-ParallelCheckpointAllowsMerge` lines 279–281, pinned by the test at lines
205–215), whereas shape 2 allows it (lines 228–242, pinned at lines 74–82). A fourth shape should
follow shape 3 and require an explicit PR number, because the consolidation merge is issued from a
dedicated `documentationandmemories` worktree whose "current branch's PR" is not a safe implicit
target.

### (e) Additional mechanisms not in the prompt's list

- **(e1) Branch-name binding.** Require `consolidation_pr.head_branch == "documentationandmemories"`
  and have the hook require the command to name a PR number, refusing the bare form. Proves nothing
  external, but narrows the shape's blast radius to one well-known branch name and makes the
  checkpoint self-describing. Zero cost, zero new seams, fully Pester-pinnable. **Recommended if
  Option B is chosen.**
- **(e2) Freshness binding, by analogy to receipt check 5.** Require
  `consolidation_pr.verified_at` to be strictly newer than the last-write time of a named upstream
  artifact (the `enforce-pr-author-skill-helpers.ps1` check-5 idiom, lines 114–128, via the
  `Get-PrContextSummaryLastWriteUtc` seam at `enforce-pr-author-skill.ps1` lines 122–142). Proves
  ordering between two local artifacts only. Cheap, precedented, adds one read seam. Catches the
  "reused a checkpoint from an earlier cleanup run" case that (d) alone does not fully cover when
  the PR number happens to be reused.
- **(e3) Do nothing in the hook; move the assurance to the skill and a validator.** Add the shape to
  the gate with only (d) + (e1), and put the *procedure* obligation in `SKILL.md` plus a
  checkpoint-shape validator, mirroring how shapes 1–3 get their real discipline (from skill text
  and adjacent validators, not from the merge gate). This matches how the existing three shapes
  actually work.
- **(e4) Rejected outright: any Python leg.** `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
  scans exactly two roots — `.claude/hooks` and `.claude/lib`, excluding `.claude/lib/bash/**`
  (lines 39–42, 64–68) — for four detection classes: a constant interpreter command
  (`python`/`python3`/`py`/`poetry`, lines 112–194), a subprocess start targeting one (lines
  196–234), a dynamic `& $variable` invocation that is not a declared `[scriptblock]` seam or a
  dot-sourced `Join-Path … '<name>.ps1'` sibling load (lines 236–273, 387–449), and
  `Invoke-Expression`/`iex` (lines 275–301). The allowlist is asserted empty (lines 102–109). A new
  `.claude/lib/**` module joins this scan automatically.

### Q3 summary table

| Mechanism | Proves CI ran? | Network-free at hook time? | Survives PS determinism rules? | Pester-pinnable? | Consistent with header posture? |
| --- | --- | --- | --- | --- | --- |
| (a) local git tip match | No | Yes (subprocess) | Yes, via `Invoke-GitExe` seam | Yes | **No** — reverses lines 29–32 |
| (b) live `gh` at decision time | Yes | **No** | Tests yes, production no | Yes | **No** — the named rejected alternative |
| (c) hash-over-`gh`-output receipt | No | Yes | Yes | Yes | Yes |
| (d) `pr_number` match | No | Yes | Yes (no new seam) | Yes | Yes — already in use |
| (e1) branch-name binding | No | Yes | Yes | Yes | Yes |
| (e2) freshness vs. upstream artifact | No | Yes | Yes | Yes | Yes |

**Only (b) proves CI ran, and (b) is the alternative the gate's author explicitly rejected.** Every
mechanism that is compatible with the gate's stated posture is a consistency check. The
specification must say that in those words.

---

## 4. Q4 — Is the merge even in the cleanup skill's tool surface?

**No — twice over.**

**Skill frontmatter.** `.claude/skills/cleanup-merged-worktrees/SKILL.md` `allowed-tools` spans
lines 4–22. The `gh` entry is a single line:

- line 20: `- "Bash(gh issue view *)"`

There is no `gh pr merge` entry, no `Bash(gh *)` wildcard, and no `Bash(gh pr *)` entry. The `git`
entries (lines 11–19) cover `fetch`, `merge-base`, `push`, `rev-parse`, `status`, `log`, `show`,
`diff`, `branch -r`, and `worktree list`. The skill's file is 264 lines.

**Project permissions.** `.claude/settings.json` `permissions.allow` (lines 4–67) contains
`"Bash(git *)"` (line 5), `"Bash(poetry run *)"` (line 6), `"Bash(pwsh *)"` (line 7), and three
specific `bash .claude/lib/bash/*.sh` entries (lines 8–10). **There is no `Bash(gh …)` entry of any
kind.** A grep of `.claude/settings.local.json` for `gh` returns no matches.

**Consequence.** In the main session, `gh pr merge --merge` is not pre-approved by any permission
rule. The user's own approval prompt is the first gate; `enforce-epic-merge-gate.ps1` is the second.
The `epic-orchestrator` agent, by contrast, carries `"Bash(gh *)"` in its own `tools` list
(`.claude/agents/epic-orchestrator.md` line 16), which is why the merge is a live path for shape 2
and not for a cleanup run.

**Step 5's actual prose.** `SKILL.md` lines 105–111:

> 5. **Wait for merge and verify git-natively.** After the consolidation PR merges,
>    verify it with `git fetch` followed by
>    `git merge-base --is-ancestor documentationandmemories main`. Exit 0 confirms every
>    consolidated commit is now reachable from `main`; that is the only state that unlocks
>    deletion of branches whose unique content was consolidated.

The heading is "**Wait for** merge", and the body is passive: "After the consolidation PR merges".
The skill **already does not claim the agent performs the merge**. What it does not do is say who
does, or that the wait is a handoff to a human. It also does not disclose that the wait can be
unbounded within a single session.

**Bearing on Option A's size.** Option A is not a reversal of a claim; it is the completion of an
under-specified sentence. Concretely it is: (i) name the actor in the step-5 heading and first
sentence, (ii) add the human handoff to the step-4/step-5 boundary alongside the existing
`Agent(pr-author)` handoff at lines 96–106, and (iii) optionally add a line to the
`## Prohibited Shortcuts` block (lines 231–251) recording that the skill never issues `gh pr merge`,
in the same register as the existing `gh pr create` prohibition at lines 233–235. That is a
localized edit inside a 264-line file with 236 lines of headroom, plus its byte-identical mirror.
It touches **zero** production code, **zero** tests, and **zero** enforcement surfaces.

---

## 5. Q5 — Line budget and module placement

### Current line counts (derived this pass)

| File | Lines | Headroom to 500 | Prior document's figure |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | **452** | 48 | `issue.md` line 84 and `epic.md` lines 22, 190 say 451 — **off by one** |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | **264** | n/a (Markdown is exempt per `.claude/rules/general-code-change.md`) | `issue.md` line 86 says 264 — correct |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | **455** | 45 | `issue.md` line 88 says 455 — correct |
| `.claude/lib/hook-payload/HookPayload.psm1` | **496** | 4 | not previously stated |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | **419** | 81 | `epic.md` line 190 says 418 — **off by one** |

The two off-by-one figures should be corrected in `spec.md` rather than carried forward, since 48
lines of headroom is the number the plan will budget against.

`HookPayload.psm1` at 496 of 500 lines has effectively **no** headroom: any Option B change that
would touch the shared payload module is structurally excluded.

### Observed `.claude/lib/**` layout and naming convention

Thirty-nine files across nine folders. Excluding `.claude/lib/bash/` (shell), the PowerShell
convention is uniform:

- **Module folder:** lower kebab-case, named for the domain — `blast-radius/`, `codex-routing/`,
  `discovery-validation/`, `hook-payload/`, `mermaid/`, `model-routing/`, `orchestrator-state/`,
  `requirements/`.
- **Module file:** `PascalCase.psm1`, prefixed with the domain's PascalCase name, with concern
  suffixes for split modules — `OrchestratorState.psm1`, `OrchestratorStateCompletion.psm1`,
  `OrchestratorStateCompletionChecks.psm1`, `BlastRadiusGlob.psm1`, `MermaidLineScanner.psm1`.
- **Exported functions:** approved-verb PascalCase, domain-prefixed nouns — for example
  `Resolve-ClaudeHookToolInput`, `Get-ClaudeHookToolInputString`,
  `Get-ClaudeHookPayloadAnomalyReason`, `Read-ClaudeHookRawPayload`, `Invoke-OrchestratorStatePreflight`.
  Export is via a single trailing `Export-ModuleMember -Function` block (`HookPayload.psm1` line 486).
- **Mirrored test path:** `tests/scripts/claude-lib/<same-kebab-folder>/<SameModuleName>.Tests.ps1`,
  with concern splits as sibling files carrying a `.Concern.Tests.ps1` infix — for example
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`,
  `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1`.

### Mandatory module conventions, enforced by test

`tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` discovers every `*.psm1` under
`.claude/lib` from disk (lines 30–33) — a new module cannot escape it — and asserts:

| Obligation | Lines |
| --- | --- |
| `$ErrorActionPreference = 'Stop'` on the line **immediately** after `Set-StrictMode -Version Latest` | 53–67 |
| every column-0 `Import-Module` carries `-ErrorAction Stop` | 69–86 |
| the leading comment-based-help block contains the literal token `imports its siblings with -ErrorAction Stop` | 88–107 |
| importing does not change the caller's `$ErrorActionPreference` | 109–121 |
| the module is at or under 500 lines | 123–136 |

`HookPayload.psm1` lines 36–44 are the canonical worked example of the header + guard shape.

### Recommendation for Option B's decision logic

**Module:** `.claude/lib/cleanup-worktrees-state/CleanupWorktreesState.psm1`
**Test:** `tests/scripts/claude-lib/cleanup-worktrees-state/CleanupWorktreesState.Tests.ps1`

Exported surface, following the observed verb/noun idiom:

- `Get-CleanupWorktreesCheckpointContent` — read seam returning raw text or `$null`
- `ConvertFrom-CleanupWorktreesCheckpoint` — parse, returning `$null` on unreadable content
- `Test-CleanupConsolidationAllowsMerge -Checkpoint <obj> -CommandPrNumber <int?>` — the pure predicate

The hook then gains three lines in the cascade after line 396, mirroring the existing pattern at
lines 383–396, plus one `Import-Module` line near line 42. That fits inside 48 lines of headroom
with margin.

**Why a `.claude/lib` module rather than a dot-sourced sibling `.ps1`:** both idioms exist —
`enforce-pr-author-skill.epic-base-branch.ps1` (104 lines) and `enforce-pr-author-skill-helpers.ps1`
(228 lines) are dot-sourced siblings created for exactly this headroom reason (see that file's
header, lines 13–16). The module route is preferred here because (i) the module is unit-testable in
isolation without dot-sourcing the hook, (ii) it does not add lines to the file #545 also edits (see
Q7), and (iii) the `Invoke-OrchestratorStatePreflight` precedent shows a module-exported function is
still `Mock`-able at hook scope when the hook is dot-sourced
(`tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` lines
30–37).

**Cost of the module route** (all of which the plan must carry):
1. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/cleanup-worktrees-state/CleanupWorktreesState.psm1` — byte-identical mirror (Q6).
2. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — a new entry
   alongside `.claude/lib/hook-payload/HookPayload.psm1` (line 113) and
   `.claude/lib/orchestrator-state/OrchestratorState.psm1` (line 116).
3. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` entry, and its
   mirror at `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
4. The five `ClaudeLibModuleConvention.Tests.ps1` obligations above.
5. The no-Python scan set (it joins `.claude/lib` automatically).

---

## 6. Q6 — Mirror and push-down obligations

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`:

- `SCOPED_ROOTS: tuple[Path, ...] = (Path(".claude"),)` — line 20.
- `list_scoped_files` (lines 39–48) recursively enumerates **every file** under the scoped root.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 106–131) enumerates every
  repo `.claude/**` file, excluding only `.claude/settings.local.json` and `.claude/agent-memory/**`
  (lines 118–122), and asserts for each that it is present in the bundle **and** that
  `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` (lines 128–131).

**Answering the three sub-questions directly:** the mirror scope is *the entire `.claude` tree by
recursive enumeration*, not an enumerated subtree list. Therefore `.claude/lib/**` **is** in scope,
`.claude/hooks/**` **is** in scope, and `.claude/skills/**` **is** in scope. No subtree opt-out
exists except the two named exclusions.

### `.codex/` copy of the merge gate — divergent, not a mirror

`.codex/hooks/enforce-epic-merge-gate.ps1` exists and is **140 lines** against the Claude copy's 452.
It is a separate, smaller implementation:

- functions are `Codex`-prefixed and differently shaped: `ConvertFrom-CodexMergeJson` (line 8),
  `Get-CodexMergeCommandPrNumber` (line 28), `Test-CodexChildMergeReady` (line 39),
  `Test-CodexEpicMergeReady` (line 57), `Invoke-CodexEpicMergeDecision` (line 84);
- it has **no parallel branch at all** — it reads only the child and epic checkpoints (lines
  128–131) and its block reason (line 116) names only two conditions;
- `Test-CodexChildMergeReady` accepts `step9_status` in `@('passed', 'verified')` (line 53), a
  vocabulary the Claude copy does not accept (Claude requires exactly `'passed'`, line 186);
- `Get-CodexMergeCommandPrNumber` (lines 33–36) has only the anchored form, not the broadened
  parallel form the Claude copy added at lines 149–156;
- it resolves a repository root explicitly (line 127) where the Claude copy uses bare relative paths.

The parallel accept branch was added to the Claude copy by issue #492 and was **not** propagated to
the Codex copy. That divergence is already live on `main`, which establishes that the two are not
byte-mirrors of each other and that a Claude-side gate change does not obligate a Codex-side change.
`.codex/hooks/**` has its own pair contract, byte-identity against
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/**`, enforced by
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (per issue #545's `spec.md` D9
table, line 514).

### Exact path lists per change class

**A change to `.claude/hooks/enforce-epic-merge-gate.ps1` requires:**
1. `.claude/hooks/enforce-epic-merge-gate.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` (byte-identical)
3. no `.codex` change (divergent implementation; state this explicitly in `spec.md` as a decision, not an omission)
4. already registered: `.claude/settings.json` line 111; `pack-manifests/core.json` line 29;
   `pester.runsettings.psd1` coverage line 44 — **no new registration needed**

**A new `.claude/lib/cleanup-worktrees-state/CleanupWorktreesState.psm1` requires:**
1. `.claude/lib/cleanup-worktrees-state/CleanupWorktreesState.psm1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/cleanup-worktrees-state/CleanupWorktreesState.psm1` (byte-identical)
3. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (new entry)
4. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (new `CodeCoverage.Path` entry)
5. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (same entry)
6. `tests/scripts/claude-lib/cleanup-worktrees-state/CleanupWorktreesState.Tests.ps1` (new)

**A change to `.claude/skills/cleanup-merged-worktrees/SKILL.md` requires:**
1. `.claude/skills/cleanup-merged-worktrees/SKILL.md`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` (byte-identical)
3. already registered in `pack-manifests/core.json` line 71 — no new registration

Option A's path list is items 1–2 of the third block. That is the entire change.

---

## 7. Q7 — Composition with issue #545 (child E)

### A contradiction on this branch that must be resolved before planning

The delegation brief states that #545 will replace "the two `gh pr merge` detection regexes inside
`Get-EpicMergeGateCommandPrNumber` and the top-level scope guard in `Invoke-EpicMergeGateDecision`".

**#545's committed `spec.md` on this branch says the opposite.** Located at
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`:

- Lines 153–158, under `Out of scope / non-goals`: "**The remaining hook-family members**, to be
  filed as a single follow-up candidate citing this specification and the research:
  `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`,
  `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`, and
  `validate-bash.ps1`. The follow-up covers `gh` and `git` global-option relocation in the merge and
  removal gates."
- Lines 807–810, an **acceptance criterion**: "No out-of-scope hook is modified:
  `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`,
  `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`, and
  `validate-bash.ps1` **carry no diff**."
- Lines 811–813, a further acceptance criterion requiring that a **separate follow-up issue** be
  filed for exactly those gates.
- Its per-hook application table (lines 352–356) lists exactly three hooks:
  `enforce-orchestration-preimplementation-gate.ps1`, `enforce-promotion-mcp-only.ps1`, and
  `enforce-pr-author-skill-helpers.ps1`. The merge gate is not among them.

**The epic manifest asserts the opposite.**
`docs/features/epics/cleanup-merged-worktrees-hardening/epic.md` lines 114–123: "Its recorded scope
is the preimplementation gate's `Test-ImplementationCommand`; the 2026-09-06 run observed the same
defect class in `enforce-epic-merge-gate.ps1` … **Child E extends #545 to cover the gate-hook
instances rather than opening a second issue for the same defect class.**" And lines 132–138 record
the dependency edge: "**D depends on E, and G depends on E.** Child E rewrites how the gate hooks
decide whether a Bash command names a gated command word … both children's new acceptance logic must
sit alongside E's matcher."

**Two further inaccuracies in the epic manifest's supporting text, both verified:**
- epic.md line 120 calls the merge-gate instance "the **unpromoted** potential entry
  `docs/features/potential/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line.md`".
  That file is not at that path and is not unpromoted: it is at
  `docs/features/potential/promoted/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line.md`
  and its lines 1–8 record **Issue #591**, already promoted on 2026-08-29. No
  `docs/features/active/**591**` folder exists on this branch, so #591 is promoted but not yet
  prepared.
- That entry describes a **different defect** from gap 8. Gap 8 (user-context file lines 118–121) is
  the *over-match*: `printf` text mentioning a gated subcommand is denied. Issue #591 (that entry's
  lines 13–15) is a *mis-parse*: the broadened branch at line 154 of the merge gate captures the
  first standalone digit run anywhere in the command line, so
  `cd …\2026-08-29T00-11 && gh pr merge --merge 688` parses PR `2026`. Both live in
  `enforce-epic-merge-gate.ps1`; they are not the same fix.

**Consequence for #634's plan.** The scope boundary between #545 and #634 is *not established* on
this branch. `spec.md` for #634 must not assert it as settled. It must record the contradiction and
require an orchestrator-level resolution before execution begins. Three resolutions are available;
the specification should name them and defer:

- **R-a.** #545's `spec.md` is amended (additively, in its own change) to bring the merge gate into
  scope, and its no-diff acceptance criterion is superseded. #634 then depends on #545 as epic.md
  states.
- **R-b.** #545 ships as specified, and the merge-gate instances are handled by the follow-up issue
  #545's own AC requires — which, given #591 already exists and covers a merge-gate parsing defect,
  probably means folding gap 8's merge-gate instance into #591. #634 then has **no** dependency on
  #545 and can execute in wave 0.
- **R-c.** #634 takes the merge-gate command-word matching itself. **Not recommended** — it would
  violate #545's acceptance criterion at lines 807–810 and expand #634's blast radius from a
  checkpoint-shape question into a command-parsing question.

### Function names and call sites to avoid

If R-a is chosen, #545 (or its successor) owns these locations in
`.claude/hooks/enforce-epic-merge-gate.ps1`:

| Location | Lines | What it is |
| --- | --- | --- |
| `Get-EpicMergeGateCommandPrNumber` | 127–158 | the whole function, including the anchored regex at 146 and the broadened regex at 154 |
| the top-level scope guard | 377–379 | `$commandText -notmatch '(?i)\bgh\s+pr\s+merge\b' -or $commandText -notmatch '--merge\b'` |
| the extractor call site | 381 | `$commandPrNumber = Get-EpicMergeGateCommandPrNumber -CommandText $commandText` |

**#634 owns, and must confine itself to:**

| Location | Lines | Ownership |
| --- | --- | --- |
| checkpoint path constants | 44–46 | add a fourth constant |
| read seams | 48–100 | add a fourth seam (or import one from the new module) |
| accept predicates | 160–308 | add a fourth predicate, modify none |
| the cascade | 383–396 | append a fourth branch after line 396 |
| the block reason | 398 | append a fourth clause |

The boundary is clean and the two sets do not intersect. **#545 owns *whether the gate has fired and
what PR number it saw*; #634 owns *which checkpoints the gate accepts once it has fired*.** The only
shared symbol is `$commandPrNumber` (produced at line 381, consumed at lines 389 and 394 today, and
by a fourth branch tomorrow) — a value flow, not a code collision.

### How #634's plan should express line citations

Because #545 merges into the integration branch first, every line number in this document above
line 127 of the hook will shift. The plan must not cite absolute line numbers into
`enforce-epic-merge-gate.ps1`. Recommended citation discipline for `plan.md`:

1. **Cite by function name and anchor text, never by line number**, for anything inside the hook —
   for example "append a fourth branch immediately after the `Test-ParallelCheckpointAllowsMerge`
   call inside `Invoke-EpicMergeGateDecision`, before the terminal
   `Get-EpicMergeGateBlockDecision` return".
2. **Cite by symbol for the value flow**: "consume `$commandPrNumber` as produced by
   `Get-EpicMergeGateCommandPrNumber`, whatever its post-#545 implementation".
3. **Line numbers are acceptable only for files #545 does not touch** — `SKILL.md`, the runsettings
   files, the pack manifest, and the new module and its test.
4. **Add a re-derivation task at the head of the plan**: after rebasing onto the post-#545
   integration branch, re-derive the hook's line count against the 500-line cap and record it as
   baseline evidence, since #545's masking/relocation work will consume some of the 48-line
   headroom.
5. **Add an explicit assertion task**: after rebase, confirm that
   `Test-ChildCheckpointAllowsEpicMerge`, `Test-EpicCheckpointAllowsMerge`, and
   `Test-ParallelCheckpointAllowsMerge` still exist with their current signatures, and that the
   fourth branch's insertion point is still the terminal return of `Invoke-EpicMergeGateDecision`.

---

## 8. Q8 — Checkpoint-name coordination with child D

### What exists on this branch

A repository-wide grep for `cleanup-worktrees-manifest` and `cleanup-worktrees-state` returns
**five** matches, all in documents; **no code, test, schema, validator, or artifact references
either name.**

| Path | Line | Name referenced |
| --- | --- | --- |
| `docs/features/potential/promoted/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate.md` | 92 | `cleanup-worktrees-state.json` |
| `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/issue.md` | 94 | `cleanup-worktrees-state.json` |
| `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/spec.md` | 90 | `cleanup-worktrees-state.json` |
| `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md` | 67 | `cleanup-worktrees-manifest.json` |
| same file | 80 | `cleanup-worktrees-state.json` |

Both names are therefore **proposals only**. Neither is yet a contract, and no rename cost has been
incurred by either child.

### The two purposes, stated so they cannot be conflated

| | `cleanup-worktrees-manifest.json` (child D, issue placeholder 903, gap 3) | `cleanup-worktrees-state.json` (child G = #634, gap 4) |
| --- | --- | --- |
| **Gated command** | `git worktree remove <path>` | `gh pr merge --merge <PR>` |
| **Gate hook** | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `.claude/hooks/enforce-epic-merge-gate.ps1` |
| **Key** | a filesystem **path** | a pull-request **number** |
| **Record content** | per worktree: the triage verdict and the evidence that produced it (user-context file lines 65–71) | one record: `consolidation_pr: {pr_number, head_sha, ci_gate.conclusion}` |
| **Cardinality** | many records, one per removal target | one record, one consolidation PR per cleanup run |
| **Lifetime** | spans the whole triage pass | written once after `gh pr checks --required` passes |
| **What it authorizes** | destruction of a local worktree directory | a merge into `main` |

They are two different documents keyed on two different things and read by two different hooks. The
`spec.md` for #634 should carry this table verbatim, and should state that a single combined file is
**not** proposed — combining them would make one hook's read seam depend on another child's record
shape and would create the fan-in collision the epic's dependency analysis
(`epic.md` lines 139–147) went out of its way to avoid on the bash surface.

**A naming recommendation for the specification to consider:** `…-manifest.json` and `…-state.json`
differ by one word in the middle of a long filename, and both live in the same
`artifacts/orchestration/` directory. If the orchestrator wants maximum reader separation, name
#634's file for what it authorizes — for example
`artifacts/orchestration/cleanup-consolidation-pr-state.json`. This is a low-cost decision **only
while both names remain unreferenced by code**, which is true today and will stop being true as soon
as either child lands.

### What #634 must not touch

`.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is child D's file and is out of #634's scope.
For the record, its current checkpoint reads are:

- `$script:EpicCheckpointPath = 'artifacts/orchestration/epic-orchestrator-state.json'` — line 63
- `$script:ParallelCheckpointPath = 'artifacts/orchestration/parallel-orchestrator-state.json'` — line 64
- `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')` — line 65

It reads **no** cleanup manifest today. Its header (lines 13–18) documents exactly two accept
branches. Its file is 419 lines (81 lines of headroom). A grep of that file for either proposed
cleanup filename returns no matches.

Its header also carries a passage worth quoting into #634's `spec.md`, because it is the
repository's existing precedent for the stale-checkpoint risk any fourth shape inherits — lines
38–46: "Accepted residual: artifacts/ is gitignored, so the parallel checkpoint persists after a run
ends and a stale document remains readable here." The mitigation there is that worktree paths carry
a session or timestamp component. A cleanup checkpoint keyed on a PR number has no such natural
uniqueness, which is the argument for mechanisms (d), (e1), and (e2) from Q3.

---

## 9. Q9 — Test-surface impact

`tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` is 455 lines: a single top-level
`Describe` at line 8, whose `BeforeAll` (lines 9–12) resolves and **dot-sources** the hook, giving
the tests access to every internal function.

### How the payload is constructed

Every decision test passes a raw JSON string literal directly to `Invoke-EpicMergeGateDecision`
via `-ToolInputRaw`; the nested-envelope form is
`'{"tool_input":{"command":"gh pr merge --merge"}}'` (line 46 and passim). Entry-point tests use the
fuller envelope with `tool_name` (line 436). **No test writes a file, spawns a process, or touches
the network.** One test drives the transport seam with four injected scriptblocks (lines 382–388).

### How the three read seams are mocked

`Mock -CommandName Get-ChildOrchestratorCheckpointContent`,
`Get-EpicOrchestratorCheckpointContent`, and `Get-ParallelOrchestratorCheckpointContent`, each
returning either a JSON string literal or `$null` (first use at lines 42–45). Two `Context` blocks
additionally exercise the seams themselves against a mocked `Test-Path` / `Get-Content` pair with a
`-ParameterFilter` keyed on the script-scoped path variable (lines 232–243 for the parallel seam;
lines 291–313 for the child and epic seams).

### The regression guard — the tests that pin the three existing accept paths

These are the named tests the plan must require to remain **green and unmodified**:

**Shape 1 (child feature):** `Context 'allow via child-feature checkpoint (epic_mode + step9_status passed)'`, lines 40–61
- `It 'allows gh pr merge --merge when the child checkpoint is epic_mode true and step9_status passed'` — lines 41–49
- `It 'denies when the child checkpoint has epic_mode true but step9_status is not passed'` — lines 51–60

**Shape 2 (epic integration):** `Context 'allow via epic-integration checkpoint (ci_gate success + matching PR number)'`, lines 63–83
- `It 'allows gh pr merge <N> --merge when epic_merge_pr.ci_gate.conclusion is success and PR number matches'` — lines 64–72
- `It 'allows a bare gh pr merge --merge (no PR number) when ci_gate.conclusion is success'` — lines 74–82

plus `Context 'deny on non-matching PR number'` (lines 85–97) and
`Context 'deny on non-success ci_gate.conclusion'` (lines 99–111).

**Shape 3 (parallel):** `Context 'allow via parallel-orchestrator checkpoint (route_id parallel + ci_green + matching PR)'`, lines 135–146
- `It 'allows gh pr merge --merge <N> when route_id is parallel and the matched item is ci_green'` — lines 136–145

plus `Context 'deny via parallel-orchestrator checkpoint (fail closed)'` (lines 148–216), whose six
`It` blocks pin non-`ci_green` status (149–159), no-matching-PR (161–171), non-parallel `route_id`
(173–183), absent checkpoint (185–193), malformed checkpoint (195–203), and bare-command deny
(205–215).

**Cross-shape fail-closed guard:** `Context 'deny on missing/unreadable checkpoints (fail closed)'`,
lines 113–133 — both `It` blocks assert deny when checkpoints are absent (114–122) or malformed
(124–132). **These two tests will require modification under Option B**, because they mock only
three seams; a fourth accept path adds a fourth seam that must also be mocked to `$null` for the
assertion to remain a true "no checkpoint satisfies the gate" case. The plan must call this out
explicitly rather than discovering it at execution: it is the one place where "the three existing
accept paths keep behaving identically" and "no test is modified" pull apart.

The same applies to the `BeforeEach` at lines 375–379 in
`Context 'entry-point exit code and emitted decision (AC-4, no child process)'`, which mocks the
same three seams; and to the two `Context 'deny on …'` blocks at lines 85–111, which mock the
parallel seam to `$null` (lines 91, 105) and would need a fourth.

**Helper-level direct-coverage contexts** (unaffected by Option B, additive-only):
`Context 'Test-ParallelCheckpointAllowsMerge helper (direct branch coverage)'` lines 245–289 (nine
`It` blocks); `Context 'Test-ChildCheckpointAllowsEpicMerge helper (direct branch coverage)'` lines
315–334 (four); `Context 'Test-EpicCheckpointAllowsMerge helper (direct branch coverage)'` lines
336–365 (six). `Context 'Get-EpicMergeGateCommandPrNumber extractor (flag-order forms)'` lines
218–230 is **#545's territory** if R-a is chosen.

### Headroom

455 of 500 lines. **45 lines of headroom.** By the density of the existing helper contexts
(`Test-ParallelCheckpointAllowsMerge`'s nine `It` blocks occupy 45 lines, lines 245–289), a fourth
shape's full coverage — a decision-level allow, a decision-level deny per rejected field, the seam
test pair, and a direct-predicate branch-coverage context of comparable size — would need roughly
70–100 lines. **A second test file is required.**

Recommended: `tests/scripts/claude-hooks/enforce-epic-merge-gate.CleanupConsolidation.Tests.ps1`,
following the precedent set by `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` (104
lines), whose header (lines 4–10) records the 500-line-cap split rationale explicitly. If the
decision logic goes into a `.claude/lib` module (Q5), the predicate's own branch coverage lives at
`tests/scripts/claude-lib/cleanup-worktrees-state/CleanupWorktreesState.Tests.ps1` instead, and the
hook-side sibling file only needs the cascade-integration and seam tests — which would likely fit
inside 45 lines. The plan should size this decision deliberately.

---

## 10. Q10 — Coverage-denominator mechanics

### Where the include-list lives

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`:
- `Run.Path = @('scripts', 'tests/powershell', 'tests/scripts')` — line 3
- `CodeCoverage.Enabled = $true` — line 18
- `CodeCoverage.OutputFormat = 'CoverageGutters'` — line 21
- `CodeCoverage.OutputPath = 'artifacts/pester/powershell-coverage.xml'` — line 22
- `CodeCoverage.Path = @( … )` — opens at line 23. It is an **explicit per-file allow-list**, a fact
  the file itself repeats in comments at lines 159, 199, 222, 229, and 237.
- `.claude/hooks/enforce-epic-merge-gate.ps1` is already listed, at **line 44**.
- `.claude/lib/**` modules are listed the same way — `.claude/lib/model-routing/ModelRouting.psm1`
  at line 66, `.claude/lib/orchestrator-state/OrchestratorState.psm1` at line 70.

The mirror is `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
Both must be updated for any new file (issue #545's `spec.md` D9 table, line 519, states the same
obligation).

### The environment defect

`mcp__drm-copilot__run_poshqc_test` instruments coverage from the **installed VS Code extension's**
copy of the runsettings, not from either in-repo copy. A `CodeCoverage.Path` entry added in this
change is therefore invisible to the MCP runner — the file is silently **absent** from the report
rather than reported at zero. Documented at
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-selfhosted-coverage.2026-08-25T13-37.md`
lines 17–24.

### The concrete self-hosted invocation the plan must record

```powershell
Import-Module "./scripts/powershell/PoshQC/PoshQC.psd1" -Force
Invoke-PoshQCTest -Root (Get-Location).ProviderPath `
  -SettingsPath "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
```

- **Module path:** `scripts/powershell/PoshQC/PoshQC.psd1`
- **Command:** `Invoke-PoshQCTest`, with `-Root` bound to the resolved provider path of the current
  location and `-SettingsPath` bound to the **in-repo** runsettings so that file is authoritative.

Two extraction facts the plan must carry, both from that same artifact:
- The console line "`Covered 95.65% / 0%`" is Pester's **command** coverage, not line coverage
  (lines 42–44). The 85% threshold is a **line** threshold and must be computed from the JaCoCo
  `counter[@type='LINE']` elements.
- Per-file line coverage must be selected from the `sourcefile` element **within the enclosing
  `package` element** whose name ends with the file's directory, not by bare filename (lines 48–53).
  For #634 this matters if `.claude/hooks/` and `.codex/hooks/` both carry a file of the same name —
  which they do for `enforce-epic-merge-gate.ps1`, though only the Claude side is in the coverage
  list today.

Delete `artifacts/pester/powershell-coverage.xml`, `powershell-coverage.koverage.xml`, and
`pester-junit.xml` before the run so freshness is provable (that artifact's lines 26–31).

---

## 11. Behavior semantics

Derived from the issue statement and the surrounding contracts, stated so either option can be
tested against it.

### Success conditions

**Under Option A:**
- A reader of `SKILL.md` step 5 can determine, without reading the hook, who performs the
  consolidation merge and that the skill's own session does not.
- The skill run reaches step 6 (`--apply`) after the human merge, with the existing git-native
  verification (`git merge-base --is-ancestor documentationandmemories main`, lines 108–109)
  unchanged as the unlock condition.
- No behavior of `enforce-epic-merge-gate.ps1` changes; `EPIC_MERGE_GATE_BLOCKED` remains the
  outcome for any agent-issued consolidation merge, and that outcome is now documented rather than
  surprising.

**Under Option B:**
- With `artifacts/orchestration/<cleanup-checkpoint>.json` present, carrying
  `consolidation_pr.ci_gate.conclusion == "success"` and a `pr_number` equal to the number named in
  the command, `gh pr merge --merge <N>` is allowed.
- Every existing accept path returns the same decision it returns today for every input in the
  existing suite.
- Every existing deny remains a deny.

### Failure conditions (Option B; the gate must fail closed on each)

1. checkpoint absent
2. checkpoint present but unparseable JSON
3. `consolidation_pr` key absent, or null
4. `ci_gate` absent, or null
5. `ci_gate.conclusion` absent, or any value other than exactly `"success"`
6. `pr_number` absent
7. `pr_number` non-numeric
8. `pr_number` present and numeric but not equal to the command's PR number
9. the command names **no** PR number (bare `gh pr merge --merge`) — deny, following shape 3's rule
   at lines 279–281, not shape 2's at lines 228–242
10. (if mechanism e1 is adopted) `head_branch` absent or not `documentationandmemories`

### Ordering rules

- The fourth branch is evaluated **last**, after the parallel branch at lines 393–396 and before the
  terminal block return at line 398. Appending preserves the existing three branches' short-circuit
  order exactly, so no existing decision can change: a checkpoint that authorizes today still
  authorizes at the same branch index.
- Within the fourth predicate, evaluate in the same order the sibling predicates use: null check,
  property-presence check, value check, then PR-number match (compare
  `Test-EpicCheckpointAllowsMerge` lines 211–244).

### Edge cases

- **Stale checkpoint.** `artifacts/` is gitignored; a cleanup checkpoint survives the run that wrote
  it. Mechanisms (d), (e1), (e2) from Q3 are the mitigations. The residual must be documented in the
  hook header in the same register as
  `enforce-epic-worktree-removal-gate.ps1` lines 38–46.
- **Two checkpoints simultaneously.** A cleanup run inside an epic worktree could have both an epic
  and a cleanup checkpoint on disk. Because branches are ORed and evaluated in order, the epic branch
  would authorize first. That is not a new hole (it is authorization the gate already grants), but
  the specification should note it so a reviewer does not read the fourth branch as the cause.
- **PR number reuse.** GitHub PR numbers are monotonic per repository, so a stale cleanup checkpoint
  cannot collide with a *future* PR number — only with the same PR, re-merged. Mechanism (e2)
  covers the residual.
- **The `--merge` scope filter.** Line 377 requires both `gh pr merge` and `--merge`. A consolidation
  merge issued with `--squash` or `--rebase` is outside this gate entirely and is allowed today
  (pinned by the test at lines 27–31). The specification should decide whether the cleanup skill's
  documented merge method is `--merge`; if it is not, Option B solves a problem the skill does not
  have.

---

## 12. Requirements mapping — proposed design under each option

### Option A design

| Change | File | Nature |
| --- | --- | --- |
| Name the actor and disclose the handoff in step 5 | `.claude/skills/cleanup-merged-worktrees/SKILL.md`, End-to-End Workflow item 5 (currently lines 105–111) | prose |
| Record that the skill never issues `gh pr merge`, and why | same file, `## Prohibited Shortcuts` (currently lines 231–251), alongside the existing `gh pr create` prohibition at lines 233–235 | prose |
| Cross-reference the gate | same file, `## Cross-References` (currently lines 253–264) | prose |
| Byte-identical mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | copy |

No state model. No enforcement change. No new test file. The verification surface is
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(lines 106–131) plus a manual read-through.

### Option B design

**State model.** One new document, `artifacts/orchestration/<cleanup-checkpoint>.json`:

```jsonc
{
  "consolidation_pr": {
    "pr_number": 0,
    "head_sha": "<sha>",
    "head_branch": "documentationandmemories",   // mechanism e1
    "verified_at": "<iso8601>",                  // mechanism e2
    "ci_gate": { "conclusion": "success" }
  }
}
```

**Transitions.** Absent → written once by the skill after `gh pr checks --required` reports all
required checks passing on the consolidation PR. There are no intermediate states: the gate reads
one terminal shape or denies.

**Required file changes** (paths and registration duties per Q6):

1. `.claude/lib/cleanup-worktrees-state/CleanupWorktreesState.psm1` (new; conventions per Q5)
2. `.claude/hooks/enforce-epic-merge-gate.ps1` — one `Import-Module` line, one path constant, a
   fourth cascade branch, an amended block reason at line 398
3. `.claude/skills/cleanup-merged-worktrees/SKILL.md` — add the checkpoint-write step between the
   current steps 4 and 5; add `gh pr checks` and the merge invocation to `allowed-tools`
4. `.claude/settings.json` — a `Bash(gh pr merge *)` and `Bash(gh pr checks *)` allow entry, or an
   explicit decision to leave the merge requiring interactive approval (Q4). **This is a permission-
   surface widening that the framing of Option B as "removes the human step" depends on and that
   neither the issue nor the epic currently acknowledges.**
5. both byte-identical `.claude/**` bundle mirrors
6. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
7. both `pester.runsettings.psd1` copies
8. `tests/scripts/claude-lib/cleanup-worktrees-state/CleanupWorktreesState.Tests.ps1` (new)
9. `tests/scripts/claude-hooks/enforce-epic-merge-gate.CleanupConsolidation.Tests.ps1` (new)
10. `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` — the fourth-seam mock additions
    identified in Q9

Ten files against Option A's two, across four surfaces (hook, library, skill, permissions), plus a
permission widening.

---

## 13. Testing implications

No test code is proposed here; this is the strategy the plan should adopt.

**Common to both options**
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` must pass in the same
  change (Q6). Under Option A this is the only automated gate that observes the change.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` must pass; under
  Option B a new `.claude/lib` module joins its scan set automatically (Q3-e4).
- Full PoshQC loop, format → analyze → test, restarting from format on any auto-fix
  (`.claude/rules/powershell.md` line 20).

**Option A specific**
- Fail-before is structurally impossible: the defect is an omission in prose, and there is no
  assertion that can fail on it today. Per
  `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` lines 93–143, the plan must record a
  **fail-before exception dossier** at
  `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/regression-testing/fail-before-exception.<timestamp>.md`
  carrying `WhyFailingRunImpossible` and an alternative proof section, rather than fabricating a
  failing run.
- Manual validation: a read-through recording that step 5 now names its actor, plus the push-down
  parity run, under `evidence/qa-gates/`.

**Option B specific**
- **Regression guard, fail-before.** An `It` asserting that
  `gh pr merge --merge <N>` with only a cleanup checkpoint present is **allowed**, recorded failing
  before the change under `evidence/regression-testing/`.
- **Deny preservation.** Every `It` named in Q9's regression-guard list must pass. The two
  `Context 'deny on missing/unreadable checkpoints (fail closed)'` blocks and the entry-point
  `BeforeEach` will gain a fourth `$null` mock; that diff must be shown to be seam-mocking only, with
  no assertion changed.
- **Fourth-predicate branch coverage**, one `It` per failure condition 1–10 in section 11, following
  the density and naming style of `Context 'Test-ParallelCheckpointAllowsMerge helper (direct branch
  coverage)'` (lines 245–289).
- **Seam tests** for the new read seam mirroring lines 232–243 (mocked `Test-Path` false → `$null`;
  mocked `Test-Path` true plus mocked `Get-Content` → the content), with `-ParameterFilter` keyed on
  the script-scoped path variable.
- **Coverage** at >= 85% line on the changed hook and the new module, measured through the
  self-hosted invocation in Q10, with the baseline for
  `.claude/hooks/enforce-epic-merge-gate.ps1` captured **before** the change (it is already in the
  denominator at runsettings line 44, so a real delta is computable) and the new module recorded as
  "no baseline — newly in the denominator".
- **Line-cap evidence** re-derived after the post-#545 rebase (Q7 citation discipline item 4).

---

## Automation Feasibility

**Autonomously executable end to end:** yes for Option A; yes with named exceptions for Option B.

| Step | Autonomous? | Notes |
| --- | --- | --- |
| Read all cited files, re-derive line numbers | Yes | Read/Grep/Glob only |
| Option A: edit `SKILL.md` + mirror | Yes | two `Edit`/`Write` operations under `.claude/**`; note that `.claude/` paths are not pre-approvable in `permissions.allow`, so each write surfaces an approval prompt |
| Option B: author the new `.claude/lib` module and both mirrors | Yes | same approval caveat |
| Option B: edit the hook | Yes | same caveat; **must be sequenced after #545 merges** (Q7) |
| Registration edits (pack manifest, both runsettings) | Yes | ordinary file edits outside `.claude/**` for the runsettings mirror |
| PoshQC format/analyze/test via MCP | Yes | `mcp__drm-copilot__run_poshqc_*` are in `permissions.allow` lines 14–17 |
| Self-hosted coverage run (Q10) | Yes | `Bash(pwsh *)` is allowed (settings.json line 7); the invocation is `Import-Module` + `Invoke-PoshQCTest`, no network |
| Push-down parity pytest | Yes | `Bash(poetry run *)` allowed (line 6) |
| **Resolving the #545 scope contradiction (Q7)** | **No** | requires an owner decision among R-a / R-b / R-c; it changes another child's committed acceptance criteria |
| **Choosing between Option A and Option B** | **No** | the issue names it as a decision for `spec.md`; it is a policy judgment about widening an enforcement allow-side |
| **Option B: widening `.claude/settings.json` permissions to pre-approve `gh pr merge`** | **No** | widening the project permission allow-list for a merge command is an owner decision, and `.claude/**` writes are not pre-approvable |
| **Option B: the checkpoint filename decision vs. child D (Q8)** | **No** | a cross-child naming decision; cheap now, expensive after either child lands |

**Human-interaction points, enumerated:** four, all listed above. Everything else in either option is
mechanically executable by an agent with the repository's standing tool grants.

**Blocking sequence dependency:** if R-a is chosen in Q7, #634's hook edit cannot begin until #545
has merged into `epic/cleanup-merged-worktrees-hardening-integration` and this branch has been
rebased onto it, because the insertion point and the surrounding line budget both move. Option A has
no such dependency and could execute in wave 0 today.

---

## 14. Recommendation

### Recommended: **Option A — document the consolidation merge as human-performed.**

### The three findings that drive it

1. **The premise that Option B "removes the human step" does not survive Q4.** `gh pr merge` is
   absent from the skill's `allowed-tools` (`SKILL.md` lines 4–22, whose only `gh` entry is
   `Bash(gh issue view *)` at line 20) **and** absent from `.claude/settings.json`
   `permissions.allow` (lines 4–67) **and** absent from `.claude/settings.local.json`. Option B as
   scoped in the issue changes only the *second* of three gates. To actually reach unattended
   execution it must additionally widen the skill's tool surface and the project permission
   allow-list — a larger and more consequential widening than the one the issue describes, and one
   the issue does not mention. The honest comparison is therefore two files versus ten files plus a
   permission widening, not "one hook branch versus a paragraph."

2. **No available constraint can do what Option B's stated rationale requires.** The issue says "the
   constraint that prevents a self-recorded success conclusion must be stated and pinned by tests."
   Q3 establishes that of six candidate mechanisms, only live `gh` at decision time proves CI ran,
   and that mechanism is the one the gate's own header explicitly rejected (lines 29–32). Every
   posture-compatible mechanism is a local-artifact consistency check, which is exactly what the
   cited pr-author receipt precedent turns out to be (Q2: it hashes a local file against a local
   sibling file and binds no external fact). Option B can be built honestly, but it cannot be built
   to the standard its own rationale sets, and a specification that claimed otherwise would not
   survive review.

3. **Option A is smaller than the issue assumes, because the skill never made the claim.** Step 5's
   heading is "**Wait for** merge" and its body is passive ("After the consolidation PR merges",
   `SKILL.md` line 105). Option A does not retract a claim; it names an actor in a sentence that
   already implied one. The cost the issue attributes to Option A — "an unautomatable step in every
   cleanup run" — is a cost the repository is *already paying* and will keep paying under Option B
   unless the permission allow-list is also widened.

Two supporting considerations, not decisive on their own but pointing the same way:

- **Sequencing.** Option B's hook edit is blocked behind an unresolved contradiction between #545's
  committed `spec.md` (which requires `enforce-epic-merge-gate.ps1` to carry **no diff**, lines
  807–810) and `epic.md` (which says child E rewrites the gate hooks, lines 114–123, 132–138).
  Option A has no dependency on #545 at all and could land in wave 0.
- **Budget.** The hook has 48 lines of headroom, its test file has 45, and both will be consumed in
  part by #545 if R-a is chosen. Option B's cascade branch fits, but its test surface does not, so a
  second test file plus a lib module plus two runsettings entries plus a pack-manifest entry become
  mandatory (Q5, Q9).

### What would change the recommendation

- **If the owner intends the cleanup skill to run unattended in a consumer repository**, Option A is
  a permanent stall in an otherwise autonomous workflow, and Option B becomes correct — but it must
  then be scoped to include the skill `allowed-tools` change and the `.claude/settings.json`
  permission entry, which the current issue text does not cover. That expanded Option B should be
  the specification's proposal, not the narrow one.
- **If the epic's leading indicator "the merge is unattended" is load-bearing for the epic's
  business outcome** (`epic.md` line 13 says the run should be carried "through report, apply,
  consolidation, and merge without hand-written scripts, manual consolidation commits, or hook
  workarounds" — merge is named explicitly), then Option A leaves the epic's own stated outcome
  partially unmet, and Option B is the consistent choice. **This is the single strongest argument
  against the recommendation above, and the specification must confront it rather than omit it.**
  The counter is that a *documented, disclosed* human merge is not a "hook workaround" — it is the
  opposite — but that is an interpretive reading of the epic's wording, and the epic's author should
  settle it.
- **If mechanism (c) or (e2) from Q3 is judged sufficient by the owner** — that is, if a
  local-artifact consistency check with a durable forensic trail is accepted as adequate for a
  merge-authorizing record — then the second driving finding loses its force and Option B becomes
  defensible on the merits.
- **If #545's scope contradiction resolves as R-b** (merge gate stays out of #545), the sequencing
  objection to Option B disappears entirely and #634 could execute in wave 0 either way.

### Contradictions against premises stated in the delegation prompt

Reported explicitly, per the prompt's instruction:

1. **"a fourth shape would trust a CI conclusion recorded by the same agent that wants to merge,
   which is a materially weaker assurance than the three existing shapes"** — **false.** All three
   existing shapes have that property (Q1). Shape 1 is additionally weaker than any proposed fourth
   shape, because it requires no PR-number match at all
   (`Test-ChildCheckpointAllowsEpicMerge`, lines 160–187, takes no PR-number parameter).
2. **"Issue #545 is concurrently replacing … the two `gh pr merge` detection regexes … and the
   top-level scope guard in `Invoke-EpicMergeGateDecision`"** — **contradicted by #545's committed
   `spec.md` on this branch**, which lists `enforce-epic-merge-gate.ps1` as out of scope (lines
   153–158) and carries an acceptance criterion requiring it to carry **no diff** (lines 807–810).
   The epic manifest asserts the opposite (lines 114–123). Unresolved (Q7).
3. **`.claude/hooks/enforce-epic-merge-gate.ps1` is "451 lines"** — it is **452**. Also
   `enforce-epic-worktree-removal-gate.ps1` is **419**, not the 418 recorded at `epic.md` line 190.
   `SKILL.md` at 264 and the test file at 455 are correct as previously recorded (Q5).
4. **The epic manifest calls
   `2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line.md` an "unpromoted potential
   entry"** — it is under `docs/features/potential/promoted/` and records **Issue #591**, promoted
   2026-08-29. It also describes a *different* defect (unanchored PR-number capture) from gap 8
   (over-match on quoted text) (Q7).
