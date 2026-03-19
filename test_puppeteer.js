const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ args: ['--no-sandbox'] });
  const page = await browser.newPage();
  page.on('console', msg => console.log('PAGE LOG:', msg.text()));
  page.on('pageerror', err => console.log('PAGE ERROR:', err.toString()));
  
  await page.goto('file:///Users/jb3/__JB3_ADDs/000_AI/_AI_CLAUDE/AI-CLAUDE-001/video-app.html', {waitUntil: 'networkidle2'});
  
  await page.evaluate(() => {
    window.addVideo('https://www.pexels.com/download/video/19414358/', 'Pexels Cat');
    window.loadVideo(0);
  });
  
  await page.waitForTimeout(3000);
  await browser.close();
})();
