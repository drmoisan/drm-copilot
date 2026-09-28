# Research: Preimplementation gate rejects an absolute checkpoint path (Issue #516)

- **Issue:** #516
- **Feature folder:** `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516`
- **Branch under study:** `bug/preimplementation-gate-rejects-absolute-checkpoint-path-516`, based on `origin/bug/preimplementation-gate-blocks-planner-surfaces-535` (head `c308dd92`), not on `origin/main`
- **Timestamp:** 2026-08-23T23-40
- **Author:** task-researcher

**Base-state note.** PR #536 (issue #535) is open and unmerged and rewrote the same hook. Everything described below as "current" is the state on this branch head, including the seven-literal `$script:CheckpointPaths` array and the `Test-PreparationModeDelegation` helper. Those are base state for this item, not prior work of it.

---

## 1. Current State

### 1.1 The four hook copies and their two families

| Copy | Family | Payload plumbing |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | Claude (canonical) | `Import-Module` of `../lib/hook-payload/HookPayload.psm1`; uses `Resolve-ClaudeHookToolInput` and `Get-ClaudeHookToolInputString` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | Claude (bundle mirror) | identical; verified byte-identical by reading both |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | Codex (canonical) | dot-sources `codex-pretooluse-file-mapping.ps1`; defines its own `Get-StringProperty`; no `HookPayload.psm1` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | Codex (bundle mirror) | identical to the canonical Codex copy |

The two families are **not** byte-identical to each other. Beyond the payload plumbing they differ in three further ways that the fix must respect:

1. The Codex `Invoke-OrchestrationPreimplementationGateDecision` receives a **re-serialized mapped tool_input** only — the entry point builds a fresh one-key object holding just `file_path` and passes that. The envelope root, including any `cwd`, is discarded before the decision function is reached.
2. The Codex `Test-ImplementationCommand` additionally parses `apply_patch` file markers and calls `Test-ImplementationPath` with **repo-relative** paths harvested from the patch text. Any change to `Test-ImplementationPath` must be a no-op for those.
3. The Codex copy throws on malformed mapped JSON and allows on empty input; the Claude copy fails closed with a deny for both. Neither behaviour is in scope here.

### 1.2 The exact defect surface

Three functions in each copy participate in the path classification, and only two of them are defective.

```powershell
# Invoke-OrchestrationPreimplementationGateDecision (both families)
$normalized = ([string]$filePath) -replace '\\', '/'
$requiresReadyCheckpoint = Test-ImplementationPath -NormalizedPath $normalized
```

Separators are normalized; the workspace root is never stripped. `Test-ImplementationPath` then applies two exemptions and one extension test:

```powershell
if (Test-FeatureDocumentationOrEvidencePath -NormalizedPath $NormalizedPath) { return $false }
if ($script:CheckpointPaths -contains $NormalizedPath) { return $false }
return $NormalizedPath -match '\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$'
```

- `Test-FeatureDocumentationOrEvidencePath` uses `$NormalizedPath.StartsWith('docs/features/active/')` — **defective for an absolute path.**
- The checkpoint exemption uses `-contains` against seven repo-relative literals — **defective for an absolute path.**
- The extension regex is unanchored and correct for both spellings.

A third `StartsWith('docs/features/active/')` appears at line 188 inside `Test-OrchestrationReady`. That one reads the **checkpoint's own `feature-folder` value**, which is repo-relative by the checkpoint contract, not a tool-supplied path. **It must not be changed.** Conflating the two is the most likely over-reach in this item.

### 1.3 Confirmation of the "bootstrap window" characterization — refined, not refuted

The parent's characterization is correct in effect but too narrow as stated, and the difference determines how acceptance conditions must be written.

Reading the control flow: a misclassified path sets `$requiresReadyCheckpoint = $true`, after which the gate consults the checkpoint and returns **allow** whenever `Test-OrchestrationReady` succeeds. So the misclassification is *masked* — not absent — whenever readiness holds.

The precise statement is: **the exemptions are load-bearing only while `artifacts/orchestration/orchestrator-state.json` is absent, unparseable, or not-ready.** That is a superset of the bootstrap window; it also covers a partially-written or field-incomplete checkpoint mid-run, which is exactly the state observed in this worktree when the parallel-planner checkpoint write was denied.

