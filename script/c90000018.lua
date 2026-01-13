
-- Crimson Howl Refrain
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(function(c)
            return c:IsFaceup() and c:IsSetCard(SET_CRIMSON_HOWL)
        end,tp,LOCATION_MZONE,0,1,nil)
    end
end

function s.activate(e,tp)
    local tc=Duel.SelectMatchingCard(tp,function(c)
        return c:IsFaceup() and c:IsSetCard(SET_CRIMSON_HOWL)
    end,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if tc then
        Duel.SynchroSummon(tp,nil,tc)
    end
end
