--Az-I-Kazak – Karak Azul Military Alliance
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	--Reveal and search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)

	-- Support sets
	s.listed_series={0xd56, 0x69c}
end

-- Filter: Searchable monsters from Deck
function s.thfilter(c,setcode,maxlevel)
	return c:IsSetCard(setcode) and c:IsType(TYPE_MONSTER)
		and c:IsLevelBelow(maxlevel) and c:IsAbleToHand()
end

-- Valid reveal monsters
function s.revealfilter(c,tp)
	if not c:IsType(TYPE_MONSTER) or c:IsPublic() or not c:IsLevelAbove(1) then return false end
	local level=c:GetLevel()
	local target_set = nil
	if c:IsSetCard(0xd56) then
		target_set = 0x69c
	elseif c:IsSetCard(0x69c) then
		target_set = 0xd56
	end
	return target_set and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,target_set,level)
end

-- Target: Reveal 1 monster in hand and prepare to search
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
	e:SetLabelObject(rc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Operation: Search and shuffle revealed card into Deck
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject()
	if not rc or not rc:IsLevelAbove(1) then return end

	local lvl=rc:GetLevel()
	local target_set=nil
	if rc:IsSetCard(0xd56) then
		target_set=0x69c
	elseif rc:IsSetCard(0x69c) then
		target_set=0xd56
	end
	if not target_set then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,target_set,lvl)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

	-- Shuffle revealed card back into the Deck
	if rc:IsLocation(LOCATION_HAND) then
		Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
