# 2026-10-28-tiered-file-size-policy-500-700-800 — Spec

- **Issue:** #990
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-28T13-30
- **Status:** Draft
- **Version:** 0.2

## Overview

The repository enforces a single 500-line limit on production code, test code, and reusable script files. The limit is too restrictive: it forces splits that are not logically separable. A tiered policy keeps pressure toward smaller files while reserving hard enforcement for files that are clearly too large.

Today no hook, CI step, validator, or `feature-review` rule counts lines. The only mechanical uses of the 500 figure are file-scoped Pester assertions, so the 500 limit is not enforced repository-wide. This feature introduces the tiered policy text and, for the first time, a repository-wide mechanical gate at the 800-line hard limit.

## Behavior

### Policy tiers

Replace the single 500-line limit with three tiers, applied to the files the current policy covers and subject to the existing exemption list (throwaway scripts created and deleted within an agent session, raw text fixtures for language-processing test data, Markdown documentation). The exemption list is unchanged.

- **500 lines (guidance):** a file that reaches 500 lines prompts the author to look for logical ways to divide it into multiple files, provided the parts can be separated logically. There is no rigorous enforcement; no gate fails at this tier.
- **700 lines (advisory):** the author looks for a split more aggressively. Reviewers and `feature-review` report a non-blocking Warning finding for a file at or above 700 lines. No gate fails at this tier.
- **800 lines (hard block):** a split is enforced regardless of logical separability. A CI/Pester check and a PreToolUse hook block a file over 800 lines (801 lines or more). A file of exactly 800 lines passes.

Tier classification for a line count: below 500, 500 through 699, 700 through 799, and 800 and above (with the hard block applying only above 800).

### Legacy handling (ratchet)

Legacy handling is a ratchet. Files already over 800 lines are recorded in a baseline list; a baselined file may not grow and no new file may exceed 800 lines. Existing files are split opportunistically, not in this issue. No mass split is performed.

### Counting convention

The gate, the hook, the baseline generator, and `feature-review` use one line-counting convention: logical lines, obtained by splitting content on `\r?\n`, where a trailing line terminator does not add a line. This equals the `@(Get-Content -LiteralPath <path>).Count` count. `wc -l` and `Measure-Object -Line` are not used in the policy code, because the first counts newline characters (differing by one when the last line has no terminator) and the second counts non-empty lines only.

### Covered files

Covered files are production code, test code, and reusable scripts identified by the extension allowlist `.py`, `.ps1`, `.psm1`, `.ts`, `.tsx`, `.js`, `.cjs`, `.mjs`, `.cs`, `.sh`, `.bats`. Everything else (Markdown, JSON, YAML, TOML, text fixtures, lock files) is outside the covered set, which realizes the existing exemptions mechanically. Throwaway scripts are not committed and need no rule. Disk discovery excludes the fixed directory names `.git`, `node_modules`, `artifacts`, `coverage`, `dist`, `out`, `virtual`, `docs`, and virtual-environment and cache directories. Whether `.psd1` is covered is an open decision (see Open Decisions for Confirmation).

### Shared policy module

A pure, entrypoint-free PowerShell module `.claude/lib/file-size-policy/FileSizePolicy.psm1` (with Codex and bundle twins) is the single source of truth. It exposes pure functions for:

- logical line counting per the counting convention;
- tier classification of a line count;
- covered-path determination (extension allowlist, excluded directories);
- ratchet comparison of a current size against a baseline entry;
- the hook decision for a Write or Edit.

The module follows the `.claude/lib` conventions pinned by the `ClaudeLibModuleConvention` suite (`Set-StrictMode -Version Latest`, the `$ErrorActionPreference = 'Stop'` guard line directly after it, `-ErrorAction Stop` on sibling imports, the fixed convention sentence in the help block).

### Repository gate (AC3)

A Pester suite under `tests/scripts/ci/` (for example `FileSizePolicy.RepoGate.Tests.ps1`) discovers covered files on disk with `Get-ChildItem`, reads `config/file-size-baseline.json` with `Get-Content`, and applies the shared module. It starts no git subprocess. The suite runs in the existing `poshqc` shards; no new CI job or required status context is added. Ratchet rules, evaluated per covered file with current size S and baseline entry B when present:

| Condition | Result |
|---|---|
| S <= 800, no entry | pass |
| S <= 800, entry exists | fail: stale baseline entry; remove it |
| S > 800, no entry | fail: new file over the hard limit |
| S > 800, entry B, S > B | fail: baselined file grew |
| S > 800, entry B, S == B | pass |
| S > 800, entry B, S < B | fail: tighten the baseline to S (strict ratchet; see Open Decisions for Confirmation) |
| Entry with no file on disk | fail: stale baseline entry (deletion or rename) |

