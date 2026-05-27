--Karak Azul Runeguard – Hylda
--Scripted by ChatGPT
local s,id=GetID()
function s.initial_effect(c)
	--① If a "Karak Azul" monster is sent to the GY, you can Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--② If used as Synchro Material for a "Karak Azul" Synchro Monster,
	--   that Summon cannot be negated, and its monster effect cannot be negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.matcon)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end

-- — Filters for (1)
function s.cfilter(c,tp)
	return c:IsSetCard(0x69c) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- only trigger when chain is empty, and a Karak-Azul monster went to GY
	return eg:IsExists(s.cfilter,1,nil,tp)

end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		   and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

-- — Condition for (2)
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	-- only when this card is material for a Karak-Azul Synchro Monster
	return r==REASON_SYNCHRO
	   and eg:IsExists(function(tc)
			return tc:IsSetCard(0x69c) and tc:IsType(TYPE_SYNCHRO)
		end,1,nil)
end

-- — Operation for (2)
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsSetCard(0x69c) and tc:IsType(TYPE_SYNCHRO) then
			-- (a) Summon cannot be negated
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)

			-- (b) Its monster effect cannot be negated
			local e2=Effect.CreateEffect(tc)
			e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_DISEFFECT)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2,true)
		end
	end
end
