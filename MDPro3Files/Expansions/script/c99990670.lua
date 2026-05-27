--Karak Azul Fusion
function c99990670.initial_effect(c)
	--Activate: Fusion Summon 1 "Karak Azul" Fusion Monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99990670.target)
	e1:SetOperation(c99990670.activate)
	c:RegisterEffect(e1)

	--GY Effect: Once per Duel, banish this card; make all monsters you control become target's Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99990670,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,99990670+EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(c99990670.lvcost)
	e2:SetTarget(c99990670.lvtarget)
	e2:SetOperation(c99990670.lvoperation)
	c:RegisterEffect(e2)
end

--Fusion material on field
function c99990670.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end

function c99990670.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end

--Fusion Monster filter: "Karak Azul" Fusion Monster
function c99990670.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x69c) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,chkf)
end

--GY material filter
function c99990670.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end

function c99990670.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp

		--Materials from field
		local mg1=Duel.GetFusionMaterial(tp):Filter(c99990670.filter0,nil)

		--Materials from GY
		local mg2=Duel.GetMatchingGroup(c99990670.filter3,tp,LOCATION_GRAVE,0,nil)

		mg1:Merge(mg2)

		return Duel.IsExistingMatchingCard(c99990670.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end

function c99990670.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp

	--Materials from field
	local mg1=Duel.GetFusionMaterial(tp):Filter(c99990670.filter1,nil,e)

	--Materials from GY
	local mg2=Duel.GetMatchingGroup(c99990670.filter3,tp,LOCATION_GRAVE,0,nil)

	mg1:Merge(mg2)

	--Valid "Karak Azul" Fusion Monsters
	local sg=Duel.GetMatchingGroup(c99990670.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	if sg:GetCount()==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=sg:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	if not tc then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
	if mat:GetCount()==0 then return end

	tc:SetMaterial(mat)

	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()

	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
	end
end

--GY effect cost: banish this card
function c99990670.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToRemoveAsCost()
	end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

--Target 1 face-up "Karak Azul" monster you control
function c99990670.lvfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x69c) and c:GetLevel()>0
end

--All face-up monsters you control with Levels
function c99990670.lvfilter2(c)
	return c:IsFaceup() and c:GetLevel()>0
end

function c99990670.lvtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
			and chkc:IsControler(tp)
			and c99990670.lvfilter1(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(c99990670.lvfilter1,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(c99990670.lvfilter2,tp,LOCATION_MZONE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c99990670.lvfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end

function c99990670.lvoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()

	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetLevel()>0 then
		local lv=tc:GetLevel()

		--All monsters currently controlled by you become that Level
		local g=Duel.GetMatchingGroup(c99990670.lvfilter2,tp,LOCATION_MZONE,0,nil)

		local lc=g:GetFirst()
		while lc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			lc:RegisterEffect(e1)

			lc=g:GetNext()
		end
	end
end