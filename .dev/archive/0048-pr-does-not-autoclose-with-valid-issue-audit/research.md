<!-- markdownlint-disable-file -->

# Task Research Notes: PR auto-close emission for audited issue when readiness is PASS

## Research Executed

### File Analysis

- `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/issue.md`
  - Defines target behavior: when active feature has deterministic `Issue: #46` and readiness is PASS, `pr_context` must emit an auto-close source recognized by `.github/prompts/generate-pr.prompt.md`.
- `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/spec.md`
  - Confirms root-cause hypothesis: `#46` appears only in `Close candidates`; PR prompt only consumes `Issues to autoclose (verified or pending)` or `PR Intent -> Author-asserted autoclose issues`.
- `artifacts/pr_context.summary.txt`
  - Current sample output shows `Auto-close issues (author asserted): #40 #42 #43 #46` under `Close candidates`, while `PR Intent` author-asserted field is blank and no `Issues to autoclose (verified or pending)` section exists.
- `scripts/dev_tools/pr_context/collector.py`
  - `author_asserted` is currently derived from all `referenced_issues`, then rendered only in `Close candidates`; PR Intent remains template-only (not populated).
  - Summary rendering pipeline is the canonical place to add a prompt-recognized auto-close section.
- `scripts/dev_tools/pr_context/feature_docs.py`
  - `gather_feature_excerpts()` currently extracts issue refs from full doc text (`extract_issue_references`) rather than explicit primary metadata (`- Issue: #NN`).
- `scripts/dev_tools/pr_context/models.py`
  - `FeatureDocExcerpt` currently carries `issue_refs` and `context_files`; no explicit field for primary issue or readiness signal.
- `scripts/dev_tools/pr_context/render_pr_helpers.py`
  - `build_close_candidates_section()` emits only `===== Close candidates =====`; no helper exists for `Issues to autoclose (verified or pending)`.
- `tests/scripts/dev_tools/test_collect_pr_context.py`
  - Existing tests assert current `Close candidates` behavior and include a regression that promotes referenced issues into author-asserted close candidates.
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py`
  - End-to-end summary rendering tests are already present and are the right seam for validating new summary section semantics.
- `tests/scripts/dev_tools/test_pr_context_integration.py`
  - Contains prompt-contract assertions and should be extended to enforce auto-close source compatibility.
- `tests/scripts/dev_tools/test_feature_docs.py`
  - Existing parsing tests provide the correct seam for adding deterministic primary-issue extraction + readiness gating behavior.
- `.github/prompts/generate-pr.prompt.md`
  - Explicitly allows auto-close only from: (1) `Issues to autoclose (verified or pending)`, else (2) `PR Intent -> Author-asserted autoclose issues`.

### Code Search Results

- `Author-asserted autoclose issues`
  - Found in `scripts/dev_tools/pr_context/collector.py` and `scripts/dev_tools/pr_context/render.py`; both are label-only intent templates today.
- `Close candidates`
  - Found in `scripts/dev_tools/pr_context/render_pr_helpers.py`; section is rendered but not consumed by PR-author prompt for `Closes #NNN`.
- `Issues to autoclose (verified or pending)`
  - Found as a required source in `.github/prompts/generate-pr.prompt.md`; not emitted by current collector summary output.
- `feature-audit` / readiness conventions
  - Feature review/orchestrator docs standardize `feature-audit.<timestamp>.md` with readiness values `PASS / NEEDS REVISION / BLOCKED`; this can be used as deterministic readiness source.

### External Research

- #githubRepo:"github/docs linking-a-pull-request-to-an-issue closing-keyword behavior"
  - Canonical docs source (`github/docs` content file) confirms close keywords only trigger issue closure when PR targets default branch and uses supported keywords like `Closes`, `Fixes`, `Resolves`.
- #fetch:https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue
  - Confirms keyword list, default-branch requirement, and distinction between linked references vs auto-close behavior.
- #fetch:https://github.com/github/docs/blob/main/content/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue.md
  - Confirms same semantics in source markdown used by GitHub Docs; strengthens correctness for prompt/summary contract decisions.
