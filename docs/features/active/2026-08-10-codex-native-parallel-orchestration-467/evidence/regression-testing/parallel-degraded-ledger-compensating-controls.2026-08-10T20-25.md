# Parallel DEGRADED Ledger Compensating Controls

Timestamp: `2026-08-11T12-00-04:00`

Task: `[P4-T10]`

## Scope

This receipt records the mechanical compensating-control tests for the two
DEGRADED translation-ledger rows. The work was test-only. No production hook,
Codex config, workflow, or `.claude/` file was changed.

## G02 controls

- Forced profile: `parallel-provenance.Tests.ps1` verifies the exact
  `parallel-planner` and `parallel-orchestrator` personas, `gpt-5.6-sol`,
  `ultra`, no alternate persona, dedicated permission profiles, and
  byte-identical root/bundle agent definitions.
- Permission and sandbox denial: the same suite verifies read-first planner and
  orchestrator profiles, exact write allowlists, `.claude/** = deny`, no broad
  implementation write, and protected child customization paths as read-only.
- PreToolUse denial: `codex-parallel-registered-transport.Tests.ps1` binds all
  six configured parallel PreToolUse gates to stable deny reasons and retains
  the complete 42-cell direct registered-process matrix.
- Sealed external launch: `parallel-child-worktree-launcher.Tests.ps1` verifies
  exact bound worktree, isolated `CODEX_HOME`, approval `never`,
  `parallel-child-workspace`, and refusal when resumed runtime permissions do
  not match the sealed launch receipt.

G02 result: `DEGRADED`, not `LOST`.

## G16 controls

`parallel-completion-compensating-controls.Tests.ps1` composes the existing
parallel output and root-completion public seams with injected in-memory
records. It verifies:

- one invalid stop receives exactly one continuation;
- repeated-stop reuse returns `continue=false`;
- invalid full checkpoint state is refused by the root completion gate;
- an immutable completion-receipt head mismatch is refused with the shared
  validator diagnostic;
- a required `parallel-completion-gate` produces a nonzero exit for invalid
  final state;
- missing, optional, or non-failing CI paths map G16 to `LOST` and block the
  plan; and
- the complete control set retains G16 as `DEGRADED`.

The test-local CI contract is intentionally registration-neutral. P5-T11 owns
the later minimal workflow registration after P5-T10 discovery evidence.

G16 result: `DEGRADED`, not `LOST`.

## Commands and results

Command: `mcp__drm-copilot__run_poshqc_format` with the four P4-T10 test paths.

EXIT_CODE: `0`

Command: `mcp__drm-copilot__run_poshqc_analyze` with the four P4-T10 test paths.

EXIT_CODE: `0`

Command: `mcp__drm-copilot__run_poshqc_test` with the four P4-T10 test paths.

EXIT_CODE: `0`

Output Summary: `37 passed, 0 failed, 0 errors`:

- `parallel-provenance.Tests.ps1`: `17/17`
- `parallel-child-worktree-launcher.Tests.ps1`: `8/8`
- `codex-parallel-registered-transport.Tests.ps1`: `5/5`
- `parallel-completion-compensating-controls.Tests.ps1`: `7/7`

The focused G16 run also passed `7/7` after the toolchain was restarted from
format following correction of one test-fixture parameter binding.

## Size and immutability checks

| Test file | Physical lines | SHA-256 |
|---|---:|---|
| `parallel-provenance.Tests.ps1` | 175 | `8FCB82453F40AD7A4375C3C2B35B3A973E9DFAD573B4E49490C240E7D7746443` |
| `parallel-child-worktree-launcher.Tests.ps1` | 317 | `0B71A942DA43F06E01B766BDFEF9ED7E1F2FE4DCABC06CF5DE858CA95D12FCB8` |
| `codex-parallel-registered-transport.Tests.ps1` | 471 | `439C161BC4257DBA8CFA00BF9972AE987DAAEAC628F51A54569F16A8107CBFC9` |
| `parallel-completion-compensating-controls.Tests.ps1` | 246 | `674504EEE55C5BA9C5B8828A4DC0AA5D598F37764A0C77B9574E4CCA8F485F6B` |

- All four reusable test files are within the 500-line policy limit.
- Fresh `.claude/` manifest: `150` files; P0-T7 comparison delta: `0`;
  `git diff --name-only -- .claude` count: `0`.
- `git diff --check` over the four test owners exited `0`.
- The sole PowerShell batch receipt named only the completed P4-T10 test
  batch, was deleted after verification, and `.codex/state` is absent.

Ledger totals remain `16 PRESERVED, 2 DEGRADED, 0 LOST`.
