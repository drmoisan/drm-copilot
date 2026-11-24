# 0014: Epic child CI opt-out

## Summary

reduction: 0014
Date: 2026-11-24
Issue: #1233
Merge commit: pending (PR #1233)

Adds the epic-level opt-out `child_ci: integration_only`. Under the opt-out an epic child merges into its integration branch on verified local final-QC evidence and a current concurrent review instead of a green `CI` run on its own head: the item checkpoint records `child_ci: "integration_only"` (relayed by the kickoff line `Child CI: integration_only.`) and a `local_qc_gate` record in place of `ci_gate`, S9 neither queries checks as a gate nor dispatches `CI` for the child head, and the merge gate helper `enforce-epic-merge-gate-child-ci.ps1` verifies the live base, `review_mode: "concurrent"`, the record, and the evidence file at the live head, denying with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: stage <id> (<name>): <detail>`. The validators (Python, TypeScript, PowerShell) and both completion-consistency hooks accept `local_qc_gate` in place of `ci_gate` only under the opt-out. The default `per_child`, an absent key, and every other value keep the previous behavior on every surface. Until the pull request exists, the `Merge commit:` line carries the canonical issue number as a stand-in, as entries 0004 and 0005 did, and the orchestrator replaces it with the pull request number right after PR creation.

## Reason and Evidence

The owner directed on 2026-11-23: "for the epic run, do not run CI on each feature. only run it on the final epic merge to main", and chose to change the gate rather than bypass it. An epic with N children paid for N full CI runs plus the integration run, and each child waited for its own run before it merged. The specification is `.dev/active/1233-epic-child-ci-opt-out/spec.md`; the research is `.dev/active/1233-epic-child-ci-opt-out/research/research.2026-11-24T04-02.md`. This entry is created by the first task that edits a file carrying a recorded region and is extended by every later editing task of the change.

## Files Changed

- `scripts/dev_tools/validate_orchestrator_state.py`: source, the key-gated local-QC selection inside the `route_requires_ci_gate` block
- `tests/fixtures/orchestrator_state_child_ci/`: created shared corpus (one JSON file per case)
- `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`: extended test
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts`: created source, the TypeScript port of the selection
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`: source, the `routeRequiresCiGate` branch calls the selection
- `extensions/drm-copilot/jest.config.cjs`: source, the `coverageThreshold` entry of the created source
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`: created test
- `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`: source, the selection inside `Get-OrchestratorStateCompletionCiGateError` and two private helpers
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`: byte-identical mirror of `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`: created test
- `.dev/engineering/process-reductions/0014-epic-child-ci-opt-out.md`: this entry
- `.dev/engineering/process-reductions/README.md`: index row

## Prior Text

### Revert Block: scripts/dev_tools/validate_orchestrator_state.py

````Current
CI_GATE_KEYS = ("conclusion", "head_sha", "verified_at")
LOCAL_QC_GATE_KEYS = ("conclusion", "head_sha", "evidence_path", "verified_at")
CHILD_CI_INTEGRATION_ONLY = "integration_only"
````

````Prior
CI_GATE_KEYS = ("conclusion", "head_sha", "verified_at")
````

### Revert Block: scripts/dev_tools/validate_orchestrator_state.py

````Current

def _child_ci_integration_only(state: dict[str, Any]) -> bool:
    """Report whether a checkpoint opts its epic child out of per-child CI.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        bool: True only when `epic_mode` is the JSON boolean true and
        `child_ci` is the exact string `integration_only` (issue #1233).
    """
    child_ci = state.get("child_ci")
    return (
        state.get("epic_mode") is True
        and isinstance(child_ci, str)
        and child_ci == CHILD_CI_INTEGRATION_ONLY
    )


def _last_review_head_sha(state: dict[str, Any]) -> object:
    """Return the `head_sha` of the final `review_outcomes` entry, or None.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        object: The recorded value, or None when the loop, the list, or the
        last object entry is absent.
    """
    loop = state.get("remediation_loop")
    if not isinstance(loop, dict):
        return None
    outcomes = cast("dict[str, object]", loop).get("review_outcomes")
    if not isinstance(outcomes, list) or not outcomes:
        return None
    last = cast("list[object]", outcomes)[-1]
    if not isinstance(last, dict):
        return None
    return cast("dict[str, object]", last).get("head_sha")


def _validate_completion_local_qc_gate(state: dict[str, Any]) -> list[str]:
    """Validate the local final-QC gate of an opted-out epic child.

    Args:
        state (dict[str, Any]): Parsed checkpoint state under the opt-out.

    Returns:
        list[str]: The ordered completion errors: the object-shape error
        alone, otherwise the missing fields, the conclusion, and then either
        the review-mode error or, under concurrent review, the head binding.
    """
    gate = state.get("local_qc_gate")
    if not isinstance(gate, dict):
        return [
            "Checkpoint completion validation failed: child_ci integration_only "
            "requires local_qc_gate to be an object with keys: "
            f"{', '.join(LOCAL_QC_GATE_KEYS)}."
        ]
    errors: list[str] = []
    gate_map = cast("dict[str, object]", gate)
    missing = _missing_object_keys(gate_map, LOCAL_QC_GATE_KEYS)
    if missing:
        errors.append(
            "Checkpoint completion validation failed: local_qc_gate missing "
            f"required fields: {', '.join(missing)}."
        )
    if gate_map.get("conclusion") != "success":
        errors.append(
            "Checkpoint completion validation failed: local_qc_gate.conclusion "
            "must be success."
        )
    if state.get("review_mode") != "concurrent":
        errors.append(
            "Checkpoint completion validation failed: child_ci integration_only "
            "requires review_mode concurrent."
        )
        return errors
    last_head = _last_review_head_sha(state)
    if not isinstance(last_head, str) or gate_map.get("head_sha") != last_head:
        errors.append(
            "Checkpoint completion validation failed: local_qc_gate.head_sha must "
            "match the head_sha of the last review_outcomes entry."
        )
    return errors


def validate_completion_gate_evidence(state: dict[str, Any]) -> list[str]:
    """Select the completion gate check for a CI-gated route (issue #1233).

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        list[str]: The local-QC errors when the checkpoint opts its epic child
        out of per-child CI, otherwise the existing `ci_gate` errors.
    """
    if _child_ci_integration_only(state):
        return _validate_completion_local_qc_gate(state)
    return _validate_completion_ci_gate(state)


````

````Prior
````

### Revert Block: scripts/dev_tools/validate_orchestrator_state.py

````Current
        if route_requires_ci_gate(state_map):
            errors.extend(validate_completion_gate_evidence(state_map))
````

````Prior
        if route_requires_ci_gate(state_map):
            errors.extend(_validate_completion_ci_gate(state_map))
````

### Revert Block: tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py

````Current
import json
from pathlib import Path
from typing import Any, cast

import pytest
````

````Prior
import json
````

### Revert Block: tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py

````Current

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
CHILD_CI_CORPUS_DIR = (
    Path(__file__).resolve().parents[3]
    / "tests"
    / "fixtures"
    / "orchestrator_state_child_ci"
)
# Floor on the shared child CI corpus (issue #1233), matching the TypeScript and
# PowerShell readers, so an empty or partial glob cannot pass vacuously.
CHILD_CI_MINIMUM_CORPUS_COUNT = 13
CHILD_CI_CORPUS_PATHS = tuple(sorted(CHILD_CI_CORPUS_DIR.glob("*.json")))
CHILD_CI_REVIEWED_HEAD = "3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f"
CI_GATE_SHAPE_ERROR = (
    "Checkpoint completion validation failed: ci_gate must be an object with keys: "
    "conclusion, head_sha, verified_at."
)

````

````Prior
````

### Revert Block: tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py

````Current
    assert any("missing mandatory phase S3_promotion" in error for error in errors)


def _load_child_ci_fixture(path: Path) -> dict[str, Any]:
    """Read one committed child CI corpus file.

    Args:
        path (Path): Absolute path to a corpus file.

    Returns:
        dict[str, Any]: The parsed fixture with `name`, `checkpoint`, and
        `expected_errors`.
    """
    return cast("dict[str, Any]", json.loads(path.read_text(encoding="utf-8")))


def _child_ci_gate_errors(errors: list[str]) -> list[str]:
    """Return the completion gate errors of either gate check.

    Args:
        errors (list[str]): Validator errors.

    Returns:
        list[str]: The errors that name `ci_gate`, `local_qc_gate`, or `child_ci`.
    """
    return [
        error
        for error in errors
        if "ci_gate" in error or "local_qc_gate" in error or "child_ci" in error
    ]


def _build_opted_out_complete_state() -> dict[str, object]:
    """Return a completion-safe small-route checkpoint that opts out of child CI.

    Returns:
        dict[str, object]: The checkpoint with the opt-out keys, a concurrent
        PASS review at the reviewed head, and a valid `local_qc_gate`.
    """
    state = build_complete_small_state()
    state.pop("ci_gate", None)
    state["epic_mode"] = True
    state["child_ci"] = "integration_only"
    state["review_mode"] = "concurrent"
    state["remediation_loop"] = {
        "review_outcomes": [{"verdict": "PASS", "head_sha": CHILD_CI_REVIEWED_HEAD}]
    }
    state["local_qc_gate"] = {
        "conclusion": "success",
        "head_sha": CHILD_CI_REVIEWED_HEAD,
        "evidence_path": (
            ".dev/active/feature-1/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md"
        ),
        "verified_at": "2026-11-24T05:00:00Z",
    }
    return state


@pytest.mark.parametrize(
    "path", CHILD_CI_CORPUS_PATHS, ids=[path.stem for path in CHILD_CI_CORPUS_PATHS]
)
def test_child_ci_corpus_matches_expected_errors(path: Path) -> None:
    """Assert the gate selection returns exactly the ordered corpus errors.

    Args:
        path (Path): One child CI corpus file.
    """
    # Arrange
    fixture = _load_child_ci_fixture(path)

    # Act
    observed = state_validator.validate_completion_gate_evidence(fixture["checkpoint"])

    # Assert
    assert fixture["name"] == path.stem
    assert observed == fixture["expected_errors"]


def test_child_ci_corpus_count_meets_floor() -> None:
    """Guard the parametrized child CI cases against an empty corpus glob."""

    # Arrange and act
    discovered = len(CHILD_CI_CORPUS_PATHS)

    # Assert
    assert discovered >= CHILD_CI_MINIMUM_CORPUS_COUNT


def test_require_complete_accepts_opted_out_child_without_ci_gate() -> None:
    """Accept an opted-out child at completion with no ci_gate error."""

    # Arrange
    state = _build_opted_out_complete_state()

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    # Assert
    assert _child_ci_gate_errors(errors) == []


def test_require_complete_reports_ci_gate_error_without_opt_out() -> None:
    """Report the existing ci_gate error once the opt-out key is removed."""

    # Arrange
    state = _build_opted_out_complete_state()
    state.pop("child_ci")

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    # Assert
    assert _child_ci_gate_errors(errors) == [CI_GATE_SHAPE_ERROR]
````

````Prior
    assert any("missing mandatory phase S3_promotion" in error for error in errors)
````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts

````Current
  PROMOTION_RECEIPT_NAMESPACE_KEY,
````

````Prior
  PROMOTION_RECEIPT_NAMESPACE_KEY,
  validateCompletionCiGate,
````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts

````Current
} from "./orchestrator-state-routing";
import { validateCompletionGateEvidence } from "./orchestrator-state-child-ci";
````

````Prior
} from "./orchestrator-state-routing";
````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts

````Current
    if (routeRequiresCiGate(stateMap, { routingMatrix })) {
      errors.push(...validateCompletionGateEvidence(stateMap));
````

````Prior
    if (routeRequiresCiGate(stateMap, { routingMatrix })) {
      errors.push(...validateCompletionCiGate(stateMap));
````

### Revert Block: extensions/drm-copilot/jest.config.cjs

````Current
    },
    // Issue #1233: the completion gate selection under child_ci integration_only.
    "./src/lib/validate/orchestrator-state-child-ci.ts": {
      lines: 85,
      branches: 75,
    },
````

````Prior
    },
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1

````Current
$script:CI_GATE_KEYS = @('conclusion', 'head_sha', 'verified_at')
$script:LOCAL_QC_GATE_KEYS = @('conclusion', 'head_sha', 'evidence_path', 'verified_at')
````

````Prior
$script:CI_GATE_KEYS = @('conclusion', 'head_sha', 'verified_at')
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1

````Current

function Test-OrchestratorStateChildCiIntegrationOnly {
    <#
    .SYNOPSIS
        Report whether a checkpoint opts its epic child out of per-child CI (issue #1233).
    .DESCRIPTION
        Private predicate mirroring _child_ci_integration_only: epic_mode must be the JSON
        boolean true and child_ci the exact string integration_only. Both keys are read by
        ordinal name, as a Python dict lookup does.
    .PARAMETER State
        The parsed checkpoint object.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject] $State
    )

    $epicMode = (Get-CheckpointObjectOrdinalMember -Owner $State -Name 'epic_mode').Value
    $childCi = (Get-CheckpointObjectOrdinalMember -Owner $State -Name 'child_ci').Value
    return (($epicMode -is [bool]) -and $epicMode -and ($childCi -is [string]) -and ($childCi -ceq 'integration_only'))
}

function Get-OrchestratorStateCompletionLocalQcGateError {
    <#
    .SYNOPSIS
        Return the local final-QC gate errors of an opted-out epic child (issue #1233).
    .DESCRIPTION
        Private check mirroring _validate_completion_local_qc_gate. A non-object local_qc_gate
        reports the object-shape error alone; otherwise the missing fields, the success
        conclusion, and then either the review-mode error or, under review_mode concurrent,
        the binding to the head_sha of the last review_outcomes entry, in that order.
    .PARAMETER State
        The parsed checkpoint object.
    .OUTPUTS
        System.String[] - zero or more error strings.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject] $State
    )

    $gate = (Get-CheckpointObjectOrdinalMember -Owner $State -Name 'local_qc_gate').Value
    if (-not (Test-CheckpointObjectValue -Value $gate)) {
        return [string[]]@("Checkpoint completion validation failed: child_ci integration_only requires local_qc_gate to be an object with keys: $($script:LOCAL_QC_GATE_KEYS -join ', ').")
    }

    $errors = [System.Collections.Generic.List[string]]::new()
    $missing = @(Get-MissingGateKey -Value $gate -GateKey $script:LOCAL_QC_GATE_KEYS)
    if ($missing.Count -gt 0) {
        $errors.Add("Checkpoint completion validation failed: local_qc_gate missing required fields: $($missing -join ', ').")
    }
    $conclusion = (Get-CheckpointObjectMember -Owner $gate -Name 'conclusion').Value
    if (-not (Test-PythonValueEqual -Actual $conclusion -Expected 'success')) {
        $errors.Add('Checkpoint completion validation failed: local_qc_gate.conclusion must be success.')
    }

    $mode = (Get-CheckpointObjectOrdinalMember -Owner $State -Name 'review_mode').Value
    if (-not (($mode -is [string]) -and ($mode -ceq 'concurrent'))) {
        $errors.Add('Checkpoint completion validation failed: child_ci integration_only requires review_mode concurrent.')
        return $errors.ToArray()
    }

    # A missing loop, a non-list value, an empty list, and a non-object last entry leave no head.
    $last = $null
    $loop = (Get-CheckpointObjectMember -Owner $State -Name 'remediation_loop').Value
    $outcomes = (Get-CheckpointObjectMember -Owner $loop -Name 'review_outcomes').Value
    if ((Test-CheckpointListValue -Value $outcomes) -and $outcomes.Count -gt 0) {
        $last = $outcomes[$outcomes.Count - 1]
    }
    $lastHead = (Get-CheckpointObjectMember -Owner $last -Name 'head_sha').Value
    $gateHead = (Get-CheckpointObjectMember -Owner $gate -Name 'head_sha').Value
    if (-not (($lastHead -is [string]) -and ($gateHead -is [string]) -and ($gateHead -ceq $lastHead))) {
        $errors.Add('Checkpoint completion validation failed: local_qc_gate.head_sha must match the head_sha of the last review_outcomes entry.')
    }
    return $errors.ToArray()
}

````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1

````Current

    # Child CI opt-out (issue #1233): local_qc_gate replaces ci_gate for an opted-out epic child.
    if (Test-OrchestratorStateChildCiIntegrationOnly -State $State) {
        return [string[]]@(Get-OrchestratorStateCompletionLocalQcGateError -State $State)
    }

    $ciGate =(Get-CheckpointObjectMember -Owner $State -Name 'ci_gate').Value
````

````Prior

    $ciGate = (Get-CheckpointObjectMember -Owner $State -Name 'ci_gate').Value
````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence in the named file, and delete the files this change created: `tests/fixtures/orchestrator_state_child_ci/` (every file), `extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`.
2. Re-copy mirrors and bundles: copy `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`.
3. Regenerate Codex variants: not applicable; run `scripts/dev_tools/generate_codex_agent_variants.py` in module form with `--check` to confirm no variant changed.
4. Restore pinned hashes: not applicable.
5. Restore contract-test literals: not applicable.
6. Run the contract tests: `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`, and `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`.

## Revert Signals

- An integration pull request into `main` fails `CI` on a defect that a child's own `CI` run would have caught, and the defect is traced to an opted-out child.
