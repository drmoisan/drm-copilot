# Research — Epic `require_complete` demands a launch binding no agent writes (Issue #524)

- Timestamp: 2026-08-23T23-45
- Issue: #524
- Branch: `bug/epic-require-complete-demands-launch-binding-no-agent-ever-writes-524`
- Workspace root: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a88168dfb6a54afdb`
- Requirements source: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/issue.md`

## Tooling Limitation (recorded before findings)

The `Bash` tool is disabled for this session, so no `git log -S`, `git log --follow`, or
`git grep` command could be executed. Every claim below is grounded in file reads and
ripgrep content searches performed through the `Grep` and `Glob` tools. Where the issue
asked for a git-history answer, the finding is reconstructed from tracked file content and
is labelled as inference rather than as verified history.

## 1. Current State — where the requirement is implemented

### 1.1 The single Python implementation

`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` is the only Python module
that implements the requirement.

- Lines 10-14 define the path marker tuple `_LAUNCH_ARTIFACT_PARTS = ("artifacts",
  "orchestration", "epic-child-launches")`.
- Lines 49-71 (`_is_launch_artifact_path`) require the value to sit strictly below that
  three-segment marker, reject `.` and `..` segments, and require the marker to be at index
  0 unless the value is absolute.
- Lines 82-109 (`_validate_branch_and_paths`) emit the branch, worktree, and two
  launch-path errors.
- Lines 112-160 (`_validate_delegation_receipt`) emit the per-feature `delegation_receipt`
  errors; line 123 is the short-circuit "must be an object" error when the key is absent.
- Lines 163-199 (`_validate_model_receipt`) emit the per-feature `model_routing_receipt`
  errors; line 175 is the short-circuit "must be an object" error when the key is absent.
- Lines 202-247 (`_validate_launch_bindings`) drive the per-feature loop. Line 219 applies
  the `skip_not_started` filter.
- Lines 264-285 (`validate_epic_child_launch_bindings`) is the activation point. Line 273
  is the defect site:

  ```python
  if not (require_codex_model_routing or require_codex_topology or require_complete):
      return []
  ```

  Line 284 sets `skip_not_started=not require_complete`, so `require_complete` both
  activates the gate and removes the only escape hatch (`merge_status == "not_started"`).

`scripts/dev_tools/validate_epic_orchestrator_state.py` lines 460-467 invoke the helper
and pass all three flags through. Lines 481-482 run the separate `_validate_completion`
gate (lines 362-402), which is the completion check the epic spec actually documented.

### 1.2 The TypeScript parity port

`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` is a
line-for-line port:

- Lines 3-7 `LAUNCH_ARTIFACT_PARTS`.
- Lines 63-97 `isLaunchArtifactPath`.
- Lines 106-131 `validateBranchAndPaths`, with the two launch-path errors at lines 123-129.
- Line 147 `delegation_receipt must be an object.`; line 202 `model_routing_receipt must be
  an object.`
- Lines 291-312 `validateEpicChildLaunchBindings`; the activation condition is lines
  295-301 and `skipNotStarted: options.requireComplete !== true` is line 310.

It is dispatched from `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`
line 429, with the separate completion gate at line 438, and reached from
`extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` lines 300-305 for
`artifact_type: "epic-orchestrator-state"`.

The parity obligation is stated in the `orchestration-artifacts.ts` module docstring at
lines 51-53: "Phase/task regexes and error-message strings are identical to the Python
source."

### 1.3 Surfaces that do NOT implement it (verified negatives)

