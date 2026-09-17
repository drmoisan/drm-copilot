# False-Approval Elimination — pr-author Readiness Gate (3.2) and Model-Routing Receipt (3.4)

- Feature: `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/`
- Issue: #673 (epic `worktree-scoped-state-resolution`, feature F5, wave 1, depends_on F1)
- Researched: 2026-09-13
- Workspace: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ac200a44665297faa`
- Branch: `worktree-agent-ac200a44665297faa` (fast-forwarded to `origin/epic/worktree-scoped-state-resolution-integration`)

---

## 0. BLOCKING LIMITATION — DEFECTS 3.2 AND 3.4 WERE **NOT** REPRODUCED BY DIRECT EXECUTION

**State this plainly and do not let it be softened downstream: this research did not observe either
gate returning `allow`. Neither defect has yet been reproduced by direct test.**

### What was attempted

The delegation required constructing a two-checkpoint fixture under
`C:/Users/DANMOI~1/AppData/Local/Temp/claude/`, invoking each hook with `pwsh` from a "session root"
cwd with a payload pertaining to a different "item worktree", and recording the decision, exit code,
stdout, and stderr.

### The blocking obstacle

**This agent session was provisioned with no command-execution tool.** The complete tool set
available was `Read`, `Grep`, `Glob`, `WebFetch`, `Write`, `Edit`. There is no `Bash` tool, no
PowerShell tool, and no other process-launch capability. Consequently:

- No `pwsh` process could be started, so neither hook could be invoked.
- No fixture directory could be created (fixture creation would require `mkdir`/`New-Item`; `Write`
  can create files but writing fixture files was pointless without an interpreter to consume them,
  and creating scratch files with no way to execute them adds no evidence).
- No `diff`, `wc -l`, `Get-FileHash`, or `git` command could be run, so every count and every
  identity claim in this document is derived from file reads and content search only.

This is an environment limitation, not a property of the defect. The reproduction procedure is fully
specified in §1.5 and §2.4 below and is directly executable by any agent or operator that has `pwsh`.

### What this means for the plan

Per the delegation's own rule — *"A mechanism we have not observed failing must not be 'fixed' on the
strength of a report alone"* — the plan MUST carry reproduction as its **first executable step**, and
the recorded `allow` decision (with exit code and stdout) MUST be archived as baseline evidence under
`docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/`
before any hook file is edited. If reproduction fails, the fix must not proceed as specified.

### Confidence in the static case, stated honestly

The static trace below is complete and end-to-end, and it identifies the exact binding sites, the
exact call sites where the defaults bind, and the exact runtime condition (§1.4) that makes the
session root the hook process's cwd. On that evidence the defect mechanism is **established with high
confidence for 3.2 and for 3.4**, but "established by code reading" is categorically weaker than
"observed allowing", and the delegation asked for the latter. Treat §1 and §2 as a *reproduction
script with a predicted outcome*, not as the reproduction itself.

---

## 1. R1 — Defect 3.2: end-to-end checkpoint resolution trace for the pr-author gate

### 1.1 Which of the three files carries the defect

| file | `wc -l` | carries a cwd-relative checkpoint binding? | role |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 311 | **YES** — line 49 | binds `$script:OrchestratorStateCheckpointPath` |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 260 | **NO** | *consumes* the variable at line 240; defines no literal |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 115 | **YES** — line 35 | a **second, independent** relative binding |

The issue report and the epic manifest both name only `enforce-pr-author-skill.ps1:49`. **That is
incomplete.** `enforce-pr-author-skill.epic-base-branch.ps1:35` is a second, structurally
independent cwd-relative binding on the same decision path, and it is reached through a different
mechanism (a parameter default bound at an argument-less call site rather than a script-scoped
variable). A fix that changes only line 49 leaves the epic base-branch check reading the session
root's checkpoint. This is the single most important correction this research makes to the issue's
root-cause analysis.

### 1.2 Trace A — the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` path (the readiness gate proper)

1. `.claude/hooks/enforce-pr-author-skill.ps1:49`
   ```powershell
   $script:OrchestratorStateCheckpointPath = 'artifacts/orchestration/orchestrator-state.json'
   ```
   A bare relative literal at script scope. Nothing anywhere in the three files reassigns it.

2. `.claude/hooks/enforce-pr-author-skill.ps1:150-191` — `Invoke-PrAuthorSkillDecision` parses the
   envelope (`:170`), extracts `tool_input.command` (`:178`), probes the PR-context artifact
   (`:183`), and calls `Get-PrAuthorBypassReason` (`:184`).

3. `.claude/hooks/enforce-pr-author-skill-helpers.ps1:239-249` — on the `--body-file` +
   context-present path:
   ```powershell
   $preflightResult = Invoke-OrchestratorStatePreflight -CheckpointPath $script:OrchestratorStateCheckpointPath
   ```
   The relative string is passed through verbatim.

4. `.claude/lib/orchestrator-state/OrchestratorState.psm1:401-486` —
   `Invoke-OrchestratorStatePreflight` invokes `& $Invoker $CheckpointPath` (`:471`).

5. **The `$Invoker` seam (`OrchestratorState.psm1:430-468`) introduces NO additional cwd
   dependence and starts no subprocess.** It is a pure in-process PowerShell scriptblock. It
   lazily imports `OrchestratorStateUnconditional.psm1` (`:437-439`) only if
   `Get-OrchestratorStateUnconditionalError` is not already defined, then calls
   `Get-OrchestratorStateCheckpoint -CheckpointPath $Path` (`:442`) and
   `Test-OrchestratorStatePrCreationReadiness -CheckpointPath $Path` (`:455`). Both forward `$Path`
   unchanged.

6. `.claude/lib/orchestrator-state/OrchestratorState.psm1:163` — the terminal filesystem touch:
   ```powershell
   if (-not (Test-Path -LiteralPath $CheckpointPath -PathType Leaf)) { ... }
   ```
   followed by `Get-Content -LiteralPath $CheckpointPath -Raw` (`:171`). `Test-Path` and
   `Get-Content` resolve a relative path against the **PowerShell provider location** (`$PWD`),
   which for a freshly launched `pwsh -NoProfile -File …` equals the process working directory.

**Conclusion for trace A: the checkpoint that is validated is `<process cwd>/artifacts/orchestration/orchestrator-state.json`, unconditionally, with no reference to the `gh pr create` command's target branch, worktree, or feature folder.**

There is a **latent fourth binding** at `OrchestratorState.psm1:427`
(`[string] $CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'`). It is **not
reached from this hook**, because helpers:240 always passes `-CheckpointPath` explicitly. It is
recorded here because it would silently become live if a future edit dropped the explicit argument.
The plan should add a regression guard for that.

### 1.3 Trace B — the `EPIC_BASE_BRANCH_MISMATCH` path (the second, undocumented binding)

1. `.claude/hooks/enforce-pr-author-skill-helpers.ps1:136` — `Test-PrAuthorReceiptVerification`
   check 6 calls `Test-EpicBaseBranchOverride -CommandText $CommandText`.
2. `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:78` —
   ```powershell
   $checkpointRaw = Get-PrAuthorCheckpointContent
   ```
   **Called with no arguments.** The parameter default therefore binds.
3. `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:35` —
   ```powershell
   [string] $CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'
   ```
4. `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:38-42` — `Test-Path -LiteralPath` /
   `Get-Content -LiteralPath` against the same cwd-relative path.

The failure shape here is worse than a plain false approval, because the check is **fail-open by
design**: `:79-81` returns `$null` (allow) on an absent/blank checkpoint, and `:83-87` returns
`$null` on unparseable JSON, and `:90-92` returns `$null` when `epic_mode` is absent/false. So in an
epic topology where the item's own checkpoint has `epic_mode: true` but the session root's sibling
checkpoint has `epic_mode: false` (or is a parallel checkpoint with no `epic_mode` key at all), the
epic base-branch requirement is silently skipped and `gh pr create --base main` is allowed for a PR
that should have been targeted at the integration branch. That is a distinct, second false approval
in the same hook family.

### 1.4 Why the hook process's cwd is the SESSION ROOT, not the item worktree

This is the load-bearing runtime fact and it is verifiable statically.

`.claude/settings.json:101-104` wires the hook as:
```json
{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-pr-author-skill.ps1" }
```

The script path is **relative**. A relative `-File` argument only resolves if the launching process's
working directory is the repository/session root. Therefore the hook process is launched with
cwd == session root by construction, and `$PSScriptRoot` == `<session root>/.claude/hooks`. The same
is true of `enforce-model-routing-receipt.ps1` (`.claude/settings.json:191-194`).

