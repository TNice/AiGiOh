
-- Crimson Howl Silence Wall
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ACTIVATE_COST)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetCondition(s.costcon)
    e1:SetCost(s.costop)
    c:RegisterEffect(e1)
end

function s.costcon(e,tp)
    return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO)
end

function s.costop(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(1-tp,300) end
    Duel.PayLPCost(1-tp,300)
end
