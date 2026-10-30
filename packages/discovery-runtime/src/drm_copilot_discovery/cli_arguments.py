"""Parse fixed console syntax into bounded immutable data without provider I/O."""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
from hashlib import sha256
from typing import cast

from drm_copilot_discovery.cli_commands import (
    CliCommand,
    command_definition,
    command_options,
)
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import (
    JsonObject,
    JsonValue,
    ParseLimits,
    canonical_json,
)
from drm_copilot_discovery.report_models import (
    ReportBudget,
    ReportLimitError,
    bounded_object,
)
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.service_contracts import (
    Mode,
    Operation,
    OutputFormat,
    ServiceRequest,
    ServiceRequestError,
)

_FIELDS = frozenset(
    (
        "operation",
        "mode",
        "workspace_root",
        "profile_path",
        "dry_run",
        "write",
        "format",
        "inputs",
    )
)
_ROOT_OPTIONS = frozenset(
    ("workspace_root", "profile_path", "dry_run", "write", "mode", "format")
)


@dataclass(frozen=True, kw_only=True)
class CliInvocation:
    """Retain pre-identity request fields and a separate outer repository binding.

    request is immutable JsonObject; repository_id is str or None and never a
    host credential. The composition resolves request.workspace_root, then calls
    build_cli_request. Direct construction checks carrier shape only; the builder
    rechecks bounded fields. No authority, filesystem lookup or I/O occurs.
    """

    request: JsonObject
    repository_id: str | None

    def __post_init__(self) -> None:
        """Check stored types; return None or raise ValueError without I/O."""
        if type(self.request) is not JsonObject or (
            self.repository_id is not None and type(self.repository_id) is not str
        ):
            raise ValueError("CLI invocation requires immutable request data")
        if self.repository_id is not None:
            if not 1 <= len(self.repository_id) <= 128:
                raise ValueError("CLI repository identity is invalid")
            RepositoryIdentity(id=self.repository_id, revision=None)


@dataclass(frozen=True, kw_only=True)
class CliHelp:
    """Carry fixed usage text for immediate output without provider construction.

    text is str supplied by the fixed command declarations. Construction checks
    its finite carrier size; consumers print it and return zero. No I/O occurs.
    """

    text: str

    def __post_init__(self) -> None:
        """Check stored text; return None or raise ValueError without I/O."""
        if type(self.text) is not str or not 1 <= len(self.text) <= 4096:
            raise ValueError("CLI help requires bounded fixed text")
        self.text.encode("utf-8")


@dataclass(frozen=True, kw_only=True)
class CliError:
    """Carry safe argument findings and recognized context without authority.

    operation/mode are known service enums or None. findings retain immutable
    actionable errors through the existing service error contract. Composition
    can report exit two without provider creation. No input snippets or I/O.
    """

    operation: Operation | None
    mode: Mode | None
    findings: tuple[Finding, ...]

    def __post_init__(self) -> None:
        """Normalize stored findings/context; return None or raise ValueError.

        Reuse ServiceRequestError validation without executing or mutating input.
        """
        error = ServiceRequestError(
            self.findings, operation=self.operation, mode=self.mode
        )
        object.__setattr__(self, "operation", error.operation)
        object.__setattr__(self, "mode", error.mode)
        object.__setattr__(self, "findings", error.findings)


def _budget(limits: ParseLimits) -> ReportBudget:
    """Revalidate limits (exact ParseLimits); return a fresh ReportBudget.

    Validate every policy field, including finding capacity, before input work.
    Raise ValueError on malformed policy; no input mutation or I/O occurs.
    """
    if type(limits) is not ParseLimits:
        raise ValueError("CLI policy requires ParseLimits")
    checked = ParseLimits(
        document_bytes=limits.document_bytes,
        nesting_depth=limits.nesting_depth,
        artifact_records=limits.artifact_records,
        findings=limits.findings,
    )
    return ReportBudget(checked)


def _tokens(argv: Sequence[str], budget: ReportBudget) -> list[str]:
    """Capture argv (Sequence[str]) once under budget (ReportBudget); return list[str].

    Reserve argument count before indexing and eight work visits per character
    before scanning, splitting or hashing. JSON-string byte accounting includes
    UTF-8 and escaping before retention. Raise ValueError/ReportLimitError on
    malformed or excessive input; mutate only local counters, never perform I/O.
    """
    if not isinstance(cast("object", argv), Sequence) or isinstance(argv, (str, bytes)):
        raise ValueError("CLI arguments require a sequence")
    count = len(argv)
    if count > budget.limits.artifact_records:
        raise ReportLimitError()
    budget.work(3 * count)
    result: list[str] = []
    # Bound each captured token before retaining it; never reread mutable argv.
    for index in range(count):
        token = argv[index]
        if type(token) is not str:
            raise ValueError("CLI arguments require exact text")
        budget.work(8 * len(token))
        budget.text(token)
        result.append(token)
    return result


