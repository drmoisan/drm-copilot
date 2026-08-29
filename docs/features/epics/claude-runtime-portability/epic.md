---
epic: claude-runtime-portability
integration_branch: epic/claude-runtime-portability-integration
created_at: 2026-08-29T15:07:00Z
# PLACEHOLDER MANIFEST. The issue_num values 901-904 are placeholders assigned at
# authoring time because no child issue exists yet. Each is back-filled with the real
# GitHub issue number from that child's promotion receipt as preparation completes, and
# the manifest is committed in resolved form before the kickoff artifact is written.
# depends_on uses issue_num values (the canonical primary-key form).
intent:
  epic_type: enabler
  business_outcome_hypothesis: The .claude/** runtime payload ships to consumer repositories that guarantee no Python interpreter, no Poetry, and no scripts/dev_tools tree. Removing the remaining executable Python invocations from that payload, and correcting the PowerShell calling conventions its callers use, makes every mandatory step of the parallel and epic orchestration surfaces executable on a destination runtime rather than silently unavailable there.
  leading_indicators:
    - No file under .claude/** contains an executable python or poetry invocation that a mandatory procedure step depends on.
    - The lane-assertion diagnostic runs to completion on a destination runtime with no Python interpreter present.
    - A fresh clone of a consumer repository that received a push-down contains no tracked batch-budget session-state file.
  nfrs:
    - Line coverage >= 85% for every new or modified PowerShell and TypeScript module, per .claude/rules/quality-tiers.md.
    - The PowerShell/bash lane-assertion port produces output identical to scripts/dev_tools/parallel_lane_assertion.py over a shared parity corpus.
    - Every edit to a .claude/** file is mirrored byte-identically into extensions/drm-copilot/resources/claude-customizations/.claude/**, as enforced by tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py.
features:
  - issue_num: 901
    feature_folder: blast-radius-powershell-calling-convention
    depends_on: []
  - issue_num: 902
    feature_folder: batch-budget-state-portability
    depends_on: []
  - issue_num: 903
    feature_folder: caller-site-invocation-correctness
    depends_on: [901]
  - issue_num: 904
    feature_folder: remove-remaining-python-invocations
    depends_on: [903]
---

# Epic: Claude Runtime Portability

## Goal

The `.claude/**` payload is published into consumer repositories by the push-down mechanism. Those
destinations guarantee no Python interpreter, no Poetry, and no `scripts/dev_tools` tree. Issue #475
already removed the Python dependency from the two discovery-gate hooks on exactly this reasoning.
This epic finishes that work for the orchestration skills and corrects the PowerShell calling
conventions that the payload's own callers use, so that a mandatory step of a published procedure is
executable at its destination rather than silently unavailable there.

## Wave Assignment

Computed by longest-path layering over the dependency DAG per the `epic-orchestrate` skill:

| wave | features |
| --- | --- |
| 0 | 901 (Feature A), 902 (Feature B) |
| 1 | 903 (Feature C) |
| 2 | 904 (Feature D) |

`wave(901) = 0` and `wave(902) = 0` (empty `depends_on`); `wave(903) = 1 + wave(901) = 1`;
`wave(904) = 1 + wave(903) = 2`. The graph is cycle-free and every `depends_on` entry resolves.

Waves 1 and 2 are serialized because Feature C and Feature D both rewrite
`.claude/skills/parallel-plan/SKILL.md` — C at its `Import-Module` call site, D at its
lane-assertion invocation site. The serialization is a genuine file-contention edge, not a stylistic
ordering.

## Cross-Cutting Constraint: the push-down mirror

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
(`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, lines 101-126) asserts that every
repository `.claude/**` file — excluding `settings.local.json` and the `.claude/agent-memory/**`
subtree — exists in `extensions/drm-copilot/resources/claude-customizations/.claude/**` and is
**byte-identical** to its repository counterpart.

Every feature in this epic that edits a `.claude/**` file must therefore make the identical edit in
the bundle copy in the same PR, or that test fails. This doubles each feature's touched-file count
and is the single most likely cause of an avoidable CI failure in this epic. It is stated once here
so that no child feature rediscovers it during execution.

## Decomposition Rationale and Per-Feature Scope

### Feature A (901, wave 0, C3) — Blast-radius PowerShell calling-convention hardening

Establishes the fail-fast import convention for the shared `.claude/lib/**` modules and corrects the
JSON date-coercion hazard at the parse sites that actually exist.

Verified scope inputs:

- **Confirmed.** No file under `.claude/lib/**` (37 files across nine subdirectories) sets
  `$ErrorActionPreference`. It appears only in `.claude/hooks/*.ps1`. The fail-fast import guard is
  genuine, unambiguous work.
- **Corrected.** `.claude/lib/blast-radius/BlastRadiusValidation.psm1:124` delegates to
  `Get-RequiredText` (`BlastRadiusConfig.psm1:52-94`), which enforces a **non-empty** string, not
  merely a string: it throws `"computed_at must be a string, got <Type>."` on a type mismatch and
  `"computed_at must not be empty."` on whitespace.
- **Corrected.** The premise that `-DateKind` is used nowhere is false, and the premise that a
  `-DateKind String` helper is needed by "every JSON parse touching a radius object" has no call
  sites. No module under `.claude/lib/blast-radius/` calls `ConvertFrom-Json` at all; those modules
  operate on an already-parsed mapping supplied by the caller. `-DateKind String` is already used
  correctly on the test side at `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:318`,
  with an explanatory comment at lines 314-316. The real production exposure is the checkpoint parse
  at `.claude/lib/orchestrator-state/OrchestratorState.psm1:175`, with
  `.claude/lib/hook-payload/HookPayload.psm1:262` and
  `.claude/lib/discovery-validation/DiscoveryValidation.psm1:338` as the other two `ConvertFrom-Json`
  sites under `.claude/lib/**`. Feature A retargets the date-coercion work to those sites.
- **Corrected — already satisfied.** The `if ($result)` truthiness hazard is already pinned by a
  regression test. `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:87-108`
  asserts `$result['conflict']` is `$false` while `[bool]$result` is `$true`, and a companion test at
  lines 110-118 asserts the comment-based help documents the divergence. The warning text at
  `.claude/lib/blast-radius/BlastRadius.psm1:432-441` is present as described. This item is a
  verification-only acceptance criterion; no new test is required unless preparation finds a gap the
  existing pair does not cover.

**Complexity C3.** Signal `cross_module_contract_change`: changing JSON date coercion at the
checkpoint parse site alters a value contract consumed across module boundaries, and adding a
fail-fast preference to shared library modules changes error propagation for every caller.

### Feature B (902, wave 0, C3) — Batch-budget state portability

Verified scope inputs:

- **Confirmed in mechanism, corrected in artifact.** No `powershell-batch-budget.default.json` file
  exists in the repository, and `.claude/state/` does not exist in this worktree at all — the
  directory is git-ignored at `.gitignore:68` and is created only at runtime. The defect is real
  nonetheless: `.claude/hooks/enforce-powershell-batch-budget.ps1` falls back to the literal string
  `'default'` for the session id at line 157 (parameter default) and lines 248-251 (entry point,
  when `$env:CLAUDE_SESSION_ID` is unset), so every session without a resolved session id shares one
  `powershell-batch-budget.default.json` counter.
- **Confirmed.** The hook has no TTL, timestamp check, or automatic reset. Its own deny message
  instructs the operator to delete the state file manually.
- **Confirmed.** Recorded paths are the raw `file_path` string from the tool payload, normalized only
  by `-replace '\\', '/'` (lines 122, 183). There is no `Resolve-Path`, no canonicalization, and no
  check that a recorded path falls under the current worktree root.
- **Corrected, and larger than stated.** The push-down mechanism does not merely fail to deliver the
  `.claude/state/` ignore line — **no destination-side `.gitignore` writer exists anywhere in the
  push-down pipeline.** `pushDownClaudeCustomizationsServiceCall`
  (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:166-201`) copies from the
  pre-built bundle root, and `enumerateSourceFiles`
  (`extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts:156-175`) walks the
  two root folders `.claude` and `config`, excluding only `.claude/settings.local.json`. Nothing in
  `extensions/drm-copilot/src` reads or writes a `.gitignore`. Fixing this is net-new TypeScript
  capability in the extension, not a one-line addition, which is why Feature B is banded C3 rather
  than C2.

**Complexity C3.** Signals `cross_module_contract_change` (the push-down payload contract gains a
destination-side ignore-file obligation) and `concurrency_or_ordering` (the shared-counter defect is
a session-state collision).

### Feature C (903, wave 1, C2) — Caller-site invocation correctness

Depends on Feature A because these call sites must reflect the import convention A establishes.

Verified scope inputs — all three relative `Import-Module` call sites confirmed at the stated lines:

- `.claude/skills/parallel-plan/SKILL.md:185`
- `.claude/skills/parallel-add/SKILL.md:64`
- `.claude/agents/parallel-planner.md:151`

Each is corrected to use `pwsh`, a root-anchored module path, `-ErrorAction Stop`, and the
`$result['conflict']` read pattern. The PowerShell 5.1 execution-policy trap — `Import-Module` of a
`.psm1` is blocked under the default PS5.1 policy, so `pwsh` is mandatory — is documented at each of
the three sites.

**Known incomplete enumeration (recorded 2026-08-29, after Feature C was prepared).** An exhaustive
re-derivation over the full family of module-load spellings (`Import-Module`, `using module`, `ipmo`,
`-Name`, and bare `.psm1` path references) found a **fourth** site of the identical defect class that
Feature C does not cover: `.claude/skills/mermaid-diagram/SKILL.md:28`, which reads
`Import-Module ./.claude/lib/mermaid/MermaidValidation.psm1 -Force` — a relative path with no `pwsh`
qualifier and no `-ErrorAction Stop`, plus a byte-identical bundle mirror at the same line.

Feature C's own count of three is not wrong for what its acceptance criteria enumerate: they are
scoped specifically to the `BlastRadius.psm1` relative-import instruction text. The mermaid site
loads a different module and therefore falls outside that wording. It is nonetheless the same bug,
and it is currently addressed by no feature in this epic. It requires an explicit disposition —
either an amendment to Feature C's scope or a separate follow-up issue — before the epic is
considered to have closed the relative-import defect class.

For completeness: all 33 `Import-Module` call sites inside `.ps1`/`.psm1` files use
`$PSScriptRoot`-anchored `Join-Path` forms. Those are working-directory independent and are correctly
out of scope.

**Complexity C2.** These are localized prose corrections to agent and skill instruction files with no
new logic, bounded to three files plus their three bundle mirrors.

### Feature D (904, wave 2, C3) — Remove remaining Python invocations

Depends on Feature C because both rewrite `.claude/skills/parallel-plan/SKILL.md`.

Verified scope inputs. There are **five** infrastructure-class executable Python invocation sites
under `.claude/**`, not the four the epic intake stated, and they are distributed differently than it
claimed. `parallel-plan/SKILL.md` contains **one** such site, not two.

This table was corrected on 2026-08-29 after an exhaustive re-derivation using the full family of
Python invocation spellings (`python`, `python3`, `py -3`, `poetry run`, `python -m`, `uv run`,
`pipx`, and fenced-block `scripts/dev_tools` references) cross-checked by two independently
constructed searches. The original four-site table came from a single-pass search and both
under-counted and mis-cited.

| # | site | fix |
| --- | --- | --- |
| 1 | `.claude/skills/epic-orchestrate/SKILL.md:296` | Trivial. The MCP form is already offered alongside it; delete the CLI spelling. |
| 2 | `.claude/skills/parallel-orchestrate/SKILL.md:482` | Trivial. Already introduced as "or the equivalent CLI invocation"; delete the alternative. |
| 3 | `.claude/skills/parallel-orchestrate/SKILL.md:817` | `parallel_drift_detection_cli`. **Non-goal — see below.** |
| 4 | `.claude/skills/parallel-plan/SKILL.md:315` | `parallel_lane_assertion`. Requires the new port. Note the line is 315, not the 317 originally cited; the earlier figure was derived from a branch carrying unmerged commits. |
| 5 | `.claude/skills/parallel-remove/SKILL.md:112` | `parallel_mutation_abandon_cli`. **Newly identified.** A fenced `bash` block introduced by the words "the single deterministic CLI invocation below and through nothing else" — a mandatory, hook-gated procedure step of the same infrastructure class as site 3. Requires an explicit disposition before Feature D can be considered complete. |

Each of the five has a byte-identical bundle mirror that must receive the same edit.

A separate class of Python invocation exists under `.claude/**` and is deliberately excluded: the
`poetry run black|ruff|pyright|pytest` toolchain commands in `.claude/rules/python.md:13-16`,
`.claude/skills/python-qa-gate/SKILL.md:30-33`, and
`.claude/skills/feature-review-workflow/SKILL.md:108`. Those run only when Python source is being
edited and are not an infrastructure dependency of the harness itself. Feature D's acceptance
criteria must state this exclusion explicitly, because the literal phrase "executable Python
invocations under `.claude/**`" does not exclude them on its own.

**The lane-assertion problem is not the rule contradiction the intake described.**
`.claude/rules/parallel-orchestration.md` (invariant M8) and `.claude/skills/parallel-plan/SKILL.md`
lines 324-331 **agree**: both state the diagnostic's findings are advisory-only and never block. The
actual defect is narrower and real. The diagnostic's *invocation* is a mandatory procedure step
(`SKILL.md:315-317`, "Immediately after the conflict-edge set is derived and before anything consumes
it, run the lane-assertion diagnostic") and a required planner completion-report line item
(`SKILL.md:571`), yet its only implementation is Python, which the destination runtime does not
guarantee. Writing the PowerShell/bash port therefore remains the correct fix; the justification is
that a required step must be executable, not that two documents disagree.
`docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/spec.md:51` records
that the port was explicitly deferred when the diagnostic landed.

**Non-goal: the drift-detection CLI port (site 3).** The `parallel_drift_detection_cli` dependency
appears deliberate rather than accidental. `.claude/agents/parallel-orchestrator.md:92-96` explicitly
retains the two `poetry run python -m` grants "for the repository-local paths that still need an
interpreter" and names the drift-detection CLI as one of them. Porting it is a second net-new
implementation that was not covered by the epic's locked decision to port the lane-assertion
diagnostic. It is recorded here as an explicit non-goal pending a separate decision, so that Feature
D's scope boundary is unambiguous and the omission is not later read as an oversight.

**Narrowed: the discovery-gate hook comments.** The `scripts/dev_tools` references in
`.claude/hooks/enforce-discovery-artifact-gate.ps1:49-52` and
`.claude/hooks/validate-discovery-artifact-gate.ps1:50-52` are not stale drift. Both read "This no
longer invokes a Python interpreter (issue #475)" and exist to record *why* the payload must not
depend on Python. Deleting them removes the rationale that prevents reintroduction. Feature D
preserves the rationale and at most rewords it; removal is out of scope.

**Complexity C3.** Signal `cross_module_contract_change`: the new port must agree with
`scripts/dev_tools/parallel_lane_assertion.py` over a shared parity corpus, which is a cross-runtime
output contract of the kind the existing bash parity suites
(`tests/shell/parallel_cohorts_parity.bats`, `tests/shell/parallel_manifest_parity.bats`) already
establish for the sibling modules.

## Non-Goals

- Porting `scripts/dev_tools/parallel_drift_detection_cli.py` to PowerShell or bash (see Feature D).
- Removing the `scripts/dev_tools` prose citations that legitimately identify the Python modules as
  the authoritative reference implementations, per `.claude/rules/parallel-orchestration.md`.
- Deleting the issue #475 rationale comments in the two discovery-gate hooks.
- Any change to TaskMaster-repository code. The TaskMaster framing in the originating bug report is
  the motivating consumer-repository evidence, not the target of the fix; this epic touches only the
  `.claude/**` runtime surface, its bundle mirror, and the push-down code that publishes it.
