# Research — Shared helper form, registration cost, copy set, and two previously out-of-scope hooks

- Issue: #545, child E of epic `cleanup-merged-worktrees-hardening`
- Branch: `bug/enforcement-hook-trigger-matches-whole-command-text-545-r2`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` (HEAD `be722eba`)
- Scope of this artifact: spec.md D7 / D8 / D9 verification, the `.psm1` alternative, a single
  recommendation, defect analysis of `enforce-parallel-abandon-gate.ps1` and `validate-bash.ps1`,
  a complete sweep of the Bash-command-classifying hook family, and a restatement of settled
  decisions D5, D6, and D10.
- Method: file reads and content searches against the current worktree only. No command was
  executed; no production file was modified. Statements about `argparse` behavior are derived
  from the CLI source and standard `argparse` semantics, and are marked as such.

---

## 1. Question 1 — D7 / D8 / D9 verified against the current tree

### 1.1 `codex-pretooluse-file-mapping.ps1`

Exists in exactly **two** locations (verified by glob `**/codex-pretooluse-file-mapping.ps1`):

1. `.codex/hooks/codex-pretooluse-file-mapping.ps1` (474 lines)
2. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-pretooluse-file-mapping.ps1`

It is Codex-only. There is no Claude-side copy and no `.claude/lib` equivalent. It is dot-sourced
by seven Codex hooks, in the shape `. (Join-Path $PSScriptRoot 'codex-pretooluse-file-mapping.ps1')`
(`check-python-test-purity.ps1:35`, `check-powershell-test-purity.ps1:38`,
`enforce-python-batch-budget.ps1:39`, `enforce-powershell-batch-budget.ps1:41`,
`enforce-orchestration-preimplementation-gate.ps1:11`, `enforce-checkpoint-monotonic.ps1:49`,
`enforce-evidence-locations.ps1:46`, `enforce-completion-consistency.ps1:52`).

**Verdict on D7's claim: confirmed.** The unprefixed shared-`.ps1` form exists and is in active use.

### 1.2 `$script:SharedModuleNames`

Present at **line 30** of `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, exactly
as D7 states. Verbatim:

```powershell
$script:SharedModuleNames = @('codex-pretooluse-file-mapping.ps1', 'enforce-orchestration-preimplementation-gate-helpers.ps1')
```

Line 31 folds it into the static-check set:

```powershell
$script:StaticCheckNames = @($script:AllHookNames) + @($script:SharedModuleNames)
```

What the contract actually enforces on each `SharedModuleNames` member, claim by claim against
D7 lines 459–462:

| D7 claim | Verdict | Evidence |
| --- | --- | --- |
| "entrypoint-free (defines functions only, never reads stdin)" | **Partly refuted.** The suite does not *assert* entrypoint-freeness. The `It` at line 119 (`'reads stdin in every hook entrypoint'`) loops `$script:AllHookNames`, **not** `$script:StaticCheckNames`, so shared modules are **exempted** from the stdin requirement rather than checked for its absence. Membership is a licence, not an obligation. The comment at lines 24–29 states the intent explicitly. | Lines 24–29, 119–125 |
| "parses cleanly" | **Confirmed.** `It` at line 93 runs `Parser::ParseFile` over `$script:StaticCheckNames` in **both** `.codex/hooks` and the Codex bundle. | Lines 93–109 |
| "stays at or under 500 lines" | **Confirmed.** Same `It`, `(Get-Content -LiteralPath $path).Count | Should -BeLessOrEqual 500`, both roots. | Line 106 |
| "contains no `$env:CLAUDE_` read" | **Confirmed, with a scope narrowing.** `It` at line 127 loops `$script:StaticCheckNames` but reads only from `$script:HookRoot` (`.codex/hooks`). The bundle copy is not independently checked — it is covered transitively by the byte-identity `It`. | Lines 127–132 |
| "byte-identical between the Codex canonical and Codex bundle copies" | **Confirmed.** `It` at line 111 compares `Get-FileHash` of canonical and bundle for every `$script:StaticCheckNames` entry. | Lines 111–117 |
| "listed in the Codex core pack manifest" | **Confirmed.** `It` at line 134 asserts `@($manifest.paths) | Should -Contain ".codex/hooks/$name"` for every `$script:SharedModuleNames` entry. | Lines 134–139 |
| Members are excluded from every process-level invocation loop | **Confirmed** (not a D7 claim, but load-bearing): the invocation loops at lines 141 and 160 use `$script:PreToolHookNames` / `$script:AllHookNames`. | Lines 146, 161 |

**One supporting rationale in D7 is refuted.** D7 justifies the unprefixed name by saying "the
`enforce-` prefix is reserved for registered hooks, and this file is a shared library." The array
itself contradicts that: its second member,
`enforce-orchestration-preimplementation-gate-helpers.ps1`, is an `enforce-`-prefixed shared
library. On the Claude side the prefixed-helper convention is the *majority* pattern —
`enforce-completion-helpers.ps1`, `enforce-parallel-cohort-barrier-helpers.ps1`,
`enforce-parallel-drift-gate-helpers.ps1`, `enforce-pr-author-skill-helpers.ps1`,
`enforce-orchestration-preimplementation-gate-helpers.ps1`, and
`enforce-pr-author-skill.epic-base-branch.ps1` are all `enforce-`-prefixed, all dot-sourced, and
none is registered in `.claude/settings.json`.

This refutes the *reason given*, not the *decision*. The name `hook-command-scanner.ps1` is
unambiguous, is not derived from any single hook (correct for a helper serving four hooks), and
matches the `codex-pretooluse-file-mapping.ps1` precedent for a cross-hook shared library. **Keep
the name.** The correction to make in the spec, if any, is to the one-sentence rationale, not to
the decision.

### 1.3 The Codex core pack manifest

Exact path:
`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
(named at line 32 of the contracts suite as `$script:CorePackManifestPath`).

Entry shape a new shared helper must add, as a member of the top-level `paths` array — quoted from
the live file, lines 32 and 40:

```json
    ".codex/hooks/codex-pretooluse-file-mapping.ps1",
    ".codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1",
```

So the required new line is `".codex/hooks/hook-command-scanner.ps1",`, inserted in the existing
alphabetical block at lines 28–43.

Note: this manifest lists only **16** `.codex/hooks/` entries and is not a complete hook inventory.
`validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`,
`enforce-orchestration-preimplementation-gate.ps1`, and the purity/budget hooks are absent from it.
Manifest membership is contractually required only for `$script:SharedModuleNames` members, which
is precisely why a new shared helper incurs the cost and a new hook would not.

