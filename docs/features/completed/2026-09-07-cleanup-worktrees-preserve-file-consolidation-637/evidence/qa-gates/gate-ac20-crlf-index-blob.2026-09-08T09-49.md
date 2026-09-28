# Gate — the CRLF fixture survives git's end-of-line conversion

Timestamp: 2026-09-08T09-49
Task: [P1-T5]
Command: git hash-object tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md
EXIT_CODE: 0
ExpectedExitCode: 0

RouteSubstitution:
- Plan spans (not run): `git add -- tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`,
  then `git rev-parse :tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`, then
  `git hash-object --no-filters tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`.
- Substitute actually run: `git hash-object --no-filters <path>` compared against
  `git hash-object <path>`, plus `git check-attr text` and a `--path ... --stdin` negative control.
- Reason: the delegation governing this execution run directs that the executor perform no
  `git add`; the orchestrator owns staging. The substitute establishes the same property without
  writing to the index. `git add` stores exactly the object that `git hash-object <path>` computes,
  because both apply the same attribute-driven clean/eol conversion for that path;
  `git hash-object --no-filters <path>` computes the object for the raw working-tree bytes. The two
  being equal is therefore the same assertion the plan's `add` + `rev-parse :path` comparison makes,
  and it is made without mutating the index.

Output Summary:

**Fixture creation.** `tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md` was created
with every line terminated by a carriage return followed by a line feed. `cat -A` confirms the
terminators, showing `^M$` at the end of all three lines:

    # Memory Index^M$
    ^M$
    - [Existing lesson](existing-lesson.md) - a pre-existing index entry terminated with CRLF^M$

**Working-tree visibility.** `git status --porcelain -- tests/fixtures/cleanup_worktrees/preserve/eol-crlf`
exited 0 and printed:

    ?? tests/fixtures/cleanup_worktrees/preserve/eol-crlf/

The directory is listed as untracked, which is the expected pre-staging state.

**Object-name comparison — the decisive observation.**

- `git hash-object --no-filters tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`
  exited 0 and printed `0c8babf1bae26e47e802aee1408a0c27edf31710` (the raw CRLF bytes).
- `git hash-object tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`
  exited 0 and printed `0c8babf1bae26e47e802aee1408a0c27edf31710` (the bytes as git would store
  them for that path, with the `.gitattributes` rules applied).

The two 40-character object names are identical, so git applies no end-of-line conversion to this
path and the stored blob is byte-identical to the CRLF working file.

**The gate is demonstrated able to fail, by two independent controls.**

1. `git check-attr text -- <fixture> <a sibling path outside the exception>` printed:

       tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md: text: unset
       tests/fixtures/cleanup_worktrees/preserve/other/MEMORY.md: text: auto

   The attribute is `unset` only inside the exception directory, and remains `auto` one directory
   away. The attribute machinery discriminates between the two paths.

2. Negative control on identical bytes:
   `git hash-object --path tests/fixtures/cleanup_worktrees/preserve/other/MEMORY.md --stdin < <fixture>`
   printed `f4127703c7e8981c9fe157128a106bbf03805280`. The same CRLF bytes hashed under the default
   `* text=auto eol=lf` rule produce a different object name, because git normalizes them to LF.
   This control writes no file. It establishes that the equality recorded above is a real property
   of the `-text` exception and not an artifact of the comparison always holding.

The equality is therefore false whenever the `.gitattributes` exception is absent, misspelled, or
ordered before the `* text=auto eol=lf` line.

A worktree-against-index difference check is deliberately not used here: that comparison applies the
same end-of-line conversion to both sides and reports no difference even when the index blob was
normalized, so it cannot detect the failure this gate exists to detect.

**Deferred spans, now discharged by the orchestrator.** The `add` and `rev-parse :path` spans the
plan names were deferred to the orchestrator, which owns staging for this run. The orchestrator
subsequently staged the tree with a real `add` and reported that
`rev-parse :tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md` returned
`0c8babf1bae26e47e802aee1408a0c27edf31710`.

- Actor: the orchestrator, not this executor.
- Observed index object name: `0c8babf1bae26e47e802aee1408a0c27edf31710`.
- Predicted index object name, recorded above before staging occurred:
  `0c8babf1bae26e47e802aee1408a0c27edf31710`.

The two are equal, so the index blob is byte-identical to the CRLF working file and the
`.gitattributes` `-text` exception applied to the real staging operation exactly as the substitute
comparison predicted. This was a falsifiable prediction: had the exception not applied, git would
have normalized the blob to LF and the index object name would have been
`f4127703c7e8981c9fe157128a106bbf03805280`, the value the negative control above recorded for the
same bytes under the default `* text=auto eol=lf` rule.

Verdict: PASS. The CRLF fixture is created, is proven to survive git's end-of-line conversion, and
the prediction was confirmed against a real staging operation.