**Consequence for acceptance conditions (mandatory).** Every new test case — allow *and* deny — must supply an explicit not-ready `-CheckpointRaw`. A case that omits it falls back to `Get-CheckpointContent`, which reads the on-disk checkpoint relative to the process CWD. That file exists in this worktree (`artifacts/orchestration/orchestrator-state.json` is the only match for the glob `**/artifacts/orchestration/*.json` in the tree) and is ready during an orchestrated run, so an allow assertion would pass vacuously and a deny assertion would read allow. The 535 plan already codified this rule for its own cases (`ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false`); this item inherits it.

### 1.4 Sibling hooks already solve this problem — and the repository has a settled idiom for it

Four in-repo implementations of the same classification already handle the absolute spelling, all with the same construction:

| File | Construction | Comment in source |
| --- | --- | --- |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` (line 196) | `-match '(^|/)artifacts/orchestration/orchestrator-state\.json$'` | — |
| `.claude/hooks/enforce-completion-consistency.ps1` (line 96) | same | — |
| `.claude/hooks/enforce-evidence-locations.ps1` (line 80) | `-match "(^|/)$escapedPrefix"` | "to handle both relative and absolute path forms" |
| `.claude/hooks/enforce-feature-folder-order.ps1` (line 87) | `-match '(^\|/)docs/features/(active\|archive)/[^/]+/plan\.md$'` | — |
| `.codex/hooks/codex-pretooluse-file-mapping.ps1` (`Test-CodexGovernedPath`, line 390) | `-match "(^|/)$escaped$"` | "so absolute and relative forms both match" |

This is the decisive finding for question 3. The repository has already answered this question five times and has never once resolved a workspace root inside a hook.

### 1.5 Toolchain and gating context

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` already registers **both** canonical hook files in `CodeCoverage.Path` (line 131 for the Codex copy, line 198 for the Claude copy). No runsettings change is required, and therefore no change to the bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` line 35 already lists `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`. No manifest change.
- The Codex pack manifest does not list the hook, and `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` records it in `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS`. No manifest change.
- `quality-tiers.yml` **does not exist** in this worktree, although `.claude/rules/quality-tiers.md` asserts it does. Recording this as an observation only; nothing in this item can or should be written there.

---

## 2. Candidate Approaches

### 2.1 Recommended — segment-anchored matching, no workspace root

Replace the two defective predicates with the repository's existing `(^|/)` anchoring, leaving separator normalization exactly where it is.

```powershell
function Test-FeatureDocumentationOrEvidencePath {
    param([Parameter(Mandatory)][string] $NormalizedPath)
    return $NormalizedPath -cmatch '(^|/)docs/features/active/'
}

