# `pr-does-not-autoclose-with-valid-issue-audit` — User Story

- Issue: #48
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-22

## Story Statement

- As a maintainer preparing a PR from an audited active feature, I want `pr_context` to emit deterministic autoclose issues from an approved section, so that I can reliably include `Closes #46` without violating prompt constraints.
- As a reviewer validating release readiness, I want narrative issue mentions to remain diagnostic-only and excluded from auto-close emission, so that merged PRs do not close unrelated issues.

## Problem / Why

The current PR-context output places relevant issue refs under `Close candidates`, but the PR authoring prompt only accepts autoclose numbers from `Issues to autoclose (verified or pending)` or `PR Intent -> Author-asserted autoclose issues`. This contract mismatch causes legitimate audited issue closures (for example `#46`) to be omitted even when readiness is `PASS`. Fixing this improves deterministic, safe issue-closing behavior while preserving anti-hallucination controls.

## Personas & Scenarios

- Persona: repository maintainer generating PR content
  - cares about deterministic, policy-compliant PR output
  - must avoid closing wrong issues from incidental references
  - wants audited issue closure to be emitted automatically when evidence is sufficient
  - needs reproducible behavior from `pr_context` artifacts
  - is constrained by strict prompt source rules
- Scenario: maintainer generates a PR for an audited active feature with `Issue: #46`
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
    - maintainer preparing PR text from generated artifacts
  - what triggered the action?
    - feature implementation is complete and audit readiness is `PASS`
  - what steps do they take?
    - run `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`
    - inspect `artifacts/pr_context.summary.txt` for `Issues to autoclose (verified or pending)`
    - generate PR content using `.github/prompts/generate-pr.prompt.md`
  - what obstacles or decisions occur?
    - if readiness is missing/non-`PASS`, maintainer must not emit auto-close claims
    - mention-only refs (`#40/#42/#43`) must be ignored for `Closes` lines
  - what outcome do they expect?
    - generated PR includes `Closes #46` only when deterministic eligibility is present, otherwise emits conservative no-autoclose behavior


## Acceptance Criteria

- [ ] `artifacts/pr_context.summary.txt` includes `===== Issues to autoclose (verified or pending) =====` after collector execution.
- [ ] When active feature metadata contains `Issue: #46` and readiness is `PASS`, the approved section includes `#46` and PR output can emit `Closes #46`.
- [ ] Mention-only refs (`#40/#42/#43`) are excluded from approved autoclose sources and do not appear as `Closes` lines.
- [ ] When deterministic inputs are incomplete (missing/invalid issue metadata or non-`PASS` readiness), autoclose output remains conservative and does not claim closure.
- [ ] Regression and integration tests cover positive path, invalid metadata path, readiness-gating path, and mention-exclusion path.

## Non-Goals

Do not relax `.github/prompts/generate-pr.prompt.md` source restrictions. Do not infer auto-close issues from generic narrative references. Do not modify unrelated `pr_context` sections beyond what is required to provide deterministic approved autoclose emission.