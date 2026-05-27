--F.F.O.A. S.D.O. Sniper Rifle
function c99990580.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c99990580.condition)
	e1:SetTarget(c99990580.target)
	e1:SetOperation(c99990580.activate)
	c:RegisterEffect(e1)
end

function c99990580.cfilter(c)
	return c:GetSequence()<5
end

function c99990580.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c99990580.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function c99990580.disfilter(c,e)
	return c:IsFaceup()
		and c:IsControler(1-e:GetHandlerPlayer())
		and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsCanBeDisabledByEffect(e)
		and c:IsDestructable()
end

function c99990580.tgfilter(c,code)
	return c:IsCode(code) and c:IsAbleToGrave()
end

function c99990580.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c99990580.disfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(c99990580.disfilter,tp,0,LOCATION_SZONE,1,nil,e) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c99990580.disfilter,tp,0,LOCATION_SZONE,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)

	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD)
	end
end

function c99990580.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		local code=tc:GetCode()

		Duel.NegateRelatedChain(tc,RESET_TURN_SET)

		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)

		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)

		Duel.AdjustInstantly()

		if tc:IsDisabled() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
			if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
				local g=Duel.GetMatchingGroup(c99990580.tgfilter,tp,0,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,nil,code)
				if g:GetCount()>0 then
					Duel.BreakEffect()
					Duel.SendtoGrave(g,REASON_EFFECT)
				end
			end
		end
	end
end