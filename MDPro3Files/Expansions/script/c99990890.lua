-- Durrek, Underforge High King — midrange revision
local s,id=GetID()

local U={SET=0xf80,GARRIN=99990860}
function U.uf(c) return c:IsSetCard(U.SET) end
function U.pend(c) return U.uf(c) and c:IsType(TYPE_PENDULUM) end
function U.normal(c) return U.pend(c) and c:IsType(TYPE_NORMAL) end
function U.extra(c) return U.pend(c) and c:IsFaceup() end
function U.normalextra(c) return U.extra(c) and c:IsType(TYPE_NORMAL) end
function U.placeable(c) return U.pend(c) and not c:IsForbidden() end
function U.explace(c) return U.extra(c) and not c:IsForbidden() end
function U.nplace(c) return U.normal(c) and not c:IsForbidden() end
function U.hand(c) return U.pend(c) and c:IsAbleToHand() end
function U.exhand(c) return U.extra(c) and c:IsAbleToHand() end
function U.nexhand(c) return U.normalextra(c) and c:IsAbleToHand() end
function U.mon(c) return U.uf(c) and c:IsFaceup() end
function U.normmon(c) return U.mon(c) and c:IsType(TYPE_NORMAL) end
function U.levelmon(c) return U.mon(c) and c:IsHasLevel() end
function U.free(tp) return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
function U.both(tp) return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)==2 end
function U.main() local p=Duel.GetCurrentPhase(); return p==PHASE_MAIN1 or p==PHASE_MAIN2 end
function U.workphase(e,tp)
 return U.main() and (Duel.GetTurnPlayer()==tp or Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(U.GARRIN) end,tp,LOCATION_MZONE,0,1,nil))
end
function U.effect(c,i,ty,range,event,cat,tg,op,con,count)
 local e=Effect.CreateEffect(c)
 e:SetDescription(aux.Stringid(id,i)); e:SetType(ty)
 if range then e:SetRange(range) end
 if event then e:SetCode(event) end
 if cat then e:SetCategory(cat) end
 if count~=false then e:SetCountLimit(1,count=='soft' and 0 or id+i+(count=='activate' and EFFECT_COUNT_CODE_OATH or 0)) end
 if tg then e:SetTarget(tg) end
 if op then e:SetOperation(op) end
 if con then e:SetCondition(con) end
 c:RegisterEffect(e); return e
end
function U.target(filter,loc,min,max)
 return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsControler(tp) and chkc:IsLocation(loc) and filter(chkc) end
  if chk==0 then return Duel.IsExistingTarget(filter,tp,loc,0,min,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET); Duel.SelectTarget(tp,filter,tp,loc,0,min,max,nil)
 end
end
function U.selected(tp,filter,loc,hint,...)
 Duel.Hint(HINT_SELECTMSG,tp,hint)
 return Duel.SelectMatchingCard(tp,filter,tp,loc,0,1,1,nil,...):GetFirst()
end
function U.tohand(tc,tp)
 if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then Duel.ConfirmCards(1-tp,tc);return true end
 return false
end
function U.place(tc,tp,zone)
 if not tc or tc:IsForbidden() or not U.free(tp) then return false end
 if zone and not Duel.CheckLocation(tp,LOCATION_PZONE,zone==1 and 0 or 1) then return false end
 return Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true,zone or 3)
end
function U.tuner(tc,c)
 local e=Effect.CreateEffect(c);e:SetType(EFFECT_TYPE_SINGLE);e:SetCode(EFFECT_ADD_TYPE);e:SetValue(TYPE_TUNER)
 e:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END);tc:RegisterEffect(e)
end
function U.level(tc,c,lv)
 local e=Effect.CreateEffect(c);e:SetType(EFFECT_TYPE_SINGLE);e:SetCode(EFFECT_CHANGE_LEVEL);e:SetValue(lv)
 e:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END);tc:RegisterEffect(e)
end
function U.disable(tc,c)
 Duel.NegateRelatedChain(tc,RESET_TURN_SET)
 local e=Effect.CreateEffect(c);e:SetType(EFFECT_TYPE_SINGLE);e:SetCode(EFFECT_DISABLE)
 e:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END);tc:RegisterEffect(e)
 local e2=e:Clone();e2:SetCode(EFFECT_DISABLE_EFFECT);tc:RegisterEffect(e2)
