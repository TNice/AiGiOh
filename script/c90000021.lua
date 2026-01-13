-- Crimson Howl Rising Dragon
local s,id=GetID()

function s.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,1,1)
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
	return c:IsType(TYPE_TUNER) and c:GetName():find("Crimson Howl")
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,2,nil,e,tp)
	for tc in aux.Next(g) do
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		Duel.DisableEffect(tc)
	end
end
