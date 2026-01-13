
-- Crimson Howl Second Movement
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(function(e,tp)
        return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
    end)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

function s.filter(c,e,tp)
    return c:IsSetCard(SET_CRIMSON_HOWL)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop(e,tp)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end
