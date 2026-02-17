# bootstrap-agents (Issue #22)

- Date captured: 2026-02-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bootstrap-agents/ (Issue #22)

- Issue: #22
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/22
- Last Updated: 2026-02-17
## Problem / Why

Agent patterns, prompts, and orchestration conventions are currently spread across multiple repositories, which makes reuse inconsistent and slows onboarding for new feature work. Teams repeatedly re-discover the same approaches instead of starting from a known-good baseline. We need a repeatable way to import and normalize existing agentic design assets into one curated collection that can be referenced by this repo and reused by other repos.

## Proposed Behavior

Add a bootstrap workflow that imports agentic design assets (instructions, skills, prompt templates, and related metadata) from one or more source repositories into this repository under a controlled destination structure.

The workflow should:
- Accept one or more source repositories (and optional branch/ref) as input.
- Discover candidate assets using configured include/exclude rules.
- Copy assets into canonical target locations in this repo.
- Normalize metadata and links to local conventions (naming, paths, and references).
- Emit a deterministic summary of imported files, skipped files, and conflicts.
- Support dry-run mode so maintainers can review changes before applying.

## Acceptance Criteria (early draft)

- [ ] Given a valid source repository with supported agent artifacts, the bootstrap workflow imports those artifacts into the expected target folders in this repo.
- [ ] Given multiple source repositories, the workflow processes all sources in a deterministic order and produces the same output structure across repeated runs.
- [ ] Given `--dry-run`, no files are written and the tool outputs the planned creates/updates/skips/conflicts.
- [ ] Given a path conflict (same target file from different sources), the workflow reports the conflict with enough detail to resolve it and does not silently overwrite content.
- [ ] Given unsupported or malformed source assets, the workflow skips them with explicit warnings and continues processing remaining valid inputs.
- [ ] The workflow emits a machine-readable import report (for automation) and a human-readable summary (for reviewers).

## Constraints & Risks

- Source repos may use incompatible folder conventions, requiring robust mapping and normalization rules.
- Imported prompts/instructions can reference files that do not exist in this repo; link validation and rewrite rules are required.
- Scope risk: importing too broadly may pull stale or low-quality artifacts; curation filters must be explicit.
- Compatibility risk: behavior must be reproducible on Windows/macOS/Linux for contributors.
- Governance risk: imported assets require provenance tracking (source repo + ref + import date) for future updates.

## Test Conditions to Consider

- [ ] Unit coverage areas
	- [ ] Source asset discovery and include/exclude filtering.
	- [ ] Target path mapping and normalization rules.
	- [ ] Conflict detection and deterministic ordering.
	- [ ] Report generation (machine-readable + human-readable outputs).
- [ ] Integration scenarios
	- [ ] Import from one source repo into clean destination.
	- [ ] Import from multiple source repos with overlapping asset names.
	- [ ] Dry-run and apply-run parity (same planned operations).
	- [ ] Re-run idempotency with no unintended drift.
- [ ] CLI/API examples
	- [ ] Single-source import with explicit ref.
	- [ ] Multi-source import with dry-run.
	- [ ] Import with custom include/exclude patterns.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/import-agents/` folder from the template