The Claude counterpart is
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, whose
`.claude/hooks/**` block runs lines 25–58 and whose `.claude/lib/**` block runs lines 113–158.
Required new line: `".claude/hooks/hook-command-scanner.ps1",`.

### 1.4 "Six registrations and four copies" — enumerated

**The four copies (confirmed correct).** The 4-copy shape is verified against an existing
four-location file, `enforce-promotion-mcp-only.ps1`:

1. `.claude/hooks/hook-command-scanner.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1`
3. `.codex/hooks/hook-command-scanner.ps1`
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1`

**The registrations — the true count is five registry files, not six.** D7's checklist (spec lines
522–531) lists six items, but item 6 is "the two bundle copies of the helper file itself", which is
not a registration at all: it is two of the four copies already counted. Enumerating the distinct
registry **files** that must change:

| # | Registry file | Entry required |
| --- | --- | --- |
| 1 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | `".claude/hooks/hook-command-scanner.ps1"` |
| 2 | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | `".codex/hooks/hook-command-scanner.ps1"` |
| 3 | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30 | append `'hook-command-scanner.ps1'` to `$script:SharedModuleNames` |
| 4 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | **two** entries: `'.claude/hooks/hook-command-scanner.ps1'` and `'.codex/hooks/hook-command-scanner.ps1'` |
| 5 | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | the same **two** entries (this file is held text-identical to #4) |

Cross-check strategy and full numeric derivation are in section 6.

So the accurate statement is **five registry files carrying seven entries, plus four file copies**.
D7's "six registrations and four copies" over-counts registrations by one and conflates a copy with
a registration. This is a wording defect in D7, not a design defect: the total work implied is the
same. It is worth correcting because a planner reading "six registrations" and then finding five
registry files will spend time looking for a missing one.

**Registrations D7 correctly omits (verified automatic, no enumeration required):**

- Claude bundle mirroring is enforced by
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
  which enumerates `.claude/**` from disk (lines 115–131) and requires byte-equal bundle content.
  No file list to edit.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` walks the
  directories `.claude/hooks` and `.claude/lib` with `Get-ChildItem -Recurse` (lines 40–41, 60).
  No file list to edit. Note it does **not** scan `.codex/hooks`, so the Codex copies of a new
  helper are outside that gate's reach.
- No per-file manifest test is required for a `.claude/hooks/*.ps1` file. (Contrast the `.claude/lib`
  route — see section 2.4.)

### 1.5 D9 synchronization contract — claim by claim

| D9 claim | Verdict |
| --- | --- |
| Claude canonical `.claude/hooks/…` content-equal to Claude bundle | **Confirmed** — enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which asserts `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` for every non-memory `.claude/**` file. |
| Codex canonical byte-identical to Codex bundle | **Confirmed** — `Get-FileHash` comparison, `It` at line 111. |
| Identity is per pair, never across pairs | **Confirmed** — no mechanism compares a `.claude/hooks` file to a `.codex/hooks` file. Divergence is real and measured: `.claude/hooks/validate-bash.ps1` is 230 lines, `.codex/hooks/validate-bash.ps1` is 185; `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` is 490, the Codex copy is 495; `.claude/hooks/enforce-promotion-mcp-only.ps1` is 275, the Codex copy is 261. |
| `enforce-orchestration-preimplementation-gate.ps1` — all four locations | **Confirmed.** |
| `enforce-promotion-mcp-only.ps1` — all four locations | **Confirmed by glob** (`.claude/hooks`, `.codex/hooks`, and both bundles). |
| `enforce-pr-author-skill-helpers.ps1` / `enforce-pr-author-skill.ps1` — Claude only, no `.codex` copy | **Confirmed** — no `.codex/hooks/enforce-pr-author-skill*.ps1` exists in the tree. |
| Mechanism table row "`It` at line 111 hashing `$script:StaticCheckNames`" | **Confirmed**, line 111. |
| Mechanism table row "`It` at line 134" for manifest membership | **Confirmed**, line 134. |
| Mechanism table row "parse check, 500-line cap, stdin-read exclusion, no-`$env:CLAUDE_`" | **Confirmed** as to the parse check, the cap, and the exclusion. The `$env:CLAUDE_` check is canonical-root-only (see 1.2). |
| Mechanism table row: both runsettings files must carry both new coverage paths | **Confirmed**, and stronger than stated: `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` lists `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` in `POSHQC_PARITY_PATHS` and compares repo text to bundle text, so the two files must be **text-identical**, not merely both-updated. |
| "`legacy-codex-hook-contracts.Tests.ps1` is at 494 of 500 lines" | **Confirmed** (494 content lines; the file renders 495 lines with the trailing newline). The associated instruction — any new Codex-side scenario goes in a **new** test file — remains binding. |
| "No production file leaves the coverage denominator" | **Confirmed** as a live obligation; both runsettings coverage lists already carry `.claude/hooks/**`, `.codex/hooks/**`, and `.claude/lib/**` production files. |

**D9 is accurate as a contract.** The only correction needed is the registration count in D7's
checklist (section 1.4).

---

## 2. Question 2 — the `.psm1` alternative

### 2.1 How hooks import `.claude/lib/**/*.psm1` today

Three distinct call sites, quoted exactly:

```powershell
# .claude/hooks/validate-bash.ps1:41
Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force
```

```powershell
# .claude/hooks/enforce-pr-author-skill.ps1:51
Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorState.psm1') -Force
```

```powershell
# .claude/hooks/enforce-mermaid-validation.ps1:83
        Import-Module -Name $script:MermaidModulePath -Force -ErrorAction Stop
