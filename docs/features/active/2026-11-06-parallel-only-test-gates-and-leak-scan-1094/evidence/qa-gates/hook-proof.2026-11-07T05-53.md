# Hook Proof (Remediation Cycle 3)

Timestamp: 2026-11-07T05-53
Command: pwsh -NoProfile -File <hook> from the item worktree, with the SubagentStop payload on standard input, for each hook and each of cases A, B, and C
EXIT_CODE: 0
Output Summary: 6 hook runs, 0 cells differ from the expected table. The table below records each run. git status --porcelain listed 0 paths after the step.

Audit-Source: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/hook-proof-audit.2026-11-07T05-51.md

| Case | Hook | Exit | Stdout | Stderr | Decision | Narrows scope | Match |
|---|---|---|---|---|---|---|---|
| A | .claude/hooks/validate-feature-review-coverage.ps1 | 0 | stdoutEmpty=True | stderrEmpty=True | decision= | narrowsScope=False | match=True |
| A | .codex/hooks/validate-feature-review-coverage.ps1 | 0 | stdoutEmpty=True | stderrEmpty=True | decision= | narrowsScope=False | match=True |
| B | .claude/hooks/validate-feature-review-coverage.ps1 | 0 | stdoutEmpty=True | stderrEmpty=True | decision= | narrowsScope=False | match=True |
| B | .codex/hooks/validate-feature-review-coverage.ps1 | 0 | stdoutEmpty=True | stderrEmpty=True | decision= | narrowsScope=False | match=True |
| C | .claude/hooks/validate-feature-review-coverage.ps1 | 2 | stdoutEmpty=True | stderrEmpty=False | decision= | narrowsScope=True | match=True |
| C | .codex/hooks/validate-feature-review-coverage.ps1 | 0 | stdoutEmpty=False | stderrEmpty=True | decision=block | narrowsScope=True | match=True |

Summary lines:

- .claude/hooks/validate-feature-review-coverage-rules.ps1 (+1/-0)
- scripts/dev_tools/validate_policy_audit_artifact.py (+1/-0)
- extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts (+1/-0)

Hook-SHA256: .claude/hooks/validate-feature-review-coverage.ps1 425604E23E809BE68AE877C19D3DAFDC011CCA59440472A97D5C939159B91A47

Hook-SHA256: .claude/hooks/validate-feature-review-coverage-rules.ps1 128458E5612842064146A279F10C3EDFBAAF52605154EAEFDAE2EAA72F80535F

Hook-SHA256: .codex/hooks/validate-feature-review-coverage.ps1 7179968160C8BD7EF7998E79F86AC181ED32A98C4F4A155EB6EA3D41AA9D3722

Case-A-Audit-SHA256: B697537FDEC61CDA0039C48C586F992228FE260FD269A6C5C5A0C09C5CE45CF8 newest=True

Case-B-Audit-SHA256: 15C01DBA101FA77735047063500F907E81885638C0E52BD1BD6C31FE4687D89F newest=True

Case-C-Audit-SHA256: F851F530BCE52C392FAD0E6644019190588B1E1148C8FB50B323FEFC016961E0 newest=True

Payload-A: {"session_id":"issue-1094-hook-proof","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":"policy-audit-path: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/hook-proof/policy-audit.2026-11-07T00-00.md\ncode-review-path: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/hook-proof/code-review.2026-11-07T00-00.md\nfeature-audit-path: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/hook-proof/feature-audit.2026-11-07T00-00.md"}

Payload-B: {"session_id":"issue-1094-hook-proof","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":"policy-audit-path: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/hook-proof/policy-audit.2026-11-07T04-20.md\ncode-review-path: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/hook-proof/code-review.2026-11-07T04-20.md\nfeature-audit-path: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/hook-proof/feature-audit.2026-11-07T04-20.md"}

Payload-C: {"session_id":"issue-1094-hook-proof","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":"policy-audit-path: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/hook-proof/policy-audit.2026-11-07T00-00.md\ncode-review-path: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/hook-proof/code-review.2026-11-07T00-00.md\nfeature-audit-path: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/hook-proof/feature-audit.2026-11-07T00-00.md"}
