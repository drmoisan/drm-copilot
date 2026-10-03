# Review pass 3: AC-42 bats and kcov measurement of .codex/codex-web-setup.sh

Timestamp: 2026-10-03T16-55
Recorded by: feature-review agent (review pass 3)
Commit measured: 425772de97a84663d781d2bffeac4b8e4787787f (branch head; working tree clean)
Base for changed lines: f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5 (merge base with origin/main)
Environment: WSL2 Ubuntu; Bats 1.13.0; kcov 43+dfsg-2 (the same kcov major version, v43, that `.github/workflows/_shell-coverage.yml` builds). kcov output was written to the session scratch directory outside the repository; only this record is committed to the feature folder.

## Commands

1. `bats tests/shell/test_codex_web_setup_codex_copy.bats`
2. `kcov --include-pattern=<worktree>/.codex/codex-web-setup.sh <scratch>/run <bats> tests/shell/test_codex_web_setup_codex_copy.bats`, then `kcov --merge <scratch>/merged <scratch>/run` (the same two kcov invocations as the workflow step "Measure .codex/codex-web-setup.sh coverage with kcov (issue 824)")
3. `git diff --unified=0 f6ef5b2f HEAD -- .codex/codex-web-setup.sh` written to `<scratch>/changed-lines.diff` (84 lines)
4. `. ./scripts/dev-tools/KcovFunctionCoverageGate.ps1; Invoke-KcovFunctionCoverageGate -CoberturaPath <scratch>/merged/kcov-merged/cov.xml -SourcePath .codex/codex-web-setup.sh -DiffPath <scratch>/changed-lines.diff -Function resolve_repo_root, select_solution_file, list_root_solution_files, restore_packages_if_needed, verify_windows_visual_studio_task_capability, write_repo_notes -Threshold 85` (the same arguments as the workflow step "Gate .codex/codex-web-setup.sh changed-function coverage (issue 824)")
5. `bash -n .codex/codex-web-setup.sh`; `shellcheck -x .codex/codex-web-setup.sh`; `shfmt -d -i 2 .codex/codex-web-setup.sh`

## Results

- bats: 15 of 15 passed (C824-1 to C824-15), exit 0.
- kcov Cobertura report produced: `merged/kcov-merged/cov.xml` exists (whole file 34 of 200 instrumented lines, 17.0%; the pre-existing remainder of the script is outside AC-42, see spec Non-Goals advisory A2).
- Gate output (verbatim):

```
FUNCTION resolve_repo_root lines=10-16 instrumented=3 covered=3 pct=100 missed=NONE PASS
FUNCTION select_solution_file lines=20-24 instrumented=2 covered=2 pct=100 missed=NONE PASS
FUNCTION list_root_solution_files lines=28-30 instrumented=1 covered=1 pct=100 missed=NONE PASS
FUNCTION restore_packages_if_needed lines=274-294 instrumented=12 covered=12 pct=100 missed=NONE PASS
FUNCTION verify_windows_visual_studio_task_capability lines=312-319 instrumented=5 covered=5 pct=100 missed=NONE PASS
FUNCTION write_repo_notes lines=341-370 instrumented=1 covered=1 pct=100 missed=NONE PASS
CHANGED-LINES=47 INSTRUMENTED=20 UNCOVERED-CHANGED=NONE
GATE-FAILED=False
EXIT=0
```

- `bash -n`: exit 0. `shellcheck -x`: exit 0, no finding. `shfmt -d -i 2`: exit 0 (the file's established two-space style; `.codex/` is outside the shell-QC discovery roots).
- Line count 405 (at most 500). SHA-256 prefix `fd4824228f81` for both `.codex/codex-web-setup.sh` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` (byte-identical).
- Last line is `if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi` (source guard; pinned by C824-1).

## Verdict

AC-42 measurement: every function that contains a changed line is at 100% line coverage (threshold 85%), and no changed executable line is uncovered. This record is a local measurement; the CI step of the same name on the PR head remains part of AC-27.
