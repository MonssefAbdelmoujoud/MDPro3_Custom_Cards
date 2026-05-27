-- Az-I-Kazak Smith
-- Level 6 / Synchro / Machine (tuner requirements left generic; adjust if needed)
-- If this card is Synchro Summoned: choose 1;
-- ● Add 1 "Az-I-Kazak" Spell/Trap from your Deck to your hand.
-- ● If all materials used for this card's Synchro Summon were "Az-I-Kazak" monsters and are all in your GY, Special Summon all of them.
-- You cannot Special Summon monsters the turn you activate this effect, except EARTH and FIRE monsters.
-- You can only use this effect of "Az-I-Kazak Smith" once per turn.

local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()

	-- Trigger: on Synchro Summon (choose effect)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)) -- Placeholder, not used in menu
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- Material check: were all materials Az-I-Kazak?
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)

	-- Custom activity counter (SS restriction)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

	-- Reference
	s.listed_series={0xd56}
	s.listed_attributes={ATTRIBUTE_EARTH,ATTRIBUTE_FIRE}
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) or c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsAttribute(ATTRIBUTE_EARTH) or c:IsAttribute(ATTRIBUTE_FIRE))
end

function s.thfilter(c)
	return c:IsSetCard(0xd56) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.mat_spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008
		and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=mg:GetCount()
	local canAdd=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local canRevive=e:GetLabel()==1 and ct>0 and mg:FilterCount(s.mat_spfilter,nil,e,tp,c)==ct
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
	if chk==0 then return canAdd or canRevive end

	local ops,opv={},{}
	local off=1
	if canAdd then
		ops[off]=aux.Stringid(id,1)
		opv[off]=0
		off=off+1
	end
	if canRevive then
		ops[off]=aux.Stringid(id,2)
		opv[off]=1
		off=off+1
	end
	local selIndex=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opv[selIndex]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetTargetCard(mg)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,0,0)
	end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local g=mg:Filter(Card.IsRelateToEffect,nil,e)
		if #g<mg:GetCount() then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g then return end
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.notAzIKazak(c)
	return not c:IsSetCard(0xd56)
end

function s.valcheck(e,c)
	local g=c:GetMaterial()
	if #g>0 and not g:IsExists(s.notAzIKazak,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
