--Az-I-Kazak - Contractor Jazurth
function c99990700.initial_effect(c)
	--Special Summon 1 "Karak Azul" Tuner from hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99990700,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,99990700)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c99990700.sptg)
	e1:SetOperation(c99990700.spop)
	c:RegisterEffect(e1)
end

function c99990700.spfilter(c,e,tp)
	return c:IsSetCard(0xd56)
		and c:IsType(TYPE_TUNER)
		and not c:IsCode(99990700)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c99990700.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(c99990700.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function c99990700.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c99990700.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)

	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end