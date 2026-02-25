# `pr-context-verification-contract-gap` — User Story

- Issue: #46
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-22

## Story Statement

- As a maintainer generating PR descriptions, I want verification claims to be derived from explicitly allowed canonical evidence files, so that completed work is reported accurately without violating anti-hallucination rules.
- As a reviewer approving changes, I want PR verification text to distinguish CI availability from canonical QA evidence results, so that I can make release decisions from auditable, deterministic signals.

## Problem / Why

Current PR-context generation under-reports completion because canonical evidence files are not included in `Additional context files`, which are the only files a PR author is allowed to cite. The prompt correctly enforces strict source constraints, so the system defaults to conservative “Not verified in this PR” wording even when feature evidence exists and indicates pass. Closing this contract gap improves truthfulness and auditability without relaxing safety constraints.

## Personas & Scenarios

- Persona: repository maintainer preparing PRs
  - needs strict source-traceable PR language
  - wants verification statements to reflect actual QA evidence
  - cannot rely on unstated files or inferred claims
  - needs deterministic artifact output for repeatable reviews
  - wants CI-unavailable cases to avoid false negative status statements
- Scenario: maintainer regenerates PR context for a branch with canonical evidence
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
    - a maintainer on an active feature branch
  - what triggered the action?
    - PR authoring requires updated verification status
  - what steps do they take?
    - run `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
    - verify `artifacts/pr_context.summary.txt` includes normalized verification evidence entries
    - generate PR body with `.github/prompts/generate-pr.prompt.md`
  - what obstacles or decisions occur?
    - if CI status is unavailable, maintainer must rely only on canonical evidence records and keep wording conservative when evidence is missing/malformed
  - what outcome do they expect?
    - PR verification section reports evidence-backed completion when allowed by contract and otherwise reports explicit conservative fallback


## Acceptance Criteria

- [ ] `Additional context files` includes canonical evidence artifact paths used to support verification statements for active features.
- [ ] Collector summary contains `Verification evidence (feature docs + canonical artifacts)` entries with parsed `Timestamp`, `Command`, `EXIT_CODE`, and normalized pass/fail result when parseable.
- [ ] When CI status is unavailable but canonical evidence indicates pass, generated verification wording explicitly reports evidence-backed pass while preserving CI-unavailable status.
- [ ] When evidence is missing or malformed, verification wording remains conservative and does not claim completion.
- [ ] Regression and integration tests cover positive, negative, and edge cases for evidence discovery, parsing, and prompt-contract-safe wording.

## Non-Goals

Do not relax anti-hallucination source restrictions in the PR-generation prompt. Do not add non-canonical evidence sources outside feature evidence folders. Do not change unrelated PR-context sections or GitHub branch/auto-close behavior as part of this fix.

## Validation Outcomes

- Prompt contract tier verification: `evidence/regression-testing/pass-prompt-contract-tier.2026-02-22T21-00.md`
- Verification rendering/fallback verification: `evidence/regression-testing/pass-verification-render-and-fallback.2026-02-22T21-00.md`
