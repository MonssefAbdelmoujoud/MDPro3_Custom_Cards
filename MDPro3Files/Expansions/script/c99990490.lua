--F.F.O.A. Hylda - Aspect of Karak Kadrin
function c99990490.initial_effect(c)
	c:SetSPSummonOnce(99990490)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c99990490.matfilter,1,1)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--send 1 "F.F.O.A." card from Deck to GY after damage calculation
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99990490,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetTarget(c99990490.tgtg)
	e2:SetOperation(c99990490.tgop)
	c:RegisterEffect(e2)
end

function c99990490.matfilter(c)
	return c:IsLinkSetCard(0x857) and c:IsLinkAttribute(ATTRIBUTE_ALL&~ATTRIBUTE_WIND)
end

function c99990490.tgfilter(c)
	return c:IsSetCard(0x857) and c:IsAbleToGrave()
end

function c99990490.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c99990490.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function c99990490.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c99990490.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end