-- Dwarven Merchant
local s,id=GetID()
function s.initial_effect(c)


	-- This card is also FIRE Attribute while on the field or in the GY
local e0=Effect.CreateEffect(c)
e0:SetType(EFFECT_TYPE_SINGLE)
e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e0:SetCode(EFFECT_ADD_ATTRIBUTE)
e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
e0:SetValue(ATTRIBUTE_FIRE)
c:RegisterEffect(e0)

  -- (1) Discard 1 other Machine/Warrior/Spellcaster: Special Summon this card
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1,id)
  e1:SetCost(s.spcost)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)

  -- (2) If banished: Add "Karak Azul Smith – Thorak" from Deck to hand
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_REMOVE)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCountLimit(1,id+1)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)
end

-- (1) Discard 1 Machine/Warrior/Spellcaster monster
function s.cfilter(c)
  return c:IsType(TYPE_MONSTER) and (c:IsRace(RACE_MACHINE) or c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_SPELLCASTER)) and c:IsDiscardable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
  Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) then
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
  end
end

-- (2) Add Thorak from Deck to hand when banished
function s.thfilter(c)
  return c:IsCode(99990010) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if #g>0 then
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
  end
end
