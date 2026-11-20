# Research: runbook command version check (#1128)

Scope: feasibility of the proposed fix. Verified by reading files in the item worktree. "Unverified" marks what was not run or not read.

## Verdict

Feasible as proposed. No design flaw found. Four corrections and traps are listed under Findings 6.

## 1. SubagentStop hook mechanics

`validate-pr-author-output.ps1` (the reference shape):
- Bootstrap line `$script:HookDependencyGuardLoadFailed` dot-sources `hook-dependency-guard.ps1`; each dependency is a single-statement `try { . ... } catch { Add-HookDependencyFailure ... }`.
- Dot-sources `subagentstop-envelope.ps1`. `Read-SubagentStopEnvelope` (stdin, or `-InputText` for tests) returns `IsValid`, `Anomaly`, `Envelope`, `AssistantText`. `Get-SubagentStopEnvelopeAnomalyReason` explains an anomaly.
- The decision function (`Get-PrAuthorOutputDecision`) first returns `Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix '<PREFIX>:'` when non-null (guard check S6), then reads the envelope, then returns an ordered dictionary `allowed` / `reason`.
- Tail: `if ($MyInvocation.InvocationName -eq '.') { return }`, then the load-failed check (exit 2), the dependency decision, then `Get-...Decision` inside try/catch; catch and a not-allowed decision call `Exit-SubagentStopBlock -Message`. That helper writes stderr and exits 2. The catch message is marked non-repairable ("not repairable by the subagent").
- Last message = `$envelope.AssistantText` (from `last_assistant_message`).

Worktree-aware reference: `validate-task-researcher-output.ps1`, function `Invoke-TaskResearcherOutputValidation`:
- Extracts the path with a regex (`research-path\s*[:=]...`, function `Get-ResearchPathFromOutput`).
- Calls `Resolve-SubagentStopTargetWorktree -Envelope -AdvertisedPath -SessionRoot` (plus `ReadTranscriptHead`, `WorktreeListInvoker` when supplied).
- Then `Resolve-SubagentStopArtifactLocation -Path -WorktreeRoot -SessionRoot` gives `RelativePath` (shape rules), `ProbePath` (the item copy to read), and `Rejected` / `RejectionDetail` (a `..` segment beneath an item root).
- `Get-SubagentStopTargetNote` appends probe-location text to "no file" blocks.
- `Resolve-SubagentStopTargetWorktree` (in `subagentstop-target-worktree.ps1`): an absolute advertised path decides via the FilePath source; otherwise it reads the first user entry of the transcript named by `agent_transcript_path` and reduces it with `Get-SubagentStopIdentityPrompt` (`branch:` label plus canonical issue line); otherwise the session root. It never throws and never falls back to main for an item.
- Item-root file reads for the lockfiles: join `$target.WorktreeRoot` + `poetry.lock` etc. when the root is non-null and not the session root (`Test-SubagentStopSessionRoot`); otherwise the session root. The runbook is at `$location.ProbePath`.

Test seams (no temp files): `-InputText` (envelope JSON built by `ConvertTo-SubagentStopEnvelopeJson` in `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1`), `-SessionRoot`, `-ReadTranscriptHead`, `-WorktreeListInvoker` (script blocks returning in-memory lines/porcelain). The researcher hook reads files through named functions (`Test-ResearchFile`, `Get-ResearchFileContent`), mockable. The new hook needs equivalent in-memory seams: `-ReadFile`/`-TestFile` script blocks for the runbook and each lockfile. One real end-to-end test spawns pwsh with stdin (tag `E3-Entry`, pr-author pattern) and needs no files because the envelope fails before any read.

Test files to mirror:
- Hook: `tests/scripts/claude-hooks/validate-human-exception-runbook-output.Tests.ps1`, plus `.TargetWorktree.Tests.ps1` (as `validate-task-researcher-output.TargetWorktree.Tests.ps1`) and `.Coverage.Tests.ps1` (as `validate-pr-author-output.Coverage.Tests.ps1`).
- Lib: `tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1` (as `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1`).

## 2. Bundle / manifest / contract obligations

