-- Codex Authority – Statutory Framework
if not Codex or not Codex.EVENT_AMEND_CHANGE then
	local ok =
		pcall(dofile, "expansions/script/codex/amendment.lua") or
		pcall(dofile, "script/codex/amendment.lua") or
		pcall(dofile, "expansions/AiGiOh/script/codex/amendment.lua") or
		pcall(dofile, "AiGiOh/script/codex/amendment.lua")
	if not ok then
		-- Hard fail with a useful message in logs
		error("Codex helper not found. Expected codex/amendment.lua under expansions/script or script/.")
	end
end

local s, id = GetID()

Codex.COUNTER_STATUTE   = Codex.COUNTER_STATUTE   or 0xC0D2
Codex.COUNTER_PRECEDENT = Codex.COUNTER_PRECEDENT or 0xC0D1

-- Default Amendment menu (can be replaced later when you formalize the actual Amendments)
Codex.AMENDMENT_LIST = Codex.AMENDMENT_LIST or {1,2,3,4,5,6,7}

function s.initial_effect(c)
  c:EnableCounterPermit(Codex.COUNTER_PRECEDENT)

  -- Activate: choose/activate 1 Amendment (mode)
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetOperation(s.activate_op)
  c:RegisterEffect(e1)

  -- (2) If a card/effect is negated/disabled: +1 Precedent Counter
  local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetOperation(s.on_chain_failed)
	c:RegisterEffect(e2)


  --- (3) End Phase: if an Amendment was active this turn: +1 Precedent Counter

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetOperation(s.endphase_op)
	c:RegisterEffect(e4)

end

-- Pick an Amendment ID from the menu
function s.announce_amendment_id(tp)
	local list=Codex.AMENDMENT_LIST
	if not list or #list==0 then list={1,2,3,4,5,6,7} end
	return Duel.AnnounceNumber(tp, table.unpack(list))
end


-- (1) On activation: activate/replace an Amendment mode on this Field Spell
function s.activate_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsRelateToEffect(e) then return end
	if not c:IsFaceup() then return end

	local new_id=s.announce_amendment_id(tp)
	if not new_id or new_id<=0 then return end

	-- Fill an empty Amendment slot if available; otherwise replace slot A by default.
	Codex.ActivateOrReplaceAmendment(tp, e, new_id, 1)
end

-- (2) Chain negated/disabled => add 1 Precedent Counter
function s.on_chain_failed(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsFaceup() then return end
	c:AddCounter(Codex.COUNTER_PRECEDENT,1)
end

-- (3) End Phase: if an Amendment was active this turn => add 1 Precedent Counter
function s.endphase_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsFaceup() then return end

	local p=c:GetControler()
	if Codex.WasAmendmentActiveThisTurn(p) then
		c:AddCounter(Codex.COUNTER_PRECEDENT,1)
	end

	-- Keep Amendment slots consistent with Tribunal presence (clears slot B if Tribunal is gone)
	Codex.ClearSlotBIfNoTribunal(p)
end