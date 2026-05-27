--Az-I-Kazak X
function c99990750.initial_effect(c)
	--Pendulum Summon
	aux.EnablePendulumAttribute(c)

	--This card is treated as an "Az-I-Kazak" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xd56)
	c:RegisterEffect(e0)

	--Pendulum Effect: banish 1 "Az-I-Kazak" card from GY; place 1 "Az-I-Kazak" Pendulum Monster from Deck in Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99990750,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,99990750)
	e1:SetCost(c99990750.pccost)
	e1:SetTarget(c99990750.pctg)
	e1:SetOperation(c99990750.pcop)
	c:RegisterEffect(e1)

	--Monster Effect: if destroyed on field, Special Summon 1 "Az-I-Kazak X" as a Tuner
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99990750,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,99990751)
	e2:SetCondition(c99990750.spcon)
	e2:SetTarget(c99990750.sptg)
	e2:SetOperation(c99990750.spop)
	c:RegisterEffect(e2)

	--Extra Deck Effect: banish this card; give an "Az-I-Kazak" Synchro monster +700 ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99990750,2))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,99990752)
	e3:SetCondition(c99990750.atkcon)
	e3:SetTarget(c99990750.atktg)
	e3:SetOperation(c99990750.atkop)
	c:RegisterEffect(e3)
end

function c99990750.cfilter(c)
	return c:IsSetCard(0xd56)
		and c:IsAbleToRemoveAsCost()
end

function c99990750.pccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c99990750.cfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c99990750.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function c99990750.pcfilter(c)
	return c:IsSetCard(0xd56)
		and c:IsType(TYPE_PENDULUM)
		and not c:IsForbidden()
end

function c99990750.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and Duel.IsExistingMatchingCard(c99990750.pcfilter,tp,LOCATION_DECK,0,1,nil)
	end
end

function c99990750.pcop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,c99990750.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end

	--For the rest of this turn, you cannot Special Summon, except EARTH and FIRE monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c99990750.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function c99990750.splimit(e,c,tp,sumtp,sumpos)
	return not (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_EARTH))
end

function c99990750.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function c99990750.spfilter(c,e,tp)
	return c:IsCode(99990750)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c99990750.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(c99990750.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function c99990750.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c99990750.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()

	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Treat the summoned monster as a Tuner
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end

	Duel.SpecialSummonComplete()
end

function c99990750.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then
		tc=Duel.GetAttackTarget()
	end

	if tc and tc:IsControler(tp)
		and tc:IsSetCard(0xd56)
		and tc:IsType(TYPE_SYNCHRO) then
		e:SetLabelObject(tc)
		return true
	end

	return false
end

function c99990750.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToRemove()
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end

function c99990750.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()

	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
		if tc and tc:IsRelateToBattle() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(700)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end