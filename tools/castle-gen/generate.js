#!/usr/bin/env node
// ─────────────────────────────────────────────────────────────────────────────
// castle-gen  —  CLI bridge between Belagerungs-Atlas logic and Godot
//
// This file has ZERO third-party dependencies.  It imports only the pure-logic
// modules from the project source (no THREE.js, no React, no DOM).
//
// Usage:
//   node generate.js                       → list all hero castle IDs
//   node generate.js <castleId>            → generate by hero ID
//   node generate.js --file=castle.json    → generate from a JSON file
//   node generate.js --stdin               → read castle JSON from stdin
//   node generate.js --validate <id>       → generate + run validator
//   node generate.js --random <seed>       → procedural castle from seed
//   node generate.js --all                 → export all hero castles as JSON
//
// Output: JSON written to stdout — pipe into a .json file or directly into Godot.
// ─────────────────────────────────────────────────────────────────────────────

import { readFileSync }    from 'fs';
import { createInterface } from 'readline';
import path                from 'path';
import { fileURLToPath }   from 'url';

// ── Resolve project root ──────────────────────────────────────────────────────
const __dir  = fileURLToPath(new URL('.', import.meta.url));
const srcDir = path.resolve(__dir, '../../src/components/diorama');

// ── Import pure-logic modules (no THREE.js anywhere in this chain) ─────────────
const { generateComponents, generateRandomCastle }  = await import(`${srcDir}/generator.js`);
const { validateDiorama, autoCorrectReachability }  = await import(`${srcDir}/DioramaValidator.js`);
const { enhanceComponentsForRealism }               = await import(`${srcDir}/fidelity.js`);
const { HERO_DIORAMAS }                             = await import(`${srcDir}/heroData.js`);

// ── resolveStyle: inlined stripped copy (no THREE.js needed) ─────────────────
// Mirrors the logic in renderer.js without pulling in WebGL context.
function resolveStyle(castle) {
  const epoch  = (castle.epoch  || castle.era    || '').toLowerCase();
  const region = (castle.region || '').toLowerCase();
  if (epoch.includes('feudal') || epoch.includes('japan')) return 'japanese';
  if (region === 'nahost' || (region === 'asien' && !epoch.includes('feudal'))) return 'oriental';
  if (epoch.includes('antike')) return 'ancient';
  if (castle.type === 'fantasy') return 'fantasy';
  return 'crusader';
}

// ── Core pipeline ─────────────────────────────────────────────────────────────
//
// Mirrors getDioramaModel (normalize.js) but without renderer.js dependency.
// Returns the same component + metadata shape that Godot reads.

function buildModel(castle, options = {}) {
  // 1. Hero override: hand-crafted dioramas take priority over generator
  const heroDiorama = HERO_DIORAMAS[castle.id] || {};
  const diorama     = { ...heroDiorama, ...(castle.diorama || {}) };

  // 2. Component source
  const rawComponents = diorama.components || castle.components || generateComponents(castle);

  // 3. Fidelity enhancement (pure — adds details, buttresses, etc.)
  const style           = diorama.style || resolveStyle(castle);
  const historicalMode  = diorama.components ? 'surveyed'
                        : castle.components  ? 'handcrafted'
                        : 'procedural';
  const enhanced = enhanceComponentsForRealism(castle, rawComponents, style, historicalMode);

  // 4. Assign stable IDs (mirrors normalize.js)
  const typeCounters = {};
  const components = enhanced.map(comp => {
    if (comp.id) return comp;
    const t = (comp.type || 'UNKNOWN').toLowerCase();
    typeCounters[t] = (typeCounters[t] || 0) + 1;
    return { ...comp, id: `${castle.id}/${t}/${typeCounters[t]}` };
  });

  // 5. Optional validation + auto-correction
  let finalComponents = components;
  let validationReport = null;
  if (options.validate) {
    const castleBaseY = 0;
    validationReport  = validateDiorama(components, { castleBaseY });
    finalComponents   = autoCorrectReachability(components, validationReport);
    if (finalComponents !== components) {
      // Re-validate after correction
      validationReport = validateDiorama(finalComponents, { castleBaseY });
    }
  }

  // 6. Metadata
  const rings    = finalComponents.filter(c => c.type === 'RING');
  const maxRingR = rings.length
    ? Math.max(...rings.flatMap(r => (r.points || []).map(pt => Math.hypot(pt.x || 0, pt.z || 0))))
    : 18;

  return {
    id:            castle.id,
    name:          castle.name || castle.id,
    style,
    historicalMode,
    scale:         diorama.scale || 1.0,
    cameraRadius:  diorama.cameraRadius || Math.max(28, maxRingR * 2.45),
    components:    finalComponents,
    validation:    validationReport,
  };
}

