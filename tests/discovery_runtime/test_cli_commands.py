"""Verify all fixed console mappings through public bounded request construction."""

from __future__ import annotations

from dataclasses import FrozenInstanceError
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.cli_arguments import (
    CliHelp,
    CliInvocation,
    build_cli_request,
    parse_cli_arguments,
)
from drm_copilot_discovery.cli_commands import COMMANDS
from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.service_contracts import parse_service_request

from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog

LIMITS = ParseLimits()
INIT = (
    "--system-id",
    "system",
    "--system-name",
    "Example",
    "--role",
    "combined",
    "--repository-id",
    "repo",
    "--production-root",
    "application",
)
CASES = (
    ("init", "init", INIT),
    ("configure", "configure", ("--deactivate",)),
    ("profile", "profile", ()),
    ("inventory", "inventory", ()),
    ("dotnet", "inventory", ()),
    ("vsto", "inventory", ()),
    ("new-contract", "new-contract", ("--feature-id", "feature", "--name", "Feature")),
    (
        "new-scenario",
        "new-scenario",
        (
            "--scenario-id",
            "scenario",
            "--feature-id",
            "feature",
            "--input",
            "proposal.json",
        ),
    ),
    (
        "update-artifact",
        "update-artifact",
        (
            "--kind",
            "feature-contract",
            "--path",
            "contracts/f.json",
            "--input",
            "proposal.json",
            "--expected-sha256",
            "a" * 64,
        ),
    ),
    (
        "link-evidence",
        "link-evidence",
        (
            "--artifact-kind",
            "feature-contract",
            "--artifact-id",
            "feature",
            "--evidence",
            "evidence/e.json",
            "--expected-sha256",
            "a" * 64,
        ),
    ),
    ("validate-profile", "validate-profile", ()),
    (
        "validate-feature-contract",
        "validate-feature-contract",
        ("--artifact", "contracts/f.json"),
    ),
    (
        "validate-coverage-ledger",
        "validate-coverage-ledger",
        ("--artifact", "ledger.json"),
    ),
    (
        "validate-runtime-scenario",
        "validate-runtime-scenario",
        ("--artifact", "scenarios/s.json"),
    ),
    ("validate-parity-matrix", "validate-parity-matrix", ("--artifact", "parity.json")),
    (
        "validate-unspecified-behavior",
        "validate-unspecified-behavior",
        ("--artifact", "unknown.json"),
    ),
    (
        "validate-product-decision",
        "validate-product-decision",
        ("--artifact", "decisions.json"),
    ),
    (
        "validate-evidence-reference",
        "validate-evidence-reference",
        ("--artifact", "evidence/e.json"),
    ),
    ("validate-decisions", "validate-decisions", ()),
    ("validate-all", "validate-all", ()),
    ("validate", "validate-all", ()),
    ("coverage-report", "coverage-report", ()),
    ("parity-report", "parity-report", ()),
    ("completion-report", "completion-report", ()),
    ("generate-acceptance", "generate-acceptance", ("--kind", "target-acceptance")),
    (
        "generate-acceptance-scenarios",
        "generate-acceptance",
        ("--kind", "target-acceptance"),
    ),
    ("snapshot-export", "snapshot-export", ("--selected-id", "feature")),
    ("snapshot-import", "snapshot-import", ("--manifest", "snapshot/manifest.json")),
    ("import-inventory", "import-inventory", ("--manifest", "analyzers/manifest.json")),
    (
        "migrate",
        "migrate",
        INIT
        + (
            "--from-version",
            "1",
            "--to-version",
            "2",
            "--destination",
            "migration",
            "--input",
            "legacy.json",
        ),
    ),
    ("doctor", "doctor", ()),
)


@pytest.mark.parametrize("name,operation,argv", CASES)
def test_all_fixed_commands_build_schema_valid_closed_requests(
    name: str,
    operation: str,
    argv: tuple[str, ...],
    initialization_catalog: SchemaCatalog,
) -> None:
    """Map name/operation (str), argv (str tuple) using trusted SchemaCatalog.

    Return None; public service parsing must accept each exact request shape.
    No workspace/provider/graph operation or mutation is executed.
    """
    parsed = parse_cli_arguments(name, argv, limits=LIMITS)
    assert isinstance(parsed, CliInvocation), parsed
    assert parsed.request["workspace_root"] == "."
    document = build_cli_request(parsed, workspace_root="C:/workspace", limits=LIMITS)
    request = parse_service_request(
        document, catalog=initialization_catalog, limits=LIMITS
    )
    assert request.operation == operation and request.mode == "structural"
    assert request.workspace_root == "C:/workspace"
    assert request.invocation_ref is None and request.authorization_ref is None
    assert request.id == request.request_id and request.id.startswith("cli-")
    assert request.write is False and request.dry_run is False
    assert set(document) == {
        "$schema",
        "schema_version",
        "artifact_kind",
        "id",
        "request_id",
        "operation",
        "mode",
        "workspace_root",
        "profile_path",
        "dry_run",
        "write",
        "format",
        "inputs",
        "invocation_ref",
        "authorization_ref",
    }