- **`.claude/lib/orchestrator-state/`** — a content search for
  `launch_binding|launch_receipt_path|launch_status_path|epic-child-launches|LaunchBinding`
  across the whole `.claude` tree returned **no matches**. None of the eleven portable
  PowerShell modules implements any part of this gate. The environment line in the issue
  ("the portable PowerShell validators under `.claude/lib/orchestrator-state/` are what run
  there") is therefore not the failing surface; the failing surface is the MCP TypeScript
  validator shipped in the VS Code extension.
- **`.claude/hooks/validate-orchestrator-output.ps1`** — for `-ArtifactType
  epic-orchestrator-state` it dispatches to `Test-OrchestratorCheckpointStructure` (lines
  152-196, dispatch at lines 267-275), which asserts only that the file exists, parses as
  JSON, and has an object root. It never passes `require_complete` for the epic type. The
  `SubagentStop` hook registered at `.claude/agents/epic-orchestrator.md` lines 28-32 and
  `.claude/settings.json` line 270 is therefore not a source of the twenty errors.
- **`.claude/rules/orchestrator-state.md`** — a case-insensitive search for `epic` and for
  `launch` in `.claude/rules/orchestrator-state.md` returned **no matches**. The rule file
  that the repository designates as the prose enforcement record for orchestrator-state
  invariants says nothing about the epic checkpoint at all, and nothing about launch
  bindings. The requirement exists only as validator code.
- **`.claude/agents/epic-planner.md` and `.claude/skills/epic-plan/SKILL.md`** — neither
  mentions `require_ready_for_execution`, so the sibling planner-side gate (section 8) is
  not invoked by the Claude runtime.

### 1.4 The count is five per feature — enumerated

Under `require_complete=True` alone, applied to a feature record written by the Claude
`epic-orchestrator` (whose documented `features[]` schema is
`docs/features/completed/2026-07-02-epic-orchestrate-275/spec.md` lines 140-144:
`worktree_path`, `branch_name`, `pr_number`, `merge_status`, four lifecycle timestamps),
the per-feature error set is:

| # | Error string (Python source line) | Cause |
| --- | --- | --- |
| 1 | `... launch binding.worktree_path must be a non-empty canonical absolute path.` (lines 100-102) | `_is_canonical_worktree_path` (lines 32-46) rejects any value containing `/` once a drive letter is present, so a Windows path recorded with forward slashes fails |
| 2 | `... launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.` (lines 103-108) | key absent |
| 3 | `... launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.` (lines 103-108) | key absent |
| 4 | `... launch binding.delegation_receipt must be an object.` (line 123) | key absent; short-circuits the three sub-checks |
| 5 | `... launch binding.model_routing_receipt must be an object.` (line 175) | key absent; short-circuits the three sub-checks |

That is exactly five, matching the issue's observation. The `branch_name` error (lines
93-95) does not fire because `branch_name` is in the documented Claude epic schema.

**Inference, not verified:** the destination checkpoints were not available to this
session, so which of `worktree_path` or `branch_name` supplied the fifth error could not be
confirmed directly. The `worktree_path` reading is the stronger inference because the
canonicality predicate demands a pure-backslash Windows path (`ntpath.normpath(path) ==
path` and `"/" not in path`, lines 44-46), while JSON checkpoints written by an agent
normally carry forward slashes. The Python and TypeScript test fixtures avoid the issue
entirely by using POSIX paths (`tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`
line 33 uses `/repo/worktrees/child-a`;
`extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` lines 33
and 43 do the same), which is why no test caught this.

Either way the count is five, because exactly one of the two path-shape checks fires.

## 2. Does anything write the directory?

### Search commands run

| Search | Scope | Result |
| --- | --- | --- |
| `launch_binding\|launch_receipt_path\|launch_status_path\|epic-child-launches` | whole repository | 42 files |
| `epic-child-launches` (content, line numbers) | whole repository | see classification below |
| `launch_binding\|launch_receipt_path\|launch_status_path\|epic-child-launches\|LaunchBinding` | `.claude/` | 0 matches |
| `launch` (case-insensitive) | `.claude/rules/` | 1 match, in `parallel-orchestration.md`, unrelated |
| Glob `artifacts/orchestration/**` | whole repository | one file only: `artifacts/orchestration/orchestrator-state.json` |

The directory `artifacts/orchestration/epic-child-launches/` does not exist in this
repository either.

### (a) Code that READS or VALIDATES the path

- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` lines 10-14, 49-71, 103-108.
- `scripts/dev_tools/epic_planner_launch_evidence.py` line 15 (`LAUNCH_ROOT`).
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` lines 3-7, 126.
- `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts` line 8.
- `.codex/hooks/codex-epic-child-launch-attestation.ps1` line 87 and lines 60-128 — reads
  the receipt from disk and cross-checks it against the running child's environment.
- `.codex/scripts/launch-epic-child-wave.ps1` lines 432-435 — containment check that the
  supplied launch spec lives under the launch root.

### (b) Code that WRITES it — exactly one producer, on the Codex runtime only

`.codex/scripts/launch-epic-child-wave.ps1` is the sole writer:

