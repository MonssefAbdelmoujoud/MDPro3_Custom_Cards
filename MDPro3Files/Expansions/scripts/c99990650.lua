--Karak Azul High Runepriest - Kordum
local s,id=GetID()

function s.initial_effect(c)
	--(1) Quick Effect: Fusion Summon using this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id+100)
	e1:SetCondition(s.fuscon)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)

	--(2) If sent to GY: Set 1 "Karak Azul" Spell/Trap from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+200)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

--========================================================
-- (1) Fusion Summon from hand/field, including this card
--========================================================

function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end

function s.filter2(c,e,tp,m,gc,chkf)
	return c:IsType(TYPE_FUSION)
		and c:IsSetCard(0x69c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,gc,chkf)
end

function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)

	if chk==0 then
		return mg1:IsContains(c)
			and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,c,chkf)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp

	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end

	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,c,chkf)

	if sg1:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg1:Select(tp,1,1,nil)
		local tc=tg:GetFirst()

		if tc then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			if not mat1 or mat1:GetCount()==0 then return end
			if not mat1:IsContains(c) then return end

			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()

			if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
				s.addnegeff(tc)
			end
		end
	end
end

--========================================================
-- Gained effect
-- Once per turn: negate opponent's face-up card effect on field
--========================================================

function s.addnegeff(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp
		and rc:IsOnField()
		and rc:IsFaceup()
		and Duel.IsChainNegatable(ev)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

--========================================================
-- (2) If sent to GY: Set 1 "Karak Azul" Spell/Trap from Deck
--========================================================

function s.setfilter(c)
	return c:IsSetCard(0x69c)
		and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()

	if tc then
		Duel.SSet(tp,tc)
	end
end