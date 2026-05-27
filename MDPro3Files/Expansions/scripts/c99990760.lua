--Az-I-Kazak Y
function c99990760.initial_effect(c)
	--Pendulum Summon
	aux.EnablePendulumAttribute(c)

	--This card is treated as an "Az-I-Kazak" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xd56)
	c:RegisterEffect(e0)

	--Pendulum Effect:
	--Destroy this card and 1 Level 2 FIRE Pendulum Monster in your Pendulum Zone;
	--Special Summon 1 specific "Az-I-Kazak" Synchro Monster from your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99990760,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,99990760)
	e1:SetTarget(c99990760.sptg)
	e1:SetOperation(c99990760.spop)
	c:RegisterEffect(e1)

	--Monster Effect:
	--If this card is added face-up to the Extra Deck, send 1 "Az-I-Kazak" Spell/Trap from Deck to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99990760,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCountLimit(1,99990761)
	e2:SetCondition(c99990760.tgcon)
	e2:SetTarget(c99990760.tgtg)
	e2:SetOperation(c99990760.tgop)
	c:RegisterEffect(e2)
end

--CHANGE THIS if Kazmadri Priest has another ID
local PRIEST_ID = 99990730

function c99990760.spfilter(c,e,tp)
	return c:IsCode(PRIEST_ID)
		and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end

function c99990760.desfilter(c)
	return c:IsType(TYPE_PENDULUM)
		and c:GetOriginalAttribute()==ATTRIBUTE_FIRE
		and c:GetOriginalLevel()==2
end

function c99990760.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c99990760.desfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
			and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
			and Duel.IsExistingMatchingCard(c99990760.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end

	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function c99990760.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if c:IsRelateToEffect(e)
		and c:IsLocation(LOCATION_PZONE)
		and Duel.IsExistingMatchingCard(c99990760.desfilter,tp,LOCATION_PZONE,0,1,e:GetHandler()) then

		local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)

		if dg:GetCount()>=2
			and Duel.Destroy(dg,REASON_EFFECT)==2
			and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then

			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,c99990760.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			local tc=g:GetFirst()

			if tc then
				tc:SetMaterial(nil)
				if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					tc:CompleteProcedure()
				end
			end
		end
	end

	--For the rest of this turn, cards in your Pendulum Zones cannot be destroyed by card effects
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_PZONE,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	--For the rest of this turn, you cannot Special Summon, except FIRE and EARTH monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c99990760.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function c99990760.splimit(e,c,tp,sumtp,sumpos)
	return not (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_EARTH))
end

function c99990760.cfilter(c,tp)
	return c:IsFaceup()
		and c:IsType(TYPE_SYNCHRO)
		and c:IsAttribute(ATTRIBUTE_FIRE)
end

function c99990760.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end

function c99990760.tgfilter(c)
	return c:IsSetCard(0xd56)
		and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsAbleToGrave()
end

function c99990760.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not Duel.IsExistingMatchingCard(c99990760.tgfilter,tp,LOCATION_DECK,0,1,nil) then return false end

		local g=Duel.GetMatchingGroup(c99990760.cfilter,tp,LOCATION_MZONE,0,nil)
		return g:GetClassCount(Card.GetRace)>=2
	end

	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function c99990760.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c99990760.tgfilter,tp,LOCATION_DECK,0,1,1,nil)

	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end