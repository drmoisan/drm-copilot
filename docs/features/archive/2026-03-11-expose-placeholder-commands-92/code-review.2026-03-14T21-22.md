# Code Review: expose-placeholder-commands feature branch

**Base Branch:** `origin/development`  
**Feature Folder:** `docs/features/active/2026-03-11-expose-placeholder-commands-92`  
**Feature folder selection rule:** Selected this folder because `artifacts/pr_context.summary.txt` marks its `spec.md` and `user-story.md` as the primary scoping docs changed and the folder suffix matches issue `#92`.  
**Review scope decision:** umbrella review scope, documented in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/other/review-scope-map.2026-03-14T15-48.md`.

## Executive Summary

Relative to `origin/development`, this branch replaces the extension’s four placeholder commands with real command handlers, bundles the corresponding Python and PowerShell runtime assets, and includes the downstream bugfixes merged into the same umbrella branch (`#93`, `#95`, and `#98`). The current reviewed state is technically sound: TypeScript, Python, and PowerShell verification all passed in this session, the thin-wrapper requirement is satisfied, and the authoritative acceptance criteria are fully checked off.

### Top 3 risks

1. **Umbrella-branch breadth.** The branch is much wider than feature `#92` alone, so reviewers need to stay anchored to the scope map and PR context instead of assuming a narrow single-feature diff.
2. **Bundled/runtime drift risk.** The extension still carries bundled copies of repo-side Python/PowerShell logic, so future changes need parity checks to avoid slow desynchronization.
3. **Tool bootstrap inside PowerShell tests.** The PowerShell suite downloads `actionlint` when absent, which is workable but adds an avoidable test-environment wrinkle.

**PR readiness recommendation:** **Go** — ready to open/merge into `origin/development` after normal CI.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `artifacts/pr_context.summary.txt` / branch scope | umbrella branch | The review surface includes merged PRs `#94`, `#96`, and `#99` in addition to issue `#92`. | Keep the PR description explicit that this is an umbrella branch, and point reviewers at the feature-scope map first. | This is a reviewability risk rather than a correctness failure. | `artifacts/pr_context.summary.txt` lists PRs `#94`, `#96`, and `#99` in range and reports 254 changed files. |
| Minor | `docs/features/active/2026-03-11-expose-placeholder-commands-92/issue.md` | acceptance checklist | The local issue mirror currently shows the wrapper-template criterion unchecked even though the authoritative full-feature sources (`spec.md` and `user-story.md`) are fully checked and the code/evidence pass. | Sync the local issue mirror in a follow-up if that file is intended to remain a human-friendly summary. | Not a release blocker because `issue.md` is not the authoritative AC source in `full-feature` mode, but it can mislead reviewers. | `issue.md` shows criterion 3 unchecked; `user-story.md` shows 9/9 checked; wrapper parity evidence records `Result: PASS`. |
| Nit | `tests/scripts/dev-tools/run-actionlint.Tests.ps1` (via Pester output) | test bootstrap path | The PowerShell test suite downloads `actionlint` on demand when it is missing. | Preinstall or cache the tool in CI/dev bootstrap so the test path stays fully local. | On-demand downloads are slightly noisier and less hermetic than fully prepared test environments. | Direct `Invoke-PoshQCTest -Root .` output includes `actionlint not found; downloading local copy into tools/actionlint/bin...`. |

## Typed Python Audit

### Strong typing

- `poetry run pyright` completed with `0 errors, 0 warnings, 0 informations`.
- Reviewed changed Python modules use explicit annotations, `Protocol`, and `@dataclass` patterns where appropriate.
- No new `Any`-driven escapes surfaced in the sampled changed Python runtime files.

### Error handling and contracts

- The earlier broad-catch concern in `new_active_feature_folder_io.py` is resolved in the reviewed state; `updatedAt` handling is explicit and no longer depends on `except Exception`.
- Wrapper-template contracts are now explicit and thin. `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` only adjusts `sys.path` and delegates to bundled `dev_tools.new_potential_bug_entry`.
- User-facing validation remains explicit for short names, feature names, runtime discovery, and subprocess exit handling.

### Public API clarity

- The extension’s command surface is intentionally small and explicit.
- Python wrapper modules document their purpose and constraints clearly enough for maintenance.
- The bundled/repo-root split is understandable, but it remains a maintenance hotspot because parity must be preserved manually.

## Test Quality Audit

- **Deterministic:** TypeScript and Python acceptance-path tests are deterministic and mock external boundaries appropriately.
- **Isolated:** The branch’s command-handler tests focus on single behaviors: registration, arguments, cancellation, runtime failures, and wrapper import/delegation.
- **Fast:** Fresh runs were quick—extension Jest about 1.0s, Python about 3.0s, Pester about 5.5s.
- **Coverage:** Python changed-module coverage clears the repo threshold; TypeScript command-handler coverage remains strong at 89.3% statements; PowerShell branch-level tests passed with stable aggregate coverage.

## Security / Correctness Checks

- No secrets were introduced in the sampled changed files.
- Subprocess calls are built from argv arrays rather than shell-concatenated user input in the reviewed TypeScript/Python paths.
- User input is validated at boundaries (`showInputBox` validators, CLI argument parsing, runtime-not-found handling).
- No unsafe HTML or dynamic-code patterns surfaced in the reviewed extension command path.

## Research Log

No external research was required. Findings are grounded in repository policy files, PR-context artifacts, direct file inspection, and fresh local verification.

## Recommendation

**Go for PR readiness.**

The branch is functionally ready and policy-clean in its current reviewed state. The remaining concerns are reviewer-experience / maintenance risks rather than correctness blockers, so the branch is suitable for merge into `origin/development` once CI confirms the same results.