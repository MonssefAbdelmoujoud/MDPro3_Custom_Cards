--Mosnef
function c99990720.initial_effect(c)
	c:EnableReviveLimit()

	--This card is treated as an "Az-I-Kazak" monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xd56)
	c:RegisterEffect(e0)

	--Synchro Summon: 1 FIRE Tuner + 1 non-Tuner FIRE monster
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),aux.NonTuner(c99990720.sfilter),1,1)

	--Dice Popboost
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99990720,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DICE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c99990720.destg)
	e1:SetOperation(c99990720.desop)
	c:RegisterEffect(e1)

	--Special Summon Level 7 FIRE Synchros
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99990720,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c99990720.spcon)
	e2:SetCost(c99990720.spcost)
	e2:SetTarget(c99990720.sptg)
	e2:SetOperation(c99990720.spop)
	c:RegisterEffect(e2)
end

c99990720.material_type=TYPE_SYNCHRO

function c99990720.sfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end

function c99990720.gyfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToDeck()
end

function c99990720.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c99990720.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

function c99990720.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=Duel.TossDice(tp,1)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local gy=Duel.SelectMatchingCard(tp,c99990720.gyfilter,tp,LOCATION_GRAVE,0,1,dc,nil)

	if gy:GetCount()==0 then return end

	local yc=Duel.SendtoDeck(gy,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)

	if yc>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(99990720,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,yc,nil)
		Duel.HintSelection(dg)

		local ct=Duel.Destroy(dg,REASON_EFFECT)

		if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end

function c99990720.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and Duel.GetTurnPlayer()~=tp
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end

function c99990720.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsReleasable()
	end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function c99990720.spfilter(c,e,tp,mc)
	return c:IsLevel(7)
		and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end

function c99990720.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c99990720.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function c99990720.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end

function c99990720.gcheck(g,ft1,ft2)
	return aux.dncheck(g)
		and g:GetCount()<=ft1
		and g:FilterCount(c99990720.exfilter,nil)<=ft2
end

function c99990720.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_SYNCHRO)
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local ct=math.min(ft,ect,2)

	if ct<=0 then return end

	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		ct=1
	end

	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	local g=Duel.GetMatchingGroup(c99990720.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,c99990720.gcheck,false,1,2,ct,ft2)

	if sg then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end