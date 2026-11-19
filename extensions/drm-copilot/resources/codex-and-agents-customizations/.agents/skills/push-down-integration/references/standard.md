# Gold Standard: push-down-integration

## Objective

An agent session integrates a push-down into a destination by reading the recorded integration items, resolving each one with ordinary edits under the destination's hooks and review, and stopping only when the deterministic validate verdict passes.

## Observable Behaviors

- **OB-1** The session reads `.push-down-integration-needed.json` and calls `detect_push_down_integration` before it edits the destination.
- **OB-2** Each item is resolved with one of the `resolution_options` of its kind, through ordinary edits; no item is resolved by a model call inside a tool.
- **OB-3** The session calls `validate_push_down_integration`, returns to resolving on `verdict: fail`, and stops only when `integration.verdict` is `pass`.
- **OB-4** The hand-off quotes the `not_checked` list and reports each item that remains after a re-run of the push-down with the decision taken for it.
- **OB-5** A path the destination owns is declared by listing it in `.push-down-exclusions`.

## Acceptance Checks

- **AC-1** (OB-1) The session transcript shows the integration-needed file read and a detect call before the first destination edit.
- **AC-2** (OB-2) Every resolved item's decision is one of the `resolution_options` listed for its kind.
- **AC-3** (OB-3) The last validate call of the session returned `integration.verdict` equal to `pass`.
- **AC-4** (OB-4) The hand-off contains the twelve `not_checked` entries and one decision line per item left in the file after the re-run.
- **AC-5** (OB-5) Every path reported as destination-owned is matched by an entry of `.push-down-exclusions`.
