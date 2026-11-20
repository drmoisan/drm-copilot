# Research: Codex review coverage hook reads stale or foreign artifacts (Issue #1114)

- Issue: #1114
- Branch: bug/codex-coverage-hook-freshness
- Feature folder: docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114
- Scope: `.codex/hooks/validate-feature-review-coverage.ps1` and the files that must change with it.
- Method: every statement below was verified by reading the named file in the item worktree, except where marked `UNVERIFIED` or `EXTERNAL`.

## 1. Current Codex hook behaviour

### 1.1 Registration and invocation

- `.codex/config.toml` registers the hook under `[[hooks.SubagentStop]]` with `matcher = "feature-review|feature-reviewer"`, as a `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/validate-feature-review-coverage.ps1"` command with `timeout = 30`. The same matcher group list also registers `validate-codex-subagent-routing.ps1` for review stops. No other Codex hook checks review artifact presence; the "Stop" body inside `.codex/agents/feature-review.toml` is prose in the converted agent text, not a registered hook.
- The script path is taken from `git rev-parse --show-toplevel` of the hook process, so the hook script, and therefore `$PSScriptRoot`, belong to the checkout in which the Codex session runs. `Get-RepoRoot` returns two levels above `$PSScriptRoot`, which is that checkout (the session root).

### 1.2 Payload shape (Codex runtime)

- Fields the hook reads today: `stop_hook_active` (must be a boolean, otherwise exit 2), `hook_event_name` (must be `SubagentStop`), `agent_type` (must be `feature-review` or `feature-reviewer`). Nothing else is read.
- Fields the Codex runtime documents for SubagentStop (EXTERNAL, `https://learn.chatgpt.com/docs/hooks`, fetched for this research): common fields `session_id` (the parent session id for subagent hooks), `transcript_path` (the session transcript, nullable), `cwd` ("working directory for the session"), `hook_event_name`, `model`, `permission_mode`; SubagentStop fields `turn_id`, `agent_id`, `agent_type`, `agent_transcript_path` (the subagent transcript, nullable), `stop_hook_active`, `last_assistant_message` (nullable). The page states that the transcript format "isn't a stable interface for hooks and may change over time".
- Repository corroboration: `.codex/hooks/validate-discovery-agent-output.ps1` (`Invoke-DiscoveryAgentOutputDecision`) reads `last_assistant_message` and `stop_hook_active` from the Codex SubagentStop payload; `.claude/lib/discovery-validation/DiscoveryPayload.psm1` (`$script:EnvelopeKeys`, `codex` row) reads `cwd`, `agent_id`, `agent_type`, `session_id`. No Codex hook reads the content of any transcript file; the Codex hooks use `transcript_path` only as a key (`Get-SubagentAttestationKey` in `.codex/hooks/record-subagent-routing-attestation.ps1`).
- Consequence: the delegation prompt is not available to a Codex SubagentStop hook in a supported form. The final reviewer message (`last_assistant_message`) is the only stable identity-bearing field.

### 1.3 Audit selection

- `Get-LatestPolicyAudit -RepoRoot` enumerates every `policy-audit.*.md` under `docs/features/active` recursively and returns the one with the greatest `LastWriteTime`. Feature folders under `docs/features/active/` are tracked files, so every checkout carries every active item's audits; the selection is by recency across all items, never by the item under review. This is the "foreign audit" defect.
- No audit -> exit 0 ("the existing SubagentStop artifact-presence hook covers this case"; on Codex no such hook is registered, see 1.1).

### 1.4 Changed languages, coverage reports, thresholds

