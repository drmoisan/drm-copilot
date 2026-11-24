# R1 contract and scope checks (P1-T11)

Timestamp: 2026-11-24T17-22
Command: pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check (through SCRATCH/issue-1233-harness.sh)
EXIT_CODE: 0
Output Summary: "harness-generation: no drift".

Timestamp: 2026-11-24T17-22
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check (through SCRATCH/issue-1233-codexgen.sh)
EXIT_CODE: 0
Output Summary: exit 0 with no output (no variant drift).

Timestamp: 2026-11-24T17-22
Command: git diff --name-only <reviewed head named in remediation-inputs.2026-11-24T13-43.md> HEAD ; git status --porcelain (through SCRATCH/issue-1233-r1-contract.sh; HEAD is 282b8f50c)
EXIT_CODE: 0
Output Summary:
- 37 cycle paths. Outside `<FEATURE>/` there are 16, each a file named in P1-T2 to P1-T6: the module and its bundle copy (P1-T2), the four fixtures (P1-T2), the helper, its Codex twin, and its two bundle copies (P1-T3), both opt-out suites (P1-T3), the new completion-helper suite (P1-T4), the Codex gate and its bundle copy (P1-T5), and ledger entry 0014 (P1-T2, P1-T3, P1-T6).
- `.claude/hooks/enforce-epic-merge-gate.ps1`, its bundle copy, and both `enforce-epic-merge-gate-review.ps1` copies are absent from the cycle paths.
- git status --porcelain lists only this cycle's uncommitted evidence under `<FEATURE>/evidence/` and the plan file (check-offs), all under `<FEATURE>/`.

Timestamp: 2026-11-24T17-22
Command: git diff --name-only <merge base of origin/main and HEAD> HEAD ; git diff --name-only --diff-filter=A <merge base> HEAD -- '*.py' ; git status --porcelain
EXIT_CODE: 0
Output Summary: 160 branch paths; none under `.claude/lib/docs/`, a docs skill, an agent source (`.claude/agents/`, `.codex/agents/`, `scripts/harness-generation/sources/agents/`), an `atomic-plan-contract` copy, or `.github/workflows/`; no added `.py` file.
