# push-down-ci-workflows-per-ecosystem-pack (Issue #1050)

- Date captured: 2026-10-31
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/push-down-ci-workflows-per-ecosystem-pack/ (Issue #1050)

- Issue: #1050
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1050
- Last Updated: 2026-10-31
## Problem / Why

The push-down ships rules, skills, agents, hooks and libraries per ecosystem option (Python, PowerShell, TypeScript, and .NET in legacy and current forms). It ships no CI: `extensions/drm-copilot/resources/` contains no GitHub workflow files.

The harness assumes CI exists. The merge gate and the S9 step read check names and a required-context list, and the toolchain rules assume artifact paths such as `artifacts/python/coverage.json` for the coverage-threshold step. A destination without matching CI makes those gates unsatisfiable or vacuous, so agents wait for checks that never run. Each destination currently builds its own CI, and the check names drift from what the harness expects.

This repository's workflows are already reusable (`_quality-checks.yml`, `_poshqc.yml`, `_root-typescript-tests.yml`, `_shell-coverage.yml`), which makes a thin-caller push-down possible.

## Proposed Behavior

1. **One CI template per ecosystem pack.** Selecting a pack option selects its jobs: Python, PowerShell, TypeScript, .NET (legacy and current). Each template carries stable check names and the artifact paths the toolchain rules expect.
2. **Thin callers by default.** The push-down writes a small workflow that calls the source repository's reusable workflows at a pinned ref. A fix reaches destinations by bumping the pin, with no copy drift. Where the source repository is not reachable from the destination, the push-down ships copies and records their hashes in the manifest defined by the vendored-code coverage carve-out (issue #1049).
3. **Required checks as data.** The push-down emits the required-check list as a data file. The merge gate, the execution-environment brief and the branch-protection setup read it instead of a hard-coded, repository-specific list.
4. **Never overwrite.** New workflows are written beside existing ones. A conflicting existing workflow is reported (see the integration tooling entry) and left untouched.
5. **Branch protection is explicit.** Setting required status checks changes repository settings, so it is an opt-in step, never a side effect of the push-down.

## Acceptance Criteria (early draft)

- [ ] Each ecosystem pack option includes a CI template, and selecting the option writes only that pack's workflows.
- [ ] The template check names and artifact paths match the toolchain rules and the merge gate's expectations; a contract test fails when they diverge.
- [ ] The default template is a thin caller with a pinned ref; a copy mode records content hashes in the manifest.
- [ ] The required-check list is emitted as data and consumed by the merge gate and the brief.
- [ ] The push-down never overwrites an existing workflow file and reports each conflict.
- [ ] Branch protection is changed only by an explicit opt-in command.
- [ ] No new Python; the push-down is TypeScript, and any helper is PowerShell or bash.

## Constraints & Risks

- CI is the most destination-specific surface: runners, secrets, publish and deploy jobs, version matrices and the branch-protection ruleset. The default must be additive.
- A thin caller needs read access to the source repository's workflows. A private source requires the copy mode.
- Overlaps the shared agent-harness layer epic (#1018): push-down consolidation and ecosystem packs (#1029). Depends on the manifest from #1049.
- A pinned ref that is never bumped leaves destinations on old CI; the bump process needs documentation.

## Test Conditions to Consider

- [x] Unit coverage areas: template selection per pack; required-check data generation; conflict detection for an existing workflow.
- [x] Integration scenarios: push to a scratch destination for each pack and confirm the generated workflow parses and exposes the expected check names.
- [ ] CLI/API examples

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/push-down-ci-workflows-per-ecosystem-pack/` folder from the template
