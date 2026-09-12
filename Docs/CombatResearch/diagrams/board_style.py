"""Editable SVG primitives for the combat diagram sample. Coordinates are design pixels."""
from pathlib import Path
from html import escape
import json, math

OUT=Path(__file__).parent
C={'bg':'#F5F3ED','paper':'#FFFFFF','ink':'#22302D','muted':'#68736E','line':'#D9DFD6','teal':'#187A75','tealbg':'#E7F3F0','amber':'#B37024','amberbg':'#FBF0DC','red':'#B84243','redbg':'#FBE8E6','green':'#477754','greenbg':'#EAF2E7','purple':'#775D9C','purplebg':'#F0EBF7'}

class Board:
    def __init__(self,name,w=1600,h=1400):
        self.name=name; self.w=w; self.h=h; self.shapes=[]; self.texts=[]
        self.rect(0,0,w,h,C['bg'],r=0)
    def rect(self,x,y,w,h,fill='white',stroke=None,r=14,sw=2):
        self.shapes.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>')
    def path(self,d,color=None,sw=3,dash=False,fill='none'):
        self.shapes.append(f'<path d="{d}" fill="{fill}" stroke="{color or C["muted"]}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"'+(' stroke-dasharray="9 7"' if dash else '')+'/>')
    def arrow(self,pts,color=None,dash=False,sw=3):
        col=color or C['muted']; self.path('M '+' L '.join(f'{x},{y}' for x,y in pts),col,sw,dash)
        x,y=pts[-1]; a,b=pts[-2]; angle=math.atan2(y-b,x-a)
        p1=(x-10*math.cos(angle)+5*math.sin(angle),y-10*math.sin(angle)-5*math.cos(angle))
        p2=(x-10*math.cos(angle)-5*math.sin(angle),y-10*math.sin(angle)+5*math.cos(angle))
        self.path(f'M {p1[0]},{p1[1]} L {x},{y} L {p2[0]},{p2[1]}',col,sw)
    def circle(self,x,y,r,fill,stroke=None,sw=2):
        self.shapes.append(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>')
    def text(self,x,y,s,size=24,color=None,weight=400,align='left',width=None,lineheight=None):
        # y is the top of the first line, not its baseline.
        self.texts.append(dict(x=x,y=y,text=s,size=size,color=color or C['ink'],weight=weight,align=align,width=width,lineheight=lineheight or size*1.4))
    def card(self,x,y,w,h,title,body='',tone='teal',title_size=25,body_size=21):
        self.rect(x,y,w,h,C[tone+'bg'],None,16)
        self.rect(x,y,5,h,C[tone],None,2)
        self.text(x+22,y+17,title,title_size,C[tone],600)
        if body: self.text(x+22,y+57,body,body_size,C['ink'],lineheight=body_size*1.48)
    def diamond(self,cx,cy,w,h,title,body=''):
        self.path(f'M {cx},{cy-h/2} L {cx+w/2},{cy} L {cx},{cy+h/2} L {cx-w/2},{cy} Z',C['teal'],2,False,C['tealbg'])
        self.text(cx,cy-(29 if body else 16),title,24,C['teal'],600,'center')
        if body:self.text(cx,cy+8,body,19,C['muted'],400,'center')
    def panel(self,x,y,w,h,num,title,subtitle=''):
        self.rect(x,y,w,h,C['paper'],C['line'],22)
        self.text(x+24,y+20,num,20,C['teal'],600)
        self.text(x+67,y+16,title,29,C['ink'],600)
        if subtitle:self.text(x+24,y+64,subtitle,21,C['muted'])
    def header(self,num,title,subtitle,meta):
        self.text(56,36,'SILKSONG / COMBAT ATLAS',20,C['teal'],600)
        self.text(56,78,title,48,C['ink'],600)
        self.text(56,145,subtitle,26,C['muted'])
        self.text(1544,38,num,48,C['teal'],600,'right')
        self.text(1544,106,meta,20,C['muted'],400,'right')
        for x,tone,label in [(56,'teal','状态 / 判断'),(286,'amber','前摇 / 预告'),(516,'red','伤害窗口'),(746,'green','收招 / 恢复'),(976,'purple','独立控制器')]:
            self.rect(x,204,16,16,C[tone],r=4);self.text(x+26,198,label,20,C['muted'])
        self.path('M 1235,213 L 1280,213',C['muted'],2,True)
        self.text(1293,198,'跨对象事件',20,C['muted'])
    def footer(self,source,note='关键战斗分支折叠图 · 静态源数据核对 · 非运行录像实测'):
        self.path(f'M 56,{self.h-88} L 1544,{self.h-88}',C['line'],2)
        self.text(56,self.h-69,note,19,C['muted'])
        self.text(56,self.h-38,source,17,C['muted'])
    def save(self):
        defs='<style>text{font-family:"PingFang SC","Noto Sans CJK SC","Microsoft YaHei",sans-serif}</style>'
        base=f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.w}" height="{self.h}" viewBox="0 0 {self.w} {self.h}"><title>{escape(self.name)}</title>{defs}'
        tx=[]
        for t in self.texts:
            anchor={'left':'start','center':'middle','right':'end'}[t['align']]
            spans=''.join(f'<tspan x="{t["x"]}" y="{t["y"]+t["size"]+i*t["lineheight"]}">{escape(s)}</tspan>' for i,s in enumerate(t['text'].split('\n')))
            tx.append(f'<text fill="{t["color"]}" font-size="{t["size"]}" font-weight="{t["weight"]}" text-anchor="{anchor}">{spans}</text>')
        (OUT/f'{self.name}.svg').write_text(base+''.join(self.shapes)+''.join(tx)+'</svg>')
        (OUT/f'{self.name}-geometry.svg').write_text(base+''.join(self.shapes)+'</svg>')
        (OUT/f'{self.name}.json').write_text(json.dumps(dict(name=self.name,width=self.w,height=self.h,texts=self.texts),ensure_ascii=False,indent=2))