The command the hook is gating, by contrast, frequently operates on a *different* directory: the
repository's own gates document `cd <worktree> && gh pr merge …` command shapes
(`.claude/hooks/enforce-epic-merge-gate.ps1:148`) and the parallel skill prescribes
`git -C <worktree_path> …` forms throughout
(`.claude/skills/parallel-orchestrate/SKILL.md:351-364`). The `cd`/`-C` takes effect **inside** the
Bash command, i.e. *after* PreToolUse has already decided. The gate therefore evaluates the session
root while the command acts on the worktree.

### 1.5 The two-checkpoint condition in this repository's topologies

`.claude/skills/parallel-orchestrate/SKILL.md:484` establishes that the parallel orchestrator writes
its own checkpoint to `artifacts/orchestration/parallel-orchestrator-state.json`, a **different
filename**. Each item's per-feature checkpoint keeps the name
`artifacts/orchestration/orchestrator-state.json` inside that item's own worktree.

That is precisely the sibling-collision condition: at the session root,
`artifacts/orchestration/orchestrator-state.json` is *not* the parallel orchestrator's file — it is
whatever previous single-feature run left behind there (in the reported incident, issue 838's). It is
a live, satisfactory-looking, completely unrelated checkpoint sitting at exactly the path the gate
reads.

### 1.6 Reproduction procedure for 3.2 (executable; not yet executed)

```
<scratch>/session-root/
  artifacts/orchestration/orchestrator-state.json   # sibling item A; ready; epic_mode absent
  artifacts/pr_context.summary.txt                  # any content; older than the receipt
  artifacts/pr_body_1.md                            # any bytes
  artifacts/pr_body_1.receipt.json                  # number=1, sha256 of the body, created_at newer
<scratch>/item-worktree/
  artifacts/orchestration/                          # EMPTY — item B has no checkpoint
```

The sibling checkpoint must satisfy `Test-OrchestratorStatePrCreationReadiness`: all 22
`REQUIRED_STATE_KEYS` (`OrchestratorState.psm1:38-61`) present, `step5_status`..`step8_status` not in
`{pending, blocked, blocked_remediation_loop_limit}`, `blocked_reason` `none` or absent, and
`local_execution_overrides` / `delegation_bypasses` empty or absent. It must also satisfy the
U-family unconditional block in `OrchestratorStateUnconditional.psm1`.

Invocation (note the hook must be invoked by **absolute** path while cwd is the session root, because
this fixture has no `.claude/` tree of its own):

```powershell
Push-Location <scratch>/session-root
'{"tool_name":"Bash","tool_input":{"command":"cd <scratch>/item-worktree && gh pr create --title \"B\" --body-file artifacts/pr_body_1.md"}}' |
  pwsh -NoProfile -File <repo>/.claude/hooks/enforce-pr-author-skill.ps1
$LASTEXITCODE
Pop-Location
```

**Predicted (unverified) result:** `permissionDecision: allow`, exit code `0`, no
`ORCHESTRATOR_STATE_PREFLIGHT_FAILED` text — a green derived entirely from item A's checkpoint while
item B has none. Record stdout, stderr, and `$LASTEXITCODE` verbatim.

A **`Push-Location` caveat that will bite the test author:** `Push-Location` changes `$PWD` but does
**not** change `[Environment]::CurrentDirectory`. `Test-Path`/`Get-Content` follow `$PWD`;
`[System.IO.File]::ReadAllBytes` at `enforce-pr-author-skill.ps1:92` follows
`[Environment]::CurrentDirectory`. In an out-of-process invocation (as above) they agree. In an
**in-process** Pester test that uses `Push-Location`, they diverge and the body-file read will hit
the wrong directory. Prefer the out-of-process form, or set both.

---

## 2. R2 — Defect 3.4: `enforce-model-routing-receipt.ps1`

### 2.1 The presence-only gating contract that MUST be preserved exactly

Confirmed from `.claude/rules/orchestrator-state.md:107`:

> "The PreToolUse deterrent (`.claude/hooks/enforce-model-routing-receipt.ps1`) performs
> presence-only gating before a delegation."

and from the hook's own header (`enforce-model-routing-receipt.ps1:11-15`): it cannot read the
delegate's chosen `model` because no `model` field is exposed in the tool input, so it verifies only
that a `model_routing_receipts[]` entry already exists for the target `subagent_type`. Correctness of
the recorded model stays with the authoritative Python validator (which runs elsewhere, not in this
hook). `.claude/skills/orchestrate/SKILL.md:175` repeats this.

### 2.2 Exactly what the hook checks today (the behaviour the fix must not alter)

`Invoke-ModelRoutingReceiptDecision` (`enforce-model-routing-receipt.ps1:120-169`), in order:

1. `:136-147` — envelope anomaly ⇒ **deny** `MODEL_ROUTING_RECEIPT_BLOCKED: payload anomaly - …`
   (fail closed).
2. `:149` — extract `tool_input.subagent_type`.
3. `:153-155` — if empty, or not in the gated set, ⇒ **allow** (scope filter). Gated set
   (`:73-80`): `atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`,
   `prd-feature`, `pr-author`. `orchestrator` is deliberately excluded (`:18-21`).
4. `:157` — `$checkpoint = Get-ModelRoutingCheckpoint` — **called with no arguments**.
5. `:158-160` — if `Test-ModelRoutingReceiptPresent` finds any `model_routing_receipts[]` entry whose
   `agent` string-equals the subagent ⇒ **allow**.
6. `:162-168` — otherwise ⇒ **deny** `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to '<x>' …`.

`Test-ModelRoutingReceiptPresent` (`:83-118`) returns `$false` for a `$null` checkpoint (`:100-102`),
`$false` when the `model_routing_receipts` property is absent (`:103-105`), and otherwise scans for a
matching `agent`. `Get-ModelRoutingCheckpoint` (`:37-60`) returns `$null` on a missing file
(`:49-51`) and `$null` on unparseable JSON (`:53-59`) — so a missing or corrupt checkpoint denies.
That is the fail-closed direction and it must be preserved verbatim.

### 2.3 The defect

`enforce-model-routing-receipt.ps1:46`:
```powershell
[string] $CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'
```
Because the sole call site (`:157`) passes no argument, this default always binds. `Test-Path`/
`Get-Content` at `:49` and `:54` resolve it against the process cwd, which §1.4 established is the
session root. There is **no** parallel-mode or epic-mode resolution anywhere in the file, and the
function takes no seam for a target. The `prompt` field of the delegation — which is where the item's
feature folder appears (`enforce-prd-feature-before-planner.ps1:14-34` shows the established
prompt-scanning idiom) — is never read by this hook.

The reported mid-run observation (`route_id: small`, `next_step: pr_creation` while gating an
unrelated parallel item) is exactly consistent with this trace: a single-feature checkpoint left at
the session root being used to authorise a delegation belonging to a different item.

Note the asymmetry that makes 3.4 less severe than 3.2 but still a genuine false approval: the check
is *presence of any receipt for this agent name*. Agent names repeat across items, so a sibling's
receipt for `atomic-planner` satisfies the gate for a different item's `atomic-planner` delegation.
The gate reports that model selection was performed for this delegation. It was not.

### 2.4 Reproduction procedure for 3.4 (executable; not yet executed)

```
<scratch>/session-root/artifacts/orchestration/orchestrator-state.json
  → {"model_routing_receipts":[{"agent":"atomic-planner","phase":"7","model":"opus"}]}
<scratch>/item-worktree/artifacts/orchestration/   (empty — item B has no checkpoint)
```

```powershell
Push-Location <scratch>/session-root
'{"tool_name":"Agent","tool_input":{"subagent_type":"atomic-planner","prompt":"docs/features/active/<item-B-folder>/spec.md"}}' |
  pwsh -NoProfile -File <repo>/.claude/hooks/enforce-model-routing-receipt.ps1
$LASTEXITCODE
Pop-Location
```

**Predicted (unverified) result:** `permissionDecision: allow`, exit `0`, on the strength of item A's
receipt while item B has no checkpoint at all.

**Control run (must be executed too):** identical payload, cwd = `<scratch>/item-worktree`. Predicted
`deny` with `MODEL_ROUTING_RECEIPT_BLOCKED`. The pair (allow from session root / deny from item
worktree, same payload) is the proof that the verdict is a function of cwd and not of the payload.
**Run the control pair for 3.2 as well** — it is the cleanest single piece of evidence for both
defects and it is what makes the reproduction unambiguous.

---

## 3. R3 — `.codex/hooks/enforce-codex-model-routing.ps1`: does it share the defect?

### Finding: NO. Recommend **OUT OF SCOPE** for F5, on positive evidence rather than on the filename.

**(a) Does it share the defect?** No. It does not read an orchestrator-state checkpoint at all.
A content search for `orchestrator-state` and `CheckpointPath` across the whole of `.codex/hooks/`
returns matches in `record-subagent-routing-attestation.ps1:371`,
`enforce-epic-planning-only.ps1:235-322`, `enforce-epic-merge-gate.ps1:174-175`,
`enforce-orchestration-preimplementation-gate*.ps1`, and `enforce-completion-consistency.ps1` —
and **zero** matches in `enforce-codex-model-routing.ps1`.

**(b) How does it resolve its state?** By a different mechanism entirely:

- `.codex/hooks/enforce-codex-model-routing.ps1:11` —
  `$script:CodexModelGateRepositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`.
  Derived from the **script's own location**, not from cwd. This is already worktree-correct with
  respect to the installed hook.
- `:163-167` — the state key is `SHA256(transcript_path)` plus `session_id`, resolved through
  `Get-CodexAuthorityAttestationPath` (`.codex/hooks/codex-authority-store.ps1:164-178`) into
  `Get-CodexAuthorityStateRoot` (`:131-146`), which roots the store under `Get-CodexAuthorityHome`
  and asserts, via `Assert-CodexAuthorityOutsideRepository` (`:144`), that the store lies **outside**
  the repository. There is no per-worktree file and therefore no sibling file to confuse.
- `:172-189` — the fallback scans that same out-of-repo session-scoped directory for an attestation
  whose `agent_id` matches the payload's. Session-scoped, not worktree-scoped.

**(c) Is it in scope?** No, and the reasoning is not "different filename". It is a *different gate
with a different contract*: it verifies **model/profile drift against a SubagentStart attestation**
(`Test-CodexModelGateProfileAttestation`, `:36-85`), comparing `actual_model`, `expected_model`,
reasoning effort, profile name/model/path and a 64-hex `profile_sha256`. The Claude hook verifies
**presence of a receipt in a checkpoint**. They share only the substring "model routing" in their
names. The Codex hook has no sibling-checkpoint fallback because it has no checkpoint.

**Two facts that argue *against* pulling it in, recorded so the decision is not revisited on
intuition:**
1. It has **no Pester test file**. A search for `enforce-codex-model-routing` across `tests/` returns
   only incidental mentions in `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1`,
   `epic-provenance.Tests.ps1`, and `codex-epic-runtime-contracts.Tests.ps1`. Adding it to F5 would
   require standing up a new test surface for an unrelated contract — scope creep on a C3
   fail-closed gate.
2. The epic's Codex-parity obligations are assigned to F2 and F3
   (`docs/features/epics/worktree-scoped-state-resolution/epic.md:195-202`), and the epic already
   flags this exact file as the open question F5 must answer. Answering it "no" closes the question
   as the manifest intends.

**Recommendation:** record in `spec.md` under *Scope & Non-Goals* → *Out of scope*:
`.codex/hooks/enforce-codex-model-routing.ps1` — investigated, does not resolve an orchestrator-state
checkpoint, derives its root from `$PSScriptRoot` and stores attestations outside the repository;
carries neither defect 3.4 nor any cwd-relative state resolution. Cite `:11` and
`codex-authority-store.ps1:144` as the evidence.

---

## 4. R4 — Bundled-payload mirroring

### 4.1 Claude surface — all four files are present and their contents match

Mirror root: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.

| file | present in bundle | content comparison result |
| --- | --- | --- |
| `enforce-pr-author-skill.ps1` | yes | identical, all 311 lines, including the defective line 49 |
| `enforce-pr-author-skill-helpers.ps1` | yes | identical (header `:1-32` and tail `:225-260` read and compared; `$script:OrchestratorStateCheckpointPath` at `:19/:240/:243` matches) |
| `enforce-pr-author-skill.epic-base-branch.ps1` | yes | identical, all 115 lines, including the defective line 35 |
| `enforce-model-routing-receipt.ps1` | yes | identical, all 180 lines, including the defective line 46 |

**No drift detected in any of the four.** The defect is present in both copies of every affected
file, which is the expected state and means the push-down currently delivers the defect.

**Verification method and its limit (unverified aspect, stated explicitly):** identity was
established by reading both copies and comparing the text. **Byte-level identity — line endings,
trailing newline, BOM — was NOT independently verified**, because no `diff`, hashing, or shell tool
was available in this session (see §0).

That gap is closed by an **existing repository gate**, which is stronger evidence than an ad-hoc diff
would have been: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143`
(`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) enumerates **every** file under
`.claude/` (excluding `.claude/settings.local.json` and `.claude/agent-memory/**`) and asserts both
presence in the bundle and `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` (`:140-143`).
Consequently F5's mirroring obligation is machine-enforced: any `.claude/**` edit without a matching
bundle edit fails pytest. The plan should cite this test as the mirroring gate rather than inventing
a manual check.

