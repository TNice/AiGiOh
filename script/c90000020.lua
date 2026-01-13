
-- Crimson Howl Rift Drummer
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.matcon)
    e2:SetOperation(s.matop)
    c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg)
    return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end

function s.spop(e,tp)
    Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    return r==REASON_SYNCHRO and re:GetHandler():IsAttribute(ATTRIBUTE_DARK)
        and re:GetHandler():IsRace(RACE_DRAGON)
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=re:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(500)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    e2:SetReset(RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)
end
