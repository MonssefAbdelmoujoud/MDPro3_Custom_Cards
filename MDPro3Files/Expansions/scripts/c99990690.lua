--Az-I-Kazak Gorgaz
local s,id=GetID()

function s.initial_effect(c)
	--Synchro Summon: 1 "Az-I-Kazak" Tuner + 1+ non-Tuner monsters
	aux.AddSynchroProcedure(c,s.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()

	--① If this card is Synchro Summoned:
	--Special Summon as many "Az-I-Kazak" Tuners with different Levels from your Deck as possible
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--② GY effect:
	--When an attack is declared involving your "Az-I-Kazak" monster:
	--banish this card; that monster's ATK becomes doubled
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	--Custom activity counter for Extra Deck lock
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

--Synchro Tuner requirement: "Az-I-Kazak" Tuner
function s.tfilter(c)
	return c:IsSetCard(0xd56)
end

--Extra Deck lock check:
--You cannot Special Summon from the Extra Deck, except FIRE or EARTH monsters
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
		or c:IsAttribute(ATTRIBUTE_FIRE)
		or c:IsAttribute(ATTRIBUTE_EARTH)
end

--After activation, lock Extra Deck Special Summons to FIRE/EARTH only
function s.extralimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
		and not c:IsAttribute(ATTRIBUTE_FIRE)
		and not c:IsAttribute(ATTRIBUTE_EARTH)
end

--Must be Synchro Summoned
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.extralimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--Deck summon filter:
--"Az-I-Kazak" Tuner
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xd56)
		and c:IsType(TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end

	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()==0 then return end

	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		ft=1
	end

	--Maximum number of monsters with different Levels that can be summoned
	local ct=math.min(g:GetClassCount(Card.GetLevel),ft)
	if ct<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	--Select monsters with different Levels
	aux.GCheckAdditional=aux.dlvcheck
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,ct)
	aux.GCheckAdditional=nil

	if sg and sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

--GY effect cost: banish this card
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToRemoveAsCost()
	end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

--An "Az-I-Kazak" monster you control involved in battle
function s.atkfilter(c,tp)
	return c
		and c:IsFaceup()
		and c:IsControler(tp)
		and c:IsSetCard(0xd56)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
			and s.atkfilter(chkc,tp)
			and (chkc==a or chkc==d)
	end

	if chk==0 then
		return s.atkfilter(a,tp) or s.atkfilter(d,tp)
	end

	local g=Group.CreateGroup()

	if s.atkfilter(a,tp) then
		g:AddCard(a)
	end
	if s.atkfilter(d,tp) then
		g:AddCard(d)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(sg)

	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,sg,1,0,0)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()

	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		if atk<0 then return end

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end