### 4.2 `core.json` manifest membership — all four already registered

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`:
- `:34` `".claude/hooks/enforce-model-routing-receipt.ps1"`
- `:44` `".claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1"`
- `:45` `".claude/hooks/enforce-pr-author-skill.ps1"`
- `:46` `".claude/hooks/enforce-pr-author-skill-helpers.ps1"`

No manifest change is needed for F5 **unless** F5 adds a new file (e.g. a second helpers file under
the 500-line cap, or — more likely — if F1's new `.claude/lib/` module is not yet registered when F5
merges). See §5.3.

### 4.3 Codex mirror surface

`.codex/**` **does** have a bundled mirror, at
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/`. Verified:
`…/codex-and-agents-customizations/.codex/hooks/enforce-codex-model-routing.ps1` exists and its head
(`:1-15`, including the `$PSScriptRoot`-derived root at `:11`) matches the repo copy. It has its own
manifest at `…/codex-and-agents-customizations/pack-manifests/core.json` and its own contract-test
suite (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`,
`…_pack_manifest_completeness.py`, `…_customizations.py`).

Because §3 puts the Codex hook out of scope, **F5 has no Codex mirror obligation**. This matches the
epic manifest's statement at `epic.md:199-202`.

---

## 5. R5 — The upstream F1 contract and how F5 should bind to it

### 5.1 Current state of `.claude/lib/` (verified against this branch)

Eleven subdirectories: `bash` (shell scripts only), `blast-radius` (8 `.psm1`), `cleanup-manifest`,
`codex-routing` (2), `discovery-validation`, `hook-payload`, `mermaid` (4), `model-routing`,
`orchestrator-state` (11), `project-file-merge` (2 `.psm1` + `Resolve-MergeableConflict.ps1`),
`requirements`. **No worktree/target resolution primitive exists.** F1's feature folder does not yet
exist on this branch either (no `docs/features/active/*target-worktree*` directory), so F1's module
name, function names, and reason-code spelling are genuinely unsettled at research time — exactly as
the delegation stated.

### 5.2 The import idiom F5 must follow (uniform across all 29 existing imports)

```powershell
Import-Module (Join-Path $PSScriptRoot '../lib/<dir>/<Module>.psm1') -Force
```

Every hook uses this exact form, resolved from `$PSScriptRoot` (script location), **not** from cwd —
e.g. `enforce-pr-author-skill.ps1:47` and `:51`, `enforce-model-routing-receipt.ps1:36`,
`enforce-parallel-worktree-removal-gate.ps1:32,35`, `validate-orchestrator-output.ps1:41`. This is
already worktree-correct: the module loaded is always the one sitting beside the hook that ran.

Dot-sourced siblings use `. (Join-Path $PSScriptRoot '<file>.ps1')` — e.g.
`enforce-pr-author-skill.ps1:144,148`.

`HookPayload.psm1` is the adjacent payload primitive. Relevant for F1/F5: `Resolve-ClaudeHookToolInput`
(`HookPayload.psm1:441-484`) returns `{ IsValid, Value, Envelope, Anomaly }` and **deliberately
exposes the parsed envelope root** on `.Envelope` (`:449-451`, added for
`enforce-epic-invocation-origin.ps1`). If F1 wants to read an envelope-root field such as `cwd`, the
accessor already exists: `Get-ClaudeHookEnvelopeValue -Envelope $result.Envelope -Name 'cwd'`
(`:306-330`). **Unverified:** whether the Claude Code PreToolUse envelope actually carries a `cwd`
key in this runtime — a content search for `cwd` across `.claude/` found no hook reading it, so no
in-repo evidence exists either way. F1 should confirm this empirically; F5 must not assume it.

### 5.3 Module-manifest registration requirement

A **new** `.claude/lib/` module is not delivered by push-down unless it is listed in
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths[]`
(current `.claude/lib/` entries at `:115-165`). The convention is enforced per-module by a dedicated
Pester file; six exist today
(`tests/scripts/claude-lib/{blast-radius,codex-routing,discovery-validation,model-routing,orchestrator-state,project-file-merge}/*.Manifest.Tests.ps1`).
The canonical shape is `tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1`:
`:17` resolves the repo root four levels up, `:18` reads `core.json`, `:29` asserts
`paths | Should -Contain <module path>`, `:37` asserts exactly one occurrence.

**This obligation belongs to F1, not F5** (`epic.md:186-191`). F5's only exposure is ordering: if F5
merges before F1's manifest entry lands, the pushed-down payload contains an F5 hook that imports a
module that push-down does not deliver, and the hook fails at load. The plan must make F1's merge
into the integration branch a hard precondition (see §5.5).

### 5.4 How F5 consumes F1 without re-implementing and without hard-coding unsettled identifiers

The problem: F5's spec must be writable now, but F1's module name, function names, and reason-code
string are not yet fixed.

**Recommended spec expression — bind by role, not by spelling.** Write the acceptance criteria
against a small set of *named contract roles*, and place the concrete identifiers in a single,
explicitly-marked binding table that the executor fills in from F1's merged source at implementation
time. Concretely, the spec should say:

> F5 consumes the F1 target-resolution module through three contract roles:
> - **`<TARGET_DERIVATION>`** — given the PreToolUse payload, returns the worktree the call pertains
>   to, or an explicit "no target" result.
> - **`<PATH_NORMALISATION>`** — given a relative or absolute path, returns its repo-relative form by
>   locating the containing worktree.
> - **`<AMBIGUITY_REASON_CODE>`** — the single distinct, greppable code emitted when the correct
>   target cannot be identified.
>
> The concrete module path, exported function names, and reason-code literal are **bound at
> implementation time** from `.claude/lib/<F1 module>` as merged into
> `epic/worktree-scoped-state-resolution-integration`. F5 MUST NOT define, re-implement, or
> re-spell any of the three; a second definition of the reason code in F5's tree is a blocking
> defect.

**Why a binding table and not a placeholder literal:** a placeholder literal (e.g.
`WORKTREE_TARGET_AMBIGUOUS`) written into F5's spec would be copied into F5's code and tests and then
silently diverge from F1's actual spelling, producing two reason codes for one condition — the exact
"second implementation that drifts" failure this epic exists to eliminate.

**Make the binding mechanically checkable.** Add an acceptance criterion of the form: *a content
search for the ambiguity reason-code literal across `.claude/**` returns matches only inside F1's
module and inside F5's deny-reason construction, and the literal in F5 is obtained by calling F1's
exported accessor rather than by repeating the string.* This is directly modelled on the existing
`Get-ClaudeHookPayloadAnomalyCode` pattern (`HookPayload.psm1:66-85`), which exists precisely "so
callers need not hard-code the literals in a second place" (`:68-70`). **Recommend F5 require F1 to
export an accessor of that shape**, and record the requirement in the spec as an upstream dependency
note so F1's author sees it.

**Runtime-safe consumption pattern.** `OrchestratorState.psm1:437-439` is the in-repo precedent for
tolerating an uncertain module surface:
```powershell
if (-not (Get-Command -Name <Fn> -ErrorAction SilentlyContinue)) { Import-Module <path> -Force }
```
F5 should **not** copy the SilentlyContinue tolerance into its decision path, though — a gate that
silently degrades when F1's module is absent is a fail-open. F5 should import unconditionally at
script scope (the `enforce-pr-author-skill.ps1:47,51` form) so a missing module is a hard load
failure at install time rather than a silent allow at gate time.

### 5.5 Ordering requirement for the plan

State as an explicit precondition: **F1 must be merged into
`epic/worktree-scoped-state-resolution-integration`, with its `core.json` entry and its
`*.Manifest.Tests.ps1`, before F5's implementation phase begins.** F5's research (this document) can
and did complete without it; F5's *plan* can be written against the roles in §5.4; F5's *code* cannot
be written until the identifiers exist. The plan should carry a first step that reads F1's merged
module and fills the binding table, and that step's output should be archived as evidence.

---

## 6. R6 — PowerShell-vs-Python divergence history on the pr-author readiness gate

### 6.1 The recorded divergence

`docs/features/potential/2026-08-15-mcp-pr-creation-ready-parity-divergence.md` (Status: Draft,
never promoted). Summary of the recorded incident:

- A checkpoint for issue 472 with `step8_status: "pending"` and `next_step: "S8_create_pr"`.
- `mcp__drm-copilot__validate_orchestration_artifacts` with `require_pr_creation_ready: true`
  returned `{"ok":true,…}` (`:32-36`).
- The Python validator on the identical bytes returned one error:
  `Checkpoint PR-creation readiness validation failed: step8_status is pending.` (`:40-43`).
- The orchestrator recorded `pr_author_preflight.status: "pass"` from the MCP result, delegated PR
  creation, and the `pr-author` agent was then blocked by the hook with
  `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (`:45`).

Severity was assessed **High, not Blocker**, with the explicit reasoning at `:59`: the hook is the
enforcement point and it failed **closed**, which is the correct direction; the damage is that the
checkpoint's own `pr_author_preflight` record becomes untrustworthy evidence.

Suspected cause (`:63`): the TypeScript core at
`extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` does not reproduce the
`step8_status` arm of `PR_CREATION_READY_STEP_KEYS`.

### 6.2 The hard constraint is ALREADY SATISFIED — the `$Invoker` seam invokes no Python today

This is the most important answer to R6 and it removes the risk the delegation was guarding against.

The divergence's resolution direction was set at `:71`: *"no enforcement hook may use Python … remove
the Python leg from the enforcement path entirely so the divergence has nowhere to occur."* That work
landed as issue **#475** (`docs/features/completed/2026-08-15-enforcement-hooks-must-not-invoke-python-475/`).
`spec.md:49` of that feature records the change: *"Delete the Python-deference branch inside
`Invoke-OrchestratorStatePreflight`'s default `$Invoker`."*

**Verified against the current tree:** `.claude/lib/orchestrator-state/OrchestratorState.psm1` was
read in full (499 lines). It contains **no** `python`, no `poetry`, no `Start-Process`, and no
`&`-invocation of any executable. The `$Invoker` default (`:430-468`) is a pure in-process
scriptblock; the module header states it explicitly at `:28-30`: *"Its default seam runs the portable
in-process validation and names no interpreter on any code path."* and at `:22-24`: *"as of issue
#475 it is not consulted at runtime, and this module is the only implementation the hooks run in
every repository, drm-copilot included."*

**Therefore:**
- **What the `$Invoker` seam invokes today:** nothing external. It runs
  `Get-OrchestratorStateCheckpoint` (`:442`), `Get-OrchestratorStateUnconditionalError` from
  `OrchestratorStateUnconditional.psm1` (lazily imported at `:437-439`), and
  `Test-OrchestratorStatePrCreationReadiness` (`:455`), all in-process PowerShell.
- **What this means for the fix:** the hard constraint "must NOT add a Python call" is not a
  restriction F5 has to work around — it is the current state. F5's change is confined to *which
  path string* reaches `Invoke-OrchestratorStatePreflight`; it does not touch the validation
  implementation at all.
- **Options, since there is no Python leg to remove:** none required. The only live risk is
  *regression*: an implementer "restoring parity with the Python validator" by re-adding a call. The
  plan should carry a guard. One already exists in principle — #475 shipped a structural AST guard
  asserting zero Python `CommandAst`s in the guarded tree (described in that feature's research
  `:198-202`). **The plan should confirm that guard's current file location and assert it covers the
  four F5 files**; this research did not locate the guard file itself (unverified).

### 6.3 Residual divergence the plan should know about but must not try to fix

The MCP/TypeScript surface is still weaker than the PowerShell hook for `require_pr_creation_ready`
(the potential-bug file at `:63-65` was never closed, only routed around). That divergence is between
MCP and the hook, not inside F5's scope, and F5 must not widen its scope to address it.

Separately, **`.claude/skills/orchestrate/SKILL.md:190` is stale**: it still describes the mechanism
as *"an injectable `$Invoker` **subprocess** seam"*. Since #475 there is no subprocess. F5 edits this
same decision path and it is a one-word documentation correction; the plan may include it as a
documentation-accuracy fix, flagged as such. (Note `.claude/skills/**` is mirrored by the same
`test_push_down_claude_resource_contracts.py` gate, so the bundle copy must change with it.)

---

## 7. R7 — Existing Pester test surface, and what the matrix needs

### 7.1 Inventory

| test file | lines | targets | how it loads the hook |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | ~482 (near cap) | cases A/B/C, receipt checks 1-5 | `. (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1")` at `:6-7` |
| `…enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 104 | `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` | same idiom, `:17-18` |
| `…enforce-pr-author-skill.epic-base-branch.Tests.ps1` | — | `Test-EpicBaseBranchOverride` | same idiom, `:18-19` |
| `…enforce-pr-author-skill.TriggerScoping.Tests.ps1` | — | structural `gh pr` invocation scoping (#545) | same idiom |
| `…enforce-pr-author-skill.Payload.Tests.ps1` | — | envelope anomalies | same idiom |
| `…enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | — | scoping for check 6 | same idiom |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` | 136 | all six decision branches | same idiom, `:6-7` |

All four production files are named coverage targets in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`:34`, `:47`, `:49`, `:62`, `:70`,
`:239`), so the >=85% line-coverage floor applies to every new line F5 writes.

### 7.2 Helper / fixture idiom (this is the constraint that shapes the new tests)

The suite has a strict **no-temporary-files** discipline, mandated by
`.claude/rules/general-unit-test.md` ("Creation and use of temporary files in tests is strictly
prohibited"). The existing tests satisfy it three ways:

1. **Mock the read seam.** `Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { '{"epic_mode":true,…}' }`
   (`epic-base-branch.Tests.ps1:24,30,36,46,…`);
   `Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { … }`
   (`enforce-model-routing-receipt.Tests.ps1:63,72,84,95`);
   `Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }`
   (11 occurrences across four files).
2. **Point a real seam at an existing committed file.** `enforce-model-routing-receipt.Tests.ps1:114`
   uses the hook script itself as an "exists but is not JSON" fixture; `:119-122` uses
   `config/orchestration-routing.json` as a "valid JSON" fixture;
   `OrchestratorStatePreflight.Tests.ps1:83` points `$script:PrContextArtifactPath` at the hook
   script.
3. **Name a path guaranteed absent.** `OrchestratorStatePreflight.Tests.ps1:84` sets
   `$script:OrchestratorStateCheckpointPath = 'artifacts/orchestration/orchestrator-state.nonexistent-fixture.json'`.

There is exactly one out-of-process test: `OrchestratorStatePreflight.Tests.ps1:54-103` resolves the
running `pwsh` (`:57-61`), spawns it with `-NoProfile -Command <inner script>` (`:94`), passes the
payload via `$env:CLAUDE_TOOL_INPUT` (`:80`), and asserts `$LASTEXITCODE -eq 0` plus the decision
JSON.

### 7.3 How much of the required matrix exists today

The delegation's matrix is **cwd** (session root | item worktree) × **path form** (relative |
absolute) × **target** (own | sibling | absent).

**Coverage of that matrix today: effectively zero.**

- **cwd axis — completely absent.** A content search for `Set-Location` and `Push-Location` across
  `tests/scripts/claude-hooks/` returns **no matches**. Every test runs at whatever cwd the Pester
  host happens to have. No test varies cwd, and no test asserts anything about cwd.
- **path form axis — relative only.** The single place a checkpoint path is chosen
  (`OrchestratorStatePreflight.Tests.ps1:84`) uses a relative path. No test passes an absolute
  checkpoint path to any of the three binding sites.
- **target axis — "own" and "absent" only, and both implicitly.** `absent` is covered by
  `OrchestratorStatePreflight.Tests.ps1:26-37` (missing checkpoint ⇒ deny) and
  `enforce-model-routing-receipt.Tests.ps1:83-92,106-109` (null checkpoint ⇒ deny; missing file ⇒
  `$null`). `own` is covered only in the degenerate sense that cwd and target coincide. **The
  `sibling` case does not exist anywhere in the suite** — which is exactly why the defect has
  survived.

**Existing rows that ARE regression guards and must be preserved verbatim:**

| existing test | row it guards |
| --- | --- |
| `OrchestratorStatePreflight.Tests.ps1:26-37` | required evidence genuinely absent ⇒ deny |
| `OrchestratorStatePreflight.Tests.ps1:39-51` | checkpoint present but not ready ⇒ deny, with summarised text |
| `OrchestratorStatePreflight.Tests.ps1:64-102` | end-to-end deny in a real `pwsh` process, exit 0 |
| `enforce-model-routing-receipt.Tests.ps1:62-68` | receipt present ⇒ allow (the standalone happy path) |
| `enforce-model-routing-receipt.Tests.ps1:71-92` | receipt absent / checkpoint missing ⇒ deny |
| `enforce-model-routing-receipt.Tests.ps1:20-58` | envelope anomalies deny; out-of-scope subagents allow |
| `epic-base-branch.Tests.ps1:22-42` | `epic_mode` false/absent and non-create ⇒ no-op |

### 7.4 What the tests need in order to express the sibling-only case

The seam-mocking idiom (method 1 above) **cannot express the sibling case**, because mocking
`Get-ModelRoutingCheckpoint` or `Get-PrAuthorCheckpointContent` *replaces the resolution step under
test*. A sibling-case test that mocks the reader proves nothing: it asserts the hook's behaviour
given a checkpoint object, not which checkpoint it chose. **This is the central test-design
constraint and the plan must state it explicitly**, because the path of least resistance is to write
a mocked test that passes without testing anything — a verification gate that cannot fail.

The sibling case requires the *real* resolution step to run against *two real directories*. Three
options, with a recommendation:

- **(A) Out-of-process, fixture directories under the scratchpad.** Extend the
  `OrchestratorStatePreflight.Tests.ps1:54-103` spawn pattern: create the two-root fixture, spawn
  `pwsh` with its working directory set to each root in turn, assert the decision.
  *Blocked by policy as written:* the no-temporary-files rule prohibits creating fixture files in
  tests. The plan must resolve this explicitly rather than silently — either by obtaining an
  exception, or by option (C).
- **(B) Committed fixture directories under `tests/fixtures/`.** `tests/fixtures/` already exists
  (e.g. `tests/fixtures/blast_radius/…`). Two committed, permanent fixture trees — a "session root"
  with a ready sibling checkpoint and an "item worktree" with none — are *committed repository
  content*, not temporary files, so the prohibition does not apply. The test sets the spawned
  process's working directory to the fixture root.
- **(C) Inject the resolution seam, not the reader.** Have F1's module expose target derivation as a
  named function, refactor each hook so the *only* thing that determines the checkpoint path is one
  call to that function, and unit-test the hook by mocking **that** function while separately
  unit-testing F1's function against committed fixtures in F1's own test file.

**Recommendation: (B) for the two or three end-to-end rows that actually need real directories
(sibling-only ⇒ deny; own-checkpoint-at-item-worktree ⇒ allow; standalone cwd==target ⇒ unchanged),
combined with (C) for the remaining table-driven rows.** (B) gives genuine evidence at the exact seam
that is defective, (C) keeps the matrix cheap and fast, and neither creates a temporary file. Do not
use (A).

Two mechanical traps for whoever writes these tests:
1. `Push-Location` changes `$PWD` but not `[Environment]::CurrentDirectory` (see §1.6). Any
   in-process cwd manipulation will make `Test-Path` and `[System.IO.File]::ReadAllBytes`
   (`enforce-pr-author-skill.ps1:92`) disagree. Prefer out-of-process with an explicit working
   directory.
2. Tests must be order-independent (`.claude/rules/general-unit-test.md`). Any cwd change must be
   restored in a `finally`, matching the `$env:CLAUDE_TOOL_INPUT` save/restore at
   `OrchestratorStatePreflight.Tests.ps1:78-101`.

---

## 8. R8 — File-size headroom (concrete numbers)

Cap: 500 lines (`.claude/rules/general-code-change.md`, *File Size Limit*).

| file | lines | headroom | helpers extraction REQUIRED? |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 311 | 189 | **No** — optional |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 260 | 240 | **No** — optional |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 115 | 385 | **No** — optional |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 180 | 320 | **No** — optional |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 499 | **1** | **N/A — but see below** |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | ~482 | ~18 | **Yes, for tests** |

**Answer to R8: a helpers extraction is NOT required by the cap for any of the four production files
in F5's scope.** Combined headroom across the four is 1,134 lines. This is consistent with
`epic.md:209-220`, which requires extractions for F2/F3/F4 and does **not** require one for F5.
Recommend the plan state this explicitly so an executor does not perform a gratuitous split.

**Two real size constraints the plan MUST carry, neither of which is about the four hooks:**

1. **`.claude/lib/orchestrator-state/OrchestratorState.psm1` has 1 line of headroom (499/500).**
   If the fix adds anything to that module — a worktree-aware overload, a new parameter with a
   doc-comment block, an additional export — it breaches the cap immediately. **Design the fix so the
   module is not modified at all:** F5's change belongs entirely in the hooks (choosing the path
   string) and in F1's new module (deriving it). Record this as a hard design constraint.
2. **`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` is at ~482 lines**, with roughly
   18 lines of headroom — the file's own sibling records the constraint
   (`epic-base-branch.Tests.ps1:9-13`: *"that file was already at 482 of the repository's 500-line
   hard cap"*). The table-driven matrix **must** go into a new sibling test file, following the
   established concern-split naming (e.g.
   `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` and
   `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`). Note the counts marked "~" were
   read from a cross-reference in the sibling file's header rather than measured, because no line
   count could be executed (see §0) — the plan should confirm before appending anything.

---

## 9. Must-not-regress: how each constraint is enforced today

### 9.1 Gates must still deny when required evidence is genuinely absent

- **pr-author:** `OrchestratorState.psm1:163-169` — missing file ⇒ `Ok=$false` ⇒
  `Invoke-OrchestratorStatePreflight` returns `HasErrors=$true` ⇒
  `enforce-pr-author-skill-helpers.ps1:241-248` returns `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`.
  Guarded by `OrchestratorStatePreflight.Tests.ps1:26-37,64-102`.
- **model-routing:** `enforce-model-routing-receipt.ps1:49-51` (missing file ⇒ `$null`) and
  `:100-102` (`$null` checkpoint ⇒ `$false`) ⇒ deny at `:162-168`. Guarded by
  `enforce-model-routing-receipt.Tests.ps1:83-92`.
- **Risk the fix introduces:** a target-resolution step that returns "no target" must **deny**, not
  fall back to cwd. The epic's `.claude` NFR is unambiguous (`epic.md:13`): *"Gates remain
  fail-closed; every ambiguity denies with a distinct, greppable reason code."* The plan must assert
  that the new resolution path has **no `else { use cwd }` branch** on the ambiguous outcome.

### 9.2 Pre-implementation gate restrictions — **there IS a coupling; here it is**

The pre-implementation gate is out of F5's scope, but it is **not decoupled**. Three of F5's files
dot-source two shared parser helpers that the pre-implementation gate and the epic-merge gate also
dot-source:

| shared helper | dot-sourced by (F5 scope) | also dot-sourced by (out of scope) |
| --- | --- | --- |
| `.claude/hooks/hook-command-scanner.ps1` | `enforce-pr-author-skill-helpers.ps1:31`, `enforce-pr-author-skill.epic-base-branch.ps1:14` | `enforce-orchestration-preimplementation-gate.ps1:23`, `enforce-epic-merge-gate.ps1:45`, `validate-bash.ps1:45`, `enforce-promotion-mcp-only.ps1:38`, `enforce-parallel-abandon-gate.ps1:51`, `enforce-parallel-worktree-removal-gate.ps1:40`, `enforce-epic-worktree-removal-gate.ps1:68` |
| `.claude/hooks/hook-command-invocation.ps1` | `enforce-pr-author-skill-helpers.ps1:32`, `enforce-pr-author-skill.epic-base-branch.ps1:15` | the same seven |

`Test-ExemptOrchestrationStagingCommand` (the pathspec/option/metacharacter exemption at
`enforce-orchestration-preimplementation-gate-helpers.ps1:296`, per `epic.md:296-299`) tokenises via
the shared scanner. **Therefore: F5 must not modify `hook-command-scanner.ps1` or
`hook-command-invocation.ps1`.** Record this as an explicit non-goal with the file names, and add a
plan guard that F5's diff touches neither. Nothing in the recommended design needs them changed —
target resolution operates on the checkpoint path, not on command tokenisation.

### 9.3 Epic merge gate's `pr_number` matcher must not be widened

`enforce-epic-merge-gate.ps1` is a separate file that F5 does not edit. Its own child-checkpoint
literal is at `:48` (`$script:ChildCheckpointPath`) — **also cwd-relative, and also part of this
epic**, but assigned to F3 (`epic.md:258`), not F5. The only shared surface is §9.2's parser pair.
Guard: assert F5's diff does not include `enforce-epic-merge-gate.ps1` or the two parser helpers.

### 9.4 Standalone and epic topologies must behave exactly as now when cwd and target coincide

**The exact code path a standalone run takes today, so the plan can assert it is untouched:**

For `enforce-pr-author-skill.ps1`, a standalone run reaches:
`Invoke-PrAuthorSkillEntryPoint` (`:261`) → `Invoke-PrAuthorSkillDecision` (`:293`) →
`Get-PrAuthorBypassReason` (helpers `:144`) → the `--body-file` + context-present branch
(helpers `:239`) → `Invoke-OrchestratorStatePreflight -CheckpointPath $script:OrchestratorStateCheckpointPath`
(helpers `:240`) → `& $Invoker $CheckpointPath` (`OrchestratorState.psm1:471`) →
`Test-Path -LiteralPath 'artifacts/orchestration/orchestrator-state.json'` (`:163`), resolved against
cwd == the single session root == the single worktree. Then `Test-PrAuthorReceiptVerification`
(helpers `:253`), whose check 6 calls `Test-EpicBaseBranchOverride` (helpers `:136`) →
`Get-PrAuthorCheckpointContent` with no argument (epic-base-branch `:78`) → default `:35`, same file.

For `enforce-model-routing-receipt.ps1`, a standalone run reaches:
`Invoke-ModelRoutingReceiptDecision` (`:176`) → gated-agent scope filter (`:153`) →
`Get-ModelRoutingCheckpoint` with no argument (`:157`) → default `:46` →
`Test-Path -LiteralPath` (`:49`), resolved against cwd == the single worktree.

**The invariant to assert:** in the standalone topology there is exactly one checkpoint and it is at
the session root, so target resolution and cwd fallback **must yield the identical absolute path**.
The plan should require a Pester row asserting exactly this — cwd == item worktree, own checkpoint
present, decision identical to the pre-change decision — as the top regression guard, and should
require that it is written **before** the fix so it is observed passing on the unmodified hook.

Epic topology adds `epic_mode`/`epic_context.integration_branch`
(`epic-base-branch.ps1:90-111`); when the epic child's cwd is its own worktree, the same path applies
and behaviour is likewise unchanged.

---

## 10. Numeric Derivation Evidence

### Claim N1 — There are exactly **3** cwd-relative orchestrator-state checkpoint bindings reachable on a decision path within F5's four in-scope hook files.

- **Complete Family:** every construct within the four in-scope files that supplies the
  orchestrator-state checkpoint path to a filesystem read, in any spelling (script-scoped variable
  assignment, parameter default, inline literal argument, or environment read), whether or not the
  binding is actually reached.
- **Exhaustive Search Scope:** `.claude/hooks/enforce-pr-author-skill.ps1`,
  `.claude/hooks/enforce-pr-author-skill-helpers.ps1`,
  `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`,
  `.claude/hooks/enforce-model-routing-receipt.ps1`. All four files were additionally read in full
  (311 + 260 + 115 + 180 lines), so the scope is covered by whole-file reading and not only by
  pattern matching.
- **Inclusion Rules:** the construct appears in executable code (not a comment or doc-comment); it
  yields the checkpoint path used by a `Test-Path` / `Get-Content` / module call on a decision path;
  the path form is relative and therefore resolved against process cwd.
- **Exclusion Rules:** doc-comment and `.DESCRIPTION` mentions of the literal; sites that *consume* an
  already-bound variable without introducing a binding; bindings in files outside the four
  (specifically `.claude/lib/orchestrator-state/OrchestratorState.psm1:427`, which is a parameter
  default in a different file and is additionally **unreachable** from these hooks because
  `enforce-pr-author-skill-helpers.ps1:240` always passes `-CheckpointPath` explicitly).
- **Primary Search Strategy:** literal-path content search for
  `artifacts/orchestration/orchestrator-state\.json` across `.claude/hooks/`, then filtered to the
  four in-scope files and classified code-vs-comment by reading each hit in context.
- **Primary Member Set:**
  1. `enforce-pr-author-skill.ps1:49` — `$script:OrchestratorStateCheckpointPath = '…'`
  2. `enforce-pr-author-skill.epic-base-branch.ps1:35` — `[string] $CheckpointPath = '…'`
  3. `enforce-model-routing-receipt.ps1:46` — `[string] $CheckpointPath = '…'`
  Excluded as comments by this strategy: `enforce-pr-author-skill.epic-base-branch.ps1:23`,
  `enforce-model-routing-receipt.ps1:9`.
- **Primary Count:** 3
- **Cross-check Search Strategy or Query Expression:** an **identifier**-based search (deliberately
  not the literal) for `CheckpointPath` restricted by glob to
  `enforce-{pr-author-skill*,model-routing-receipt}.ps1`, followed by a manual call-site trace of
  each declaring function to determine whether its default actually binds. This strategy finds
  bindings the literal search would miss (e.g. a path composed from a variable) and separates
  bindings from consumption sites, which the literal search cannot do.
- **Cross-check Member Set:**
  1. `enforce-pr-author-skill.ps1:49` — declares `$script:OrchestratorStateCheckpointPath`; consumed
     at `enforce-pr-author-skill-helpers.ps1:240`. **Binding — IN.**
  2. `enforce-pr-author-skill.epic-base-branch.ps1:35` — parameter default of
     `Get-PrAuthorCheckpointContent`; sole call site `epic-base-branch.ps1:78` passes no argument, so
     the default binds. **Binding — IN.**
  3. `enforce-model-routing-receipt.ps1:46` — parameter default of `Get-ModelRoutingCheckpoint`; sole
     production call site `:157` passes no argument, so the default binds. **Binding — IN.**
  - `enforce-pr-author-skill-helpers.ps1:19` (doc-comment), `:240` and `:243` (reads of the
    already-bound variable) — **consumption, not binding — OUT.**
  - `epic-base-branch.ps1:26` (`.PARAMETER` doc), `:38`, `:42`,
    `enforce-model-routing-receipt.ps1:49`, `:54` — **uses of the bound parameter — OUT.**
- **Cross-check Count:** 3
- **Member-set Comparison:** normalised to `file:line`, the primary set
  `{enforce-pr-author-skill.ps1:49, enforce-pr-author-skill.epic-base-branch.ps1:35,
  enforce-model-routing-receipt.ps1:46}` is **identical** to the cross-check set. Both counts are 3;
  no member appears in one set only. The two strategies are independent (one matches a string
  literal, the other matches an identifier and then traces call sites) and each independently
  enumerated its members. **Assertion stands.**

  Consequence for the spec: the issue's root-cause section names only two of the three
  (`enforce-pr-author-skill.ps1:49` and `enforce-model-routing-receipt.ps1:46`). The third,
  `enforce-pr-author-skill.epic-base-branch.ps1:35`, must be added.

### Claim N2 — Exactly **4** files require a bundled mirror update for F5.

- **Complete Family:** every file F5 edits under `.claude/**` and therefore every file for which
  `extensions/drm-copilot/resources/claude-customizations/.claude/**` must be updated in the same
  change.
- **Exhaustive Search Scope:** the mirror directory
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and the pack manifest
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- **Inclusion Rules:** the file is one of F5's four in-scope hook files and has a counterpart under
  the mirror root.
- **Exclusion Rules:** `.claude/lib/orchestrator-state/OrchestratorState.psm1` (not edited — §8
  constraint 1); `.claude/skills/orchestrate/SKILL.md` (edited only if the optional §6.3
  documentation correction is taken; counted separately if so); any `.codex/**` file (out of scope
  per §3).
- **Primary Search Strategy:** filesystem glob of the mirror hooks directory —
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author*` plus
  `extensions/drm-copilot/resources/claude-customizations/**/enforce-model-routing-receipt.ps1`.
- **Primary Member Set:** `enforce-pr-author-skill-helpers.ps1`,
  `enforce-pr-author-skill.epic-base-branch.ps1`, `enforce-pr-author-skill.ps1`,
  `enforce-model-routing-receipt.ps1`.
- **Primary Count:** 4
- **Cross-check Search Strategy or Query Expression:** content search of the **pack manifest**
  `core.json` — a different artefact and a different mechanism — for
  `enforce-pr-author|enforce-model-routing`, enumerating the `paths[]` entries.
- **Cross-check Member Set:** `core.json:34` `.claude/hooks/enforce-model-routing-receipt.ps1`;
  `:44` `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`;
  `:45` `.claude/hooks/enforce-pr-author-skill.ps1`;
  `:46` `.claude/hooks/enforce-pr-author-skill-helpers.ps1`.
- **Cross-check Count:** 4
- **Member-set Comparison:** normalised to bare filenames, both sets are
  `{enforce-model-routing-receipt.ps1, enforce-pr-author-skill.epic-base-branch.ps1,
  enforce-pr-author-skill.ps1, enforce-pr-author-skill-helpers.ps1}` — **identical**, counts agree at
  4. The two strategies are independent (directory enumeration vs manifest content). **Assertion
  stands.** Note this count would become 5 if the §6.3 SKILL.md correction is taken, and would grow
  further if F5 adds a new file; the plan must recompute if scope changes.

---

## 11. Recommended approach

### Selected approach — resolve the checkpoint once, at the top of each hook, from F1's module; deny on ambiguity; never fall back to cwd

**Shape.** In each of the two hook entry points, replace the cwd-relative binding with a single
resolution step, executed before any decision logic, that returns one of exactly three outcomes:

| outcome | action |
| --- | --- |
| target resolved, checkpoint path known | proceed with that **absolute** path; all existing decision logic runs unchanged |
| target genuinely has no checkpoint at the resolved location | **deny** with the existing reason (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED` / `MODEL_ROUTING_RECEIPT_BLOCKED`) — unchanged behaviour |
| target cannot be identified (ambiguous) | **deny** with F1's `<AMBIGUITY_REASON_CODE>` — new behaviour, and the only new deny path |

