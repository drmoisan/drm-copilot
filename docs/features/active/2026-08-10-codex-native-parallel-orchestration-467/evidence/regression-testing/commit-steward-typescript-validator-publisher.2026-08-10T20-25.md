# P6-T31 Commit-Steward TypeScript Validator and Publisher Parity

Timestamp: `2026-08-10T20-25`

Command: `npx prettier --write <two writable owners>` -> `npx eslint <two writable owners>` -> `npm --prefix extensions/drm-copilot run typecheck` -> `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts test/lib/push-down/codex-pack-selection.test.ts test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-routing-merge.test.ts`

EXIT_CODE: `0`, `0`, `0`, `0`

Output Summary: One clean restarted ordered pass completed with `5` suites and `81` tests passed, `0` failed, in `0.524s`. The first Jest pass had `80` passing tests and one test-only ordering assertion defect: the publisher emitted the correct six paths in deterministic lexical order while the new expected constant placed the base profile first. The expectation was sorted, and the full loop was restarted.

## Validator and Publisher Results

- Strict model routing accepts logical agent `commit-steward`, deployment agent `commit-steward-c4`, model `gpt-5.6-sol`, and reasoning effort `max`.
- Strict topology accepts the same C4 receipt beside matching delegation and ceiling-transition evidence.
- Selected-core publication writes exactly the base plus five generated profiles, with one destination write per profile and no unrelated `.claude/` path.
- The normalized Python constant, TypeScript constant, and real core manifest each contain the same six sorted paths; path parity is `6/6`, and root/resource byte parity is `6/6`.
- Root/resource SHA-256 values in normalized lexical path order are `6DF81A59F85C46ED57F0A57AB87A64C9E2E93DF871760BBF31BFF8881398B5E0`, `40F57A42959CE82262A62FC01EC2EAA16BBC434C7706AD947D82C0F5887D9233`, `1378C01A8AD4DD94BC7A0A1E164E859C793C7227A8886150C6CA8402D4FF2807`, `53EF0B396A7DFA96F631A096FB308F47712148C0BCF32CF6FAD1F84E5DF8FB22`, `DCB21EB9D87A38B02F773BFC48A19854B45C46DA20FEF2162D05EF24CB9E83C4`, and `E209F61D55E3EC283017321E332DA4BA88680A98CA5DD74F24C298B5691ADA3E`.
- Additive routing preserves the destination-owned route and top-level marker while adding `codex_model_policy.generated_agent_families=["commit-steward"]`. Existing equal-skip, deterministic collision reason/order, destination-byte preservation, and unrelated-operation delegation tests remain green.

## Owner and Repository Invariants

- Writable test owner sizes: `451` and `172` lines. Verification-only owners remain `458`, `317`, and `301` lines.
- Temporary-file API/pattern findings: `0`.
- `git diff --check -- <two writable owners>`: exit `0`.
- `.claude/` status entries: `0`.
- `.codex/state` exists: `false`.
- TypeScript production, dependency, and suppression changes in P6-T31: `0`.

Result: `PASS`.
