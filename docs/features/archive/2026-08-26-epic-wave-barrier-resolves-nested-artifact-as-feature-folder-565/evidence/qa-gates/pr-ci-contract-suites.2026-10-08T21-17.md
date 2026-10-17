# PR CI evidence: contract and manifest suites (spec.md AC item 30)

Timestamp: 2026-10-08T21-17
Command: gh run view 37868178642 --repo drmoisan/drm-copilot --json headSha,conclusion,event,url; gh pr checks 854 --repo drmoisan/drm-copilot; gh run view 37868178642 --repo drmoisan/drm-copilot --job 113619819769 --log; gh run view 37868178642 --repo drmoisan/drm-copilot --job 113619819876 --log; gh run view 37868178642 --repo drmoisan/drm-copilot --job 113619819718 --log
EXIT_CODE: 0
Output Summary:
- PR #854 (base epic/enforcement-hook-precision-integration); workflow run CI 37868178642, event pull_request, headSha e4499d72204b8625dbdfc562d932c9259f329281, conclusion success (re-verified by this executor with `gh run view` at the timestamp above). All 20 checks on the PR passed.
- quality-checks7 / Code Quality & Tests (3.12), job 113619819769:
  - tests/scripts/dev_tools/test_codex_core_manifest_closure.py `.....`
  - tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py `.`
  - tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py `....`
  - tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py `.`
  - tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py `.`
  - summary: `6603 passed, 6 skipped in 171.42s`
  - The 3.10, 3.11, and 3.13 jobs also passed.
- poshqc / PowerShell hook suites (Linux), job 113619819876: `[+] tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `[+] tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
- poshqc / PowerShell QC (Windows), job 113619819718: the same two Pester files reported `[+]`.

Provenance: the per-job log facts were collected by the orchestrator with gh; this executor re-verified the run-level headSha, event, and conclusion.

## Links

- PR: https://github.com/drmoisan/drm-copilot/pull/854
- Run: https://github.com/drmoisan/drm-copilot/actions/runs/37868178642
- Python 3.12 job: https://github.com/drmoisan/drm-copilot/actions/runs/37868178642/job/113619819769
- PowerShell hook suites (Linux) job: https://github.com/drmoisan/drm-copilot/actions/runs/37868178642/job/113619819876
- PowerShell QC (Windows) job: https://github.com/drmoisan/drm-copilot/actions/runs/37868178642/job/113619819718