**Why this shape:**
- It concentrates every change at exactly the three binding sites of Claim N1, leaving all six
  receipt checks, both scope filters, both anomaly paths, and both allow constructions untouched.
  That is what makes the "epic and standalone topologies behave exactly as now" criterion assertable
  rather than merely hoped for.
- Passing an **absolute** path downstream means `OrchestratorState.psm1` needs no change, which
  respects the 1-line headroom constraint (§8).
- Denying on ambiguity, with no cwd fallback branch, is the literal requirement of `epic.md:13` and
  `epic.md:104-106`.
- It reuses F1 rather than re-implementing, satisfying the epic's contract boundary.

**Per-site application:**
1. `enforce-pr-author-skill.ps1:49` — `$script:OrchestratorStateCheckpointPath` becomes the resolved
   absolute path (or the hook returns the ambiguity deny before helpers are consulted). Helpers
   `:240/:243` then need no change at all.
2. `enforce-pr-author-skill.epic-base-branch.ps1:78` — pass the resolved path explicitly:
   `Get-PrAuthorCheckpointContent -CheckpointPath $script:OrchestratorStateCheckpointPath`. Keep the
   parameter default in place for the dot-sourced-standalone case, or remove it and make the
   parameter mandatory — **recommend making it mandatory**, so the latent relative default cannot
   reappear on a future call site. Note this changes the *fail-open* semantics of check 6 only in
   the ambiguous case (where the hook has already denied upstream), so the `epic_mode false/absent ⇒
   no-op` guards at `epic-base-branch.Tests.ps1:22-42` stay green.