// ── CLI argument parser ────────────────────────────────────────────────────────

const args = process.argv.slice(2);

function flag(name) {
  return args.some(a => a === `--${name}` || a.startsWith(`--${name}=`));
}
function flagVal(name) {
  const a = args.find(a => a.startsWith(`--${name}=`));
  return a ? a.split('=').slice(1).join('=') : null;
}

// ── Commands ──────────────────────────────────────────────────────────────────

// --list  /  (no args)
if (args.length === 0 || flag('list')) {
  const ids = Object.keys(HERO_DIORAMAS);
  process.stderr.write(`Available hero castle IDs (${ids.length}):\n`);
  ids.forEach(id => process.stderr.write(`  ${id}\n`));
  process.stderr.write('\nUsage examples:\n');
  process.stderr.write('  node generate.js krak-des-chevaliers\n');
  process.stderr.write('  node generate.js --random=mycastle123\n');
  process.stderr.write('  node generate.js --file=castle.json --validate\n');
  process.stderr.write('  node generate.js --all > all_castles.json\n');
  process.exit(0);
}

// --all → export every hero castle as a JSON array
if (flag('all')) {
  const validate = flag('validate');
  const models = Object.entries(HERO_DIORAMAS).map(([id]) => {
    const heroDio  = HERO_DIORAMAS[id];
    const fakeCastle = { id, name: id, diorama: heroDio };
    return buildModel(fakeCastle, { validate });
  });
  process.stdout.write(JSON.stringify(models, null, 2));
  process.exit(0);
}

// --random=<seed>
if (flag('random')) {
  const seed    = flagVal('random') || args[0] || 'random_seed';
  const castle  = generateRandomCastle(seed);
  const model   = buildModel(castle, { validate: flag('validate') });
  process.stdout.write(JSON.stringify(model, null, 2));
  process.exit(0);
}

// --file=<path>
if (flag('file')) {
  const filePath = flagVal('file');
  if (!filePath) { process.stderr.write('Error: --file requires a path\n'); process.exit(1); }
  const castle = JSON.parse(readFileSync(filePath, 'utf8'));
  const model  = buildModel(castle, { validate: flag('validate') });
  process.stdout.write(JSON.stringify(model, null, 2));
  process.exit(0);
}

// --stdin
if (flag('stdin')) {
  const rl   = createInterface({ input: process.stdin });
  const lines = [];
  rl.on('line', l => lines.push(l));
  rl.on('close', () => {
    const castle = JSON.parse(lines.join('\n'));
    const model  = buildModel(castle, { validate: flag('validate') });
    process.stdout.write(JSON.stringify(model, null, 2));
  });
  process.exit(0); // rl keeps event loop alive
}

// Positional: <castleId>
const castleId = args.find(a => !a.startsWith('--'));
if (castleId) {
  const heroDio = HERO_DIORAMAS[castleId];
  if (!heroDio && !flag('random')) {
    // Try as a random seed
    const castle = generateRandomCastle(castleId);
    const model  = buildModel(castle, { validate: flag('validate') });
    process.stdout.write(JSON.stringify(model, null, 2));
    process.exit(0);
  }
  const castle = { id: castleId, name: castleId, diorama: heroDio || {} };
  const model  = buildModel(castle, { validate: flag('validate') });
  process.stdout.write(JSON.stringify(model, null, 2));
  process.exit(0);
}

process.stderr.write('Unknown command. Run without arguments to see usage.\n');
process.exit(1);
