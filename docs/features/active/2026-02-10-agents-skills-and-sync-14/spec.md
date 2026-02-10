# 2026-02-10-agents-skills-and-sync — Spec

- **Issue:** #14
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-10T09-08
- **Status:** Locked
- **Version:** 1.0

Status Badge: ![Locked](https://img.shields.io/badge/status-Locked-brightgreen)

## Overview

Skills, agent instructions, and prompt scaffolding live in multiple places with overlapping guidance. This creates drift, increases onboarding time, and makes it harder to reason about which source is canonical. The lack of a repeatable synchronization path between repos forces manual updates and makes MVP-level coordination brittle.


## Behavior

Establish a GitHub-style taxonomy for `SKILL.md` files that allows agents to discover, load, and apply skills consistently across repositories. Define a canonical-location registry so repeated content lives in one authoritative skill and is referenced elsewhere, reducing duplication and conflict. Provide a lightweight synchronization mechanism to keep agentic files (skills, instructions, and prompt templates) aligned between repos until the extension provides first-class automation.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- CLI: `scripts/dev_tools/agentic_sync.py` with positional args `left_repo` and `right_repo`.
	- CLI flags: `--force-left-to-right`, `--force-right-to-left`, `--threshold-seconds` (default 180).
	- Files: `.github/agents/`, `.github/instructions/`, `.github/prompts/`, `.github/skills/` (only files present in both repos are considered).
	- Skill metadata: `SKILL.md` frontmatter (`name`, `description`) and a canonical-location section inside the skill content.
	- Environment: local filesystem access to both repos (no network dependency).
- Outputs (artifacts, logs, telemetry)
	- JSON artifact written to `artifacts/agentic-sync/sync-<timestamp>.json` in the current working directory.
	- Console log line indicating artifact location.
	- No external telemetry or network calls for MVP sync.
- Config keys and defaults:
	- `threshold_seconds`: default `180` (mtime equivalence window).
	- `force_direction`: `left-to-right` or `right-to-left` when explicitly requested.
- Versioning or backward-compatibility constraints:
	- Existing agent/prompt/instruction files remain in place; skills are additive under `.github/skills/`.
	- Sync only matches files present in both repos to avoid unintentional one-way propagation.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Command: `python scripts/dev_tools/agentic_sync.py <left_repo> <right_repo>`
	- Expected output: `Wrote sync artifact to: <repo>/artifacts/agentic-sync/sync-<timestamp>.json`
- Flags:
	- `--force-left-to-right`: always use left repo content when differences exist.
	- `--force-right-to-left`: always use right repo content when differences exist.
	- `--threshold-seconds <int>`: override mtime equivalence window.
- Contracts and validation rules:
	- Both repo paths must exist and be directories or the command fails fast.
	- Files are matched by relative path within each scoped root folder.
	- When not forced, files within the threshold window short-circuit to an mtime-equivalent decision.
	- When content differs and not forced, the newer mtime wins; ties default to left.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Sync decisions are derived from relative-path matching, mtime comparisons, and content equality checks.
	- The canonical-location rule is stored in skill content and treated as the authoritative reference for reusable guidance.
	- Only files present in both repos are processed; missing files are skipped to avoid accidental one-way copies.
- Caching or persistence details:
	- No cache layer; the only persisted state is the sync artifact JSON per run.
	- The artifact JSON captures per-file decisions, source selection, and timestamps.
- Migration or backfill requirements (if any):
	- None; introducing `.github/skills/` is additive and does not require moving existing files.

## Constraints & Risks

- Must remain compatible with existing repo structure and instruction precedence rules.
- Risk of breaking agent flows if canonical locations are wrong or missing.
- Synchronization should avoid network-only assumptions and should be safe for read-only environments.
- Avoid creating tight coupling to a single repo layout or extension version.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Define the skill taxonomy and canonical-location guidance within `SKILL.md` content.
	- Add a reusable skill for feature-review workflow guidance and point the agent/prompt to it.
	- Use the existing MVP sync script to align `.github` content between repos.
- New classes/functions/commands to add or update:
	- Create `.github/skills/feature-review-workflow/SKILL.md` with reusable workflow steps.
	- Update `.github/agents/feature-review.agent.md` to reference the skill and remove duplicated workflow rules.
	- Update `.github/prompts/review-feature.prompt.md` to a thin loader that references the skill.
	- Keep `scripts/dev_tools/agentic_sync.py` as the sync command for MVP alignment.
- Dependency changes (new/removed packages) and rationale:
	- None; the MVP sync and skill taxonomy are file-structure changes only.
- Logging/telemetry additions and locations:
	- Log sync artifacts to stdout and store JSON under `artifacts/agentic-sync/`.
	- No external telemetry for MVP to avoid network dependencies.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Roll out skills by adding them alongside existing agent/prompt guidance.
	- If a skill is missing or invalid, fall back to existing agent instructions until fixed.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos (evidence: test plan entries in this spec).
- [ ] Behavior matches acceptance criteria in all documented environments (evidence: demo using the sync CLI against two repos).
- [ ] Tests updated/added (unit/integration as applicable) (evidence: new tests covering taxonomy resolution and sync decisions).
- [ ] Edge cases and error handling covered by tests (evidence: tests for missing skill, conflicts, and partial sync).
- [ ] Docs updated (README, docs/features/active/... links) (evidence: updated docs linking the new skill taxonomy).
- [ ] Telemetry/logging added or updated (if applicable) (evidence: sync artifact log output documented).
- [ ] Toolchain pass completed (format → lint → type-check → test) (evidence: toolchain output captured in PR).

## Seeded Test Conditions (from potential)
- [ ] Unit: taxonomy resolution (skill lookup, canonical reference parsing, missing skill errors).
- [ ] Unit: canonical-location resolution detects duplicates and conflicts.
- [ ] Integration: sync pulls/pushes across two repos with overlapping skill sets.
- [ ] Integration: conflict detection and resolution prompts/logging.
- [ ] CLI/API: example command or script invocation for MVP sync.

## Acceptance Criteria Evidence (partial, as of 2026-02-10T13-45)

| Criterion | Evidence | Verification command(s) |
| --- | --- | --- |
| SKILL taxonomy is documented and used to locate and load skills consistently across agent flows. | `.github/skills/README.md`; `scripts/dev_tools/skill_taxonomy.py`; `tests/scripts/dev_tools/test_skill_taxonomy.py`. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` (see `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`). |
| Canonical locations are defined for repeatable guidance, with explicit references to prevent drift. | `.github/skills/README.md` (Canonical Location section); `.github/skills/skill-canonical-location-audit/SKILL.md`. | Review files above (document evidence). |
| MVP synchronization workflow can pull/push agentic files between repos without manual diff hunting. | `scripts/dev_tools/agentic_sync.py`; `tests/scripts/dev_tools/test_agentic_sync.py` (unit coverage for sync decisions). | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` (see `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`). |
| Failure cases (missing skill, conflicting canonical location, sync conflict) produce actionable messages. | Regression artifacts for missing skill + duplicate canonical: `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/missing-skill.2026-02-10T13-10.md`, `duplicate-canonical.2026-02-10T13-12.md`; CLI tests in `tests/scripts/dev_tools/test_skill_taxonomy.py`. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` (see `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`). |
| Edge cases (renamed skill folder, deleted canonical file, partial sync) are handled deterministically. | No evidence yet. | None recorded. |

Open criteria:
- Integration sync across two repos not demonstrated.
- Sync conflict messaging not evidenced.
- Edge-case handling (renamed folder, deleted canonical file, partial sync) not evidenced.
