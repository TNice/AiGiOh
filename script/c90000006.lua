-- Crimson Howl Cataclysm Conductor
local s,id=GetID()

function s.initial_effect(c)
	aux.AddSynchroMixProcedure(
		c,
		aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),
		aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),
		aux.NonTuner(nil)
	)
	c:EnableReviveLimit()

	-- Cannot be destroyed by battle
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e0:SetValue(1)
	c:RegisterEffect(e0)

	-- If Synchro Summoned: destroy Defense Position monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	-- Can attack all monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