- `Get-ChangedLanguageSet -RepoRoot` reads `artifacts/pr_context.summary.txt` beneath the session root; an absent summary yields no language and the hook exits 0.
- `Get-LanguageRepoCoverage -RepoRoot -Language` dispatches to `Get-LcovRepoCoverage` (`coverage/lcov.info`, `artifacts/python/lcov.info`) or `Get-JacocoRepoCoverage` (`artifacts/pester/powershell-coverage.xml`, `artifacts/csharp/coverage.xml`) beneath the session root. An absent report returns `$null` and the floor check is skipped silently. There is no freshness check of any kind (the "stale coverage" defect).
- Thresholds: the hook dot-sources `.codex/hooks/feature-review-coverage-thresholds.ps1` and calls `Get-FeatureReviewCoverageThreshold -ClaudeMdText` with the root `CLAUDE.md` text (absent -> defaults; unreadable -> throw, fails closed). Only the line floor is enforced on Codex.
- Row rule: `Test-LanguageCoverageRow` with `Get-CoverageNarrowingLine`; the definition text is pinned against the Claude rules file by `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1`.
- Output: a finding emits `Get-FeatureReviewCoverageContinuation` JSON (`decision = block` once; `continue = false` when `stop_hook_active` is true) with exit 0; malformed input exits 2 with the reason on stderr.

## 2. Claude implementation after #1105, and what is runtime-neutral

### 2.1 Flow of `.claude/hooks/validate-feature-review-coverage.ps1` (`Invoke-FeatureReviewCoverageValidation`)

1. `Read-SubagentStopEnvelope` (`subagentstop-envelope.ps1`) parses the Claude envelope; `AssistantText` is the final message.
2. The four tokens `policy-audit-path`, `code-review-path`, `feature-audit-path`, `remediation-inputs-path` are read with `Get-ReviewArtifactPathFromOutput` (`validate-feature-review-coverage-rules.ps1`). The policy audit is the advertised one, not a recency pick.
3. `Resolve-SubagentStopTargetWorktree` (`subagentstop-target-worktree.ps1`) resolves the item root once: absolute advertised paths -> `Resolve-HookTargetWorktree -FilePath`; otherwise the first user entry of `agent_transcript_path` (Claude JSONL, `Get-TranscriptFirstUserText`) reduced by `Get-SubagentStopIdentityPrompt` (`Find-WorktreeResolutionBranchSignal`, `Find-WorktreeItemIssueSignal`) -> `-DelegationPrompt`, with `Get-WorktreeItemCheckpointIssue` as the checkpoint reader for an issue-only identity; with neither, the session root. A `ReasonCode` blocks the review.
4. `Resolve-SubagentStopArtifactLocation` converts each advertised value (absolute inside the item root -> repository-relative; `..` beneath an item root rejected); `Get-ReviewArtifactInfo` enforces the `docs/features/active/<folder>/<stem>.<timestamp>.md` (or `audit/<timestamp>/<stem>.md`) shape; the sibling artifacts must share folder and timestamp.
5. For an item root other than the session root, the PR summary, root `CLAUDE.md`, and coverage reports are read beneath the item root (`Get-ArtifactFileContent -Root`, `Get-FeatureReviewClaudeMdText -Root`, `Get-LanguageRepoCoverage -Root`, `Get-LanguageBranchCoverage -Root` in `validate-feature-review-coverage-metrics.ps1`), and `Get-FeatureReviewCoverageFreshnessDecision` (`validate-feature-review-coverage-freshness.ps1`) runs first.
6. The session-root case is unchanged: no freshness probe, process-relative reads.

### 2.2 Freshness rule (`validate-feature-review-coverage-freshness.ps1`)

- Functions: `Get-FeatureReviewCoverageReportPath`, `Get-FeatureReviewCoveragePathspec`, `Get-FeatureReviewReportLastWriteUtc` (file-time seam), `Get-FeatureReviewCoverageFreshnessDecision` (`-WorktreeRoot -SessionRoot -Source -ChangedLanguage -GitInvoker`).
- Returns `$null` when `Source` is `SessionRoot`, the root is blank, or the root equals the session root (no probe). Otherwise it reports: absent PR summary (repairable), absent report for a changed language (repairable), report last-write time earlier than the committer time of `git log -1 --format=%ct HEAD -- <pathspecs>` in the item root (repairable), and a git failure (fail-closed, not repairable).
- Runtime dependencies: none beyond `git` on PATH and the file-time seam. No module import, no `.claude` path, no transcript, no Python. The file is functions-only. It is runtime-neutral.

