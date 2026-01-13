
-- Crimson Howl Supernova Dirge
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),
        aux.FilterBoolFunction(Card.GetLevel,10))
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
end

function s.op(e,tp)
    local c=e:GetHandler()
    if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
        Duel.Remove(Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD),POS_FACEUP,REASON_EFFECT)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetOperation(s.retop)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.retop(e,tp)
    local c=e:GetHandler()
    Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    local g=Duel.SelectMatchingCard(tp,function(c)
        return c:IsSetCard(SET_CRIMSON_HOWL)
    end,tp,LOCATION_GRAVE,0,1,2,nil)
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
