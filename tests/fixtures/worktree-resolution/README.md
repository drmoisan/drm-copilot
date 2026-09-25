# Worktree-resolution fixture roots (issue #673)

## Purpose

These roots supply the committed state the pr-author and model-routing matrix suites
read. They exist because a committed fixture cannot be a real worktree — git does not
track a `.git` component — so the suites inject worktree *topology* through mocks while
reading checkpoint and artifact *content* from these real files.

Two properties make that split work:

- `.gitignore` ignores `/artifacts` with a root anchor, so the repository-root
  `artifacts/` tree is untracked and absent on a clean checkout, while
  `tests/fixtures/worktree-resolution/<root>/artifacts/...` is tracked normally.
- The pr-author gate reads three paths relative to the process directory:
  `artifacts/pr_body_<N>.receipt.json` (check 2), `artifacts/pr_body_<N>.md` (check 4),
  and the last-write time of `artifacts/pr_context.summary.txt` (check 5). A matrix row
  that left the working directory to the executing process would therefore pass in a
  development worktree that happens to hold `/artifacts` and fail on a clean checkout,
  before reaching the behaviour it asserts. Every row runs inside one of these roots
  with an explicit working directory instead.

Because these roots carry committed bytes, no row mocks `Get-PrContextArtifactExistence`,
`Get-PrAuthorReceiptContent`, `Get-PrBodyFileBytes`, or `Get-PrContextSummaryLastWriteUtc`.
A fixture root was chosen over a permitted mock so that each row enters through the same
entrypoint production uses and exercises the Case C branch rather than bypassing it.

## Root map

| Root | Checkpoint `issue-num` | Content |
| --- | --- | --- |
| `pr-author/session-root` | `838` | base checkpoint; `artifacts/pr_context.summary.txt`; `artifacts/pr_body_1.md`; `artifacts/pr_body_1.receipt.json` |
| `pr-author/item-own-ready` | `901` | base checkpoint with `objective` `Own item B fixture.`; the same three artifact files |
| `pr-author/item-own-not-ready` | `901` | base checkpoint with `step5_status` `pending` |
| `pr-author/item-own-epic-mode` | `901` | base checkpoint plus `"epic_mode": true` and `"epic_context": {"integration_branch": "epic/f5-fixture-integration"}` |
| `model-routing/session-root` | `838` | a minimal checkpoint recording an `atomic-planner` routing receipt |
| `model-routing/item-own-receipt` | `901` | a minimal checkpoint recording an `atomic-planner` routing receipt |
| `model-routing/item-own-no-receipt` | `901` | a minimal checkpoint recording a `feature-review` receipt only |
| `model-routing/item-stale-receipt` | `901` | a minimal checkpoint recording an `atomic-planner` routing receipt |
| `shared/item-own-invalid-json` | unknown | a checkpoint holding text that is not valid JSON |
| `shared/item-own-empty` | unknown | a checkpoint of zero bytes |
| `shared/item-no-checkpoint` | none | `artifacts/pr_context.summary.txt` only |

`pr-author/item-own-epic-mode` deliberately carries no artifact files. A matrix row
resolves its target there while *running* in `pr-author/session-root`, which is what lets
that row read the committed receipt, body, and context-summary bytes from the working
directory and take the epic base-branch verdict from the resolved checkpoint. That row is
the direct pass-after evidence for the epic base-branch binding.

Fixture branch names appear only inside mocks and never in a checkpoint:
`f5-fixture-own`, `f5-fixture-sibling`, `f5-fixture-missing`. Issue `902` is recorded by
no root, so a call naming it resolves to no live worktree.

## Schema dependency

The four `pr-author/` checkpoints must keep satisfying `Invoke-OrchestratorStatePreflight`
in the states their rows require. That function reads the key set named by
`REQUIRED_STATE_KEYS` in `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1`.
A change to either the key set or the preflight's step-status rules can invalidate these
checkpoints without touching this directory, and the symptom is a matrix row failing on a
preflight reason rather than on the behaviour it asserts.

The base checkpoint's `completed_steps` order is also load-bearing beyond the preflight:
`.claude/hooks/enforce-checkpoint-monotonic.ps1` matches a checkpoint path by suffix, so
it evaluates a write to any file here. It denies only on an out-of-order `completed_steps`
pair or a missing prerequisite for an advanced step, and the order copied into these
fixtures satisfies both. Reordering `completed_steps` here would arm that gate.

## Determinism

Every file is committed with LF endings, so the SHA-256 recorded in each
`pr_body_1.receipt.json` holds on every platform. Each receipt's `created_at` is
`2099-01-01T00:00:00Z`, strictly newer than any checkout time, so a freshness comparison
against the body file cannot depend on when the repository was cloned. No suite creates,
writes, or deletes a file under this directory.
