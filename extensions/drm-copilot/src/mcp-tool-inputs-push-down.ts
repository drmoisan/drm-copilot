import {
  normalizeRequiredText,
  normalizeWorkspaceRoot,
} from "./workflow-command-arguments";
import {
  asToolArgumentObject,
  type WorkspaceToolInput,
} from "./mcp-tool-inputs";

/** Optional run options of every push-down tool input (issue #1029). */
export interface PushDownRunToolInput {
  readonly dryRun?: boolean;
  readonly overwriteUnmanaged?: boolean;
}

export interface PushDownCopilotCustomizationsToolInput
  extends WorkspaceToolInput, PushDownRunToolInput {
  readonly packs?: ReadonlyArray<string>;
}

export interface PushDownClaudeCustomizationsToolInput
  extends WorkspaceToolInput, PushDownRunToolInput {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: "modern" | "legacy";
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}

export interface PushDownCodexAndAgentsCustomizationsToolInput
  extends WorkspaceToolInput, PushDownRunToolInput {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: "modern" | "legacy";
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}

/**
 * Resolve an optional boolean field.
 *
 * @param rawValue Raw argument value.
 * @param field Field name used in the error.
 * @returns The boolean, or `undefined` when absent.
 * @throws Error When the value is present and not a boolean.
 */
function resolveBooleanField(
  rawValue: unknown,
  field: "dry_run" | "overwrite_unmanaged",
): boolean | undefined {
  if (rawValue === undefined) {
    return undefined;
  }
  if (typeof rawValue !== "boolean") {
    throw new Error(`Field '${field}' must be a boolean when provided.`);
  }
  return rawValue;
}

/**
 * Resolve `dry_run` and `overwrite_unmanaged`, each only when present.
 *
 * @param args Tool argument object.
 * @returns The present run options.
 * @throws Error When either field is present and not a boolean.
 */
function resolveRunOptions(
  args: Readonly<Record<string, unknown>>,
): PushDownRunToolInput {
  const dryRun = resolveBooleanField(args["dry_run"], "dry_run");
  const overwriteUnmanaged = resolveBooleanField(
    args["overwrite_unmanaged"],
    "overwrite_unmanaged",
  );
  return {
    ...(dryRun === undefined ? {} : { dryRun }),
    ...(overwriteUnmanaged === undefined ? {} : { overwriteUnmanaged }),
  };
}

function resolvePacksField(
  rawValue: unknown,
): ReadonlyArray<string> | undefined {
  // An absent packs field yields the backward-compatible publish-everything
  // default (undefined). When present it must be an array of strings.
  if (rawValue === undefined) {
    return undefined;
  }
  if (!Array.isArray(rawValue)) {
    throw new Error("Field 'packs' must be an array of strings when provided.");
  }
  return rawValue.map((entry, index) =>
    normalizeRequiredText(entry, `packs[${index}]`),
  );
}

function resolveCsharpVariantField(
  rawValue: unknown,
): "modern" | "legacy" | undefined {
  // An absent variant leaves the field undefined so the engine default applies.
  if (rawValue === undefined) {
    return undefined;
  }
  const variant = normalizeRequiredText(rawValue, "csharp_variant");
  if (variant !== "modern" && variant !== "legacy") {
    throw new Error("Field 'csharp_variant' must be 'modern' or 'legacy'.");
  }
  return variant;
}

function resolveMemoryModeField(
  rawValue: unknown,
): "overwrite" | "merge" | "skip" | undefined {
  // An absent memory mode leaves the field undefined so the engine default
  // (overwrite) applies.
  if (rawValue === undefined) {
    return undefined;
  }
  const mode = normalizeRequiredText(rawValue, "memory_mode");
  if (mode !== "overwrite" && mode !== "merge" && mode !== "skip") {
    throw new Error(
      "Field 'memory_mode' must be 'overwrite', 'merge', or 'skip'.",
    );
  }
  return mode;
}

export function resolvePushDownClaudeCustomizationsToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): PushDownClaudeCustomizationsToolInput {
  const args = asToolArgumentObject(rawInput);
  const packs = resolvePacksField(args["packs"]);
  const csharpVariant = resolveCsharpVariantField(args["csharp_variant"]);
  const memoryMode = resolveMemoryModeField(args["memory_mode"]);
  // Spread each optional field only when present so a workspace_root-only
  // invocation resolves to an input with every new field left undefined.
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    ...(packs === undefined ? {} : { packs }),
    ...(csharpVariant === undefined ? {} : { csharpVariant }),
    ...(memoryMode === undefined ? {} : { memoryMode }),
    ...resolveRunOptions(args),
  };
}

export function resolvePushDownCopilotCustomizationsToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): PushDownCopilotCustomizationsToolInput {
  const args = asToolArgumentObject(rawInput);
  const packs = resolvePacksField(args["packs"]);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    ...(packs === undefined ? {} : { packs }),
    ...resolveRunOptions(args),
  };
}

export function resolvePushDownCodexAndAgentsCustomizationsToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): PushDownCodexAndAgentsCustomizationsToolInput {
  const args = asToolArgumentObject(rawInput);
  const packs = resolvePacksField(args["packs"]);
  const csharpVariant = resolveCsharpVariantField(args["csharp_variant"]);
  const memoryMode = resolveMemoryModeField(args["memory_mode"]);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    ...(packs === undefined ? {} : { packs }),
    ...(csharpVariant === undefined ? {} : { csharpVariant }),
    ...(memoryMode === undefined ? {} : { memoryMode }),
    ...resolveRunOptions(args),
  };
}
