--Karak Azul Ambush
local s,id=GetID()
function s.initial_effect(c)
	-- Negate attack and end Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1, id)
	c:RegisterEffect(e1)
end

-- Cost: if activating from hand, reveal the card
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	if c:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,c)
	end
end

-- Allow activation from field or hand if you control Link2+ Karak Azul
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttackTarget()
	if not (tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsSetCard(0x69c)) then return false end
	if c:IsLocation(LOCATION_SZONE) then return true end
	return Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.linkfilter(c)
	return c:IsSetCard(0x69c) and c:IsType(TYPE_LINK) and c:GetLink()>=2
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() then
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
