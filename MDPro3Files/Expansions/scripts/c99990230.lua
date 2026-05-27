--Az-I-Kazak's United Guildmasters
local s,id=GetID()

function s.initial_effect(c)
	--Link Summon procedure: 2+ FIRE and/or EARTH monsters
	--For a LINK-3 monster: minimum 2 materials, maximum 3 materials
	aux.AddLinkProcedure(c,s.matfilter,2,3)
	c:EnableReviveLimit()

	--① This card is also treated as a "Karak Azul" card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetValue(0x69c)
	c:RegisterEffect(e1)

	--② If this card is Link Summoned: apply the appropriate effect based on its materials
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.lkcon)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end

--Materials must be FIRE and/or EARTH monsters
function s.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_EARTH)
end

--Must be Link Summoned
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

--Face-up monster target filter for mixed FIRE + EARTH effect
function s.atkfilter(c)
	return c:IsFaceup()
end

function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local mat=c:GetMaterial()
	local total=mat:GetCount()
	local fire=mat:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_FIRE)
	local earth=mat:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_EARTH)

	if fire==total then
		--Only FIRE materials
		--This only gives the card the Quick Effect, so no target is needed now
		e:SetLabel(1)
		e:SetCategory(0)
		if chk==0 then return true end

	elseif earth==total then
		--Only EARTH materials
		--This gives protection and the Quick Effect, so no target is needed now
		e:SetLabel(2)
		e:SetCategory(0)
		if chk==0 then return true end

	else
		--Both FIRE and EARTH materials
		e:SetLabel(3)
		e:SetCategory(CATEGORY_ATKCHANGE)

		if chkc then
			return chkc:IsLocation(LOCATION_MZONE)
				and s.atkfilter(chkc)
		end

		if chk==0 then
			return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
	end
end

function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local label=e:GetLabel()

	if label==1 then
		--Only FIRE:
		--Once per turn, Quick Effect: target up to 2 cards on the field; destroy them
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,id+1)
		e1:SetTarget(s.firetg)
		e1:SetOperation(s.fireop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

	elseif label==2 then
		--Only EARTH:
		--This card cannot be destroyed by card effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		--Once per turn, Quick Effect:
		--target 1 Special Summoned monster your opponent controls; shuffle it into the Deck
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetCategory(CATEGORY_TODECK)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1,id+2)
		e2:SetTarget(s.shuftg)
		e2:SetOperation(s.shufop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)

	elseif label==3 then
		--Both FIRE and EARTH:
		--Targeted monster's ATK becomes 0 until the end of this turn
		local tc=Duel.GetFirstTarget()

		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end

--FIRE-only Quick Effect target filter
function s.firefilter(c)
	return c:IsOnField() and c:IsDestructable()
end

function s.firetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_ONFIELD)
			and s.firefilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(s.firefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.firefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end

function s.fireop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local dg=Group.CreateGroup()

	if g then
		local tc=g:GetFirst()
		while tc do
			if tc:IsRelateToEffect(e) then
				dg:AddCard(tc)
			end
			tc=g:GetNext()
		end
	end

	if dg:GetCount()>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

--EARTH-only Quick Effect target filter
function s.shuffilter(c)
	return c:IsFaceup()
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and c:IsAbleToDeck()
end

function s.shuftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(1-tp)
			and chkc:IsLocation(LOCATION_MZONE)
			and s.shuffilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(s.shuffilter,tp,0,LOCATION_MZONE,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.shuffilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function s.shufop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()

	if tc and tc:IsRelateToEffect(e) and tc:IsAbleToDeck() then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end