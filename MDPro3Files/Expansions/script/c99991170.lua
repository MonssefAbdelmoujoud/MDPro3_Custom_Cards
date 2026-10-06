-- Zharr Dreadquake Mortar
-- Script for MDPro3
local s,id=GetID()
local SET_ZHARR=0xf81
function s.initial_effect(c)
	-- 2+ Level 4 "Zharr" monsters
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_ZHARR),4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- (1) Attach up to 2 cards from either GY to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mattg)
	e1:SetOperation(s.matop)
	c:RegisterEffect(e1)
	-- (2) Detach any number; choose that many zones that contain a card; destroy the cards in those zones
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanOverlay),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Overlay(c,g)
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local fc=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return fc>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local max=math.min(c:GetOverlayCount(),fc)
	c:RemoveOverlayCard(tp,1,max,REASON_COST)
	e:SetLabel(Duel.GetOperatedGroup():GetCount())
	-- This card cannot attack during the turn you activate this effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- Zones are remembered as one bitmask per player:
-- bits 0-6 = Monster Zones (incl. Extra Monster Zones), bits 8-15 = Spell & Trap Zones (incl. Field Zone)
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	local fc=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if ct>fc then ct=fc end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	Duel.HintSelection(g)
	local mask={[0]=0,[1]=0}
	for tc in aux.Next(g) do
		local p=tc:GetControler()
		local bit=tc:GetSequence()
		if tc:IsLocation(LOCATION_SZONE) then bit=bit+8 end
		mask[p]=mask[p]|(1<<bit)
	end
	e:SetLabel(mask[0],mask[1])
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local m0,m1=e:GetLabel()
	local mask={[0]=m0 or 0,[1]=m1 or 0}
	local g=Group.CreateGroup()
	for p=0,1 do
		for bit=0,15 do
			if mask[p]&(1<<bit)~=0 then
				local loc=LOCATION_MZONE
				local seq=bit
				if bit>=8 then
					loc=LOCATION_SZONE
					seq=bit-8
				end
				local tc=Duel.GetFieldCard(p,loc,seq)
				if tc then g:AddCard(tc) end
			end
		end
	end
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
