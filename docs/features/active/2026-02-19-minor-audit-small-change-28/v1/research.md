<!-- markdownlint-disable-file -->

# Task Research Notes: minor-audit-small-change implementation approach

## Research Executed

### File Analysis

- `docs/features/active/2026-02-19-minor-audit-small-change-28/issue.md`
  - Defines Minor Change Audit Path: expanded `issue.md` as canonical artifact for bootstrapped/small-scope work, with reduced evidence requirements (baseline/end-state/targeted verification).
- `docs/engineering/Feature Playbook.md`
  - Current lifecycle requires active folder artifacts (`user-story.md`, `spec.md`, `plan.md`) before coding; no explicit lightweight exception path currently documented.
- `docs/features/templates/README.md`
  - Reinforces full template completion for active features and separate refactor templates for non-user-facing work.
- `docs/features/templates/feature/spec.md`
  - Current spec template is design-heavy and optimized for full-feature documentation.
- `docs/features/templates/feature/user-story.md`
  - Requires full story/persona framing that may be overhead for plug-and-plan changes.
- `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`
  - Requires phased atomic plan and full references, also design-heavy for minor pre-cooked changes.
- `scripts/dev_tools/potential_to_issue.py`
  - Promotion body is assembled from fixed sections (`Problem / Why`, `Proposed Behavior`, AC, constraints, tests), and then moved to `docs/features/potential/promoted/`; this is a direct seam for issue-body contract changes.
- `scripts/dev_tools/new_active_feature_folder.py`
  - Always creates/opens full active folder template set for `feature`; currently seeds `user-story.md/spec.md/plan` and moves promoted potential into active folder as `issue.md`.
- `.vscode/tasks.json`
  - Promotion and active-folder flow is wired through `Dev: 2 Promote Potential to GitHub Issue` and `Dev: 3 Create Active Folder`; issue-template tasks reference `.github/ISSUE_TEMPLATE/*` but repository currently has no such folder.

### Code Search Results

- `Minor Change Audit Path|bootstrapped|baseline|end-state|minimum evidence`
  - Matches found in feature docs (`issue.md`, `spec.md`, `user-story.md`) under `docs/features/active/2026-02-19-minor-audit-small-change-28/`.
- `ISSUE_TEMPLATE|issue template|blank_issues_enabled|config.yml`
  - Found references in `.vscode/tasks.json`, but no `.github/ISSUE_TEMPLATE/` files currently exist.
- `issue.md|user-story.md|spec.md|plan|promoted`
  - Found behavior-defining seams in `scripts/dev_tools/potential_to_issue.py` and `scripts/dev_tools/new_active_feature_folder.py`; existing tests in `tests/scripts/dev_tools/test_potential_to_issue.py` and `tests/scripts/dev_tools/test_new_active_feature_folder.py` already cover key promotion/creation paths.

### External Research

- #githubRepo:"N/A (tool unavailable in this environment) issue-template and issue-body governance patterns"
  - Dedicated GitHub repository search tool is unavailable in this session; authoritative external evidence was gathered from GitHub Docs and GitHub CLI docs.
- #fetch:file:///c%3A/Users/DanMoisan/repos/drm-copilot/.github/prompts/research-issue.prompt.md
  - Confirms required output contract: single research file under `artifacts/research/`, one selected recommendation, brief rejected alternatives, explicit implementation hooks, risks, and verification plan.
- #fetch:https://github.com/drmoisan/drm-copilot/issues/28
  - Returned HTTP 404 from fetch context; local `issue.md` in the active feature folder was treated as the authoritative feature specification.
- #fetch:https://docs.github.com/en/issues/tracking-your-work-with-issues/learning-about-issues/about-issues
  - Confirms issues are a first-class planning/tracking artifact for bugs/features/tasks and support metadata, dependencies, and integration with PR/project workflows.
- #fetch:https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-an-issue
  - Confirms issue creation supports templates and body-driven workflow patterns (web, CLI, URL query), useful for standardized minor-audit issue bodies.
- #fetch:https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/about-issue-and-pull-request-templates
  - Confirms repository-level issue templates/forms can standardize required issue fields and improve consistency.
- #fetch:https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository
  - Confirms `.github/ISSUE_TEMPLATE/` with `config.yml` can enforce template chooser behavior and disable blank issues if desired.
