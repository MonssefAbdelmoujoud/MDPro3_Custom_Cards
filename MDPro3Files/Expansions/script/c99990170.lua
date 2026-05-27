--Karak Azul Warmachine – The Elgi Sweeper
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()

	aux.AddFusionProcCodeFun(c,99990010,aux.FilterBoolFunction(Card.IsFusionSetCard,0x69c),1,false,false)

	--extra att
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
end
