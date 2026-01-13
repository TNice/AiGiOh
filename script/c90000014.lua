
-- Crimson Howl Initiate
local s,id=GetID()
local SET_CRIMSON_HOWL=0x123

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.drcon)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)
end

function s.thfilter(c)
    return c:IsSetCard(SET_CRIMSON_HOWL) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thop(e,tp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return r==REASON_SYNCHRO and re:GetHandler():IsAttribute(ATTRIBUTE_DARK)
        and re:GetHandler():IsRace(RACE_DRAGON)
end

function s.drop(e,tp)
    Duel.Draw(tp,1,REASON_EFFECT)
    Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT)
end
