-- Codex Authority – Statutory Framework
dofile("repositories/aigioh/script/codex/amendment.lua")

local s, id = GetID()

Codex.COUNTER_STATUTE   = Codex.COUNTER_STATUTE   or 0xC0D2
Codex.COUNTER_PRECEDENT = Codex.COUNTER_PRECEDENT or 0xC0D1

-- Default Amendment menu (can be replaced later when you formalize the actual Amendments)
Codex.AMENDMENT_LIST = Codex.AMENDMENT_LIST or {1,2,3,4,5,6,7}

function s.initial_effect(c)
  -- Enable Precedent counters on this Field Spell
  c:EnableCounterPermit(Codex.COUNTER_PRECEDENT)

  ------------------------------------------------------------
  -- (0) Activate
  ------------------------------------------------------------
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetCode(EVENT_FREE_CHAIN)
  e0:SetOperation(s.activate_op)
  c:RegisterEffect(e0)

  ------------------------------------------------------------
  -- (1) If a card/effect is negated/disabled: +1 Precedent Counter
  -- Note: the engine-reliable portion is negated/disabled.
  -- Generic "resolves with no effect" is not reliably detectable for all effects.
  ------------------------------------------------------------
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e1:SetRange(LOCATION_FZONE)
  e1:SetCode(EVENT_CHAIN_NEGATED)
  e1:SetOperation(s.on_chain_failed)
  c:RegisterEffect(e1)

  local e2=e1:Clone()
  e2:SetCode(EVENT_CHAIN_DISABLED)
  c:RegisterEffect(e2)

  ------------------------------------------------------------
  -- (2) End Phase: if an Amendment was active this turn: +1 Precedent Counter
  -- IMPORTANT: CONTINUOUS (NOT TRIGGER) to avoid End Phase loop/prompt spam.
  ------------------------------------------------------------
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e3:SetRange(LOCATION_FZONE)
  e3:SetCode(EVENT_PHASE+PHASE_END)
  e3:SetOperation(s.endphase_op)
  c:RegisterEffect(e3)

  ------------------------------------------------------------
  -- (3) Once per turn (optional): remove 2 Precedent; lock 1 active Amendment
  -- Text normalization requested: "may" (so this is optional ignition)
  ------------------------------------------------------------
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,0)) -- harmless if you don't have string; description is optional
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetRange(LOCATION_FZONE)
  e4:SetCountLimit(1,id)
  e4:SetCost(s.lock_cost)
  e4:SetTarget(s.lock_tg)
  e4:SetOperation(s.lock_op)
  c:RegisterEffect(e4)

  ------------------------------------------------------------
  -- (4) If this card leaves the field: deactivate Amendments + clear its own hint
  -- Practical note: since Amendments are stored on this card instance, they effectively vanish
  -- when the Field Spell is gone. We still clear flags/hint explicitly to avoid any edge-case
  -- stale UI/state during leave-field processing.
  ------------------------------------------------------------
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e5:SetCode(EVENT_LEAVE_FIELD)
  e5:SetOperation(s.on_leave_field)
  c:RegisterEffect(e5)
end

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
function s.announce_amendment_id(tp)
	local list=Codex.AMENDMENT_LIST
	if not list or #list==0 then list={1,2,3,4,5,6,7} end
	return Duel.AnnounceNumber(tp, table.unpack(list))
end

function s.get_active_slots(tp)
	local fs=Codex.RequireFramework(tp)
	if not fs then return nil,0,0 end
	local a=Codex.GetAmendSlot(fs,1)
	local b=Codex.GetAmendSlot(fs,2)
	local maxs=Codex.GetMaxAmendSlots(tp)
	return fs,a,b,maxs
end

----------------------------------------------------------------
-- Activate: choose/activate 1 Amendment mode
----------------------------------------------------------------
function s.activate_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

	local new_id=s.announce_amendment_id(tp)
	if not new_id or new_id<=0 then return end

	-- Fill empty slot if possible, else replace slot A by default
	Codex.ActivateOrReplaceAmendment(tp, e, new_id, 1)
end

----------------------------------------------------------------
-- (1) Chain negated/disabled => add 1 Precedent Counter
----------------------------------------------------------------
function s.on_chain_failed(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsFaceup() then return end
	c:AddCounter(Codex.COUNTER_PRECEDENT,1)
end

----------------------------------------------------------------
-- (2) End Phase counter gain
----------------------------------------------------------------
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

----------------------------------------------------------------
-- (3) OPT lock effect (optional)
----------------------------------------------------------------
function s.lock_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsFaceup() and c:GetCounter(Codex.COUNTER_PRECEDENT)>=2
			and Codex.HasAnyActiveAmendment(tp)
	end
	c:RemoveCounter(tp, Codex.COUNTER_PRECEDENT, 2, REASON_COST)
end

function s.lock_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local fs,a,b,maxs=s.get_active_slots(tp)
		if not fs then return false end
		-- must have at least one active amendment
		return (a~=0) or (maxs>=2 and b~=0)
	end
end

function s.lock_op(e,tp,eg,ep,ev,re,r,rp)
	local fs,a,b,maxs=s.get_active_slots(tp)
	if not fs then return end
	if (a==0) and (maxs<2 or b==0) then return end

	-- Choose which active Amendment slot to lock (only matters if 2 slots exist and both active)
	local slot=1
	if maxs>=2 and a~=0 and b~=0 then
		-- Choose slot number (1 or 2). We avoid string dependencies.
		-- If player picks an invalid slot, we fall back to the other.
		local chosen=Duel.AnnounceNumber(tp,1,2)
		if chosen==2 then slot=2 else slot=1 end
	end

	-- Validate selection
	if slot==2 and (maxs<2 or b==0) then slot=1 end
	if slot==1 and a==0 and maxs>=2 and b~=0 then slot=2 end

	-- Lock chosen Amendment slot until End Phase.
	-- This prevents replacement, and also prevents negation via Codex.NegateAmendSlot (it fails if locked).
	Codex.LockAmendSlot(fs, slot, RESET_PHASE+PHASE_END)

	-- Update hint/UI (if you implemented UpdateFrameworkHint)
	if Codex.UpdateFrameworkHint then
		Codex.UpdateFrameworkHint(tp)
	end
end

----------------------------------------------------------------
-- (4) Leave-field cleanup
----------------------------------------------------------------
function s.on_leave_field(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c then return end

	-- Clear slot flags directly on this instance (SetAmendSlot requires an on-field framework)
	c:ResetFlagEffect(Codex.FLAG_AMEND_SLOT_A)
	c:ResetFlagEffect(Codex.FLAG_AMEND_SLOT_B)
	c:ResetFlagEffect(Codex.FLAG_AMEND_LOCK_A)
	c:ResetFlagEffect(Codex.FLAG_AMEND_LOCK_B)
	c:ResetFlagEffect(Codex.FLAG_AMEND_NEG_A)
	c:ResetFlagEffect(Codex.FLAG_AMEND_NEG_B)

	-- Clear the persistent numeric hint on the card instance (best-effort)
	-- Some clients ignore this after leaving; that's fine.
	c:SetHint(CHINT_NUMBER, 0)
end