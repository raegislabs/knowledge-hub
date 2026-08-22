// prose-detect.mjs — score text for AI-writing tells that a regex lint cannot see
// (hashtag stuffing, stylometry, vocabulary-tier density, tool fingerprints).
// Engine: conorbronsdon/avoid-ai-writing detector (MIT) vendored as prose-patterns.js.
// usage: node prose-detect.mjs FILE [--json]
import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
const require = createRequire(import.meta.url);
const D = require(resolve(dirname(fileURLToPath(import.meta.url)), 'prose-patterns.js'));
const file = process.argv[2];
if (!file) { console.error('usage: prose-detect.mjs FILE [--json]'); process.exit(2); }
const r = D.analyzeText(readFileSync(file, 'utf8'));
const out = { score: r.score, label: r.label, issues: r.issues.length, wordCount: r.stats?.wordCount,
  byType: r.issues.reduce((a, i) => (a[i.type] = (a[i.type] || 0) + 1, a), {}),
  examples: r.issues.slice(0, 8).map(i => ({ type: i.type, text: String(i.text || '').slice(0, 60) })) };
if (process.argv.includes('--json')) { console.log(JSON.stringify(out, null, 2)); }
else {
  console.log(`detector: score ${out.score}/100 (${out.label}), ${out.issues} issues, ${out.wordCount} words`);
  for (const [t, n] of Object.entries(out.byType)) console.log(`  ${n}x ${t}`);
  for (const e of out.examples) console.log(`  - [${e.type}] ${e.text}`);
}
process.exit(out.score >= 25 ? 1 : 0);