```

The dominant shape is a single-line `Import-Module (Join-Path $PSScriptRoot '../lib/<dir>/<Name>.psm1') -Force`
at the top of the file; 24 of the 25 `Import-Module` sites in `.claude/hooks` use exactly that shape
against `../lib/hook-payload/HookPayload.psm1`. Two hooks
(`enforce-mermaid-validation.ps1`, `enforce-discovery-artifact-gate.ps1`,
`validate-discovery-artifact-gate.ps1`) additionally import a second module lazily inside a
function, via a precomputed `$script:…ModulePath` and `-ErrorAction Stop`. Every path is resolved
relative to `$PSScriptRoot`, never to the process working directory.

### 2.2 The decisive question — can Codex reach `.claude/lib`?

**No, on two independent grounds.**

1. **No Codex file imports any module.** A content search for `Import-Module` across the entire
   `.codex/` tree returns **zero matches**. Every Codex hook that consumes shared code does so by
   dot-sourcing a sibling `.ps1` in the same directory:
   `. (Join-Path $PSScriptRoot 'codex-pretooluse-file-mapping.ps1')` and
   `. (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-helpers.ps1')`.
   The dot-source idiom is universal on that side (20 sites observed across 12 files); the
   `Import-Module` idiom is entirely absent.

2. **`.claude/lib` is not delivered to the Codex side.** A content search for `claude/lib` across
   `extensions/drm-copilot/resources/codex-and-agents-customizations/` returns **zero matches**,
   and the Codex core manifest's `paths` array contains no `.claude/**` entry. The Codex bundle is
   a self-contained `.codex/**` payload. A `.claude/lib` module is not present on disk anywhere the
   Codex hooks can reach by a `$PSScriptRoot`-relative path.

Consequence: a `.psm1` under `.claude/lib/` **cannot serve the Codex copies of
`enforce-orchestration-preimplementation-gate.ps1` and `enforce-promotion-mcp-only.ps1`**, which are
two of the four hooks D1–D10 put in scope. Choosing `.psm1` would require either (a) a second,
duplicate scanner implementation as a `.codex/hooks/*.ps1`, or (b) inventing a cross-tree delivery
path for `.claude/lib` into the Codex bundle. Option (a) is the "second implementation that drifts"
outcome the repository's enforcement-hook policy exists to prevent (spec D1, rejected alternative C
states the same principle for a Python leg). Option (b) is a runtime-architecture change far larger
than issue #545.

### 2.3 Codex hook inventory

`.codex/hooks/*.ps1` — 28 files present:

`authorize-root-epic-invocation.ps1`, `check-powershell-test-purity.ps1`,
`check-python-test-purity.ps1`, `codex-agent-profile-attestation.ps1`, `codex-authority-store.ps1`,
`codex-epic-child-launch-attestation.ps1`, `codex-pretooluse-file-mapping.ps1`,
`enforce-checkpoint-monotonic.ps1`, `enforce-codex-model-routing.ps1`,
`enforce-completion-consistency.ps1`, `enforce-completion-helpers.ps1`,
`enforce-epic-child-worktree-binding.ps1`, `enforce-epic-merge-gate.ps1`,
`enforce-epic-planning-only.ps1`, `enforce-epic-root-invocation.ps1`,
`enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`,
`enforce-evidence-locations.ps1`, `enforce-orchestration-preimplementation-gate-helpers.ps1`,
`enforce-orchestration-preimplementation-gate-modes.ps1`,
`enforce-orchestration-preimplementation-gate.ps1`, `enforce-powershell-batch-budget.ps1`,
`enforce-promotion-mcp-only.ps1`, `enforce-python-batch-budget.ps1`,
`record-subagent-routing-attestation.ps1`, `validate-bash.ps1`,
`validate-codex-subagent-routing.ps1`, `validate-feature-review-coverage.ps1`.

None imports a `.psm1`. All shared-code consumption is dot-sourced `.ps1`.

### 2.4 Registration cost of a new `.psm1` under `.claude/lib/<newdir>/`

