# Research: orchestrator-state rule sentence dropped from #850 (issue #898)

- **Issue:** #898
- **Mode:** preparation, research only
- **Branch:** `bug/orchestrator-state-rule-sentence-dropped-850-898` (based on `origin/main` 2ef8d361e)
- **Date:** 2026-10-11
- **Scope of edit approved by the operator:** one sentence in `.claude/rules/orchestrator-state.md` (section "Standalone-Merge-Authorization Scope and Backward Compatibility", paragraph at line 238) and the same sentence in the bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`.

All citations are against the current worktree tree. Items not verified by a tool call are marked "unverified".

## 1. Current State: how the gates select the per-feature checkpoint for an explicit pull request number

### 1.1 Merge gate (`gh pr merge --merge`)

Entry and wiring:

- `.claude/hooks/enforce-epic-merge-gate.ps1:72` dot-sources `enforce-epic-merge-gate-resolution.ps1`, which imports `WorktreeRunResolution.psm1` and `WorktreeItemResolution.psm1` behind a dependency guard that turns a failed import into a deny (`.claude/hooks/enforce-epic-merge-gate-resolution.ps1:9-13,35-36`).
- The explicit number is taken only from the segment that invokes `gh pr merge`: first all-digit positional operand, else the `--merge` flag value; a bare command yields `$null` (`.claude/hooks/enforce-epic-merge-gate.ps1:99-143`).

Per-feature (child) checkpoint selection, `.claude/hooks/enforce-epic-merge-gate.ps1:358-375`:

1. `$sessionRoot` is the session's worktree root (`:359`; `.claude/hooks/enforce-epic-merge-gate-resolution.ps1:98-110`).
2. Bare command (no number): the child checkpoint is read beneath the session worktree (`:365-366`).
3. Explicit number: `Resolve-EpicMergeGateItemTarget -PrNumber N` (`:368`), which calls `Resolve-WorktreeItemTargetByPrNumber` (`.claude/hooks/enforce-epic-merge-gate-resolution.ps1:133-149`). The child root is the resolved `WorktreeRoot` only when the status is `SessionRoot` or `OtherWorktree`; otherwise it is `$null` and no per-feature checkpoint is read (`.claude/hooks/enforce-epic-merge-gate.ps1:369-371`). There is no fallback to the session root for an explicit number.
4. The file read is always `artifacts/orchestration/orchestrator-state.json` beneath the chosen root (`Get-WorktreeRunCheckpointPath -Kind item`, `:371`; the relative path literal is defined at `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:37`).

Resolver semantics, `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`:

- **What is matched** (`Test-WorktreeItemCheckpointRecordsPr`, `:399-427`): a checkpoint matches when `pr_gate.pr_number` parses (via `[long]::TryParse` of its string form) to N (`:415-418`), or when any `standalone_merge_authorizations` entry has a `pr_number` that is a JSON integer (`[int]`/`[long]`), greater than zero, equal to N (`:419-425`). Nothing else is read: not the branch, not `issue-num`, not `session_id`. A `pr_gate.pr_number` that differs from N does not prevent a standalone entry from matching at this stage.
- **What counts as a live worktree** (`Get-WorktreeItemLiveRoot`, `:180-215`): the session path is ascended to its worktree root; candidates are the main checkout plus each linked worktree registered under the common git directory's `worktrees/<name>/gitdir` files (`.claude/lib/worktree-resolution/WorktreeResolution.psm1:334-363`); a candidate is kept only if its root still carries a worktree marker (a `.git` directory, or a `.git` file whose first line is a `gitdir:` line; `WorktreeResolution.psm1:12-15`, `WorktreeItemResolution.psm1:209-213`). No `git worktree list` subprocess is started (`WorktreeResolution.psm1:18-19,339`).
- **Outcomes and tie-breaks** (`Resolve-WorktreeItemTargetByPrNumber`, `:429-472`): N <= 0 is `NoTarget` (`:453-455`); zero matching live worktrees is `NoTarget` (`:463-465`); exactly one is resolved and labelled `SessionRoot` or `OtherWorktree` (`:466-468`; labelling at `:217-257`); more than one is `Ambiguous` with no tie-break, and the detail tells the operator to move the stale checkpoint to `artifacts/orchestration/handoff/` (`:470-471`). The doc comment states "several are Ambiguous with no tie-break" (`:436`).

After selection:

- The child branch allows only if the checkpoint has `epic_mode == true` and `step9_status == "passed"` (`Test-ChildCheckpointAllowsEpicMerge`, `.claude/hooks/enforce-epic-merge-gate.ps1:145` onward) and `Test-ChildCheckpointPrGateBinding` binds N (`:372-375`). The binding is stricter than the resolver: if `pr_gate.pr_number` is recorded it must equal N, and only when `pr_gate.pr_number` is absent does a positive-integer standalone entry naming N satisfy it (`.claude/hooks/enforce-epic-merge-gate-resolution.ps1:151-203`).
- The same resolved per-feature checkpoint is also one of the three checkpoints passed to the standalone branch 4 (`.claude/hooks/enforce-epic-merge-gate.ps1:400-404`).
- The epic and parallel checkpoints are resolved separately by run record (`Resolve-WorktreeRunTargetByRecord -RecordField pr_number`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1:112-131`; gate `:377-398`).
- When the item, epic, and parallel targets are all unresolved, the deny reason is prefixed with the resolution code and the three details (`Get-EpicMergeGateUnresolvedReason`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1:205-243`; gate `:408-412`).
- The gate's own header states the same contract: "Issue #850: with an explicit PR number, the per-feature checkpoint is read beneath the live worktree whose checkpoint records the number in pr_gate.pr_number or a standalone record ... A bare command reads every checkpoint beneath the session worktree." (`.claude/hooks/enforce-epic-merge-gate.ps1:41-46`).

### 1.2 pr-author hook (`gh pr create` / `gh pr edit`)

The pr-author hook does not resolve by pull request number. It resolves the target worktree from the command text by portable identity: the canonical issue-number line and a branch signal (`--head`, `--branch`, or `branch:`), via `Resolve-WorktreeItemTarget` (`.claude/hooks/enforce-pr-author-skill-helpers.ps1:55-76`; resolver at `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:352-397`). `NoTarget` and `Ambiguous` deny; there is no fallback to the session root's checkpoint (`.claude/hooks/enforce-pr-author-skill-helpers.ps1:84-95,123`). The #850 spec lists `gh pr edit <N>` resolution by pull request number as a follow-up candidate, not delivered (`docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md:290`).

Consequence for the sentence: it should describe the merge gate only. It must not claim that the pr-author hook selects by pull request number.

## 2. Draft sentence vs. code; recommended wording

Draft intent (`docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/research/research.2026-10-08T14-00.md:354`): "for an explicit PR number, the per-feature checkpoint consulted by the merge gate is the live worktree whose checkpoint records that number in `pr_gate.pr_number` or a `standalone_merge_authorizations` entry."

Assessment:

- The matched fields are correct (section 1.1).
- Imprecise: a checkpoint is not a worktree; the checkpoint is read beneath the worktree.
- Incomplete: it does not state the zero-match and multiple-match outcomes (no per-feature checkpoint is read, no tie-break, no session-root fallback), which are the behaviors most likely to surprise an operator.
- It omits the bare-command case, which reads the session worktree. Including it keeps the sentence self-contained.
- It does not mention the positive-JSON-integer requirement on the standalone `pr_number`; this is already stated by invariant 1 (`.claude/rules/orchestrator-state.md:246`), so repeating it is unnecessary.

Rejected alternatives (brief): the draft verbatim (imprecise, as above); a two-sentence version that also restates the #788 binding (exceeds the approved one-sentence scope and duplicates detail that lives in the hook).

### Recommended sentence (verbatim, single line)

```text
For a command that names an explicit pull request number, the gate reads the per-feature checkpoint `artifacts/orchestration/orchestrator-state.json` beneath the one live worktree whose checkpoint records that number in `pr_gate.pr_number` or in a `standalone_merge_authorizations` entry, and it reads no per-feature checkpoint when no live worktree or more than one records it; a bare command reads the checkpoint beneath the session worktree.
```

### Insertion location

Append to the end of line 238 of `.claude/rules/orchestrator-state.md`, after the existing last sentence "...and only after its per-feature, epic, and parallel allow conditions have all declined.", separated by one space, on the same line. The paragraph is a single physical line (`.claude/rules/orchestrator-state.md:238`), so this is a one-line edit with no new line or blank line. Apply the identical edit to line 238 of `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`, whose lines 234-238 read identically to the primary (verified by reading both files). Appending, rather than a new paragraph, keeps the sentence with the paragraph that already describes when "the gate" consults checkpoints, so "the gate" has the same antecedent.

## 3. Parity and content tests

### 3.1 Byte/content parity between the rule and its mirror

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`:89-110`) enumerates every distributable repo `.claude/**` file and asserts it exists in the bundle and that the UTF-8 text equals the repo text. `.claude/rules/**` is not excluded by `filter_distributable_claude_paths` (no `rules` reference in `tests/scripts/dev_tools/claude_payload_scope_test_support.py`). This is a decoded-text comparison, not a `read_bytes()` comparison; it fails if the sentence is added to one copy only.
- No test pins `orchestrator-state.md` specifically with `read_bytes()`. Searched `MIRROR_PAIRS` in `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:72-87` (does not include it) and the `read_bytes`/`Get-FileHash` users across `tests/` and `extensions/drm-copilot/test/` (none target it).
- Run (pytest, not Pester or Jest): `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k all_repo_runtime_contracts`. Full file: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- Known local hazard (from prior sessions; unverified in this tree): a bundle-parity failure on gitignored local state (issue #510) can appear locally and be green in CI. Read the failing path before attributing a failure to this edit.

### 3.2 Tests or validators that assert on the rule's content

Python tests that read `.claude/rules/orchestrator-state.md` all scope their assertions to named sections other than the Standalone section:

| Test file | Section(s) asserted |
|---|---|
| `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py:37-39,245` | `## Required Top-Level Keys` (bounded by `## Foreign Schema Warning` and `## Scope and Backward Compatibility`), `## Bare-Module CLI Contract` |
| `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py:176` | `## Blocked-Reason Vocabulary` |
| `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py:39,49` | `## Invariants (remediation_loop.review_outcomes)` and the rules introduction |
| `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py:44,49` | `## Invariants (issue_adoption object)` |
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:412` | frontmatter `paths:` only |

No line-count, whole-file hash, or snapshot assertion on this file was found. No Pester suite under `tests/scripts/claude-hooks/` references it. No Jest test under `extensions/drm-copilot/test/` references `.claude/rules`. The hook string at `.claude/hooks/enforce-epic-merge-gate-authorization.ps1:54` cites the section by name ("the Standalone-Merge-Authorization section"); the heading is unchanged by this edit.

### 3.3 Manifests and hash files in `extensions/drm-copilot`

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:83` lists `.claude/rules/orchestrator-state.md` as a path only. No `sha256`/hash/integrity field exists in any pack manifest (zero matches under `pack-manifests/`).
- The only JSON under `extensions/drm-copilot` containing "sha256" is `resources/config/orchestration-handoff.schema.json`, which is unrelated to bundled-resource hashing.
- The installed extension serves the packaged payload, so a push-down does not reflect the edit until rebuild and reinstall (prior-session observation; not re-verified here). This does not affect tests.

## 4. Copilot surface under `.github/`

No copy of this rule exists under `.github/`. `**/orchestrator-state.md` matches only the primary and the bundled mirror. No file under `.github/` contains `standalone_merge_authorizations` or the path `rules/orchestrator-state`; no `.github/instructions/*orchestrat*` file exists. The 11 `.github/` files that mention "orchestrator-state" refer to the checkpoint concept, not this rule. Reported only; no edit proposed.

## 5. #850 spec line 284 and proposed correction note

Current text, `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md:284` (under `## Risks & Mitigations`):

> - Risk: epic children on routes without `pr_gate` lose explicit-number merges (#788). Mitigation: documented as an accepted behavior change with its remedy; `orchestrator-state.md` updated.

The clause "`orchestrator-state.md` updated" is inaccurate. Plan decision D4 dropped the edit (`plan.2026-10-08T13-54.md:85`), and the feature audit and policy audit both recorded the gap (`feature-audit.2026-10-09T01-12.md:19,89`; `policy-audit.2026-10-09T01-12.md:88,161`, gap G-4). The rule file contains no `788`, `850`, or `pr_gate` text today (zero grep matches). The spec's in-scope statement at `spec.md:48` and the file list at `spec.md:125` also name the edit. The accepted behavior change and its remedy are documented in the spec itself at `spec.md:163`.

Proposed correction note (insert as a new line immediately after `spec.md:284`, indented two spaces as a sub-bullet, no checkbox):

```text
  - Correction (2026-10-11): `orchestrator-state.md` was not updated under #850; plan decision D4 dropped the one-sentence alignment named in the In-scope list, and the sentence stating which per-feature checkpoint the merge gate reads for an explicit pull request number lands under #898. The #788 behavior change and its remedy are documented in this spec (Accepted behavior change, #788).
```

Format constraints: no validator that constrains the format of a feature `spec.md` body was found. Searched `.claude/hooks/*.ps1` (hits only check presence of `spec.md` per work mode, e.g. `.claude/hooks/enforce-feature-folder-order.ps1:19-20`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1:102-105`) and `scripts/dev_tools/` (18 files reference `spec.md`; they read it for PR context, blast-radius extraction, and prompt resolution, not format validation). The note carries no `- [ ]`/`- [x]` marker, so AC-checkbox tracking is unaffected. Unverified: whether `scripts/dev_tools/_blast_radius_extraction.py` would pick up the path tokens in the note if a blast-radius computation were later run against the #850 folder; the #850 feature is complete, so the practical effect is expected to be nil.

## 6. Line 204 (context for concurrent #886; no fix proposed)

Current text of the relevant sentence, `.claude/rules/orchestrator-state.md:204`: "The file-path form derives the repository root from the script location and appends it to `sys.path` only when the script runs without a package context." The mirror's line 204 is not separately quoted here; parity is enforced by the test in section 3.1. `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py:241-253` asserts only that three invocation phrases appear in that section, not the append/insert wording. Because #898 edits line 238 and #886 edits line 204 of the same two files, the two branches touch the same files on different lines; a textual merge is expected to be clean, but whichever merges second should rebase and re-run the section 3.1 parity test.

## 7. Requirements Mapping

| Requirement | Change |
|---|---|
| Add the sentence to the primary rule | Append the recommended sentence to `.claude/rules/orchestrator-state.md:238` |
| Keep the bundled mirror identical | Apply the identical append to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md:238` |
| Correct the #850 record | Add the dated sub-bullet after `spec.md:284` of the #850 feature folder |

No source code, hook, test, manifest, or `.github/` file changes are required.

## 8. Testing Implications

- No new test is required to express the behavior; the sentence documents behavior already covered by `tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1` and `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`.
- The minor-audit plan template's Phase 2 "regression test must fail first" step does not map naturally to a one-sentence documentation edit. A planner may either mark it not applicable with rationale, or use the existing parity test as the red/green check: edit the primary first, run the section 3.1 test (expected to fail on the mirror), then edit the mirror and re-run (expected to pass). A content assertion pinning the new sentence is possible but would add a test to protect prose, which the repository has done for other sections (section 3.2); whether to add one is a planning decision.
- Verification commands: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`.
- Markdown is exempt from the 500-line cap; no coverage language is in scope.

## 9. Process note

The supplied filename `research.2026-10-11T13-45.md` does not match the filename pattern enforced by the task-researcher SubagentStop hook, `^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$` (`.claude/hooks/validate-task-researcher-output.ps1:85-98,261-263`). The file was written at the supplied path as instructed. If the hook blocks completion, the conforming name would be `2026-10-11T13-45-orchestrator-state-rule-sentence-research.md` in the same folder.
