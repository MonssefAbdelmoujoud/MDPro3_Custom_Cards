--Az-I-Kazak Penta The Grudgebelly – All Father
--Scripted by ChatGPT
local s,id=GetID()
function s.initial_effect(c)
  --(0) Link Summon: 1 FIRE or EARTH monster (testing)
  c:EnableReviveLimit()
  aux.AddLinkProcedure(c, aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE+ATTRIBUTE_EARTH), 4,5)

	  -- Always treated as "Karak Azul"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetValue(0x69c)
	c:RegisterEffect(e1)


  --(2) Equip on Link Summon
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_EQUIP)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
  end)
  e2:SetTarget(s.eqtg)
  e2:SetOperation(s.eqop)
  c:RegisterEffect(e2)

  --(3) Destroy opponent’s DEF monsters after battle (now correctly placed!)
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,2))
  e3:SetCategory(CATEGORY_DESTROY)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_BATTLED)
  e3:SetProperty(EFFECT_FLAG_DELAY)
  e3:SetCondition(s.descon)
  e3:SetTarget(s.destg)
  e3:SetOperation(s.desop)
  c:RegisterEffect(e3)

  -- (4) During opponent’s End Phase: destroy opponent’s monsters that didn’t attack
local e4=Effect.CreateEffect(c)
e4:SetDescription(aux.Stringid(id,3))
e4:SetCategory(CATEGORY_DESTROY)
e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
e4:SetCode(EVENT_PHASE+PHASE_END)
e4:SetRange(LOCATION_MZONE)
e4:SetCountLimit(1)
e4:SetCondition(s.destroycond)
e4:SetTarget(s.destroytg)
e4:SetOperation(s.destroyop)
c:RegisterEffect(e4)

end





-- Equip Ancestral Relic from Extra Deck
function s.eqfilter(c,tp,lc)
  return c:IsSetCard(0xE80) and c:IsType(TYPE_MONSTER)
	and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	  and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,tp,c)
  end
  Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
  local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tp,c)
  local tc=g:GetFirst()
  if tc then
	Duel.Equip(tp,tc,c,true)
	-- Enable equip limit so it stays attached properly
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function(e,c) return c==e:GetOwner() end)
	tc:RegisterEffect(e1)
  end
end


-- 3th effect
function s.descon(e,tp,eg,ep,ev,re,r,rp)
  local c=Duel.GetAttacker()
  local tc=Duel.GetAttackTarget()
  return c==e:GetHandler()
	 and tc and tc:IsDefensePos() and tc:IsControler(1-tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos, tp, 0, LOCATION_MZONE, 1, nil) end
  local g=Duel.GetMatchingGroup(Card.IsDefensePos, tp, 0, LOCATION_MZONE, nil)
  Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetMatchingGroup(Card.IsDefensePos, tp, 0, LOCATION_MZONE, nil)
  if #g>0 then Duel.Destroy(g, REASON_EFFECT) end
end


-- 4th eff

function s.destroycond(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetTurnPlayer()~=tp and e:GetHandler():IsFaceup()
end

function s.destroytg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_MZONE,e:GetHandler())
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.destroyop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
  local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_MZONE,e:GetHandler())
  Duel.Destroy(g,REASON_EFFECT)
end

function s.dfilter(c)
  return c:GetAttackAnnouncedCount()==0
end


