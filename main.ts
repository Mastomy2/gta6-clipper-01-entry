// gta6-clipper-01 entry (Node 22, standard library only): it copies VIDEO.json from the repository root to
// /output/VIDEO.json, where the gate reads it. That is all the program has to do. The entry is the video itself:
// a 48-second vertical GTA 6 clip (1080x1920) cut in-session from Kai Cenat's first GTA 6 stream on Twitch
// (VOD 2932305259): Kai blows up a gas station and hits 6 stars, steals a sheriff SUV and escapes, then the
// clip pitches make.fun on screen ("Make clips like this with AI and earn money on make.fun" +
// "make.fun/bounty/gta6-clipper-01"). The clip goes up on YouTube as a public Short with the bounty's line
// and the play code in its description, and VIDEO.json names the video. Nothing this program writes about
// the video is scored.
//
// The VIDEO.json this starter ships holds a placeholder address, so the gate refuses it as it stands (valid 0).
// Replace it with your video's address before you submit.
//
// Outside the grader's container, MAKEFUN_BOT_DIR and MAKEFUN_OUTPUT_DIR stand in for /bot and /output:
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, mkdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const BOT_DIR = process.env.MAKEFUN_BOT_DIR ?? '/bot';
const OUTPUT_DIR = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const videoPath = join(BOT_DIR, 'VIDEO.json');

mkdirSync(OUTPUT_DIR, { recursive: true });
try {
  copyFileSync(videoPath, join(OUTPUT_DIR, 'VIDEO.json'));
} catch (err) {
  console.error(`VIDEO.json could not be copied from ${BOT_DIR}: ${(err as Error).message}`);
  process.exit(1);
}

// Say which video this entry hands in, and warn while it is still the placeholder.
// A VIDEO.json that is not JSON, or has no url string, is a broken entry: stop loudly.
let video: { url?: unknown };
try {
  video = JSON.parse(readFileSync(join(OUTPUT_DIR, 'VIDEO.json'), 'utf8')) as { url?: unknown };
} catch (err) {
  console.error(`VIDEO.json is not valid JSON: ${(err as Error).message}`);
  process.exit(1);
}
if (typeof video.url !== 'string' || video.url.length === 0) {
  console.error('VIDEO.json has no url; put the uploaded clip address in VIDEO.json.');
  process.exit(1);
}
if (video.url.includes('<id>')) {
  console.error('VIDEO.json still holds the placeholder address; upload the clip to YouTube, then put its address in VIDEO.json.');
} else {
  console.log(`gta6-clipper-01 entry video: ${video.url}`);
}
