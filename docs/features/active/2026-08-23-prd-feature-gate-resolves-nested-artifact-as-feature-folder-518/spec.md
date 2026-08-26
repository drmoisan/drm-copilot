# 2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder (Spec)

- **Issue:** #518
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23T23-22
- **Status:** Complete — ready for planning
- **Version:** 1.0
- **Work Mode:** `full-bug` (`user-story.md` is intentionally absent per `.claude/skills/feature-promotion-lifecycle/SKILL.md`)

## Context
`enforce-prd-feature-before-planner.ps1` identifies the active feature folder by scanning the delegation prompt for `docs/features/active/<token>` paths and taking the **longest** match, using its parent when the match ends in `.md`. Citing any artifact nested below the feature folder — a `research/` finding, an `evidence/` file — produces a longer match than the folder itself, so the gate resolves to the subdirectory, finds no `issue.md` there, cannot read a work-mode marker, and fails closed demanding both `spec.md` and `user-story.md` inside that subdirectory.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a — hooks are PowerShell; PowerShell 7.6.5
- Command/flags used: `Agent` delegation to `atomic-planner` with a prompt citing a research artifact by full repo-relative path
- Data source or fixture: `.claude/hooks/enforce-prd-feature-before-planner.ps1` at commit `bee15c06`; observed live during an orchestration run on 2026-08-23

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. It fails closed so it is not a safety hole, but it blocks a mandated delegation on a correctly prepared feature, the block message points at the wrong remedy, and the demanded remedy is unsatisfiable for `full-bug` work. An agent following the message would either re-run `prd-feature` pointlessly or create a `user-story.md` that violates the lifecycle contract — the second outcome is actively harmful, since the gate would then pass while the feature folder had become non-compliant.

Not a Blocker because a workaround exists once the cause is known, and because the correct delegation form is reachable.


## Repro & Evidence
Steps to Reproduce:
1. Prepare an active feature folder that legitimately satisfies the gate: `issue.md` carrying a `- Work Mode: full-bug` marker, and `spec.md` present. `user-story.md` is correctly absent for that work mode.
2. Delegate to `atomic-planner` with a prompt that names both the feature folder and a research artifact inside it, for example `docs/features/active/<slug>/research/<timestamp>-findings.md`.
3. Observe the gate decision.
4. Re-issue the identical delegation with the research artifact expressed folder-relative — `research/<timestamp>-findings.md` — so the longest `docs/features/active/...` token in the prompt is the feature folder itself.
5. Compare.

Expected:
Both delegations describe the same feature folder and should produce the same decision. A prompt that cites supporting artifacts is normal and expected: the orchestrator is required to hand the planner its research findings, and `.claude/skills/orchestrate/SKILL.md` names the research path as a delegation input. Citing an input should not change which folder the gate believes is in scope.

Actual:
Step 2 is denied. Step 4 is allowed.

```text
PRD_FEATURE_BLOCKED: cannot delegate to atomic-planner before prd-feature outputs are
present in 'docs/features/active/<slug>/research'. Missing: spec.md, user-story.md.
Work mode could not be determined from 'docs/features/active/<slug>/research/issue.md'
(marker absent, unreadable, or unrecognized); failing closed to the strictest
prerequisite set (spec.md, user-story.md). Invoke the prd-feature subagent first.
```

The message is self-diagnosing if read closely — it names `.../research` as the folder and `.../research/issue.md` as the file it could not read — but the headline is "invoke the prd-feature subagent first", which is wrong and misdirects the reader toward re-running a step that has already completed correctly.

Two failure modes compound:

1. **Longest-match folder resolution.** The hook's documented strategy is that "the longest match wins; when it points at a `.md`, use its parent". Any nested artifact is a longer path than the folder, so the deeper directory wins.
2. **Fail-closed to the strictest set.** Having resolved to a directory with no `issue.md`, the hook cannot read the work-mode marker and demands both `spec.md` and `user-story.md`. For a `full-bug` feature that is doubly wrong: `user-story.md` must be *absent* under `.claude/skills/feature-promotion-lifecycle/SKILL.md`, so the gate demands a file whose presence the lifecycle rules treat as an integrity failure. No valid state satisfies it.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet is inlined under **Actual Behavior** above.
- Workaround used at the time: express nested artifact paths folder-relative in the delegation prompt, keeping the feature folder as the longest matching token. This is undiscoverable without reading the hook source.


## Scope & Non-Goals

### In scope

1. `.claude/hooks/enforce-prd-feature-before-planner.ps1` — replace the longest-match folder-resolution rule in `Find-PrdFeatureFolderFromPrompt` (lines 191-233) with two-segment truncation plus a deterministic selection rule; make an indeterminate work mode a distinct block reason; re-lead the block message with the resolved folder.
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` — the identical edit. Not optional: text parity is asserted by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, function `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 101-126), whose `SCOPED_ROOTS` covers all of `.claude/**`.
3. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` — update the two existing assertions the change invalidates (lines 250-256, lines 358-370).
4. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` — a new companion test file carrying the new resolution and selection cases, created if and only if the file-size rule in the Test Strategy section requires it.

### Out of scope / non-goals

- **No shared helper module.** Extracting the resolution rule into a new production PowerShell file would force a new bundled mirror, two `pester.runsettings.psd1` edits (self-hosted and bundled), and a new test file, for a larger write set than the duplication it removes. None of the affected hooks is near the 500-line limit (research section 4).
- **No version-folder awareness.** No versioned folder exists under `docs/features/active/` today (research section 2). A hypothetical versioned active feature would resolve its `issue.md` correctly under truncation and then fail the `spec.md` probe — an outcome identical to today's behavior for a prompt citing the folder alone. The limitation is pre-existing, unchanged by this fix, and is recorded in the hook's comment-based help rather than coded around.
- **No change to trailing-punctuation handling.** A token such as a folder path ending a prose sentence with a period is captured with the period attached by the existing regex character class (research section 1(a)). Truncation neither introduces nor repairs this; it is recorded and left unchanged.
- **No change to hook registration.** `.claude/settings.json:186` and its bundled mirror are unmodified.
- **No change to `pester.runsettings.psd1` in either copy.** `.claude/hooks/enforce-prd-feature-before-planner.ps1` is already registered in the `CodeCoverage.Path` allow-list at line 202 (research section 7). No new production file is created, so no allow-list entry is added.

