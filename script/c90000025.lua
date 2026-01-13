-- Crimson Howl Sudden Silence
local s,id=GetID()

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO)
		and Duel.IsChainNegatable(ev)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	local rc=re:GetHandler()
	if Duel.IsExistingMatchingCard(function(c)
		return c:IsType(TYPE_SYNCHRO) and c:GetLevel()>=10
	end,tp,LOCATION_MZONE,0,1,nil) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	else
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