function Test-ImplementationPath {
    param([Parameter(Mandatory)][string] $NormalizedPath)
    if (Test-FeatureDocumentationOrEvidencePath -NormalizedPath $NormalizedPath) { return $false }
    foreach ($checkpoint in $script:CheckpointPaths) {
        if ($NormalizedPath -match ('(^|/)' + [regex]::Escape($checkpoint) + '$')) { return $false }
    }
    return $NormalizedPath -match '\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$'
}
```

**Why this is correct.**

- **No workspace root is needed at all**, so every failure mode of root resolution disappears: 8.3 short names (this session's own scratchpad path is spelled `C:\Users\DANMOI~1\...`, so short names demonstrably occur on this machine), drive-letter case, symlinks, and the linked-worktree case where the worktree root is not the main repository root.
- **Idempotent for a relative path.** `(^|/)` matches at `^`, so the Codex `apply_patch` call site, which passes repo-relative paths harvested from patch markers, is bit-for-bit unaffected.
- **Preserves the decision function as a pure function.** No new parameter, no environment read, no filesystem probe, no subprocess. The existing test seam `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ... -CheckpointRaw ...` is unchanged in both families, so no existing test signature moves.
- **Negative half holds.** An absolute path to a production source file — for example the absolute spelling of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — contains no `docs/features/active/` segment, ends with none of the seven checkpoint literals on a segment boundary, and matches `\.ps1$`. It is still classified as an implementation path and still denied. This is the half the issue calls mandatory.
- **Two pre-existing 535 deny cases survive unchanged.** `artifacts/orchestration/some-other-file.json` still denies (it is not one of the seven literals). `scripts/parallel-planner-state.json` still denies (the required `artifacts/orchestration/` segment is absent). Neither test needs editing, though the second's title says "full-path equality" and should be re-worded to "segment-anchored suffix" so the name stays honest.

**Known widening, quantified.** The predicate now also exempts a path *outside* the workspace whose tail is exactly `.../artifacts/orchestration/<one of the seven names>`. Measured exposure: a glob of `**/artifacts/orchestration/*.json` across the worktree returns exactly one file, the real checkpoint. There is no nested or vendored second copy. The same widening has been accepted four times already for the identical literal in the two checkpoint hooks. Recommendation: accept it and state it in the hook comment.

**Case-sensitivity decision.** PowerShell `-match` is case-insensitive and `-contains` is case-insensitive; `.NET` `String.StartsWith(string)` is case-sensitive. To hold the behaviour delta at exactly zero:

- use `-match` (case-insensitive) for the checkpoint set, preserving the current `-contains` semantics exactly;
- use `-cmatch` (case-sensitive) for the `docs/features/active/` prefix, preserving the current `StartsWith` semantics exactly.

The alternative — `-match` on both, accepting a case-insensitive widening that arguably matches Windows filesystem semantics — is defensible but is a behaviour change the acceptance criterion "no unintended behavior changes outside the defined scope" would have to absorb. Recommend the zero-delta form and record the choice in the hook comment so a later reader does not "tidy" `-cmatch` into `-match`.

**Edge cases, decided.**

| Input shape | Result | Judgment |
| --- | --- | --- |
| `./artifacts/orchestration/orchestrator-state.json` | exempt (the `/` of `./` satisfies the anchor) | correct |
| Backslash spelling, absolute or relative | exempt (separators normalized upstream, unchanged) | correct |
| UNC `//server/share/repo/artifacts/orchestration/orchestrator-state.json` | exempt | correct |
| Path containing `..`, e.g. `.../artifacts/orchestration/../orchestration/orchestrator-state.json` | **denied** | accepted fail-closed miss; the `Write` tool does not emit `..` segments, and adding a canonicalizer would reintroduce filesystem dependence for no measured benefit |
| Trailing slash | not applicable; every governed path ends in a file extension | — |
| Absolute production source file | denied | required |

### 2.2 Rejected alternatives (summary)

- **Workspace-root prefix strip.** Exact rather than suffix-tolerant, but it requires resolving a root, and every available mechanism fails somewhere: `$PSScriptRoot` ascent is deterministic but must be spelled differently per family and silently mis-resolves if a copy is ever relocated; process CWD makes a pure decision function depend on process state and would need a new parameter threaded through both families' entry points; the envelope `cwd` field is **verified present only for Codex** (the repo's own fixture `ConvertTo-CodexPreToolPayload` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` sets it, and the Codex entry point then discards it before the decision function runs) and is **unverified for Claude** — `PreToolUseSchema.Contract.Tests.ps1` asserts only the deny-output schema, never the input envelope shape, and no `.claude/**` file reads a `cwd` key anywhere; and `git rev-parse --show-toplevel` adds a subprocess to a per-tool-call hook, would require a wrapper seam under `.claude/rules/powershell.md` mocking rules, and would still have to be case-and-shortname-tolerant. Decisive against: a strip that fails to match leaves the path absolute and the gate denies, so every one of those failure modes reintroduces the reported defect in a subtler, less reproducible form.
- **A shared normalization helper in `.claude/lib/hook-payload/`.** Not reachable by the Codex copies. See section 3.
- **Adding absolute literals to `$script:CheckpointPaths`.** Not viable: the absolute prefix is machine- and worktree-specific and unknowable at authoring time. The issue itself rejects this ("A tolerant comparison is preferable to a second literal").

---

## 3. Where the change must live (question 1, answered)

**A shared helper in `.claude/lib/hook-payload/` is not reachable by the Codex copies, and must not be made reachable.** Evidence:

1. The Codex hooks dot-source exactly one shared file, `codex-pretooluse-file-mapping.ps1`, whose own header states it performs no policy evaluation. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` enumerates shared modules in `$script:SharedModuleNames` and gates them with parse, 500-line, byte-identity, and manifest-membership assertions.
2. The Codex bundle publishes through a **separate pack** (`codex-and-agents-customizations`) from the Claude pack (`claude-customizations`). A destination that installs only the Codex pack has no `.claude/lib/` tree, so a cross-runtime import would fail at hook load on the published surface — the worst possible failure location for a `PreToolUse` gate.
3. The 535 plan (P3-T1, on this branch) explicitly instructs: "Do not add a cross-runtime import of `.claude/lib/hook-payload/HookPayload.psm1`." That is settled base-state policy for this hook.

**Recommended placement: no shared helper.** Edit the two predicate bodies in place, in all four copies. The change is two expressions per file. A shared module would instead require creating a new module file plus its bundled mirror, registering it in two pack manifests, adding it to `$script:SharedModuleNames`, adding it to `CodeCoverage.Path` in two runsettings files, and adding a new test suite — six to nine extra written files to share four lines of regex. The repository already accepts family duplication for this hook and gates it with byte-identity and content-equality tests.

**Enumeration of files each candidate placement would require the diff to WRITE:**

- *Recommended (in-place, no shared helper):* the four hook copies. Four production files.
- *Shared helper in `.claude/lib/hook-payload/`:* the four hook copies, plus `.claude/lib/hook-payload/HookPayload.psm1` (or a new sibling module), plus its bundled mirror under `claude-customizations`, plus a new Codex-reachable copy of the helper, plus its Codex bundled mirror, plus `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, plus `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, plus `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror, plus a new test suite for the helper, plus an edit to `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Twelve-plus files. Rejected.

**Rule constraints checked.** `.claude/rules/` contains nineteen files; none constrains where enforcement-hook path logic lives. The only adjacent constraint is the Python prohibition, enforced by the AST scanner `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` with an empty allowlist. The recommended change introduces no interpreter invocation of any kind, so that gate is satisfied without edit. **No bash mirror of this hook exists** — a glob of `**/enforce-orchestration-preimplementation-gate.*` returns exactly the four `.ps1` copies and one test file.

---

## 4. How the hook learns the workspace root (question 2, answered)

**Recommendation: it should not, and under the recommended fix it does not need to.**

The inference the parent asked to verify is nonetheless confirmed, and is worth recording because it explains why `Get-CheckpointContent` works today:

- `.claude/settings.json` registers the hook three times (matchers `Bash`, `Write|Edit`, `Agent`) with the command `pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — a **workspace-relative** `-File` argument. That argument resolves only if the hook process's current working directory is the workspace root. The hook therefore runs with CWD equal to the workspace root, which is why `Get-CheckpointContent`'s relative `Test-Path` finds the checkpoint. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` asserts this exact command string against both the active and the bundled settings files.
- In a linked worktree such as this one the CWD is the **worktree** root, so the relative form is correct there too.
- `.codex/config.toml` registers the same hook with `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/..."`, so the Codex surface pays for a git subprocess at registration time and does not depend on CWD to locate the script — but its `Get-CheckpointContent` is still CWD-relative, and `legacy-codex-hook-contracts.Tests.ps1` exercises that with `Push-Location` to a checkpoint-free directory.

