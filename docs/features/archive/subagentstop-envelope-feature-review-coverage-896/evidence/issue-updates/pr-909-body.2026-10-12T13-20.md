# PR #909 Body Evidence (AC-29)

Timestamp: 2026-10-12T13-20
Command: gh pr view 909 --repo drmoisan/drm-copilot --json body --jq .body
EXIT_CODE: 0
PostedAs: body
PR URL: https://github.com/drmoisan/drm-copilot/pull/909
PR State: OPEN (base epic/subagentstop-envelope-integration)
Branch head at verification: f0eeecd82399941ecf06882427d8e1eb0f284ebf

Output Summary:
- `gh` was available; the body below was retrieved live from GitHub (no local-file substitution was needed).
- `Refs #884` present: PASS (1 line matching `^Refs #884$`, body line 16).
- `Refs #897` present: PASS (1 line matching `^Refs #897$`, body line 17).
- Closing keyword adjacent to `#884` or `#897`: PASS (0 matches).
- Closing keyword adjacent to any issue number: 0 matches (no closing keyword is used for `#896` either; the body uses `Refs #896`).
- Cross-check against the sent body file `artifacts/pr_body_896.md` (SHA-256 d756dfd0fa9f092ae50e35fb800d89872159b9d14246a8ec24f45d37aaaf8cc0, equal to the receipt hash): `diff --strip-trailing-cr` reports only one trailing empty line appended by `gh --jq`; content is otherwise identical. The raw `gh` output SHA-256 is 8fbb59d87ba785edc5db728b0cde72ec58fa9bc9c07e312ccfdc97de78bf07f3 because of that trailing newline.
- AC-29 result: PASS.

## Checks

Reference checks (grep -cE, applied to the retrieved body):

- `^Refs #884$` -> count 1 (PASS)
- `^Refs #897$` -> count 1 (PASS)

Closing-keyword adjacency check (grep -ciE, case-insensitive):

```text
\b(close|closes|closed|fix|fixes|fixed|resolve|resolves|resolved)\b[[:space:]:]*#(884|897)\b
```

Result: count 0 (PASS).

Supplementary check for any closing keyword followed by an issue number:

```text
\b(close|closes|closed|fix|fixes|fixed|resolve|resolves|resolved)\b[[:space:]:]*#[0-9]+
```

Result: no matches.

All other mentions of `#884` / `#897` in the body (lines 25, 39, 73, 120, 121) are descriptive references with no adjacent closing keyword.

## Full PR Body (as returned by gh)

````markdown
## Suggested title

fix(hooks): feature-review coverage hooks read the SubagentStop envelope, block with exit 2, and share the root CLAUDE.md floor (E4)

## Summary

