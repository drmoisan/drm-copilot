# `2026-10-28-tiered-file-size-policy-500-700-800` — User Story

- Issue: #990
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-28T13-30

## Story Statement

- As a repository author (human or agent), I want a tiered file-size policy (500 guidance, 700 advisory, 800 hard block), so that I split files when the parts separate logically and am not forced to split files that do not.
- As a reviewer or `feature-review` agent, I want files at or above 700 lines reported as non-blocking Warnings, so that growing files are visible before they reach the hard limit without blocking delivery.
- As a repository maintainer, I want a CI check and a PreToolUse hook that block files over 800 lines, with a baseline ratchet for legacy files, so that no new oversized file enters the repository and existing ones never grow, without a mass split.

## Problem / Why

The repository enforces a single 500-line limit on production code, test code, and reusable script files. The limit is too restrictive: it forces splits that are not logically separable. A tiered policy keeps pressure toward smaller files while reserving hard enforcement for files that are clearly too large.

Today the 500 limit is mechanically checked only by file-scoped Pester assertions; no hook, CI step, or review rule enforces it repository-wide.

## Personas & Scenarios

- Persona: Agent or human author
  - who the user is: a contributor who writes or edits production code, test code, or reusable scripts.
  - what they care about: cohesive modules that are not split artificially.
  - their constraints: the existing exemptions (throwaway scripts, raw text fixtures, Markdown) continue to apply; legacy files over 800 lines exist.
  - their goals and frustrations: keep files readable; the single 500 limit forced splits of logically inseparable code.
  - their context and motivations: guidance at 500 and 700 lines prompts a split when sensible, and the 800 limit gives a firm, predictable boundary.
- Scenario: Author grows a file past each tier
  - who is acting: an author extending a covered file.
  - what triggered the action: the file reaches 500 lines.
  - what steps do they take: at 500 they look for a logical split and continue if none exists; at 700 they look more aggressively and `feature-review` reports a non-blocking Warning; at 801 lines the PreToolUse hook denies the Write or Edit with a message naming the tiers and the split requirement.
  - what obstacles or decisions occur: the file cannot be separated logically, but the hard limit applies regardless, so the author splits it.
  - what outcome do they expect: a file at or below 800 lines, with no gate failure between 500 and 800 lines.
- Persona: Maintainer of a legacy file
  - who the user is: a maintainer working on a file already over 800 lines.
  - what they care about: making small fixes without being forced into an unrelated split.
  - their constraints: no mass split is in scope; the file is recorded in the baseline list.
  - their goals and frustrations: fix defects without gate failures, while ensuring the file never grows.
  - their context and motivations: legacy files are split opportunistically.
- Scenario: Edit to a baselined file
  - who is acting: a maintainer editing a baselined file.
  - what triggered the action: a defect fix.
  - what steps do they take: the edit shrinks or keeps the file size; the hook allows it. If the edit shrinks the file, the baseline entry is tightened to the new size in the same change.
  - what obstacles or decisions occur: an edit that grows the file is denied by the hook and fails the CI check.
  - what outcome do they expect: the fix lands and the baseline can only decrease.
- Persona: Reviewer
  - who the user is: a reviewer or the `feature-review` agent.
  - what they care about: visibility of file growth and of baseline changes.
  - their goals: see 700-line Warnings in the code-review findings and treat any added or increased baseline entry as a blocking policy finding.

## Acceptance Criteria

- [x] AC1: Policy text in every authoritative and mirrored surface states a three-tier policy (500 guidance, 700 advisory Warning, 800 hard block) and keeps the existing exemption list.
- [x] AC2: No gate fails for a file between 500 and 800 lines; `feature-review` reports files at or above 700 lines as non-blocking Warning findings.
- [x] AC3: A CI/Pester check fails for any file over 800 lines that is not on the baseline list, and for any baselined file that grows.
- [x] AC4: A PreToolUse hook denies a Write or Edit that leaves a covered file above 800 lines, with a message naming the tiers and the split requirement; baselined files may shrink or stay equal.
- [x] AC5: Every existing test, hook, validator, and document that hard-codes the 500-line limit is updated or confirmed unaffected.
- [x] AC6: The baseline list is generated deterministically from the repository at the merge base and is reviewable.
- [ ] AC7: All mirrors and bundle copies pass the contract tests, and the seven-stage toolchain passes.

## Non-Goals

- Splitting any existing file that exceeds 800 lines; legacy files are split opportunistically, not in this issue.
- Any gate failure or blocking finding for files between 500 and 800 lines.
- Changing the existing exemption list (throwaway scripts created and deleted within an agent session, raw text fixtures for language-processing test data, Markdown documentation).
- Rewording historical explanatory comments that mention a 500-line limit but do not state policy.
- Adding a new CI workflow job or changing required status contexts.
- Changing unrelated "500" figures (skill-authoring limits, issue number #500, plan-size limits).