So a CWD-based strip *would* work today on the Claude surface. It is still the wrong choice, because it converts a pure decision function into one that reads process state, would need a new injectable parameter to stay testable under `.claude/rules/general-unit-test.md` ("tests must not depend on implicit working-directory assumptions"), and would have to be case- and short-name-tolerant to survive the `DANMOI~1` spelling. The `(^|/)` anchor delivers the same outcome for every spelling the `Write` tool can emit, with none of that.

---

## 5. Behavior Semantics

Intended behaviour after the change, stated as decision rules over the separator-normalized `file_path`:

1. A path whose text contains the segment `docs/features/active/` at the string start or immediately after a `/` is **not** an implementation path, in either spelling and either separator style.
2. A path whose text ends with one of the seven checkpoint literals at a segment boundary is **not** an implementation path, in either spelling and either separator style.
3. Any other path matching `\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$` **is** an implementation path, in either spelling. This is the negative half and is non-negotiable.
4. Rules 1 and 2 are evaluated in that order, unchanged.
5. Classification is the only thing that changes. `Test-OrchestrationReady`, `Test-ImplementationCommand`, `Test-PreparationModeDelegation`, `Test-ImplementationDelegation`, `Get-CheckpointContent`, the anomaly-handling path, the deny reason text (`PREIMPLEMENTATION_GATE_BLOCKED`, `route metadata`, `lifecycle readiness`), and the decision-JSON schema are all unmodified.
6. The Codex entry point's exit-code contract (0 for a decision, 2 for a transport failure) is unmodified.

