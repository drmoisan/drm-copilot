"""Declare fixed console syntax independently from service authority or dispatch."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal

if TYPE_CHECKING:
    from drm_copilot_discovery.service_contracts import Operation


@dataclass(frozen=True)
class CliOption:
    """Describe trusted syntax consumed by the pure parser; never select code.

    flag/key map a console token to a fixed request field. kind controls value
    arity, choices constrain console spelling, and constant supplies switch data.
    Instances are module-owned immutable declarations, not configuration input.
    Parsing copies no authority; construction and use perform no I/O.
    """

    flag: str
    key: str
    kind: Literal["text", "repeat", "integer", "switch"] = "text"
    choices: tuple[str, ...] = ()
    constant: str | bool | None = None


@dataclass(frozen=True)
class CliCommand:
    """Bind a fixed console spelling to operation syntax and constant inputs.

    Parser lookup returns these immutable values. Aliases share canonical
    operations while explicit defaults retain their selector distinction.
    options/defaults describe data only; no module loading, execution or I/O.
    """

    name: str
    operation: Operation
    options: tuple[CliOption, ...] = ()
    defaults: tuple[tuple[str, str | tuple[str, ...]], ...] = ()


COMMON_OPTIONS = (
    CliOption("--workspace-root", "workspace_root"),
    CliOption("--profile", "profile_path"),
    CliOption("--repository-id", "repository_id"),
)
ROOT_OPTIONS = (
    CliOption(
        "--mode",
        "mode",
        choices=("structural", "discovery-complete", "parity-complete", "planning"),
    ),
    CliOption("--format", "format", choices=("json", "markdown", "both")),
)
INIT_OPTIONS = (
    CliOption("--system-id", "system_id"),
    CliOption("--system-name", "system_name"),
    CliOption(
        "--role",
        "system_role",
        choices=("legacy-source", "modernization-target", "combined"),
    ),
    CliOption("--production-root", "production_roots", "repeat"),
    CliOption("--test-root", "test_roots", "repeat"),
    CliOption("--draft", "draft", "switch", constant=True),
)
GENERATION_OPTIONS = (
    CliOption(
        "--kind",
        "acceptance_kind",
        choices=("legacy-characterization", "target-acceptance"),
    ),
    CliOption("--feature-id", "feature_ids", "repeat"),
    CliOption("--client-id", "client_ids", "repeat"),
    CliOption("--mode-id", "mode_ids", "repeat"),
    CliOption("--platform-id", "platform_ids", "repeat"),
    CliOption(
        "--output-format", "output_format", choices=("markdown", "gherkin", "both")
    ),
)
INPUT = (CliOption("--input", "input_path"),)
ARTIFACT = (CliOption("--artifact", "artifact_path"),)
MANIFEST = (CliOption("--manifest", "manifest_path"),)
VALIDATE_OPTIONS = ROOT_OPTIONS + (CliOption("--output-prefix", "output_prefix"),)
COMMANDS = (
    CliCommand("init", "init", INIT_OPTIONS),
    CliCommand(
        "configure",
        "configure",
        INPUT
        + (
            CliOption(
                "--activate", "configuration_action", "switch", constant="activate"
            ),
            CliOption(
                "--deactivate", "configuration_action", "switch", constant="deactivate"
            ),
        ),
    ),
    CliCommand("profile", "profile", INPUT),
    CliCommand(
        "inventory", "inventory", (CliOption("--analyzer", "analyzer_ids", "repeat"),)
    ),
    CliCommand("dotnet", "inventory", defaults=(("analyzer_ids", ("dotnet",)),)),
    CliCommand("vsto", "inventory", defaults=(("analyzer_ids", ("office-vsto",)),)),
    CliCommand(
        "new-contract",
        "new-contract",
        INPUT
        + (
            CliOption("--feature-id", "feature_id"),
            CliOption("--name", "name"),
            CliOption("--capability-group", "capability_group"),
        ),
    ),
    CliCommand(
        "new-scenario",
        "new-scenario",
        INPUT
        + (
            CliOption("--scenario-id", "scenario_id"),
            CliOption("--feature-id", "feature_ids", "repeat"),
        ),
    ),
    CliCommand(
        "update-artifact",
        "update-artifact",
        INPUT
        + (
            CliOption("--kind", "artifact_kind"),
            CliOption("--path", "artifact_path"),
            CliOption("--expected-sha256", "expected_sha256"),
        ),
        (("update_action", "replace"),),
    ),
    CliCommand(
        "link-evidence",
        "link-evidence",
        (
            CliOption("--artifact-kind", "artifact_kind"),
            CliOption("--artifact-id", "artifact_id"),
            CliOption("--evidence", "evidence_path"),
            CliOption("--expected-sha256", "expected_sha256"),
        ),
    ),
    CliCommand("validate-profile", "validate-profile", INPUT),
    CliCommand("validate-feature-contract", "validate-feature-contract", ARTIFACT),
    CliCommand("validate-coverage-ledger", "validate-coverage-ledger", ARTIFACT),
    CliCommand("validate-runtime-scenario", "validate-runtime-scenario", ARTIFACT),
    CliCommand("validate-parity-matrix", "validate-parity-matrix", ARTIFACT),
    CliCommand(
        "validate-unspecified-behavior", "validate-unspecified-behavior", ARTIFACT
    ),
    CliCommand("validate-product-decision", "validate-product-decision", ARTIFACT),
    CliCommand("validate-evidence-reference", "validate-evidence-reference", ARTIFACT),
    CliCommand("validate-decisions", "validate-decisions"),
    CliCommand("validate-all", "validate-all", VALIDATE_OPTIONS),
    CliCommand("validate", "validate-all", VALIDATE_OPTIONS),
    CliCommand("coverage-report", "coverage-report", ROOT_OPTIONS),
    CliCommand("parity-report", "parity-report", ROOT_OPTIONS),
    CliCommand("completion-report", "completion-report", ROOT_OPTIONS),
    CliCommand("generate-acceptance", "generate-acceptance", GENERATION_OPTIONS),
    CliCommand(
        "generate-acceptance-scenarios", "generate-acceptance", GENERATION_OPTIONS
    ),
    CliCommand(
        "snapshot-export",
        "snapshot-export",
        (
            CliOption("--selected-id", "selected_ids", "repeat"),
            CliOption("--path", "paths", "repeat"),
        ),
    ),
    CliCommand("snapshot-import", "snapshot-import", MANIFEST),
    CliCommand("import-inventory", "import-inventory", MANIFEST),
    CliCommand(
        "migrate",
        "migrate",
        INIT_OPTIONS
        + INPUT
        + (
            CliOption("--from-version", "from_version", "integer", ("1",)),
            CliOption("--to-version", "to_version", "integer", ("2",)),
            CliOption("--destination", "destination"),
            CliOption("--path", "paths", "repeat"),
        ),
    ),
    CliCommand("doctor", "doctor"),
)
OPTIONAL_WRITES = (
    "inventory",
    "import-inventory",
    "generate-acceptance",
    "coverage-report",
    "parity-report",
    "completion-report",
)
INTRINSIC_WRITES = (
    "init",
    "configure",
    "new-contract",
    "new-scenario",
    "update-artifact",
    "link-evidence",
    "snapshot-export",
    "snapshot-import",
    "migrate",
    "validate-all",
)


def command_definition(name: str) -> CliCommand | None:
    """Return fixed CliCommand for name (exact str), or None for unknown syntax.

    Reject oversized or collaborator-defined string equality before lookup.
    Scan only 31 fixed names; no configuration, imports or I/O are selected.
    """
    if type(name) is not str or not 1 <= len(name) <= 31:
        return None
    # Fixed declaration order has no plugin or user-dependent dispatch semantics.
    for command in COMMANDS:
        if command.name == name:
            return command
    return None


def command_options(command: CliCommand) -> tuple[CliOption, ...]:
    """Return immutable console options for trusted command (CliCommand).

    Add only the fixed publication flags appropriate to its operation. This
    syntactic map grants no mutation; service rules retain semantic validation.
    No I/O or mutation occurs; callers pass module-owned definitions.
    """
    options = COMMON_OPTIONS + command.options
    if command.operation in OPTIONAL_WRITES:
        options += (CliOption("--write", "write", "switch", constant=True),)
    if command.operation in OPTIONAL_WRITES + INTRINSIC_WRITES:
        options += (CliOption("--dry-run", "dry_run", "switch", constant=True),)
    return options
