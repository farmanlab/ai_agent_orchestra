#!/usr/bin/env node
/**
 * Image Comparison Tool
 *
 * Compares two images and outputs difference metrics.
 *
 * Usage:
 *   node compare.js <image1> <image2> [diff-output]
 *
 * Examples:
 *   node compare.js html_screenshot.png figma_screenshot.png
 *   node compare.js html.png figma.png diff.png
 */

const fs = require('fs');
const path = require('path');
const { PNG } = require('pngjs');
const pixelmatch = require('pixelmatch');

function padImage(img, targetWidth, targetHeight) {
  const padded = new PNG({ width: targetWidth, height: targetHeight });
  // Fill with white background
  for (let i = 0; i < padded.data.length; i += 4) {
    padded.data[i] = 255;     // R
    padded.data[i + 1] = 255; // G
    padded.data[i + 2] = 255; // B
    padded.data[i + 3] = 255; // A
  }
  // Copy original image
  for (let y = 0; y < img.height; y++) {
    for (let x = 0; x < img.width; x++) {
      const srcIdx = (y * img.width + x) * 4;
      const dstIdx = (y * targetWidth + x) * 4;
      padded.data[dstIdx] = img.data[srcIdx];
      padded.data[dstIdx + 1] = img.data[srcIdx + 1];
      padded.data[dstIdx + 2] = img.data[srcIdx + 2];
      padded.data[dstIdx + 3] = img.data[srcIdx + 3];
    }
  }
  return padded;
}

async function compareImages(img1Path, img2Path, diffPath) {
  // Read images
  let img1 = PNG.sync.read(fs.readFileSync(img1Path));
  let img2 = PNG.sync.read(fs.readFileSync(img2Path));

  // Check dimensions and pad if necessary
  if (img1.width !== img2.width || img1.height !== img2.height) {
    console.log(`Warning: Image dimensions differ`);
    console.log(`  Image 1: ${img1.width}x${img1.height}`);
    console.log(`  Image 2: ${img2.width}x${img2.height}`);

    // Resize to larger dimensions for comparison
    const width = Math.max(img1.width, img2.width);
    const height = Math.max(img1.height, img2.height);

    console.log(`  Comparing at: ${width}x${height} (padding smaller image)`);

    // Pad images to same size
    if (img1.width !== width || img1.height !== height) {
      img1 = padImage(img1, width, height);
    }
    if (img2.width !== width || img2.height !== height) {
      img2 = padImage(img2, width, height);
    }
  }

  const { width, height } = img1;
  const diff = new PNG({ width, height });

  // Compare pixels
  const numDiffPixels = pixelmatch(
    img1.data,
    img2.data,
    diff.data,
    width,
    height,
    {
      threshold: 0.1,
      includeAA: false,
      alpha: 0.1,
      diffColor: [255, 0, 0],
      diffColorAlt: [0, 255, 0]
    }
  );

  const totalPixels = width * height;
  const diffPercentage = ((numDiffPixels / totalPixels) * 100).toFixed(2);

  console.log(`\nComparison Results:`);
  console.log(`  Total pixels: ${totalPixels.toLocaleString()}`);
  console.log(`  Different pixels: ${numDiffPixels.toLocaleString()}`);
  console.log(`  Difference: ${diffPercentage}%`);

  if (diffPercentage === '0.00') {
    console.log(`\n✅ PIXEL PERFECT - Images are identical!`);
  } else if (parseFloat(diffPercentage) < 1) {
    console.log(`\n🟡 NEARLY PERFECT - Minor differences (< 1%)`);
  } else if (parseFloat(diffPercentage) < 5) {
    console.log(`\n🟠 NOTICEABLE - Some differences detected`);
  } else {
    console.log(`\n🔴 SIGNIFICANT - Major differences detected`);
  }

  // Save diff image if path provided
  if (diffPath) {
    fs.writeFileSync(diffPath, PNG.sync.write(diff));
    console.log(`\nDiff image saved: ${diffPath}`);
  }

  return {
    totalPixels,
    numDiffPixels,
    diffPercentage: parseFloat(diffPercentage),
    pixelPerfect: numDiffPixels === 0
  };
}

// Main
const args = process.argv.slice(2);

if (args.length < 2) {
  console.log(`
Image Comparison Tool

Usage:
  node compare.js <image1> <image2> [diff-output]

Examples:
  node compare.js html_screenshot.png figma_screenshot.png
  node compare.js html.png figma.png diff.png

Output:
  Prints pixel difference statistics and optionally saves a diff image
  where red pixels indicate differences.
  `);
  process.exit(0);
}

compareImages(args[0], args[1], args[2])
  .catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
  });