Ordering and failure semantics: the gate remains fail-closed. Nothing in this change moves a deny to an allow except for the two exemptions the gate already grants in the relative spelling.

**Out of scope, recorded deliberately.** The issue's note that "the checkpoint exemption also requires `lifecycle_ready` to be truthy, which is undocumented in the skill" is a separate observation, stated as such in the issue, and is not addressed here. The issue's suggestion to "distinguish the two failure reasons in the message text" is a message-text change with no test dependency and is likewise not addressed; the existing suite asserts the current message substrings and this item should not disturb them.

---

## 6. Requirements Mapping

| Requirement (from `spec.md` and `issue.md`) | Design element |
| --- | --- |
| Absolute checkpoint `Write` allowed with no checkpoint present | Rule 2 above, in all four copies |
| Absolute production-source `Write` still blocked | Rule 3 above; asserted explicitly as the negative half |
| Absolute feature-documentation artifact allowed | Rule 1 above |
| Both separator styles | existing `-replace '\\', '/'`, unchanged |
| Paired relative/absolute tests per exemption, keeping existing relative cases | new `Context`/`Describe` added; no existing case removed or weakened |
| No unintended behaviour change | `-cmatch` for the documentation prefix, `-match` for the checkpoint set; `Test-OrchestrationReady` line 188 untouched |
| Four-copy parity | Claude pair byte-identical; Codex pair byte-identical; families remain distinct |
| Full toolchain pass | section 8 |

**Change-budget consequence.** Four production PowerShell files exceed the direct-mode cap of 2 in `.claude/rules/powershell.md`, and the per-batch cap is 3 production + 3 test files. The implementation must split into two batches exactly as 535 did: batch 1 = the two Claude hook copies plus the Claude test file; batch 2 = the two Codex hook copies plus the Codex test file. The Codex pair must land byte-identical **in the same commit** or the byte-identity `It` in `legacy-codex-hook-contracts.Tests.ps1` fails.

---

## 7. Testing Implications

### 7.1 Which test files must change (question 4, answered)

