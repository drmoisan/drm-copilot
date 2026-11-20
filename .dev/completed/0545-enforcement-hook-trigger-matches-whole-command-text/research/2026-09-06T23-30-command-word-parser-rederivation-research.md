# Command-word parser re-derivation research (issue #545, epic child E)

- **Issue:** #545 (widened to fold in #591)
- **Epic:** `cleanup-merged-worktrees-hardening`, child E
- **Branch:** `bug/enforcement-hook-trigger-matches-whole-command-text-545-r2`
- **Base:** `origin/epic/cleanup-merged-worktrees-hardening-integration`, HEAD `be722eba`
- **Timestamp:** 2026-09-06T23-30
- **Author:** task-researcher
- **Supersedes for citation purposes:** `research/2026-08-25T09-45-enforcement-hook-trigger-matches-whole-command-text-research.md` (read for context; its design remains the starting point, its tree citations are re-derived here)

This document re-derives every tree citation in the 2026-08-25 feature folder against the current
tree, records two live 2026-09-06 reproductions, extends the defect inventory to the gate hooks,
and proposes a concrete shared-parser contract for the two downstream epic children.

**Measurement note used throughout.** Line counts below are physical-line enumerations produced by
ripgrep over the file (equivalent to `@(Get-Content -LiteralPath $path).Count`, which is what the
repository's own 500-line cap tests use — see
`tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1:129` and
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:93`). The epic brief's figures were
taken with `wc -l`, which counts newline characters and therefore reports one fewer for a file with
no terminating newline. Both figures are given where they differ; the `Get-Content` figure is the
one the gates evaluate.

---

## Section 0 — Ground-truth line counts (verified 2026-09-06)

| File | Epic brief (`wc -l`) | Re-derived (`Get-Content` count) | Headroom under 500 |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 418 | **419** | 81 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 280 | **281** | 219 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 451 | **452** | 48 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 228 | **228** | 272 |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 274 | **275** | 225 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 489 | **490** | **10** |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 | **349** | 151 |
| `.claude/lib/hook-payload/HookPayload.psm1` | 496 | **496** | **4** |

**Confirmed and reported as requested:** the preimplementation gate has **10 lines of headroom**
under the cap as the cap test measures it (11 by `wc -l`). This is tighter than the epic brief
implied and is the single hardest size constraint in the change: the gate cannot absorb a new
dot-source line plus a reworked `Test-ImplementationCommand` body without a relocation.

Additional counts re-derived in the same pass, not in the brief:

| File | Lines | Note |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 480 | New since 2026-08-25 (issue #554); 20 lines headroom |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 312 | |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | (see Section C.7) | Ninth defect-class site, not in any prior scope list |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 256 | |
| `.claude/hooks/validate-bash.ps1` | 230 | |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 495 | **5 lines headroom** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 477 | |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 | |
| `.codex/hooks/enforce-promotion-mcp-only.ps1` | 261 | |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 140 | |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 151 | |
| `.codex/hooks/validate-bash.ps1` | 185 | |

The `.codex` preimplementation gate at 495 lines is the binding size constraint on the Codex side —
five lines. Any Codex-side rework must relocate code out of that file first.

### Mirror-tree size

`.claude/lib/` currently holds **39** files across nine directories (`bash` 11, `blast-radius` 7,
`orchestrator-state` 11, `mermaid` 4, `codex-routing` 2, `discovery-validation` 1, `hook-payload` 1,
`model-routing` 1, `requirements` 1). The mirror
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/` holds the same 39 paths,
one-to-one, including the `bash/` subtree. The epic brief's figure of 38 is one low; the mirror
relation itself is intact.

---

## Section A — Re-derivation of `plan.2026-08-25T08-13.md`

Source: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md` (306 lines).

Verdict key: **VALID** = correct at HEAD `be722eba`; **DRIFTED** = the referent still exists but the
cited value has changed; **STALE** = the statement was true on 2026-08-25 and is no longer true;
**NOT-FOUND** = the referent does not exist.

| Citation (as written in plan) | Location in plan | Current tree state | Verdict | Corrected value |
| --- | --- | --- | --- | --- |
| `docs/.../545/spec.md` | Sources, L13 | Exists, 886 lines | VALID | — |
| `docs/.../545/issue.md` | Sources, L14 | Exists, 189 lines | VALID | — |
| `research/2026-08-25T09-45-...-research.md` | Sources, L15 | Exists, 368 lines | VALID | — |
| "baseline Pester is green at 151 and 142 passing across the relevant suites" | L19 | Not re-runnable as stated; suite composition changed (two new #554 suites added) | STALE | Re-measure; do not reuse |
| `artifacts/pester/pester-junit.xml` root `testsuites` with `tests`/`errors`/`failures`/`disabled`/`time`, no `passed`, no root `skipped` | L87–91 | Contract unchanged (Pester JUnitXml writer); not re-executed in this research | VALID (unverified by execution) | — |
| `artifacts/pester/powershell-coverage.xml` JaCoCo-shaped, root `report`, no `coverage` element, no `line-rate` | L95–98 | `CodeCoverage.OutputFormat = 'CoverageGutters'` still set at `pester.runsettings.psd1:21` | VALID | — |
| "`CodeCoverage.Path` … The allow list holds **83 entries**" | L102 | List has grown since 2026-08-25; issue #554 added `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (L214) and `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (L139) among others | **DRIFTED** | Re-derive with `(Import-PowerShellDataFile scripts/powershell/PoshQC/settings/pester.runsettings.psd1).CodeCoverage.Path.Count`; do not reuse 83 |
| "the whole-allow-list aggregate measured approximately **61.6%** at preflight" | L102, repeated L301 | The plan's own baseline artifact `evidence/baseline/baseline-selfhosted-coverage.2026-08-25T13-37.md` L90–91 records report-level LINE coverage of **96.1433%** (missed 267 / covered 6656) | **STALE — internally contradictory** | The plan contradicts its own evidence. Re-measure; neither figure may be carried forward |
| "zero entries under `extensions/drm-copilot/resources/`" in `CodeCoverage.Path` | L100 | Confirmed: no entry in the list begins with `extensions/` | VALID | — |
| "`.claude/rules/powershell.md` sets a direct-mode ceiling of 2 production PowerShell files and a per-batch cap of 3 production + 3 test" | L106 | Rule file present; ceiling not re-read in this pass | VALID (unverified) | — |
| "This change touches 16 production PowerShell copies plus 4 registration files" | L106 | Copy set is correct for the *old* scope; the widened scope adds at least the six Section C hooks plus their Claude bundle mirrors | **STALE** | Re-derive from the widened scope (Section H below) |
| `.claude/hooks/hook-command-scanner.ps1` (new) | B1, [P4-T1] | Does not exist | NOT-FOUND (as designed; never created) | Superseded — see Section E recommendation |
| `.codex/hooks/hook-command-scanner.ps1` (new) | B1, [P4-T2] | Does not exist | NOT-FOUND (as designed) | Superseded |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` "sits at 494 lines" | L129, L222, L280 | **494** lines | VALID | — |
| `$script:SharedModuleNames` array "on line 30" of that file | [P5-T5] | Line 30 exactly: `$script:SharedModuleNames = @('codex-pretooluse-file-mapping.ps1', 'enforce-orchestration-preimplementation-gate-helpers.ps1')` | VALID | — |
| "the array contains three members" after the append | [P5-T5] | Currently **two** members, so an append yields three | VALID | — |
| "`.codex/hooks/enforce-promotion-mcp-only.ps1` … outside the `CodeCoverage.Path` list" | [P0-T8], [P5-T8] | Still absent from the list | VALID | — |
| Five in-scope files with a coverage baseline: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/…`, `.claude/hooks/enforce-promotion-mcp-only.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1` | [P0-T8] | All five present in `CodeCoverage.Path` at lines 206, 131, 205, 220, 34/47 | VALID | — |
| "`.claude/hooks/enforce-pr-author-skill.ps1`" listed once in the coverage list | implied by [P0-T8] | Listed **twice**, at lines 34 and 47 | DRIFTED (pre-existing duplicate) | Any list-length arithmetic must account for the duplicate |
| `.claude/state/` "is fully gitignored and holds no tracked file"; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` "is expected to fail at baseline" | [P0-T9], [P10-T2], [P11-T5] | `.claude/state/` **does not exist** in this worktree (glob returns no files) | **STALE** | The baseline failure this gate depends on may not reproduce here. [P0-T9]'s "rerun until the pre-existing failure is observed" is unsatisfiable if the directory is never populated. The [P11-T5] zero-delta gate must be re-derived, not reused |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | many | Exists, 451 lines | VALID | — |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` helpers dot-source "on line 14" | [P6-T1] | Line 14 exactly: `. (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-helpers.ps1')` | VALID | — |
| (not cited) a second dot-source | [P6-T1] context | Line 20 now also dot-sources `enforce-orchestration-preimplementation-gate-modes.ps1` (issue #554, added after the plan) | **DRIFTED — new referent** | The gate now dot-sources two siblings, not one |
| `$implementationCommandPatterns` "five entries", byte-unchanged | [P6-T1], [P6-T2] | Five entries at lines 128–134, unchanged text | VALID | — |
| `Test-ImplementationCommand` | [P6-T1] | Present at lines 118–151 | VALID | — |
| `Test-ImplementationPath`, `Test-OrchestrationReady`, "the delegation classifiers" | [P6-T2] | `Test-ImplementationPath` L83, `Test-OrchestrationReady` L217, `Test-ImplementationDelegation` L196, `Test-PreparationModeDelegation` L153 | VALID | — |
| Codex gate's "two upstream `apply_patch` marker legs … upstream of the pattern loop" | [P6-T7], [P6-T8] | Not re-verified line by line in this pass | VALID (unverified) | — |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` `It` `denies a message-body payload that merely contains the staging literal` | [P3-T3], "single intended assertion reversal" | Present at line **246**, inside Context at line 245 | VALID | — |
| Codex analogue `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, same `It` | [P3-T7] | Present at line **250**; file is 271 lines | VALID | — |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | [P6-T5] | Exists, **461** lines | VALID | — |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | [P6-T5] | Exists, 223 lines | VALID | — |
| Phase 6 suite list (four Claude suites) | [P6-T5] | **Incomplete now**: `enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` (159 lines) and `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` (491 lines) were added by issue #554 and are not named | **STALE** | Six Claude suites now cover this hook |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | [P6-T11] | Exists, 242 lines | VALID | — |
| (not cited) Codex `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | [P6-T11] | Exists, 332 lines; added by #554 | **STALE** | Codex suite list is incomplete |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` "line 101 carries the adjacency-requiring expression for the `gh` issue-creation subcommands" | Phase 1 preamble, L160 | Line 101 exactly: `if ($CommandText -match '(?i)\bgh\s+issue\s+(?:create\|new)\b') {` | VALID | — |
| Promotion hook "four forbidden-token literals" | [P7-T2] | Lines 86–91: `new-potential-entry.ps1`, `new_potential_bug_entry`, `potential_to_issue`, `new_active_feature_folder` | VALID | — |
| Promotion hook "`gh` API POST lookahead conjunction" | [P7-T2] | Line 110 | VALID | — |
| `.codex/hooks/enforce-promotion-mcp-only.ps1` "the hook is 261 lines" | [P7-T8] | **261** lines | VALID | — |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` "`$isPrCreate` and `$isPrEdit` trigger decision at lines 170 and 171" | [P8-T1] | Lines 170 and 171 exactly | VALID | — |
| "body-file and inline-body flag parsing" (implicitly 177/178) | [P8-T1], [P8-T3] | Lines 177 and 178 | VALID | — |
| `.claude/hooks/enforce-pr-author-skill.ps1` "existing helpers dot-source on line 148" | [P8-T2] | Line 148 exactly: `. (Join-Path $PSScriptRoot 'enforce-pr-author-skill-helpers.ps1')` | VALID | — |
| (not cited) a second dot-source in that file | [P8-T2] context | Line 144: `. (Join-Path $PSScriptRoot 'enforce-pr-author-skill.epic-base-branch.ps1')` | DRIFTED — new referent for scope | That sibling carries a ninth instance of the defect (Section C.7) |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | [P8-T5] | Exists, 447 lines | VALID | — |
| `…Payload.Tests.ps1` | [P8-T5] | Exists, 103 lines | VALID | — |
| `…OrchestratorStatePreflight.Tests.ps1` | [P8-T5] | Exists, 104 lines | VALID | — |
| `…epic-base-branch.Tests.ps1` | [P8-T5] | Exists, 113 lines | VALID | — |
| `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` | [P7-T5] | Exists, 214 lines | VALID | — |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | [P9-T3] | Exists, 500 lines (**at the cap**) | VALID + **at-cap warning** | Cannot absorb a new `It`; a new scenario needs a sibling file |
| "the new helper inside its scan set" | [P9-T3] | The guard scans `.claude/hooks` and `.claude/lib` recursively, excluding `.claude/lib/bash/*` (lines 39–42, 66) | VALID | A new `.claude/lib/<dir>/*.psm1` is automatically in scan scope |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | [P5-T3] | Exists; `.claude/lib/**` entries at lines 113–158 | VALID | — |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | [P5-T4] | Exists | VALID | — |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` "carries exactly one `CodeCoverage.Path` list; the other `Path` key is the test-discovery set under `Run`" | [P5-T8] | Confirmed: `Run.Path` at L3, `CodeCoverage.Path` at L23 | VALID | — |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | [P5-T9] | Exists and is text-parity-pinned to the repo copy by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | VALID + **new constraint** | Edits must be textually identical, not merely equivalent |
| `scripts/powershell/PoshQC/PoshQC.psd1` + `Invoke-PoshQCTest -SettingsPath …` | [P0-T8], [P9-T9], [P11-T4] | `Invoke-PoshQCTest` defined at `scripts/powershell/PoshQC/PoshQC.Testing.psm1:151`; `-SettingsPath` parameter at L156 | VALID | — |
| Out-of-scope list: `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`, `validate-bash.ps1` | L134, [P9-T6], [P10-T1] | All five files exist | VALID as paths, **STALE as scope** | The epic widens #545 to cover the first three; the list is now a *scope* statement that must be rewritten |
| `docs/features/potential/2026-08-25-hook-family-structural-command-classification-followup.md` | [P10-T1] | Not created (Phase 10 never ran) | NOT-FOUND | Superseded by folding #591 into #545 |
| `docs/features/potential/2026-08-25-gitignored-claude-state-files-fail-push-down-contract-test.md` | [P10-T2] | Not created | NOT-FOUND | See the `.claude/state/` STALE row above |
| "the plan holds 113 tasks in total" | L71 | Task IDs [P0-T1]–[P11-T8]; not recounted here | Unverified | Do not reuse without recount |
| Checked-off tasks [P0-T1]–[P0-T8], [P0-T10], [P1-T1]–[P1-T7] | Phase 0/1 checkboxes | Phase 1 edits [P1-T1]–[P1-T7] are marked `[x]` but `spec.md` **Version is still 1.0** (L8) and no `### D10 —` heading exists in `spec.md` at the reported location… | **See note below** | — |

**Note on the Phase 1 checkboxes.** `spec.md` line 537 *does* carry
`### D10 — Promotion-hook gh relocation is IN SCOPE …`, and lines 821–824 carry the appended
acceptance criterion, so [P1-T1] through [P1-T7] did land. However `spec.md` line 8 still reads
`**Version:** 1.0` and line 6 `**Last Updated:** 2026-08-25`, while [P1-T13] (which bumps to 1.1)
is unchecked. The spec is therefore in a half-revised state: content edits applied, version marker
not. Any downstream reader keying off the version field will be misled.

### Section A summary

Citations re-derived: **58**. Of these — **43 VALID**, **7 DRIFTED**, **5 STALE**,
**3 NOT-FOUND**. The highest-consequence findings are:

1. The 83-entry coverage-list count and the 61.6% aggregate are both unusable; the second
   contradicts the plan's own baseline artifact.
2. `.claude/state/` does not exist here, so the plan's entire push-down baseline/final gate pair
   ([P0-T9] / [P11-T5]) rests on a failure that may not reproduce.
3. Issue #554 added a third production sibling (`-modes.ps1`, 480/477 lines) and three test suites
   to the preimplementation-gate surface after the plan was written. The plan's file inventories,
   suite lists, and batch table are all short by those files.
4. `enforce-pr-author-skill.epic-base-branch.ps1` carries the same defect and appears in no scope
   list anywhere.

---

## Section B — Re-derivation of `spec.md`

Source: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`, **886** lines (count confirmed).

| Citation (as written in spec) | Location in spec | Current tree state | Verdict | Corrected value |
| --- | --- | --- | --- | --- |
| `**Version:** 1.0` / `**Last Updated:** 2026-08-25` | L6, L8 | D10 and AC #25 are present in the file, so version 1.1 content landed | **DRIFTED (self-inconsistent)** | Should read 1.1 / a later date |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` "and the three mirrored copies under `.codex/hooks/` and `extensions/drm-copilot/resources/`" | L34–36 | All four exist | VALID | — |
| Five trigger patterns quoted verbatim | L94–98 | Byte-identical to `enforce-orchestration-preimplementation-gate.ps1` lines 129–133 | **VALID** | — |
| `(^\|\s)` "anchors only to a whitespace boundary" | L101 | Confirmed by inspection | VALID | — |
| Quoted #539 D8 text | L125–130 | Byte-identical to `…-539/spec.md` line 186 | **VALID** | — |
| `hook-command-scanner.ps1` (the proposed helper) | L135 and passim | Does not exist | NOT-FOUND (never built) | Superseded by Section E |
| Non-goal list naming `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`, `validate-bash.ps1` | L154–158 | All exist | VALID as paths, **OBSOLETE as scope** | Widened scope pulls three in; see "Obsolete design decisions" below |
| "`.claude/skills/epic-plan/SKILL.md` and `.claude/skills/parallel-plan/SKILL.md` — verified to describe only the #539 exemption" | L172–173 | Not re-verified in this pass | Unverified | Re-verify before reuse |
| `Test-ExemptOrchestrationStagingCommand`, `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken` in `enforce-orchestration-preimplementation-gate-helpers.ps1` | L195–199 | Present at lines 296, 39, 91 respectively | **VALID** | — |
| "It does not handle heredocs, subshell/group openers, `$(...)`, or env-assignment prefixes, and it is confined to the allow side" | L199–201 | Confirmed by full read (Section D) | **VALID** | — |
| `git -C <dir> add`, `git --git-dir=<x> commit`, `git --work-tree=<x> add`, `npx --yes prettier`, `gh --repo <o/r> pr create`, `gh -R <o/r> issue create` "all pass by non-match" | L189–191 | Confirmed against the current regexes | VALID | — |
| Wrapper carve-out set of 14 members | L292–297 | Design proposal, no tree referent | n/a | — |
| "pinned today by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` **line 140**" | L300–301 | Line 140 exactly: `'pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"'` | **VALID** | — |
| Per-hook table: preimplementation gate "(4 copies)" | L354 | 4 copies confirmed | VALID | — |
| Per-hook table: promotion hook "(4 copies)" | L355 | 4 copies confirmed | VALID | — |
| Per-hook table: `enforce-pr-author-skill-helpers.ps1` "(2 copies, Claude side only) … There is no `.codex` copy" | L356, L508 | Confirmed: no `.codex/hooks/enforce-pr-author-skill*` exists | VALID | — |
| Quoted regex `\bgh\s+issue\s+(?:create\|new)\b` | L355, L549 | Byte-identical to `enforce-promotion-mcp-only.ps1:101` | **VALID** | — |
| Quoted regexes `\bgh\s+pr\s+create\b` / `\bgh\s+pr\s+edit\b` | L356 | Match `enforce-pr-author-skill-helpers.ps1:170-171` modulo the `(?i)` prefix present in the source | VALID (prefix omitted in the quote) | Source spelling is `'(?i)\bgh\s+pr\s+create\b'` |
| "the `gh api … POST` lookahead conjunction" | L358–361 | Present at `enforce-promotion-mcp-only.ps1:110` | VALID | — |
| `` `git${IFS}add` ``, `\git add` ungated | L388, L416 | Not re-measured | Unverified | — |
| D7: `codex-pretooluse-file-mapping.ps1` "already establishes the unprefixed form in the `$script:SharedModuleNames` contract array (`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` **line 30**, verified)" | L452–454 | Line 30 exactly | **VALID** | — |
| D7 constraints for a `$script:SharedModuleNames` member: entrypoint-free, parses, ≤500 lines, no `$env:CLAUDE_`, byte-identical Codex pair, listed in Codex core manifest | L459–462 | Each maps to a named `It` in the legacy suite: L93 (parse + 500 cap), L111 (byte identity), L119 (stdin), L127 (`$env:CLAUDE_`), L134 (pack manifest) | **VALID** | — |
| D8 table: `…-539/spec.md` **line 128** = D4 rule table row 14 | L478 | Line 128 is row 14, text matches | **VALID** | — |
| D8 table: **line 150** = deny-map `allow-by-non-match` row | L479 | Line 150 exactly | **VALID** | — |
| D8 table: **line 153** = deny-map heredoc/message-body row | L480 | Line 153 exactly | **VALID** | — |
| D8 table: **lines 184–186** = design decision D8 | L481 | L184 heading, L186 body | **VALID** | — |
| D8 table: **line 278** = Rollout & Follow-up "Known deferrals" | L482 | Line 278 exactly | **VALID** | — |
| D9 pair table: Claude canonical ↔ Claude bundle "**Content-equal**"; Codex canonical ↔ Codex bundle "**Byte-identical**" | L493–498 | Correct and materially important — see Section H | **VALID** | — |
| D9: Codex byte-identity `It` "at **line 111**" | L514 | Line 111: `It 'keeps the canonical hooks byte-identical to their bundled copies'` | **VALID** | — |
| D9: Codex pack-manifest `It` "at **line 134**" | L515 | Line 134: `It 'lists every shared hook module in the core pack manifest'` | **VALID** | — |
| D9 registration 3 "(line 30)" | L527 | Line 30 | **VALID** | — |
| D9: "`legacy-codex-hook-contracts.Tests.ps1` is at **494** of 500 lines" | L533 | 494 | **VALID** | — |
| D10: promotion hook "**line 101**" | L548 | Line 101 | **VALID** | — |
| Test Strategy: gate suite "at **461** lines"; legacy codex "at **494**" | L636–637 | 461 and 494 | **VALID** | — |
| Regression-first: CommandExemption `It` at "**lines 245–266**" | L645 | Context opens L245, `It` L246–265, Context closes L266 | **VALID** | — |
| "the Codex analogue sits at **approximately line 249**" | L647 | Actual line **250** | VALID (within "approximately") | 250 |
| Deny preservation: "existing Claude suite denials … (**lines 112–149**)" | L690, L758 | Lines 112–149 hold four denial `It` blocks ending at 149 | **VALID** | — |
| Deny preservation: Codex classification table "(**lines 348–358**)" | L692, L758 | `It 'classifies <Label> as implementation command <Expected>' -ForEach @(` begins at line 348 | **VALID** | — |
| Deny preservation: "#539 D4 rows 14a–14d chained relocating denials (**lines 219–228** on the Claude side)" | L695 | Rows 14a–14d are at lines **222–225**. Lines 219–228 span rows 12d through 15c | **DRIFTED / incorrect** | **lines 222–225** |
| Risks: "the two existing gate suites are at **461 and 271**" | L852 | Claude gate suite 461 (valid); the Claude CommandExemption suite is now **267**, the Codex command-exemption suite is **271** | **DRIFTED / ambiguous** | Name the file: Claude CommandExemption = 267; Codex command-exemption = 271 |
| Links: `…-539/spec.md`, research path, issue URL | L882–886 | All exist | VALID | — |

### Section B summary

Citations re-derived: **41**. Of these — **31 VALID**, **4 DRIFTED**, **1 NOT-FOUND**,
**5 unverified/deferred**. Notably, every quoted regex literal and every `spec.md`-to-`spec.md`
line citation into issue #539's document is still correct. The two genuine numeric drifts are the
`219–228` span (should be `222–225`) and the `461 and 271` pair (should name its files).

### Design decision D8, quoted in full

The delegation prompt asks for "design decision D8 … since it records the fail-open constraint".
There are two distinct D8s and they must not be conflated.

**(a) The #545 spec's own D8**, `spec.md` lines 467–484, which is *not* about fail-open — it is
the additive-annotation rule:

> ### D8 — Issue #539's spec is annotated additively, never rewritten (orchestrator decision, settled)
>
> Its historical rule table, deny map, and design decision D8 are a closed feature's record. Each
> affected row and decision receives a supersession note pointing at issue #545; **nothing is edited
> in place**.
>
> The affected locations in
> `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md`:
>
> | Location | Current statement | Required annotation |
> | --- | --- | --- |
> | Line 128 — D4 rule table, row 14 | "…passes by non-match — a pre-existing trigger limitation recorded with D8, unchanged by this fix" | Additive note: the bare relocating spelling now classifies as of issue #545; the NEVER-EXEMPT disposition is unchanged. |
> | Line 150 — deny map, `allow-by-non-match` row | Records allow-by-non-match as current behavior | Same additive supersession note. |
> | Line 153 — deny map, heredoc/message-body row | Records the heredoc deny as current behavior | Additive note: a heredoc mention in a non-wrapper segment now allows as of issue #545; a heredoc feeding a wrapper still denies. |
> | Lines 184–186 — design decision D8 | Defers the trigger scoping as a fail-open change | Additive note: resolved by issue #545 with a masked-trigger model that does not scope to segment-leading command names; see this spec's D3. |
> | Line 278 — Rollout & Follow-up, "Known deferrals" | Records the deferral | Additive note: the deferral is closed by issue #545. |
>
> This decision is settled and is not to be reopened.

**(b) Issue #539's D8**, the actual fail-open constraint, at `…-539/spec.md` lines 184–186 and
quoted verbatim inside the #545 spec at lines 125–130. Both copies are byte-identical to the
source, re-verified:

> ### D8 — Whole-command-text over-match: out of scope, with reason
>
> Recorded under Scope & Non-Goals. The trigger regex is not narrowed in this fix because trigger
> scoping to a segment-leading command name is a fail-open change (wrapper bypasses via `xargs`,
> nested shells). D3 bounds the practical interaction. The same trigger property produces an
> under-match in the opposite direction: a relocating spelling that separates the command name from
> the subcommand is never classified at all and passes by non-match; this direction is part of the
> same follow-up candidate. Follow-up candidate for a separate issue; not filed here.

This is the constraint Section I must answer.

### Design decisions now obsolete or needing amendment under the widened scope

| Decision | Status under the widened scope | Required amendment |
| --- | --- | --- |
| **D1** (selected remedy) | Sound and unchanged in substance | None; restate against the new module boundary |
| **D2** Piece 1 (scanner) | Sound | None |
| **D2** Piece 2 (masked trigger + wrapper carve-out) | Sound, and load-bearing for the fail-open answer | None |
| **D2** Piece 3 (structural relocation classifier) | **Needs extension** — the gate hooks need `git worktree remove` and `gh pr merge` subcommand *paths* (two words), plus positional-operand and named-flag-value retrieval. Piece 3 as written models only single-word subcommands (`add`, `commit`, `create`, `edit`, `new`) and returns a boolean | Extend to a subcommand-path match plus operand/flag extraction (Section I) |
| **D2** per-hook application table (L352–356) | **Incomplete** — three more hooks and one more Claude sibling enter scope | Add rows for `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-epic-merge-gate.ps1`, and `enforce-pr-author-skill.epic-base-branch.ps1` |
| **D3** fail-closed table | **Incomplete** — needs rows for the new gate forms (`cd <path-with-digits> && gh pr merge --merge <n>`, `git -C <dir> worktree remove <path>`, `git worktree remove --force <path>`, quoted `printf`/heredoc mentions of `gh pr merge --merge`) | Add the rows; each becomes a test obligation |
| **D3** rows asserting `bash -c 'git add .'`, `sh -c "git add ."`, `echo "$(git add .)"` deny today | **Contradicted by the plan's own preflight**, which measured all three as `allow` (plan L130) | Correct the Today/Under cells to `allow`/`allow`, direction `neutral`; plan task [P1-T8] was written to do this and is still unchecked |
| **D4.1** example `bash -c 'echo "pytest"'` | **Wrong** — plan L131 measured it `allow`, so it does not demonstrate D4.1's point | Substitute `bash -c 'echo pytest'`; [P1-T11] unchecked |
| **D4** residual list | Needs a fourth entry recording the three quote-/paren-abutted forms as an accepted residual | [P1-T10] unchecked |
| **D5** (promotion hook in scope) | Unchanged | None |
| **D6** (pr-author under-match in scope) | Unchanged, but must extend to `enforce-pr-author-skill.epic-base-branch.ps1:67` | Add the sibling |
| **D7** (`hook-command-scanner.ps1` as a dot-sourced `.ps1`) | **Needs amendment.** D7's name and file kind were chosen because "`.codex` side has no `lib/` directory" (spec L600–601), which is confirmed true. But the widened scope's six primary call sites are all Claude-side hooks that already `Import-Module` from `.claude/lib/`. The epic brief also directs a `.claude/lib/` module. These are in tension | See Section E: recommend a `.claude/lib/` `.psm1` for the Claude side and treat the Codex side as a separate, explicitly-scoped decision |
| **D8** (#545's own, additive annotation) | Unchanged | None |
| **D9** (synchronization contract, "six registrations") | **Wrong count for a `.psm1` under `.claude/lib/`.** A `.claude/lib` module needs: the Claude bundle mirror, the Claude `core.json` entry, both coverage lists, and a `<Module>.Manifest.Tests.ps1`. It does **not** need `$script:SharedModuleNames` or the Codex pack manifest unless a Codex copy is also delivered | Rewrite the registration checklist per the chosen placement (Section E/H) |
| **D10** (promotion-hook `gh` relocation in scope) | Unchanged | None |
| Non-Goals bullet listing five out-of-scope hooks (L154–158) | **Obsolete** | Three of the five move in scope; `enforce-parallel-abandon-gate.ps1` and `validate-bash.ps1` should stay out (different sub-class; see Section C.8/C.9) |
| Acceptance criterion at L807–810 ("No out-of-scope hook is modified", naming the five) | **Obsolete** | Rewrite against the new boundary |
| Acceptance criterion at L811–813 (file a single follow-up candidate) | **Partly obsolete** | #591 is already filed and open; the follow-up now covers only the genuinely deferred items |
| Acceptance criterion at L752–755 ("all **seven** wrapper deny pins") | **Contradicted by preflight** (four deny, three allow) | [P1-T9] unchecked |

---

## Section C — Gate-hook instances of the defect class

The defect class: *classifying a Bash command by regex-matching the raw command text, with no notion
of where a command begins and no awareness of quoting.*

### C.1 `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`

- **Scope filter.** `Invoke-EpicWorktreeRemovalGateDecision`, lines **319–366**. Line **347**:
  ```powershell
  if ($commandText -notmatch '(?i)\bgit\s+worktree\s+remove\b') {
  ```
  Feeds an early `return Get-EpicWorktreeGateAllowDecision`.
- **Operand extractor.** `Get-EpicWorktreeRemovalCommandPath`, lines **131–151**. Line **147**:
  ```powershell
  if ($CommandText -match '(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)') {
  ```
  Line **148**: `return $Matches['path'].Trim('"''')`.
- **What the match feeds.** The captured path goes to `Find-EpicWorktreeFeatureRecord` (L153) and
  then `Test-ParallelCheckpointAllowsWorktreeRemoval` (L225). No match on any authorizing record
  produces the deny at line **365**.
- **Deny code.** `EPIC_WORKTREE_REMOVAL_BLOCKED` (lines 337 and 365).
- **False positive.** A Bash write whose body quotes the gated phrase, e.g.
  `printf '%s\n' "run git worktree remove <path> after the PR merges" >> notes.md`. Line 347 matches
  the quoted prose, line 147 captures `<path>` (or, in a real note, whatever token follows), no
  checkpoint record matches it, and the write is denied with `EPIC_WORKTREE_REMOVAL_BLOCKED`.
- **Latent bypass.** `git -C /repo/main worktree remove /repo/worktrees/item-a-101` — the `-C <dir>`
  global option breaks adjacency, line 347 does **not** match, the gate returns `allow`, and the
  removal proceeds with no checkpoint authorization at all. This is a genuine ungated destructive
  removal.
- **Second, narrower defect.** `git worktree remove --force /repo/worktrees/item-a-101` (flag
  *before* the path) makes line 147 capture the literal `--force` as the worktree path, which
  matches no record and produces a false deny of a legitimate removal. The existing test at
  `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1:78` only covers the
  flag-*after*-path spelling, so the defect is unpinned. Note the `.codex` copy already handles it:
  `.codex/hooks/enforce-epic-worktree-removal-gate.ps1:35` uses
  `'(?i)\bgit\s+worktree\s+remove(?:\s+--force)?\s+(?:"(?<double>[^"]+)"|''(?<single>[^'']+)''|(?<bare>\S+))'`.
  The two runtimes have silently diverged on this behavior.

### C.2 `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`

- **Scope filter.** `Invoke-ParallelWorktreeRemovalGateDecision`, lines **178–228**. Line **206**:
  ```powershell
  if ($commandText -notmatch '(?i)\bgit\s+worktree\s+remove\b') {
  ```
- **Operand extractor.** `Get-ParallelWorktreeRemovalCommandPath`, lines **54–74**. Line **70**:
  ```powershell
  if ($CommandText -match '(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)') {
  ```
  Line **71**: `return $Matches['path'].Trim('"''')`.
- **Byte-identity check (as requested).** The two regex literals are **byte-identical**:

  | File | Line | Literal |
  | --- | --- | --- |
  | `enforce-epic-worktree-removal-gate.ps1` | 147 | `'(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)'` |
  | `enforce-parallel-worktree-removal-gate.ps1` | 70 | `'(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)'` |

  The scope filters are likewise byte-identical (`'(?i)\bgit\s+worktree\s+remove\b'`), and the
  `.Trim('"''')` call is identical. This is a copy-paste duplication of the whole extraction
  concern across two files — exactly the reusability target for a shared module.
- **What the match feeds.** `Find-ParallelWorktreeItemRecord` (L76) → `Test-ParallelWorktreeRemovalAllowed` (L121).
- **Deny code.** `PARALLEL_WORKTREE_REMOVAL_BLOCKED` (lines 196, 227).
- **False positive / latent bypass.** Identical to C.1.

### C.3 `.claude/hooks/enforce-epic-merge-gate.ps1`

- **Scope filter.** `Invoke-EpicMergeGateDecision`, lines **340–399**. Line **377**:
  ```powershell
  if ($commandText -notmatch '(?i)\bgh\s+pr\s+merge\b' -or $commandText -notmatch '--merge\b') {
  ```
- **PR-number extractor.** `Get-EpicMergeGateCommandPrNumber`, lines **127–158**.
  - Line **146** (anchored, correct):
    ```powershell
    if ($CommandText -match '(?i)\bgh\s+pr\s+merge\s+(\d+)\b') {
    ```
  - Line **154** (unanchored, defective):
    ```powershell
    if ($CommandText -match '(?i)\bgh\s+pr\s+merge\b' -and $CommandText -match '(?<![-\w])(\d+)\b') {
    ```
- **What the match feeds.** `$commandPrNumber` (L381) is compared against
  `epic_merge_pr.pr_number` in `Test-EpicCheckpointAllowsMerge` (L189) and against `items[].pr_number`
  in `Test-ParallelCheckpointAllowsMerge` (L247).
- **Deny code.** `EPIC_MERGE_GATE_BLOCKED` (lines 365, 398).
- **False positive (two distinct kinds).**
  1. *Scope over-match:* any command text containing both `gh pr merge` and `--merge` anywhere,
     including inside quotes. This is the mechanism behind Reproduction 2 below.
  2. *Operand mis-parse (issue #591):* `cd C:\Users\…\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688`
     parses the PR number as `2026`, because the second `-match` at line 154 rescans the whole
     command text and `2026` is preceded by a backslash, which the `(?<![-\w])` lookbehind does not
     exclude. A correct, CI-green merge is denied.
- **Latent bypass.** `gh --repo owner/name pr merge 688 --merge` — the `--repo` global option breaks
  adjacency, line 377 does not match, and the gate returns `allow`. A merge proceeds with no
  checkpoint authorization.

### C.4 `.claude/hooks/enforce-pr-author-skill-helpers.ps1`

- **Enclosing function.** `Get-PrAuthorBypassReason`, lines **139–228**.
- **Lines 170–171 (trigger):**
  ```powershell
  $isPrCreate = $CommandText -match '(?i)\bgh\s+pr\s+create\b'
  $isPrEdit = $CommandText -match '(?i)\bgh\s+pr\s+edit\b'
  ```
- **Lines 177–178 (flag detection):**
  ```powershell
  $hasBodyFile = $CommandText -match '(?i)--body-file\b'
  $hasInlineBody = $CommandText -match '(?i)--body(?!-file)\b'
  ```
- **What the match feeds.** `$isPrCreate`/`$isPrEdit` gate the whole function (early `return $null`
  at L173–175). The two flag booleans then select among Case A (L182), Case B (L188), Case C (L201),
  the orchestrator-state preflight (L207), and receipt verification (L220).
- **Deny codes.** `PR_AUTHOR_SKILL_BLOCKED` (L183, L189), `PR_CONTEXT_MISSING` (L202),
  `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (L215), and the `PR_BODY_PATH_NONCANONICAL` /
  `PR_AUTHOR_RECEIPT_*` family via `Test-PrAuthorReceiptVerification` (L29).
- **False positive.** A JSON receipt write whose value quotes both `gh pr create` and `--body-file`
  classifies as a PR-create invocation with a body file; receipt verification then runs against a
  path that is prose, producing `PR_BODY_PATH_NONCANONICAL`. This is the first of the five
  2026-08-24 instances recorded in `issue.md`.
- **Latent bypass.** `gh --repo owner/name pr create --body "inline"` — line 170 does not match, the
  function returns `$null` at L174, and the inline-body PR is created ungated.

### C.5 `.claude/hooks/enforce-promotion-mcp-only.ps1`

- **Enclosing function.** `Get-PromotionBypassReason`, lines **66–116**.
- **Token scan, lines 86–97:**
  ```powershell
  $forbiddenTokens = @(
      'new-potential-entry.ps1',
      'new_potential_bug_entry',
      'potential_to_issue',
      'new_active_feature_folder'
  )

  foreach ($token in $forbiddenTokens) {
      if ($CommandText.IndexOf($token, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
          return (Get-PromotionMcpOnlyBlockedReason)
      }
  }
  ```
- **Line 101:**
  ```powershell
  if ($CommandText -match '(?i)\bgh\s+issue\s+(?:create|new)\b') {
  ```
- **Lines 110–111:**
  ```powershell
  $ghApiIssuesPostPattern = '(?i)(?=.*\bgh\s+api\b)(?=.*repos/[^/\s]+/[^/\s]+/issues(?:\b|/[^/\s]*$))(?=.*(?:-X\s+POST|--method\s+POST))'
  if ($CommandText -match $ghApiIssuesPostPattern) {
  ```
- **What the match feeds.** `Get-PromotionBypassReason` returns a reason string; `Test-PromotionBypassToken`
  (L118) is a thin boolean wrapper; the decision path converts a non-null reason into a deny.
- **Deny codes.** `PROMOTION_MCP_ONLY_BLOCKED` in two spellings: the legacy promotion-script reason
  (`$script:PromotionMcpOnlyBlockedReason`, line **34**) and the `gh`-issue reason
  (`$script:PromotionMcpOnlyGhIssueBlockedReason`, line **36**).
- **False positive.** Any text containing one of the four literal tokens anywhere — including in a
  JSON string value or a heredoc body. This is Reproduction 1 below.
- **Latent bypass.** `gh --repo owner/name issue create --title x` — line 101 does not match (this is
  exactly what spec D10 records), and the third leg's `repos/<o>/<r>/issues` lookahead does not
  apply, so a raw issue creation proceeds.
- **Second latent bypass, not previously recorded.** The lookahead conjunction at line 110 is
  order-free and whole-text: `gh api repos/o/r/issues` in one segment and `-X POST` in a *different*
  segment satisfies it (false positive), while a POST spelled `--method=POST` (equals form) does not
  match at all (`--method\s+POST` requires whitespace) — a genuine bypass.

### C.6 `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (the originally-filed instance)

- **Enclosing function.** `Test-ImplementationCommand`, lines **118–151**.
- **Pattern array, lines 128–134:**
  ```powershell
  $implementationCommandPatterns = @(
      '(^|\s)git\s+(add|commit)\b',
      '(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b',
      '(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b',
      '(^|\s)npx\s+(prettier|eslint|tsc|jest)\b',
      '(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)'
  )
  ```
- **Match site, line 137:** `if ($normalizedCommand -notmatch $implementationCommandPatterns[$index]) {`
  where `$normalizedCommand = $Command.Trim()` (line 123).
- **What the match feeds.** A match returns `$true` (L148) unless index 0 is cleared by
  `Test-ExemptOrchestrationStagingCommand` (L145). `$true` makes the caller deny when the checkpoint
  is not ready.
- **Deny code.** `PREIMPLEMENTATION_GATE_BLOCKED` (via `Get-OrchestrationPreimplementationGateBlockDecision`, L298).
- **False positive.** Pattern 2's bare tool names match the English word `black` in prose; pattern 3's
  `.*` bridges segments so `npm --version && echo lint` classifies; a heredoc body quoting
  `git add <path>` classifies (pinned today by the `It` at CommandExemption line 246).
- **Latent bypass.** `git -C ../other-worktree add .` — `(^|\s)git\s+(add|commit)\b` requires
  adjacency, so the line never reaches the classifier and passes ungated. Recorded in
  `…-539/spec.md` line 150 as `allow-by-non-match`.

### C.7 New instance: `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`

Not named in the plan, the spec, the epic brief, or the #591 lifecycle record.

- **Enclosing function.** `Test-EpicBaseBranchOverride`, beginning at line **40**.
- **Line 67:**
  ```powershell
  if ($CommandText -notmatch '(?i)\bgh\s+pr\s+create\b') {
      return $null
  }
  ```
- **What the match feeds.** When it matches and the checkpoint has `epic_mode == true`, the command
  must carry `--base <epic_context.integration_branch>`; otherwise `EPIC_BASE_BRANCH_MISMATCH`.
- **Deny code.** `EPIC_BASE_BRANCH_MISMATCH`.
- **False positive.** In an epic-mode run, any Bash write whose text quotes `gh pr create` without a
  matching `--base` value is denied with `EPIC_BASE_BRANCH_MISMATCH`.
- **Latent bypass.** `gh --repo o/n pr create --base main` in epic mode — the relocating spelling
  skips the check entirely and the PR targets the wrong base branch.

This file is dot-sourced by `enforce-pr-author-skill.ps1` at line **144**, immediately above the
helpers dot-source at line 148, so it is already loaded into the same scope as the module a fix
would import.

### C.8 `.claude/hooks/enforce-parallel-abandon-gate.ps1` — same class, different sub-class

- **Predicates.** `Test-ParallelAbandonCommandInScope` (lines **88–111**) and
  `Test-ParallelAbandonCommandConfirmed` (lines **113–136**), each using
  `$NormalizedCommand.Contains(<token>, OrdinalIgnoreCase)` at lines **108** and **133**.
- **Tokens (declared once each, lines 41–42):** `'--disposition abandon'` and `'--confirm-abandon'`.
- **Deny code.** `PARALLEL_ABANDON_BLOCKED` (L45).
- **Why it is a different sub-class.** This gate matches *flag tokens*, not a command word plus a
  subcommand. A command-word parser does not directly serve it; what it needs is per-segment
  quote-aware flag presence. It is **over-match only** (a quoted mention of `--disposition abandon`
  in a note is denied) and is **fail-closed by construction** — the deny direction is safe.
  **Recommendation: leave out of #545's production scope**, but note that the same parser's
  segment/token output would serve it in a later change.

### C.9 `.claude/hooks/validate-bash.ps1` — same class, deliberately exempted

- **Substring denylist.** `Get-BlockedBashPattern` (lines **43–56**) returns six literals
  (`rm -rf`, `git push --force`, `git push origin --force`, `Remove-Item -Recurse -Force`,
  `git reset --hard`, `git push -f`); `Get-BlockedPatternMatch` (L58–79) does a plain
  `$Command.Contains($pattern)` at line **73**.
- **Second pattern.** `$script:CdChainedReadCommandPattern` at line **89**:
  `'cd\s+\S.*?(&&|;)\s*(grep|cat|head|tail|less|more|awk|sed\s+-n)\b'`, matched at line **105**.
- **Deny reasons.** `Blocked dangerous command pattern detected: '<pattern>'` (L125) and the
  `cd ... && <readop>` reason (L130).
- **Why it stays out.** The file's own header (lines 24–29) records a *deliberate* exception to the
  fail-closed envelope policy: it is a denylist, not a receipt gate. Its substring semantics are the
  intended design, and its documented CLI form
  `pwsh -NoProfile -File validate-bash.ps1 "<command>"` depends on treating unparseable raw text as
  the command. Narrowing it would change a documented interface. **Recommendation: out of scope.**
  (This is the hook already recorded in project memory as swallowing `--force-with-lease` via the
  `git push --force` substring; that is a *separate* defect in the same file and remains unfiled.)

### C.10 `.codex/hooks/` copies of the gate hooks

| File | Lines | Defect-class expression | Relation to the Claude copy |
| --- | --- | --- | --- |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 140 | L33 `'(?i)\bgh\s+pr\s+merge\s+(\d+)\b'`; L98 `-notmatch '(?i)\bgh\s+pr\s+merge\b' -or -notmatch '(?i)--merge\b'` | **Has only the anchored branch.** The unanchored line-154 branch that causes issue #591 does **not** exist here. The #591 defect is Claude-only |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 151 | L35 `'(?i)\bgit\s+worktree\s+remove(?:\s+--force)?\s+(?:"(?<double>[^"]+)"\|''(?<single>[^'']+)''\|(?<bare>\S+))'`; L100 `-notmatch '(?i)\bgit\s+worktree\s+remove\b'` | **Strictly better than the Claude copy**: handles `--force` before the path and quoted operands structurally. The Claude copy should adopt at least this much |
| `.codex/hooks/enforce-promotion-mcp-only.ps1` | 261 | L99 `'(?i)\bgh\s+issue\s+(?:create\|new)\b'` | Same defect as the Claude copy |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 495 | Same five-pattern loop | Same defect |
| `.codex/hooks/validate-bash.ps1` | 185 | Denylist | Same deliberate exemption |
| `.codex/hooks/enforce-epic-planning-only.ps1` | — | L113 `'^\s*git\s+worktree\s+list\b'` | Anchored to start-of-string; not the same defect. Out of scope |

There is **no** `.codex` copy of `enforce-parallel-worktree-removal-gate.ps1`,
`enforce-parallel-abandon-gate.ps1`, `enforce-pr-author-skill*.ps1`, or the pr-author sibling.

### C.11 Registration gap observed while sweeping

`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (477 lines, issue #554) is
**not** a member of `$script:SharedModuleNames`
(`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30`), so it is not covered by the
Codex byte-identity `It` (L111), the parse/500-cap `It` (L93), the `$env:CLAUDE_` `It` (L127), or
the pack-manifest `It` (L134). Its bundle mirror exists, but nothing pins it. This is a pre-existing
registration gap, not caused by this change, and should be filed separately rather than folded in.

### Live in-run reproductions, 2026-09-06

**Reproduction 1 — promotion hook, over-match.** Already recorded at
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/other/live-reproduction-promotion-hook-overmatch.2026-09-06T23-35.md`
(48 lines). Writing `artifacts/orchestration/orchestrator-state.json` through a Bash heredoc was
denied with:

> `PROMOTION_MCP_ONLY_BLOCKED: Direct Bash promotion-script execution is not allowed in agent sessions. Use the drm-copilot MCP promotion tools instead.`

**Determination of which pattern matched.** That exact reason string is
`$script:PromotionMcpOnlyBlockedReason`, declared at `enforce-promotion-mcp-only.ps1` **line 34**
and returned only by `Get-PromotionMcpOnlyBlockedReason` (line 38). Inside
`Get-PromotionBypassReason`, that getter is called from exactly one site — the forbidden-token loop
at lines 93–97. Therefore the matching expression is:

```powershell
if ($CommandText.IndexOf($token, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
```

with `$token` drawn from the four-member array at lines 86–91. The heredoc body carried promotion
tool names as JSON *values* under `delegation_receipts.promotion.*`, so at least one of
`potential_to_issue` / `new_active_feature_folder` / `new_potential_bug_entry` occurred as a
substring. The `gh` legs at lines 101 and 111 return the *other* reason string
(`$script:PromotionMcpOnlyGhIssueBlockedReason`, line 36), which was not the observed text, so they
are excluded. The mechanism is a plain `IndexOf` over the whole raw command text with no segment
and no quote awareness.

This reproduction is self-obstructing in a way worth carrying into the spec: the orchestrator
checkpoint schema *requires* the promotion receipt fields, and writing those required values through
the ordinary Bash route is denied by the gate that governs the tokens those values name.

**Reproduction 2 — epic merge gate, over-match.** Recorded verbatim in the 2026-09-06 cleanup-run
observations as gap 8: "The gate hooks match on the Bash command string, so a `printf` whose literal
text mentioned the gated gh subcommand was denied (`EPIC_MERGE_GATE_BLOCKED`) while writing a memory
note."

**Determination of which pattern produced it.** `EPIC_MERGE_GATE_BLOCKED` with a non-anomaly reason
can only come from line **398**, which is reachable only past the scope filter at line **377**:

```powershell
if ($commandText -notmatch '(?i)\bgh\s+pr\s+merge\b' -or $commandText -notmatch '--merge\b') {
    return Get-EpicMergeGateAllowDecision
}
```

Both conjuncts are whole-raw-text matches with no quote awareness. A memory note documenting the
merge gate necessarily contains the phrase `gh pr merge` and the flag `--merge`, so both conjuncts
are satisfied by the quoted prose, the gate proceeds to checkpoint evaluation, no checkpoint
authorizes a merge that is not happening, and line 398 denies. The over-match is caused by the
*scope filter*, not by the PR-number extractor.

Both reproductions confirm the defect is live at `be722eba` and is not confined to the
originally-filed hook.

### Summary of the promoted lifecycle record for issue #591

`docs/features/potential/promoted/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line.md`
(90 lines). Issue #591 is OPEN with no feature folder and no work done. Its content folds into #545.

**The two constraints any fix must preserve** (verbatim from lines 75–76):

> - Both branches must continue to return `$null` for a bare `gh pr merge --merge` carrying no
>   number, because downstream logic treats a missing explicit pull-request number as a fail-closed
>   condition.
> - The epic-path branch at line 146 must keep its current behavior; the parallel branch was
>   deliberately additive.

Both are binding on the design in Section I. The first means the parser's flag-value getter must
return `$null`, not `0` or an empty string, when `--merge` has no operand. The second means the
anchored `gh pr merge <n>` form must still resolve to `<n>` — which a positional-operand getter
does naturally.

**Its proposed-fix bullets** (lines 80–84), condensed but complete:

1. Bind the number capture **positionally to the `gh pr merge` invocation** rather than scanning the
   whole command text — for example by matching the flag and its argument together in a single
   pattern anchored on `gh\s+pr\s+merge`.
2. **Do not** fix this by widening the lookbehind character class to exclude backslashes. That
   suppresses the reproduction while leaving the general defect intact, since any digit run before
   the `gh` token would still be captured.
3. Unit coverage areas: a `cd` prefix whose path contains a standalone digit run followed by
   `gh pr merge --merge <n>`; the bare `gh pr merge --merge <n>` form; the epic form
   `gh pr merge <n> --merge`; a bare `gh pr merge --merge` with no number, which must still yield
   `$null`; and a command whose path prefix contains a digit run adjacent to a word character.
4. Add a falsifiability check: a test asserting the parsed number equals the argument of `--merge`
   specifically, so a future rewrite that reintroduces an unanchored scan fails loudly.
5. Sweep the sibling parallel gates for the same unanchored-scan pattern, specifically
   `enforce-parallel-worktree-removal-gate.ps1` and `enforce-parallel-abandon-gate.ps1`. **This
   research completes that sweep** (Sections C.2 and C.8).

Bullet 2 is the binding design constraint: it forbids the cheap fix and mandates the structural one.

---

## Section D — The existing quote-aware parser

File: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, **349** lines,
read in full. Its Codex twin at `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
is also 349 lines and is byte-identity-pinned (it is a `$script:SharedModuleNames` member).

### What it does, by function

| Function | Lines | Signature | Behavior |
| --- | --- | --- | --- |
| `Split-OrchestrationCommandLine` | **39–89** | `[CmdletBinding()] [OutputType([hashtable])] param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)` | Character-by-character scan tracking a single `$openQuote` char. Splits on `;`, `&`, `\|`, `` `n ``, `` `r `` **only outside quotes**. Returns `@{ Balanced = <bool>; Segments = <string[]> }` with empty/whitespace-only segments dropped |
| `ConvertTo-OrchestrationCommandToken` | **91–146** | `[CmdletBinding()] [OutputType([string[]])] param([Parameter(Mandatory)][AllowEmptyString()][string] $Segment)` | Whitespace-delimited tokenizer that *strips* balanced quotes, so `-m "epic scaffold"` yields `-m` and `epic scaffold`. Sets `$hasToken` on quote open so an empty quoted token survives |
| `Test-ExemptOrchestrationOperand` | **148–204** | `[CmdletBinding()] [OutputType([bool])] param([Parameter(Mandatory)][AllowEmptyString()][string] $Operand)` | Pathspec prefix test against `$script:OrchestrationBookkeepingTrees` (5 entries, L22–28). Rejects `:`-magic, leading `/`, drive letters, `..` segments; truncates a glob at the first `*?[` |
| `Test-ExemptOrchestrationSegmentToken` | **206–294** | `[CmdletBinding()] [OutputType([bool])] param([Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Token)` | **The modeled option table.** Requires `$Token[0] -cne 'git'` to fail, `$Token[1]` to be `add` or `commit`, then walks options: `--` switches to pathspec-only mode; any `-`-leading token on `add` denies; on `commit`, only `-m` / `--message` / `--message=` / `-m<value>` are modeled and anything else denies. Requires at least one operand and every operand exempt |
| `Test-ExemptOrchestrationStagingCommand` | **296–349** | `[CmdletBinding()] [OutputType([bool])] param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)` | Entry predicate. Rejects any text containing `$`, `` ` ``, `>`, `<` (`$script:UnresolvableCommandCharacters`, L33). Requires `Balanced`. Requires **every** segment to be independently exempt |

### Answers to the specific questions

**Can the segment-splitting logic be lifted into a shared module without behavior change?**
Yes, with two caveats. `Split-OrchestrationCommandLine` and `ConvertTo-OrchestrationCommandToken`
are pure, take only a string, return only data, and touch no script-scope state. They can be moved
verbatim. The two caveats:

1. Both currently live in a file that is **byte-identity-pinned across the Codex pair** and is a
   `$script:SharedModuleNames` member. Removing them from that file changes its hash and its line
   count; the pinning tests will demand the mirror be updated in the same commit. This is
   mechanical, not risky.
2. `Test-ExemptOrchestrationSegmentToken` reads `$script:PathspecWildcardCharacters` and
   `$script:OrchestrationBookkeepingTrees` at module scope. Those are policy, not parsing, and
   **must not move**.

The recommended shape is therefore: **copy** the two pure parsing functions into the new module
under new names, leave the #539 file byte-untouched, and let the #539 exemption keep its own private
copies. Duplicating ~110 lines is the wrong instinct in general, but here the #539 file is a closed
feature's record with an explicit acceptance criterion demanding zero functional edit
(`spec.md` L762–765), and the two implementations are behaviorally pinned by their own suites. If
the plan prefers de-duplication, it must budget for re-pinning the Codex pair hash and re-running
the #539 exemption suites — and note that the #545 spec's own AC at L762 forbids exactly that.

**What it would need to become general.**

| Gap | Why it matters for the widened scope |
| --- | --- |
| No heredoc awareness | Reproductions 1 and 2 are both heredoc/quoted-body writes |
| No backslash-escape handling | `\"` inside a double-quoted span currently closes the span |
| No subshell/group/substitution openers as delimiters (`(`, `)`, `{`, `}`, `$(`, backtick) | `$(git worktree remove x)` is one segment today |
| `$`, `` ` ``, `>`, `<` reject the **whole line**, not the segment | Too coarse for a trigger; a redirection in segment 3 should not blind segment 1 |
| No `VAR=value` env-prefix skip | `GIT_DIR=x git worktree remove y` is unmodeled |
| No wrapper concept | The fail-open answer depends on wrapper-led segments scanning raw |
| Command word hard-coded to `git`; subcommand hard-coded to `add`/`commit`; both `-cne` (case-sensitive) | Needs to serve `git worktree remove`, `gh pr merge`, `gh issue create`, `gh pr create/edit` |
| Only two-token subcommands unsupported | `worktree remove` and `pr merge` are two-word subcommand paths |
| No operand or flag-value **retrieval** — it only returns `$true`/`$false` | The gates need the worktree path and the PR number back |
| Allow-side only, total-parse semantics | As a trigger it would deny nearly every ordinary command (spec D1 rejected alternative B) |

**Behavior that MUST be preserved because a test pins it.**

| Behavior | Pinning test |
| --- | --- |
| Balanced-quote stripping so a quoted operand reaches the prefix test unquoted | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:88` `It 'allows a quoted operand under the active feature tree'` |
| Chain split so an all-exempt two-segment line allows | same file `:136` `It 'allows a chained two-segment line whose every segment is independently exempt'` |
| Unbalanced quoting denies | same file `:215` (D4 row 11 fixture) inside the `-ForEach` at `:188` |
| `$`, backtick, `>`, `<` deny | same file `:216`–`:219` (D4 rows 12a–12d) |
| Chained line with a non-exempt second segment denies | same file `:220`–`:221` (D4 rows 13a–13b) |
| Relocating spellings chained with a trigger-matching segment deny (NEVER EXEMPT) | same file `:222`–`:225` (D4 rows 14a–14d) |
| Backslash separator normalization | same file `:100` `It 'allows a backslash-spelled operand after separator normalization (D4 row 18)'` |
| The whole rule table denies as a set | same file `:188` `It 'denies <Label>'` `-ForEach` (rows 1 through 19) |
| The heredoc-prose deny (the **one** assertion #545 intends to reverse) | same file `:246` `It 'denies a message-body payload that merely contains the staging literal'` |
| The Codex mirror of every one of the above | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (271 lines; the reversal target at `:250`) |
| The helpers file's own byte identity across the Codex pair, parse-check, 500-line cap, no-`$env:CLAUDE_`, and pack-manifest membership | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` `It`s at `:93`, `:111`, `:127`, `:134` (via `$script:SharedModuleNames` at `:30`) |

---

## Section E — Shared-module placement

### `HookPayload.psm1` confirmation

`.claude/lib/hook-payload/HookPayload.psm1` is **496** lines; the file ends at line 496 with the last
continuation of `Export-ModuleMember`. **Four lines of headroom.** Nothing new fits.

`Export-ModuleMember` list (lines 486–496), in file order:

```powershell
Export-ModuleMember -Function `
    Read-ClaudeHookRawPayload, `
    ConvertFrom-ClaudeHookEnvelope, `
    Get-ClaudeHookToolInput, `
    Resolve-ClaudeHookToolInput, `
    Get-ClaudeHookEnvelopeValue, `
    Test-ClaudeHookEnvelopeHasKey, `
    Test-ClaudeHookObjectValue, `
    Get-ClaudeHookToolInputString, `
    Get-ClaudeHookPayloadAnomalyCode, `
    Get-ClaudeHookPayloadAnomalyReason
```

`Get-ClaudeHookToolInputString` is at lines **410–439** (the reported range is exact). Its contract:

```powershell
[CmdletBinding()]
[OutputType([string])]
param(
    [AllowNull()]
    [object] $ToolInput,

    [Parameter(Mandatory)]
    [string] $Name
)
```

It reads a named string property off an already-extracted `tool_input` object via
`Get-ClaudeHookEnvelopeValue`, returning `''` (not `$null`) when the property is absent. Its
docstring states the design intent explicitly: "Property-level tolerance lives here: an absent
property returns an empty string, which every hook already treats as 'out of my scope, allow'."
Every hook in Section C obtains its command text from this one call, spelled
`Get-ClaudeHookToolInputString -ToolInput $payload.Value -Name 'command'`. That call is the natural
upstream seam for a parser.

### `.claude/lib/` conventions a new `.psm1` must follow

Derived from `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` (137 lines), which
**discovers modules from disk** with `Get-ChildItem -Path .claude/lib -Filter '*.psm1' -File -Recurse`
(lines 30–33). A new module cannot escape it.

1. **Directory-per-concern**, kebab-case directory name; PascalCase `<Name>.psm1` inside. Nine
   existing directories confirm the pattern.
2. **Module header** is a comment-based-help block with `.SYNOPSIS` and `.DESCRIPTION`, ending with
   the exact convention sentence — the test matches the literal token
   `imports its siblings with -ErrorAction Stop` (test line 38) anywhere before the `Set-StrictMode`
   line. Existing modules spell it: `CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.`
3. **`Set-StrictMode -Version Latest` must be immediately followed by `$ErrorActionPreference = 'Stop'`**
   — adjacency is asserted by index (test lines 58–63). Both compared after `.Trim()`, and the guard
   line is compared case-sensitively (`-ceq`).
4. **Every column-0 `Import-Module` line must carry `-ErrorAction Stop`** (test lines 74–81). A
   module with no sibling imports trivially satisfies this.
5. **`Export-ModuleMember -Function <list>` at the end of the file.** `GeneratedDocumentCounters.psm1`
   uses the single-line form; `HookPayload.psm1` uses the backtick-continued multi-line form. Either
   is acceptable.
6. **≤ 500 physical lines**, measured with `@(Get-Content -LiteralPath $path).Count` (test lines
   126–132) — not `Measure-Object -Line`, which the test's own comment flags as under-reporting.
7. **Importing a module must not alter the caller's `$ErrorActionPreference`** (test lines 109–121).
8. Additional constraint from the no-Python guard (Section F): the module must not use
   `Invoke-Expression`/`iex`, `Start-Process`, `& $variable` on a non-`[scriptblock]`-typed
   parameter, `& (<expression>)`, or `. (<expression>)` unless the expression is a `Join-Path` call
   whose second argument is a literal `.ps1` path.

### The exact `Import-Module` call shape a hook uses

Checked across more than two hooks; the form is uniform and there are **no** variants:

```powershell
Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force
```

Occurrences (repo-root copies): `enforce-epic-merge-gate.ps1:42`,
`enforce-epic-worktree-removal-gate.ps1:62`, `enforce-parallel-worktree-removal-gate.ps1:32`,
`enforce-promotion-mcp-only.ps1:33`, `enforce-orchestration-preimplementation-gate.ps1:9`,
`enforce-pr-author-skill.ps1:47`, `validate-bash.ps1:41`, and 20 more. A second module is imported
the same way at `enforce-pr-author-skill.ps1:51`:

```powershell
Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorState.psm1') -Force
```

**Why this resolves in the mirrored bundle too.** The path is relative to `$PSScriptRoot`, and the
bundle preserves the identical `.claude/hooks/` ↔ `.claude/lib/` relative layout under
`extensions/drm-copilot/resources/claude-customizations/`. Both trees hold all 39 lib files. Since
`Import-Module` is byte-identical in canonical and mirror (the mirror is content-equal by
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`), a new `.claude/lib/<dir>/<X>.psm1`
resolves in the bundle exactly as it does at the repo root, **provided the mirror copy is created**.

Note the divergent idiom used **within** `.claude/hooks/` for sibling `.ps1` helpers, which is
dot-source, not import:

```powershell
. (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-helpers.ps1')
```

(`enforce-orchestration-preimplementation-gate.ps1:14`, `:20`; `enforce-pr-author-skill.ps1:144`, `:148`).

### The `.codex` constraint (must be settled before implementation)

Every `.codex/hooks/` file loads siblings with `$PSScriptRoot`-relative **dot-source** only; not one
references `../lib` or `.claude/lib`. Verified across all 28 `.codex/hooks/*.ps1`. Spec assumption
L600–601 states this correctly: "the `.codex` side has no `lib/` directory." A `.claude/lib` module
therefore **cannot** serve `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`,
`.codex/hooks/enforce-promotion-mcp-only.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, or
`.codex/hooks/enforce-epic-worktree-removal-gate.ps1`.

Three options, with a recommendation:

| Option | Consequence |
| --- | --- |
| **(a) Claude-only `.claude/lib` module; Codex hooks out of scope for this change** | Smallest change; keeps the #554-constrained 495-line Codex gate untouched; leaves the Codex runtime with the old defect until a follow-up. Registration burden: 1 mirror + 1 `core.json` entry + 2 coverage entries + 1 Manifest test |
| **(b) `.claude/lib` module for Claude + a byte-identical `.codex/hooks/<name>.ps1` dot-sourced sibling** | Two implementations of one parser. Directly violates the standing "a second implementation drifts" principle that this repository applies to the Python question. Registration burden roughly doubles |
| **(c) Keep spec D7's `.ps1` dot-sourced sibling in `.claude/hooks/` + `.codex/hooks/` (four copies, no `.claude/lib`)** | One source of truth in *content*, four physical copies pinned by hash. Matches the existing precedent (`codex-pretooluse-file-mapping.ps1`, `enforce-orchestration-preimplementation-gate-helpers.ps1`). Does **not** use `.claude/lib` |

**Recommendation: (a).** Rationale: the six primary call sites in Section C are all Claude-side; the
epic's downstream children D and G edit Claude-side hooks only; the Codex merge and worktree-removal
gates do **not** carry the #591 defect (the Codex merge gate lacks the unanchored branch, and the
Codex worktree gate already parses `--force` and quotes structurally); and the Codex preimplementation
gate has 5 lines of headroom, which cannot absorb the change without a prior relocation. Option (a)
keeps the change inside its size budget and its blast radius. The Codex side should be filed as a
named, explicit follow-up in the same PR body — not silently dropped.

### Recommended module path and name

```
.claude/lib/command-line/CommandLine.psm1
```

Mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/command-line/CommandLine.psm1`.

Justification:

- **Directory-per-concern.** The concern is "reading a shell command line structurally". `command-line`
  names it without binding to `hook`, so a future non-hook consumer (a skill validator, a bash port
  oracle) can use it. Compare `blast-radius`, `model-routing`, `discovery-validation`.
- **Not `hook-command-scanner`.** Spec D7 chose that name for a `.ps1` in `.claude/hooks/`, where the
  `enforce-` prefix carries meaning. Under `.claude/lib/` the naming convention is
  `<Directory>/<PascalCaseName>.psm1`, and `HookCommandScanner.psm1` would embed the consumer in the
  library's name. D7 should be amended, and its stated rationale (avoiding the reserved `enforce-`
  prefix) is satisfied either way.
- **Import path.** `Import-Module (Join-Path $PSScriptRoot '../lib/command-line/CommandLine.psm1') -Force`
  is exactly the established shape.

### Line budget

| Component | Estimate |
| --- | --- |
| Header + `Set-StrictMode`/`$ErrorActionPreference` + convention sentence | 25 |
| `$script:WrapperCommandName` (14 members) + `$script:TransparentWrapperName` + `$script:GitGlobalOption` + `$script:GhGlobalOption` tables, with comments | 45 |
| `Split-CommandLineSegment` (quote + escape + heredoc + opener/closer state machine) | 120 |
| `ConvertTo-CommandLineToken` (quote-stripping tokenizer with escape handling) | 55 |
| `Read-CommandLineSegment` (segment record builder: RawText/MaskedText/Tokens/HasLiveSubstitution/Unbalanced) | 60 |
| `Test-CommandLineInvocation` (command word + subcommand path + global-option absorption) | 70 |
| `Get-CommandLineOperand` (positional operand after the matched subcommand) | 40 |
| `Get-CommandLineFlagValue` (named flag value, `--flag v` and `--flag=v`) | 45 |
| `Export-ModuleMember` | 8 |
| **Total** | **≈ 468** |

**Verdict: it fits under 500, but only barely, and the estimate has no margin for the
comment density this repository's modules carry** (`HookPayload.psm1` devotes 41 header lines and a
full comment-based-help block per function). **Recommend planning for a two-module split from the
start:**

| Module | Contents | Estimate |
| --- | --- | --- |
| `.claude/lib/command-line/CommandLineSegment.psm1` | Segment scanner, tokenizer, segment-record builder, `Unbalanced`/`HasLiveSubstitution` flags. No policy tables | ≈ 280 |
| `.claude/lib/command-line/CommandLineInvocation.psm1` | Wrapper set, git/gh option tables, `Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`. Imports the segment module with `-ErrorAction Stop` | ≈ 260 |

The split costs one extra `core.json` entry, two extra coverage entries, and one extra Manifest
test, and it removes the size risk entirely. The `blast-radius` directory (7 modules) and
`orchestrator-state` directory (11 modules) establish that multi-module directories are normal here.

---

## Section F — Test inventory

| Test file | Lines | `Describe` block(s) | Import / dot-source mechanism |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | **428** | `enforce-epic-worktree-removal-gate.ps1` (L24) | `BeforeAll` at L25: `$script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-worktree-removal-gate.ps1").Path` then `. $script:UnderTest` (L27) |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | **455** | `enforce-epic-merge-gate.ps1` (L8) | Same pattern, `Resolve-Path` L10, dot-source L11 |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | **392** | `enforce-parallel-worktree-removal-gate.ps1` (L18) | Same pattern, L20–21 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | **447** | `enforce-pr-author-skill.ps1` (L4) | Same pattern, L6–7 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1` | **103** | `enforce-pr-author-skill.ps1 payload envelope` (L17) | Same pattern, L19–20 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | **104** | `enforce-pr-author-skill.ps1 (orchestrator-state preflight)` (L15) | Same pattern, L17–18; second `Resolve-Path` at L56 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` | **113** | `enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride` (L16) | Same pattern, L18–19 (dot-sources the parent hook, which dot-sources the sibling) |
| `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` | **214** | `enforce-promotion-mcp-only.ps1` (L4) | Same pattern, L6–7 |
| `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1` | **487** | Six: `Read-ClaudeHookRawPayload transport` (L25), `ConvertFrom-ClaudeHookEnvelope` (L180), `Get-ClaudeHookToolInput strict nested extraction` (L240), `Resolve-ClaudeHookToolInput end-to-end extraction` (L302), `Anomaly reason mapping` (L390), `Shape helper predicates` (L425) | **`Import-Module`**, not dot-source: top-level `BeforeAll` (L14) sets `$script:HookPayloadModulePath` then `Import-Module $script:HookPayloadModulePath -Force` (L19) |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | **500 (at the cap)** | `enforcement hooks must not invoke Python` (L99), with Contexts `allowlist policy`, `detection class 1`–`4`, `non-detection`, `carve-out boundaries`, `repository scan` | Top-level `BeforeAll` dot-sources a sibling helper: `. (Join-Path -Path $PSScriptRoot -ChildPath 'EnforcementHooksNoPythonInvocation.Helpers.ps1')` (L32) |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | **461** | `enforce-orchestration-preimplementation-gate.ps1` (L4) | Same dot-source pattern, L6–7 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | **267** | `enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539)` (L15) | Same pattern, L17–18 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | **223** | `enforce-orchestration-preimplementation-gate.ps1 absolute-path classification` (L139) | Same pattern, L141–142 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` | **159** | `enforce-orchestration-preimplementation-gate.ps1 classifier (issue #554)` (L32) | Dot-sources the gate (L34–35) **and** the modes sibling (L41) |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | **491** | `enforce-orchestration-preimplementation-gate.ps1 mode resolution` (L12) | Dot-sources the gate (L14–15) and the modes sibling (L21) |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | **271** | (Codex analogue) | Dot-source |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | **332** | (Codex analogue, #554) | Dot-source |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | **242** | (Codex analogue) | Dot-source |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | **494** | Codex contract suite | Name-driven from `$script:AllHookNames` (L22) + `$script:SharedModuleNames` (L30) |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | **137** | `Claude library module conventions` (L44) | Disk discovery, no import except one probe at L116 |

The two suites the plan proposed to create — `…TriggerScoping.Tests.ps1` on either side — do **not**
exist. Phase 3 never ran.

**Size warnings for the plan:** `enforcement-hooks-no-python-invocation.Tests.ps1` is exactly at 500
lines; `legacy-codex-hook-contracts.Tests.ps1` is at 494; `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
is at 491; `enforce-epic-merge-gate.Tests.ps1` is at 455. None can absorb a new scenario. Every new
case goes in a sibling file.

### The no-Python guard, in detail

**Exact assertions.** Two are the repository scan; three constrain the allowlist and the enumeration.

```powershell
It 'ships an empty allowlist' {
    $allowlist = Get-PythonInvocationAllowlist
    @($allowlist).Count | Should -Be 0
}
```
(lines 102–109)

```powershell
It 'enumerates only the two guarded roots and never the bundled mirror' {
    $files = Get-GuardedPowerShellFile
    @($files).Count | Should -BeGreaterThan 0
    $outsideRoots = @($files | Where-Object {
            $_.Relative -notlike '.claude/hooks/*' -and $_.Relative -notlike '.claude/lib/*'
        })
    $outsideRoots.Count | Should -Be 0 -Because (...)
    $bashPaths = @($files | Where-Object { $_.Relative -like '.claude/lib/bash/*' })
    $bashPaths.Count | Should -Be 0 -Because 'the bash library is shell, not PowerShell'
    $mirrorPaths = @($files | Where-Object { $_.Relative -like 'extensions/*' })
    $mirrorPaths.Count | Should -Be 0 -Because (...)
}
```
(lines 452–471)

```powershell
It 'reports no Python invocation beyond the allowlist across the guarded tree' {
    $findings = Get-RepositoryPythonInvocationFinding
    $allowlist = Get-PythonInvocationAllowlist
    $residual = Select-UnallowedPythonInvocationFinding -Finding @($findings) -Allowlist @($allowlist)
    @($residual).Count | Should -Be 0 -Because (
        "residual Python invocation sites:`n" + (($residual | ForEach-Object { $_.Message }) -join "`n"))
}
```
(lines 473–484)

```powershell
It 'carries no stale allowlist entry' {
    ...
    $stale = Get-UnusedPythonInvocationAllowlistEntry -Finding @($findings) -Allowlist @($allowlist)
    @($stale).Count | Should -Be 0 -Because (...)
}
```
(lines 486–498)

**Does the glob include a new file under `.claude/lib/`?** **Yes.** The scan roots are defined at
lines 39–42:

```powershell
$script:ScanRoot = @(
    (Join-Path -Path $script:RepoRoot -ChildPath '.claude/hooks'),
    (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib')
)
```

and `Get-GuardedPowerShellFile` (lines 50–76) enumerates `Get-ChildItem -Path $root -Recurse -File`
filtered to `.ps1`/`.psm1`, skipping only `.claude/lib/bash/*`. A new
`.claude/lib/command-line/CommandLine.psm1` is therefore in the guarded set automatically, with no
registration. The bundle mirror is deliberately excluded (`extensions/*` assertion at lines 468–470),
so the mirror copy is not scanned.

**What the new module must avoid so it does not trip the guard**, by detection class:

1. **Constant interpreter command** — no command whose name is `python`, `python3`, `py`, or
   `poetry`, in any case, invoked bare, with `&`, with `.`, or quoted. (Interpreter names inside
   *string literals* and *comments* are explicitly non-detections, lines 304–331 — so the module may
   safely carry the literals as data.)
2. **Subprocess start** — no `Start-Process` at all (and the token itself is forbidden under
   `tests/` by `check-powershell-test-purity.ps1:119`, per the suite header at lines 14–16).
3. **Dynamic invocation, fail-closed** — no `& $variable` unless `$variable` is a `[scriptblock]`-typed
   parameter of the enclosing function (name-matched, case-insensitively); no `& (<expression>)`;
   no `. (<expression>)` unless the expression is a `Join-Path` call whose argument is a literal
   `.ps1` path.
4. **Arbitrary text execution** — no `Invoke-Expression` and no `iex`.

A pure string-processing parser satisfies all four trivially. The one realistic trap is a
`& $Handler`-style dispatch table; use `switch` or a hashtable of values instead of scriptblock
invocation, or type the parameter `[scriptblock]`.

### Where a new library test file must live

`.claude/rules/general-unit-test.md` requires the `tests/` tree to mirror the production structure
and forbids colocation. The established mapping for `.claude/lib/<dir>/<X>.psm1` is
`tests/scripts/claude-lib/<dir>/<X>.Tests.ps1` — confirmed by all 43 existing files under
`tests/scripts/claude-lib/`. For the recommended module:

- `tests/scripts/claude-lib/command-line/CommandLineSegment.Tests.ps1`
- `tests/scripts/claude-lib/command-line/CommandLineInvocation.Tests.ps1`
- `tests/scripts/claude-lib/command-line/CommandLine.Manifest.Tests.ps1` — the manifest-membership
  and bundle-mirror suite, modeled on
  `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1` (76 lines).
  That template asserts three things per module: `core.json` membership, exactly-once membership,
  and that **every on-disk `.psm1` in the directory is registered** (its `It` at line 48). The last
  assertion means adding a second module to `command-line/` without a manifest entry fails loudly —
  which is the desired behavior.

### Existing test assertions that would break if a detection call site is rewritten

These are the regression risks the plan must sequence around.

| Assertion | File:line | Risk |
| --- | --- | --- |
| `It 'denies a message-body payload that merely contains the staging literal'` | `…gate.CommandExemption.Tests.ps1:246` | **Intended reversal.** Its expected decision changes `deny` → `allow`. The only sanctioned reversal on the Claude side |
| Codex twin of the same `It` | `…-command-exemption.Tests.ps1:250` | **Intended reversal**, Codex side — only if the Codex side is in scope (see Section E option (a)) |
| `It 'allows gh pr merge without --merge (e.g., --squash)'` | `enforce-epic-merge-gate.Tests.ps1:27` | Must still pass; a rewritten scope filter must not classify `--squash` |
| `It 'allows a bare gh pr merge --merge (no PR number) when ci_gate.conclusion is success'` | `:74` | Depends on `Get-EpicMergeGateCommandPrNumber` returning `$null`. Constraint 1 of #591 |
| `It 'returns $null for a bare gh pr merge --merge with no PR number'` | `:227` | Directly pins the `$null` contract |
| `It 'returns 410 for the number-before-flag form gh pr merge 410 --merge'` | `:223` | Constraint 2 of #591 — the anchored branch must keep behaving |
| `It 'returns 410 for the flag-before-number form gh pr merge --merge 410'` | `:227`* | The form the unanchored branch was added for; a positional/flag getter must reproduce it |
| `It 'denies a bare gh pr merge --merge (no PR number) even when a parallel checkpoint is present'` | `:205` | Fail-closed on missing number |
| `It 'allows a non gh-pr-merge Bash command'` (`git status`) | `:21` | Scope filter must stay narrow |
| `It 'extracts the target path from the command text'` | `enforce-epic-worktree-removal-gate.Tests.ps1:136` and `enforce-parallel-worktree-removal-gate.Tests.ps1:254` | Pin `Get-*WorktreeRemovalCommandPath`'s return for the simple form. A signature change breaks both directly |
| `It 'returns $null when the command does not name a path'` (`git status`) | `:141` / `:259` | Same |
| `It 'allows git worktree remove --force when the matching record has merge_status merged'` | `enforce-parallel-worktree-removal-gate.Tests.ps1:78` | Fixture is `git worktree remove <path> --force` (flag after path). A structural parser must still resolve `<path>` here |
| `It 'matches worktree_path when the command quotes the target path'` | `:243` | Pins the `.Trim('"''')` behavior; a tokenizer that strips quotes gives the same answer, but the equivalence must be asserted |
| `It 'allows git worktree list'` / `It 'allows git worktree add'` | `:36` / `:41` | The subcommand-path matcher must not classify sibling subcommands |
| `It 'does not call the read seam for a command that is not git worktree remove'` | `:217` | Pins that the scope filter short-circuits **before** any disk read. A rewrite that parses first and filters second still satisfies this only if no seam call precedes the filter |
| `It 'blocks new_active_feature_folder'` (and the three siblings at `:32`, `:39`, `:45`) | `enforce-promotion-mcp-only.Tests.ps1:51` | Fixtures are genuine invocations; must still deny after the token scan moves onto masked segment text |
| `It 'blocks gh issue create case-insensitively'` | `:72` | The parser's command-word and subcommand comparison must be case-insensitive, unlike the #539 helper's `-cne` |
| `It 'allows gh issue list'` / `It 'allows gh issue view 10'` | `:104` / `:110` | The subcommand-path matcher must stop, not classify |
| `It 'blocks gh api repos/owner/repo/issues -X POST -f title=foo'` and `--method POST` | `:85` / `:92` | The lookahead conjunction must keep denying within a single segment |
| `It 'allows gh api repos/owner/repo/issues with no method (defaults to GET)'` | `:98` | Must not become a deny |
| `It 'blocks staging and commit command payloads before readiness'` | `…gate.Tests.ps1:123` | `git add .` and `git commit -m "test"` must still deny |
| `It 'blocks formatter and test command payloads before readiness'` (three fixtures incl. the `pwsh -NoProfile -Command` wrapper at L140) | `:135` | The wrapper carve-out is what preserves the L140 fixture's denial. This is the single most load-bearing deny pin for the fail-open answer |
| The 19-row `It 'denies <Label>' -ForEach` table | `…CommandExemption.Tests.ps1:188` | Every row must still deny; rows 14a–14d (lines 222–225) are the relocating-spelling NEVER-EXEMPT rows |
| `It 'classifies <Label> as implementation command <Expected>' -ForEach` | `legacy-codex-hook-contracts.Tests.ps1:348` | The Codex classification table; only relevant if the Codex side is in scope |
| Convention suite's six `It`s | `ClaudeLibModuleConvention.Tests.ps1:45–136` | A new module that misses the guard-line adjacency, the convention sentence, or the 500-line cap fails here |
| `It 'reports no Python invocation beyond the allowlist across the guarded tree'` | `enforcement-hooks-no-python-invocation.Tests.ps1:473` | Automatically covers the new module |
| `test_poshqc_bundled_module_files_match_repo_root_sources` | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:63` | A coverage-list edit in one runsettings file and not the other fails here |
| `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:106` | A new `.claude/**` file without its mirror fails here |

\* the `:227` line hosts two adjacent `It`s in the extractor Context (lines 218–231); the exact
line for each is 223 and 227 respectively, per the `It` index. Re-read that Context before writing
a citation into the plan.

---

## Section G — Coverage registration

### How a PowerShell file enters the Pester coverage denominator

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (256 lines) is the single source. Two
independent keys named `Path` exist and must not be confused:

- `Run.Path` (line 3): `@('scripts', 'tests/powershell', 'tests/scripts')` — **test discovery**, not
  coverage. Untouched by a coverage registration.
- `CodeCoverage.Path` (line 23 through line 245) — an **explicit per-file allow list**. A production
  file that is not literally listed here produces no `sourcefile` element in
  `artifacts/pester/powershell-coverage.xml` and is silently outside the denominator.

Other settings that matter: `CodeCoverage.Enabled = $true` (L18), `OutputFormat = 'CoverageGutters'`
(L21, which is what makes the report JaCoCo-shaped), `OutputPath = 'artifacts/pester/powershell-coverage.xml'`
(L22), and `CoveragePercentTarget = 0` (L247) — so the run itself never fails on coverage; the
threshold is enforced by evidence, not by the tool.

`config/poshqc-scan.json` (7 lines) is unrelated to coverage:

```json
{
  "version": 1,
  "test": {
    "scanFolders": ["scripts", "tests/powershell", "tests/scripts"]
  }
}
```

It supplies the **test scan folders** only. **No edit to `config/poshqc-scan.json` is needed** to
register a coverage path.

**Note on the current list state.** The list has grown since the 2026-08-25 baseline recorded 83
entries (issue #554 added the two `-modes.ps1` entries at lines 139 and 214, among others), and it
contains a pre-existing duplicate of `.claude/hooks/enforce-pr-author-skill.ps1` (lines 34 and 47).
Any acceptance criterion phrased as "the list length increases by exactly N" must re-derive the
baseline length programmatically first.

### The exact edit needed for a new `.claude/lib/<dir>/<Module>.psm1`

Two files, textually identical edits, because `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`
pins `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` to
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` by exact UTF-8
text equality (its `POSHQC_PARITY_PATHS` tuple, lines 9–18, includes the runsettings file).

Append inside the `CodeCoverage.Path` array, following the established comment-then-path idiom (see
lines 93–96 for the closest precedent):

```powershell
            # Issue #545 added the shared command-line parser so the enforcement hooks classify a
            # Bash invocation structurally rather than by matching raw command text.
            # CodeCoverage.Path is an explicit per-file allow-list, so the new production modules
            # are registered here; without these entries they would sit outside the coverage
            # denominator, which the Coverage Exclusion Policy forbids.
            '.claude/lib/command-line/CommandLineSegment.psm1'
            '.claude/lib/command-line/CommandLineInvocation.psm1'
```

**No** `extensions/…/claude-customizations/…` path is added: the list holds zero entries under
`extensions/drm-copilot/resources/`, and bundle mirrors are covered by hash/content parity instead.

### The exact self-hosted invocation

The MCP tool `mcp__drm-copilot__run_poshqc_test` wraps `Invoke-PoshQCTest`, defined at
`scripts/powershell/PoshQC/PoshQC.Testing.psm1:151` and exported through
`scripts/powershell/PoshQC/PoshQC.psd1`. The MCP path resolves its settings from the **installed VS
Code extension's** copy, so a `CodeCoverage.Path` entry added in this checkout is invisible to it —
the file is silently absent from the JaCoCo report rather than reported at zero. The direct route,
which makes the in-repo settings authoritative via the explicit `-SettingsPath` parameter (defined
at `PoshQC.Testing.psm1:156`), is:

```powershell
pwsh -NoProfile -Command "Set-Location 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a1f9391a7c0a908df'; Import-Module './scripts/powershell/PoshQC/PoshQC.psd1' -Force; Invoke-PoshQCTest -Root (Get-Location).ProviderPath -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'"
```

This is the same form the 2026-08-25 baseline used and recorded as successful
(`evidence/baseline/baseline-selfhosted-coverage.2026-08-25T13-37.md`, lines 9–13, EXIT_CODE 0).

Reading a per-file percentage out of the emitted report requires the **package-qualified** selection
recorded in that artifact (lines 46–53): the `counter` element whose `type` is `LINE`, on the
`sourcefile` element whose `name` equals the bare filename, selected **within** the enclosing
`package` element whose `name` ends with that file's directory. A bare-filename lookup is ambiguous
because several filenames occur under both `.claude/hooks` and `.codex/hooks`.

---

## Section H — Mirroring / push-down contract

Source: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (451 lines).

### Which source paths must be mirrored

`SCOPED_ROOTS = (Path(".claude"),)` (line 20). `test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(lines 106–131) enumerates **every file under `.claude/**` at the repo root**, excluding exactly two
things: `.claude/settings.local.json` (line 121) and the `.claude/agent-memory/**` subtree (line 121,
via `_is_agent_memory_path`). Every remaining file must exist at the same relative path under
`extensions/drm-copilot/resources/claude-customizations/`.

### Byte-identical or content-equal? Do line endings matter?

**Content-equal, and line endings do not matter for this test.** The assertion (lines 128–131) is:

```python
assert read_text(BUNDLED_ROOT, relative_path) == read_text(
    REPO_ROOT,
    relative_path,
), f"Bundle content differs from repo for: {relative_path}"
```

`read_text` (lines 51–54) is `(root / relative_path).read_text(encoding="utf-8")`, which opens in
text mode with Python's default universal-newline translation, so `\r\n` and `\n` both decode to
`\n`. A CRLF/LF difference between canonical and mirror passes this test.

Three narrower assertions in the same file **are** byte-exact, but they cover only named paths:

- `test_planner_review_resources_exist_and_are_byte_identical` (lines 134–144) uses `read_bytes()`
  over `PLANNER_REVIEW_RESOURCE_PATHS` (lines 32–36): the atomic-plan-contract skill,
  `.claude/hooks/validate-planner-output.ps1`, and the atomic-planner agent. None is in this
  change's scope.
- `test_bundled_claude_payload_contains_required_runtime_files` (lines 57–70) requires nine anchor
  files from `REQUIRED_BUNDLED_FILES` (lines 21–31) to be present. None is in scope.

The **Codex** pair is different and stricter: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
`It` at line 111 compares SHA-256 hashes, so `.codex/hooks/**` canonical↔bundle must be
**byte-identical**. This is exactly the split spec D9 records at lines 493–498, re-verified correct.

### Is a NEW file under `.claude/lib/<newdir>/` automatically covered?

**For the parity pytest, yes — automatically.** `list_scoped_files` (lines 39–48) uses
`scoped_path.rglob("*")` with no enumerated list, so a new directory and file are picked up with no
edit anywhere. The consequence is the reverse of convenience: creating
`.claude/lib/command-line/CommandLine.psm1` without its mirror **immediately turns the pytest red**.

**For push-down delivery, no — a manifest edit is required.** `scripts/dev_tools/push_down_claude_customizations.py`
resolves published paths from the pack manifests
(`PACK_MANIFEST_SUBDIR = "pack-manifests"`, line 71; `_resolve_published_paths`, lines 137–180;
`load_pack_manifests` / `compute_published_paths` imported at lines 38–39). Under a `--packs`
selection, only manifest-listed paths are delivered. `core.json` enumerates `.claude/lib/**`
explicitly at lines 113–158 (25 `.psm1` entries plus 11 `.sh` entries). A new module must be added
there or it will not ship under `--packs core`.

Additionally, the `.claude/lib` convention is that each directory carries a `*.Manifest.Tests.ps1`
suite asserting manifest membership and bundle byte-identity. The template
(`tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1`) has an `It`
at line 48 — `registers every on-disk discovery-validation module so none is unregistered` — that
enumerates the on-disk directory and requires each file to be in the expected-path list. This makes
the manifest omission fail loudly at test time rather than silently at push-down time.

Note that the Manifest tests assert **byte identity** (`Get-FileHash -Algorithm SHA256`, lines 70–72)
for `.claude/lib` modules, which is stricter than the pytest's content equality. So for a new lib
module the operative requirement is **byte-identical**, and line endings **do** matter.

### `.codex/hooks/` copies of these gate hooks

Present, and governed by a different contract:

| Canonical | Bundle | Governing contract | Enforcing test |
| --- | --- | --- | --- |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | Byte-identical (SHA-256) | `legacy-codex-hook-contracts.Tests.ps1:111`, driven by `$script:StaticCheckNames` (L31) = `$script:AllHookNames` (L22) + `$script:SharedModuleNames` (L30) |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | same tree | Byte-identical | same |
| `.codex/hooks/enforce-promotion-mcp-only.ps1` | same tree | Byte-identical | same |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | same tree | Byte-identical | same |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | same tree | Byte-identical + parse + 500-cap + no-`$env:CLAUDE_` + pack-manifest membership | `:93`, `:111`, `:127`, `:134` via `$script:SharedModuleNames` |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | same tree (mirror exists) | **Ungoverned** — not a member of `$script:SharedModuleNames` | none (see C.11) |
| `.codex/hooks/validate-bash.ps1` | same tree | Byte-identical | same |

There is **no** `.codex` copy of `enforce-parallel-worktree-removal-gate.ps1`,
`enforce-parallel-abandon-gate.ps1`, or any `enforce-pr-author-skill*` file.

### Complete mirror file list for the widened change

Assuming Section E option (a) — Claude-side production change, one `.claude/lib/command-line/`
directory split into two modules — the complete set of files whose *mirror* must change:

**Claude bundle mirrors of changed production files** (content-equal by pytest; keep them
byte-identical anyway so the recomputed-hash evidence criterion is satisfiable):

1. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`
5. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1`
6. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
7. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` — **only if** the helpers file is edited; the current recommendation is to leave it byte-untouched, in which case this mirror does **not** change
8. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` — **only if** the `Import-Module` line is added there rather than in the helpers file
9. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` — if C.7 is brought in scope

**Claude bundle mirrors of new library files** (byte-identical, pinned by the Manifest suite):

10. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/command-line/CommandLineSegment.psm1`
11. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/command-line/CommandLineInvocation.psm1`

**Registration / settings files:**

12. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — two new `.claude/lib/command-line/…` entries
13. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — two new `CodeCoverage.Path` entries
14. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — the **textually identical** edit, pinned by `test_poshqc_bundled_parity.py`

**If the Codex side is brought in scope** (option (b) or (c)), add:

15. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
16. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1`
17. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1`
18. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
19. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/<parser>.ps1` (new)
20. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
21. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30 — one-line
    `$script:SharedModuleNames` append (the file is at 494 lines and can absorb no new line)

Base case (option (a), helpers untouched, C.7 included): **11 mirror/registration files**
(items 1–6, 8, 9, 10–14 minus items 7 and 15–21 — precisely 1,2,3,4,5,6,8,9,10,11,12,13,14 = 13
files, of which 11 are mirrors and 2 are settings). Enumerate exactly at plan time against the final
production-file set; this list is the derivation, not a substitute for it.

---

## Section I — Proposed parser contract (downstream contract)

Epic children D and G edit the same hooks immediately after this work: child D adds
cleanup-manifest acceptance to `enforce-epic-worktree-removal-gate.ps1`; child G adds a
consolidation-PR checkpoint shape to `enforce-epic-merge-gate.ps1`. The signatures below are a
contract, not an implementation detail.

### Public surface

Module `.claude/lib/command-line/CommandLineSegment.psm1`:

```powershell
function Read-CommandLineSegment {
    <#
    .SYNOPSIS
        Scan a raw Bash command line into an ordered list of segment records.
    .DESCRIPTION
        A single left-to-right scan tracking single-quote spans, double-quote spans,
        backslash escapes, and a heredoc delimiter state machine. Segment delimiters,
        recognized only outside quoted spans and heredoc bodies: ';', '&', '|', newline,
        and the subshell/group/substitution openers and closers '(', ')', '{', '}',
        '$(' and the backtick.

        Pure: reads no file, starts no process, reads no clock, mutates no input.
    .PARAMETER CommandText
        The raw Bash command text, exactly as delivered by
        Get-ClaudeHookToolInputString -Name 'command'.
    .OUTPUTS
        System.Management.Automation.PSCustomObject[] - one record per segment, in
        source order. Each record carries:
          RawText             [string]   the segment's original text, unmodified
          MaskedText          [string]   quoted spans and attached heredoc bodies
                                         replaced by single spaces
          Tokens              [string[]] quote-stripped, whitespace-delimited tokens
          CommandWord         [string]   the first token after any VAR=value prefixes,
                                         or '' when the segment has no command word
          IsWrapperLed        [bool]     $true when CommandWord is a member of the
                                         wrapper carve-out set
          HasLiveSubstitution [bool]     $true when '$(' or a backtick occurred inside
                                         one of the segment's double-quoted spans
          Unbalanced          [bool]     $true when a quote span or heredoc did not
                                         close before end of text
          ScanText            [string]   the clause-ordered selection: RawText when
                                         Unbalanced or HasLiveSubstitution or
                                         IsWrapperLed; MaskedText otherwise
        Returns an empty array for null, empty, or whitespace-only input.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $CommandText
    )
}
```

Module `.claude/lib/command-line/CommandLineInvocation.psm1`:

```powershell
function Test-CommandLineInvocation {
    <#
    .SYNOPSIS
        Report whether a command line invokes a named command word with a named
        subcommand path, structurally rather than by raw-text adjacency.
    .DESCRIPTION
        Scans every segment produced by Read-CommandLineSegment. For each segment:
        skips VAR=value env-assignment prefixes; skips the transparent wrappers
        (command, env, nohup, time, timeout); requires the next token to equal
        CommandWord case-insensitively; absorbs the modeled global options for that
        command word; then matches SubcommandPath token-for-token against the
        following non-option tokens.

        FAIL-CLOSED RULES, all mandatory:
          - An unmodeled dash-leading token between the command word and the
            subcommand classifies as a match. Over-classification only forces a
            checkpoint check; under-classification is a bypass.
          - A non-dash token that is not the next expected subcommand element
            terminates that segment's scan without a match, so 'git log --grep add'
            does not classify as 'git add'.
          - A segment whose Unbalanced flag is set classifies as a match, because its
            structure could not be resolved.
          - A wrapper-led segment (IsWrapperLed) classifies as a match whenever its
            RawText contains the command word and every subcommand element, in any
            arrangement. This preserves today's denial for xargs, env, nested shells,
            and the pwsh -Command wrapper, and is the direct answer to #539 D8.
          - A segment whose HasLiveSubstitution flag is set is evaluated against
            RawText by the same wrapper rule.
    .PARAMETER CommandText
        The raw Bash command text.
    .PARAMETER CommandWord
        The command name, e.g. 'git' or 'gh'. Compared case-insensitively.
    .PARAMETER SubcommandPath
        One or more ordered subcommand tokens, e.g. @('worktree','remove'),
        @('pr','merge'), @('issue','create'), @('add'). Compared case-insensitively.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $CommandText,

        [Parameter(Mandatory)]
        [string] $CommandWord,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $SubcommandPath
    )
}

function Get-CommandLineOperand {
    <#
    .SYNOPSIS
        Return the positional operands of a matched invocation, in source order.
    .DESCRIPTION
        Locates the first segment in which CommandWord + SubcommandPath match
        structurally, then returns the non-option tokens that follow the subcommand
        path in that segment only. Modeled option-with-argument pairs are consumed
        (so '--force' contributes nothing and '-C <dir>' consumes both tokens);
        a token after a bare '--' separator is always an operand; a dash-leading
        token that is not modeled terminates operand collection, because its arity
        is unknown and a wrong guess would silently return a flag as a path.

        The operand list comes from the MATCHED segment only. A 'cd <path>' segment
        chained before the invocation contributes nothing, which is the direct fix
        for issue #591.
    .PARAMETER CommandText
        The raw Bash command text.
    .PARAMETER CommandWord
        The command name.
    .PARAMETER SubcommandPath
        The ordered subcommand tokens.
    .OUTPUTS
        System.String[] - operands with balanced quotes already stripped, in source
        order. An empty array when no segment matched, or when the matched segment
        carries no operand. Never $null.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $CommandText,

        [Parameter(Mandatory)]
        [string] $CommandWord,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $SubcommandPath
    )
}

function Get-CommandLineFlagValue {
    <#
    .SYNOPSIS
        Return the value of a named flag belonging to a matched invocation.
    .DESCRIPTION
        Locates the matched segment as Test-CommandLineInvocation does, then searches
        that segment's tokens for FlagName. Recognizes both the separated form
        ('--merge 688') and the equals form ('--merge=688'). Returns $null when the
        flag is absent, when the flag is present with no following value token, or
        when the following token is itself dash-leading.

        The $null-on-missing-value contract is mandatory and is pinned by issue #591's
        first constraint: downstream logic treats a missing explicit pull-request
        number as a fail-closed condition, so a bare 'gh pr merge --merge' must yield
        $null, never 0 and never ''.
    .PARAMETER CommandText
        The raw Bash command text.
    .PARAMETER CommandWord
        The command name.
    .PARAMETER SubcommandPath
        The ordered subcommand tokens.
    .PARAMETER FlagName
        The flag as written, including leading dashes, e.g. '--merge' or '--body-file'.
        Compared case-insensitively.
    .OUTPUTS
        System.String or $null. Quotes are already stripped. Callers that need an
        integer cast the result themselves after a $null check.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $CommandText,

        [Parameter(Mandatory)]
        [string] $CommandWord,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $SubcommandPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $FlagName
    )
}

function Test-CommandLineMention {
    <#
    .SYNOPSIS
        Report whether a command line merely MENTIONS a command word and subcommand
        path without invoking it.
    .DESCRIPTION
        Convenience inverse used by hooks that want to log or explain an allow. True
        when the raw text contains the command word and every subcommand element but
        Test-CommandLineInvocation returns false. Purely informational; no hook makes
        a deny decision from this predicate.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText,
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath
    )
}
```

Exported constants, each a named script-scope read-only table pinned by test:
`Get-CommandLineWrapperName`, `Get-CommandLineTransparentWrapperName`,
`Get-CommandLineGlobalOption -CommandWord <git|gh|npx>`. Getters rather than raw variables so the
module scope stays private and the pinning test asserts against a public surface.

### How each Section C call site is rewritten

| # | Call site | Before | After |
| --- | --- | --- | --- |
| C.1 | `enforce-epic-worktree-removal-gate.ps1:347` (scope filter) | `if ($commandText -notmatch '(?i)\bgit\s+worktree\s+remove\b') { return allow }` | `if (-not (Test-CommandLineInvocation -CommandText $commandText -CommandWord 'git' -SubcommandPath @('worktree','remove'))) { return allow }` |
| C.1 | `enforce-epic-worktree-removal-gate.ps1:147-148` (`Get-EpicWorktreeRemovalCommandPath`) | `-match '(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)'` then `.Trim('"''')` | `$operands = Get-CommandLineOperand -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree','remove'); if ($operands.Count -eq 0) { return $null } return $operands[0]` — the function keeps its name, signature, and `$null`-on-miss contract, so the two pinning `It`s at `:136` and `:141` are unaffected |
| C.2 | `enforce-parallel-worktree-removal-gate.ps1:206` | identical regex | identical rewrite to C.1's scope filter |
| C.2 | `enforce-parallel-worktree-removal-gate.ps1:70-71` | identical regex | identical rewrite; both files now delegate the duplicated concern to one implementation |
| C.3 | `enforce-epic-merge-gate.ps1:377` (scope filter) | `-notmatch '(?i)\bgh\s+pr\s+merge\b' -or -notmatch '--merge\b'` | `$isMerge = Test-CommandLineInvocation -CommandText $commandText -CommandWord 'gh' -SubcommandPath @('pr','merge')`; `$hasMergeFlag = $null -ne (Get-CommandLineFlagValue … -FlagName '--merge') -or (Get-CommandLineOperand … ) -contains '--merge'`. **Caveat:** `--merge` is a *boolean* flag with an optional adjacent number, not a valued flag, so the presence test needs its own predicate — see "call sites the proposal cannot serve as written" |
| C.3 | `enforce-epic-merge-gate.ps1:146` (anchored branch) | `-match '(?i)\bgh\s+pr\s+merge\s+(\d+)\b'` | `$operands = Get-CommandLineOperand -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr','merge'); $first = $operands \| Where-Object { $_ -match '^\d+$' } \| Select-Object -First 1` — preserves #591 constraint 2 |
| C.3 | `enforce-epic-merge-gate.ps1:154` (unanchored branch) | `-match '(?i)\bgh\s+pr\s+merge\b' -and -match '(?<![-\w])(\d+)\b'` | **Deleted.** Replaced by `Get-CommandLineFlagValue … -FlagName '--merge'` on the matched segment, which returns `$null` for a bare `--merge` (constraint 1) and `688` for `cd …\2026-08-29T00-11 && gh pr merge --merge 688` (the #591 fix) |
| C.4 | `enforce-pr-author-skill-helpers.ps1:170-171` | two `-match` triggers | `$isPrCreate = Test-CommandLineInvocation … -CommandWord 'gh' -SubcommandPath @('pr','create')`; `$isPrEdit = … @('pr','edit')` |
| C.4 | `enforce-pr-author-skill-helpers.ps1:177-178` | `--body-file\b` / `--body(?!-file)\b` | `$hasBodyFile = $null -ne (Get-CommandLineFlagValue … -FlagName '--body-file')`; `$hasInlineBody` needs a presence-only predicate for the same reason as `--merge` (see below). Per spec D2 (L356), the downstream `--body-file` **path value** and every `PR_*` reason code stay on the existing raw-text logic and are unchanged |
| C.5 | `enforce-promotion-mcp-only.ps1:93-97` (token `IndexOf` loop) | `$CommandText.IndexOf($token, …)` | `foreach ($segment in (Read-CommandLineSegment -CommandText $CommandText)) { foreach ($token in $forbiddenTokens) { if ($segment.ScanText.IndexOf($token, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return … } } }` — the four literals stay byte-unchanged (spec R2), only the scanned text changes |
| C.5 | `enforce-promotion-mcp-only.ps1:101` | `'(?i)\bgh\s+issue\s+(?:create\|new)\b'` | `if ((Test-CommandLineInvocation … -SubcommandPath @('issue','create')) -or (Test-CommandLineInvocation … -SubcommandPath @('issue','new'))) { … }` — closes the D10 relocation bypass |
| C.5 | `enforce-promotion-mcp-only.ps1:110-111` (`gh api … POST` lookahead) | whole-text lookahead conjunction | Evaluate the **byte-unchanged** pattern per segment against `$segment.ScanText`. Narrows the cross-segment false positive; a genuine single-segment call still matches. Does **not** close the `--method=POST` equals-form bypass — that needs a separate flag predicate |
| C.6 | `enforce-orchestration-preimplementation-gate.ps1:137` (five-pattern loop) | `$normalizedCommand -notmatch $implementationCommandPatterns[$index]` | Loop over segments outside the pattern loop: `foreach ($segment in $segments) { for ($index …) { if ($segment.ScanText -notmatch $pattern[$index]) { continue } … } }`; then add a structural leg `Test-CommandLineInvocation -CommandWord 'git' -SubcommandPath @('add')` / `@('commit')`. The five pattern strings stay byte-unchanged (spec R2); the #539 exemption stays on the git leg at the same point (spec R5) |
| C.7 | `enforce-pr-author-skill.epic-base-branch.ps1:67` | `-notmatch '(?i)\bgh\s+pr\s+create\b'` | `if (-not (Test-CommandLineInvocation … -SubcommandPath @('pr','create'))) { return $null }`; the `--base` value then comes from `Get-CommandLineFlagValue … -FlagName '--base'` |

**Call sites the proposal cannot serve as written.** Three, all the same shape:

- `--merge` in `enforce-epic-merge-gate.ps1:377` is a **boolean** flag.
- `--body` in `enforce-pr-author-skill-helpers.ps1:178` is boolean-with-value but the hook only asks
  whether it is present *and distinct from `--body-file`*.
- `--force` in the worktree gates is boolean.

`Get-CommandLineFlagValue` returns `$null` for all three whether the flag is absent or present
without a value, so it cannot distinguish presence. **Add a fourth public function:**

```powershell
function Test-CommandLineFlag {
    <#
    .SYNOPSIS
        Report whether a named flag is present on a matched invocation, regardless of
        whether it carries a value.
    .DESCRIPTION
        Presence-only companion to Get-CommandLineFlagValue, for boolean flags such as
        '--merge', '--force', and '--body'. Matches both '--flag' and '--flag=value'.
        Exact token comparison after quote stripping: '--body' does not match
        '--body-file', which is the distinction the pr-author hook's negative lookahead
        currently expresses as '--body(?!-file)\b'.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText,
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $FlagName
    )
}
```

With `Test-CommandLineFlag` added, all seven call sites are served. No call site remains unserved.

### How the proposal answers the D8 fail-open objection

#539 D8's objection is precise and correct against a naive fix: *scoping the trigger to a
segment-leading command name is fail-open, because wrapper forms legitimately place the command name
elsewhere.* The proposal does **not** scope to segment-leading command names. Four mechanisms keep
the wrapper forms fail-closed:

1. **`IsWrapperLed` forces raw-text evaluation.** A segment whose command word is in the wrapper
   carve-out set never has its quoted spans masked, and `Test-CommandLineInvocation` falls back to a
   containment test over `RawText`. `xargs git worktree remove x`, `env git add .`,
   `bash -c 'git add .'`, `pwsh -NoProfile -Command "Invoke-Pester …"`, and `bash <<EOF … git add … EOF`
   all keep today's classification.
2. **`Unbalanced` forces a match.** If quoting or a heredoc did not close, the structure is unknown
   and the segment classifies. Today's helper *denies the exemption* on unbalanced text
   (`Test-ExemptOrchestrationStagingCommand` line 332); the trigger side takes the same posture in
   the opposite polarity, which is the same fail-closed direction.
3. **`HasLiveSubstitution` forces raw-text evaluation.** `echo "$(git add .)"` keeps today's answer.
4. **Unmodeled dash-leading token classifies.** A global option this design has not modeled makes
   the segment classify rather than pass. The failure mode of an incomplete option table is
   over-classification, which costs a checkpoint check, not a bypass.

**Proposed wrapper deny list** (a named script-scope constant, exported through
`Get-CommandLineWrapperName`, pinned by a membership test). Fourteen members, adopted verbatim from
spec D2 Piece 2 lines 292–297:

```text
sh   bash   zsh   dash   ksh   pwsh   powershell
xargs   env   command   eval   nohup   time   timeout
```

Plus a separate five-member **transparent wrapper** set used only by the structural matcher's skip
step (spec D2 Piece 3 step 2), exported through `Get-CommandLineTransparentWrapperName`:

```text
command   env   nohup   time   timeout
```

(`command`, `env`, `nohup`, `time`, `timeout` appear in both sets deliberately: they are wrappers for
the raw-scan rule *and* transparent for the structural rule, so `env git worktree remove x`
classifies by both mechanisms.)

**Recommended additions to the wrapper set for the widened scope**, each because the widened gates
govern destructive operations: `sudo`, `doas`, `nice`, `stdbuf`, `setsid`, `script`, `parallel`.
`parallel` is named in spec residual risk D4.3 as a known unlisted wrapper; the gate hooks make it
worth closing now rather than deferring. Adding it changes the set from fourteen to twenty-one
members, which means **spec acceptance criterion at L741–743 ("exactly the fourteen members") must
be amended** if the additions are adopted.

**Explicitly still open after this design** (record as residual, do not claim closed):

- Nested wrapper re-scanning. A wrapper's quoted argument is treated as opaque raw text, not
  re-segmented. `bash -c 'echo "pytest"'` still classifies (spec D4.1).
- Quote-/paren-abutted command names. The five preimplementation-gate patterns anchor on `(^|\s)`,
  which a preceding quote or paren does not satisfy; the plan's preflight measured
  `bash -c 'git add .'`, `sh -c "git add ."`, and `echo "$(git add .)"` as `allow` **today**.
  Because those segments are wrapper-led and therefore scan raw, they remain `allow` after the fix.
  This is a neutral, not a regression, but it must be stated so no one records a false deny.
- Obfuscated respellings (`git${IFS}add`, `\git add`). The tokenizer must **not** unescape a
  backslash-escaped command name; doing so would be a behavior change with its own fail-open
  analysis (spec D4.2).
- `validate-bash.ps1` and `enforce-parallel-abandon-gate.ps1` (Sections C.8, C.9).

---

## Acceptance test cases the CURRENT hooks fail and the FIXED hooks must pass

Each is a concrete, runnable input string with an expected classification, drivable through the
hooks' pure decision seams (no temporary file, no child process, no live executable).

**AT-1 — Latent bypass, epic worktree removal gate (under-match direction).**

- Seam: `Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw <envelope>`
- Command text: `git -C /repo/main worktree remove /repo/worktrees/item-a-101`
- Checkpoint: an epic checkpoint whose `features[]` contains **no** record with that
  `worktree_path`, or whose matching record has `merge_status: "pr_open"`.
- **Current behavior:** `allow` — line 347's `\bgit\s+worktree\s+remove\b` does not match because
  `-C /repo/main` breaks adjacency. An unauthorized destructive removal proceeds.
- **Required behavior:** `deny` with `EPIC_WORKTREE_REMOVAL_BLOCKED`.
- This is the mandatory latent-bypass case.

**AT-2 — Operand mis-parse, epic merge gate (issue #591, the recorded reproduction).**

- Seam: `Get-EpicMergeGateCommandPrNumber -CommandText <text>`
- Command text: `cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688`
- **Current behavior:** returns `2026`. Line 154's second `-match` rescans the whole command text
  and `2026` is preceded by a backslash, which `(?<![-\w])` does not exclude. The gate then denies a
  correct, CI-green merge with `EPIC_MERGE_GATE_BLOCKED`.
- **Required behavior:** returns `688`, taken from the `--merge` flag of the `gh` segment. The
  paired negative must hold in the same suite: `gh pr merge --merge` with no number still returns
  `$null` (#591 constraint 1), and `gh pr merge 410 --merge` still returns `410` (#591 constraint 2).

**AT-3 — Over-match, promotion hook (live reproduction 1 of 2026-09-06).**

- Seam: `Get-PromotionBypassReason -CommandText <text>`
- Command text (a single string containing a heredoc):
  ```
  cat > artifacts/orchestration/orchestrator-state.json <<'JSON'
  {"delegation_receipts":{"promotion":{"required_tools":["mcp__drm-copilot__potential_to_issue","mcp__drm-copilot__new_active_feature_folder"]}}}
  JSON
  ```
- **Current behavior:** returns the `PROMOTION_MCP_ONLY_BLOCKED: Direct Bash promotion-script
  execution is not allowed in agent sessions.` reason, via the `IndexOf` loop at lines 93–97. The
  checkpoint write is blocked, and the checkpoint schema requires exactly those values.
- **Required behavior:** returns `$null` (allow). The heredoc body is masked and the `cat` segment
  is not wrapper-led. The paired positive must hold: `pwsh scripts/dev_tools/potential_to_issue.ps1`
  still returns the same reason string.

**AT-4 — Over-match, epic merge gate (live reproduction 2 of 2026-09-06, gap 8).**

- Seam: `Invoke-EpicMergeGateDecision -ToolInputRaw <envelope>`
- Command text:
  `printf '%s\n' "The merge gate denies gh pr merge --merge when no checkpoint authorizes it." >> .claude/agent-memory/notes.md`
- **Current behavior:** `deny` with `EPIC_MERGE_GATE_BLOCKED`. Line 377's two conjuncts are both
  satisfied by the quoted prose; no checkpoint authorizes a merge that is not happening.
- **Required behavior:** `allow`. The `printf` segment is not wrapper-led, so its double-quoted span
  is masked and neither conjunct matches.

**AT-5 — Latent bypass, promotion hook `gh` relocation (spec D10).**

- Seam: `Get-PromotionBypassReason -CommandText <text>`
- Command text: `gh --repo drmoisan/drm-copilot issue create --title "x" --body "y"`
- **Current behavior:** returns `$null` (allow). Line 101's `\bgh\s+issue\s+(?:create|new)\b`
  requires adjacency, which `--repo drmoisan/drm-copilot` breaks.
- **Required behavior:** returns the `gh`-issue reason
  (`$script:PromotionMcpOnlyGhIssueBlockedReason`). Paired negative: `gh --repo o/r issue list` must
  still return `$null`.

**AT-6 — Wrapper deny preservation (the fail-open guard; must pass BEFORE and AFTER).**

- Seam: `Test-ImplementationCommand -Command <text>` against a not-ready checkpoint.
- Command text: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"`
- **Current behavior:** classifies (`$true`) — pinned today at
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:140`.
- **Required behavior:** still classifies. `pwsh` is wrapper-led, so the segment scans raw. This
  case does not currently fail; it is included because it is the assertion that would break if the
  fail-open objection were answered wrongly, and it must be run in the same suite as AT-1 through
  AT-5 so a regression is visible in one place.

**AT-7 — False deny, worktree removal with a leading `--force` (Claude/Codex divergence).**

- Seam: `Get-ParallelWorktreeRemovalCommandPath -CommandText <text>` (and the epic twin).
- Command text: `git worktree remove --force /repo/worktrees/item-a-101`
- **Current behavior:** returns the literal `--force`, which matches no `items[]` record, so the
  gate denies a legitimate removal with `PARALLEL_WORKTREE_REMOVAL_BLOCKED`. Unpinned by any test:
  the existing `It` at `:78` uses the flag-after-path spelling.
- **Required behavior:** returns `/repo/worktrees/item-a-101`. The `.codex` copy already gets this
  right (`.codex/hooks/enforce-epic-worktree-removal-gate.ps1:35`), so this test also closes a
  cross-runtime divergence.

---

## Numeric Derivation Evidence

One numeric population claim in this document is likely to become a `spec.md` acceptance criterion —
the count of Claude-side hook files carrying the defect class — so it is derived twice below. No
other number in this document is proposed as an acceptance criterion; every other count is reported
as an observation with its method disclosed, and the coverage-list length is explicitly withheld
pending programmatic re-derivation.

### Claim: nine files under `.claude/hooks/` classify Bash command text by raw-text regex or substring matching

- **Complete Family:** every file under `.claude/hooks/` that (i) obtains a Bash command string from
  the PreToolUse envelope and (ii) reaches a decision by matching that string with `-match`,
  `-notmatch`, `[regex]::Match`, `String.IndexOf`, or `String.Contains`. All match/containment
  operators are in scope, not one named operator.
- **Exhaustive Search Scope:** all 41 files in `.claude/hooks/` (enumerated by glob). No sampling.
- **Inclusion Rules:** the file must both extract a command string and match against it. All five
  match/containment mechanisms count. Dot-sourced siblings count as separate files because each is
  independently editable and independently coverage-registered.
- **Exclusion Rules:** excluded are files that extract the command but never match it; files whose
  matching is over a *path* rather than a command; files that match only pre-tokenized data supplied
  by another function (this excludes `enforce-orchestration-preimplementation-gate-helpers.ps1`,
  whose `Test-ExemptOrchestrationSegmentToken` compares already-split `[string[]]` tokens, not raw
  text); and the `.codex/`, `extensions/`, and `tests/` trees.
- **Primary Search Strategy / Query Expression:** regex search over `.claude/hooks/` for a command
  variable adjacent to any match or containment operator —
  `\$(CommandText|commandText|Command|normalizedCommand|NormalizedCommand|commandToCheck)\b.*(-match|-notmatch|\.IndexOf\(|\.Contains\()` — plus a
  targeted read of `validate-bash.ps1:105` for the `[regex]::Match` form, which the operator
  alternation does not cover.
- **Primary Member Set:** `enforce-parallel-abandon-gate.ps1` (108, 133);
  `enforce-parallel-worktree-removal-gate.ps1` (70, 206);
  `enforce-pr-author-skill.epic-base-branch.ps1` (67);
  `enforce-epic-merge-gate.ps1` (146, 154, 377);
  `enforce-epic-worktree-removal-gate.ps1` (147, 347);
  `enforce-orchestration-preimplementation-gate.ps1` (137, patterns 128–133);
  `enforce-promotion-mcp-only.ps1` (94, 101, 111);
  `enforce-pr-author-skill-helpers.ps1` (170, 171, 177, 178);
  `validate-bash.ps1` (73, 105).
- **Primary Count:** **9**.
- **Cross-check Search Strategy / Query Expression:** a structurally different query — search
  `.claude/hooks/` for the *extraction* seam rather than the match operator, using
  `Name 'command'|-Name "command"|commandText|CommandText`, which returns the candidate population,
  then read each returned file in full and apply the exclusion rules by hand.
- **Cross-check Member Set:** the extraction query returns 11 files: `validate-bash.ps1`,
  `enforce-promotion-mcp-only.ps1`, `enforce-pr-author-skill.ps1`,
  `enforce-pr-author-skill.epic-base-branch.ps1`, `enforce-pr-author-skill-helpers.ps1`,
  `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`,
  `enforce-orchestration-preimplementation-gate.ps1`,
  `enforce-orchestration-preimplementation-gate-helpers.ps1`,
  `enforce-epic-worktree-removal-gate.ps1`, `enforce-epic-merge-gate.ps1`. Two are excluded by the
  stated rules after reading: `enforce-pr-author-skill.ps1` (extracts the command at line 178 and
  forwards it; carries no match or containment operator against it — verified by an operator search
  over that file returning only line 289's `$PSBoundParameters.ContainsKey`) and
  `enforce-orchestration-preimplementation-gate-helpers.ps1` (matches against `[string[]]` tokens,
  not raw command text). 11 − 2 = 9.
- **Cross-check Count:** **9**.
- **Member-set Comparison:** the two normalized member sets are identical, element for element:
  {enforce-epic-merge-gate, enforce-epic-worktree-removal-gate,
  enforce-orchestration-preimplementation-gate, enforce-parallel-abandon-gate,
  enforce-parallel-worktree-removal-gate, enforce-pr-author-skill-helpers,
  enforce-pr-author-skill.epic-base-branch, enforce-promotion-mcp-only, validate-bash}. No member
  appears in one set and not the other. The counts agree at 9.

**Assertion released:** nine files under `.claude/hooks/` carry the defect class. Of these, the
epic brief and the existing spec together account for six; `enforce-pr-author-skill.epic-base-branch.ps1`
is new to this research; and `enforce-parallel-abandon-gate.ps1` and `validate-bash.ps1` are
recommended to stay out of production scope for the reasons in Sections C.8 and C.9. The in-scope
production count is therefore **seven**, and the deferred count is **two**.

---

## Blocking unknowns

1. **Codex-side scope is undecided and cannot be decided by this research.** A `.claude/lib` module
   cannot serve `.codex/hooks/`, which loads siblings by `$PSScriptRoot` dot-source only (verified
   across all 28 files). The `.codex` preimplementation gate has 5 lines of headroom. The
   orchestrator must choose option (a), (b), or (c) from Section E before planning. This research
   recommends (a).
2. **The `.claude/state/` baseline is not reproducible here.** The directory does not exist in this
   worktree, so the plan's [P0-T9] / [P11-T5] zero-delta gate pair rests on a failure that may never
   be observed. The plan must either re-derive the push-down baseline empirically or replace the
   delta gate with an absolute-zero gate.
3. **The coverage-list length and the aggregate coverage percentage are both unusable.** The plan
   asserts 83 entries and ~61.6%; its own baseline artifact records 96.14%. Both must be re-measured
   before any acceptance criterion cites either.
4. **Issue #545's `spec.md` is in a half-revised state** — D10 and AC #25 landed but the version
   marker still reads 1.0, and seven Phase 1 tasks ([P1-T8] through [P1-T13], plus [P1-T7]'s
   downstream numbering) remain unchecked. It is unclear whether those edits landed and the boxes
   were not ticked, or whether the edits never landed. A reader must diff, not trust the checkboxes.
5. **Whether the wrapper set grows from fourteen to twenty-one members** is a policy decision, not a
   research finding. If it grows, spec acceptance criterion at L741–743 must be amended in the same
   change.
6. **`enforce-parallel-abandon-gate.ps1` and `validate-bash.ps1` disposition.** This research
   recommends leaving both out. `validate-bash.ps1`'s substring semantics are documented as
   deliberate, and it also carries a separate, unfiled defect (the `git push --force` substring
   swallowing `--force-with-lease`). The orchestrator should confirm the exclusion rather than let
   it be inferred.