- #fetch:https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-branches-in-your-repository/changing-the-default-branch
  - Confirms default branch is PR base branch for canonical close-keyword behavior, reinforcing why deterministic source emission matters before PR authoring.

### Project Conventions

- Standards referenced: prompt-contract strictness, deterministic evidence-first output, conservative fallback behavior when verification sources are missing.
- Instructions followed: `.github/prompts/research-issue.prompt.md` framework, `.github/prompts/generate-pr.prompt.md` auto-close source constraints, Python test seams under `tests/scripts/dev_tools/*`.

## Key Discoveries

### Project Structure

`scripts/dev_tools/pr_context/collector.py` is the orchestration point that produces `artifacts/pr_context.summary.txt`, and `.github/prompts/generate-pr.prompt.md` is intentionally strict about which summary sections can feed `## GitHub Auto-close`. Because current collector output does not emit `Issues to autoclose (verified or pending)` and leaves `PR Intent` unpopulated, deterministic issue IDs from feature docs cannot flow into `Closes #NNN`.

### Implementation Patterns

Current issue derivation in `collector.py` combines broad reference detection (`referenced_issues`) with close-candidate rendering, which causes narrative mentions (`#40/#42/#43`) to mix with the audited feature issue (`#46`). Minimal-risk fix is to add a narrow, deterministic pending-autoclose source keyed to explicit feature metadata (`Issue: #NN`) and readiness PASS, rather than reusing broad mention extraction.

### Complete Examples

```text
Current behavior (from artifacts/pr_context.summary.txt):
- PR Intent:
  Author-asserted autoclose issues:
  (blank)
- Close candidates:
  Auto-close issues (author asserted): #40 #42 #43 #46

Prompt contract (.github/prompts/generate-pr.prompt.md):
- Allowed Closes sources:
  1) Issues to autoclose (verified or pending)
  2) PR Intent -> Author-asserted autoclose issues
- Close candidates is not a permitted source.
```

### API and Schema Documentation

- Existing data model: `FeatureDocExcerpt(feature, excerpt, issue_refs, context_files)`.
- Proposed schema extension (minimal):
  - Add deterministic `primary_issue_ref: str | None` extracted from feature doc metadata line `- Issue: #NN`.
  - Add optional `readiness_status: str | None` derived from latest `feature-audit.<timestamp>.md` (`PASS|NEEDS REVISION|BLOCKED`) when present.
- Summary output extension:
  - Add section header `===== Issues to autoclose (verified or pending) =====`.
  - Values precedence:
    1. Verified from GitHub PR metadata (`closingIssuesReferences`) when available.
    2. Pending deterministic audited issue when `primary_issue_ref` exists and readiness is PASS.
    3. Conservative none message.

### Configuration Examples

```text
No new configuration keys required.
Behavior should remain additive in pr_context summary schema.
```

### Technical Requirements

- Maintain compatibility with `.github/prompts/generate-pr.prompt.md` by emitting one of its accepted sources without relaxing anti-hallucination constraints.
- Avoid promoting narrative issue mentions into auto-close targets.
- Keep conservative behavior when deterministic audited issue cannot be resolved or readiness is not PASS.

**Mandatory unachievable objective callout**:
- **None identified for implementation strategy.**

## Recommended Approach

Implement **deterministic pending-autoclose emission** in `pr_context.summary.txt` via a new `Issues to autoclose (verified or pending)` section, sourced from explicit feature metadata + readiness PASS.

Detailed recommendation:
1. Extend feature-doc parsing to derive `primary_issue_ref` from the explicit metadata line (`- Issue: #NN`) instead of broad mention scanning.
2. Add readiness resolution helper that inspects latest `feature-audit.<timestamp>.md` in the active feature folder and returns readiness state.
3. In `collector.collect_and_write()` compute `issues_to_autoclose`:
   - If `verified_closing` exists, use it.
   - Else if deterministic `primary_issue_ref` exists and readiness == `PASS`, use `[primary_issue_ref]` as **pending**.
   - Else emit a conservative none reason.
