-- Crimson Howl Bloodbound Warden
local s,id=GetID()

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsChainNegatable(ev) then
		if Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
			and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
			Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
		else
			Duel.NegateActivation(ev)
		end
	end
end
