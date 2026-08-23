/** Canonical artifact and option catalog for orchestration validation. */

export const VALIDATOR_ARTIFACT_TYPES = [
  "plan",
  "policy-audit",
  "code-review",
  "feature-audit",
  "orchestrator-state",
  "epic-orchestrator-state",
  "epic-planner-state",
  "epic-kickoff",
  "parallel-orchestrator-state",
  "parallel-planner-state",
  "parallel-kickoff",
] as const;

export const VALIDATOR_FLAG_DEFINITIONS = [
  {
    inputName: "require_complete",
    optionName: "requireComplete",
    description:
      "When true and artifact_type is 'orchestrator-state', 'epic-orchestrator-state', or 'parallel-orchestrator-state', require all phases to be complete.",
  },
  {
    inputName: "require_pr_creation_ready",
    optionName: "requirePrCreationReady",
    description:
      "When true and artifact_type is 'orchestrator-state', require readiness for PR creation without requiring final PR or CI evidence.",
  },
  {
    inputName: "require_model_routing",
    optionName: "requireModelRouting",
    description:
      "When true and artifact_type is 'orchestrator-state', require a legacy model_routing_receipts entry per delegated agent.",
  },
  {
    inputName: "require_codex_model_routing",
    optionName: "requireCodexModelRouting",
    description:
      "When true for an orchestrator checkpoint, require canonical Codex deployment receipts for delegated agents.",
  },
  {
    inputName: "require_codex_topology",
    optionName: "requireCodexTopology",
    description:
      "When true for an orchestrator checkpoint, require canonical Codex topology receipts for delegated agents and epic roots.",
  },
  {
    inputName: "require_ready_for_execution",
    optionName: "requireReadyForExecution",
    description:
      "When true for 'epic-planner-state', 'parallel-planner-state', or 'parallel-kickoff', require complete preparation and committed execution-readiness evidence.",
  },
] as const;

export type ValidatorFlagOptionName =
  (typeof VALIDATOR_FLAG_DEFINITIONS)[number]["optionName"];

export type SelectedValidatorFlags = Partial<
  Readonly<Record<ValidatorFlagOptionName, true>>
>;
export type ValidatorFlagValues = Readonly<
  Partial<Record<ValidatorFlagOptionName, boolean>>
>;

export interface ValidatorCatalogSurface {
  readonly name: string;
  readonly artifactTypes: ReadonlyArray<string>;
  readonly validationFlags: ReadonlyArray<string>;
}

export const VALIDATOR_VALIDATION_FLAGS = VALIDATOR_FLAG_DEFINITIONS.map(
  ({ inputName }) => inputName,
);

export const VALIDATOR_ARTIFACT_TYPE_PROPERTY = Object.freeze({
  type: "string",
  enum: VALIDATOR_ARTIFACT_TYPES,
  description: "The type of orchestration artifact to validate.",
});

export const VALIDATOR_FLAG_SCHEMA_PROPERTIES = Object.freeze(
  Object.fromEntries(
    VALIDATOR_FLAG_DEFINITIONS.map(({ inputName, description }) => [
      inputName,
      Object.freeze({ type: "boolean", description }),
    ]),
  ),
) as Readonly<
  Record<string, Readonly<{ type: "boolean"; description: string }>>
>;

/** Select only literal-true flags while deriving every name from the catalog. */
export function selectValidatorFlags(
  args: Readonly<Record<string, unknown>>,
): SelectedValidatorFlags {
  const selected: Partial<Record<ValidatorFlagOptionName, true>> = {};
  for (const definition of VALIDATOR_FLAG_DEFINITIONS) {
    const value = args[definition.inputName];
    if (value !== undefined && typeof value !== "boolean") {
      throw new Error(
        `Field '${definition.inputName}' must be a boolean when provided.`,
      );
    }
    if (value === true) {
      selected[definition.optionName] = true;
    }
  }
  return selected;
}

/** Copy every defined camel-case validator option without changing its value. */
export function selectDefinedValidatorFlagValues(
  input: ValidatorFlagValues,
): ValidatorFlagValues {
  const selected: Partial<Record<ValidatorFlagOptionName, boolean>> = {};
  for (const { optionName } of VALIDATOR_FLAG_DEFINITIONS) {
    const value = input[optionName];
    if (value !== undefined) {
      selected[optionName] = value;
    }
  }
  return selected;
}

/** Fail when any declared catalog surface differs in values or order. */
export function assertValidatorCatalogParity(
  reference: ValidatorCatalogSurface,
  candidates: ReadonlyArray<ValidatorCatalogSurface>,
): void {
  const expectedArtifacts = JSON.stringify(reference.artifactTypes);
  const expectedFlags = JSON.stringify(reference.validationFlags);
  for (const candidate of candidates) {
    if (
      JSON.stringify(candidate.artifactTypes) !== expectedArtifacts ||
      JSON.stringify(candidate.validationFlags) !== expectedFlags
    ) {
      throw new Error(
        `ORCH_VALIDATOR_CATALOG_DIVERGENCE: '${candidate.name}' does not match '${reference.name}'.`,
      );
    }
  }
}