- Line 272 computes the wave status path `wave.<wave-id>.status.json` under the artifact root.
- Line 303 computes the per-child receipt path `<launch-id>.receipt.json`.
- Line 325 writes it: `Write-CodexChildJsonCreateNew -Path $receiptPath -Value $receipt`.
- Line 156 exports the receipt path to the child process as
  `CODEX_EPIC_CHILD_LAUNCH_RECEIPT`.

Its published mirror is
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/launch-epic-child-wave.ps1`
(line 432 matches).

The Codex agent persona instructs persistence of these fields:
`.codex/agents/epic-orchestrator.toml` lines 70-74 require the checkpoint to persist "each
feature's issue/folder, unique branch/worktree, delegation receipt/id, delegation-bound
model receipt, and launch receipt/status paths", and lines 76-82 require the final
validation to pass all three flags (`require_complete`, `require_codex_topology`,
`require_codex_model_routing`).
`.agents/skills/epic-orchestrate/SKILL.md` lines 83 and 168-169 say the same.

**No Claude-runtime producer exists.** `.claude/agents/epic-orchestrator.md` line 126-127
delegates children through the in-process `Agent` tool (`isolation: "worktree"`,
`run_in_background: true`); its checkpoint-persistence instruction (lines 133-141) lists
`features[]` with `merge_status` and the four lifecycle timestamps plus the three top-level
receipt arrays, and names no launch receipt, no per-feature `delegation_receipt`, and no
per-feature `model_routing_receipt`. Its completion requirements (lines 152-162) ask only
for `require_complete=True`. `.claude/skills/epic-orchestrate/SKILL.md` lines 278-293 says
the same. There is no launcher script, no environment handoff, and no attestation hook on
the Claude surface.

### (c) Tests and fixtures that merely construct one

All of the following build path strings or in-memory objects and create nothing on disk:

- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py` line 25.
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` line 22.
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py` line 32.
- `tests/scripts/dev_tools/test_epic_planner_readiness.py` line 127.
- `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py` lines 156, 162, 236, 266.
- `tests/scripts/dev_tools/epic_planner_launch_evidence_test_support.py` lines 37, 146.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` lines 192-198.
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts` line 19.
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` lines 293-296.
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` lines 48-50.
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 59-61.
- `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts` lines 176-178.
- `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts` lines 111-216.
- `tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1` line 11 and
  `tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1` line 11 — both build
  an ordered hashtable of path strings (see lines 17-40 of the first) and never touch the
  filesystem.

**Crux, stated explicitly:** tests construct launch receipts; the only production writer is
a Codex-runtime PowerShell launcher. On the Claude runtime no production agent, skill, hook,
or script ever writes one, yet the Claude runtime is the only runtime that reaches the gate
through `require_complete` alone.

## 3. What `launch_binding` was intended to prove that `delegation_receipts[]` does not

Git history was unavailable (see the tooling-limitation note). No feature folder under
`docs/features/` documents the introduction: a content search for `launch_receipt_path`,
`launch-binding`, or `launch binding` across `docs/` returned only this issue's own folder,
the promoted potential-feature record, and three `parallel-*` research documents that cite
the module as prior art. `.claude/rules/orchestrator-state.md` is silent. The original epic
specification `docs/features/completed/2026-07-02-epic-orchestrate-275/spec.md` line 185
documents the `require_complete` gate as exactly two conditions — every feature merged or
worktree-removed, and a non-empty `epic_merge_pr.merge_commit_sha` — with no launch
binding, which places the launch-binding extension after that specification.

The intent is nonetheless **recoverable from the consumer**, and the consumer is
unambiguous. `.codex/hooks/codex-epic-child-launch-attestation.ps1` lines 60-128 read the
on-disk receipt from inside the running child process and require exact equality between
the receipt and the child's own environment across three path pairs (lines 95-104:
receipt path, spec path, worktree path) and seven identity pairs (lines 105-118: launch id,
delegation id, execution context, deployment agent, model, reasoning effort, and the SHA-256
of the agent profile), plus containment of the receipt and spec under the launch root
(lines 124-125) and equality of the child's repository root with the receipt's declared
worktree (line 121).

That yields a precise answer:

