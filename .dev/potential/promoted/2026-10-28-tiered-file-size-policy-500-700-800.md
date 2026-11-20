# tiered-file-size-policy-500-700-800 (Issue #990)

- Date captured: 2026-10-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/tiered-file-size-policy-500-700-800/ (Issue #990)

- Issue: #990
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/990
- Last Updated: 2026-10-28
## Problem / Why

The repository enforces a single 500-line limit on production code, test code, and reusable script files. The limit is too restrictive: it forces splits that are not logically separable. A tiered policy keeps pressure toward smaller files while reserving hard enforcement for files that are clearly too large.

## Proposed Behavior

Replace the single 500-line limit with three tiers, applied to the files the current policy covers and subject to the existing exemption list (throwaway scripts created and deleted within an agent session, raw text fixtures for language-processing test data, Markdown documentation):

- **500 lines (guidance):** a file that reaches 500 lines prompts the author to look for logical ways to divide it into multiple files, provided the parts can be separated logically. There is no rigorous enforcement; no gate fails at this tier.
- **700 lines (advisory):** the author looks for a split more aggressively. Reviewers and `feature-review` report a non-blocking Warning finding. No gate fails at this tier.
- **800 lines (hard block):** a split is enforced regardless of logical separability. A CI/Pester check and a PreToolUse hook block a file over 800 lines.

Legacy handling is a ratchet. Files already over 800 lines are recorded in a baseline list; a baselined file may not grow and no new file may exceed 800 lines. Existing files are split opportunistically, not in this issue.

Surfaces: the authoritative `.github/instructions` and `.github/copilot-instructions.md` text, the `.claude/rules` and agent/skill mirrors, the `.agents` and `.codex` surfaces, the bundled copies under `extensions/drm-copilot/resources/`, the execution-environment brief (six byte-identical copies), and any hook, validator, or test that hard-codes the 500 figure.

## Acceptance Criteria (early draft)

- [ ] AC1: Policy text in every authoritative and mirrored surface states the three tiers (500 guidance, 700 advisory Warning, 800 hard block) and keeps the existing exemption list.
- [ ] AC2: No gate fails for a file between 500 and 800 lines; `feature-review` reports files over 700 lines as non-blocking Warning findings.
- [ ] AC3: A CI/Pester check fails for any file over 800 lines that is not on the baseline list, and for any baselined file that grows.
- [ ] AC4: A PreToolUse hook denies a Write or Edit that leaves a covered file above 800 lines, with a message naming the tiers and the split requirement; baselined files may shrink or stay equal.
- [ ] AC5: Every existing test, hook, validator, and document that hard-codes the 500-line limit is updated or confirmed unaffected.
- [ ] AC6: The baseline list is generated deterministically from the repository at the merge base and is reviewable.
- [ ] AC7: All mirrors and bundle copies pass the contract tests, and the seven-stage toolchain passes.

## Constraints & Risks

- CLAUDE.md names `.github/instructions` as authoritative and says not to modify it; the user explicitly approved editing it together with the `.claude` mirrors for this issue.
- Many existing files exceed 800 lines; the ratchet must not fail them.
- The new gate itself must stay under the policy it enforces.
- Execution-environment brief copies must stay byte-identical.

## Test Conditions to Consider

- [ ] Unit coverage areas: tier classification (below 500, 500-699, 700-799, 800 and above), exemption handling, ratchet comparison against the baseline, hook decision for Write/Edit.
- [ ] Integration scenarios: a baselined file that shrinks, stays equal, and grows; a new file at 801 lines.
- [ ] CLI/API examples: the CI check run against a fixture-free in-memory file list.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/tiered-file-size-policy-500-700-800/` folder from the template
