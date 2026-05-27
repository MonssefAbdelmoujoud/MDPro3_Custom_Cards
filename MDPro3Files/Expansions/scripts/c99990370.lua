-- Az-I-Kazak Y
-- Level 3 / FIRE / Machine
-- If you control a FIRE monster, you can Special Summon this card (from your hand).
-- You can Tribute this card; Special Summon 1 "Az-I-Kazak" Tuner from your Deck,
-- also you cannot Special Summon monsters for the rest of this turn, except EARTH and FIRE monsters.
-- You can only Special Summon "Az-I-Kazak Y" once per turn.

local s,id=GetID()
function s.initial_effect(c)

	-- SPSummon once per turn (card name)
	c:SetSPSummonOnce(id)

	-- 1) Special Summon from hand if you control a FIRE monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	-- 2) Tribute this card; SS 1 Az-I-Kazak TUNER from Deck, lock to EARTH/FIRE
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

-- ===== Hand SS if you control a FIRE monster =====
function s.firefilter(c) return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.firefilter,tp,LOCATION_MZONE,0,1,nil)
end

-- ===== Tribute self as cost =====
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

-- ===== Deck SS target: Az-I-Kazak TUNER =====
function s.decksfilter(c,e,tp)
	return c:IsSetCard(0xd56) and c:IsType(TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- allow -1 because cost tributes this card and frees a zone
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			and Duel.IsExistingMatchingCard(s.decksfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.decksfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- Lock: cannot Special Summon except EARTH/FIRE for the rest of this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,tp,sumtp,sumpos)
	-- disallow anything that is NOT EARTH or FIRE
	return not (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_EARTH))
end