3. `enforce-model-routing-receipt.ps1:157` — pass the resolved path explicitly to
   `Get-ModelRoutingCheckpoint`; make `:46`'s parameter mandatory for the same reason.

### Rejected alternatives (brief)

- **Make the relative literal absolute by joining `$PSScriptRoot/..`.** Rejected: `$PSScriptRoot` is
  the *session root's* `.claude/hooks`, so this would make the session-root binding *more* durable,
  not correct it. It fixes nothing and would give a false sense of a fix.
- **Search upward from the target path for the nearest `artifacts/orchestration/` directory.**
  Rejected: an upward search silently resolves to the first ancestor that has one, which in a nested
  `.claude/worktrees/<x>` layout is the session root — reintroducing the sibling fallback as an
  implicit behaviour rather than an explicit one. It also duplicates F1's normalisation contract.
- **Add a Python call to the authoritative validator to settle the path.** Rejected outright:
  prohibited by `epic.md:119-120` and by the owner directive recorded at
  `docs/features/potential/2026-08-15-mcp-pr-creation-ready-parity-divergence.md:71`; and unnecessary,
  since §6.2 establishes the enforcement path is already Python-free.

---

## 12. Behaviour semantics and requirements mapping

### 12.1 Success / failure conditions

| condition | required decision | reason code |
| --- | --- | --- |
| target resolved; own checkpoint present and ready | allow | — |
| target resolved; own checkpoint present, not ready | deny | `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (unchanged) |
| target resolved; own checkpoint absent | deny | `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (unchanged) |
| target resolved; own `model_routing_receipts[]` lacks the agent | deny | `MODEL_ROUTING_RECEIPT_BLOCKED` (unchanged) |
| **sibling's checkpoint is the only state present** | **deny** | **F1's `<AMBIGUITY_REASON_CODE>` (new)** |
| target not identifiable from the payload | deny | F1's `<AMBIGUITY_REASON_CODE>` (new) |
| envelope anomaly | deny | existing per-hook anomaly reason (unchanged) |
| subagent outside the gated set / command is not `gh pr create|edit` | allow | scope filter (unchanged) |