| Obligation | Evidence |
| --- | --- |
| List in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Lines 113–158 enumerate every existing `.claude/lib/**` module individually. |
| Add to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` coverage list | `.claude/lib/**` modules are enumerated there (lines 66, 70–71, 96, 100–112, 163–169, 194–197, 204). |
| Add the same entry to `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | Text-identical parity enforced by `test_poshqc_bundled_parity.py`. |
| Mirror the file into `extensions/drm-copilot/resources/claude-customizations/.claude/lib/<newdir>/` | Enforced by the push-down parity test. |
| **Add a new `tests/scripts/claude-lib/<newdir>/<Name>.Manifest.Tests.ps1` suite** | Convention followed by every existing lib family: `blast-radius`, `codex-routing`, `discovery-validation`, `model-routing`, `orchestrator-state` each have one. `DiscoveryValidation.Manifest.Tests.ps1` shows the required shape: manifest membership, no-duplicate, "every on-disk `.psm1` in this folder is registered", and bundle byte-identity. |
| **Plus a duplicate `.codex/hooks/*.ps1` implementation** for the Codex side, carrying the full `$script:SharedModuleNames` registration set from section 1.4 | Forced by 2.2. |

So the `.psm1` route costs **more**, not less: it carries four registrations of its own, adds a
conventional manifest test suite, and then still requires the entire `.ps1` shared-helper apparatus
on the Codex side — this time as a genuine second implementation with no byte-identity contract
between the two.

The epic brief's premise — "`HookPayload.psm1` is 496 lines against a 500-line cap so nothing new
fits there" — is factually correct (`.claude/lib/hook-payload/HookPayload.psm1` measures **496**
lines) but it argues only against *extending HookPayload*, which no one proposed. It does not
argue for a new `.psm1`.

---

## 3. Question 3 — recommendation

### Recommendation: **(a) — keep D7. Ship `hook-command-scanner.ps1` as a dot-sourced, entrypoint-free `.ps1` shared helper in `.claude/hooks/` and `.codex/hooks/`.**

**Decisive reason:** a `.psm1` under `.claude/lib/` is unreachable from the Codex hooks. `.claude/lib`
is not delivered into the Codex bundle (zero `claude/lib` references under
`codex-and-agents-customizations/`) and no `.codex/**` file contains a single `Import-Module` call.
Two of the four in-scope hooks — the Codex copies of
`enforce-orchestration-preimplementation-gate.ps1` and `enforce-promotion-mcp-only.ps1` — could
therefore not consume the module, and the change would need a duplicate scanner implementation on
the Codex side. One defect class fixed by two divergent implementations is strictly worse than one
implementation delivered to four locations under an enforced byte-identity contract.

Supporting findings, in the order the question asked for them:

- **Which form the existing test contracts support.** Only the `.ps1` form. `$script:SharedModuleNames`
  is a purpose-built contract for exactly this file shape: it grants the stdin-read exemption and
  the invocation-loop exemption while retaining the parse check, the 500-line cap, the byte-identity
  hash, and the manifest requirement. There is no equivalent contract for a Codex-reachable module.
- **Codex consumption.** `.ps1` — yes, by the established dot-source idiom. `.psm1` — no.
- **Registration and mirroring cost.** `.ps1`: five registry files, seven entries, four copies.
  `.psm1`: four registry files plus a new conventional manifest test suite, plus the whole `.ps1`
  apparatus anyway for Codex.
- **The 500-line cap.** Both forms are capped at 500 lines; the cap is not a differentiator. It is
  a live constraint on the *call sites*, though: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
  is at **490/500** and its Codex copy at **495/500**. Neither can absorb more than a handful of
  lines, which independently confirms that the scanner must be a separate file rather than inline
  code in the gate.
- **Precedent.** `codex-pretooluse-file-mapping.ps1` (474 lines, 8 dot-source consumers) and
  `enforce-orchestration-preimplementation-gate-helpers.ps1` (349 lines, both sides) are the two
  existing cross-hook shared libraries. Both are `.ps1`. Both are `SharedModuleNames` members. The
  proposed helper is the same kind of object.

**D7 is correct on current evidence. Do not reopen it.** Two narrow corrections to its supporting
text are warranted and are additive, not reversals:

1. The count "six registrations and four copies" should read "five registry files carrying seven
   entries, and four file copies" (section 1.4).
2. The naming rationale "the `enforce-` prefix is reserved for registered hooks" is not borne out —
   `enforce-orchestration-preimplementation-gate-helpers.ps1` is an unregistered `enforce-`-prefixed
   shared library sitting in the same array. The name `hook-command-scanner.ps1` should be retained
   on the better ground that it is not derived from any one of the four consuming hooks.

### Line budget

Measured comparators at this repository's documentation density (comment-based help on every
function, per-parameter `.PARAMETER` blocks, `[OutputType]` attributes):

| Comparator | Lines | Functions / constants |
| --- | --- | --- |
| `enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 | 5 functions + 3 script-scope constants (~62 lines per function including help) |
| `codex-pretooluse-file-mapping.ps1` | 474 | shared Codex payload mapper |
| `.claude/lib/hook-payload/HookPayload.psm1` | 496 | shared payload reader |

The D2 contract requires, at minimum: the segment scanner with a heredoc state machine; masked-text
production; a tokenizer in the `ConvertTo-OrchestrationCommandToken` idiom; the
`HasLiveSubstitution` and `Unbalanced` determinations; the scan-text selection function implementing
clauses 1–3; the wrapper carve-out constant; the git and gh option-table constants; and the
structural relocation classifier with its env-prefix skip, transparent-wrapper skip, option
absorption, and subcommand test. That is realistically **8 to 10 functions plus 3 to 4 script-scope
constants**.

At the measured ~62 lines per function, the estimate is **≈ 420–620 lines**. The lower bound fits
one file; the upper bound does not.

**Verdict on the line budget: plan for two sibling files from the start.** A single file under 500
lines is achievable only by compressing the help blocks below the density of every comparator in
`.claude/hooks`, which trades a review finding for a file count. The natural seam is the one D2
already draws: Piece 1 + Piece 2 (scanning, masking, scan-text selection) in
`hook-command-scanner.ps1`; Piece 3 (the structural relocation classifier and its option tables) in
a sibling. Each sibling then carries the same five-registry-file registration set and its own four
copies — **8 files and 14 registry entries total** if the split happens. Confirming the split at
planning time is cheaper than discovering it mid-execution, because it changes both pack manifests,
both runsettings files, and the `$script:SharedModuleNames` array.

---

## 4. Question 4 — the two previously out-of-scope hooks, and the family sweep

### 4.1 `.claude/hooks/enforce-parallel-abandon-gate.ps1`

- **Exists.** 256 lines. Copy set: **2 locations only** — `.claude/hooks/` and
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. There is **no** `.codex`
  copy, so it follows the pr-author copy shape, not the four-copy shape.
- **Registered** at `.claude/settings.json` line 123, on the `Bash` PreToolUse matcher.
- **Coverage-registered** at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 188.
- **Test suite:** `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`, 24 `It`
  blocks.

**Functions and line ranges:**

| Function | Lines |
| --- | --- |
| `Get-ParallelAbandonGateToolInput` | 47–60 |
| `Get-ParallelAbandonNormalizedCommand` | 62–86 |
| `Test-ParallelAbandonCommandInScope` | 88–111 |
| `Test-ParallelAbandonCommandConfirmed` | 113–136 |
| `Get-ParallelAbandonGateAllowDecision` | 138–155 |
| `Get-ParallelAbandonGateBlockDecision` | 157–180 |
| `Get-ParallelAbandonGateBlockReason` | 182–202 |
| `Invoke-ParallelAbandonGateDecision` | 204–245 |
| Entrypoint guard and body | 247–256 |

Script-scope constants: `$script:AbandonDispositionToken = '--disposition abandon'` (line 41),
`$script:AbandonConfirmToken = '--confirm-abandon'` (line 42),
`$script:AbandonBlockedReasonCode = 'PARALLEL_ABANDON_BLOCKED'` (line 45).

**Matching mechanism — there is no regex at all.** This hook is the purest instance of the defect
class. It normalizes whitespace with a single `-replace '\s+', ' '` (line 85) and then performs two
`String.Contains(..., OrdinalIgnoreCase)` substring tests over the whole command text (lines 108–110
and 133–135). It never identifies a command word, an argument boundary, a quote span, or a segment.

**Deny code emitted:** `PARALLEL_ABANDON_BLOCKED`, as `permissionDecisionReason` on a
`permissionDecision: deny` PreToolUse envelope (lines 173–179, 193–201). A payload anomaly also
denies with the same code plus `': payload anomaly - '` (lines 226–229).

**Concrete false positive (over-match), verified against the code path:**

```
grep -rn -- "--disposition abandon" docs/features/
```

`Get-ParallelAbandonNormalizedCommand` leaves the token intact; `Test-ParallelAbandonCommandInScope`
returns `$true` on the quoted literal; `Test-ParallelAbandonCommandConfirmed` returns `$false`; the
hook denies with `PARALLEL_ABANDON_BLOCKED`. Searching the repository for the token is blocked.
The same applies to any heredoc or `-m` message documenting the abandon disposition — the identical
class of failure that spec.md lines 111–112 record for the promotion hook (a memory file documenting
the defect was blocked because it quoted the token it warned about).

**Concrete latent bypass (under-match), verified against the producer:**

```
poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py --item 545 --disposition=abandon --pr 900 --worktree ../wt/x
```

`scripts/dev_tools/parallel_mutation_abandon_cli.py` line 236 registers `DISPOSITION_OPTION`
(`--disposition`) as an ordinary `argparse` optional with `choices=VALID_DISPOSITIONS`. Standard
`argparse` accepts the `--option=value` spelling for such an option, so the CLI executes the abandon
disposition. The hook's substring is the space-separated form `'--disposition abandon'`, which is
not present in `--disposition=abandon`, so `Test-ParallelAbandonCommandInScope` returns `$false` and
the destructive path runs **without any confirmation check**. (The CLI's own `--confirm-abandon`
check at line 343 is a separate, independent guard; the point is that the *hook* is bypassed.
Confirmed structurally from the source; not executed.)

A second bypass, in the confirmation direction rather than the scope direction:

```
echo "note: --confirm-abandon is required" && python scripts/dev_tools/parallel_mutation_abandon_cli.py --item 545 --disposition abandon --pr 900 --worktree ../wt/x
```

The confirmation test is a whole-text substring scan, so a mention of `--confirm-abandon` anywhere
on the line — including in an unrelated quoted string in a different segment — satisfies it and the
gate allows. The existing suite's `It 'allows when the confirmation marker precedes the disposition
token'` (line 62) pins order-independence but not segment-scoping, so a per-segment fix that
requires both tokens in the *same* segment keeps that test green.

**Fix shape under D2:** the disposition and confirmation tests move onto per-segment `MaskedText`,
and the token comparison is widened to accept both the space-separated and `=`-joined spellings
(structurally, via the segment's `Tokens`, in the same idiom as the git/gh option tables). Both
token literals stay byte-unchanged as script-scope constants — required, because
`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` parses both the hook and the CLI at
run time and fails on a rename of either side.

### 4.2 `.claude/hooks/validate-bash.ps1`

- **Exists.** 230 lines (Claude canonical). Copy set: **4 locations**, but a **divergent pair** —
  `.codex/hooks/validate-bash.ps1` is 185 lines, lacks the `cd`-chained leg entirely, and parses its
  payload with a bare `ConvertFrom-Json` rather than the shared reader. Only the per-pair identity
  contract applies.
- **Registered** at `.claude/settings.json` line 95 (first hook on the `Bash` matcher) and at
  `.codex/config.toml` lines 124–125.
- **Coverage-registered** at `pester.runsettings.psd1` line 27.
- **Test suite:** `tests/scripts/claude-hooks/validate-bash.Tests.ps1`, whose deny pins are the six
  denylist literals (lines 31–36) and the eight `cd`-chained forms (lines 164–171).

**Functions and line ranges:**

| Function | Lines |
| --- | --- |
| `Get-BlockedBashPattern` | 43–56 |
| `Get-BlockedPatternMatch` | 58–79 |
| `Get-CdChainedReadCommandMatch` | 91–111 |
| `Get-BashBlockReason` | 113–134 |
| `Get-BashDenyDecision` | 136–151 |
| `Get-BashCommandToCheck` | 153–192 |
| `Invoke-ValidateBashDecision` | 194–217 |
| Entrypoint guard and body | 219–230 |

**Mechanism 1 — the substring denylist (the most over-matching construct in the family).**
`Get-BlockedBashPattern` returns six literal strings (lines 48–55):

```powershell
    return [string[]]@(
        'rm -rf',
        'git push --force',
        'git push origin --force',
        'Remove-Item -Recurse -Force',
        'git reset --hard',
        'git push -f'
    )
```

`Get-BlockedPatternMatch` tests each with `$Command.Contains($pattern)` (line 73). Properties that
follow directly, each of which is a defect:

- **No boundary of any kind.** Not `\b`, not `(^|\s)`, not a leading-word test. A literal that is a
  *prefix* of a longer, safer flag matches the longer flag. This is the confirmed
  `--force-with-lease` failure: `git push --force-with-lease origin HEAD` contains the substring
  `git push --force` and is denied, even though `--force-with-lease` is the lease-safe form the
  repository's own workflow prescribes. The same holds for `--force-if-includes`.
- **Case-sensitive.** `String.Contains(string)` is ordinal and case-sensitive, so `RM -RF /`,
  `Git push --force`, and `remove-item -recurse -force` all pass ungated. (PowerShell parameter
  names and the Windows shell are case-insensitive, so the last of these is a real command.)
- **Whole-text scan.** Any quoted mention denies. `git commit -m "removed the rm -rf call"` is
  denied with `Blocked dangerous command pattern detected: 'rm -rf'`.
- **Adjacency-required, so trivially relocatable.** `git -C ../wt push --force` contains none of the
  six literals (`git push --force` requires adjacency; `git push -f` is not a substring of
  `push --force`) and passes ungated. So do `git push -u origin --force`, `git push --force origin`
  in the `origin`-last spelling, `rm -fr`, `rm -r -f`, `rm --recursive --force`,
  `git -C ../wt reset --hard`, and `Remove-Item -Force -Recurse` (order swapped).
- **Unparseable payload is treated as command text.** `Get-BashCommandToCheck` lines 171–175 return
  the raw envelope string itself when JSON parsing fails, a deliberate AC-5 exception documented at
  lines 24–29. This widens the over-match surface: any raw text reaching stdin is scanned as if it
  were a command.

**Mechanism 2 — the `cd`-chained read regex** (line 89, the only regex in the file):

```powershell
$script:CdChainedReadCommandPattern = 'cd\s+\S.*?(&&|;)\s*(grep|cat|head|tail|less|more|awk|sed\s+-n)\b'
```

Evaluated with `[regex]::Match` over raw command text (line 105); the matched read-command name is
interpolated into the deny reason at line 130. Defect properties:

- **No left boundary on `cd`.** The pattern can start inside another word, so `abcd x && cat y`
  matches on the `cd` inside `abcd`.
- **No left boundary on the read-command alternation** — only a trailing `\b`. `cd x && more-args`
  matches (`more` followed by `-`, a word boundary).
- **Raw-text scan.** `git commit -m "cd docs && cat notes.md"` is denied. This is the concrete
  false positive.
- **Latent bypasses.** `\s*` after the connector does not admit a parenthesis or a path prefix, so
  `cd docs && (cat notes.md)` and `cd docs && /usr/bin/cat notes.md` both pass. `.` does not match
  a newline in .NET by default, so a newline-separated `cd docs` / `cat notes.md` pair passes.
  A pipeline connector (`|`) is not in the alternation, so `cd docs | ...` forms pass.

**Deny codes emitted.** Unlike its siblings this hook emits **no reason-code token**; the reason
strings are prose: `"Blocked dangerous command pattern detected: '<pattern>'"` (line 125) and
`"Forbidden Bash pattern: 'cd ... && <op>' (or ';'-chained). …"` (line 130). Both are carried on a
`permissionDecision: deny` PreToolUse envelope. The hook is also the family's one deliberate
fail-**open** case: an empty payload allows, by documented exception (lines 24–29).

**Concrete false positive:**

```
git commit -m "docs: explain why rm -rf is banned"
```

Denied: `Blocked dangerous command pattern detected: 'rm -rf'`. No `rm` executes.

**Concrete latent bypass:**

```
git -C ../drm-copilot-wt/x push --force origin HEAD
```

Allowed by non-match. A force push executes with no gate.

**Fix shape under D2, with one caution.** Moving both mechanisms onto per-segment masked scan text
removes the quoted-prose over-match, and applying the D2 Piece 3 structural classifier to `git`
closes the `-C` relocation bypass for `push --force` and `reset --hard`. But the
`--force-with-lease` failure is **not** a masking failure and is **not** fixed by the scanner alone:
it is a missing token boundary inside the denylist literal. Closing it requires evaluating
`git push --force` against the segment's `Tokens` (exact token equality, so `--force-with-lease` is
a different token) rather than by substring. That is a change to *how* the literal is compared, not
to the literal's text, so R2 ("the trigger strings are byte-unchanged") survives — but the spec's
scope amendment must say so explicitly, because a reviewer applying R2 literally would otherwise
read a `Contains`-to-token-equality change as out of contract.

### 4.3 Family sweep — every hook that classifies Bash command text

The complete family is determinable exactly, from two independent directions that agree (see
section 6, Family A). It is **eight Claude hooks**:

| # | Hook | Covered by | One-line verdict |
| --- | --- | --- | --- |
| 1 | `.claude/hooks/validate-bash.ps1` | **this artifact** | In scope. Six unbounded substring literals plus one unanchored regex; the most over-matching member of the family and the only one whose defect needs a comparison change as well as a scan-text change. |
| 2 | `.claude/hooks/enforce-promotion-mcp-only.ps1` | spec D5 + D10 | Already in scope; four `IndexOf` token scans and two `gh` regexes, plus the `gh` relocation closure. |
| 3 | `.claude/hooks/enforce-pr-author-skill.ps1` (with `-helpers.ps1`) | spec D6 | Already in scope; `gh pr create` / `gh pr edit` triggers and the `gh` relocation closure. |
| 4 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | spec D1–D4 | Already in scope; the original five trigger patterns plus the `git` relocation closure. |
| 5 | `.claude/hooks/enforce-epic-merge-gate.ps1` | sibling researcher | In scope. Reads `tool_input.command` at line 370 and regex-classifies a `gh`/`git` merge surface; same `gh` relocation exposure as #2 and #3. |
| 6 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | sibling researcher | In scope. Reads `tool_input.command` at line 342 and classifies `git worktree remove`; same `git` relocation exposure. |
| 7 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | sibling researcher | In scope. Its own header states it "Regex-matches git worktree remove against the envelope's tool_input.command"; same `git` relocation exposure. |
| 8 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | **this artifact** | In scope. Two whole-text substring tests, no regex, no command-word notion; both an over-match and an `=`-spelling under-match. |

**No unnamed hook remains.** Every hook the sibling and I have named is accounted for, and the two
enumerations in section 6 agree exactly. Explicitly excluded from the family, with reasons:

- `.claude/hooks/enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1`,
  `enforce-prd-feature-before-planner.ps1`, `enforce-epic-wave-barrier.ps1`,
  `enforce-epic-invocation-origin.ps1`, `enforce-model-routing-receipt.ps1` — registered on the
  `Agent` matcher; they classify delegation prompts and subagent types, never `tool_input.command`.
  Out of scope.
- The eleven `Write|Edit`-matcher hooks — they classify `file_path` and `content`, not command text.
  Out of scope. (`enforce-orchestration-preimplementation-gate.ps1` appears on all three matchers,
  but its command leg is item 4 above.)
- The `SubagentStop` validators — they classify agent output text. Out of scope.
- Codex side: five hooks read `tool_input.command` — `validate-bash.ps1`,
  `enforce-promotion-mcp-only.ps1`, `enforce-orchestration-preimplementation-gate.ps1`,
  `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`. All five are the Codex
  copies of items 1, 2, 4, 5, 6. There is no Codex-only member of the family.

---

## 5. Question 5 — settled decisions D5, D6, D10

### D5 — `enforce-promotion-mcp-only.ps1` is IN SCOPE (spec lines 425–434)

**Commits the implementation to:** routing the promotion hook's classification through the same
shared helper, so its four forbidden-token `IndexOf` scans and its two `gh` regexes evaluate against
per-segment scan text rather than the raw command string. The four token literals and both regex
strings stay byte-unchanged (R2); the block-reason getters and the decision shape are unchanged.
All four copies of the hook are touched.

**Rationale of record:** the over-match is the confirmed checkpoint-bootstrap blocker. A checkpoint's
required-MCP-tool list must name the promotion tools by name, so any Bash write of a complete
checkpoint is denied today. Verified against the live file: `Get-PromotionBypassReason` lines 86–97
scans four literals — `new-potential-entry.ps1`, `new_potential_bug_entry`, `potential_to_issue`,
`new_active_feature_folder` — with `IndexOf(..., OrdinalIgnoreCase) -ge 0` over the whole command.

**Marked settled and not to be reopened at planning, execution, or review.**

### D6 — the pr-author under-match is IN SCOPE (spec lines 436–444)

**Commits the implementation to:** closing the `gh` global-option relocation in
`enforce-pr-author-skill-helpers.ps1` alongside the masking, using the same helper and the same
test suite. Concretely: `\bgh\s+pr\s+create\b` and `\bgh\s+pr\s+edit\b` move onto per-segment scan
text, and the structural `gh` classifier of D2 Piece 3 additionally classifies
`gh --repo <o/r> pr create` and `gh -R <o/r> pr edit`. Everything downstream of the trigger —
`--body-file` / `--body` parsing, receipt verification, and every `PR_*` reason code — stays on raw
text and is unchanged. Claude canonical and Claude bundle only; there is no `.codex` copy.

**Rationale of record:** closing one hook's relocation bypass while leaving the sibling's open in
the same change is arbitrary.

**Marked settled and not to be reopened.**

### D10 — promotion-hook `gh` relocation is IN SCOPE (spec lines 537–563)

**Commits the implementation to:** applying the D2 Piece 3 structural `gh` classifier to the
promotion hook's issue-creation subcommands (`issue create`, `issue new`) in all four copies —
over and above the masking that D5 alone would have delivered.

**D10 is the stylistic template for the scope amendment that brings the gate hooks in.** Its
structure, section by section, is worth copying exactly:

1. **A heading that states the reversal in its own title.** `### D10 — Promotion-hook gh relocation
   is IN SCOPE (orchestrator decision, settled, reverses the prior Non-Goal)`. The reader learns
   from the heading alone that a Non-Goal has moved.
2. **An explicit supersession sentence naming the decision it narrows**, in the first line of the
   body: "This decision **supersedes D5's masking-only scoping**…". It states what the earlier
   decision covered, what it deferred, and that the deferral is overruled. The earlier decision is
   *not* edited — the same additive discipline D8 imposes on issue #539's spec.
3. **A two-part rationale, with both parts declared load-bearing.** "The rationale has two parts,
   and both are load-bearing."
   - **Part one is evidence.** It cites a file, a line, and a regex:
     "`.claude/hooks/enforce-promotion-mcp-only.ps1` line 101 carries
     `\bgh\s+issue\s+(?:create|new)\b`, which requires `issue` to be adjacent to `gh`." (Verified:
     that is exactly line 101 of the current file.) It then names the specific bypass spelling
     (`gh --repo <o/r> issue create`) and shows it is the same defect as two already-in-scope
     instances, concluding "It is one defect class in one hook family, not a distinct condition
     peculiar to the promotion surface."
   - **Part two is a consistency argument.** "closing three of four relocation bypasses while
     leaving the fourth open — in the very change that builds the classifier that closes it — would
     be arbitrary", followed by a marginal-cost statement: "applying an existing constant table to
     a third call site rather than designing anything new."
4. **A closing settlement sentence in fixed wording:** "This decision is settled and is not to be
   reopened at planning, execution, or review."

An amendment bringing `enforce-epic-merge-gate.ps1`,
`enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`,
`enforce-parallel-abandon-gate.ps1`, and `validate-bash.ps1` into scope should therefore be written
as new decisions (D11 and following) that supersede the Non-Goal bullet at spec lines 154–158
additively, cite a file-and-line for each hook's defect, argue marginal cost against the classifier
this change already builds, and close with the same settlement sentence. It must **not** edit the
Non-Goal bullet in place, and it must not contradict D5, D6, or D10 — all three of which it extends
rather than revises. The two extra obligations the amendment carries that D10 did not are: the
`validate-bash.ps1` comparison-semantics caution in section 4.2, and the fact that
`enforce-parallel-abandon-gate.ps1` has a **two**-copy set rather than four.

---

## 6. Numeric Derivation Evidence

Three numeric claims are proposed above and are candidates for `spec.md` acceptance criteria. Each
is derived twice, by independent strategies, with member sets compared.

### Family A — the complete set of Claude enforcement hooks that classify Bash command text

- **Complete Family:** every `.ps1` under `.claude/hooks/` that reads a Bash command string from a
  PreToolUse envelope and makes a permission decision from its content.
- **Exhaustive Search Scope:** all 41 files matching `.claude/hooks/*.ps1`, plus every PreToolUse
  entry in `.claude/settings.json`. Both directions cover the whole directory and the whole
  registration file; neither is restricted to a single named pattern.
- **Inclusion Rules:** the file extracts the envelope's `command` field (under any accessor
  spelling) **and** branches its decision on that string's content.
- **Exclusion Rules:** hooks that only classify `file_path`, `content`, `subagent_type`, `prompt`,
  or subagent output; helper files that are dot-sourced and never registered; hooks on the
  `Write|Edit`, `Agent`, or `SubagentStop` surfaces that never touch `command`.
- **Primary Search Strategy:** enumerate the `matcher: "Bash"` block of `.claude/settings.json`
  (lines 89–126) and take every registered hook path.
- **Primary Member Set:** `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`,
  `enforce-pr-author-skill.ps1`, `enforce-orchestration-preimplementation-gate.ps1`,
  `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`,
  `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`.
- **Primary Count:** 8.
- **Cross-check Search Strategy:** a content search across `.claude/hooks/` for command-field
  extraction, using a two-alternative expression that covers **both** accessor spellings present in
  the tree — `-Name 'command'` (the `Get-ClaudeHookToolInputString` / `Get-StringProperty` form) and
  `.command` (the direct property form) — so the search is not narrowed to one helper's API.
  Prose-only hits in comment blocks were then discarded by reading each hit in place.
- **Cross-check Member Set:** `enforce-epic-worktree-removal-gate.ps1` (line 342),
  `enforce-epic-merge-gate.ps1` (line 370), `enforce-parallel-worktree-removal-gate.ps1` (line 201),
  `enforce-parallel-abandon-gate.ps1` (line 232),
  `enforce-orchestration-preimplementation-gate.ps1` (line 379), `validate-bash.ps1` (line 179),
  `enforce-pr-author-skill.ps1` (line 178), `enforce-promotion-mcp-only.ps1` (line 211).
- **Cross-check Count:** 8.
- **Member-set Comparison:** normalized to bare filenames, the two sets are identical; the symmetric
  difference is empty. Registration and implementation agree, so there is neither a registered hook
  that ignores `command` nor an unregistered file that reads it. **8 is asserted.**

### Family B — registry files a new shared hook helper must be added to

- **Complete Family:** every checked-in file, other than a copy of the helper itself, whose content
  must change for a new `$script:SharedModuleNames`-class helper to be delivered and measured.
- **Exhaustive Search Scope:** the whole repository, via a repository-wide content search; plus a
  reading of every mechanism row in spec D9 and of each mechanism's own source to determine whether
  it enumerates files or globs directories.
- **Inclusion Rules:** the file names shared hook modules individually, so a new one is invisible to
  it until added.
- **Exclusion Rules:** mechanisms that discover files by directory walk or glob and therefore need
  no edit; documentation and evidence files; the helper's own four copies.
- **Primary Search Strategy:** repository-wide content search for the name of an existing
  `SharedModuleNames` member, `enforce-orchestration-preimplementation-gate-helpers\.ps1`, then
  discard `docs/**` hits and dot-source call sites inside hook files.
- **Primary Member Set:** `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`;
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`;
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`;
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- **Primary Count:** 5.
- **Cross-check Search Strategy:** independent of any existing filename — walk spec D9's mechanism
  table row by row and open each named mechanism to classify it as *enumerating* or *globbing*.
  Rows: (i) contracts-suite hash `It` line 111 → enumerating, via `SharedModuleNames`;
  (ii) contracts-suite manifest `It` line 134 → enumerating, the Codex `core.json`;
  (iii) contracts-suite parse/cap/stdin/`CLAUDE_` checks → same array, no new file;
  (iv) `test_push_down_claude_resource_contracts.py` lines 115–131 → **globbing**
  (`list_scoped_files(REPO_ROOT)`), no edit; (v) Claude `core.json` → enumerating;
  (vi) the two `pester.runsettings.psd1` files → enumerating, two files;
  (vii) `enforcement-hooks-no-python-invocation.Tests.ps1` lines 40–41, 60 → **globbing**
  (`Get-ChildItem -Recurse` over two directories), no edit. Additionally checked, and found not to
  apply to a `.claude/hooks/*.ps1` file: the `tests/scripts/claude-lib/**/*.Manifest.Tests.ps1`
  convention, which exists only for `.claude/lib` modules.
- **Cross-check Member Set:** contracts suite (from i, ii, iii); Codex `core.json` (ii); Claude
  `core.json` (v); repo `pester.runsettings.psd1` (vi); bundled `pester.runsettings.psd1` (vi).
- **Cross-check Count:** 5.
- **Member-set Comparison:** the two sets are identical file-for-file. The strategies are genuinely
  independent — the first is name-driven and would miss a registry that has never held this
  particular name; the second is mechanism-driven and would miss a registry not listed in D9.
  Their agreement rules out both failure modes. **5 registry files is asserted**, carrying **7**
  entries (the two runsettings files take two entries each). D7's "six registrations" is **not**
  asserted; it counts the two bundle file copies as a registration.

### Family C — file copies of a new shared hook helper

- **Complete Family:** every checked-in on-disk copy of one shared hook file.
- **Exhaustive Search Scope:** the whole repository, by filename glob, for each of two existing
  reference files of different delivery shapes.
- **Inclusion Rules:** a file whose basename equals the reference basename, anywhere in the tree.
- **Exclusion Rules:** none; the glob is unrestricted by directory.
- **Primary Search Strategy:** glob `**/enforce-promotion-mcp-only.ps1` — a hook D9 asserts is
  present in all four locations, used here as the four-copy reference shape.
- **Primary Member Set:** `.claude/hooks/…`; `.codex/hooks/…`;
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/…`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/…`.
- **Primary Count:** 4.
- **Cross-check Search Strategy:** glob `**/validate-bash.ps1` — a different hook, chosen because it
  is one of the two this artifact analyses and is independently known to be a divergent pair, so it
  tests the copy *shape* rather than re-testing the same file.
- **Cross-check Member Set:** `.claude/hooks/validate-bash.ps1`; `.codex/hooks/validate-bash.ps1`;
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`;
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`.
- **Cross-check Count:** 4.
- **Member-set Comparison:** the two member sets occupy the identical four directories; normalized
  to directory prefixes they are equal. Both a byte-identical-pair hook and a divergent-pair hook
  ship to the same four locations, so the four-copy shape is a property of the delivery system, not
  of any one file. **4 is asserted** for a helper serving both sides.
- **Counter-example recorded, deliberately not folded into the count:** globs of
  `**/codex-pretooluse-file-mapping.ps1` (2 copies, Codex-only) and
  `**/enforce-parallel-abandon-gate.ps1` (2 copies, Claude-only) show that a **single-side** file has
  a 2-copy set. The 4-copy assertion is therefore conditional on the helper serving both sides,
  which the D7 recommendation requires.

---

## 7. Testing implications

Consistent with `.claude/rules/general-unit-test.md` and D9's "any new Codex-side scenario goes in a
new test file" constraint (the contracts suite is at 494/500 lines):

- **New Claude-side scanner suite** — `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1`.
  Unit surface for the scanner itself: segment splitting outside quotes; the heredoc state machine
  including `<<-`, quoted delimiters, multiple pending heredocs on one line, an unterminated
  heredoc, and `<<<`; the `Unbalanced` and `HasLiveSubstitution` determinations; the wrapper
  carve-out constant's exact membership; and the git and gh option tables' exact membership (R6
  requires all three to be pinned by test).
- **New Codex-side suite** — a new file under `tests/scripts/codex-hooks/`, never an addition to
  `legacy-codex-hook-contracts.Tests.ps1`. The single unavoidable edit to that suite is the one-line
  append to `$script:SharedModuleNames` at line 30, which adds no line.
- **Regression pins in both directions, per D3's table** — every row of the D3 form table is an
  obligation; the wrapper deny pins (`xargs`, `bash -c`, `pwsh -NoProfile -Command`) must stay green,
  and the newly-denying relocation forms need positive pins.
- **For the two hooks this artifact adds**, if the scope amendment lands:
  - `enforce-parallel-abandon-gate`: an over-match pin (a `grep` for the token allows), an
    under-match pin (`--disposition=abandon` denies without confirmation), and a segment-scoped
    confirmation pin. The 24 existing `It` blocks stay green, including the order-independence
    pin at line 62.
  - `validate-bash`: an over-match pin (a quoted `rm -rf` mention in a commit message allows), the
    `--force-with-lease` pin (allows), relocation pins (`git -C <dir> push --force` denies), and the
    existing six denylist pins (lines 31–36) plus eight `cd`-chain pins (lines 164–171) unchanged.
- **Determinism.** All of the above is pure string processing over literal inputs — no clock, no
  RNG, no filesystem, no child process, no temporary files.
- **Coverage.** Every new production file joins both `pester.runsettings.psd1` coverage lists in the
  same change, so no production file leaves the denominator.

---

## 8. Blocking unknowns and risks

1. **None blocking the D7 recommendation.** Every claim in section 3 is grounded in a file read or a
   content search against this worktree.
2. **The one-file-versus-two-files question is unresolved by measurement and cannot be**
   — it depends on the implementation's documentation density, which does not exist yet. The
   estimate (≈420–620 lines) straddles the cap. Treat "two sibling files" as the planning
   assumption, because the downside of assuming one file and being wrong is a mid-execution change
   to five registry files, whereas the downside of assuming two and being wrong is one unnecessary
   file.
3. **`validate-bash.ps1` needs a comparison-semantics change, not only a scan-text change.** The
   `--force-with-lease` failure is a missing token boundary inside a denylist literal. The scanner
   alone does not fix it. If the scope amendment asserts that bringing `validate-bash.ps1` in scope
   fixes the `--force-with-lease` block, it must also state that R2 permits changing `Contains` to
   token equality while keeping the literal's text byte-unchanged. Left unstated, this is a
   foreseeable review dispute.
4. **The Codex copies of a new helper are outside the no-Python gate's reach.**
   `enforcement-hooks-no-python-invocation.Tests.ps1` walks `.claude/hooks` and `.claude/lib` only.
   The policy still binds; the automated check does not extend to `.codex/**`. The Codex byte-identity
   contract makes drift between the two Codex copies impossible but does not compare them to the
   Claude copies.
5. **`enforce-parallel-abandon-gate.ps1` has a token seam with a Python producer.**
   `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` parses both
   `.claude/hooks/enforce-parallel-abandon-gate.ps1` and
   `scripts/dev_tools/parallel_mutation_abandon_cli.py` at run time and fails if either side's token
   declaration changes shape. Any fix must keep both token literals in their current
   single-assignment form at lines 41–42. This is a constraint the sibling hooks do not have.
6. **The `--disposition=abandon` bypass is derived, not executed.** It follows from the CLI's use of
   a standard `argparse` optional (line 236) and standard `argparse` `--opt=value` handling. It has
   not been run. Execution-time confirmation is a reasonable first implementation step but is not
   required to accept the finding.