A rename or move produces a new path. If the file is over 800 lines, the new path fails as a new file over the hard limit and the old entry fails as stale, unless the entry is moved in the same change with the recorded size unchanged. A move therefore cannot reset the ratchet upward. Baseline growth (a new key or a raised value) is not detectable by the check; it is a reviewer and `feature-review` concern.

### PreToolUse hook (AC4)

A PowerShell hook `.claude/hooks/enforce-file-size-limit.ps1` (with Codex and bundle twins) follows the evidence-locations hook pattern:

- It dot-sources `hook-dependency-guard.ps1` inside the `$script:HookDependencyGuardLoadFailed` try, imports `HookPayload.psm1` and the policy module the same guarded way, and returns `Get-HookDependencyFailureDecision` (deny, fail closed) on any dependency load failure. The `hook-dependency-guard-completeness` suite pins this pattern.
- It reads the envelope through `Read-ClaudeHookRawPayload`, `Resolve-ClaudeHookToolInput`, and `Get-ClaudeHookToolInputString`. An unreadable envelope denies. The deny shape is `hookSpecificOutput.permissionDecision = 'deny'` with `permissionDecisionReason`, exit 0.
- The covered-path test is the first decision. Every non-covered path returns allow with no file read.
- For a Write, the resulting size is the logical line count of `content`. For an Edit, the hook applies `old_string` to `new_string` in memory against the pre-edit file content obtained through an injected file-reader seam (tests supply in-memory content; no temporary files), following the replacement approach of `enforce-completion-consistency.ps1` including `replace_all`. An unreadable file, or an absent, empty, ambiguous, or not-found `old_string`, fails closed for covered paths.
- Baseline-free pre-edit-size ratchet: the hook denies only when the resulting size is above 800 and either the file is new or the resulting size is greater than the pre-edit size. A shrinking or equal edit to an already-large file is allowed. The hook does not read `config/file-size-baseline.json`, because the hook ships to consumer repositories through push-down where no baseline exists. The CI check is the baseline-aware gate; the hook is the early, baseline-independent gate. A growth path outside Write and Edit (for example a Bash write) is still caught by the CI check.
- The deny message names the tiers (500 guidance, 700 advisory, 800 enforced regardless of logical separability), the split requirement, the path, and the resulting line count. The message does not name any consuming product.
- Registration: `.claude/settings.json` under the `Write|Edit` matcher list alongside `enforce-evidence-locations.ps1`; `.codex/config.toml` `[[hooks.PreToolUse.hooks]]` under the matcher `^(apply_patch|Edit|Write)$` with `command`, `command_windows`, and `timeout`, mapped through `ConvertTo-CodexFileEditInput` in `codex-pretooluse-file-mapping.ps1` (an `apply_patch` Update resolves updated content with `-ResolveUpdateContent`); and the bundle twins of both. Existing suites that enumerate hooks (`PreToolUseSchema.Contract.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`) are updated for the added hook.
- The hook uses no Python.

### Baseline list (AC6)

`config/file-size-baseline.json` has the shape `{ "schemaVersion": 1, "hardLimit": 800, "files": { "<repo-relative forward-slash path>": <recorded line count> } }`, with keys sorted by ordinal comparison, 2-space indent, LF endings, and a trailing newline. Sizes are recorded so the ratchet needs no git base reference (CI checkouts may be depth one). A generator script (for example `scripts/ci/New-FileSizeBaseline.ps1`) lists tracked files at the merge base with `git ls-tree -r --name-only <merge-base>` (never `origin/main` itself), reads each blob's logical line count through the shared module, keeps covered files over 800, sorts ordinally, and writes the JSON. Git access goes through an `Invoke-GitExe` wrapper seam. Running the generator twice at the same ref yields byte-identical output. The generator's pure core (file list plus sizes to JSON text) is unit-tested in memory. The one-off run that produces the committed file is recorded as evidence under `<FEATURE>/evidence/baseline/` with the ref, command, and output hash. This spec states no baseline count; the baseline contents are produced by the generator.

### Feature-review Warning (AC2)

`.claude/agents/feature-review.md` gains a `## File Size Advisory` section. The reviewer measures the logical line count of every added or modified covered file in the branch diff and:

- reports each file at or above 700 lines as a non-blocking `Warning` finding in the `code-review.<timestamp>.md` Findings Table;
- reports an uncovered-by-baseline file over 800 lines, and any added or increased baseline entry, as a blocking policy finding;
- produces no finding for the 500 tier.

