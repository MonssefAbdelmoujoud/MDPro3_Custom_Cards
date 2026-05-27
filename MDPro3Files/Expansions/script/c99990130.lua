--Karak Azul Ironwall – Bar-Kazad
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon procedure
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x69c),4,2)
	c:EnableReviveLimit()

	--Protect other Karak Azul monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- List Karak Azul support
	s.listed_series={0x69c}
end

-- Optional overlay filter (if you want to restrict materials further, edit here)
function s.ovfilter(c,tp,lc)
	return true
end

-- Cost: detach 1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Make other Karak Azul monsters unaffected by opponent's effects
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.protfilter,tp,LOCATION_MZONE,0,nil,c)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(s.efilter)
		tc:RegisterEffect(e1)
	end
end

-- Only protect OTHER face-up Karak Azul monsters
function s.protfilter(c,handler)
	return c:IsFaceup() and c:IsSetCard(0x69c) and c~=handler
end

-- Unaffected by opponent's effects
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
