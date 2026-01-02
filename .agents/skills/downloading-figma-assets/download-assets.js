#!/usr/bin/env node
/**
 * Figma Asset Downloader
 *
 * Downloads assets from Figma MCP asset URLs.
 *
 * Usage:
 *   node download-assets.js <output-dir> [--fix-svg]
 *
 * The script reads asset URLs from stdin as JSON:
 *   echo '{"home": "https://www.figma.com/api/mcp/asset/xxx"}' | node download-assets.js ./icons
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

function download(url, filepath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(filepath);
    https.get(url, (res) => {
      if (res.statusCode === 302 || res.statusCode === 301) {
        file.close();
        fs.unlinkSync(filepath);
        download(res.headers.location, filepath).then(resolve).catch(reject);
        return;
      }
      if (res.statusCode !== 200) {
        file.close();
        reject(new Error(`HTTP ${res.statusCode}`));
        return;
      }
      res.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve();
      });
    }).on('error', (err) => {
      file.close();
      fs.unlinkSync(filepath);
      reject(err);
    });
  });
}

function detectExtension(filepath) {
  const content = fs.readFileSync(filepath, 'utf8').slice(0, 100);
  if (content.includes('<svg')) return '.svg';
  if (content.slice(0, 8).includes('PNG')) return '.png';
  if (content.slice(0, 3) === '\xff\xd8\xff') return '.jpg';
  return '.bin';
}

function fixSvgFill(filepath) {
  let content = fs.readFileSync(filepath, 'utf8');
  const original = content;

  // Replace CSS variable fills with currentColor
  content = content.replace(/fill="var\(--fill-\d+,\s*white\)"/g, 'fill="currentColor"');
  content = content.replace(/fill="var\(--fill-\d+,\s*#[a-fA-F0-9]+\)"/g, 'fill="currentColor"');

  if (content !== original) {
    fs.writeFileSync(filepath, content);
    return true;
  }
  return false;
}

async function main() {
  const args = process.argv.slice(2);
  const outDir = args[0] || './assets';
  const fixSvg = args.includes('--fix-svg');

  // Read JSON from stdin
  let input = '';
  process.stdin.setEncoding('utf8');

  for await (const chunk of process.stdin) {
    input += chunk;
  }

  let assets;
  try {
    assets = JSON.parse(input);
  } catch (e) {
    console.error('Error: Invalid JSON input');
    console.error('Usage: echo \'{"name": "url"}\' | node download-assets.js <output-dir>');
    process.exit(1);
  }

  fs.mkdirSync(outDir, { recursive: true });

  for (const [name, url] of Object.entries(assets)) {
    const tempPath = path.join(outDir, name + '.tmp');

    try {
      await download(url, tempPath);

      // Detect actual file type
      const ext = detectExtension(tempPath);
      const finalPath = path.join(outDir, name + ext);

      fs.renameSync(tempPath, finalPath);

      // Fix SVG fills if requested
      if (fixSvg && ext === '.svg') {
        const fixed = fixSvgFill(finalPath);
        console.log(`Downloaded: ${name}${ext}${fixed ? ' (fill fixed)' : ''}`);
      } else {
        console.log(`Downloaded: ${name}${ext}`);
      }
    } catch (e) {
      console.error(`Failed: ${name} - ${e.message}`);
      if (fs.existsSync(tempPath)) {
        fs.unlinkSync(tempPath);
      }
    }
  }
}

main();