- #fetch:https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms
  - Confirms issue forms support required fields and validations, and convert responses to structured markdown issue bodies.
- #fetch:https://cli.github.com/manual/gh_issue_create
  - Confirms `gh issue create` supports `--body-file`, `--template`, labels, and repo targeting; aligns with current `potential_to_issue.py` non-interactive workflow.
- #fetch:https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/about-task-lists
  - Confirms checklist semantics for issue body tracking and notes current shift toward sub-issues for deeper decomposition.

### Project Conventions

- Standards referenced: Feature lifecycle in `docs/engineering/Feature Playbook.md`; template expectations in `docs/features/templates/README.md`; promotion/creation automation in `scripts/dev_tools/potential_to_issue.py` and `scripts/dev_tools/new_active_feature_folder.py`.
- Instructions followed: `.github/prompts/research-issue.prompt.md`, `.github/instructions/general-code-change.instructions.md` (planning and compliance), Task Researcher operating constraints.

## Key Discoveries

### Project Structure

The current flow has a rigid handoff: potential doc -> promoted issue -> active folder with full feature templates. The requested Minor Change Audit Path conflicts with that rigidity at one key point: active-folder tooling assumes full template workflow for all `feature` work. There is no documented or automated policy branch for "small pre-cooked change, issue-centric audit only".

### Implementation Patterns

- `potential_to_issue.py` already maps structured markdown sections to issue body content and is the most direct place to enforce a minimum-audit issue contract.
- `new_active_feature_folder.py` currently seeds all major docs and opens them by default for `feature`; a minor-audit mode would need a branching path or alternate template selection.
- Existing test suites are robust and can absorb targeted coverage additions for eligibility gating and reduced-evidence behavior.

### Complete Examples

```python
# Source: scripts/dev_tools/potential_to_issue.py
def build_body(
    problem: str,
    behavior: str,
    criteria: str,
    constraints: str,
    tests: str,
    relative_path: str,
) -> str:
    return (
        f"## Problem / Why\n{problem}\n\n"
        f"## Proposed Behavior\n{behavior}\n\n"
        f"## Acceptance Criteria\n{criteria}\n\n"
        f"## Constraints & Risks\n{constraints}\n\n"
        f"## Test Conditions\n{tests}\n\n"
        f"## Source\nFrom: {relative_path}\n"
    )
```

### API and Schema Documentation

- `gh issue create` (`--body-file`, `--template`, `-R`) supports deterministic, non-interactive issue creation and repository targeting.
- GitHub issue templates/forms support required fields and validations in `.github/ISSUE_TEMPLATE/`.
- Issue form top-level required keys are `name`, `description`, and `body`; optional keys (`labels`, `title`, `type`, `assignees`, `projects`) can automate minor-audit metadata.

### Configuration Examples

```yaml
# Canonical issue-template chooser control (.github/ISSUE_TEMPLATE/config.yml)
blank_issues_enabled: false
contact_links:
  - name: Questions / Support
    url: https://github.com/orgs/community/discussions
    about: Use discussions for non-actionable support threads.
```

### Technical Requirements

- Implement a deterministic eligibility gate for Minor Change Audit Path:
  - bootstrapped/pre-cooked solve OR
  - <=3 production files (+ corresponding tests), narrow blast radius, low integration risk.
- Define a minimum audit evidence contract aligned with existing evidence schema:
  - baseline evidence artifact
  - end-state evidence artifact
  - targeted verification artifact
  - explicit rationale when broad regression is skipped.
- Preserve default full-feature workflow as fallback when eligibility fails.

**Mandatory unachievable objective callout**:
- **Direct fetch verification of GitHub issue #28 was not achievable in this session (`HTTP 404`), so local active-folder `issue.md` was used as the authoritative source.**

## Recommended Approach

Adopt an **Issue-Centric Minor Audit Path (Mode-Gated)** with explicit eligibility and evidence contracts, implemented as a narrow extension of existing automation rather than a new parallel lifecycle.

Selected approach details:

1. Add a `minor-audit` mode flag to promotion/active-folder workflow.
2. In `minor-audit` mode, require expanded `issue.md` sections as the primary planning artifact, and treat `user-story.md/spec.md/plan` as optional/non-generated unless scope expands.
3. Require minimum evidence artifacts under active feature evidence folders:
   - `evidence/baseline/`
   - `evidence/other/` (end-state + targeted verification)
