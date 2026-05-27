--F.F.O.A. Ironshield's Compass
function c99990610.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c99990610.condition)
	e1:SetTarget(c99990610.target)
	e1:SetOperation(c99990610.activate)
	c:RegisterEffect(e1)
end

function c99990610.cfilter(c)
	return c:GetSequence()<5
end

function c99990610.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c99990610.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function c99990610.thfilter(c)
	return c:IsSetCard(0x857) and c:IsAbleToHand()
end

function c99990610.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end

function c99990610.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end

	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local sg=g:Filter(c99990610.thfilter,nil)

	if sg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=sg:Select(tp,1,1,nil)

		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)

		g:Sub(tg)
		if g:GetCount()>0 then
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
		end

		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
			and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
			and Duel.SelectYesNo(tp,aux.Stringid(99990610,0)) then
			Duel.BreakEffect()
			Duel.DiscardDeck(tp,2,REASON_EFFECT)
		end
	else
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	end
end