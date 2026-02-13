'use strict';

const COMMANDS = {
  init:          { desc: 'Initialize agent config in current project', node: true },
  update:        { desc: 'Update sync scripts to latest version', node: true },
  sync:          { desc: 'Sync to agents (default: all)', shell: 'all' },
  reverse:       { desc: 'Reverse sync from agents to unified dir', shell: 'reverse' },
  validate:      { desc: 'Validate directory structure and content', shell: 'validate' },
  'check-size':  { desc: 'Check prompt file sizes and token counts', shell: 'check-size' },
  'check-quality': { desc: 'Check prompt quality and best practices', shell: 'check-quality' },
  plugins:       { desc: 'Sync Claude Code plugins', shell: 'plugins' },
  clean:         { desc: 'Remove all generated files', shell: 'clean' },
  'install-hooks': { desc: 'Install git pre-commit hook', shell: 'install-hooks' },
  prune:         { desc: 'Remove a file and all synced copies', shell: 'prune' },
};

function printHelp() {
  const pkg = require('../package.json');
  const lines = [
    `${pkg.name} v${pkg.version}`,
    '',
    'Usage: aao <command> [options]',
    '',
    'Commands:',
  ];

  for (const [name, cmd] of Object.entries(COMMANDS)) {
    lines.push(`  ${name.padEnd(18)} ${cmd.desc}`);
  }

  lines.push('');
  lines.push('Sync sub-commands:');
  lines.push('  sync                 Sync to all agents');
  lines.push('  sync claude          Sync to Claude Code only');
  lines.push('  sync copilot         Sync to GitHub Copilot only');
  lines.push('');
  lines.push('Reverse sub-commands:');
  lines.push('  reverse              Reverse sync from all agents');
  lines.push('  reverse claude       Reverse sync from Claude Code');
  lines.push('  reverse copilot      Reverse sync from GitHub Copilot');
  lines.push('');
  lines.push('Init options:');
  lines.push('  --dir <name>         Unified folder name (default: .agents)');
  lines.push('  --agents <list>      Comma-separated agents: claude,copilot');
  lines.push('');
  lines.push('Global options:');
  lines.push('  --verbose            Show detailed output');
  lines.push('  --dry-run            Show what would be done');
  lines.push('  -h, --help           Show this help message');
  lines.push('  -v, --version        Show version number');

  console.log(lines.join('\n'));
}

function printVersion() {
  const pkg = require('../package.json');
  console.log(pkg.version);
}

module.exports = { COMMANDS, printHelp, printVersion };