### 2.3 Classification

| Piece | File | Runtime-neutral | Reason |
| --- | --- | --- | --- |
| Freshness decision and its three helpers | `.claude/hooks/validate-feature-review-coverage-freshness.ps1` | Yes | Pure logic plus `git` and a file-time seam. |
| `Resolve-HookTargetWorktree` and five helpers | `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`; Codex twin `.codex/hooks/hook-target-worktree.ps1` | Yes (twin exists) | The twin is function-text identical and already ships in the Codex core pack. |
| `Resolve-SubagentStopTargetWorktree`, `Resolve-SubagentStopArtifactLocation`, `Get-SubagentStopTargetNote`, transcript readers | `.claude/hooks/subagentstop-target-worktree.ps1` | No | Imports three `.claude/lib/worktree-resolution` modules at load; the identity path reads the Claude transcript JSONL shape, which Codex does not guarantee. |
| `Get-ReviewArtifactPathFromOutput`, `Get-ReviewArtifactInfo` | `.claude/hooks/validate-feature-review-coverage-rules.ps1` | Logic yes, file no | The file also defines `Get-ChangedLanguageSet -Lines`, which collides with the Codex `Get-ChangedLanguageSet -RepoRoot`; the Codex feature-review agents emit no `policy-audit-path:` token. |
| Metrics readers with `-Root` | `.claude/hooks/validate-feature-review-coverage-metrics.ps1` | Logic yes, file no | Name collisions with the Codex readers (`Get-LcovRepoCoverage`, `Get-LanguageRepoCoverage`) and branch metrics the Codex hook does not enforce. The Codex readers already accept a root (`-RepoRoot`). |
| `Read-SubagentStopEnvelope`, `Exit-SubagentStopBlock` | `.claude/hooks/subagentstop-envelope.ps1` | No | Claude envelope and exit-2 block contract; the Codex hook uses the continuation JSON contract, and `E4-ST7` forbids both names in the Codex hook. |

## 3. May a Codex hook dot-source `.claude/`?