### 12.2 Ordering rules that must not change

- pr-author decision order (`enforce-pr-author-skill.ps1:28-30` and helpers `:212-257`): Case A →
  Case B → `gh pr edit` no-body allow → Case C (`PR_CONTEXT_MISSING`) → orchestrator-state preflight
  → receipt checks 1-6. The **new ambiguity deny must sit before the preflight**, because an
  unresolvable target makes the preflight meaningless; it must sit **after** the scope filter at
  helpers `:181`, so a non-`gh pr` command is never denied for ambiguity.
- model-routing decision order (`:136` anomaly → `:153` scope filter → `:157` checkpoint →
  `:158` presence → `:162` deny). The ambiguity deny goes between `:155` and `:157`.

### 12.3 Edge cases

- Checkpoint present at the target but empty / invalid JSON: existing fail-closed handling
  (`OrchestratorState.psm1:175-193`; `enforce-model-routing-receipt.ps1:53-59`) must be reached
  **after** resolution, so it stays a genuine-absence deny and not an ambiguity deny. The two
  categories must remain distinguishable in the reason text — this is the substance of the C3
  complexity rating at `epic.md:269-274`.
- Target resolves to a path that is not inside any worktree: ambiguity deny.
- A command that names *two* different worktrees (e.g. a chained `cd A && … && cd B`): ambiguity
  deny, not first-match.

