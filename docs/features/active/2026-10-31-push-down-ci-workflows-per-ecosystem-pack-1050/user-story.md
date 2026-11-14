# `2026-10-31-push-down-ci-workflows-per-ecosystem-pack` — User Story

- Issue: #1050
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-11-14
- Spec: `spec.md` (criteria S1 to S17)

## Story Statement

- As a destination maintainer, I want the push-down to deliver CI matching the packs I selected, only when I ask for it, so that the harness gates have real checks to wait on and my existing workflows stay untouched.
- As a harness agent running the merge gate or S9 in a destination, I want the CI workflow named `CI` with one aggregate `CI Required Gate` context, recorded in a data file, so that I evaluate the checks the harness expects.
- As a destination maintainer, I want branch protection changed only by a command I run deliberately, so that the push-down never alters repository settings.
- As the extension maintainer, I want destinations to call pinned reusable workflows, so that a CI fix reaches them by a documented pin bump without copy drift.

## Problem / Why

The push-down ships no CI, while the merge gate, S9, and the coverage hooks assume a workflow named `CI` and fixed artifact paths. Destinations without matching CI leave those gates unsatisfiable or vacuous.

## Personas & Scenarios

- Persona: destination maintainer. Owns a repository that receives the harness; cares about not losing local CI customizations; may host the repository privately.
  - Scenario: runs the Claude push-down with `packs: ["python"]` and `ci_workflows: "reference"`. The run writes `.github/workflows/drm-copilot-ci.yml` with a Python job and the `CI Required Gate` job, plus `.github/drm-copilot/ci-required-checks.json`. A later run without `ci_workflows` keeps reference mode. If the repository already has a workflow named `CI`, the caller is withheld and a `push-down conflict:` warning names that file.
  - Scenario: decides to require the gate, runs `.github/drm-copilot/Set-CiRequiredChecks.ps1`, reviews the printed ruleset body, then re-runs with `-Apply`.
- Persona: harness agent (orchestrator or merge-gate hook). Needs a `CI` workflow on `pull_request` for `"epic/**"` and `workflow_dispatch`, and the artifact paths the coverage hooks read.
- Persona: extension maintainer. Releases the extension with tag `v<payload_version>` and documents the bump.

## Acceptance Criteria

- [ ] U1: A destination maintainer who omits `ci_workflows` or sets `off` receives no CI files; setting `reference` or `copy` delivers them, an omitted input on a later run keeps the recorded mode, and an invalid value or both C# variants stops the run before any write. (S1, S2, S4)
- [ ] U2: The delivered caller contains a job for each selected language pack and no other pack, plus the `CI Required Gate` job; in reference mode it calls this repository's `harness-<pack>.yml` at `v<payload_version>`, and in copy mode it calls local copies recorded in the manifest with their hashes. (S3, S5, S6, S11)
- [ ] U3: The destination receives `.github/drm-copilot/ci-required-checks.json` naming workflow `CI` and the single required context `CI Required Gate`, and every execution-environment brief copy names that file. (S7, S13)
- [ ] U4: Check names and artifact paths of the delivered workflows match the merge-gate literal and the coverage-hook paths, a contract test fails when they diverge, and one dispatched run per pack in a scratch destination shows the expected checks. (S11, S12, S17)
- [ ] U5: The push-down never overwrites an existing workflow, reports each conflict (unmanaged file, edited managed file, or another workflow named `CI`), and an identical re-run reports the CI files `unchanged`. (S8, S9, S10)
- [ ] U6: Branch protection changes only when the maintainer runs `Set-CiRequiredChecks.ps1 -Apply`, which creates a new ruleset and never edits an existing one; the default run is a dry run. (S14)
- [ ] U7: The extension maintainer can follow documented steps to bump the pin, with the tag, private-source, and copy-mode exemption limits stated. (S15)
- [ ] U8: The feature adds no Python and changes no hook. (S16)

## Non-Goals

- Editing hooks, S9, `ci.yml`, existing `_*.yml` workflows, or canonical policy files.
- A shell (bats/kcov) pack or a smoke job in this repository's CI.
- Vendoring PoshQC into destinations, a manifest schema change, or a new manifest layer.
- The `integration-needed` file and detect or validate tools (#1051).
- Any repository-settings change made by the push-down.
