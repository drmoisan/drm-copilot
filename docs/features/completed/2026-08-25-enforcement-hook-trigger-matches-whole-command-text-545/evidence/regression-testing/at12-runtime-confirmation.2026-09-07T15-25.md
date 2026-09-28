# AT-12 — executed confirmation of the equals-joined disposition bypass (issue #545)

Timestamp: 2026-09-07T15-25

Task: [P10-T12]

Spec D11.6 forbids checking off the AT-12 acceptance criterion until an executed run exists. This
artifact records that run. It is deliberately **not** a derivation from `argparse` semantics: the
returned value below was produced by executing the hook's own function against the unfixed hook.

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context, so the run was executed through `mcp__drm-copilot__run_poshqc_test` and its per-case results
were read from `artifacts/pester/pester-junit.xml`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`, driving a throwaway suite
`tests/scripts/claude-hooks/at12-prechange-observation.Tests.ps1` that dot-sourced the UNFIXED
`.claude/hooks/enforce-parallel-abandon-gate.ps1` and called
`Test-ParallelAbandonCommandInScope`. The suite was created and deleted within this agent session and
is not part of the delivered suite set; its assertions stated the pre-change values, so a PASS is the
positive observation of the bypass.

EXIT_CODE: 1 (folder-wide failed-test count: the 1 documented pre-existing
`enforce-pr-author-skill.Tests.ps1` failure. The throwaway suite itself reported **2 tests, 0
failures, 0 errors**.)

## The executed run and its returned value

Command text supplied, verbatim:

```
poetry run python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition=abandon --confirm-abandon
```

That text was passed through `Get-ParallelAbandonNormalizedCommand` and then to
`Test-ParallelAbandonCommandInScope`.

| Spelling | Function called | **Returned value** | Consequence |
| --- | --- | --- | --- |
| `--disposition=abandon` (equals-joined) | `Test-ParallelAbandonCommandInScope` | **`$false`** | **out of scope — the gate does not fire, so the abandon proceeds ungated** |
| `--disposition abandon` (space-separated) | `Test-ParallelAbandonCommandInScope` | **`$true`** | in scope — the gate fires as intended |

Both assertions passed, so both returned values are observed rather than inferred.

Mechanism: the scope test is
`$NormalizedCommand.Contains($script:AbandonDispositionToken, [System.StringComparison]::OrdinalIgnoreCase)`
where `$script:AbandonDispositionToken` is the literal `'--disposition abandon'`, a two-word string
joined by a space. The equals-joined spelling contains no such substring, and whitespace
normalization does not introduce one, so the containment test is false and the gate never engages.

## The producer-side registration that makes the equals-joined spelling acceptable

`scripts/dev_tools/parallel_mutation_abandon_cli.py`, the `add_argument` call beginning at line 236:

```python
    parser.add_argument(
        DISPOSITION_OPTION,
        choices=VALID_DISPOSITIONS,
        required=True,
        help=(
            f"The removal disposition. This CLI executes "
            f"{ABANDON_DISPOSITION_TOKEN!r} only."
        ),
    )
```

with, from the same module:

```python
OPTION_PREFIX = "--"
DISPOSITION_OPTION = f"{OPTION_PREFIX}disposition"
ABANDON_DISPOSITION = "abandon"
ABANDON_DISPOSITION_TOKEN = f"{DISPOSITION_OPTION} {ABANDON_DISPOSITION}"
```

`DISPOSITION_OPTION` resolves to `--disposition`, registered as a long option carrying a value.
`argparse` accepts a long option's value in either the space-separated or the equals-joined form, so
`--disposition=abandon` and `--disposition abandon` are the same invocation to the producer. The
exported `ABANDON_DISPOSITION_TOKEN` composes only the space-separated spelling, and the hook matches
that composed string as a literal substring, so the two spellings diverge at the consumer even though
the producer treats them identically.

The registration is recorded here as the reason the bypass is reachable in practice. It is
**supporting context only**; the finding above rests on the executed run, not on this reading.

## Consequence and what closes it

An operator or agent writing the equals-joined spelling — which the producer accepts — bypasses the
gate entirely. [P10-T15] closes this by accepting both spellings structurally through the segment's
`Tokens`, while leaving the two token literals at lines 41 and 42 byte-unchanged, because
`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` parses the hook at run time and fails on
a change of shape.

Output Summary: executed confirmation recorded. Driving `Test-ParallelAbandonCommandInScope` against
the **unfixed** hook with `--disposition=abandon` returned **`$false`** — the command is out of scope
and the abandon proceeds ungated — while the space-separated `--disposition abandon` returned
**`$true`**. Both values come from a Pester run that reported **2 tests, 0 failures**, not from a
derivation. The `argparse` registration at
`scripts/dev_tools/parallel_mutation_abandon_cli.py` line 236 registers `--disposition` as a
value-carrying long option, which is why the producer accepts the equals-joined spelling the consumer
misses. The D11.6 precondition for checking off the AT-12 acceptance criterion is now satisfied.
