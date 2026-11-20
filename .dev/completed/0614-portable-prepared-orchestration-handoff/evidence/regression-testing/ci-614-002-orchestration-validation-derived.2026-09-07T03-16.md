# Orchestration Validation Test Derived Root — [P1-T10]

Timestamp: 2026-09-07T11-40
Task: [P1-T10]

Command: `Select-String -LiteralPath extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts -Pattern 'C:/workspace' -SimpleMatch -CaseSensitive`; `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`
EXIT_CODE: 0 for the `Select-String` invocation; 2 for the `tsc` invocation, unchanged from the [P0-T9] baseline exit code of 2

## Change made

The file already imports `path`, so only a module-level constant was added, placed above `VALID_PLAN`:

```
const VIRTUAL_WORKSPACE_ROOT = path
  .resolve("virtual-workspace")
  .replaceAll("\\", "/");
```

with a JSDoc block stating why the derivation replaces a drive-letter literal.

All twelve literals recorded by [P0-T8] were replaced. Nine bare literals took `VIRTUAL_WORKSPACE_ROOT` directly: the `const workspaceRoot` at pre-change line 71, `expectedWorkspaceRoot` at 91, the `rev-parse --show-toplevel` observation at 110, and the request roots at 213, 241, 265, 288, 312, and 389. The three `VirtualFileSystem` keys at pre-change lines 203, 229, and 254 became computed keys holding a template literal prefixed by `${VIRTUAL_WORKSPACE_ROOT}/`, written in the collapsed single-line bracketed form Prettier produces at print width 80:

```
      [`${VIRTUAL_WORKSPACE_ROOT}/docs/plan.md`]: VALID_PLAN,
      [`${VIRTUAL_WORKSPACE_ROOT}/docs/state.json`]: "[]",
      [`${VIRTUAL_WORKSPACE_ROOT}/docs/policy-audit.md`]: "incomplete document",
```

Measured widths are 61, 58, and 80 characters. The `docs/policy-audit.md` key is the longest of the three and measures exactly 80 characters, as the plan states, so it sits at the print width and does not wrap. `npx prettier --check` confirms the file conforms with no rewrite pending.

## Why the computed keys still match what production derives

Both production key-derivation sites were re-read from the current tree.

`validate-orchestration-service-call.ts` lines 80 through 82:

```
  const artifactFullPath = toPosixPath(
    path.join(input.workspaceRoot, input.artifactPath),
  );
```

`orchestration-handoff-authority-service.ts` lines 78 through 84:

```
    const candidate = toPosixPath(
      path.resolve(canonicalWorkspaceRoot, repositoryPath),
    );
```

Both produce the derived root followed by a forward slash and the repository-relative suffix on either platform, which is exactly the shape the computed keys register.

## Results

- `C:/workspace` case-sensitive match count: 0 (required: 0)
- File line count: 454 (pre-change 442; within the 500-line limit)
- Prettier: "All matched files use Prettier code style!"

## Type check against the [P0-T9] baseline

- Total `error TS` lines: 331, identical to the baseline count.
- Normalized diagnostics absent from the baseline set: 0. No regression introduced.
- Per-changed-path counts unchanged, including this file at 9 both before and after. Those nine pre-existing diagnostics are one `TS2420` on the `VirtualFileSystem` class declaration, six `TS2739` on its use sites, and two `TS4111` index-signature property accesses. None concerns a workspace-root value; all are structural typing gaps against a wider `FileSystem` interface, which a test-only literal substitution cannot clear.

Clause 1 of this task's type acceptance is unsatisfiable at baseline as recorded in `../remediation-baseline/typescript-test-tree-typecheck.2026-09-07T03-16.md` and is not claimed as satisfied. This file carries the largest share of that pre-existing set.

Output Summary: All twelve recorded literals were replaced, nine with the derived constant and three as computed template-literal keys, bringing the case-sensitive `C:/workspace` count in this file to 0. The file grew from 442 to 454 lines. The type-check emits 331 `error TS` lines, normalized-identical to the [P0-T9] baseline with 0 new diagnostics and no per-file count change, so clause 2 passes.
