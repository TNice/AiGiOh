
-- Crimson Howl Backbeat Revival
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r) return r==REASON_SYNCHRO end)
    e2:SetOperation(function(e,tp) Duel.Draw(tp,1,REASON_EFFECT) end)
    c:RegisterEffect(e2)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_CRIMSON_HOWL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
end

function s.spop(e,tp)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        Duel.NegateRelatedChain(tc)
        tc:RegisterEffect(Effect.CreateEffect(tc):SetType(EFFECT_TYPE_SINGLE):SetCode(EFFECT_DISABLE))
        tc:RegisterEffect(Effect.CreateEffect(tc):SetType(EFFECT_TYPE_SINGLE):SetCode(EFFECT_DISABLE_EFFECT))
    end
end
