-- Crimson Howl Echo Phantom
local s,id=GetID()

function s.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,1,1)
	c:EnableReviveLimit()

	-- Draw when card destroyed by Synchro
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.drcon)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)

	-- Reduce Level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.lvlop)
	c:RegisterEffect(e2)
end

function s.drcon(e,tp,eg)
	return eg:IsExists(function(c)
		return c:GetReasonCard():IsType(TYPE_SYNCHRO)
	end,1,nil)
end

function s.drop(e,tp)
	Duel.Draw(tp,1,REASON_EFFECT)
end

function s.lvlop(e,tp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
