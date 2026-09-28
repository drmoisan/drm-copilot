# Research: prd-feature gate resolves a nested artifact as the feature folder (Issue #518)

- **Issue:** #518
- **Feature folder:** `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518`
- **Work mode:** `full-bug`
- **Timestamp:** 2026-08-23T23-40
- **Scope:** read-only investigation; no source, test, or configuration file was modified.

Policy reading order followed per `CLAUDE.md`: `.github/copilot-instructions.md` tone policy (mirrored at `.claude/rules/tonality.md`), `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`.

---

## 1. Exact Current Behavior

All line references are to `.claude/hooks/enforce-prd-feature-before-planner.ps1` (352 lines) unless stated otherwise.

### 1(a) Candidate-path scan — `Find-PrdFeatureFolderFromPrompt`, lines 191-233

Lines 210-215:

```powershell
    # Allow forward or backslash separators inside the matched path token.
    $pattern = 'docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+'
    $matchList = [regex]::Matches($Prompt, $pattern)
    if ($matchList.Count -eq 0) {
        return $null
    }
```

The character class `[^\s"''`]+` is greedy and terminates only on whitespace, a double quote, a single quote, or a backtick. It does not terminate on `/`, so the match consumes the entire nested path including `research/...` or `evidence/<kind>/...`. It also does not terminate on trailing prose punctuation such as `.`, `,`, or `)`.

Lines 217-221 normalize separators and de-duplicate:

```powershell
    $unique = @{}
    foreach ($m in $matchList) {
        $normalized = ($m.Value -replace '\\', '/').TrimEnd('/')
        $unique[$normalized] = $true
    }
```

`$unique` is a `[hashtable]`. PowerShell hashtable key enumeration order is unspecified, so the candidate order entering the sort is not the prompt order.

### 1(b) Longest-match selection — lines 223-224

```powershell
    $candidates = @(@($unique.Keys) | Sort-Object -Property Length -Descending)
    $best = $candidates[0]
```

This is the defect. `docs/features/active/<slug>/research/<ts>-findings.md` (longer) outranks `docs/features/active/<slug>` (shorter), so any nested-artifact citation displaces the folder itself. `Sort-Object` is stable, but the input order is a hashtable enumeration, so a length tie between two distinct folders resolves non-deterministically.

### 1(c) `.md`-implies-parent rule — lines 226-232

```powershell
    # If the longest match ends in .md, treat it as a file and use its parent.
    if ($best -match '\.md$') {
        $parent = $best -replace '/[^/]+\.md$', ''
        return $parent
    }

    return $best
```

This strips exactly one leaf. For `.../<slug>/research/x.md` it yields `.../<slug>/research` — a directory, so the rule stops there and the deeper directory is returned as the "feature folder". The rule is documented in the comment-based help at lines 14-19 ("The longest match wins; when it points at a file (ends with .md), use its parent directory.").

### 1(d) Work-mode marker read — `Get-PrdFeatureIssueContent` (lines 71-95) and `Resolve-PrdFeatureWorkMode` (lines 97-130)

Called from `Invoke-PrdFeatureBeforePlannerDecision` at lines 312-314:

```powershell
    $issueContent = Get-PrdFeatureIssueContent -FeatureFolder $folderNormalized
    $workMode = Resolve-PrdFeatureWorkMode -IssueContent $issueContent
    $modeDetermined = [bool]$workMode
```

`Get-PrdFeatureIssueContent` builds `"$FeatureFolder/issue.md"` (line 84) and returns `$null` when that path is not a leaf file (lines 85-87) or when `Get-Content` throws (lines 89-94). With a mis-resolved folder the probed path is `docs/features/active/<slug>/research/issue.md`, which does not exist, so the function returns `$null` and `Resolve-PrdFeatureWorkMode` short-circuits at lines 116-118. The marker regex is `'(?im)^-\s*Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$'` (line 120), with legacy `full` normalized to `full-feature` (lines 126-129).

### 1(e) Fail-closed prerequisite-set selection and block message — `Get-PrdFeatureRequiredFile` (lines 132-159) and the message construction (lines 325-331)

Lines 153-158:

```powershell
    switch ($WorkMode) {
        'full-feature' { return [string[]]@('spec.md', 'user-story.md') }
        'full-bug' { return [string[]]@('spec.md') }
        'minor-audit' { return [string[]]@() }
        default { return [string[]]@('spec.md', 'user-story.md') }
    }