end
function U.spnormal(c,e,tp)
 return U.normal(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function U.handsp(e,tp,optional)
 if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
 if not Duel.IsExistingMatchingCard(U.spnormal,tp,LOCATION_HAND,0,1,nil,e,tp) then return end
 if optional and not Duel.SelectYesNo(tp,aux.Stringid(id,7)) then return end
 local tc=U.selected(tp,U.spnormal,LOCATION_HAND,HINTMSG_SPSUMMON,e,tp)
 if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
function U.extmonster(c) return U.uf(c) and c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) end
function U.link(c) return U.uf(c) and c:IsFaceup() and c:IsType(TYPE_LINK) end
function U.selfscale(c,i)
 local e=U.effect(c,i,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O,nil,EVENT_DESTROYED,0,
  function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return U.free(tp) and not e:GetHandler():IsForbidden() end end,
  function(e,tp) local tc=e:GetHandler();if tc:IsRelateToEffect(e) then U.place(tc,tp) end end,
  function(e) local tc=e:GetHandler();return tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsFaceup() and tc:IsReason(REASON_BATTLE+REASON_EFFECT) end)
 e:SetProperty(EFFECT_FLAG_DELAY)
end
function U.pair(c,i,range,event,mode,other,con,count)
 local e=U.effect(c,i,range and EFFECT_TYPE_QUICK_O or EFFECT_TYPE_ACTIVATE,range,event,CATEGORY_DESTROY+(mode=='destroy' and 0 or mode=='deck' and CATEGORY_TODECK or CATEGORY_TOHAND),
 function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local f=function(tc) return U.uf(tc) and tc:IsDestructable() end
  local loc=mode=='deck' and LOCATION_PZONE or LOCATION_ONFIELD
  if chkc then return chkc:IsOnField() and ((chkc:IsControler(tp) and chkc:IsLocation(loc) and f(chkc) and (not other or chkc~=e:GetHandler())) or chkc:IsControler(1-tp)) end
  if chk==0 then return Duel.IsExistingTarget(f,tp,loc,0,1,other and e:GetHandler() or nil) and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
  local a=Duel.SelectTarget(tp,f,tp,loc,0,1,1,other and e:GetHandler() or nil):GetFirst()
  Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil);e:SetLabelObject(a)
 end,function(e,tp)
  local a=e:GetLabelObject();local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS);local b=g:Filter(function(tc) return tc~=a end,nil):GetFirst()
  if mode=='destroy' then
   local sg=g:Filter(function(tc) return tc:IsRelateToEffect(e) end,nil);Duel.Destroy(sg,REASON_EFFECT)
  elseif a and a:IsRelateToEffect(e) and Duel.Destroy(a,REASON_EFFECT)>0 and b and b:IsRelateToEffect(e) then
   if mode=='deck' then Duel.SendtoDeck(b,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) else Duel.SendtoHand(b,nil,REASON_EFFECT) end
  end
 end,con,count);e:SetProperty(EFFECT_FLAG_CARD_TARGET);return e
end

function U.fuel(c,e,tp)
 return U.normal(c) and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
 and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 or not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function U.refuel(e,tp,loc)
 if Duel.IsExistingMatchingCard(U.fuel,tp,loc,0,1,nil,e,tp) then local tc=U.selected(tp,U.fuel,loc,HINTMSG_SPSUMMON,e,tp);if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end end
end
function U.uflock(e,tp)
 local x=Effect.CreateEffect(e:GetHandler());x:SetType(EFFECT_TYPE_FIELD);x:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
 x:SetProperty(EFFECT_FLAG_PLAYER_TARGET);x:SetTargetRange(1,0);x:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not U.uf(c) end)
 x:SetReset(RESET_PHASE+PHASE_END);Duel.RegisterEffect(x,tp)
end
function U.recovery(c,i,range,stype,filter,loc)
 local e=U.effect(c,i,stype and EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O or EFFECT_TYPE_IGNITION,range,stype and EVENT_SPSUMMON_SUCCESS or nil,CATEGORY_TOHAND,
 function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(filter,tp,loc,0,1,nil) end end,
 function(e,tp) U.tohand(U.selected(tp,filter,loc,HINTMSG_ATOHAND),tp) end,stype and function(e) return e:GetHandler():IsSummonType(stype) end or nil)
 if stype then e:SetProperty(EFFECT_FLAG_DELAY) end