The `Warning` label is added to the legend of the code-review template (`docs/features/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`) and its bundle twin. The Warning is not written to `remediation-inputs.<timestamp>.md` and its text does not contain the strings the orchestrator counts (`BLOCKING`, `Severity: Blocking`). The policy-audit template rows that say "Under 500 lines" and "Cohesive and under 500 lines" (and the "Test File Size" row) are reworded to record the 800 tier as PASS or FAIL and the 700 tier as a noted Warning, in the template and its bundle twin. The Codex `feature-review.toml` is regenerated, not hand-edited.

### Policy text and mirrors (AC1, AC5)

The tiers are stated once per surface in `general-code-change` and referenced elsewhere rather than repeated:

- Authoritative: `.github/instructions/general-code-change.instructions.md` section `## 4. Module & File Structure`. The exceptions bullet is kept unchanged.
- Claude: `.claude/rules/general-code-change.md` section `## File Size Limit`.
- Agents and Codex: `.agents/skills/general-code-change/SKILL.md` and root `AGENTS.md` (Code Change section).
- Referencing surfaces reworded to point to the policy instead of the 500 figure: `.github/instructions/powershell-code-change.instructions.md`, `.claude/rules/powershell.md`, `.claude/rules/shell.md`, `.agents/skills/powershell/SKILL.md`, `.github/agents/commentary-remediation.agent.md`, `.github/prompts/remediate-comments.prompt.md`.
- Engineer agents: the phase line-count paragraphs in `.github/agents/python-typed-engineer.agent.md` and `.github/agents/python-execution-only-typed.agent.md`, and the escalation trigger in `.claude/agents/{python,powershell,csharp}-typed-engineer.md`, change from "near or over 500, violation" to tiered behavior: at 500 look for a logical split, at 700 split more aggressively, over 800 split before proceeding (hard stop). The same sentence in `.codex-variants/csharp-legacy` and `.claude-variants/csharp-legacy` is updated.
- Codex engineer variants (`.codex/agents/*typed-engineer*.toml`) are produced by `scripts/dev_tools/generate_codex_agent_variants.py` from the edited base agents and are not edited by hand.
- Bundle twins under `extensions/drm-copilot/resources/` (`claude-customizations`, `codex-and-agents-customizations`, `customizations`) of every file above are updated together with their sources.
- `.github/copilot-instructions.md` and root `CLAUDE.md` do not state the figure; `CLAUDE.md` is not edited. Authoritative `.github` text and all mirrors are updated together by user approval, overriding the CLAUDE.md do-not-modify note for this issue.
- Not changed: `make-skill-template` skill-authoring limits, the `#500` issue number in `parallel-orchestration.md`, plan-size limits in the planner agents, and sample-data strings in tests and fixtures that contain "500 lines" as content.
- Historical explanatory comments of the form "keeps the file inside the 500-line limit" in code and tests describe why files were split; they do not state policy and are confirmed unaffected.

### Execution-environment brief

The bullet in `## Coverage and File-Size Gates` stating that no file exceeds 500 physical lines is rewritten for the three tiers in all six byte-identical copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and the three bundle copies under `extensions/drm-copilot/resources/`. The heading `## Coverage and File-Size Gates` is kept, because `test_brief_has_required_headings` pins it. The `Measure-Object -Line` bullet under `## Preflight Defect Classes the Validator Cannot See` is unchanged. The rewritten text must pass `test_brief_has_no_consuming_names` and `test_brief_has_no_g11_or_g12_findings`.

### Existing 500-based Pester assertions (AC5)

The file-scoped assertions that pass today under a stricter bound remain valid. The affected suites are `ClaudeLibModuleConvention`, `hook-dependency-guard` (H12, Claude and Codex), `legacy-codex-hook-contracts`, `enforce-orchestration-preimplementation-gate-epic-scope`, `codex-epic-runtime-contracts`, `enforcement-hooks-checkpoint-path-explicit`, the two `enforce-orchestration-preimplementation-gate-*.Parity` suites, `session-root-reads-850.Constraints`, and `codex-preimplementation-gate-absolute-paths`. Disposition is an open decision (see Open Decisions for Confirmation). Before any `It` name is edited, the test tree is searched for references to that name.

## Inputs / Outputs

- Inputs:
  - Hook: the PreToolUse JSON envelope (`tool_name`, `tool_input.file_path`, and `content` for Write or `old_string`/`new_string`/`replace_all` for Edit), plus the pre-edit file content through the injected reader.
  - Repository gate: covered files discovered on disk and `config/file-size-baseline.json`.
  - Generator: a merge-base ref and the tracked blob contents at that ref.
  - `feature-review`: the branch diff of added and modified covered files.