- The Claude feature-review SubagentStop gate (`.claude/hooks/validate-feature-review-coverage.ps1`) now reads the documented SubagentStop envelope through the E1 helper `subagentstop-envelope.ps1` and blocks with exit code 2. Before this change it read `$env:CLAUDE_HOOK_INPUT`, which SubagentStop does not set, and ended block paths with exit 1, which does not block SubagentStop.
- Unhandled exceptions in the decision path and payload anomalies (for example `EmptyPayload`, `UnparseableJson`) now block with exit 2 and a stderr reason instead of failing open.
- An unreadable root `CLAUDE.md` now fails closed (CR-4); an absent one still uses the 85/75 defaults.
- The Claude hook is split into entry, `-metrics`, and `-rules` files (CR-8); the threshold resolver accepts trailing comparator forms such as `70% minimum` and `80% or more` (CR-9); failing-row messages name the floor source.
- The Codex feature-review hook now reads its line floor from root `CLAUDE.md` through a shared `feature-review-coverage-thresholds.ps1` copy instead of a hard-coded 80 floor, and its line coverage is 100.00% (146/146).
- Feature-review skill and agent texts name root `CLAUDE.md` as the floor source instead of hard-coded 80%/90% figures.
- Epic child E4 of epic subagentstop-envelope (epic issue #904); targets `epic/subagentstop-envelope-integration`, not `main`.

Refs #896
Refs #884
Refs #897

## Why

From the feature spec (`docs/features/active/subagentstop-envelope-feature-review-coverage-896/spec.md`):

- The Claude feature-review SubagentStop completion gate did not block at runtime. It read `$env:CLAUDE_HOOK_INPUT`, which SubagentStop does not set, parsed `.output`, which the envelope does not carry, and ended a block path with `Write-Error` under `$ErrorActionPreference = 'Stop'` followed by `exit 1`. The effective process exit was 1, and exit 1 does not block SubagentStop (E1 live differential; PR #881 / #786). Any unhandled exception inside the decision function also ended as exit 1 and was therefore fail-open.
- Review findings from #824 / PR #879 remained open: CR-4 (unreadable `CLAUDE.md` behavior), CR-6 (per-test mock duplication), CR-8 (file size), and CR-9 (statement forms not recognized by the resolver).
- The Codex hook applied a separate hard-coded 80% floor and had low line coverage (the Codex half of #884).
- E1's merged spec governs the helper contract and consumer policy; the upstream-merge check (AC-1) verified E1 is merged into the integration branch and compared its contract item by item before any production change.

## What Changed

### Claude hook (transport, block semantics, CR-4, CR-8, CR-9)

- `.claude/hooks/validate-feature-review-coverage.ps1` (+124/-396): dot-sources `subagentstop-envelope.ps1` through the guarded single-statement pattern, calls `Read-SubagentStopEnvelope -InputText`, and blocks through `Exit-SubagentStopBlock` (exit 2). No `CLAUDE_HOOK_INPUT`, `Write-Error`, or `exit 1` remains in any of the three Claude hook files or their mirrors.
- `Invoke-FeatureReviewCoverageValidation` takes `-InputText` and no longer takes `-RawPayload` or `-AssistantText`; on a dependency failure it returns the `Get-HookDependencyFailureDecision` object unchanged (`ExitCode = 2`).
- Re-entry policy (E1 consumer rule 2) is pinned by the `E4-TR10` tests.
- New `.claude/hooks/validate-feature-review-coverage-metrics.ps1` (180 lines) and `.claude/hooks/validate-feature-review-coverage-rules.ps1` (195 lines); the entry file is 205 lines.
- `.claude/hooks/feature-review-coverage-thresholds.ps1`: accepts trailing comparator forms (`minimum`, `at least`, `or more`, `or higher`, `or above`, `or greater`) and rejects past-tense, multi-metric, and out-of-range statements; help names each accepted form.
- A corpus false-positive gate ran before the blocking switch: 45 initial false positives were reduced to 0 against the recorded corpus (`evidence/other/corpus-rule-changes.2026-10-12T06-02.md`).

### Codex hook (#884 Codex half)

- New `.codex/hooks/feature-review-coverage-thresholds.ps1`, byte-identical to the Claude copy and both bundle mirrors.
- `.codex/hooks/validate-feature-review-coverage.ps1` dot-sources it from `$PSScriptRoot`, contains no hard-coded 80 floor, and does not reference the Claude envelope helper. Its transport and continuation contract is unchanged; `.codex/config.toml` is unchanged.
- The thresholds module is listed in the Codex core pack manifest and in `$script:SharedModuleNames` of `legacy-codex-hook-contracts.Tests.ps1`.

### Skill and agent texts

- `feature-review-workflow/SKILL.md` copies (`.claude`, `.agents`, `.github`, bundle mirrors) and both `.codex/agents/feature-review.toml` copies name root `CLAUDE.md` as the floor source and no longer contain hard-coded `80%`/`90%` figures.

### Tests

- Claude suites: new `E4-ST*` static tests, `E4-TR*` regression tests on redirected stdin, shared helper file `validate-feature-review-coverage.E4.Helpers.ps1`; the previous exit-1 assertion is removed. CR-6: `Get-ArtifactFileResult` and `Set-ReviewArtifactMap` move to `BeforeAll` in the Issue824 suite, verified by an AST check (`E4-ST6`).
- Codex suites: new `feature-review-coverage-thresholds.Tests.ps1` (`E4-PX2` hash parity plus resolver rows), new `feature-review-coverage-floor-parity.Tests.ps1` (`E4-PX1`, Claude and Codex floors equal for three `CLAUDE.md` fixtures), and `E4-TR7`/`E4-TR8`/`E4-TR9`/`E4-ST7` in the Codex coverage suite.
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`: new `test_feature_review_texts_name_claude_md_floor_source` and widened `STEP_EIGHT_COPIES`.

### Mirrors and manifests

- Every changed or new file under `.claude/`, `.codex/`, `.agents/`, and `.github/skills/` has a byte-identical mirror under `extensions/drm-copilot/resources/`; the two new Claude hook files are added to the Claude core pack manifest.

### Docs

- Feature folder `docs/features/active/subagentstop-envelope-feature-review-coverage-896/`: spec, plan, and evidence under `evidence/other/`, `evidence/qa-gates/`, and `evidence/regression-testing/`.

## Architecture / How It Fits Together

- SubagentStop invokes `.claude/hooks/validate-feature-review-coverage.ps1`. The entry file dot-sources the E1 helper, the thresholds module, and the `-metrics` and `-rules` files through the guarded pattern; a load failure yields the dependency-failure decision with exit 2.
- The entry reads the envelope from stdin via `Read-SubagentStopEnvelope`. An invalid envelope blocks with `validate-feature-review-coverage: payload anomaly - <reason>`. A valid envelope proceeds to the decision body, which resolves floors via `Get-FeatureReviewCoverageThreshold` (root `CLAUDE.md` first, per-metric defaults 85/75), evaluates the advertised review artifacts and coverage rows, and blocks with exit 2 on any failing finding or unhandled exception.
- The Codex hook keeps its own transport and continuation output and consumes the same thresholds module from `.codex/hooks/`, so both hooks report the same line floor for the same `CLAUDE.md`.

## Verification

### Completed (from feature evidence)

- Acceptance criteria: 30 of 31 checked in `spec.md`; AC-29 (this PR body carries `Refs #884` and `Refs #897` with no closing keyword) is verified at PR time (`evidence/other/ac-status.2026-10-12T08-45.md`, `evidence/other/ac-29-handoff.2026-10-12T08-44.md`).
- Fail-first: on the base production files, `E4-TR1`, `E4-TR4`, the six positive `E4-TR5` rows, and `E4-TR7` failed (9 failed); on the branch head they pass (`evidence/regression-testing/fail-first.2026-10-12T00-05.md`, `evidence/qa-gates/fail-first-head-run.2026-10-12T08-39.md`).
- Final QC loop clean on pass 3 with no file change (`evidence/qa-gates/final-qc-loop.2026-10-12T08-33.md`): PoshQC format 0 changes; PSSA 0 findings; black, ruff, pyright clean; targeted Pester 1142 passed, 0 failed; full Pester run 10217 passed, 0 failed, 89.67% covered; contract pytest 87 passed and 26 passed.
- Per-file line coverage (`evidence/qa-gates/final-pester-coverage.2026-10-12T08-31.md`): Claude entry 98.82%, `-metrics` 100.00%, `-rules` 98.88%, thresholds copies 100.00%, Codex hook 100.00% (146/146). Changed-line coverage is at or above 98.67% for all six files; Codex hook baseline 99.29% to 100.00% (`evidence/qa-gates/coverage-delta.2026-10-12T08-38.md`).
- File sizes: no file at or above 500 lines; Codex hook 316 lines, `legacy-codex-hook-contracts.Tests.ps1` 497 lines (`evidence/qa-gates/file-size.2026-10-12T08-37.md`).
- Mirror SHA256 parity for all nine pairs and the resource-contract and manifest pytest suites pass (`evidence/other/mirror-log.2026-10-12T07-27.md`, `evidence/qa-gates/mirror-parity-pytest.2026-10-12T07-28.md`, `evidence/qa-gates/manifest-pytest.2026-10-12T07-28.md`).
- No changes under `.github/instructions` or `.claude/rules`; `.codex/config.toml` unchanged; E2/E3 validators, the E1 helper, `.claude/settings.json`, and the #824 feature folder are absent from the diff (`evidence/qa-gates/policy-files-unchanged.2026-10-12T07-24.md`, `evidence/qa-gates/codex-config-unchanged.2026-10-12T07-10.md`, `evidence/qa-gates/scope-boundary.2026-10-12T08-43.md`).
- Feature review remediation cycle 1 re-audit recorded 0 blocking findings (commit `f0eeecd82`).
- CI status at head: Not verified in this PR (not available in the context bundle).

### Recommended

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

```bash
poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py
```

## Backward Compatibility / Migration Notes

- `Invoke-FeatureReviewCoverageValidation` no longer accepts `-RawPayload` or `-AssistantText`; callers pass `-InputText`. All in-repo callers and tests are updated.
- The Claude gate now blocks (exit 2) in cases where it previously failed open, including payload anomalies, unhandled exceptions, and an unreadable root `CLAUDE.md`. This is the intended behavior change.
- The Codex hook floor changes from a hard-coded 80% to the root `CLAUDE.md` figure, defaulting to 85% line. Repositories without a stated figure see a higher line floor.
- The bundled payload changes take effect for consumers only after an extension rebuild and reinstall.

## Risks and Mitigations

- Risk: the switch to blocking surfaces false positives on legitimate review outputs. Mitigation: the corpus gate reduced recorded false positives from 45 to 0 before the switch.
- Risk: the threshold resolver accepts a statement it should not. Mitigation: negative rows cover past-tense, combined-metric, and out-of-range statements; the existing T824 rows pass unchanged.
- Risk: Claude and Codex floors drift. Mitigation: `E4-PX2` asserts hash equality of all four thresholds copies and `E4-PX1` asserts equal floors.
- Rollback: revert this PR's merge commit on `epic/subagentstop-envelope-integration`.

## Review Guide

1. `.claude/hooks/validate-feature-review-coverage.ps1` (entry, transport, block path), then the `-metrics` and `-rules` files.
2. `.claude/hooks/feature-review-coverage-thresholds.ps1` and its `.codex/` copy.
3. `.codex/hooks/validate-feature-review-coverage.ps1`.
4. Tests under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, then `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
5. Skill and agent text edits.
- Noisy: files under `extensions/drm-copilot/resources/` are byte-identical mirrors. Most of the 116 docs files are feature evidence; the corpus-run artifacts are 700+ lines each. The branch history includes `wip:` checkpoint commits and two merges of the integration branch.

## Follow-ups

- AC-29 is checked off after this PR is opened, from `gh pr view <number> --json body` recorded under the feature folder's `evidence/issue-updates/`.
- #884 also covers `.claude/lib/bash/compute-concurrency-batches.sh`, which is out of scope for this child.
- #897 remains open for the other epic children.

## GitHub Auto-close

- None. This epic child references issues only; no issue is set to auto-close from this PR.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

https://claude.ai/code/session_01HKWcdjg6d2VVFawbJ6GhU3
````
