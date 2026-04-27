"""Define typed domain models for the Codex-native converter.

Purpose:
    Centralize the typed enums and value objects that the converter uses to
    classify source artifacts, plan targets, report findings, and describe a
    conversion run.

Usage:
    Import these models from the inventory, classifier, mapping, validation,
    reporting, engine, and CLI modules so the converter shares one contract.

Flow:
    The module defines source taxonomy enums first, then immutable dataclasses
    that capture mapping records, validation findings, and run options.

Invariants / Constraints:
    Relative paths recorded by these models stay normalized to POSIX-style text
    so report output remains deterministic across operating systems.

Side Effects:
    None.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pathlib import Path


class SourceEcosystem(str, Enum):
    """Describe a supported source runtime ecosystem.

    Purpose:
        Identify the top-level ecosystem that the converter should interpret.

    Usage:
        Store this enum in run options and mapping records so later stages can
        apply ecosystem-specific classification and rewrite rules.

    Flow:
        Values are parsed from CLI or wrapper inputs and then carried through the
        entire conversion pipeline.

    Invariants / Constraints:
        Only the supported v1 ecosystems are modeled here.

    Side Effects:
        None.
    """

    GITHUB_COPILOT = "github-copilot"
    CLAUDE = "claude"


class SourceKind(str, Enum):
    """Describe the type of source artifact discovered in a source tree.

    Purpose:
        Capture the role a source file or folder plays before conversion logic
        decides whether it maps directly, decomposes, or fails as unsupported.

    Usage:
        The classifier assigns a value from this enum to every discovered source
        artifact.

    Flow:
        Inventory returns normalized paths, then the classifier tags each path
        with a source kind so mapping rules can branch by intent.

    Invariants / Constraints:
        The enum intentionally models repository-relevant artifact types rather
        than every possible file extension.

    Side Effects:
        None.
    """

    STANDING_INSTRUCTION = "standing-instruction"
    PATH_SCOPED_INSTRUCTION = "path-scoped-instruction"
    REUSABLE_SKILL = "reusable-skill"
    AGENT_MANIFEST = "agent-manifest"
    LAUNCHER_PROMPT = "launcher-prompt"
    HOOK_DEFINITION = "hook-definition"
    PERMISSIONS_OR_SETTINGS = "permissions-or-settings"
    SHELL_POLICY_OR_RULE = "shell-policy-or-rule"
    MCP_DEPENDENCY_DECLARATION = "mcp-dependency-declaration"
    HOST_ADAPTER_REFERENCE = "host-adapter-reference"
    UNKNOWN = "unknown"


class ConversionClass(str, Enum):
    """Describe how a source artifact should be converted.

    Purpose:
        Express whether an artifact maps directly, must be decomposed, maps to a
        repository convention, or has no safe v1 mapping.

    Usage:
        Mapping records store this enum so reports and validation can distinguish
        safe direct mappings from fail-closed unsupported cases.

    Flow:
        The classifier chooses a conversion class after identifying source kind
        and target role.

    Invariants / Constraints:
        Values align with the approved feature requirements and user-story text.

    Side Effects:
        None.
    """

    DIRECT = "direct"
    DECOMPOSED = "decomposed"
    REPO_CONVENTION = "repo-convention"
    UNSUPPORTED = "unsupported"


class TargetRole(str, Enum):
    """Describe the Codex-native role targeted by a mapped artifact.

    Purpose:
        Capture the intended Codex-native destination role independent of the
        final file path.

    Usage:
        Mapping records use this enum to explain why a given output path was
        selected and which native runtime surface it serves.

    Flow:
        The classifier assigns a role, then the mapping module resolves the
        concrete path for that role.

    Invariants / Constraints:
        Roles are limited to the native surfaces approved by the feature scope.

    Side Effects:
        None.
    """

    STANDING_GUIDANCE = "standing-guidance"
    SHARED_SKILL = "shared-skill"
    SUBAGENT = "subagent"
    HOOK = "hook"
    APPROVAL_RULE = "approval-rule"
    MCP_CONFIG = "mcp-config"
    LAUNCHER = "launcher"
    UNSUPPORTED = "unsupported"


@dataclass(frozen=True, slots=True)
class MappingRecord:
    """Represent the planned conversion of one source artifact.

    Purpose:
        Carry the normalized classification, mapping, and rewrite details for a
        single source artifact from analysis through reporting.

    Usage:
        Create one record per discovered artifact after classification and path
        planning are complete.

    Flow:
        Inventory discovers a path, classification assigns source kind and role,
        mapping resolves a target path, and reporting serializes the record.

    Invariants / Constraints:
        Paths are stored as normalized relative text, not OS-specific absolute
        paths, so emitted reports remain deterministic.

    Side Effects:
        None.

    Attributes:
        source_path (str): Normalized relative path within the source root.
        source_ecosystem (SourceEcosystem): Declared source ecosystem.
        source_kind (SourceKind): Classified source artifact kind.
        conversion_class (ConversionClass): Planned conversion behavior.
        target_role (TargetRole): Intended native destination role.
        target_path (str | None): Planned relative destination path, if any.
        notes (tuple[str, ...]): Additional mapping notes or rewrite summaries.
        is_required (bool): Whether the artifact is required for a valid apply
            run.
    """

    source_path: str
    source_ecosystem: SourceEcosystem
    source_kind: SourceKind
    conversion_class: ConversionClass
    target_role: TargetRole
    target_path: str | None
    notes: tuple[str, ...] = ()
    is_required: bool = True

    def to_json_dict(self) -> dict[str, object]:
        """Serialize the mapping record to a JSON-friendly dictionary.

        Purpose:
            Provide stable structured output for JSON reporting artifacts.

        Args:
            None.

        Returns:
            dict[str, object]: A JSON-friendly representation of the mapping
            record.

        Raises:
            None.

        Side Effects:
            None.
        """

        return {
            "source_path": self.source_path,
            "source_ecosystem": self.source_ecosystem.value,
            "source_kind": self.source_kind.value,
            "conversion_class": self.conversion_class.value,
            "target_role": self.target_role.value,
            "target_path": self.target_path,
            "notes": list(self.notes),
            "is_required": self.is_required,
        }


@dataclass(frozen=True, slots=True)
class ValidationFinding:
    """Represent one validation result emitted by the converter.

    Purpose:
        Capture blocking and non-blocking validation outcomes in a form that the
        CLI, reports, and wrappers can all reuse.

    Usage:
        The validation module emits these findings after it inspects planned
        mappings and generated content.

    Flow:
        Validation creates findings, reporting serializes them, and the engine
        decides whether apply mode may continue based on their blocking flag.

    Invariants / Constraints:
        Each finding must provide a stable machine-readable code and a concise
        human-readable remediation action.

    Side Effects:
        None.

    Attributes:
        code (str): Stable machine-readable failure or warning code.
        severity (str): Human-readable severity label such as warning or error.
        blocking (bool): Whether the finding must stop apply mode.
        source_path (str | None): Source-relative path associated with the
            finding, if any.
        target_path (str | None): Target-relative path associated with the
            finding, if any.
        message (str): Human-readable explanation of the finding.
        recommended_action (str): Human-readable remediation guidance.
    """

    code: str
    severity: str
    blocking: bool
    source_path: str | None
    target_path: str | None
    message: str
    recommended_action: str

    def to_json_dict(self) -> dict[str, object]:
        """Serialize the validation finding to a JSON-friendly dictionary.

        Purpose:
            Produce structured validation output for machine-readable artifacts.

        Args:
            None.

        Returns:
            dict[str, object]: The validation finding represented with JSON-safe
            primitive values.

        Raises:
            None.

        Side Effects:
            None.
        """

        return {
            "code": self.code,
            "severity": self.severity,
            "blocking": self.blocking,
            "source_path": self.source_path,
            "target_path": self.target_path,
            "message": self.message,
            "recommended_action": self.recommended_action,
        }


@dataclass(frozen=True, slots=True)
class RunOptions:
    """Describe one requested converter run.

    Purpose:
        Bundle the validated inputs that control review or apply execution.

    Usage:
        The CLI or TypeScript wrapper constructs one instance after validating
        user input and passes it into the converter engine.

    Flow:
        Input parsing resolves roots and flags, then the engine reads this value
        object to drive inventory, mapping, validation, and output writing.

    Invariants / Constraints:
        Source and output roots are stored as absolute normalized paths so all
        later file-system operations operate on one canonical location.

    Side Effects:
        None.

    Attributes:
        mode (str): Requested run mode, expected to be ``review`` or ``apply``.
        source_root (Path): Absolute source root path.
        source_ecosystem (SourceEcosystem): Declared source ecosystem.
        selected_paths (tuple[Path, ...]): Optional subset of paths under the
            source root.
        destination_root (Path | None): Required destination path for apply mode.
        artifact_root (Path): Artifact output root.
        enable_repo_prompts (bool): Whether repo-convention prompt output is
            enabled.
    """

    mode: str
    source_root: Path
    source_ecosystem: SourceEcosystem
    selected_paths: tuple[Path, ...]
    destination_root: Path | None
    artifact_root: Path
    enable_repo_prompts: bool = False

    def to_json_dict(self) -> dict[str, object]:
        """Serialize the run options to a JSON-friendly dictionary.

        Purpose:
            Provide structured run metadata for reports and automation wrappers.

        Args:
            None.

        Returns:
            dict[str, object]: The run options expressed with JSON-safe
            primitive values.

        Raises:
            None.

        Side Effects:
            None.
        """

        return {
            "mode": self.mode,
            "source_root": self.source_root.as_posix(),
            "source_ecosystem": self.source_ecosystem.value,
            "selected_paths": [path.as_posix() for path in self.selected_paths],
            "destination_root": (
                self.destination_root.as_posix()
                if self.destination_root is not None
                else None
            ),
            "artifact_root": self.artifact_root.as_posix(),
            "enable_repo_prompts": self.enable_repo_prompts,
        }
