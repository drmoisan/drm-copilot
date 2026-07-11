/** Resolve Codex implementation topology from deterministic scope inputs. */

export type ExecutionContext =
  "standalone" | "epic_preparation_child" | "epic_execution_child";
export type TopologyRoute = "small" | "large" | "epic";
export type Topology = "typed_engineer" | "orchestrator" | "epic_persona";
export type RootPersona = "epic-planner" | "epic-orchestrator";

export interface LanguageBudget {
  readonly direct_mode_enabled: boolean;
  readonly max_production_files: number;
  readonly max_test_files: number;
  readonly logical_agent: string;
}

export interface CodexTopologyReceipt {
  readonly execution_context: ExecutionContext;
  readonly languages: ReadonlyArray<string>;
  readonly production_file_count: number;
  readonly test_file_count: number;
  readonly cross_cutting: boolean;
  readonly root_persona: RootPersona | null;
  readonly route: TopologyRoute;
  readonly topology: Topology;
  readonly logical_agent: string;
  readonly routing_reason: string;
  readonly max_production_files: number | null;
  readonly max_test_files: number | null;
}

export interface ResolveCodexTopologyOptions {
  readonly crossCutting?: unknown;
  readonly rootPersona?: unknown;
}

export const VALID_EXECUTION_CONTEXTS: ReadonlySet<string> = new Set([
  "standalone",
  "epic_preparation_child",
  "epic_execution_child",
]);
export const EPIC_CHILD_CONTEXTS: ReadonlySet<string> = new Set([
  "epic_preparation_child",
  "epic_execution_child",
]);
export const FORCED_ROOT_PERSONAS: ReadonlySet<string> = new Set([
  "epic-planner",
  "epic-orchestrator",
]);
export const ORCHESTRATOR_LOGICAL_AGENT = "orchestrator";
export const ESCALATION_PRECEDENCE = [
  "epic_child_context",
  "invalid_estimate",
  "cross_language",
  "unsupported_language",
  "cross_cutting",
  "direct_mode_disabled",
  "production_budget_exceeded",
] as const;

export const LANGUAGE_BUDGETS: Readonly<Record<string, LanguageBudget>> = {
  python: {
    direct_mode_enabled: true,
    max_production_files: 3,
    max_test_files: 3,
    logical_agent: "python-typed-engineer",
  },
  powershell: {
    direct_mode_enabled: true,
    max_production_files: 2,
    max_test_files: 3,
    logical_agent: "powershell-typed-engineer",
  },
  csharp: {
    direct_mode_enabled: true,
    max_production_files: 3,
    max_test_files: 3,
    logical_agent: "csharp-typed-engineer",
  },
  typescript: {
    direct_mode_enabled: false,
    max_production_files: 0,
    max_test_files: 0,
    logical_agent: "typescript-engineer",
  },
};

function pythonRepr(value: unknown): string {
  if (value === undefined || value === null) {
    return "None";
  }
  if (typeof value === "string") {
    return `'${value.replaceAll("\\", "\\\\").replaceAll("'", "\\'")}'`;
  }
  if (typeof value === "boolean") {
    return value ? "True" : "False";
  }
  return String(value);
}

function validateContext(value: unknown): ExecutionContext {
  if (typeof value !== "string" || !VALID_EXECUTION_CONTEXTS.has(value)) {
    throw new Error(
      "execution_context must be one of " +
        "('epic_execution_child', 'epic_preparation_child', 'standalone'), " +
        `found ${pythonRepr(value)}.`,
    );
  }
  return value as ExecutionContext;
}

function normalizeLanguages(value: unknown): string[] {
  if (
    !Array.isArray(value) ||
    value.some(
      (language) => typeof language !== "string" || language.trim() === "",
    )
  ) {
    throw new Error("languages must contain non-empty strings.");
  }
  const normalized = new Set(
    value.map((language) => (language as string).trim().toLowerCase()),
  );
  return [...normalized].sort();
}

function requireInteger(value: unknown, fieldName: string): number {
  if (typeof value !== "number" || !Number.isInteger(value)) {
    throw new Error(`${fieldName} must be an integer.`);
  }
  return value;
}

