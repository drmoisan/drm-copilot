"""Reject ambiguous or excessive console inputs before any provider activity."""

from __future__ import annotations

from collections.abc import Sequence
from typing import TYPE_CHECKING, NoReturn, cast, overload

import pytest
from drm_copilot_discovery import cli_arguments, gateway_local, service
from drm_copilot_discovery.cli_arguments import (
    CliError,
    CliHelp,
    CliInvocation,
    build_cli_request,
    parse_cli_arguments,
)
from drm_copilot_discovery.cli_commands import command_definition
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject, JsonValue, ParseLimits
from drm_copilot_discovery.report_models import (
    ReportBudget,
    ReportLimitError,
    bounded_object,
)
from drm_copilot_discovery.service_contracts import parse_service_request

from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.service_contracts import Mode, Operation

LIMITS = ParseLimits()


@pytest.mark.parametrize(
    "command,argv",
    (
        ("unknown-secret", ()),
        ("dev.discovery.doctor", ()),
        ("read-source", ()),
        ("prepare-agent", ()),
        ("finalize-agent", ()),
        ("doctor", ("secret-positional",)),
        ("doctor", ("@secret-response-file",)),
        ("doctor", ("--unknown-secret",)),
        ("doctor", ("--work", "secret")),
        ("doctor", ("--workspace-root",)),
        ("doctor", ("--workspace-root=",)),
        ("doctor", ("--workspace-root", "--profile", "secret")),
        ("doctor", ("--workspace-root", "a", "--workspace-root=b")),
        ("doctor", ("--repository-id", "a", "--repository-id", "b")),
        ("doctor", ("--repository-id", "secret/invalid")),
        ("doctor", ("--repository-id", "a" * 129)),
        ("doctor", ("--profile", "one", "--profile", "two")),
        ("doctor", ("--help", "secret")),
        ("doctor", ("--help=true",)),
        ("doctor", ("--dry-run",)),
        ("doctor", ("--write",)),
        ("doctor", ("--mode", "structural")),
        ("doctor", ("--format", "json")),
        ("inventory", ("--analyzer", "repository", "--analyzer", "repository")),
        ("inventory", ("--write=true",)),
        ("inventory", ("--write", "--write")),
        ("dotnet", ("--analyzer", "repository")),
        ("vsto", ("--analyzer", "repository")),
        ("configure", ("--activate", "--deactivate")),
        ("configure", ("--activate",)),
        ("configure", ("--deactivate", "--input", "secret.json")),
        ("profile", ("--input", "a.json", "--profile", "b.json")),
        ("validate", ("secret.json",)),
        ("validate-all", ("--mode", "agent-output")),
        ("validate-all", ("--mode", "secret")),
        ("validate-all", ("--format", "secret")),
        ("validate-all", ("--write",)),
        ("new-contract", ()),
        ("new-scenario", ("--scenario-id", "scenario")),
        ("snapshot-export", ()),
        ("generate-acceptance", ("--kind", "secret")),
        (
            "generate-acceptance",
            ("--kind", "target-acceptance", "--output-format", "secret"),
        ),
        ("migrate", ("--from-version", "3")),
        ("migrate", ("--to-version", "1")),
        ("init", ("--role", "secret")),
    ),
)
def test_unsupported_ambiguous_or_incomplete_arguments_are_redacted(
    command: str, argv: tuple[str, ...]
) -> None:
    """Reject command (str)/argv (str tuple) with fixed findings; return None.

    Assertions cover syntax/combination errors only. No graph, path, provider or
    filesystem operation is executed, and untrusted snippets never enter errors.
    """
    result = parse_cli_arguments(command, argv, limits=LIMITS)
    assert isinstance(result, CliError), result
    assert len(result.findings) == 1 and result.findings[0].code == "CLI_ARGUMENTS"
    assert "secret" not in str(result)
    assert result.findings[0].next_action.startswith("Use --help")


class CountedArguments(Sequence[str]):
    """Expose a finite observable sequence for deterministic prepaid-work tests.

    count/value define immutable virtual contents; reads counts indexed access.
    No iterator allocation, filesystem or other collaborator exists. Each test
    creates its own instance and verifies bounds before the first retained token.
    """

    def __init__(self, count: int, value: str) -> None:
        """Retain count (int)/value (str), reset reads; return None without I/O."""
        self.size, self.value, self.reads = count, value, 0

    def __len__(self) -> int:
        """Return declared count (int); no inputs, mutation or external effects."""
        return self.size

    @overload
    def __getitem__(self, index: int) -> str:
        """Describe indexed str access for index (int); no independent execution."""
        ...

    @overload
    def __getitem__(self, index: slice) -> Sequence[str]:
        """Describe unsupported slice input; implementation raises without I/O."""
        ...

    def __getitem__(self, index: int | slice) -> str | Sequence[str]:
        """Count int index access; return str or raise IndexError for invalid input.

        slice input is deliberately unsupported. Only the test-local counter
        changes; no external effects or mutable source content is returned.
        """
        if not isinstance(index, int) or not 0 <= index < self.size:
            raise IndexError("No such argument")
        self.reads += 1
        return self.value


