--F.F.O.A. Rakin's Forge-Flux Overdrive Accelerator
function c99990630.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	--send 1 other card you control to the GY; your opponent cannot respond to your Spell activations this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99990630,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c99990630.tgtg)
	e2:SetOperation(c99990630.tgop)
	c:RegisterEffect(e2)

	--during the End Phase: Set "F.F.O.A." Spells from your GY, up to the number of "F.F.O.A." Spells activated this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99990630,1))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c99990630.settg)
	e3:SetOperation(c99990630.setop)
	c:RegisterEffect(e3)

	--count activated "F.F.O.A." Spells
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c99990630.regop)
	c:RegisterEffect(e4)

	--if the activation is negated, reduce the count again
	local e5=e4:Clone()
	e5:SetCode(EVENT_CHAIN_NEGATED)
	e5:SetOperation(c99990630.regop2)
	c:RegisterEffect(e5)
end

function c99990630.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c end
	if chk==0 then
		return Duel.GetFlagEffect(tp,99990631)==0
			and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end

function c99990630.tgop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(c99990630.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	Duel.RegisterFlagEffect(tp,99990631,RESET_PHASE+PHASE_END,0,1)

	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	Duel.BreakEffect()
	Duel.SendtoGrave(tc,REASON_EFFECT)
end

function c99990630.actop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		Duel.SetChainLimit(c99990630.chainlm)
	end
end

function c99990630.chainlm(e,rp,tp)
	return tp==rp
end

function c99990630.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsSetCard(0x857)
		and re:IsActiveType(TYPE_SPELL)
		and rp==tp
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) then

		local flag=c:GetFlagEffectLabel(99990630)
		if flag then
			c:SetFlagEffectLabel(99990630,flag+1)
		else
			c:RegisterFlagEffect(99990630,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,1)
		end
	end
end

function c99990630.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsSetCard(0x857)
		and re:IsActiveType(TYPE_SPELL)
		and rp==tp
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) then

		local flag=c:GetFlagEffectLabel(99990630)
		if flag and flag>0 then
			c:SetFlagEffectLabel(99990630,flag-1)
		end
	end
end

function c99990630.setfilter(c)
	return c:IsSetCard(0x857) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end

function c99990630.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(99990630)
	if chk==0 then
		return ct and ct>0
			and Duel.IsExistingMatchingCard(c99990630.setfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end

function c99990630.gselect(g,ft)
	local fc=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	return fc<=1 and aux.dncheck(g) and g:GetCount()-fc<=ft
end

function c99990630.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c99990630.setfilter),tp,LOCATION_GRAVE,0,nil)
	local ct=c:GetFlagEffectLabel(99990630) or 0
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)

	if g:GetCount()==0 or ct==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tg=g:SelectSubGroup(tp,c99990630.gselect,false,1,math.min(ct,ft+1),ft)

	if not tg or Duel.SSet(tp,tg)==0 then return end

	local tc=tg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
end