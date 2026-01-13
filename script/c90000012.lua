-- Crimson Howl Grave Lockdown
local s,id=GetID()

function s.initial_effect(c)
	-- Cards cannot be banished
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,1)
	c:RegisterEffect(e1)

	-- Negate sending from Deck to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

function s.negcon(e,tp,eg)
	return eg:IsExists(function(c)
		return c:IsPreviousLocation(LOCATION_DECK)
	end,1,nil)
end

function s.negop(e,tp,eg)
	Duel.NegateRelatedChain(eg)
end
