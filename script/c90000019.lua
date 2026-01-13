
-- Crimson Howl Resonance Field
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.tgcon)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.atktg)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
end

function s.tgcon(e,tp,eg)
    return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end

function s.tgop(e,tp)
    local g=Duel.SelectMatchingCard(tp,function(c)
        return c:IsSetCard(SET_CRIMSON_HOWL)
    end,tp,LOCATION_DECK,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_EFFECT)
end

function s.atktg(e,c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end

function s.atkval(e,c)
    return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_GRAVE)*300
end