def _help(command: CliCommand, budget: ReportBudget) -> CliHelp:
    """Render fixed usage for command (CliCommand) under budget (ReportBudget).

    Return CliHelp after prospective static-text reservation. Raise
    ReportLimitError on capacity; no user values, provider calls or I/O.
    """
    options = command_options(command)
    size = 80 + len(command.name)
    # Account for all fixed flags before constructing the help string.
    for option in options:
        size += len(option.flag) + 1
    budget.work(size)
    budget.spend(size)
    # Fixed declarations alone determine help; untrusted arguments never appear.
    flags = " ".join(option.flag for option in options)
    return CliHelp(
        text=(
            f"Usage: dev.discovery.{command.name} [options]\n"
            f"Options: --help -h {flags}\n"
        )
    )


def _fields(
    command: CliCommand, tokens: list[str], budget: ReportBudget
) -> tuple[JsonObject, str | None]:
    """Map command/tokens to pre-identity JsonObject and outer repository ID.

    command (CliCommand) is fixed metadata, tokens (list[str]) were prepaid, and
    budget (ReportBudget) bounds repeat sorting/copies. Reject unknown/duplicate
    options with ValueError; limits raise ReportLimitError. No I/O or authority.
    """
    # The finite option index cannot select modules or external configuration.
    options = {option.flag: option for option in command_options(command)}
    fields: dict[str, object] = dict(
        operation=command.operation,
        mode="structural",
        workspace_root=".",
        profile_path=None,
        dry_run=False,
        write=False,
        format="json",
    )
    inputs: dict[str, object] = dict(command.defaults)
    repeated: dict[str, set[str]] = {}
    seen: set[str] = set()
    repository_id: str | None = None
    index = 0
    # Consume each prepaid token exactly once; no abbreviation or response files.
    while index < len(tokens):
        flag, separator, supplied = tokens[index].partition("=")
        option = options.get(flag)
        if option is None:
            raise ValueError("CLI option is unsupported")
        index += 1
        value: object = option.constant
        # Switches accept no value; all other options require one explicit token.
        if option.kind == "switch":
            if separator:
                raise ValueError("CLI switch does not accept a value")
        else:
            if not separator:
                if index >= len(tokens) or tokens[index].startswith("--"):
                    raise ValueError("CLI option requires a value")
                supplied = tokens[index]
                index += 1
            if not supplied or (option.choices and supplied not in option.choices):
                raise ValueError("CLI value is unsupported")
            value = int(supplied) if option.kind == "integer" else supplied
        key = option.key
        # Repeats are genuine selections: duplicate values are errors, never deduped.
        if option.kind == "repeat":
            values = repeated.setdefault(key, set())
            if supplied in values:
                raise ValueError("CLI selection is duplicated")
            values.add(supplied)
        else:
            if key in seen:
                raise ValueError("CLI scalar option is duplicated")
            seen.add(key)
            if key == "repository_id":
                repository_id = cast("str", value)
                if command.operation in ("init", "migrate", "generate-acceptance"):
                    inputs[key] = value
            elif key in _ROOT_OPTIONS:
                fields[key] = value
            else:
                inputs[key] = value
    # Reserve comparison work before deterministic ordering of each selection set.
    for key, values in repeated.items():
        budget.work(len(values))
        # Charge the worst comparison-prefix work before sorting retained values.
        text_size = sum(len(value) for value in values)
        budget.work(text_size * max(1, len(values).bit_length()))
        inputs[key] = tuple(sorted(values))
    fields["inputs"] = bounded_object(inputs, limits=budget.limits)
    budget.check(fields)
    return bounded_object(fields, limits=budget.limits), repository_id


def _request(fields: JsonObject, identifier: str) -> ServiceRequest:
    """Check prepaid fields (JsonObject) and identifier (str); return ServiceRequest.

    Delegate direct typed/combination checks to the accepted public carrier.
    Raise ValueError on wrong shape/combinations; no schema reads, I/O or execution.
    """
    values = dict(fields.members)
    if values.keys() != _FIELDS:
        raise ValueError("CLI request fields are invalid")
    return ServiceRequest(
        id=identifier,
        request_id=identifier,
        operation=cast("Operation", values["operation"]),
        mode=cast("Mode", values["mode"]),
        workspace_root=cast("str", values["workspace_root"]),
        profile_path=cast("str | None", values["profile_path"]),
        dry_run=cast("bool", values["dry_run"]),
        write=cast("bool", values["write"]),
        format=cast("OutputFormat", values["format"]),
        inputs=cast("JsonObject", values["inputs"]),
        invocation_ref=None,
        authorization_ref=None,
    )


