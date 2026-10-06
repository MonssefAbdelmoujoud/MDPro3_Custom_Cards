-- Zharr Tithe of Slaves
-- Script for MDPro3
local s,id=GetID()
local SET_ZHARR=0xf81
function s.initial_effect(c)
	-- When your opponent would Summon a monster(s): detach 2 materials from "Zharr" Xyz Monster(s) you control;
	-- negate the Summon, and if you do, attach that monster(s) to a "Zharr" Xyz Monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.NegateSummonCondition() and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ZHARR) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_MZONE,0,nil)
		return g:GetSum(Card.GetOverlayCount)>=2
	end
	for i=1,2 do
		local g=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_MZONE,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:RemoveOverlayCard(tp,1,1,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ZHARR) and c:IsType(TYPE_XYZ)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	local og=eg:Filter(Card.IsCanOverlay,nil)
	if #xg>0 and #og>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local xc=xg:Select(tp,1,1,nil):GetFirst()
		local mg=Group.CreateGroup()
		for tc in aux.Next(og) do
			mg:Merge(tc:GetOverlayGroup())
		end
		if #mg>0 then
			Duel.SendtoGrave(mg,REASON_RULE)
		end
		Duel.Overlay(xc,og)
	end
	-- anything that could not be attached is destroyed so it does not stay on the field
	local rest=eg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if #rest>0 then
		Duel.Destroy(rest,REASON_EFFECT)
	end
end