```

`$null` falls to `default`, so an indeterminate mode demands `spec.md` and `user-story.md`. `Get-PrdFeatureMissingFile` (lines 235-260) probes `"$FeatureFolder/$name"` through the mockable wrapper `Get-PrdFeatureFileExistence` (lines 56-69).

Lines 325-331 build the reason:

```powershell
    $list = ($missing -join ', ')
    if ($modeDetermined) {
        $reason = "PRD_FEATURE_BLOCKED: cannot delegate to atomic-planner before prd-feature outputs are present in '$folderNormalized'. Missing: $list (work mode: $workMode). Invoke the prd-feature subagent first."
    }
    else {
        $reason = "PRD_FEATURE_BLOCKED: cannot delegate to atomic-planner before prd-feature outputs are present in '$folderNormalized'. Missing: $list. Work mode could not be determined from '$folderNormalized/issue.md' (marker absent, unreadable, or unrecognized); failing closed to the strictest prerequisite set (spec.md, user-story.md). Invoke the prd-feature subagent first."
    }
```

The `else` branch is the message quoted in `issue.md` lines 41-47. Both branches end in "Invoke the prd-feature subagent first", which is the misdirecting remedy.

### Functions involved

`Find-PrdFeatureFolderFromPrompt`, `Get-PrdFeatureCheckpointFolder`, `Get-PrdFeatureIssueContent`, `Resolve-PrdFeatureWorkMode`, `Get-PrdFeatureRequiredFile`, `Get-PrdFeatureFileExistence`, `Get-PrdFeatureMissingFile`, `Invoke-PrdFeatureBeforePlannerDecision`.

### Hook activation

Registered as a `PreToolUse` hook on the `Agent` matcher at `.claude/settings.json:186`. It activates only when `subagent_type == 'atomic-planner'` (lines 286-289).

---

## 2. Corrective Rule

### Recommended approach: two-segment truncation plus an explicit distinct-folder selection rule

Replace lines 217-232 with:

1. Normalize each match to forward slashes and `TrimEnd('/')`.
2. Split on `/` and keep the first four segments (`docs`, `features`, `active`, `<folder>`). Reject any candidate that yields fewer than four segments.
3. De-duplicate the truncated candidates **preserving first-occurrence order**. `[hashtable]` must not be used for this; use an ordered collection (`[System.Collections.Specialized.OrderedDictionary]`) or a `List[string]` with a `Contains` guard.
4. Select among distinct candidates by the documented rule in the next subsection.
5. Delete the `.md`-implies-parent branch: `docs/features/active/foo/spec.md` truncates to `docs/features/active/foo` directly, so the rule is subsumed.

### Critical implementation trap

Truncation alone is not sufficient. If the existing `Sort-Object -Property Length -Descending` is retained after truncation, every candidate is the same depth, so length ordering degenerates to "the folder with the longest slug wins" — an arbitrary criterion. The sort must be removed, not merely fed truncated input.

### Case the truncation gets wrong, and the cases it does not

| Case | Verdict |
| --- | --- |
| Prompt cites the folder alone | Correct. Two-segment truncation is the identity here. |
| Prompt cites `<folder>/spec.md` | Correct. Truncation reproduces today's `.md`-parent result. Verified against the existing test at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:194-196`, which still passes. |
| Prompt cites `<folder>/research/<file>.md` or `<folder>/evidence/<kind>/<file>.md` | Fixed. Truncation is depth-insensitive. |
| Prompt cites only a nested artifact and never the folder | Fixed. Truncation recovers the folder from the artifact path. |
| Bare `docs/features/active` or `docs/features/active/` | Not matched by the regex at all. `[\\/]+[^\s"''`]+` requires at least one non-separator character after `active/`, and `[\\/]+` cannot surrender its only slash on backtracking. The new implementation must still reject a fewer-than-four-segment candidate defensively (for example `docs/features/active/.`). |
| Windows absolute path such as `C:\repo\docs\features\active\foo\research\x.md` | Correct. The regex anchors at `docs`, so the match is already repo-relative and truncation applies unchanged. |
| Trailing prose punctuation, for example ``docs/features/active/foo-1.`` at the end of a sentence | Pre-existing, unchanged by truncation. The token becomes `docs/features/active/foo-1.` and probes a folder that does not exist. Out of scope; record only. |
| **Two different feature folders cited in one prompt** | **Needs a documented rule — see below.** |

### Versioned feature folders (`v1/`, `v2/`)

`.claude/skills/evidence-and-timestamp-conventions/SKILL.md:59-68` describes multi-version features. Verified facts:

- **No versioned folder exists under `docs/features/active/` today.** Glob `docs/features/active/*/v[0-9]/**` returns no files.
- Versioned folders exist only under `docs/features/archive/` and `docs/features/completed/`: `docs/features/archive/2026-03-09-push-down-copilot-customizations-84/v1|v2`, `docs/features/completed/2026-04-11-claude-code-architecture-136/v1|v2`, `docs/features/completed/2026-04-26-codex-native-converter-164/v1|v2`.
- In every one of those, `issue.md` sits at the **feature root**, not in the version folder (`docs/features/archive/2026-03-09-push-down-copilot-customizations-84/issue.md`), while `spec.md` and `user-story.md` sit **inside** the version folder. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:175` corroborates this ("current version folder if present; otherwise feature root").

Consequence for a hypothetical versioned **active** feature: two-segment truncation resolves `docs/features/active/<slug>`, finds `issue.md`, and reads the work mode **correctly**. The subsequent `spec.md` probe at `<slug>/spec.md` would fail because `spec.md` lives at `<slug>/v2/spec.md`.

That failure is **pre-existing and unchanged**: today, a prompt citing the folder alone produces the identical outcome. Truncation neither introduces nor fixes it. **The gate does not need to handle versioning for this fix.** Adding version-awareness would be speculative code with no reachable instance in the repository and no test corpus. Record it as a known limitation in the hook's comment-based help instead.

### Two different feature folders in one prompt — a real case that needs a rule

This is legitimate and already exercised. Evidence:

- `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1:299-302` constructs a prompt containing two distinct folders (`docs\features\active\alpha-501\` and `docs/features/active/b`) and asserts the longest-match outcome `alpha-501`.
- `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1:55` shows an epic-mode prompt naming an epic folder token and a child feature folder path.
- A research or plan artifact commonly cross-references prior work in another active feature folder.

Recommended documented rule, in order:

1. If exactly one distinct truncated candidate exists, use it.
2. If more than one exists, prefer the candidate whose normalized value equals the orchestrator checkpoint's `feature-folder` field, read through the existing `Get-PrdFeatureCheckpointFolder` (lines 161-189). This reuses a seam the hook already owns and already mocks.
3. Otherwise, use the **earliest-occurring** candidate in the prompt text. `.claude/skills/orchestrate/SKILL.md:298-304` lists "the active feature folder path" among the items the orchestrator supplies, and the observed delegation form names the folder before citing artifacts inside it.

Under rule 3 the existing drift-gate assertion at `enforce-parallel-drift-gate.Tests.ps1:299-302` still yields `alpha-501` (it occurs first), so no expectation changes; only the `It` name ("returns the longest match") becomes inaccurate.

### Rejected alternative

**Filesystem probe — walk each candidate upward until a directory containing `issue.md` is found.** Rejected for three reasons: it converts a pure string function into an I/O function requiring a new mock seam; it cannot resolve a folder whose `issue.md` is missing or malformed, which is exactly the state the fail-closed branch exists to report; and its result depends on the process working directory, which `.claude/rules/powershell.md:69-76` prohibits tests from relying on.

---

## 3. Fail-Closed Prerequisite Set

### Documented document set per work mode

Source: `.claude/skills/feature-promotion-lifecycle/SKILL.md`, lines 66-70 and 106-111.

| Work mode | `issue.md` | `spec.md` | `user-story.md` | Citation |
| --- | --- | --- | --- | --- |
| `minor-audit` | Required, and must carry an explicit `## Acceptance Criteria` section | Must **not** exist. Appearance is "an integrity failure" | Must **not** exist. Appearance is "an integrity failure" | SKILL.md:68-70, :107, :109 |
| `full-feature` | Required | Expected | Expected | SKILL.md:110 |
| `full-bug` | Required | Expected | "should be absent unless the requirements explicitly justify it" | SKILL.md:111 |

The `- Work Mode:` marker is mandatory in `issue.md` metadata above the first `##` heading for all three modes (SKILL.md:113-117).

### Is the current fail-closed set correct?

No. Evaluated against the table:

- `{spec.md, user-story.md}` (today, line 157) is satisfiable **only** in `full-feature`.
  - For `full-bug` it demands a file the lifecycle says should be absent. It is not strictly forbidden ("unless the requirements explicitly justify it"), so it is satisfiable in principle, but only by creating a file the lifecycle discourages.
  - For `minor-audit` it is **strictly unsatisfiable without an integrity violation**: SKILL.md:109 classifies the appearance of either file as an integrity failure.
- `{spec.md}` only is satisfiable in `full-feature` and `full-bug`, and remains unsatisfiable in `minor-audit` for the same reason.
- The intersection across all three modes is the empty set, which would be failing **open** — the exact defect class `docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/` corrected, as the existing test file records at `enforce-prd-feature-before-planner.Tests.ps1:350-357`.

### Recommendation

**Report "work mode indeterminate" as its own distinct block reason, and do not run the required-file probe in that branch at all.**

Rationale:

1. When the mode is unknown, **no** prerequisite set is knowable, so any set the gate names is a guess that is wrong for at least one mode. Reporting the indeterminate mode as the block cause is the only statement that is true in all three modes.
2. Blocking on the indeterminate mode alone is strictly fail-closed: the delegation is denied.
3. It is satisfiable by a legal repair in every mode — add or correct the `- Work Mode:` marker in `<resolved folder>/issue.md` — whereas both candidate file sets are unsatisfiable in at least one mode.
4. After the folder-resolution fix, an indeterminate mode means a genuinely malformed feature folder (`new_active_feature_folder` always creates `issue.md`; SKILL.md:74-77), so the correct remedy is repairing `issue.md`, not re-running `prd-feature`. The current headline points at the wrong remedy precisely because it conflates the two causes.

The reason string should lead with the resolved folder and the `issue.md` path, and state the marker repair as the remedy, per `issue.md:78`.

If the plan prefers to retain a required-file probe in the indeterminate branch, `spec.md` **only** is the correct choice among the union options (satisfiable in two of three modes rather than one). It is a strict improvement but is not sufficient on its own, which is why the distinct block reason is the operative recommendation.

**A fail-closed set that includes `user-story.md` must not be retained.** It is the specific condition `issue.md:54` identifies as actively harmful: an agent following the message creates a `user-story.md` that makes the folder non-compliant while the gate then passes.

---

## 4. Sibling Hooks With the Same Rule

The selection rule is textually identifiable. A repository-wide search for `Sort-Object -Property Length -Descending` returns exactly eight files — four self-hosted hooks and their four bundled mirrors — and nothing else:

| File | Line | Same rule? | Needs a code edit? |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 223 | Yes | **Yes** — the subject of this issue |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | 99 | Yes | **Yes, same defect** (see below) |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 150 | Yes | **Yes, same defect** |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 196 | Yes | **Yes, same defect** |
| `.claude/hooks/enforce-feature-folder-order.ps1` | — | **No** | **No** |

### `enforce-feature-folder-order.ps1` does **not** need a code edit

It does not infer a feature folder from prompt text. It reads `file_path` from the tool payload (line 120), normalizes separators (line 125), and applies a strict anchored regex at line 87:

```powershell
    return $NormalizedPath -match '(^|/)docs/features/(active|archive)/[^/]+/plan\.md$'
```

`[^/]+` forbids a nested segment, and the path must end in `/plan.md`. There is no scan, no longest-match, and no `.md`-parent rule. The folder is derived by a single anchored strip at line 61 (`$PlanFilePath -replace '/plan\.md$', ''`). It is structurally immune to this defect.

Two adjacent observations about this hook, recorded but **out of scope**:

- It demands `issue.md`, `spec.md`, **and** `user-story.md` unconditionally (line 62), with no work-mode awareness. That would block a `full-bug` plan write, contradicting SKILL.md:111 — a distinct defect from the selection rule.
- Because the regex requires a literal `plan.md`, the repository's prevailing timestamped convention (`plan.2026-08-23T23-22.md` in this very feature folder) does not match, so the hook is inert for timestamped plan artifacts. Neither observation should be folded into #518; both are separate issues.

### The three prompt-scanning siblings carry the identical defect

All three return the **basename** rather than the full path, but the defect is the same and the failure is a false block:

- `enforce-epic-wave-barrier.ps1:60-107` — `Find-EpicWaveBarrierFeatureFolderFromPrompt`. Its own docstring at lines 66-69 states it "Mirrors enforce-prd-feature-before-planner.ps1's Find-PrdFeatureFolderFromPrompt technique". A nested citation resolves the basename to `research`, `Find-EpicWaveBarrierFeatureRecord` (lines 109-148) finds no record, `Test-EpicWaveBarrierDependenciesMerged` returns `$false` (line 173), and `Invoke-EpicWaveBarrierDecision` blocks at line 287.
- `enforce-parallel-cohort-barrier.ps1:112-152` — `Find-ParallelCohortBarrierFeatureFolderFromPrompt`, feeding `Get-ParallelCohortBarrierFolderBasename` (lines 78-110). Same path: no item record, block at line 237.
- `enforce-parallel-drift-gate.ps1:172-201` — `Find-ParallelDriftGateFeatureFolderFromPrompt`. Same path: block at line 307 or a failed record lookup downstream.

For these three, the correct fix is the same truncation followed by taking the fourth segment, which is by definition the basename they already want.

### Scope recommendation, with the constraint that decides it

`.claude/rules/powershell.md:37-40` sets the change budget: "Per-batch cap in all modes: at most 3 production files and 3 test files unless an explicit override has been approved", and "Direct-mode overall scope: up to 2 production PowerShell files (plus corresponding tests)".

Fixing all four hooks means four self-hosted production files (eight counting the mandatory bundled mirrors from section 5). That exceeds both caps and requires either batching or an explicit override.

**Recommended:** scope #518 to `enforce-prd-feature-before-planner.ps1` and its bundled mirror — two production files, within the direct-mode budget — and record the three siblings as a documented follow-up issue citing the line numbers above. This is both budget-compliant and blast-radius-minimal. The alternative (fix all four under an approved override, batched) is technically sound but multiplies the write set as shown in section 8.

A shared helper module for the four hooks was considered and is **not** recommended: it creates a new production file, which forces a new bundled mirror, two `pester.runsettings.psd1` edits, and a new test file, for a net-larger blast radius than the duplication it removes. None of the four hooks is near the 500-line limit (352, 333, 283, 394).

---

## 5. Push-Down Bundle Parity

### (a) Are the bundled copies identical today?

Yes. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` is line-for-line identical to the self-hosted copy across the regions inspected (the defective `Find-PrdFeatureFolderFromPrompt` at bundled lines 191-233 matches self-hosted lines 191-233 exactly, and the message construction at bundled lines 325-331 matches self-hosted lines 325-331 exactly; both files end at line 352). The same holds for the other three hooks — the `Sort-Object` search returns the identical line numbers in both trees (99, 150, 196, 223).

### (b) Is parity enforced?

Yes, by a test.

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, function `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 101-126):

```python
    for relative_path in repo_runtime_files:
        assert (
            relative_path in bundled_files
        ), f"Repo file missing from bundle: {relative_path}"
        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
            REPO_ROOT,
            relative_path,
        ), f"Bundle content differs from repo for: {relative_path}"
```

`SCOPED_ROOTS` is `(Path(".claude"),)` (line 20), so every file under `.claude/**` is in scope. The only exclusions are `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree (lines 113-117, 68-98). `.claude/hooks/**` is fully covered. The comparison is UTF-8 **text** identity (`read_text`, line 49), so line-ending or BOM changes are not distinguished but content changes are.

A second, narrower parity mechanism exists for the PoshQC settings: `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, function `test_poshqc_bundled_module_files_match_repo_root_sources` (lines 63-81), locks `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (listed at line 16) to `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` by the path substitution at lines 56-59.

### (c) Must the fix edit both copies?

**Yes.** Editing only the self-hosted hook fails `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Every self-hosted `.claude/hooks/*.ps1` edit requires the identical edit to its bundled mirror in the same change.

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` already enumerates `enforce-prd-feature-before-planner.ps1`; no manifest edit is needed as long as no **new** file is added under `.claude/`.

---

## 6. Test Surface

### `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` — 408 lines

**Structure.** One `Describe 'enforce-prd-feature-before-planner.ps1'` with nine `Context` blocks:

| Context | Lines |
| --- | --- |
| `tool input parsing` | 10-45 |
| `atomic-planner delegation` | 47-152 |
| `Entrypoint transport` | 154-182 |
| `Find-PrdFeatureFolderFromPrompt` | 184-197 |
| `Resolve-PrdFeatureWorkMode` | 199-235 |
| `Get-PrdFeatureRequiredFile` | 237-257 |
| `Get-PrdFeatureIssueContent` | 259-269 |
| `work-mode aware prerequisite resolution` | 271-348 |
| `fail-closed prerequisite resolution (AC: unable to determine work mode)` | 350-407 |

**Seam.** `BeforeAll` at lines 5-8 resolves the hook path and dot-sources it; the hook's guard at production lines 343-345 (`if ($MyInvocation.InvocationName -eq '.') { return }`) prevents the entry point from executing. The decision is driven by calling `Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw <json>` directly.

**Synthetic payload.** Yes. Every case builds a nested PreToolUse envelope in-line, for example lines 50-53:

```powershell
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'See docs/features/active/2026-05-10-foo-1 for details.' }
                } | ConvertTo-Json -Compress -Depth 5)
```

**Filesystem.** Not touched for behavior assertions. `Get-PrdFeatureFileExistence`, `Get-PrdFeatureIssueContent`, and `Get-PrdFeatureCheckpointFolder` are mocked (lines 49, 58, 88, 273, 299, and elsewhere). Four `It` blocks deliberately exercise the real wrappers against paths chosen not to exist (lines 175-177, 179-181, 260-262, 397-406), and two mock `Test-Path`/`Get-Content` directly (lines 265-268, 373-375). No temporary file is created anywhere, satisfying the prohibition in `.claude/rules/general-unit-test.md` ("Creation and use of temporary files in tests is strictly prohibited").

**Existing cases that must be EDITED by the fix:**

- Lines 250-256 — `Get-PrdFeatureRequiredFile` asserts `@('spec.md','user-story.md')` for `$null` and for `'bogus'`. If the fail-closed branch stops returning that pair, both expectations change.
- Lines 358-370 — the marker-absent case asserts the reason matches `user-story\.md`. Under the recommended distinct-reason design, that assertion is replaced by an assertion on the new indeterminate-mode reason.
- Lines 194-196 — `'strips .md suffix to a folder parent'` still **passes** under truncation (same result). Only the `It` name becomes inaccurate; renaming it to describe truncation is a cosmetic follow-on.

**How to add new cases.** Follow the existing pattern exactly: a new `Context` inside the same `Describe`, each `It` mocking `Get-PrdFeatureIssueContent` and `Get-PrdFeatureFileExistence`, driving `Invoke-PrdFeatureBeforePlannerDecision` with an in-line `ConvertTo-Json` envelope. For folder-resolution assertions, follow the capture idiom at lines 109-114 and 126-131 (accumulate probed paths into `$script:capturedPaths` from the mock, then assert on the joined string). For pure-helper assertions, follow the `Context 'Find-PrdFeatureFolderFromPrompt'` idiom at lines 184-197.

**File-size headroom.** 408 of 500 lines; **92 lines of headroom** against `.claude/rules/general-code-change.md` ("No production code, test code, or reusable script file may exceed 500 lines") and `.claude/rules/powershell.md:35`.

The cases required by `spec.md:122-124` are: folder alone; folder plus a `research/` artifact; folder plus an `evidence/<kind>/` artifact; nested artifact alone; a `full-bug` folder with `user-story.md` correctly absent is allowed; plus the distinct-folder selection rule and the new indeterminate-mode reason. That is roughly eight `It` blocks at about ten lines each, or about 80 lines, leaving under 12 lines of margin.

**Recommendation:** add the new resolution cases in a companion file rather than inflating the existing one. The repository already uses this pattern for exactly this reason — `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1` (92 lines) documents itself at lines 8-12 as a "Sibling of enforce-parallel-cohort-barrier.Tests.ps1, which has no headroom under the 500-line ceiling", and `enforce-pr-author-skill.Payload.Tests.ps1` / `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` follow the same convention. Keep the edits to the existing file limited to the two assertion updates above.

### `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1` — 181 lines

**Structure.** One `Describe` with four `Context` blocks: `tool input parsing` (10-47), `plan.md in a feature folder` (49-124), `Entrypoint (exit code seam, no child process)` (126-165), `Test-IsFeaturePlanPath` (167-180).

**Seam.** Identical dot-source pattern (lines 5-8). Payloads are raw JSON string literals rather than `ConvertTo-Json` hashtables, for example line 52: `'{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'`. `Get-FeatureFolderFileExistence` is mocked; the entry-point exit code is asserted through `Invoke-FeatureFolderOrderEntryPoint`'s `[int]` return value with a `ReadPayload` scriptblock seam (lines 128-136), never by spawning a child process. No filesystem writes.

**Headroom.** 181 of 500; 319 lines. **No change is required to this file**, because the hook it covers needs no code edit (section 4).

### Sibling test files, if the scope is widened

| File | Lines | Headroom |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1` | 258 | 242 |
| `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` | 455 | 45 |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | 437 | 63 |

`tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1:140-147` also dot-sources the prd-feature hook, but asserts only the PreToolUse deny **shape** and mocks `Get-PrdFeatureCheckpointFolder` to `$null`. It is insensitive to both the selection rule and the reason text, so it needs no edit.

---

## 7. Coverage Tooling

**Command.** `mcp__drm-copilot__run_poshqc_test` per `.claude/rules/powershell.md:18`. The tool signature is defined at `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-poshqc.ts:61-80`: required `workspace_root`, optional `scan_folders` array. When `scan_folders` is omitted the scan set resolves from `config/poshqc-scan.json` (`test.scanFolders`), which is `["scripts", "tests/powershell", "tests/scripts"]`.

**Config.** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. The MCP tool runs against **bundled** extension resources, so the file actually consumed is `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`; the two are locked to text parity by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (section 5b), so their contents are identical.

**Output paths** (runsettings lines 12-22):

- Test results: `artifacts/pester/pester-junit.xml`, `OutputFormat = 'JUnitXml'`.
- Coverage: `artifacts/pester/powershell-coverage.xml`, `OutputFormat = 'CoverageGutters'`.
- `CoveragePercentTarget = 0` (line 207), so the run does not fail on percentage; the threshold is enforced by review against the artifact, not by the runner.

**Coverage scope.** `CodeCoverage.Path` (lines 23-205) is an explicit **per-file allow-list**, not a glob. Both hooks named in this issue are already registered:

- `.claude/hooks/enforce-feature-folder-order.ps1` — line 200
- `.claude/hooks/enforce-prd-feature-before-planner.ps1` — line 202

The three prompt-scanning siblings are registered as well: `.claude/hooks/enforce-epic-wave-barrier.ps1` (line 45), `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (line 166), `.claude/hooks/enforce-parallel-drift-gate.ps1` (line 171).

**Consequence for the plan.** No `pester.runsettings.psd1` edit is required **provided the fix creates no new production file**. If a new file is created (a shared helper module, for example), it must be appended to `CodeCoverage.Path` in **both** runsettings copies, because the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` forbids leaving a production file outside the denominator, and an allow-list omission has exactly that effect.

**Thresholds.** Line coverage `>= 85%` applies. Per `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md:64`, Pester reports command (instruction) and line coverage only; **there is no PowerShell branch-coverage gate**. Coverage regression on changed lines is a blocking finding (`.claude/rules/powershell.md:65`).

**Baseline and post-change capture.** Run `mcp__drm-copilot__run_poshqc_test` before any edit and again after the toolchain is clean, and copy `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` findings into evidence artifacts under `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/evidence/baseline/` and `.../evidence/qa-gates/` respectively, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Read the per-file line-coverage figure for `.claude/hooks/enforce-prd-feature-before-planner.ps1` out of the CoverageGutters XML for the changed-lines comparison.

---

## Automation Feasibility

**No step of the eventual fix requires human interaction.** Evidence:

- The entire change surface is PowerShell source files, PowerShell Pester test files, and (conditionally) a PowerShell data file. All are editable with `Write`/`Edit`.
- The full toolchain is available as MCP calls with no interactive prompt: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` (`.claude/rules/powershell.md:13-20`). Type checking is explicitly not applicable to PowerShell (`.claude/rules/powershell.md:17`).
- The two parity gates are Python tests runnable non-interactively: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
- There is no third-party UI, no web console, no credential entry, no marketplace or publish step, and no external service in the change surface. The hooks read only local files and stdin.
- Verification is achievable entirely through unit tests: the reproduction in `issue.md:25-31` is a differential over two prompt strings, which is expressible as two `It` blocks against `Invoke-PrdFeatureBeforePlannerDecision`. No live orchestration run is required to demonstrate the fix.
- One human decision is required **before** implementation, not during it: whether to widen scope to the three sibling hooks under a change-budget override (section 4). That is a planning choice recorded in the plan, not an interactive step inside execution.

---

## 8. Exact File Set the Fix Will Write

Repo-relative literal paths. No globs, no placeholders, no `<`, `>`, `$` interpolation markers, no `%`.

### Certain — recommended scope (prd-feature hook only)

1. `.claude/hooks/enforce-prd-feature-before-planner.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
3. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
4. `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`
5. `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/plan.2026-08-23T23-22.md`

Item 2 is not optional; it is forced by the parity test cited in section 5b. Items 4 and 5 are the feature's own planning artifacts: `spec.md` sections `## Proposed Fix`, `## Test Strategy`, and `## Scope & Non-Goals` are currently empty (spec.md lines 65-133), and the plan file already exists and will be revised.

### Conditional on the test-headroom decision (section 6)

6. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` — **created** if the new resolution cases are placed in a companion file rather than inflating item 3 past the 500-line limit. Recommended.

### Conditional on widening scope to the three sibling hooks (section 4, requires a change-budget override)

7. `.claude/hooks/enforce-epic-wave-barrier.ps1`
8. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1`
9. `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1`
10. `.claude/hooks/enforce-parallel-cohort-barrier.ps1`
11. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1`
12. `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`
13. `.claude/hooks/enforce-parallel-drift-gate.ps1`
14. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1`
15. `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`

### Conditional on creating a new shared production file (NOT recommended, section 4)

16. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
17. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

Both are required together if and only if a new production PowerShell file is introduced, per the Coverage Exclusion Policy and the parity test in section 5b. Under the recommended approach neither is touched.

### Explicitly NOT in the write set

- `.claude/hooks/enforce-feature-folder-order.ps1` — does not carry the rule (section 4).
- `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1` — no behavior change to cover.
- `.claude/settings.json` and its bundled mirror — hook registration is unchanged.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — already enumerates the hook; unchanged unless a new `.claude/**` file is added.
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` — shape-only assertions, insensitive to this change.
- Any file under `.codex/` — the `Sort-Object -Property Length -Descending` search returns no `.codex` file; there is no Codex mirror of any of the four hooks.
- Any `.claude/rules/*.md` file — no rule file documents the folder-resolution contract; the only prose statement of it is the hooks' own comment-based help, which is edited in place as part of items 1, 2, 7, 8, 10, 11, 13, and 14.

### Evidence artifacts (outside the enumerated list)

Baseline, regression, and QA-gate evidence will be written under `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/evidence/baseline/`, `.../evidence/regression-testing/`, and `.../evidence/qa-gates/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Their filenames carry execution-time ISO-8601 timestamps and cannot be enumerated in advance, so they are recorded here as directories rather than as concrete path tokens.
