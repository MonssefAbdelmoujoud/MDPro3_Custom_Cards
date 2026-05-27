--F.F.O.A. Hylda - Aspect of Ironshield
function c99990500.initial_effect(c)
	c:SetSPSummonOnce(99990500)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c99990500.matfilter,1,1)
	--target 1 face-up opponent's monster; it cannot attack until the end of your opponent's turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99990500,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c99990500.atktg)
	e1:SetOperation(c99990500.atkop)
	c:RegisterEffect(e1)
	--gain 100 LP when your "F.F.O.A." Spell Card or effect resolves
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c99990500.reccon)
	e3:SetOperation(c99990500.recop)
	c:RegisterEffect(e3)
end

function c99990500.matfilter(c)
	return c:IsLinkSetCard(0x857) and c:IsLinkAttribute(ATTRIBUTE_ALL&~ATTRIBUTE_EARTH)
end

function c99990500.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end

function c99990500.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end

function c99990500.reccon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_SPELL)
		and re:GetHandler():IsSetCard(0x857)
		and rp==tp
		and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end

function c99990500.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,100,REASON_EFFECT)
end