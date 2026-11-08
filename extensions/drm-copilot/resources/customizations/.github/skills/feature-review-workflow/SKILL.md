---
name: feature-review-workflow
description: 'Feature-branch review workflow for base-branch resolution, PR-context refresh, active feature folder selection, review artifact generation, validator gates, acceptance-criteria check-off, and remediation triggers. Use when authoring or executing PR-style feature reviews.'
---

# Feature Review Workflow

Reusable workflow guidance for PR-style feature review.

## Required Shared Skills

Always apply:
- `policy-compliance-order`
- `evidence-and-timestamp-conventions`
- `policy-audit-template-usage`
- `pr-context-artifacts`
- `pr-base-branch-merge-base`
- `acceptance-criteria-tracking`
- `remediation-handoff-atomic-planner`

## Role

- Review a feature branch relative to the correct base branch.
- Produce audit artifacts, not implementation fixes.
- Prefer deterministic evidence from canonical PR-context artifacts and exact diff anchors.
- Trigger remediation planning when blockers or unmet acceptance criteria remain.

## Workflow Contract

### Baseline and evidence

- Treat the review as a feature-vs-base audit, not an isolated file inspection.
- Use `artifacts/pr_context.summary.txt` as the primary evidence source.
- Use `artifacts/pr_context.appendix.txt` as the baseline-diff appendix for raw evidence and exact anchors.
- If PR-context artifacts are missing or stale, refresh them per `pr-context-artifacts` using the resolved base branch.

### Review artifact templates

- When creating review artifacts from templates, use the MCP-exposed bundled assets instead of copying directly from repo template paths.
- Resolve the templates through the MCP server tool `resolve_policy_audit_template_asset` with these selectors:
  - `template` for `policy-audit.<timestamp>.md`
  - `code-review-template` for `code-review.<timestamp>.md`
  - `feature-audit-template` for `feature-audit.<timestamp>.md`
- The MCP-resolved asset is the authoritative template source for review artifacts in this workflow.
- Baseline fields are read from the plan's `Phase 0 baseline` artifact. A baseline field is recorded as `N/A - no pre-change run` only for a language or file with no pre-change run (a new file, or an item whose plan predates the `Phase 0 baseline` rule and captured static baselines only), and the comparison line then reads `Baseline: N/A - no pre-change run -> Post-change: <percent>. Change: N/A.`

### No silent fixes

- Do not clean up code during review.
- If checks fail, document the failure and include exact remediation guidance.

### Process-reduction ledger

- This rule applies only when `docs/engineering/process-reductions/` exists, so a repository without that folder is unaffected.
- A change that reduces evidence, plan tasks, gates, or review process adds its ledger entry in the same commit, in the format of that folder's `README.md`.
- A branch diff that makes such a reduction with no entry is a Blocking finding.
- The reviewer confirms from the branch log that each reduction is its own commit, with the `reduction: NNNN` token in its subject.
- One-off waivers for a single item are not entries.

### Work-mode acceptance-criteria contract

- Read the persisted marker from `issue.md` using one of:
  - `- Work Mode: minor-audit`
  - `- Work Mode: full-feature`
  - `- Work Mode: full-bug`
- Legacy compatibility: interpret `- Work Mode: full` as `full-feature`.
- Acceptance-criteria sources by marker:
  - `minor-audit`: only the explicit `## Acceptance Criteria` section in `issue.md`
  - `full-feature`: `spec.md` and `user-story.md`
  - `full-bug`: `spec.md`
- Fail closed:
  - if the marker is missing or malformed, use `full-feature`
  - if `minor-audit` is selected and `issue.md` lacks `## Acceptance Criteria`, require remediation

## Ordered Procedure

1. **Resolve the base branch**
   - Use the supplied base branch when it is present.
   - Otherwise resolve `PRBaseBranch` with `pr-base-branch-merge-base`.
   - Record the resolved branch, merge-base SHA, merge-base timestamp, and top competing candidates when available.

