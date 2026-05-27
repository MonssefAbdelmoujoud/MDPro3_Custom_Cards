--Z
function c99990740.initial_effect(c)
	--This card is treated as an "Az-I-Kazak" monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xd56)
	c:RegisterEffect(e0)

	--Synchro Summon: 1 FIRE Tuner + 1+ non-Tuner FIRE monsters
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()

	--Target 1 face-up monster your opponent controls that was Special Summoned from the Extra Deck;
	--make its ATK 0 and negate its effects until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99990740,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,99990740)
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c99990740.distg)
	e1:SetOperation(c99990740.disop)
	c:RegisterEffect(e1)
end

function c99990740.disfilter(c)
	return c:IsFaceup()
		and c:IsSummonLocation(LOCATION_EXTRA)
		and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end

function c99990740.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
			and chkc:IsControler(1-tp)
			and c99990740.disfilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(c99990740.disfilter,tp,0,LOCATION_MZONE,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	Duel.SelectTarget(tp,c99990740.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
end

function c99990740.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Set ATK to 0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)

		--Negate already-related chains
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)

		--Disable monster
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)

		--Disable effects
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end