- Owning pack: `core` (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/agents/human-exception-runbook.md`, the skill's `SKILL.md` and `example.runbook.md`, `.claude/hooks/validate-pr-author-output.ps1`, and the `.claude/lib/...` modules). Add to `core.json`: the new `.psm1` and the new hook.
- Bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/` of the new lib, hook, agent, skill, and example (byte-equal; `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`).
- `test_push_down_pack_manifest_dependency_closure.py`: `test_scanned_source_floor` (scanned set must equal manifested PowerShell entries, so a manifest omission fails), `test_claude_manifest_powershell_dependency_closure` (every `$PSScriptRoot` dependency, including `hook-dependency-guard.ps1`, `subagentstop-envelope.ps1`, `subagentstop-target-worktree.ps1`, and `../lib/runbook/RunbookCommandVersion.psm1`, in core), `test_every_psscriptroot_occurrence_is_recognized` (use only the standard `Join-Path $PSScriptRoot '...'` forms), and the frontmatter-hook check (`.claude/agents/*.md` frontmatter hook commands must be in core plus the owning pack). `human-exception-runbook.md` is manifested, so the new hook must be in core.
- `hook-dependency-guard-completeness.Tests.ps1`: hooks are discovered from `.claude/settings.json` and `.codex/config.toml` only (`Get-HookRegistration`), not agent frontmatter. Its S1 to S6 rows will not cover this hook. The pr-author hook is likewise unlisted there, but the new hook should follow the S1 to S6 shape anyway (bootstrap, single-statement guards with `-ErrorAction Stop`, dependency decision first, tail check after the dot-source early return). No edit to that test is required.
- `subagentstop-uncaught-error.Tests.ps1` and `hook-dependency-failure.Claude.Tests.ps1` list SubagentStop hooks with their `*_MISSING:` prefixes (`validate-pr-author-output.ps1` appears in both). Add the new hook with its prefix to both for parity. Not strictly required by a failing test (unverified whether they iterate a discovery list or only the literal rows); the literal rows are visible.
- `config/poshqc-coverage.json` roots already include `.claude/hooks`, `.claude/lib`; `config/poshqc-scan.json` scans `tests/scripts`. No config edit; the new files enter the coverage denominator and need >= 85% line coverage. No new shard config. `config/poshqc-leak-allowlist.json` only if tests set globals (avoid).
- `.claude/settings.json`: `Agent(human-exception-runbook)` is already allowed (its SubagentStop `matcher` list does not name pr-author or human-exception-runbook; agent frontmatter registers instead). No settings change needed. The agent file's `tools:` allows `Write(<FEATURE>/runbooks/**)` only, with Read/Grep/Glob; the hook runs outside the agent's tool list, so no tool change. The agent gets a `hooks:` block (`SubagentStop` matcher `human-exception-runbook`, `pwsh -NoProfile -File .claude/hooks/validate-human-exception-runbook-output.ps1`), as in `pr-author.md`.
- `claude-architecture-doc.Tests.ps1`: it asserts specific phrases of `docs/engineering/claude-code-architecture.md` and named rule/agent files (MCP contract, `feature-review.md`). A grep of `human-exception` in that test found nothing; it needs no update unless the architecture doc is edited. Recommend a one-line doc mention only if a doc already lists agent hooks (unverified).
- Codex: no `.codex/agents/human-exception-runbook*.toml` and no `runbook` text in `.codex/`. `generate_codex_agent_variants.py` `CORE_FAMILIES` is orchestrator, atomic-planner, atomic-executor, feature-reviewer, task-researcher, prd-feature, pr-author, commit-steward, plus the discovery families. The runbook agent is not a family, so no Codex variant or `--check` change. Hook is Claude-only; no `.codex/hooks` twin.
- `.agents/skills/human-exception-runbook/{SKILL.md,example.runbook.md}` exist, with bundle copies under `codex-and-agents-customizations/.agents/skills/...`; they need text parity only (`test_push_down_codex_and_agents_resource_contracts.py` equality; `test_push_down_codex_and_agents_pack_manifest_completeness.py` lists the SKILL.md). Whether `.agents` text must equal the `.claude` text byte-for-byte is unverified; diff the current pairs before editing.

## 3. Existing tests asserting current text

Searched `tests/` for `human-exception-runbook`, `example.runbook`, `Source and Citation`, `Cue`, `runbook` (case-insensitive).
- No test asserts the skill, agent, or example runbook prose. Only `.agents/skills/human-exception-runbook/SKILL.md` appears as a path in `test_push_down_codex_and_agents_pack_manifest_completeness.py` (manifest membership; unchanged), and in `tests/fixtures/blast_radius/historical-runs/*.json` (frozen historical data; do not edit).
- Other `runbook` matches are `runbook_path` handling (orchestrator-output hook and state validators, `test_validate_orchestrator_state_human_interaction.py`, `OrchestratorStateReceipts.Tests.ps1`, worktree-removal gate trigger tests). They are independent of the skill text.
- Existing runbooks under `docs/features/completed/*/runbooks/*.runbook.md` are not validated by any test; the new hook runs only at agent stop, so they are unaffected.
- Mirror byte-parity is the only pin. All nine skill/agent/example copies must change together (`.claude`, `.agents`, and the two bundle roots).

## 4. Lockfile helpers

No reusable lockfile parser exists. `PowerShell`/`.claude/lib` grep for `poetry.lock|uv.lock|package-lock|[[package]]` finds only `scripts/dev-tools/Invoke-FullRelease.ps1` (path joins to `package-lock.json` for staging, no parsing). `DocsTomlKeys.psm1` is key extraction for docs analyzers, not a package parser (not read in depth; unverified). A new parser is needed: poetry.lock/uv.lock `[[package]]` blocks (line scan for `name = "..."` then `version = "..."`), `package-lock.json` via `ConvertFrom-Json` (`packages."node_modules/<n>".version`; nested `node_modules/a/node_modules/b` should be ignored or take the shallowest), requirements via regex `^name==version`. All lines are pure string input.

## 5. Recommended shape

Keep the proposal. The module takes lockfile text and runbook text only (pure); the hook owns all reads through seams. Put hook decision logic in a `Get-HumanExceptionRunbookDecision` function. File size is no concern (each file well under 500 lines). Place a second lib module only if parsing plus checking exceeds ~400 lines (for example `RunbookLockfile.psm1` and `RunbookCommandVersion.psm1`); either needs entries in `core.json` and both bundle trees.

## 6. Traps and corrections

1. The hook and the lib are an unavoidable 3+ production PowerShell files (module, hook, perhaps two modules) plus bundle mirrors: the batch-budget cap (3 distinct production PowerShell files per session) counts bundle copies, so this belongs on the orchestrated large path or must be split across sessions.
2. `.claude/hooks/subagentstop-target-worktree.ps1` does not import its own guard; dot-source it in the new hook under the guarded single-statement pattern (`try { . ... } catch { Add-HookDependencyFailure -Name '...' -ErrorRecord $_ }`) after `hook-dependency-guard.ps1`, as the researcher hook does. Add a guarded `Import-Module ... RunbookCommandVersion.psm1 -Force -ErrorAction Stop` pre-load in the hook; a lazy import would fail S5.
3. Frontmatter hook is not exercised by isolated subagents until it merges (execution-environment brief, Hook Execution Context): acceptance must rely on Pester, not a live run.
4. Runbook path extraction: the agent returns `runbook_path`; reuse the researcher regex pattern with `runbook_path` and also accept `runbook-path`; require the `.runbook.md` suffix and a `/runbooks/` segment, and reject `..` via `Resolve-SubagentStopArtifactLocation`.
5. Fences: tool inference must skip fences whose info string is not shell-like (`powershell`, `bash`, `sh`, `console`, none) or the example output blocks will be false findings; define behavior for multi-line blocks (check the first command token of each non-blank, non-comment line, or the whole block as one unit) in the spec. A `Version check:` placement rule (line immediately after the closing fence) must be stated in the SKILL.md and example.runbook.md.
6. Version mismatch rule: compare the marker version to the pinned value with exact string equality (poetry/uv versions are normalized PEP 440; npm semver). Normalization of names only (lowercase, `_`/`.` to `-`, PEP 503). Add `.`.
7. Unpinned-tool rule: `<tool> not pinned in this repository` is a finding only when the tool is pinned (as proposed). Tools that are system binaries (`az`, `gh`, `git`) are never pinned in lockfiles; they must use the third form. Decide whether the third form is also accepted for them without a pinned lookup (it is, per the proposal) and state it in the spec.

## Pre-Mortem

- Review checklists: a reviewer can fail the change for missing mirror copies or an unlisted `core.json` entry. Mitigation: the plan lists all nine skill/agent/example copies and the module/hook bundle copies plus both manifest edits.
- Coverage: the new lib and hook are in the coverage denominator (>= 85% line, no branch gate). Mitigation: tests per parser (poetry, uv, npm, requirements), each marker form, malformed fences, and each hook block reason.
- Mirror parity: byte-equality tests fail if any bundle copy differs. Mitigation: copy each file, then run the push-down contract tests listed in the execution-environment brief.
- File size: no file approaches 500 lines if parsing and checking stay split. Mitigation: split before reaching 500.
- Test isolation: the hook tests may not create files. Mitigation: in-memory seams as named in section 1, no globals or environment edits so the leak scan stays clean.
- CI-only behavior: Linux hook-suite job runs `tests/scripts/claude-hooks`; forward-slash paths, exact case, no drive letters in fixtures. Mitigation: use `/synthetic-root`-style paths as `hook-dependency-guard-completeness.Tests.ps1` does.
- Evidence: the hook cannot be proven live from a branch. Mitigation: record the Pester run output as evidence and state the live check is deferred until merge.