4. Keep full-feature path unchanged as the default fallback when eligibility is not met.

Proposed state model:

- `DraftPotential` -> `PromotedIssue` -> `EligibilityEvaluated`
- `EligibilityEvaluated` -> `MinorAuditQualified` or `FullFeatureRequired`
- `MinorAuditQualified` -> `IssueCentricExecution` -> `BaselineCaptured` -> `EndStateCaptured` -> `TargetedVerificationCaptured` -> `ReviewReady`
- `FullFeatureRequired` -> existing full template workflow states.

Where/when updates occur:

- Promotion time: enforce/add minimum issue sections in `potential_to_issue.py` body builder.
- Active folder creation time: branch behavior in `new_active_feature_folder.py` to skip or defer full docs when `minor-audit` is selected.
- Verification/reporting time: standardize minimum evidence filenames and schema fields (`Timestamp`, `Command`, `EXIT_CODE`, `Output Summary` for baseline).

High-level pseudocode:

```text
if qualifies_minor_audit(issue_content, changed_file_budget, risk_profile):
    ensure_issue_sections(issue_md, required_minor_sections)
    create_or_verify_evidence_paths(feature_root)
    require_artifact("evidence/baseline/*.md")
    require_artifact("evidence/other/*end-state*.md")
    require_artifact("evidence/other/*targeted-verification*.md")
    mark_review_mode("issue-centric")
else:
    run_existing_full_feature_flow()
```

Specific implementation hooks:

- `scripts/dev_tools/potential_to_issue.py`
  - Extend section extraction/body generation for minor-audit required headers.
  - Optional flag: `--work-mode minor-audit|full`.
- `scripts/dev_tools/new_active_feature_folder.py`
  - Add mode-aware doc materialization logic for `feature` type.
  - Keep fallback to existing template behavior.
- `docs/engineering/Feature Playbook.md`
  - Add formal eligibility criteria and mode-routing rules.
- `docs/features/templates/README.md`
  - Document when to use minor-audit vs full-feature vs refactor.
- `.vscode/tasks.json`
  - Add or update inputs/tasks to pass mode signal through promotion/active-folder commands.

Risks and mitigations:

- Risk: mode abuse to skip needed rigor.
  - Mitigation: explicit gate checklist in issue body + reviewer sign-off criterion.
- Risk: reduced regression misses adjacent breakage.
  - Mitigation: mandatory targeted verification scope statement and escalation trigger for broad regression.
- Risk: lifecycle fragmentation.
  - Mitigation: single flow with mode flag; full path remains default.

Verification plan (design-level):

- Unit tests:
  - eligibility evaluator (`minor-audit` qualified vs rejected)
  - issue section validator/injector
  - evidence contract validator (required files + schema fields)
- Integration concept (no external services, no temp-file dependency in tests):
  - fake filesystem + fake gh client test proving end-to-end mode routing from potential -> promoted issue body -> active folder result.

Rejected alternatives (brief):

- **New standalone template family (`docs/features/templates/minor-audit/*`)**: rejected as first step because it duplicates lifecycle surfaces and increases maintenance burden before eligibility/routing logic is stabilized.
- **Policy-only change without automation hooks**: rejected because manual enforcement is likely to drift and recreate split-brain behavior between issue-first and template-first paths.

## Implementation Guidance

- **Objectives**: Make `issue.md`-centric minor audit path deterministic, auditable, and low-overhead for pre-cooked/small-scope work while preserving full-feature fallback.
- **Key Tasks**:
  - Add mode flag + eligibility gate in promotion/active-folder tooling.
  - Define required issue sections and minimum evidence contract.
  - Update playbook/templates/tasks to document and route mode consistently.
  - Add targeted unit/integration tests for routing and evidence requirements.
- **Dependencies**: Existing Python tooling (`potential_to_issue.py`, `new_active_feature_folder.py`), active-feature evidence conventions, VS Code task wiring.
- **Success Criteria**: Reviewer can approve qualifying minor work from expanded `issue.md` + minimum evidence only; non-qualifying work is automatically routed to full-feature docs path.