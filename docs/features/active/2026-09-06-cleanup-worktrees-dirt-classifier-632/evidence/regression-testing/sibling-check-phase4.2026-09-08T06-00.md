# Sibling check — Phase 4 (R5, the anchored diff header skip)

Timestamp: 2026-09-08T06-40

Task: [P4-T7] of `remediation-plan.2026-09-08T05-00.md`

Command: the [P4-T6] run —

```
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats
```

EXIT_CODE: 0

Full result recorded at
`evidence/regression-testing/pass-after-diff-header-anchor.2026-09-08T06-00.md`: plan line
`1..47`, 47 `ok`, 0 `not ok`.

## Sibling region checked

The edited line is the only filter standing between a diff line and the `HintPath`
confinement test, so both pre-existing pins that read that branch were re-checked. Both
names are reproduced verbatim:

- `dirt_build_artifact: a HintPath-only csproj modification is DISPOSABLE_BUILD_ARTIFACT`
  (`tests/shell/test_cleanup_worktrees_dirt_classify.bats:60`). Its fixture carries real
  `--- a/src/Legacy/Legacy.csproj` and `+++ b/src/Legacy/Legacy.csproj` headers that must
  still be skipped. An anchoring that missed the `a/` or `b/` prefix would count them as
  changed lines, fail the confinement test, and flip this verdict to `UNIQUE`.
- `dirt_build_artifact_mixed: a csproj diff carrying a non-HintPath line is UNIQUE`
  (`:83`). This is the near-miss half of the build-artifact pin and reads the same branch
  from the other direction: its `+    <Compile Include="Services\NewInvoiceService.cs" />`
  line must continue to be counted.

## Observed `ok` lines for both

```
ok 1 dirt_build_artifact: a HintPath-only csproj modification is DISPOSABLE_BUILD_ARTIFACT
ok 3 dirt_build_artifact_mixed: a csproj diff carrying a non-HintPath line is UNIQUE
```

Output Summary: Both pre-existing header-skip pins pass unchanged after the anchoring. The
anchoring narrowed what the filter drops without changing any verdict that depended on the
filter dropping a genuine header.
