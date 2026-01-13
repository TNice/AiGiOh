-- Crimson Howl Pulsecaller
local s,id=GetID()

function s.initial_effect(c)
	-- Special Summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(function(e,tp)
		return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_TUNER)
	end)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- If used as Synchro Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r) return r==REASON_SYNCHRO end)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

function s.spop(e,tp)
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

function s.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:GetLevel()<=2 and c:GetName():find("Crimson Howl")
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
