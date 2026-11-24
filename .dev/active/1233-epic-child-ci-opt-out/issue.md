# epic-child-ci-opt-out (Issue #1233)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1233-epic-child-ci-opt-out/ (Issue #1233)

- Issue: #1233
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1233
- Last Updated: 2026-11-24
- Work Mode: full-feature

## Problem / Why

Every epic child must pass CI on its own pull request before it merges into the epic integration branch. The merge gate `enforce-epic-merge-gate-child-ci.ps1` (issue #1130), byte-identical in `.claude/hooks/` and `.codex/hooks/`, enforces this. The S9 dispatch fallback starts a `CI` run per child head, because `ci.yml` does not trigger on pull requests into `epic/**`. An epic with N children pays for N full CI runs plus the integration run. The owner directed on 2026-11-23: "for the epic run, do not run CI on each feature. only run it on the final epic merge to main". The owner chose to change the gate rather than bypass it.

## Proposed Behavior

- Add an epic-level opt-out, recorded in the epic manifest and copied into the epic checkpoint, for example `child_ci: integration_only`. The default stays `per_child`, today's behavior.
- Under `integration_only`, an epic child merges into the integration branch without a CI run on its own head. The gate instead requires:
  - the child's local final-QC evidence at the live head;
  - the existing review guard (`REVIEW_GATE_*`) at a current head;
  - the remaining child merge-gate predicates.
- No `CI` dispatch is issued for child heads.
- The integration-to-main pull request still requires a full green `CI` run, and its merge to main is unchanged.
- The orchestrate skill (S9 for epic children), the epic-orchestrate, epic-plan, and epic-run skills, and the checkpoint validators (Python, TypeScript, PowerShell) treat a child under `integration_only` as complete without `ci_gate` success. They record the opt-out explicitly, so that missing CI is never read as green by accident.
- The change applies to the Claude and Codex hooks and skills, the Copilot surfaces where they describe the rule, and every bundle copy under `extensions/drm-copilot/resources/`.
- Record the change in `.dev/engineering/process-reductions/` as a standing gate reduction, with the prior text and revert steps.

## Acceptance Criteria (early draft)

- [ ] With `child_ci: integration_only` in the epic checkpoint, the epic merge gate allows a child merge into its integration branch without a `CI` run on the child head, provided the final-QC evidence and the review-guard conditions hold. With `per_child`, or with the key absent, behavior is unchanged.
- [ ] The gate never applies the opt-out to a pull request whose base is `main`.
- [ ] The S9 epic-child procedure issues no CI dispatch under the opt-out, and the integration PR still requires green `CI`.
- [ ] The validators accept a completed epic child under the opt-out without `ci_gate` success, and reject the same checkpoint when the opt-out is absent. The Python, TypeScript, and PowerShell error strings are byte-identical.
- [ ] Claude and Codex hook copies stay byte-identical, bundle parity holds, and harness generation reports no drift.
- [ ] Pester tests cover the allow and deny paths, the main-base exclusion, and the default behavior.
- [ ] A process-reduction ledger entry records the prior text and the revert steps.

## Constraints & Risks

- No new Python logic. The existing Python validator may need a key-gated change to keep three-runtime parity; keep it minimal.
- Test runs are parallel only. The full suite runs only at the Phase 0 baseline and in the final QC loop; every other run is targeted.
- Risk: a child defect that only CI would catch is found later, at the integration PR. The integration PR's full CI run is the backstop.
- Concurrent work: epic #1217 runs now, and #1228 edits the test-cadence wording in `atomic-plan-contract`, the orchestrate and epic skills, and the agent sources. Merge main and resolve conflicts as needed.

## Test Conditions to Consider

- [ ] Merge-gate Pester tests: allow, deny, and main-base cases
- [ ] Validator corpus fixtures for all three runtimes
- [ ] Hook byte-identity and bundle parity tests

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/epic-child-ci-opt-out/` folder from the template