**Claude family.** Behaviour is covered by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (461 content lines). A paired relative/absolute matrix across seven literals, two absolute-root shapes, two separator styles, plus the documentation and negative-half cases, plus a re-declaration of the literal list (it currently lives in a sibling `Context`'s `BeforeAll` and is not visible to a new `Context`), lands the file at or above the 500-line cap in `.claude/rules/general-code-change.md`, which applies to test code. **Recommend a new sibling suite** rather than an in-place extension.

**Codex family.** Behaviour for this hook is covered by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, not by `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (that suite only enumerates the hook by name in a transport group list). The legacy-contracts file is at **494 content lines against a 500-line cap** — six lines of headroom. Even the most compact table-driven `It` covering one allow, one documentation allow, and one deny exceeds it. **A new sibling suite is required here, not merely preferable.**

Neither existing suite needs an edit. In particular:

- The byte-identity `It` in `legacy-codex-hook-contracts.Tests.ps1` (line 111) already covers the Codex pair over `$script:StaticCheckNames` and needs no change.
- The Claude bundle mirror is gated by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which asserts **content equality for every repo `.claude/**` file** against its bundled counterpart. No new parity test is needed; that suite must be run as a verification step.
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` dot-sources the hook and asserts only the deny-decision shape, which is unchanged. It must be re-run, not edited.
- One optional in-place edit is worth calling out but is **not** required: the existing 535 case titled "denies a checkpoint-named file outside artifacts/orchestration/ (full-path equality)" still passes, but its parenthetical becomes inaccurate. Re-wording it is a one-line title change inside an already-in-scope file only if that file is otherwise edited; under the recommended new-file approach it should be left alone to keep the diff honest.

### 7.2 Fail-before feasibility (question 6, answered)

**A fail-before Pester run is structurally possible and straightforward.** The hook guards its entry point with `if ($MyInvocation.InvocationName -eq '.') { return }`, so dot-sourcing exposes the pure decision function without executing the entry point — the existing suite already does exactly this.

Concrete failing-case shape, written against the current code:

- Arrange: a nested `Write` envelope whose `tool_input.file_path` is a **synthetic** absolute prefix joined to `artifacts/orchestration/parallel-planner-state.json`, plus an explicit not-ready checkpoint built from the existing `ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false` helper.
- Act: `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ... -CheckpointRaw ...`.
- Assert: `permissionDecision` equals `allow`.
- Current result: `deny` — the test fails. Post-fix result: `allow` — the test passes.

Use a **synthetic** absolute prefix (one Windows-shaped, one POSIX-shaped, one UNC-shaped) rather than deriving one from `$PSScriptRoot` or `$PWD`. Because the recommended predicate is a pure suffix match, the real root is irrelevant to the assertion, and a synthetic prefix makes the suite independent of checkout location, of OS, and of the linked-worktree layout — satisfying the determinism requirements in `.claude/rules/powershell.md` and `.claude/rules/general-unit-test.md`. No disk I/O, no child process, no temporary file.

The negative half must be in the same fail-before batch and is expected to **pass before and after**: the synthetic-absolute spelling of a `.ps1` production file must deny in both states. Include it so the run demonstrates that the fix did not simply open the gate.

### 7.3 Scenario coverage to require of the plan

For each of the seven checkpoint literals: relative allow (regression), absolute-Windows allow, absolute-POSIX allow, backslash-absolute allow. For the documentation exemption: relative `.json` allow (regression), absolute `.json` allow, backslash-absolute allow. Negative half: absolute production `.ps1` deny, absolute production `.py` deny, absolute `artifacts/orchestration/some-other-file.json` deny, absolute `scripts/parallel-planner-state.json` deny. Codex-specific: a repo-relative `apply_patch` marker path still classifies unchanged (idempotence proof for the `Test-ImplementationCommand` call site).

### 7.4 Coverage

Both canonical hook files are already in `CodeCoverage.Path`, so per-file line coverage is produced without configuration change. Per `.claude/rules/quality-tiers.md` the uniform line threshold of >= 85% applies; PowerShell is exempt from the branch threshold because Pester does not measure branch coverage, and that exemption is **not** a licence to exclude a file — both hooks remain in the denominator. The two bundle mirrors are executed by no suite; they inherit their measurement through SHA256 equality with their canonical counterparts, which is the mechanism 535 used and recorded.

---

## 8. Toolchain Commands (question 7, answered)

Per `.claude/rules/powershell.md`, run in order and restart from step 1 whenever a stage fails or rewrites a file:

1. **Format** — `mcp__drm-copilot__run_poshqc_format`
2. **Analyze** — `mcp__drm-copilot__run_poshqc_analyze` (optional autofix: `mcp__drm-copilot__run_poshqc_analyze_autofix`)
3. **Type check** — not applicable to PowerShell; skip
4. **Test** — `mcp__drm-copilot__run_poshqc_test`, using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

Do not substitute VS Code task wrappers.

**Coverage capture.** Coverage is configured in the runsettings file, not per invocation — the MCP test tool exposes no coverage parameter. `CodeCoverage.Enabled` is `$true`, `OutputFormat` is `CoverageGutters`, and output lands at **`artifacts/pester/powershell-coverage.xml`**. Test results land at `artifacts/pester/pester-junit.xml`. Extract the per-file numeric line-coverage percentage from the per-file counters in the coverage artifact, not from the aggregate console summary; `CoveragePercentTarget` is `0`, so the run never fails on percentage and the threshold check is the reader's responsibility.

**Additional verification leg.** Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` after touching the Claude bundle mirror. That suite is the gate on Claude root-to-bundle content equality.

**Batch-budget note.** `.claude/hooks/enforce-powershell-batch-budget.ps1` caps production PowerShell files per session at 3. Four production copies are in scope, so the session state file must be reset between batch 1 and batch 2, exactly as 535's P2-T9 did.

---

## 9. Scope Boundary (question 5, answered)

**Neither sibling hook shares the defect. Recommend the narrow scope. Do not file a follow-up either.**

- `.claude/hooks/enforce-evidence-locations.ps1` (line 80) already matches with `(^|/)` and carries the source comment "Match the prefix either at the start of the string or after any directory separator, to handle both relative and absolute path forms." Its Codex counterpart `.codex/hooks/enforce-evidence-locations.ps1` uses the identical construction. **Correct as written.**
- `.claude/hooks/enforce-feature-folder-order.ps1` (line 87) already matches with `(^|/)`. Its downstream helper `Get-FeatureFolderMissingFile` strips the `plan.md` tail and probes siblings against whatever prefix survived, so an absolute path resolves its siblings absolutely. **Correct as written.**

The promoted record's suspicion was reasonable but is refuted by reading the code. Nothing is left to fix in either file, so there is no residual work to split out. Widening scope to them would be pure churn, and this run schedules concurrent items by declared file set, so the churn would also cost concurrency.

**Also explicitly out of scope, with reasons:** `Test-OrchestrationReady`'s `StartsWith` on the checkpoint's own `feature-folder` value (different input class, repo-relative by contract); the `lifecycle_ready` documentation gap (named as separate in the issue itself); the block-message wording change (would break existing message assertions for no functional gain).

---

## Automation Feasibility

**This change is fully automatable. No human interaction is required at any point.**

Reasoning, stated against the concrete mechanics rather than in general terms:

1. **The edit is mechanical and local.** Two predicate bodies per file, four files, no signature change, no new parameter, no new module, no configuration change. There is no design judgment left open after this document: the construction is fixed, the case-sensitivity choice is fixed, and the placement question is settled by an existing prohibition on cross-runtime imports.
2. **Every verification step is a non-interactive command.** Format, analyze, and test all run through MCP tools; the push-down parity leg is a single `poetry run pytest` invocation; byte-identity is a `Get-FileHash` comparison. None prompts, none requires credentials, and none requires a network.
3. **Fail-before evidence is producible without any manual setup.** Section 7.2 gives a test shape that fails against the current committed code and passes after the edit, using synthetic path strings only — no fixture file to create, no temporary directory, no repository state to arrange.
4. **The success condition is machine-checkable.** Allow/deny is a string comparison on `permissionDecision`; coverage is a numeric read from `artifacts/pester/powershell-coverage.xml`; byte-identity is a hash equality; parity is a pytest exit code.
5. **No decision is deferred to a reviewer.** The one judgment call that could have required escalation — whether to accept the segment-anchored suffix widening — is settled by measurement (one matching file in the tree) plus four in-repo precedents, and is recorded here rather than left open.
6. **The rollback is trivial.** The change is additive-in-behaviour and revertible by restoring two expressions per file, with no data migration, no schema change, and no published-artifact coupling beyond the two bundle mirrors that are gated by existing tests.

The only operational sequencing constraint is the batch-budget reset between the two implementation batches (section 8), which is itself a scripted command already used by 535.

---

## Recommended File Set for the Diff

```text
.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/spec.md
```

Seven files: four production hook copies, two new Pester suites, and the feature spec (its Proposed Fix, Scope, Test Strategy, and Acceptance Criteria sections are currently empty templates and must be completed).

**Files deliberately NOT in the set, each with its reason:**

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — both canonical hooks are already registered in `CodeCoverage.Path`.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — already lists the Claude hook.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` — the Codex hook is a recorded pre-existing exception in the completeness test.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` — every existing case still passes; new cases go in the new sibling suite to stay under the 500-line cap.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — six lines of headroom against the cap; its byte-identity and decision assertions all still pass.
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — all must be **run**, none needs editing.
- `.claude/hooks/enforce-evidence-locations.ps1`, `.claude/hooks/enforce-feature-folder-order.ps1` and their Codex counterparts — verified free of the defect (section 9).
- `.claude/settings.json`, `.codex/config.toml` and their bundled mirrors — registration is unchanged.

**Policy documents:** no file under `.claude/rules/` needs to be written. The change adopts an idiom that five existing hooks already use, introduces no new invariant, and adds no enforcement mechanism that requires prose backing. No file under `.github/instructions/` needs to be written; `CLAUDE.md` forbids modifying them in any case. `quality-tiers.yml` needs no change — and, as recorded in section 1.5, that file does not exist in this worktree, so nothing could be written to it.
