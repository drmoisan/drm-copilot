# 2026-08-24-preimplementation-gate-blocks-planner-integration-commits (Spec)

- **Issue:** #539
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-24
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug (this spec is the sole acceptance-criteria source; no user-story.md exists for this feature)

## Context

`Test-ImplementationCommand` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` denies every git staging and integration invocation by command pattern (`(^|\s)git\s+(add|commit)\b`), with no path-based or planner-surface exemption and no epic-shaped readiness source. The `docs/features/active/` and `CheckpointPaths` exemptions exist only on the `file_path` branch of `Invoke-OrchestrationPreimplementationGateDecision`; the command branch has none. `Test-OrchestrationReady` accepts only the single-feature checkpoint shape (`issue-num`, a `feature-folder` under `docs/features/active/`, a `route_id` or `path_selected`, truthy `lifecycle_ready`), which an epic run or a parallel run can never truthfully satisfy.

Consequence: `epic-planner` and `parallel-planner` cannot record their contract-mandated artifacts (`epic.md`, per-feature fan-ins, kickoff artifacts, parallel run manifests), so `/epic-plan` and `/parallel-plan` are structurally blocked at their integration steps even after PR #536 fixed the checkpoint-write and preparation-delegation legs.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: `/epic-plan` (TaskMaster destination repo, 2026-08-24, pushed-down hook copy); leg reproduced by inspection of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` at `main` post-PR #536
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/settings.json` PreToolUse matchers (Bash, Write|Edit, Agent)

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Authoritative research: `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/research/2026-08-24T10-30-preimplementation-gate-blocks-planner-integration-commits-research.md`. This spec adopts its remedy (a) recommendation and its fail-closed rule table.

## Repro & Evidence

Steps to Reproduce:
1. With no ready `artifacts/orchestration/orchestrator-state.json` present, invoke the hook with a Bash payload whose `command` is `git add docs/features/epics/<slug>/epic.md` (or any `git commit`). `Test-ImplementationCommand` matches `(^|\s)git\s+(add|commit)\b` (hook line 90) and the decision is `deny` with `PREIMPLEMENTATION_GATE_BLOCKED`.
2. Observe that the `docs/features/active/` prefix exemption and the `CheckpointPaths` membership exemption exist only inside `Test-ImplementationPath`, reached from the `file_path` branch of `Invoke-OrchestrationPreimplementationGateDecision` (line 260). The `command` branch (line 264) reaches `Test-ImplementationCommand` and nothing else, so a docs-only or checkpoint-only commit is denied exactly like a production-code commit.
3. Observe that `Test-OrchestrationReady` (lines 164–192) accepts only the single-feature checkpoint tuple. An epic run (integration branch, artifacts under `docs/features/epics/<slug>/`, many issues) and a parallel run (artifacts under `docs/features/parallel/<slug>/`) can never truthfully satisfy it, so once a `git add`/`git commit` is classified as implementation the deny is structurally unavoidable for the planner surfaces.

Expected:
- Planner and orchestrator surfaces can stage and commit their contract-mandated artifacts (epic folder documents, parallel run manifests, kickoff artifacts) without a single-feature-ready `orchestrator-state.json`, because recording planning output is orchestration bookkeeping, not implementation.
- The gate stays fail-closed for genuine implementation commits (production source, tests) made before orchestration readiness exists.

Actual:
- Every `git add` / `git commit` is denied unless the single-feature checkpoint is ready. A TaskMaster `/epic-plan` run on 2026-08-24 was halted before scaffolding: the integration-branch commit of `epic.md`, every fan-in commit, and the durable kickoff copy were all denied. The same exposure applies to `/parallel-plan` planner commits.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:

  ```text
  PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require
  artifacts/orchestration/orchestrator-state.json to contain issue number,
  feature folder, route metadata, lifecycle readiness, and checkpoint state
  before implementation begins.
  ```

## Scope & Non-Goals

- In scope:
  - A pathspec-scoped exemption on the command branch of the gate (design decision D1 below): a trigger-matching staging or integration invocation is exempt from the ready-checkpoint requirement when, and only when, it parses as a complete, recognized invocation whose every pathspec operand resolves inside an orchestration-bookkeeping tree.
  - The normative fail-closed rule table (D4) governing every parse and operand form.
  - The same behavioral change in all four hook copies (D5), with recomputed pair-hash parity evidence following the PR #536 precedent.
  - Extraction of the pathspec parser into dot-sourced sibling helper files (D6), with the associated pack-manifest, contract-test, and coverage-denominator registrations.
  - Additive prose in `.claude/skills/epic-plan/SKILL.md` and `.claude/skills/parallel-plan/SKILL.md` (plus their claude-customizations bundle mirrors) instructing planner surfaces to use the pathspec-bearing commit form (D7).
  - New sibling Pester test files on both the Claude and Codex sides covering the allow scenarios, the rule-table deny scenarios, and regression of existing behavior.
- Out of scope / non-goals:
  - **The whole-command-text over-match facet (D8).** The trigger regex is applied to the entire command string, so text that merely contains the literal `git add`/`git commit` (heredoc bodies, `--body` strings, quoted prose) still classifies as an implementation command. Narrowing the trigger to a segment-leading command name would create wrapper bypasses (`xargs git add`, `bash -c "git add ."`, `pwsh -Command "git commit ..."`) — a fail-open change, which is not acceptable inside a fix whose requirement is fail-closed safety. D3 bounds the practical interaction: prose containing the literal does not parse as a well-formed invocation, so it denies rather than accidentally exempting. Recorded as a follow-up candidate for a separate issue; the issue is not filed by this feature.
  - Rejected remedy candidates (b) accept epic/parallel planner checkpoints as alternative readiness sources, and (c) scope the command-branch gate to implementation routes. Both are rejected because they convert a content property into a temporal/state property: planner checkpoints are writable from the first moment of a run (the #535 `CheckpointPaths` exemption), and the hook is session-agnostic (it reads a repo file via `Get-CheckpointContent`), so either candidate would open the entire command classifier — including production-path commits — for as long as a possibly-stale planner checkpoint exists on disk.
  - Index inspection (`git diff --cached --name-only`) for pathless commits — deferred, not rejected: it verifies real content but introduces external-process I/O and a wrapper/mock seam into a currently pure hook. It composes later without schema change.
  - Any change to `Test-OrchestrationReady`, `Test-ImplementationPath`, the delegation classifiers, the block-reason text, the decision-JSON schema, or the hook registrations.
  - Issue #516 absolute-path normalization (exempt-tree prefixes stay repo-relative; absolute operands deny, so the future root-stripping fix composes upstream).
  - Any change to the pinned preparation-mode marker literals (`Preparation mode: true.` / `route_id: preparation.`).
- Explicitly excluded systems, integrations, or datasets:
  - `.github/instructions/` and `.claude/rules/` — no file under either tree is modified.
  - `.claude/settings.json` and `.codex/config.toml` hook registrations — unchanged (research section 8.1 verified no registration change is required).
  - The non-git implementation-command patterns (pytest/black/npx/pwsh tests) — unchanged.

## Root Cause Analysis

- `Test-ImplementationCommand` (hook lines 79–103) classifies by command pattern only; it never inspects the paths being staged. The path-based exemptions added by #535 live exclusively on the `file_path` branch.
- The gate's readiness source is keyed to the single-feature `orchestrator` route. It predates the epic and parallel surfaces, so a planner integration commit has no truthful readiness tuple and the deny is structural, not incidental.
- Issue #535 / PR #536 fixed the other two gate legs (checkpoint writes via `CheckpointPaths`, preparation-mode delegations via `Test-PreparationModeDelegation`) and deliberately left this leg out of scope, recording it as a related standing finding. This fix is the scheduled closure of that finding.
- The hook is push-down-owned: the fix must land in drm-copilot and both push-down resource copies, then reach destination repos via push-down.

## Proposed Fix

The following design decisions are fixed. They are recorded here as the normative contract; the atomic-planner decides sequencing and final file layout within these constraints.

### D1 — Selected remedy: pathspec-scoped exemption on the command branch

A trigger-matching staging or integration invocation is exempt from the ready-checkpoint requirement when, and only when, every pathspec operand resolves inside an orchestration-bookkeeping tree. The property that makes a planner commit safe is what it stages, not who runs it or when: a commit staging only orchestration-bookkeeping paths cannot introduce implementation code regardless of session state. The exemption is stateless, session-agnostic, and granted only on a positive parse; every ambiguity denies, so parser defects and rollback both degrade toward deny, never toward allow.

Candidates (b) (alternative readiness sources) and (c) (route-scoped command gate) are rejected for the reason stated under Scope & Non-Goals: both convert a content property into a temporal/state property, and the session-agnostic hook cannot bind a checkpoint to the invoking session, so either would exempt production-path commits for the lifetime of a possibly-stale planner checkpoint.

### D2 — Exempt trees

The exempt-tree set is exactly:

1. `docs/features/epics/`
2. `docs/features/parallel/`
3. `docs/features/active/`
4. `docs/features/potential/`
5. `artifacts/orchestration/`

`docs/features/potential/` is included because promotion moves lifecycle records out of that tree, so a mandated feature-folder integration step plausibly stages a potential-side path (a deletion/move alongside the active-side additions), and the tree holds no production source, so its inclusion costs no fail-closed strength. `artifacts/orchestration/` is a directory prefix on this branch — an asymmetry with the #535 literal set on the write branch that is deliberate: staging records content that already exists on disk, and every governed write into that directory already passed the `file_path` gate (or is a kickoff `.md`, which never matched the extension pattern), so a staging-side prefix cannot launder a write the write branch would have denied.

### D3 — Exemption requires a well-formed, fully-parsed invocation

The exemption applies only when the trigger-matching command segment parses as a complete, recognized staging or integration invocation whose every operand is an exempt path. Any segment that does not parse that way denies. This property is load-bearing for fail-closed safety: it bounds the interaction with the whole-command-text over-match. A literal `git add`/`git commit` appearing inside a here-string, a message body, or quoted prose does not parse as a well-formed invocation, so it denies (the pre-fix behavior) rather than accidentally exempting. Parsing is used only to grant exemptions (allow-side), never to suppress the trigger (deny-side).

### D4 — Normative fail-closed rule table

This table is the behavioral contract for the command-branch classifier. Every row must be individually testable, and the test surface (below) requires at least one named case per row per side. The invariant is all-operands-exempt: the exemption is granted only when at least one pathspec operand is found and all operands pass.

| # | Form | Rule | Reason |
| --- | --- | --- | --- |
| 1 | `git add` with zero operands | DENY | Nothing parseable to scope |
| 2 | `git add -A` / `--all` / `-u` / `--update` / `--no-all` variants | DENY | Index-wide/tree-wide staging; no per-path claim |
| 3 | `git add .` / `git add :/` / any `:/`-rooted operand | DENY | Whole-tree operand |
| 4 | `git commit` with no pathspec operand (including `-m`-only) | DENY | Records already-staged content the parser cannot see; the index is not fully gated (`git rm`/`git mv`/`git checkout` are unmatched by the trigger), so staged state is unverifiable |
| 5 | `git commit -a` / `--all` / `-i` / `--include` / `--interactive` / `-p` / `--amend` | DENY | Widens the recorded content beyond the named pathspecs, or rewrites history |
| 6 | `--pathspec-from-file=` / `--pathspec-file-nul` | DENY | Pathspecs are off the command line |
| 7 | `--` separator | Tokens after `--` are pathspecs even when dash-leading; each must pass the prefix test; `--` with nothing after it and no earlier pathspec ⇒ DENY (rules 1/4) |
| 8 | Dash-leading token before `--` not in the modeled option allowlist | DENY | Unknown option may be tree-wide; fail closed on the unmodeled |
| 9 | Operand starting with `:` — `:(exclude)`, `:!`, `:/`, `:(top)`, `:(glob)`, `:(icase)`, any magic | DENY | Pathspec magic can escape or invert the tree scope |
| 10 | Leading-dash operand without a preceding `--` | DENY | Indistinguishable from an option (rule 8) |
| 11 | Quoted operands / operands with spaces | Strip balanced quotes, then apply the prefix test; unbalanced quoting ⇒ DENY |
| 12 | Operand containing `$` or a backtick, or the segment containing redirection (`>`, `<`) | DENY | Interpolation/redirection not resolvable statically |
| 13 | Chained/compound lines (`&&`, `;`, `\|\|`, `\|`, newline) | Split into segments outside quotes; every trigger-matching segment must independently pass (a non-git segment matching any other implementation pattern still requires readiness); unsplittable or ambiguous text ⇒ DENY |
| 14 | Anything between the command name and the subcommand (`-C <dir>`, `--git-dir=`, `--work-tree=`, env-style prefixes) | DENY | Pathspec base relocated; the repo-relative prefix test is no longer sound |
| 15 | Glob operands (`*`, `?`, `[`) | Allow only when the literal prefix before the first wildcard is strictly inside an exempt tree and the token has no `..` segment; otherwise DENY (`docs/features/*` DENIES — it can match siblings outside the exempt set) |
| 16 | Absolute operands (`/...`, `C:\...`, `\\...`) | DENY | Base not provably the repository root (mirrors the #516 posture: exempt prefixes stay repo-relative) |
| 17 | Any `..` segment | DENY | Escapes the prefix |
| 18 | Backslash separators in an otherwise relative operand | Normalize `\` → `/` before the prefix test (consistent with the `file_path` branch) |
| 19 | Mixed operand set (one exempt + one production path, e.g. `git add docs/features/epics/x/epic.md scripts/a.ps1`) | DENY | All-operands-exempt is the invariant |

Post-fix decision table on the command branch, no ready checkpoint present:

| Operation (Bash `command`) | Decision |
| --- | --- |
| `git add docs/features/epics/<slug>/epic.md` | allow |
| `git add docs/features/parallel/<slug>/parallel.md docs/features/parallel/<slug>/parallel-kickoff.md` | allow |
| `git add "docs/features/active/<folder>/plan.md"` (quoted; backslash spelling included) | allow |
| `git add artifacts/orchestration/parallel-kickoff-<slug>.md` | allow |
| `git commit -m "epic scaffold" -- docs/features/epics/<slug>/epic.md` | allow |
| `git add docs/... && git commit -m m -- docs/...` (chained, all segments exempt) | allow |
| `git add docs/features/epics/x/epic.md scripts/a.ps1` (mixed) | deny (unchanged reason text) |
| `git add .` / `git add -A` / `git add :/` | deny |
| `git commit -m "msg"` (pathless) | deny |
| `git commit -a -m "msg"` / `--amend` / `--include` | deny |
| `git -C ../x add docs/...` / `--git-dir` / `--work-tree` | deny |
| `git add ':(exclude)scripts/' docs/...` or any `:`-magic operand | deny |
| `git add docs/... && poetry run pytest` (chained, non-exempt segment) | deny |
| Heredoc/message body containing the literal `git add` | deny (unchanged; residual known limitation per D8) |
| Every non-git implementation pattern (pytest/black/npx/pwsh tests) | deny (unchanged) |
| Everything on the `file_path` and delegation branches | unchanged from #535 behavior |

Block-reason text, decision-JSON schema, matchers, `Test-OrchestrationReady`, `Test-ImplementationPath`, and the delegation classifiers are unchanged.

### D5 — Four synchronized copies

The same behavioral change lands in all four hook copies, following the PR #536 pair-synchronization precedent:

1. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (canonical Claude)
2. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (canonical Codex)
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (Claude bundle)
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (Codex bundle)

The Codex pair is a deliberately divergent implementation and receives the fix in its own idiom (the #535 precedent). The Codex canonical/bundle pair stays byte-identical (hash-binding contract test in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`); the Claude pair stays content-equal (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`). Recomputed pair-hash parity evidence is produced for both pairs, following the #535 evidence pattern.

### D6 — Helper extraction

Both canonical copies sit near the 500-line cap (Claude 340, Codex 337; headroom roughly 160 lines each) and the estimated addition is 130–190 lines per copy, so the pathspec parser is extracted to a dot-sourced sibling helper — the only sharing idiom available on both pairs, since the `.codex` side has no `lib/`. Mirrored helper paths on all four sides and the registration surfaces the researcher identified are part of the delivery:

- `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (which automatically subjects the Codex helper to the parse, 500-line, byte-identity, and pack-manifest checks);
- both pack manifests (`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`);
- both PoshQC coverage lists (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`), so the new production surfaces stay in the coverage denominator per the Coverage Exclusion Policy.

The exact final layout (helper file names, function boundaries) is the atomic-planner's decision; the constraints are the sibling-helper idiom, the mirrored four-side layout, the registrations above, and the 500-line cap on every production and test file.

### D7 — Additive skill prose (in scope)

Because a pathless integration invocation denies (rule 4), the planner skills must adopt the pathspec-bearing form (`git commit -m "msg" -- <exempt paths>` or `git commit <exempt paths> -m "msg"`). `.claude/skills/epic-plan/SKILL.md` and `.claude/skills/parallel-plan/SKILL.md`, plus their claude-customizations bundle mirrors, receive additive prose stating the required form. Without this amendment the fix does not unblock the flows it exists for. The pinned preparation-mode marker literals (`Preparation mode: true.` / `route_id: preparation.`) are not changed.

### D8 — Whole-command-text over-match: out of scope, with reason

Recorded under Scope & Non-Goals. The trigger regex is not narrowed in this fix because trigger scoping to a segment-leading command name is a fail-open change (wrapper bypasses via `xargs`, nested shells). D3 bounds the practical interaction. Follow-up candidate for a separate issue; not filed here.

### Boundaries and invariants to preserve

- Fail-closed default preserved by construction: the exemption is an enumerated allow-side layer over unchanged deny logic; the pre-fix behavior (deny) is the fallback for every unmodeled form.
- The block-decision reason keeps the `PREIMPLEMENTATION_GATE_BLOCKED` prefix and the phrases `route metadata` and `lifecycle readiness`, which existing tests assert.
- The Codex pair stays byte-identical; the Claude pair stays content-equal.
- No new readiness source, no checkpoint schema change, no registration change.

### Dependencies or blocked work

- None blocking. Composes with (does not implement) issue #516 (rule 16 keeps all prefixes repo-relative).
- Change budget: four production hook files plus helper files exceeds the direct-mode cap of 2 (`.claude/rules/powershell.md`), so execution routes through `powershell-orchestrator` or uses explicit approved batching, settled at planning time (the #535/#536 precedent).
- Enforcement hooks must not gain a Python leg (standing repository guidance); this fix is PowerShell-only.

### Rollback considerations

- No feature flag. Rollback is reverting the hook and helper edits; the pre-fix behavior (deny) is strictly more restrictive, so rollback cannot open an enforcement gap. The skill-prose amendments are additive and harmless post-rollback (the pathspec-bearing form is valid git usage regardless).

## Assumptions, Constraints, Dependencies

- Assumptions:
  - `HookPayload.psm1` remains available to the Claude pair and `codex-pretooluse-file-mapping.ps1` to the Codex pair; no module change is required.
  - The promotion-move commit shape actually stages a `docs/features/potential/` path alongside the active-side additions. This is plausible but not verified end-to-end at runtime; the planner should confirm it during test authoring (research section 3).
- Constraints:
  - PowerShell only. 500-line cap on every production, test, and reusable script file. Pester v5, advanced functions with `CmdletBinding()`, approved verbs, `[OutputType([bool])]` on predicates.
  - Pester line coverage >= 85% on every changed or added production file (no PowerShell branch-coverage gate); no production file leaves the coverage denominator.
  - Toolchain: PoshQC format → PSScriptAnalyzer analyze → Pester, via the MCP tools, restarting from format on any failure until a clean single pass.
  - Do not modify anything under `.github/instructions/` or `.claude/rules/`.
- External dependencies: none. Verification is entirely local.

## Data / API / Config Impact

- User-facing or API changes: none. Hook decision schema, matchers, and registrations unchanged. Behavioral change is limited to the enumerated allow-side exemption on the command branch.
- Data or migration considerations: none.
- Configuration: no configuration file, environment variable, or settings key is added or read. The exempt-tree set is a script-scoped constant.
- Compatibility: the Codex byte-identity contract and the Claude content-equality contract are maintained; both bundle copies ship the fix to push-down destinations through the existing publish path.

## Test Strategy

Both existing suites are near the 500-line cap (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` at 461 lines; `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at 494 lines), so the new scenarios land in new sibling test files, one per side, each dot-sourcing its canonical hook copy exactly as the existing suites do. The planner chooses the file names; this spec states the coverage obligation.

All new decision tests are driven through the pure seam (`Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ... -CheckpointRaw ...` on the Claude side; the established Codex decision seam on the Codex side) with an explicitly not-ready checkpoint, no disk I/O, no child processes, and no temporary files — the #535 pattern.

Required scenario groups:

1. **Allow — orchestration-tree-only staging with no ready checkpoint.** At minimum: `git add docs/features/epics/<slug>/epic.md`; a parallel manifest plus kickoff staging; a quoted operand; a backslash spelling; `git add artifacts/orchestration/parallel-kickoff-<slug>.md`; the pathspec-bearing commit form `git commit -m "msg" -- <exempt path>`; a chained line whose every segment is independently exempt; a `docs/features/potential/` operand.
2. **Deny — mixed pathspec.** An operand set containing an exempt path plus a production path, with cases covering `.ps1`, `.py`, `.ts`, and `.cs`.
3. **Deny — bare or unparseable invocations.** At least one named case per row of the D4 rule table (rows 1–17 and 19; row 18 is exercised by the backslash allow case), on each side. A `-ForEach` table keeps this compact.
4. **Regression — existing behavior unchanged.** The existing Claude suite contexts (implementation writes and command denials, anomaly fail-closed, #535 exemptions, entrypoint seam, settings registration) re-run green without modification. The Codex in-process classification table re-runs green, including `Test-ImplementationCommand 'git commit -m "wip"'` ⇒ `$true` (a pathless commit still classifies as implementation). The ready-checkpoint allow path and the non-git implementation patterns are unchanged.
5. **Parity.** The Codex byte-identity `It` passes with the canonical `.codex` and Codex-bundle copies (hook and helper) updated byte-identically in the same commit; `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes with the Claude pair content-equal.
6. **Skill prose.** The additive pathspec-bearing-form prose is present in both planner SKILL.md files and both bundle mirrors; the #535 marker tests and the verbatim-kickoff allow-case prompts in the existing Claude suite pass unmodified (the pinned marker literals are unchanged).

Additional strategy points:
- Fail-before evidence: run the new allow cases against the unfixed hook to produce a failing baseline; record it under `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/evidence/regression-testing/`.
- Pair-hash evidence: recomputed SHA256 per pair (Claude pair, Codex pair) recorded under `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/evidence/other/`, following the #535 artifact shape (hash, line count, method).
- Coverage: all new classifier branches are reachable through the pure seam, so the rule-table deny cases double as coverage cases; the helper files must appear in both runsettings coverage lists or the changed surface falls outside the denominator (a Blocking finding under the Coverage Exclusion Policy).
- Toolchain commands: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`, restarting from format on any failure until a clean single pass.
- Manual/integration validation after merge and push-down: `/epic-plan` in a destination repo commits `epic.md` to the integration branch; `/parallel-plan` commits its manifest and kickoff artifacts.

## Acceptance Criteria

- [x] The command branch of `Invoke-OrchestrationPreimplementationGateDecision` grants an exemption from the ready-checkpoint requirement if and only if the trigger-matching segment parses as a complete, recognized `git add`/`git commit` invocation with at least one pathspec operand, and every operand — after balanced-quote stripping and `\` → `/` normalization — resolves inside one of exactly the five exempt trees `docs/features/epics/`, `docs/features/parallel/`, `docs/features/active/`, `docs/features/potential/`, and `artifacts/orchestration/`; verified by the allow-case Pester tests in the new Claude-side and Codex-side sibling suites, each driven through the pure decision seam with an explicitly not-ready checkpoint.
- [x] Each allow scenario in Test Strategy group 1 (epic.md staging, parallel manifest plus kickoff staging, quoted operand, backslash spelling, `artifacts/orchestration/` kickoff `.md`, pathspec-bearing commit form, all-exempt chained line, `docs/features/potential/` operand) passes as a named `It` in the new sibling suites with no ready checkpoint present.
- [x] A mixed operand set containing an exempt path plus a production path is denied, with named deny cases covering `.ps1`, `.py`, `.ts`, and `.cs` operands (Test Strategy group 2), and the deny reason retains the `PREIMPLEMENTATION_GATE_BLOCKED` prefix and the phrases `route metadata` and `lifecycle readiness`.
- [x] Every row of the D4 fail-closed rule table (rows 1–17 and 19; row 18 via the backslash allow case) has at least one named Pester case per side asserting the mandated decision (Test Strategy group 3), including: bare `git add`; tree-wide flags (`-A`, `--all`, `-u`, `.`, `:/`); pathless `git commit -m`; `-a`/`--include`/`-i`/`--interactive`/`-p`/`--amend`; `--pathspec-from-file`/`--pathspec-file-nul`; `--` semantics; unknown dash-leading option; `:`-magic operands; leading-dash operand without `--`; unbalanced quotes; `$`/backtick/redirection; chained line with a non-exempt segment and unsplittable text; `-C`/`--git-dir`/`--work-tree`; glob prefix rules including `docs/features/*` denying; absolute operands; `..` segments; and the mixed operand set.
- [x] Existing implementation-command behavior is unchanged: the existing Claude suite (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`) passes without modification to its assertions, and the Codex in-process classification table in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes with `Test-ImplementationCommand 'git commit -m "wip"'` still returning `$true`; the non-git implementation patterns, the ready-checkpoint allow path, `Test-OrchestrationReady`, `Test-ImplementationPath`, the delegation classifiers, the block-reason text, and the decision-JSON schema are unmodified.
- [ ] The behavioral change is present in all four hook copies: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; the Codex canonical/bundle pair (hook and helper) is byte-identical and the hash-binding `It` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes; the Claude pair is content-equal and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
- [ ] Recomputed pair-hash parity evidence (SHA256 per pair member, line counts, method) is recorded under `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/evidence/other/` for both the Claude pair and the Codex pair, following the #535 artifact shape.
- [ ] The pathspec parser is extracted to dot-sourced sibling helper files mirrored across all four sides, and every production and test file touched or added by this fix is at or under 500 lines, verified by the PoshQC/contract line-cap checks and by the plan's file-length gate.
- [ ] The helper files are registered on every required surface: appended to `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (subjecting the Codex helper to its parse/500-line/byte-identity/pack-manifest checks), listed in both pack manifests (`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`), and listed in both PoshQC coverage settings files (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`); the pack-manifest completeness pytest and the codex contract suite pass.
- [ ] Pester line coverage is >= 85% on every changed or added production PowerShell file, with the new helper files inside the coverage denominator, verified by the `mcp__drm-copilot__run_poshqc_test` coverage report.
- [ ] `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/parallel-plan/SKILL.md`, and their claude-customizations bundle mirrors carry additive prose stating the pathspec-bearing commit form for planner integration commits; the pinned preparation-mode marker literals (`Preparation mode: true.` / `route_id: preparation.`) are byte-unchanged, verified by the existing #535 marker tests and verbatim-kickoff allow-case prompts passing without modification.
- [x] Fail-before evidence exists: the new allow cases run against the unfixed hook produce a failing baseline recorded under `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/evidence/regression-testing/`, followed by pass-after results per pair.
- [ ] The PoshQC toolchain passes clean in a single pass — `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` — over all changed and added PowerShell files.
- [ ] No out-of-scope changes: the trigger regex `(^|\s)git\s+(add|commit)\b` is unmodified (the whole-command-text over-match is not narrowed; a here-string/message-body literal still denies, asserted by a named deny case per side); no alternative readiness source is added; `Test-OrchestrationReady` is unchanged; no file under `.github/instructions/` or `.claude/rules/` is modified; and no Python leg is added to any enforcement hook — verified by the plan's diff-scope gate and the deny cases above.

## Risks & Mitigations

- **Parser defects.** A shell-token parser with a modeled option table is the largest and most defect-prone piece of the remedy. Mitigation: deny-on-unknown is the universal fallback (rules 8, 10, 13), every rule-table row carries a named test, and the pre-fix behavior (deny) is the degradation target for every unmodeled form.
- **Glob or magic escape.** A pathspec magic form or glob could escape the exempt trees. Mitigation: rules 3, 9, 15, and 17 deny all magic, whole-tree, and `..`-bearing forms; `docs/features/*` denies by rule 15.
- **Prose-literal accidental exemption.** Text merely containing `git add` might be exempted. Mitigation: D3 — only a segment that parses as a complete recognized invocation can be exempted; a named deny case asserts the here-string/message-body form.
- **Copy divergence.** Fixing only one pair leaves the defect live in the other runtime or in push-down destinations. Mitigation: four-copy delivery is an acceptance criterion; the Codex hash-binding test and the Claude content-equality pytest enforce their pairs automatically; recomputed pair-hash evidence is a separate criterion.
- **Fix without skill amendment does not unblock the flows.** A pathless `git commit -m` still denies (rule 4), so planner surfaces following their current prose remain blocked. Mitigation: D7 makes the additive skill prose an acceptance criterion.
- **Headroom exhaustion.** The estimated 130–190-line addition can exceed the roughly 160-line headroom, and #516 is queued against the same file. Mitigation: D6 mandates the helper extraction rather than betting on the low estimate.
- **Change-budget violation.** Four-plus production PowerShell files exceed the direct-mode cap of 2. Mitigation: route through `powershell-orchestrator` or explicit approved batching, settled at planning time.
- Rollback: reverting the edits restores the strictly more restrictive pre-fix behavior; no enforcement gap can result.

## Rollout & Follow-up

- Release/rollout steps: land all four hook copies, the helper files, the registration edits, the new test files, and the skill-prose amendments in one feature branch/PR; both bundle copies ship the fix to push-down destinations through the existing publish path. No configuration or registration-matcher change is required.
- Post-merge validation: `/epic-plan` in a destination repo commits `epic.md` to its integration branch; `/parallel-plan` commits its manifest and kickoff artifacts; the promotion-move commit shape (potential-side path) is confirmed during test authoring or this validation.
- Known deferrals recorded, not fixed here: the whole-command-text over-match trigger scoping (D8; separate issue candidate, not filed), index inspection for pathless commits (deferred enhancement), and issue #516 absolute-path normalization (composes upstream of rule 16).
- Links: issue #539 (https://github.com/drmoisan/drm-copilot/issues/539); research `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/research/2026-08-24T10-30-preimplementation-gate-blocks-planner-integration-commits-research.md`; precedent `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/spec.md` (issue #535, PR #536).
