# 2026-09-13-taskmaster-push-down-and-resume — Plan

- **Issue:** #674
- **Parent (optional):** none (epic: `worktree-scoped-state-resolution`, wave 2, ref F7)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-13T20-48
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **AC Sources:** `spec.md` and `user-story.md` (9 identical criteria each, tracked independently per `.claude/skills/acceptance-criteria-tracking/SKILL.md`)

## Required References

- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/tonality.md`
- `.claude/skills/atomic-plan-contract/SKILL.md`
- `.claude/rules/plan-acceptance-gates.md`
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- `research/2026-09-13T22-15-taskmaster-push-down-and-resume-research.md`
- `runbooks/reload-vscode-window-for-mcp-payload.runbook.md` (HI-2)
- `runbooks/confirm-taskmaster-run-resume.runbook.md` (HI-1)

**All work must comply with these policies; do not duplicate their content here.**

## Plan Scope and Constraints

- **No new logic.** This plan is procedural delivery only. No task edits `.claude/hooks/**`, `.claude/lib/**`, `extensions/drm-copilot/src/**`, or `pack-manifests/core.json`. F1's `core.json` registration is verified in Phase 6 and never authored by this plan.
- **Execution context.** This plan is executed by `epic-orchestrator` after F2, F3, F4, F5, and F6 have merged into `epic/worktree-scoped-state-resolution-integration`. F1's content is reached transitively through F4 and F5, both of which gate F7 (epic manifest `depends_on: [1002, 1003, 1004, 1005, 1006]`). Phase 1 gates on this fact rather than assuming it.
- **The changed-literal collision.** No corrected content exists in any commit as of this plan's authoring (preparation-mode). Per Wrap-Tolerant Assertion Authoring, a token containing `<`, `>`, `${`, `$(`, or `%` is a documented command shape, not a real assertion, so this plan cannot hardcode the literal the freshness grep (Phase 5) and destination-content grep (Phase 9) assert on. Phase 2 makes the **derivation** of that literal its own gating task with a checkable acceptance condition: a non-zero match count against the post-fix file at `HEAD`, and a zero match count against the pre-fix version of the same file at the epic's fork point from `main`. Phase 2 records the concrete literal in an evidence artifact (`literal-derivation.<timestamp>.md`), and Phase 5 and Phase 9 both cite that artifact by task ID (P2-T4) rather than repeating a value invented at authoring time. Using the identical literal in Phase 5 and Phase 9 is itself a stated acceptance condition, not an incidental note, so the plan proves the same content moved end to end rather than two unrelated facts.
- **Language toolchains out of scope.** This feature adds no Python, PowerShell, TypeScript, or C# production or test code of its own. Every task below either reads existing files, runs pre-existing tools (Pester, git, the sideload script, the push-down MCP tool) as black boxes, or writes Markdown evidence artifacts. Phase 11 (P11-T4) verifies this claim with an anchored `git diff` plus a `git status --porcelain` companion, rather than asserting the absence of a toolchain loop by omission, so the omission is a checked fact and not something a reviewer must take on faith.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance, Context, and Pre-Execution Baseline Capture

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, and `.claude/rules/tonality.md` (the .claude/skills/policy-compliance-order/SKILL.md baseline order, extended with tonality.md, named directly by CLAUDE.md's Tone Policy section, and quality-tiers.md, named by general-code-change.md's Module Rigor Tiers section, itself part of the required baseline reading). Confirm no language-specific rule file (`python.md`, `powershell.md`, `typescript.md`, `csharp.md`) applies, because this feature edits no `.py`/`.ps1`/`.ts`/`.cs` production or test file (independently confirmed later by P11-T4). Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/baseline/phase0-instructions-read.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Policy Order:`, and the explicit list of files read.
  - Acceptance: the artifact exists, lists all five files in the stated order, and includes a one-line statement that no language-specific rule file applies.

- [ ] [P0-T2] Run `git rev-parse HEAD` and record the result as `F7_START_SHA` — the commit at which this plan's own execution begins, used by P11-T4 to scope the later no-code-change check to this plan's own commits only, excluding F2–F6's already-merged changes. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/baseline/f7-start-sha.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command: git rev-parse HEAD`, `EXIT_CODE:`, `Output Summary: <the resolved 40-character SHA>`.
  - Acceptance: the artifact records a 40-character hex SHA and `EXIT_CODE: 0`.

- [ ] [P0-T3] Run `git merge-base origin/main HEAD` and record the result as `EPIC_BASE_SHA` — the epic branch's fork point from `main`, reused by P1-T3 (dependency gate) and P2-T1/P2-T2 (literal derivation) as the pre-fix reference point. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/baseline/epic-base-sha.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command: git merge-base origin/main HEAD`, `EXIT_CODE:`, `Output Summary: <the resolved 40-character SHA>`.
  - Acceptance: the artifact records a 40-character hex SHA distinct from `F7_START_SHA`, with `EXIT_CODE: 0`.

- [ ] [P0-T4] Run `Get-ChildItem -Path "$env:USERPROFILE\.vscode\extensions","$env:USERPROFILE\.vscode-insiders\extensions" -Directory -Filter '*drm-copilot*'`, and for each matched directory read its `package.json` version and the file count under `resources/claude-customizations/.claude/hooks/`. Record the pre-rebuild directory list, versions, and hook counts in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/baseline/installed-extensions-pre-rebuild.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: <per-directory version/hook-count table>`. Re-discovery is required rather than reuse of the four directories the research recorded, because the installed set can change between the research session and execution.
  - Acceptance: the artifact lists every directory the command discovers (zero discovered directories is itself a valid, recorded finding) with the version/hook-count table populated for each.

- [ ] [P0-T5] Run `Get-ChildItem -Recurse -Path tests/scripts/claude-lib -Filter '*.Manifest.Tests.ps1' | Select-Object -ExpandProperty FullName` and record the file count and list as a starting-state snapshot at the beginning of F7's own execution. Because F1 merges in epic wave 0, before F7's wave 2 execution begins, this snapshot already includes F1's own `<ModuleName>.Manifest.Tests.ps1`; it is retained for audit trail only and is not used by P6-T1 as a count-delta baseline, since no task between P0-T5 and P6-T1 adds a file within F7's own execution. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/baseline/manifest-tests-pre-f1.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: <file count and list>`. This repository holds 6 such files at plan-authoring time (`blast-radius`, `codex-routing`, `discovery-validation`, `model-routing`, `orchestrator-state`, `project-file-merge`), verified by Glob; re-verify at execution time rather than trusting this count.
  - Acceptance: the artifact records a numeric file count and the full file list, with `EXIT_CODE: 0`.

### Phase 1 — Dependency Gate: Confirm F2–F6 Content Is Present on the Build Branch

- [ ] [P1-T1] Read the `features:` list in `docs/features/epics/worktree-scoped-state-resolution/epic.md` at execution time and record the current `feature_folder` value for each of F2 (`preimplementation-gate-worktree-selector`), F3 (`epic-merge-gate-authorization-record`), F4 (`prd-feature-gate-target-resolution`), F5 (`false-approval-elimination-pr-author-model-routing`), and F6 (`collect-pr-context-explicit-target`) in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/dependency-gate-folders.<yyyy-MM-ddTHH-mm>.md`, with `Timestamp:` and the five folder names. This grounds P1-T2 on the manifest as it exists at execution time, not on this authoring pass's snapshot.
  - Acceptance: the artifact lists exactly five folder names, one per feature ref F2–F6.

- [ ] [P1-T2] For each of the five folder names recorded in P1-T1, run `Get-ChildItem -Directory -Path docs/features/active,docs/features/completed -Filter '*-<feature_folder>-*'` (substituting each folder name) and confirm exactly one match across the combined result set per folder. Both lifecycle locations must be searched together, not `completed` alone: `.claude/skills/epic-orchestrate/SKILL.md` (lines 56-58, 186-189) states a dependency's `feature_folder` resolves under either `docs/features/active/` or `docs/features/completed/` depending on its lifecycle state at emit time, no step moves a merged child's folder to `completed/` automatically, and F7 runs in wave 2 immediately after wave 1, so F2–F6's folders will in all likelihood still be under `docs/features/active/` when this task runs. Record all five invocations in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/dependency-gate-completed-folders.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` naming the matched folder and which of the two directories it was found under, for each of F2–F6. For any folder returning zero matches across both locations, additionally record `SearchScope: docs/features/active, docs/features/completed`, `SearchPatterns: *-<feature_folder>-*`, `SearchResult: none`. If any of the five returns zero matches across both locations, this task fails and Phase 3 must not proceed until it is resolved.
  - Acceptance: the artifact records exactly one matched folder, with its lifecycle location named, across the combined `docs/features/active` and `docs/features/completed` search, for each of the five feature folders.

- [ ] [P1-T3] Using `EPIC_BASE_SHA` from P0-T3, run `git log --oneline EPIC_BASE_SHA..HEAD -- <path>` for each of six target paths: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (F2), `.claude/hooks/enforce-epic-merge-gate.ps1` (F3), `.claude/hooks/enforce-prd-feature-before-planner.ps1` (F4), `.claude/hooks/enforce-pr-author-skill.ps1` (F5), `.claude/hooks/enforce-model-routing-receipt.ps1` (F5), and `extensions/drm-copilot/src/lib/pr-context/git-client.ts` (F6). Confirm each invocation returns at least one commit line. Record all six invocations and their output in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/dependency-gate-commit-history.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. This is a second, independent signal alongside P1-T2's folder check; if any of the six returns zero lines, this task fails and Phase 3 must not proceed.
  - Acceptance: the artifact records at least one commit line for each of the six invocations.

### Phase 2 — Derive and Validate the Changed-Content Literal

- [ ] [P2-T1] Using `EPIC_BASE_SHA` from P0-T3, run `git diff EPIC_BASE_SHA..HEAD -- .claude/hooks/ .claude/lib/` and select one added, single-line, non-interpolated literal (containing none of `<`, `>`, `${`, `$(`, `%`) unique to the new content of one specific file. Record the selected literal, its source file's repo-relative path, and the diff excerpt it was drawn from in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/literal-derivation.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`.
  - Acceptance: the artifact names one concrete literal and one concrete source-file path, both quoted verbatim.

- [ ] [P2-T2] Confirm the local working tree is clean for the P2-T1 source file (`git status --porcelain -- <source-file-path>` returns empty), then run `git show EPIC_BASE_SHA:<source-file-path>` piped to a fixed-string search for the P2-T1 literal, and confirm the match count is `0`. Append the command, its output, and `EXIT_CODE:` to the P2-T1 artifact, plus `SearchScope: EPIC_BASE_SHA:<source-file-path>`, `SearchPatterns: <the literal>`, `SearchResult: 0 matches`.
  - Acceptance: the recorded match count is exactly `0`; a non-zero count means the literal is not unique to the fix and P2-T1 must select a different literal before this task can close.

- [ ] [P2-T3] Run a fixed-string search for the P2-T1 literal against the current (`HEAD`, i.e., the checked-out working copy) version of `<source-file-path>` and confirm the match count is greater than `0`. Append the command, its output, and `EXIT_CODE:` to the P2-T1 artifact.
  - Acceptance: the recorded match count is `>= 1`.

- [ ] [P2-T4] Close the P2-T1 artifact with a one-line summary: "Literal `<the derived literal>` confirmed present in `<source-file-path>` at `HEAD` and absent at `EPIC_BASE_SHA`; this is the literal used identically by P5-T2 and P9-T1."
  - Acceptance: the closing line names the literal, the source file, and both downstream task IDs (P5-T2, P9-T1) that reuse it.

### Phase 3 — Rebuild and Reinstall the Extension

- [ ] [P3-T1] Run `code-insiders --version` (or `code --version` if the executor's install targets stable VS Code) and confirm it exits `0` and prints a version string, before relying on the sideload script. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/vscode-cli-check.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: <printed version string>`.
  - Acceptance: `EXIT_CODE: 0` and the artifact records a non-empty printed version string.

- [ ] [P3-T2] Run `pwsh -NoProfile -File scripts/dev-tools/publish-sideloaded-extension.ps1 -UseInsiders -Force` from the repository root. Record the exit code together with the full captured stdout/stderr output — not the exit code alone, since a `0` exit here does not by itself prove the running VS Code window will serve the new payload; that is Phase 5's job. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/rebuild-reinstall.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: <verbatim captured output, including the vsce package path and the install command's own printed result>`.
  - Acceptance: `EXIT_CODE: 0` and the artifact's `Output Summary:` contains the actual captured output of the run, not a paraphrase.

### Phase 4 — Human Exception HI-2: Reload the VS Code Window

- [ ] [P4-T1] Hand off to the operator per `runbooks/reload-vscode-window-for-mcp-payload.runbook.md`: identify the target VS Code Insiders window (runbook Step 1–2) and run "Developer: Reload Window" (Step 3) or the documented restart fallback (Step 4). Record the hand-off in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/reload-handoff.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:` and a one-line statement of which action the operator took (reload vs. restart). Do not proceed to Phase 5 until the operator confirms the action was taken; Phase 5's grep, not this task, is the proof it took effect.
  - Acceptance: the hand-off artifact records `Timestamp:` and states which of the two actions was performed.

### Phase 5 — Installed-Payload Freshness Grep (Proves HI-2 Took Effect)

- [ ] [P5-T1] Re-run the P0-T4 discovery command (`Get-ChildItem -Path "$env:USERPROFILE\.vscode\extensions","$env:USERPROFILE\.vscode-insiders\extensions" -Directory -Filter '*drm-copilot*'`) and record the post-reload directory list in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/installed-extensions-post-reload.<yyyy-MM-ddTHH-mm>.md`, since the installed set may differ from P0-T4's baseline (a duplicate `undefined_publisher.drm-copilot` identity was observed coexisting with the current publisher identity during research and must not be assumed absent).
  - Acceptance: the artifact lists every directory discovered in this pass with a note comparing the count against P0-T4's baseline.

- [ ] [P5-T2] For every directory recorded in P5-T1, run a fixed-string search for the P2-T4 literal against that directory's `resources/claude-customizations/.claude/hooks/` tree, and record per-directory whether the literal was found. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/freshness-grep.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:` (one line per directory), `EXIT_CODE:` (per invocation), `Output Summary:` (per-directory PASS/FAIL). This artifact (`freshness-grep.<ts>.md`) is the plan's realization of the runbook's own `reload-vscode-window.<ts>.md` write-back requirement (`runbooks/reload-vscode-window-for-mcp-payload.runbook.md`, "What to Write Back (Evidence)"); the substitution of filename is intentional and this note satisfies the runbook's citation. For any directory where the literal is absent, additionally record `SearchScope: <directory>/resources/claude-customizations/.claude/hooks/`, `SearchPatterns: <the P2-T4 literal>`, `SearchResult: none`. If the literal is absent from the directory the active window is confirmed to have loaded (or that directory cannot be determined), this task fails and Phase 4 must repeat before Phase 6 proceeds.
  - Acceptance: the literal is found (match count `>= 1`) in the directory the active window loaded, per the runbook's Verification section; the artifact states which directory that is and how it was determined.

### Phase 6 — Manifest-Registration Check for F1's Module

- [ ] [P6-T1] Locate F1's feature folder by running `Get-ChildItem -Directory -Path docs/features/active,docs/features/completed -Filter '*-target-worktree-resolution-module-*'` (F1, issue #1001) and confirming exactly one match across the combined result set, using the same both-locations lookup mechanism P1-T2 uses and for the same reason: F1 merges in epic wave 0, but nothing moves a merged child's folder to `docs/features/completed/`, so F1's folder may still be under `docs/features/active/` when this task runs. From the matched folder, read F1's plan or spec to identify F1's module directory name and `ModuleName` (the existing pattern `ModelRouting.Manifest.Tests.ps1` under `tests/scripts/claude-lib/model-routing/` establishes the naming convention). Then run `Get-ChildItem -Recurse -Path tests/scripts/claude-lib -Filter '*.Manifest.Tests.ps1' | Select-Object -ExpandProperty FullName` and confirm the returned list includes `tests/scripts/claude-lib/<F1-module-dir>/<F1-ModuleName>.Manifest.Tests.ps1` by exact path match. P0-T5's snapshot is retained for audit trail only and is not the basis for this check: it is a starting-state record taken before F7's own execution, not a pre-F1 baseline, since F1 already merged in wave 0. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/manifest-registration.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: <the full file list and an explicit statement of whether F1's named file is present>`. If F1's named file is absent from the list, run the parameterized fallback instead: `grep -c '".claude/lib/<F1-module-dir>/<F1-ModuleName>.psm1"' extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (using the same F1 module directory and file stem identified above), and confirm the result is `1`. Either check failing blocks Phase 8.
  - Acceptance: either F1's named `<ModuleName>.Manifest.Tests.ps1` file is present by exact path match in the P6-T1 discovery list, or the fallback grep returns exactly `1`.

- [ ] [P6-T2] Run `Invoke-Pester -Path <the file list from P6-T1> -PassThru` and confirm the returned result object's `FailedCount` is `0`. Append the command, its output, and `EXIT_CODE:` to the P6-T1 artifact.
  - Acceptance: `FailedCount -eq 0` for every discovered `*.Manifest.Tests.ps1` file, including F1's new one.

### Phase 7 — Destination Pre-Check for an Un-superseded Local Hand-Fix

- [ ] [P7-T1] Record the operator-supplied TaskMaster `workspace_root` absolute path in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/workspace-root.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:` and the literal path string, since the tool has no discovery logic for this value and it must not be invented.
  - Acceptance: the artifact records one absolute path string supplied by the operator.

- [ ] [P7-T2] Confirm the local working tree is clean for `.claude/hooks/enforce-model-routing-receipt.ps1` (`git status --porcelain -- .claude/hooks/enforce-model-routing-receipt.ps1` returns empty), then run `git diff --no-index .claude/hooks/enforce-model-routing-receipt.ps1 <workspace_root>/.claude/hooks/enforce-model-routing-receipt.ps1` and record whether the two files are identical (empty diff, exit code `0`) or differ (non-empty diff, exit code `1`). Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/handfix-precheck.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: the artifact records one of the two outcomes with the actual diff output (or its confirmed absence) attached.

- [ ] [P7-T3] If P7-T2 found the files identical, record `SearchScope: <workspace_root>/.claude/hooks/enforce-model-routing-receipt.ps1`, `SearchPatterns: byte-for-byte diff against the local working copy`, `SearchResult: none — no un-superseded hand-fix present` in the P7-T2 artifact, and close this task PASS. If P7-T2 found the files differ, run a fixed-string search for the P2-T4 literal against `<workspace_root>/.claude/hooks/enforce-model-routing-receipt.ps1`; if found, record the destination already carries the upstream fix and close PASS; if not found, record `SearchScope: <workspace_root>/.claude/hooks/enforce-model-routing-receipt.ps1`, `SearchPatterns: <the P2-T4 literal>`, `SearchResult: none`, state the destination carries an un-superseded local difference, and close FAIL; Phase 8 must not run the push-down against `.claude/hooks/enforce-model-routing-receipt.ps1` until the difference is confirmed superseded.
  - Acceptance: the P7-T2 artifact carries an explicit PASS or FAIL conclusion for this check, stated in one sentence, with the negative-claim fields present when the conclusion asserts absence.

### Phase 8 — Push-Down Invocation

- [ ] [P8-T1] Invoke `mcp__drm-copilot__push_down_claude_customizations` with `workspace_root` set to the P7-T1 path and `packs: ["core"]`, only after Phases 1, 5, 6, and 7 have each closed PASS. Record the tool's returned `PushDownServiceCallResult` (summary text, `created_count`, `overwritten_count`, and the artifact path it wrote) verbatim in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/push-down-result.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command: <the tool invocation and its arguments>`, `EXIT_CODE:` (or the tool's success/error field), `Output Summary:`. Explicitly state in the artifact that this result proves a copy action ran and which paths were touched, and does not by itself prove which content version was copied — Phase 9 is required for that.
  - Acceptance: the artifact records the verbatim tool result and the explicit disclaimer sentence above.

### Phase 9 — Destination-Content Grep and Overwrite-Safety Confirmation

- [ ] [P9-T1] Run a fixed-string search for the P2-T4 literal against `<workspace_root>/<source-file-path>` (the same source-file path recorded in P2-T1) at the destination, using the identical literal used in P5-T2, and confirm the match count is `>= 1`. If the match count is 0, additionally record `SearchScope: <workspace_root>/<source-file-path>`, `SearchPatterns: <the P2-T4 literal>`, `SearchResult: none`; this task fails, and Phase 10 must not proceed until the discrepancy is resolved. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/destination-content-grep.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and an explicit citation of P2-T4 confirming the literal is identical to the one used in P5-T2. This grep result, not P8-T1's exit code or JSON summary, is the evidence of record for content delivery.
  - Acceptance: the match count is `>= 1` and the artifact cites P2-T4 and P5-T2 by task ID as the source of the identical literal. On a 0 match count, the artifact instead records the three negative-claim fields above and the task is marked FAIL rather than closed PASS.

- [ ] [P9-T2] Record the final overwrite-safety conclusion in the P9-T1 artifact, restating the P7-T3 finding: either no un-superseded local fix existed before the push-down, or the un-superseded fix was confirmed superseded before the push-down ran, so no destination fix was lost. State this in one sentence citing P7-T3 by task ID.
  - Acceptance: the P9-T1 artifact contains one sentence citing P7-T3's PASS conclusion, or, if P7-T3 was FAIL, a statement that the push-down did not run against the affected path and why.

### Phase 10 — Human Exception HI-1: Confirm TaskMaster Run Resume

- [ ] [P10-T1] Only after P9-T1 has closed with a `>= 1` match count, hand off to the operator per `runbooks/confirm-taskmaster-run-resume.runbook.md`: execute Steps 1–7 (locate run `bugs-2026-09-11`'s state, record the pre-resume baseline, resume the run, observe the five previously gate-blocked items and the one previously unlandable fix, and identify which item's checkpoint each deciding gate consulted). Confirm the operator's own evidence artifact exists at `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/confirm-run-resume.<yyyy-MM-ddTHH-mm>.md` and contains a one-sentence PASS or FAIL conclusion per the runbook's Verification section, including the false-approval check (step 6) result for every item that proceeded.
  - Acceptance: the runbook's own evidence artifact exists, is dated after P9-T1's artifact, and contains an explicit one-sentence PASS or FAIL conclusion plus the step-6 checkpoint-identity finding for each proceeding item.

### Phase 11 — Acceptance-Criteria Check-off, Negative-Claim Audit, and Scope Statement

- [ ] [P11-T1] For each of the 9 acceptance criteria in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/spec.md`'s `## Acceptance Criteria` section, change `- [ ]` to `- [x]` once the corresponding phase task(s) above have closed PASS with their evidence artifact in hand, per the acceptance-criteria-tracking skill's check-off protocol (one at a time, evidence before check-off, no text changes beyond the checkbox).
  - Acceptance: all 9 checkboxes in `spec.md` are `[x]`, or any remaining `[ ]` item is documented in this task's own note as an unmet criterion with its blocking evidence artifact named.

- [ ] [P11-T2] Repeat P11-T1 against `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/user-story.md`'s `## Acceptance Criteria` section, independently, per the acceptance-criteria-tracking skill's requirement to track each AC source file separately.
  - Acceptance: all 9 checkboxes in `user-story.md` are `[x]`, or any remaining `[ ]` item is documented with its blocking evidence artifact named.

- [ ] [P11-T3] Grep every file under `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/` for the label `SearchScope:` and record the total match count found. This count is execution-time-contingent: P2-T2 unconditionally contributes exactly one match every run; P1-T2, P5-T2, P7-T3, and P9-T1 each contribute a match only if their own task's absence or failure branch fired during this run, which a fully successful execution is not guaranteed to trigger. For every matched file, confirm each `SearchScope:` line is accompanied by a `SearchPatterns:` and a `SearchResult:` line in the same file. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/qa-gates/negative-claim-audit.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: <total match count and file list>`.
  - Acceptance: `Output Summary:` records at least 1 match (P2-T2's unconditional entry, which must always be present) and, for every matched file, both companion labels (`SearchPatterns:`, `SearchResult:`) are also present in that file. If additional matches exist from P1-T2, P5-T2, P7-T3, or P9-T1, each is subject to the same companion-label check.

- [ ] [P11-T4] Run `git diff --name-only F7_START_SHA..HEAD -- '*.py' '*.ps1' '*.psm1' '*.ts' '*.tsx' '*.cs'` (using `F7_START_SHA` from P0-T2) and `git status --porcelain -- '*.py' '*.ps1' '*.psm1' '*.ts' '*.tsx' '*.cs'`, and confirm both return empty output, proving this plan's own execution added or modified no Python, PowerShell, TypeScript, or C# production or test file. Record in `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/qa-gates/no-code-toolchain-surface.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:`, `Command:` (both invocations), `EXIT_CODE:`, `Output Summary: <both outputs, expected empty>`. This is the checked basis for this plan's declared omission of the mandatory seven-stage toolchain loop: no such loop applies because no covered-language file was touched by this feature's own work.
  - Acceptance: both commands return empty output and `EXIT_CODE: 0`; a non-empty result means this plan's execution exceeded its procedural-delivery scope and must be investigated before the plan is reported complete.

## Test Plan

- Unit / integration: none authored or required. This feature adds no production or test code (confirmed by P11-T4). The one pre-existing test suite this plan depends on (`tests/scripts/claude-lib/**/*.Manifest.Tests.ps1`, Pester) is exercised read-only in Phase 6 to verify a registration fact, not modified.
- Manual/CLI: Phases 3, 5, 6, 7, 8, and 9 are CLI/MCP-tool verification steps; Phases 4 and 10 are human-exception runbook hand-offs (HI-2, HI-1).
- Coverage evidence: not applicable. No language in scope carries a coverage obligation for this feature, per the Plan Scope and Constraints section above and the P11-T4 check.

## Open Questions / Notes

- The exact literal (P2-T1) and F1's exact module name/path (P6-T1) cannot be fixed at authoring time because F1–F6 have not executed; both are execution-time derivations with their own checkable acceptance conditions, not open scope questions.
- The TaskMaster `workspace_root` (P7-T1) is an operator-supplied external input with no discovery logic in the tool; it is not invented by this plan.
