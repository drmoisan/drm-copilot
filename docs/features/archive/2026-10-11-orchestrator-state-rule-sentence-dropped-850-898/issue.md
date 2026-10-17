# orchestrator-state-rule-sentence-dropped-850 (Issue #898)

- Work Mode: minor-audit
- Issue: #898
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/898
- Promotion type: bug
- Issue adoption: filed_before_orchestration (verified with `gh issue view 898` on 2026-10-11)
- Lifecycle record: `origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-11-orchestrator-state-rule-sentence-dropped-850.md` (cited by ref; not copied)
- Parallel run: bug-burndown-2026-10-11 (group P11)
- Last Updated: 2026-10-11

## Problem / Why

The #850 spec (`docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md:48`) included a one-sentence documentation alignment in `.claude/rules/orchestrator-state.md` stating which per-feature checkpoint the merge gate consults for an explicit pull request number. The #850 plan (decision D4) dropped it because the file is a policy document that agents may not modify without operator approval. The sentence is absent on main in both the rule and its bundled mirror, and `spec.md:284` of the #850 folder still states "`orchestrator-state.md` updated", which is inaccurate.

## Operator Approval

Recorded 2026-10-11 by the operator in the delegation prompt for parallel run bug-burndown-2026-10-11 (group P11):

- APPROVED: adding the #850 sentence to `.claude/rules/orchestrator-state.md` and its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`.
- The approval covers that sentence only. No other edit to any file under `.claude/rules/` or `.github/instructions/` is approved.

## Implementation Intent

1. Append the following sentence, verbatim and on the same line, after the final sentence of `.claude/rules/orchestrator-state.md:238` ("... and only after its per-feature, epic, and parallel allow conditions have all declined."), separated by one space, and make the identical edit in the bundled mirror:

   For a command that names an explicit pull request number, the gate reads the per-feature checkpoint `artifacts/orchestration/orchestrator-state.json` beneath the one live worktree whose checkpoint records that number in `pr_gate.pr_number` or in a `standalone_merge_authorizations` entry, and it reads no per-feature checkpoint when no live worktree or more than one records it; a bare command reads the checkpoint beneath the session worktree.

   The wording was verified against the current merge-gate code (`.claude/hooks/enforce-epic-merge-gate.ps1:358-371`, `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`); see `research/2026-10-11T13-45-orchestrator-state-rule-sentence-research.md`. The pr-author hook resolves by issue or branch, not by pull request number, so the sentence describes the merge gate only.

2. Insert a dated correction sub-bullet directly after `spec.md:284` of the #850 folder:

   - Correction (2026-10-11): `orchestrator-state.md` was not updated under #850; plan decision D4 dropped the one-sentence alignment named in the In-scope list, and the sentence stating which per-feature checkpoint the merge gate reads for an explicit pull request number lands under #898. The #788 behavior change and its remedy are documented in this spec (Accepted behavior change, #788).

## Acceptance Criteria

- [x] AC-1: `.claude/rules/orchestrator-state.md` line 238 ends with the Implementation Intent sentence verbatim, appended after "have all declined." on the same line, and no other line of the file changes relative to `origin/main`.
- [x] AC-2: `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` is byte-identical to `.claude/rules/orchestrator-state.md`, and the bundle parity test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
- [x] AC-3: `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md` carries the dated "Correction (2026-10-11)" sub-bullet directly after the `orchestrator-state.md updated` mitigation line, and the original line text is unchanged.
- [x] AC-4: No file under `.claude/rules/` or `.github/instructions/` other than the two approved copies of `orchestrator-state.md` changes relative to `origin/main`.
- [x] AC-5: The existing Python tests that read `.claude/rules/orchestrator-state.md` pass after the edit.

## Dependencies / Risks

- Parallel item #886 edits line 204 of the same two files (`sys.path` append to insert-first). Whichever item merges second must rebase and re-run the parity test. Line 204 is out of scope here and must not be edited.
- The rule file is a policy document; any edit beyond the approved sentence violates the operator approval.

## Verification Steps

- Pytest: bundle parity test and the rule-content tests named in the research file.
- `git diff origin/main --name-only` limited to `.claude/rules/` and `.github/instructions/`.
- Byte comparison of the rule and its mirror.

## Evidence Checklist

- [x] baseline
- [x] targeted verification
- [x] end-state
