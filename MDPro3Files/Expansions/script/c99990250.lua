-- Ancestral Relic – Rune of Duel
local s,id=GetID()
function s.initial_effect(c)
  -- (1) Target and equip to Az-I-Kazak or Karak Azul
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_EQUIP)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_MZONE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCountLimit(1,id)
  e1:SetTarget(s.eqtg)
  e1:SetOperation(s.eqop)
  c:RegisterEffect(e1)

  -- (2) Manual destruction replacement with LP cost
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
  e2:SetCode(EFFECT_DESTROY_REPLACE)
  e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
  e2:SetTarget(s.reptg)
  e2:SetOperation(s.repop)
  e2:SetValue(1)
  c:RegisterEffect(e2)

  -- (3) Uniqueness
  c:SetUniqueOnField(1,0,id)
end

-- (1) Target Az-I-Kazak or Karak Azul to equip
function s.eqfilter(c)
  return c:IsFaceup() and (c:IsSetCard(0x69c) or c:IsSetCard(0xd56))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
  local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToEffect(e) then return end
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
	Duel.Equip(tp,c,tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function(e,tc2) return tc2==tc end)
	c:RegisterEffect(e1)
  end
end

-- (2) Destruction replacement logic
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  local ec=c:GetEquipTarget()
  if chk==0 then
	return ec and ec:IsOnField() and not ec:IsReason(REASON_REPLACE)
	  and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
	  and Duel.CheckLPCost(tp,1000)
  end
  return Duel.SelectYesNo(tp, aux.Stringid(id, 1))
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
  Duel.PayLPCost(tp,1000)
  local ec=e:GetHandler():GetEquipTarget()
  if ec and ec:IsFaceup() then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e1)
  end
end
