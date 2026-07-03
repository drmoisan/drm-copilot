<!-- markdownlint-disable-file -->

# Task Research Notes: Expose PR Context Script via Extension-side Execution

## Research Executed

### File Analysis

- `extensions/scaffold-extension/src/extension.ts`
  - Existing extension boundary pattern already executes bundled scripts from extension resources with destination workspace `cwd` and `shell: false`.
- `extensions/scaffold-extension/package.json`
  - Command contribution model is already in place; a new PR-context command can be added consistently.
- `extensions/scaffold-extension/test/extension.test.ts`
  - Strong unit coverage exists for command registration, runtime detection, spawn args, cwd, and deterministic error logging.
- `extensions/scaffold-extension/test/extension.integration.test.ts`
  - Integration seam exists for validating end-to-end command invocation and artifact behavior.
- `scripts/dev_tools/pr_context/collector.py`
  - Collector supports explicit `--base`, `--out`, `--appendix-out`, and `--repo-root`, enabling extension orchestration without copying scripts to workspace root.
- `scripts/dev_tools/pr_context/render.py`
  - Includes rendering and base/branch helper interplay used by collector outputs.
- `scripts/dev_tools/pr_context/render_pr_helpers.py`
  - Contains default base selection helper; useful baseline to compare with deterministic extension-side branch-selection UX.
- `scripts/dev_tools/pr_context/git.py`
  - Encapsulates git process interactions and error propagation style.
- `tests/scripts/dev_tools/test_collect_pr_context.py`
  - Existing deterministic collector tests validate argument handling and write behavior.
- `tests/scripts/dev_tools/test_collect_pr_context_part2.py`
  - Additional collector coverage for edge paths and fallback behavior.
- `tests/scripts/dev_tools/test_render.py`
  - Rendering/base-selection related expectations already codified.
- `docs/features/active/2026-03-04-expose-pr-context-script-77/issue.md`
  - Primary requirements source: extension-side execution, branch selection flow, boundary constraints, deterministic errors, and test strategy.
- `docs/features/active/2026-03-04-expose-pr-context-script-77/spec.md`
  - Confirms intended UX and output contracts.
- `docs/features/active/2026-03-04-expose-pr-context-script-77/plan.2026-03-04T23-07.md`
  - Maps candidate implementation/test milestones for issue #77.

### Code Search Results

- `collectCommitContext`
  - Found extension command and tests that provide the exact execution template to extend for PR context.
- `executeBundledScript`
  - Found centralized command runner with runtime probing and output-channel logging; ideal reuse point.
- `pr_context`
  - Found collector implementation and corresponding test suites under `scripts/dev_tools/pr_context` and `tests/scripts/dev_tools`.
- `select_default_base`
  - Found current Python-side default-base helper; indicates where extension-selected base should be passed explicitly to avoid ambiguity.
- `artifacts/pr_context.summary.txt|artifacts/pr_context.appendix.txt`
  - Found canonical output contract paths used by collector defaults and expected by workflows.

### External Research

- #githubRepo:"microsoft/vscode window.showQuickPick canPickMany return type"
  - Verified `window.showQuickPick` overloads in `vscode.d.ts`: single-pick resolves to `T | undefined`; `canPickMany: true` resolves to `T[] | undefined`; dismissal/cancel resolves `undefined`.
- #fetch:https://code.visualstudio.com/api/references/vscode-api
  - Confirmed command contribution/registration model (`commands` manifest + `registerCommand`) and quick input behavior including hide/dismiss semantics.
- #fetch:https://github.com/microsoft/vscode/blob/main/src/vscode-dts/vscode.d.ts
  - Confirmed exact `showQuickPick` signatures and explicit docs that dismissal returns `undefined`.
- #fetch:https://git-scm.com/docs/git-merge-base
  - Confirmed merge-base semantics and ancestor checks for deterministic base branch reasoning.
- #fetch:https://git-scm.com/docs/git-for-each-ref
  - Confirmed deterministic remote-tracking branch enumeration/sorting capabilities for candidate branch lists.
- #fetch:https://git-scm.com/docs/git-symbolic-ref
  - Confirmed symbolic ref behavior (including `--short`) for deriving default branch from `refs/remotes/origin/HEAD` when available.

### Project Conventions

- Standards referenced: extension command registration via manifest + activation; bundled-resource execution; deterministic output artifacts under `artifacts/`; strict deterministic error messaging and test-first verification in existing extension tests.
- Instructions followed: `.github/prompts/research-issue.prompt.md`, policy/skill guidance for PR-context artifacts, merge-base branch selection, and evidence/timestamp conventions.

## Key Discoveries

### Project Structure

The extension already implements destination-side execution boundaries correctly: scripts are executed from extension resources and run against the destination workspace `cwd` without script materialization into workspace root. The existing `collectCommitContext` command is a near-direct blueprint for a new PR-context command. The PR-context Python collector already supports all key arguments needed by extension orchestration (`--base`, output paths, repo root), so implementation scope is mostly extension command/UX wiring plus tests.

