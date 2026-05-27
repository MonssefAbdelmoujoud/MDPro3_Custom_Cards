-- Az-I-Kazak X
-- Level 3 / FIRE / Machine
-- If you control no monsters, you can Special Summon this card (from your hand).
-- When this card is Normal or Special Summoned: You can add 1 "Karak Azul" monster
-- from your Deck to your hand, except "Az-I-Kazak X".
-- You can only use this effect of "Az-I-Kazak X" once per turn.

local s,id=GetID()
function s.initial_effect(c)


	-- 1) Special Summon from hand if you control no monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	-- 2) Search on summon (Normal or Special)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY) -- modern safe timing
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id) -- HOPT on the search effect
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

-- ===== Hand SS condition =====
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- ===== Search filter/target/op =====
function s.thfilter(c)
	return c:IsSetCard(0xd56) -- Karak Azul
		and c:IsType(TYPE_MONSTER)
		and not c:IsCode(id)	  -- "except Az-I-Kazak X" (harmless even though it's not 0x69c)
		and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
