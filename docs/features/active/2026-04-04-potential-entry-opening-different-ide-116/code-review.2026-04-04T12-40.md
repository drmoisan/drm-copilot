# Code Review: potential-entry-opening-different-ide (Issue #116)

## Executive Summary

This review covers the post-implementation small-path delivery recorded under `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116`. The reviewed change set aligns the Python-backed VS Code launchers with the PowerShell control path by resolving the correct CLI (`code` vs `code-insiders`) and adding `--reuse-window` to the launch command, while adding regression coverage in the two pytest modules named by the issue.

**Feature folder selection rule:** The user-specified active folder was retained because it is the only folder matching issue `#116` and it includes complete Phase 0–2 evidence.

**Baseline note:** The root PR context artifacts were stale and referenced `feature/mcp-functions`. For this review, the authoritative baseline came from the feature folder itself plus `evidence/baseline/p0-t3.git-baseline.2026-04-04T12-21.md`, which records feature branch `potential-entry-opening-different-ide` at commit `da3fa594bcb10be67f885c7cc9f49aa1d83653b3` relative to base branch `development`.

**Top 3 risks**
1. Acceptance Criteria 1 and 2 are still unverified on live Windows.
2. Changed/new-code coverage is not isolated, so the 90% new-code coverage policy is not yet closed.
3. The launcher logic is duplicated between root and bundled copies, so even small documentation or behavior drift can recur if both copies are not updated together.

**PR readiness recommendation:** **No-Go / Needs revision.** The change is technically plausible and the recorded Python QC loop is clean, but the feature is not ready to merge until the live Windows behavior is observed and recorded for the two user-facing workflows.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/other/p1-t3.implementation-summary.2026-04-04T12-29.md` | lines 44-47 | AC-1 and AC-2 remain `UNVERIFIED / remediation required`. | Run the two live Windows workflows from an already-open workspace, record the observed same-window behavior, and add a timestamped evidence artifact in the feature folder. | The feature's primary user-facing requirement is same-window reuse. Static code inspection and unit tests are not sufficient to close that behavior. | `p1-t3.implementation-summary.2026-04-04T12-29.md`; `p2-t5.end-state-summary.2026-04-04T12-36.md` lines 11-16, 35-38 |
| Major | `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/p2-t5.end-state-summary.2026-04-04T12-36.md` | line 32 | Changed/new-code coverage remains `remediation required`. | Add a deterministic coverage artifact that isolates the four launcher files and the two targeted pytest modules, or document an approved policy exception if isolation is genuinely impossible. | Repo policy requires ≥90% coverage for new code. The current evidence shows no regression, but not policy closure for the changed lines. | `p0-t7.pytest-coverage.2026-04-04T12-21.md`; `p2-t4.pytest-coverage.2026-04-04T12-36.md`; `p2-t5.end-state-summary.2026-04-04T12-36.md` |
| Minor | `scripts/dev_tools/new_potential_bug_entry.py` and `scripts/dev_tools/new_active_feature_folder_io.py` | `new_potential_bug_entry.py` lines 241-243; `new_active_feature_folder_io.py` lines 253-255 | `_resolve_code_cli()` docstrings contain an accidental literal command fragment (`[code_cmd, "--reuse-window", ...]`) inside the summary line. The same artifact appears in the bundled mirrors. | Remove the stray literal from both root and bundled copies when the remediation pass occurs. | The repo requires robust intent-first docstrings. The current docstrings remain readable, but the stray literal is noise and suggests an editing artifact. | Direct file inspection during this review |

## Typed Python Audit

### Type quality

- Production functions remain fully annotated.
- `FileSystem` remains modeled as a `Protocol`, which is appropriate for the fake filesystem strategy in tests.
- `RealFileSystem` remains a small `@dataclass`, consistent with the repo's value-object guidance.
- No new `Any` usage appears in production code. The only `Any` import observed is in `tests/scripts/dev_tools/test_new_potential_bug_entry.py` for a monkeypatched helper signature.

### Contracts and boundaries

- `_is_insiders_session()` and `_resolve_code_cli()` give the launch contract a clear, typed seam.
- `default_code_launcher()` retains the existing boolean success contract rather than changing surrounding workflows.
- `create_bug_entry()` and the active-folder path keep filesystem and launcher concerns injected as callables or protocols, which supports deterministic unit testing.

### Error handling

- Validation and missing-template behavior remain explicit through `ValueError` and `FileNotFoundError` at the CLI boundary.
- No naked `except` blocks were introduced in the reviewed files.
- PATH resolution happens before subprocess invocation, which keeps the editor-launch behavior explicit and predictable.

### Logging and CLI behavior

- The scripts still use user-facing `print()` calls at the CLI boundary and for no-CLI warnings. That is acceptable for a CLI workflow, though it is better to keep helper-layer warning emission minimal.

### Public API clarity

- Helper naming is explicit and consistent.
- Internal helpers remain underscore-prefixed.
- The duplicated root/bundled copies increase maintenance risk, but the structure is consistent and understandable.

## Test Quality Audit

- The targeted red/green cycle is present and deterministic:
  - red run: `6 failed, 25 passed`
  - green run: `31 passed`
- The tests are isolated through fakes and monkeypatching rather than live editor invocations.
- The test names describe concrete behaviors rather than implementation trivia.
- The final full-suite recorded QC pass reports `911 passed` and `83%` total coverage.
- The remaining test-quality concern is not missing tests, but missing coverage isolation evidence for the changed code.

## Security and Correctness Checks

- No secrets were introduced in the reviewed evidence.
- The launchers resolve the editor CLI via `shutil.which()` before subprocess execution.
- The workflow still preserves graceful fallback when no editor CLI is available.
- Correctness risk remains only at the live integration boundary: whether Windows/Insiders actually reuses the originating window in the real host environment.

## Notes on Scope

The workspace was not checked out to the audited feature branch during this review, and the repo-level PR context artifacts were stale for a different feature. To avoid disturbing unrelated local changes, this review did not switch branches. Instead, it used the active feature folder's preserved evidence as the authoritative record for the small-path audit.

## Recommendation

**Needs revision before merge.**

The implementation appears directionally correct, and the recorded Python quality loop is clean. However, the feature remains short of merge readiness until:
1. live Windows verification closes AC-1 and AC-2, and
2. changed/new-code coverage evidence closes the policy gap recorded in the end-state summary.
