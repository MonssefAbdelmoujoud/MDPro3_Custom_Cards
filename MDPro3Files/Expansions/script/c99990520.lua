--F.F.O.A. RAK-Unit Type Tuk-Dawi
function c99990520.initial_effect(c)
	aux.AddCodeList(c,99990450,99990460)
	--link summon
	c:SetSPSummonOnce(99990520)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x857),2,2)
	--cannot be used as Link Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--add 1 "F.F.O.A." Spell from Deck/GY to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99990520,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,99990520)
	e1:SetTarget(c99990520.thtg)
	e1:SetOperation(c99990520.thop)
	c:RegisterEffect(e1)
	--tribute this card; Special Summon Hylda Ironshield and Zigritch from Deck/GY, then optionally destroy 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99990520,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,99990520)
	e2:SetCost(c99990520.spcost)
	e2:SetTarget(c99990520.sptg)
	e2:SetOperation(c99990520.spop)
	c:RegisterEffect(e2)
end

function c99990520.thfilter(c)
	return c:IsSetCard(0x857) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function c99990520.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c99990520.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function c99990520.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c99990520.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function c99990520.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c,tp)>1 end
	Duel.Release(c,REASON_COST)
end

function c99990520.spfilter1(c,e,tp)
	return c:IsCode(99990450) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c99990520.spfilter2(c,e,tp)
	return c:IsCode(99990460) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c99990520.fselect(g)
	return g:GetClassCount(Card.GetCode)==2
end

function c99990520.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.IsExistingMatchingCard(c99990520.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(c99990520.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function c99990520.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c99990520.spfilter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c99990520.spfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if g1:GetCount()>=1 and g2:GetCount()>=1 then
		g1:Merge(g2)
		local sg=g1:SelectSubGroup(tp,c99990520.fselect,false,2,2)
		if sg and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(99990520,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if dg:GetCount()>0 then
				Duel.BreakEffect()
				Duel.HintSelection(dg)
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end