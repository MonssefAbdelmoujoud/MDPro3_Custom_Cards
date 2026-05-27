--Az-I-Kazak Rakin
local s,id=GetID()

function s.initial_effect(c)
	--Synchro Summon: 1 Tuner + 1+ non-Tuner monsters
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()

	--① If this card is Special Summoned: Add 1 "Az-I-Kazak" Spell/Trap from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	--② Quick Effect: Target 1 Level 6 or higher Synchro Monster on the field, except this card;
	--return this card to the Extra Deck, and if you do, Special Summon 1 "Az-I-Kazak" Synchro Monster
	--from your Extra Deck with the same Level as that target
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--Listed archetype
	s.listed_series={0xd56}
end

--Search 1 "Az-I-Kazak" Spell/Trap
function s.thfilter(c)
	return c:IsSetCard(0xd56)
		and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)

	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Target filter:
--1 Level 6 or higher Synchro Monster on the field, except "Az-I-Kazak Rakin"
function s.cfilter(c,e,tp,ec)
	return c:IsFaceup()
		and c:IsType(TYPE_SYNCHRO)
		and c:GetLevel()>=6
		and not c:IsCode(id)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel(),ec)
end

--Extra Deck summon filter:
--1 "Az-I-Kazak" Synchro Monster with same Level
function s.spfilter(c,e,tp,lv,ec)
	return c:IsSetCard(0xd56)
		and c:IsType(TYPE_SYNCHRO)
		and c:IsLevel(lv)
		and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
			and s.cfilter(chkc,e,tp,c)
	end

	if chk==0 then
		return c:IsAbleToExtra()
			and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,c)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,c)

	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if not c:IsRelateToEffect(e) then return end
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end

	local lv=tc:GetLevel()

	--Return this card to the Extra Deck
	if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,nil):GetFirst()

		if sc then
			sc:SetMaterial(nil)
			if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
				sc:CompleteProcedure()
			end
		end
	end
end