2. **Load or refresh PR context**
   - Load the canonical PR-context summary and appendix per `pr-context-artifacts`.
   - Refresh only when the artifacts are missing or stale relative to the current branch state.

3. **Determine the active feature folder**
   - Prefer the active feature folder that corresponds to the primary changed scoping docs.
   - If multiple active folders are present, prefer the one whose suffix matches the issue number in the branch name.
   - Otherwise choose the folder with the most material scoping-doc changes.
   - If no active feature folder exists, create `docs/features/active/<today>-feature-review/` and document the assumption.

4. **Produce the policy audit**
  - Use `policy-audit-template-usage` and the MCP `template` asset to drive the artifact structure.
   - Include exact command references for the checks that were run.
   - Validate the resulting `policy-audit.<timestamp>.md` immediately after writing it.

5. **Run required checks**
   - Prefer repo-defined, check-only commands.
   - Default order:
     1. formatting check
     2. lint check
     3. type check
     4. tests
   - A focused run of one test file to debug a specific failure is debugging only; a review check does not rest on it.
   - If a tool cannot run in the environment, mark the affected section unverified or partial with a concrete reason.

6. **Produce the code review**
  - Create the artifact from the MCP `code-review-template` asset.
   - Write `code-review.<timestamp>.md` with:
     - `## Executive Summary`
     - `## Findings Table`
     - a Markdown findings table header containing `Severity | File | Location | Finding | Recommendation | Rationale | Evidence`
   - Include typed-Python review where Python files changed.
   - Validate the artifact immediately after writing it.

7. **Produce the feature audit**
  - Create the artifact from the MCP `feature-audit-template` asset.
   - Write `feature-audit.<timestamp>.md` with:
     - `## Scope and Baseline`
     - `## Acceptance Criteria Inventory`
     - `## Acceptance Criteria Evaluation`
     - `## Summary`
     - `## Acceptance Criteria Check-off`
   - Use the resolved base branch in the baseline section.
   - Evaluate each criterion as PASS, PARTIAL, FAIL, or UNVERIFIED.
   - Check off passing criteria in the authoritative source files per `acceptance-criteria-tracking`.
   - Validate the artifact immediately after writing it.

8. **Trigger remediation when required**
   - Remediation is required when any of the following apply:
     - the policy audit contains meaningful FAIL or PARTIAL results
     - toolchain checks fail
     - the code review contains blockers
     - required acceptance criteria are FAIL or PARTIAL
     - coverage below the governing thresholds (the root `CLAUDE.md` thresholds when stated, otherwise the defaults: line 85%, branch 75% for branch-capable languages; repo-wide per language, modified files including any regression on changed lines against the `Phase 0 baseline`, or new files)
   - Choose the remediation path. Write one line `Remediation-Path: light` or `Remediation-Path: full` into the remediation inputs, and inside each blocking finding block one line `Finding-Scope: contained` or `Finding-Scope: design`. A missing path line reads as `full`, and a missing scope line reads as `design`. These lines never contain the substrings the orchestrator counts.
   - Write `Remediation-Path: light` only when all of these hold: at most 3 blocking findings, every one `autonomous` with `Finding-Scope: contained`; no change to a spec acceptance criterion, a public interface, or the file inventory beyond the branch diff plus tests and mirrors; no change to a validator contract, hook decision, or production logic beyond the finding's named location; the cycle is opened by a review; and the prior cycle was not light. Otherwise write `Remediation-Path: full`. The orchestrator may move a cycle to a heavier path and never to a lighter one.
   - With `Remediation-Path: light`, also write a `## Light Fix Tasks` section: one canonical `- [ ] [P0-T1] ...` line per fix, numbered in order, each naming the file and the finding it fixes. Write no checkbox line anywhere else in the file, because the executor stop hook counts every checkbox line of the file it executes.
   - The remediation plan target stays for both paths, because this review contract requires it.
   - Create `remediation-inputs.<timestamp>.md` first.
   - Create the target remediation plan file from the canonical plan template.
   - Hand off plan creation through `remediation-handoff-atomic-planner`.
   - Do not report completion unless the remediation plan file exists when remediation was triggered.

