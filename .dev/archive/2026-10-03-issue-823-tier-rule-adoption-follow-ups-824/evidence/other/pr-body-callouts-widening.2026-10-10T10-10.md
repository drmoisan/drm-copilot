# PR-Body Callout Addendum (PA-1 Scope Widening)

Timestamp: 2026-10-10T10-10

This addendum supplements, and does not replace, the P7-T2 callouts artifact.

1. Issue reference: unchanged. The PR body references the issue with the exact line `Refs #824` and uses no closing keyword for the issue.
2. Additional policy edit: `.claude/rules/shell.md` and its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md` add `.codex/` to the shell-qc discovery roots and the kcov include roots. Authority: the operator decision on feature-review finding PA-1 (2026-10-10), which widened #824 scope instead of recording a waiver and authorizes this edit for these two files only (spec.md Change Log, 2026-10-10).
3. Shell toolchain change: `scripts/bash/shell_qc_lib.sh` adds the `.codex` discovery root and appends `.codex` to the kcov include pattern; `tests/shell/test_shell_qc_discovery.bats`, `tests/shell/test_shell_qc_commands.bats`, and the fixture `tests/fixtures/shell_qc/.codex/codex_entry.sh` cover the change. `.github/workflows/_shell-coverage.yml` is unchanged.
4. `.codex/codex-web-setup.sh` now uses the shfmt default layout (a whitespace-only change; the P16-T6 ledger lists no shellcheck remediation); its bundled copy stays byte-identical. `.github/codex/codex-web-setup.sh` is a separate file with no parity test against `.codex/codex-web-setup.sh` and is unchanged.
5. Coverage: kcov measures `.codex/codex-web-setup.sh` at 95.67% line coverage (line-rate 0.957) in CI run 38057811190; repo-wide Bash line coverage is 94.3%. Three new bats suites (`tests/shell/test_codex_web_setup_codex_installers.bats`, `tests/shell/test_codex_web_setup_codex_dotnet.bats`, `tests/shell/test_codex_web_setup_codex_verify.bats`) add cases C824-16 to C824-61.
6. Follow-up list amendment: the out-of-scope follow-up stating that `.codex/` is outside shell-qc discovery and the kcov include roots is resolved by this PR and is removed from the follow-ups list. The other follow-ups in the P7-T2 callouts artifact are unchanged.

## Verification (P17-T7)

Command: the four P17-T7 greps over this file (fixed-string `Refs #824`; fixed-string `.claude/rules/shell.md`; fixed-string `PA-1`; case-insensitive closing-keyword pattern followed by the issue number)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `Refs #824` grep: 3 (exit 0).
- `.claude/rules/shell.md` grep: 3 (exit 0).
- `PA-1` grep: 4 (exit 0).
- Closing-keyword grep: 0 (exit 1), so no closing keyword for the issue is present.
