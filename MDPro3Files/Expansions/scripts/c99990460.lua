--F.F.O.A.- King Slayer Zigritch
function c99990460.initial_effect(c)
	--Special Summon this card from your hand if an "F.F.O.A." monster is Normal or Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99990460,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,99990460)
	e1:SetCondition(c99990460.spcon1)
	e1:SetTarget(c99990460.sptg)
	e1:SetOperation(c99990460.spop1)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	--Special Summon this card from the GY if an opponent's monster leaves the Extra Monster Zone by battle or your card effect, then optionally negate 1 opponent's monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99990460,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,99990461)
	e3:SetCondition(c99990460.spcon2)
	e3:SetTarget(c99990460.sptg)
	e3:SetOperation(c99990460.spop2)
	c:RegisterEffect(e3)
end

function c99990460.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x857) and not c:IsCode(99990460)
end

function c99990460.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99990460.cfilter1,1,nil)
end

function c99990460.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function c99990460.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function c99990460.cfilter2(c,tp,rp)
	return c:IsPreviousControler(1-tp)
		and c:GetPreviousSequence()>4
		and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or (rp==tp and c:IsReason(REASON_EFFECT)))
end

function c99990460.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99990460.cfilter2,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end

function c99990460.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(99990460,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
		local g=Duel.SelectMatchingCard(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.HintSelection(g)
		local tc=g:GetFirst()
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
	end
end