4. Render `===== Issues to autoclose (verified or pending) =====` before `Close candidates`.
5. Keep `Close candidates` for diagnostics only; do not treat it as auto-close source.

Rejected alternatives (brief, non-exhaustive):
- Populate PR Intent `Author-asserted autoclose issues` automatically from all referenced issues.
  - Rejected: high risk of false positives (`#40/#42/#43`) and weak semantic boundary between mentions vs intended closes.
- Modify `.github/prompts/generate-pr.prompt.md` to accept `Close candidates`.
  - Rejected: weakens strict source contract and increases hallucination/over-close risk; prompt already supports intended dedicated section.

## Implementation Guidance

- **Objectives**: Emit `Closes #46` deterministically when audited issue is known and readiness is PASS, while preserving conservative behavior and prompt-source safety.
- **Key Tasks**:
  - Add deterministic primary-issue extraction + readiness derivation in `feature_docs` flow.
  - Add pending/verified auto-close summary section rendering in collector output.
  - Update tests to enforce single-source deterministic behavior and prevent mention-based over-closing.
  - Keep prompt compatibility unchanged (no required changes to `.github/prompts/generate-pr.prompt.md`).
- **Dependencies**:
  - Existing feature folder metadata (`issue.md`/`spec.md` lines with `Issue: #NN`).
  - Existing readiness artifact convention (`feature-audit.<timestamp>.md`).
- **Success Criteria**:
  - `pr_context.summary.txt` contains `===== Issues to autoclose (verified or pending) =====` with `#46` in pending/verified state for PASS-ready audited feature.
  - Generated PR body can produce `- Closes #46` using existing prompt rules.
  - Narrative issue references are excluded from auto-close unless explicitly verified or asserted by approved source.

- **Acceptance-oriented recommendations**:
  - AC1: Add a collector regression asserting only audited primary issue appears in `Issues to autoclose (verified or pending)` for PASS readiness.
  - AC2: Add negative regression asserting `#40/#42/#43` remain non-autoclose references when present only in narrative text.
  - AC3: Add fallback regression asserting section emits conservative `None (...)` text when readiness is missing/non-PASS.
  - AC4: Add integration assertion that prompt contract remains satisfied without changing allowed auto-close sources.

- **Concise implementation map (likely touched files)**:
  - `scripts/dev_tools/pr_context/feature_docs.py`
    - Add helper(s) to parse explicit issue metadata and readiness from feature-audit artifacts.
  - `scripts/dev_tools/pr_context/models.py`
    - Extend `FeatureDocExcerpt` with deterministic primary issue/readiness fields (or add a dedicated metadata dataclass).
  - `scripts/dev_tools/pr_context/collector.py`
    - Compute `issues_to_autoclose` precedence and render new summary section.
  - `scripts/dev_tools/pr_context/render_pr_helpers.py`
    - Add formatter helper for `Issues to autoclose (verified or pending)` section.
  - `tests/scripts/dev_tools/test_feature_docs.py`
    - Add tests for explicit `Issue: #NN` extraction and readiness parsing.
  - `tests/scripts/dev_tools/test_collect_pr_context.py`
    - Add deterministic pending-autoclose + mention-exclusion regression tests.
  - `tests/scripts/dev_tools/test_collect_pr_context_part4.py`
    - Add summary section rendering + conservative fallback assertions.
  - `tests/scripts/dev_tools/test_pr_context_integration.py`
    - Add prompt-compatibility scenario validating `Closes #46` source eligibility.

- **Verification commands (recommended)**:
  - `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`
  - `poetry run pytest tests/scripts/dev_tools/test_feature_docs.py -q`
  - `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context.py -q`
  - `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_part4.py -q`
  - `poetry run pytest tests/scripts/dev_tools/test_pr_context_integration.py -q`
  - `poetry run black .`
  - `poetry run ruff check`
  - `poetry run pyright`
  - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
