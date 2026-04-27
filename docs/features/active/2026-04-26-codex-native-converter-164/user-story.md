# `codex-native-converter` — User Story

- Issue: #164
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-04-26T18-01

## Story Statement

- As a repository maintainer, I want to convert supported GitHub Copilot and Claude agent assets into this repo's Codex-native layout so that I can migrate workflow behavior without manually rewriting every file.
- As a workflow author, I want review-first conversion with explicit failures for unsupported mappings and hard gates so that I can trust the generated Codex assets before applying them to a workspace.

## Problem / Why

This repository now has a defined Codex-native target shape, but migrations from other agent ecosystems are still manual and inconsistent. Contributors currently have to interpret mixed-concern source files, translate host-specific automation references by hand, and decide case by case how to preserve strict enforcement behavior.

That manual process is slow, duplicates rules across outputs, and makes it easy to weaken a hard gate during migration. The feature needs a deterministic converter that can classify supported source artifacts, generate only approved Codex-native targets, and fail closed when it cannot prove a safe mapping.

## Personas & Scenarios

- Persona: Repository maintainer
  - Owns repository runtime conventions and wants them preserved during ecosystem migration.
  - Needs repeatable output that can be reviewed before it is written into a target workspace.
  - Cannot accept silent drops, advisory rewrites of hard gates, or duplicated guidance scattered across generated files.
  - Wants the converter to be explicit about what is supported in v1 and what requires manual follow-up.
- Persona: Workflow migration author
  - Translates existing automation assets into Codex-native runtime surfaces.
  - Needs clear mapping rules for skills, agents, hooks, MCP dependencies, and standing instructions.
  - Requires fail-closed behavior when a source handoff or enforcement rule has no verified Codex-native equivalent.
  - Wants outputs and reports that are easy to diff, review, and validate in automation.
- Scenario: Review a GitHub Copilot or Claude tree before applying changes
  - A maintainer points the converter at a supported source root from a GitHub Copilot or Claude layout.
  - The extension and MCP entry points invoke the same bundled Python converter contract.
  - The converter classifies each examined file into a deterministic conversion class and target role.
  - It produces a review artifact set that includes a proposed Codex-native tree, a mapping catalog, and validation results.
  - The maintainer inspects any unsupported mappings, unresolved MCP rewrites, and hard-gate failures before deciding whether the conversion is safe.
  - The expected outcome is a complete, reviewable proposal with no workspace writes to the destination runtime.
- Scenario: Apply an approved conversion into a destination root
  - After reviewing the proposed outputs, a migration author reruns the converter in apply mode with an explicit destination root.
  - The extension and MCP entry points invoke the same bundled Python converter contract.
  - The converter writes only approved Codex-native outputs, preserving shared guidance in common skills instead of duplicating it across multiple agents or prompts.
  - If the converter encounters an unresolved hard gate, an unsupported source artifact, or a lingering source-runtime reference that should have been rewritten, it stops the apply run and reports the blocking failure.
  - The expected outcome is a deterministic Codex-native output set plus the same report artifacts captured during review.

## Acceptance Criteria

- [x] A maintainer can run the converter against a supported GitHub Copilot or Claude source tree and receive deterministic classification for every examined artifact as `direct`, `decomposed`, `repo-convention`, or `unsupported`, plus a concrete target role.
- [x] The extension and MCP entry points invoke the same bundled Python converter contract.
- [x] v1 support is explicit and limited to documented GitHub Copilot and Claude source surfaces; unsupported ecosystems or unsupported files within those ecosystems are reported explicitly instead of inferred or silently dropped.
- [x] Generated outputs target only approved Codex-native surfaces such as `AGENTS.md`, `.agents/skills/**`, `.codex/agents/**`, `.codex/config.toml`, `.codex/hooks/**` or native hook configuration, `.codex/rules/**`, and repository-specific `.codex/prompts/**` only when that repository-convention output is intentionally enabled.
- [x] Hard gates and handoff-related behavior remain fail-closed and non-discretionary: if the converter cannot map them to verified Codex-native enforcement or delegation mechanisms, apply mode stops and records a blocking validation failure.
- [x] When a supported host-specific automation mapping exists, the converter rewrites it to the repository's semantic MCP usage model on server `drmCopilotExtension`; when no safe rewrite exists, the converter reports the gap and does not emit a misleading replacement.
- [x] Review mode is non-mutating and always produces a reviewable artifact set that includes `conversion-report.md`, `mapping-catalog.json`, `validation-results.json`, and a `proposed-tree/` snapshot.
- [x] Apply mode requires an explicit destination root, writes the approved Codex-native outputs plus the same report artifacts, and fails closed when required inputs, mappings, or native enforcement equivalents are missing.
- [x] At least one representative GitHub Copilot fixture and one representative Claude fixture can be converted into reviewable v1 outputs, and the result preserves reusable guidance in shared skills rather than flattening duplicated text across agents or prompts.

## Non-Goals

- Supporting every external agent ecosystem in v1.
- Claiming that `.codex/prompts/**` is a universal Codex product surface; in this repo it is a repository-specific convention only.
- Performing a one-file-to-one-file mirror of source assets when the source artifact mixes concerns that must be decomposed to fit Codex-native structures.
- Downgrading source hard gates into comments, advisory text, or optional follow-up steps.
- Emitting `.github`, `.claude`, or `CLAUDE.md` artifacts as conversion targets.