### Explicitly excluded systems, integrations, or datasets

- **`.claude/hooks/enforce-epic-wave-barrier.ps1` (line 99), `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (line 150), and `.claude/hooks/enforce-parallel-drift-gate.ps1` (line 196), together with their three bundled mirrors and three test files.** These three hooks carry the identical `Sort-Object -Property Length -Descending` selection rule and the identical defect: a nested-artifact citation resolves the basename to `research` or `evidence`, the record lookup fails, and the hook issues a false block (research section 4). They are excluded from #518 because `.claude/rules/powershell.md:37-40` caps a batch at 3 production files and direct mode at 2 production PowerShell files. Fixing all four hooks means eight production files counting the mandatory bundled mirrors, which exceeds both caps and would require an explicit override. **Each of the three warrants its own issue**, citing the line numbers above and the fourth-segment fix described in research section 4.
- **`.claude/hooks/enforce-feature-folder-order.ps1`.** Needs no code edit. It reads `file_path` from the tool payload (line 120) rather than scanning prompt text, and its path test at line 87 is a strictly anchored regex whose `[^/]+` segment forbids a nested path and whose match must end in `/plan.md`. It is structurally immune to this defect (research section 4). Two adjacent defects in that hook are recorded here and likewise excluded: (a) it demands `issue.md`, `spec.md`, **and** `user-story.md` unconditionally at line 62 with no work-mode awareness, which would block a `full-bug` plan write and contradicts `.claude/skills/feature-promotion-lifecycle/SKILL.md:111`; (b) because its regex requires a literal `plan.md`, it is inert against the repository's prevailing timestamped plan-artifact convention. Both are separate issues and must not be folded into #518.
- **`tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1`** — no behavior change to cover.
- **`tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`** — dot-sources the hook at lines 140-147 but asserts only the PreToolUse deny shape and mocks `Get-PrdFeatureCheckpointFolder` to a null value. It is insensitive to both the selection rule and the reason text.
- **`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`** — already enumerates the hook; unchanged because no new file is added under `.claude/`.
- **Any file under `.codex/`** — the selection-rule search returns no Codex file; there is no Codex mirror of this hook.
- **Any `.claude/rules/` file** — no rule file documents the folder-resolution contract. The only prose statement of it is the hook's own comment-based help, which is edited in place.

## Root Cause Analysis
- Longest-match is the wrong selection rule for this purpose. The feature folder is identifiable structurally, not by length: it is the path segment immediately below `docs/features/active/`. Truncating any matched path to exactly two segments past that prefix resolves every case correctly and is insensitive to how deep the cited artifact sits.
- The `.md`-implies-parent rule is a partial approximation of the same idea and should be removed once truncation is in place, since a `.md` directly inside the feature folder is handled by truncation anyway.
- The fail-closed branch deserves separate attention. Failing closed is right in principle, but failing closed to a set that includes `user-story.md` is wrong for two of the three work modes. Consider failing closed to `spec.md` only, or reporting "work mode indeterminate" as its own distinct reason rather than folding it into a missing-file message.
- The block message should name the resolved folder in the headline rather than the remedy, so the next reader sees the path problem first.
- Check `enforce-feature-folder-order.ps1` and any other hook that infers a feature folder from prompt text for the same selection rule.

Resolution of the last bullet, from research section 4: a repository-wide search for `Sort-Object -Property Length -Descending` returns exactly eight files — four self-hosted hooks and their four bundled mirrors — and nothing else. Three of those four hooks (`enforce-epic-wave-barrier.ps1:99`, `enforce-parallel-cohort-barrier.ps1:150`, `enforce-parallel-drift-gate.ps1:196`) carry the identical defect and are excluded from #518 by the change budget; see Scope & Non-Goals. `enforce-feature-folder-order.ps1` does **not** carry the rule and needs no code edit: it reads `file_path` from the tool payload rather than scanning prompt text, and its path test at line 87 is a strictly anchored regex whose `[^/]+` segment forbids a nested path.


## Proposed Fix

### Design summary (what changes where):

Three changes inside `.claude/hooks/enforce-prd-feature-before-planner.ps1`, mirrored byte-for-byte into the bundled copy.

1. **Structural folder resolution replaces longest-match selection** in `Find-PrdFeatureFolderFromPrompt` (lines 191-233). Every matched `docs/features/active/...` token is truncated to exactly two segments past the `docs/features/active/` prefix — that is, to the four segments `docs`, `features`, `active`, and the feature-folder name. Selection among the truncated candidates follows the documented rule below. The `Sort-Object -Property Length -Descending` call at line 223 is **deleted**, and the `.md`-implies-parent branch at lines 226-232 is **deleted**.
2. **An indeterminate work mode becomes its own block reason.** The required-file probe is skipped entirely in that branch, and the message states marker repair as the remedy.
3. **The block message leads with the resolved folder**, not with the "invoke the prd-feature subagent first" remedy.

### Boundaries and invariants to preserve:

- **The gate must remain fail-closed.** Every path that cannot establish the prerequisites denies the delegation. The empty prerequisite set is never used as a fail-closed default; that would fail open, the defect class corrected by `docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/` and locked by the existing test at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:350-357`.
- **The gate must keep denying when `prd-feature` genuinely has not run.** A `full-feature` or `full-bug` folder with no `spec.md` still blocks.
- **`Find-PrdFeatureFolderFromPrompt` adds no new I/O.** Matching, normalization, truncation, and deduplication are pure string operations. Resolution reaches the pre-existing `Get-PrdFeatureCheckpointFolder` seam only in the tie-break case where two or more distinct candidates survive deduplication, exactly as the data-flow requirements at lines 158-161 of this document mandate; with zero or one distinct candidate no seam is consulted. That seam already existed and is already mocked by the test suite, so no new mock seam is introduced. An earlier revision of this bullet stated the function "remains a pure string function" with "no filesystem probe added to folder resolution", which contradicted the operative data-flow text; the delivered implementation follows the data-flow text and discloses the conditional read in its own comment-based help. Corrected at close-out per review finding NB-8. The filesystem-walk alternative is rejected: it converts a pure function into an I/O function requiring a new mock seam, cannot resolve a folder whose `issue.md` is missing (exactly the state the fail-closed branch exists to report), and depends on the process working directory, which `.claude/rules/powershell.md:69-76` prohibits tests from relying on.
- **The hook activates only for `subagent_type == 'atomic-planner'`** (lines 286-289). Unchanged.
- **The existing mock seams are preserved**: `Get-PrdFeatureFileExistence` (lines 56-69), `Get-PrdFeatureIssueContent` (lines 71-95), and `Get-PrdFeatureCheckpointFolder` (lines 161-189) keep their names and signatures so existing tests continue to mock them.
- **The dot-source guard at lines 343-345 is unchanged**, so tests continue to load the hook without executing the entry point.
- **The PreToolUse deny payload shape is unchanged**, so `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` continues to pass without edit.
- **No file may reach 500 lines** per `.claude/rules/general-code-change.md`. The hook is 351 lines; the existing test file is 408.