- Outputs:
  - Hook: allow, or a deny decision with a reason naming the tiers, the split requirement, the path, and the resulting count.
  - Repository gate: Pester pass or fail with the ratchet message for each violating path.
  - Generator: `config/file-size-baseline.json` and an evidence record under `<FEATURE>/evidence/baseline/`.
  - `feature-review`: Warning rows in `code-review.<timestamp>.md`.
- Config keys and defaults: `schemaVersion` = 1, `hardLimit` = 800, `files` = sorted path-to-recorded-size map. The advisory limit 700 and guidance limit 500 are constants in the shared module.
- Versioning or backward-compatibility constraints: the hook is backward compatible with repositories that have no baseline file. The baseline schema carries `schemaVersion` for later change.

## API / CLI Surface

- Shared module functions (names are indicative; the plan fixes them): a line counter, a tier classifier, a covered-path test, a ratchet comparer, and a hook decision function. All are pure and take injected data.
- Example invocations with expected outputs:
  - Hook, Write of a new covered file with 801 logical lines: deny with the tier message.
  - Hook, Write of a new covered file with 800 lines: allow.
  - Hook, Edit that grows a pre-edit 810-line covered file to 815: deny. Edit that shrinks it to 805 or leaves it at 810: allow.
  - Hook, Write or Edit of a Markdown or JSON path of any size: allow with no read.
  - Repository gate against an in-memory file list: one result per ratchet row above.
  - Generator run twice at the same ref: byte-identical `config/file-size-baseline.json`.
- Contracts and validation rules: the hook fails closed on dependency-load failure, unreadable envelope, unreadable file, and unresolvable Edit for covered paths. The gate fails on any ratchet-row violation. No gate fails for a covered file of 500 through 800 lines that has no baseline entry.

## Data & State

- Data transformations and invariants:
  - Line count is a pure function of content under the counting convention. CRLF and LF content of the same text count identically.
  - Baseline invariant: every entry is a covered file over 800 lines whose recorded size equals its current size; the key set is sorted ordinally.
  - The baseline can only shrink through edits that tighten entries; additions and increases are reviewer-blocked.
- Caching or persistence details: `config/file-size-baseline.json` is the only persisted state; no caches.
- Migration or backfill requirements: one-time baseline generation at the merge base. No source file is split by this issue.

## Constraints & Risks

- CLAUDE.md names `.github/instructions` as authoritative and says not to modify it; the user explicitly approved editing it together with the `.claude` mirrors for this issue.
- Many existing files exceed 800 lines; the ratchet must not fail them.
- The new gate itself must stay under the policy it enforces. The module, hook, gate suite, generator, and their tests are separate files each targeted under 500 lines, and their bundle twins are counted by the gate.
- Execution-environment brief copies must stay byte-identical.
- Local versus CI discovery: `Get-ChildItem` sees untracked and gitignored files that CI does not (for example coverage-annotation artifacts and `testResults.xml`). The extension allowlist and fixed directory excludes mitigate this.
- Line endings: checkouts are normalized to LF in CI; a Windows worktree with CRLF files must count identically. Tests use in-memory strings with explicit `\r\n` and `\n`, not committed CRLF fixtures.
- Linux hook-suite job: hook tests use `Join-Path`, forward slashes, and exact case.
- Hook false denies: a hook that denied edits to non-covered large files would be a regression; the covered-path test is first.
- Hook proving: branch hooks are not exercised by isolated subagents until merged, so AC4 verification rests on Pester suites that import the hook.
- Bundle changes reach a push-down only after the extension is rebuilt and reinstalled.
- Docs-only PRs skip the `poshqc` jobs; this is acceptable because Markdown is exempt.
- Policy-audit and code-review artifacts are validated by an installed-extension validator that does not parse severity words; adding the `Warning` label is confirmed by running the validator on a sample artifact during implementation.

## Implementation Strategy

- Implementation scope (what changes, not sequencing):
  - Policy text and mirror updates across `.github`, `.claude`, `.agents`, `AGENTS.md`, `.codex` (generated), `.claude-variants`, `.codex-variants`, and the bundle twins.
  - New shared policy module, repository-gate suite, hook, generator, baseline file, and registrations.
  - `feature-review` section, code-review template legend, and policy-audit template row rewording.
  - Execution-environment brief rewrite in six copies.
  - Disposition of the existing file-scoped 500 assertions.
