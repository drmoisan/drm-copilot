"use strict";
/**
 * Public surface for the Codex-native converter port.
 *
 * Purpose:
 *     Re-export the models/enums, the engine review/apply entry points and run
 *     result, the CLI command surface, and the report/topology helpers. Mirrors
 *     the role of `codex_native_converter/__init__.py` while exposing the full
 *     in-process API the service helper and tests consume.
 *
 * Invariants:
 *     This module adds no behavior; it only re-exports the converter contract.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.renderSourceToRepeatedDestinationChart = exports.renderSourceToDestinationChart = exports.renderDestinationToRepeatedSourceChart = exports.writeConversionReportSet = exports.review = exports.resolveSourceEcosystem = exports.resolveRunOptions = exports.printRunSummary = exports.apply = exports.runReviewMode = exports.runApplyMode = exports.validationFindingToJson = exports.TargetRole = exports.sourceArtifactToJson = exports.SourceKind = exports.SourceEcosystem = exports.SemanticCueKind = exports.SectionIntentKind = exports.runOptionsToJson = exports.mappingRecordToJson = exports.ConversionClass = void 0;
var models_1 = require("./models");
Object.defineProperty(exports, "ConversionClass", { enumerable: true, get: function () { return models_1.ConversionClass; } });
Object.defineProperty(exports, "mappingRecordToJson", { enumerable: true, get: function () { return models_1.mappingRecordToJson; } });
Object.defineProperty(exports, "runOptionsToJson", { enumerable: true, get: function () { return models_1.runOptionsToJson; } });
Object.defineProperty(exports, "SectionIntentKind", { enumerable: true, get: function () { return models_1.SectionIntentKind; } });
Object.defineProperty(exports, "SemanticCueKind", { enumerable: true, get: function () { return models_1.SemanticCueKind; } });
Object.defineProperty(exports, "SourceEcosystem", { enumerable: true, get: function () { return models_1.SourceEcosystem; } });
Object.defineProperty(exports, "SourceKind", { enumerable: true, get: function () { return models_1.SourceKind; } });
Object.defineProperty(exports, "sourceArtifactToJson", { enumerable: true, get: function () { return models_1.sourceArtifactToJson; } });
Object.defineProperty(exports, "TargetRole", { enumerable: true, get: function () { return models_1.TargetRole; } });
Object.defineProperty(exports, "validationFindingToJson", { enumerable: true, get: function () { return models_1.validationFindingToJson; } });
var engine_1 = require("./engine");
Object.defineProperty(exports, "runApplyMode", { enumerable: true, get: function () { return engine_1.runApplyMode; } });
Object.defineProperty(exports, "runReviewMode", { enumerable: true, get: function () { return engine_1.runReviewMode; } });
var cli_1 = require("./cli");
Object.defineProperty(exports, "apply", { enumerable: true, get: function () { return cli_1.apply; } });
Object.defineProperty(exports, "printRunSummary", { enumerable: true, get: function () { return cli_1.printRunSummary; } });
Object.defineProperty(exports, "resolveRunOptions", { enumerable: true, get: function () { return cli_1.resolveRunOptions; } });
Object.defineProperty(exports, "resolveSourceEcosystem", { enumerable: true, get: function () { return cli_1.resolveSourceEcosystem; } });
Object.defineProperty(exports, "review", { enumerable: true, get: function () { return cli_1.review; } });
var reporting_1 = require("./reporting");
Object.defineProperty(exports, "writeConversionReportSet", { enumerable: true, get: function () { return reporting_1.writeConversionReportSet; } });
var reporting_topology_1 = require("./reporting-topology");
Object.defineProperty(exports, "renderDestinationToRepeatedSourceChart", { enumerable: true, get: function () { return reporting_topology_1.renderDestinationToRepeatedSourceChart; } });
Object.defineProperty(exports, "renderSourceToDestinationChart", { enumerable: true, get: function () { return reporting_topology_1.renderSourceToDestinationChart; } });
Object.defineProperty(exports, "renderSourceToRepeatedDestinationChart", { enumerable: true, get: function () { return reporting_topology_1.renderSourceToRepeatedDestinationChart; } });
