-- Hashut, Bull-Father of the Zharr (overframe alternate art)
-- Script for MDPro3
local s=GetID()
-- Alternate art (overframe) of Hashut 99991110: use the original ID so both versions share
-- the once-per-turn Special Summon and effect limits.
local id=99991110
local SET_ZHARR=0xf81
function s.initial_effect(c)
	-- 3 Level 12 monsters / or 1 Rank 8 "Zharr" Xyz Monster you control that has no material
	aux.AddXyzProcedure(c,nil,12,3,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	-- (1) Gains 500 ATK for each material it has
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- (1) While it has a material your opponent owns: unaffected by your opponent's card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(s.immcon)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	-- (2) Quick Effect: detach 1; attach all monsters your opponent controls to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.wipecost)
	e3:SetTarget(s.wipetg)
	e3:SetOperation(s.wipeop)
	c:RegisterEffect(e3)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ZHARR) and c:IsType(TYPE_XYZ) and c:IsRank(8) and c:GetOverlayCount()==0
end
function s.atkval(e,c)
	return c:GetOverlayCount()*500
end
function s.immcon(e)
	local c=e:GetHandler()
	local p=c:GetControler()
	return c:GetOverlayGroup():IsExists(function(oc) return oc:GetOwner()~=p end,1,nil)
end
function s.immval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.wipecost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.wipetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,0,LOCATION_MZONE,1,nil) end
end
function s.wipeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local g=Duel.GetMatchingGroup(function(tc) return tc:IsCanOverlay() and not tc:IsImmuneToEffect(e) end,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	-- materials of attached Xyz Monsters are sent to the GY
	local og=Group.CreateGroup()
	for tc in aux.Next(g) do
		og:Merge(tc:GetOverlayGroup())
	end
	if #og>0 then
		Duel.SendtoGrave(og,REASON_RULE)
	end
	Duel.Overlay(c,g)
end
