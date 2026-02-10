# agents-skills-and-sync (Issue #14)

- Date captured: 2026-02-10
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/agents-skills-and-sync/ (Issue #14)

- Issue: #14
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/14
- Last Updated: 2026-02-10
## Problem / Why

Skills, agent instructions, and prompt scaffolding live in multiple places with overlapping guidance. This creates drift, increases onboarding time, and makes it harder to reason about which source is canonical. The lack of a repeatable synchronization path between repos forces manual updates and makes MVP-level coordination brittle.

## Proposed Behavior

Establish a GitHub-style taxonomy for `SKILL.md` files that allows agents to discover, load, and apply skills consistently across repositories. Define a canonical-location registry so repeated content lives in one authoritative skill and is referenced elsewhere, reducing duplication and conflict. Provide a lightweight synchronization mechanism to keep agentic files (skills, instructions, and prompt templates) aligned between repos until the extension provides first-class automation.

## Acceptance Criteria (early draft)

- [ ] SKILL taxonomy is documented and used to locate and load skills consistently across agent flows.
- [ ] Canonical locations are defined for repeatable guidance, with explicit references to prevent drift.
- [ ] MVP synchronization workflow can pull/push agentic files between repos without manual diff hunting.
- [ ] Failure cases (missing skill, conflicting canonical location, sync conflict) produce actionable messages.
- [ ] Edge cases (renamed skill folder, deleted canonical file, partial sync) are handled deterministically.

## Constraints & Risks

- Must remain compatible with existing repo structure and instruction precedence rules.
- Risk of breaking agent flows if canonical locations are wrong or missing.
- Synchronization should avoid network-only assumptions and should be safe for read-only environments.
- Avoid creating tight coupling to a single repo layout or extension version.

## Test Conditions to Consider

- [ ] Unit: taxonomy resolution (skill lookup, canonical reference parsing, missing skill errors).
- [ ] Unit: canonical-location resolution detects duplicates and conflicts.
- [ ] Integration: sync pulls/pushes across two repos with overlapping skill sets.
- [ ] Integration: conflict detection and resolution prompts/logging.
- [ ] CLI/API: example command or script invocation for MVP sync.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/agents-skills-and-sync/` folder from the template
