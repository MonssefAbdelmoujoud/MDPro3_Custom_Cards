--Shadow Dwarf Assault
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon Procedure
	aux.AddXyzProcedure(c,nil,5,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	
	--Xyz Limit Condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.xyzcondition)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--(2) Special Summon from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.GetCurrentPhase()==PHASE_MAIN1 end)
	e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsLevelBelow,4),tp,LOCATION_HAND,0,1,nil)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		-- Prevent Battle Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsLevelBelow,4),tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end)
	c:RegisterEffect(e2)

	--(3) Destroy Fields, Recover LP, Search Field Spell
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	end)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
		if chk==0 then return #g>0 end
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
		if #g==0 then return end
		if Duel.Destroy(g,REASON_EFFECT)==0 then return end
		local og=Duel.GetOperatedGroup()
		if #og>0 then
			Duel.Recover(tp,1000,REASON_EFFECT)
			local fg=Duel.GetMatchingGroup(function(c)
				return c:IsType(TYPE_FIELD) and c:IsAbleToHand() and not og:IsExists(Card.IsCode,1,nil,c:GetCode())
			end,tp,LOCATION_DECK,0,nil)
			if #fg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=fg:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
				end
			end
		end
	end)
	c:RegisterEffect(e3)
end

--Xyz Material Filter
function s.ovfilter(c)
	return c:IsFaceup() and (c:IsRank(3) or c:IsRank(4))
end

--Xyz Summon Restriction (once per turn)
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end

--Xyz material lockout if has materials
function s.xyzcondition(e)
	return e:GetHandler():GetOverlayCount()>0
end
