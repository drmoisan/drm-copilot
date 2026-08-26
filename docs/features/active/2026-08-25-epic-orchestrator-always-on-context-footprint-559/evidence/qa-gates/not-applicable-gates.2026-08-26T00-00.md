# Not-Applicable Quality Gates, With Reasons (Issue #559)

Timestamp: 2026-08-26T00-55
Task: [P6-T7]

This artifact records the quality gates that do **not** apply to this change, each with the reason it
does not apply. Recording the reason matters as much as recording the gate: a gate listed without a
reason is indistinguishable from a gate that was skipped.

The change's actual file inventory, against which every reason below is checked, is the 44-file
committed diff of this branch versus its merge base with `origin/main` (`b36179b2`), enumerated at
`[P6-T6]` and re-asserted at `[P6-T9]`.

## Gates that do not apply

| # | Gate | Reason it does not apply |
|---|---|---|
| 1 | **PoshQC** (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) | Decision 2 of the plan chose pytest as the regression-test home. **No PowerShell file is added or edited by this change** — zero `.ps1`, `.psm1`, or `.psd1` files appear in the branch diff. Choosing Pester would have pulled the PoshQC format, analyze, and test gate into a change that otherwise contains no PowerShell, and would have added `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and the `poshqc` module to the contention surface. |
| 2 | **Extension TypeScript test workflow** (`npx prettier`, `npx eslint`, `npx tsc`, `npx jest`) | **No file under `extensions/drm-copilot/src/` changes.** The eight files this change touches under `extensions/drm-copilot/` are all under `resources/claude-customizations/.claude/`, which is bundled Markdown payload, not compiled TypeScript source. No `.ts` or `.tsx` file is added or edited anywhere in the branch. |
| 3 | **Shell coverage workflow** (bats, kcov) | **No shell or bats file changes.** Zero `.sh` and zero `.bats` files appear in the branch diff. In particular `.claude/lib/bash/parallel-yaml-scan.sh` is cited in the `.claude/rules/parallel-orchestration.md` frontmatter added by `[P2-T5]` but is not written by it; a `paths:` glob naming a file is a scoping declaration, not an edit. |
| 4 | **Architecture-boundary checks** (dependency-cruiser, NetArchTest.Rules) | These are scoped to TypeScript and C# respectively, and **neither language changes.** No `.ts`, `.tsx`, or `.cs` file is added or edited. There is no module-dependency edge for either tool to evaluate. |
| 5 | **Contract / schema compatibility checks** (oasdiff, schema-snapshot diff) | **No contract schema file changes.** Nothing under `schemas/` is written, and no JSON Schema is authored, imported, or read — consistent with the standing prohibition in `.claude/rules/parallel-orchestration.md` and `.claude/rules/orchestrator-state.md` that enforcement is prose plus validator logic, never an imported schema. The four contracts this change does alter (`epic-mode-child-return-contract`, `claude-bundled-payload-byte-identity`, `frozen-epic-surface-digest-pin`, `claude-rules-frontmatter-scoping`) are all enforced by pytest assertions, which run inside `[P6-T4]`, not by a schema-diff tool. |
| 6 | **Integration tests** | **No adapter to an external system changes.** This change writes runtime policy prose, agent and skill definitions, their bundled mirrors, two new pytest modules, and evidence documents. No network client, database adapter, filesystem I/O boundary, or host-service wrapper is added or edited, so there is no external-system interaction for an integration test to exercise. |
| 7 | **Mutation testing** | Per `.claude/rules/general-unit-test.md`, mutation testing runs in pre-merge or nightly pipelines rather than the per-commit loop, and per `.claude/rules/quality-tiers.md` it is required only for T1 modules. No T1 module changes; no `scripts/dev_tools` or `src` file changes at all. |
| 8 | **Branch-coverage threshold** | Not evaluated because the coverage command run at `[P0-T6]` and `[P6-T4]` does not pass `--cov-branch`, on both sides identically. The uniform 85% **line** floor is the gate that applies and it is met at 92.65% (`[P6-T6]`). |

## The Markdown finding — stated explicitly

**No Markdown lint or format gate exists in this repository.** No such gate is claimed, invented, or
run by this change. This is the single most consequential statement in this artifact, because this
change is overwhelmingly a Markdown change, and an unexamined assumption that a Markdown gate exists
would leave the largest part of the diff appearing to be covered by a check that does not exist.

Three candidate mechanisms were examined. Each was ruled out against its own source text.

### 1. `.github/workflows/_docs-validation.yml` — existence checks only

The workflow contains exactly three steps, and none of them lints or formats Markdown:

| Step | What it does | Blocking? |
|---|---|---|
| `Validate README exists and is not empty` | `[ ! -f README.md ] \|\| [ ! -s README.md ]` then `exit 1` | Yes |
| `Check for LICENSE file` | `[ ! -f LICENSE ]` then `exit 1` | Yes |
| `Validate instruction documents exist` | `echo "WARNING: ..."` if `.github/copilot-instructions.md` or `docs/code-change.instructions.md` is missing | **No** — emits a warning and never exits non-zero |

The first two are file-existence and non-emptiness tests on two specific root files. The third is
non-blocking by construction: its only action on a missing file is `echo`, with no `exit 1`, so it
cannot fail the workflow. None of the three inspects Markdown *content*, syntax, style, or
formatting, and none of them looks at any file this change writes.

### 2. `dev.format-markdown` — a chat-transcript formatter, not a policy-file gate

`pyproject.toml` line 75 declares:

```
"dev.format-markdown" = "scripts.dev_tools.markdown_label_formatter:main"
```

The module's own docstring is `"""Format markdown chat transcripts with labeled sections."""`, and
its behaviour keys on two hard-coded transcript labels:

```python
LABEL_PREFIXES: tuple[str, ...] = ("User:", "GitHub Copilot:")
```

It reformats conversation transcripts around `User:` and `GitHub Copilot:` label lines. It is not a
policy-file gate, it is not wired into any workflow as a check, it has no `--check` mode invoked by
CI, and running it against a policy rule file, a skill file, or an evidence artifact would be a
category error rather than a validation.

### 3. The prettier globs in `package.json` — cover no Markdown file

`package.json` lines 31-32 define `format` and `format:check`. Both pass exactly the same operand
list to prettier:

```
"src/**/*.{ts,tsx,js,mjs,cjs,json}"  "tests/**/*.{ts,tsx,js,mjs,cjs,json}"
"eslint.config.mjs"  "jest.config.cjs"  "tsconfig*.json"  "run-*.cjs"
```

The extension set is `ts, tsx, js, mjs, cjs, json`. **`md` does not appear in either brace group, and
no operand has a `.md` extension.** Prettier is capable of formatting Markdown, but it is never
pointed at a Markdown file here. The `--no-error-on-unmatched-pattern` flag further means an operand
matching nothing is silent rather than failing, so no negative signal would surface even if a glob
were wrong.

### Consequence

Markdown correctness in this change is therefore assured by the mechanisms this plan actually built
and ran, not by a repository-wide Markdown gate:

- the 15 new pytest assertions in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` and
  `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`, which parse the YAML
  frontmatter and assert the prose contracts (`[P6-T10]`, `[P6-T11]`);