- No, for this hook. `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` (`E4-ST7: the Codex hook reads the floor from its own thresholds copy`) asserts that the Codex hook contains no dot-source whose text contains `.claude`, and contains neither `subagentstop-envelope.ps1` nor `Exit-SubagentStopBlock`.
- Codex installs do not ship `.claude/`. `scripts/dev_tools/push_down_codex_and_agents_customizations.py` publishes `ROOT_FOLDERS = (.codex, .agents)` plus the virtual roots `config/`, `.codex/lib/codex-routing`, and `.codex/lib/discovery-validation`. The header of `.codex/hooks/hook-target-worktree.ps1` states the reason for that twin: "Codex hooks cannot import .claude/lib in a consumer repository".
- The only `.claude` reads by Codex hooks are the discovery hooks' self-hosting fallback (`Get-...ModuleCandidate` in `enforce-discovery-planning-gate.ps1`, `enforce-discovery-artifact-gate.ps1`, `validate-discovery-agent-output.ps1`, `discovery-start-attestation.ps1`; "exemption D4"), which prefer the published `.codex/lib/discovery-validation` copy. That mechanism covers module libraries stored under `resources/lib`, not hook files, and would add a published-library leg for one small functions file.
- Prevailing sharing patterns and their pins:
  - Whole-file byte identity: `feature-folder-resolution.ps1` (`tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1` compares the `.claude/hooks` and `.codex/hooks` copies); `enforce-epic-merge-gate-review.ps1` (`tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`); `feature-review-coverage-thresholds.ps1` (`tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1`, four copies byte-identical).
  - Function-text identity with its own header: `.codex/hooks/hook-target-worktree.ps1` (`tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` parses both files, compares the function-name set and each function's extent text, asserts no statement outside function definitions, and runs the shared resolver rows against the dot-sourced twin).
- Bundle identity and packaging pins for any `.codex/hooks` file: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (for names in `$script:StaticCheckNames`: parse, at most 500 lines, byte-identical bundle copy, no `$env:CLAUDE_`; names in `$script:SharedModuleNames` must be listed in the Codex `core.json`); `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (bundle text equality); `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` (every bundled file in a pack manifest); `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` with `tests/scripts/dev_tools/pack_manifest_dependency_scan.py` (every positional `Join-Path $PSScriptRoot '<child>'` dependency of a manifested file is in core plus the owning pack).

## 4. Existing Pester suites and seams

### 4.1 Codex suites (`tests/scripts/codex-hooks/`)

- `validate-feature-review-coverage.Coverage.Tests.ps1`: dot-sources the hook and drives the entry point through the `&` route with `[Console]::SetIn`; file reads are Pester mocks of `Test-Path`, `Get-ChildItem`, `Get-Content`. Tests that assert the current behaviour and must change:
  - `returns no audit when the active folder is absent` and `returns the most recently written audit` call `Get-LatestPolicyAudit` (recency selection). Replace with item-identity selection tests, or delete with `Get-LatestPolicyAudit`.
  - Entry-point rows `exits 0 when no policy audit exists`, `exits 0 when the branch changes no tracked language`, `requests a continuation when a changed language lacks a verdict`, `stops the continuation loop when a validator error occurs with the stop hook active`, `E4-TR7`, `E4-TR8`, and both `E4-TR9` rows supply the audit through a `Get-ChildItem` mock and a payload without `last_assistant_message`. Under the recommended design their payload must name the audit path, and the `Get-ChildItem` mock becomes unnecessary; their asserted outcomes are otherwise unchanged. `exits 0 when no policy audit exists` changes outcome (see D2).
  - `E4-ST7` stays valid and must keep passing (no `.claude` dot-source).
  - `exits 2 for <Case>` rows are unchanged.
- `feature-review-coverage-narrowing-parity.Tests.ps1` and `feature-review-coverage-floor-parity.Tests.ps1`: dot-source each hook in a child scope and call only the row rule and the threshold resolver; unaffected by the change provided `Test-LanguageCoverageRow`, `Get-CoverageNarrowingLine`, and the thresholds dot-source keep their text.
- `legacy-codex-hook-contracts.Tests.ps1`: `uses one SubagentStop continuation ...` dot-sources the hook and calls `Get-FeatureReviewCoverageContinuation`; unchanged. The 500-line cap applies to the hook.
- `hook-dependency-failure.Codex.Tests.ps1`: enumerates registered Codex hooks and their direct dot-source edges from the AST at discovery, so each new guarded dot-source automatically gains a `B1` row; the entry must still exit 2 with the `validate-feature-review-coverage:` prefix naming the failed dependency.
- `codex-bundle-hook-probe.Tests.ps1`: lists the hook in `ExpectedExcludedHooks` (not a PreToolUse hook); unaffected.
- `hook-target-worktree.Tests.ps1`: pins the resolver twin; unaffected (no resolver change).

### 4.2 Claude suites (`tests/scripts/claude-hooks/`)

- `validate-feature-review-coverage-freshness.Tests.ps1`: mocks `Get-FeatureReviewReportLastWriteUtc` and passes an in-memory `GitInvoker`; fixture roots are `/synthetic-worktrees/...`. This is the template for the Codex freshness suite.
- `validate-feature-review-coverage.Tests.ps1` (`E4-ST3`): requires the Codex hook's first comment token to contain "an absent root CLAUDE.md uses the defaults" and "an unreadable root CLAUDE.md fails closed". A help rewrite must keep both sentences.
- `validate-feature-review-coverage.TargetWorktree.Tests.ps1`, `...Coverage.Tests.ps1`, `...Issue824.Tests.ps1`, `...ThresholdsGuard.Tests.ps1`: Claude-only; unaffected if no Claude file changes (recommended).
- Seams available on Claude: `-SessionRoot`, `-ReadTranscriptHead`, `-WorktreeListInvoker`, `-CheckpointIssueReader`, `-GitInvoker` on `Invoke-FeatureReviewCoverageValidation`. The Codex hook has `param()` and no seams; its entry reads stdin directly.

## 5. Mirrors, manifests, and the brief

- Bundle mirror of every changed or new `.codex/hooks` file: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/<name>` (byte-identical).
- Pack manifest: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists `.codex/hooks/validate-feature-review-coverage.ps1`, `.codex/hooks/hook-target-worktree.ps1`, `.codex/hooks/feature-review-coverage-thresholds.ps1`, and `.codex/hooks/feature-folder-resolution.ps1`. Each new `.codex/hooks` file needs an entry. `scripts/dev_tools/generate_codex_agent_variants.py` (`render_manifest`) preserves existing entries and only appends agent paths, so a hand-added hook entry survives the generator `--check`.
- No Claude-side file needs to change under the recommended design, so `extensions/drm-copilot/resources/claude-customizations/` is untouched.
- `.codex/config.toml` and its bundle copy need no change (the hook name and registration are unchanged).
- Execution-environment brief: the `## Hook Execution Context` bullet "SubagentStop artifact paths (#1105)" names only `.claude/hooks/validate-feature-review-coverage.ps1`, and the preceding bullet says the review coverage hook is not among the gates that use the root holding the hook script. The fix changes a fact the brief states (the Codex coverage hook's audit selection, item root, and freshness rule), so the maintenance rule in `## Purpose and Maintenance` requires an update in the same change in all six byte-identical copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and the three bundle copies under `extensions/drm-copilot/resources/` (`claude-customizations/.claude/...`, `codex-and-agents-customizations/.agents/...`, `customizations/.github/...`). `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` pins byte identity of the six copies, required headings, no consuming names, and no G11/G12 findings; no test pins the text of this bullet.

## 6. Candidate approaches

### A (recommended): Codex-local target selection, reuse of the resolver twin, and a function-text twin of the freshness file

- Item identity: parse `last_assistant_message` for policy-audit paths matching the `Get-ReviewArtifactInfo` shapes (`docs/features/active/<folder>/[<version>/]policy-audit.<timestamp>.md` and `docs/features/active/<folder>/audit/<timestamp>/policy-audit.md`), relative or absolute, either separator, with or without a `policy-audit-path:` label. The Codex feature-review agents are required to "Report every artifact path created or updated" (`.codex/agents/feature-reviewer.toml`, `Final response contract`), so the path is present in a compliant final message.
- Item root: when an extracted path is absolute, call `Resolve-HookTargetWorktree -SessionRoot <session root> -FilePath <absolute paths>` from the dot-sourced `.codex/hooks/hook-target-worktree.ps1`, and convert the path with `Get-HookTargetWorktreeRelativePath`. A relative path resolves to the session root, which is the same rule the resolver applies. An `TARGET_WORKTREE_AMBIGUOUS` result (paths in several worktrees) blocks.
- Audit selection: exactly one distinct `(folder, timestamp)` audit -> that file beneath the item root; several audits in one folder -> the lexicographically greatest timestamp; audits in different folders -> block (ambiguous); none -> see D2. The file must exist beneath the item root, otherwise block. No recency enumeration of `docs/features/active` remains.
- Coverage inputs: pass the item root to the existing `Get-ChangedLanguageSet -RepoRoot`, `Get-LanguageRepoCoverage -RepoRoot`, and the `CLAUDE.md` read. For the session-root case these are the same paths as today.
- Freshness: add `.codex/hooks/validate-feature-review-coverage-freshness.ps1`, carrying the four functions of `.claude/hooks/validate-feature-review-coverage-freshness.ps1` with byte-identical function text and a Codex header (the `hook-target-worktree.ps1` pattern). Call `Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot <item root> -SessionRoot <session root> -Source <resolver source> -ChangedLanguage <set> -GitInvoker <wrapper>` before the floor check; a non-null result emits the existing continuation with the reasons. The git default is reached through a named wrapper function in the Codex hook (for example `Invoke-CodexReviewCoverageGitLog`) so that the `&`-route tests can mock it; the worktree list likewise through a wrapper passed as `-WorktreeListInvoker`.
- Size: the hook is a 500-line-capped file. New Codex-only logic (path extraction, target and audit selection, the two git wrappers) goes into a new functions-only file `.codex/hooks/feature-review-coverage-target.ps1`, dot-sourced under the guarded pattern, so the hook stays well under the cap.
- Advantages: no `.claude` read; no second resolver; no Claude file changes; the Claude freshness rule is reused by pinned text; behaviour for a single-item checkout whose message names its audit and whose reports are fresh is unchanged.
- Limitations: freshness parity with Claude means no probe when the item root equals the session root (D1). Identity depends on the reviewer naming the audit path (D2).

### Rejected alternatives

- Dot-source `.claude/hooks/subagentstop-target-worktree.ps1` and the Claude freshness file from the Codex hook: violates `E4-ST7`, fails in Codex consumer installs that have no `.claude/`, and the transcript identity path reads a Claude JSONL shape that Codex documents as unstable.
- Publish the freshness file through a `.codex/lib` virtual root with a self-hosting `.claude` fallback (the discovery pattern): adds a `VIRTUAL_RESOURCE_DIRECTORIES` entry, a `resources/lib` copy, and loader code for one functions file; still a `.claude` path read on the self-hosting leg, which `E4-ST7` forbids for this hook.
- Byte-identical whole-file copy of the Claude freshness file: its header states it is "Dot-sourced by validate-feature-review-coverage.ps1" and "Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/", which is wrong for a Codex copy; correcting the header in both files adds two Claude production files and their mirror to the change without changing behaviour.
- Read the delegation prompt from `agent_transcript_path`: format undocumented and unstable per the Codex documentation; no Codex hook reads transcript content today.
- Session checkpoint `feature-folder` fallback (`artifacts/orchestration/orchestrator-state.json`): a parallel or epic session root holds a parent checkpoint, not the reviewed item's, so it can name the wrong item; it adds a file-read seam for a case a compliant reviewer message already covers.

## 7. Behaviour semantics (proposed)

- Success: the audit named by the reviewer is read beneath the resolved item root; changed languages, reports, and `CLAUDE.md` are read beneath the same root; for an item root other than the session root the reports exist and are not older than the newest commit touching the language; every changed language carries a non-narrowed PASS or FAIL row, and a FAIL row is present when repo-wide line coverage is below the floor.
- Ordering: payload validation -> audit path extraction -> item root resolution -> audit selection and existence -> changed-language read -> freshness decision -> thresholds -> row rule.
- Failure outputs keep the Codex contract: one `decision = block` continuation, then `continue = false` when `stop_hook_active` is true; malformed payloads exit 2. A git failure in the freshness decision is reported in the same continuation; the Codex contract has no repairable or non-repairable distinction and none is added.
- Edge cases: two active items with the other item's audit newer (the named audit wins); several audits of one item named (greatest timestamp); audits of two items named (block, ambiguous); absolute audit path outside every registered worktree (resolver falls back to the session root; the file probe beneath the session root decides); audit path with a `..` segment (reject); `last_assistant_message` null or not a string (treated as no path).

### Decisions for the spec owner

- D1 (freshness scope). Recommended: identical to #1105, so the probe runs only when the resolved item root differs from the session root. Consequence: a Codex session started inside the item worktree keeps today's no-freshness behaviour there, as Claude does; repro step 4 is satisfied for the item-worktree case. The alternative (probe at the session root as well) requires a guard change in the shared function, which would break function-text parity with Claude or change Claude behaviour, and makes an absent report block every session-root review, including consumer repositories that never produce a report for a changed language.
- D2 (no identifiable audit). Recommended: block once with a message that asks the reviewer to state the policy-audit path (a repairable condition), then `continue = false` when `stop_hook_active` is true. Today the hook exits 0 only when no audit exists anywhere, which never happens in a checkout with active items; falling back to recency would keep the defect.

## 8. Requirements mapping and minimal file inventory

| Requirement (spec Expected) | Design element | Files |
| --- | --- | --- |
| Read the policy audit of the item under review | Path extraction plus audit selection from `last_assistant_message` | `.codex/hooks/feature-review-coverage-target.ps1` (new), `.codex/hooks/validate-feature-review-coverage.ps1` |
| Read coverage from the item's worktree | `Resolve-HookTargetWorktree` (twin) with the absolute paths; item root passed to the existing readers | `.codex/hooks/validate-feature-review-coverage.ps1` |
| Block on a missing or stale report, matching #1105 | Function-text twin of the freshness decision | `.codex/hooks/validate-feature-review-coverage-freshness.ps1` (new) |
| Unchanged single-item behaviour with a fresh report | Session-root path unchanged except audit selection by name | (same files) |
| Docs/config references updated | Brief bullet names the Codex hook and its twins | six brief copies |

Production files (8, plus six brief copies):

1. `.codex/hooks/validate-feature-review-coverage.ps1` (modify: remove `Get-LatestPolicyAudit`, read `last_assistant_message`, guarded dot-sources of `hook-target-worktree.ps1`, `validate-feature-review-coverage-freshness.ps1`, `feature-review-coverage-target.ps1`; keep the two `CLAUDE.md` help sentences).
2. `.codex/hooks/validate-feature-review-coverage-freshness.ps1` (new).
3. `.codex/hooks/feature-review-coverage-target.ps1` (new).
4. to 6. Bundle mirrors of 1 to 3 under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
7. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (two entries).
8. Six copies of `execution-environment/SKILL.md` (one text edit, copied six times).

Test files:

- `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` (update the rows listed in 4.1; add entry rows for the two-item foreign-audit case, a stale report in an item worktree, an absent report in an item worktree, and the no-path block).
- `tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1` (new: function-name set and per-function text parity with the Claude file, no statement outside function definitions, and the freshness scenarios run against the dot-sourced Codex twin so the twin is covered).
- `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1` (new: extraction shapes, relative and absolute paths, resolver ambiguity, greatest-timestamp selection, cross-folder ambiguity, `..` rejection, null message).
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (add the two new names to `$script:SharedModuleNames`, so the 500-line cap, bundle identity, and core-manifest listing cover them).

## 9. Testing implications

- All new tests use in-memory seams: Pester mocks of `Get-FeatureReviewReportLastWriteUtc`, the git and worktree-list wrapper functions, `Test-Path`, and `Get-Content`; no temporary files, no real git.
- Fixture roots are `/`-rooted forward-slash literals with exact case; paths are joined with `Join-Path`; no drive letters or backslash literals (Linux hook-suite job).
- Assertions on the continuation JSON (`decision`, `reason` substrings naming the audit path, the item root, and the stale language).
- Coverage: the three Codex files are measured (`config/poshqc-coverage.json` lists `.codex/hooks`); each needs at least 85 percent line coverage from the Codex suites; the twin is covered only by tests that dot-source the Codex copy.
- Gate: one `Invoke-PoshQCParallelTest` run; plus the pytest contract tests named in section 5 and the Codex generator `--check`.

## Numeric Derivation Evidence

No numeric count is proposed for a `spec.md` acceptance criterion. The counts used in this document are descriptive and are recorded here for traceability.

- Claim: the execution-environment brief has six copies that must change together.
  - Complete Family: every file carrying the brief text.
  - Exhaustive Search Scope: the whole item worktree.
  - Inclusion Rules: a file that contains the literal `SubagentStop artifact paths (#1105)`.
  - Exclusion Rules: none.
  - Primary Search Strategy or Query Expression: content search for the literal `SubagentStop artifact paths \(#1105\)` across the worktree.
  - Primary Member Set: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.
  - Primary Count: 6.
  - Cross-check Search Strategy or Query Expression: the `_BRIEF_COPIES` tuple in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`.
  - Cross-check Member Set: the same six paths.
  - Cross-check Count: 6.
  - Member-set Comparison: identical after normalizing separators.

## Pre-Mortem

- Review checklists: a reviewer can find that the Codex hook help no longer states the absent and unreadable `CLAUDE.md` rules (`E4-ST3`), or that the hook still enumerates `docs/features/active` by recency; the plan must keep both help sentences and delete `Get-LatestPolicyAudit` with its tests rewritten, and must record D1 and D2 as spec decisions so the review does not treat the session-root no-probe as an omission.
- Coverage: the two new Codex files are measured and start at zero; the twin freshness file is covered only by tests that dot-source the Codex copy, and the git default inside the twin's `GitInvoker` parameter default cannot run in tests; the plan must give each new file its own suite and pass a mockable wrapper so the hook's call path is exercised.
- Mirror parity: every changed or new `.codex/hooks` file needs a byte-identical bundle copy, two new `core.json` entries, the two names in `$script:SharedModuleNames`, function-text parity with `.claude/hooks/validate-feature-review-coverage-freshness.ps1`, and the brief update in all six copies; the plan must carry one task per family and run `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_execution_environment_brief_contracts.py`, and the Codex generator `--check`.
- File size: Codex hook files are capped at 500 lines by `legacy-codex-hook-contracts.Tests.ps1`, stricter than the 800-line repository limit; the hook's current length leaves too little room for the target logic and seams, so the plan must place that logic in `feature-review-coverage-target.ps1` and check every Codex file against 500 lines.
- Test isolation: the existing Codex suite mocks `Test-Path`, `Get-ChildItem`, and `Get-Content` at script scope and registers epic-state baseline mocks; new suites must not run git (default invoker) or read gitignored `artifacts/` state, and must restore stdin and stderr in `finally`; the plan must route git and the worktree list through mockable wrapper functions.
- CI-only behavior: `poshqc / PowerShell hook suites (Linux)` runs `tests/scripts/codex-hooks` on a case-sensitive file system; fixtures must use `/`-rooted forward-slash paths in exact case, `Join-Path`, and no drive letters, and the extraction regex must accept both separators without relying on Windows path semantics.
- Evidence: branch hooks are not exercised by isolated subagents until merge, so acceptance must rest on Pester rows (fail-before for the foreign-audit and stale-report rows, pass-after) recorded under `<FEATURE>/evidence/regression-testing/`, with the Phase 0 baseline under `<FEATURE>/evidence/baseline/`; PoshQC MCP results carry no output, so counts and coverage come from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` of a direct `Invoke-PoshQCParallelTest` run.

## Automation Feasibility

- No human interaction is expected. Every change is a repository file edit plus Pester and pytest runs.
- Batch budget: the production PowerShell set is six files (three `.codex/hooks` files and three bundle mirrors), above the direct-mode cap of three; the run must hold a non-terminal `large`, `remediation`, or `preparation` route in the item worktree checkpoint before the fourth production PowerShell write.
- Tool routes: the researcher cannot run git or the clock; the orchestrator should confirm that `main` has not moved the Codex hook or the Claude freshness file since this research. The timestamp in this file name was not read from a clock (see the final report).
- The Codex runtime payload facts in 1.2 come from the external Codex hooks documentation; no live Codex run is needed, because the design relies only on `last_assistant_message`, `stop_hook_active`, `hook_event_name`, and `agent_type`, all of which existing Codex hooks already read.