### Dependencies or blocked work:

- No blocking dependency. The research artifact `research/2026-08-23T23-40-prd-feature-gate-folder-resolution-research.md` is complete and authoritative for current behavior, the file set, and the constraints.
- No step requires human interaction: the change surface is PowerShell source and Pester tests, and the full toolchain is available as non-interactive MCP calls (research, Automation Feasibility section).
- Three follow-up issues for the sibling hooks are downstream of this fix, not upstream of it.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| Path | Change |
| --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | Resolution rule, indeterminate-mode branch, message text, comment-based help |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | Identical edit; forced by the parity test |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | Update the two invalidated assertions |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | New companion file for the new cases, conditional on the size rule below |

#### Functions/classes/CLI commands impacted:

- `Find-PrdFeatureFolderFromPrompt` (lines 191-233) — rewritten body; signature and return contract unchanged (a normalized forward-slash folder path, or a null value when no candidate resolves).
- `Get-PrdFeatureRequiredFile` (lines 132-159) — the `default` arm at line 157, which currently returns `@('spec.md', 'user-story.md')` for an unrecognized or null mode, is no longer reached from the indeterminate branch because the probe is skipped there.
- `Invoke-PrdFeatureBeforePlannerDecision` (message construction at lines 325-331) — the indeterminate branch becomes a separate decision path, and both reason strings are re-led with the resolved folder.
- `Get-PrdFeatureCheckpointFolder` (lines 161-189) — no code change; it becomes an input to the multi-candidate selection rule.
- No CLI command or exported interface changes. The hook has no command-line surface beyond the PreToolUse stdin payload.

#### Data flow and validation changes:

**Folder resolution, in order:**

1. Match `docs/features/active/...` tokens in the prompt with the existing regex at line 211. The regex is unchanged.
2. Normalize each match to forward slashes and apply `TrimEnd('/')` — the existing lines 218-219 behavior.
3. Split each normalized value on `/` and keep the first four segments. **Reject** any candidate yielding fewer than four segments (for example a degenerate token such as `docs/features/active/.`). Truncation is depth-insensitive, so a folder path, a `spec.md` path, a `research/` artifact path, and an `evidence/` artifact path all reduce to the same value.
4. **De-duplicate preserving first-occurrence order.** The current `[hashtable]` at line 217 must not be used for this: PowerShell hashtable key enumeration order is unspecified (research section 1(a)), so a first-occurrence selection rule fed by a hashtable is not deterministic. Use an order-preserving collection — `[System.Collections.Specialized.OrderedDictionary]`, or a `List[string]` with a `Contains` guard.
5. **Delete the length sort.** Truncation alone is not sufficient. After truncation every candidate has the same depth, so `Sort-Object -Property Length -Descending` degenerates into "the folder with the longest slug wins", which is an arbitrary criterion and not the intended rule. The sort must be removed, not merely fed truncated input.
6. **Select among distinct candidates:**
   1. If exactly one distinct truncated candidate exists, use it.
   2. If more than one exists, prefer the candidate whose normalized value equals the orchestrator checkpoint's feature-folder field, obtained through the existing `Get-PrdFeatureCheckpointFolder`. Justification: the checkpoint is the orchestrator's own record of which feature is in flight, so it is the authoritative disambiguator; and it reuses a seam the hook already owns and already mocks, adding no new I/O surface.
   3. Otherwise, use the **earliest-occurring** candidate in the prompt text. Justification: `.claude/skills/orchestrate/SKILL.md:298-304` lists the active feature folder path among the items the orchestrator supplies to the planner, and the observed delegation form names the folder before citing artifacts inside it. A cross-reference to another feature's work appears later in the prompt.
7. Return a null value when no candidate survives, preserving the existing contract.

