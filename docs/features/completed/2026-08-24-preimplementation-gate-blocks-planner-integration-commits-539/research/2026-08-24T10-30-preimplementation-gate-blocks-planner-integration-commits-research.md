# Preimplementation Gate Blocks Planner Integration Commits — Research (Issue #539)

- **Issue:** #539
- **Date:** 2026-08-24T10-30
- **Work mode:** full-bug
- **Feature folder:** `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539`
- **Method:** read-only inspection of all four hook copies, both Pester suites, both runtime registrations, coverage settings, pack-manifest/parity contracts, and the issue #535 precedent folder. No file outside this research path was modified. No shell was available to this researcher, so hash claims are content-comparison claims (full-file reads), not recomputed digests; recomputed digests exist in the #535 evidence cited below.

---

## 1. Current behavior, precisely

### 1.1 The four copies and their pair relationship

| Copy | Path | Lines | Pair |
| --- | --- | --- | --- |
| Canonical Claude | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 340 | Claude pair |
| Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 340 | Claude pair |
| Canonical Codex | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 337 | Codex pair |
| Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 337 | Codex pair |

- **Claude pair:** verified line-by-line identical by full reads of both files (340 lines each, identical content). Content equality of every `.claude/**` file against its bundle counterpart is separately enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (cited in `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/other/claude-pair-hash.2026-08-23T21-48.md`, which recorded SHA256 `F57FAE11...493C` for both copies).
- **Codex pair:** verified line-by-line identical by full reads of both files (337 lines each, identical content). Byte-identity is enforced at run time by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:111-117` (`Get-FileHash` over `$script:StaticCheckNames`). The #535 evidence `codex-pair-hash.2026-08-23T21-58.md` recorded SHA256 `E8A2DFC7...4F37` for both.
- **The two pairs are deliberately divergent implementations.** The Codex copies dot-source `codex-pretooluse-file-mapping.ps1` (line 11) instead of importing `HookPayload.psm1`, add apply_patch marker parsing inside `Test-ImplementationCommand` (lines 92–103), use a permissive decision entry (`allow` on empty `-ToolInputRaw`, `throw` on malformed JSON; lines 260–267) instead of the Claude anomaly-deny path, and carry a Codex stdin entrypoint (lines 302–336). The #535 spec (its section "Four-copy parity") records this divergence as intentional: "the fix is applied to it in its own idiom, not byte-copied from `.claude`."

### 1.2 Function line ranges, canonical `.claude` copy

| Function | Lines |
| --- | --- |
| `$script:CheckpointPaths` (seven exempt literals) | 18–26 |
| `Test-FeatureDocumentationOrEvidencePath` | 57–63 |
| `Test-ImplementationPath` | 65–77 |
| `Test-ImplementationCommand` | 79–103 (git pattern at line 90) |
| `Test-PreparationModeDelegation` | 105–138 |
| `Test-ImplementationDelegation` | 140–162 |
| `Test-OrchestrationReady` | 164–192 |
| `Invoke-OrchestrationPreimplementationGateDecision` | 235–287 (command branch: 262–267) |
| `Invoke-OrchestrationPreimplementationGateEntryPoint` | 289–325 |

Corresponding Codex-copy ranges: `Test-ImplementationCommand` 82–119 (git pattern at line 106), `Test-OrchestrationReady` 181–209, `Invoke-OrchestrationPreimplementationGateDecision` 252–300.

### 1.3 The defect, confirmed against the source

1. `Test-ImplementationCommand` (`.claude` copy lines 89–95) classifies by five regexes against the whole trimmed command text. `'(^|\s)git\s+(add|commit)\b'` (line 90) matches every staging and commit invocation, and also any command whose text merely contains the two-word literal anywhere (here-string bodies, message bodies, quoted prose). No path inspection occurs on this leg in the Claude pair. (The Codex pair inspects paths only for apply_patch markers, lines 92–103 — a precedent, see section 3.)
2. The `docs/features/active/` prefix exemption (line 70) and the `CheckpointPaths` membership exemption (line 73) live inside `Test-ImplementationPath`, which is reached only from the `file_path` branch of the decision function (line 260). The `command` branch (line 264) reaches `Test-ImplementationCommand` and nothing else.
3. `Test-OrchestrationReady` (lines 164–192) requires the single-feature tuple: non-empty `issue-num`, non-empty `feature-folder` beginning `docs/features/active/`, non-empty `route_id` (or `path_selected` fallback, line 176), and truthy `lifecycle_ready`. An epic run (artifacts under `docs/features/epics/<slug>/`, many issues, an integration branch) and a parallel run (artifacts under `docs/features/parallel/<slug>/`) have no truthful single-feature tuple, so once a `git add`/`git commit` is classified as implementation the deny is structurally unavoidable for the planner surfaces.
4. Consequence, confirmed against the planner contracts: `.claude/skills/epic-plan/SKILL.md:79-85` mandates committing `epic.md` to the integration branch before delegating preparation and fanning in prepared child outputs; `.claude/skills/parallel-plan/SKILL.md` mandates the fully-resolved committed manifest (line 49), per-item plan commits on per-item feature branches (line 144), and a durable kickoff copy committed to `docs/features/parallel/<slug>/parallel-kickoff.md` (line 471). Every one of these is a `git add`/`git commit`, so `/epic-plan` and `/parallel-plan` remain blocked at their integration steps despite PR #536.

### 1.4 Whole-command-text over-match (second facet)

The pattern is applied to the entire command string with `(^|\s)` as the only anchor (lines 97–101). A `Bash` command such as a heredoc that writes a document containing the words `git add`, a `gh pr create --body "... git commit ..."`, or a `git log --grep "git add"` is classified as an implementation command. This facet is in scope for analysis (section 5) but the recommended remedy does not change the trigger (rationale in 5.2).

---

## 2. Precedent: issue #535 / PR #536

Source folder: `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/` (spec.md, plan.2026-08-23T20-40.md, research, evidence, feature-audit/policy-audit/code-review).

- **Structure of the fix.** Two enumerated exemptions layered over unchanged deny logic: (1) `Test-ImplementationPath` widened from one checkpoint literal to a script-scoped array of exactly seven repo-relative literals behind one `-contains` membership check — deliberately a literal set, not a directory prefix or glob (spec.md "Design summary" item 1, acceptance criterion 1); (2) a new `Test-PreparationModeDelegation` three-conjunct predicate (agent exactly `orchestrator`, field-scoped `prompt` carrying both verbatim markers) evaluated before the unchanged whole-payload delegation regex, with any extraction failure falling through to the stricter classifier (hook lines 149–158).
- **Four-copy synchronization.** The same behavioral fix landed in all four copies; the Codex pair received it "in its own idiom" (spec.md, Four-copy parity). The Codex pair was updated byte-identically in the same commit; the Claude pair's parity is enforced by the push-down content-equality pytest.
- **Parity evidence produced.** `evidence/other/claude-pair-hash.2026-08-23T21-48.md` and `evidence/other/codex-pair-hash.2026-08-23T21-58.md` record SHA256 equality per pair, line counts, and the method (same edit hunks applied to both members of a pair rather than file copy). `evidence/qa-gates/pushdown-parity.2026-08-23T22-18.md` records the push-down gate. Fail-before evidence under `evidence/regression-testing/` (failing baseline of the new allow cases against the unfixed hook), then pass-after per pair.
- **Deliberate out-of-scope legs and why.** spec.md "Scope & Non-Goals" and "Root Cause Analysis" explicitly exclude: (a) **the `git add|commit` housekeeping gap in `Test-ImplementationCommand`** — recorded as a "related standing finding; unchanged by this fix" (this is issue #539's subject); (b) issue #516 absolute-path normalization on the `file_path` branch (the literal set stays repo-relative so the #516 fix composes later); (c) `enforce-promotion-mcp-only.ps1` overbreadth; (d) any change to `Test-OrchestrationReady`. The stated reason for (a): #535 kept the gate fail-closed for genuine implementation operations and did not touch the command classifier at all.
- **Reusable execution facts.** Change budget: four production PowerShell files exceeds the direct-mode cap of 2, so #535 routed through `powershell-orchestrator`/explicit batching (spec.md Dependencies). Tests were driven entirely through the pure seam `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ... -CheckpointRaw ...` with no disk I/O or child processes; allow-case prompts used the verbatim SKILL.md kickoff lines so contract drift fails the suite.

---

## 3. Remedy candidates and recommendation

### (a) Pathspec-scoped staging/integration exemption

Exempt a `git add`/`git commit` invocation if and only if every pathspec operand parses successfully and falls inside an orchestration-bookkeeping tree; every unparseable, pathless, tree-wide, or mixed invocation stays denied.

- **Correctness.** Directly matches the requirement: the property that makes a planner commit safe is *what it stages*, not who runs it. A commit staging only `docs/features/epics/**` markdown cannot introduce implementation code regardless of session state.
- **Fail-closed safety.** Exemption is granted only on a positive parse; every ambiguity denies (table in section 4). The pre-fix behavior (deny) is the fallback for every unmodeled form, so rollback and parser bugs both degrade toward deny, never toward allow.
- **Testability.** Pure string classification, drivable through the existing `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ... -CheckpointRaw ...` seam with zero I/O. Stateless and session-agnostic.
- **Blast radius.** Confined to `Test-ImplementationCommand` (plus an extracted helper, section 6) in the four copies, tests, coverage lists, and — see section 8.3 — a command-shape note in the two planner skills. No checkpoint schema, registration, or readiness change.
- **In-repo precedent.** The Codex copy already performs path-aware command classification inside `Test-ImplementationCommand`: apply_patch `*** Add/Update/Delete File:` and `*** Move to:` records are routed through `Test-ImplementationPath` (Codex copy lines 92–103). Remedy (a) extends the same idea to the git leg.
- **Cost.** A shell-token parser in PowerShell with a modeled option table; the largest and most defect-prone piece of the three candidates. Mitigated by the deny-on-unknown rule and by the ~20-case test table in section 7.

### (b) Accept `epic-planner-state.json` / `parallel-planner-state.json` as alternative readiness sources on the command branch

- **Correctness/safety defects.** The planner checkpoints are writable from the first moment of a planner run precisely because #535 exempted them (`CheckpointPaths`, lines 18–26). Treating their existence (or even a shape-validated "planning underway" state) as command-branch readiness opens the *entire* command classifier — `git add scripts/foo.py`, `pytest`, formatters — for as long as a planner checkpoint sits on disk. The hook is session-agnostic (it reads a repo file, `Get-CheckpointContent`, lines 194–203), so a stale checkpoint from a prior or concurrent run opens the gate for unrelated sessions. The exemption is scoped by *time*, not by *content*, which is the wrong axis for this defect.
- **Cost.** Small (a second readiness probe modeled on `Test-OrchestrationReady`), which is its only advantage.

### (c) Scope the command-branch gate to implementation routes only

- **Correctness/safety defects.** The hook has no session identity; the only route signal available is `route_id` inside whatever checkpoint happens to be on disk. Planner runs deliberately do not own `orchestrator-state.json`, so "route is not an implementation route" collapses into "checkpoint absent or planner-shaped" — behaviorally candidate (b) with the same staleness and cross-session exposure, plus it exempts production-path commits during any non-implementation phase.

### Combinations

(a)+(b) adds (b)'s exposure without adding anything (a) does not already grant for the enumerated trees. No combination improves on (a) alone.

### Recommendation

**Remedy (a), alone.** It is the only candidate whose exemption predicate is the same property that defines the hazard (staged content), the only one that stays stateless and session-agnostic, and the only one whose failure modes all point toward deny. Candidates (b) and (c) both convert a content property into a temporal/state property and thereby exempt production-path commits during planner activity. The trade the planner must accept for (a): a real parser with a modeled option table (implementation and review cost), a residual usability constraint on pathless `git commit` (section 4.3), and no improvement to the over-match facet (section 5). The decision remains the atomic-planner's; sections 4–6 give the material needed to write the plan either way.

### Exempt tree set

`docs/features/epics/`, `docs/features/parallel/`, `docs/features/active/`, `artifacts/orchestration/`, and — recommended — `docs/features/potential/`.

**On `docs/features/potential/`:** promotion is performed by each preparation-mode child via the promotion MCP tools (`.claude/skills/parallel-plan/SKILL.md:40-47`), and promotion moves the lifecycle record out of `docs/features/potential/` (the #535 spec itself links a promoted record at `docs/features/potential/promoted/...`). A preparation child's mandated "commit the feature folder and plan" therefore plausibly stages a deletion/move under `docs/features/potential/` alongside the additions under `docs/features/active/`. If `potential` is excluded, that commit denies on a path the run legitimately touched. The tree holds only markdown lifecycle records (no path there matches the implementation-extension pattern on the file_path branch either), so including it does not widen the gate toward production code. Not verified end-to-end at runtime; the planner should confirm during test authoring that the promotion-move commit shape actually includes the potential-side path.

**On `artifacts/orchestration/` as a prefix (asymmetry with #535's literal set).** #535 deliberately rejected a directory-prefix exemption *on the write branch*, because a prefix would let arbitrary future `.json` writes bypass the gate. The command branch differs: staging a file records content that already exists on disk, and every governed write into that directory already passed the `file_path` gate (or is a kickoff `.md`, which never matched the extension pattern). A staging-side prefix therefore cannot launder an implementation write that the write branch would have denied. The planner may still choose the stricter shape (the seven literals plus the two kickoff `.md` shapes) at the cost of one more moving part; the prefix is defensible here and the reasoning above should be recorded in the spec either way.

---

## 4. Pathspec parsing for remedy (a)

### 4.1 What must be parsed

To grant the exemption safely the classifier must, for each command segment whose invocation is `git add ...` or `git commit ...`:

1. Tokenize the segment shell-style: whitespace splitting with single- and double-quote grouping. Unbalanced quotes ⇒ parse failure ⇒ DENY.
2. Confirm the segment's leading token (after nothing else — see the `-C` rule) is `git` and the next token is `add` or `commit`. Any token between `git` and the subcommand ⇒ DENY.
3. Walk the remaining tokens against a modeled option table: options that take a following argument (`-m`, `--message`, `-F`/`--file` for commit) consume it; `--opt=value` forms are self-contained; `--` ends option processing and everything after it is a pathspec even if dash-leading. Any dash-leading token not in the modeled allowlist ⇒ DENY.
4. Normalize each pathspec operand (`\` → `/`, strip balanced quotes) and require it to pass the exempt-tree prefix test.
5. Grant the exemption only if at least one pathspec operand was found and **all** operands passed.

### 4.2 Fail-closed rule table

| # | Form | Rule | Reason |
| --- | --- | --- | --- |
| 1 | `git add` with zero operands | DENY | Nothing parseable to scope |
| 2 | `git add -A` / `--all` / `-u` / `--update` / `--no-all` variants | DENY | Index-wide/tree-wide staging; no per-path claim |
| 3 | `git add .` / `git add :/` / any `:/`-rooted operand | DENY | Whole-tree operand |
| 4 | `git commit` with no pathspec operand (including `-m`-only) | DENY | Records already-staged content the parser cannot see; the index is not fully gated today (`git rm`/`git mv`/`git checkout` are unmatched by the trigger, so staged state is unverifiable) |
| 5 | `git commit -a` / `--all` / `-i` / `--include` / `--interactive` / `-p` / `--amend` | DENY | Widens the recorded content beyond the named pathspecs (or rewrites history) |
| 6 | `--pathspec-from-file=` / `--pathspec-file-nul` | DENY | Pathspecs are off the command line |
| 7 | `--` separator | Tokens after `--` are pathspecs even when dash-leading; each must pass the prefix test; `--` with nothing after it and no earlier pathspec ⇒ DENY (rule 1/4) |
| 8 | Dash-leading token before `--` not in the modeled allowlist | DENY | Unknown option may be tree-wide (fail closed on the unmodeled) |
| 9 | Operand starting with `:` — `:(exclude)`, `:!`, `:/`, `:(top)`, `:(glob)`, `:(icase)`, any magic | DENY | Pathspec magic can escape or invert the tree scope |
| 10 | Leading-dash operand without a preceding `--` | DENY | Indistinguishable from an option (rule 8) |
| 11 | Quoted operands / operands with spaces | Strip balanced quotes, then apply the prefix test; unbalanced quoting ⇒ DENY | Exempt trees contain no spaces, but quoting is legal |
| 12 | Operand containing `$`, backtick, or the segment containing redirection (`>`, `<`) | DENY | Interpolation/redirection not resolvable statically (same marker logic as the placeholder guards in `.claude/rules/plan-acceptance-gates.md`) |
| 13 | Chained/compound lines (`&&`, `;`, `\|\|`, `\|`, newline) | Split into segments outside quotes. The exemption holds only if **every** segment that the implementation trigger matches is independently exempt; a non-git segment matching any other implementation pattern (pytest, npx, ...) still requires readiness. Unsplittable or ambiguous text ⇒ DENY |
| 14 | `git -C <dir>` / `--git-dir=` / `--work-tree=` / env-style or any prefix between `git` and the subcommand | DENY | Pathspec base relocated; repo-relative prefix test is no longer sound |
| 15 | Glob operands (`*`, `?`, `[`) | Allow only when the literal prefix before the first wildcard is strictly inside an exempt tree and the token has no `..` segment; otherwise DENY (`docs/features/*` DENIES — it can match `docs/features/potential` siblings outside the chosen set if `potential` is excluded, and future siblings regardless) |
| 16 | Absolute operands (`/...`, `C:\...`, `\\...`) | DENY | Base not provably the repository root (mirrors the #516 posture: exempt entries stay repo-relative) |
| 17 | Any `..` segment | DENY | Escapes the prefix |
| 18 | Backslash separators in an otherwise relative operand | Normalize `\` → `/` before the prefix test (consistent with the `file_path` branch, hook line 259) |
| 19 | Mixed operand set (one exempt + one production path, e.g. `git add docs/features/epics/x/epic.md scripts/a.ps1`) | DENY | All-operands-exempt is the invariant |

### 4.3 Consequence the planner must resolve: pathless `git commit`

Rule 4 means the common two-step `git add <paths>` then `git commit -m "msg"` remains blocked at the second step even after the fix, because the commit names no paths. The workable shapes under remedy (a) are pathspec-bearing commits: `git commit -m "msg" -- <exempt paths>` or `git commit <exempt paths> -m "msg"` (git's default `--only` semantics record the named paths' content directly, so a prior `git add` is not even required for tracked files; a brand-new file still needs the — exempt — `git add` first). **The plan must therefore include a prose amendment to `.claude/skills/epic-plan/SKILL.md` and `.claude/skills/parallel-plan/SKILL.md` (and their bundle mirrors) instructing planner surfaces to use the pathspec-bearing commit form.** Without that amendment the fix does not unblock the planner flows it exists for.

A considered-and-deferred alternative: allow pathless `git commit` by shelling out to `git diff --cached --name-only` and testing the actual staged set against the exempt trees. This verifies real content rather than command text, but it adds an external-process dependency to a hook that is currently pure, requires an `Invoke-GitExe`-style wrapper seam plus mocks (`.claude/rules/powershell.md` Design Seams), and fails ambiguously when the working directory is not the repo root. It composes cleanly as a later enhancement; it should not gate this fix.

---

## 5. Interaction with the whole-command-text over-match

### 5.1 What a pathspec-aware classifier does and does not fix

The classifier runs only *after* the broad trigger regex fires, and grants an exemption only on a positive parse of a genuine `git add|commit` segment. A command whose text merely contains the literals in prose (heredoc bodies, `--body` strings, quoted messages) will not parse as an exempt staging segment, so it stays denied exactly as today. **Remedy (a) leaves the prose-literal false-positive class unchanged.** It removes only the false positives that are genuine, orchestration-tree-only staging commands — which is the class issue #539 is about.

One partial improvement: under rule 13 the segment model can recognize that a matched region sits inside a quoted operand of a non-git segment; whether to exonerate that case is a planner choice. Doing so is a trigger-scoping change, analyzed next.

### 5.2 Scoping the trigger to segment-leading tokens: risk assessment

Scoping the *trigger* (not just the exemption) to segments whose leading token is `git` would eliminate the prose-literal false positives (heredocs, message bodies). The fail-closed cost is a new bypass class: any wrapper that puts `git` in non-leading position evades the gate entirely — `xargs git add`, `bash -c "git add ."`, `pwsh -Command "git commit ..."`, `env GIT_X=1 git add .` (depending on how env-prefixes are modeled). Enforcement hooks are adversarial-facing by design, so opening a syntactic bypass to buy ergonomic relief inverts the gate's priorities. **Recommendation: keep the trigger regex unchanged in this fix; use parsing only to grant exemptions (allow-side), never to suppress the trigger (deny-side). Record the prose-literal over-match as a residual known limitation** (it already has a memory-level record as the "checkpoint bootstrap pincer" / staging-block standing finding). If a later feature wants trigger scoping, it should be its own issue with its own bypass analysis.

---

## 6. File-size budget

- Canonical `.claude` copy: 340 lines (cap 500; headroom 160). Canonical `.codex` copy: 337 lines (headroom 163). Both bundle copies match their canonicals.
- Estimated addition for remedy (a): exempt-tree constant (~8), segment splitter (~25–35), quote-aware tokenizer (~40–60), option model for `add`/`commit` (~20–30), operand prefix/magic/glob test (~30–40), integration into `Test-ImplementationCommand` (~10–15), plus house-style comments. **Realistic total: 130–190 lines per copy.** The upper half of that range exceeds both headrooms; the lower half fits with almost no margin for the next fix (#516 is queued against the same file).
- **Verdict: plan the extraction rather than betting on the low estimate.** The repository has two established idioms:
  1. **Claude hooks: dot-sourced sibling helper** — `.claude/hooks/enforce-pr-author-skill.ps1:146-148` dot-sources `enforce-pr-author-skill-helpers.ps1` with a comment naming the "issue #501 headroom split"; `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:203-204` lists `enforce-parallel-cohort-barrier-helpers.ps1` and `enforce-pr-author-skill-helpers.ps1` as "dot-sourced helper siblings extracted for headroom".
  2. **Claude lib module** — `Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force` (hook line 9), mirrored at `extensions/drm-copilot/resources/claude-customizations/.claude/lib/hook-payload/HookPayload.psm1`.
  The Codex runtime has **no** `.codex/lib`; its sharing idiom is a sibling `.ps1` in `.codex/hooks/` (`codex-pretooluse-file-mapping.ps1`, dot-sourced at Codex hook line 11, registered in `$script:SharedModuleNames` at `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30` and in the core pack manifest per the `It` at lines 134–139). **The sibling-helper idiom is therefore the only one that works uniformly across both pairs; recommend it.**
- Exact mirrored paths a helper extraction requires (four files):
  1. `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
  2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (content-equal to 1; enforced by `test_push_down_claude_resource_contracts.py`)
  3. `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
  4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (byte-identical to 3; enforced by the hash-binding `It`)
- Required registrations for the new files:
  - `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30` — append the helper name to `$script:SharedModuleNames` (this automatically subjects it to the parse/500-line/byte-identity/no-legacy-env checks and to the pack-manifest `It`).
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` — add `.codex/hooks/<helper>`.
  - `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — add the Claude helper (the manifest lists the gate hook today; completeness is checked by `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` on the codex side; the claude-side contract test compares content of all bundled files).
  - Coverage denominator: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (the gate hook is listed at lines 131 and 198; both helper files must be added — the Coverage Exclusion Policy forbids leaving a changed production surface outside the denominator) and its mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- Since the classification logic is pure string work, the Claude and Codex helper files can be byte-identical to each other, which reduces the divergence surface even though no test currently binds the two pairs together.

---

## 7. Test surface

### 7.1 `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (461 lines)

- Dot-sources the canonical hook (`. $script:UnderTest`, lines 6–7; the hook's `$MyInvocation.InvocationName -eq '.'` guard at line 328 makes this safe).
- Payload builders in `BeforeAll`: `ConvertTo-ImplementationWriteToolInput` (9–19), `ConvertTo-CommandToolInput` (21–28, builds `{tool_name:'Bash', tool_input:{command:...}}`), `ConvertTo-DelegationToolInput` (30–37), `ConvertTo-CheckpointRaw` (39–53).
- Checkpoint supply: every decision test passes `-CheckpointRaw` explicitly through the pure seam; #535 tests pass an explicitly **not-ready** checkpoint so the assertion measures the exemption itself rather than the on-disk checkpoint (comment at lines 260–263). New allow-cases must copy this pattern.
- Contexts: implementation writes (56–170; the command-branch denials sit at 112–149, including `'git add .'` and `'git commit -m "test"'` at 123–133), parsing/anomaly fail-closed (172–244), #535 checkpoint-write exemptions (246–309), #535 preparation-delegation exemption (311–400), entrypoint exit-code seam (402–430), settings registration for both Claude settings copies (432–460).
- Existing parity assertion: none against the Codex pair in this file; pair parity lives in the codex suite and the push-down pytest.

### 7.2 `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (494 lines)

- Static checks over canonical+bundle for all listed hooks: parse + 500-line cap (93–109), **byte-identity via `Get-FileHash`** (111–117), stdin-read presence (119–125), no legacy `$env:CLAUDE_` (127–132), pack-manifest listing for shared modules (134–139).
- Behavior: process-level invocations via `Invoke-CodexHookProcess` (60–90), pure-decision denial for the gate (217–222, dot-sources the canonical `.codex` copy), #535 allow-cases (237–251), and an in-process behavior Context (295–493) whose `-ForEach` classification table (348–357) asserts `Test-ImplementationCommand 'git commit -m "wip"'` ⇒ `$true` — an expectation that **remains true** under remedy (a) (pathless commit still classifies as implementation), so no existing assertion needs weakening.

### 7.3 Where the new scenarios attach

| Scenario | Attachment |
| --- | --- |
| Orchestration-tree-only staging allowed with no ready checkpoint (`git add docs/features/epics/<slug>/epic.md`, parallel manifest, kickoff `.md` under `artifacts/orchestration/`, pathspec-bearing commit form, backslash spelling, quoted operand) | New `Context 'issue #539 orchestration-tree staging exemption'` driven through `ConvertTo-CommandToolInput` + not-ready `ConvertTo-CheckpointRaw` |
| Mixed pathspec including a production path (`.ps1`/`.py`/`.ts`/`.cs`) denied | Same context, deny cases |
| Bare/unparseable staging denied (`git add .`, `git add -A`, pathless `git commit -m`, `:(exclude)` magic, `-C` prefix, unbalanced quote, chained line with one non-exempt segment) | Same context, one `It` per table row of section 4.2 (a `-ForEach` table keeps this compact) |
| Existing implementation-command behavior unchanged | Groups at 112–149 re-run unmodified; the codex `-ForEach` row `git commit -m "wip"` ⇒ true re-run unmodified |

**File-size constraint on the tests themselves:** the Claude suite is at 461/500 and the Codex suite at 494/500. The new scenario set (realistically 80–150 lines) does not fit in either. Plan a **new test file per side**, mirroring the tests-mirror-source layout: e.g. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (dot-sourcing the canonical `.claude` hook exactly as the existing suite does) and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (dot-sourcing the canonical `.codex` copy). The only edits to the existing 494-line codex file are the one-line `$script:SharedModuleNames` addition (if the helper extraction is taken) — +1 line fits.

### 7.4 Coverage posture

Both canonical hook copies are explicitly in the Pester coverage denominator (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:131` for `.codex`, `:198` for `.claude`). The uniform >= 85% line-coverage threshold applies (no PowerShell branch gate). All new branches are reachable through the pure seam, so the deny-table cases double as coverage cases; the helper files must be added to both runsettings copies or the changed surface falls outside the denominator (a Blocking finding under the Coverage Exclusion Policy).

---

## 8. Consumers and callers

### 8.1 Registrations

- `.claude/settings.json`: the gate is registered under three PreToolUse matchers — `Bash` (line 112), `Write|Edit` (line 157), `Agent` (line 190) — mirrored in `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`; both are asserted by the registration Context of the Claude suite (lines 437–459). **No registration change is required by any candidate remedy.**
- `.codex/config.toml`: registered twice (lines 134–138 and 218–222), mirrored in the codex bundle `config.toml`. Codex has no matchers; the hook self-filters by `tool_name` (Codex copy lines 313–331). No change required.

### 8.2 Block-reason and prose consumers

`PREIMPLEMENTATION_GATE_BLOCKED` appears, outside `docs/**`, only in: the four hook copies, the two suites above, and `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (verified by repo-wide grep excluding `docs/**`; the grep also covered `.github/**` and matched nothing there). **No skill, agent, or rule file documents this gate or its block reason.** No `.claude/rules/` file governs it today; #535 put its doctrine in the spec and hook comments rather than a rule file, and the same is sufficient here. **No `.github/instructions/` file is involved; nothing in the canonical policy set needs (or may receive) modification.** `README.md` and `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:13` mention the hook by name (the latter only as a fail-closed precedent in a comment); neither depends on command-branch behavior.

### 8.3 Prose amendments the remedy does require

- `.claude/skills/epic-plan/SKILL.md` and `.claude/skills/parallel-plan/SKILL.md` (plus their claude-customizations bundle mirrors): add the pathspec-bearing command shape for planner commits (section 4.3). This is a consequence of deny-rule 4 and is load-bearing — without it the planner surfaces stay blocked at `git commit`. The pinned preparation-mode marker literals (`Preparation mode: true.` / `route_id: preparation.`) must not change; the guidance is additive prose.
- The preparation-mode kickoff lines themselves ("commit the feature folder and plan to the current branch") are satisfied by the pathspec-bearing form without rewording, but the planner should decide whether to spell the form inside the kickoff text so destination-repo children follow it; if the kickoff literal changes, the #535 marker tests keyed to the two markers are unaffected, but the verbatim-kickoff allow-case prompts in the Claude suite (lines 314–316) must be updated to the new verbatim text in the same change.

### 8.4 Adjacent constraints for the plan

- Change budget: 4 production PowerShell hook files (+2 helper files if extracted) exceeds the direct-mode cap of 2 → route via `powershell-orchestrator` or explicit batching (precedent: #535 spec, Dependencies).
- Standing repository guidance: enforcement hooks must not gain a Python leg (bash preferred, PowerShell acceptable); remedy (a) is PowerShell-only and compliant.
- Composition with #516: keep all exempt-tree prefixes repo-relative (deny absolutes, rule 16) so the future root-stripping normalization slots in upstream, exactly as #535 arranged for the literal set.

---

## 9. Behavior semantics (post-fix decision table, no ready checkpoint present)

| Operation (Bash `command` branch) | Decision |
| --- | --- |
| `git add docs/features/epics/<slug>/epic.md` | allow |
| `git add docs/features/parallel/<slug>/parallel.md docs/features/parallel/<slug>/parallel-kickoff.md` | allow |
| `git add "docs/features/active/<folder>/plan.md"` (quoted, backslash spellings included) | allow |
| `git add artifacts/orchestration/parallel-kickoff-<slug>.md` | allow |
| `git commit -m "epic scaffold" -- docs/features/epics/<slug>/epic.md` | allow |
| `git add docs/features/epics/x/epic.md scripts/a.ps1` (mixed) | deny (unchanged reason text) |
| `git add .` / `git add -A` / `git add :/` | deny |
| `git commit -m "msg"` (pathless) | deny |
| `git commit -a -m "msg"` / `--amend` / `--include` | deny |
| `git -C ../x add docs/...` / `--git-dir` / `--work-tree` | deny |
| `git add ':(exclude)scripts/' docs/...` or any `:`-magic operand | deny |
| `git add docs/... && poetry run pytest` (chained, non-exempt segment) | deny |
| `git add docs/... && git commit -m m -- docs/...` (chained, all segments exempt) | allow |
| Heredoc/message body containing the literal `git add` | deny (unchanged; residual known limitation) |
| Every non-git implementation pattern (pytest/black/npx/pwsh tests) | deny (unchanged) |
| Everything on the `file_path` and delegation branches | unchanged from #535 behavior |

Block-reason text, decision-JSON schema, matchers, `Test-OrchestrationReady`, `Test-ImplementationPath`, and the delegation classifiers are unchanged.

## 10. Rejected alternatives (summary)

- **(b) planner-state readiness on the command branch** — rejected: time-scoped rather than content-scoped; opens all implementation commands while a (possibly stale) planner checkpoint exists; session-agnostic hook cannot bind the checkpoint to the invoking session.
- **(c) route-scoped command gate** — rejected: no session route signal exists in the hook; degenerates into (b) with the same exposure plus production-commit exemption during planner phases.
- **Index inspection (`git diff --cached`) for pathless commits** — deferred, not rejected: correct but introduces external-process I/O and a wrapper/mock seam into a currently pure hook; composes later without schema change.
- **Trigger scoping to segment-leading `git`** — deferred: removes prose-literal false positives but creates wrapper bypasses (`xargs git add`, `bash -c "git add ."`); belongs to a separate issue with its own bypass analysis.

## 11. Open questions for the atomic-planner

1. Exempt-tree shape for `artifacts/orchestration/`: prefix (recommended, staging-side rationale in section 3) or the stricter seven-literals-plus-kickoff-shapes set.
2. Include `docs/features/potential/` (recommended; confirm the promotion-move commit shape during test authoring).
3. Extraction now (recommended) versus inline with ~0–30 lines of headroom left before #516 lands in the same file.
4. Whether the pathspec-bearing commit form is added only to the two planner SKILL.md files or also spelled into the pinned kickoff literals (the latter forces a same-change update of the verbatim prompts in the Claude test suite, lines 314–316).
5. Chained-command policy granularity: per-segment evaluation (recommended, rule 13) versus flat deny on any chaining operator (simpler parser, blocks the natural `git add X && git commit -m m -- X` shape).
