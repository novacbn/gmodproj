return(function(d,...)local n=_G
local o=n.error
local r=n.setfenv
local l=n.setmetatable
local t={}local c={}local function a(o)local e={}local n=l({},{__index=function(l,t)if e[t]~=nil then
return e[t]end
return n[t]end,__newindex=e})return r(o,n),e
end
local function i(e)return{name=e,globals=c}end
local function r(e)return l({},{__index=e,__newindex=function(e,e,e)o("module 'exports' table is read only")end})end
local n=nil
function n(e,...)local l=d[e]if not l then o("bad argument #1 to 'import' (invalid module, got '"..e.."')")end
if not t[e]then
local i=i(e)local o,l=a(l)o(i,l,n,n,...)t[e]=r(l)end
return t[e]end
return n('novacbn/gmodproj-plugin-builtin/Plugin',...)end)({['jonstoler/toml/main']=function(e,e,e,e,...)version=.4
strict=true
function parse(d,e)e=e or{}local i=(e.strict~=nil and e.strict or strict)local s="[\t ]"local o="[\n"do
local e="\r\n"o=o..e
end
o=o.."]"local t=""local r=1
local m={}local l=m
local function e(e)e=e or 0
return d:sub(r+e,r+e)end
local function n(e)e=e or 1
r=r+e
end
local function c()while(e():match(s))do
n()end
end
local function h(e)return e:gsub("^%s*(.-)%s*$","%1")end
local function a(l,e)if l==""then return{}end
local t={}local n=e
if e:match("%%")then
n=e:gsub("%%","")end
for e in(l..n):gmatch("(.-)"..e)do
table.insert(t,e)end
return t
end
local function a(t,e)if not e or(e and i)then
local n=1
local e=0
for t in d:gmatch("(.-)"..o)do
e=e+t:len()if e>=r then
break
end
n=n+1
end
error("TOML: "..t.." on line "..n..".",4)end
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
local l={b="\b",t="\t",n="\n",f="\f",r="\r",['"']='"',["\\"]="\\",}local function o(e)local t={{2047,192},{65535,224},{2097151,240}}if e<128 then return string.char(e)end
local n={}for l,t in pairs(t)do
if e<=t[1]then
for l=l+1,2,-1 do
local t=e%64
e=(e-t)/64
n[l]=string.char(128+t)end
n[1]=string.char(t[2]+e)break
end
end
return table.concat(n)end
if l[e(1)]then
t=t..l[e(1)]n(2)elseif e(1)=="u"then
n()local e=e(1)..e(2)..e(3)..e(4)n(5)e=tonumber(e,16)if(e>=0 and e<=55295)and not(e>=57344 and e<=1114111)then
t=t..o(e)else
a("Unicode escape is not a Unicode scalar")end
elseif e(1)=="U"then
n()local e=e(1)..e(2)..e(3)..e(4)..e(5)..e(6)..e(7)..e(8)n(9)e=tonumber(e,16)if(e>=0 and e<=55295)and not(e>=57344 and e<=1114111)then
t=t..o(e)else
a("Unicode escape is not a Unicode scalar")end
else
a("Invalid escape")end
end
else
t=t..e()n()end
end
return{value=t,type="string"}end
local function b()local t=""local l
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
local function g()n()local t=""local l=false
local r={}while i()do
if e()=="}"then
break
elseif e()=="'"or e()=='"'then
t=f().value
l=true
elseif e()=="="then
if not l then
t=h(t)end
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
local function p()local t
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
return b()elseif e()=="["then
return s()elseif e()=="{"then
return g()else
return p()end
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
n()c()t=h(t)if t:match("^[0-9]*$")and not s then
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
l=m
local function r(e)e=e or false
t=h(t)if not s and t==""then
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
return m
end
function encode(c)local n=""local t={}local function o(e)for l,e in pairs(e)do
if type(e)=="boolean"then
n=n..l.." = "..tostring(e).."\n"elseif type(e)=="number"then
n=n..l.." = "..tostring(e).."\n"elseif type(e)=="string"then
local t='"'e=e:gsub("\\","\\\\")if e:match("^\n(.*)$")then
t=t:rep(3)e="\\n"..e
elseif e:match("\n")then
t=t:rep(3)end
e=e:gsub("\b","\\b")e=e:gsub("\t","\\t")e=e:gsub("\f","\\f")e=e:gsub("\r","\\r")e=e:gsub('"','\\"')e=e:gsub("/","\\/")n=n..l.." = "..t..e..t.."\n"elseif type(e)=="table"then
local i,r=true,true
local a={}for n,t in pairs(e)do
if type(n)~="number"then i=false end
if type(t)~="table"then
e[n]=nil
a[n]=t
r=false
end
end
if i then
if r then
table.insert(t,l)for l,e in pairs(e)do
n=n.."[["..table.concat(t,".").."]]\n"for n,t in pairs(e)do
if type(t)~="table"then
e[n]=nil
a[n]=t
end
end
o(a)o(e)end
table.remove(t)else
n=n..l.." = [\n"for t,e in pairs(a)do
n=n..tostring(e)..",\n"end
n=n.."]\n"end
else
table.insert(t,l)n=n.."["..table.concat(t,".").."]\n"o(a)o(e)table.remove(t)end
end
end
end
o(c)return n:sub(1,-2)end end,['matthewwild/minify/llex']=function(e,e,e,e,...)local h=_G
local i=require"string"local d=i.find
local f=i.match
local a=i.sub
local m={}for e in i.gmatch([[
and break do else elseif end false for function if in
local nil not or repeat return then true until while]],"%S+")do
m[e]=true
end
local e,c,t,o,r
local function l(n,t)local e=#tok+1
tok[e]=n
seminfo[e]=t
tokln[e]=r
end
local function s(n,i)local a=a
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
c=o
t=1
r=1
tok={}seminfo={}tokln={}local n,a,e,o=d(e,"^(#[^\r\n]*)(\r?\n?)")if n then
t=t+#e
l("TK_COMMENT",e)if#o>0 then s(t,true)end
end
end
function chunkid()if c and f(c,"^[=@]")then
return a(c,2)end
return"[string]"end
function errorline(e,t)local n=error or h.error
n(i.format("%s:%d: %s",chunkid(),t or r,e))end
local c=errorline
local function u(n)local o=a
local a=o(e,n,n)n=n+1
local l=#f(e,"=*",n)n=n+l
t=n
return(o(e,n,n)==a)and l or(-l)-1
end
local function p(f,r)local n=t+1
local l=a
local a=l(e,n,n)if a=="\r"or a=="\n"then
n=s(n)end
local a=n
while true do
local a,d,i=d(e,"([\r\n%]])",n)if not a then
c(f and"unfinished long string"or"unfinished long comment")end
n=a
if i=="]"then
if u(n)==r then
o=l(e,o,t)t=t+1
return o
end
n=t
else
o=o.."\n"n=s(n)end
end
end
local function g(f)local n=t
local r=d
local i=a
while true do
local a,d,l=r(e,"([\n\r\\\"'])",n)if a then
if l=="\n"or l=="\r"then
c("unfinished string")end
n=a
if l=="\\"then
n=n+1
l=i(e,n,n)if l==""then break end
a=r("abfnrtv\n\r",l,1,true)if a then
if a>7 then
n=s(n)else
n=n+1
end
elseif r(l,"%D")then
n=n+1
else
local l,e,t=r(e,"^(%d%d?%d?)",n)n=e+1
if t+1>256 then
c("escape sequence too large")end
end
else
n=n+1
if l==f then
t=n
return i(e,o,n-1)end
end
else
break
end
end
c("unfinished string")end
function llex()local r=d
local d=f
while true do
local n=t
while true do
local f,b,i=r(e,"^([_%a][_%w]*)",n)if f then
t=n+#i
if m[i]then
l("TK_KEYWORD",i)else
l("TK_NAME",i)end
break
end
local i,m,f=r(e,"^(%.?)%d",n)if i then
if f=="."then n=n+1 end
local f,o,s=r(e,"^%d*[%.%d]*([eE]?)",n)n=o+1
if#s==1 then
if d(e,"^[%+%-]",n)then
n=n+1
end
end
local o,n=r(e,"^[_%w]*",n)t=n+1
local e=a(e,i,n)if not h.tonumber(e)then
c("malformed number")end
l("TK_NUMBER",e)break
end
local h,f,m,i=r(e,"^((%s)[ \t\v\f]*)",n)if h then
if i=="\n"or i=="\r"then
s(n,true)else
t=f+1
l("TK_SPACE",m)end
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
l("TK_LCOMMENT",p(false,i))else
t=r(e,"[\n\r]",n)or(#e+1)l("TK_COMMENT",a(e,o,t-1))end
break
end
else
local e=u(n)if e>=0 then
l("TK_LSTRING",p(true,e))elseif e==-1 then
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
end,['matthewwild/minify/lparser']=function(e,ee,e,e,...)local O=_G
local T=require"string"local L,E,j,V,c,r,J,n,v,d,h,g,t,R,w,M,f,_,y
local p,i,b,x,N,k
local e=T.gmatch
local S={}for e in e("else elseif end until <eof>","%S+")do
S[e]=true
end
local W={}for e in e("if while do for repeat function local return break","%S+")do
W[e]=e.."_stat"end
local P={}local z={}for e,t,n in e([[
{+ 6 6}{- 6 6}{* 7 7}{/ 7 7}{% 7 7}
{^ 10 9}{.. 5 4}
{~= 3 3}{== 3 3}
{< 3 3}{<= 3 3}{> 3 3}{>= 3 3}
{and 2 2}{or 1 1}
]],"{(%S+)%s(%d+)%s(%d+)}")do
P[e]=t+0
z[e]=n+0
end
local Z={["not"]=true,["-"]=true,["#"]=true,}local Q=8
local function l(n,e)local t=error or O.error
t(T.format("(source):%d: %s",e or d,n))end
local function e()J=j[c]n,v,d,h=L[c],E[c],j[c],V[c]c=c+1
end
local function X()return L[c]end
local function s(t)local e=n
if e~="<number>"and e~="<string>"then
if e=="<name>"then e=v end
e="'"..e.."'"end
l(t.." near "..e)end
local function u(e)s("'"..e.."' expected")end
local function l(t)if n==t then e();return true end
end
local function C(e)if n~=e then u(e)end
end
local function o(n)C(n);e()end
local function Y(e,n)if not e then s(n)end
end
local function a(e,t,n)if not l(e)then
if n==d then
u(e)else
s("'"..e.."' expected (to close '"..t.."' at line "..n..")")end
end
end
local function u()C("<name>")local n=v
g=h
e()return n
end
local function G(e,n)e.k="VK"end
local function D(e)G(e,u())end
local function m(o,l)local n=t.bl
local e
if n then
e=n.locallist
else
e=t.locallist
end
local n=#f+1
f[n]={name=o,xref={g},decl=g,}if l then
f[n].isself=true
end
local t=#_+1
_[t]=n
y[t]=e
end
local function A(e)local n=#_
while e>0 do
e=e-1
local e=n-e
local t=_[e]local n=f[t]local l=n.name
n.act=h
_[e]=nil
local o=y[e]y[e]=nil
local e=o[l]if e then
n=f[e]n.rem=-t
end
o[l]=t
end
end
local function K()local n=t.bl
local e
if n then
e=n.locallist
else
e=t.locallist
end
for n,e in O.pairs(e)do
local e=f[e]e.rem=h
end
end
local function h(e,n)if T.sub(e,1,1)=="("then
return
end
m(e,n)end
local function O(l,t)local n=l.bl
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
local t=O(n,l)if t>=0 then
e.k="VLOCAL"e.id=t
return"VLOCAL"else
if T(n.prev,l,e)=="VGLOBAL"then
return"VGLOBAL"end
e.k="VUPVAL"return"VUPVAL"end
end
end
local function q(l)local n=u()T(t,n,l)if l.k=="VGLOBAL"then
local e=M[n]if not e then
e=#w+1
w[e]={name=n,xref={g},}M[n]=e
else
local e=w[e].xref
e[#e+1]=g
end
else
local e=l.id
local e=f[e].xref
e[#e+1]=g
end
end
local function T(n)local e={}e.isbreakable=n
e.prev=t.bl
e.locallist={}t.bl=e
end
local function g()local e=t.bl
K()t.bl=e.prev
end
local function F()local e
if not t then
e=R
else
e={}end
e.prev=t
e.bl=nil
e.locallist={}t=e
end
local function H()K()t=t.prev
end
local function K(t)local n={}e()D(n)t.k="VINDEXED"end
local function B(n)e()i(n)o("]")end
local function U(e)local e,t={},{}if n=="<name>"then
D(e)else
B(e)end
o("=")i(t)end
local function O(e)if e.v.k=="VVOID"then return end
e.v.k="VVOID"end
local function O(e)i(e.v)end
local function I(t)local r=d
local e={}e.v={}e.t=t
t.k="VRELOCABLE"e.v.k="VVOID"o("{")repeat
if n=="}"then break end
local n=n
if n=="<name>"then
if X()~="="then
O(e)else
U(e)end
elseif n=="["then
U(e)else
O(e)end
until not l(",")and not l(";")a("}","{",r)end
local function X()local o=0
if n~=")"then
repeat
local n=n
if n=="<name>"then
m(u())o=o+1
elseif n=="..."then
e()t.is_vararg=true
else
s("<name> or '...' expected")end
until t.is_vararg or not l(",")end
A(o)end
local function U(r)local t={}local o=d
local l=n
if l=="("then
if o~=J then
s("ambiguous syntax (function call x new statement)")end
e()if n==")"then
t.k="VVOID"else
p(t)end
a(")","(",o)elseif l=="{"then
I(t)elseif l=="<string>"then
G(t,v)e()else
s("function arguments expected")return
end
r.k="VCALL"end
local function J(t)local n=n
if n=="("then
local n=d
e()i(t)a(")","(",n)elseif n=="<name>"then
q(t)else
s("unexpected symbol")end
end
local function O(t)J(t)while true do
local n=n
if n=="."then
K(t)elseif n=="["then
local e={}B(e)elseif n==":"then
local n={}e()D(n)U(t)elseif n=="("or n=="<string>"or n=="{"then
U(t)else
return
end
end
end
local function D(l)local n=n
if n=="<number>"then
l.k="VKNUM"elseif n=="<string>"then
G(l,v)elseif n=="nil"then
l.k="VNIL"elseif n=="true"then
l.k="VTRUE"elseif n=="false"then
l.k="VFALSE"elseif n=="..."then
Y(t.is_vararg==true,"cannot use '...' outside a vararg function");l.k="VVARARG"elseif n=="{"then
I(l)return
elseif n=="function"then
e()N(l,false,d)return
else
O(l)return
end
e()end
local function v(l,o)local t=n
local a=Z[t]if a then
e()v(l,Q)else
D(l)end
t=n
local n=P[t]while n and n>o do
local l={}e()local e=v(l,z[t])t=e
n=P[t]end
return t
end
function i(e)v(e,0)end
local function P(e)local n={}local e=e.v.k
Y(e=="VLOCAL"or e=="VUPVAL"or e=="VGLOBAL"or e=="VINDEXED","syntax error")if l(",")then
local e={}e.v={}O(e.v)P(e)else
o("=")p(n)return
end
n.k="VNONRELOC"end
local function v(e,n)o("do")T(false)A(e)b()g()end
local function D(e)local n=r
h("(for index)")h("(for limit)")h("(for step)")m(e)o("=")x()o(",")x()if l(",")then
x()else
end
v(1,true)end
local function G(e)local n={}h("(for generator)")h("(for state)")h("(for control)")m(e)local e=1
while l(",")do
m(u())e=e+1
end
o("in")local t=r
p(n)v(e,false)end
local function I(e)local t=false
q(e)while n=="."do
K(e)end
if n==":"then
t=true
K(e)end
return t
end
function x()local e={}i(e)end
local function v()local e={}i(e)end
local function x()e()v()o("then")b()end
local function U()local e,n={}m(u())e.k="VLOCAL"A(1)N(n,false,d)end
local function K()local e=0
local n={}repeat
m(u())e=e+1
until not l(",")if l("=")then
p(n)else
n.k="VVOID"end
A(e)end
function p(e)i(e)while l(",")do
i(e)end
end
function N(t,e,n)F()o("(")if e then
h("self",true)A(1)end
X()o(")")k()a("end","function",n)H()end
function b()T(false)k()g()end
function for_stat()local l=r
T(true)e()local t=u()local e=n
if e=="="then
D(t)elseif e==","or e=="in"then
G(t)else
s("'=' or 'in' expected")end
a("end","for",l)g()end
function while_stat()local n=r
e()v()T(true)o("do")b()a("end","while",n)g()end
function repeat_stat()local n=r
T(true)T(false)e()k()a("until","repeat",n)v()g()g()end
function if_stat()local t=r
local l={}x()while n=="elseif"do
x()end
if n=="else"then
e()b()end
a("end","if",t)end
function return_stat()local t={}e()local e=n
if S[e]or e==";"then
else
p(t)end
end
function break_stat()local n=t.bl
e()while n and not n.isbreakable do
n=n.prev
end
if not n then
s("no loop to break")end
end
function expr_stat()local e={}e.v={}O(e.v)if e.v.k=="VCALL"then
else
e.prev=nil
P(e)end
end
function function_stat()local l=r
local t,n={},{}e()local e=I(t)N(n,e,l)end
function do_stat()local n=r
e()b()a("end","do",n)end
function local_stat()e()if l("function")then
U()else
K()end
end
local function o()r=d
local e=n
local n=W[e]if n then
ee[n]()if e=="return"or e=="break"then return true end
else
expr_stat()end
return false
end
function k()local e=false
while not e and not S[n]do
e=o()l(";")end
end
function parser()F()t.is_vararg=true
e()k()C("<eof>")H()return w,f
end
function init(e,o,a)c=1
R={}local n=1
L,E,j,V={},{},{},{}for t=1,#e do
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
L[n]=e
j[n]=a[t]V[n]=t
n=n+1
end
end
w,M,f={},{},{}_,y={},{}end
end,['matthewwild/minify/main']=function(n,n,e,n,...)local d=table.concat
local n=e"matthewwild/minify/llex"local o=e"matthewwild/minify/lparser"local c=e"matthewwild/minify/optlex"local i=e"matthewwild/minify/optparser"local r={basic={"comments","whitespace","emptylines"},debug={"whitespace","locals","entropy","comments","numbers"},default={"comments","whitespace","emptylines","numbers","locals"},full={"comments","whitespace","emptylines","eols","strings","numbers","locals","entropy"}}local t={["comments"]="opt-comments",["emptylines"]="opt-emptylines",["entropy"]="opt-entropy",["eols"]="opt-eols",["locals"]="opt-locals",["numbers"]="opt-numbers",["strings"]="opt-strings",["whitespace"]="opt-whitespace"}local function a(l)local n={}local e
for o,l in pairs(l)do
e=t[l]if e then
n[e]=true
end
end
return n
end
function minify(t,e)if e=="none"then return t end
assert(type(e)=="string","bad argument #1 to 'minify' (expected string)")assert(type(e)=="table"or type(e)=="string","bad argument #2 to 'minify' (expected string or table)")if type(e)=="string"then
e=assert(r[e],"bad argument #2 to 'minify' (invalid minification level)")end
e=a(e)n.init(t)n.llex()local t,n,l=n.tok,n.seminfo,n.tokln
if e["opt-locals"]then
o.init(t,n,l)local l,o=o.parser()i.optimize(e,t,n,l,o)end
t,n,l=c.optimize(e,t,n,l)return d(n)end end,['matthewwild/minify/optlex']=function(e,e,e,e,...)local r=_G
local f=require"string"local l=f.match
local e=f.sub
local d=f.find
local c=f.rep
local g
error=r.error
warn={}local a,o,s
local T={TK_KEYWORD=true,TK_NAME=true,TK_NUMBER=true,TK_STRING=true,TK_LSTRING=true,TK_OP=true,TK_EOS=true,}local b={TK_COMMENT=true,TK_LCOMMENT=true,TK_EOL=true,TK_SPACE=true,}local i
local function E(e)local n=a[e-1]if e<=1 or n=="TK_EOL"then
return true
elseif n==""then
return E(e-1)end
return false
end
local function _(n)local e=a[n+1]if n>=#a or e=="TK_EOL"or e=="TK_EOS"then
return true
elseif e==""then
return _(n+1)end
return false
end
local function A(n)local t=#l(n,"^%-%-%[=*%[")local t=e(n,t+1,-(t-1))local e,n=1,0
while true do
local t,a,o,l=d(t,"([\r\n])([\r\n]?)",e)if not t then break end
e=t+1
n=n+1
if#l>0 and o~=l then
e=e+1
end
end
return n
end
local function w(i,r)local t=l
local n,e=a[i],a[r]if n=="TK_STRING"or n=="TK_LSTRING"or
e=="TK_STRING"or e=="TK_LSTRING"then
return""elseif n=="TK_OP"or e=="TK_OP"then
if(n=="TK_OP"and(e=="TK_KEYWORD"or e=="TK_NAME"))or(e=="TK_OP"and(n=="TK_KEYWORD"or n=="TK_NAME"))then
return""end
if n=="TK_OP"and e=="TK_OP"then
local n,e=o[i],o[r]if(t(n,"^%.%.?$")and t(e,"^%."))or(t(n,"^[~=<>]$")and e=="=")or(n=="["and(e=="["or e=="="))then
return" "end
return""end
local n=o[i]if e=="TK_OP"then n=o[r]end
if t(n,"^%.%.?%.?$")then
return" "end
return""else
return" "end
end
local function v()local i,r,t={},{},{}local e=1
for n=1,#a do
local l=a[n]if l~=""then
i[e],r[e],t[e]=l,o[n],s[n]e=e+1
end
end
a,o,s=i,r,t
end
local function N(d)local n=o[d]local n=n
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
local t=#l(n,"^0*")local t=#n-t
local l=r.tostring(#n)if t+2+#l<1+#n then
a=e(n,-t).."e-"..l
end
end
end
else
local n,t=l(n,"^([^eE]+)[eE]([%+%-]?%d+)$")t=r.tonumber(t)local i,o=l(n,"^(%d*)%.(%d*)$")if i then
t=t-#o
n=i..o
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
if a and a~=o[d]then
if i then
i=i+1
end
o[d]=a
end
end
local function j(s)local n=o[s]local r=e(n,1,1)local u=(r=="'")and'"'or"'"local n=e(n,2,-2)local t=1
local c,a=0,0
while t<=#n do
local h=e(n,t,t)if h=="\\"then
local o=t+1
local s=e(n,o,o)local i=d("abfnrtv\\\n\r\"'0123456789",s,1,true)if not i then
n=e(n,1,t-1)..e(n,o)t=t+1
elseif i<=8 then
t=t+2
elseif i<=10 then
local l=e(n,o,o+1)if l=="\r\n"or l=="\n\r"then
n=e(n,1,t).."\n"..e(n,o+2)elseif i==10 then
n=e(n,1,t).."\n"..e(n,o+1)end
t=t+2
elseif i<=12 then
if s==r then
c=c+1
t=t+2
else
a=a+1
n=e(n,1,t-1)..e(n,o)t=t+1
end
else
local l=l(n,"^(%d%d?%d?)",o)o=t+1+#l
local s=l+0
local i=f.char(s)local d=d("\a\b\f\n\r\t\v",i,1,true)if d then
l="\\"..e("abfnrtv",d,d)elseif s<32 then
l="\\"..s
elseif i==r then
l="\\"..i
c=c+1
elseif i=="\\"then
l="\\\\"else
l=i
if i==u then
a=a+1
end
end
n=e(n,1,t-1)..l..e(n,o)t=t+#l
end
else
t=t+1
if h==u then
a=a+1
end
end
end
if c>a then
t=1
while t<=#n do
local l,a,o=d(n,"(['\"])",t)if not l then break end
if o==r then
n=e(n,1,l-2)..e(n,l)t=l
else
n=e(n,1,l-1).."\\"..e(n,l)t=l+2
end
end
r=u
end
n=r..n..r
if n~=o[s]then
if i then
i=i+1
end
o[s]=n
end
end
local function L(f)local n=o[f]local i=l(n,"^%[=*%[")local t=#i
local u=e(n,-t,-1)local r=e(n,t+1,-(t+1))local a=""local n=1
while true do
local t,o,c,i=d(r,"([\r\n])([\r\n]?)",n)local o
if not t then
o=e(r,n)elseif t>=n then
o=e(r,n,t-1)end
if o~=""then
if l(o,"%s+$")then
warn.lstring="trailing whitespace in long string near line "..s[f]end
a=a..o
end
if not t then
break
end
n=t+1
if t then
if#i>0 and c~=i then
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
t=c("=",n-2)i,u="["..t.."[","]"..t.."]"end
end
o[f]=i..a..u
end
local function h(f)local t=o[f]local i=l(t,"^%-%-%[=*%[")local n=#i
local s=e(t,-n,-1)local r=e(t,n+1,-(n-1))local a=""local t=1
while true do
local o,n,c,i=d(r,"([\r\n])([\r\n]?)",t)local n
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
n=c("=",t-2)i,s="--["..n.."[","]"..n.."]"end
end
o[f]=i..a..s
end
local function m(a)local n=o[a]local t=l(n,"%s*$")if#t>0 then
n=e(n,1,-(t+1))end
o[a]=n
end
local function P(o,n)if not o then return false end
local t=l(n,"^%-%-%[=*%[")local t=#t
local l=e(n,-t,-1)local e=e(n,t+1,-(t-1))if d(e,o,1,true)then
return true
end
end
function optimize(n,t,K,l)local u=n["opt-comments"]local d=n["opt-whitespace"]local f=n["opt-emptylines"]local p=n["opt-eols"]local x=n["opt-strings"]local y=n["opt-numbers"]local k=n.KEEP
i=n.DETAILS and 0
g=g or r.print
if p then
u=true
d=true
f=true
end
a,o,s=t,K,l
local n=1
local t,i
local r
local function l(t,l,e)e=e or n
a[e]=t or""o[e]=l or""end
while true do
t,i=a[n],o[n]local s=E(n)if s then r=nil end
if t=="TK_EOS"then
break
elseif t=="TK_KEYWORD"or
t=="TK_NAME"or
t=="TK_OP"then
r=n
elseif t=="TK_NUMBER"then
if y then
N(n)end
r=n
elseif t=="TK_STRING"or
t=="TK_LSTRING"then
if x then
if t=="TK_STRING"then
j(n)else
L(n)end
end
r=n
elseif t=="TK_COMMENT"then
if u then
if n==1 and e(i,1,1)=="#"then
m(n)else
l()end
elseif d then
m(n)end
elseif t=="TK_LCOMMENT"then
if P(k,i)then
if d then
h(n)end
r=n
elseif u then
local e=A(i)if b[a[n+1]]then
l()t=""else
l("TK_SPACE"," ")end
if not f and e>0 then
l("TK_EOL",c("\n",e))end
if d and t~=""then
n=n-1
end
else
if d then
h(n)end
r=n
end
elseif t=="TK_EOL"then
if s and f then
l()elseif i=="\r\n"or i=="\n\r"then
l("TK_EOL","\n")end
elseif t=="TK_SPACE"then
if d then
if s or _(n)then
l()else
local t=a[r]if t=="TK_LCOMMENT"then
l()else
local e=a[n+1]if b[e]then
if(e=="TK_COMMENT"or e=="TK_LCOMMENT")and
t=="TK_OP"and o[r]=="-"then
else
l()end
else
local e=w(r,n+1)if e==""then
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
v()if p then
n=1
if a[1]=="TK_COMMENT"then
n=3
end
while true do
t,i=a[n],o[n]if t=="TK_EOS"then
break
elseif t=="TK_EOL"then
local e,t=a[n-1],a[n+1]if T[e]and T[t]then
local e=w(n-1,n+1)if e==""then
l()end
end
end
n=n+1
end
v()end
return a,o,s
end
end,['matthewwild/minify/optparser']=function(e,e,e,e,...)local e=_G
local t=require"string"local u=require"table"local a="etaoinshrdlucmfwypvbgkqjxz_ETAOINSHRDLUCMFWYPVBGKQJXZ"local d="etaoinshrdlucmfwypvbgkqjxz_0123456789ETAOINSHRDLUCMFWYPVBGKQJXZ"local p={}for e in t.gmatch([[
and break do else elseif end false for function if in
local nil not or repeat return then true until while
self]],"%S+")do
p[e]=true
end
local c,m,h,l,f,b,r,i
local function s(e)local l={}for a=1,#e do
local n=e[a]local o=n.name
if not l[o]then
l[o]={decl=0,token=0,size=0,}end
local e=l[o]e.decl=e.decl+1
local l=n.xref
local t=#l
e.token=e.token+t
e.size=e.size+t*#o
if n.decl then
n.id=a
n.xcount=t
if t>1 then
n.first=l[2]n.last=l[t]end
else
e.id=a
end
end
return l
end
local function T(e)local r=t.byte
local i=t.char
local t={TK_KEYWORD=true,TK_NAME=true,TK_NUMBER=true,TK_STRING=true,TK_LSTRING=true,}if not e["opt-comments"]then
t.TK_COMMENT=true
t.TK_LCOMMENT=true
end
local e={}for n=1,#c do
e[n]=m[n]end
for n=1,#l do
local n=l[n]local t=n.xref
for n=1,n.xcount do
local n=t[n]e[n]=""end
end
local n={}for e=0,255 do n[e]=0 end
for l=1,#c do
local l,e=c[l],e[l]if t[l]then
for t=1,#e do
local e=r(e,t)n[e]=n[e]+1
end
end
end
local function o(t)local e={}for l=1,#t do
local t=r(t,l)e[l]={c=t,freq=n[t],}end
u.sort(e,function(e,n)return e.freq>n.freq
end)local n={}for t=1,#e do
n[t]=i(e[t].c)end
return u.concat(n)end
a=o(a)d=o(d)end
local function g()local n
local i,c=#a,#d
local e=r
if e<i then
e=e+1
n=t.sub(a,e,e)else
local l,o=i,1
repeat
e=e-l
l=l*c
o=o+1
until l>e
local l=e%i
e=(e-l)/i
l=l+1
n=t.sub(a,l,l)while o>1 do
local l=e%c
e=(e-l)/c
l=l+1
n=n..t.sub(d,l,l)o=o-1
end
end
r=r+1
return n,f[n]~=nil
end
function optimize(e,t,n,o,a)c,m,h,l=t,n,o,a
r=0
i={}f=s(h)b=s(l)if e["opt-entropy"]then
T(e)end
local e={}for n=1,#l do
e[n]=l[n]end
u.sort(e,function(n,e)return n.xcount>e.xcount
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
local a,t
repeat
a,t=g()until not p[a]i[#i+1]=a
local n=r
if t then
local o=h[f[a].id].xref
local a=#o
for t=1,r do
local t=e[t]local r,e=t.act,t.rem
while e<0 do
e=l[-e].rem
end
local l
for n=1,a do
local n=o[n]if n>=r and n<=e then l=true end
end
if l then
t.skip=true
n=n-1
end
end
end
while n>0 do
local t=1
while e[t].skip do
t=t+1
end
n=n-1
local o=e[t]t=t+1
o.newname=a
o.skip=true
o.done=true
local r,i=o.first,o.last
local c=o.xref
if r and n>0 then
local a=n
while a>0 do
while e[t].skip do
t=t+1
end
a=a-1
local e=e[t]t=t+1
local a,t=e.act,e.rem
while t<0 do
t=l[-t].rem
end
if not(i<a or r>t)then
if a>=o.act then
for l=1,o.xcount do
local l=c[l]if l>=a and l<=t then
n=n-1
e.skip=true
break
end
end
else
if e.last and e.last>=o.act then
n=n-1
e.skip=true
end
end
end
if n==0 then break end
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
local e=l[e]local n=e.xref
if e.newname then
for t=1,e.xcount do
local n=n[t]m[n]=e.newname
end
e.name,e.oldname=e.newname,e.name
else
e.oldname=e.name
end
end
if c then
i[#i+1]="self"end
local e=s(l)end
end,['novacbn/gmodproj-plugin-builtin/Plugin']=function(n,g,n,e,...)local h
h=gmodproj.api.Plugin
local i
i=e("novacbn/gmodproj-plugin-builtin/PluginOptions").PluginOptions
local a
a=e("novacbn/gmodproj-plugin-builtin/assets/DataFileAsset").DataFileAsset
local r
r=e("novacbn/gmodproj-plugin-builtin/assets/JSONAsset").JSONAsset
local o
o=e("novacbn/gmodproj-plugin-builtin/assets/LuaAsset").LuaAsset
local t
t=e("novacbn/gmodproj-plugin-builtin/assets/LPropAsset").LPropAsset
local l
l=e("novacbn/gmodproj-plugin-builtin/assets/MoonAsset").MoonAsset
local n
n=e("novacbn/gmodproj-plugin-builtin/assets/MPropAsset").MPropAsset
local d
d=e("novacbn/gmodproj-plugin-builtin/assets/TOMLAsset").TOMLAsset
local c
c=e("novacbn/gmodproj-plugin-builtin/platforms/GarrysmodPlatform").GarrysmodPlatform
local f,s
do
local e=e("novacbn/gmodproj-plugin-builtin/platforms/LuaPlatform")f,s=e.LuaPlatform,e.setMinificationLevel
end
local u
u=e("novacbn/gmodproj-plugin-builtin/templates/AddonTemplate").AddonTemplate
local p
p=e("novacbn/gmodproj-plugin-builtin/templates/GamemodeTemplate").GamemodeTemplate
local m
m=e("novacbn/gmodproj-plugin-builtin/templates/PackageTemplate").PackageTemplate
g.Plugin=h:extend({schema=i,registerAssets=function(i,e)e:registerAsset("lua",o)e:registerAsset("moon",l)e:registerAsset("datl",a)e:registerAsset("json",r)e:registerAsset("lprop",t)e:registerAsset("mprop",n)return e:registerAsset("toml",d)end,registerTemplates=function(n,e)e:registerTemplate("addon",u)e:registerTemplate("gamemode",p)return e:registerTemplate("package",m)end,registerPlatforms=function(n,e)s(n.options:get("minificationLevel"))e:registerPlatform("garrysmod",c)return e:registerPlatform("lua",f)end})end,['novacbn/gmodproj-plugin-builtin/PluginOptions']=function(e,e,e,e,...)local e
e=gmodproj.api.Schema
PluginOptions=e:extend({namespace="gmodproj-plugin-builtin",schema={minificationLevel={one_of={"none","basic","debug","default","full"}}},default={minificationLevel="default"}})end,['novacbn/gmodproj-plugin-builtin/assets/DataFileAsset']=function(e,e,e,e,...)local n
n=gmodproj.api.DataAsset
local e
e=gmodproj.require("novacbn/gmodproj/lib/datafile").fromString
DataFileAsset=n:extend({preTransform=function(t,n)return e(n)end})end,['novacbn/gmodproj-plugin-builtin/assets/JSONAsset']=function(e,e,e,n,...)local e
e=n("rxi/json/main").decode
local n
n=gmodproj.api.DataAsset
JSONAsset=n:extend({preTransform=function(t,n)return e(n)end})end,['novacbn/gmodproj-plugin-builtin/assets/LPropAsset']=function(e,e,e,e,...)local e
e=gmodproj.api.DataAsset
local n
n=gmodproj.require("novacbn/properties/exports").decode
LPropAsset=e:extend({preTransform=function(t,e)return n(e,{propertiesEncoder="lua"})end})end,['novacbn/gmodproj-plugin-builtin/assets/LuaAsset']=function(e,e,e,e,...)local l,o
do
local e=string
l,o=e.gsub,e.match
end
local n
n=gmodproj.api.Asset
local e
e=gmodproj.require("novacbn/novautils/collections/Set").Set
local a="import"local r="dependency"local i="import[\\(]?[%s]*['\"]([%w/%-_]+)['\"]"local c="dependency[\\(]?[%s]*['\"]([%w/%-_]+)['\"]"LuaAsset=n:extend({collectDependencies=function(t,n)local e=e:new()t:scanDependencies(a,i,n,e)t:scanDependencies(r,c,n,e)return e:values()end,scanDependencies=function(r,t,n,e,a)if o(e,t)then
return l(e,n,function(e)return a:push(e)end)end
end})end,['novacbn/gmodproj-plugin-builtin/assets/MPropAsset']=function(e,e,e,e,...)local n
n=gmodproj.api.DataAsset
local e
e=gmodproj.require("novacbn/properties/exports").decode
MPropAsset=n:extend({preTransform=function(t,n)return e(n,{propertiesEncoder="moonscript"})end})end,['novacbn/gmodproj-plugin-builtin/assets/MoonAsset']=function(e,e,e,o,...)local n,t
do
local e=string
n,t=e.match,e.gsub
end
local i,c
do
local e=require("moonscript/compile")i,c=e.format_error,e.tree
end
local a
a=require("moonscript/parse").string
local l
l=gmodproj.require("novacbn/gmodproj/lib/logging").logFatal
local e
e=o("novacbn/gmodproj-plugin-builtin/assets/LuaAsset").LuaAsset
local r="import"local o="(import[%s]+[%w_,%s]+[%s]+from[%s]+)(['\"][%w/%-_]+['\"])"MoonAsset=e:extend({transformImports=function(l,e)if n(e,r)then
return t(e,o,function(n,e)return n.."dependency("..tostring(e)..")"end)end
return e
end,preTransform=function(o,e,n)e=o:transformImports(e)local r,t=a(e)if not(r)then
l("Failed to parse asset '"..tostring(o.assetName).."': "..tostring(t))end
local n,a
n,t,a=c(r)if not(n)then
l("Failed to compile asset '"..tostring(o.assetName).."': "..tostring(i(t,a,e)))end
return n
end})end,['novacbn/gmodproj-plugin-builtin/assets/TOMLAsset']=function(n,n,n,e,...)local n
n=e("jonstoler/toml/main").parse
local e
e=gmodproj.api.DataAsset
TOMLAsset=e:extend({preTransform=function(t,e,t)return n(e)end})end,['novacbn/gmodproj-plugin-builtin/platforms/GarrysmodPlatform']=function(e,e,e,n,...)local t,e
do
local n=n("novacbn/gmodproj-plugin-builtin/platforms/LuaPlatform")t,e=n.LuaPlatform,n.TEMPLATE_HEADER_PACKAGE
end
TEMPLATE_HEADER_DEVELOPMENT=function(n)return e(n,"local CompileString = _G.CompileString\n\n    for moduleName, assetChunk in pairs(modules) do\n        modules[moduleName] = CompileString('return function (module, exports, import, dependency, ...) '..assetChunk..' end', moduleName)()\n    end")end
GarrysmodPlatform=t:extend({generatePackageHeader=function(t,n)return t.isProduction and e(n,"")or TEMPLATE_HEADER_DEVELOPMENT(n)end})end,['novacbn/gmodproj-plugin-builtin/platforms/LuaPlatform']=function(e,e,e,l,...)local e
e=string.format
local t
t=gmodproj.api.Platform
local n
n=l("matthewwild/minify/main").minify
local l="full"TEMPLATE_HEADER_PACKAGE=function(e,n)return"return (function (modules, ...)\n    local _G            = _G\n    local error         = _G.error\n    local setfenv       = _G.setfenv\n    local setmetatable  = _G.setmetatable\n\n    local moduleCache       = {}\n    local packageGlobals    = {}\n\n    local function makeEnvironment(moduleChunk)\n        local exports = {}\n\n        local moduleEnvironment = setmetatable({}, {\n            __index = function (self, key)\n                if exports[key] ~= nil then\n                    return exports[key]\n                end\n\n                return _G[key]\n            end,\n\n            __newindex = exports\n        })\n\n        return setfenv(moduleChunk, moduleEnvironment), exports\n    end\n\n    local function makeModuleHeader(moduleName)\n        return {\n            name    = moduleName,\n            globals = packageGlobals\n        }\n    end\n\n    local function makeReadOnly(tbl)\n        return setmetatable({}, {\n            __index = tbl,\n            __newindex = function (self, key, value) error(\"module 'exports' table is read only\") end\n        })\n    end\n\n    local import = nil\n    function import(moduleName, ...)\n        local moduleChunk = modules[moduleName]\n        if not moduleChunk then error(\"bad argument #1 to 'import' (invalid module, got '\"..moduleName..\"')\") end\n\n        if not moduleCache[moduleName] then\n            local moduleHeader                  = makeModuleHeader(moduleName)\n            local moduleEnvironment, exports    = makeEnvironment(moduleChunk)\n\n            moduleEnvironment(moduleHeader, exports, import, import, ...)\n\n            moduleCache[moduleName] = makeReadOnly(exports)\n        end\n\n        return moduleCache[moduleName]\n    end\n\n    "..tostring(n).."\n\n    return import('"..tostring(e).."', ...)\nend)({"end
TEMPLATE_HEADER_DEVELOPMENT=function(e)return TEMPLATE_HEADER_PACKAGE(e,"local loadstring = _G.loadstring\n\n    for moduleName, assetChunk in pairs(modules) do\n        modules[moduleName] = loadstring('return function (module, exports, import, dependency, ...) '..assetChunk..' end', moduleName)()\n    end")end
TEMPLATE_FOOTER_PACKAGE=function()return"}, ...)"end
TEMPLATE_MODULE_PACKAGE=function(n,e)return"['"..tostring(n).."'] = function (module, exports, import, dependency, ...) "..tostring(e).." end,\n"end
TEMPLATE_MODULE_DEVELOPMENT=function(t,n)return"['"..tostring(t).."'] = "..tostring(e('%q',n))..",\n"end
LuaPlatform=t:extend({generatePackageHeader=function(n,e)return n.isProduction and TEMPLATE_HEADER_PACKAGE(e,"")or TEMPLATE_HEADER_DEVELOPMENT(e)end,generatePackageModule=function(t,n,e)return t.isProduction and TEMPLATE_MODULE_PACKAGE(n,e)or TEMPLATE_MODULE_DEVELOPMENT(n,e)end,generatePackageFooter=function(e)return TEMPLATE_FOOTER_PACKAGE()end,transformPackage=function(t,e)return t.isProduction and n(e,l)or e
end})setMinificationLevel=function(e)l=e
end end,['novacbn/gmodproj-plugin-builtin/templates/AddonTemplate']=function(e,e,e,e,...)local e
e=gmodproj.api.Template
AddonTemplate=e:extend({createProject=function(e)e:createDirectory("addons")e:createDirectory("addons/"..tostring(e.projectName))e:createDirectory("addons/"..tostring(e.projectName).."/lua")e:createDirectory("addons/"..tostring(e.projectName).."/lua/autorun")e:createDirectory("addons/"..tostring(e.projectName).."/lua/autorun/client")e:createDirectory("addons/"..tostring(e.projectName).."/lua/autorun/server")e:createDirectory("src")e:writeJSON("addons/"..tostring(e.projectName).."/addon.json",{title=e.projectName,type="",tags={},description="",ignore={}})local n=e.projectAuthor.."/"..e.projectName
e:write("src/client.lua","imp".."ort('"..tostring(n).."/shared').sharedFunc()\nprint('I was called on the client!')")e:write("src/server.lua","imp".."ort('"..tostring(n).."/shared').sharedFunc()\nprint('I was called on the server!')")e:write("src/shared.lua","function sharedFunc()\n\tprint('I was called on the client and server!')\nend")return e:writeProperties(".gmodmanifest",{name=e.projectName,author=e.projectAuthor,version="0.0.0",repository="unknown://unknown",buildDirectory="addons/"..tostring(e.projectName).."/lua",projectBuilds={[tostring(n).."/client"]="autorun/client/"..tostring(e.projectName)..".client",[tostring(n).."/server"]="autorun/server/"..tostring(e.projectName)..".server"}})end})end,['novacbn/gmodproj-plugin-builtin/templates/GamemodeTemplate']=function(e,e,e,e,...)local t
t=string.format
local r,n
do
local e=table
r,n=e.concat,e.insert
end
local a
a=gmodproj.api.Template
local o
o=function(e)return t([["%s"
{
    "base"			"base"
    "title"			"%s"
    "maps"			""
    "menusystem"	"1"

    "settings" {}
}]],e,e)end
local t
t=function(t,l)local e={}if t then
n(e,"-- These scripts are sent to the client")for l=1,#t do
local t=t[l]n(e,"AddCSLuaFile('"..tostring(t).."')")end
end
if l then
n(e,"-- These scripts are bootloaded by this script")for t=1,#l do
local t=l[t]n(e,"include('"..tostring(t).."')")end
end
return r(e,"\n")end
GamemodeTemplate=a:extend({createProject=function(e)e:createDirectory("gamemodes")e:createDirectory("gamemodes/"..tostring(e.projectName))e:createDirectory("gamemodes/"..tostring(e.projectName).."/gamemode")e:createDirectory("src")e:write("gamemodes/"..tostring(e.projectName).."/"..tostring(e.projectName)..".txt",o(e.projectName))e:write("gamemodes/"..tostring(e.projectName).."/gamemode/cl_init.lua",t(nil,{tostring(e.projectName)..".client.lua"}))e:write("gamemodes/"..tostring(e.projectName).."/gamemode/init.lua",t({"cl_init.lua",tostring(e.projectName)..".client.lua"},{tostring(e.projectName)..".server.lua"}))local n=e.projectAuthor.."/"..e.projectName
e:write("src/client.lua","imp".."ort('"..tostring(n).."/shared').sharedFunc()\nprint('I was called on the client!')")e:write("src/server.lua","imp".."ort('"..tostring(n).."/shared').sharedFunc()\nprint('I was called on the server!')")e:write("src/shared.lua","function sharedFunc()\n\tprint('I was called on the client and server!')\nend")return e:writeProperties(".gmodmanifest",{name=e.projectName,author=e.projectAuthor,version="0.0.0",repository="unknown://unknown",buildDirectory="gamemodes/"..tostring(e.projectName).."/gamemode",projectBuilds={[tostring(n).."/client"]=tostring(e.projectName)..".client",[tostring(n).."/server"]=tostring(e.projectName)..".server"}})end})end,['novacbn/gmodproj-plugin-builtin/templates/PackageTemplate']=function(e,e,e,e,...)local l
l=gmodproj.api.Template
local t
t=function(n,e)return"-- Code within this project can be imported by dependent project that have this installed\n-- E.g. If this was exported:\nfunction add(x, y)\n    return x + y\nend\n\n-- Then project that have this project installed via 'gmodproj install' could import it via:\nlocal "..tostring(e).." = imp".."ort('"..tostring(n).."/"..tostring(e).."/main')\nprint("..tostring(e)..".add(1, 2)) -- Prints '3' to console\n\n\n\n-- Alternatively, if this package was built with `gmodproj build`, you could import the entire library in Garry's Mod:\nlocal "..tostring(e).." = include('"..tostring(n).."."..tostring(e)..".lua')\nprint("..tostring(e)..".add(1, 2)) -- Prints '3' to console\n\n-- NOTE: when doing this, only the 'main.lua' exports can be used\n-- If you were to have this in 'substract.lua':\nfunction substract(a, b)\n    return a - b\nend\n\n-- You would need to alias the export in 'main.lua' to use it in a standard script:\nexports.substract = imp".."ort('"..tostring(n).."/"..tostring(e).."/substract')\n\n-- Then in a standard Garry's Mod script:\nlocal "..tostring(e).." = include('"..tostring(n).."."..tostring(e)..".lua')\nprint("..tostring(e)..".substract(3, 1)) -- Prints '2' to console\n"end
PackageTemplate=l:extend({createProject=function(e)e:createDirectory("dist")e:createDirectory("src")e:write("src/main.lua",t(e.projectAuthor,e.projectName))return e:writeProperties(".gmodmanifest",{name=e.projectName,author=e.projectAuthor,version="0.0.0",repository="unknown://unknown",projectBuilds={[tostring(e.projectAuthor).."/"..tostring(e.projectName).."/main"]=tostring(e.projectAuthor).."."..tostring(e.projectName)}})end})end,['rxi/json/main']=function(e,c,e,e,...)c._version="0.1.1"local t
local e={["\\"]="\\\\",['"']='\\"',["\b"]="\\b",["\f"]="\\f",["\n"]="\\n",["\r"]="\\r",["\t"]="\\t",}local i={["\\/"]="/"}for n,e in pairs(e)do
i[e]=n
end
local function a(n)return e[n]or string.format("\\u%04x",n:byte())end
local function r(e)return"null"end
local function d(e,n)local l={}n=n or{}if n[e]then error("circular reference")end
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
local function l(e)return'"'..e:gsub('[%z\1-\31\\"]',a)..'"'end
local function n(e)if e~=e or e<=-math.huge or e>=math.huge then
error("unexpected number value '"..tostring(e).."'")end
return string.format("%.14g",e)end
local e={["nil"]=r,["table"]=d,["string"]=l,["number"]=n,["boolean"]=tostring,}t=function(t,l)local n=type(t)local e=e[n]if e then
return e(t,l)end
error("unexpected type '"..n.."'")end
function c.encode(e)return(t(e))end
local r
local function e(...)local e={}for n=1,select("#",...)do
e[select(n,...)]=true
end
return e
end
local a=e(" ","\t","\r","\n")local s=e(" ","\t","\r","\n","]","}",",")local m=e("\\","/",'"',"b","f","n","r","t","u")local h=e("true","false","null")local p={["true"]=true,["false"]=false,["null"]=nil,}local function o(n,e,l,t)for e=e,#n do
if l[n:sub(e,e)]~=t then
return e
end
end
return#n+1
end
local function t(l,t,o)local n=1
local e=1
for t=1,t-1 do
e=e+1
if l:sub(t,t)=="\n"then
n=n+1
e=1
end
end
error(string.format("%s at line %d col %d",o,n,e))end
local function l(e)local n=math.floor
if e<=127 then
return string.char(e)elseif e<=2047 then
return string.char(n(e/64)+192,e%64+128)elseif e<=65535 then
return string.char(n(e/4096)+224,n(e%4096/64)+128,e%64+128)elseif e<=1114111 then
return string.char(n(e/262144)+240,n(e%262144/4096)+128,n(e%4096/64)+128,e%64+128)end
error(string.format("invalid unicode codepoint '%x'",e))end
local function f(e)local n=tonumber(e:sub(3,6),16)local e=tonumber(e:sub(9,12),16)if e then
return l((n-55296)*1024+(e-56320)+65536)else
return l(n)end
end
local function u(e,o)local d=false
local c=false
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
c=true
else
d=true
end
else
local l=string.char(l)if not m[l]then
t(e,n,"invalid escape char '"..l.."' in string")end
r=true
end
a=nil
elseif l==34 then
local e=e:sub(o+1,n-1)if c then
e=e:gsub("\\u[dD][89aAbB]..\\u....",f)end
if d then
e=e:gsub("\\u....",f)end
if r then
e=e:gsub("\\.",i)end
return e,n+1
else
a=l
end
end
t(e,o,"expected closing quote for string")end
local function l(n,e)local l=o(n,e,s)local o=n:sub(e,l-1)local a=tonumber(o)if not a then
t(n,e,"invalid number '"..o.."'")end
return a,l
end
local function i(n,l)local o=o(n,l,s)local e=n:sub(l,o-1)if not h[e]then
t(n,l,"invalid literal '"..e.."'")end
return p[e],o
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
local function d(n,e)local c={}e=e+1
while 1 do
local i,l
e=o(n,e,a,true)if n:sub(e,e)=="}"then
e=e+1
break
end
if n:sub(e,e)~='"'then
t(n,e,"expected string for key")end
i,e=r(n,e)e=o(n,e,a,true)if n:sub(e,e)~=":"then
t(n,e,"expected ':' after key")end
e=o(n,e+1,a,true)l,e=r(n,e)c[i]=l
e=o(n,e,a,true)local l=n:sub(e,e)e=e+1
if l=="}"then break end
if l~=","then t(n,e,"expected '}' or ','")end
end
return c,e
end
local l={['"']=u,["0"]=l,["1"]=l,["2"]=l,["3"]=l,["4"]=l,["5"]=l,["6"]=l,["7"]=l,["8"]=l,["9"]=l,["-"]=l,["t"]=i,["f"]=i,["n"]=i,["["]=s,["{"]=d,}r=function(n,e)local o=n:sub(e,e)local l=l[o]if l then
return l(n,e)end
t(n,e,"unexpected character '"..o.."'")end
function c.decode(e)if type(e)~="string"then
error("expected argument of type string, got "..type(e))end
local l,n=r(e,o(e,1,a,true))n=o(e,n,a,true)if n<=#e then
t(e,n,"trailing garbage")end
return l
end end,},...)