def parse_cli_arguments(
    command: str, argv: Sequence[str], *, limits: ParseLimits
) -> CliInvocation | CliHelp | CliError:
    """Parse command (str) and argv (Sequence[str]) under limits (ParseLimits).

    Return immutable invocation, fixed help, or safe argument findings. Unknown
    syntax/policy/Unicode and bounded-work failures never disclose supplied text.
    Root remains explicit spelling or '.'; service owns schema/path validation.
    No provider, filesystem, network, process, graph or publication effects.
    """
    definition = command_definition(command)
    operation = definition.operation if definition is not None else None
    mode: Mode | None = None
    code = "CLI_ARGUMENTS"
    try:
        budget = _budget(limits)
        if definition is None:
            raise ValueError("CLI command is unsupported")
        tokens = _tokens(argv, budget)
        if len(tokens) == 1 and tokens[0] in ("--help", "-h"):
            return _help(definition, budget)
        fields, repository_id = _fields(definition, tokens, budget)
        checked = _request(fields, "cli")
        mode = checked.mode
        return CliInvocation(request=fields, repository_id=repository_id)
    except ReportLimitError:
        code = "CLI_LIMIT"
    except (ValueError, IndexError):
        # These pure argument transforms cannot mask executor/provider failures.
        pass
    return CliError(
        operation=operation,
        mode=mode,
        findings=(
            Finding(
                code=code,
                message="Discovery command arguments are invalid or exceed limits.",
                next_action="Use --help and provide bounded explicit options.",
            ),
        ),
    )


def _reserve_request_work(value: JsonObject, budget: ReportBudget) -> None:
    """Prepay direct value (JsonObject) traversal using budget (ReportBudget).

    Return None after reserving eight visits per string character and bounded
    container/member visits for measurement, reconstruction, copies and encoding.
    Reserve children before stack expansion and depth before descending. Raise
    ReportLimitError on exhaustion; no character scan, encoding or I/O occurs.
    Only a bounded local stack and the supplied work counter change.
    """
    budget.work(1)
    pending: list[tuple[JsonValue, int]] = [(value, 1)]
    # Charge each retained occurrence; repeated aliases do not bypass work limits.
    while pending:
        budget.work(1)
        item, depth = pending.pop()
        if depth > budget.limits.nesting_depth:
            raise ReportLimitError()
        # Strings are charged from their length before any UTF-8/escape scan.
        if type(item) is str:
            budget.work(8 * len(item))
        elif type(item) is JsonObject:
            budget.work(4 * len(item.members))
            # Reserve the complete member expansion before retaining child pairs.
            for key, child in item.members:
                pending.append((key, depth + 1))
                pending.append((child, depth + 1))
        elif type(item) is tuple:
            budget.work(2 * len(item))
            # Each array occurrence is measured independently by later JSON passes.
            for child in item:
                pending.append((child, depth + 1))


def build_cli_request(
    invocation: CliInvocation, *, workspace_root: str, limits: ParseLimits
) -> JsonObject:
    """Build closed wire data after composition resolves the workspace root.

    invocation (CliInvocation) supplies bounded immutable fields; workspace_root
    (str) is the composition's canonical root, and limits (ParseLimits) bounds
    copies/encoding/hash work. Return JsonObject with deterministic IDs and null
    host references. Raise ValueError/ReportLimitError before provider creation
    on invalid data. No schema lookup, path resolution, authority or I/O occurs.
    """
    budget = _budget(limits)
    if (
        type(invocation) is not CliInvocation
        or type(workspace_root) is not str
        or not workspace_root
    ):
        raise ValueError("CLI request requires typed inputs")
    _reserve_request_work(invocation.request, budget)
    budget.check(invocation.request)
    budget.work(8 * len(workspace_root))
    budget.text(workspace_root)
    fields = dict(invocation.request.members)
    fields["workspace_root"] = workspace_root
    prepared = bounded_object(fields, limits=limits)
    _request(prepared, "cli")
    # Reserve hashing and serialization work before materializing canonical bytes.
    budget.work(4 * (limits.document_bytes - budget.bytes_left))
    identifier = "cli-" + sha256(canonical_json(prepared)).hexdigest()
    fields.update(
        {
            "$schema": "urn:drm-copilot:discovery:2.0.0:service-request",
            "schema_version": "2.0.0",
            "artifact_kind": "service-request",
            "id": identifier,
            "request_id": identifier,
            "invocation_ref": None,
            "authorization_ref": None,
        }
    )
    return bounded_object(fields, limits=limits)