**`launch_binding` proves a cross-process binding that `delegation_receipts[]`
structurally cannot.** The receipt is written to disk by the launcher *before* the child OS
process starts (`Write-CodexChildJsonCreateNew`, an exclusive-create write, line 325 of the
launcher), handed to the child only through the environment (line 156), and verified from
*inside* the child by a hook the child does not control. It is therefore an independent
witness that a specific process, in a specific worktree, under a specific agent profile
hash, model, and reasoning effort, corresponds to a specific delegation id.

`delegation_receipts[]` is a different kind of artifact. It is written by the orchestrator
into the orchestrator's own checkpoint after the fact, and the epic specification's example
shape is `[{ "agent_name": "orchestrator" }, { "agent_name": "pr-author" }]`
(`docs/features/completed/2026-07-02-epic-orchestrate-275/spec.md` line 161) — an
agent-name list with no per-feature identity, no worktree, no profile hash, and no
independent witness. It is self-attestation.

**The strongest inference about scope:** the launch binding was designed for the Codex
epic runtime, where children are separate OS processes started by a launcher script and the
binding problem is real. On the Claude runtime children are started by the in-process
`Agent` tool with `isolation: "worktree"`, so there is no launcher to write the receipt, no
environment handoff, and no attestation hook to read it — the binding the receipt exists to
prove is supplied by the tool itself. The defect is that the activation condition at line
273 admitted `require_complete`, which is the generic completion flag every runtime uses,
rather than restricting the gate to the two Codex-specific flags that accompany the runtime
where the producer lives.

## 4. Candidate resolutions

Assessment criteria applied to each: residual discriminating power, number of runtimes that
must change, survival of the push-down, and whether the gate can still fail on a genuinely
incomplete epic.

### Recommended — scope the gate to evidence that a producer actually writes

Change the activation logic so that, under `require_complete` **alone**, a feature is
subjected to launch-binding validation **only when it carries `launch_receipt_path` or
`launch_status_path`**. Under `require_codex_model_routing` or `require_codex_topology` the
gate remains unconditional and byte-identical to today.

Rationale:

- **Residual discriminating power is higher than a plain removal.** A Codex checkpoint that
  records a partial or malformed launch binding still fails under `require_complete` alone,
  because the presence of either path key re-arms the full five-check set. Only a checkpoint
  that records no launch evidence at all — which is precisely the Claude shape, and which no
  Claude producer can ever change — is exempt.
- **The `require_complete` gate keeps every check it was specified to make.**
  `_validate_completion` (lines 362-402 of `validate_epic_orchestrator_state.py`) still
  fails on any feature not `merged`/`worktree_removed` and on a missing or empty
  `epic_merge_pr.merge_commit_sha`. The wave-barrier invariant, `merge_status` enum
  membership, dependency-cycle rejection, `waves[]` consistency, and the required-key set
  all run unconditionally and are untouched. Applied to the destination epic
  `quickfiler-suite-determinism-foundation`, the twenty launch-binding errors disappear and
  the one genuine descoped-child error remains, which is the outcome the issue's integration
  scenario demands.
- **It matches an established, documented pattern in this exact validator family.**
  `.claude/rules/orchestrator-state.md` already defines three key-gated invariant blocks
  (`remediation_loop`, `human_interaction`, `complexity_assessments`,
  `model_routing_receipts`) whose stated contract is that they "apply only when the
  checkpoint contains" the key, and are otherwise byte-identical to a plain call. This
  change makes the launch-binding block behave the same way under the generic flag.
- **Two runtimes change** (Python helper and TypeScript port), which is the minimum for any
  option that alters validator behaviour, because the parity relation is byte-identical
  error strings.
- **It survives the push-down.** The changed files are the repository's own
  `scripts/dev_tools/` module and the extension source. The extension is compiled and
  shipped as the MCP server, so a destination receives the fix when it updates the
  extension; no destination-side `.claude` edit is involved, so no sync destroys it.
- **The gate can still fail.** Two existing negative tests prove it
  (section 7), and the presence-gated arm adds a third failure mode.

### Rejected alternatives

**Option 1 — make `epic-orchestrator` write the launch receipt.** Rejected. On the Claude
runtime the same agent would write both the receipt and the checkpoint it is checked
against, so the artifact would be self-attestation and would prove nothing that
`delegation_receipts[]` does not already prove; the cross-process binding that gives the
Codex receipt its value (section 3) does not exist for an in-process `Agent` delegation.
It also requires the agent to synthesise, per feature, a canonical backslash-normalised
absolute `worktree_path`, a unique `branch_name`, a `delegation_receipt` with a unique
`delegation_id`, and a `model_routing_receipt` whose `execution_context` is exactly
`epic_execution_child` — six coupled fields specified only in validator code, with no
producer-side test, which is the same class of prose-to-validator drift that produced this
bug. Changes required: `.claude/agents/epic-orchestrator.md`,
`.claude/skills/epic-orchestrate/SKILL.md`, both of their bundled mirrors, and both
validator runtimes.

