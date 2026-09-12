const { chromium } = require('/Users/mars/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs = require('fs');
const path = require('path');
(async () => {
  const browser = await chromium.launch({executablePath:'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',headless:true});
  const page = await browser.newPage({viewport:{width:1600,height:1400},deviceScaleFactor:1});
  for (const name of process.argv.slice(2)) {
    const filepath=path.join(__dirname,name+'.svg');
    await page.setContent('<html><body style="margin:0">'+fs.readFileSync(filepath,'utf8')+'</body></html>');
    const layout = await page.evaluate(() => {
      const texts=[...document.querySelectorAll('svg text')].map(n=>({text:n.textContent,box:n.getBoundingClientRect().toJSON()}));
      const outside=texts.filter(n=>n.box.left<0||n.box.top<0||n.box.right>1600||n.box.bottom>1400);
      const overlaps=[];
      for(let i=0;i<texts.length;i++) for(let j=i+1;j<texts.length;j++) {
        const a=texts[i].box,b=texts[j].box;
        if(Math.min(a.right,b.right)-Math.max(a.left,b.left)>3 && Math.min(a.bottom,b.bottom)-Math.max(a.top,b.top)>3) overlaps.push([texts[i].text,texts[j].text]);
      }
      return {outside:outside.map(n=>n.text),overlaps};
    });
    await page.screenshot({path:path.join(__dirname,name+'.png')});
    console.log(JSON.stringify({name,...layout}));
  }
  await browser.close();
})();
