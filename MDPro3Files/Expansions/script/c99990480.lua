--F.F.O.A. Hylda - Aspect of Az-I-Kazak
function c99990480.initial_effect(c)
	c:SetSPSummonOnce(99990480)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c99990480.matfilter,1,1)

	--gain 100 ATK for each Spell in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(c99990480.atkval)
	c:RegisterEffect(e1)

	--if Special Summoned: add 1 "F.F.O.A." Spell from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99990480,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c99990480.thtg)
	e2:SetOperation(c99990480.thop)
	c:RegisterEffect(e2)
end

function c99990480.matfilter(c)
	return c:IsLinkSetCard(0x857) and c:IsLinkAttribute(ATTRIBUTE_ALL&~ATTRIBUTE_FIRE)
end

function c99990480.atkval(e)
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_SPELL)*100
end

function c99990480.thfilter(c)
	return c:IsSetCard(0x857) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function c99990480.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c99990480.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c99990480.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectTarget(tp,c99990480.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end

function c99990480.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end