9. **Finalize the review**
   - Verify every reported artifact exists on disk before reporting completion.
   - Report artifact paths and a concise go/no-go recommendation for PR readiness.
   - End the final report with these exact single-line fields:
     - `REVIEW_STATUS: PASS` or `REVIEW_STATUS: REMEDIATION_REQUIRED`
     - `FEATURE_FOLDER: <path>`
     - `POLICY_AUDIT: <path>`
     - `CODE_REVIEW: <path>`
     - `FEATURE_AUDIT: <path>`
     - `REMEDIATION_INPUTS: <path-or-NONE>`
     - `REMEDIATION_PLAN: <path-or-NONE>`

## Required Artifact Shapes

- `policy-audit.<timestamp>.md`
  - copied from the canonical policy-audit template
  - template instruction block removed
  - includes the canonical major headings and Appendix B command reference
- `code-review.<timestamp>.md`
  - contains `## Executive Summary`
  - contains `## Findings Table`
  - contains the required findings table header
- `feature-audit.<timestamp>.md`
  - contains the five required major sections listed above

## File Size Advisory

The tiered file-size policy (section 4, Module & File Structure, in `.github/instructions/general-code-change.instructions.md`) sets a 500-line guidance tier, a 700-line advisory tier, and an 800-line hard limit. Measure the logical line count of every added or modified covered file in the branch diff. Covered files have one of the extensions `.py`, `.ps1`, `.psm1`, `.ts`, `.tsx`, `.js`, `.cjs`, `.mjs`, `.cs`, `.sh`, or `.bats` and are not under a build, cache, dependency, virtual-environment, or `docs` directory. A logical line count splits the content on line terminators, and a trailing terminator does not add a line; it equals `@(Get-Content -LiteralPath <path>).Count`. Do not use `wc -l` or `Measure-Object -Line`.

- Report each covered file at or above 700 lines as a non-blocking `Warning` row in the Findings Table of `code-review.<timestamp>.md`, naming the file and its line count. Do not write the Warning to `remediation-inputs.<timestamp>.md`, and do not give it a remediation severity label.
- Report a covered file above 800 lines that has no entry in `config/file-size-baseline.json`, and any added or increased entry in `config/file-size-baseline.json`, as a blocking policy finding.
- Produce no finding for the 500-line guidance tier.

## Documentation Surface Check

This check turns a documented-surface change without a matching coverage-ledger change into a blocking finding. It uses the evidence model: inspect the existing artifacts and do not rerun any documentation tooling.

1. When `docs/documentation-estate/docs-profile.json` is absent on the branch head, the check is not applicable and produces no finding.
2. List the changed paths with `git diff --name-only <merge-base>..HEAD`. When no changed path lies under an entry of the profile's `surface_selection.source_roots`, the check produces no finding.
3. When at least one changed path lies under such an entry, require the newest `<FEATURE>/evidence/qa-gates/docs-surface-delta.<timestamp>.md` (the lexicographically greatest matching file), carrying the fields `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`.
4. When that artifact is absent, or records `EXIT_CODE: 1`, report the blocking finding `surface-change-without-ledger-change` with the line `Remediability: autonomous` and a `Remediability-Evidence:` line stating that the coverage ledger can be updated on the branch and the `surface-delta` evidence regenerated without an external dependency. Name the changed source paths in the finding.
5. When the artifact records `EXIT_CODE: 0`, the check passes.

## Constraints

- Prefer check-only commands.
- Do not claim completion until every required artifact exists and its validator passes.
- Use shared skills as the source of truth for policy order, base-branch resolution, PR-context handling, acceptance-criteria tracking, template usage, and remediation handoff.
- Do not omit any required final result field from the review report.
