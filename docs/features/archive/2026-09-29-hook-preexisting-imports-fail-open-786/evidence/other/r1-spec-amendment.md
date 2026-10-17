# Remediation Cycle 1 Spec Amendment Verification ([P1-T3])

Timestamp: 2026-10-10T09-01
Command: <SCRATCHPAD>/r1-p1t3.ps1 (route sh, fresh process): the [P0-T2] AC Lines derivation (<SCRATCHPAD>/r1-aclines.ps1); counts of `^- \[x\] AC-\d+:` and `^- \[ \] AC-\d+:`; the [P1-T1] and [P1-T2] acceptance checks; git diff --numstat df0965aeaa8a3905fe4966fcbb4b49143d566941 -- docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md; git status --porcelain -- docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
EXIT_CODE: 0
Output Summary: [P1-T1] check pass and [P1-T2] check pass. AC-11, AC-12, and AC-17 SHA-256 values equal the [P0-T2] values. Checked 25 + unchecked 2 = 27. Numstat for spec.md: 5 added, 1 removed (difference 4, removed 1). Porcelain lists spec.md as modified.

SHA comparison against [P0-T2]:
- AC-11: 6cb5ec2448e66f283605bc034ae7c476a02c6ba8bf2d62556186da2c3ca76eb8 | equal
- AC-12: 65dcd2292361ba247115265e0661384d1e509b89ac537e3cfd55dbdf28ea177e | equal
- AC-17: b1edbd7e5ea3b1da150b90b0052d4bb15190b347d6290c828896b3291ac77690 | equal

```text
AC-LINE: AC-6 | line=233 | state=[ ] | sha256=6c1cc82fd71588adec1d079708243a45b6d81625400e4227c9e75a2dc0f6ae33
AC-LINE: AC-11 | line=238 | state=[x] | sha256=6cb5ec2448e66f283605bc034ae7c476a02c6ba8bf2d62556186da2c3ca76eb8
AC-LINE: AC-12 | line=239 | state=[x] | sha256=65dcd2292361ba247115265e0661384d1e509b89ac537e3cfd55dbdf28ea177e
AC-LINE: AC-17 | line=244 | state=[x] | sha256=b1edbd7e5ea3b1da150b90b0052d4bb15190b347d6290c828896b3291ac77690
AC-LINE: AC-24 | line=251 | state=[ ] | sha256=4f0e53d36ec728f7f2fbcaf6b319096ecb70be79e9b025e1161aae15de51aa66
AC-6-TEXT: - [ ] AC-6: For every registered Claude PreToolUse hook with dependencies, a test per direct edge simulates that edge's failure with the C3 mocks and asserts a deny decision whose reason begins with the hook's existing leading token (or existing prose prefix) and names the failed dependency; the entry point returns exit code 0 with the deny JSON and calls no HookPayload function. Exception (Change Log 2026-10-10): the named-exemption edges of H1, H4, H5, and H6, which are the `feature-folder-resolution.ps1` edge of `enforce-feature-folder-order.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-parallel-drift-gate.ps1`, and `enforce-parallel-cohort-barrier.ps1`, are excepted from this criterion; for those edges the deny is the fail-closed handler recorded in `evidence/other/exemption-decisions.md` and proven by `fail-closed-proof.H1.md`, `fail-closed-proof.H4.md`, `fail-closed-proof.H5.md`, and `fail-closed-proof.H6.md`. Every other edge meets this criterion as written.
CHECKED: 25
UNCHECKED: 2
P1T1-AC6-UNCHECKED-MATCHES: 1
P1T1-PREFIX-MATCH: True
P1T1-LITERAL: Change Log 2026-10-10 | True
P1T1-LITERAL: H1, H4, H5, and H6 | True
P1T1-LITERAL: exemption-decisions.md | True
P1T1-LITERAL: fail-closed-proof.H1.md | True
P1T1-LITERAL: fail-closed-proof.H4.md | True
P1T1-LITERAL: fail-closed-proof.H5.md | True
P1T1-LITERAL: fail-closed-proof.H6.md | True
P1T1-CHECK: pass
P1T2-NEW-ENTRY-LINES: 281
P1T2-OLD-ENTRY-LINES: 274
P1T2-LAST-H2: ## Change Log
P1T2-CHECK: pass
NUMSTAT:
5	1	docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
PORCELAIN:
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
```
