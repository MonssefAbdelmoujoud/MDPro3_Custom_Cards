--Lady of the 5th-Peak Octar Grudgebelly
function c99990710.initial_effect(c)
	--This card is treated as an "Az-I-Kazak" monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xd56)
	c:RegisterEffect(e0)

	--Link Summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_FIRE),2,2)
	c:EnableReviveLimit()

	--Normal Summon 1 FIRE monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99990710,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,99990710)
	e1:SetTarget(c99990710.sumtg)
	e1:SetOperation(c99990710.sumop)
	c:RegisterEffect(e1)

	--Reveal 2 "Az-I-Kazak" monsters, add 1 and send the other to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99990710,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,99990711)
	e2:SetTarget(c99990710.thtg)
	e2:SetOperation(c99990710.thop)
	c:RegisterEffect(e2)
end

function c99990710.sumfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsSummonable(true,nil)
end

function c99990710.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(c99990710.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end

function c99990710.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c99990710.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end

function c99990710.costfilter(c,g)
	return c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsType(TYPE_SYNCHRO)
		and c:IsAbleToRemoveAsCost()
		and g:IsExists(c99990710.thfilter1,1,nil,g,c:GetLevel())
end

function c99990710.thfilter1(c,g,lv)
	return g:IsExists(c99990710.thfilter2,1,c,c,lv)
end

function c99990710.thfilter2(c,mc,lv)
	return not c:IsCode(mc:GetCode())
		and c:GetLevel()+mc:GetLevel()==lv
end

function c99990710.thfilter(c)
	return c:IsSetCard(0xd56)
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
end

function c99990710.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c99990710.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(c99990710.costfilter,tp,LOCATION_EXTRA,0,1,nil,g) 
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=Duel.SelectMatchingCard(tp,c99990710.costfilter,tp,LOCATION_EXTRA,0,1,1,nil,g)

	e:SetLabel(sg:GetFirst():GetLevel())
	Duel.Remove(sg,POS_FACEUP,REASON_COST)

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,1,tp,LOCATION_DECK)
end

function c99990710.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c99990710.thfilter,tp,LOCATION_DECK,0,nil)
	local lv=e:GetLabel()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:FilterSelect(tp,c99990710.thfilter1,1,1,nil,g,lv)

	if sg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg2=g:FilterSelect(tp,c99990710.thfilter2,1,1,sg:GetFirst(),sg:GetFirst(),lv)

		sg:Merge(sg2)

		Duel.ConfirmCards(1-tp,sg)

		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tg=sg:RandomSelect(1-tp,1)

		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)

		sg:Sub(tg)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end