# Remediation Inputs - Issue #1047 (feature review 2026-11-03T21-58, re-audit after cycle 2)

Review-Verdict: PASS

- Feature folder: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
- Branch: `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `22af34134`
- Base: `origin/main` @ `01706c697f3ad4a53b4a771d99d851afc7417ea9` (merge base)
- Source artifacts:
  - `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/policy-audit.2026-11-03T21-58.md`
  - `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/code-review.2026-11-03T21-58.md`
  - `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/feature-audit.2026-11-03T21-58.md`
- Findings that require remediation: 0.

## Resolution of the Cycle 2 Items (remediation-inputs.2026-11-03T21-16.md)

- N1 (option-shaped `-Branch`, `-Main`, `-Ref`): resolved in `22af34134`. The review re-ran the CLI suite (81/81) and called the real CLI: `-Ref:-p`, `-Ref --output=x`, and `-Branch:--upload-pack=x` exit 2 with the new message; `-Ref origin/main` exits 0.
- N2 (spec design names `ParallelAdmissionJson.psm1`): resolved; the edit is in `## Implementation Strategy` and no acceptance-criterion line changed.
- Coverage at HEAD: `Invoke-ParallelAdmission.ps1` 96.48% (at or above the 96.44% floor), repo-wide PowerShell LINE 92.61%, read from `artifacts/pester/powershell-coverage.xml`, whose missed line numbers map onto the committed HEAD content.

## Remediation Findings

None.

## Non-Remediation Items (for information; not remediation triggers)

- Spec criterion "Precedence rejection and barrier" stays unchecked pending the CI job `poshqc / PowerShell hook suites (Linux)`; the item orchestrator checks it off at S9.
- Full-tree Pester failures on this Linux host (409 single-process) are the same 97 distinct failure lines as cycle 1, pre-existing at the merge base and in suites outside the diff (`policy-audit.2026-11-03T21-58.md` Section 8). The `windows-latest` CI shards are the authoritative result at S9. The PATH leak in `tests/scripts/dev-tools/run-actionlint.Tests.ps1` line 497 is an unrelated test-isolation defect; file it as a separate issue.
- One Minor code-review finding may be fixed in this item at the orchestrator's discretion: the receipt field `base_commit` reaches `git merge-base --is-ancestor` and `git diff --name-only --no-renames` without a format check (`code-review.2026-11-03T21-58.md` Findings Table).
