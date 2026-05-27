--Karak Azul Enhancement
local s,id=GetID()
function s.initial_effect(c)
	-- (1) Fusion Summon using materials from hand/field/deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	-- (2) IGNITION: banish this card from GY; add 1 “Karak Azul” monster from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- Only allow monsters as “deck materials”
function s.matfilter(c)
	return c:IsType(TYPE_MONSTER)
	   and c:IsAbleToGrave()
	   and c:IsCanBeFusionMaterial()
end

-- Find “Karak Azul” Fusion monsters in the Extra Deck
function s.filter1(c,e,tp,m,chkf)
	return c:IsType(TYPE_FUSION)
	   and c:IsSetCard(0x69c)
	   and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
	   and c:CheckFusionMaterial(m,nil,chkf)
end

-- (1) Target check + no‐response on activation
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- Gather normal Fusion Materials (field/hand)
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToGrave,nil)
		-- Gather “deck materials” (monsters only)
		local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,chkf)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- Block any chaining to this activation
	Duel.SetChainLimit(aux.FALSE)
end

-- (1) Perform the Fusion Summon
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToGrave,nil)
	local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	local sg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,chkf)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
	if #mat==0 then return end
	tc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end

-- (2.a) Filter for “Karak Azul” monster in GY that can be added to hand
function s.thfilter(c)
	return c:IsSetCard(0x69c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

-- (2.b) Targeting: select 1 “Karak Azul” monster in GY
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end

-- (2.c) Operation: add the selected monster to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