end
function U.levels(c)
 local e=U.effect(c,0,EFFECT_TYPE_IGNITION,LOCATION_PZONE,nil,0,U.target(U.levelmon,LOCATION_MZONE,1,2),function(e,tp)
 local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS);local lv=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))==0 and 4 or 6
 for tc in aux.Next(g) do if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsHasLevel() then U.level(tc,e:GetHandler(),lv) end end end);e:SetProperty(EFFECT_FLAG_CARD_TARGET)
end
function U.tunerscale(c)
 local e=U.effect(c,0,EFFECT_TYPE_IGNITION,LOCATION_PZONE,nil,0,U.target(U.normmon,LOCATION_MZONE,1,1),function(e,tp)
 local tc=Duel.GetFirstTarget();if tc:IsRelateToEffect(e) and tc:IsFaceup() then U.tuner(tc,e:GetHandler()) end end);e:SetProperty(EFFECT_FLAG_CARD_TARGET)
end
function U.fmg(e,tp) return Duel.GetFusionMaterial(tp):Filter(function(c) return not c:IsImmuneToEffect(e) end,nil) end
function U.ff(c,e,tp,mg) return U.uf(c) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil,tp) end
function U.fcheck(tp,g,fc) return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0 end
function U.fusiontg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then local old=aux.FCheckAdditional;aux.FCheckAdditional=U.fcheck;local ok=Duel.IsExistingMatchingCard(U.ff,tp,LOCATION_EXTRA,0,1,nil,e,tp,U.fmg(e,tp));aux.FCheckAdditional=old;return ok end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function U.fusionop(e,tp)
 local old=aux.FCheckAdditional;aux.FCheckAdditional=U.fcheck;local mg=U.fmg(e,tp);local g=Duel.GetMatchingGroup(U.ff,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
 if #g>0 then Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON);local sc=g:Select(tp,1,1,nil):GetFirst();local mat=Duel.SelectFusionMaterial(tp,sc,mg,nil,tp);sc:SetMaterial(mat)
 Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION);Duel.BreakEffect();if Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then sc:CompleteProcedure() end end
 aux.FCheckAdditional=old
end
function U.negate(c,i,loc,detach)
 local e=U.effect(c,i,EFFECT_TYPE_QUICK_O,LOCATION_MZONE,EVENT_FREE_CHAIN,CATEGORY_DISABLE,
 function(e,tp,eg,ep,ev,re,r,rp,chk,chkc) if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(loc) and chkc:IsFaceup() end
 if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,loc,1,nil) end;Duel.SelectTarget(tp,Card.IsFaceup,tp,0,loc,1,1,nil) end,
 function(e,tp) local tc=Duel.GetFirstTarget();if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then U.disable(tc,e:GetHandler()) end end)
 e:SetProperty(EFFECT_FLAG_CARD_TARGET);if detach then e:SetCost(s.cost) end
end

function s.initial_effect(c)
c:EnableReviveLimit();aux.AddLinkProcedure(c,U.uf,2,3,function(g) return g:IsExists(Card.IsSummonLocation,1,nil,LOCATION_EXTRA) end)
local e=U.effect(c,0,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O,nil,EVENT_SPSUMMON_SUCCESS,0,
 function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return U.free(tp) and Duel.IsExistingMatchingCard(s.place,tp,LOCATION_EXTRA,0,1,nil) end end,
 function(e,tp) if U.free(tp) then U.place(U.selected(tp,s.place,LOCATION_EXTRA,HINTMSG_TOFIELD),tp) end end,
 function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end,nil)
 e:SetProperty(EFFECT_FLAG_DELAY)
 local e=U.effect(c,1,EFFECT_TYPE_QUICK_O,LOCATION_MZONE,EVENT_FREE_CHAIN,CATEGORY_TODECK,
 function(e,tp,eg,ep,ev,re,r,rp,chk,chkc) if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
 if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end;Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil) end,
 function(e,tp) local tc=Duel.GetFirstTarget();if tc:IsRelateToEffect(e) then Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end end);e:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) local f=function(tc) return U.extra(tc) and tc:IsAbleToDeckAsCost() end
 if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_EXTRA,0,1,nil) end;Duel.SendtoDeck(U.selected(tp,f,LOCATION_EXTRA,HINTMSG_TODECK),nil,SEQ_DECKSHUFFLE,REASON_COST) end)
end
function s.place(c) return U.explace(c) end