### Implementation Patterns

- Reuse `executeBundledScript(...)` as the single subprocess orchestration path.
- Keep explicit argv arrays and `shell: false` to maintain deterministic process behavior.
- Add a command-level branch selection pre-step using `showQuickPick`.
- Pass selected branch to collector via `--base` rather than relying on collector defaults when user explicitly chooses.
- Preserve output contracts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`

### Complete Examples

```typescript
// Source: extensions/scaffold-extension/src/extension.ts (existing pattern)
const collectCommitContextDisposable = vscode.commands.registerCommand(
  "scaffoldExtension.collectCommitContext",
  async () => {
    await executeBundledScript(context, output, {
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/collect_commit_context.py",
      commandId: "scaffoldExtension.collectCommitContext",
      args: ["--output", "artifacts/commit_context.txt"],
    });
  },
);
```

### API and Schema Documentation

- `window.showQuickPick(...)` signatures (from `vscode.d.ts`):
  - Single pick: `Thenable<T | undefined>`
  - Multi-pick (`canPickMany: true`): `Thenable<T[] | undefined>`
  - Dismiss/cancel returns `undefined`
- `collector.py` CLI options (current implementation):
  - `--base`
  - `--head`
  - `--out`
  - `--appendix-out`
  - `--repo-root`
  - `--append`
  - `--no-untracked`

### Configuration Examples

```json
{
  "contributes": {
    "commands": [
      {
        "command": "scaffoldExtension.collectPrContext",
        "title": "Scaffold Utils: Collect PR Context"
      }
    ]
  }
}
```

### Technical Requirements

- Must execute bundled PR-context collector from extension resources.
- Must run in destination workspace `cwd`.
- Must not copy/materialize script files into destination workspace root.
- Must provide deterministic branch-selection UX and cancellation path.
- Must produce deterministic, actionable error messages for:
  - no workspace
  - runtime not found
  - branch selection canceled
  - git reference discovery failure
  - collector non-zero exit
- Must include unit + integration tests covering command registration, arg wiring, cwd/boundary constraints, cancel path, and subprocess failures.

**Mandatory unachievable objective callout**:
- **None identified. All stated objectives are achievable within current extension architecture and collector CLI surface.**

## Recommended Approach

Implement a new extension command `scaffoldExtension.collectPrContext` that performs a two-step flow before invoking the bundled collector:

1. Discover candidate base branches deterministically (prefer remote-tracking refs).
2. Present a Quick Pick for base-branch selection (with explicit cancel handling).
3. Invoke bundled collector with explicit args:
   - `--base <selected-branch>`
   - `--out artifacts/pr_context.summary.txt`
   - `--appendix-out artifacts/pr_context.appendix.txt`

Deterministic branch-candidate priority:
- First candidate from `refs/remotes/origin/HEAD` symbolic target when available.
- Then filtered remote branches from `origin/*` (`main`, `master`, `develop`, `trunk`, release-like refs), sorted stably.
- Optional local fallback only if no remote candidates exist.

Deterministic cancellation behavior:
- If quick pick resolves `undefined`, do not invoke subprocess.
- Emit single explicit output message, e.g., `"PR context collection canceled (no base branch selected)."`

Rejected alternatives (brief):
- Auto-run with no prompt using collector default base only: rejected because issue #77 requires a branch-selection UX.
- Copying collector into destination workspace before execution: rejected because it violates extension boundary constraints.
- Multi-select base branches (`canPickMany`) then selecting one later: rejected as unnecessary complexity for single-compare use case.

## Implementation Guidance

- **Objectives**: Expose PR-context collection from extension side while preserving runtime/boundary guarantees and adding deterministic base-branch selection UX.
- **Key Tasks**:
  - Add command contribution in `extensions/scaffold-extension/package.json`.
  - Extend `extensions/scaffold-extension/src/extension.ts` with:
    - branch discovery helper
    - quick-pick selection helper
    - `collectPrContext` command registration
    - explicit collector args wiring.
  - Add/update bundled resource script in extension resources (mirroring existing commit-context resource strategy).
  - Extend unit tests in `extensions/scaffold-extension/test/extension.test.ts` for registration, cancel path, branch args, and failures.
  - Extend integration tests in `extensions/scaffold-extension/test/extension.integration.test.ts` for end-to-end artifact/cwd/no-copy behavior.
- **Dependencies**: VS Code command/quick-input API; existing extension subprocess helper; existing Python collector CLI; git branch-ref discovery (symbolic-ref/for-each-ref).
- **Success Criteria**:
  - New command appears in palette and activates correctly.
  - Branch picker appears and canceling does not spawn subprocess.
  - Selected base is passed via `--base` deterministically.
  - Summary/appendix artifacts are produced at canonical paths.
  - No script materialization into destination workspace root.
  - Added unit/integration tests pass and validate deterministic error paths.