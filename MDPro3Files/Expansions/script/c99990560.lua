--F.F.O.A. Rakin's First Aid Kit
function c99990560.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER+CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c99990560.condition)
	e1:SetTarget(c99990560.target)
	e1:SetOperation(c99990560.activate)
	c:RegisterEffect(e1)
end

function c99990560.cfilter(c)
	return c:GetSequence()<5
end

function c99990560.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c99990560.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function c99990560.spfilter(c,e,tp)
	return c:IsSetCard(0x857) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c99990560.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end

function c99990560.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE)
			and c99990560.spfilter(chkc,e,tp)
	end

	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c99990560.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=true

	if chk==0 then return b1 or b2 end

	local op
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(99990560,0),aux.Stringid(99990560,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(99990560,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(99990560,1))+1
	end

	e:SetLabel(op)

	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,c99990560.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
	end

	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		if Duel.IsExistingMatchingCard(c99990560.rmfilter,tp,0,LOCATION_GRAVE,1,nil) then
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
		end
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
	end
end

function c99990560.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()

	if op==0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		Duel.Recover(tp,2000,REASON_EFFECT)
	end

	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)<3 then return end

	local b1=Duel.IsExistingMatchingCard(c99990560.rmfilter,tp,0,LOCATION_GRAVE,1,nil)
	local b2=true

	if not b1 and not b2 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(99990560,2)) then return end

	Duel.BreakEffect()

	local op2
	if b1 and b2 then
		op2=Duel.SelectOption(tp,aux.Stringid(99990560,3),aux.Stringid(99990560,4))
	elseif b1 then
		op2=Duel.SelectOption(tp,aux.Stringid(99990560,3))
	else
		op2=Duel.SelectOption(tp,aux.Stringid(99990560,4))+1
	end

	if op2==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c99990560.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
		if g:GetCount()>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	else
		Duel.Damage(1-tp,1500,REASON_EFFECT)
	end
end