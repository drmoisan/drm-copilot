# `2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production` — User Story

- Issue: #1016
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-59

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

`docs/features/` has outgrown its name. It holds potential entries, active and completed features, an archive, epics, parallel orchestrations, templates and research, and it is 28,452 of the files under `docs/`. It is development-process material, but it sits in the folder that conventionally holds production documentation. The same layout is pushed to every destination repo that uses this toolset.

Goal: separate development documentation from production documentation. Development records move to a new top-level `.dev/` root. `docs/` is reserved for production documentation.

Most professional repos keep work-tracking state in the issue tracker, and keep design records as one file per decision with a status in the header. This repo uses the folder as the lifecycle (potential, active, completed, archive). That is why a rename is expensive, and why this item moves the tree and changes no lifecycle behavior.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] `.dev/` holds all development records in the layout above, and `docs/` holds only production documentation plus a README stating its purpose.
- [ ] One configured key, `development_docs_root`, drives every consumer in Python, PowerShell and TypeScript; no consumer hard-codes the old path.
- [ ] With the default `docs/features` the repo behaves exactly as before Phase 1; with `.dev` set, the full toolchain passes.
- [ ] A destination repo that has not migrated keeps working through the fallback for one release.
- [ ] The TypeScript migration command moves a destination's folders with `git mv`, rewrites references, and a second run changes nothing.
- [ ] The migration command and its tests need no Python.
- [ ] `.dev/**` counts as docs-only in the CI change scope, and `.dev/**/*.json` stays under JSON governance.
- [ ] A test proves every Node-glob and ripgrep consumer finds a record under `.dev`.
- [ ] A test proves every agent and hook write scope covers the configured root.
- [ ] Historical fixtures stay frozen and still pass through the fallback.
- [ ] Mirrored and bundled files, pack manifests, Codex counterparts and contract tests pass.


## Non-Goals

Call out what is explicitly excluded from this feature.