def test_argument_count_reservation_precedes_any_sequence_access() -> None:
    """Reject oversized sequence before indexing; return None, counted memory seam."""
    args = CountedArguments(3, "secret")
    result = parse_cli_arguments("doctor", args, limits=ParseLimits(artifact_records=2))
    assert isinstance(result, CliError) and result.findings[0].code == "CLI_LIMIT"
    assert args.reads == 0


def test_character_work_reservation_precedes_token_retention() -> None:
    """Reject excessive character work after one read; return None without scans."""
    args = CountedArguments(1, "secret" * 100)
    result = parse_cli_arguments("doctor", args, limits=ParseLimits(artifact_records=1))
    assert isinstance(result, CliError) and result.findings[0].code == "CLI_LIMIT"
    assert args.reads == 1 and "secret" not in str(result)


@pytest.mark.parametrize("value", ("é" * 10, "\U0001f680" * 6, "\x01" * 5))
def test_encoded_and_escaped_bytes_are_charged_before_retention(value: str) -> None:
    """Bound value (str) by UTF-8/JSON bytes, not characters; return None, no I/O."""
    result = parse_cli_arguments(
        "doctor", (value,), limits=ParseLimits(document_bytes=20)
    )
    assert isinstance(result, CliError) and result.findings[0].code == "CLI_LIMIT"


@pytest.mark.parametrize("argv", ("--help", b"--help", (1,), ("\ud800",)))
def test_bad_argument_containers_types_and_unicode_fail_closed(argv: object) -> None:
    """Reject malformed argv (object) without coercion; return None, pure boundary."""
    result = parse_cli_arguments("doctor", cast("Sequence[str]", argv), limits=LIMITS)
    assert isinstance(result, CliError) and result.findings[0].code == "CLI_ARGUMENTS"


@pytest.mark.parametrize("limits", (None, True, {}, 1))
def test_policy_requires_the_exact_validated_limits_type(limits: object) -> None:
    """Reject limits (object) before help or copies; return None without providers."""
    result = parse_cli_arguments(
        "doctor", ("--help",), limits=cast("ParseLimits", limits)
    )
    assert isinstance(result, CliError)


def test_limits_are_revalidated_and_help_reserves_output_capacity() -> None:
    """Reject corrupted policy and bounded help overflow; return None, no I/O."""
    limits = ParseLimits()
    object.__setattr__(limits, "document_bytes", True)
    result = parse_cli_arguments("doctor", (), limits=limits)
    assert isinstance(result, CliError)
    bounded = parse_cli_arguments(
        "doctor", ("--help",), limits=ParseLimits(document_bytes=20)
    )
    assert isinstance(bounded, CliError) and bounded.findings[0].code == "CLI_LIMIT"


