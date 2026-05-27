--Karak Azul RuneSworn – Rakin Gearbelly

local s,id,o=GetID()
function s.initial_effect(c)
	-- Synchro Summon procedure
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x69c),aux.NonTuner(Card.IsSetCard,0x69c),1,1)
	c:EnableReviveLimit()

  -- (1) If Synchro Summoned: Banish up to 2 monsters on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.rmcon)
	e1:SetOperation(s.rmop)
	e1:SetCountLimit(1, id)
	c:RegisterEffect(e1)
end

-- (1) Trigger only if Synchro Summoned
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Non-targeting: Select and banish up to 2 monsters on resolution
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,1,math.min(2,#g),nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
