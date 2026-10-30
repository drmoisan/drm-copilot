# `2026-10-30-retire-github-skills-and-thin-copilot-layer` — User Story

- Issue: #1032
- Parent: epic #1018, child 6
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Spec: `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/spec.md`

## Story Statement

- As the repository owner, I want `.github/skills` retired and `.github/agents` settled according to the recorded Copilot experiment result, so that Copilot loads each skill and agent once and no unique content or native capability is lost without a recorded reason.
- As a contributor who does not have the owner's personal VS Code settings, I want the Copilot collision controls delivered with the repository or documented in it, so that I can get single loading without reproducing private configuration.
- As a destination-repository user who receives push-downs, I want the bundled Copilot customizations to contain no retired files, so that a push-down does not install `.github/skills` copies that duplicate the shared skills.
- As the repository owner, I want `.github/copilot-instructions.md` to hold only Copilot-only text, so that shared instructions have one source in `AGENTS.md`.

## Problem / Why

Epic #1018 moves the three agent ecosystems in this repository onto shared cross-tool conventions so that each tool loads every skill and instruction exactly once with default settings. GitHub Copilot in VS Code reads `.github/skills`, `.claude/skills` and `.agents/skills`, so `.github/skills` (a strict subset of the other two skill folders by name) causes duplicate loading. `.github/agents` duplicates agent definitions that Copilot in VS Code also reads from `.claude/agents`. Collision controls currently exist only in the owner's personal user settings.

## Personas & Scenarios

- **Persona: Repository owner (drmoisan).**
  - Maintains the Claude Code, Codex and Copilot ecosystems in this repository and the push-down bundles.
  - Cares about single loading, no silent loss of skill content, and an auditable record for every retirement.
  - Constraint: upstream children 1, 3, 4 and 5 deliver first; this child is planned ahead of them (owner decision E3).
- **Persona: Contributor without personal settings.**
  - Clones the repository and uses Copilot in VS Code with default settings.
  - Cares about seeing each skill, rule and agent once and following the documented setup.
  - Constraint: `.vscode/settings.json` is gitignored.
- **Persona: Destination-repository user.**
  - Receives Copilot customizations through the extension push-down.
  - Cares that the bundle contains only current files and that the shared layer is the source of skills.

- **Scenario: Owner runs the retirement.**
  1. The orchestrator runs the main plan; Phase 0 confirms the parallel run `bugs-1001-1002-1003-1006` merged and child 1, 3, 4 and 5 outputs match the spec's interface assumptions, or stops for re-planning.
  2. The executor records U1 and U2 as stale and U3 per child 1's classification, deletes `.github/skills` and its bundle mirror, repoints references, updates the brief copies, documents, matrix entries and contract tests.
  3. The orchestrator reads the recorded E3 result and runs exactly one agents branch plan.
  4. Expected outcome: all named tests pass and the evidence folder holds the records.
- **Scenario: Contributor opens the repository in VS Code.**
  1. The contributor follows the documented step to copy the collision keys (or applies the documented user-scope settings when workspace scope does not work).
  2. Expected outcome: Copilot lists each shared skill once.
- **Scenario: Destination push-down.**
  1. A destination user runs the Copilot push-down.
  2. Expected outcome: no `.github/skills` file is written from the bundle.

## Acceptance Criteria

- [ ] US-AC1 — `.github/skills/` and `extensions/drm-copilot/resources/customizations/.github/skills/` are absent from the tree (spec AC1, AC2).
- [ ] US-AC2 — The U1, U2 and U3 dispositions are recorded with reasons under `<FEATURE>/evidence/other/`, and any owner-overridden section is present in `.agents/skills/<name>/SKILL.md` (spec AC3).
- [ ] US-AC3 — Exactly one agents branch plan ran, matching child 1's recorded E3 result, and the `.github/agents` outcome matches that branch; every prompt binding and handoff target resolves (spec AC4, AC5, AC6).
- [ ] US-AC4 — `.github/copilot-instructions.md` holds only Copilot-only text, and `.github/prompts` and `.github/hooks` remain native (spec AC7, AC8).
- [ ] US-AC5 — Collision controls are in `.vscode/settings_required.json` with a documented copy step when E4 shows workspace scope works, otherwise documented as user-scope settings, and `test_vscode_workspace_settings.py` passes (spec AC9).
- [ ] US-AC6 — The remaining execution-environment brief copies are byte-identical and their contract tests pass (spec AC10).
- [ ] US-AC7 — The named contract tests and push-down contract tests pass, and no pack manifest or bundle mirror lists a removed file (spec AC11, AC12).
- [ ] US-AC8 — No stale `.github/skills` reference remains outside classified historical, fixture or generic-input hits, and current-fact documents are updated (spec AC13, AC15).
- [ ] US-AC9 — Parity-matrix entries are updated and `HarnessParityMatrix.RepoGate.Tests.ps1` passes (spec AC14).
- [ ] US-AC10 — Toolchain, coverage, isolation and file-size gates are green and no new Python is added (spec AC16, AC17, AC18, AC19).

## Non-Goals

- Editing `.github/instructions`, the shared-source generators, push-down consolidation, or hook behavior (children 3, 4, 5).
- Delivering collision controls to destination repositories (requested of child 4).
- Re-opening the settled epic design.
- Changing historical records or historical fixtures.
