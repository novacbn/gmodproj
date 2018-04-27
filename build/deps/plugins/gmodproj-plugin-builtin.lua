return(function(d,...)local e=_G
local a=e.error
local n=e.loadstring
local r=e.setfenv
local o=e.setmetatable
local l={}local c={}local function i(l)local n={}local e=o({},{__index=function(l,t)if n[t]~=nil then
return n[t]end
return e[t]end,__newindex=n})return r(l,e),n
end
local function r(e)return{name=e,globals=c}end
local function c(e)return o({},{__index=e,__newindex=function(e,e,e)a("module 'exports' table is read only")end})end
local n=nil
function n(e,...)local t=d[e]if not t then a("bad argument #1 to 'import' (invalid module, got '"..e.."')")end
if not l[e]then
local o=r(e)local a,t=i(t)a(o,t,n,n,...)l[e]=c(t)end
return l[e]end
return n('novacbn/gmodproj-plugin-builtin/Plugin',...)end)({['jonstoler/toml/main']=function(e,e,e,e,...)version=.4
strict=true
function parse(d,e)e=e or{}local i=(e.strict~=nil and e.strict or strict)local s="[\t ]"local o="[\n"do
local e="\r\n"o=o..e
end
o=o.."]"local t=""local r=1
local h={}local l=h
local function e(e)e=e or 0
return d:sub(r+e,r+e)end
local function n(e)e=e or 1
r=r+e
end
local function c()while(e():match(s))do
n()end
end
local function m(e)return e:gsub("^%s*(.-)%s*$","%1")end
local function a(l,e)if l==""then return{}end
local t={}local n=e
if e:match("%%")then
n=e:gsub("%%","")end
for e in(l..n):gmatch("(.-)"..e)do
table.insert(t,e)end
return t
end
local function a(l,e)if not e or(e and i)then
local n=1
local e=0
for t in d:gmatch("(.-)"..o)do
e=e+t:len()if e>=r then
break
end
n=n+1
end
error("TOML: "..l.." on line "..n..".",4)end
end
local function i()return r<=d:len()end
local function f()local r=e()local l=(e(1)==e(2)and e(1)==e())local t=""n(l and 3 or 1)while(i())do
if l and e():match(o)and t==""then
n()end
if e()==r then
if l then
if e(1)==e(2)and e(1)==r then
n(3)break
end
else
n()break
end
end
if e():match(o)and not l then
a("Single-line string cannot contain line break")end
if r=='"'and e()=="\\"then
if l and e(1):match(o)then
n(1)while(i())do
if not e():match(s)and not e():match(o)then
break
end
n()end
else
local o={b="\b",t="\t",n="\n",f="\f",r="\r",['"']='"',["\\"]="\\",}local function r(e)local t={{2047,192},{65535,224},{2097151,240}}if e<128 then return string.char(e)end
local n={}for t,l in pairs(t)do
if e<=l[1]then
for l=t+1,2,-1 do
local t=e%64
e=(e-t)/64
n[l]=string.char(128+t)end
n[1]=string.char(l[2]+e)break
end
end
return table.concat(n)end
if o[e(1)]then
t=t..o[e(1)]n(2)elseif e(1)=="u"then
n()local e=e(1)..e(2)..e(3)..e(4)n(5)e=tonumber(e,16)if(e>=0 and e<=55295)and not(e>=57344 and e<=1114111)then
t=t..r(e)else
a("Unicode escape is not a Unicode scalar")end
elseif e(1)=="U"then
n()local e=e(1)..e(2)..e(3)..e(4)..e(5)..e(6)..e(7)..e(8)n(9)e=tonumber(e,16)if(e>=0 and e<=55295)and not(e>=57344 and e<=1114111)then
t=t..r(e)else
a("Unicode escape is not a Unicode scalar")end
else
a("Invalid escape")end
end
else
t=t..e()n()end
end
return{value=t,type="string"}end
local function g()local t=""local l
local r=false
while(i())do
if e():match("[%+%-%.eE_0-9]")then
if not l then
if e():lower()=="e"then
l=""elseif e()~="_"then
t=t..e()end
elseif e():match("[%+%-0-9]")then
l=l..e()else
a("Invalid exponent")end
elseif e():match(s)or e()=="#"or e():match(o)or e()==","or e()=="]"or e()=="}"then
break
elseif e()=="T"or e()=="Z"then
r=true
while(i())do
if e()==","or e()=="]"or e()=="#"or e():match(o)or e():match(s)then
break
end
t=t..e()n()end
else
a("Invalid number")end
n()end
if r then
return{value=t,type="date"}end
local e=false
if t:match("%.")then e=true end
l=l and tonumber(l)or 0
t=tonumber(t)if not e then
return{value=math.floor(t*10^l),type="int",}end
return{value=t*10^l,type="float"}end
local s,u
function s()n()c()local r
local t={}while(i())do
if e()=="]"then
break
elseif e():match(o)then
n()c()elseif e()=="#"then
while(i()and not e():match(o))do
n()end
else
local l=u()if not l then break end
if r==nil then
r=l.type
elseif r~=l.type then
a("Mixed types in array",true)end
t=t or{}table.insert(t,l.value)if e()==","then
n()end
c()end
end
n()return{value=t,type="array"}end
local function p()n()local t=""local l=false
local r={}while i()do
if e()=="}"then
break
elseif e()=="'"or e()=='"'then
t=f().value
l=true
elseif e()=="="then
if not l then
t=m(t)end
n()c()if e():match(o)then
a("Newline in inline table")end
local i=u().value
r[t]=i
c()if e()==","then
n()elseif e():match(o)then
a("Newline in inline table")end
l=false
t=""else
t=t..e()n()end
end
n()return{value=r,type="array"}end
local function b()local t
if d:sub(r,r+3)=="true"then
n(4)t={value=true,type="boolean"}elseif d:sub(r,r+4)=="false"then
n(5)t={value=false,type="boolean"}else
a("Invalid primitive")end
c()if e()=="#"then
while(not e():match(o))do
n()end
end
return t
end
function u()if e()=='"'or e()=="'"then
return f()elseif e():match("[%+%-0-9]")then
return g()elseif e()=="["then
return s()elseif e()=="{"then
return p()else
return b()end
end
local s=false
while(r<=d:len())do
if e()=="#"then
while(not e():match(o))do
n()end
end
if e():match(o)then
end
if e()=="="then
n()c()t=m(t)if t:match("^[0-9]*$")and not s then
t=tonumber(t)end
if t==""and not s then
a("Empty key name")end
local f=u()if f then
if l[t]then
a('Cannot redefine key "'..t..'"',true)end
l[t]=f.value
end
t=""s=false
c()if e()=="#"then
while(i()and not e():match(o))do
n()end
end
if not e():match(o)and r<d:len()then
a("Invalid primitive")end
elseif e()=="["then
t=""n()local o=false
if e()=="["then
o=true
n()end
l=h
local function r(e)e=e or false
t=m(t)if not s and t==""then
a("Empty table name")end
if e and l[t]and not o and#l[t]>0 then
a("Cannot redefine table",true)end
if o then
if l[t]then
l=l[t]if e then
table.insert(l,{})end
l=l[#l]else
l[t]={}l=l[t]if e then
table.insert(l,{})l=l[1]end
end
else
l[t]=l[t]or{}l=l[t]end
end
while(i())do
if e()=="]"then
if o then
if e(1)~="]"then
a("Mismatching brackets")else
n()end
end
n()r(true)t=""break
elseif e()=='"'or e()=="'"then
t=f().value
s=true
elseif e()=="."then
n()r()t=""else
t=t..e()n()end
end
t=""s=false
elseif(e()=='"'or e()=="'")then
t=f().value
s=true
end
t=t..(e():match(o)and""or e())n()end
return h
end
function encode(c)local n=""local t={}local function a(e)for l,e in pairs(e)do
if type(e)=="boolean"then
n=n..l.." = "..tostring(e).."\n"elseif type(e)=="number"then
n=n..l.." = "..tostring(e).."\n"elseif type(e)=="string"then
local t='"'e=e:gsub("\\","\\\\")if e:match("^\n(.*)$")then
t=t:rep(3)e="\\n"..e
elseif e:match("\n")then
t=t:rep(3)end
e=e:gsub("\b","\\b")e=e:gsub("\t","\\t")e=e:gsub("\f","\\f")e=e:gsub("\r","\\r")e=e:gsub('"','\\"')e=e:gsub("/","\\/")n=n..l.." = "..t..e..t.."\n"elseif type(e)=="table"then
local r,i=true,true
local o={}for n,t in pairs(e)do
if type(n)~="number"then r=false end
if type(t)~="table"then
e[n]=nil
o[n]=t
i=false
end
end
if r then
if i then
table.insert(t,l)for l,e in pairs(e)do
n=n.."[["..table.concat(t,".").."]]\n"for t,n in pairs(e)do
if type(n)~="table"then
e[t]=nil
o[t]=n
end
end
a(o)a(e)end
table.remove(t)else
n=n..l.." = [\n"for t,e in pairs(o)do
n=n..tostring(e)..",\n"end
n=n.."]\n"end
else
table.insert(t,l)n=n.."["..table.concat(t,".").."]\n"a(o)a(e)table.remove(t)end
end
end
end
a(c)return n:sub(1,-2)end end,['matthewwild/minify/llex']=function(e,e,e,e,...)local m=_G
local c=require"string"local s=c.find
local f=c.match
local a=c.sub
local p={}for e in c.gmatch([[
and break do else elseif end false for function if in
local nil not or repeat return then true until while]],"%S+")do
p[e]=true
end
local e,d,t,o,r
local function l(t,n)local e=#tok+1
tok[e]=t
seminfo[e]=n
tokln[e]=r
end
local function i(n,i)local a=a
local o=a(e,n,n)n=n+1
local e=a(e,n,n)if(e=="\n"or e=="\r")and(e~=o)then
n=n+1
o=o..e
end
if i then l("TK_EOL",o)end
r=r+1
t=n
return n
end
function init(n,o)e=n
d=o
t=1
r=1
tok={}seminfo={}tokln={}local o,a,e,n=s(e,"^(#[^\r\n]*)(\r?\n?)")if o then
t=t+#e
l("TK_COMMENT",e)if#n>0 then i(t,true)end
end
end
function chunkid()if d and f(d,"^[=@]")then
return a(d,2)end
return"[string]"end
function errorline(t,e)local n=error or m.error
n(c.format("%s:%d: %s",chunkid(),e or r,t))end
local c=errorline
local function u(n)local o=a
local a=o(e,n,n)n=n+1
local l=#f(e,"=*",n)n=n+l
t=n
return(o(e,n,n)==a)and l or(-l)-1
end
local function h(r,d)local n=t+1
local l=a
local a=l(e,n,n)if a=="\r"or a=="\n"then
n=i(n)end
local a=n
while true do
local a,f,s=s(e,"([\r\n%]])",n)if not a then
c(r and"unfinished long string"or"unfinished long comment")end
n=a
if s=="]"then
if u(n)==d then
o=l(e,o,t)t=t+1
return o
end
n=t
else
o=o.."\n"n=i(n)end
end
end
local function g(f)local n=t
local r=s
local d=a
while true do
local a,s,l=r(e,"([\n\r\\\"'])",n)if a then
if l=="\n"or l=="\r"then
c("unfinished string")end
n=a
if l=="\\"then
n=n+1
l=d(e,n,n)if l==""then break end
a=r("abfnrtv\n\r",l,1,true)if a then
if a>7 then
n=i(n)else
n=n+1
end
elseif r(l,"%D")then
n=n+1
else
local l,t,e=r(e,"^(%d%d?%d?)",n)n=t+1
if e+1>256 then
c("escape sequence too large")end
end
else
n=n+1
if l==f then
t=n
return d(e,o,n-1)end
end
else
break
end
end
c("unfinished string")end
function llex()local r=s
local d=f
while true do
local n=t
while true do
local f,b,s=r(e,"^([_%a][_%w]*)",n)if f then
t=n+#s
if p[s]then
l("TK_KEYWORD",s)else
l("TK_NAME",s)end
break
end
local s,p,f=r(e,"^(%.?)%d",n)if s then
if f=="."then n=n+1 end
local f,o,i=r(e,"^%d*[%.%d]*([eE]?)",n)n=o+1
if#i==1 then
if d(e,"^[%+%-]",n)then
n=n+1
end
end
local o,n=r(e,"^[_%w]*",n)t=n+1
local e=a(e,s,n)if not m.tonumber(e)then
c("malformed number")end
l("TK_NUMBER",e)break
end
local m,f,p,s=r(e,"^((%s)[ \t\v\f]*)",n)if m then
if s=="\n"or s=="\r"then
i(n,true)else
t=f+1
l("TK_SPACE",p)end
break
end
local i=d(e,"^%p",n)if i then
o=n
local s=r("-[\"'.=<>~",i,1,true)if s then
if s<=2 then
if s==1 then
local c=d(e,"^%-%-(%[?)",n)if c then
n=n+2
local i=-1
if c=="["then
i=u(n)end
if i>=0 then
l("TK_LCOMMENT",h(false,i))else
t=r(e,"[\n\r]",n)or(#e+1)l("TK_COMMENT",a(e,o,t-1))end
break
end
else
local e=u(n)if e>=0 then
l("TK_LSTRING",h(true,e))elseif e==-1 then
l("TK_OP","[")else
c("invalid long string delimiter")end
break
end
elseif s<=5 then
if s<5 then
t=n+1
l("TK_STRING",g(i))break
end
i=d(e,"^%.%.?%.?",n)else
i=d(e,"^%p=?",n)end
end
t=n+#i
l("TK_OP",i)break
end
local e=a(e,n,n)if e~=""then
t=n+1
l("TK_OP",e)break
end
l("TK_EOS","")return
end
end
end
end,['matthewwild/minify/lparser']=function(e,Q,e,e,...)local P=_G
local T=require"string"local N,E,A,G,a,i,I,n,y,d,u,p,t,S,k,D,c,_,L
local b,r,g,x,j,v
local e=T.gmatch
local O={}for e in e("else elseif end until <eof>","%S+")do
O[e]=true
end
local W={}for e in e("if while do for repeat function local return break","%S+")do
W[e]=e.."_stat"end
local V={}local J={}for e,n,t in e([[
{+ 6 6}{- 6 6}{* 7 7}{/ 7 7}{% 7 7}
{^ 10 9}{.. 5 4}
{~= 3 3}{== 3 3}
{< 3 3}{<= 3 3}{> 3 3}{>= 3 3}
{and 2 2}{or 1 1}
]],"{(%S+)%s(%d+)%s(%d+)}")do
V[e]=n+0
J[e]=t+0
end
local X={["not"]=true,["-"]=true,["#"]=true,}local Z=8
local function l(n,e)local t=error or P.error
t(T.format("(source):%d: %s",e or d,n))end
local function e()I=A[a]n,y,d,u=N[a],E[a],A[a],G[a]a=a+1
end
local function ee()return N[a]end
local function f(t)local e=n
if e~="<number>"and e~="<string>"then
if e=="<name>"then e=y end
e="'"..e.."'"end
l(t.." near "..e)end
local function h(e)f("'"..e.."' expected")end
local function o(t)if n==t then e();return true end
end
local function C(e)if n~=e then h(e)end
end
local function l(n)C(n);e()end
local function H(n,e)if not n then f(e)end
end
local function s(e,t,n)if not o(e)then
if n==d then
h(e)else
f("'"..e.."' expected (to close '"..t.."' at line "..n..")")end
end
end
local function m()C("<name>")local n=y
p=u
e()return n
end
local function M(e,n)e.k="VK"end
local function R(e)M(e,m())end
local function h(l,o)local e=t.bl
local n
if e then
n=e.locallist
else
n=t.locallist
end
local e=#c+1
c[e]={name=l,xref={p},decl=p,}if o then
c[e].isself=true
end
local t=#_+1
_[t]=e
L[t]=n
end
local function w(e)local n=#_
while e>0 do
e=e-1
local e=n-e
local t=_[e]local n=c[t]local o=n.name
n.act=u
_[e]=nil
local l=L[e]L[e]=nil
local e=l[o]if e then
n=c[e]n.rem=-t
end
l[o]=t
end
end
local function K()local n=t.bl
local e
if n then
e=n.locallist
else
e=t.locallist
end
for n,e in P.pairs(e)do
local e=c[e]e.rem=u
end
end
local function u(e,n)if T.sub(e,1,1)=="("then
return
end
h(e,n)end
local function P(l,t)local n=l.bl
local e
if n then
e=n.locallist
while e do
if e[t]then return e[t]end
n=n.prev
e=n and n.locallist
end
end
e=l.locallist
return e[t]or-1
end
local function T(n,l,e)if n==nil then
e.k="VGLOBAL"return"VGLOBAL"else
local t=P(n,l)if t>=0 then
e.k="VLOCAL"e.id=t
return"VLOCAL"else
if T(n.prev,l,e)=="VGLOBAL"then
return"VGLOBAL"end
e.k="VUPVAL"return"VUPVAL"end
end
end
local function F(l)local n=m()T(t,n,l)if l.k=="VGLOBAL"then
local e=D[n]if not e then
e=#k+1
k[e]={name=n,xref={p},}D[n]=e
else
local e=k[e].xref
e[#e+1]=p
end
else
local e=l.id
local e=c[e].xref
e[#e+1]=p
end
end
local function T(n)local e={}e.isbreakable=n
e.prev=t.bl
e.locallist={}t.bl=e
end
local function p()local e=t.bl
K()t.bl=e.prev
end
local function q()local e
if not t then
e=S
else
e={}end
e.prev=t
e.bl=nil
e.locallist={}t=e
end
local function U()K()t=t.prev
end
local function P(t)local n={}e()R(n)t.k="VINDEXED"end
local function B(n)e()r(n)l("]")end
local function z(e)local e,t={},{}if n=="<name>"then
R(e)else
B(e)end
l("=")r(t)end
local function K(e)if e.v.k=="VVOID"then return end
e.v.k="VVOID"end
local function K(e)r(e.v)end
local function Y(t)local a=d
local e={}e.v={}e.t=t
t.k="VRELOCABLE"e.v.k="VVOID"l("{")repeat
if n=="}"then break end
local n=n
if n=="<name>"then
if ee()~="="then
K(e)else
z(e)end
elseif n=="["then
z(e)else
K(e)end
until not o(",")and not o(";")s("}","{",a)end
local function ee()local l=0
if n~=")"then
repeat
local n=n
if n=="<name>"then
h(m())l=l+1
elseif n=="..."then
e()t.is_vararg=true
else
f("<name> or '...' expected")end
until t.is_vararg or not o(",")end
w(l)end
local function z(a)local t={}local o=d
local l=n
if l=="("then
if o~=I then
f("ambiguous syntax (function call x new statement)")end
e()if n==")"then
t.k="VVOID"else
b(t)end
s(")","(",o)elseif l=="{"then
Y(t)elseif l=="<string>"then
M(t,y)e()else
f("function arguments expected")return
end
a.k="VCALL"end
local function I(t)local n=n
if n=="("then
local n=d
e()r(t)s(")","(",n)elseif n=="<name>"then
F(t)else
f("unexpected symbol")end
end
local function K(t)I(t)while true do
local n=n
if n=="."then
P(t)elseif n=="["then
local e={}B(e)elseif n==":"then
local n={}e()R(n)z(t)elseif n=="("or n=="<string>"or n=="{"then
z(t)else
return
end
end
end
local function R(l)local n=n
if n=="<number>"then
l.k="VKNUM"elseif n=="<string>"then
M(l,y)elseif n=="nil"then
l.k="VNIL"elseif n=="true"then
l.k="VTRUE"elseif n=="false"then
l.k="VFALSE"elseif n=="..."then
H(t.is_vararg==true,"cannot use '...' outside a vararg function");l.k="VVARARG"elseif n=="{"then
Y(l)return
elseif n=="function"then
e()j(l,false,d)return
else
K(l)return
end
e()end
local function y(l,a)local t=n
local o=X[t]if o then
e()y(l,Z)else
R(l)end
t=n
local n=V[t]while n and n>a do
local l={}e()local e=y(l,J[t])t=e
n=V[t]end
return t
end
function r(e)y(e,0)end
local function M(e)local n={}local e=e.v.k
H(e=="VLOCAL"or e=="VUPVAL"or e=="VGLOBAL"or e=="VINDEXED","syntax error")if o(",")then
local e={}e.v={}K(e.v)M(e)else
l("=")b(n)return
end
n.k="VNONRELOC"end
local function y(e,n)l("do")T(false)w(e)g()p()end
local function B(e)local n=i
u("(for index)")u("(for limit)")u("(for step)")h(e)l("=")x()l(",")x()if o(",")then
x()else
end
y(1,true)end
local function V(e)local n={}u("(for generator)")u("(for state)")u("(for control)")h(e)local e=1
while o(",")do
h(m())e=e+1
end
l("in")local t=i
b(n)y(e,false)end
local function R(e)local t=false
F(e)while n=="."do
P(e)end
if n==":"then
t=true
P(e)end
return t
end
function x()local e={}r(e)end
local function y()local e={}r(e)end
local function x()e()y()l("then")g()end
local function I()local n,e={}h(m())n.k="VLOCAL"w(1)j(e,false,d)end
local function P()local e=0
local n={}repeat
h(m())e=e+1
until not o(",")if o("=")then
b(n)else
n.k="VVOID"end
w(e)end
function b(e)r(e)while o(",")do
r(e)end
end
function j(t,n,e)q()l("(")if n then
u("self",true)w(1)end
ee()l(")")v()s("end","function",e)U()end
function g()T(false)v()p()end
function for_stat()local l=i
T(true)e()local t=m()local e=n
if e=="="then
B(t)elseif e==","or e=="in"then
V(t)else
f("'=' or 'in' expected")end
s("end","for",l)p()end
function while_stat()local n=i
e()y()T(true)l("do")g()s("end","while",n)p()end
function repeat_stat()local n=i
T(true)T(false)e()v()s("until","repeat",n)y()p()p()end
function if_stat()local t=i
local l={}x()while n=="elseif"do
x()end
if n=="else"then
e()g()end
s("end","if",t)end
function return_stat()local t={}e()local e=n
if O[e]or e==";"then
else
b(t)end
end
function break_stat()local n=t.bl
e()while n and not n.isbreakable do
n=n.prev
end
if not n then
f("no loop to break")end
end
function expr_stat()local e={}e.v={}K(e.v)if e.v.k=="VCALL"then
else
e.prev=nil
M(e)end
end
function function_stat()local n=i
local t,l={},{}e()local e=R(t)j(l,e,n)end
function do_stat()local n=i
e()g()s("end","do",n)end
function local_stat()e()if o("function")then
I()else
P()end
end
local function l()i=d
local e=n
local n=W[e]if n then
Q[n]()if e=="return"or e=="break"then return true end
else
expr_stat()end
return false
end
function v()local e=false
while not e and not O[n]do
e=l()o(";")end
end
function parser()q()t.is_vararg=true
e()v()C("<eof>")U()return k,c
end
function init(e,o,r)a=1
S={}local n=1
N,E,A,G={},{},{},{}for t=1,#e do
local e=e[t]local l=true
if e=="TK_KEYWORD"or e=="TK_OP"then
e=o[t]elseif e=="TK_NAME"then
e="<name>"E[n]=o[t]elseif e=="TK_NUMBER"then
e="<number>"E[n]=0
elseif e=="TK_STRING"or e=="TK_LSTRING"then
e="<string>"E[n]=""elseif e=="TK_EOS"then
e="<eof>"else
l=false
end
if l then
N[n]=e
A[n]=r[t]G[n]=t
n=n+1
end
end
k,D,c={},{},{}_,L={},{}end
end,['matthewwild/minify/main']=function(n,n,e,n,...)local r=table.concat
local n=e"matthewwild/minify/llex"local o=e"matthewwild/minify/lparser"local i=e"matthewwild/minify/optlex"local c=e"matthewwild/minify/optparser"local l={basic={"comments","whitespace","emptylines"},debug={"whitespace","locals","entropy","comments","numbers"},default={"comments","whitespace","emptylines","numbers","locals"},full={"comments","whitespace","emptylines","eols","strings","numbers","locals","entropy"}}local d={["comments"]="opt-comments",["emptylines"]="opt-emptylines",["entropy"]="opt-entropy",["eols"]="opt-eols",["locals"]="opt-locals",["numbers"]="opt-numbers",["strings"]="opt-strings",["whitespace"]="opt-whitespace"}local function a(t)local n={}local e
for l,t in pairs(t)do
e=d[t]if e then
n[e]=true
end
end
return n
end
function minify(t,e)if e=="none"then return t end
assert(type(e)=="string","bad argument #1 to 'minify' (expected string)")assert(type(e)=="table"or type(e)=="string","bad argument #2 to 'minify' (expected string or table)")if type(e)=="string"then
e=assert(l[e],"bad argument #2 to 'minify' (invalid minification level)")end
e=a(e)n.init(t)n.llex()local t,n,l=n.tok,n.seminfo,n.tokln
if e["opt-locals"]then
o.init(t,n,l)local l,o=o.parser()c.optimize(e,t,n,l,o)end
t,n,l=i.optimize(e,t,n,l)return r(n)end end,['matthewwild/minify/optlex']=function(e,e,e,e,...)local r=_G
local s=require"string"local l=s.match
local e=s.sub
local i=s.find
local c=s.rep
local v
error=r.error
warn={}local a,o,f
local _={TK_KEYWORD=true,TK_NAME=true,TK_NUMBER=true,TK_STRING=true,TK_LSTRING=true,TK_OP=true,TK_EOS=true,}local E={TK_COMMENT=true,TK_LCOMMENT=true,TK_EOL=true,TK_SPACE=true,}local d
local function T(e)local n=a[e-1]if e<=1 or n=="TK_EOL"then
return true
elseif n==""then
return T(e-1)end
return false
end
local function b(e)local n=a[e+1]if e>=#a or n=="TK_EOL"or n=="TK_EOS"then
return true
elseif n==""then
return b(e+1)end
return false
end
local function K(t)local n=#l(t,"^%-%-%[=*%[")local t=e(t,n+1,-(n-1))local e,n=1,0
while true do
local t,a,o,l=i(t,"([\r\n])([\r\n]?)",e)if not t then break end
e=t+1
n=n+1
if#l>0 and o~=l then
e=e+1
end
end
return n
end
local function k(r,i)local t=l
local n,e=a[r],a[i]if n=="TK_STRING"or n=="TK_LSTRING"or
e=="TK_STRING"or e=="TK_LSTRING"then
return""elseif n=="TK_OP"or e=="TK_OP"then
if(n=="TK_OP"and(e=="TK_KEYWORD"or e=="TK_NAME"))or(e=="TK_OP"and(n=="TK_KEYWORD"or n=="TK_NAME"))then
return""end
if n=="TK_OP"and e=="TK_OP"then
local n,e=o[r],o[i]if(t(n,"^%.%.?$")and t(e,"^%."))or(t(n,"^[~=<>]$")and e=="=")or(n=="["and(e=="["or e=="="))then
return" "end
return""end
local n=o[r]if e=="TK_OP"then n=o[i]end
if t(n,"^%.%.?%.?$")then
return" "end
return""else
return" "end
end
local function w()local i,r,l={},{},{}local e=1
for n=1,#a do
local t=a[n]if t~=""then
i[e],r[e],l[e]=t,o[n],f[n]e=e+1
end
end
a,o,f=i,r,l
end
local function P(i)local n=o[i]local n=n
local a
if l(n,"^0[xX]")then
local e=r.tostring(r.tonumber(n))if#e<=#n then
n=e
else
return
end
end
if l(n,"^%d+%.?0*$")then
n=l(n,"^(%d+)%.?0*$")if n+0>0 then
n=l(n,"^0*([1-9]%d*)$")local t=#l(n,"0*$")local l=r.tostring(t)if t>#l+1 then
n=e(n,1,#n-t).."e"..l
end
a=n
else
a="0"end
elseif not l(n,"[eE]")then
local t,n=l(n,"^(%d*)%.(%d+)$")if t==""then t=0 end
if n+0==0 and t==0 then
a="0"else
local o=#l(n,"0*$")if o>0 then
n=e(n,1,#n-o)end
if t+0>0 then
a=t.."."..n
else
a="."..n
local t=#l(n,"^0*")local l=#n-t
local t=r.tostring(#n)if l+2+#t<1+#n then
a=e(n,-l).."e-"..t
end
end
end
else
local n,t=l(n,"^([^eE]+)[eE]([%+%-]?%d+)$")t=r.tonumber(t)local o,i=l(n,"^(%d*)%.(%d*)$")if o then
t=t-#i
n=o..i
end
if n+0==0 then
a="0"else
local o=#l(n,"^0*")n=e(n,o+1)o=#l(n,"0*$")if o>0 then
n=e(n,1,#n-o)t=t+o
end
local l=r.tostring(t)if t==0 then
a=n
elseif t>0 and(t<=1+#l)then
a=n..c("0",t)elseif t<0 and(t>=-#n)then
o=#n+t
a=e(n,1,o).."."..e(n,o+1)elseif t<0 and(#l>=-t-#n)then
o=-t-#n
a="."..c("0",o)..n
else
a=n.."e"..t
end
end
end
if a and a~=o[i]then
if d then
d=d+1
end
o[i]=a
end
end
local function L(u)local n=o[u]local r=e(n,1,1)local h=(r=="'")and'"'or"'"local n=e(n,2,-2)local t=1
local f,a=0,0
while t<=#n do
local u=e(n,t,t)if u=="\\"then
local o=t+1
local d=e(n,o,o)local c=i("abfnrtv\\\n\r\"'0123456789",d,1,true)if not c then
n=e(n,1,t-1)..e(n,o)t=t+1
elseif c<=8 then
t=t+2
elseif c<=10 then
local l=e(n,o,o+1)if l=="\r\n"or l=="\n\r"then
n=e(n,1,t).."\n"..e(n,o+2)elseif c==10 then
n=e(n,1,t).."\n"..e(n,o+1)end
t=t+2
elseif c<=12 then
if d==r then
f=f+1
t=t+2
else
a=a+1
n=e(n,1,t-1)..e(n,o)t=t+1
end
else
local l=l(n,"^(%d%d?%d?)",o)o=t+1+#l
local d=l+0
local c=s.char(d)local i=i("\a\b\f\n\r\t\v",c,1,true)if i then
l="\\"..e("abfnrtv",i,i)elseif d<32 then
l="\\"..d
elseif c==r then
l="\\"..c
f=f+1
elseif c=="\\"then
l="\\\\"else
l=c
if c==h then
a=a+1
end
end
n=e(n,1,t-1)..l..e(n,o)t=t+#l
end
else
t=t+1
if u==h then
a=a+1
end
end
end
if f>a then
t=1
while t<=#n do
local l,a,o=i(n,"(['\"])",t)if not l then break end
if o==r then
n=e(n,1,l-2)..e(n,l)t=l
else
n=e(n,1,l-1).."\\"..e(n,l)t=l+2
end
end
r=h
end
n=r..n..r
if n~=o[u]then
if d then
d=d+1
end
o[u]=n
end
end
local function N(s)local n=o[s]local r=l(n,"^%[=*%[")local t=#r
local u=e(n,-t,-1)local d=e(n,t+1,-(t+1))local a=""local n=1
while true do
local t,o,i,r=i(d,"([\r\n])([\r\n]?)",n)local o
if not t then
o=e(d,n)elseif t>=n then
o=e(d,n,t-1)end
if o~=""then
if l(o,"%s+$")then
warn.lstring="trailing whitespace in long string near line "..f[s]end
a=a..o
end
if not t then
break
end
n=t+1
if t then
if#r>0 and i~=r then
n=n+1
end
if not(n==1 and n==t)then
a=a.."\n"end
end
end
if t>=3 then
local e,n=t-1
while e>=2 do
local t="%]"..c("=",e-2).."%]"if not l(a,t)then n=e end
e=e-1
end
if n then
t=c("=",n-2)r,u="["..t.."[","]"..t.."]"end
end
o[s]=r..a..u
end
local function p(f)local t=o[f]local d=l(t,"^%-%-%[=*%[")local n=#d
local s=e(t,-n,-1)local r=e(t,n+1,-(n-1))local a=""local t=1
while true do
local o,n,c,i=i(r,"([\r\n])([\r\n]?)",t)local n
if not o then
n=e(r,t)elseif o>=t then
n=e(r,t,o-1)end
if n~=""then
local t=l(n,"%s*$")if#t>0 then n=e(n,1,-(t+1))end
a=a..n
end
if not o then
break
end
t=o+1
if o then
if#i>0 and c~=i then
t=t+1
end
a=a.."\n"end
end
n=n-2
if n>=3 then
local e,t=n-1
while e>=2 do
local n="%]"..c("=",e-2).."%]"if not l(a,n)then t=e end
e=e-1
end
if t then
n=c("=",t-2)d,s="--["..n.."[","]"..n.."]"end
end
o[f]=d..a..s
end
local function g(a)local n=o[a]local t=l(n,"%s*$")if#t>0 then
n=e(n,1,-(t+1))end
o[a]=n
end
local function y(o,n)if not o then return false end
local t=l(n,"^%-%-%[=*%[")local t=#t
local l=e(n,-t,-1)local e=e(n,t+1,-(t-1))if i(e,o,1,true)then
return true
end
end
function optimize(n,l,i,t)local h=n["opt-comments"]local s=n["opt-whitespace"]local u=n["opt-emptylines"]local m=n["opt-eols"]local j=n["opt-strings"]local x=n["opt-numbers"]local A=n.KEEP
d=n.DETAILS and 0
v=v or r.print
if m then
h=true
s=true
u=true
end
a,o,f=l,i,t
local n=1
local t,i
local r
local function l(t,l,e)e=e or n
a[e]=t or""o[e]=l or""end
while true do
t,i=a[n],o[n]local d=T(n)if d then r=nil end
if t=="TK_EOS"then
break
elseif t=="TK_KEYWORD"or
t=="TK_NAME"or
t=="TK_OP"then
r=n
elseif t=="TK_NUMBER"then
if x then
P(n)end
r=n
elseif t=="TK_STRING"or
t=="TK_LSTRING"then
if j then
if t=="TK_STRING"then
L(n)else
N(n)end
end
r=n
elseif t=="TK_COMMENT"then
if h then
if n==1 and e(i,1,1)=="#"then
g(n)else
l()end
elseif s then
g(n)end
elseif t=="TK_LCOMMENT"then
if y(A,i)then
if s then
p(n)end
r=n
elseif h then
local e=K(i)if E[a[n+1]]then
l()t=""else
l("TK_SPACE"," ")end
if not u and e>0 then
l("TK_EOL",c("\n",e))end
if s and t~=""then
n=n-1
end
else
if s then
p(n)end
r=n
end
elseif t=="TK_EOL"then
if d and u then
l()elseif i=="\r\n"or i=="\n\r"then
l("TK_EOL","\n")end
elseif t=="TK_SPACE"then
if s then
if d or b(n)then
l()else
local t=a[r]if t=="TK_LCOMMENT"then
l()else
local e=a[n+1]if E[e]then
if(e=="TK_COMMENT"or e=="TK_LCOMMENT")and
t=="TK_OP"and o[r]=="-"then
else
l()end
else
local e=k(r,n+1)if e==""then
l()else
l("TK_SPACE"," ")end
end
end
end
end
else
error("unidentified token encountered")end
n=n+1
end
w()if m then
n=1
if a[1]=="TK_COMMENT"then
n=3
end
while true do
t,i=a[n],o[n]if t=="TK_EOS"then
break
elseif t=="TK_EOL"then
local e,t=a[n-1],a[n+1]if _[e]and _[t]then
local e=k(n-1,n+1)if e==""then
l()end
end
end
n=n+1
end
w()end
return a,o,f
end
end,['matthewwild/minify/optparser']=function(e,e,e,e,...)local e=_G
local t=require"string"local h=require"table"local o="etaoinshrdlucmfwypvbgkqjxz_ETAOINSHRDLUCMFWYPVBGKQJXZ"local r="etaoinshrdlucmfwypvbgkqjxz_0123456789ETAOINSHRDLUCMFWYPVBGKQJXZ"local p={}for e in t.gmatch([[
and break do else elseif end false for function if in
local nil not or repeat return then true until while
self]],"%S+")do
p[e]=true
end
local c,f,s,l,u,T,d,i
local function m(e)local o={}for a=1,#e do
local e=e[a]local l=e.name
if not o[l]then
o[l]={decl=0,token=0,size=0,}end
local n=o[l]n.decl=n.decl+1
local o=e.xref
local t=#o
n.token=n.token+t
n.size=n.size+t*#l
if e.decl then
e.id=a
e.xcount=t
if t>1 then
e.first=o[2]e.last=o[t]end
else
n.id=a
end
end
return o
end
local function g(e)local a=t.byte
local i=t.char
local n={TK_KEYWORD=true,TK_NAME=true,TK_NUMBER=true,TK_STRING=true,TK_LSTRING=true,}if not e["opt-comments"]then
n.TK_COMMENT=true
n.TK_LCOMMENT=true
end
local t={}for e=1,#c do
t[e]=f[e]end
for e=1,#l do
local e=l[e]local n=e.xref
for e=1,e.xcount do
local e=n[e]t[e]=""end
end
local e={}for n=0,255 do e[n]=0 end
for l=1,#c do
local l,t=c[l],t[l]if n[l]then
for n=1,#t do
local n=a(t,n)e[n]=e[n]+1
end
end
end
local function l(t)local n={}for l=1,#t do
local t=a(t,l)n[l]={c=t,freq=e[t],}end
h.sort(n,function(e,n)return e.freq>n.freq
end)local e={}for t=1,#n do
e[t]=i(n[t].c)end
return h.concat(e)end
o=l(o)r=l(r)end
local function b()local n
local i,c=#o,#r
local e=d
if e<i then
e=e+1
n=t.sub(o,e,e)else
local a,l=i,1
repeat
e=e-a
a=a*c
l=l+1
until a>e
local a=e%i
e=(e-a)/i
a=a+1
n=t.sub(o,a,a)while l>1 do
local o=e%c
e=(e-o)/c
o=o+1
n=n..t.sub(r,o,o)l=l-1
end
end
d=d+1
return n,u[n]~=nil
end
function optimize(e,n,a,t,o)c,f,s,l=n,a,t,o
d=0
i={}u=m(s)T=m(l)if e["opt-entropy"]then
g(e)end
local e={}for n=1,#l do
e[n]=l[n]end
h.sort(e,function(e,n)return e.xcount>n.xcount
end)local t,n,c={},1,false
for l=1,#e do
local e=e[l]if not e.isself then
t[n]=e
n=n+1
else
c=true
end
end
e=t
local r=#e
while r>0 do
local a,n
repeat
a,n=b()until not p[a]i[#i+1]=a
local t=r
if n then
local o=s[u[a].id].xref
local a=#o
for n=1,r do
local n=e[n]local r,e=n.act,n.rem
while e<0 do
e=l[-e].rem
end
local l
for n=1,a do
local n=o[n]if n>=r and n<=e then l=true end
end
if l then
n.skip=true
t=t-1
end
end
end
while t>0 do
local n=1
while e[n].skip do
n=n+1
end
t=t-1
local o=e[n]n=n+1
o.newname=a
o.skip=true
o.done=true
local r,c=o.first,o.last
local i=o.xref
if r and t>0 then
local a=t
while a>0 do
while e[n].skip do
n=n+1
end
a=a-1
local e=e[n]n=n+1
local a,n=e.act,e.rem
while n<0 do
n=l[-n].rem
end
if not(c<a or r>n)then
if a>=o.act then
for l=1,o.xcount do
local l=i[l]if l>=a and l<=n then
t=t-1
e.skip=true
break
end
end
else
if e.last and e.last>=o.act then
t=t-1
e.skip=true
end
end
end
if t==0 then break end
end
end
end
local t,n={},1
for l=1,r do
local e=e[l]if not e.done then
e.skip=false
t[n]=e
n=n+1
end
end
e=t
r=#e
end
for e=1,#l do
local e=l[e]local t=e.xref
if e.newname then
for n=1,e.xcount do
local n=t[n]f[n]=e.newname
end
e.name,e.oldname=e.newname,e.name
else
e.oldname=e.name
end
end
if c then
i[#i+1]="self"end
local e=m(l)end
end,['novacbn/gmodproj-plugin-builtin/Plugin']=function(n,m,n,e,...)local t
t=gmodproj.api.Plugin
local l
l=e("novacbn/gmodproj-plugin-builtin/PluginOptions").PluginOptions
local o
o=e("novacbn/gmodproj-plugin-builtin/assets/DataFileAsset").DataFileAsset
local r
r=e("novacbn/gmodproj-plugin-builtin/assets/JSONAsset").JSONAsset
local a
a=e("novacbn/gmodproj-plugin-builtin/assets/LuaAsset").LuaAsset
local s
s=e("novacbn/gmodproj-plugin-builtin/assets/MoonAsset").MoonAsset
local f
f=e("novacbn/gmodproj-plugin-builtin/assets/TOMLAsset").TOMLAsset
local d
d=e("novacbn/gmodproj-plugin-builtin/platforms/GarrysmodPlatform").GarrysmodPlatform
local i,c
do
local e=e("novacbn/gmodproj-plugin-builtin/platforms/LuaPlatform")i,c=e.LuaPlatform,e.setMinificationLevel
end
local h
h=e("novacbn/gmodproj-plugin-builtin/templates/AddonTemplate").AddonTemplate
local u
u=e("novacbn/gmodproj-plugin-builtin/templates/GamemodeTemplate").GamemodeTemplate
local n
n=e("novacbn/gmodproj-plugin-builtin/templates/PackageTemplate").PackageTemplate
m.Plugin=t:extend({schema=l,registerAssets=function(n,e)e:registerAsset("lua",a)e:registerAsset("moon",s)e:registerAsset("datl",o)e:registerAsset("json",r)return e:registerAsset("toml",f)end,registerTemplates=function(t,e)e:registerTemplate("addon",h)e:registerTemplate("gamemode",u)return e:registerTemplate("package",n)end,registerPlatforms=function(n,e)c(n.options:get("minificationLevel"))e:registerPlatform("garrysmod",d)return e:registerPlatform("lua",i)end})end,['novacbn/gmodproj-plugin-builtin/PluginOptions']=function(e,e,e,e,...)local e
e=gmodproj.api.Schema
PluginOptions=e:extend({namespace="gmodproj-plugin-builtin",schema={minificationLevel={one_of={"none","basic","debug","default","full"}}},default={minificationLevel="default"}})end,['novacbn/gmodproj-plugin-builtin/assets/DataFileAsset']=function(e,e,e,e,...)local n
n=gmodproj.api.DataAsset
local e
e=gmodproj.require("novacbn/gmodproj/lib/datafile").fromString
DataFileAsset=n:extend({preTransform=function(t,n)return e(n)end})end,['novacbn/gmodproj-plugin-builtin/assets/JSONAsset']=function(n,n,n,e,...)local n
n=e("rxi/json/main").decode
local e
e=gmodproj.api.DataAsset
JSONAsset=e:extend({preTransform=function(t,e)return n(e)end})end,['novacbn/gmodproj-plugin-builtin/assets/LuaAsset']=function(e,e,e,e,...)local l,t
do
local e=string
l,t=e.gsub,e.match
end
local n
n=gmodproj.api.Asset
local e
e=gmodproj.require("novacbn/novautils/collections/Set").Set
local o="import"local r="dependency"local a="import[\\(]?[%s]*['\"]([%w/%-_]+)['\"]"local i="dependency[\\(]?[%s]*['\"]([%w/%-_]+)['\"]"LuaAsset=n:extend({collectDependencies=function(n,t)local e=e:new()n:scanDependencies(o,a,t,e)n:scanDependencies(r,i,t,e)return e:values()end,scanDependencies=function(r,o,n,e,a)if t(e,o)then
return l(e,n,function(e)return a:push(e)end)end
end})end,['novacbn/gmodproj-plugin-builtin/assets/MoonAsset']=function(e,e,e,a,...)local t,l
do
local e=string
t,l=e.match,e.gsub
end
local c,i
do
local e=require("moonscript/compile")c,i=e.format_error,e.tree
end
local n
n=require("moonscript/parse").string
local o
o=gmodproj.require("novacbn/gmodproj/lib/logging").logFatal
local e
e=a("novacbn/gmodproj-plugin-builtin/assets/LuaAsset").LuaAsset
local a="import"local r="(import[%s]+[%w_,%s]+[%s]+from[%s]+)(['\"][%w/%-_]+['\"])"MoonAsset=e:extend({transformImports=function(n,e)if t(e,a)then
return l(e,r,function(n,e)return n.."dependency("..tostring(e)..")"end)end
return e
end,preTransform=function(l,e,t)e=l:transformImports(e)local a,t=n(e)if not(a)then
o("Failed to parse asset '"..tostring(l.assetName).."': "..tostring(t))end
local n,r
n,t,r=i(a)if not(n)then
o("Failed to compile asset '"..tostring(l.assetName).."': "..tostring(c(t,r,e)))end
return n
end})end,['novacbn/gmodproj-plugin-builtin/assets/TOMLAsset']=function(n,n,n,e,...)local n
n=e("jonstoler/toml/main").parse
local e
e=gmodproj.api.DataAsset
TOMLAsset=e:extend({preTransform=function(t,e,t)return n(e)end})end,['novacbn/gmodproj-plugin-builtin/platforms/GarrysmodPlatform']=function(e,e,e,t,...)local n,e
do
local t=t("novacbn/gmodproj-plugin-builtin/platforms/LuaPlatform")n,e=t.LuaPlatform,t.TEMPLATE_HEADER_PACKAGE
end
TEMPLATE_HEADER_DEVELOPMENT=function(n)return e(n,"local CompileString = _G.CompileString\n\n    for moduleName, assetChunk in pairs(modules) do\n        modules[moduleName] = CompileString('return function (module, exports, import, dependency, ...) '..assetChunk..' end', moduleName)()\n    end")end
GarrysmodPlatform=n:extend({generatePackageHeader=function(t,n)return t.isProduction and e(n,"")or TEMPLATE_HEADER_DEVELOPMENT(n)end})end,['novacbn/gmodproj-plugin-builtin/platforms/LuaPlatform']=function(e,e,e,t,...)local e
e=string.format
local n
n=gmodproj.api.Platform
local l
l=t("matthewwild/minify/main").minify
local t="full"TEMPLATE_HEADER_PACKAGE=function(e,n)return"return (function (modules, ...)\n    local _G            = _G\n    local error         = _G.error\n    local loadstring    = _G.loadstring\n    local setfenv       = _G.setfenv\n    local setmetatable  = _G.setmetatable\n\n    local moduleCache       = {}\n    local packageGlobals    = {}\n\n    local function makeEnvironment(moduleChunk)\n        local exports = {}\n\n        local moduleEnvironment = setmetatable({}, {\n            __index = function (self, key)\n                if exports[key] ~= nil then\n                    return exports[key]\n                end\n\n                return _G[key]\n            end,\n\n            __newindex = exports\n        })\n\n        return setfenv(moduleChunk, moduleEnvironment), exports\n    end\n\n    local function makeModuleHeader(moduleName)\n        return {\n            name    = moduleName,\n            globals = packageGlobals\n        }\n    end\n\n    local function makeReadOnly(tbl)\n        return setmetatable({}, {\n            __index = tbl,\n            __newindex = function (self, key, value) error(\"module 'exports' table is read only\") end\n        })\n    end\n\n    local import = nil\n    function import(moduleName, ...)\n        local moduleChunk = modules[moduleName]\n        if not moduleChunk then error(\"bad argument #1 to 'import' (invalid module, got '\"..moduleName..\"')\") end\n\n        if not moduleCache[moduleName] then\n            local moduleHeader                  = makeModuleHeader(moduleName)\n            local moduleEnvironment, exports    = makeEnvironment(moduleChunk)\n\n            moduleEnvironment(moduleHeader, exports, import, import, ...)\n\n            moduleCache[moduleName] = makeReadOnly(exports)\n        end\n\n        return moduleCache[moduleName]\n    end\n\n    "..tostring(n).."\n\n    return import('"..tostring(e).."', ...)\nend)({"end
TEMPLATE_HEADER_DEVELOPMENT=function(e)return TEMPLATE_HEADER_PACKAGE(e,"local loadstring = _G.loadstring\n\n    for moduleName, assetChunk in pairs(modules) do\n        modules[moduleName] = loadstring('return function (module, exports, import, dependency, ...) '..assetChunk..' end', moduleName)()\n    end")end
TEMPLATE_FOOTER_PACKAGE=function()return"}, ...)"end
TEMPLATE_MODULE_PACKAGE=function(e,n)return"['"..tostring(e).."'] = function (module, exports, import, dependency, ...) "..tostring(n).." end,\n"end
TEMPLATE_MODULE_DEVELOPMENT=function(n,t)return"['"..tostring(n).."'] = "..tostring(e('%q',t))..",\n"end
LuaPlatform=n:extend({generatePackageHeader=function(n,e)return n.isProduction and TEMPLATE_HEADER_PACKAGE(e,"")or TEMPLATE_HEADER_DEVELOPMENT(e)end,generatePackageModule=function(t,n,e)return t.isProduction and TEMPLATE_MODULE_PACKAGE(n,e)or TEMPLATE_MODULE_DEVELOPMENT(n,e)end,generatePackageFooter=function(e)return TEMPLATE_FOOTER_PACKAGE()end,transformPackage=function(n,e)return n.isProduction and l(e,t)or e
end})setMinificationLevel=function(e)t=e
end end,['novacbn/gmodproj-plugin-builtin/templates/AddonTemplate']=function(e,e,e,e,...)local e
e=gmodproj.api.Template
AddonTemplate=e:extend({createProject=function(e)e:createDirectory("addons")e:createDirectory("addons/"..tostring(e.projectName))e:createDirectory("addons/"..tostring(e.projectName).."/lua")e:createDirectory("addons/"..tostring(e.projectName).."/lua/autorun")e:createDirectory("addons/"..tostring(e.projectName).."/lua/autorun/client")e:createDirectory("addons/"..tostring(e.projectName).."/lua/autorun/server")e:createDirectory("src")e:writeJSON("addons/"..tostring(e.projectName).."/addon.json",{title=e.projectName,type="",tags={},description="",ignore={}})local n=e.projectAuthor.."/"..e.projectName
e:write("src/client.lua","imp".."ort('"..tostring(n).."/shared').sharedFunc()\nprint('I was called on the client!')")e:write("src/server.lua","imp".."ort('"..tostring(n).."/shared').sharedFunc()\nprint('I was called on the server!')")e:write("src/shared.lua","function sharedFunc()\n\tprint('I was called on the client and server!')\nend")return e:writeDataFile("manifest.gmodproj",{Project={projectName=e.projectName,projectAuthor=e.projectAuthor,projectVersion="0.0.0",projectRepository="unknown://unknown",buildDirectory="addons/"..tostring(e.projectName).."/lua",entryPoints={{tostring(n).."/client","autorun/client/"..tostring(e.projectName)..".client"},{tostring(n).."/server","autorun/server/"..tostring(e.projectName)..".server"}}}})end})end,['novacbn/gmodproj-plugin-builtin/templates/GamemodeTemplate']=function(e,e,e,e,...)local t
t=string.format
local a,n
do
local e=table
a,n=e.concat,e.insert
end
local o
o=gmodproj.api.Template
local r
r=function(e)return t([["%s"
{
    "base"			"base"
    "title"			"%s"
    "maps"			""
    "menusystem"	"1"

    "settings" {}
}]],e,e)end
local l
l=function(t,l)local e={}if t then
n(e,"-- These scripts are sent to the client")for l=1,#t do
local t=t[l]n(e,"AddCSLuaFile('"..tostring(t).."')")end
end
if l then
n(e,"-- These scripts are bootloaded by this script")for t=1,#l do
local t=l[t]n(e,"include('"..tostring(t).."')")end
end
return a(e,"\n")end
GamemodeTemplate=o:extend({createProject=function(e)e:createDirectory("gamemodes")e:createDirectory("gamemodes/"..tostring(e.projectName))e:createDirectory("gamemodes/"..tostring(e.projectName).."/gamemode")e:createDirectory("src")e:write("gamemodes/"..tostring(e.projectName).."/"..tostring(e.projectName)..".txt",r(e.projectName))e:write("gamemodes/"..tostring(e.projectName).."/gamemode/cl_init.lua",l(nil,{tostring(e.projectName)..".client.lua"}))e:write("gamemodes/"..tostring(e.projectName).."/gamemode/init.lua",l({"cl_init.lua",tostring(e.projectName)..".client.lua"},{tostring(e.projectName)..".server.lua"}))local n=e.projectAuthor.."/"..e.projectName
e:write("src/client.lua","imp".."ort('"..tostring(n).."/shared').sharedFunc()\nprint('I was called on the client!')")e:write("src/server.lua","imp".."ort('"..tostring(n).."/shared').sharedFunc()\nprint('I was called on the server!')")e:write("src/shared.lua","function sharedFunc()\n\tprint('I was called on the client and server!')\nend")return e:writeDataFile("manifest.gmodproj",{Project={projectName=e.projectName,projectAuthor=e.projectAuthor,projectVersion="0.0.0",projectRepository="unknown://unknown",buildDirectory="gamemodes/"..tostring(e.projectName).."/gamemode",entryPoints={{tostring(n).."/client",tostring(e.projectName)..".client"},{tostring(n).."/server",tostring(e.projectName)..".server"}}}})end})end,['novacbn/gmodproj-plugin-builtin/templates/PackageTemplate']=function(e,e,e,e,...)local t
t=gmodproj.api.Template
local l
l=function(n,e)return"-- Code within this project can be imported by dependent project that have this installed\n-- E.g. If this was exported:\nfunction add(x, y)\n    return x + y\nend\n\n-- Then project that have this project installed via 'gmodproj install' could import it via:\nlocal "..tostring(e).." = imp".."ort('"..tostring(n).."/"..tostring(e).."/main')\nprint("..tostring(e)..".add(1, 2)) -- Prints '3' to console\n\n\n\n-- Alternatively, if this package was built with `gmodproj build`, you could import the entire library in Garry's Mod:\nlocal "..tostring(e).." = include('"..tostring(n).."."..tostring(e)..".lua')\nprint("..tostring(e)..".add(1, 2)) -- Prints '3' to console\n\n-- NOTE: when doing this, only the 'main.lua' exports can be used\n-- If you were to have this in 'substract.lua':\nfunction substract(a, b)\n    return a - b\nend\n\n-- You would need to alias the export in 'main.lua' to use it in a standard script:\nexports.substract = imp".."ort('"..tostring(n).."/"..tostring(e).."/substract')\n\n-- Then in a standard Garry's Mod script:\nlocal "..tostring(e).." = include('"..tostring(n).."."..tostring(e)..".lua')\nprint("..tostring(e)..".substract(3, 1)) -- Prints '2' to console\n"end
PackageTemplate=t:extend({createProject=function(e)e:createDirectory("dist")e:createDirectory("src")e:write("src/main.lua",l(e.projectAuthor,e.projectName))return e:writeDataFile("manifest.gmodproj",{Project={projectName=e.projectName,projectAuthor=e.projectAuthor,projectVersion="0.0.0",projectRepository="unknown://unknown",entryPoints={{tostring(e.projectAuthor).."/"..tostring(e.projectName).."/main",tostring(e.projectAuthor).."."..tostring(e.projectName)}}}})end})end,['rxi/json/main']=function(e,i,e,e,...)i._version="0.1.1"local t
local n={["\\"]="\\\\",['"']='\\"',["\b"]="\\b",["\f"]="\\f",["\n"]="\\n",["\r"]="\\r",["\t"]="\\t",}local c={["\\/"]="/"}for e,n in pairs(n)do
c[n]=e
end
local function r(e)return n[e]or string.format("\\u%04x",e:byte())end
local function d(e)return"null"end
local function a(e,n)local l={}n=n or{}if n[e]then error("circular reference")end
n[e]=true
if e[1]~=nil or next(e)==nil then
local o=0
for e in pairs(e)do
if type(e)~="number"then
error("invalid table: mixed or invalid key types")end
o=o+1
end
if o~=#e then
error("invalid table: sparse array")end
for o,e in ipairs(e)do
table.insert(l,t(e,n))end
n[e]=nil
return"["..table.concat(l,",").."]"else
for e,o in pairs(e)do
if type(e)~="string"then
error("invalid table: mixed or invalid key types")end
table.insert(l,t(e,n)..":"..t(o,n))end
n[e]=nil
return"{"..table.concat(l,",").."}"end
end
local function n(e)return'"'..e:gsub('[%z\1-\31\\"]',r)..'"'end
local function l(e)if e~=e or e<=-math.huge or e>=math.huge then
error("unexpected number value '"..tostring(e).."'")end
return string.format("%.14g",e)end
local n={["nil"]=d,["table"]=a,["string"]=n,["number"]=l,["boolean"]=tostring,}t=function(e,l)local t=type(e)local n=n[t]if n then
return n(e,l)end
error("unexpected type '"..t.."'")end
function i.encode(e)return(t(e))end
local r
local function e(...)local e={}for n=1,select("#",...)do
e[select(n,...)]=true
end
return e
end
local a=e(" ","\t","\r","\n")local s=e(" ","\t","\r","\n","]","}",",")local h=e("\\","/",'"',"b","f","n","r","t","u")local u=e("true","false","null")local m={["true"]=true,["false"]=false,["null"]=nil,}local function o(e,n,l,t)for n=n,#e do
if l[e:sub(n,n)]~=t then
return n
end
end
return#e+1
end
local function t(o,t,l)local n=1
local e=1
for t=1,t-1 do
e=e+1
if o:sub(t,t)=="\n"then
n=n+1
e=1
end
end
error(string.format("%s at line %d col %d",l,n,e))end
local function l(e)local n=math.floor
if e<=127 then
return string.char(e)elseif e<=2047 then
return string.char(n(e/64)+192,e%64+128)elseif e<=65535 then
return string.char(n(e/4096)+224,n(e%4096/64)+128,e%64+128)elseif e<=1114111 then
return string.char(n(e/262144)+240,n(e%262144/4096)+128,n(e%4096/64)+128,e%64+128)end
error(string.format("invalid unicode codepoint '%x'",e))end
local function d(e)local n=tonumber(e:sub(3,6),16)local e=tonumber(e:sub(9,12),16)if e then
return l((n-55296)*1024+(e-56320)+65536)else
return l(n)end
end
local function f(e,o)local s=false
local i=false
local r=false
local a
for n=o+1,#e do
local l=e:byte(n)if l<32 then
t(e,n,"control character in string")end
if a==92 then
if l==117 then
local l=e:sub(n+1,n+5)if not l:find("%x%x%x%x")then
t(e,n,"invalid unicode escape in string")end
if l:find("^[dD][89aAbB]")then
i=true
else
s=true
end
else
local l=string.char(l)if not h[l]then
t(e,n,"invalid escape char '"..l.."' in string")end
r=true
end
a=nil
elseif l==34 then
local e=e:sub(o+1,n-1)if i then
e=e:gsub("\\u[dD][89aAbB]..\\u....",d)end
if s then
e=e:gsub("\\u....",d)end
if r then
e=e:gsub("\\.",c)end
return e,n+1
else
a=l
end
end
t(e,o,"expected closing quote for string")end
local function l(n,e)local a=o(n,e,s)local o=n:sub(e,a-1)local l=tonumber(o)if not l then
t(n,e,"invalid number '"..o.."'")end
return l,a
end
local function c(l,n)local o=o(l,n,s)local e=l:sub(n,o-1)if not u[e]then
t(l,n,"invalid literal '"..e.."'")end
return m[e],o
end
local function s(n,e)local c={}local l=1
e=e+1
while 1 do
local i
e=o(n,e,a,true)if n:sub(e,e)=="]"then
e=e+1
break
end
i,e=r(n,e)c[l]=i
l=l+1
e=o(n,e,a,true)local l=n:sub(e,e)e=e+1
if l=="]"then break end
if l~=","then t(n,e,"expected ']' or ','")end
end
return c,e
end
local function d(n,e)local l={}e=e+1
while 1 do
local c,i
e=o(n,e,a,true)if n:sub(e,e)=="}"then
e=e+1
break
end
if n:sub(e,e)~='"'then
t(n,e,"expected string for key")end
c,e=r(n,e)e=o(n,e,a,true)if n:sub(e,e)~=":"then
t(n,e,"expected ':' after key")end
e=o(n,e+1,a,true)i,e=r(n,e)l[c]=i
e=o(n,e,a,true)local l=n:sub(e,e)e=e+1
if l=="}"then break end
if l~=","then t(n,e,"expected '}' or ','")end
end
return l,e
end
local l={['"']=f,["0"]=l,["1"]=l,["2"]=l,["3"]=l,["4"]=l,["5"]=l,["6"]=l,["7"]=l,["8"]=l,["9"]=l,["-"]=l,["t"]=c,["f"]=c,["n"]=c,["["]=s,["{"]=d,}r=function(n,e)local o=n:sub(e,e)local l=l[o]if l then
return l(n,e)end
t(n,e,"unexpected character '"..o.."'")end
function i.decode(e)if type(e)~="string"then
error("expected argument of type string, got "..type(e))end
local l,n=r(e,o(e,1,a,true))n=o(e,n,a,true)if n<=#e then
t(e,n,"trailing garbage")end
return l
end end,},...)