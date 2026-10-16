# R1 QC Source Tokens (Issue #927, CR-1, CR-2, CR-3, CR-4, CR-5, CR-9 source halves; loop pass 2)

Timestamp: 2026-10-16T08-45
Command: grep -c -F -e 'exit 124' tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1
EXIT_CODE: 0
Output Summary: Every rerun grep of [P2-T3] (without its line count), [P2-T4], [P3-T1] to [P3-T4], [P4-T1], [P4-T3], [P4-T5], and [P5-T5] prints the value its task states. [P5-T1] is not rerun because the CR-5 fallback of decision D-R1-6 has run; suite E's pair is therefore 8 7.

[P2-T3] exit 124: 3 | --match-head-commit=: 3 | GhOutput = '[]': 1 | --auto=true: 1
[P2-T4] --base main -B=main: 1 | -dB=other: 1 | gh pr create -B=main: 0 (exit 1) | DocsOnly line count: 243
[P3-T1] function Invoke-DocsOnlyBoundedNative {: 1 | ^function : 9 | & $ProcessStarter $startInfo: 1
[P3-T2] git @args: 0 (exit 1) | gh @args: 0 (exit 1) | -TimeoutMilliseconds 3000 }: 1 | -TimeoutMilliseconds 7000 }: 1 | & $GitInvoker -C $WorktreeRoot @GitArgs: 1 | & $GhInvoker @GhArgs: 1
[P3-T3] Time limit:: 1 | working directory set by an earlier shell call: 1 | reports exit code 124, which denies: 1 | through the -ProcessStarter parameter: 1
[P3-T4] helper line count: 478 | 'fetch', Import-Module, Get-Content, (Get-Location).Path, ReadAllText, ReadAllLines, Invoke-Expression, dot-source line: 0 (one alternation grep, exit 1)
[P4-T1] made by an earlier Bash call: 1 | Claude gate line count: 491
[P4-T3] earlier shell call is not visible either: 1 | Codex gate line count: 411
[P4-T5] GH_REPO or GH_HOST: 1 1 1 | DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: 1 1 | --match-head-commit: 2 2
[P5-T1] not rerun (CR5_DECISION: RETAINED)
[P5-T5] It/Arrange pairs: A 21 21, B 13 13, D 7 7, E 8 7 (CR-5 retained), F 8 8
