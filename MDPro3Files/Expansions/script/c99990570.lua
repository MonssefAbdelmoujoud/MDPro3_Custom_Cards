--F.F.O.A. Rune of Destruction
function c99990570.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c99990570.condition)
	e1:SetTarget(c99990570.target)
	e1:SetOperation(c99990570.activate)
	c:RegisterEffect(e1)
end

function c99990570.cfilter(c)
	return c:GetSequence()<5
end

function c99990570.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c99990570.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function c99990570.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsOnField() and c:IsDestructable()
end

function c99990570.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c99990570.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c99990570.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c99990570.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)

	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
		and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
	end
end

function c99990570.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
			and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 then
			Duel.BreakEffect()
			local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
			local sg=g:RandomSelect(tp,1)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end