- the byte-identity mirror contract in
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (`[P3-T18]`);
- the re-baselined SHA-256 digest pin in
  `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`[P3-T13]`, `[P3-T14]`);
- the `git diff HEAD --exit-code` scope guards at `[P4-T5]` and `[P6-T8]`;
- and explicit line-ending verification after each programmatic Markdown edit, since a silent LF-to-CRLF
  rewrite would invalidate the pinned digests and is not revealed by `git diff --stat`.

Output Summary: Eight gates are recorded as not applicable, each with its reason: PoshQC (no
PowerShell file changes), the extension TypeScript workflow (no file under
`extensions/drm-copilot/src/` changes), the shell coverage workflow (no shell or bats file changes),
architecture-boundary checks (TypeScript and C# both unchanged), contract and schema compatibility
checks (no schema file changes), integration tests (no external-system adapter changes), mutation
testing (nightly/pre-merge scope, no T1 module changes), and the branch-coverage threshold (not
requested on either side of the comparison). The Markdown finding is stated explicitly: **no Markdown
lint or format gate exists in this repository** — `_docs-validation.yml` performs only README
non-emptiness and LICENSE existence checks plus one non-blocking warning step, `dev.format-markdown`
resolves to `scripts.dev_tools.markdown_label_formatter` which is a `User:`/`GitHub Copilot:`
chat-transcript formatter, and the `package.json` prettier globs cover only
`ts, tsx, js, mjs, cjs, json` with no `.md` operand. No Markdown gate is claimed, invented, or run.
