--Karak Azul Siege Engine – Hellhammer
local s,id=GetID()
function s.initial_effect(c)
	-- Xyz Summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x69c),5,2)
	c:EnableReviveLimit()

	-- (1) Detach 2: destroy all cards in this card's column
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.descost)
	e1:SetTarget(s.columntg)
	e1:SetOperation(s.columnop)
	c:RegisterEffect(e1)

	-- (2) Recharge: attach 1 "Karak Azul" monster from GY as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.mttg)
	e2:SetOperation(s.mtop)
	c:RegisterEffect(e2)
end

-- (1) Cost: detach 2 materials
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end

-- (1) Target: all cards in this card’s column
function s.columntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetColumnGroup()
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

-- (1) Operation: destroy all cards in column
function s.columnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetColumnGroup():Filter(Card.IsDestructable,nil)
	-- Include this card itself, since effect says "all cards in this card's column"
	g:AddCard(c)
	if #g>0 then
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- (2) Recharge: attach 1 "Karak Azul" monster from GY
function s.mtfilter(c)
	return c:IsSetCard(0x69c) and c:IsType(TYPE_MONSTER)
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=Duel.SelectMatchingCard(tp,s.mtfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end
