
-- Crimson Howl Mute Breaker
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(function(e,tp,eg,ep,ev,re) return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) end)
    e1:SetCost(s.cost)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)>0 then
        Duel.Remove(Duel.SelectMatchingCard(1-tp,aux.TRUE,1-tp,LOCATION_GRAVE,0,1,1,nil),
            POS_FACEUP,REASON_EFFECT)
    else
        Duel.NegateActivation(ev)
    end
end
