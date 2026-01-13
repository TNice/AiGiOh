
-- Crimson Howl Echo Phantom
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),1,99)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.drcon)
    e1:SetOperation(function(e,tp) Duel.Draw(tp,1,REASON_EFFECT) end)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetOperation(s.lvlop)
    c:RegisterEffect(e2)
end

function s.drcon(e,tp,eg)
    return eg:IsExists(function(c)
        local rc=c:GetReasonCard()
        return rc and rc:IsType(TYPE_SYNCHRO)
    end,1,nil)
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
