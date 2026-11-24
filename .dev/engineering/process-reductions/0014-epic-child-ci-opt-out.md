# 0014: Epic child CI opt-out

## Summary

reduction: 0014
Date: 2026-11-24
Issue: #1233
Merge commit: pending (PR #1233)

Adds the epic-level opt-out `child_ci: integration_only`. Under the opt-out an epic child merges into its integration branch on verified local final-QC evidence and a current concurrent review instead of a green `CI` run on its own head: the item checkpoint records `child_ci: "integration_only"` (relayed by the kickoff line `Child CI: integration_only.`) and a `local_qc_gate` record in place of `ci_gate`, S9 neither queries checks as a gate nor dispatches `CI` for the child head, and the merge gate helper `enforce-epic-merge-gate-child-ci.ps1` verifies the live base, `review_mode: "concurrent"`, the record, and the evidence file at the live head, denying with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: stage <id> (<name>): <detail>`. The validators (Python, TypeScript, PowerShell) and both completion-consistency hooks accept `local_qc_gate` in place of `ci_gate` only under the opt-out. The default `per_child`, an absent key, and every other value keep the previous behavior on every surface. Until the pull request exists, the `Merge commit:` line carries the canonical issue number as a stand-in, as entries 0004 and 0005 did, and the orchestrator replaces it with the pull request number right after PR creation.

## Reason and Evidence

The owner directed on 2026-11-23: "for the epic run, do not run CI on each feature. only run it on the final epic merge to main", and chose to change the gate rather than bypass it. An epic with N children paid for N full CI runs plus the integration run, and each child waited for its own run before it merged. The specification is `.dev/active/1233-epic-child-ci-opt-out/spec.md`; the research is `.dev/active/1233-epic-child-ci-opt-out/research/research.2026-11-24T04-02.md`. This entry is created by the first task that edits a file carrying a recorded region and is extended by every later editing task of the change.

Backstop: the integration pull request into `main` (merge-gate branch 2, `epic_merge_pr.ci_gate`) is unchanged and still requires a full green `CI` run, so every opted-out child is verified by CI before it reaches `main`. A defect that only CI would catch is found at the integration pull request instead of at the child.

Residual automatic run (spec decision D1): `.github/workflows/ci.yml` triggers on `pull_request` into `epic/**`, and this change does not edit any workflow, so a child pull request still starts an automatic `CI` run. Under the opt-out that run is neither waited for nor dispatched and is not a merge condition; the saving is the per-child wait and the dispatch fallback, not the compute of the automatic run.

Self-declared key (decision D10): `child_ci` is written by the item checkpoint, and a writer in the same session can set it; like every gate key, the opt-out is a policy-level control, not a security control. The reduction is bounded by the live pull-request base read through `baseRefName` (the base must equal the recorded `epic/<slug>-integration` branch and is never `main`, otherwise per-child CI verification decides), by the `review_mode: "concurrent"` requirement (the review guard proves a `PASS` review at a current head before the helper runs), and by the committed local-QC evidence file at the live head, whose first `EXIT_CODE:` is `0` and whose `Head:` line equals `local_qc_gate.head_sha`. Every checkpoint without the key, and every other value, keeps the previous behavior, which the default rows of both merge-gate suites, the unchanged existing suites, and the corpus default cases prove.

## Files Changed

- `scripts/dev_tools/validate_orchestrator_state.py`: source, the key-gated local-QC selection inside the `route_requires_ci_gate` block
- `tests/fixtures/orchestrator_state_child_ci/`: created shared corpus (one JSON file per case)
- `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`: extended test
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts`: created source, the TypeScript port of the selection
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`: source, the `routeRequiresCiGate` branch calls the selection
- `extensions/drm-copilot/jest.config.cjs`: source, the `coverageThreshold` entry of the created source
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`: created test
- `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`: source, the selection inside `Get-OrchestratorStateCompletionCiGateError` and three private helpers, including the ordinal presence check `Get-MissingOrdinalGateKey`; the local-QC check reads every key through `Get-CheckpointObjectOrdinalMember`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`: byte-identical mirror of `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`: created test
- `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`: source, opt-out stages B, R, L1, L2, and L3, the `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED` prefix, the seam `Get-EpicMergeGateChildCiLivePullRequest`, `-GitRoot`, and the ordinal accessors `Get-EpicMergeGateChildCiOrdinalProperty` and `Get-EpicMergeGateChildLocalQcReviewedHead` through which the opt-out reads its keys
- `.codex/hooks/enforce-epic-merge-gate-child-ci.ps1`: byte-identical twin of `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`: byte-identical mirror of `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-child-ci.ps1`: byte-identical mirror of `.codex/hooks/enforce-epic-merge-gate-child-ci.ps1`
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1`: created test
- `.claude/hooks/enforce-epic-merge-gate.ps1`: source, branch 1 passes `-GitRoot $childRoot` and header condition 1 names the opt-out
- `.codex/hooks/enforce-epic-merge-gate.ps1`: source, header comment only (not identical to the Claude gate)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`: byte-identical mirror of `.claude/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`: byte-identical mirror of `.codex/hooks/enforce-epic-merge-gate.ps1`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1`: created test
- `.claude/hooks/enforce-completion-helpers.ps1`: source, `Test-CompletionChildCiIntegrationOnly` and `Get-CompletionLocalQcGateMissing`
- `.codex/hooks/enforce-completion-helpers.ps1`: byte-identical twin of `.claude/hooks/enforce-completion-helpers.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-helpers.ps1`: byte-identical mirror of `.claude/hooks/enforce-completion-helpers.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1`: byte-identical mirror of `.codex/hooks/enforce-completion-helpers.ps1`
- `tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1`: extended test
- `tests/scripts/codex-hooks/enforce-completion-helpers.OrdinalKeys.Tests.ps1`: created test
- `.claude/hooks/enforce-completion-consistency.ps1`: source, `Get-MissingCompletionEvidence` and the deny reason branch on the opt-out
- `.codex/hooks/enforce-completion-consistency.ps1`: source, the same change (not identical to the Claude hook)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`: byte-identical mirror of `.claude/hooks/enforce-completion-consistency.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`: byte-identical mirror of `.codex/hooks/enforce-completion-consistency.ps1`
- `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`: extended test
- `tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1`: extended test
- `.claude/skills/orchestrate/SKILL.md`: source, the opt-out paragraphs of `## Step S9 — CI Green Gate`, `## Checkpoint Schema — CI Gate Fields`, and condition 6 of `## PR Creation Gate`
- `.agents/skills/orchestrate/SKILL.md`: source (separate text), the opt-out paragraphs of `## CI Green Gate` and condition 5 of `## PR Creation Gate`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`: byte-identical mirror of `.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`: byte-identical mirror of `.agents/skills/orchestrate/SKILL.md`
- `.claude/skills/epic-orchestrate/SKILL.md`: source, the opt-out paragraphs of `## Epic Dependency Manifest`, `## Epic Integration Branch Lifecycle`, `## Merge-on-Green Kickoff Parameter`, and `## Epic-Level Checkpoint`
- `.agents/skills/epic-orchestrate/SKILL.md`: source (separate text), the opt-out paragraphs of `## Manifest Contract`, `## Integration Branch and Child Worktrees`, `## Fan-In and Conflict Handling`, `## Status Projection and Checkpoint`, and `## Final Integration PR`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`: byte-identical mirror of `.claude/skills/epic-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`: byte-identical mirror of `.agents/skills/epic-orchestrate/SKILL.md`
- `.claude/skills/epic-run/SKILL.md`: source, one paragraph at the end of `## Scope`
- `.agents/skills/epic-run/SKILL.md`: source (separate text), one paragraph at the end of `## Procedure`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-run/SKILL.md`: byte-identical mirror of `.claude/skills/epic-run/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md`: byte-identical mirror of `.agents/skills/epic-run/SKILL.md`
- `.dev/templates/epic/epic.md`: source, the commented optional `child_ci` key of the manifest frontmatter
- `extensions/drm-copilot/resources/feature-templates/epic/epic.md`: byte-identical mirror of `.dev/templates/epic/epic.md`
- `.agents/skills/epic-plan/SKILL.md`: generator source, one list item of `## Decomposition and Wave Design`
- `.claude/skills/epic-plan/SKILL.md`: generated output of `.agents/skills/epic-plan/SKILL.md` (text differs from its source)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md`: byte-identical mirror of `.claude/skills/epic-plan/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`: byte-identical mirror of `.agents/skills/epic-plan/SKILL.md`
- `scripts/harness-generation/sources/rules/orchestrator-state.md`: generator source, the section `epic-child-ci-opt-out-issue-1233` and one `## Enforcement` list item
- `scripts/harness-generation/sources/rules/orchestrator-state.json`: generator source, the section id in the Claude target `sections` list
- `.claude/rules/orchestrator-state.md`: generated output of the rule source
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`: byte-identical mirror of `.claude/rules/orchestrator-state.md`
- `.agents/skills/execution-environment/SKILL.md`: generator source of the execution-environment brief, four bullets
- `.claude/skills/execution-environment/SKILL.md`: generated output, byte-identical to `.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`: byte-identical mirrors of the brief
- `tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1`: created contract test, the labeled opt-out units in every copy
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: pinned hashes, the `.claude/skills/epic-orchestrate/SKILL.md` digest of `PINNED_FROZEN_SURFACE_HASHES` and the `RE-BASELINED by issue #1233` comment paragraph; the agent digest is unchanged
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

function Get-MissingOrdinalGateKey {
    <#
    .SYNOPSIS
        Return the gate keys absent or blank in a gate object, matched by ordinal name (issue #1233).
    .DESCRIPTION
        Private helper with the contract of Get-MissingGateKey, except that a key is present only
        when a property name equals it ordinally, as a Python dict lookup does. A non-object value
        reports every key as missing, because the ordinal accessor reads no member from it; a
        present key holding null or a blank string is also missing.
    .PARAMETER Value
        The candidate gate value from the checkpoint. May be $null.
    .PARAMETER GateKey
        The required key names, in message order.
    .OUTPUTS
        System.String[] - the missing key names, in the given order.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Value,

        [Parameter(Mandatory = $true)]
        [string[]] $GateKey
    )

    $missing = [System.Collections.Generic.List[string]]::new()
    foreach ($key in $GateKey) {
        $item = (Get-CheckpointObjectOrdinalMember -Owner $Value -Name $key).Value
        if ($null -eq $item -or (($item -is [string]) -and [string]::IsNullOrWhiteSpace([string]$item))) {
            $missing.Add($key)
        }
    }
    return $missing.ToArray()
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
    $missing = @(Get-MissingOrdinalGateKey -Value $gate -GateKey $script:LOCAL_QC_GATE_KEYS)
    if ($missing.Count -gt 0) {
        $errors.Add("Checkpoint completion validation failed: local_qc_gate missing required fields: $($missing -join ', ').")
    }
    $conclusion = (Get-CheckpointObjectOrdinalMember -Owner $gate -Name 'conclusion').Value
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
    $loop = (Get-CheckpointObjectOrdinalMember -Owner $State -Name 'remediation_loop').Value
    $outcomes = (Get-CheckpointObjectOrdinalMember -Owner $loop -Name 'review_outcomes').Value
    if ((Test-CheckpointListValue -Value $outcomes) -and $outcomes.Count -gt 0) {
        $last = $outcomes[$outcomes.Count - 1]
    }
    $lastHead = (Get-CheckpointObjectOrdinalMember -Owner $last -Name 'head_sha').Value
    $gateHead = (Get-CheckpointObjectOrdinalMember -Owner $gate -Name 'head_sha').Value
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

    $ciGate = (Get-CheckpointObjectMember -Owner $State -Name 'ci_gate').Value
````

````Prior

    $ciGate = (Get-CheckpointObjectMember -Owner $State -Name 'ci_gate').Value
````

### Revert Block: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1

````Current
    live-head lookup can change the head; like the rest of the gate this is a policy-level control.

    Child CI opt-out (issue #1233): when the checkpoint records epic_mode as the JSON boolean true,
    child_ci as the exact string integration_only, and an epic_context.integration_branch that matches
    ^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$, stages B, R, L1, L2, and L3 run after stage 1 in
    place of stages 2 to 6:

      B.  One bounded gh pr view <PR> --json headRefOid,baseRefName (Get-EpicMergeGateChildCiLivePullRequest).
          A failed lookup denies. A live base that is not exactly the recorded integration branch, or that
          is main, does not apply the opt-out: stages 2 to 6 run unchanged, and stage 3 reuses the head
          read here, so no second gh pr view is made.
      R.  review_mode is exactly concurrent. The review guard runs before this helper under that key, so
          reaching stage R proves a PASS review at a current head.
      L1. local_qc_gate is an object whose conclusion is exactly success, whose head_sha is a lowercase
          object id, and whose evidence_path is a clean relative path under
          <feature-folder>/evidence/qa-gates/ that ends in .md.
      L2. local_qc_gate.head_sha equals the head_sha of the last remediation_loop.review_outcomes entry.
      L3. One bounded git cat-file -p <live head>:<evidence_path> at GitRoot: the file exists, its first
          EXIT_CODE: line has value 0, and it holds a Timestamp: line and the line Head: <head_sha>.

    Every opt-out failure returns a Reason that begins
    "EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: " and does not fall through. Without the
    predicate the helper is unchanged and the opt-out seam is never called. child_ci is self-declared by
    the item checkpoint; the live base, the concurrent review, and the evidence file bound it.
    The opt-out reads its keys by ordinal name, as the validators and the completion hooks do.
#>

$script:EpicMergeGateChildCiReasonPrefix = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: '
$script:EpicMergeGateChildLocalQcReasonPrefix = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: '
$script:EpicMergeGateChildCiIntegrationBranchPattern = '\Aepic/[A-Za-z0-9][A-Za-z0-9._-]*-integration\z'
````

````Prior
    live-head lookup can change the head; like the rest of the gate this is a policy-level control.
#>

$script:EpicMergeGateChildCiReasonPrefix = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: '
````

### Revert Block: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1

````Current

function Get-EpicMergeGateChildCiOrdinalProperty {
    <#
    .SYNOPSIS
        Read a named property off a parsed JSON object by ordinal name, or $null when absent (issue #1233).
    .DESCRIPTION
        Same contract as Get-EpicMergeGateChildCiProperty, except that a property matches only when its
        name equals Name ordinally (-ceq), as a Python dict and a TypeScript property lookup do.
    .PARAMETER InputObject
        The parsed value.
    .PARAMETER Name
        The property name, compared ordinally.
    .OUTPUTS
        System.Object
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param([AllowNull()] $InputObject, [Parameter(Mandatory)][string] $Name)

    if ($InputObject -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    foreach ($property in $InputObject.PSObject.Properties) {
        if ($property.Name -ceq $Name) { return , $property.Value }
    }
    return $null
}

function Get-EpicMergeGateChildLocalQcReviewedHead {
    <#
    .SYNOPSIS
        Return the head_sha of the last remediation_loop.review_outcomes entry, read by ordinal names (pure).
    .DESCRIPTION
        A missing loop, a value that is not a list, an empty list, and a last entry that is not an object
        all return $null; only the final list element counts.
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .OUTPUTS
        System.Object or $null
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param([AllowNull()] $Checkpoint)

    $loop = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'remediation_loop'
    $outcomes = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $loop -Name 'review_outcomes'
    if ($outcomes -isnot [System.Array] -or $outcomes.Count -eq 0) { return $null }
    $head = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $outcomes[$outcomes.Count - 1] -Name 'head_sha'
    return , $head
}

function Test-EpicMergeGateChildCiOptOut {
    <#
    .SYNOPSIS
        Report whether the child-CI opt-out predicate of issue #1233 holds for a parsed checkpoint (pure).
    .DESCRIPTION
        True only when epic_mode is the JSON boolean true, child_ci is the exact string integration_only
        (ordinal), and epic_context.integration_branch is a string matching the integration-branch pattern.
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Checkpoint)

    $epicMode = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'epic_mode'
    if (-not ($epicMode -is [bool] -and $epicMode)) { return $false }
    $childCi = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'child_ci'
    if (-not ($childCi -is [string] -and $childCi -ceq 'integration_only')) { return $false }
    $context = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'epic_context'
    $branch = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $context -Name 'integration_branch'
    return ($branch -is [string] -and $branch -cmatch $script:EpicMergeGateChildCiIntegrationBranchPattern)
}

function Get-EpicMergeGateChildCiLivePullRequest {
    <#
    .SYNOPSIS
        Return the live head and base of a pull request, or $null on any failure (the opt-out seam).
    .DESCRIPTION
        Makes exactly one Invoke-DocsOnlyGhExe call, gh pr view <PR> --json headRefOid,baseRefName. A
        non-zero exit, output that does not parse to a JSON object, a malformed head, and an absent or
        blank base all return $null.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with HeadSha and BaseRef, or $null
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)][int] $PrNumber, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr', 'view', [string]$PrNumber, '--json', 'headRefOid,baseRefName')
    if ($null -eq $lookup -or $lookup.ExitCode -ne 0) { return $null }
    try {
        $pr = ConvertFrom-Json -InputObject ([string]$lookup.Output) -ErrorAction Stop
    } catch {
        # Unreadable gh output is a lookup failure; the opt-out fails closed on $null.
        return $null
    }
    $head = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $pr -Name 'headRefOid'
    $base = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $pr -Name 'baseRefName'
    if (-not (Test-EpicMergeGateChildCiObjectId -Value $head)) { return $null }
    if (-not ($base -is [string]) -or [string]::IsNullOrWhiteSpace($base)) { return $null }
    return [ordered]@{ HeadSha = [string]$head; BaseRef = [string]$base }
}

function Test-EpicMergeGateChildCiEvidencePath {
    <#
    .SYNOPSIS
        Report whether an evidence path is a clean relative .md path under <feature-folder>/evidence/qa-gates/ (pure).
    .PARAMETER Path
        The candidate local_qc_gate.evidence_path value, of any type.
    .PARAMETER FeatureFolder
        The validated feature-folder value.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Path, [Parameter(Mandatory)][string] $FeatureFolder)

    if ($Path -isnot [string] -or $Path.Length -eq 0) { return $false }
    if ($Path.IndexOf([char]92) -ge 0) { return $false }
    foreach ($segment in $Path.Split('/')) {
        if ($segment.Length -eq 0 -or $segment -ceq '.' -or $segment -ceq '..') { return $false }
    }
    if (-not $Path.StartsWith("$FeatureFolder/evidence/qa-gates/", [System.StringComparison]::Ordinal)) { return $false }
    return $Path.EndsWith('.md', [System.StringComparison]::Ordinal)
}

function Get-EpicMergeGateChildLocalQcEvidenceDetail {
    <#
    .SYNOPSIS
        Stage L3: read the evidence file at the live head and return a failure detail, or $null when it passes.
    .DESCRIPTION
        Makes exactly one Invoke-DocsOnlyGitExe call, git cat-file -p <head>:<path>, at GitRoot. The file
        must exist, its first EXIT_CODE: line must have value 0, and it must hold a Timestamp: line and the
        line Head: <head_sha>, compared ordinally.
    .PARAMETER LiveHead
        The live head commit of the pull request.
    .PARAMETER EvidencePath
        The validated local_qc_gate.evidence_path.
    .PARAMETER RecordedHead
        The validated local_qc_gate.head_sha.
    .PARAMETER GitRoot
        The directory git runs in.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $LiveHead,
        [Parameter(Mandatory)][string] $EvidencePath,
        [Parameter(Mandatory)][string] $RecordedHead,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $read = Invoke-DocsOnlyGitExe -WorktreeRoot $GitRoot -GitArgs @('cat-file', '-p', "${LiveHead}:$EvidencePath")
    if ($null -eq $read -or $read.ExitCode -ne 0) { return "stage L3 (evidence): $EvidencePath could not be read at the live head $LiveHead." }
    $lines = @(([string]$read.Output) -split "`n" | ForEach-Object { $_.TrimEnd("`r") })
    $exitLine = @($lines | Where-Object { $_.StartsWith('EXIT_CODE:', [System.StringComparison]::Ordinal) } | Select-Object -First 1)
    if ($exitLine.Count -eq 0) { return "stage L3 (evidence): $EvidencePath has no EXIT_CODE: line." }
    if ($exitLine[0].Substring('EXIT_CODE:'.Length).Trim() -cne '0') { return "stage L3 (evidence): the first EXIT_CODE: line of $EvidencePath is not 0." }
    if (@($lines | Where-Object { $_.StartsWith('Timestamp:', [System.StringComparison]::Ordinal) }).Count -eq 0) {
        return "stage L3 (evidence): $EvidencePath has no Timestamp: line."
    }
    if (@($lines | Where-Object { $_.TrimEnd() -ceq "Head: $RecordedHead" }).Count -eq 0) {
        return "stage L3 (evidence): $EvidencePath has no line Head: $RecordedHead."
    }
    return $null
}

function ConvertTo-EpicMergeGateChildLocalQcResult {
    <#
    .SYNOPSIS
        Build an applied opt-out result with a detail and the live head (pure).
    .PARAMETER Detail
        The failure detail, or $null when every stage passed.
    .PARAMETER LiveHead
        The live head read by stage B, or $null when stage B failed.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Applies, Detail, and LiveHead.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()][AllowEmptyString()][string] $Detail, [AllowNull()][AllowEmptyString()][string] $LiveHead)

    $detailValue = if ([string]::IsNullOrEmpty($Detail)) { $null } else { $Detail }
    $headValue = if ([string]::IsNullOrEmpty($LiveHead)) { $null } else { $LiveHead }
    return [ordered]@{ Applies = $true; Detail = $detailValue; LiveHead = $headValue }
}

function Get-EpicMergeGateChildLocalQcResult {
    <#
    .SYNOPSIS
        Evaluate opt-out stages B, R, L1, L2, and L3 (issue #1233).
    .DESCRIPTION
        Applies is $false only when the live base is not exactly the recorded integration branch or is
        main; LiveHead then carries the head read by stage B, for reuse by stage 3. Otherwise Applies is
        $true and Detail holds the first failure detail, or $null when every stage passes.
    .PARAMETER Checkpoint
        The parsed child checkpoint, for which Test-EpicMergeGateChildCiOptOut holds.
    .PARAMETER PrNumber
        The resolved pull request number.
    .PARAMETER GhRoot
        The directory gh runs in.
    .PARAMETER GitRoot
        The directory git runs in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Applies, Detail, and LiveHead.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] $Checkpoint,
        [Parameter(Mandatory)][int] $PrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $live = Get-EpicMergeGateChildCiLivePullRequest -PrNumber $PrNumber -WorktreeRoot $GhRoot
    if ($null -eq $live) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail "stage B (base): the live head and base of pull request $PrNumber could not be resolved." -LiveHead $null
    }
    $integration = [string](Get-EpicMergeGateChildCiOrdinalProperty -InputObject (Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'epic_context') -Name 'integration_branch')
    if ($live.BaseRef -cne $integration -or $live.BaseRef -ceq 'main') {
        return [ordered]@{ Applies = $false; Detail = $null; LiveHead = $live.HeadSha }
    }

    if (-not (Test-EpicMergeGateReviewModeConcurrent -Checkpoint $Checkpoint)) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage R (review): child_ci integration_only requires review_mode "concurrent".' -LiveHead $live.HeadSha
    }

    $gate = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'local_qc_gate'
    if ($gate -isnot [System.Management.Automation.PSCustomObject]) { return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage L1 (record): the checkpoint records no local_qc_gate object.' -LiveHead $live.HeadSha }
    $conclusion = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $gate -Name 'conclusion'
    if (-not ($conclusion -is [string] -and $conclusion -ceq 'success')) { return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage L1 (record): local_qc_gate.conclusion is not "success".' -LiveHead $live.HeadSha }
    $recordedHead = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $gate -Name 'head_sha'
    if (-not (Test-EpicMergeGateChildCiObjectId -Value $recordedHead)) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage L1 (record): local_qc_gate.head_sha is not a lowercase 40- or 64-character object id.' -LiveHead $live.HeadSha
    }
    $featureFolder = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $Checkpoint -Name 'feature-folder'
    if (-not (Test-EpicMergeGateReviewFeatureFolder -Value $featureFolder)) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail 'stage L1 (record): the checkpoint feature-folder is absent or not a clean development-docs path.' -LiveHead $live.HeadSha
    }
    $evidencePath = Get-EpicMergeGateChildCiOrdinalProperty -InputObject $gate -Name 'evidence_path'
    if (-not (Test-EpicMergeGateChildCiEvidencePath -Path $evidencePath -FeatureFolder ([string]$featureFolder))) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail "stage L1 (record): local_qc_gate.evidence_path is not a clean relative path under $featureFolder/evidence/qa-gates/ that ends in .md." -LiveHead $live.HeadSha
    }

    $reviewedHead = Get-EpicMergeGateChildLocalQcReviewedHead -Checkpoint $Checkpoint
    if (-not ($reviewedHead -is [string] -and $reviewedHead -ceq $recordedHead)) {
        return ConvertTo-EpicMergeGateChildLocalQcResult -Detail "stage L2 (binding): local_qc_gate.head_sha $recordedHead differs from the head_sha of the last review_outcomes entry." -LiveHead $live.HeadSha
    }

    $evidenceDetail = Get-EpicMergeGateChildLocalQcEvidenceDetail -LiveHead $live.HeadSha -EvidencePath ([string]$evidencePath) -RecordedHead ([string]$recordedHead) -GitRoot $GitRoot
    return ConvertTo-EpicMergeGateChildLocalQcResult -Detail $evidenceDetail -LiveHead $live.HeadSha
}

````

````Prior
````

### Revert Block: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1

````Current
        The directory gh runs in: the session root on Claude, the repository root on Codex.
    .PARAMETER GitRoot
        The directory git runs in for opt-out stage L3: the item worktree on Claude. Omitted or empty, it
        defaults to GhRoot.
````

````Prior
        The directory gh runs in: the session root on Claude, the repository root on Codex.
````

### Revert Block: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1

````Current
        [AllowNull()][Nullable[int]] $CommandPrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $gitDirectory = if ([string]::IsNullOrEmpty($GitRoot)) { $GhRoot } else { $GitRoot }
    try {
        $detail = Get-EpicMergeGateChildCiFailureDetail -Checkpoint $Checkpoint -CommandPrNumber $CommandPrNumber -GhRoot $GhRoot -GitRoot $gitDirectory
````

````Prior
        [AllowNull()][Nullable[int]] $CommandPrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot
    )

    try {
        $detail = Get-EpicMergeGateChildCiFailureDetail -Checkpoint $Checkpoint -CommandPrNumber $CommandPrNumber -GhRoot $GhRoot
````

### Revert Block: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1

````Current
    if ($null -eq $detail) { return [ordered]@{ Verified = $true; Reason = '' } }
    # An opt-out failure already carries its own prefix; every other detail takes the CI prefix.
    if ($detail.StartsWith($script:EpicMergeGateChildLocalQcReasonPrefix, [System.StringComparison]::Ordinal)) {
        return [ordered]@{ Verified = $false; Reason = $detail }
    }
````

````Prior
    if ($null -eq $detail) { return [ordered]@{ Verified = $true; Reason = '' } }
````

### Revert Block: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1

````Current
        The directory gh runs in.
    .PARAMETER GitRoot
        The directory git runs in for opt-out stage L3.
````

````Prior
        The directory gh runs in.
````

### Revert Block: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1

````Current
    [OutputType([string])]
    param(
        [AllowNull()] $Checkpoint,
        [AllowNull()][Nullable[int]] $CommandPrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $pr = Get-EpicMergeGateChildCiPrNumber -Checkpoint $Checkpoint -CommandPrNumber $CommandPrNumber
    if ($null -eq $pr.PrNumber) { return 'stage 1 (PR number): ' + $pr.Detail }

    # Child CI opt-out (issue #1233): stages B to L3 replace stages 2 to 6 unless the live base falls back.
    $knownLiveHead = $null
    if (Test-EpicMergeGateChildCiOptOut -Checkpoint $Checkpoint) {
        $localQc = Get-EpicMergeGateChildLocalQcResult -Checkpoint $Checkpoint -PrNumber $pr.PrNumber -GhRoot $GhRoot -GitRoot $GitRoot
        if ($localQc.Applies) {
            if ($null -eq $localQc.Detail) { return $null }
            return $script:EpicMergeGateChildLocalQcReasonPrefix + $localQc.Detail
        }
        $knownLiveHead = $localQc.LiveHead
    }

````

````Prior
    [OutputType([string])]
    param([AllowNull()] $Checkpoint, [AllowNull()][Nullable[int]] $CommandPrNumber, [AllowNull()][AllowEmptyString()][string] $GhRoot)

    $pr = Get-EpicMergeGateChildCiPrNumber -Checkpoint $Checkpoint -CommandPrNumber $CommandPrNumber
    if ($null -eq $pr.PrNumber) { return 'stage 1 (PR number): ' + $pr.Detail }

````

### Revert Block: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1

````Current

    $liveHead = if ($null -ne $knownLiveHead) { $knownLiveHead } else { Get-EpicMergeGateChildCiLiveHeadSha -PrNumber $pr.PrNumber -WorktreeRoot $GhRoot }
````

````Prior

    $liveHead = Get-EpicMergeGateChildCiLiveHeadSha -PrNumber $pr.PrNumber -WorktreeRoot $GhRoot
````

### Revert Block: .claude/hooks/enforce-epic-merge-gate.ps1

````Current
         #1130) verifies a green CI run on the live PR head. Any stage failure denies with
         EPIC_CHILD_CI_NOT_VERIFIED and never falls through to the later branches. The #1233 opt-out
         checks local final-QC evidence (-GitRoot); a failure denies EPIC_CHILD_LOCAL_QC_NOT_VERIFIED.
````

````Prior
         #1130) verifies a green CI run on the live PR head. Any stage failure denies with
         EPIC_CHILD_CI_NOT_VERIFIED and never falls through to the later branches.
````

### Revert Block: .claude/hooks/enforce-epic-merge-gate.ps1

````Current
        (Test-ChildCheckpointPrGateBinding -Checkpoint $childCheckpoint -CommandPrNumber $commandPrNumber)) {
        $childCi = Get-EpicMergeGateChildCiDecision -Checkpoint $childCheckpoint -CommandPrNumber $commandPrNumber -GhRoot $sessionRoot -GitRoot $childRoot
````

````Prior
        (Test-ChildCheckpointPrGateBinding -Checkpoint $childCheckpoint -CommandPrNumber $commandPrNumber)) {
        $childCi = Get-EpicMergeGateChildCiDecision -Checkpoint $childCheckpoint -CommandPrNumber $commandPrNumber -GhRoot $sessionRoot
````

### Revert Block: .codex/hooks/enforce-epic-merge-gate.ps1

````Current
    through to the epic, standalone, or docs-only branches.

    Child CI opt-out (issue #1233): under child_ci integration_only the same helper verifies the
    local final-QC evidence in place of a CI run (stages B, R, L1, L2, and L3), with gh and git in
    the repository root because -GitRoot defaults to -GhRoot, and a failure denies with
    EPIC_CHILD_LOCAL_QC_NOT_VERIFIED. The call below is unchanged.
````

````Prior
    through to the epic, standalone, or docs-only branches.
````

### Revert Block: .claude/hooks/enforce-completion-helpers.ps1

````Current
        absent, or ambiguous.
      - Test-CompletionChildCiIntegrationOnly and Get-CompletionLocalQcGateMissing:
        the child CI opt-out (issue #1233) predicate and its local_qc_gate
        evidence check, used in place of the ci_gate check under the opt-out.
````

````Prior
        absent, or ambiguous.
````

### Revert Block: .claude/hooks/enforce-completion-helpers.ps1

````Current

function Test-CompletionChildCiIntegrationOnly {
    <#
    .SYNOPSIS
        Returns $true when a checkpoint opts its epic child out of per-child CI (issue #1233).
    .DESCRIPTION
        Pure predicate: epic_mode must be the JSON boolean true and child_ci the exact string
        integration_only (ordinal). An absent key, a case variant, a non-string child_ci, and an
        epic_mode that is not a boolean all return $false, so every other checkpoint keeps the
        ci_gate evidence check.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $Payload
    )

    if ($Payload -isnot [System.Management.Automation.PSCustomObject]) {
        return $false
    }
    $names = @($Payload.PSObject.Properties.Name)
    if ($names -cnotcontains 'epic_mode' -or $names -cnotcontains 'child_ci') {
        return $false
    }
    $epicMode = $Payload.epic_mode
    $childCi = $Payload.child_ci
    return ($epicMode -is [bool] -and $epicMode -and $childCi -is [string] -and $childCi -ceq 'integration_only')
}

function Get-CompletionLocalQcGateMissing {
    <#
    .SYNOPSIS
        Returns the missing local_qc_gate evidence of an opted-out epic child (issue #1233).
    .DESCRIPTION
        Pure check used in place of the ci_gate evidence check: local_qc_gate must be an object
        whose conclusion is exactly success and whose head_sha and evidence_path are non-empty
        strings. An empty list means the evidence is present.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $Payload
    )

    $gate = $null
    if ($Payload -is [System.Management.Automation.PSCustomObject] -and (@($Payload.PSObject.Properties.Name) -ccontains 'local_qc_gate')) {
        $gate = $Payload.local_qc_gate
    }
    if ($gate -isnot [System.Management.Automation.PSCustomObject]) {
        return [string[]]@('local_qc_gate (object with conclusion == "success" and non-empty head_sha and evidence_path)')
    }

    $missing = [System.Collections.Generic.List[string]]::new()
    $names = @($gate.PSObject.Properties.Name)
    $conclusion = if ($names -ccontains 'conclusion') { $gate.conclusion } else { $null }
    if (-not ($conclusion -is [string] -and $conclusion -ceq 'success')) {
        $missing.Add('local_qc_gate.conclusion == "success"')
    }
    foreach ($field in @('head_sha', 'evidence_path')) {
        $value = if ($names -ccontains $field) { $gate.$field } else { $null }
        if ($null -eq $value -or [string]::IsNullOrWhiteSpace([string]$value)) {
            $missing.Add("local_qc_gate.$field")
        }
    }
    return [string[]]$missing.ToArray()
}

````

````Prior
````

### Revert Block: tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1

````Current
}

Describe 'Test-CompletionChildCiIntegrationOnly (Codex helpers, issue #1233)' {
    It 'returns true only for the JSON boolean epic_mode and the exact integration_only value' {
        $payload = '{"epic_mode":true,"child_ci":"integration_only"}' | ConvertFrom-Json
        Test-CompletionChildCiIntegrationOnly -Payload $payload | Should -BeTrue
    }

    It 'returns false for the default variant <Label>' -ForEach @(
        @{ Label = 'child_ci absent'; Json = '{"epic_mode":true}' }
        @{ Label = 'child_ci per_child'; Json = '{"epic_mode":true,"child_ci":"per_child"}' }
        @{ Label = 'a case variant'; Json = '{"epic_mode":true,"child_ci":"Integration_Only"}' }
        @{ Label = 'a non-string child_ci'; Json = '{"epic_mode":true,"child_ci":true}' }
        @{ Label = 'epic_mode the string true'; Json = '{"epic_mode":"true","child_ci":"integration_only"}' }
        @{ Label = 'epic_mode false'; Json = '{"epic_mode":false,"child_ci":"integration_only"}' }
        @{ Label = 'epic_mode absent'; Json = '{"child_ci":"integration_only"}' }
    ) {
        Test-CompletionChildCiIntegrationOnly -Payload ($Json | ConvertFrom-Json) | Should -BeFalse
    }

    It 'returns false for a null payload' {
        Test-CompletionChildCiIntegrationOnly -Payload $null | Should -BeFalse
    }
}

Describe 'Get-CompletionLocalQcGateMissing (Codex helpers, issue #1233)' {
    It 'returns no missing evidence for a valid local_qc_gate' {
        $payload = '{"local_qc_gate":{"conclusion":"success","head_sha":"3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f","evidence_path":".dev/active/f/evidence/qa-gates/local-qc-gate.md","verified_at":"2026-11-24T05:00:00Z"}}' | ConvertFrom-Json
        @(Get-CompletionLocalQcGateMissing -Payload $payload).Count | Should -Be 0
    }

    It 'names the object for <Label>' -ForEach @(
        @{ Label = 'an absent local_qc_gate'; Json = '{}' }
        @{ Label = 'a non-object local_qc_gate'; Json = '{"local_qc_gate":"success"}' }
    ) {
        @(Get-CompletionLocalQcGateMissing -Payload ($Json | ConvertFrom-Json)) | Should -Be @('local_qc_gate (object with conclusion == "success" and non-empty head_sha and evidence_path)')
    }

    It 'names <Expected> for <Label>' -ForEach @(
        @{ Label = 'an absent conclusion'; Json = '{"local_qc_gate":{"head_sha":"h","evidence_path":"p"}}'; Expected = 'local_qc_gate.conclusion == "success"' }
        @{ Label = 'a failure conclusion'; Json = '{"local_qc_gate":{"conclusion":"failure","head_sha":"h","evidence_path":"p"}}'; Expected = 'local_qc_gate.conclusion == "success"' }
        @{ Label = 'an absent head_sha'; Json = '{"local_qc_gate":{"conclusion":"success","evidence_path":"p"}}'; Expected = 'local_qc_gate.head_sha' }
        @{ Label = 'an empty head_sha'; Json = '{"local_qc_gate":{"conclusion":"success","head_sha":"","evidence_path":"p"}}'; Expected = 'local_qc_gate.head_sha' }
        @{ Label = 'an absent evidence_path'; Json = '{"local_qc_gate":{"conclusion":"success","head_sha":"h"}}'; Expected = 'local_qc_gate.evidence_path' }
        @{ Label = 'an empty evidence_path'; Json = '{"local_qc_gate":{"conclusion":"success","head_sha":"h","evidence_path":""}}'; Expected = 'local_qc_gate.evidence_path' }
    ) {
        @(Get-CompletionLocalQcGateMissing -Payload ($Json | ConvertFrom-Json)) | Should -Be @($Expected)
    }
}
````

````Prior
}
````

### Revert Block: .claude/hooks/enforce-completion-consistency.ps1

````Current
    }
    if (Test-CompletionChildCiIntegrationOnly -Payload $Payload) { $missing += @(Get-CompletionLocalQcGateMissing -Payload $Payload) } # Child CI opt-out (issue #1233)
    elseif ($null -eq $ciGate -or $ciGate -isnot [System.Management.Automation.PSCustomObject]) {
````

````Prior
    }
    if ($null -eq $ciGate -or $ciGate -isnot [System.Management.Automation.PSCustomObject]) {
````

### Revert Block: .claude/hooks/enforce-completion-consistency.ps1

````Current
            $ciHeadSha = Get-CheckpointStringValue -Payload $ciGate -Name 'head_sha'
            if (-not (Test-CompletionChildCiIntegrationOnly -Payload $Payload) -and $prHeadSha -and $ciHeadSha -and $prHeadSha -ne $ciHeadSha) {
````

````Prior
            $ciHeadSha = Get-CheckpointStringValue -Payload $ciGate -Name 'head_sha'
            if ($prHeadSha -and $ciHeadSha -and $prHeadSha -ne $ciHeadSha) {
````

### Revert Block: .claude/hooks/enforce-completion-consistency.ps1

````Current

    $reason = if (Test-CompletionChildCiIntegrationOnly -Payload $payload) { "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: $($missing -join ', '). A completion-asserting checkpoint of an epic child with child_ci integration_only must include a non-empty issue-num, a non-empty feature-folder, and a local_qc_gate object with conclusion == 'success' and non-empty head_sha and evidence_path in place of a ci_gate object; routes whose requires_pr_gate is true must also include pr_gate evidence. Supply the missing evidence or remove the completion assertion." } else { "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: $($missing -join ', '). A completion-asserting checkpoint must include a non-empty issue-num, a non-empty feature-folder, and a ci_gate object with conclusion == 'success' and a non-empty head_sha; routes whose requires_pr_gate is true must also include pr_gate evidence with a matching head_sha. Supply the missing evidence or remove the completion assertion." }
````

````Prior

    $reason = "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: $($missing -join ', '). A completion-asserting checkpoint must include a non-empty issue-num, a non-empty feature-folder, and a ci_gate object with conclusion == 'success' and a non-empty head_sha; routes whose requires_pr_gate is true must also include pr_gate evidence with a matching head_sha. Supply the missing evidence or remove the completion assertion."
````

### Revert Block: .codex/hooks/enforce-completion-consistency.ps1

````Current
    }
    if (Test-CompletionChildCiIntegrationOnly -Payload $Payload) { $missing += @(Get-CompletionLocalQcGateMissing -Payload $Payload) } # Child CI opt-out (issue #1233)
    elseif ($null -eq $ciGate -or $ciGate -isnot [System.Management.Automation.PSCustomObject]) {
````

````Prior
    }
    if ($null -eq $ciGate -or $ciGate -isnot [System.Management.Automation.PSCustomObject]) {
````

### Revert Block: .codex/hooks/enforce-completion-consistency.ps1

````Current
            $ciHeadSha = Get-CheckpointStringValue -Payload $ciGate -Name 'head_sha'
            if (-not (Test-CompletionChildCiIntegrationOnly -Payload $Payload) -and $prHeadSha -and $ciHeadSha -and $prHeadSha -ne $ciHeadSha) {
````

````Prior
            $ciHeadSha = Get-CheckpointStringValue -Payload $ciGate -Name 'head_sha'
            if ($prHeadSha -and $ciHeadSha -and $prHeadSha -ne $ciHeadSha) {
````

### Revert Block: .codex/hooks/enforce-completion-consistency.ps1

````Current

    $reason = if (Test-CompletionChildCiIntegrationOnly -Payload $payload) { "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: $($missing -join ', '). A completion-asserting checkpoint of an epic child with child_ci integration_only must include a non-empty issue-num, a non-empty feature-folder, and a local_qc_gate object with conclusion == 'success' and non-empty head_sha and evidence_path in place of a ci_gate object; routes whose requires_pr_gate is true must also include pr_gate evidence. Supply the missing evidence or remove the completion assertion." } else { "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: $($missing -join ', '). A completion-asserting checkpoint must include a non-empty issue-num, a non-empty feature-folder, and a ci_gate object with conclusion == 'success' and a non-empty head_sha; routes whose requires_pr_gate is true must also include pr_gate evidence with a matching head_sha. Supply the missing evidence or remove the completion assertion." }
````

````Prior

    $reason = "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: $($missing -join ', '). A completion-asserting checkpoint must include a non-empty issue-num, a non-empty feature-folder, and a ci_gate object with conclusion == 'success' and a non-empty head_sha; routes whose requires_pr_gate is true must also include pr_gate evidence with a matching head_sha. Supply the missing evidence or remove the completion assertion."
````

### Revert Block: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1

````Current
    }

    Context 'child CI opt-out (issue #1233)' {
        BeforeAll {
            $script:optOutHead = '3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f'
            $script:optOutPrGateMatrix = {
                [pscustomobject]@{ routes = [pscustomobject]@{ large = [pscustomobject]@{ requires_pr_gate = $true } } }
            }
            $script:preChangeReason = "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: ci_gate (object with conclusion == `"success`" and non-empty head_sha). A completion-asserting checkpoint must include a non-empty issue-num, a non-empty feature-folder, and a ci_gate object with conclusion == 'success' and a non-empty head_sha; routes whose requires_pr_gate is true must also include pr_gate evidence with a matching head_sha. Supply the missing evidence or remove the completion assertion."

            # Builds an opted-out completion payload; Gate replaces local_qc_gate, and RemoveGate drops it.
            function ConvertTo-OptOutCompletionPayload {
                param([hashtable] $Gate, [switch] $RemoveGate)

                $payload = @{
                    next_step        = 'complete'
                    'issue-num'      = '1233'
                    'feature-folder' = 'docs/features/active/feature-1233'
                    path_selected    = 'large'
                    epic_mode        = $true
                    child_ci         = 'integration_only'
                    pr_gate          = @{ pr_number = '42'; pr_url = 'https://github.com/o/r/pull/42'; head_branch = 'feature/x'; head_sha = 'ffffffffffffffffffffffffffffffffffffffff' }
                    local_qc_gate    = @{ conclusion = 'success'; head_sha = $script:optOutHead; evidence_path = 'docs/features/active/feature-1233/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md'; verified_at = '2026-11-24T05:00:00Z' }
                }
                if ($Gate) { $payload['local_qc_gate'] = $Gate }
                if ($RemoveGate) { $payload.Remove('local_qc_gate') }
                return $payload
            }
        }

        It 'allows DONE with a valid local_qc_gate, no ci_gate, and a pr_gate head that differs from the local head' {
            # Arrange
            $json = ConvertTo-CheckpointToolInput -Payload (ConvertTo-OptOutCompletionPayload)

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true } -RoutingMatrixReader $script:optOutPrGateMatrix

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because ([string]$decision.hookSpecificOutput.permissionDecisionReason)
        }

        It 'denies DONE naming <Missing> for <Label>' -ForEach @(
            @{ Label = 'an absent local_qc_gate'; Gate = $null; Remove = $true; Missing = 'local_qc_gate (object with' }
            @{ Label = 'a failure conclusion'; Gate = @{ conclusion = 'failure'; head_sha = 'h'; evidence_path = 'p' }; Remove = $false; Missing = 'local_qc_gate.conclusion == "success"' }
            @{ Label = 'an empty head_sha'; Gate = @{ conclusion = 'success'; head_sha = ''; evidence_path = 'p' }; Remove = $false; Missing = 'local_qc_gate.head_sha' }
            @{ Label = 'an absent evidence_path'; Gate = @{ conclusion = 'success'; head_sha = 'h' }; Remove = $false; Missing = 'local_qc_gate.evidence_path' }
        ) {
            # Arrange
            $json = ConvertTo-CheckpointToolInput -Payload (ConvertTo-OptOutCompletionPayload -Gate $Gate -RemoveGate:$Remove)

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true } -RoutingMatrixReader $script:optOutPrGateMatrix

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.Contains($Missing) | Should -BeTrue -Because $reason
        }

        It 'names the local_qc_gate alternative in the opt-out deny reason' {
            # Arrange
            $json = ConvertTo-CheckpointToolInput -Payload (ConvertTo-OptOutCompletionPayload -RemoveGate)

            # Act
            $reason = [string](Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true } -RoutingMatrixReader $script:optOutPrGateMatrix).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*local_qc_gate object with conclusion*in place of a ci_gate object*'
        }

        It 'keeps the pre-change deny reason byte-unchanged for a keyless checkpoint' {
            # Arrange
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '1233'
                'feature-folder' = 'docs/features/active/feature-1233'
                path_selected    = 'small'
            }

            # Act
            $reason = [string](Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true } -RoutingMatrixReader $script:optOutPrGateMatrix).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason | Should -BeExactly $script:preChangeReason
        }
    }
````

````Prior
    }
````

### Revert Block: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1

````Current
    }

    Context 'child CI opt-out (issue #1233)' {
        BeforeAll {
            $script:PreChangeReason = "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: ci_gate (object with conclusion == `"success`" and non-empty head_sha). A completion-asserting checkpoint must include a non-empty issue-num, a non-empty feature-folder, and a ci_gate object with conclusion == 'success' and a non-empty head_sha; routes whose requires_pr_gate is true must also include pr_gate evidence with a matching head_sha. Supply the missing evidence or remove the completion assertion."

            function ConvertTo-OptOutContent {
                <#
                    Builds the JSON content of an opted-out completion checkpoint; Gate replaces
                    local_qc_gate and RemoveGate drops it.
                #>
                param([hashtable] $Gate, [switch] $RemoveGate)

                $base = [ordered]@{
                    next_step        = 'complete'
                    route_id         = 'full-bug'
                    'issue-num'      = '1233'
                    'feature-folder' = '.dev/active/sample'
                    epic_mode        = $true
                    child_ci         = 'integration_only'
                    pr_gate          = [ordered]@{ pr_number = 42; pr_url = 'https://github.com/o/r/pull/42'; head_branch = 'feature/x'; head_sha = 'ffffffffffffffffffffffffffffffffffffffff' }
                    local_qc_gate    = [ordered]@{ conclusion = 'success'; head_sha = '3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f'; evidence_path = '.dev/active/sample/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md'; verified_at = '2026-11-24T05:00:00Z' }
                }
                if ($Gate) { $base['local_qc_gate'] = $Gate }
                if ($RemoveGate) { $base.Remove('local_qc_gate') }
                return ($base | ConvertTo-Json -Compress -Depth 10)
            }
        }

        It 'allows DONE with a valid local_qc_gate, no ci_gate, and a pr_gate head that differs from the local head' {
            # Arrange
            $raw = @{ file_path = $script:CheckpointPath; content = (ConvertTo-OptOutContent) } | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because ([string]$decision.hookSpecificOutput.permissionDecisionReason)
        }

        It 'denies DONE naming <Missing> for <Label>' -ForEach @(
            @{ Label = 'an absent local_qc_gate'; Gate = $null; Remove = $true; Missing = 'local_qc_gate (object with' }
            @{ Label = 'a failure conclusion'; Gate = @{ conclusion = 'failure'; head_sha = 'h'; evidence_path = 'p' }; Remove = $false; Missing = 'local_qc_gate.conclusion == "success"' }
            @{ Label = 'an empty head_sha'; Gate = @{ conclusion = 'success'; head_sha = ''; evidence_path = 'p' }; Remove = $false; Missing = 'local_qc_gate.head_sha' }
            @{ Label = 'an empty evidence_path'; Gate = @{ conclusion = 'success'; head_sha = 'h'; evidence_path = '' }; Remove = $false; Missing = 'local_qc_gate.evidence_path' }
        ) {
            # Arrange
            $raw = @{ file_path = $script:CheckpointPath; content = (ConvertTo-OptOutContent -Gate $Gate -RemoveGate:$Remove) } | ConvertTo-Json -Compress

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.Contains($Missing) | Should -BeTrue -Because $reason
        }

        It 'names the local_qc_gate alternative in the opt-out deny reason' {
            # Arrange
            $raw = @{ file_path = $script:CheckpointPath; content = (ConvertTo-OptOutContent -RemoveGate) } | ConvertTo-Json -Compress

            # Act
            $reason = [string](Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:PrGateRoute).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*local_qc_gate object with conclusion*in place of a ci_gate object*'
        }

        It 'keeps the pre-change deny reason byte-unchanged for a keyless checkpoint' {
            # Arrange
            $content = '{"next_step":"complete","route_id":"full-bug","issue-num":"1233","feature-folder":".dev/active/sample"}'
            $raw = @{ file_path = $script:CheckpointPath; content = $content } | ConvertTo-Json -Compress

            # Act
            $reason = [string](Invoke-CompletionConsistencyDecision -ToolInputRaw $raw -FolderExistsCheck $script:FolderPresent -RoutingMatrixReader $script:NoPrGateRoute).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason | Should -BeExactly $script:PreChangeReason
        }
    }
````

````Prior
    }
````

### Revert Block: .claude/skills/orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): a child records `child_ci: "integration_only"` at its first checkpoint write when its delegation prompt carries the separate line `Child CI: integration_only.`. Under `epic_mode: true` and that key, S9 resolves the live head and base with `gh pr view --json headRefOid,baseRefName`. When the base is not exactly `epic_context.integration_branch`, or is `main`, the opt-out does not apply and steps 1 to 6 run unchanged. Otherwise S9 does not query checks as a gate and never dispatches `CI` for the child head: it writes `<feature-folder>/evidence/qa-gates/local-qc-gate.<timestamp>.md` from the final QA artifacts (a `Timestamp:` line, the line `Head: <reviewed head>`, and an `EXIT_CODE:` line whose first occurrence is `0`), commits and pushes it on the PR branch, records `local_qc_gate` and `step9_status: "passed"` with `ci_gate` absent, and step 6 merges; the merge gate verifies the record and the file at the live head and denies a failure with `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED`. The opt-out requires `review_mode: "concurrent"`; a resumed sequential run stays `per_child`. Under the opt-out, `local_qc_gate` meets the CI conditions of item 5 of `## Concurrent Review and CI (review_mode)`, and item 11 compares the cross-check rows with the local final-QC evidence instead of `gh pr checks`. CI-dependent acceptance criteria are listed as pending integration CI and do not block the child's DONE.

````

````Prior
````

### Revert Block: .claude/skills/orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): an epic child adds the top-level `child_ci` (`per_child` or `integration_only`; absent means `per_child`) and, under `integration_only`, records in place of `ci_gate` a top-level `local_qc_gate` object containing `conclusion` (`success`), `head_sha` (the reviewed head), `evidence_path` (the repository-relative path of the committed local-QC evidence file), and `verified_at` (ISO-8601 UTC time at which S9 recorded the result).

````

````Prior
````

### Revert Block: .claude/skills/orchestrate/SKILL.md

````Current
6. `ci_gate.conclusion == "success"` AND `ci_gate.head_sha == current head SHA of the PR branch`. DONE is not written while either sub-condition is false.
   Child CI opt-out (issue #1233): under `child_ci` `integration_only`, the condition is met by `local_qc_gate` with `conclusion` `success` and `head_sha` equal to the reviewed head of the last `review_outcomes[]` entry, which the merge gate proves current, in place of `ci_gate`.
````

````Prior
6. `ci_gate.conclusion == "success"` AND `ci_gate.head_sha == current head SHA of the PR branch`. DONE is not written while either sub-condition is false.
````

### Revert Block: .agents/skills/orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): an epic child adds the top-level `child_ci` (`per_child` or `integration_only`; absent means `per_child`) and, under `integration_only`, records in place of `ci_gate` a top-level `local_qc_gate` object with the keys `conclusion` (`success`), `head_sha` (the reviewed head), `evidence_path` (the repository-relative path of the committed local-QC evidence file), and `verified_at` (the ISO-8601 UTC time at which this gate recorded the result).

The checkpoint records the pull request in a top-level `pr_gate` object with the keys `pr_number`, `pr_url`, `head_branch`, and `head_sha`. The key set is defined by `PR_GATE_KEYS` in `scripts/dev_tools/_orchestrator_state_routing.py`.

CI-dependent acceptance criteria are criteria whose verification requires the result of CI on the PR head. The item's own orchestrator run owns their check-off. After `ci_gate.conclusion` is `success`, check off each CI-dependent criterion in the item's own worktree, commit, push to the PR branch, and re-run this gate against the new head SHA, so that `ci_gate.head_sha` equals the final PR head before DONE. A failed re-run enters the Remediation Loop (R1–R5) as a blocking finding; the shared `remediation_loop.completed_attempts` count and its halt after three completed attempts are unchanged. A parent or coordinating session never commits these check-offs from its own root.

Child CI opt-out (issue #1233): a child records `child_ci: "integration_only"` at its first checkpoint write when its delegation prompt carries the separate line `Child CI: integration_only.`. Under `epic_mode: true` and that key, the gate resolves the live head and base with `gh pr view --json headRefOid,baseRefName`. When the base is not exactly `epic_context.integration_branch`, or is `main`, the opt-out does not apply and the gate procedure runs unchanged. Otherwise the gate does not query checks as a gate and never dispatches `CI` for the child head: it writes `<feature-folder>/evidence/qa-gates/local-qc-gate.<timestamp>.md` from the final QA artifacts (a `Timestamp:` line, the line `Head: <reviewed head>`, and an `EXIT_CODE:` line whose first occurrence is `0`), commits and pushes it on the PR branch, records `local_qc_gate` and `step9_status: "passed"` with `ci_gate` absent, and the child merges; `.codex/hooks/enforce-epic-merge-gate-child-ci.ps1` verifies the record and the file at the live head and denies a failure with `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED`. The opt-out requires `review_mode: "concurrent"`; a resumed sequential run stays `per_child`. Under the opt-out, `local_qc_gate` meets the CI conditions of item 5 of `## Concurrent Review and CI (review_mode)`, and item 11 compares the cross-check rows with the local final-QC evidence instead of `gh pr checks`. CI-dependent acceptance criteria are listed as pending integration CI and do not block the child's DONE.

````

````Prior

The checkpoint records the pull request in a top-level `pr_gate` object with the keys `pr_number`, `pr_url`, `head_branch`, and `head_sha`. The key set is defined by `PR_GATE_KEYS` in `scripts/dev_tools/_orchestrator_state_routing.py`.

CI-dependent acceptance criteria are criteria whose verification requires the result of CI on the PR head. The item's own orchestrator run owns their check-off. After `ci_gate.conclusion` is `success`, check off each CI-dependent criterion in the item's own worktree, commit, push to the PR branch, and re-run this gate against the new head SHA, so that `ci_gate.head_sha` equals the final PR head before DONE. A failed re-run enters the Remediation Loop (R1–R5) as a blocking finding; the shared `remediation_loop.completed_attempts` count and its halt after three completed attempts are unchanged. A parent or coordinating session never commits these check-offs from its own root.

````

### Revert Block: .agents/skills/orchestrate/SKILL.md

````Current
5. Every check on the current PR head SHA passed or was skipped (`ci_gate.conclusion` is `success`).
   Child CI opt-out (issue #1233): under `child_ci` `integration_only`, the condition is met by `local_qc_gate` with `conclusion` `success` and `head_sha` equal to the reviewed head of the last `review_outcomes[]` entry, which the merge gate proves current, in place of `ci_gate`.
````

````Prior
5. Every check on the current PR head SHA passed or was skipped (`ci_gate.conclusion` is `success`).
````

### Revert Block: .claude/skills/epic-orchestrate/SKILL.md

````Current
  (`## Cross-Epic Dependencies (cross_epic_depends_on)`).
- Child CI opt-out (issue #1233): the optional epic-level key `child_ci` takes the value
  `per_child` or `integration_only`, and an absent key means `per_child`. Any other value is a
  malformed manifest and is rejected before epic kickoff as a synthetic Blocking finding.
````

````Prior
  (`## Cross-Epic Dependencies (cross_epic_depends_on)`).
````

### Revert Block: .claude/skills/epic-orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): under `child_ci: integration_only` the integration pull request
of step 6 still requires a green `CI` run through the same S9 procedure; only child pull requests
into the integration branch skip their own `CI` run. Child acceptance criteria that depend on CI
are checked off in the integration worktree after integration CI is green, under the
merged-feature follow-up allowance (issue #1141).

````

````Prior
````

### Revert Block: .claude/skills/epic-orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): when the epic checkpoint records `child_ci: integration_only`,
the prompt carries the separate line `Child CI: integration_only.` after the epic-mode kickoff
line, which stays unchanged. The child records `child_ci: "integration_only"` at its first
checkpoint write and follows the `Child CI opt-out (issue #1233)` paragraph of S9 in
`.claude/skills/orchestrate/SKILL.md`.

````

````Prior
````

### Revert Block: .claude/skills/epic-orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): for a child whose epic records `child_ci: integration_only`,
`epic-orchestrator` never dispatches `CI` on the child branch, and the child merges on its
committed local final-QC evidence and a current concurrent review, which the same helper verifies
(`EPIC_CHILD_LOCAL_QC_NOT_VERIFIED`). The child's `features[]` entry moves from `pr_open` to
`merged` and is never recorded as `ci_green`. A child pull request still starts the automatic
`CI` run that the repository workflow triggers on `epic/**`; that run is not a merge condition.

````

````Prior
````

### Revert Block: .claude/skills/epic-orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): `epic-orchestrator` copies `child_ci` from the manifest to the
top level of the epic checkpoint at kickoff; an absent manifest key records nothing and means
`per_child`. The epic checkpoint validators tolerate the key.

````

````Prior
````

### Revert Block: .agents/skills/epic-orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): the optional epic-level key `child_ci` takes the value
`per_child` or `integration_only`, and an absent key means `per_child`. Any other value is a
malformed manifest and is rejected before kickoff as a synthetic Blocking finding.

````

````Prior
````

### Revert Block: .agents/skills/epic-orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): when the epic checkpoint records `child_ci: integration_only`,
the prompt carries the separate line `Child CI: integration_only.` after the literal above, which
stays unchanged. The child records `child_ci: "integration_only"` at its first checkpoint write
and follows the `Child CI opt-out (issue #1233)` paragraph of the `orchestrate` skill's CI Green
Gate.

````

````Prior
````

### Revert Block: .agents/skills/epic-orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): for a child whose epic records `child_ci: integration_only`,
`epic-orchestrator` never dispatches `CI` on the child branch, and the child merges on its
committed local final-QC evidence and a current concurrent review, which the same helper verifies
(`EPIC_CHILD_LOCAL_QC_NOT_VERIFIED`). The child's `features[]` entry moves from `pr_open` to
`merged` and is never recorded as `ci_green`. A child pull request still starts the automatic
`CI` run that the repository workflow triggers on `epic/**`; that run is not a merge condition.

````

````Prior
````

### Revert Block: .agents/skills/epic-orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): `epic-orchestrator` copies `child_ci` from the manifest to the
top level of the epic checkpoint at kickoff; an absent manifest key records nothing and means
`per_child`. The epic checkpoint validators tolerate the key.

````

````Prior
````

### Revert Block: .agents/skills/epic-orchestrate/SKILL.md

````Current

Child CI opt-out (issue #1233): under `child_ci: integration_only` the final integration PR still
requires a green `CI` run through the same CI-green procedure; only child pull requests into the
integration branch skip their own `CI` run. Child acceptance criteria that depend on CI are checked
off in the integration worktree after integration CI is green, under the merged-feature follow-up
allowance (issue #1141).

````

````Prior
````

### Revert Block: tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py

````Current
# pin stays live for both entries.
#
# RE-BASELINED by issue #1233. That change added the child CI opt-out
# (`child_ci: integration_only`) paragraphs to the epic skill: a list item of
# `## Epic Dependency Manifest`, a paragraph after item 6 of
# `## Epic Integration Branch Lifecycle`, a kickoff paragraph and a paragraph
# after `Epic-child CI verification (issue #1130)` in
# `## Merge-on-Green Kickoff Parameter`, and a paragraph of
# `## Epic-Level Checkpoint`. Only the skill digest moved; the agent digest is
# unchanged and the pin stays live for both entries.
PINNED_FROZEN_SURFACE_HASHES: tuple[tuple[str, str], ...] = (
    (
        ".claude/agents/epic-orchestrator.md",
        "47c4c5925c0ecbd53bcbbcab9672355826b971052939d3a81d2c7b82b00b549f",
    ),
    (
        ".claude/skills/epic-orchestrate/SKILL.md",
        "6fa8f3d30ede95af7431741d434212d66beeefb83ab70185a8e31c3ff29b44ce",
````

````Prior
# pin stays live for both entries.
PINNED_FROZEN_SURFACE_HASHES: tuple[tuple[str, str], ...] = (
    (
        ".claude/agents/epic-orchestrator.md",
        "47c4c5925c0ecbd53bcbbcab9672355826b971052939d3a81d2c7b82b00b549f",
    ),
    (
        ".claude/skills/epic-orchestrate/SKILL.md",
        "e334237b27c2188d2aafd0dc6d4f97c6493ba3f59a0b72772d86f74830e77e80",
````

### Revert Block: .claude/skills/epic-run/SKILL.md

````Current

Child CI opt-out (issue #1233): under `child_ci: integration_only` the per-child green-`CI`
requirement is replaced by verified local final-QC evidence and a current concurrent review, as
the `Child CI opt-out (issue #1233)` paragraphs of `## Merge-on-Green Kickoff Parameter` in the
`epic-orchestrate` skill state, and the integration pull request into `main` still requires a
green `CI` run.

````

````Prior
````

### Revert Block: .agents/skills/epic-run/SKILL.md

````Current
same epic slug.

Child CI opt-out (issue #1233): under `child_ci: integration_only` the per-child green-`CI`
requirement is replaced by verified local final-QC evidence and a current concurrent review, as
the `Child CI opt-out (issue #1233)` paragraphs of `## Fan-In and Conflict Handling` in the
`epic-orchestrate` skill state, and the final integration PR into `main` still requires a green
`CI` run.
````

````Prior
same epic slug.
````

### Revert Block: .dev/templates/epic/epic.md

````Current

# Optional epic-level child CI policy (issue #1233). Omit the key for the default
# `per_child`, under which every child merges only on a green CI run of its own head.
# Set `integration_only` only when the owner chose to run CI on the integration pull
# request into main alone; children then merge on local final-QC evidence.
# child_ci: <per_child | integration_only>

````

````Prior
````

### Revert Block: .agents/skills/epic-plan/SKILL.md

````Current

- Child CI opt-out (issue #1233): write `child_ci: integration_only` in the manifest frontmatter
  only when the owner chose to opt the epic out of per-child CI; otherwise omit the key, which
  means `per_child`. Under the opt-out, avoid child acceptance criteria that depend on CI, or
  mark each such criterion pending integration CI.

````

````Prior
````

### Revert Block: .claude/skills/epic-plan/SKILL.md

````Current

- Child CI opt-out (issue #1233): write `child_ci: integration_only` in the manifest frontmatter
  only when the owner chose to opt the epic out of per-child CI; otherwise omit the key, which
  means `per_child`. Under the opt-out, avoid child acceptance criteria that depend on CI, or
  mark each such criterion pending integration CI.

````

````Prior
````

### Revert Block: scripts/harness-generation/sources/rules/orchestrator-state.md

````Current

<!-- harness-section: epic-child-ci-opt-out-issue-1233 -->
## Epic-child CI opt-out (issue #1233)

An epic whose manifest records `child_ci: integration_only` opts its children out of per-child CI; an absent key, `per_child`, and every other value keep the per-child CI verification above. The epic checkpoint copies the key at kickoff, the kickoff prompt carries the separate line `Child CI: integration_only.`, and each child records `child_ci: "integration_only"` at its first checkpoint write and, at S9, a `local_qc_gate` object (`conclusion`, `head_sha`, `evidence_path`, `verified_at`) in place of `ci_gate`. The activation predicate is JSON `epic_mode` true and `child_ci` exactly `integration_only` (ordinal); the merge gate additionally requires `epic_context.integration_branch` to match `^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$`. Under the predicate, `Get-EpicMergeGateChildCiDecision` in `enforce-epic-merge-gate-child-ci.ps1` runs these stages after stage 1 in place of stages 2 to 6, and each failure denies with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: stage <id> (<name>): <detail>` without falling through:

- B (base): one bounded `gh pr view <PR> --json headRefOid,baseRefName`; a failed lookup denies, and a live base that is not exactly the recorded integration branch, or that is `main`, does not apply the opt-out, so stages 2 to 6 decide.
- R (review): `review_mode: "concurrent"`; the review guard runs first under that key, so reaching stage R proves a `PASS` review at a current head.
- L1 (record): `local_qc_gate` is an object whose `conclusion` is exactly `success`, whose `head_sha` is a lowercase 40- or 64-character object id, and whose `evidence_path` is a clean relative path under `<feature-folder>/evidence/qa-gates/` that ends in `.md`.
- L2 (binding): `local_qc_gate.head_sha` equals the `head_sha` of the last `remediation_loop.review_outcomes[]` entry.
- L3 (evidence): one bounded `git cat-file -p <live head>:<evidence_path>` in the item worktree (`-GitRoot`); the first `EXIT_CODE:` line is `0`, and the file holds a `Timestamp:` line and the line `Head: <head_sha>`.

Under `require_complete`, the Python, TypeScript, and PowerShell validators select the `local_qc_gate` check in place of the `ci_gate` check under the predicate and report byte-identical errors, pinned by the corpus `tests/fixtures/orchestrator_state_child_ci/`; both completion-consistency hooks accept `local_qc_gate` in place of `ci_gate` under the same predicate. The integration pull request into `main` still requires a green `CI` run, and a child pull request still starts the automatic `CI` run that `.github/workflows/ci.yml` triggers on `epic/**`; the opt-out removes it as a merge condition only. The reduction is recorded in process-reduction ledger entry 0014.

Honest disclosure: `child_ci` is self-declared by the item checkpoint, and a writer in the same session can set it; like every gate key, this is a policy-level control, not a security control (decision D10). The reduction is bounded by the live base read through `baseRefName`, which never admits a merge into `main`, by the `review_mode: "concurrent"` requirement, and by the evidence file at the live head with its `Head:` line.

````

````Prior
````

### Revert Block: scripts/harness-generation/sources/rules/orchestrator-state.md

````Current
- Restored-host note (#1163): after a worktree is restored or moved to a different host path, run `git worktree repair` so its registration names the current path. Until then the stale registration is `prunable`; `Resolve-AgentTargetWorktree` (`.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`) excludes it, so a branch registered only at the prunable path resolves `TARGET_WORKTREE_NOT_DERIVABLE`, the SubagentStop artifact hooks block with that code and the `git worktree repair` remedy, and a removal-gate record whose absolute `worktree_path` names no live registration is matched through its `branch_name`. The hooks do not run the repair.
- Child CI opt-out (issue #1233): both merge gates enforce the `child_ci` `integration_only` stages through the byte-identical helper `enforce-epic-merge-gate-child-ci.ps1` and deny with `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED`; the Python, TypeScript, and PowerShell checkpoint validators select the `local_qc_gate` check under the same key, and both completion-consistency hooks accept `local_qc_gate` in place of `ci_gate`.
````

````Prior
- Restored-host note (#1163): after a worktree is restored or moved to a different host path, run `git worktree repair` so its registration names the current path. Until then the stale registration is `prunable`; `Resolve-AgentTargetWorktree` (`.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`) excludes it, so a branch registered only at the prunable path resolves `TARGET_WORKTREE_NOT_DERIVABLE`, the SubagentStop artifact hooks block with that code and the `git worktree repair` remedy, and a removal-gate record whose absolute `worktree_path` names no live registration is matched through its `branch_name`. The hooks do not run the repair.
````

### Revert Block: scripts/harness-generation/sources/rules/orchestrator-state.json

````Current
        "epic-child-ci-verification-issue-1130",
        "epic-child-ci-opt-out-issue-1233",
````

````Prior
        "epic-child-ci-verification-issue-1130",
````

### Revert Block: .claude/rules/orchestrator-state.md

````Current

## Epic-child CI opt-out (issue #1233)

An epic whose manifest records `child_ci: integration_only` opts its children out of per-child CI; an absent key, `per_child`, and every other value keep the per-child CI verification above. The epic checkpoint copies the key at kickoff, the kickoff prompt carries the separate line `Child CI: integration_only.`, and each child records `child_ci: "integration_only"` at its first checkpoint write and, at S9, a `local_qc_gate` object (`conclusion`, `head_sha`, `evidence_path`, `verified_at`) in place of `ci_gate`. The activation predicate is JSON `epic_mode` true and `child_ci` exactly `integration_only` (ordinal); the merge gate additionally requires `epic_context.integration_branch` to match `^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$`. Under the predicate, `Get-EpicMergeGateChildCiDecision` in `enforce-epic-merge-gate-child-ci.ps1` runs these stages after stage 1 in place of stages 2 to 6, and each failure denies with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: stage <id> (<name>): <detail>` without falling through:

- B (base): one bounded `gh pr view <PR> --json headRefOid,baseRefName`; a failed lookup denies, and a live base that is not exactly the recorded integration branch, or that is `main`, does not apply the opt-out, so stages 2 to 6 decide.
- R (review): `review_mode: "concurrent"`; the review guard runs first under that key, so reaching stage R proves a `PASS` review at a current head.
- L1 (record): `local_qc_gate` is an object whose `conclusion` is exactly `success`, whose `head_sha` is a lowercase 40- or 64-character object id, and whose `evidence_path` is a clean relative path under `<feature-folder>/evidence/qa-gates/` that ends in `.md`.
- L2 (binding): `local_qc_gate.head_sha` equals the `head_sha` of the last `remediation_loop.review_outcomes[]` entry.
- L3 (evidence): one bounded `git cat-file -p <live head>:<evidence_path>` in the item worktree (`-GitRoot`); the first `EXIT_CODE:` line is `0`, and the file holds a `Timestamp:` line and the line `Head: <head_sha>`.

Under `require_complete`, the Python, TypeScript, and PowerShell validators select the `local_qc_gate` check in place of the `ci_gate` check under the predicate and report byte-identical errors, pinned by the corpus `tests/fixtures/orchestrator_state_child_ci/`; both completion-consistency hooks accept `local_qc_gate` in place of `ci_gate` under the same predicate. The integration pull request into `main` still requires a green `CI` run, and a child pull request still starts the automatic `CI` run that `.github/workflows/ci.yml` triggers on `epic/**`; the opt-out removes it as a merge condition only. The reduction is recorded in process-reduction ledger entry 0014.

Honest disclosure: `child_ci` is self-declared by the item checkpoint, and a writer in the same session can set it; like every gate key, this is a policy-level control, not a security control (decision D10). The reduction is bounded by the live base read through `baseRefName`, which never admits a merge into `main`, by the `review_mode: "concurrent"` requirement, and by the evidence file at the live head with its `Head:` line.

````

````Prior
````

### Revert Block: .claude/rules/orchestrator-state.md

````Current
- Restored-host note (#1163): after a worktree is restored or moved to a different host path, run `git worktree repair` so its registration names the current path. Until then the stale registration is `prunable`; `Resolve-AgentTargetWorktree` (`.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`) excludes it, so a branch registered only at the prunable path resolves `TARGET_WORKTREE_NOT_DERIVABLE`, the SubagentStop artifact hooks block with that code and the `git worktree repair` remedy, and a removal-gate record whose absolute `worktree_path` names no live registration is matched through its `branch_name`. The hooks do not run the repair.
- Child CI opt-out (issue #1233): both merge gates enforce the `child_ci` `integration_only` stages through the byte-identical helper `enforce-epic-merge-gate-child-ci.ps1` and deny with `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED`; the Python, TypeScript, and PowerShell checkpoint validators select the `local_qc_gate` check under the same key, and both completion-consistency hooks accept `local_qc_gate` in place of `ci_gate`.
````

````Prior
- Restored-host note (#1163): after a worktree is restored or moved to a different host path, run `git worktree repair` so its registration names the current path. Until then the stale registration is `prunable`; `Resolve-AgentTargetWorktree` (`.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`) excludes it, so a branch registered only at the prunable path resolves `TARGET_WORKTREE_NOT_DERIVABLE`, the SubagentStop artifact hooks block with that code and the `git worktree repair` remedy, and a removal-gate record whose absolute `worktree_path` names no live registration is matched through its `branch_name`. The hooks do not run the repair.
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- Child-CI helper (#1130): `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`, byte-identical to its `.codex/hooks/` twin, is dot-sourced by both `enforce-epic-merge-gate.ps1` gates. Their epic-child branch allows a merge only when `Get-EpicMergeGateChildCiDecision` verifies, through one bounded `gh pr view` and one bounded `gh run list --commit` call, that `ci_gate.head_sha` equals the live PR head and that the newest run of the workflow named `CI` on that head is a completed, successful `pull_request` run or the `workflow_dispatch` run recorded in `ci_gate.dispatch_run_id`. Every other case denies with `EPIC_CHILD_CI_NOT_VERIFIED` after the token `EPIC_MERGE_GATE_BLOCKED`, without falling through to a later branch. The workflow name `CI` is an assumption, and a `push`-event run is not accepted.
- Child-CI opt-out (#1233): when the child checkpoint records JSON `epic_mode` true, `child_ci` exactly `integration_only`, and an `epic_context.integration_branch` matching `^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$`, the same helper runs stages B, R, L1, L2, and L3 in place of stages 2 to 6: one bounded `gh pr view <PR> --json headRefOid,baseRefName` (a live base other than the integration branch, or `main`, falls back to stages 2 to 6), `review_mode: "concurrent"`, a valid `local_qc_gate` bound to the last reviewed head, and one bounded `git cat-file -p <live head>:<evidence_path>` in the directory that `-GitRoot` names (the item worktree on Claude; omitted, it defaults to `-GhRoot`). Every failure denies with `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED` after the token `EPIC_MERGE_GATE_BLOCKED`, without falling through. Both completion-consistency hooks accept `local_qc_gate` in place of `ci_gate` under the same key. It is a policy-level control, not a security control.
````

````Prior
- Child-CI helper (#1130): `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`, byte-identical to its `.codex/hooks/` twin, is dot-sourced by both `enforce-epic-merge-gate.ps1` gates. Their epic-child branch allows a merge only when `Get-EpicMergeGateChildCiDecision` verifies, through one bounded `gh pr view` and one bounded `gh run list --commit` call, that `ci_gate.head_sha` equals the live PR head and that the newest run of the workflow named `CI` on that head is a completed, successful `pull_request` run or the `workflow_dispatch` run recorded in `ci_gate.dispatch_run_id`. Every other case denies with `EPIC_CHILD_CI_NOT_VERIFIED` after the token `EPIC_MERGE_GATE_BLOCKED`, without falling through to a later branch. The workflow name `CI` is an assumption, and a `push`-event run is not accepted.
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- The push-down integration tools (#1051, `detect_push_down_integration` and `validate_push_down_integration`) are read-only and run in the installed extension, so a destination receives both tools, and their validate rules V1 to V5, only after an extension and MCP package release that carries them is installed.
- Child-CI opt-out (#1233): installed MCP applies the `child_ci` `integration_only` completion rule only after the extension release that carries the TypeScript port is installed. Until then a Claude run validates an opted-out child checkpoint through `scripts/dev_tools/validate_orchestration_artifacts.py` in its `orchestrator-state` subcommand with `--require-complete`, and on Codex, whose orchestrator requires the installed MCP validator with no fallback, the opt-out is unavailable.
````

````Prior
- The push-down integration tools (#1051, `detect_push_down_integration` and `validate_push_down_integration`) are read-only and run in the installed extension, so a destination receives both tools, and their validate rules V1 to V5, only after an extension and MCP package release that carries them is installed.
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- Epic-child dispatch (#1130): when an epic child's head has no `CI` check, for example in a destination whose `CI` workflow does not list `epic/**` in its `pull_request` branches, S9 dispatches `CI` once with `gh workflow run CI --ref <child branch>` and records the run's `databaseId` as `ci_gate.dispatch_run_id`; the merge gate accepts that run and no other `workflow_dispatch` run.
- Child-CI opt-out (#1233): under `child_ci: integration_only` S9 does not dispatch `CI` for an epic child head and does not query checks as a gate; the child merges on committed local final-QC evidence, and the integration pull request into `main` still requires a green `CI` run. A child pull request into `epic/**` still starts the automatic `CI` run, which is not a merge condition.
````

````Prior
- Epic-child dispatch (#1130): when an epic child's head has no `CI` check, for example in a destination whose `CI` workflow does not list `epic/**` in its `pull_request` branches, S9 dispatches `CI` once with `gh workflow run CI --ref <child branch>` and records the run's `databaseId` as `ci_gate.dispatch_run_id`; the merge gate accepts that run and no other `workflow_dispatch` run.
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`: the section- and item-scoped regenerate-path text of issue #1156 in the orchestrate, epic-orchestrate, and parallel-orchestrate skills, the orchestrator-state rule, both orchestrator agents, and this brief; the absence of `Invoke-RegenerationPath` from the `.agents` orchestrate and epic-orchestrate skills; and the absence of `config/orchestration-regeneration.json` from the repository and the bundle.
- Child-CI opt-out (#1233): `tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1`: the labeled child CI opt-out units of issue #1233 in the orchestrate, epic-orchestrate, epic-run, and epic-plan skills, the orchestrator-state rule, and this brief, and the `child_ci` key of the epic manifest template, in every copy.
````

````Prior
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`: the section- and item-scoped regenerate-path text of issue #1156 in the orchestrate, epic-orchestrate, and parallel-orchestrate skills, the orchestrator-state rule, both orchestrator agents, and this brief; the absence of `Invoke-RegenerationPath` from the `.agents` orchestrate and epic-orchestrate skills; and the absence of `config/orchestration-regeneration.json` from the repository and the bundle.
````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence in the named file, and delete the files this change created: `tests/fixtures/orchestrator_state_child_ci/` (every file), `extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1`, `tests/scripts/codex-hooks/enforce-completion-helpers.OrdinalKeys.Tests.ps1`, and `tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1`.
2. Re-copy mirrors and bundles: copy `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`; copy `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1` to `.codex/hooks/enforce-epic-merge-gate-child-ci.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-child-ci.ps1`; copy `.claude/hooks/enforce-epic-merge-gate.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` and `.codex/hooks/enforce-epic-merge-gate.ps1` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`; copy `.claude/hooks/enforce-completion-helpers.ps1` to `.codex/hooks/enforce-completion-helpers.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-helpers.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1`; copy `.claude/hooks/enforce-completion-consistency.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-consistency.ps1` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`; copy `.claude/skills/orchestrate/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` and `.agents/skills/orchestrate/SKILL.md` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`; copy `.claude/skills/epic-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` and `.agents/skills/epic-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`; copy `.claude/skills/epic-run/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-run/SKILL.md` and `.agents/skills/epic-run/SKILL.md` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md`; copy `.dev/templates/epic/epic.md` to `extensions/drm-copilot/resources/feature-templates/epic/epic.md`; copy `.agents/skills/epic-plan/SKILL.md` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md` and `.agents/skills/execution-environment/SKILL.md` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`; then run `scripts/harness-generation/Invoke-HarnessGeneration.ps1` to regenerate `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/execution-environment/SKILL.md`, `.claude/rules/orchestrator-state.md`, and their `claude-customizations` bundle copies, and run it again with `-Check`.
3. Regenerate Codex variants: not applicable; run `scripts/dev_tools/generate_codex_agent_variants.py` in module form with `--check` to confirm no variant changed.
4. Restore pinned hashes: the revert block of `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` restores the prior `.claude/skills/epic-orchestrate/SKILL.md` digest in `PINNED_FROZEN_SURFACE_HASHES` and removes the `RE-BASELINED by issue #1233` paragraph; this block is reverted before the hunk of `patches/0010-early-dependent-starts.patch` on the same file.
5. Restore contract-test literals: not applicable.
6. Run the contract tests: `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`, `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`, `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`, `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1`, the push-down resource and pack-manifest contract tests under `tests/scripts/dev_tools/`, and `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`.

## Revert Signals

- An integration pull request into `main` fails `CI` on a defect that a child's own `CI` run would have caught, and the defect is traced to an opted-out child.
