const test = require('node:test');
const assert = require('node:assert/strict');
require('../assets/levels.js');
const { World, intersects } = require('../web/physics.js');
const levels = globalThis.CutRopeLevels;
const run = (w, n) => { for (let i = 0; i < n; i++) w.step(); return w; };
const fixture = objects => ({ box: 1, number: 1, settings: {width:320,height:480}, objects });

test('swipes intersect crossing, endpoint, collinear and tiny segments correctly', () => {
  assert.ok(intersects({x:0,y:5},{x:10,y:5},{x:5,y:0},{x:5,y:10}));
  assert.ok(intersects({x:0,y:0},{x:5,y:0},{x:5,y:0},{x:10,y:0}));
  assert.ok(!intersects({x:0,y:0},{x:2,y:0},{x:5,y:0},{x:10,y:0}));
  assert.ok(!intersects({x:0,y:0},{x:0,y:0},{x:5,y:0},{x:10,y:0}));
});
test('first original level: cut the actual rope, collect all stars, feed Om Nom', () => {
  const w = run(new World(levels[0]), 100);
  assert.equal(w.state, 'playing');
  assert.equal(w.swipe({x:110,y:90},{x:210,y:90}), 1);
  run(w, 240);
  assert.equal(w.state, 'won');
  assert.equal(w.collected, 3);
  const t = w.time; run(w, 100); assert.equal(w.time, t);
});
test('slow swipes composed of subpixel samples still cut the crossed rope', () => {
  const w=new World(levels[0]);
  for(let x=110;x<210;x+=0.5)w.swipe({x,y:90},{x:x+0.5,y:90});
  assert.equal(w.cuts,1);assert.equal(w.ropes.filter(r=>r.active).length,0);
});
test('restarting creates independent star, rope and bubble states', () => {
  const a = new World(levels[0]); a.swipe({x:100,y:90},{x:220,y:90}); run(a,240);
  const b = new World(levels[0]);
  assert.equal(b.collected,0); assert.equal(b.ropes.filter(r=>r.active).length,1);
});
test('automatic hooks catch once and cannot reattach after a cut', () => {
  const w = new World(fixture([{type:'candy',x:160,y:200},{type:'target',x:280,y:430},
    {type:'grab',x:160,y:150,radius:60,length:50}]));
  run(w,2); assert.equal(w.ropes.length,1);
  w.swipe({x:120,y:175},{x:210,y:175}); run(w,2);
  assert.equal(w.ropes.filter(r=>r.active).length,0);
});
test('bubble floats, then popping restores gravity', () => {
  const w = new World(fixture([{type:'candy',x:160,y:300},{type:'target',x:280,y:430},
    {type:'bubble',x:160,y:300}]));
  run(w,60); assert.ok(w.candy.y<280); assert.ok(w.bubble);
  assert.equal(w.tap({x:w.candy.x,y:w.candy.y}), 'bubble');
  run(w,100); assert.ok(w.candy.y>300);
});
test('spikes break candy and emit exactly one terminal event', () => {
  const w = new World(fixture([{type:'candy',x:160,y:100},{type:'target',x:260,y:430},
    {type:'spike2',x:160,y:200,angle:0,size:2}]));
  run(w,180); assert.equal(w.state,'lost');
  assert.equal(w.events.filter(e=>e.type==='lost').length,1);
});
test('size-two spikes use the original 134px sprite collision span', () => {
  const w = new World(fixture([{type:'candy',x:225,y:100},{type:'target',x:280,y:430},
    {type:'spike2',x:160,y:200,angle:0,size:2}]));
  run(w,180);assert.equal(w.state,'lost');assert.match(w.reason,/尖刺/);
});
test('timed stars expire after original timeout plus three seconds', () => {
  const w = new World(fixture([{type:'candy',x:160,y:100},{type:'grab',x:160,y:50,length:50},
    {type:'target',x:280,y:430},{type:'star',x:10,y:10,timeout:1}]));
  run(w,239); assert.ok(!w.stars[0].expired);
  run(w,2); assert.ok(w.stars[0].expired);
});
test('pumps only apply their impulse within the directional air corridor', () => {
  const w = new World(fixture([{type:'candy',x:160,y:200},{type:'target',x:280,y:430},
    {type:'pump',x:60,y:200,angle:0}]));
  assert.equal(w.tap({x:60,y:200}),'pump'); run(w,5); assert.ok(w.candy.x>170);
});
test('all 50 original levels remain finite and have three stars', () => {
  assert.equal(levels.length,50);
  for (const l of levels) {
    const w=run(new World(l),1800);
    assert.equal(w.stars.length,3);
    assert.ok(Number.isFinite(w.candy.x)&&Number.isFinite(w.candy.y),l.source);
    assert.ok(w.ropes.every(r=>r.nodes.every(p=>Number.isFinite(p.x)&&Number.isFinite(p.y))),l.source);
  }
});
