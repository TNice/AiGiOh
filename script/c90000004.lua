
-- Crimson Howl Blackout Pulse
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp)
    return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE) >
           Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end

function s.activate(e,tp)
    local diff=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE) -
               Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    while diff>0 and #g>0 do
        local sg=g:Select(tp,1,1,nil)
        Duel.Destroy(sg,REASON_EFFECT)
        g:Sub(sg)
        diff=diff-1
    end
end