**Why the multi-folder rule is required rather than optional:** the case is real and already exercised. `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1:299-302` constructs a prompt containing two distinct folders and asserts a specific outcome, and `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1:55` shows an epic-mode prompt naming both an epic folder token and a child feature folder path. A research or plan artifact commonly cross-references prior work in another active feature folder.

**Work-mode branch:**

- When the marker resolves (`minor-audit`, `full-feature`, `full-bug`, or legacy `full` normalized to `full-feature`), behavior is unchanged: `Get-PrdFeatureRequiredFile` selects the set, `Get-PrdFeatureMissingFile` probes it, and the decision allows when nothing is missing.
- When the marker is indeterminate — absent, unreadable, or unrecognized — the decision denies with a **distinct reason** and **does not run the required-file probe at all**.

**Justification for skipping the probe.** When the mode is unknown, no prerequisite set is knowable, so any set the gate names is wrong for at least one mode. Measured against `.claude/skills/feature-promotion-lifecycle/SKILL.md:66-70` and `:106-111`:

| Candidate fail-closed set | `full-feature` | `full-bug` | `minor-audit` |
| --- | --- | --- | --- |
| `{spec.md, user-story.md}` (today) | Satisfiable | Satisfiable only by creating a file the lifecycle says should be absent | **Strictly unsatisfiable without an integrity violation** (SKILL.md:109) |
| `{spec.md}` | Satisfiable | Satisfiable | **Strictly unsatisfiable without an integrity violation** |
| `{}` (empty) | Fails open | Fails open | Fails open |

The intersection across all three modes is the empty set, which fails open and is prohibited. Therefore no non-empty set is universally satisfiable, and the only remedy true in all three modes is repairing the `- Work Mode:` marker. That is what the message must say. Blocking on the indeterminate mode alone remains strictly fail-closed: the delegation is denied. After the folder-resolution fix, an indeterminate mode means a genuinely malformed feature folder, because `new_active_feature_folder` always creates `issue.md` (SKILL.md:74-77), so marker repair is the correct remedy rather than re-running `prd-feature`.

**A fail-closed set that includes `user-story.md` must not be retained.** It is the condition `issue.md` identifies as actively harmful: an agent following the message creates a `user-story.md` that makes the folder non-compliant while the gate then passes.

#### Error handling and logging updates:

The hook emits no log stream; its only output is the PreToolUse decision payload. Two reason strings change.

- **Missing-prerequisite reason (mode determined).** The headline names the resolved feature folder first, then the missing file list and the work mode, and only then states the prd-feature remedy. A reader who sees a wrong folder in the headline diagnoses a path problem immediately instead of re-running a completed step.
- **Indeterminate-marker reason (new, distinct).** Names the resolved feature folder and the `issue.md` path it probed, states that the `- Work Mode:` marker was absent, unreadable, or unrecognized, and states the remedy as adding or correcting that marker. It must **not** name `spec.md` or `user-story.md` and must **not** present a missing-file demand.
- Both keep the `PRD_FEATURE_BLOCKED:` prefix so existing prefix-matching assertions and operator expectations hold.
- Existing failure tolerance is unchanged: `Get-PrdFeatureIssueContent` still returns a null value when the path is not a leaf file or when `Get-Content` throws (lines 85-94), and `Get-PrdFeatureCheckpointFolder` returning a null value is a normal, handled outcome that falls through to the earliest-occurrence rule.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. A PreToolUse hook has one live behavior, and a flag would double the state space of a gate whose value is its determinism. Rollback is a revert of the change to both hook copies and the test files; there is no persisted state, no migration, and no artifact written by the hook to unwind.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- **Input.** The PreToolUse JSON envelope on stdin, carrying `tool_name` and a `tool_input` object with `subagent_type` and `prompt`. Unchanged. The hook acts only when `tool_name` is `Agent` and `subagent_type` is `atomic-planner`.
- **Secondary input.** The orchestrator-state checkpoint at `artifacts/orchestration/orchestrator-state.json`, read through `Get-PrdFeatureCheckpointFolder`. Already read today; this change adds one further use of the value it returns.
- **Output.** The existing PreToolUse decision object. Allow is unchanged. Deny carries a `PRD_FEATURE_BLOCKED:`-prefixed reason whose text changes as described above.
- **`Find-PrdFeatureFolderFromPrompt` contract.** Input: one prompt string. Output: a repo-relative folder path normalized to forward slashes with exactly four segments, or a null value. The function performs no I/O and is deterministic for a given prompt and checkpoint value.

#### Required configuration keys and defaults:

None. The hook reads no configuration file and introduces no key. Hook registration at `.claude/settings.json:186` is unchanged.

#### Backward-compatibility expectations:

