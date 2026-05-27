--Karak Azul - Rune Guard Golem
local s,id=GetID()

function s.initial_effect(c)
	--Fusion Materials: 1 "Karak Azul" monster + 1 Effect Monster
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,s.ffilter,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),true)

	--(1) If Fusion Summoned: Add 1 "Karak Azul" monster from Deck to hand, then Normal Summon it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id+100)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	--(2) Quick Effect: Xyz Summon 1 "Karak Azul" Xyz Monster using monsters you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id+200)
	e2:SetCondition(s.xyzcon)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end

--========================================================
-- Fusion Material
-- 1 "Karak Azul" monster + 1 Effect Monster
--========================================================

function s.ffilter(c)
	return c:IsSetCard(0x69c) and c:IsType(TYPE_MONSTER)
end

--========================================================
-- (1) If Fusion Summoned: Search then Normal Summon
--========================================================

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.thfilter(c)
	return c:IsSetCard(0x69c)
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()

	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)

		if tc:IsLocation(LOCATION_HAND) and tc:IsSummonable(true,nil) then
			Duel.BreakEffect()
			Duel.Summon(tp,tc,true,nil)
		end
	end
end

--========================================================
-- (2) Quick Effect: Xyz Summon a "Karak Azul" Xyz Monster
--========================================================

function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.xyzfilter(c)
	return c:IsType(TYPE_XYZ)
		and c:IsSetCard(0x69c)
		and c:IsXyzSummonable(nil)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()

	if tc then
		Duel.XyzSummon(tp,tc,nil)
	end
end