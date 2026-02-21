<!-- markdownlint-disable-file -->

# Task Research Notes: Persisted Work Mode marker for minor-audit branching (review agents + skills)

## Research Executed

### File Analysis

- `c:\Users\DanMoisan\repos\drm-copilot\scripts\dev_tools\new_active_feature_folder.py`
  - Accepts `--work-mode {minor-audit|full}` and builds a deterministic minor-audit `issue.md` with required sections (`## Implementation Intent`, `## Acceptance Criteria`, `## Evidence Checklist`).
  - Emits `Selected mode: ...` to stdout but does **not** persist a “Work Mode” marker into `issue.md`.

- `c:\Users\DanMoisan\repos\drm-copilot\scripts\dev_tools\potential_to_issue.py`
  - Accepts `--work-mode {minor-audit|full}` and generates a deterministic minor-audit GitHub issue body via `build_minor_audit_body(...)`.
  - Emits `Selected mode: ...` to stdout but does **not** persist a “Work Mode” marker into the issue body.

- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\feature-review.agent.md`
  - Acceptance-criteria extraction sources: PR context summary + “active feature scoping docs (plan/spec/user-story)”. It does not mention a minor-audit branch and does not name `issue.md` as the authoritative AC source.

- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\epic-review.agent.md`
  - FeatureDeliveryInventory requires a “Doc completeness (issue/spec/user-story/plan present?)” column.
  - Acceptance criteria extraction is defined explicitly as “list each acceptance criterion from the most recent spec.md and user-story.md.”
  - No minor-audit branching rules are described.

- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\status_updater.agent.md`
  - Delivered definition is “ALL acceptance criteria across spec.md and user-story.md have evidence,” and evidence-writing targets those same docs.
  - No minor-audit branching rules are described.

- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\feature-promotion-lifecycle\SKILL.md`
  - Canonical commands do not include `--work-mode`, and the “required outputs” list does not explicitly describe minor-audit as a first-class path where `spec.md`/`user-story.md` are N/A by design.

- `c:\Users\DanMoisan\repos\drm-copilot\.vscode\tasks.json`
  - Promotion task passes `--work-mode ${input:PotentialWorkMode}`.
  - Active-folder creation task passes `--work-mode ${input:ActiveWorkMode}`.

- `c:\Users\DanMoisan\repos\drm-copilot\docs\engineering\Feature Playbook.md`
  - Defines “Minor Change Audit Path” and states it “does not require broad regression or extended design docs by default; escalate only when risk or scope warrants it.”

- `c:\Users\DanMoisan\repos\drm-copilot\docs\features\templates\README.md`
  - Provides a decision-tree entry for `minor-audit` and repeats the “no broad regression/extended design docs by default” guidance.

### Code Search Results

- `--work-mode`
  - Found in `.vscode/tasks.json`, `scripts/dev_tools/new_active_feature_folder.py`, `scripts/dev_tools/potential_to_issue.py`.

- `Selected mode:`
  - Found in `scripts/dev_tools/new_active_feature_folder.py` and `scripts/dev_tools/potential_to_issue.py` as stdout output, not persisted into markdown artifacts.

- `minor-audit`
  - Found in `docs/engineering/Feature Playbook.md`, `docs/features/templates/README.md`, and the two Python scripts above.

### External Research

- #githubRepo:"drmoisan/drm-copilot persisted work mode marker minor-audit"
  - Not executed (repo-local evidence was sufficient).

- #fetch:https://example.invalid
  - Not executed (no URLs were provided/required).

### Project Conventions

- Standards referenced: `.github/skills/policy-compliance-order/SKILL.md` (policy reading precedence); `.github/skills/evidence-and-timestamp-conventions/SKILL.md` (evidence schema + canonical locations).
- Instructions followed: Task Researcher mode (research-only; write under `artifacts/research/` only; do not modify source outside that folder).

## Key Discoveries

### Project Structure

- Producer workflow already supports `minor-audit` (scripts + VS Code tasks), but reviewers and shared lifecycle docs are not mode-aware.