- **Every prompt form that resolves correctly today continues to resolve to the same folder.** Two-segment truncation is the identity for a prompt citing the folder alone, and reproduces the `.md`-parent result for a prompt citing a file directly inside the folder. The existing test at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:194-196` passes unchanged under truncation; only its `It` name becomes inaccurate, and renaming it is cosmetic.
- **Three assertion sites change intentionally, and the indeterminate branch additionally invalidates seven pre-existing `It` blocks.** The intentional assertion changes are the `Get-PrdFeatureRequiredFile` expectations at lines 250-256 (the fail-closed pair for a null or unrecognized mode) and the marker-absent reason assertion at lines 358-370, which currently matches on `user-story\.md`. Beyond those, seven pre-existing `It` blocks in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` mock the file-existence seam `Get-PrdFeatureFileExistence` but not the issue-content seam `Get-PrdFeatureIssueContent`, and their prompt folders do not exist on disk, so they reach the indeterminate path today and pass only because the current fail-closed set is satisfied by the existence mock. Once the indeterminate branch denies without probing, all seven break. They are: `allows when both spec.md and user-story.md exist in the target folder (prompt path)` (lines 48-55), `blocks when spec.md is missing` (lines 57-70), `blocks when user-story.md is missing` (lines 72-84), `falls back to orchestrator-state.json when prompt has no folder reference` (lines 98-106), `prefers the prompt-derived folder over the checkpoint folder` (lines 108-123), `treats a path ending in .md as a file and uses its parent directory` (lines 125-142), and `accepts backslash separators inside the prompt path` (lines 144-151). Each is repaired by adding the missing work-mode mock so the case reaches the determined-mode path; every one keeps its existing `It` name and its existing assertion intent.
- **The bundled mirror must be textually identical** to the self-hosted copy after the change. This is a hard constraint, not a convention: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` compares UTF-8 text for every file under `.claude/**`, so editing only the self-hosted copy fails CI.
- No public API, CLI flag, config schema, or artifact format changes.

#### Performance constraints (latency/throughput/memory):

No measurable constraint applies and none is introduced. The hook runs once per `atomic-planner` delegation on a single prompt string. Truncation replaces a sort with a linear pass, so the work is bounded by the number of matched tokens, which is small. No new I/O is added: `Get-PrdFeatureCheckpointFolder` is already called on the existing path.

## Assumptions, Constraints, Dependencies

### Assumptions (environment, data, access)

- The feature folder is always the segment immediately below `docs/features/active/`. This is the structural invariant the fix relies on and it holds for every folder in the repository.
- `issue.md` sits at the feature root, not inside a version folder. Verified against the three versioned features that exist under `docs/features/archive/` and `docs/features/completed/`, and corroborated by `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:175`.
- The orchestrator supplies the active feature folder path among its delegation inputs, per `.claude/skills/orchestrate/SKILL.md:298-304`, and names it before citing artifacts nested inside it. This assumption underwrites the earliest-occurrence tiebreak; it is a tiebreak of last resort, so a violation degrades selection rather than breaking the gate.
- The bundled copy is line-for-line identical to the self-hosted copy today (research section 5(a)), so a single edit applied to both keeps them identical.
- PowerShell 7.6.5 on Windows is the execution environment. `[System.Collections.Specialized.OrderedDictionary]` and `System.Collections.Generic.List` are available without any added module dependency.

### Constraints (budget, performance, compatibility)

- **Change budget.** `.claude/rules/powershell.md:37-40` caps a batch at 3 production files and 3 test files, and caps direct mode at 2 production PowerShell files plus corresponding tests. The recommended scope is exactly 2 production files (the hook and its bundled mirror), which fits direct mode without an override. This constraint is what excludes the three sibling hooks.
- **File-size limit.** No production, test, or reusable script file may exceed 500 lines (`.claude/rules/general-code-change.md`; `.claude/rules/powershell.md:35`). The hook is 351 lines and the existing test file is 408.
- **Bundle parity.** Text identity between the self-hosted and bundled hook copies is enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. A one-sided edit fails CI.
- **Coverage.** Line coverage at or above 85% (`.claude/rules/quality-tiers.md`), no regression on changed lines (`.claude/rules/powershell.md:65`). Pester measures command and line coverage only, so no branch-coverage gate applies to PowerShell.
- **No temporary files in tests.** `.claude/rules/general-unit-test.md` prohibits their creation and use. The existing test file satisfies this and the new cases must too.
- **Coverage allow-list.** `CodeCoverage.Path` in `pester.runsettings.psd1` is an explicit per-file allow-list. The hook is already registered at line 202. Any new production file would have to be appended to both copies of that file; the recommended scope creates none.

### External dependencies (services, libraries, releases)

None. The hook has no third-party dependency, no network access, no credential handling, and no external service in its change surface. It reads only local files and stdin.

## Data / API / Config Impact

- **User-facing or API changes:** the two `PRD_FEATURE_BLOCKED:` reason strings change wording and a third decision path (indeterminate marker) is added. There is no programmatic API, no CLI surface, and no consumer that parses the reason text beyond the `PRD_FEATURE_BLOCKED:` prefix, which is preserved.
- **Data or migration considerations:** none. The hook writes no data, persists no state, and reads the orchestrator-state checkpoint read-only through an existing seam. No schema, no artifact format, and no stored file changes.
- **Logging/telemetry updates (if any):** none. The hook emits no log stream; the decision reason is its only output channel.
- **Compatibility notes (CLI flags, config schemas, versioning):** no CLI flag, no configuration key, and no schema is added, removed, or altered. Hook registration in `.claude/settings.json` and the pack manifest at `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` are unchanged, the latter because no new file is added under `.claude/`.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas — cases asserting the same resolved folder for a prompt citing the folder alone, the folder plus a `research/` artifact, the folder plus an `evidence/<kind>/` artifact, and a nested artifact alone. Add a case asserting a `full-bug` feature with `user-story.md` correctly absent is allowed, which is the case that currently cannot pass.
- [x] Integration scenario to retest — the differential above: identical delegations differing only in whether the research path is folder-relative or full must produce the same decision.
- [x] Manual verification notes — confirm the gate still denies when `prd-feature` genuinely has not run: no `spec.md` for a `full-feature` or `full-bug` folder must still block. A fix that resolved the folder correctly but stopped denying would remove the gate's purpose.

### Test framework

Pester, not pytest. The change surface is PowerShell. The two Python parity tests named below are executed as-is and are not modified.

### Test file placement and the 500-line rule

`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` is 408 lines, leaving 92 lines of headroom against the 500-line limit. The new cases are estimated at roughly eight `It` blocks of about ten lines each, or about 80 lines, which would leave under 12 lines of margin. **If the combined total would reach or exceed 500 lines, the new resolution and selection cases go into a companion file** `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`, and the edits to the existing file are limited to the two invalidated assertions. The repository already uses this convention for exactly this reason: `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1` documents itself at lines 8-12 as a sibling of a file with no headroom, and the `enforce-pr-author-skill` test files follow the same pattern.

### Regression tests to add or update

- **Update** `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:250-256` — `Get-PrdFeatureRequiredFile` currently asserts `@('spec.md','user-story.md')` for a null mode and for `'bogus'`. Both expectations change when the fail-closed branch stops returning that pair.
- **Update** `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:358-370` — the marker-absent case currently asserts the reason matches `user-story\.md`. It is replaced by an assertion on the new indeterminate-marker reason, plus a negative assertion that the reason does **not** mention `user-story.md`.
- **Preserve** `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:194-196` — the `.md`-parent case passes unchanged under truncation. Renaming the `It` to describe truncation is optional and cosmetic.
- **Preserve** `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:350-357` — the fail-open regression lock from issue #501 must continue to pass.
- **Run unchanged** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) as the bundle-parity regression gate.
- **Run unchanged** `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` to confirm the deny-payload shape is untouched.

### Unit tests for the fixed behavior and boundaries

Follow the existing seam exactly: dot-source the hook, mock `Get-PrdFeatureIssueContent`, `Get-PrdFeatureFileExistence`, and `Get-PrdFeatureCheckpointFolder`, and drive `Invoke-PrdFeatureBeforePlannerDecision` with an in-line `ConvertTo-Json` envelope. For folder-resolution assertions, use the probed-path capture idiom at lines 109-114 and 126-131. For pure-helper assertions, use the `Context 'Find-PrdFeatureFolderFromPrompt'` idiom at lines 184-197.

1. **Equivalence set — same decision for four prompt forms.** Folder alone; folder plus a `research/` artifact path; folder plus an `evidence/` artifact path under a kind subdirectory; nested artifact alone with the folder never cited. All four resolve to the same folder and produce the same decision.
2. **The differential from the reproduction.** Two delegations differing only in whether the research path is written folder-relative or full repo-relative produce identical decisions.
3. **The case that cannot pass today.** A `full-bug` folder with `issue.md` carrying the marker, `spec.md` present, and `user-story.md` correctly absent is **allowed**, including when the prompt cites a nested research artifact.
4. **Deterministic multi-folder selection.** Checkpoint match wins when the checkpoint folder is among the candidates; earliest occurrence wins when `Get-PrdFeatureCheckpointFolder` returns a null value or a folder not among the candidates. Include a case where the checkpoint-preferred folder occurs later in the prompt than another candidate, so the two rules are distinguished rather than coincidentally agreeing.
5. **Deduplication order.** A prompt citing the same folder several times at different depths yields exactly one distinct candidate.
6. **Indeterminate marker.** Produces the distinct indeterminate-marker reason, names the resolved folder and its `issue.md` path, and does not name `spec.md` or `user-story.md`.
7. **Work-mode-determined paths preserved.** `full-feature` requires both documents; `full-bug` requires `spec.md` only; `minor-audit` requires neither; legacy `full` normalizes to `full-feature`.

### Edge cases and negative scenarios (invalid inputs, missing data, boundary values)

- **Negative case, mandatory:** a `full-feature` folder with no `spec.md` still **denies**, and a `full-bug` folder with no `spec.md` still **denies**. A fix that resolved the folder correctly but stopped denying would remove the gate's purpose.
- A candidate yielding fewer than four segments (for example `docs/features/active/.`) is rejected defensively rather than resolved.
- A prompt with no `docs/features/active/` token at all — resolution returns a null value and the existing no-folder path is unchanged.
- A Windows absolute path such as a repo-rooted path using backslashes — the regex anchors at `docs`, so the match is already repo-relative and truncation applies unchanged.
- Mixed forward and backslash separators within a single token.
- A prompt whose only citation is an `evidence/` artifact three levels below the feature folder.
- Bare `docs/features/active` with no trailing segment — not matched by the regex at all; assert the null-resolution outcome.
- A folder token followed immediately by trailing prose punctuation — assert the current, unchanged behavior so the known limitation is pinned rather than silently altered.

### Error handling and logging verification

- Assert the `PRD_FEATURE_BLOCKED:` prefix is present on every deny reason.
- Assert the missing-prerequisite reason names the resolved feature folder before the remedy text.
- Assert the indeterminate-marker reason names the folder and the `issue.md` path and states marker repair as the remedy.
- Assert the indeterminate-marker reason contains no missing-file list.
- Confirm `Get-PrdFeatureIssueContent` still returns a null value for a non-existent path and when `Get-Content` throws, following the existing cases at lines 259-269 and 265-268.

### Coverage impact and targets for changed lines/modules

- Line coverage at or above 85% overall and for `.claude/hooks/enforce-prd-feature-before-planner.ps1` specifically, read from the per-file figure in the CoverageGutters XML at `artifacts/pester/powershell-coverage.xml`.
- No coverage regression on changed lines relative to the baseline capture.
- No branch-coverage target: Pester does not measure branch coverage, and `.claude/rules/quality-tiers.md` exempts PowerShell from that threshold.
- No file is excluded from measurement. `CodeCoverage.Path` already lists the hook at line 202 and needs no edit because no new production file is created.
- Baseline evidence is captured before any edit and post-change evidence after the toolchain is clean, written under `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/evidence/baseline/`, `.../evidence/regression-testing/`, and `.../evidence/qa-gates/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

### Toolchain commands to run

PowerShell has no type-checking stage (`.claude/rules/powershell.md:17`). Run in order and restart from the first stage on any failure or auto-fix:

1. `mcp__drm-copilot__run_poshqc_format`
2. `mcp__drm-copilot__run_poshqc_analyze`
3. `mcp__drm-copilot__run_poshqc_test`
4. The two Python parity tests, executed unmodified: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.

### Manual validation steps (if required)

None required. The reproduction is a differential over two prompt strings, which is fully expressible as two `It` blocks against `Invoke-PrdFeatureBeforePlannerDecision`; no live orchestration run is needed to demonstrate the fix. A confirmatory live delegation to `atomic-planner` with a prompt citing a nested research artifact is optional and does not gate acceptance.


## Acceptance Criteria

### Folder resolution

- [ ] `Find-PrdFeatureFolderFromPrompt` returns the same four-segment folder path for all four prompt forms: the feature folder alone; the folder plus a `research/` artifact path; the folder plus an `evidence/` artifact path under a kind subdirectory; and a nested artifact path alone with the folder never cited. A passing Pester case exists for each of the four.
- [ ] `Invoke-PrdFeatureBeforePlannerDecision` returns the same decision (allow or deny, and the same reason) for all four prompt forms above, given identical mocked filesystem and checkpoint state.
- [ ] The reproduction differential passes: two delegations differing only in whether the research path is written folder-relative or full repo-relative produce identical decisions.
- [ ] `Sort-Object -Property Length -Descending` no longer appears in `.claude/hooks/enforce-prd-feature-before-planner.ps1` or in its bundled mirror.
- [ ] The `.md`-implies-parent branch is removed, and the existing case at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:194-196` still passes because truncation produces the same result.
- [ ] Candidate deduplication uses an order-preserving collection, not a `[hashtable]`. A Pester case asserts that a prompt citing one folder at three different depths yields exactly one distinct candidate.
- [ ] A matched token that truncates to fewer than four segments is rejected rather than returned as a folder, with a passing case for a degenerate token such as `docs/features/active/.`.

### Deterministic selection among two feature folders

- [ ] When a prompt names two distinct feature folders and the orchestrator checkpoint records one of them, the checkpoint-recorded folder is selected. A passing case exists in which the checkpoint-recorded folder occurs **later** in the prompt than the other candidate, so this rule is distinguished from the earliest-occurrence rule rather than coincidentally agreeing with it.
- [ ] When a prompt names two distinct feature folders and `Get-PrdFeatureCheckpointFolder` returns a null value, or returns a folder that is not among the candidates, the earliest-occurring candidate in the prompt text is selected. A passing case exists for each of those two conditions.

### Work mode and prerequisite sets

- [ ] A `full-bug` folder whose `issue.md` carries the `- Work Mode: full-bug` marker, whose `spec.md` is present, and whose `user-story.md` is correctly absent is **ALLOWED**, including when the delegation prompt cites a nested `research/` artifact. This is the case that cannot pass today.
- [ ] A `full-feature` folder with no `spec.md` still **DENIES**. A passing negative case asserts this.
- [ ] A `full-bug` folder with no `spec.md` still **DENIES**. A passing negative case asserts this.
- [ ] A `full-feature` folder with `spec.md` present and `user-story.md` absent still **DENIES**, naming `user-story.md` as missing.
- [ ] A `minor-audit` folder is allowed with neither `spec.md` nor `user-story.md` present, and legacy `full` is still normalized to `full-feature`.
- [ ] No decision path returns an empty prerequisite set as a fail-closed default. The existing fail-open regression lock at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:350-357` still passes.

### Indeterminate work-mode marker

- [ ] An indeterminate `- Work Mode:` marker — absent, unreadable, or unrecognized — produces a **distinct block reason** that is not the missing-prerequisite reason. A passing case asserts each of the three indeterminate conditions.
- [ ] The indeterminate-marker reason names the resolved feature folder and the `issue.md` path that was probed, and states adding or correcting the `- Work Mode:` marker as the remedy.
- [ ] The indeterminate-marker reason contains no missing-file list and mentions neither `spec.md` nor `user-story.md`. A passing case asserts the absence of `user-story.md` from the reason text.
- [ ] The required-file probe is not executed in the indeterminate branch. A passing case asserts that the `Get-PrdFeatureFileExistence` mock records zero invocations on that path.
- [ ] The indeterminate branch still **DENIES** the delegation.

### Block message

- [ ] The missing-prerequisite reason names the resolved feature folder before any remedy text, so a misresolved path is visible in the headline. A passing case asserts the folder path appears ahead of the prd-feature remedy phrase.
- [ ] Every deny reason retains the `PRD_FEATURE_BLOCKED:` prefix.

### Bundle parity

- [ ] `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` are textually identical after the change.
- [ ] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes without modification to the test.

### Scope containment

- [ ] `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/hooks/enforce-parallel-cohort-barrier.ps1`, `.claude/hooks/enforce-parallel-drift-gate.ps1`, their three bundled mirrors, and their three test files are unmodified by this change.
- [ ] `.claude/hooks/enforce-feature-folder-order.ps1`, its bundled mirror, and `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1` are unmodified.
- [ ] `.claude/settings.json`, its bundled mirror, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and both copies of `pester.runsettings.psd1` are unmodified.
- [ ] `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` passes without modification.
- [ ] Three follow-up issues are filed for the sibling hooks named above, and one follow-up issue is filed for the two `enforce-feature-folder-order.ps1` defects recorded in Scope & Non-Goals.

### Toolchain, coverage, and file size

- [ ] `mcp__drm-copilot__run_poshqc_format` reports no reformatting needed on a clean pass.
- [ ] `mcp__drm-copilot__run_poshqc_analyze` reports zero PSScriptAnalyzer findings.
- [ ] `mcp__drm-copilot__run_poshqc_test` reports zero Pester failures, and all three stages pass in a single consecutive run with no re-fix in between.
- [ ] Line coverage is at or above 85% overall and for `.claude/hooks/enforce-prd-feature-before-planner.ps1`, read from `artifacts/pester/powershell-coverage.xml` and recorded in evidence. No branch-coverage threshold applies, per `.claude/rules/quality-tiers.md`.
- [ ] No coverage regression on changed lines, demonstrated by comparing the post-change per-file figure against the pre-change baseline capture.
- [ ] Baseline, regression, and QA-gate evidence are written under `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/evidence/baseline/`, `.../evidence/regression-testing/`, and `.../evidence/qa-gates/`.
- [ ] Every changed file is under 500 lines, per `.claude/rules/general-code-change.md`. If adding the new cases to `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` (408 lines today, roughly 80 new lines estimated) would bring it to 500 or more, the new cases live in the companion file `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` instead.
- [ ] The change touches at most 2 production PowerShell files, within the direct-mode budget in `.claude/rules/powershell.md:37-40`, with no override requested.

### Documentation

- [ ] The hook's comment-based help (self-hosted lines 14-19 and the bundled equivalent) no longer describes the longest-match and `.md`-parent strategy, and instead states two-segment truncation, the checkpoint-then-earliest-occurrence selection rule, and the known version-folder limitation.

## Risks & Mitigations

### Technical or operational risks

1. **A prompt form that resolves correctly today resolves differently after the change.** Truncation is the identity for a folder-alone citation and reproduces the `.md`-parent result for a file directly inside the folder, so no known form changes. Residual risk is an unenumerated form.
2. **Removing the length sort without a replacement rule makes multi-folder selection non-deterministic.** Deleting the sort while leaving a `[hashtable]` for deduplication would make selection depend on unspecified hashtable enumeration order — a worse defect than the one being fixed, and one that would surface intermittently rather than reproducibly.
3. **Editing only the self-hosted copy.** The bundled mirror is easy to overlook and the failure appears in a Python test rather than in the PowerShell toolchain.
4. **Weakening the gate.** A resolution fix that also relaxed the prerequisite check would remove the gate's purpose while appearing to pass.
5. **The indeterminate branch could be read as failing open.** Skipping the required-file probe superficially resembles removing a check.
6. **Test-file growth past the 500-line limit.** Adding roughly 80 lines to a 408-line file leaves under 12 lines of margin.
7. **The three sibling hooks remain defective after this change ships.** Their false blocks continue until separately fixed.

### Mitigations and rollbacks

1. Retain and re-run every existing case in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`. Only two assertions are intentionally changed, and both are named explicitly in the Test Strategy section; any third existing failure is treated as an unintended behavior change and investigated before proceeding.
2. The selection rule is specified as an acceptance criterion with a distinguishing test case in which the checkpoint-preferred folder occurs later in the prompt, so checkpoint preference and earliest occurrence cannot both be satisfied by accident. The order-preserving-collection requirement is its own acceptance criterion.
3. Bundle parity is both a hard constraint in this spec and a CI gate: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` compares UTF-8 text for every file under `.claude/**`. It is listed in the toolchain commands so it runs before review.
4. Three mandatory negative acceptance criteria assert that a `full-feature` folder with no `spec.md`, a `full-bug` folder with no `spec.md`, and a `full-feature` folder missing `user-story.md` all still deny.
5. The indeterminate branch denies unconditionally. That is asserted as an acceptance criterion, and the rationale — that no prerequisite set is knowable when the mode is unknown, and that the empty set is the only universally satisfiable one and fails open — is recorded in the Proposed Fix section so a later reader does not mistake it for a relaxation.
6. The companion-file convention is specified in advance, with the trigger condition stated numerically, so the decision is made before the limit is reached rather than after.
7. The three sibling hooks are recorded in Scope & Non-Goals with their file paths and line numbers, and filing follow-up issues is an acceptance criterion of this change.

**Rollback.** Revert the change to both hook copies and to the test files. The hook persists no state, writes no artifact, and performs no migration, so the revert is complete and requires no cleanup.

## Rollout & Follow-up

### Release/rollout steps

1. Capture the pre-change PoshQC baseline into `.../evidence/baseline/`.
2. Apply the identical edit to the self-hosted hook and the bundled mirror.
3. Update the two invalidated test assertions and add the new cases, placing them per the companion-file rule.
4. Run the full PowerShell toolchain to a clean consecutive pass, then the two Python parity tests.
5. Capture post-change coverage and QA-gate evidence.
6. Open a pull request against `main`. The hook takes effect for every `atomic-planner` delegation as soon as the change is on the working branch; there is no separate deployment, activation, or version bump.
7. The bundled mirror ships with the next extension release through the existing push-down mechanism. No manifest edit is required.

### Post-fix monitoring or clean-up tasks

- Confirm on the next orchestration run that a delegation prompt citing a full repo-relative research artifact path is allowed, and that the folder-relative workaround recorded in `issue.md` is no longer necessary.
- File three follow-up issues for `.claude/hooks/enforce-epic-wave-barrier.ps1` (line 99), `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (line 150), and `.claude/hooks/enforce-parallel-drift-gate.ps1` (line 196), each citing the fourth-segment fix and the mandatory bundled mirror.
- File one follow-up issue for the two `enforce-feature-folder-order.ps1` defects: the unconditional `user-story.md` demand at line 62, and the hook's inertness against timestamped plan artifacts.
- Optionally file a low-priority issue for the trailing-prose-punctuation token case, which this fix leaves unchanged.
- Consider recording the folder-resolution contract in a `.claude/rules/` file if a second hook is later fixed the same way, so the rule has a single prose home rather than living only in per-hook comment-based help.

### Links

- Issue: https://github.com/drmoisan/drm-copilot/issues/518
- Requirements source: `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/issue.md`
- Research: `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/research/2026-08-23T23-40-prd-feature-gate-folder-resolution-research.md`
- Lifecycle contract: `.claude/skills/feature-promotion-lifecycle/SKILL.md`
- Related prior fix: `docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`
- PRs: to be added when opened.