---

## 13. Test strategy (no test code written)

1. **Baseline, before any edit.** Execute both reproduction procedures (§1.6, §2.4) including the
   control pair. Archive the raw decision JSON, exit codes, and stderr under
   `<FEATURE>/evidence/baseline/`. If either predicted `allow` is not observed, halt and report.
2. **Regression guards first.** Confirm the seven existing rows in §7.3 pass on the unmodified hooks,
   and add the standalone `cwd == item worktree, own checkpoint present ⇒ allow` row (§9.4) as a new
   guard observed passing **before** the fix.
3. **Table-driven matrix**, split across two new sibling test files (§8 constraint 2), using design
   (B)+(C) from §7.4: committed fixture roots under `tests/fixtures/` for the three rows that need
   real directories, and F1-seam injection for the remainder. Cover cwd × path form × target as
   specified, plus §12.3's edge cases.
4. **Negative guard on the fix itself.** Assert no code path in the four files contains a cwd
   fallback on the ambiguous outcome, and assert the ambiguity reason-code literal appears in F5's
   tree only via F1's accessor (§5.4).
5. **Python-free guard.** Confirm #475's structural guard still covers these four files (§6.2;
   location unverified).
6. **Coupling guard.** Assert F5's diff touches neither `hook-command-scanner.ps1` nor
   `hook-command-invocation.ps1` nor `enforce-epic-merge-gate.ps1` (§9.2, §9.3).
