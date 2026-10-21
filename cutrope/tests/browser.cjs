/* Dev-only QA: NODE_PATH=/path/to/node_modules node tests/browser.cjs */
const {chromium}=require('playwright');
const {spawn}=require('node:child_process');
const path=require('node:path');
const fs=require('node:fs');
const assert=require('node:assert/strict');
const {pathToFileURL}=require('node:url');
const root=path.resolve(__dirname,'..'),out=path.join(root,'analysis');
const chrome=process.env.CHROME_PATH||'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const report={checks:[],consoleErrors:[],pageErrors:[],networkFailures:[],screenshots:[],pixels:{}};
const check=(name,condition)=>{assert.ok(condition,name);report.checks.push(name);console.log('PASS',name);};
const screenshot=async(page,name)=>{await page.screenshot({path:path.join(out,name),fullPage:true});report.screenshots.push(name);};
const pixels=page=>page.evaluate(()=>{
  const c=document.querySelector('canvas'),data=c.getContext('2d').getImageData(0,0,c.width,c.height).data;
  let colored=0;for(let i=0;i<data.length;i+=4)if(data[i]+data[i+1]+data[i+2]>30&&data[i+3]>0)colored++;
  return colored/(c.width*c.height);
});
async function main(){
  const server=spawn(process.env.PYTHON||'python3',[path.join(out,'serve.py'),'--port','0'],{stdio:['ignore','pipe','pipe']});
  let browser;
  try{
    const url=await new Promise((resolve,reject)=>{
      const timeout=setTimeout(()=>reject(new Error('Static server did not start')),10000);
      server.stdout.once('data',data=>{clearTimeout(timeout);resolve(data.toString().trim());});
      server.once('error',reject);
    });
    browser=await chromium.launch({headless:true,...(fs.existsSync(chrome)?{executablePath:chrome}:{})});
    const context=await browser.newContext({viewport:{width:1440,height:1050}});
    const page=await context.newPage();
    page.on('pageerror',e=>report.pageErrors.push(String(e)));
    page.on('requestfailed',r=>report.networkFailures.push({url:r.url(),failure:r.failure()}));
    page.on('console',msg=>{if(msg.type()==='error')report.consoleErrors.push(msg.text());});
    await page.goto(url);await page.waitForFunction(()=>window.cutrope?.mode==='ready');
    await page.waitForTimeout(700);
    check('initial scene renders behind start card',await page.evaluate(()=>cutrope.world.ropes.length===1&&cutrope.renderer.errors.length===0));
    report.pixels.initial=await pixels(page);check('initial canvas >=90% colored',report.pixels.initial>=.9);
    await screenshot(page,'screen_initial.png');
    report.performance=await page.evaluate(async()=>{
      const times=[],draws=[];
      for(let i=0;i<61;i++)await new Promise(resolve=>requestAnimationFrame(t=>{
        times.push(t);const start=performance.now();cutrope.renderer.draw(cutrope.world,t);draws.push(performance.now()-start);resolve();
      }));
      draws.sort((a,b)=>a-b);return {observedFps:60000/(times[60]-times[0]),renderP95Ms:draws[Math.floor(draws.length*.95)]};
    });
    check('scene draw fits the 16.7ms frame budget',report.performance.renderP95Ms<16.7);
    await page.locator('#primaryBtn').click();await page.waitForTimeout(200);
    await screenshot(page,'screen_gameplay.png');
    const swipe=await page.evaluate(()=>{
      const r=cutrope.world.ropes[0],a=r.nodes[0],b=r.nodes[1],p={x:(a.x+b.x)/2,y:(a.y+b.y)/2};
      const q=cutrope.renderer.toScreen(p),rect=gameCanvas.getBoundingClientRect();
      return {x:q.x+rect.left,y:q.y+rect.top};
    });
    await page.mouse.move(swipe.x-55,swipe.y);await page.mouse.down();await page.mouse.move(swipe.x+55,swipe.y,{steps:12});await page.mouse.up();
    await page.waitForFunction(()=>cutrope.world.state==='won',null,{timeout:12000});
    check('real pointer swipe cuts rope and earns three stars',await page.evaluate(()=>cutrope.world.cuts===1&&cutrope.world.collected===3));
    await page.waitForTimeout(800);check('success overlay appears',await page.locator('#overlay').isVisible());
    await screenshot(page,'screen_win.png');
    await page.locator('#primaryBtn').click();await page.waitForTimeout(500);
    check('next button enters original level 1-2',await page.evaluate(()=>cutrope.index===1&&cutrope.world.ropes.length===3));
    report.pixels.stage2=await pixels(page);await screenshot(page,'screen_stage2.png');
    await page.locator('#pauseBtn').click();
    const before=await page.evaluate(()=>({x:cutrope.world.candy.x,y:cutrope.world.candy.y,time:cutrope.world.time}));
    await page.waitForTimeout(400);
    check('pause freezes physics',await page.evaluate(b=>cutrope.mode==='paused'&&cutrope.world.candy.x===b.x&&cutrope.world.candy.y===b.y&&cutrope.world.time===b.time,before));
    await page.locator('#primaryBtn').click();await page.locator('#restartBtn').click();
    check('restart clears cuts and stars',await page.evaluate(()=>cutrope.world.cuts===0&&cutrope.world.collected===0));
    await page.locator('#levelsBtn').click();await page.locator('[data-select-box="2"]').click();
    check('second chapter has all 25 selectable levels',await page.locator('#levelGrid button').count()===25);
    await page.locator('#levelGrid button').first().click();
    check('chapter selection loads original pumps',await page.evaluate(()=>cutrope.index===25&&cutrope.world.pumps.length===3));
    // Decode original sounds independently; catches bad DefineSound seek offsets.
    const sounds=JSON.parse(fs.readFileSync(path.join(root,'assets/manifest.json'))).sounds.map(s=>s.file);
    const decoded=await page.evaluate(async names=>{
      const ctx=new AudioContext();let done=0;
      for(let i=0;i<names.length;i+=4)await Promise.all(names.slice(i,i+4).map(async name=>{
        const res=await fetch('assets/audio/'+name),b=await ctx.decodeAudioData(await res.arrayBuffer());
        if(b.length>0)done++;
      }));
      await ctx.close();return done;
    },sounds);
    check('all 32 original MP3 sounds decode',decoded===32);
    const audioLifecycle=await page.evaluate(async()=>{
      const s=new CutRopeMedia.Sound();s.enabled=true;s.unlock();
      const buffer=s.context.createBuffer(1,s.context.sampleRate*3,s.context.sampleRate);
      s.buffers.set('probe',buffer);await s.play('probe');
      const source=s.sources.values().next().value;let stopped=false;
      source.addEventListener('ended',()=>{stopped=true;});s.setEnabled(false);
      await new Promise(resolve=>setTimeout(resolve,80));
      const muted=stopped&&s.sources.size===0;
      s.enabled=true;
      const pending=s.play('probe');s.suspend();await pending;
      const deferred=s.sources.size===0;
      s.suspend();s.setEnabled(true);await new Promise(resolve=>setTimeout(resolve,80));
      const paused=s.paused&&s.context.state==='suspended'&&(!s.music||s.music.paused);
      s.setEnabled(false);await s.context.close();return {muted,paused,deferred};
    });
    check('muting stops active Web Audio sources',audioLifecycle.muted);
    check('sound toggle cannot escape a game pause',audioLifecycle.paused);
    check('late audio completion cannot start a paused effect',audioLifecycle.deferred);
    await page.reload();await page.waitForFunction(()=>window.cutrope?.mode==='ready');
    check('best stars survive reload',await page.evaluate(()=>JSON.parse(localStorage.getItem('atb-cutrope-v1')).scores[0]===3));
    // Every map is instantiated and rendered, including tall/wide camera maps.
    const rendered=await page.evaluate(()=>{
      for(let i=0;i<50;i++){
        cutrope.loadLevel(i,false);
        for(let j=0;j<120;j++)cutrope.world.step();
        cutrope.renderer.draw(cutrope.world);
        if(cutrope.world.stars.length!==3)throw new Error('Invalid map '+i);
      }
      cutrope.loadLevel(0,false);return 50;
    });
    check('all 50 maps initialize and render',rendered===50);
    await page.waitForTimeout(300);await context.close();
    // Touchscreen interaction using real CDP touch input.
    const mobile=await browser.newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true,deviceScaleFactor:2});
    const mp=await mobile.newPage();mp.on('pageerror',e=>report.pageErrors.push(String(e)));
    await mp.goto(url);await mp.locator('#primaryBtn').tap();await mp.waitForTimeout(250);
    const touch=await mp.evaluate(()=>{
      const r=cutrope.world.ropes[0],p=cutrope.renderer.toScreen({x:r.nodes[0].x,y:(r.nodes[0].y+r.nodes[1].y)/2}),rect=gameCanvas.getBoundingClientRect();
      return {x:p.x+rect.left,y:p.y+rect.top};
    });
    const cdp=await mobile.newCDPSession(mp);
    await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:touch.x-45,y:touch.y}]});
    for(let i=1;i<=10;i++)await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x:touch.x-45+i*9,y:touch.y}]});
    await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    await mp.waitForFunction(()=>cutrope.world.cuts===1,null,{timeout:2000});
    check('touch swipe cuts the rope',await mp.evaluate(()=>cutrope.world.cuts===1));
    await mp.locator('#restartBtn').tap();await mp.waitForTimeout(200);
    const slow=await mp.evaluate(()=>{
      const r=cutrope.world.ropes[0],p=cutrope.renderer.toScreen({x:r.nodes[0].x,y:(r.nodes[0].y+r.nodes[1].y)/2}),rect=gameCanvas.getBoundingClientRect();
      return {x:p.x+rect.left,y:p.y+rect.top};
    });
    await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:slow.x-10,y:slow.y}]});
    for(let i=1;i<=80;i++)await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x:slow.x-10+i*.25,y:slow.y}]});
    await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    await mp.waitForFunction(()=>cutrope.world.cuts===1,null,{timeout:2000});
    check('subpixel touch samples still cut a rope',await mp.evaluate(()=>cutrope.world.cuts===1));
    check('390px viewport has no horizontal overflow',await mp.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
    report.pixels.mobile=await pixels(mp);await screenshot(mp,'screen_mobile.png');
    await mobile.close();
    // Direct-file protocol: classic scripts, level data, original art, real win.
    const file=await browser.newPage({viewport:{width:1100,height:950}});
    file.on('pageerror',e=>report.pageErrors.push(String(e)));
    await file.goto(pathToFileURL(path.join(root,'web/index.html')).href);await file.waitForFunction(()=>window.cutrope?.mode==='ready');await file.waitForTimeout(500);
    check('file protocol loads valid scene and images',await file.evaluate(()=>CutRopeMedia.isImgValid(cutrope.assets.image(339))));
    await file.locator('#primaryBtn').click();await file.locator('#accessibleActions button').first().click();
    await file.waitForFunction(()=>cutrope.world.state==='won',null,{timeout:12000});
    // Chrome marks file-origin image canvases as tainted. Pixel readback is
    // asserted on HTTP and fallback; file rendering is verified by screenshot.
    await screenshot(file,'screen_file.png');check('file protocol gameplay completes',await file.evaluate(()=>cutrope.world.collected===3));
    check('file audio effects stop on pause',await file.evaluate(async()=>{
      const s=new CutRopeMedia.Sound();s.enabled=true;s.unlock();await s.play('Win');
      const audio=s.pool[0];s.suspend();const paused=audio.paused&&s.pool.length===0;
      s.setEnabled(false);await s.context?.close();return paused;
    }));
    await file.close();
    // A delayed retry must initialize exactly once, after the new script loads.
    const retry=await browser.newPage();let dataRequests=0;
    await retry.route('**/assets/levels.js',async route=>{
      dataRequests++;if(dataRequests===1)return route.abort();
      await new Promise(resolve=>setTimeout(resolve,450));return route.continue();
    });
    await retry.goto(url);await retry.waitForFunction(()=>window.cutrope?.mode==='ready');
    check('failed level script retries and waits before initialization',dataRequests===2&&await retry.evaluate(()=>CutRopeLevels.length===50));
    await retry.close();
    const noData=await browser.newPage();await noData.route('**/assets/levels.js',r=>r.abort());await noData.goto(url);
    await noData.waitForFunction(()=>document.querySelector('#primaryBtn').disabled);
    check('unavailable level data shows an explicit recovery message',await noData.locator('#overlayTitle').textContent()==='关卡资源未能载入');
    await noData.close();
    // Missing image fallback is tested in an isolated context: expected HTTP 404s
    // must not be mixed with the zero-error acceptance run above.
    const faulty=await browser.newPage({viewport:{width:1100,height:900}});
    const fallbackErrors=[];faulty.on('pageerror',e=>fallbackErrors.push(String(e)));
    await faulty.route('**/assets/images/**',r=>r.abort());await faulty.goto(url);await faulty.waitForFunction(()=>window.cutrope);
    await faulty.waitForTimeout(900);report.pixels.fallback=await pixels(faulty);
    check('missing art keeps canvas colored and game operational',report.pixels.fallback>=.9&&await faulty.evaluate(()=>cutrope.renderer.errors.length===0));
    await faulty.locator('#primaryBtn').click();await faulty.locator('#accessibleActions button').first().click();
    await faulty.waitForFunction(()=>cutrope.world.state==='won',null,{timeout:12000});
    check('fallback gameplay wins with no uncaught exception',fallbackErrors.length===0);
    check('normal browser console has zero errors',report.consoleErrors.length===0);
    check('all normal contexts have zero uncaught exceptions',report.pageErrors.length===0);
    check('all captured canvases >=90% colored',Object.values(report.pixels).every(r=>r>=.9));
    report.result='passed';report.checkedAt=new Date().toISOString();
    fs.writeFileSync(path.join(out,'browser-verification.json'),JSON.stringify(report,null,2));
    console.log(JSON.stringify(report,null,2));
  }finally{await browser?.close();server.kill();}
}
main().catch(error=>{report.result='failed';report.failure=String(error);fs.writeFileSync(path.join(out,'browser-verification.json'),JSON.stringify(report,null,2));console.error(error);process.exitCode=1;});