function requireBoolean(value: unknown): boolean {
  if (typeof value !== "boolean") {
    throw new Error("cross_cutting must be a boolean.");
  }
  return value;
}

function orchestratorReceipt(
  context: ExecutionContext,
  languages: ReadonlyArray<string>,
  productionFileCount: number,
  testFileCount: number,
  crossCutting: boolean,
  reason: string,
  budget?: LanguageBudget,
): CodexTopologyReceipt {
  return {
    execution_context: context,
    languages,
    production_file_count: productionFileCount,
    test_file_count: testFileCount,
    cross_cutting: crossCutting,
    root_persona: null,
    route: "large",
    topology: "orchestrator",
    logical_agent: ORCHESTRATOR_LOGICAL_AGENT,
    routing_reason: reason,
    max_production_files: budget?.max_production_files ?? null,
    max_test_files: budget?.max_test_files ?? null,
  };
}

/** Resolve the initial implementation topology independently from model choice. */
export function resolveCodexTopology(
  languagesValue: unknown,
  productionFileCountValue: unknown,
  testFileCountValue: unknown,
  executionContextValue: unknown,
  options: ResolveCodexTopologyOptions = {},
): CodexTopologyReceipt {
  const context = validateContext(executionContextValue);
  const languages = normalizeLanguages(languagesValue);
  const productionFileCount = requireInteger(
    productionFileCountValue,
    "production_file_count",
  );
  const testFileCount = requireInteger(testFileCountValue, "test_file_count");
  const crossCutting = requireBoolean(
    options.crossCutting === undefined ? false : options.crossCutting,
  );
  const rootPersona = options.rootPersona ?? null;

  if (rootPersona !== null) {
    if (
      typeof rootPersona !== "string" ||
      !FORCED_ROOT_PERSONAS.has(rootPersona)
    ) {
      throw new Error(
        `Unsupported Codex root persona: ${pythonRepr(rootPersona)}.`,
      );
    }
    if (context !== "standalone") {
      throw new Error("A forced root persona requires standalone context.");
    }
    const persona = rootPersona as RootPersona;
    return {
      execution_context: context,
      languages,
      production_file_count: productionFileCount,
      test_file_count: testFileCount,
      cross_cutting: crossCutting,
      root_persona: persona,
      route: "epic",
      topology: "epic_persona",
      logical_agent: persona,
      routing_reason: "forced_root_persona",
      max_production_files: null,
      max_test_files: null,
    };
  }

  const escalate = (
    reason: string,
    budget?: LanguageBudget,
  ): CodexTopologyReceipt =>
    orchestratorReceipt(
      context,
      languages,
      productionFileCount,
      testFileCount,
      crossCutting,
      reason,
      budget,
    );

  if (EPIC_CHILD_CONTEXTS.has(context)) {
    return escalate("epic_child_context");
  }
  if (productionFileCount <= 0 || testFileCount < 0) {
    return escalate("invalid_estimate");
  }
  if (languages.length > 1) {
    return escalate("cross_language");
  }
  if (languages.length !== 1) {
    return escalate("unsupported_language");
  }

  const budget = LANGUAGE_BUDGETS[languages[0] ?? ""];
  if (budget === undefined) {
    return escalate("unsupported_language");
  }
  if (crossCutting) {
    return escalate("cross_cutting", budget);
  }
  if (!budget.direct_mode_enabled) {
    return escalate("direct_mode_disabled", budget);
  }
  if (productionFileCount > budget.max_production_files) {
    return escalate("production_budget_exceeded", budget);
  }
  return {
    execution_context: context,
    languages,
    production_file_count: productionFileCount,
    test_file_count: testFileCount,
    cross_cutting: crossCutting,
    root_persona: null,
    route: "small",
    topology: "typed_engineer",
    logical_agent: budget.logical_agent,
    routing_reason: "within_language_budget",
    max_production_files: budget.max_production_files,
    max_test_files: budget.max_test_files,
  };
}
