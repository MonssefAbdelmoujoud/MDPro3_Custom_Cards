--Az-I-Kazak – Sven Moltenhammer
local s,id=GetID()

function s.initial_effect(c)
	--Link Summon: 1 non-Link monster with 1000 ATK or less
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()

	--① If this card is Link Summoned: Add 1 "First Peak - Az-I-Kazak" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	--② When an opponent's monster declares an attack targeting this card: Destroy this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	e2:SetCountLimit(1,id+1)
	c:RegisterEffect(e2)

	--Listed support
	s.listed_series={0xd56}
	s.listed_names={99990330}
end

--Link Summon requirement:
--1 non-Link monster with 1000 ATK or less
function s.matfilter(c)
	return not c:IsType(TYPE_LINK)
		and c:GetAttack()>=0
		and c:GetAttack()<=1000
end

--① Search condition: must be Link Summoned
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

--Search "First Peak - Az-I-Kazak"
function s.thfilter(c)
	return c:IsCode(99990330) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)

	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--② Condition:
--This card was targeted for an attack by an opponent's monster
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local at=Duel.GetAttacker()
	return eg:IsContains(c) and at and at:IsControler(1-tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDestructable()
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Destroy(c,REASON_EFFECT)
	end
end