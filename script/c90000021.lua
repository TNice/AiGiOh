
-- Crimson Howl Rising Dragon
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),1,99)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

function s.filter(c,e,tp)
    return c:IsSetCard(SET_CRIMSON_HOWL) and c:IsType(TYPE_TUNER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop(e,tp)
    local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ct<=0 then return end
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,math.min(2,ct),nil,e,tp)
    for tc in aux.Next(g) do
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)
    end
end
