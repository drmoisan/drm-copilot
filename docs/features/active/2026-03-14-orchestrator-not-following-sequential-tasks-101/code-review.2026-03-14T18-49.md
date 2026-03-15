# Code Review: orchestrator-not-following-sequential-tasks (#101)

**Review Date:** 2026-03-14  
**Feature Folder:** `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101`  
**Feature Folder Selection Rule:** User-specified active folder for issue `#101`; it matches the issue suffix `-101` and was used directly without alternate-folder tie-breaking.  
**Base Branch:** `development`

## Executive summary

The reviewed change is focused and internally consistent: it updates the root C# orchestrator agent, the C# orchestration prompt, the C# router/state-machine skills, and the bundled extension customization mirrors so the small path no longer jumps straight to planning or implementation. The branch also adds a targeted Python regression file, `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`, which captures the original contract drift as fail-before evidence and proves the repaired contract surface with six passing assertions.

The strongest evidence comes from the feature folder itself: five red regression artifacts, one consolidated green regression artifact, a QA summary describing the changed root and mirror files, and a clean repo-root Python QC pass. The only operational wrinkle is that the refreshed `pr_context` against `development` shows an empty committed range because the #101 work is presently in the working tree rather than in branch commits; that affects PR metadata visibility, not the implementation quality reviewed here.

Top 3 risks:
1. The review scope is not yet represented in committed branch history, so future reviewers will need a post-commit `pr_context` refresh before opening a PR.
2. There is no fresh end-to-end `/orchestrate-csharp-work` rerun artifact after the contract update; current confidence rests on contract-level tests plus the feature evidence trail.
3. The router skill intentionally distinguishes direct `csharp-typed-engineer` use from orchestrated small-path behavior; that nuance is now documented, but future edits could reintroduce ambiguity if parity tests are removed.

**PR readiness recommendation:** **Go for implementation quality.** Commit the current working-tree changes and refresh PR context before opening the PR so the branch diff becomes visible in the canonical comparison artifacts.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `artifacts/pr_context.summary.txt` | `Base/Head` and `Range` sections | The refreshed PR-context comparison against `development` shows `HEAD == merge-base`, so the intended #101 review scope is not yet visible as committed branch history. | Commit the current #101 changes, then rerun `poetry run python -m scripts.dev_tools.pr_context.collector --base development` before opening a PR. | Reviewing the live working tree is fine for this session, but canonical PR review artifacts should describe a real branch diff, not just local edits. | `artifacts/pr_context.summary.txt` after refresh reports `Range: dc0502de6e7b02ea76720fb898c038f01ad13f92..dc0502de6e7b02ea76720fb898c038f01ad13f92`. |
| Nit | `.github/skills/csharp-change-budget-router/SKILL.md` | route bullets + `## Orchestrated Small-Path Requirements` | The skill now correctly explains the orchestrated short path, but readers must combine the top routing bullets with the later section to understand why `csharp-orchestrator` behaves differently from direct `csharp-typed-engineer` usage. | Keep the direct-mode/orchestrated-mode distinction explicit in future edits and preserve the regression test that locks the wording in place. | This is not incorrect today; it is simply a place where future wording drift could reintroduce the very confusion issue #101 is fixing. | `.github/skills/csharp-change-budget-router/SKILL.md`; `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py::test_csharp_change_budget_router_requires_orchestrated_small_path_wording`. |
| Nit | `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101/evidence/**` | validation coverage | The feature has strong contract-level red/green evidence, but there is no fresh manual rerun note for `/orchestrate-csharp-work` after the markdown-contract update. | Optionally add one short manual validation note after re-running the issue’s original small-scope orchestration scenario. | The implementation surface here is configuration/contract driven, so an end-to-end note would be extra confidence rather than a hard blocker. | `spec.md` manual validation bullets request a rerun of `/orchestrate-csharp-work`; current evidence includes red/green contract tests and QC artifacts only. |

## Typed Python audit

### What changed well

- `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` is fully typed, uses a narrow helper, and avoids `Any` or implicit typing escapes.
- The test module relies on repository text fixtures only, which keeps the regression seam deterministic and easy to reason about.
- Mirror parity is enforced directly rather than by loose substring checks, which is the right level of strictness for bundled customization contracts.

### Typing and API notes

- No new `Any`, `# type: ignore`, or `# noqa` suppressions were introduced.
- The helper `read_repo_text(relative_path: str) -> str` is precisely annotated and keeps file access localized.
- No new public Python API surface was added; the Python change is test-only.

### Error handling and logging

- The test module does not broad-catch exceptions and lets missing files fail loudly, which is appropriate for contract verification.
- No ad-hoc logging or print-debugging was introduced.

## Test quality audit

- **Deterministic:** The suite reads checked-in files only and has no network, process, clock, or temp-file dependency.
- **Isolated:** Each test checks one contract invariant, making failures pinpoint the drift immediately.
- **Fast:** The targeted green run completed in `0.04s`, and the full repo-root Pytest run completed in `2.99s`.
- **Good failure messages:** The red artifacts capture the exact missing string or parity mismatch, which makes the regression easy to diagnose.

## Security and correctness checks

- No secrets, credentials, or external endpoints were introduced.
- No unsafe subprocess usage was added in the reviewed code.
- Input validation at the test boundary is adequate because the suite consumes repository-relative constant paths only.
- The large-path C# workflow remains preserved by explicit regression coverage, reducing the risk that the short-path fix accidentally broadens into a routing rewrite.

## Research log

No external research was required for this review. Repository policies, refreshed PR-context artifacts, the feature-folder evidence, and the current working-tree diff were sufficient.

## Verdict

No blocker or major code-quality issues were found in the #101 implementation. The contract updates are coherent, the root/bundled mirrors are synchronized, the regression tests are appropriately strict, and the repo-root verification loop passed cleanly. The only follow-up needed before PR opening is operational: commit the current working-tree changes and refresh `pr_context` so the canonical branch comparison reflects the reviewed scope.