**Option 2 — point the gate at `delegation_receipts[]`.** Rejected on the
discriminating-power criterion. The epic checkpoint's top-level `delegation_receipts[]`
carries agent names only (spec line 161); it has no per-feature key, so a per-feature
cross-check against it would reduce to "an `orchestrator` delegation receipt exists
somewhere", a single boolean for the whole epic that is true for every epic that ever
delegated anything. That is a gate that effectively always passes, which the issue
correctly identifies as worse than the current state. Making it meaningful would require
extending the receipt shape to carry per-feature identity — which is Option 1 with
different field names, and inherits Option 1's objections.

**Option 3 as stated — drop the requirement outright** (remove `require_complete` from the
activation set at line 273, with no presence gate). Not rejected on correctness: it fixes
the defect, changes the same two files, survives the push-down identically, and leaves
`require_complete` with exactly the discriminating power the epic specification assigned it
at line 185. It is rejected only as second-best, because it discards the free extra
discrimination the presence gate retains for a Codex checkpoint validated with
`require_complete` alone. A reviewer who prefers the smaller diff can adopt it; the file
list in section 6 is unchanged either way.

## 5. Push-down and parity surface

Every copy that must move together, with the relation each pair must satisfy:

| Pair | Relation | Evidence |
| --- | --- | --- |
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` and `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` | **Behavioural parity with byte-identical error strings.** Not a file copy; a hand-maintained port. | `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` lines 51-53 ("error-message strings are identical to the Python source"); `.claude/rules/parallel-orchestration.md` records the same relation and its known divergence classes for the sibling parallel port |
| Any file under `.claude/` and its twin under `extensions/drm-copilot/resources/claude-customizations/.claude/` | **Byte-identical mirror**, excluding `.claude/settings.local.json` and `.claude/agent-memory/**` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` lines 101-126: every repo `.claude` file must exist in the bundle with equal content |
| `.claude/lib/orchestrator-state/*.psm1` and their bundle twins | **Byte-identical mirror plus core-pack manifest membership** | `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` lines 60-104 |
| `.codex/**` and `.agents/**` and their twins under `extensions/drm-copilot/resources/codex-and-agents-customizations/` | Mirror, asserted by `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | file present at that path |
| `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json` | **Byte-for-byte** | `.claude/rules/parallel-orchestration.md`, Enforcement section |

Applying the recommendation, the surfaces that must change are:

1. `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` (authoritative logic).
2. `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`
   (parity port; must produce the identical error strings for the identical inputs).
3. If, and only if, `.claude/rules/orchestrator-state.md` is amended to record the scoping
   decision, its bundle twin
   `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
   must be updated byte-identically in the same commit, or
   `test_push_down_claude_resource_contracts.py` fails.

Surfaces that must **not** change and why:

- `.claude/lib/orchestrator-state/**` — implements none of this gate (verified zero
  matches); no PowerShell parity obligation is created.
- `.claude/hooks/validate-orchestrator-output.ps1` — for the epic artifact type it performs
  a structural check only (lines 152-196, 267-275) and never passes `require_complete`.
- `.codex/**` and `.agents/**` — the Codex runtime keeps the gate unchanged, because it
  passes both Codex flags (`.codex/agents/epic-orchestrator.toml` lines 76-82;
  `.agents/skills/epic-orchestrate/SKILL.md` lines 168-169), which remain in the activation
  set.
- `extensions/drm-copilot/src/mcp-tool-definitions.ts` and
  `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` — the
  `require_complete` description at `mcp-tool-definitions.ts` lines 423-427 says nothing
  about launch bindings, so no description change is required. Both Codex flags are already
  exposed (`mcp-tool-definitions.ts` lines 433-442;
  `extensions/drm-copilot/src/mcp-tool-inputs.ts` lines 459-460), so the Codex path keeps
  its gate through the MCP surface after the change.
- `scripts/dev_tools/validate_orchestration_artifacts.py` — the epic subparser already
  carries all three flags (lines 284-300) and dispatches all three (lines 422-430).

## 6. Concrete file list for the fix

### Production files the diff would WRITE

- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`
- `.claude/rules/orchestrator-state.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`

The last two are a single logical change recorded twice under the byte-identical mirror
relation of section 5. They add one short prose section stating that the epic
launch-binding block is scoped to the Codex enforcement flags and is key-gated under
`require_complete`. A reviewer who judges the prose record out of scope for a bug fix can
drop both and the remaining two files still constitute a complete fix; they are listed
because the rule file is the repository's declared enforcement-documentation mechanism for
this validator family and its silence is a contributing cause of the defect.

### Test files the diff would WRITE

- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts`

### Read-only policy citations (NOT written by this diff)

These files are consulted for policy compliance and are not amended:

- `CLAUDE.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/python.md`
- `.claude/rules/typescript.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/tonality.md`
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

Note on tier classification: `quality-tiers.yml` is **absent** from the repository root
(confirmed by glob; independently recorded at
`docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/other/quality-tiers-classification.2026-08-07T19-58.md`).
The uniform thresholds of `.claude/rules/quality-tiers.md` therefore apply without a
tier-specific overlay.

## 7. Existing test coverage of the epic `require_complete` gate

### Python (pytest)

`tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`:

| Test | Line | Exercises | Fate under the recommendation |
| --- | --- | --- | --- |
| `test_model_routing_gate_accepts_complete_launch_binding` | 78 | Codex model-routing flag, full binding | unchanged |
| `test_topology_gate_activates_launch_binding_validation` | 88 | Codex topology flag activates the gate | unchanged |
| `test_unlaunched_feature_does_not_require_binding_under_routing_gate` | 104 | `skip_not_started` under a Codex flag | unchanged |
| `test_launch_binding_is_dormant_without_an_enforcement_gate` | 125 | no flag, no errors | unchanged |
| `test_require_complete_requires_binding_for_every_feature` | 136 | **the defect, asserted as intended behaviour** — a `not_started` feature missing `model_routing_receipt` must fail under `require_complete` alone | **MUST CHANGE.** This is the test that pins the bug. Replace with a presence-gated pair: a feature carrying neither launch path key produces no launch-binding errors under `require_complete` alone; a feature carrying `launch_receipt_path` but missing `model_routing_receipt` still produces the error |
| `test_require_complete_accepts_complete_persisted_binding` | 154 | full binding plus merged state passes | unchanged (still passes) |
| `test_require_complete_rejects_unmerged_feature` | 167 | **negative case — gate still fails** on `merge_status` not merged | unchanged; this is one of the two guarantees the gate remains able to fail |
| `test_require_complete_rejects_missing_merge_commit_sha` | 183 | **negative case — gate still fails** on missing `epic_merge_pr.merge_commit_sha` | unchanged; second guarantee |
| `test_require_complete_remains_disabled_by_default` | 196 | default is off | unchanged |
| parametrised path/receipt-mismatch cases | 239, 262, 299, 316, 335, 365, 381 | all use `require_codex_model_routing=True` | unchanged |

New Python coverage required: a feature that carries `launch_receipt_path` but omits
`launch_status_path` must still fail under `require_complete` alone (proves the presence
gate re-arms rather than exempting), and a feature carrying neither must pass.

`tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` lines 160-215
build a fully-populated epic fixture including both launch paths and assert CLI dispatch;
unchanged, because the fixture keeps the keys and therefore keeps the gate armed.

`tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` contains no
`require_complete` test (searched: one match, `test_validate_accepts_completed_lifecycle_hint_dependency`
at line 333, unrelated). No change.

### TypeScript (Jest)

`extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts`:

| Test | Line | Fate |
| --- | --- | --- |
| `accepts complete evidence under the model-routing gate` | 71 | unchanged |
| `activates under the topology gate` | 80 | unchanged |
| `does not require evidence before the feature launches` | 94 | unchanged |
| `remains dormant without a routing or completion gate` | 115 | unchanged |
| `requires evidence for every feature under requireComplete` | 126 | **MUST CHANGE** — direct twin of the Python test at line 136 |
| `accepts complete persisted evidence at completion` | 141 | unchanged |
| remaining shape and uniqueness cases | 240, 256, 292 | unchanged |

`extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts`:

| Test | Line | Fate |
| --- | --- | --- |
| `rejects requireComplete when a feature is not merged/worktree_removed` | 241 | **negative case — unchanged**, guarantees the gate can still fail |
| `rejects requireComplete when epic_merge_pr.merge_commit_sha is missing` | 256 | **negative case — unchanged**, second guarantee |
| `accepts a fully complete checkpoint under requireComplete` | 271 | unchanged; the fixture populates both launch paths at lines 293-296, so the gate stays armed and still returns an empty error list |
| `defaults requireComplete to false (backward-compatible)` | 305 | unchanged |

New TypeScript coverage required: the twins of the two new Python cases, with byte-identical
error strings.

### PowerShell (Pester)

**None exists.** A content search for `launch_receipt_path` and `launch_status_path` across
`tests/scripts/claude-lib/` returned zero files, consistent with `.claude/lib/orchestrator-state/`
implementing none of this gate. The Pester suites that mention `epic-child-launches`
(`tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1`,
`epic-child-launch-attestation.Tests.ps1`, `epic-child-launch-hardening.Tests.ps1`,
`epic-child-worktree-launcher.Tests.ps1`, `codex-worktree-binding-hook.Tests.ps1`) cover the
Codex launcher and its attestation hook, not the checkpoint validator, and are unaffected.

## 8. Related exposure — the epic planner surface (out of scope, recommend filing separately)

`scripts/dev_tools/validate_epic_planner_state.py` line 331 calls
`validate_epic_planner_child_launch_bindings` unconditionally inside its
`require_ready_for_execution` block (line 320). That helper
(`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` lines 250-261) sets
`skip_not_started=False`, `expected_execution_context="epic_preparation_child"`, and
`require_generated_orchestrator=True`, the last of which restricts `agent_name` to the five
Codex-generated persona names at lines 15-23 (`orchestrator-c1` through `orchestrator-c4`).
Those personas do not exist in the Claude runtime.

This is the same defect shape. It is **not currently reachable from the Claude runtime**:
neither `.claude/agents/epic-planner.md` nor `.claude/skills/epic-plan/SKILL.md` mentions
`require_ready_for_execution` (searched: zero matches). The exposure is therefore latent
rather than active, which is why it is recorded here as a follow-up rather than folded into
#524. Folding it in would widen the diff to
`scripts/dev_tools/validate_epic_planner_state.py`,
`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, and four further test
files without a reproducing symptom to verify against.

## 9. Testing implications (strategy only, no test code)

Per `.claude/rules/general-unit-test.md`, both changed modules are pure functions over
in-memory JSON text, so every case is a unit test with no filesystem, no clock, and no
temporary files. The four scenario groups that must be covered in **both** runtimes, with
byte-identical error strings:

1. **Positive, Claude shape.** A completion-ready epic checkpoint whose features carry
   neither `launch_receipt_path` nor `launch_status_path` returns an empty error list under
   `require_complete` alone. This is the destination reproduction.
2. **Positive, Codex shape.** A completion-ready checkpoint carrying full launch bindings
   returns an empty error list under `require_complete` alone and under each Codex flag —
   proving the change is a no-op for a well-formed Codex checkpoint.
3. **Negative, partial binding.** A checkpoint carrying `launch_receipt_path` but missing
   `launch_status_path`, `delegation_receipt`, or `model_routing_receipt` still fails under
   `require_complete` alone. This is what keeps the presence gate from being an exemption.
4. **Negative, genuine incompleteness — the discrimination guarantee.** A checkpoint whose
   feature is not `merged`/`worktree_removed`, and separately one with an absent
   `epic_merge_pr.merge_commit_sha`, still fail under `require_complete`. Existing tests at
   Python lines 167 and 183 and TypeScript lines 241 and 256 already carry this and must be
   left intact; they are the evidence that the fix did not make the gate always pass.

Regression evidence should reproduce the destination shape: a four-feature epic checkpoint
with no launch keys produces twenty launch-binding errors before the change and zero after,
while a single deliberately unmerged feature keeps producing exactly one completion error in
both runs.

Coverage obligation under `.claude/rules/quality-tiers.md`: line coverage at or above 85
percent and branch coverage at or above 75 percent for both Python and TypeScript, with no
regression on changed lines. The changed lines are a single conditional in each runtime and
are directly exercised by scenarios 1 and 3.