- New classes/functions/commands to add or update:
  - Add `.claude/lib/file-size-policy/FileSizePolicy.psm1` (plus Codex and bundle twins).
  - Add `.claude/hooks/enforce-file-size-limit.ps1` (plus Codex and bundle twins), registered in `.claude/settings.json`, `.codex/config.toml`, and bundle twins.
  - Add `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`, module unit tests, and hook tests under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, each in separate files.
  - Add `scripts/ci/New-FileSizeBaseline.ps1` and `config/file-size-baseline.json`.
  - Add the hook and module to `core.json` in both `pack-manifests` directories (the Codex `core.json` is regenerated by the generator, not hand-edited).
  - Update the hook-enumerating suites listed under PreToolUse hook.
- Dependency changes (new/removed packages) and rationale: none. Python is rejected for the gate and the hook because enforcement hooks must not invoke Python and a Python gate would be a second policy implementation. A new CI workflow job is rejected because it changes the required status contexts and the CI facts in the execution-environment brief.
- Logging/telemetry additions and locations: none. Failures are reported through Pester output and the hook deny reason.
- Rollout plan (feature flags, staged deploys, fallback path): no feature flag. The work exceeds the direct-mode batch budget of three distinct production files and runs on the orchestrated large path. The baseline is committed in the same change as the gate so the gate is green on merge. Fallback is reverting the change; the hook and gate are independent of each other, and the hook does not depend on the baseline.

## Acceptance Criteria

- [x] AC1: Policy text in every authoritative and mirrored surface states a three-tier policy (500 guidance, 700 advisory Warning, 800 hard block) and keeps the existing exemption list.
- [x] AC2: No gate fails for a file between 500 and 800 lines; `feature-review` reports files at or above 700 lines as non-blocking Warning findings.
- [x] AC3: A CI/Pester check fails for any file over 800 lines that is not on the baseline list, and for any baselined file that grows.
- [x] AC4: A PreToolUse hook denies a Write or Edit that leaves a covered file above 800 lines, with a message naming the tiers and the split requirement; baselined files may shrink or stay equal.
- [x] AC5: Every existing test, hook, validator, and document that hard-codes the 500-line limit is updated or confirmed unaffected.
- [x] AC6: The baseline list is generated deterministically from the repository at the merge base and is reviewable.
- [ ] AC7: All mirrors and bundle copies pass the contract tests, and the seven-stage toolchain passes.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: tier classification (below 500, 500-699, 700-799, 800 and above), exemption handling, ratchet comparison against the baseline, hook decision for Write/Edit.
- [ ] Integration scenarios: a baselined file that shrinks, stays equal, and grows; a new file at 801 lines.
- [ ] CLI/API examples: the CI check run against a fixture-free in-memory file list.

Additional unit coverage derived from the design: logical line counting with `\n`, `\r\n`, and no trailing terminator; boundary counts 0, 499, 500, 699, 700, 799, 800, and 801; ratchet rows including rename and missing-file entries; hook rows for dependency-load failure, unreadable envelope, unreadable file, unresolvable Edit, and non-covered path; and baseline generator ordering and determinism. Isolation checks use at least three seeded shuffled Pester file-order runs of the touched suites and a fresh single-process run over `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`. PowerShell line coverage is at least the repository threshold for each changed file; no branch gate applies to PowerShell.

## Open Decisions for Confirmation

1. **Strict ratchet semantics.** A baselined file that shrinks must have its baseline entry tightened to the new size; the gate fails otherwise. Default: yes, strict. The alternative (accept a shrink silently) allows a file to shrink and later regrow to its old size without detection.
2. **Existing file-scoped `<= 500` Pester assertions.** Default: keep the per-file `<= 500` assertions and reword `It` names and comments that call 500 the repository cap, while `ClaudeLibModuleConvention` switches its general gate to the shared 800 hard limit so two competing size gates do not apply to `.psm1` files. The alternative of rewording only is lower risk but leaves the competing gate.
3. **Re-derivation of the over-800 population.** Before the baseline is committed, the over-800 population is re-derived with `git ls-files` filtered to the covered extension allowlist, using the pinned counting convention. This includes resolving the 800-versus-801 boundary file and whether `scripts/dev_tools/pr_context/render.py,cover` is tracked. Default: this is a planning task, and the generator at the merge base is the authoritative source for the baseline contents.
4. **`.psd1` coverage.** Default: `.psd1` is not covered (not in the extension allowlist), consistent with treating data files as outside production code, test code, and reusable scripts. The planner confirms or amends the allowlist.