def test_help_and_argument_errors_never_construct_or_execute_providers(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Trap providers with monkeypatch (pytest.MonkeyPatch); return None, no I/O."""
    calls: list[str] = []

    def forbidden(*args: object, **kwargs: object) -> NoReturn:
        """Reject args (object tuple)/kwargs (object dict); never return or do I/O."""
        calls.append("provider")
        raise AssertionError("Pure parser must not construct providers")

    monkeypatch.setattr(gateway_local, "installed_local_io", forbidden)
    monkeypatch.setattr(service, "execute", forbidden)
    assert isinstance(
        parse_cli_arguments("doctor", ("--help",), limits=LIMITS), CliHelp
    )
    assert isinstance(
        parse_cli_arguments("doctor", ("--bad",), limits=LIMITS), CliError
    )
    assert calls == []


def test_direct_carrier_and_builder_misuse_is_rejected() -> None:
    """Reject malformed direct data without schema/provider effects; return None."""
    with pytest.raises(ValueError):
        CliInvocation(request=cast("JsonObject", {}), repository_id=None)
    with pytest.raises(ValueError):
        CliInvocation(request=JsonObject(()), repository_id=cast("str", 1))
    with pytest.raises(ValueError):
        CliHelp(text="")
    with pytest.raises(ValueError):
        CliHelp(text="\ud800")
    with pytest.raises(ValueError):
        CliError(operation=None, mode=None, findings=())
    parsed = parse_cli_arguments("doctor", (), limits=LIMITS)
    assert isinstance(parsed, CliInvocation)
    with pytest.raises(ValueError):
        build_cli_request(
            cast("CliInvocation", None), workspace_root="C:/work", limits=LIMITS
        )
    with pytest.raises(ValueError):
        build_cli_request(parsed, workspace_root="", limits=LIMITS)
    with pytest.raises(ValueError):
        build_cli_request(
            CliInvocation(request=JsonObject(()), repository_id=None),
            workspace_root="C:/work",
            limits=LIMITS,
        )
    with pytest.raises(ReportLimitError):
        build_cli_request(
            parsed, workspace_root="C:/work", limits=ParseLimits(document_bytes=10)
        )


def test_unknown_context_and_metadata_refusal_preserve_safe_values() -> None:
    """Normalize direct unknown enum context and fixed lookup; return None, no I/O."""
    failure = CliError(
        operation=cast("Operation", "secret"),
        mode=cast("Mode", "secret"),
        findings=(
            Finding(code="CLI_ARGUMENTS", message="Invalid", next_action="Use help"),
        ),
    )
    assert failure.operation is None and failure.mode is None
    assert command_definition(cast("str", None)) is None
    assert command_definition("x" * 1000) is None


def test_builder_reuses_public_combination_checks_for_direct_invocations() -> None:
    """Reject a manually altered command combination; return None without I/O."""
    parsed = parse_cli_arguments("doctor", (), limits=LIMITS)
    assert isinstance(parsed, CliInvocation)
    fields = dict(parsed.request.members)
    fields["write"] = True
    changed = CliInvocation(
        request=bounded_object(fields, limits=LIMITS), repository_id=None
    )
    with pytest.raises(ValueError):
        build_cli_request(changed, workspace_root="C:/work", limits=LIMITS)


@pytest.mark.parametrize("placement", ("root", "nested"))
def test_builder_reserves_direct_text_before_measurement(
    placement: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject excessive direct text before measurement/copy/encoding; return None.

    placement (str) selects retained root or nested non-root input, while
    monkeypatch (pytest.MonkeyPatch) counts public budget and serialization seams.
    Counts are deterministic; no timing, filesystem or provider calls occur.
    """
    parsed = parse_cli_arguments(
        "new-contract", ("--feature-id", "feature", "--name", "Feature"), limits=LIMITS
    )
    assert isinstance(parsed, CliInvocation)
    fields = dict(parsed.request.members)
    long_text = "x" * 1024
    if placement == "root":
        fields["workspace_root"] = long_text
    else:
        fields["inputs"] = bounded_object(
            {"feature_id": "feature", "name": long_text}, limits=LIMITS
        )
    invocation = CliInvocation(
        request=bounded_object(fields, limits=LIMITS), repository_id=None
    )
    measured: list[int] = []
    encoded: list[str] = []
    reservations: list[int] = []
    real_text, real_work = ReportBudget.text, ReportBudget.work

    def measure(budget: ReportBudget, value: str) -> None:
        """Count value (str) scan in budget (ReportBudget); return None or limit error.

        Delegate accepted measurement; only test-local counters change, no I/O.
        """
        measured.append(len(value))
        real_text(budget, value)

    def reserve(budget: ReportBudget, count: int) -> None:
        """Record count (int) reservation on budget (ReportBudget).

        Return None or propagate the original budget error.

        Only accepted work and test-local counters change; no scans or I/O.
        """
        real_work(budget, count)
        reservations.append(count)

    def encode(value: JsonValue) -> NoReturn:
        """Reject value (JsonValue) encoding with AssertionError; no return or I/O."""
        encoded.append("encode")
        raise AssertionError("Exhausted direct input must not reach encoding")

    monkeypatch.setattr(ReportBudget, "text", measure)
    monkeypatch.setattr(ReportBudget, "work", reserve)
    monkeypatch.setattr(cli_arguments, "canonical_json", encode)
    with pytest.raises(ReportLimitError):
        build_cli_request(
            invocation, workspace_root="C:/work", limits=ParseLimits(artifact_records=2)
        )
    assert measured == [] and encoded == []
    assert reservations and sum(reservations) <= 128


def test_adequate_direct_builder_keeps_identity_and_public_schema(
    initialization_catalog: SchemaCatalog,
) -> None:
    """Validate direct-builder identity with trusted SchemaCatalog; return None.

    Adequate capacity preserves root substitution, immutable fields and exact
    public request validation. No graph/provider execution or external I/O.
    """
    parsed = parse_cli_arguments("doctor", (), limits=LIMITS)
    assert isinstance(parsed, CliInvocation)
    fields = dict(parsed.request.members)
    fields["workspace_root"] = "retained-" + "x" * 1024
    direct = CliInvocation(
        request=bounded_object(fields, limits=LIMITS), repository_id=None
    )
    document = build_cli_request(direct, workspace_root="C:/work", limits=LIMITS)
    assert document == build_cli_request(
        parsed, workspace_root="C:/work", limits=LIMITS
    )
    checked = parse_service_request(
        document, catalog=initialization_catalog, limits=LIMITS
    )
    assert checked.operation == "doctor" and checked.workspace_root == "C:/work"
    assert checked.id == checked.request_id and checked.id.startswith("cli-")
    assert checked.invocation_ref is None and checked.authorization_ref is None
    assert direct.request["workspace_root"] == fields["workspace_root"]
    with pytest.raises(ReportLimitError):
        build_cli_request(
            direct, workspace_root="C:/work", limits=ParseLimits(nesting_depth=1)
        )