### Implementation Patterns

- The minor-audit workflow produces a deterministic `issue.md` format, but it currently lacks a stable, machine-checkable `Work Mode:` marker.
- Review agents are currently “hard-wired” to treat `spec.md` + `user-story.md` as the acceptance-criteria source and as prerequisites for doc completeness / Delivered status.

### Complete Examples

```text
# Deterministic minor-audit issue.md section set (new_active_feature_folder.py)

## Problem / Why
## Implementation Intent
## Acceptance Criteria
## Dependencies / Risks
## Verification Steps
## Evidence Checklist
```

### API and Schema Documentation

- Evidence artifact schema gate (unchanged and still required):
  - `Timestamp: <ISO-8601>`
  - `Command: <exact command>`
  - `EXIT_CODE: <int>`

### Configuration Examples

```jsonc
// .vscode/tasks.json (verified): work-mode is passed through to scripts.
"--work-mode",
"${input:ActiveWorkMode}"
```

### Technical Requirements

- Review agents need a deterministic way to identify whether the feature is `minor-audit` or `full`.
- The producer workflow must persist that signal in a durable artifact available in the active feature folder.

**Mandatory unachievable objective callout**:
- **None.** Persisting a `Work Mode:` marker is implementable in the existing producer scripts and consumable by reviewer agents.

## Recommended Approach

Persist a **Work Mode marker** in `issue.md` (and, optionally, in the GitHub issue body) and treat that marker as the primary branching signal.

### Proposed marker contract (single, deterministic convention)

- Location: metadata list above the first `##` section in `issue.md`.
- Format: exactly one line:
  - `- Work Mode: minor-audit` OR
  - `- Work Mode: full`

Rationale:
- Avoids brittle heuristics (folder name parsing, “missing files implies minor-audit”).
- Enables reviewers to branch deterministically and “fail closed” when the marker is absent.

### Producer-side insertion points (verified)

- `scripts/dev_tools/new_active_feature_folder.py`
  - When building minor-audit `issue_body`, insert the marker after the `# <feature_name>` heading and before `## Problem / Why`.

- `scripts/dev_tools/potential_to_issue.py`
  - In `build_minor_audit_body(...)` and `build_body(...)`, insert the marker above the first section header so the mode is preserved in the GitHub issue.

### Consumer-side expectations (review agents + status sync)

- `feature-review.agent.md` and `epic-review.agent.md` should branch:
  - If `Work Mode: minor-audit`: extract AC from `issue.md`.
  - If `Work Mode: full`: extract AC from `spec.md` + `user-story.md` (as today).

- `status_updater.agent.md` should branch:
  - If `Work Mode: minor-audit`: Delivered is based on all AC in `issue.md` having evidence; append evidence to `issue.md`.
  - If `Work Mode: full`: keep current behavior (spec/user-story evidence sections).

### Rejected alternatives (brief)

- Heuristic mode detection (presence of headings or missing docs) was rejected as the primary contract because it is ambiguous and makes audit results fragile; it can be used only as a temporary fallback when the persisted marker is missing.

## Implementation Guidance

- **Objectives**: Ensure minor-audit work does not false-fail audits by persisting a deterministic mode marker and enabling mode-aware acceptance-criteria extraction.

- **Key Tasks**:
  - Update producer scripts to persist `- Work Mode: ...` into `issue.md` (and optionally GitHub issue body).
  - Update reviewer agents (`feature-review`, `epic-review`) to branch their AC extraction and doc-completeness expectations based on the marker.
  - Update status sync agent to branch “Delivered” and evidence-writing targets based on the marker.
  - Update `feature-promotion-lifecycle` skill to include `${work-mode}` and pass `--work-mode` in canonical commands.

- **Dependencies**: None external.

- **Success Criteria**:
  - A minor-audit feature produced by existing workflows is audited without being marked incomplete solely due to missing `spec.md`/`user-story.md`.
  - Review artifacts clearly state detected mode and apply the correct acceptance-criteria source.
  - Mode detection is stable across time (no reliance on stdout logs).