7. **Mirror gate.** `test_bundled_claude_payload_contains_all_repo_runtime_contracts` must pass
   (§4.1) — this is the mirroring proof; no manual diff is needed.
8. **Toolchain.** Full seven-stage loop per `.claude/rules/general-code-change.md`; line coverage
   >= 85% for all four files (all are runsettings coverage targets, §7.1); Pester has no branch-
   coverage gate (`.claude/rules/quality-tiers.md`).

---

## 14. Open items and explicitly unverified claims

| item | status |
| --- | --- |
| Direct reproduction of 3.2 and 3.4 | **NOT DONE** — no execution tool in this session (§0). Must be the plan's first step. |
| Byte-level (line-ending / trailing-newline / BOM) identity of the four bundle mirrors | **Unverified** — no diff/hash tool. Covered in practice by `test_push_down_claude_resource_contracts.py:118-143`. |
| Line counts | Derived from full-file reads, not from `wc -l`. Consistent with `epic.md:209-215` for the two files the epic lists. `enforce-pr-author-skill.Tests.ps1` ≈ 482 is taken from a cross-reference in `epic-base-branch.Tests.ps1:9-13`, not measured. |
| Whether the Claude PreToolUse envelope carries a `cwd` key | **Unverified** — no hook reads it; no in-repo evidence either way. F1 must establish this. |
| Location of #475's structural Python guard test | **Unverified** — the guard is described in that feature's research (`:198-202`) but its file was not located in this session. |
| F1's module name, function names, ambiguity reason-code spelling | **Not yet fixed.** F1's feature folder does not exist on this branch. Bind per §5.4. |
| `enforce-epic-merge-gate.ps1:48` `$script:ChildCheckpointPath` is also cwd-relative | Observed; belongs to F3 (`epic.md:258`), not F5. Recorded so it is not fixed twice or missed. |
| `.claude/skills/orchestrate/SKILL.md:190` describes `$Invoker` as a "subprocess seam" | Stale since #475. Optional documentation correction (§6.3). |

---

## 15. Orchestrator Addendum — 2026-09-13 (measured verification of §14 open items)

Authored by the orchestrator after the research delegation returned, to close the measurable subset
of §14 and to record a second, independent reproduction attempt. Everything below was measured in
this workspace; nothing is inferred.

### 15.1 Second reproduction attempt — also blocked, by a different mechanism

The orchestrator session does hold a command-execution tool and did attempt the §2.4 control pair
for defect 3.4. The attempt was refused by the agent-worktree isolation guard, which declines any
command that launches `pwsh`, in both the compound and the plain single-command form:

- Compound form refused: `... this command runs pwsh inside a construct too complex to verify ...`
- Plain form refused: `... this command runs pwsh in a plain command; what it reads or is handed as
  shell text cannot be shown not to run git. Refusing to run it ...`

The guard is a blanket refusal on `pwsh` for a worktree-isolated agent, not a property of the
fixture or of the hook. The fixture itself was built successfully at
`<scratchpad>/f5repro/{session-root,item-worktree}` and the payload file was written; only the
interpreter launch was refused. **No attempt was made to route around the guard.**

**Net position: defects 3.2 and 3.4 remain unreproduced by direct execution after two independent
attempts, for two unrelated environment reasons.** §0 stands unchanged and is not softened. The
consequence for the plan is unchanged and is now doubly warranted: reproduction is the plan's first
executable step, its observed `allow` is archived under `evidence/baseline/`, and a failure to
observe the predicted `allow` halts execution before any hook file is edited.

Note for the executing environment: the reproduction step needs an environment in which `pwsh` can
be launched. `mcp__drm-copilot__run_poshqc_test` runs Pester out of process and is available even
where a direct `pwsh` launch is refused, so a Pester-expressed reproduction is the fallback route if
the execution environment carries the same guard. The plan must name both routes so the step cannot
stall.

### 15.2 Measured resolution of §14's measurable open items

| §14 item | measured result |
| --- | --- |
| Byte-level identity of the four bundle mirrors | **`cmp` reports IDENTICAL for all four.** No drift. `enforce-pr-author-skill.ps1`, `enforce-pr-author-skill-helpers.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`, `enforce-model-routing-receipt.ps1` each match their copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. |
| Hook line counts | **`wc -l` confirms 311 / 260 / 115 / 180**, exactly as §1.1 and §8 report. Bundle copies carry the same counts. |
| `OrchestratorState.psm1` headroom | **`wc -l` = 499.** §8's 1-line-headroom constraint is confirmed measured. The fix must not add a line to this file. |
| `.codex/hooks/enforce-codex-model-routing.ps1` | **`wc -l` = 198**, as stated. R3's out-of-scope recommendation is unaffected. |
| `enforce-pr-author-skill.Tests.ps1` size | **`wc -l` = 447**, not the ≈482 cross-referenced in §8. Headroom is 53 lines, not 18. The §8 conclusion is unchanged — the matrix still belongs in new sibling test files — but the number is corrected here. |

Full measured test-surface inventory for the two hook families (`tests/scripts/claude-hooks/`):
`enforce-pr-author-skill.Tests.ps1` 447, `enforce-pr-author-skill.TriggerScoping.Tests.ps1` 327,
`enforce-pr-author-skill.epic-base-branch.Tests.ps1` 113,
`enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` 104,
`enforce-pr-author-skill.Payload.Tests.ps1` 103,
`enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` 57,
`enforce-model-routing-receipt.Tests.ps1` 136.

### 15.3 Items that remain open

These were not measurable here and stay open for the plan to resolve:

- Whether the Claude PreToolUse envelope carries a `cwd` key — F1 must establish it.
- Location of issue #475's structural Python guard test.
- F1's module name, exported function names, and ambiguity reason-code spelling — bind per §5.4.