def test_exact_command_population_and_alias_semantics() -> None:
    """Assert 31 names, 27 operations and four aliases; return None, no I/O."""
    # Compare independent expected declarations, not generated console registration.
    assert {item.name for item in COMMANDS} == {case[0] for case in CASES}
    assert len(COMMANDS) == 31 and len({case[1] for case in CASES}) == 27
    # Aliases retain fixed selectors or exactly the canonical request identity.
    for name, expected in (("dotnet", "dotnet"), ("vsto", "office-vsto")):
        parsed = parse_cli_arguments(name, (), limits=LIMITS)
        assert isinstance(parsed, CliInvocation)
        assert parsed.request["inputs"] == bounded_object(
            {"analyzer_ids": (expected,)}, limits=LIMITS
        )
    # Equivalent aliases must not create a separate canonical request identity.
    for name, canonical, argv in (
        ("validate", "validate-all", ()),
        (
            "generate-acceptance-scenarios",
            "generate-acceptance",
            ("--kind", "target-acceptance"),
        ),
    ):
        assert parse_cli_arguments(name, argv, limits=LIMITS) == parse_cli_arguments(
            canonical, argv, limits=LIMITS
        )


@pytest.mark.parametrize("name", ("init", "inventory", "validate-all", "doctor"))
def test_help_is_fixed_and_does_not_require_operation_inputs(name: str) -> None:
    """Render fixed help for name (str); return None without providers or I/O."""
    first = parse_cli_arguments(name, ("--help",), limits=LIMITS)
    assert isinstance(first, CliHelp)
    assert first == parse_cli_arguments(name, ("-h",), limits=LIMITS)
    assert first.text.startswith(f"Usage: dev.discovery.{name} ")
    assert first.text.endswith("\n") and "--workspace-root" in first.text
    with pytest.raises(FrozenInstanceError):
        first.__setattr__("text", "changed")


def test_reordered_selection_and_option_spelling_preserve_identity() -> None:
    """Normalize equivalent syntax before IDs; return None, all transforms pure."""
    first = parse_cli_arguments(
        "inventory",
        (
            "--analyzer",
            "dotnet",
            "--analyzer",
            "repository",
            "--workspace-root",
            "relative",
        ),
        limits=LIMITS,
    )
    second = parse_cli_arguments(
        "inventory",
        ("--workspace-root=other", "--analyzer=repository", "--analyzer=dotnet"),
        limits=LIMITS,
    )
    assert isinstance(first, CliInvocation) and isinstance(second, CliInvocation)
    assert first.request["workspace_root"] == "relative"
    one = build_cli_request(first, workspace_root="C:/actual", limits=LIMITS)
    two = build_cli_request(second, workspace_root="C:/actual", limits=LIMITS)
    assert canonical_json(one) == canonical_json(two)
    assert (
        one["id"]
        != build_cli_request(first, workspace_root="C:/other", limits=LIMITS)["id"]
    )
    with pytest.raises(FrozenInstanceError):
        first.__setattr__("repository_id", "replacement")


def test_repository_binding_is_outer_data_except_explicit_service_inputs() -> None:
    """Keep repository provider data separate; return None without constructing it."""
    parsed = parse_cli_arguments("doctor", ("--repository-id", "repo"), limits=LIMITS)
    assert isinstance(parsed, CliInvocation)
    assert parsed.repository_id == "repo" and parsed.request[
        "inputs"
    ] == bounded_object({}, limits=LIMITS)
    generation = parse_cli_arguments(
        "generate-acceptance",
        (
            "--kind",
            "target-acceptance",
            "--repository-id",
            "source",
            "--client-id",
            "desktop",
            "--feature-id",
            "feature",
            "--mode-id",
            "offline",
            "--platform-id",
            "windows",
            "--output-format",
            "gherkin",
            "--write",
            "--dry-run",
        ),
        limits=LIMITS,
    )
    assert isinstance(generation, CliInvocation)
    assert generation.request["inputs"] == bounded_object(
        {
            "acceptance_kind": "target-acceptance",
            "repository_id": "source",
            "client_ids": ("desktop",),
            "feature_ids": ("feature",),
            "mode_ids": ("offline",),
            "platform_ids": ("windows",),
            "output_format": "gherkin",
        },
        limits=LIMITS,
    )
    assert generation.request["dry_run"] is True and generation.request["write"] is True


@pytest.mark.parametrize(
    "mode", ("structural", "discovery-complete", "parity-complete", "planning")
)
def test_report_mode_format_and_publication_flags_remain_explicit(mode: str) -> None:
    """Preserve mode (str), format and planning flags; return None with no effects."""
    result = parse_cli_arguments(
        "completion-report",
        (
            "--mode",
            mode,
            "--format",
            "both",
            "--write",
            "--dry-run",
        ),
        limits=LIMITS,
    )
    assert isinstance(result, CliInvocation)
    assert result.request["mode"] == mode and result.request["format"] == "both"
    assert result.request["write"] is True and result.request["dry_run"] is True


def test_optional_fields_switches_and_literal_paths_are_retained() -> None:
    """Keep explicit optional syntax as data; return None without path inspection."""
    activate = parse_cli_arguments(
        "configure", ("--activate", "--profile", "custom.yaml"), limits=LIMITS
    )
    draft = parse_cli_arguments(
        "init", INIT[:-2] + ("--draft", "--test-root", "verification"), limits=LIMITS
    )
    contract = parse_cli_arguments(
        "new-contract",
        (
            "--feature-id",
            "feature",
            "--name",
            "Feature",
            "--capability-group",
            "group",
            "--input",
            "@literal.json",
        ),
        limits=LIMITS,
    )
    assert isinstance(activate, CliInvocation) and isinstance(draft, CliInvocation)
    assert isinstance(contract, CliInvocation)
    assert activate.request["inputs"] == bounded_object(
        {"configuration_action": "activate"}, limits=LIMITS
    )
    assert contract.request["inputs"] == bounded_object(
        {
            "feature_id": "feature",
            "name": "Feature",
            "capability_group": "group",
            "input_path": "@literal.json",
        },
        limits=LIMITS,
    )
    inputs = draft.request["inputs"]
    assert isinstance(inputs, JsonObject)
    assert inputs["draft"] is True
